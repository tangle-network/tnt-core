import {
  Credits,
  InflationPool,
  MultiAssetDelegation,
  OperatorStatusRegistry,
  RewardVaults,
  Tangle,
  onBlock,
} from "generated";
import type {
  Blueprint,
  CreditBalance,
  CreditOperation,
  DepositLock,
  DelegationBlueprintEvent,
  DelegationPosition,
  DelegationUnstakeRequest,
  Delegator,
  DelegatorAssetPosition,
  EscrowBalance,
  HeartbeatConfig,
  JobCall,
  JobResult,
  Operator,
  OperatorHeartbeat,
  OperatorIntent,
  OperatorLifecycleEvent,
  OperatorMetricSnapshot,
  OperatorRegistration,
  OperatorStakeChange,
  ParticipationState,
  PointsAccount,
  PointsEvent,
  PointsProgram,
  PointsSnapshot,
  ProtocolState,
  QuoteUsage,
  RestakingAsset,
  RestakingRewardClaim,
  RestakingRound,
  RestakingSlash,
  RewardClaim,
  RewardDistribution,
  RewardVault,
  RewardVaultEvent,
  RewardVaultState,
  Role,
  RoleAssignment,
  Service,
  ServiceOperator,
  ServiceRequest,
  SlashConfig,
  SlashProposal,
  SlashRecord,
  SubscriptionBilling,
  Upgrade,
  WithdrawRequest,
} from "generated/src/Types.gen";
import type { PointsContext, PointsProgramId } from "./points";
import { PointsManager, ensurePointsProgram } from "./points";

type PointsProgramCategory = "OPERATOR" | "DELEGATOR" | "SERVICE" | "CREDIT" | "BONUS";
type RewardVaultEventType = "DECAY_UPDATED" | "COMMISSION_UPDATED" | "LOCK_DURATIONS_UPDATED";
type DelegationSelectionMode = "ALL" | "FIXED";
type LockMultiplier = "NONE" | "ONE_MONTH" | "TWO_MONTHS" | "THREE_MONTHS" | "SIX_MONTHS";
type RequestStatus = "PENDING" | "READY" | "EXECUTED" | "CANCELLED";
type RewardDistributionKind = "POOL" | "DELEGATOR_CLAIM" | "OPERATOR_COMMISSION" | "INFLATION";
type DelegationBlueprintAction = "ADDED" | "REMOVED";

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const GLOBAL_PROTOCOL_ID = "tangle-protocol";
const GLOBAL_SLASH_CONFIG_ID = "slash-config";
const HOURLY_INTERVAL = 3600n;
const HOURLY_BLOCK_INTERVAL = 300;
const AVERAGE_BLOCK_TIME = 12n;

const HOURLY_PROGRAMS: Array<{
  programId: PointsProgramId;
  category: PointsProgramCategory;
  statePrefix: string;
}> = [
  { programId: "operator-hourly", category: "OPERATOR", statePrefix: "operator" },
  { programId: "delegator-hourly", category: "DELEGATOR", statePrefix: "delegator" },
  { programId: "service-hourly", category: "SERVICE", statePrefix: "service" },
];

const normalizeAddress = (value: string | { toString(): string } | undefined | null) =>
  (value ? value.toString().toLowerCase() : ZERO_ADDRESS);

const toHexString = (value: string | { toString(): string } | undefined | null) => (value ? value.toString() : "");
const toBigInt = (value: bigint | number | string | undefined | null): bigint => {
  if (typeof value === "bigint") return value;
  if (typeof value === "number") return BigInt(value);
  if (typeof value === "string" && value.length > 0) return BigInt(value);
  return 0n;
};
const toNumber = (value: bigint | number | undefined | null) =>
  typeof value === "number" ? value : value ? Number(value) : 0;
