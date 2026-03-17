import { ethers } from "ethers";
import { MerkleTree } from "../protocol/merkle-tree.js";
import { Keypair } from "../protocol/keypair.js";
import { Utxo } from "../protocol/utxo.js";
import { decryptUtxo } from "../protocol/encryption.js";
import type { NoteData } from "../note/note.js";

const VANCHOR_ABI = [
  "event NewCommitment(uint256 commitment, uint256 subTreeIndex, uint256 leafIndex, bytes encryptedOutput)",
];

/// Maximum block range per query to avoid RPC limits
const BLOCK_BATCH_SIZE = 10_000;

export interface LeafSyncResult {
  /// Number of new leaves inserted
  leavesInserted: number;
  /// Block number of the last processed event
  lastBlock: number;
}

export interface DiscoveredNote {
  /// The decrypted UTXO
  utxo: Utxo;
  /// The leaf index in the Merkle tree
  leafIndex: number;
  /// The block number where this commitment was emitted
  blockNumber: number;
}

/// Fetch NewCommitment events from the VAnchor contract and insert leaves
/// into the local Merkle tree. Leaves are inserted in order of their leafIndex.
export async function syncLeaves(
  provider: ethers.Provider,
  poolAddress: string,
  tree: MerkleTree,
  fromBlock?: number,
  toBlock?: number
): Promise<LeafSyncResult> {
  const contract = new ethers.Contract(poolAddress, VANCHOR_ABI, provider);
  const startBlock = fromBlock ?? 0;
  const endBlock = toBlock ?? (await provider.getBlockNumber());

  let leavesInserted = 0;
  let lastBlock = startBlock;

  for (let from = startBlock; from <= endBlock; from += BLOCK_BATCH_SIZE + 1) {
    const to = Math.min(from + BLOCK_BATCH_SIZE, endBlock);
    const events = await contract.queryFilter(
      contract.filters.NewCommitment(),
      from,
      to
    );

    // Sort by leafIndex to ensure correct insertion order
    const sorted = events
      .filter((e): e is ethers.EventLog => e instanceof ethers.EventLog)
      .sort((a, b) => {
        const idxA = Number(a.args[2]);
        const idxB = Number(b.args[2]);
        return idxA - idxB;
      });

    for (const event of sorted) {
      const commitment = event.args[0] as bigint;
      const leafIndex = Number(event.args[2]);

      // Skip leaves already in the tree
      if (leafIndex < tree.nextIndex) {
        continue;
      }

      // Sanity check: leaves must be inserted sequentially
      if (leafIndex !== tree.nextIndex) {
        throw new Error(
          `Leaf sync gap: expected index ${tree.nextIndex}, got ${leafIndex}`
        );
      }

      await tree.insert(commitment);
      leavesInserted++;
      lastBlock = event.blockNumber;
    }
  }

  return { leavesInserted, lastBlock };
}

/// Sync NewCommitment events and attempt to decrypt each encrypted output
/// using the provided keypair. Returns any UTXOs that belong to this keypair.
export async function discoverNotes(
  provider: ethers.Provider,
  poolAddress: string,
  keypair: Keypair,
  fromBlock?: number,
  toBlock?: number
): Promise<DiscoveredNote[]> {
  const contract = new ethers.Contract(poolAddress, VANCHOR_ABI, provider);
  const startBlock = fromBlock ?? 0;
  const endBlock = toBlock ?? (await provider.getBlockNumber());

  const discovered: DiscoveredNote[] = [];

  for (let from = startBlock; from <= endBlock; from += BLOCK_BATCH_SIZE + 1) {
    const to = Math.min(from + BLOCK_BATCH_SIZE, endBlock);
    const events = await contract.queryFilter(
      contract.filters.NewCommitment(),
      from,
      to
    );

    for (const event of events) {
      if (!(event instanceof ethers.EventLog)) continue;

      const leafIndex = Number(event.args[2]);
      const encryptedOutput = ethers.getBytes(event.args[3]);

      // Try to decrypt with our keypair — returns null if not ours
      const utxo = await decryptUtxo(
        encryptedOutput,
        keypair,
        0n // chainId is encoded in the ciphertext
      );

      if (utxo !== null) {
        utxo.index = leafIndex;
        discovered.push({
          utxo,
          leafIndex,
          blockNumber: event.blockNumber,
        });
      }
    }
  }

  return discovered;
}
