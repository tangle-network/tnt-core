/**
 * E2E Proof Generation Test — 8-edge circuit (production config)
 *
 * Tests the poseidon_vanchor_2_8 circuit with maxEdges=7.
 * This is the actual circuit used in deployment (supports up to 8 chains).
 * Empty edge slots are filled with the zero hash.
 */

import { describe, it, expect, beforeAll } from "vitest";
import { existsSync, readFileSync } from "fs";
import { join } from "path";
import {
  Keypair,
  Utxo,
  MerkleTree,
  ChainType,
  typedChainId,
  FIELD_SIZE,
} from "../src/protocol/index.js";
import {
  buildWitnessInputs,
  computeExtDataHash,
  computePublicAmount,
} from "../src/proof/witness.js";

const ROOT_DIR = join(import.meta.dirname, "../../../");
const CIRCUIT_DIR = join(ROOT_DIR, "build/circuits/vanchor_2_8");
const WASM_PATH = join(
  CIRCUIT_DIR,
  "poseidon_vanchor_2_8_js/poseidon_vanchor_2_8.wasm"
);
const ZKEY_PATH = join(CIRCUIT_DIR, "circuit_final.zkey");
const VKEY_PATH = join(CIRCUIT_DIR, "verification_key.json");

const SKIP =
  process.env.SKIP_PROOF_E2E === "1" ||
  !existsSync(WASM_PATH) ||
  !existsSync(ZKEY_PATH);

describe.skipIf(SKIP)("8-Edge Proof Generation (Production Circuit)", () => {
  let keypair: Keypair;
  let tree: MerkleTree;
  let chainId: bigint;

  // The zero hash for the outer tree level — must match what LinkableAnchor uses
  // for empty edge slots. This is getZeroHash(outerLevels - 1) = zeros(29) from PoseidonHasher.
  // For a 30-level tree, outerLevels = 30, so we need zeros(29).
  // In the circuit, empty roots are just 0 (the circuit's zeroLeaf default).
  // On-chain, LinkableAnchor.getZeroHash returns PoseidonHasher.zeros(29).
  // For the test, we use 0 since the circuit accepts it for disabled edges.
  const EMPTY_ROOT = 0n;

  beforeAll(async () => {
    keypair = new Keypair();
    tree = await MerkleTree.create(30);
    chainId = typedChainId(ChainType.EVM, 8453); // Base mainnet
  });

  it("should generate deposit proof with 8 roots (7 empty)", async () => {
    const snarkjs = await import("snarkjs");

    const depositAmount = 10n * 10n ** 18n;
    const output = Utxo.create({ chainId, amount: depositAmount, keypair });
    const changeOutput = await Utxo.zero(chainId, keypair);

    const zeroInput1 = await Utxo.zero(chainId, keypair);
    const zeroInput2 = await Utxo.zero(chainId, keypair);
    zeroInput1.index = 0;
    zeroInput2.index = 0;

    const extDataHash = computeExtDataHash({
      recipient: "0x0000000000000000000000000000000000000000",
      extAmount: depositAmount,
      relayer: "0x0000000000000000000000000000000000000000",
      fee: 0n,
      refund: 0n,
      token: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913", // USDC on Base
      encryptedOutput1: new Uint8Array(0),
      encryptedOutput2: new Uint8Array(0),
    });

    // 8 roots: 1 local + 7 empty neighbors (all zeros for unoccupied edge slots)
    const roots = [
      tree.root,
      EMPTY_ROOT, EMPTY_ROOT, EMPTY_ROOT, EMPTY_ROOT,
      EMPTY_ROOT, EMPTY_ROOT, EMPTY_ROOT,
    ];

    const witnessInput = await buildWitnessInputs({
      inputs: [zeroInput1, zeroInput2],
      outputs: [output, changeOutput],
      tree,
      extDataHash,
      extAmount: depositAmount,
      fee: 0n,
      chainId,
      roots,
    });

    // Verify 8 roots in witness
    expect(witnessInput.roots).toHaveLength(8);

    // Generate proof
    console.time("8-edge proof generation");
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
      witnessInput as unknown as Record<string, unknown>,
      WASM_PATH,
      ZKEY_PATH
    );
    console.timeEnd("8-edge proof generation");

    expect(proof).toBeDefined();
    expect(publicSignals.length).toBeGreaterThan(0);

    // Verify locally
    const vKey = JSON.parse(readFileSync(VKEY_PATH, "utf-8"));
    const valid = await snarkjs.groth16.verify(vKey, publicSignals, proof);
    expect(valid).toBe(true);

    console.log(`8-edge proof: ${publicSignals.length} public signals, ${JSON.stringify(proof).length} bytes`);
  }, 120_000);

  it("should generate proof with 4 populated edges + 3 empty", async () => {
    const snarkjs = await import("snarkjs");

    const depositAmount = 5n * 10n ** 18n;
    const output = Utxo.create({ chainId, amount: depositAmount, keypair });
    const changeOutput = await Utxo.zero(chainId, keypair);

    const zeroInput1 = await Utxo.zero(chainId, keypair);
    const zeroInput2 = await Utxo.zero(chainId, keypair);
    zeroInput1.index = 0;
    zeroInput2.index = 0;

    const extDataHash = computeExtDataHash({
      recipient: "0x0000000000000000000000000000000000000000",
      extAmount: depositAmount,
      relayer: "0x0000000000000000000000000000000000000000",
      fee: 0n,
      refund: 0n,
      token: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
      encryptedOutput1: new Uint8Array(0),
      encryptedOutput2: new Uint8Array(0),
    });

    // Simulate 4 connected chains (Ethereum, Arbitrum, Hyperliquid, BSC)
    // with fake non-zero roots, + 3 empty slots
    const fakeRoot = 12345678901234567890n;
    const roots = [
      tree.root,       // Base (self)
      fakeRoot,        // Ethereum
      fakeRoot + 1n,   // Arbitrum
      fakeRoot + 2n,   // Hyperliquid
      fakeRoot + 3n,   // BSC
      EMPTY_ROOT,      // empty
      EMPTY_ROOT,      // empty
      EMPTY_ROOT,      // empty
    ];

    const witnessInput = await buildWitnessInputs({
      inputs: [zeroInput1, zeroInput2],
      outputs: [output, changeOutput],
      tree,
      extDataHash,
      extAmount: depositAmount,
      fee: 0n,
      chainId,
      roots,
    });

    console.time("4-edge proof generation");
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
      witnessInput as unknown as Record<string, unknown>,
      WASM_PATH,
      ZKEY_PATH
    );
    console.timeEnd("4-edge proof generation");

    const vKey = JSON.parse(readFileSync(VKEY_PATH, "utf-8"));
    const valid = await snarkjs.groth16.verify(vKey, publicSignals, proof);
    expect(valid).toBe(true);

    console.log("4 populated + 3 empty edges: proof valid!");
  }, 120_000);
});