const getTimestamp = (event: { block: { timestamp: number } }) => BigInt(event.block.timestamp);
const getBlockNumber = (event: { block: { number: number | string } }) =>
  BigInt(typeof event.block.number === "string" ? Number(event.block.number) : event.block.number ?? 0);
const getTxHash = (event: { transaction?: { hash?: string }; block: { hash: string } }) =>
  event.transaction?.hash ?? event.block.hash;
const getEventId = (event: { block: { hash: string }; logIndex: number }) => `${event.block.hash}-${event.logIndex}`;

const toPointsValue = (amount: bigint) => {
  if (amount <= 0n) return 0n;
  const scaled = amount / 10_000_000_000_000_000n;
  return scaled > 0n ? scaled : 1n;
};

const mapLockMultiplier = (value: number | bigint | undefined): LockMultiplier => {
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

const mapSelectionMode = (value: number | bigint | undefined): DelegationSelectionMode =>
  Number(value ?? 0) === 1 ? "FIXED" : "ALL";

type EventLike = { block: { number: number | string; timestamp: number; hash: string }; transaction?: { hash?: string } };

const getPointsManager = (context: PointsContext, event: EventLike) =>
  new PointsManager(context, getBlockNumber(event), getTimestamp(event), getTxHash(event));

const ensureProtocolState = async (
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

const ensureSlashConfig = async (
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
  }
  return config;
};

const ensureOperator = async (
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

const ensureRestakingAsset = async (
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

const ensureDelegator = async (
  context: { Delegator: { get: (id: string) => Promise<Delegator | undefined>; set: (entity: Delegator) => void } },
  address: string,
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

const ensureAssetPosition = async (
  context: { DelegatorAssetPosition: { get: (id: string) => Promise<DelegatorAssetPosition | undefined>; set: (entity: DelegatorAssetPosition) => void } },
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

const ensureDelegationPosition = async (
  context: { DelegationPosition: { get: (id: string) => Promise<DelegationPosition | undefined>; set: (entity: DelegationPosition) => void } },
  delegator: Delegator,
  operator: Operator,
  token: string | undefined,
  mode: DelegationSelectionMode,
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
      selectionMode: mode,
      createdAtRound: round,
      updatedAtRound: round,
    } as DelegationPosition;
  }
  position = { ...position, selectionMode: mode, updatedAtRound: round, lastKnownAmount: position.lastKnownAmount ?? 0n };
  context.DelegationPosition.set(position);
  return position;
};

const getParticipationId = (programId: string, entityId: string) => `${programId}:${entityId}`;

const ensureParticipationState = async (
  context: any,
  program: PointsProgram,
  entityId: string,
  category: PointsProgramCategory,
  timestamp: bigint
) => {
  const id = getParticipationId(program.id, entityId);
  let state = await context.ParticipationState.get(id);
  if (!state) {
    state = {
      id,
      entityId,
      program_id: program.id,
      category,
      active: true,
      lastAwardAt: timestamp,
    } as ParticipationState;
  }
  return state;
};

const activateParticipation = async (
  context: any,
  programId: PointsProgramId,
  entityId: string,
  category: PointsProgramCategory,
  timestamp: bigint
) => {
  const program = await ensurePointsProgram(pointsContext(context), programId, timestamp);
  const state = await ensureParticipationState(context, program, entityId, category, timestamp);
  context.ParticipationState.set({ ...state, active: true } as ParticipationState);
};

const deactivateParticipation = async (
  context: any,
  programId: PointsProgramId,
  entityId: string,
  timestamp: bigint
) => {
  const program = await ensurePointsProgram(pointsContext(context), programId, timestamp);
  const id = getParticipationId(program.id, entityId);
  const current = await context.ParticipationState.get(id);
  if (!current) return;
  context.ParticipationState.set({ ...current, active: false } as ParticipationState);
};

const recordOperatorStakeChange = async (
  context: { OperatorStakeChange: { set: (entity: OperatorStakeChange) => void } },
  operator: Operator,
  kind: string,
  amount: bigint | undefined,
  readyRound: bigint | undefined,
  event: EventLike & { logIndex: number }
) => {
  const change: OperatorStakeChange = {
    id: `stake-${operator.id}-${getEventId(event)}`,
    operator_id: operator.id,
    kind: kind as OperatorStakeChange["kind"],
    amount,
    readyRound,
    blockNumber: getBlockNumber(event),
    timestamp: getTimestamp(event),
    txHash: getTxHash(event),
  } as OperatorStakeChange;
  context.OperatorStakeChange.set(change);
};

const settleWithdrawRequest = async (
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

const settleUnstakeRequest = async (
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

const createRewardDistribution = (
  context: { RewardDistribution: { set: (entity: RewardDistribution) => void } },
  kind: RewardDistributionKind,
  event: EventLike & { logIndex: number },
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

const createRestakingRewardClaim = (
  context: { RestakingRewardClaim: { set: (entity: RestakingRewardClaim) => void } },
  kind: RewardDistributionKind,
  event: EventLike & { logIndex: number },
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

const recordDelegationBlueprintEvent = (
  context: { DelegationBlueprintEvent: { set: (entity: DelegationBlueprintEvent) => void } },
  action: DelegationBlueprintAction,
  event: EventLike & { logIndex: number },
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

const recordRewardVaultEvent = (
  context: { RewardVaultEvent: { set: (entity: RewardVaultEvent) => void } },
  eventType: RewardVaultEventType,
  event: EventLike & { logIndex: number },
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

const pointsContext = (context: any): PointsContext => ({
  PointsProgram: context.PointsProgram,
  PointsAccount: context.PointsAccount,
  PointsEvent: context.PointsEvent,
  PointsSnapshot: context.PointsSnapshot,
});

/* ────────────────────────────────────────────────────────────────────────────
   TANGLE EVENTS
   ────────────────────────────────────────────────────────────────────────── */

Tangle.BlueprintCreated.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const blueprint: Blueprint = {
    id: toBigInt(event.params.blueprintId).toString(),
    blueprintId: toBigInt(event.params.blueprintId),
    owner: normalizeAddress(event.params.owner),
    manager: normalizeAddress(event.params.manager),
    metadataUri: undefined,
    active: true,
    createdAt: timestamp,
    updatedAt: timestamp,
    operatorCount: 0n,
  } as Blueprint;
  context.Blueprint.set(blueprint);
});

Tangle.BlueprintUpdated.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const id = toBigInt(event.params.blueprintId).toString();
  const existing = await context.Blueprint.get(id);
  if (!existing) return;
  context.Blueprint.set({ ...existing, metadataUri: event.params.metadataUri, updatedAt: timestamp });
});

Tangle.BlueprintTransferred.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const id = toBigInt(event.params.blueprintId).toString();
  const existing = await context.Blueprint.get(id);
  if (!existing) return;
  context.Blueprint.set({ ...existing, owner: normalizeAddress(event.params.to), updatedAt: timestamp });
});

Tangle.BlueprintDeactivated.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const id = toBigInt(event.params.blueprintId).toString();
  const existing = await context.Blueprint.get(id);
  if (!existing) return;
  context.Blueprint.set({ ...existing, active: false, updatedAt: timestamp });
});

Tangle.OperatorPreRegistered.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const intent: OperatorIntent = {
    id: getEventId(event),
    blueprint_id: toBigInt(event.params.blueprintId).toString(),
    operator_id: operator.id,
    createdAt: timestamp,
    txHash: getTxHash(event),
  } as OperatorIntent;
  context.OperatorIntent.set(intent);
});

