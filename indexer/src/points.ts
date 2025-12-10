import type { PointsAccount, PointsEvent, PointsHourlyTotal, PointsProgram, PointsSnapshot } from "generated/src/Types.gen";
import { ensurePointsProgram, PROGRAMS } from "./points/programs";
import type { PointsProgramId } from "./points/programs";
export { ensurePointsProgram } from "./points/programs";
export type { PointsProgramId } from "./points/programs";

export type PointsContext = {
  PointsProgram: {
    get: (id: string) => Promise<PointsProgram | undefined>;
    set: (entity: PointsProgram) => void;
  };
  PointsAccount: {
    get: (id: string) => Promise<PointsAccount | undefined>;
    set: (entity: PointsAccount) => void;
  };
  PointsEvent: {
    set: (entity: PointsEvent) => void;
  };
  PointsSnapshot: {
    set: (entity: PointsSnapshot) => void;
  };
  PointsHourlyTotal: {
    get: (id: string) => Promise<PointsHourlyTotal | undefined>;
    set: (entity: PointsHourlyTotal) => void;
  };
};

export type PointsAwardBasis = {
  usdValue?: bigint;
  liquidUsdValue?: bigint;
  serviceUsdValue?: bigint;
};

let pointsEventCounter = 0;

export class PointsManager {
  constructor(
    private readonly context: PointsContext,
    private readonly blockNumber: bigint,
    private readonly timestamp: bigint,
    private readonly txHash: string
  ) {}

  async award(
    accountId: string,
    programId: PointsProgramId,
    amount: bigint,
    reason?: string,
    metadata?: string,
    basis?: PointsAwardBasis
  ) {
    if (amount === 0n) {
      return;
    }
    const program = await ensurePointsProgram(this.context, programId, this.timestamp);
    const account = await this.ensureAccount(accountId);
    const updatedAccount: PointsAccount = {
      ...account,
      totalPoints: (account.totalPoints ?? 0n) + amount,
      totalMainnetPoints:
        program.network === "MAINNET" ? (account.totalMainnetPoints ?? 0n) + amount : account.totalMainnetPoints ?? 0n,
      totalTestnetPoints:
        program.network === "TESTNET" ? (account.totalTestnetPoints ?? 0n) + amount : account.totalTestnetPoints ?? 0n,
      leaderboardPoints: (account.leaderboardPoints ?? 0n) + amount,
      updatedAt: this.timestamp,
    } as PointsAccount;

    const eventId = `${this.txHash}-${programId}-${pointsEventCounter++}`;
    const event: PointsEvent = {
      id: eventId,
      account_id: updatedAccount.id,
      program_id: program.id,
      amount,
      reason,
      blockNumber: this.blockNumber,
      timestamp: this.timestamp,
      txHash: this.txHash,
      metadata,
    } as PointsEvent;

    const snapshot: PointsSnapshot = {
      id: `${eventId}-snapshot`,
      account_id: updatedAccount.id,
      program_id: program.id,
      totalPoints: updatedAccount.totalPoints,
      usdBasis: basis?.usdValue,
      liquidUsdBasis: basis?.liquidUsdValue,
      serviceUsdBasis: basis?.serviceUsdValue,
      blockNumber: this.blockNumber,
      timestamp: this.timestamp,
    } as PointsSnapshot;

    this.context.PointsAccount.set(updatedAccount);
    this.context.PointsEvent.set(event);
    this.context.PointsSnapshot.set(snapshot);
    await this.recordHourlyBasis(program.id, basis);
  }

  private async ensureAccount(address: string) {
    const id = address.toLowerCase();
    let account = await this.context.PointsAccount.get(id);
    if (!account) {
      account = {
        id,
        totalPoints: 0n,
        totalMainnetPoints: 0n,
        totalTestnetPoints: 0n,
        leaderboardPoints: 0n,
        updatedAt: this.timestamp,
      } as PointsAccount;
    }
    return account;
  }

  private async recordHourlyBasis(programId: string, basis?: PointsAwardBasis) {
    if (!basis) return;
    const usd = basis.usdValue ?? 0n;
    const liquid = basis.liquidUsdValue ?? 0n;
    const service = basis.serviceUsdValue ?? 0n;
    if (usd === 0n && liquid === 0n && service === 0n) {
      return;
    }
    const hour = (this.timestamp / 3600n) * 3600n;
    const id = `${programId}-${hour.toString()}`;
    const existing = await this.context.PointsHourlyTotal.get(id);
    const entity: PointsHourlyTotal = {
      id,
      program_id: programId,
      hourTimestamp: hour,
      usdBasis: (existing?.usdBasis ?? 0n) + usd,
      liquidUsdBasis: (existing?.liquidUsdBasis ?? 0n) + liquid,
      serviceUsdBasis: (existing?.serviceUsdBasis ?? 0n) + service,
      updatedAt: this.timestamp,
    } as PointsHourlyTotal;
    this.context.PointsHourlyTotal.set(entity);
  }
}
