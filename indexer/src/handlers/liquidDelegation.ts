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
import { awardRestakerVaultStake } from "../points/awards";

const getVaultId = (address: string) => normalizeAddress(address);

const getPositionId = (vaultId: string, accountId: string) => `${vaultId}-${accountId}`;

const ensureVaultEntity = async (context: any, vaultAddress: string): Promise<LiquidVaultEntity | undefined> => {
  const id = getVaultId(vaultAddress);
  return (await context.LiquidDelegationVault.get(id)) as LiquidVaultEntity | undefined;
};

const saveVaultEntity = (context: any, entity: LiquidVaultEntity) => {
  context.LiquidDelegationVault.set(entity);
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
      firstMintedAt: timestamp,
      updatedAt: timestamp,
    } as LiquidVaultPosition;
  }
  return position;
};

const savePosition = (context: any, position: LiquidVaultPosition) => {
  context.LiquidVaultPosition.set(position);
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
      createdAt: timestamp,
      updatedAt: timestamp,
      txHash: getTxHash(event),
      isNative: assetAddress === ZERO_ADDRESS,
    } as LiquidVaultEntity;
    saveVaultEntity(context, entity);
    const registrar = (context as any).contracts;
    if (registrar?.addLiquidDelegationVault) {
      registrar.addLiquidDelegationVault(vaultAddress);
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
    await awardRestakerVaultStake(points, owner, vault.id, assets);
  });

  LiquidDelegationVault.Withdraw.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vault = await ensureVaultEntity(context, event.srcAddress);
    if (!vault) return;
    const assets = toBigInt(event.params.assets);
    const updatedVault: LiquidVaultEntity = {
      ...vault,
      totalAssets: subtractToZero(vault.totalAssets, assets),
      pendingRedeemShares: subtractToZero(vault.pendingRedeemShares, toBigInt(event.params.shares)),
      updatedAt: timestamp,
    } as LiquidVaultEntity;
    saveVaultEntity(context, updatedVault);

    const controller = normalizeAddress(event.params.owner);
    const requestId = await resolveRedeemRequest(context, updatedVault.id, controller, toBigInt(event.params.shares));
    if (requestId) {
      const req = (await context.LiquidRedeemRequest.get(requestId)) as LiquidRedeemRequest | undefined;
      if (req) {
        context.LiquidRedeemRequest.set({
          ...req,
          claimed: true,
          claimedAt: timestamp,
          claimer: normalizeAddress(event.params.receiver),
        } as LiquidRedeemRequest);
      }
    }
  });

  LiquidDelegationVault.RedeemRequest.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const vault = await ensureVaultEntity(context, event.srcAddress);
    if (!vault) return;
    const controller = normalizeAddress(event.params.controller);
    const owner = normalizeAddress(event.params.owner);
    const id = `${vault.id}-${controller}-${toBigInt(event.params.requestId).toString()}`;
    const request: LiquidRedeemRequest = {
      id,
      vault_id: vault.id,
      controller,
      owner_id: owner,
      requestId: toBigInt(event.params.requestId),
      shares: toBigInt(event.params.shares),
      requestedRound: 0n,
      claimed: false,
      createdAt: timestamp,
      txHash: getTxHash(event),
    } as LiquidRedeemRequest;
    context.LiquidRedeemRequest.set(request);
    const updatedVault: LiquidVaultEntity = {
      ...vault,
      totalShares: subtractToZero(vault.totalShares, request.shares),
      pendingRedeemShares: (vault.pendingRedeemShares ?? 0n) + request.shares,
      updatedAt: timestamp,
    } as LiquidVaultEntity;
    saveVaultEntity(context, updatedVault);
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
    savePosition(context, { ...position, shares: nextShares, updatedAt: timestamp } as LiquidVaultPosition);
    if (nextShares === 0n) {
      if ((position.shares ?? 0n) > 0n && totalDepositors > 0n) {
        totalDepositors -= 1n;
      }
      await maybeDeactivateDelegatorParticipation(context, delegator, timestamp);
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

const resolveRedeemRequest = async (
  context: any,
  vaultId: string,
  controller: string,
  shares: bigint
) => {
  const requests = (await context.LiquidRedeemRequest.getWhere.vault_id.eq(vaultId)) as LiquidRedeemRequest[];
  const pending = requests.find(
    (req) => !req.claimed && req.controller === controller && (req.shares ?? 0n) === shares
  );
  return pending?.id;
};