Tangle.OperatorRegistered.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const blueprintId = toBigInt(event.params.blueprintId).toString();
  const blueprint = await context.Blueprint.get(blueprintId);
  const operator = await ensureOperator(context, event.params.operator, timestamp, {
    ecdsaPublicKey: toHexString(event.params.ecdsaPublicKey),
    rpcAddress: event.params.rpcAddress,
  });
  const regId = `${blueprintId}-${operator.id}`;
  const registration: OperatorRegistration = {
    id: regId,
    blueprint_id: blueprintId,
    operator_id: operator.id,
    status: "ACTIVE",
    registeredAt: timestamp,
    updatedAt: timestamp,
    unregisteredAt: undefined,
    ecdsaPublicKey: operator.ecdsaPublicKey,
    rpcAddress: operator.rpcAddress,
  } as OperatorRegistration;
  context.OperatorRegistration.set(registration);
  if (blueprint) {
    context.Blueprint.set({ ...blueprint, operatorCount: (blueprint.operatorCount ?? 0n) + 1n } as Blueprint);
  }
});

Tangle.OperatorUnregistered.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const blueprintId = toBigInt(event.params.blueprintId).toString();
  const operatorId = normalizeAddress(event.params.operator);
  const regId = `${blueprintId}-${operatorId}`;
  const registration = await context.OperatorRegistration.get(regId);
  if (!registration) return;
  context.OperatorRegistration.set({ ...registration, status: "UNREGISTERED", unregisteredAt: timestamp, updatedAt: timestamp });
});

