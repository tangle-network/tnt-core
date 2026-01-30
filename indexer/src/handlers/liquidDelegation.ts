import { LiquidDelegationFactory, LiquidDelegationVault } from "generated";
import type {
  LiquidDelegationVault as LiquidVaultEntity,
  LiquidRedeemRequest,
  LiquidVaultPosition,
  Operator,
  RestakingAsset,
} from "generated/src/Types.gen";
import {
  ZERO_ADDRESS,
  ensureDelegator,
  ensureOperator,
  ensureRestakingAsset,
  getPointsManager,
  getTimestamp,
  getTxHash,
  normalizeAddress,
  subtractToZero,
  toBigInt,
  maybeDeactivateDelegatorParticipation,
} from "../lib/handlerUtils";
import { activateParticipation, pointsContext } from "../points/participation";
import { awardLiquidVaultStake, penalizeLiquidVaultWithdraw } from "../points/awards";
import { upsertAssetMetadata } from "../points/assets";

const getVaultId = (address: string) => normalizeAddress(address);

const SHARE_PRICE_SCALE = 1_000_000n;

const computeDerivedScale = (vault: LiquidVaultEntity) => {
  const totalShares = vault.totalShares ?? 0n;
  const totalAssets = vault.totalAssets ?? 0n;
  if (totalShares === 0n || totalAssets === 0n) {
    return 1;
  }
  const scaled = (totalAssets * SHARE_PRICE_SCALE) / totalShares;
  return Number(scaled) / Number(SHARE_PRICE_SCALE);
};

const syncVaultAssetMetadata = (vault: LiquidVaultEntity) => {
  upsertAssetMetadata({
    address: vault.id,
    symbol: vault.symbol ?? `ld-${vault.id.slice(2, 6)}`,
    decimals: 18,
    category: "VAULT",
    derivedFrom: vault.assetAddress ?? ZERO_ADDRESS,
    derivedScale: computeDerivedScale(vault),
    description: vault.name ? `${vault.name} vault share` : undefined,
  });
};

const getPositionId = (vaultId: string, accountId: string) => `${vaultId}-${accountId}`;

const ensureVaultEntity = async (context: any, vaultAddress: string): Promise<LiquidVaultEntity | undefined> => {
  const id = getVaultId(vaultAddress);
  return (await context.LiquidDelegationVault.get(id)) as LiquidVaultEntity | undefined;
};

const saveVaultEntity = (context: any, entity: LiquidVaultEntity) => {
  context.LiquidDelegationVault.set(entity);
  syncVaultAssetMetadata(entity);
};

const ensurePosition = async (
  context: any,
  vaultId: string,
  accountId: string,
  timestamp: bigint
): Promise<LiquidVaultPosition> => {
  const id = getPositionId(vaultId, accountId);
  let position = (await context.LiquidVaultPosition.get(id)) as LiquidVaultPosition | undefined;
  if (!position) {
    position = {
      id,
      vault_id: vaultId,
      account_id: accountId,
      shares: 0n,
      pendingShares: 0n,
      pendingAssets: 0n,
      firstMintedAt: timestamp,
      updatedAt: timestamp,
    } as LiquidVaultPosition;
  }
  return position;
};

const savePosition = (context: any, position: LiquidVaultPosition) => {
  context.LiquidVaultPosition.set(position);
};

const applyDelta = (current: bigint | undefined, delta: bigint) => {
  if (delta >= 0n) {
    return (current ?? 0n) + delta;
  }
  return subtractToZero(current, -delta);
};

const adjustPendingPosition = async (
  context: any,
  vaultId: string,
  accountId: string,
  shareDelta: bigint,
  assetDelta: bigint,
  timestamp: bigint
) => {
  const position = await ensurePosition(context, vaultId, accountId, timestamp);
  const updated: LiquidVaultPosition = {
    ...position,
    pendingShares: applyDelta(position.pendingShares, shareDelta),
    pendingAssets: applyDelta(position.pendingAssets, assetDelta),
    updatedAt: timestamp,
  } as LiquidVaultPosition;
  savePosition(context, updated);
  return updated;
};

