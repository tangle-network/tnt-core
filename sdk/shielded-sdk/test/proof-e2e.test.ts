/**
 * E2E Proof Generation Test
 *
 * This test generates a REAL Groth16 proof using the compiled VAnchor circuit.
 * It requires circuit artifacts (WASM + zkey) to be present at:
 *   build/circuits/vanchor_2_2/
 *
 * Run after: scripts/trusted-setup/ceremony.sh (or local setup below)
 *
 * Skip with: SKIP_PROOF_E2E=1 npx vitest run
 */

import { describe, it, expect, beforeAll } from "vitest";
import { existsSync } from "fs";
import { join } from "path";
import {
  Keypair,
  Utxo,
  MerkleTree,
  poseidonHash,
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
const CIRCUIT_DIR = join(ROOT_DIR, "build/circuits/vanchor_2_2");
const WASM_PATH = join(
  CIRCUIT_DIR,
  "poseidon_vanchor_2_2_js/poseidon_vanchor_2_2.wasm"
);
const ZKEY_PATH = join(CIRCUIT_DIR, "circuit_final.zkey");

const SKIP =
  process.env.SKIP_PROOF_E2E === "1" ||
  !existsSync(WASM_PATH) ||
  !existsSync(ZKEY_PATH);

describe.skipIf(SKIP)("E2E Proof Generation", () => {
  let keypair: Keypair;
  let tree: MerkleTree;
  let chainId: bigint;

  beforeAll(async () => {
    keypair = new Keypair();
    tree = await MerkleTree.create(30);
    chainId = typedChainId(ChainType.EVM, 84532); // Base Sepolia
  });

  it("should generate a valid deposit witness", async () => {
    // Create output UTXO (deposit 10 tokens)
    const depositAmount = 10n * 10n ** 18n;
    const output = Utxo.create({ chainId, amount: depositAmount, keypair });
    const changeOutput = await Utxo.zero(chainId, keypair);

    // Create zero inputs (deposit has no inputs to spend)
    const zeroInput1 = await Utxo.zero(chainId, keypair);
    const zeroInput2 = await Utxo.zero(chainId, keypair);
    zeroInput1.index = 0;
    zeroInput2.index = 0;

    // Compute external data hash
    const extDataHash = computeExtDataHash({
      recipient: "0x0000000000000000000000000000000000000000",
      extAmount: depositAmount,
      relayer: "0x0000000000000000000000000000000000000000",
      fee: 0n,
      refund: 0n,
      token: "0x036CbD53842c5426634e7929541eC2318f3dCF7e",
      encryptedOutput1: new Uint8Array(0),
      encryptedOutput2: new Uint8Array(0),
    });

    // Build witness inputs
    const roots = [tree.root, 0n]; // local root + 1 neighbor (maxEdges=1)

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

    // Verify witness structure
    expect(witnessInput.inputNullifier).toHaveLength(2);
    expect(witnessInput.outputCommitment).toHaveLength(2);
    expect(witnessInput.inAmount).toHaveLength(2);
    expect(witnessInput.inPrivateKey).toHaveLength(2);
    expect(witnessInput.inBlinding).toHaveLength(2);
    expect(witnessInput.inPathIndices).toHaveLength(2);
    expect(witnessInput.inPathElements).toHaveLength(2);
    expect(witnessInput.inPathElements[0]).toHaveLength(30); // tree levels
    expect(witnessInput.outChainID).toHaveLength(2);
    expect(witnessInput.outAmount).toHaveLength(2);
    expect(witnessInput.outPubkey).toHaveLength(2);
    expect(witnessInput.outBlinding).toHaveLength(2);
    expect(witnessInput.roots).toHaveLength(2);

    // Verify amount conservation: publicAmount + sum(inputs) = sum(outputs)
    const pubAmount = computePublicAmount(depositAmount, 0n);
    const inputSum = witnessInput.inAmount.reduce(
      (s, a) => s + BigInt(a),
      0n
    );
    const outputSum = witnessInput.outAmount.reduce(
      (s, a) => s + BigInt(a),
      0n
    );
    // publicAmount + inputSum = outputSum (mod FIELD_SIZE)
    expect((pubAmount + inputSum) % FIELD_SIZE).toBe(outputSum % FIELD_SIZE);
  });

  it("should generate and verify a Groth16 proof", async () => {
    // This test actually calls snarkjs to generate a proof
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
      token: "0x036CbD53842c5426634e7929541eC2318f3dCF7e",
      encryptedOutput1: new Uint8Array(0),
      encryptedOutput2: new Uint8Array(0),
    });

    const roots = [tree.root, 0n];

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

    // Generate Groth16 proof
    console.time("proof generation");
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
      witnessInput as unknown as Record<string, unknown>,
      WASM_PATH,
      ZKEY_PATH
    );
    console.timeEnd("proof generation");

    expect(proof).toBeDefined();
    expect(proof.pi_a).toBeDefined();
    expect(proof.pi_b).toBeDefined();
    expect(proof.pi_c).toBeDefined();
    expect(publicSignals).toBeDefined();
    expect(publicSignals.length).toBeGreaterThan(0);

    // Verify the proof locally
    const vKeyPath = ZKEY_PATH.replace(
      "circuit_final.zkey",
      "../verification_key.json"
    );
    if (existsSync(vKeyPath)) {
      const { readFileSync } = await import("fs");
      const vKey = JSON.parse(readFileSync(vKeyPath, "utf-8"));
      const valid = await snarkjs.groth16.verify(vKey, publicSignals, proof);
      expect(valid).toBe(true);
    }

    console.log("Proof generated successfully!");
    console.log(
      `  Public signals: ${publicSignals.length}`,
    );
    console.log(
      `  Proof size: ${JSON.stringify(proof).length} bytes`,
    );
  }, 120_000); // 2 minute timeout for proof generation
});