Tangle.OperatorPreferencesUpdated.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp, {
    ecdsaPublicKey: toHexString(event.params.ecdsaPublicKey) || undefined,
    rpcAddress: event.params.rpcAddress || undefined,
  });
  const blueprintId = toBigInt(event.params.blueprintId).toString();
  const regId = `${blueprintId}-${operator.id}`;
  const registration = await context.OperatorRegistration.get(regId);
  if (registration) {
    context.OperatorRegistration.set({
      ...registration,
      ecdsaPublicKey: operator.ecdsaPublicKey,
      rpcAddress: operator.rpcAddress,
      updatedAt: timestamp,
    });
  }
});

Tangle.ServiceRequested.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const id = toBigInt(event.params.requestId).toString();
  const request: ServiceRequest = {
    id,
    requestId: toBigInt(event.params.requestId),
    blueprint_id: toBigInt(event.params.blueprintId).toString(),
    requester: normalizeAddress(event.params.requester),
    createdAt: timestamp,
    updatedAt: timestamp,
    status: "PENDING",
    approvalCount: 0n,
    approvedOperators: [],
    rejectedOperators: [],
    operatorCandidates: [],
    securityRequirements: undefined,
  } as ServiceRequest;
  context.ServiceRequest.set(request);
});

Tangle.ServiceRequestedWithSecurity.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const id = toBigInt(event.params.requestId).toString();
  const request = await context.ServiceRequest.get(id);
  if (!request) return;
  context.ServiceRequest.set({
    ...request,
    operatorCandidates: (event.params.operators || []).map((op) => normalizeAddress(op)),
    securityRequirements: JSON.stringify(event.params.securityRequirements ?? []),
    updatedAt: timestamp,
  });
});

Tangle.ServiceApproved.handler(async ({ event, context }) => {
  const id = toBigInt(event.params.requestId).toString();
  const request = await context.ServiceRequest.get(id);
  if (!request) return;
  const operator = normalizeAddress(event.params.operator);
  if (request.approvedOperators?.includes(operator)) return;
  context.ServiceRequest.set({
    ...request,
    approvedOperators: [...(request.approvedOperators ?? []), operator],
    approvalCount: (request.approvalCount ?? 0n) + 1n,
  });
});

Tangle.ServiceRejected.handler(async ({ event, context }) => {
  const id = toBigInt(event.params.requestId).toString();
  const request = await context.ServiceRequest.get(id);
  if (!request) return;
  const operator = normalizeAddress(event.params.operator);
  if (request.rejectedOperators?.includes(operator)) return;
  context.ServiceRequest.set({
    ...request,
    rejectedOperators: [...(request.rejectedOperators ?? []), operator],
  });
});

