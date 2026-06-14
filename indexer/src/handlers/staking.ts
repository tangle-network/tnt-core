import { indexer } from "envio";
import type {
  CommissionChangeState,
  DelegationPosition,
  DelegationBalance,
  DelegationBalanceDelta,
  DelegationUnstakeRequest,
  Delegator,
  ExpiredLockHarvest,
  DelegatorAssetPosition,
  DepositLock,
  HeartbeatConfig,
  Operator,
  OperatorBlueprint,
  OperatorHeartbeat,
  OperatorLifecycleEvent,
  OperatorMetricSnapshot,
  StakingAsset,
  StakingRound,
  StakingSlash,
  SlashRecord,
  WithdrawRequest,
} from "envio";
import {
  ZERO_ADDRESS,
  ensureAssetPosition,
  ensureDelegationPosition,
  ensureDelegator,
  ensureOperator,
  ensureStakingAsset,
  getBlockNumber,
  getEventId,
  getPointsManager,
  getTimestamp,
  getTxHash,
  mapBlueprintSelection,
  mapLockDuration,
  maybeDeactivateDelegatorParticipation,
  maybeDeactivateOperatorParticipation,
  normalizeAddress,
  recordDelegationBlueprintEvent,
  recordOperatorStakeChange,
  settleUnstakeRequest,
  settleWithdrawRequest,
  subtractToZero,
  toBigInt,
  toNumber,
} from "../lib/handlerUtils";
import { activateParticipation, deactivateParticipation, pointsContext } from "../points/participation";
import { toPointsValue } from "../points/math";
import { awardOperatorUptime } from "../points/awards";
import type { HandlerContext } from "../lib/handlerContext";

const getOperatorStakingStake = (operator: Operator) => operator.stakingStake ?? 0n;

const getOperatorStakingDelegationCount = (operator: Operator) => operator.stakingDelegationCount ?? 0n;

const setStakingAsset = (context: HandlerContext, asset: StakingAsset) => {
  context.StakingAsset.set(asset);
};

const setStakingRound = (context: HandlerContext, round: StakingRound) => {
  context.StakingRound.set(round);
};

const setStakingSlash = (context: HandlerContext, slash: StakingSlash) => {
  context.StakingSlash.set(slash);
};

/* ────────────────────────────────────────────────────────────────────────────
   MULTI-ASSET DELEGATION EVENTS
   ────────────────────────────────────────────────────────────────────────── */

const latestRound = async (context: HandlerContext) => {
  const stakingRound = await context.StakingRound.get("latest");
  return stakingRound?.round ?? 0n;
};

const ensureDelegationBalance = async (
  context: { DelegationBalance: { get: (id: string) => Promise<DelegationBalance | undefined>; set: (entity: DelegationBalance) => void } },
  delegator: string,
  token: string,
  timestamp: bigint
) => {
  const id = `${delegator}-${token}`;
  let balance = await context.DelegationBalance.get(id);
  if (!balance) {
    balance = { id, delegator, token, amount: 0n, lastUpdatedAt: timestamp } as DelegationBalance;
  }
  context.DelegationBalance.set({ ...balance, lastUpdatedAt: timestamp } as DelegationBalance);
  return balance;
};

