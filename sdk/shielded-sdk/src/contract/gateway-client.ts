import { ethers } from "ethers";
import { Keypair } from "../protocol/keypair.js";
import { Utxo } from "../protocol/utxo.js";
import { MerkleTree } from "../protocol/merkle-tree.js";
import { typedChainId, ChainType } from "../protocol/constants.js";
import {
  buildWitnessInputs,
  computeExtDataHash,
  generateProof,
  encodeSolidityProof,
  type CircuitArtifacts,
} from "../proof/index.js";
import { encodeRootsBytes } from "../proof/roots.js";
import { syncLeaves } from "./leaf-sync.js";
import { NoteManager } from "../note/note-store.js";
import { noteToUtxo, utxoToNote, type NoteData } from "../note/note.js";
import { encryptUtxo } from "../protocol/encryption.js";

/// Configuration for the ShieldedGatewayClient
export interface GatewayClientConfig {
  /// Ethers provider (read-only operations)
  provider: ethers.Provider;
  /// ShieldedGateway contract address
  gatewayAddress: string;
  /// VAnchor pool address
  poolAddress: string;
  /// Wrapped token address
  wrappedTokenAddress: string;
  /// Chain ID
  chainId: number;
  /// Merkle tree levels (typically 30)
  treeLevels: number;
  /// Circuit artifacts for proof generation
  smallCircuit: CircuitArtifacts; // 2-input
  largeCircuit?: CircuitArtifacts; // 16-input (optional)
}

// Minimal ABIs for contract interaction
const GATEWAY_ABI = [
  "function shieldedRequestService(tuple(bytes proof, bytes auxPublicInputs, bytes externalData, bytes publicInputs, bytes encryptions) anchorProof, tuple(uint64 blueprintId, address[] operators, bytes config, address[] permittedCallers, uint64 ttl, uint8 confidentiality) params) external payable returns (uint64)",
  "function shieldedFundService(tuple(bytes proof, bytes auxPublicInputs, bytes externalData, bytes publicInputs, bytes encryptions) anchorProof, uint64 serviceId) external payable",
  "function shieldedFundCredits(tuple(bytes proof, bytes auxPublicInputs, bytes externalData, bytes publicInputs, bytes encryptions) anchorProof, bytes32 commitment, address spendingKey) external payable",
  "function getPool(address wrappedToken) external view returns (address)",
];

const VANCHOR_ABI = [
  "function transact(bytes, bytes, tuple(address,int256,address,uint256,uint256,address), tuple(bytes,bytes,uint256[],uint256[2],uint256,uint256), tuple(bytes,bytes)) external payable",
  "function getLastRoot() external view returns (uint256)",
  "function getLatestNeighborEdges() external view returns (tuple(uint256 chainID, uint256 root, uint256 latestLeafIndex, bytes32 srcResourceID)[])",
  "function getNextIndex() external view returns (uint32)",
  "event NewCommitment(uint256 commitment, uint256 subTreeIndex, uint256 leafIndex, bytes encryptedOutput)",
];

const ERC20_ABI = [
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function balanceOf(address account) external view returns (uint256)",
];

/// High-level client for interacting with the ShieldedGateway.
///
/// Handles: UTXO selection, proof generation, transaction encoding, and note management.
export class ShieldedGatewayClient {
  readonly config: GatewayClientConfig;
  private _tree: MerkleTree | null = null;

  constructor(config: GatewayClientConfig) {
    this.config = config;
  }