Tangle.ServiceActivated.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const serviceId = toBigInt(event.params.serviceId).toString();
  const blueprintId = toBigInt(event.params.blueprintId).toString();
  const requestId = toBigInt(event.params.requestId).toString();
  const request = await context.ServiceRequest.get(requestId);
  const service: Service = {
    id: serviceId,
    serviceId: toBigInt(event.params.serviceId),
    blueprint_id: blueprintId,
    request_id: request?.id,
    owner: request?.requester ?? ZERO_ADDRESS,
    status: "ACTIVE",
    createdAt: timestamp,
    terminatedAt: undefined,
  } as Service;
  context.Service.set(service);
  if (request) {
    context.ServiceRequest.set({ ...request, status: "ACTIVATED", updatedAt: timestamp });
  }
  await activateParticipation(context, "service-hourly", service.id, "SERVICE", timestamp);
});

Tangle.ServiceTerminated.handler(async ({ event, context }) => {
  const serviceId = toBigInt(event.params.serviceId).toString();
  const service = await context.Service.get(serviceId);
  if (!service) return;
  const timestamp = getTimestamp(event);
  context.Service.set({ ...service, status: "TERMINATED", terminatedAt: timestamp });
  await deactivateParticipation(context, "service-hourly", service.id, timestamp);
});

Tangle.OperatorJoinedService.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const id = `${service.id}-${operator.id}`;
  const membership: ServiceOperator = {
    id,
    service_id: service.id,
    operator_id: operator.id,
    exposureBps: BigInt(event.params.exposureBps ?? 0),
    joinedAt: timestamp,
    active: true,
  } as ServiceOperator;
  context.ServiceOperator.set(membership);
});

Tangle.OperatorLeftService.handler(async ({ event, context }) => {
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
  const membership = await context.ServiceOperator.get(id);
  if (!membership) return;
  context.ServiceOperator.set({ ...membership, active: false, leftAt: getTimestamp(event) });
});

Tangle.ExitScheduled.handler(async ({ event, context }) => {
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
  const membership = await context.ServiceOperator.get(id);
  if (!membership) return;
  context.ServiceOperator.set({ ...membership, exitScheduledAt: getTimestamp(event), exitExecuteAfter: toBigInt(event.params.executeAfter) });
});

Tangle.ExitCanceled.handler(async ({ event, context }) => {
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
  const membership = await context.ServiceOperator.get(id);
  if (!membership) return;
  context.ServiceOperator.set({ ...membership, exitScheduledAt: undefined, exitExecuteAfter: undefined, exitCancelledAt: getTimestamp(event) });
});

Tangle.ExitForced.handler(async ({ event, context }) => {
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const id = `${service.id}-${normalizeAddress(event.params.operator)}`;
  const membership = await context.ServiceOperator.get(id);
  if (!membership) return;
  context.ServiceOperator.set({
    ...membership,
    active: false,
    leftAt: getTimestamp(event),
    exitScheduledAt: undefined,
    exitExecuteAfter: undefined,
    exitForcedBy: normalizeAddress(event.params.forcer),
  });
});

Tangle.JobSubmitted.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const callId = toBigInt(event.params.callId).toString();
  const job: JobCall = {
    id: `${service.id}-${callId}`,
    service_id: service.id,
    callId: toBigInt(event.params.callId),
    jobIndex: toNumber(event.params.jobIndex),
    caller: normalizeAddress(event.params.caller),
    inputs: toHexString(event.params.inputs),
    createdAt: timestamp,
    completed: false,
  } as JobCall;
  context.JobCall.set(job);
  await getPointsManager(pointsContext(context), event).award(job.caller, "service-activity", 1n, "job submitted");
});

