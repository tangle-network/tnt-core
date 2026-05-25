import { indexer } from "envio";
import { PointsManager } from "../points";
import { CHAIN_ID, HOURLY_BLOCK_INTERVAL } from "../lib/handlerUtils";
import { HOURLY_PROGRAMS, pointsContext, processParticipation } from "../points/participation";
import { refreshRegisteredAssetPrices } from "../points/prices";

const INDEXER_CHAIN_ID = Number(CHAIN_ID);

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
  indexer.onBlock(
    {
      name: "asset-price-refresh",
      where: ({ chain }) => {
        if (chain.id !== INDEXER_CHAIN_ID) return false;
        return { block: { number: { _every: HOURLY_BLOCK_INTERVAL } } };
      },
    },
    async ({ block, context }) => {
      const { blockNumber, timestamp } = extractBlockMeta(block);
      await refreshRegisteredAssetPrices(context, blockNumber, timestamp);
    }
  );

  indexer.onBlock(
    {
      name: "hourly-participation",
      where: ({ chain }) => {
        if (chain.id !== INDEXER_CHAIN_ID) return false;
        return { block: { number: { _every: HOURLY_BLOCK_INTERVAL } } };
      },
    },
    async ({ block, context }) => {
      const { blockNumber, timestamp, hash } = extractBlockMeta(block);
      const points = new PointsManager(pointsContext(context), blockNumber, timestamp, hash);
      for (const program of HOURLY_PROGRAMS) {
        await processParticipation(context, program.programId, blockNumber, timestamp, points);
      }
    }
  );
}