  /// Deposit tokens into the VAnchor pool (public -> shielded).
  /// This is a standard VAnchor deposit — the user's identity is visible.
  /// Privacy begins AFTER the deposit.
  async deposit(params: {
    signer: ethers.Signer;
    keypair: Keypair;
    amount: bigint;
    noteManager?: NoteManager;
  }): Promise<NoteData> {
    const { signer, keypair, amount, noteManager } = params;
    const chainId = typedChainId(ChainType.EVM, this.config.chainId);

    // Create the output UTXO
    const output = Utxo.create({ chainId, amount, keypair });
    // Create a zero-change output
    const changeOutput = await Utxo.zero(chainId, keypair);

    // For deposits, inputs are zero UTXOs
    const zeroInput1 = await Utxo.zero(chainId, keypair);
    const zeroInput2 = await Utxo.zero(chainId, keypair);
    zeroInput1.index = 0;
    zeroInput2.index = 0;

    // Get the current tree state
    const tree = await this._getTree();

    // Get roots for cross-chain proof
    const roots = await this._getRoots();

    // Encrypt outputs for UTXO discovery
    const encryptedOutput1 = await encryptUtxo(output);
    const encryptedOutput2 = await encryptUtxo(changeOutput);

    // Build external data
    const signerAddress = await signer.getAddress();
    const extDataHash = computeExtDataHash({
      recipient: ethers.ZeroAddress,
      extAmount: amount,
      relayer: ethers.ZeroAddress,
      fee: 0n,
      refund: 0n,
      token: this.config.wrappedTokenAddress,
      encryptedOutput1,
      encryptedOutput2,
    });

    // Build witness and generate proof
    const witnessInput = await buildWitnessInputs({
      inputs: [zeroInput1, zeroInput2],
      outputs: [output, changeOutput],
      tree,
      extDataHash,
      extAmount: amount,
      fee: 0n,
      chainId,
      roots,
    });

    const proof = await generateProof(witnessInput, this.config.smallCircuit);
    const solidityProof = await encodeSolidityProof(proof);

    // Approve and transact
    const token = new ethers.Contract(
      this.config.wrappedTokenAddress,
      ERC20_ABI,
      signer
    );
    await token.approve(this.config.poolAddress, amount);

    const pool = new ethers.Contract(
      this.config.poolAddress,
      VANCHOR_ABI,
      signer
    );

    const tx = await pool.transact(
      solidityProof.proofBytes,
      new Uint8Array(0),
      {
        recipient: ethers.ZeroAddress,
        extAmount: amount,
        relayer: ethers.ZeroAddress,
        fee: 0,
        refund: 0,
        token: this.config.wrappedTokenAddress,
      },
      {
        roots: encodeRootsBytes(witnessInput.roots.map(BigInt)),
        extensionRoots: new Uint8Array(0),
        inputNullifiers: witnessInput.inputNullifier.map(BigInt),
        outputCommitments: witnessInput.outputCommitment.map(BigInt),
        publicAmount: BigInt(witnessInput.publicAmount),
        extDataHash,
      },
      {
        encryptedOutput1,
        encryptedOutput2,
      }
    );

    const receipt = await tx.wait();

    // Find the leaf index from NewCommitment event
    const commitment = await output.getCommitment();
    let leafIndex: number | undefined;
    for (const log of receipt.logs) {
      try {
        const parsed = pool.interface.parseLog(log);
        if (
          parsed?.name === "NewCommitment" &&
          parsed.args.commitment === commitment
        ) {
          leafIndex = Number(parsed.args.leafIndex);
          break;
        }
      } catch {
        // Skip non-matching logs
      }
    }

    // Create note
    const note = utxoToNote(
      output,
      this.config.chainId,
      this.config.chainId,
      "WRAPPED",
      this.config.poolAddress
    );
    if (leafIndex !== undefined) {
      note.index = leafIndex;
    }

    // Store note if manager provided
    if (noteManager) {
      await noteManager.addNote(note);
    }

    return note;
  }

