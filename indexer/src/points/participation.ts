import type {
  Delegator,
  DelegatorAssetPosition,
  LiquidDelegationVault,
  LiquidVaultPosition,
  Operator,
  ParticipationState,
  PointsProgram,
  Service,
  ServiceOperator,
} from "generated/src/Types.gen";
import type { PointsContext, PointsProgramId } from "../points";
import { PointsManager, ensurePointsProgram } from "../points";
import { toPointsValue } from "./math";
import { getAssetMetadata, ZERO_ADDRESS } from "./assets";
import { ensureAssetPrice, getStoredAssetPrice, PRICE_SCALE } from "./prices";

export type PointsProgramCategory = "OPERATOR" | "DELEGATOR" | "SERVICE" | "CREDIT" | "BONUS";

export const HOURLY_PROGRAMS: Array<{ programId: PointsProgramId; category: PointsProgramCategory; statePrefix: string }> =
  [
    { programId: "operator-hourly", category: "OPERATOR", statePrefix: "operator" },
    { programId: "delegator-hourly", category: "DELEGATOR", statePrefix: "delegator" },
    { programId: "service-hourly", category: "SERVICE", statePrefix: "service" },
  ];

const USD_SCALE = 10n ** 18n;

type ParticipationValue = {
  total: bigint;
  directUsd?: bigint;
  liquidUsd?: bigint;
  serviceUsd?: bigint;
};


export const pointsContext = (context: any): PointsContext => ({
  PointsProgram: context.PointsProgram,
  PointsAccount: context.PointsAccount,
  PointsEvent: context.PointsEvent,
  PointsSnapshot: context.PointsSnapshot,
});

const getParticipationId = (programId: string, entityId: string) => `${programId}:${entityId}`;

const adjustAmountToScale = (amount: bigint, decimals: number) => {
  const diff = 18 - decimals;
  if (diff >= 0) {
    return amount * 10n ** BigInt(diff);
  }
  const divisor = 10n ** BigInt(-diff);
  return amount / divisor;
};

const convertAmountToUsd = async (context: any, amount: bigint, token: string | undefined, blockNumber: bigint, timestamp: bigint): Promise<bigint> => {
  if (amount === 0n) {
    return 0n;
  }
  const metadata = getAssetMetadata(token);
  const normalized = adjustAmountToScale(amount, metadata.decimals);
  let priceScaled = await getStoredAssetPrice(context, metadata);
  if (!priceScaled || priceScaled <= 0n) {
    priceScaled = await ensureAssetPrice(context, metadata, blockNumber, timestamp);
  }
  if (!priceScaled || priceScaled <= 0n) {
    return normalized;
  }
  return (normalized * priceScaled) / PRICE_SCALE;
};

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