Tangle.JobResultSubmitted.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const serviceId = toBigInt(event.params.serviceId).toString();
  const callId = toBigInt(event.params.callId).toString();
  const job = await context.JobCall.get(`${serviceId}-${callId}`);
  if (!job) return;
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const result: JobResult = {
    id: `${serviceId}-${callId}-${operator.id}`,
    jobCall_id: job.id,
    operator_id: operator.id,
    output: toHexString(event.params.output),
    aggregated: false,
    submittedAt: timestamp,
    txHash: getTxHash(event),
  } as JobResult;
  context.JobResult.set(result);
  await getPointsManager(pointsContext(context), event).award(operator.id, "service-activity", 1n, "job result");
});

Tangle.JobCompleted.handler(async ({ event, context }) => {
  const serviceId = toBigInt(event.params.serviceId).toString();
  const job = await context.JobCall.get(`${serviceId}-${toBigInt(event.params.callId).toString()}`);
  if (!job) return;
  context.JobCall.set({ ...job, completed: true, completedAt: getTimestamp(event) });
});

Tangle.AggregatedResultSubmitted.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const serviceId = toBigInt(event.params.serviceId).toString();
  const callId = toBigInt(event.params.callId).toString();
  const job = await context.JobCall.get(`${serviceId}-${callId}`);
  if (!job) return;
  const result: JobResult = {
    id: `${serviceId}-${callId}-aggregate`,
    jobCall_id: job.id,
    operator_id: undefined,
    output: toHexString(event.params.output),
    signerBitmap: toBigInt(event.params.signerBitmap),
    aggregated: true,
    submittedAt: timestamp,
    txHash: getTxHash(event),
  } as JobResult;
  context.JobResult.set(result);
  const service = await context.Service.get(job.service_id ?? "");
  const owner = service?.owner ?? ZERO_ADDRESS;
  await getPointsManager(pointsContext(context), event).award(owner, "service-activity", 1n, "aggregated result");
});

Tangle.EscrowFunded.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const id = service.id;
  const existing = await context.EscrowBalance.get(id);
  const balance: EscrowBalance = {
    id,
    service_id: service.id,
    token: normalizeAddress(event.params.token ?? existing?.token ?? ZERO_ADDRESS),
    totalFunded: (existing?.totalFunded ?? 0n) + toBigInt(event.params.amount),
    totalBilled: existing?.totalBilled ?? 0n,
    lastFundedAt: timestamp,
    lastBilledAt: existing?.lastBilledAt,
  } as EscrowBalance;
  context.EscrowBalance.set(balance);
});

Tangle.SubscriptionBilled.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const service = await context.Service.get(toBigInt(event.params.serviceId).toString());
  if (!service) return;
  const id = service.id;
  const existing = await context.EscrowBalance.get(id);
  const balance: EscrowBalance = {
    id,
    service_id: service.id,
    token: existing?.token ?? ZERO_ADDRESS,
    totalFunded: existing?.totalFunded ?? 0n,
    totalBilled: (existing?.totalBilled ?? 0n) + toBigInt(event.params.amount),
    lastFundedAt: existing?.lastFundedAt,
    lastBilledAt: timestamp,
  } as EscrowBalance;
  context.EscrowBalance.set(balance);
  const billing: SubscriptionBilling = {
    id: getEventId(event),
    service_id: service.id,
    amount: toBigInt(event.params.amount),
    period: toBigInt(event.params.period),
    billedAt: timestamp,
    txHash: getTxHash(event),
  } as SubscriptionBilling;
  context.SubscriptionBilling.set(billing);
});

Tangle.RewardsClaimed.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const claim: RewardClaim = {
    id: getEventId(event),
    account: normalizeAddress(event.params.account),
    token: normalizeAddress(event.params.token),
    amount: toBigInt(event.params.amount),
    claimedAt: timestamp,
    txHash: getTxHash(event),
  } as RewardClaim;
  context.RewardClaim.set(claim);
});

Tangle.RoleAdminChanged.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const role: Role = {
    id: toHexString(event.params.role),
    role: toHexString(event.params.role),
    adminRole: toHexString(event.params.newAdminRole),
    updatedAt: timestamp,
  } as Role;
  context.Role.set(role);
});