  /// Build the VAnchorProof struct for a shielded withdrawal to the gateway.
  /// This is the core function — it selects UTXOs, generates the ZK proof,
  /// and encodes everything for the ShieldedGateway contract.
  async buildShieldedWithdrawal(params: {
    keypair: Keypair;
    amount: bigint;
    noteManager: NoteManager;
  }): Promise<{
    anchorProof: {
      proof: Uint8Array;
      auxPublicInputs: Uint8Array;
      externalData: Uint8Array;
      publicInputs: Uint8Array;
      encryptions: Uint8Array;
    };
    spentNotes: NoteData[];
    changeNote: NoteData | null;
  }> {
    const { keypair, amount, noteManager } = params;
    const chainId = typedChainId(ChainType.EVM, this.config.chainId);

    // Select notes to spend
    const { selected, change } = noteManager.selectNotesFifo(
      this.config.chainId,
      this.config.poolAddress,
      amount
    );

    // Convert selected notes to UTXOs
    const inputs = selected.map(noteToUtxo);

    // Pad inputs to 2 or 16
    while (inputs.length < 2) {
      const zero = new Utxo({ chainId, amount: 0n, keypair });
      zero.index = 0;
      inputs.push(zero);
    }

    // Create output UTXOs
    const changeOutput = Utxo.create({ chainId, amount: change, keypair });
    const dummyOutput = await Utxo.zero(chainId, keypair);

    // Build tree from on-chain state
    const tree = await this._getTree();
    const roots = await this._getRoots();

    // Encrypt outputs for UTXO discovery
    const encryptedOutput1 = await encryptUtxo(changeOutput);
    const encryptedOutput2 = await encryptUtxo(dummyOutput);

    // External data: withdraw to the gateway
    const gateway = this.config.gatewayAddress;
    const extDataHash = computeExtDataHash({
      recipient: gateway,
      extAmount: -amount,
      relayer: ethers.ZeroAddress,
      fee: 0n,
      refund: 0n,
      token: this.config.wrappedTokenAddress,
      encryptedOutput1,
      encryptedOutput2,
    });

    // Build witness and generate proof
    const witnessInput = await buildWitnessInputs({
      inputs: inputs.slice(0, 2),
      outputs: [changeOutput, dummyOutput],
      tree,
      extDataHash,
      extAmount: -amount,
      fee: 0n,
      chainId,
      roots,
    });

    const zkProof = await generateProof(
      witnessInput,
      this.config.smallCircuit
    );
    const solidityProof = await encodeSolidityProof(zkProof);

    // Encode the structs for the gateway
    const abiCoder = ethers.AbiCoder.defaultAbiCoder();

    const externalData = abiCoder.encode(
      [
        "tuple(address recipient, int256 extAmount, address relayer, uint256 fee, uint256 refund, address token)",
      ],
      [
        {
          recipient: gateway,
          extAmount: -amount,
          relayer: ethers.ZeroAddress,
          fee: 0,
          refund: 0,
          token: this.config.wrappedTokenAddress,
        },
      ]
    );

    const publicInputs = abiCoder.encode(
      [
        "tuple(bytes roots, bytes extensionRoots, uint256[] inputNullifiers, uint256[2] outputCommitments, uint256 publicAmount, uint256 extDataHash)",
      ],
      [
        {
          roots: encodeRootsBytes(witnessInput.roots.map(BigInt)),
          extensionRoots: new Uint8Array(0),
          inputNullifiers: witnessInput.inputNullifier.map(BigInt),
          outputCommitments: witnessInput.outputCommitment.map(BigInt),
          publicAmount: BigInt(witnessInput.publicAmount),
          extDataHash,
        },
      ]
    );

    const encryptions = abiCoder.encode(
      ["tuple(bytes encryptedOutput1, bytes encryptedOutput2)"],
      [
        {
          encryptedOutput1,
          encryptedOutput2,
        },
      ]
    );

    // Update note manager
    for (const note of selected) {
      await noteManager.removeNote(note);
    }

    let changeNote: NoteData | null = null;
    if (change > 0n) {
      changeNote = utxoToNote(
        changeOutput,
        this.config.chainId,
        this.config.chainId,
        "WRAPPED",
        this.config.poolAddress
      );
      await noteManager.addNote(changeNote);
    }

    return {
      anchorProof: {
        proof: solidityProof.proofBytes,
        auxPublicInputs: new Uint8Array(0),
        externalData: ethers.getBytes(externalData),
        publicInputs: ethers.getBytes(publicInputs),
        encryptions: ethers.getBytes(encryptions),
      },
      spentNotes: selected,
      changeNote,
    };
  }

  /// Fund a shielded credit account via the gateway.
  async fundCredits(params: {
    signer: ethers.Signer;
    keypair: Keypair;
    amount: bigint;
    commitment: string;
    spendingKey: string;
    noteManager: NoteManager;
  }): Promise<ethers.TransactionReceipt> {
    const { signer, keypair, amount, commitment, spendingKey, noteManager } = params;

    const { anchorProof } = await this.buildShieldedWithdrawal({
      keypair,
      amount,
      noteManager,
    });

    const gateway = new ethers.Contract(
      this.config.gatewayAddress,
      GATEWAY_ABI,
      signer
    );

    const tx = await gateway.shieldedFundCredits(anchorProof, commitment, spendingKey);
    return tx.wait();
  }

  /// Fetch the on-chain Merkle tree state
  private async _getTree(): Promise<MerkleTree> {
    if (this._tree) return this._tree;
    this._tree = await MerkleTree.create(this.config.treeLevels);
    // Sync existing leaves from on-chain events
    try {
      await syncLeaves(this.config.provider, this.config.poolAddress, this._tree);
    } catch {
      // If sync fails (e.g., no events yet), continue with empty tree
    }
    return this._tree;
  }

  /// Fetch cross-chain roots for the proof
  private async _getRoots(): Promise<bigint[]> {
    const pool = new ethers.Contract(
      this.config.poolAddress,
      VANCHOR_ABI,
      this.config.provider
    );
    const localRoot: bigint = await pool.getLastRoot();
    const neighborEdges = await pool.getLatestNeighborEdges();
    return [localRoot, ...neighborEdges.map((e: { root: bigint }) => e.root)];
  }
}
