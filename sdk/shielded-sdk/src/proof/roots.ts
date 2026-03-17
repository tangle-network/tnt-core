import { ethers } from "ethers";

/// Encode roots for the VAnchor circuit.
/// Returns a flat array of bigints: [localRoot, ...neighborRoots] padded to maxEdges+1.
export function encodeRoots(
  localRoot: bigint,
  neighborRoots: bigint[],
  maxEdges: number
): bigint[] {
  if (neighborRoots.length > maxEdges) {
    throw new Error(
      `Too many neighbor roots: ${neighborRoots.length} > maxEdges ${maxEdges}`
    );
  }
  const roots: bigint[] = [localRoot];
  for (let i = 0; i < maxEdges; i++) {
    roots.push(i < neighborRoots.length ? neighborRoots[i] : 0n);
  }
  return roots;
}

/// ABI-encode roots as bytes (uint256[] packed) for the Solidity PublicInputs.roots field.
export function encodeRootsBytes(roots: bigint[]): Uint8Array {
  const encoded = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[]"],
    [roots]
  );
  return ethers.getBytes(encoded);
}

/// Decode roots from ABI-encoded bytes back to bigints.
export function decodeRootsBytes(data: Uint8Array, length: number): bigint[] {
  const [decoded] = ethers.AbiCoder.defaultAbiCoder().decode(
    ["uint256[]"],
    data
  );
  const roots: bigint[] = [];
  for (let i = 0; i < length; i++) {
    roots.push(BigInt(decoded[i]));
  }
  return roots;
}
