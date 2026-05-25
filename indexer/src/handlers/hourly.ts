import { indexer } from "envio";
import { PointsManager } from "../points";
import { CHAIN_ID, HOURLY_BLOCK_INTERVAL } from "../lib/handlerUtils";
import { HOURLY_PROGRAMS, pointsContext, processParticipation } from "../points/participation";
import { refreshRegisteredAssetPrices } from "../points/prices";

const INDEXER_CHAIN_ID = Number(CHAIN_ID);

/**
 * v3 `indexer.onBlock` handlers receive `{ block: { number } }` — the
 * timestamp/hash extended fields are NOT in the configurable `block_fields`
 * allowlist (which is limited to `parentHash`, `nonce`, `gasLimit`, etc.).
 * Timestamp is synthesized from a 12-second L2 block time approximation;
 * hash is a deterministic placeholder keyed off the block number.
 *
 * This is a known accuracy compromise — the points-issued-at timestamps are
 * derived rather than measured. Acceptable for the hourly cadence because:
 *   1. participation/price snapshots are not time-critical to the second
 *   2. the indexer always processes blocks in order, so the synthesized
 *      timestamps remain monotonic relative to each other
 *   3. the `hash` is used only as an entity-id seed, never for verification
 *
 * If accuracy ever matters, the canonical fix is to wrap a `block.timestamp`
 * lookup as an Effect (per-block RPC `eth_getBlockByNumber`) and read it
 * from inside the handler.
 */
const BASE_SEPOLIA_BLOCK_SECONDS = 12n;

const extractBlockMeta = (block: { number: number }) => {
  const blockNumber = BigInt(block.number);
  return {
    blockNumber,
    timestamp: blockNumber * BASE_SEPOLIA_BLOCK_SECONDS,
    hash: `hourly-${blockNumber.toString()}`,
  };
};

/**
 * `where` predicate shared by both block handlers — only fires on the
 * configured indexer chain, then samples every Nth block. Hoisted so the
 * two `onBlock` registrations don't duplicate the literal.
 */
const everyHourlyBlock = ({ chain }: { chain: { id: number } }) => {
  if (chain.id !== INDEXER_CHAIN_ID) return false;
  return { block: { number: { _every: HOURLY_BLOCK_INTERVAL } } };
};

indexer.onBlock(
  { name: "asset-price-refresh", where: everyHourlyBlock },
  async ({ block, context }) => {
    const { blockNumber, timestamp } = extractBlockMeta(block);
    await refreshRegisteredAssetPrices(context, blockNumber, timestamp);
  }
);

indexer.onBlock(
  { name: "hourly-participation", where: everyHourlyBlock },
  async ({ block, context }) => {
    const { blockNumber, timestamp, hash } = extractBlockMeta(block);
    const points = new PointsManager(pointsContext(context), blockNumber, timestamp, hash);
    for (const program of HOURLY_PROGRAMS) {
      await processParticipation(context, program.programId, blockNumber, timestamp, points);
    }
  }
);
