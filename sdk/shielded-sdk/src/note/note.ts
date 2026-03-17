import { Keypair } from "../protocol/keypair.js";
import { Utxo } from "../protocol/utxo.js";
import { typedChainId, ChainType } from "../protocol/constants.js";

/// A serializable note representing a shielded deposit.
/// Format: tangle://v1:vanchor/{sourceChainId}:{targetChainId}/{amount}/{tokenSymbol}?secrets={chainId}:{amount}:{privKey}:{blinding}
export interface NoteData {
  /// Source chain where the deposit was made
  sourceChainId: number;
  /// Target chain where the UTXO can be spent
  targetChainId: number;
  /// Token amount in base units
  amount: bigint;
  /// Token symbol (informational)
  tokenSymbol: string;
  /// The VAnchor contract address on the target chain
  targetAnchor: string;
  /// The private key of the owning keypair
  privateKey: string;
  /// The blinding factor
  blinding: string;
  /// Merkle tree leaf index (set after deposit confirmation)
  index?: number;
}

/// Serialize a note to a URI string for storage/sharing
export function serializeNote(note: NoteData): string {
  const secrets = [
    typedChainId(ChainType.EVM, note.targetChainId).toString(),
    note.amount.toString(),
    note.privateKey,
    note.blinding,
  ].join(":");

  const params = new URLSearchParams({
    secrets,
    anchor: note.targetAnchor,
    ...(note.index !== undefined ? { index: note.index.toString() } : {}),
  });

  return `tangle://v1:vanchor/${note.sourceChainId}:${note.targetChainId}/${note.amount}/${note.tokenSymbol}?${params}`;
}

/// Parse a note URI back to NoteData
export function deserializeNote(uri: string): NoteData {
  // `tangle://` is not a registered scheme, so `new URL` rejects it.
  // Swap to https for parsing, then treat the first path segment as the
  // protocol version token (e.g. "v1:vanchor").
  const url = new URL(uri.replace(/^tangle:\/\//, "https://tangle.internal/"));
  const pathParts = url.pathname.split("/").filter(Boolean);

  // Parse: v1:vanchor / sourceChain:targetChain / amount / tokenSymbol
  const [sourceChainId, targetChainId] = pathParts[1].split(":").map(Number);
  const amount = BigInt(pathParts[2]);
  const tokenSymbol = pathParts[3];

  const secrets = url.searchParams.get("secrets")!;
  const [, , privateKey, blinding] = secrets.split(":");
  const targetAnchor = url.searchParams.get("anchor")!;
  const indexStr = url.searchParams.get("index");

  return {
    sourceChainId,
    targetChainId,
    amount,
    tokenSymbol,
    targetAnchor,
    privateKey,
    blinding,
    index: indexStr ? Number(indexStr) : undefined,
  };
}

/// Convert a NoteData to a Utxo for circuit computation
export function noteToUtxo(note: NoteData): Utxo {
  return new Utxo({
    chainId: typedChainId(ChainType.EVM, note.targetChainId),
    amount: note.amount,
    keypair: Keypair.fromString(note.privateKey),
    blinding: BigInt(note.blinding),
    index: note.index,
  });
}

/// Convert a Utxo to NoteData for storage
export function utxoToNote(
  utxo: Utxo,
  sourceChainId: number,
  targetChainId: number,
  tokenSymbol: string,
  targetAnchor: string
): NoteData {
  return {
    sourceChainId,
    targetChainId,
    amount: utxo.amount,
    tokenSymbol,
    targetAnchor,
    privateKey: utxo.keypair.toString(),
    blinding: "0x" + utxo.blinding.toString(16).padStart(62, "0"),
    index: utxo.index ?? undefined,
  };
}
