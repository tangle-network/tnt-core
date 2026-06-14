import { indexer } from "envio";
import type { RewardVault, RewardVaultState } from "envio";
import {
  ZERO_ADDRESS,
  createStakingRewardClaim,
  createRewardDistribution,
  ensureDelegator,
  ensureOperator,
  getPointsManager,
  getTimestamp,
  normalizeAddress,
  recordRewardVaultEvent,
  toBigInt,
} from "../lib/handlerUtils";
import { pointsContext } from "../points/participation";
import { awardStakingVaultStake } from "../points/awards";

const ensureRewardVault = async (
  context: {
    RewardVault: { get: (id: string) => Promise<RewardVault | undefined>; set: (entity: RewardVault) => void };
    RewardVaultState: { get: (id: string) => Promise<RewardVaultState | undefined>; set: (entity: RewardVaultState) => void };
  },
  asset: string | undefined,
  timestamp: bigint,
  patch: Partial<RewardVault>
) => {
  const token = normalizeAddress(asset ?? ZERO_ADDRESS);
  let vault = await context.RewardVault.get(token);
  if (!vault) {
    vault = {
      id: token,
      asset: token,
      depositCap: 0n,
      active: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    } as RewardVault;
  }
  vault = { ...vault, updatedAt: timestamp, ...patch };
  context.RewardVault.set(vault);
  let state = await context.RewardVaultState.get(token);
  if (!state) {
    state = {
      id: token,
      vault_id: token,
      totalDeposits: 0n,
      totalScore: 0n,
      rewardsDistributed: 0n,
      updatedAt: timestamp,
    } as RewardVaultState;
  }
  context.RewardVaultState.set(state);
  return { vault, state };
};

indexer.onEvent({ contract: "RewardVaults", event: "VaultCreated" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  await ensureRewardVault(context, event.params.asset, timestamp, {
    depositCap: toBigInt(event.params.depositCap),
    active: true,
  });
});

indexer.onEvent({ contract: "RewardVaults", event: "VaultConfigUpdated" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  await ensureRewardVault(context, event.params.asset, timestamp, {
    depositCap: toBigInt(event.params.depositCap),
  });
});

indexer.onEvent({ contract: "RewardVaults", event: "VaultDeactivated" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  await ensureRewardVault(context, event.params.asset, timestamp, { active: false });
});

indexer.onEvent({ contract: "RewardVaults", event: "StakeRecorded" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const { state } = await ensureRewardVault(context, event.params.asset, timestamp, {});
  context.RewardVaultState.set({
    ...state,
    totalDeposits: (state.totalDeposits ?? 0n) + toBigInt(event.params.amount),
    updatedAt: timestamp,
  } as RewardVaultState);
  const points = getPointsManager(pointsContext(context), event);
  await awardStakingVaultStake(points, normalizeAddress(event.params.delegator), event.params.asset, toBigInt(event.params.amount));
});

indexer.onEvent({ contract: "RewardVaults", event: "UnstakeRecorded" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const { state } = await ensureRewardVault(context, event.params.asset, timestamp, {});
  context.RewardVaultState.set({
    ...state,
    totalDeposits: (state.totalDeposits ?? 0n) - toBigInt(event.params.amount),
    updatedAt: timestamp,
  } as RewardVaultState);
});

indexer.onEvent({ contract: "RewardVaults", event: "RewardsDistributed" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const { state } = await ensureRewardVault(context, event.params.asset, timestamp, {});
  context.RewardVaultState.set({
    ...state,
    rewardsDistributed: (state.rewardsDistributed ?? 0n) + toBigInt(event.params.poolReward),
    updatedAt: timestamp,
  } as RewardVaultState);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  createRewardDistribution(context, "POOL", event, {
    operator_id: operator.id,
    asset: normalizeAddress(event.params.asset ?? ZERO_ADDRESS),
    amount: toBigInt(event.params.poolReward),
    commission: toBigInt(event.params.commission),
  });
});

indexer.onEvent({ contract: "RewardVaults", event: "DelegatorRewardsClaimed" }, async ({ event, context }) => {
  const delegator = await ensureDelegator(context, event.params.delegator, getTimestamp(event));
  createStakingRewardClaim(context, "DELEGATOR_CLAIM", event, {
    delegator_id: delegator.id,
    operator_id: normalizeAddress(event.params.operator),
    asset: normalizeAddress(event.params.asset ?? ZERO_ADDRESS),
    amount: toBigInt(event.params.amount),
  });
});

indexer.onEvent({ contract: "RewardVaults", event: "OperatorCommissionClaimed" }, async ({ event, context }) => {
  const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
  createRewardDistribution(context, "OPERATOR_COMMISSION", event, {
    operator_id: operator.id,
    asset: normalizeAddress(event.params.asset ?? ZERO_ADDRESS),
    amount: toBigInt(event.params.amount),
  });
});

indexer.onEvent({ contract: "RewardVaults", event: "OperatorCommissionUpdated" }, async ({ event, context }) => {
  recordRewardVaultEvent(context, "COMMISSION_UPDATED", event, { valueA: BigInt(event.params.newBps) });
});

indexer.onEvent({ contract: "RewardVaults", event: "LockDurationsUpdated" }, async ({ event, context }) => {
  recordRewardVaultEvent(context, "LOCK_DURATIONS_UPDATED", event, {
    valueA: toBigInt(event.params.oneMonth),
    valueB: toBigInt(event.params.twoMonths),
    valueC: toBigInt(event.params.threeMonths),
  });
});

indexer.onEvent({ contract: "InflationPool", event: "OperatorRewardClaimed" }, async ({ event, context }) => {
  const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
  createRewardDistribution(context, "INFLATION", event, {
    operator_id: operator.id,
    amount: toBigInt(event.params.amount),
  });
});

indexer.onEvent({ contract: "InflationPool", event: "CustomerRewardClaimed" }, async ({ event, context }) => {
  const delegator = await ensureDelegator(context, event.params.customer, getTimestamp(event));
  createRewardDistribution(context, "INFLATION", event, {
    delegator_id: delegator.id,
    amount: toBigInt(event.params.amount),
  });
});

indexer.onEvent({ contract: "InflationPool", event: "DeveloperRewardClaimed" }, async ({ event, context }) => {
  createRewardDistribution(context, "INFLATION", event, {
    delegator_id: normalizeAddress(event.params.developer),
    amount: toBigInt(event.params.amount),
  });
});