export const activateParticipation = async (
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

export const deactivateParticipation = async (
  context: any,
  programId: PointsProgramId,
  entityId: string,
  timestamp: bigint
) => {
  const program = await ensurePointsProgram(pointsContext(context), programId, timestamp);
  const id = getParticipationId(program.id, entityId);
  const current = await context.ParticipationState.get(id);
  if (!current) {
    return;
  }
  context.ParticipationState.set({ ...current, active: false } as ParticipationState);
};

const getOperatorStakeBasis = async (context: any, operatorId: string, blockNumber: bigint, timestamp: bigint): Promise<bigint> => {
  const operator = (await context.Operator.get(operatorId)) as Operator | undefined;
  if (!operator) {
    return 0n;
  }
  return convertAmountToUsd(context, operator.restakingStake ?? 0n, ZERO_ADDRESS, blockNumber, timestamp);
};

const sumDelegatorPositions = async (
  context: any,
  delegator: Delegator,
  positions: DelegatorAssetPosition[],
  blockNumber: bigint,
  timestamp: bigint
): Promise<bigint> => {
  let total = 0n;
  for (const position of positions) {
    const amount = position.totalDeposited ?? 0n;
    if (amount === 0n) continue;
    total += await convertAmountToUsd(context, amount, position.token, blockNumber, timestamp);
  }
  if (total > 0n) {
    return total;
  }
  const fallbackAmount = delegator.totalDelegated ?? 0n;
  return convertAmountToUsd(context, fallbackAmount, ZERO_ADDRESS, blockNumber, timestamp);
};

const getLiquidVaultStakeBasis = async (
  context: any,
  delegatorId: string,
  blockNumber: bigint,
  timestamp: bigint
): Promise<bigint> => {
  if (!context.LiquidVaultPosition) {
    return 0n;
  }
  const positions = (await context.LiquidVaultPosition.getWhere.account_id.eq(delegatorId)) as LiquidVaultPosition[];
  let total = 0n;
  for (const position of positions) {
    const shares = position.shares ?? 0n;
    if (shares <= 0n) continue;
    const vault = (await context.LiquidDelegationVault.get(position.vault_id)) as LiquidDelegationVault | undefined;
    if (!vault) continue;
    const totalShares = vault.totalShares ?? 0n;
    const totalAssets = vault.totalAssets ?? 0n;
    if (totalShares === 0n || totalAssets === 0n) continue;
    const proportionalAssets = (shares * totalAssets) / totalShares;
    if (proportionalAssets === 0n) continue;
    total += await convertAmountToUsd(context, proportionalAssets, vault.assetAddress, blockNumber, timestamp);
  }
  return total;
};

const getDelegatorStakeBasis = async (context: any, delegatorId: string, blockNumber: bigint, timestamp: bigint): Promise<bigint> => {
  const delegator = (await context.Delegator.get(delegatorId)) as Delegator | undefined;
  if (!delegator) {
    return 0n;
  }
  const positions = (await context.DelegatorAssetPosition.getWhere.delegator_id.eq(delegator.id)) as DelegatorAssetPosition[];
  const direct = await sumDelegatorPositions(context, delegator, positions, blockNumber, timestamp);
  const liquid = await getLiquidVaultStakeBasis(context, delegator.id, blockNumber, timestamp);
  return direct + liquid;
};

const getServiceActivityBasis = async (context: any, serviceId: string): Promise<bigint> => {
  const service = (await context.Service.get(serviceId)) as Service | undefined;
  if (!service) {
    return 0n;
  }
  const memberships = (await context.ServiceOperator.getWhere.service_id.eq(service.id)) as ServiceOperator[];
  const activeCount = memberships.filter((membership) => membership.active).length;
  return BigInt(activeCount) * USD_SCALE;
};

const calculateParticipationValue = async (
  context: any,
  state: ParticipationState,
  blockNumber: bigint,
  timestamp: bigint
): Promise<ParticipationValue> => {
  if (state.category === "OPERATOR") {
    const total = await getOperatorStakeBasis(context, state.entityId, blockNumber, timestamp);
    return { total, directUsd: total };
  }
  if (state.category === "DELEGATOR") {
    const direct = await getDelegatorStakeBasis(context, state.entityId, blockNumber, timestamp);
    const liquid = await getLiquidVaultStakeBasis(context, state.entityId, blockNumber, timestamp);
    return { total: direct + liquid, directUsd: direct, liquidUsd: liquid };
  }
  if (state.category === "SERVICE") {
    const total = await getServiceActivityBasis(context, state.entityId);
    return { total, serviceUsd: total };
  }
  return { total: 0n };
};

export const processParticipation = async (
  context: any,
  programId: PointsProgramId,
  blockNumber: bigint,
  timestamp: bigint,
  points: PointsManager
) => {
  const program = await ensurePointsProgram(pointsContext(context), programId, timestamp);
  const states = (await context.ParticipationState.getWhere.program_id.eq(program.id)) as ParticipationState[];
  for (const state of states) {
    if (!state.active) continue;
    const sinceLastAward = timestamp - (state.lastAwardAt ?? 0n);
    if (sinceLastAward < 3600n) continue;
    const usdValue = await calculateParticipationValue(context, state, blockNumber, timestamp);
    const amount = toPointsValue(usdValue.total);
    if (amount === 0n) continue;
    await points.award(
      state.entityId,
      programId,
      amount,
      "hourly participation",
      undefined,
      {
        usdValue: usdValue.total,
        liquidUsdValue: usdValue.liquidUsd,
        serviceUsdValue: usdValue.serviceUsd,
      }
    );
    context.ParticipationState.set({ ...state, lastAwardAt: timestamp } as ParticipationState);
  }
};
