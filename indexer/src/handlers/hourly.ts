import { onBlock } from "generated";
import { PointsManager } from "../points";
import { HOURLY_BLOCK_INTERVAL } from "../lib/handlerUtils";
import { HOURLY_PROGRAMS, pointsContext, processParticipation } from "../points/participation";
import { refreshRegisteredAssetPrices } from "../points/prices";

export function registerHourlyHandlers() {
  onBlock({ name: "hourly-participation", chain: 84532, interval: HOURLY_BLOCK_INTERVAL }, async ({ block, context }) => {
    const blockNumber = typeof block.number === "string" ? BigInt(block.number) : BigInt(block.number ?? 0);
    const timestamp = blockNumber * 12n;
    const blockHash = `hourly-${block.number}`;
    const points = new PointsManager(pointsContext(context), blockNumber, timestamp, blockHash);
    await refreshRegisteredAssetPrices(context, blockNumber, timestamp);
    for (const program of HOURLY_PROGRAMS) {
      await processParticipation(context, program.programId, blockNumber, timestamp, points);
    }
  });
}