export function registerLiquidDelegationHandlers() {
  LiquidDelegationFactory.VaultCreated.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vaultAddress = normalizeAddress(event.params.vault);
    const operatorAddress = normalizeAddress(event.params.operator);
    const assetAddress = normalizeAddress(event.params.asset ?? ZERO_ADDRESS);
    const operator = (await ensureOperator(context, operatorAddress, timestamp)) as Operator;
    const asset = (await ensureRestakingAsset(context, assetAddress, timestamp)) as RestakingAsset;
    const existing = await ensureVaultEntity(context, vaultAddress);
    if (existing) {
      return;
    }
    const blueprintIds = (event.params.blueprintIds ?? []).map((value) => toBigInt(value));
    const blueprintSelection = blueprintIds.length > 0 ? "FIXED" : "ALL";
    const entity: LiquidVaultEntity = {
      id: vaultAddress,
      address: vaultAddress,
      operator_id: operator.id,
      asset_id: asset.id,
      assetAddress: assetAddress,
      name: event.params.name,
      symbol: event.params.symbol,
      blueprintSelection,
      blueprintIds,
      totalAssets: 0n,
      totalShares: 0n,
      totalDepositors: 0n,
      pendingRedeemShares: 0n,
       harvestedRewards: 0n,
      createdAt: timestamp,
      updatedAt: timestamp,
      txHash: getTxHash(event),
      isNative: assetAddress === ZERO_ADDRESS,
    } as LiquidVaultEntity;
    saveVaultEntity(context, entity);
    // Dynamic contract registration is optional and may not be available in all Envio versions
    try {
      const registrar = (context as any).contracts;
      if (registrar?.addLiquidDelegationVault) {
        registrar.addLiquidDelegationVault(vaultAddress);
      }
    } catch {
      // Dynamic registration not supported - vault addresses should be in config.yaml
    }
  });

  LiquidDelegationVault.Deposit.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vault = await ensureVaultEntity(context, event.srcAddress);
    if (!vault) return;
    const assets = toBigInt(event.params.assets);
    const shares = toBigInt(event.params.shares);
    const updatedVault: LiquidVaultEntity = {
      ...vault,
      totalAssets: (vault.totalAssets ?? 0n) + assets,
      totalShares: (vault.totalShares ?? 0n) + shares,
      updatedAt: timestamp,
    } as LiquidVaultEntity;
    saveVaultEntity(context, updatedVault);
    const owner = normalizeAddress(event.params.owner);
    const points = getPointsManager(pointsContext(context), event);
    await awardLiquidVaultStake(points, owner, vault.id, assets);
  });

  LiquidDelegationVault.Withdraw.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vault = await ensureVaultEntity(context, event.srcAddress);
    if (!vault) return;
    const assets = toBigInt(event.params.assets);
    const shares = toBigInt(event.params.shares);
    const updatedVault: LiquidVaultEntity = {
      ...vault,
      totalAssets: subtractToZero(vault.totalAssets, assets),
      pendingRedeemShares: subtractToZero(vault.pendingRedeemShares, shares),
      updatedAt: timestamp,
    } as LiquidVaultEntity;
    saveVaultEntity(context, updatedVault);

    const controller = normalizeAddress(event.params.owner);
    const request = await resolveRedeemRequest(context, updatedVault.id, controller, shares);
    if (request) {
      context.LiquidRedeemRequest.set({
        ...request,
        claimed: true,
        claimedAt: timestamp,
        claimer: normalizeAddress(event.params.receiver),
      } as LiquidRedeemRequest);
      if (request.owner_id) {
        await adjustPendingPosition(
          context,
          updatedVault.id,
          request.owner_id,
          -(request.shares ?? 0n),
          -(request.estimatedAssets ?? 0n),
          timestamp
        );
        const delegator = await ensureDelegator(context, request.owner_id, timestamp);
        await maybeDeactivateDelegatorParticipation(context, delegator, timestamp);
        const points = getPointsManager(pointsContext(context), event);
        await penalizeLiquidVaultWithdraw(points, request.owner_id, updatedVault.id, assets);
      }
    }
  });

  LiquidDelegationVault.RedeemRequest.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vault = await ensureVaultEntity(context, event.srcAddress);
    if (!vault) return;
    const controller = normalizeAddress(event.params.controller);
    const owner = normalizeAddress(event.params.owner);
    const shares = toBigInt(event.params.shares);
    const totalShares = vault.totalShares ?? 0n;
    const totalAssets = vault.totalAssets ?? 0n;
    const estimatedAssets = totalShares > 0n && totalAssets > 0n ? (shares * totalAssets) / totalShares : shares;
    const id = `${vault.id}-${controller}-${toBigInt(event.params.requestId).toString()}`;
    const request: LiquidRedeemRequest = {
      id,
      vault_id: vault.id,
      controller,
      owner_id: owner,
      requestId: toBigInt(event.params.requestId),
      shares,
      estimatedAssets,
      requestedRound: 0n,
      claimed: false,
      createdAt: timestamp,
      txHash: getTxHash(event),
    } as LiquidRedeemRequest;
    context.LiquidRedeemRequest.set(request);
    const updatedVault: LiquidVaultEntity = {
      ...vault,
      totalShares: subtractToZero(vault.totalShares, request.shares ?? 0n),
      pendingRedeemShares: (vault.pendingRedeemShares ?? 0n) + (request.shares ?? 0n),
      updatedAt: timestamp,
    } as LiquidVaultEntity;
    saveVaultEntity(context, updatedVault);
    await adjustPendingPosition(context, updatedVault.id, owner, shares, estimatedAssets, timestamp);
    await activateParticipation(context, "delegator-hourly", owner, "DELEGATOR", timestamp);
  });

  LiquidDelegationVault.Transfer.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vault = await ensureVaultEntity(context, event.srcAddress);
    if (!vault) return;
    const value = toBigInt(event.params.value);
    if (value === 0n) {
      return;
    }
    const from = normalizeAddress(event.params.from);
    const to = normalizeAddress(event.params.to);
    await handleShareMovement(context, vault, from, to, value, timestamp);
  });

  LiquidDelegationVault.RewardsHarvested.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vault = await ensureVaultEntity(context, event.srcAddress);
    if (!vault) return;
    const amount = toBigInt(event.params.amount);
    const updatedVault: LiquidVaultEntity = {
      ...vault,
      totalAssets: (vault.totalAssets ?? 0n) + amount,
      harvestedRewards: (vault.harvestedRewards ?? 0n) + amount,
      updatedAt: timestamp,
    } as LiquidVaultEntity;
    saveVaultEntity(context, updatedVault);
  });
}

