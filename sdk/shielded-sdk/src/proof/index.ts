export {
  buildWitnessInputs,
  computeExtDataHash,
  computePublicAmount,
} from "./witness.js";
export type { VAnchorWitnessInput } from "./witness.js";
export {
  generateProof,
  verifyProof,
  encodeSolidityProof,
} from "./prover.js";
export type {
  CircuitArtifacts,
  Groth16Proof,
  SolidityProof,
} from "./prover.js";
export { encodeRoots, encodeRootsBytes, decodeRootsBytes } from "./roots.js";
export { getCircuitArtifacts, downloadIfMissing } from "./artifacts.js";
