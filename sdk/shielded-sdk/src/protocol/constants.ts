/// BN254 scalar field size (used by Poseidon and the Groth16 circuits)
export const FIELD_SIZE = BigInt(
  "21888242871839275222246405745257275088548364400416034343698204186575808495617"
);

/// Zero value for empty Merkle tree leaves: keccak256("tornado") % FIELD_SIZE
export const ZERO_VALUE = BigInt(
  "21663839004416932945382355908790599225266501822907911457504978515578255421292"
);

/// Chain type prefixes for typed chain IDs
export enum ChainType {
  EVM = 0x0100,
  Substrate = 0x0200,
}

/// Compute a typed chain ID: (chainType << 32) | chainId
export function typedChainId(chainType: ChainType, chainId: number): bigint {
  return (BigInt(chainType) << 32n) | BigInt(chainId);
}

/// Parse a typed chain ID back to its components
export function parseTypedChainId(typed: bigint): {
  chainType: ChainType;
  chainId: number;
} {
  const chainId = Number(typed & 0xffffffffn);
  const chainType = Number(typed >> 32n) as ChainType;
  return { chainType, chainId };
}