const handleShareMovement = async (
  context: any,
  vault: LiquidVaultEntity,
  from: string,
  to: string,
  value: bigint,
  timestamp: bigint
) => {
  let totalDepositors = vault.totalDepositors ?? 0n;
  if (from !== ZERO_ADDRESS) {
    const delegator = await ensureDelegator(context, from, timestamp);
    const position = await ensurePosition(context, vault.id, delegator.id, timestamp);
    const nextShares = subtractToZero(position.shares, value);
    const updatedPosition: LiquidVaultPosition = { ...position, shares: nextShares, updatedAt: timestamp } as LiquidVaultPosition;
    savePosition(context, updatedPosition);
    if (nextShares === 0n) {
      if ((position.shares ?? 0n) > 0n && totalDepositors > 0n) {
        totalDepositors -= 1n;
      }
      const hasPending = (updatedPosition.pendingShares ?? 0n) > 0n || (updatedPosition.pendingAssets ?? 0n) > 0n;
      if (!hasPending) {
        await maybeDeactivateDelegatorParticipation(context, delegator, timestamp);
      }
    }
  }
  if (to !== ZERO_ADDRESS) {
    const delegator = await ensureDelegator(context, to, timestamp);
    const position = await ensurePosition(context, vault.id, delegator.id, timestamp);
    const nextShares = (position.shares ?? 0n) + value;
    savePosition(context, { ...position, shares: nextShares, updatedAt: timestamp } as LiquidVaultPosition);
    if (nextShares > 0n) {
      if ((position.shares ?? 0n) === 0n) {
        totalDepositors += 1n;
      }
      await activateParticipation(context, "delegator-hourly", delegator.id, "DELEGATOR", timestamp);
    }
  }
  saveVaultEntity(context, { ...vault, totalDepositors, updatedAt: timestamp } as LiquidVaultEntity);
};

const resolveRedeemRequest = async (context: any, vaultId: string, controller: string, shares: bigint) => {
  const requests = (await context.LiquidRedeemRequest.getWhere.vault_id.eq(vaultId)) as LiquidRedeemRequest[];
  return requests.find((req) => !req.claimed && req.controller === controller && (req.shares ?? 0n) === shares);
};
