import type {
  CreditLedger,
  CreditLedgerAccount,
  DelegationBlueprintEvent,
  DelegationPosition,
  DelegationUnstakeRequest,
  Delegator,
  DelegatorAssetPosition,
  LiquidVaultPosition,
  Operator,
  OperatorStakeChange,
  ProtocolState,
  RestakingAsset,
  RestakingRewardClaim,
  RewardDistribution,
  RewardVaultEvent,
  SlashConfig,
  SlashProposal,
  WithdrawRequest,
} from "generated/src/Types.gen";
import type { PointsContext } from "../points";
import { PointsManager } from "../points";
import { deactivateParticipation } from "../points/participation";

export type RewardVaultEventType = "DECAY_UPDATED" | "COMMISSION_UPDATED" | "LOCK_DURATIONS_UPDATED";
export type BlueprintSelectionMode = "ALL" | "FIXED";
export type LockDuration = "NONE" | "ONE_MONTH" | "TWO_MONTHS" | "THREE_MONTHS" | "SIX_MONTHS";
export type RequestStatus = "PENDING" | "READY" | "EXECUTED" | "CANCELLED";
export type RewardDistributionKind = "POOL" | "DELEGATOR_CLAIM" | "OPERATOR_COMMISSION" | "INFLATION";
export type DelegationBlueprintAction = "ADDED" | "REMOVED";

export const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
export const GLOBAL_PROTOCOL_ID = "tangle-protocol";
export const GLOBAL_SLASH_CONFIG_ID = "slash-config";
export const HOURLY_BLOCK_INTERVAL = 300;

// Chain ID - reads from INDEXER_CHAIN_ID env var, defaults to 31337 for local dev
// Production (config.yaml) uses 84532 (Base Sepolia), local (config.local.yaml) uses 31337
export const CHAIN_ID = parseInt(process.env.INDEXER_CHAIN_ID || "31337") as 31337 | 84532;

export type EventLike = {
  block: { hash: string; number: number | string; timestamp: number };
  transaction?: { hash?: string };
  logIndex: number;
};

export const normalizeAddress = (value: string | { toString(): string } | undefined | null) =>
  (value ? value.toString().toLowerCase() : ZERO_ADDRESS);

export const toHexString = (value: string | { toString(): string } | undefined | null) => (value ? value.toString() : "");

export const toBigInt = (value: bigint | number | string | undefined | null): bigint => {
  if (typeof value === "bigint") return value;
  if (typeof value === "number") return BigInt(value);
  if (typeof value === "string" && value.length > 0) return BigInt(value);
  return 0n;
};

export const toNumber = (value: bigint | number | undefined | null) =>
  typeof value === "number" ? value : value ? Number(value) : 0;

export const getTimestamp = (event: { block: { timestamp: number } }) => BigInt(event.block.timestamp);

export const getBlockNumber = (event: { block: { number: number | string } }) =>
  BigInt(typeof event.block.number === "string" ? Number(event.block.number) : event.block.number ?? 0);

export const getTxHash = (event: { transaction?: { hash?: string }; block: { hash: string } }) =>
  event.transaction?.hash ?? event.block.hash;

export const getEventId = (event: { block: { hash: string }; logIndex: number }) => `${event.block.hash}-${event.logIndex}`;

export const getSlashProposalId = (value: bigint | number | string | undefined) => toBigInt(value ?? 0n).toString();

export const mapLockDuration = (value: number | bigint | undefined): LockDuration => {
  const numeric = typeof value === "bigint" ? Number(value) : value ?? 0;
  switch (numeric) {
    case 1:
      return "ONE_MONTH";
    case 2:
      return "TWO_MONTHS";
    case 3:
      return "THREE_MONTHS";
    case 4:
      return "SIX_MONTHS";
    default:
      return "NONE";
  }
};

export const mapBlueprintSelection = (value: number | bigint | undefined): BlueprintSelectionMode =>
  Number(value ?? 0) === 1 ? "FIXED" : "ALL";

export const getPointsManager = (context: PointsContext, event: EventLike) =>
  new PointsManager(context, getBlockNumber(event), getTimestamp(event), getTxHash(event));

export const ensureProtocolState = async (
  context: { ProtocolState: { get: (id: string) => Promise<ProtocolState | undefined>; set: (entity: ProtocolState) => void } },
  timestamp: bigint
) => {
  let state = await context.ProtocolState.get(GLOBAL_PROTOCOL_ID);
  if (!state) {
    state = {
      id: GLOBAL_PROTOCOL_ID,
      paused: false,
      lastUpdatedAt: timestamp,
    } as ProtocolState;
  }
  context.ProtocolState.set(state);
  return state;
};

