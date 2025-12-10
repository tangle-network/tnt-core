#!/usr/bin/env ts-node
import { convertAmountToUsd } from "../src/points/participation";
import { PointsProgramId } from "../src/points";
import { ZERO_ADDRESS } from "../src/lib/handlerUtils";

type Snapshot = {
  id: string;
  timestamp: bigint;
  account: { id: string };
  program: { id: PointsProgramId; category: string };
  usdBasis?: bigint | null;
  liquidUsdBasis?: bigint | null;
  serviceUsdBasis?: bigint | null;
};

type DelegatorState = {
  assetPositions: Array<{ token: string; totalDeposited: string }>;
  liquidVaultPositions: Array<{
    shares: string;
    pendingAssets: string;
    vault: { assetAddress: string; totalAssets: string; totalShares: string };
  }>;
};

const SNAPSHOT_CHUNK = 100;

const parseArgs = () => {
  const args = process.argv.slice(2);
  const options: { endpoint?: string; program?: PointsProgramId } = {};
  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    if (arg === "--endpoint" && args[i + 1]) {
      options.endpoint = args[++i];
    } else if (arg === "--program" && args[i + 1]) {
      options.program = args[++i] as PointsProgramId;
    } else if (arg === "--help") {
      console.log("Usage: pnpm ts-node scripts/backfill-points-basis.ts --endpoint <graph-url> [--program delegator-hourly]");
      process.exit(0);
    }
  }
  if (!options.endpoint) {
    throw new Error("Missing --endpoint");
  }
  options.program = options.program ?? ("delegator-hourly" as PointsProgramId);
  return options;
};

const fetchSnapshots = async (endpoint: string, programId: PointsProgramId, skip: number): Promise<Snapshot[]> => {
  const query = `
    query Snapshots($programId: String!, $skip: Int!) {
      pointsSnapshots(first: ${SNAPSHOT_CHUNK}, skip: $skip, where: { program: $programId }, orderBy: timestamp) {
        id
        timestamp
        usdBasis
        liquidUsdBasis
        serviceUsdBasis
        account { id }
        program { id category }
      }
    }
  `;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ query, variables: { programId, skip } }),
  });
  if (!response.ok) {
    throw new Error(`Failed to load snapshots: ${response.status} ${response.statusText}`);
  }
  const payload = (await response.json()) as {
    data?: { pointsSnapshots: Array<Omit<Snapshot, "timestamp"> & { timestamp: string }> };
    errors?: Array<{ message: string }>;
  };
  if (payload.errors?.length) {
    throw new Error(payload.errors.map((err) => err.message).join(", "));
  }
  return (payload.data?.pointsSnapshots ?? []).map((snapshot) => ({
    ...snapshot,
    timestamp: BigInt(snapshot.timestamp),
    usdBasis: snapshot.usdBasis ? BigInt(snapshot.usdBasis) : null,
    liquidUsdBasis: snapshot.liquidUsdBasis ? BigInt(snapshot.liquidUsdBasis) : null,
    serviceUsdBasis: snapshot.serviceUsdBasis ? BigInt(snapshot.serviceUsdBasis) : null,
  }));
};

const fetchDelegatorState = async (endpoint: string, delegatorId: string): Promise<DelegatorState | null> => {
  const query = `
    query DelegatorState($id: ID!) {
      delegator(id: $id) {
        assetPositions { token totalDeposited }
        liquidVaultPositions {
          shares
          pendingAssets
          vault { assetAddress totalAssets totalShares }
        }
      }
    }
  `;
  const response = await fetch(endpoint, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ query, variables: { id: delegatorId } }),
  });
  if (!response.ok) {
    throw new Error(`Failed to load delegator ${delegatorId}: ${response.statusText}`);
  }
  const payload = (await response.json()) as {
    data?: { delegator?: DelegatorState };
    errors?: Array<{ message: string }>;
  };
  if (payload.errors?.length) {
    throw new Error(payload.errors.map((err) => err.message).join(", "));
  }
  return payload.data?.delegator ?? null;
};

const makePriceContext = () => {
  const prices = new Map<string, { price: bigint }>();
  return {
    AssetPrice: {
      async get(id: string) {
        return prices.get(id.toLowerCase()) ?? null;
      },
      set(entity: { id: string; price: bigint }) {
        prices.set(entity.id.toLowerCase(), { price: entity.price });
      },
    },
    AssetPriceSample: {
      set() {
        return undefined;
      },
    },
  };
};

const computeDelegatorUsdBasis = async (endpoint: string, snapshot: Snapshot) => {
  const delegator = await fetchDelegatorState(endpoint, snapshot.account.id);
  if (!delegator) {
    return null;
  }
  const context = makePriceContext();
  let directUsd = 0n;
  for (const position of delegator.assetPositions ?? []) {
    const amount = BigInt(position.totalDeposited ?? "0");
    directUsd += await convertAmountToUsd(context, amount, position.token ?? ZERO_ADDRESS, 0n, snapshot.timestamp);
  }
  let liquidUsd = 0n;
  for (const position of delegator.liquidVaultPositions ?? []) {
    const shares = BigInt(position.shares ?? "0");
    const pendingAssets = BigInt(position.pendingAssets ?? "0");
    const vault = position.vault;
    if (!vault) continue;
    const totalShares = BigInt(vault.totalShares ?? "0");
    const totalAssets = BigInt(vault.totalAssets ?? "0");
    if (shares > 0n && totalShares > 0n && totalAssets > 0n) {
      const proportionalAssets = (shares * totalAssets) / totalShares;
      liquidUsd += await convertAmountToUsd(context, proportionalAssets, vault.assetAddress, 0n, snapshot.timestamp);
    }
    if (pendingAssets > 0n) {
      liquidUsd += await convertAmountToUsd(context, pendingAssets, vault.assetAddress, 0n, snapshot.timestamp);
    }
  }
  return { usdBasis: directUsd + liquidUsd, liquidUsdBasis: liquidUsd };
};

const main = async () => {
  const { endpoint, program } = parseArgs();
  let skip = 0;
  const updates: Array<{ id: string; usdBasis: string; liquidUsdBasis?: string }> = [];
  while (true) {
    const snapshots = await fetchSnapshots(endpoint!, program!, skip);
    if (snapshots.length === 0) break;
    for (const snapshot of snapshots) {
      if (snapshot.usdBasis && snapshot.liquidUsdBasis) {
        continue;
      }
      if (snapshot.program.category !== "DELEGATOR") {
        continue;
      }
      const recalculated = await computeDelegatorUsdBasis(endpoint!, snapshot);
      if (!recalculated) continue;
      updates.push({
        id: snapshot.id,
        usdBasis: recalculated.usdBasis.toString(),
        liquidUsdBasis: recalculated.liquidUsdBasis.toString(),
      });
    }
    if (snapshots.length < SNAPSHOT_CHUNK) {
      break;
    }
    skip += SNAPSHOT_CHUNK;
  }
  if (updates.length === 0) {
    console.log("No snapshots required backfilling.");
    return;
  }
  console.log(JSON.stringify({ updates }, null, 2));
  console.error(`Computed ${updates.length} snapshot updates. Apply them via SQL/Graph mutations as needed.`);
};

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