const recordDelegationBalanceDelta = async (
  context: {
    DelegationBalance: { get: (id: string) => Promise<DelegationBalance | undefined>; set: (entity: DelegationBalance) => void };
    DelegationBalanceDelta: { set: (entity: DelegationBalanceDelta) => void };
  },
  delegator: string,
  token: string,
  delta: bigint,
  kind: DelegationBalanceDelta["kind"],
  event: { block: { timestamp: number; hash: string; number: number | string }; logIndex: number; transaction?: { hash?: string } }
) => {
  const timestamp = getTimestamp(event);
  const existing = await ensureDelegationBalance(context, delegator, token, timestamp);
  const next = (existing.amount ?? 0n) + delta;
  const amountAfter = next < 0n ? 0n : next;
  context.DelegationBalance.set({ ...existing, amount: amountAfter, lastUpdatedAt: timestamp } as DelegationBalance);
  const entity: DelegationBalanceDelta = {
    id: `delegation-delta-${getEventId(event)}`,
    balance_id: existing.id,
    delegator,
    token,
    kind,
    delta,
    amountAfter,
    blockNumber: getBlockNumber(event),
    timestamp,
    txHash: getTxHash(event),
  } as DelegationBalanceDelta;
  context.DelegationBalanceDelta.set(entity);
};

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorRegistered" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const stake = toBigInt(event.params.stake);
  const operator = await ensureOperator(
    context,
    event.params.operator,
    timestamp,
    ({
      stakingStatus: "ACTIVE",
      stakingStake: stake,
      stakingUpdatedAt: timestamp,
    })
  );
  await recordOperatorStakeChange(context, operator, "REGISTERED", stake, undefined, event);
  await getPointsManager(pointsContext(context), event).award(operator.id, "operator-registration", toPointsValue(stake), "operator registered");
  await activateParticipation(context, "operator-hourly", operator.id, "OPERATOR", timestamp);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorStakeIncreased" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const amount = toBigInt(event.params.amount);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const stake = getOperatorStakingStake(operator) + amount;
  context.Operator.set({
    ...operator,
    ...({
      stakingStake: stake,
      stakingUpdatedAt: timestamp,
    }),
  } as Operator);
  await recordOperatorStakeChange(context, operator, "STAKE_INCREASED", amount, undefined, event);
  await getPointsManager(pointsContext(context), event).award(operator.id, "operator-stake", toPointsValue(amount), "stake increased");
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorUnstakeScheduled" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const amount = toBigInt(event.params.amount);
  const readyAtRound = toBigInt(event.params.readyRound);
  const operator = await ensureOperator(
    context,
    event.params.operator,
    timestamp,
    ({
      stakingScheduledUnstakeAmount: amount,
      stakingScheduledUnstakeRound: readyAtRound,
      stakingUpdatedAt: timestamp,
    })
  );
  await recordOperatorStakeChange(context, operator, "UNSTAKE_SCHEDULED", amount, readyAtRound, event);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorUnstakeExecuted" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const stake = getOperatorStakingStake(operator) - toBigInt(event.params.amount);
  const nextStake = stake < 0n ? 0n : stake;
  const updatedOperator: Operator = {
    ...operator,
    ...({
      stakingStake: nextStake,
      stakingScheduledUnstakeAmount: undefined,
      stakingScheduledUnstakeRound: undefined,
      stakingUpdatedAt: timestamp,
    }),
  } as Operator;
  context.Operator.set(updatedOperator);
  await recordOperatorStakeChange(context, operator, "UNSTAKE_EXECUTED", toBigInt(event.params.amount), undefined, event);
  await maybeDeactivateOperatorParticipation(context, updatedOperator, timestamp);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorLeavingScheduled" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(
    context,
    event.params.operator,
    timestamp,
    ({
      stakingStatus: "LEAVING",
      stakingLeavingRound: toBigInt(event.params.readyRound),
      stakingUpdatedAt: timestamp,
    })
  );
  await recordOperatorStakeChange(context, operator, "LEAVING_SCHEDULED", undefined, toBigInt(event.params.readyRound), event);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorLeft" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(
    context,
    event.params.operator,
    timestamp,
    ({
      stakingStatus: "INACTIVE",
      stakingStake: 0n,
      stakingDelegationCount: 0n,
      stakingUpdatedAt: timestamp,
    })
  );
  await recordOperatorStakeChange(context, operator, "LEFT", undefined, undefined, event);
  await deactivateParticipation(context, "operator-hourly", operator.id, timestamp);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorBlueprintAdded" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const blueprintId = toBigInt(event.params.blueprintId).toString();
  const blueprint = await context.Blueprint.get(blueprintId);
  if (!blueprint) return;
  const id = `${operator.id}-${blueprintId}`;
  const membership: OperatorBlueprint = {
    id,
    operator_id: operator.id,
    blueprint_id: blueprintId,
    addedAt: timestamp,
    active: true,
  } as OperatorBlueprint;
  context.OperatorBlueprint.set(membership);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorBlueprintRemoved" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const blueprintId = toBigInt(event.params.blueprintId).toString();
  const id = `${operator.id}-${blueprintId}`;
  const membership = await context.OperatorBlueprint.get(id);
  if (!membership) return;
  context.OperatorBlueprint.set({ ...membership, active: false, removedAt: timestamp } as OperatorBlueprint);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "Deposited" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const amount = toBigInt(event.params.amount);
  const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
  const asset = await ensureStakingAsset(context, event.params.token, timestamp);
  const updatedAsset: StakingAsset = {
    ...asset,
    currentDeposits: (asset.currentDeposits ?? 0n) + amount,
  } as StakingAsset;
  setStakingAsset(context, updatedAsset);
  const position = await ensureAssetPosition(context, delegator, event.params.token, timestamp);
  const updatedPosition: DelegatorAssetPosition = {
    ...position,
    totalDeposited: (position.totalDeposited ?? 0n) + amount,
  } as DelegatorAssetPosition;
  context.DelegatorAssetPosition.set(updatedPosition);
  const updatedDelegator: Delegator = {
    ...delegator,
    totalDeposited: (delegator.totalDeposited ?? 0n) + amount,
  } as Delegator;
  context.Delegator.set(updatedDelegator);
  const multiplier = mapLockDuration(event.params.lock as any);
  if (multiplier !== "NONE") {
    const lock: DepositLock = {
      id: `lock-${position.id}-${getEventId(event)}`,
      position_id: position.id,
      amount,
      duration: multiplier,
      expiryTimestamp: 0n,
    } as DepositLock;
    context.DepositLock.set(lock);
  }
  await getPointsManager(pointsContext(context), event).award(delegator.id, "delegator-deposit", toPointsValue(amount), "deposit");
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "WithdrawScheduled" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const amount = toBigInt(event.params.amount);
  const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
  const position = await ensureAssetPosition(context, delegator, event.params.token, timestamp);
  const updatedPosition: DelegatorAssetPosition = {
    ...position,
    totalDeposited: subtractToZero(position.totalDeposited, amount),
  } as DelegatorAssetPosition;
  context.DelegatorAssetPosition.set(updatedPosition);
  const nonce = delegator.withdrawNonce ?? 0n;
  const updatedDelegator: Delegator = { ...delegator, withdrawNonce: nonce + 1n } as Delegator;
  context.Delegator.set(updatedDelegator);
  const request: WithdrawRequest = {
    id: `withdraw-${delegator.id}-${nonce}`,
    delegator_id: delegator.id,
    position_id: position.id,
    token: normalizeAddress(event.params.token ?? ZERO_ADDRESS),
    amount,
    requestedRound: toBigInt(event.params.readyRound),
    readyAtRound: toBigInt(event.params.readyRound),
    status: "PENDING",
    nonce,
  } as WithdrawRequest;
  context.WithdrawRequest.set(request);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "Withdrawn" }, async ({ event, context }) => {
  const delegator = await ensureDelegator(context, event.params.delegator, getTimestamp(event));
  await settleWithdrawRequest(
    context,
    delegator,
    normalizeAddress(event.params.token ?? ZERO_ADDRESS),
    toBigInt(event.params.amount),
    getTimestamp(event)
  );
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "Delegated" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const amount = toBigInt(event.params.amount);
  const shares = toBigInt(event.params.shares);
  const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const round = await latestRound(context);
  const mode = mapBlueprintSelection(event.params.selectionMode as any);
  const token = normalizeAddress(event.params.token ?? ZERO_ADDRESS);
  const position = await ensureDelegationPosition(context, delegator, operator, token, mode, round, timestamp);
  const wasZero = (position.shares ?? 0n) === 0n;
  const updatedPosition: DelegationPosition = {
    ...position,
    shares: (position.shares ?? 0n) + shares,
    lastKnownAmount: (position.lastKnownAmount ?? 0n) + amount,
  } as DelegationPosition;
  context.DelegationPosition.set(updatedPosition);
  const updatedDelegator: Delegator = {
    ...delegator,
    totalDelegated: (delegator.totalDelegated ?? 0n) + amount,
  } as Delegator;
  context.Delegator.set(updatedDelegator);
  let delegationCount = getOperatorStakingDelegationCount(operator);
  if (wasZero && shares > 0n) {
    delegationCount += 1n;
  }
  const updatedOperator: Operator = {
    ...operator,
    ...({
      stakingDelegationCount: delegationCount,
      stakingUpdatedAt: timestamp,
    }),
  } as Operator;
  context.Operator.set(updatedOperator);
  await getPointsManager(pointsContext(context), event).award(delegator.id, "delegation", toPointsValue(amount), "delegated");
  await activateParticipation(context, "delegator-hourly", delegator.id, "DELEGATOR", timestamp);
  await activateParticipation(context, "operator-hourly", operator.id, "OPERATOR", timestamp);
  await recordDelegationBalanceDelta(context, delegator.id, token, amount, "DELEGATE", event);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "DelegatorUnstakeScheduled" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
  const operatorId = normalizeAddress(event.params.operator);
  const token = normalizeAddress(event.params.token ?? ZERO_ADDRESS);
  const nonce = delegator.unstakeNonce ?? 0n;
  const updatedDelegator: Delegator = { ...delegator, unstakeNonce: nonce + 1n } as Delegator;
  context.Delegator.set(updatedDelegator);
  const request: DelegationUnstakeRequest = {
    id: `unstake-${delegator.id}-${nonce}`,
    delegator_id: delegator.id,
    operator_id: operatorId,
    position_id: `${delegator.id}-${operatorId}-${token}`,
    token,
    nonce,
    shares: toBigInt(event.params.shares),
    estimatedAmount: toBigInt(event.params.estimatedAmount),
    requestedRound: toBigInt(event.params.readyRound),
    readyAtRound: toBigInt(event.params.readyRound),
    status: "PENDING",
  } as DelegationUnstakeRequest;
  context.DelegationUnstakeRequest.set(request);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "DelegatorUnstakeExecuted" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
  const operatorId = normalizeAddress(event.params.operator);
  const token = normalizeAddress(event.params.token ?? ZERO_ADDRESS);
  const shares = toBigInt(event.params.shares);
  const amount = toBigInt(event.params.amount);
  await settleUnstakeRequest(context, delegator, operatorId, token, shares, amount, timestamp);
  const positionId = `${delegator.id}-${operatorId}-${token}`;
  const position = await context.DelegationPosition.get(positionId);
  let resultingShares = position?.shares ?? 0n;
  if (position) {
    const updated: DelegationPosition = {
      ...position,
      shares: subtractToZero(position.shares, shares),
      lastKnownAmount: subtractToZero(position.lastKnownAmount, amount),
    } as DelegationPosition;
    context.DelegationPosition.set(updated);
    resultingShares = updated.shares ?? 0n;
  }
  const updatedDelegator: Delegator = {
    ...delegator,
    totalDelegated: subtractToZero(delegator.totalDelegated, amount),
  } as Delegator;
  context.Delegator.set(updatedDelegator);
  await maybeDeactivateDelegatorParticipation(context, updatedDelegator, timestamp);
  await recordDelegationBalanceDelta(context, delegator.id, token, -amount, "UNSTAKE_EXECUTED", event);
  if (resultingShares === 0n) {
    const operator = await context.Operator.get(operatorId);
    if (operator) {
      const updatedOperator: Operator = {
        ...operator,
        ...({
          stakingDelegationCount: subtractToZero(getOperatorStakingDelegationCount(operator), 1n),
          stakingUpdatedAt: timestamp,
        }),
      } as Operator;
      context.Operator.set(updatedOperator);
    }
  }
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "BlueprintAddedToDelegation" }, async ({ event, context }) => {
  recordDelegationBlueprintEvent(context, "ADDED", event, {
    delegator: normalizeAddress(event.params.delegator),
    delegationIndex: toBigInt(event.params.delegationIndex),
    blueprintId: toBigInt(event.params.blueprintId),
  });
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "BlueprintRemovedFromDelegation" }, async ({ event, context }) => {
  recordDelegationBlueprintEvent(context, "REMOVED", event, {
    delegator: normalizeAddress(event.params.delegator),
    delegationIndex: toBigInt(event.params.delegationIndex),
    blueprintId: toBigInt(event.params.blueprintId),
  });
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "AssetEnabled" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const asset = await ensureStakingAsset(context, event.params.token, timestamp);
  setStakingAsset(context, {
    ...asset,
    enabled: true,
    minOperatorStake: toBigInt(event.params.minOperatorStake),
    minDelegation: toBigInt(event.params.minDelegation),
    updatedAt: timestamp,
  });
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "AssetDisabled" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const asset = await ensureStakingAsset(context, event.params.token, timestamp);
  setStakingAsset(context, { ...asset, enabled: false, updatedAt: timestamp });
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "RoundAdvanced" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const roundValue = toBigInt(event.params.round);
  const round: StakingRound = {
    id: roundValue.toString(),
    round: roundValue,
    blockNumber: getBlockNumber(event),
    timestamp,
  } as StakingRound;
  setStakingRound(context, round);
  setStakingRound(context, { ...round, id: "latest" });
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "Slashed" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const slash: StakingSlash = {
    id: getEventId(event),
    operator_id: operator.id,
    serviceId: toBigInt(event.params.serviceId),
    operatorSlashed: toBigInt(event.params.operatorSlashed),
    delegatorsSlashed: toBigInt(event.params.delegatorsSlashed),
    exchangeRateAfter: toBigInt(event.params.exchangeRateAfter),
    blockNumber: getBlockNumber(event),
    txHash: getTxHash(event),
  } as StakingSlash;
  setStakingSlash(context, slash);
  const remainingStake = subtractToZero(getOperatorStakingStake(operator), toBigInt(event.params.operatorSlashed));
  const updatedOperator: Operator = {
    ...operator,
    ...({
      stakingStake: remainingStake,
      stakingUpdatedAt: timestamp,
    }),
  } as Operator;
  context.Operator.set(updatedOperator);
  await maybeDeactivateOperatorParticipation(context, updatedOperator, timestamp);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "SlashRecorded" }, async ({ event, context }) => {
  const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
  const record: SlashRecord = {
    id: getEventId(event),
    operator_id: operator.id,
    slashId: toBigInt(event.params.slashId),
    totalSlashed: toBigInt(event.params.totalSlashed),
    exchangeRateBefore: toBigInt(event.params.exchangeRateBefore),
    exchangeRateAfter: toBigInt(event.params.exchangeRateAfter),
    blockNumber: getBlockNumber(event),
    txHash: getTxHash(event),
  } as SlashRecord;
  context.SlashRecord.set(record);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorDelegationModeSet" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operatorAddress = normalizeAddress(event.params.operator);
  const operator = await ensureOperator(context, operatorAddress, timestamp);

  context.Operator.set({
    ...operator,
    delegationMode: toNumber(event.params.mode),
    ...({
      stakingUpdatedAt: timestamp,
    }),
  } as Operator);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "OperatorWhitelistUpdated" }, async () => {
  // No-op: Whitelist membership is checked via contract calls (canDelegate/isWhitelisted).
  // This handler exists to acknowledge the event. Extend if whitelist analytics are needed.
});

