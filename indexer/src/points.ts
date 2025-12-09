import type {
  PointsAccount,
  PointsEvent,
  PointsProgram,
  PointsSnapshot,
} from "generated/src/Types.gen";

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
};

interface ProgramDefinition {
  id: string;
  name: string;
  description: string;
  category: string;
  network: string;
  weight: number;
}

export const PROGRAMS = {
  "operator-registration": {
    id: "operator-registration",
    name: "Operator Registration",
    description: "Registration bonus",
    category: "OPERATOR",
    network: "GENERIC",
    weight: 100,
  },
  "operator-stake": {
    id: "operator-stake",
    name: "Operator Stake",
    description: "Self-stake boost",
    category: "OPERATOR",
    network: "GENERIC",
    weight: 10,
  },
  "delegator-deposit": {
    id: "delegator-deposit",
    name: "Delegator Deposit",
    description: "Depositing assets into restaking",
    category: "DELEGATOR",
    network: "GENERIC",
    weight: 5,
  },
  "delegation": {
    id: "delegation",
    name: "Delegation",
    description: "Delegating stake to operators",
    category: "DELEGATOR",
    network: "GENERIC",
    weight: 8,
  },
  "credit-claim": {
    id: "credit-claim",
    name: "Credit Claim",
    description: "Claiming off-chain credits",
    category: "CREDIT",
    network: "GENERIC",
    weight: 3,
  },
  "service-activity": {
    id: "service-activity",
    name: "Service Activity",
    description: "Submitting jobs or results",
    category: "SERVICE",
    network: "GENERIC",
    weight: 2,
  },
  "operator-hourly": {
    id: "operator-hourly",
    name: "Operator Uptime",
    description: "Hourly reward for active operators",
    category: "OPERATOR",
    network: "GENERIC",
    weight: 1,
  },
  "delegator-hourly": {
    id: "delegator-hourly",
    name: "Delegator Uptime",
    description: "Hourly reward for active delegators",
    category: "DELEGATOR",
    network: "GENERIC",
    weight: 1,
  },
  "service-hourly": {
    id: "service-hourly",
    name: "Service Uptime",
    description: "Hourly reward for active services",
    category: "SERVICE",
    network: "GENERIC",
    weight: 1,
  },
} satisfies Record<string, ProgramDefinition>;

export type PointsProgramId = keyof typeof PROGRAMS;

let pointsEventCounter = 0;

export async function ensurePointsProgram(
  context: PointsContext,
  programId: PointsProgramId,
  timestamp: bigint
): Promise<PointsProgram> {
  const def = PROGRAMS[programId];
  if (!def) {
    throw new Error(`Unknown points program ${programId}`);
  }
  const existing = await context.PointsProgram.get(def.id);
  if (existing) {
    return existing;
  }
  const program: PointsProgram = {
    id: def.id,
    name: def.name,
    description: def.description,
    category: def.category,
    network: def.network,
    weight: def.weight,
    createdAt: timestamp,
  } as PointsProgram;
  context.PointsProgram.set(program);
  return program;
}

export class PointsManager {
  constructor(
    private readonly context: PointsContext,
    private readonly blockNumber: bigint,
    private readonly timestamp: bigint,
    private readonly txHash: string
  ) {}

  async award(accountId: string, programId: PointsProgramId, amount: bigint, reason?: string, metadata?: string) {
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
      leaderboardScore: (account.totalPoints ?? 0n) + amount,
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
      blockNumber: this.blockNumber,
      timestamp: this.timestamp,
    } as PointsSnapshot;

    this.context.PointsAccount.set(updatedAccount);
    this.context.PointsEvent.set(event);
    this.context.PointsSnapshot.set(snapshot);
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
        leaderboardScore: 0n,
        updatedAt: this.timestamp,
      } as PointsAccount;
    }
    return account;
  }
}
