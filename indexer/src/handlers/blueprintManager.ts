import { MasterBlueprintServiceManager } from "generated";
import type { BlueprintDefinition } from "generated/src/Types.gen";
import {
  getEventId,
  getPointsManager,
  getTimestamp,
  getTxHash,
  normalizeAddress,
  toBigInt,
  toHexString,
} from "../lib/handlerUtils";
import { pointsContext } from "../points/participation";
import { awardDeveloperBlueprint } from "../points/awards";

export function registerBlueprintManagerHandlers() {
  MasterBlueprintServiceManager.BlueprintDefinitionRecorded.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const blueprintId = toBigInt(event.params.blueprintId);
    const owner = normalizeAddress(event.params.owner);
    const definition: BlueprintDefinition = {
      id: getEventId(event),
      blueprintId,
      owner,
      encodedDefinition: toHexString(event.params.encodedDefinition),
      recordedAt: timestamp,
      txHash: getTxHash(event),
    } as BlueprintDefinition;
    context.BlueprintDefinition.set(definition);
    const points = getPointsManager(pointsContext(context), event);
    await awardDeveloperBlueprint(points, owner, blueprintId.toString());
  });
}
