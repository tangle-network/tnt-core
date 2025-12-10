import type { PointsProgram as PointsProgramEntity, PointsProgram } from "generated/src/Types.gen";

interface ProgramDefinition {
  id: string;
  name: string;
  description: string;
  category: string;
  network: PointsProgramEntity["network"];
  weight: number;
}

const normalizeNetwork = (value: string | undefined, fallback: PointsProgramEntity["network"]) => {
  if (!value) return fallback;
  const upper = value.toUpperCase();
  if (upper === "MAINNET" || upper === "TESTNET" || upper === "GENERIC") {
    return upper as PointsProgramEntity["network"];
  }
  return fallback;
};

const getProgramNetwork = (programId: string, fallback: PointsProgramEntity["network"] = "MAINNET") => {
  const envKey = `POINTS_NETWORK_${programId.replace(/-/g, "_").toUpperCase()}`;
  return normalizeNetwork(process.env[envKey] ?? process.env.POINTS_NETWORK, fallback);
};

export const PROGRAMS = {
  "operator-registration": {
    id: "operator-registration",
    name: "Operator Registration",
    description: "Registration bonus",
    category: "OPERATOR",
    network: getProgramNetwork("operator-registration"),
    weight: 100,
  },
  "operator-stake": {
    id: "operator-stake",
    name: "Operator Stake",
    description: "Self-stake boost",
    category: "OPERATOR",
    network: getProgramNetwork("operator-stake"),
    weight: 10,
  },
  "operator-uptime": {
    id: "operator-uptime",
    name: "Operator Uptime",
    description: "Heartbeats and service participation",
    category: "OPERATOR",
    network: getProgramNetwork("operator-uptime"),
    weight: 3,
  },
  "delegator-deposit": {
    id: "delegator-deposit",
    name: "Delegator Deposit",
    description: "Depositing assets into restaking",
    category: "DELEGATOR",
    network: getProgramNetwork("delegator-deposit"),
    weight: 5,
  },
  delegation: {
    id: "delegation",
    name: "Delegation",
    description: "Delegating stake to operators",
    category: "DELEGATOR",
    network: getProgramNetwork("delegation"),
    weight: 8,
  },
  "restaker-vault": {
    id: "restaker-vault",
    name: "Vault Stake",
    description: "Locking restaked assets into vaults",
    category: "DELEGATOR",
    network: getProgramNetwork("restaker-vault"),
    weight: 6,
  },
  "liquid-vault-deposit": {
    id: "liquid-vault-deposit",
    name: "Liquid Vault Deposit",
    description: "Depositing into liquid delegation vaults",
    category: "DELEGATOR",
    network: getProgramNetwork("liquid-vault-deposit"),
    weight: 4,
  },
  "liquid-unstake": {
    id: "liquid-unstake",
    name: "Liquid Vault Withdrawals",
    description: "Penalty when exiting liquid vaults",
    category: "DELEGATOR",
    network: getProgramNetwork("liquid-unstake"),
    weight: 2,
  },
  "native-pod": {
    id: "native-pod",
    name: "Validator Pod",
    description: "Creating validator pods",
    category: "DELEGATOR",
    network: getProgramNetwork("native-pod", "TESTNET"),
    weight: 25,
  },
  "customer-service": {
    id: "customer-service",
    name: "Service Instantiation",
    description: "Requesting and activating services",
    category: "SERVICE",
    network: getProgramNetwork("customer-service"),
    weight: 4,
  },
  "customer-escrow": {
    id: "customer-escrow",
    name: "Service Funding",
    description: "Funding and maintaining service escrows",
    category: "SERVICE",
    network: getProgramNetwork("customer-escrow"),
    weight: 4,
  },
  "service-activity": {
    id: "service-activity",
    name: "Service Activity",
    description: "Submitting jobs or aggregated results",
    category: "SERVICE",
    network: getProgramNetwork("service-activity"),
    weight: 2,
  },
  "operator-service": {
    id: "operator-service",
    name: "Service Participation",
    description: "Joining services as an operator",
    category: "OPERATOR",
    network: getProgramNetwork("operator-service"),
    weight: 15,
  },
  "operator-service-hourly": {
    id: "operator-service-hourly",
    name: "Operator Service Uptime",
    description: "Hourly reward for active service operators",
    category: "OPERATOR",
    network: getProgramNetwork("operator-service-hourly"),
    weight: 1,
  },
  "developer-blueprint": {
    id: "developer-blueprint",
    name: "Blueprint Deployment",
    description: "Publishing new blueprints",
    category: "BONUS",
    network: getProgramNetwork("developer-blueprint"),
    weight: 10,
  },
  "operator-hourly": {
    id: "operator-hourly",
    name: "Operator Uptime",
    description: "Hourly reward for active operators",
    category: "OPERATOR",
    network: getProgramNetwork("operator-hourly"),
    weight: 1,
  },
  "delegator-hourly": {
    id: "delegator-hourly",
    name: "Delegator Uptime",
    description: "Hourly reward for active delegators",
    category: "DELEGATOR",
    network: getProgramNetwork("delegator-hourly"),
    weight: 1,
  },
  "service-hourly": {
    id: "service-hourly",
    name: "Service Uptime",
    description: "Hourly reward for active services",
    category: "SERVICE",
    network: getProgramNetwork("service-hourly"),
    weight: 1,
  },
} satisfies Record<string, ProgramDefinition>;

export type PointsProgramId = keyof typeof PROGRAMS;

export async function ensurePointsProgram(
  context: {
    PointsProgram: { get: (id: string) => Promise<PointsProgram | undefined>; set: (entity: PointsProgram) => void };
  },
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
