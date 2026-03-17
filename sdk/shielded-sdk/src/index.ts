// Core cryptographic primitives
export {
  Keypair,
  Utxo,
  MerkleTree,
  poseidonHash,
  poseidonHash2,
  FIELD_SIZE,
  ZERO_VALUE,
  ChainType,
  typedChainId,
  parseTypedChainId,
  encryptUtxo,
  decryptUtxo,
} from "./protocol/index.js";
export type { UtxoConfig, MerkleProof } from "./protocol/index.js";

// ZK proof generation
export {
  buildWitnessInputs,
  computeExtDataHash,
  computePublicAmount,
  generateProof,
  verifyProof,
  encodeSolidityProof,
  encodeRoots,
  encodeRootsBytes,
  decodeRootsBytes,
  getCircuitArtifacts,
  downloadIfMissing,
} from "./proof/index.js";
export type {
  VAnchorWitnessInput,
  CircuitArtifacts,
  Groth16Proof,
  SolidityProof,
} from "./proof/index.js";

// Note management
export {
  serializeNote,
  deserializeNote,
  noteToUtxo,
  utxoToNote,
  NoteManager,
  MemoryNoteStorage,
  FileNoteStorage,
} from "./note/index.js";
export type { NoteData, NoteStorage } from "./note/index.js";

// Contract interaction
export { ShieldedGatewayClient, syncLeaves, discoverNotes } from "./contract/index.js";
export type { GatewayClientConfig } from "./contract/index.js";
export type { LeafSyncResult, DiscoveredNote } from "./contract/index.js";

// Credits (anonymous pay-per-use)
export {
  ShieldedCreditsClient,
  generateCreditKeys,
  signSpendAuthorization,
  signWithdrawal,
} from "./contract/index.js";
export type { CreditKeys, CreditAccountState, SignedSpendAuth } from "./contract/index.js";
