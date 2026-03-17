import { FIELD_SIZE } from "./constants.js";

type PoseidonFn = (inputs: (bigint | string)[]) => bigint;

let poseidonFn: PoseidonFn | null = null;

/// Initialize the Poseidon hash function (lazy singleton)
async function getPoseidon(): Promise<PoseidonFn> {
  if (!poseidonFn) {
    // circomlibjs is a CJS module; dynamic import avoids ESM interop issues.
    // In v0.0.x the module exports `poseidon` directly (no builder).
    // In v0.1.x+ the module exports `buildPoseidon` which returns a
    // poseidon instance with an `.F` field.
    // @ts-expect-error circomlibjs doesn't ship types
    const mod = await import("circomlibjs");

    if (typeof mod.buildPoseidon === "function") {
      // v0.1.x API
      const instance = await mod.buildPoseidon();
      poseidonFn = (inputs: (bigint | string)[]) => {
        const raw = instance(inputs.map((x) => x.toString()));
        return BigInt(instance.F.toString(raw));
      };
    } else {
      // v0.0.x API — poseidon returns bigint directly
      const directFn = mod.poseidon ?? mod.default?.poseidon;
      poseidonFn = (inputs: (bigint | string)[]) =>
        BigInt(directFn(inputs.map((x) => x.toString())));
    }
  }
  return poseidonFn;
}

/// Poseidon hash of arbitrary inputs, returned as bigint in the BN254 field
export async function poseidonHash(inputs: bigint[]): Promise<bigint> {
  const poseidon = await getPoseidon();
  return poseidon(inputs) % FIELD_SIZE;
}

/// Poseidon hash of exactly 2 inputs (common for Merkle tree nodes)
export async function poseidonHash2(
  left: bigint,
  right: bigint
): Promise<bigint> {
  return poseidonHash([left, right]);
}
