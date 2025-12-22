import { existsSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { getAddress } from "viem";
import { detectQueryField, graphql, loadJson } from "./_shared.ts";

export type CreditsStateV1 = {
  version: 1;
  token: string; // lowercased ERC20 address
  endTs: string; // unix seconds, bigint as string
  balances: Record<string, string>; // lowercased address -> bigint as string (wei)
};

export type Window = { startTs: bigint; endTs: bigint; epochSeconds: bigint };

type DeltaRow = {
  id: string;
  delegator: string;
  token: string;
  delta: string;
  timestamp: string;
};

const WEI_PER_TNT = 10n ** 18n;

export function creditsFromStakeWeiSeconds(stakeWeiSeconds: bigint, creditsPerTntPerEpoch: bigint, epochSeconds: bigint) {
  if (epochSeconds <= 0n) throw new Error("epochSeconds must be > 0");
  // credits = (weiSeconds / (epochSeconds * 1e18)) * creditsPerTntPerEpoch
  return (stakeWeiSeconds * creditsPerTntPerEpoch) / (epochSeconds * WEI_PER_TNT);
}

export function loadState(path: string): CreditsStateV1 | undefined {
  if (!existsSync(path)) return undefined;
  const raw = loadJson<CreditsStateV1>(path);
  if (raw.version !== 1) throw new Error(`Unsupported credits state version: ${(raw as any).version}`);
  return raw;
}

export function writeState(path: string, tokenLower: string, endTs: bigint, balances: Map<string, bigint>) {
  const out: CreditsStateV1 = {
    version: 1,
    token: tokenLower,
    endTs: endTs.toString(),
    balances: {},
  };
  for (const [acct, bal] of balances.entries()) {
    if (bal <= 0n) continue;
    out.balances[acct.toLowerCase()] = bal.toString();
  }
  writeFileSync(resolve(path), JSON.stringify(out, null, 2));
}

async function* fetchDeltas(url: string, table: string, tokenLower: string, where: string, variables: Record<string, unknown>, pageSize: number) {
  const query = `
    query FetchDeltas($limit: Int!, $offset: Int!, $token: String!, ${Object.keys(variables)
      .filter((k) => k !== "token")
      .map((k) => `$${k}: BigInt!`)
      .join(", ")}) {
      ${table}(
        limit: $limit,
        offset: $offset,
        where: { token: { _eq: $token }, ${where} },
        order_by: [{ timestamp: asc }, { id: asc }]
      ) {
        id
        delegator
        token
        delta
        timestamp
      }
    }
  `;

  let offset = 0;
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const data = await graphql<Record<string, DeltaRow[]>>(url, query, { limit: pageSize, offset, token: tokenLower, ...variables });
    const page = data[table] ?? [];
    for (const row of page) yield row;
    if (page.length < pageSize) break;
    offset += pageSize;
  }
}

export async function computeTimeWindowedEntitlements(opts: {
  graphqlUrl: string;
  token: string;
  window: Window;
  creditsPerTntPerEpoch: bigint;
  minCredits: bigint;
  pageSize: number;
  statePath?: string;
}) {
  const tokenLower = getAddress(opts.token).toLowerCase();
  const statePath = opts.statePath ? resolve(opts.statePath) : undefined;
  const state = statePath ? loadState(statePath) : undefined;
  const { startTs, endTs, epochSeconds } = opts.window;

  const table = await detectQueryField(opts.graphqlUrl, "DelegationBalanceDelta");

  const balances = new Map<string, bigint>();
  if (state && state.token === tokenLower && BigInt(state.endTs) === startTs) {
    for (const [acct, balStr] of Object.entries(state.balances)) balances.set(acct.toLowerCase(), BigInt(balStr));
  } else {
    // One-time initialization: replay all deltas up to startTs to build starting balances.
    for await (const row of fetchDeltas(opts.graphqlUrl, table, tokenLower, "timestamp: { _lt: $before }", { before: startTs.toString() }, opts.pageSize)) {
      const acct = row.delegator.toLowerCase();
      const next = (balances.get(acct) ?? 0n) + BigInt(row.delta);
      balances.set(acct, next < 0n ? 0n : next);
    }
    // Drop zero balances to keep state small.
    for (const [acct, bal] of balances.entries()) if (bal <= 0n) balances.delete(acct);
  }

  const stakeWeiSeconds = new Map<string, bigint>();
  const lastTs = new Map<string, bigint>();
  const active = new Set<string>();
  for (const [acct, bal] of balances.entries()) {
    if (bal > 0n) {
      active.add(acct);
      lastTs.set(acct, startTs);
      stakeWeiSeconds.set(acct, 0n);
    }
  }

  for await (const row of fetchDeltas(
    opts.graphqlUrl,
    table,
    tokenLower,
    "timestamp: { _gte: $start, _lt: $end }",
    { start: startTs.toString(), end: endTs.toString() },
    opts.pageSize
  )) {
    const acct = row.delegator.toLowerCase();
    if (!active.has(acct)) {
      active.add(acct);
      balances.set(acct, balances.get(acct) ?? 0n);
      lastTs.set(acct, startTs);
      stakeWeiSeconds.set(acct, 0n);
    }
    const prevTs = lastTs.get(acct) ?? startTs;
    const ts = BigInt(row.timestamp);
    const bal = balances.get(acct) ?? 0n;
    if (ts > prevTs && bal > 0n) {
      stakeWeiSeconds.set(acct, (stakeWeiSeconds.get(acct) ?? 0n) + bal * (ts - prevTs));
    }
    lastTs.set(acct, ts);
    const nextBal = bal + BigInt(row.delta);
    balances.set(acct, nextBal < 0n ? 0n : nextBal);
  }

  for (const acct of active.values()) {
    const prevTs = lastTs.get(acct) ?? startTs;
    const bal = balances.get(acct) ?? 0n;
    if (endTs > prevTs && bal > 0n) {
      stakeWeiSeconds.set(acct, (stakeWeiSeconds.get(acct) ?? 0n) + bal * (endTs - prevTs));
    }
  }

  const entitlements: Array<{ account: string; amount: string }> = [];
  for (const acct of active.values()) {
    const weiSeconds = stakeWeiSeconds.get(acct) ?? 0n;
    if (weiSeconds <= 0n) continue;
    const credits = creditsFromStakeWeiSeconds(weiSeconds, opts.creditsPerTntPerEpoch, epochSeconds);
    if (credits < opts.minCredits) continue;
    entitlements.push({ account: getAddress(acct), amount: credits.toString() });
  }
  entitlements.sort((a, b) => a.account.toLowerCase().localeCompare(b.account.toLowerCase()));

  if (statePath) writeState(statePath, tokenLower, endTs, balances);

  return { entitlements, tokenLower, balancesEnd: balances };
}