export const ensureSlashConfig = async (
  context: { SlashConfig: { get: (id: string) => Promise<SlashConfig | undefined>; set: (entity: SlashConfig) => void } },
  timestamp: bigint
) => {
  let config = await context.SlashConfig.get(GLOBAL_SLASH_CONFIG_ID);
  if (!config) {
    config = {
      id: GLOBAL_SLASH_CONFIG_ID,
      disputeWindow: 0n,
      instantSlashEnabled: false,
      maxSlashBps: 0n,
      updatedAt: timestamp,
    } as SlashConfig;
    context.SlashConfig.set(config);
  }
  return config;
};

export const getSlashProposal = async (
  context: { SlashProposal: { get: (id: string) => Promise<SlashProposal | undefined> } },
  slashId: bigint | number | string | undefined
) => context.SlashProposal.get(getSlashProposalId(slashId));

export const ensureOperator = async (
  context: { Operator: { get: (id: string) => Promise<Operator | undefined>; set: (entity: Operator) => void } },
  address: string | { toString(): string } | undefined,
  timestamp: bigint,
  patch: Partial<Operator> = {}
) => {
  const id = normalizeAddress(address);
  let operator = await context.Operator.get(id);
  if (!operator) {
    operator = {
      id,
      createdAt: timestamp,
      updatedAt: timestamp,
    } as Operator;
  }
  operator = { ...operator, updatedAt: timestamp, ...patch };
  context.Operator.set(operator);
  return operator;
};

export const ensureRestakingAsset = async (
  context: { RestakingAsset: { get: (id: string) => Promise<RestakingAsset | undefined>; set: (entity: RestakingAsset) => void } },
  token: string | undefined,
  timestamp: bigint
) => {
  const id = normalizeAddress(token ?? ZERO_ADDRESS);
  let asset = await context.RestakingAsset.get(id);
  if (!asset) {
    asset = {
      id,
      token: id,
      enabled: true,
      minOperatorStake: 0n,
      minDelegation: 0n,
      depositCap: 0n,
      currentDeposits: 0n,
      rewardMultiplierBps: 0,
      createdAt: timestamp,
      updatedAt: timestamp,
    } as RestakingAsset;
  }
  asset = { ...asset, updatedAt: timestamp };
  context.RestakingAsset.set(asset);
  return asset;
};

export const ensureDelegator = async (
  context: { Delegator: { get: (id: string) => Promise<Delegator | undefined>; set: (entity: Delegator) => void } },
  address: string | { toString(): string } | undefined,
  timestamp: bigint
) => {
  const id = normalizeAddress(address);
  let delegator = await context.Delegator.get(id);
  if (!delegator) {
    delegator = {
      id,
      address: id,
      totalDeposited: 0n,
      totalDelegated: 0n,
      createdAt: timestamp,
      updatedAt: timestamp,
      withdrawNonce: 0n,
      withdrawCursor: 0n,
      unstakeNonce: 0n,
      unstakeCursor: 0n,
    } as Delegator;
  }
  delegator = { ...delegator, updatedAt: timestamp };
  context.Delegator.set(delegator);
  return delegator;
};

export const ensureAssetPosition = async (
  context: {
    DelegatorAssetPosition: { get: (id: string) => Promise<DelegatorAssetPosition | undefined>; set: (entity: DelegatorAssetPosition) => void };
  },
  delegator: Delegator,
  token: string | undefined,
  timestamp: bigint
) => {
  const tokenAddr = normalizeAddress(token ?? ZERO_ADDRESS);
  const id = `${delegator.id}-${tokenAddr}`;
  let position = await context.DelegatorAssetPosition.get(id);
  if (!position) {
    position = {
      id,
      delegator_id: delegator.id,
      token: tokenAddr,
      totalDeposited: 0n,
      delegatedAmount: 0n,
      lockedAmount: 0n,
      lastUpdatedAt: timestamp,
    } as DelegatorAssetPosition;
  }
  position = { ...position, lastUpdatedAt: timestamp };
  context.DelegatorAssetPosition.set(position);
  return position;
};