Tangle.RoleGranted.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const roleId = toHexString(event.params.role);
  const assignment: RoleAssignment = {
    id: `${roleId}-${normalizeAddress(event.params.account)}`,
    roleRef_id: roleId,
    account: normalizeAddress(event.params.account),
    active: true,
    grantedAt: timestamp,
    sender: normalizeAddress(event.params.sender),
  } as RoleAssignment;
  context.RoleAssignment.set(assignment);
});

Tangle.RoleRevoked.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const roleId = toHexString(event.params.role);
  const id = `${roleId}-${normalizeAddress(event.params.account)}`;
  const assignment = await context.RoleAssignment.get(id);
  if (!assignment) return;
  context.RoleAssignment.set({ ...assignment, active: false, revokedAt: timestamp, sender: normalizeAddress(event.params.sender) });
});

Tangle.ServiceTerminated.handler(async ({ event, context }) => {
  const serviceId = toBigInt(event.params.serviceId).toString();
  const service = await context.Service.get(serviceId);
  if (!service) return;
  const timestamp = getTimestamp(event);
  context.Service.set({ ...service, status: "TERMINATED", terminatedAt: timestamp });
  await deactivateParticipation(context, "service-hourly", service.id, timestamp);
});

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
  const operator = await ensureOperator(context, event.params.operator, timestamp, {
    restakingScheduledUnstakeAmount: toBigInt(event.params.amount),
    restakingScheduledUnstakeReadyRound: toBigInt(event.params.readyRound),
    restakingUpdatedAt: timestamp,
  });
  await recordOperatorStakeChange(context, operator, "UNSTAKE_SCHEDULED", toBigInt(event.params.amount), toBigInt(event.params.readyRound), event);
});

MultiAssetDelegation.OperatorUnstakeExecuted.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const operator = await ensureOperator(context, event.params.operator, timestamp);
  const stake = (operator.restakingStake ?? 0n) - toBigInt(event.params.amount);
  context.Operator.set({
    ...operator,
    restakingStake: stake < 0n ? 0n : stake,
    restakingScheduledUnstakeAmount: undefined,
    restakingScheduledUnstakeReadyRound: undefined,
    restakingUpdatedAt: timestamp,
  } as Operator);
  await recordOperatorStakeChange(context, operator, "UNSTAKE_EXECUTED", toBigInt(event.params.amount), undefined, event);
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
  const multiplier = mapLockMultiplier(event.params.lock as any);
  if (multiplier !== "NONE") {
    const lock: DepositLock = {
      id: `lock-${position.id}-${getEventId(event)}`,
      position_id: position.id,
      amount,
      multiplier,
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
    totalDeposited: (position.totalDeposited ?? 0n) - amount,
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
    readyRound: toBigInt(event.params.readyRound),
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
  const mode = mapSelectionMode(event.params.selectionMode as any);
  const position = await ensureDelegationPosition(context, delegator, operator, event.params.token, mode, round, timestamp);
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
  const updatedOperator: Operator = {
    ...operator,
    restakingDelegationCount: (operator.restakingDelegationCount ?? 0n) + 1n,
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
    readyRound: toBigInt(event.params.readyRound),
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
  if (position) {
    const updated: DelegationPosition = {
      ...position,
      shares: (position.shares ?? 0n) - shares,
      lastKnownAmount: (position.lastKnownAmount ?? 0n) - amount,
    } as DelegationPosition;
    context.DelegationPosition.set(updated);
  }
  const updatedDelegator: Delegator = {
    ...delegator,
    totalDelegated: (delegator.totalDelegated ?? 0n) - amount,
  } as Delegator;
  context.Delegator.set(updatedDelegator);
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
  context.Operator.set({ ...operator, restakingStake: (operator.restakingStake ?? 0n) - toBigInt(event.params.operatorSlashed) } as Operator);
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
  await getPointsManager(pointsContext(context), event).award(delegator.id, "service-activity", toPointsValue(toBigInt(event.params.amount)), "restaking reward");
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

/* ────────────────────────────────────────────────────────────────────────────
   REWARD VAULTS & INFLATION
   ────────────────────────────────────────────────────────────────────────── */

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
  context.RewardVaultState.set({ ...state, totalDeposits: (state.totalDeposits ?? 0n) + toBigInt(event.params.amount), updatedAt: timestamp } as RewardVaultState);
});

RewardVaults.UnstakeRecorded.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const { state } = await ensureRewardVault(context, event.params.asset, timestamp, {});
  context.RewardVaultState.set({ ...state, totalDeposits: (state.totalDeposits ?? 0n) - toBigInt(event.params.amount), updatedAt: timestamp } as RewardVaultState);
});

