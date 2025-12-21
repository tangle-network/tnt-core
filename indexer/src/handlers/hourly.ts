import { onBlock } from "generated";
import { PointsManager } from "../points";
import { CHAIN_ID, HOURLY_BLOCK_INTERVAL } from "../lib/handlerUtils";
import { HOURLY_PROGRAMS, pointsContext, processParticipation } from "../points/participation";
import { refreshRegisteredAssetPrices } from "../points/prices";

// `generated` is compiled from whatever `config*.yaml` was used during `envio codegen`.
// The chain ID is validated at runtime; we cast here to avoid coupling builds to a single chain literal.
import type { chain as GeneratedChain } from "generated/src/Types.gen";
const INDEXER_CHAIN = CHAIN_ID as unknown as GeneratedChain;

const extractBlockMeta = (block: { number?: number | string; timestamp?: number | string; hash?: string }) => {
  const blockNumber = typeof block.number === "string" ? BigInt(block.number) : BigInt(block.number ?? 0);
  const timestamp =
    typeof block.timestamp === "string"
      ? BigInt(block.timestamp)
      : typeof block.timestamp === "number"
        ? BigInt(block.timestamp)
        : blockNumber * 12n;
  const hash = block.hash ? block.hash.toString() : `hourly-${block.number}`;
  return { blockNumber, timestamp, hash };
};

export function registerHourlyHandlers() {
  onBlock({ name: "asset-price-refresh", chain: INDEXER_CHAIN, interval: HOURLY_BLOCK_INTERVAL }, async ({ block, context }) => {
    const { blockNumber, timestamp } = extractBlockMeta(block);
    await refreshRegisteredAssetPrices(context, blockNumber, timestamp);
  });

  onBlock({ name: "hourly-participation", chain: INDEXER_CHAIN, interval: HOURLY_BLOCK_INTERVAL }, async ({ block, context }) => {
    const { blockNumber, timestamp, hash } = extractBlockMeta(block);
    const points = new PointsManager(pointsContext(context), blockNumber, timestamp, hash);
    for (const program of HOURLY_PROGRAMS) {
      await processParticipation(context, program.programId, blockNumber, timestamp, points);
    }
  });
}
