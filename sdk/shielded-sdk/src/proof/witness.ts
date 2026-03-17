import { Utxo } from "../protocol/utxo.js";
import { MerkleTree, type MerkleProof } from "../protocol/merkle-tree.js";
import { FIELD_SIZE } from "../protocol/constants.js";
import { ethers } from "ethers";

/// Circuit witness inputs for the VAnchor transaction proof
export interface VAnchorWitnessInput {
  publicAmount: string;
  extDataHash: string;
  inputNullifier: string[];
  inAmount: string[];
  inPrivateKey: string[];
  inBlinding: string[];
  inPathIndices: string[];
  inPathElements: string[][];
  outputCommitment: string[];
  outChainID: string[];
  outAmount: string[];
  outPubkey: string[];
  outBlinding: string[];
  chainID: string;
  roots: string[];
}

/// External data hash for the VAnchor proof
export function computeExtDataHash(params: {
  recipient: string;
  extAmount: bigint;
  relayer: string;
  fee: bigint;
  refund: bigint;
  token: string;
  encryptedOutput1: Uint8Array;
  encryptedOutput2: Uint8Array;
}): bigint {
  const encoded = ethers.AbiCoder.defaultAbiCoder().encode(
    [
      "tuple(address recipient, int256 extAmount, address relayer, uint256 fee, uint256 refund, address token, bytes encryptedOutput1, bytes encryptedOutput2)",
    ],
    [
      {
        recipient: params.recipient,
        extAmount: params.extAmount,
        relayer: params.relayer,
        fee: params.fee,
        refund: params.refund,
        token: params.token,
        encryptedOutput1: params.encryptedOutput1,
        encryptedOutput2: params.encryptedOutput2,
      },
    ]
  );
  const hash = BigInt(ethers.keccak256(encoded));
  return hash % FIELD_SIZE;
}

/// Compute the publicAmount for the circuit:
/// publicAmount = extAmount - fee (mod FIELD_SIZE if negative)
export function computePublicAmount(
  extAmount: bigint,
  fee: bigint
): bigint {
  const publicAmount = extAmount - fee;
  return publicAmount >= 0n
    ? publicAmount
    : FIELD_SIZE - (-publicAmount % FIELD_SIZE);
}

/// Build witness inputs for the VAnchor Groth16 circuit
export async function buildWitnessInputs(params: {
  /// Input UTXOs being spent (2 or 16)
  inputs: Utxo[];
  /// Output UTXOs being created (always 2)
  outputs: [Utxo, Utxo];
  /// Merkle tree containing the input commitments
  tree: MerkleTree;
  /// External data hash
  extDataHash: bigint;
  /// External amount (positive=deposit, negative=withdraw)
  extAmount: bigint;
  /// Relayer fee
  fee: bigint;
  /// Chain ID for this VAnchor
  chainId: bigint;
  /// Roots from connected VAnchor instances (for cross-chain proofs)
  roots: bigint[];
}): Promise<VAnchorWitnessInput> {
  const { inputs, outputs, tree, extDataHash, extAmount, fee, chainId, roots } =
    params;

  const publicAmount = computePublicAmount(extAmount, fee);

  // Build input data
  const inputNullifiers: string[] = [];
  const inAmount: string[] = [];
  const inPrivateKey: string[] = [];
  const inBlinding: string[] = [];
  const inPathIndices: string[] = [];
  const inPathElements: string[][] = [];

  for (const input of inputs) {
    const nullifier = await input.getNullifier();
    inputNullifiers.push(nullifier.toString());
    inAmount.push(input.amount.toString());
    inPrivateKey.push(input.keypair.privateKey.toString());
    inBlinding.push(input.blinding.toString());

    if (input.index !== null && input.amount > 0n) {
      const proof: MerkleProof = await tree.proof(input.index);
      inPathIndices.push(proof.pathIndices.toString());
      inPathElements.push(proof.pathElements.map((e) => e.toString()));
    } else {
      // Zero amount inputs don't need valid Merkle proofs
      inPathIndices.push("0");
      inPathElements.push(
        Array(tree.levels)
          .fill(0)
          .map(() => "0")
      );
    }
  }

  // Build output data
  const outputCommitment: string[] = [];
  const outChainID: string[] = [];
  const outAmount: string[] = [];
  const outPubkey: string[] = [];
  const outBlinding: string[] = [];

  for (const output of outputs) {
    const commitment = await output.getCommitment();
    outputCommitment.push(commitment.toString());
    outChainID.push(output.chainId.toString());
    outAmount.push(output.amount.toString());
    outPubkey.push((await output.keypair.getPublicKey()).toString());
    outBlinding.push(output.blinding.toString());
  }

  return {
    publicAmount: publicAmount.toString(),
    extDataHash: extDataHash.toString(),
    inputNullifier: inputNullifiers,
    inAmount,
    inPrivateKey,
    inBlinding,
    inPathIndices,
    inPathElements,
    outputCommitment,
    outChainID,
    outAmount,
    outPubkey,
    outBlinding,
    chainID: chainId.toString(),
    roots: roots.map((r) => r.toString()),
  };
}