export const ensureDelegationPosition = async (
  context: { DelegationPosition: { get: (id: string) => Promise<DelegationPosition | undefined>; set: (entity: DelegationPosition) => void } },
  delegator: Delegator,
  operator: Operator,
  token: string | undefined,
  mode: BlueprintSelectionMode,
  round: bigint,
  timestamp: bigint
) => {
  const tokenAddr = normalizeAddress(token ?? ZERO_ADDRESS);
  const id = `${delegator.id}-${operator.id}-${tokenAddr}`;
  let position = await context.DelegationPosition.get(id);
  if (!position) {
    position = {
      id,
      delegator_id: delegator.id,
      operator_id: operator.id,
      token: tokenAddr,
      shares: 0n,
      lastKnownAmount: 0n,
      blueprintSelection: mode,
      createdAtRound: round,
      updatedAtRound: round,
    } as DelegationPosition;
  }
  position = {
    ...position,
    blueprintSelection: mode,
    updatedAtRound: round,
    lastKnownAmount: position.lastKnownAmount ?? 0n,
  };
  context.DelegationPosition.set(position);
  return position;
};

export const recordOperatorStakeChange = async (
  context: { OperatorStakeChange: { set: (entity: OperatorStakeChange) => void } },
  operator: Operator,
  kind: string,
  amount: bigint | undefined,
  readyAtRound: bigint | undefined,
  event: EventLike
) => {
  const change: OperatorStakeChange = {
    id: `stake-${operator.id}-${getEventId(event)}`,
    operator_id: operator.id,
    kind: kind as OperatorStakeChange["kind"],
    amount,
    readyAtRound,
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
  } as OperatorStakeChange;
  context.OperatorStakeChange.set(change);
};

export const settleWithdrawRequest = async (
  context: {
    WithdrawRequest: { get: (id: string) => Promise<WithdrawRequest | undefined>; set: (entity: WithdrawRequest) => void };
    Delegator: { set: (entity: Delegator) => void };
  },
  delegator: Delegator,
  token: string,
  amount: bigint,
  timestamp: bigint
) => {
  let cursor = delegator.withdrawCursor ?? 0n;
  while (cursor < (delegator.withdrawNonce ?? 0n)) {
    const requestId = `withdraw-${delegator.id}-${cursor}`;
    const request = await context.WithdrawRequest.get(requestId);
    if (request && request.status === "PENDING" && request.token === token && request.amount === amount) {
      const updated: WithdrawRequest = { ...request, status: "EXECUTED", executedAt: timestamp } as WithdrawRequest;
      context.WithdrawRequest.set(updated);
      const updatedDelegator: Delegator = { ...delegator, withdrawCursor: cursor + 1n } as Delegator;
      context.Delegator.set(updatedDelegator);
      return;
    }
    cursor += 1n;
  }
};

export const settleUnstakeRequest = async (
  context: {
    DelegationUnstakeRequest: { get: (id: string) => Promise<DelegationUnstakeRequest | undefined>; set: (entity: DelegationUnstakeRequest) => void };
    Delegator: { set: (entity: Delegator) => void };
  },
  delegator: Delegator,
  operatorId: string,
  token: string,
  shares: bigint,
  amount: bigint,
  timestamp: bigint
) => {
  let cursor = delegator.unstakeCursor ?? 0n;
  while (cursor < (delegator.unstakeNonce ?? 0n)) {
    const requestId = `unstake-${delegator.id}-${cursor}`;
    const request = await context.DelegationUnstakeRequest.get(requestId);
    if (request && request.status === "PENDING" && request.operator_id === operatorId && request.token === token && request.shares === shares) {
      const updated: DelegationUnstakeRequest = {
        ...request,
        estimatedAmount: amount,
        status: "EXECUTED" as RequestStatus,
        executedAt: timestamp,
      } as DelegationUnstakeRequest;
      context.DelegationUnstakeRequest.set(updated);
      const updatedDelegator: Delegator = { ...delegator, unstakeCursor: cursor + 1n } as Delegator;
      context.Delegator.set(updatedDelegator);
      return;
    }
    cursor += 1n;
  }
};

export const createRewardDistribution = (
  context: { RewardDistribution: { set: (entity: RewardDistribution) => void } },
  kind: RewardDistributionKind,
  event: EventLike,
  data: Partial<RewardDistribution>
) => {
  const entity: RewardDistribution = {
    id: `reward-${getEventId(event)}`,
    kind,
    asset: ZERO_ADDRESS,
    amount: 0n,
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
    ...data,
  } as RewardDistribution;
  context.RewardDistribution.set(entity);
};