/* ────────────────────────────────────────────────────────────────────────────
   OPERATOR STATUS REGISTRY
   ────────────────────────────────────────────────────────────────────────── */

indexer.onEvent({ contract: "OperatorStatusRegistry", event: "HeartbeatReceived" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const heartbeat: OperatorHeartbeat = {
    id: getEventId(event),
    operator_id: operator.id,
    serviceId: toBigInt(event.params.serviceId),
    blueprintId: toBigInt(event.params.blueprintId),
    statusCode: toNumber(event.params.statusCode),
    blockNumber: getBlockNumber(event),
    timestamp,
    txHash: getTxHash(event),
  } as OperatorHeartbeat;
  context.OperatorHeartbeat.set(heartbeat);
  const points = getPointsManager(pointsContext(context), event);
  await awardOperatorUptime(points, operator.id, toBigInt(event.params.serviceId).toString());
});

indexer.onEvent({ contract: "OperatorStatusRegistry", event: "OperatorWentOffline" }, async ({ event, context }) => {
  const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
  const entity: OperatorLifecycleEvent = {
    id: getEventId(event),
    operator_id: operator.id,
    serviceId: toBigInt(event.params.serviceId),
    eventType: "WENT_OFFLINE",
    missedBeats: toNumber(event.params.missedBeats),
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
  } as OperatorLifecycleEvent;
  context.OperatorLifecycleEvent.set(entity);
});

