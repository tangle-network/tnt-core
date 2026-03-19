import * as snarkjs from "snarkjs";
import type { VAnchorWitnessInput } from "./witness.js";

/// ZK circuit artifacts needed for proof generation
export interface CircuitArtifacts {
  /// Path to the circuit WASM file (witness calculator)
  wasmPath: string;
  /// Path to the proving key (zkey)
  zkeyPath: string;
}

/// A generated Groth16 proof with public signals
export interface Groth16Proof {
  proof: snarkjs.Groth16Proof;
  publicSignals: string[];
}

/// Solidity-encoded proof components
export interface SolidityProof {
  /// The proof bytes (a, b, c concatenated)
  proofBytes: Uint8Array;
  /// Encoded public inputs
  publicInputs: string[];
}

/// Generate a Groth16 proof for a VAnchor transaction
export async function generateProof(
  witnessInput: VAnchorWitnessInput,
  artifacts: CircuitArtifacts
): Promise<Groth16Proof> {
  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    witnessInput as unknown as snarkjs.CircuitSignals,
    artifacts.wasmPath,
    artifacts.zkeyPath
  );
  return { proof, publicSignals };
}

/// Verify a Groth16 proof locally (for testing / client-side validation)
export async function verifyProof(
  proof: Groth16Proof,
  verificationKeyPath: string
): Promise<boolean> {
  const { readFileSync } = await import("fs");
  const vKey = JSON.parse(readFileSync(verificationKeyPath, "utf-8"));
  return snarkjs.groth16.verify(vKey, proof.publicSignals, proof.proof);
}

/// Encode a proof for Solidity contract consumption
export async function encodeSolidityProof(
  proof: Groth16Proof
): Promise<SolidityProof> {
  const calldata = await snarkjs.groth16.exportSolidityCallData(
    proof.proof,
    proof.publicSignals
  );

  // Parse the calldata string
  // Format: ["a[0]","a[1]"],[["b[0][0]","b[0][1]"],["b[1][0]","b[1][1]"]],["c[0]","c[1]"],["input[0]",...]
  const [a, b, c, inputs] = JSON.parse(`[${calldata}]`);

  // Pack proof components into bytes
  // a = [2 x uint256], b = [2 x 2 x uint256], c = [2 x uint256] = 8 x 32 bytes = 256 bytes
  const proofElements: bigint[] = [
    BigInt(a[0]),
    BigInt(a[1]),
    BigInt(b[0][0]),
    BigInt(b[0][1]),
    BigInt(b[1][0]),
    BigInt(b[1][1]),
    BigInt(c[0]),
    BigInt(c[1]),
  ];

  const proofBytes = new Uint8Array(256);
  for (let i = 0; i < 8; i++) {
    const bytes = proofElements[i]
      .toString(16)
      .padStart(64, "0");
    for (let j = 0; j < 32; j++) {
      proofBytes[i * 32 + j] = parseInt(bytes.substring(j * 2, j * 2 + 2), 16);
    }
  }

  return {
    proofBytes,
    publicInputs: inputs.map(String),
  };
}