export const createRestakingRewardClaim = (
  context: { RestakingRewardClaim: { set: (entity: RestakingRewardClaim) => void } },
  kind: RewardDistributionKind,
  event: EventLike,
  data: Partial<RestakingRewardClaim>
) => {
  const entity: RestakingRewardClaim = {
    id: `restaking-claim-${getEventId(event)}`,
    kind,
    asset: ZERO_ADDRESS,
    amount: 0n,
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
    ...data,
  } as RestakingRewardClaim;
  context.RestakingRewardClaim.set(entity);
};

export const recordDelegationBlueprintEvent = (
  context: { DelegationBlueprintEvent: { set: (entity: DelegationBlueprintEvent) => void } },
  action: DelegationBlueprintAction,
  event: EventLike,
  data: { delegator: string; delegationIndex: bigint; blueprintId: bigint }
) => {
  const entity: DelegationBlueprintEvent = {
    id: `${action.toLowerCase()}-${getEventId(event)}`,
    delegator: data.delegator,
    delegationIndex: data.delegationIndex,
    blueprintId: data.blueprintId,
    action,
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
  } as DelegationBlueprintEvent;
  context.DelegationBlueprintEvent.set(entity);
};

export const recordRewardVaultEvent = (
  context: { RewardVaultEvent: { set: (entity: RewardVaultEvent) => void } },
  eventType: RewardVaultEventType,
  event: EventLike,
  data: Partial<RewardVaultEvent>
) => {
  const vaultId = data.asset ? normalizeAddress(data.asset) : undefined;
  const entity: RewardVaultEvent = {
    id: `${eventType}-${getEventId(event)}`,
    eventType,
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
    vault_id: vaultId,
    ...data,
  } as RewardVaultEvent;
  context.RewardVaultEvent.set(entity);
};

export const subtractToZero = (current: bigint | undefined, delta: bigint) => {
  const next = (current ?? 0n) - delta;
  return next < 0n ? 0n : next;
};

export const ensureCreditLedger = async (
  context: { CreditLedger: { get: (id: string) => Promise<CreditLedger | undefined>; set: (entity: CreditLedger) => void } },
  offchainId: string,
  timestamp: bigint
) => {
  let ledger = await context.CreditLedger.get(offchainId);
  if (!ledger) {
    ledger = {
      id: offchainId,
      offchainAccountId: offchainId,
      totalClaimed: 0n,
      claimCount: 0n,
      lastClaimAt: timestamp,
    } as CreditLedger;
  }
  return ledger;
};

export const ensureCreditLedgerAccount = async (
  context: { CreditLedgerAccount: { get: (id: string) => Promise<CreditLedgerAccount | undefined>; set: (entity: CreditLedgerAccount) => void } },
  ledgerId: string,
  account: string,
  timestamp: bigint
) => {
  const id = `${ledgerId}-${account}`;
  let entry = await context.CreditLedgerAccount.get(id);
  if (!entry) {
    entry = {
      id,
      ledger_id: ledgerId,
      account,
      totalClaimed: 0n,
      claimCount: 0n,
      lastClaimAt: timestamp,
    } as CreditLedgerAccount;
  }
  return entry;
};

const hasLiquidVaultStake = async (context: any, delegatorId: string): Promise<boolean> => {
  if (!context.LiquidVaultPosition) {
    return false;
  }
  const positions = (await context.LiquidVaultPosition.getWhere.account_id.eq(delegatorId)) as LiquidVaultPosition[];
  return positions.some((position) => {
    const activeShares = position.shares ?? 0n;
    const pendingShares = position.pendingShares ?? 0n;
    const pendingAssets = position.pendingAssets ?? 0n;
    return activeShares + pendingShares > 0n || pendingAssets > 0n;
  });
};

export const maybeDeactivateDelegatorParticipation = async (context: any, delegator: Delegator, timestamp: bigint) => {
  const hasDirect = (delegator.totalDelegated ?? 0n) > 0n;
  const hasLiquid = await hasLiquidVaultStake(context, delegator.id);
  if (!hasDirect && !hasLiquid) {
    await deactivateParticipation(context, "delegator-hourly", delegator.id, timestamp);
  }
};

export const maybeDeactivateOperatorParticipation = async (context: any, operator: Operator, timestamp: bigint) => {
  if ((operator.restakingStake ?? 0n) <= 0n) {
    await deactivateParticipation(context, "operator-hourly", operator.id, timestamp);
  }
};
