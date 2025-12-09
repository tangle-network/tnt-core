import { ValidatorPodManager } from "generated";
import type { Operator, ValidatorPod } from "generated/src/Types.gen";
import {
  ensureDelegator,
  ensureOperator,
  getPointsManager,
  getTimestamp,
  getTxHash,
  maybeDeactivateDelegatorParticipation,
  normalizeAddress,
  subtractToZero,
  toBigInt,
} from "../lib/handlerUtils";
import { activateParticipation, pointsContext } from "../points/participation";
import { awardNativePodCreated } from "../points/awards";
import { toPointsValue } from "../points/math";

export function registerValidatorPodHandlers() {
  ValidatorPodManager.PodCreated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const owner = normalizeAddress(event.params.owner);
    const pod = normalizeAddress(event.params.pod);
    const entity: ValidatorPod = {
      id: pod,
      owner,
      createdAt: timestamp,
      txHash: getTxHash(event),
    } as ValidatorPod;
    context.ValidatorPod.set(entity);
    await ensureDelegator(context, owner, timestamp);
    const points = getPointsManager(pointsContext(context), event);
    await awardNativePodCreated(points, owner, pod);
  });

  ValidatorPodManager.Delegated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const amount = toBigInt(event.params.amount);
    const updatedDelegator = {
      ...delegator,
      totalDelegated: (delegator.totalDelegated ?? 0n) + amount,
    };
    context.Delegator.set(updatedDelegator);
    const points = getPointsManager(pointsContext(context), event);
    await points.award(delegator.id, "delegation", toPointsValue(amount), "native delegation");
    await activateParticipation(context, "delegator-hourly", delegator.id, "DELEGATOR", timestamp);
    await activateParticipation(context, "operator-hourly", operator.id, "OPERATOR", timestamp);
  });

  ValidatorPodManager.Undelegated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
    const amount = toBigInt(event.params.amount);
    const updatedDelegator = {
      ...delegator,
      totalDelegated: subtractToZero(delegator.totalDelegated, amount),
    };
    context.Delegator.set(updatedDelegator);
    await maybeDeactivateDelegatorParticipation(context, updatedDelegator, timestamp);
  });
}