indexer.onEvent({ contract: "OperatorStatusRegistry", event: "OperatorCameOnline" }, async ({ event, context }) => {
  const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
  const entity: OperatorLifecycleEvent = {
    id: getEventId(event),
    operator_id: operator.id,
    serviceId: toBigInt(event.params.serviceId),
    eventType: "CAME_ONLINE",
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
  } as OperatorLifecycleEvent;
  context.OperatorLifecycleEvent.set(entity);
});

indexer.onEvent({ contract: "OperatorStatusRegistry", event: "StatusChanged" }, async ({ event, context }) => {
  const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
  const entity: OperatorLifecycleEvent = {
    id: getEventId(event),
    operator_id: operator.id,
    serviceId: toBigInt(event.params.serviceId),
    eventType: "STATUS_CHANGED",
    statusCode: toNumber(event.params.newStatus),
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
  } as OperatorLifecycleEvent;
  context.OperatorLifecycleEvent.set(entity);
});

indexer.onEvent({ contract: "OperatorStatusRegistry", event: "HeartbeatConfigUpdated" }, async ({ event, context }) => {
  const entity: HeartbeatConfig = {
    id: toBigInt(event.params.serviceId).toString(),
    serviceId: toBigInt(event.params.serviceId),
    interval: toBigInt(event.params.interval),
    maxMissed: toNumber(event.params.maxMissed),
    updatedAt: getTimestamp(event),
  } as HeartbeatConfig;
  context.HeartbeatConfig.set(entity);
});

