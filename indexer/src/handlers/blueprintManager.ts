import { indexer } from "envio";
import type { BlueprintDefinition } from "envio";
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

indexer.onEvent({ contract: "MasterBlueprintServiceManager", event: "BlueprintDefinitionRecorded" }, async ({ event, context }) => {
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
