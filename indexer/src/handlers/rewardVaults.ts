import { InflationPool, RewardVaults } from "generated";
import type { RewardVault, RewardVaultState } from "generated/src/Types.gen";
import {
  ZERO_ADDRESS,
  createRestakingRewardClaim,
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
import { awardRestakerVaultStake } from "../points/awards";

export function registerRewardVaultHandlers() {
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
        apyBps: 0n,
        depositCap: 0n,
        incentiveCap: 0n,
        boostMultiplierBps: 0n,
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
        lastUpdateBlock: 0n,
        updatedAt: timestamp,
      } as RewardVaultState;
    }
    context.RewardVaultState.set(state);
    return { vault, state };
  };

  RewardVaults.VaultCreated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    await ensureRewardVault(context, event.params.asset, timestamp, {
      apyBps: toBigInt(event.params.apyBps),
      depositCap: toBigInt(event.params.depositCap),
      incentiveCap: toBigInt(event.params.incentiveCap),
      active: true,
    });
  });

  RewardVaults.VaultConfigUpdated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    await ensureRewardVault(context, event.params.asset, timestamp, {
      apyBps: toBigInt(event.params.apyBps),
      depositCap: toBigInt(event.params.depositCap),
      incentiveCap: toBigInt(event.params.incentiveCap),
    });
  });

  RewardVaults.VaultDeactivated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    await ensureRewardVault(context, event.params.asset, timestamp, { active: false });
  });

  RewardVaults.StakeRecorded.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const { state } = await ensureRewardVault(context, event.params.asset, timestamp, {});
    context.RewardVaultState.set({
      ...state,
      totalDeposits: (state.totalDeposits ?? 0n) + toBigInt(event.params.amount),
      updatedAt: timestamp,
    } as RewardVaultState);
    const points = getPointsManager(pointsContext(context), event);
    await awardRestakerVaultStake(points, normalizeAddress(event.params.delegator), event.params.asset, toBigInt(event.params.amount));
  });

  RewardVaults.UnstakeRecorded.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const { state } = await ensureRewardVault(context, event.params.asset, timestamp, {});
    context.RewardVaultState.set({
      ...state,
      totalDeposits: (state.totalDeposits ?? 0n) - toBigInt(event.params.amount),
      updatedAt: timestamp,
    } as RewardVaultState);
  });

  RewardVaults.RewardsDistributed.handler(async ({ event, context }) => {
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

  RewardVaults.DelegatorRewardsClaimed.handler(async ({ event, context }) => {
    const delegator = await ensureDelegator(context, event.params.delegator, getTimestamp(event));
    createRestakingRewardClaim(context, "DELEGATOR_CLAIM", event, {
      delegator_id: delegator.id,
      operator_id: normalizeAddress(event.params.operator),
      asset: normalizeAddress(event.params.asset ?? ZERO_ADDRESS),
      amount: toBigInt(event.params.amount),
    });
  });

  RewardVaults.OperatorCommissionClaimed.handler(async ({ event, context }) => {
    const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
    createRewardDistribution(context, "OPERATOR_COMMISSION", event, {
      operator_id: operator.id,
      asset: normalizeAddress(event.params.asset ?? ZERO_ADDRESS),
      amount: toBigInt(event.params.amount),
    });
  });

  RewardVaults.DecayConfigUpdated.handler(async ({ event, context }) => {
    recordRewardVaultEvent(context, "DECAY_UPDATED", event, {
      valueA: toBigInt(event.params.startBlock),
      valueB: toBigInt(event.params.rateBps),
    });
  });

  RewardVaults.OperatorCommissionUpdated.handler(async ({ event, context }) => {
    recordRewardVaultEvent(context, "COMMISSION_UPDATED", event, { valueA: BigInt(event.params.newBps) });
  });

  RewardVaults.LockDurationsUpdated.handler(async ({ event, context }) => {
    recordRewardVaultEvent(context, "LOCK_DURATIONS_UPDATED", event, {
      valueA: toBigInt(event.params.oneMonth),
      valueB: toBigInt(event.params.twoMonths),
      valueC: toBigInt(event.params.threeMonths),
    });
  });

  InflationPool.OperatorRewardClaimed.handler(async ({ event, context }) => {
    const operator = await ensureOperator(context, event.params.operator, getTimestamp(event));
    createRewardDistribution(context, "INFLATION", event, {
      operator_id: operator.id,
      amount: toBigInt(event.params.amount),
    });
  });

  InflationPool.CustomerRewardClaimed.handler(async ({ event, context }) => {
    const delegator = await ensureDelegator(context, event.params.customer, getTimestamp(event));
    createRewardDistribution(context, "INFLATION", event, {
      delegator_id: delegator.id,
      amount: toBigInt(event.params.amount),
    });
  });

  InflationPool.DeveloperRewardClaimed.handler(async ({ event, context }) => {
    createRewardDistribution(context, "INFLATION", event, {
      delegator_id: normalizeAddress(event.params.developer),
      amount: toBigInt(event.params.amount),
    });
  });
}