indexer.onEvent({ contract: "OperatorStatusRegistry", event: "MetricReported" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const snapshot: OperatorMetricSnapshot = {
    id: getEventId(event),
    operator_id: operator.id,
    serviceId: toBigInt(event.params.serviceId),
    metricName: event.params.metricName,
    value: toBigInt(event.params.value),
    blockNumber: getBlockNumber(event),
    timestamp,
  } as OperatorMetricSnapshot;
  context.OperatorMetricSnapshot.set(snapshot);
});

indexer.onEvent({ contract: "OperatorStatusRegistry", event: "SlashingTriggered" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const entity: OperatorLifecycleEvent = {
    id: getEventId(event),
    operator_id: operator.id,
    serviceId: toBigInt(event.params.serviceId),
    eventType: "SLASH_ALERT",
    blockNumber: getBlockNumber(event),
    timestamp,
    txHash: getTxHash(event),
  } as OperatorLifecycleEvent;
  context.OperatorLifecycleEvent.set(entity);
});

// Protocol-global operator-commission timelock (StakingAdminFacet). Singleton
// entity tracking the latest QUEUED/EXECUTED/CANCELLED transition.
const GLOBAL_COMMISSION_CHANGE_ID = "global";

indexer.onEvent({ contract: "MultiAssetDelegation", event: "CommissionChangeQueued" }, async ({ event, context }) => {
  const state: CommissionChangeState = {
    id: GLOBAL_COMMISSION_CHANGE_ID,
    status: "QUEUED",
    pendingBps: toNumber(event.params.newBps),
    executeAfter: toBigInt(event.params.executeAfter),
    oldBps: undefined,
    newBps: toNumber(event.params.newBps),
    updatedAt: getTimestamp(event),
    txHash: getTxHash(event),
  } as CommissionChangeState;
  context.CommissionChangeState.set(state);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "CommissionChangeExecuted" }, async ({ event, context }) => {
  const state: CommissionChangeState = {
    id: GLOBAL_COMMISSION_CHANGE_ID,
    status: "EXECUTED",
    pendingBps: undefined,
    executeAfter: undefined,
    oldBps: toNumber(event.params.oldBps),
    newBps: toNumber(event.params.newBps),
    updatedAt: getTimestamp(event),
    txHash: getTxHash(event),
  } as CommissionChangeState;
  context.CommissionChangeState.set(state);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "CommissionChangeCancelled" }, async ({ event, context }) => {
  const state: CommissionChangeState = {
    id: GLOBAL_COMMISSION_CHANGE_ID,
    status: "CANCELLED",
    pendingBps: undefined,
    executeAfter: undefined,
    oldBps: undefined,
    newBps: toNumber(event.params.cancelledBps),
    updatedAt: getTimestamp(event),
    txHash: getTxHash(event),
  } as CommissionChangeState;
  context.CommissionChangeState.set(state);
});

indexer.onEvent({ contract: "MultiAssetDelegation", event: "ExpiredLocksHarvested" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
  const harvest: ExpiredLockHarvest = {
    id: getEventId(event),
    delegator_id: delegator.id,
    token: normalizeAddress(event.params.token),
    count: toBigInt(event.params.count),
    totalAmount: toBigInt(event.params.totalAmount),
    harvestedAt: timestamp,
    txHash: getTxHash(event),
  } as ExpiredLockHarvest;
  context.ExpiredLockHarvest.set(harvest);
});
