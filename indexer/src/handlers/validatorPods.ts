import { indexer } from "envio";
import type {
  Operator,
  OperatorPoolSlash,
  ValidatorPod,
  ValidatorPodShareEvent,
  ValidatorPodBeaconRebase,
  ValidatorPodWithdrawal,
  NativeOperator,
} from "envio";
import {
  ensureDelegator,
  ensureOperator,
  getPointsManager,
  getTimestamp,
  getTxHash,
  maybeDeactivateDelegatorParticipation,
  normalizeAddress,
  toHexString,
  subtractToZero,
  toBigInt,
} from "../lib/handlerUtils";
import { activateParticipation, pointsContext } from "../points/participation";
import { awardNativePodCreated } from "../points/awards";
import { toPointsValue } from "../points/math";

export function registerValidatorPodHandlers() {
  indexer.onEvent({ contract: "ValidatorPodManager", event: "PodCreated" }, async ({ event, context }) => {
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

  indexer.onEvent({ contract: "ValidatorPodManager", event: "Delegated" }, async ({ event, context }) => {
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
    await trackNativeOperatorDelegation(context, operator.id, amount, timestamp);
  });

  indexer.onEvent({ contract: "ValidatorPodManager", event: "Undelegated" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
    const amount = toBigInt(event.params.amount);
    const updatedDelegator = {
      ...delegator,
      totalDelegated: subtractToZero(delegator.totalDelegated, amount),
    };
    context.Delegator.set(updatedDelegator);
    await maybeDeactivateDelegatorParticipation(context, updatedDelegator, timestamp);
    await trackNativeOperatorDelegation(context, normalizeAddress(event.params.operator), -amount, timestamp);
  });

  indexer.onEvent({ contract: "ValidatorPodManager", event: "SharesUpdated" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const entity: ValidatorPodShareEvent = {
      id: `shares-${getTxHash(event)}-${event.logIndex}`,
      owner: normalizeAddress(event.params.owner),
      sharesDelta: toBigInt(event.params.sharesDelta),
      newShares: toBigInt(event.params.newShares),
      totalAssets: toBigInt(event.params.totalAssets),
      totalSharesPool: toBigInt(event.params.totalSharesPool),
      timestamp,
      txHash: getTxHash(event),
    } as ValidatorPodShareEvent;
    context.ValidatorPodShareEvent.set(entity);
  });

  // Beacon rebases (rewards / slashes) move totalAssets only; shares are invariant.
  // Tracked separately from SharesUpdated so analytics can distinguish principal
  // mints from pool-price moves.
  indexer.onEvent({ contract: "ValidatorPodManager", event: "BeaconRebase" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const entity: ValidatorPodBeaconRebase = {
      id: `rebase-${getTxHash(event)}-${event.logIndex}`,
      owner: normalizeAddress(event.params.owner),
      assetsDelta: toBigInt(event.params.assetsDelta),
      newTotalAssets: toBigInt(event.params.newTotalAssets),
      totalSharesPool: toBigInt(event.params.totalSharesPool),
      timestamp,
      txHash: getTxHash(event),
    } as ValidatorPodBeaconRebase;
    context.ValidatorPodBeaconRebase.set(entity);
  });

  indexer.onEvent({ contract: "ValidatorPodManager", event: "OperatorRegistered" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureNativeOperator(context, event.params.operator, timestamp);
    const updated: NativeOperator = {
      ...operator,
      registered: true,
      registeredAt: timestamp,
      deregisteredAt: undefined,
      updatedAt: timestamp,
    } as NativeOperator;
    context.NativeOperator.set(updated);
  });

  indexer.onEvent({ contract: "ValidatorPodManager", event: "OperatorDeregistered" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureNativeOperator(context, event.params.operator, timestamp);
    const updated: NativeOperator = {
      ...operator,
      registered: false,
      deregisteredAt: timestamp,
      updatedAt: timestamp,
    } as NativeOperator;
    context.NativeOperator.set(updated);
  });

  indexer.onEvent({ contract: "ValidatorPodManager", event: "OperatorPoolSlashed" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const slash: OperatorPoolSlash = {
      id: `pool-slash-${getTxHash(event)}-${event.logIndex}`,
      operator: normalizeAddress(event.params.operator),
      slashedAssets: toBigInt(event.params.slashedAssets),
      newTotalAssets: toBigInt(event.params.newTotalAssets),
      totalShares: toBigInt(event.params.totalShares),
      slashedAt: timestamp,
      txHash: getTxHash(event),
    } as OperatorPoolSlash;
    context.OperatorPoolSlash.set(slash);
  });

  indexer.onEvent({ contract: "ValidatorPodManager", event: "WithdrawalQueued" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const root = toHexString(event.params.withdrawalRoot);
    const withdrawal: ValidatorPodWithdrawal = {
      id: root,
      withdrawalRoot: root,
      staker: normalizeAddress(event.params.staker),
      shares: toBigInt(event.params.shares),
      queuedAssets: toBigInt(event.params.assets),
      status: "PENDING",
      queuedAt: timestamp,
      txHash: getTxHash(event),
    } as ValidatorPodWithdrawal;
    context.ValidatorPodWithdrawal.set(withdrawal);
  });

  indexer.onEvent({ contract: "ValidatorPodManager", event: "WithdrawalCompleted" }, async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const root = toHexString(event.params.withdrawalRoot);
    const existing = (await context.ValidatorPodWithdrawal.get(root)) as ValidatorPodWithdrawal | undefined;
    if (!existing) return;
    const updated: ValidatorPodWithdrawal = {
      ...existing,
      completedAssets: toBigInt(event.params.assets),
      status: "EXECUTED",
      completedAt: timestamp,
      txHash: getTxHash(event),
    } as ValidatorPodWithdrawal;
    context.ValidatorPodWithdrawal.set(updated);
  });
}

const ensureNativeOperator = async (context: any, address: string, timestamp: bigint) => {
  const id = normalizeAddress(address);
  let entity = ((await context.NativeOperator.get(id)) as NativeOperator | undefined) ?? ({
    id,
    registered: false,
    totalDelegated: 0n,
    updatedAt: timestamp,
  } as NativeOperator);
  if (!entity.updatedAt || entity.updatedAt < timestamp) {
    entity = { ...entity, updatedAt: timestamp } as NativeOperator;
  }
  context.NativeOperator.set(entity);
  return entity;
};

const trackNativeOperatorDelegation = async (context: any, operatorId: string, amountDelta: bigint, timestamp: bigint) => {
  const operator = await ensureNativeOperator(context, operatorId, timestamp);
  const next = subtractToZero(operator.totalDelegated, amountDelta < 0n ? -amountDelta : 0n) + (amountDelta > 0n ? amountDelta : 0n);
  context.NativeOperator.set({
    ...operator,
    totalDelegated: next,
    updatedAt: timestamp,
  } as NativeOperator);
};