RewardVaults.RewardsDistributed.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const { state } = await ensureRewardVault(context, event.params.asset, timestamp, {});
  context.RewardVaultState.set({ ...state, rewardsDistributed: (state.rewardsDistributed ?? 0n) + toBigInt(event.params.poolReward), updatedAt: timestamp } as RewardVaultState);
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

/* ────────────────────────────────────────────────────────────────────────────
   CREDIT CLAIMS
   ────────────────────────────────────────────────────────────────────────── */

Credits.CreditsClaimed.handler(async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const account = normalizeAddress(event.params.account);
  const balanceId = account;
  let balance = await context.CreditBalance.get(balanceId);
  if (!balance) {
    balance = {
      id: balanceId,
      account,
      amount: 0n,
      lastUpdatedAt: timestamp,
    } as CreditBalance;
  }
  const amount = toBigInt(event.params.amount);
  const updated: CreditBalance = { ...balance, amount: (balance.amount ?? 0n) + amount, lastUpdatedAt: timestamp } as CreditBalance;
  context.CreditBalance.set(updated);
  const operation: CreditOperation = {
    id: getEventId(event),
    balance_id: balanceId,
    operationType: "CLAIM",
    amount,
    blockNumber: getBlockNumber(event),
    timestamp,
    txHash: getTxHash(event),
    offchainAccountId: event.params.offchainAccountId,
  } as CreditOperation;
  context.CreditOperation.set(operation);
  await getPointsManager(pointsContext(context), event).award(account, "credit-claim", toPointsValue(amount), "credit claim");
});

/* ────────────────────────────────────────────────────────────────────────────
   HOURLY PARTICIPATION BLOCK HANDLER
   ────────────────────────────────────────────────────────────────────────── */

const processParticipation = async (
  context: any,
  programId: PointsProgramId,
  timestamp: bigint,
  points: PointsManager
) => {
  const program = await ensurePointsProgram(pointsContext(context), programId, timestamp);
  const states = (await context.ParticipationState.getWhere.program_id.eq(program.id)) as ParticipationState[];
  for (const state of states) {
    if (!state.active) continue;
    if (timestamp - (state.lastAwardAt ?? 0n) < HOURLY_INTERVAL) continue;
    await points.award(state.entityId, programId, 1n, "hourly participation");
    context.ParticipationState.set({ ...state, lastAwardAt: timestamp } as ParticipationState);
  }
};

onBlock({ name: "hourly-participation", chain: 84532, interval: HOURLY_BLOCK_INTERVAL }, async ({ block, context }) => {
  const blockNumber = typeof block.number === "string" ? BigInt(block.number) : BigInt(block.number ?? 0);
  const timestamp = blockNumber * AVERAGE_BLOCK_TIME;
  const blockHash = `hourly-${block.number}`;
  const points = new PointsManager(pointsContext(context), blockNumber, timestamp, blockHash);
  for (const program of HOURLY_PROGRAMS) {
    await processParticipation(context, program.programId, timestamp, points);
  }
});
