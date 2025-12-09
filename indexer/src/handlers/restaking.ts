import { MultiAssetDelegation, OperatorStatusRegistry } from "generated";
import type {
  DelegationPosition,
  DelegationUnstakeRequest,
  Delegator,
  DelegatorAssetPosition,
  DepositLock,
  HeartbeatConfig,
  Operator,
  OperatorBlueprint,
  OperatorHeartbeat,
  OperatorLifecycleEvent,
  OperatorMetricSnapshot,
  RestakingAsset,
  RestakingRound,
  RestakingSlash,
  SlashRecord,
  WithdrawRequest,
} from "generated/src/Types.gen";
import {
  ZERO_ADDRESS,
  createRestakingRewardClaim,
  createRewardDistribution,
  ensureAssetPosition,
  ensureDelegationPosition,
  ensureDelegator,
  ensureOperator,
  ensureRestakingAsset,
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

export function registerRestakingHandlers() {
  /* ────────────────────────────────────────────────────────────────────────────
     MULTI-ASSET DELEGATION EVENTS
     ────────────────────────────────────────────────────────────────────────── */

  const latestRound = async (context: { RestakingRound: { get: (id: string) => Promise<RestakingRound | undefined> } }) =>
    (await context.RestakingRound.get("latest"))?.round ?? 0n;

  MultiAssetDelegation.OperatorRegistered.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const stake = toBigInt(event.params.stake);
    const operator = await ensureOperator(context, event.params.operator, timestamp, {
      restakingStatus: "ACTIVE",
      restakingStake: stake,
      restakingUpdatedAt: timestamp,
    });
    await recordOperatorStakeChange(context, operator, "REGISTERED", stake, undefined, event);
    await getPointsManager(pointsContext(context), event).award(operator.id, "operator-registration", toPointsValue(stake), "operator registered");
    await activateParticipation(context, "operator-hourly", operator.id, "OPERATOR", timestamp);
  });

  MultiAssetDelegation.OperatorStakeIncreased.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const amount = toBigInt(event.params.amount);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const stake = (operator.restakingStake ?? 0n) + amount;
    context.Operator.set({ ...operator, restakingStake: stake, restakingUpdatedAt: timestamp } as Operator);
    await recordOperatorStakeChange(context, operator, "STAKE_INCREASED", amount, undefined, event);
    await getPointsManager(pointsContext(context), event).award(operator.id, "operator-stake", toPointsValue(amount), "stake increased");
  });

  MultiAssetDelegation.OperatorUnstakeScheduled.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const amount = toBigInt(event.params.amount);
    const readyAtRound = toBigInt(event.params.readyRound);
    const operator = await ensureOperator(context, event.params.operator, timestamp, {
      restakingScheduledUnstakeAmount: amount,
      restakingScheduledUnstakeRound: readyAtRound,
      restakingUpdatedAt: timestamp,
    });
    await recordOperatorStakeChange(context, operator, "UNSTAKE_SCHEDULED", amount, readyAtRound, event);
  });

  MultiAssetDelegation.OperatorUnstakeExecuted.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const stake = (operator.restakingStake ?? 0n) - toBigInt(event.params.amount);
    const nextStake = stake < 0n ? 0n : stake;
    const updatedOperator: Operator = {
      ...operator,
      restakingStake: nextStake,
      restakingScheduledUnstakeAmount: undefined,
      restakingScheduledUnstakeRound: undefined,
      restakingUpdatedAt: timestamp,
    } as Operator;
    context.Operator.set(updatedOperator);
    await recordOperatorStakeChange(context, operator, "UNSTAKE_EXECUTED", toBigInt(event.params.amount), undefined, event);
    await maybeDeactivateOperatorParticipation(context, updatedOperator, timestamp);
  });

  MultiAssetDelegation.OperatorLeavingScheduled.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp, {
      restakingStatus: "LEAVING",
      restakingLeavingRound: toBigInt(event.params.readyRound),
      restakingUpdatedAt: timestamp,
    });
    await recordOperatorStakeChange(context, operator, "LEAVING_SCHEDULED", undefined, toBigInt(event.params.readyRound), event);
  });

  MultiAssetDelegation.OperatorLeft.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp, {
      restakingStatus: "INACTIVE",
      restakingStake: 0n,
      restakingDelegationCount: 0n,
      restakingUpdatedAt: timestamp,
    });
    await recordOperatorStakeChange(context, operator, "LEFT", undefined, undefined, event);
    await deactivateParticipation(context, "operator-hourly", operator.id, timestamp);
  });

  MultiAssetDelegation.OperatorBlueprintAdded.handler(async ({ event, context }) => {
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

  MultiAssetDelegation.OperatorBlueprintRemoved.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const blueprintId = toBigInt(event.params.blueprintId).toString();
    const id = `${operator.id}-${blueprintId}`;
    const membership = await context.OperatorBlueprint.get(id);
    if (!membership) return;
    context.OperatorBlueprint.set({ ...membership, active: false, removedAt: timestamp } as OperatorBlueprint);
  });

  MultiAssetDelegation.Deposited.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const amount = toBigInt(event.params.amount);
    const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
    const asset = await ensureRestakingAsset(context, event.params.token, timestamp);
    const updatedAsset: RestakingAsset = {
      ...asset,
      currentDeposits: (asset.currentDeposits ?? 0n) + amount,
    } as RestakingAsset;
    context.RestakingAsset.set(updatedAsset);
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
        expiryBlock: 0n,
      } as DepositLock;
      context.DepositLock.set(lock);
    }
    await getPointsManager(pointsContext(context), event).award(delegator.id, "delegator-deposit", toPointsValue(amount), "deposit");
  });

  MultiAssetDelegation.WithdrawScheduled.handler(async ({ event, context }) => {
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

  MultiAssetDelegation.Withdrawn.handler(async ({ event, context }) => {
    const delegator = await ensureDelegator(context, event.params.delegator, getTimestamp(event));
    await settleWithdrawRequest(
      context,
      delegator,
      normalizeAddress(event.params.token ?? ZERO_ADDRESS),
      toBigInt(event.params.amount),
      getTimestamp(event)
    );
  });

  MultiAssetDelegation.Delegated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const amount = toBigInt(event.params.amount);
    const shares = toBigInt(event.params.shares);
    const delegator = await ensureDelegator(context, event.params.delegator, timestamp);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const round = await latestRound(context);
    const mode = mapBlueprintSelection(event.params.selectionMode as any);
    const position = await ensureDelegationPosition(context, delegator, operator, event.params.token, mode, round, timestamp);
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
    let delegationCount = operator.restakingDelegationCount ?? 0n;
    if (wasZero && shares > 0n) {
      delegationCount += 1n;
    }
    const updatedOperator: Operator = {
      ...operator,
      restakingDelegationCount: delegationCount,
      restakingUpdatedAt: timestamp,
    } as Operator;
    context.Operator.set(updatedOperator);
    await getPointsManager(pointsContext(context), event).award(delegator.id, "delegation", toPointsValue(amount), "delegated");
    await activateParticipation(context, "delegator-hourly", delegator.id, "DELEGATOR", timestamp);
    await activateParticipation(context, "operator-hourly", operator.id, "OPERATOR", timestamp);
  });

  MultiAssetDelegation.DelegatorUnstakeScheduled.handler(async ({ event, context }) => {
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

  MultiAssetDelegation.DelegatorUnstakeExecuted.handler(async ({ event, context }) => {
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
    if (resultingShares === 0n) {
      const operator = await context.Operator.get(operatorId);
      if (operator) {
        const updatedOperator: Operator = {
          ...operator,
          restakingDelegationCount: subtractToZero(operator.restakingDelegationCount, 1n),
          restakingUpdatedAt: timestamp,
        } as Operator;
        context.Operator.set(updatedOperator);
      }
    }
  });

  MultiAssetDelegation.BlueprintAddedToDelegation.handler(async ({ event, context }) => {
    recordDelegationBlueprintEvent(context, "ADDED", event, {
      delegator: normalizeAddress(event.params.delegator),
      delegationIndex: toBigInt(event.params.delegationIndex),
      blueprintId: toBigInt(event.params.blueprintId),
    });
  });

  MultiAssetDelegation.BlueprintRemovedFromDelegation.handler(async ({ event, context }) => {
    recordDelegationBlueprintEvent(context, "REMOVED", event, {
      delegator: normalizeAddress(event.params.delegator),
      delegationIndex: toBigInt(event.params.delegationIndex),
      blueprintId: toBigInt(event.params.blueprintId),
    });
  });

  MultiAssetDelegation.AssetEnabled.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const asset = await ensureRestakingAsset(context, event.params.token, timestamp);
    context.RestakingAsset.set({
      ...asset,
      enabled: true,
      minOperatorStake: toBigInt(event.params.minOperatorStake),
      minDelegation: toBigInt(event.params.minDelegation),
      updatedAt: timestamp,
    });
  });

  MultiAssetDelegation.AssetDisabled.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const asset = await ensureRestakingAsset(context, event.params.token, timestamp);
    context.RestakingAsset.set({ ...asset, enabled: false, updatedAt: timestamp });
  });

  MultiAssetDelegation.RoundAdvanced.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const roundValue = toBigInt(event.params.round);
    const round: RestakingRound = {
      id: roundValue.toString(),
      round: roundValue,
      blockNumber: getBlockNumber(event),
      timestamp,
    } as RestakingRound;
    context.RestakingRound.set(round);
    context.RestakingRound.set({ ...round, id: "latest" });
  });

  MultiAssetDelegation.Slashed.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const operator = await ensureOperator(context, event.params.operator, timestamp);
    const slash: RestakingSlash = {
      id: getEventId(event),
      operator_id: operator.id,
      serviceId: toBigInt(event.params.serviceId),
      operatorSlashed: toBigInt(event.params.operatorSlashed),
      delegatorsSlashed: toBigInt(event.params.delegatorsSlashed),
      exchangeRateAfter: toBigInt(event.params.newExchangeRate),
      blockNumber: getBlockNumber(event),
      txHash: getTxHash(event),
    } as RestakingSlash;
    context.RestakingSlash.set(slash);
    const remainingStake = subtractToZero(operator.restakingStake, toBigInt(event.params.operatorSlashed));
    const updatedOperator: Operator = { ...operator, restakingStake: remainingStake } as Operator;
    context.Operator.set(updatedOperator);
    await maybeDeactivateOperatorParticipation(context, updatedOperator, timestamp);
  });

  MultiAssetDelegation.SlashRecorded.handler(async ({ event, context }) => {
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

  MultiAssetDelegation.RewardDistributed.handler(async ({ event, context }) => {
    const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
    createRewardDistribution(context, "POOL", event, {
      operator_id: operator.id,
      amount: toBigInt(event.params.amount),
    });
  });

  MultiAssetDelegation.RewardClaimed.handler(async ({ event, context }) => {
    const delegator = await ensureDelegator(context, event.params.account, getTimestamp(event));
    createRestakingRewardClaim(context, "DELEGATOR_CLAIM", event, {
      delegator_id: delegator.id,
      amount: toBigInt(event.params.amount),
    });
  });

  /* ────────────────────────────────────────────────────────────────────────────
     OPERATOR STATUS REGISTRY
     ────────────────────────────────────────────────────────────────────────── */

  OperatorStatusRegistry.HeartbeatReceived.handler(async ({ event, context }) => {
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

  OperatorStatusRegistry.OperatorWentOffline.handler(async ({ event, context }) => {
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

  OperatorStatusRegistry.OperatorCameOnline.handler(async ({ event, context }) => {
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

  OperatorStatusRegistry.StatusChanged.handler(async ({ event, context }) => {
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

  OperatorStatusRegistry.HeartbeatConfigUpdated.handler(async ({ event, context }) => {
    const entity: HeartbeatConfig = {
      id: toBigInt(event.params.serviceId).toString(),
      serviceId: toBigInt(event.params.serviceId),
      interval: toBigInt(event.params.interval),
      maxMissed: toNumber(event.params.maxMissed),
      updatedAt: getTimestamp(event),
    } as HeartbeatConfig;
    context.HeartbeatConfig.set(entity);
  });

  OperatorStatusRegistry.MetricReported.handler(async ({ event, context }) => {
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

  OperatorStatusRegistry.SlashingTriggered.handler(async ({ event, context }) => {
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
}
