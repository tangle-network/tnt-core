/**
 * Compute TNT-delegation credit entitlements from the indexer (Hasura GraphQL).
 *
 * This is a *snapshot-based* computation: it uses the current DelegationPosition state
 * (sum of lastKnownAmount across all operators) for the provided TNT token address.
 *
 * Output format matches `generateMerkleTree.ts` input:
 *   [{ "account": "0x...", "amount": "123..." }, ...]
 *
 * Env (optional):
 * - GRAPHQL_URL (defaults to http://localhost:8080/v1/graphql)
 * - HASURA_GRAPHQL_ADMIN_SECRET (if required)
 * - HASURA_GRAPHQL_ROLE (if required)
 *
 * Args:
 * - --tnt-token <0x...>              (required)
 * - --credits-per-tnt <int>          (default: 1) credits per 1 TNT (1e18 wei)
 * - --min-credits <int>             (default: 1) filter dust
 * - --output <path>                 (default: entitlements.json)
 * - --page-size <int>               (default: 500)
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { getAddress, isAddress } from "viem";

type Entitlement = { account: string; amount: string };

const parseArgs = () => {
  const args = process.argv.slice(2);
  const out: Record<string, string> = {};
  for (let i = 0; i < args.length; i++) {
    const key = args[i];
    if (!key.startsWith("--")) continue;
    const value = args[i + 1];
    if (!value || value.startsWith("--")) continue;
    out[key.slice(2)] = value;
    i++;
  }
  return out;
};

type Manifest = { tntToken?: string };

const loadManifest = (path: string): Manifest => {
  const raw = readFileSync(path, "utf-8");
  return JSON.parse(raw) as Manifest;
};

async function graphql<T>(url: string, query: string, variables: Record<string, unknown>) {
  const headers: Record<string, string> = { "content-type": "application/json" };
  const secret = process.env.HASURA_GRAPHQL_ADMIN_SECRET || process.env.HASURA_ADMIN_SECRET;
  const role = process.env.HASURA_GRAPHQL_ROLE;
  if (secret) headers["x-hasura-admin-secret"] = secret;
  if (role) headers["x-hasura-role"] = role;

  const res = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify({ query, variables }),
  });
  const json = (await res.json()) as any;
  if (!res.ok || json.errors) {
    const details = JSON.stringify(json.errors ?? json, null, 2);
    throw new Error(`GraphQL error (${res.status}): ${details}`);
  }
  return json.data as T;
}

async function detectTableName(url: string) {
  const data = await graphql<{ __schema: { queryType: { fields: Array<{ name: string }> } } }>(
    url,
    "query Introspect { __schema { queryType { fields { name } } } }",
    {}
  );
  const fields = data.__schema.queryType.fields.map((f) => f.name);
  const exact = fields.find((name) => name === "DelegationPosition");
  if (exact) return exact;
  const ci = fields.find((name) => name.toLowerCase() === "delegationposition");
  if (ci) return ci;
  const candidate = fields.find((name) => name.toLowerCase().includes("delegationposition") && !name.endsWith("_aggregate") && !name.endsWith("_by_pk"));
  if (candidate) return candidate;
  throw new Error(`Could not find DelegationPosition query field in GraphQL schema. Found fields: ${fields.slice(0, 50).join(", ")}...`);
}

async function fetchAllDelegationPositions(url: string, table: string, tokenLower: string, pageSize: number) {
  const query = `
    query FetchPositions($limit: Int!, $offset: Int!, $token: String!) {
      ${table}(limit: $limit, offset: $offset, where: { token: { _eq: $token } }) {
        delegator_id
        lastKnownAmount
        shares
      }
    }
  `;

  let offset = 0;
  const rows: Array<{ delegator_id: string; lastKnownAmount: string; shares: string }> = [];
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const data = await graphql<Record<string, Array<{ delegator_id: string; lastKnownAmount: string; shares: string }>>>(
      url,
      query,
      { limit: pageSize, offset, token: tokenLower }
    );
    const page = data[table] ?? [];
    rows.push(...page);
    if (page.length < pageSize) break;
    offset += pageSize;
  }
  return rows;
}

function computeCreditsFromDelegatedWei(delegatedWei: bigint, creditsPerTnt: bigint) {
  const WEI_PER_TNT = 10n ** 18n;
  return (delegatedWei * creditsPerTnt) / WEI_PER_TNT;
}

async function main() {
  const args = parseArgs();
  const graphqlUrl = process.env.GRAPHQL_URL || "http://localhost:8080/v1/graphql";
  let tntToken = args["tnt-token"];
  const manifestPath = args["manifest"];
  if (manifestPath) {
    const manifest = loadManifest(manifestPath);
    if (!tntToken && manifest.tntToken) tntToken = manifest.tntToken;
  }
  if (!tntToken) throw new Error("--tnt-token required (or --manifest)");
  if (!isAddress(tntToken)) throw new Error(`Invalid --tnt-token: ${tntToken}`);

  const creditsPerTnt = BigInt(args["credits-per-tnt"] ?? "1");
  const minCredits = BigInt(args["min-credits"] ?? "1");
  const output = resolve(args["output"] ?? "entitlements.json");
  const pageSize = Number(args["page-size"] ?? "500");
  if (!Number.isFinite(pageSize) || pageSize <= 0) throw new Error("--page-size must be > 0");

  const table = await detectTableName(graphqlUrl);
  const tokenLower = getAddress(tntToken).toLowerCase();
  const rows = await fetchAllDelegationPositions(graphqlUrl, table, tokenLower, pageSize);

  const totals = new Map<string, bigint>();
  for (const row of rows) {
    const shares = BigInt(row.shares ?? "0");
    if (shares <= 0n) continue;
    const delegator = String(row.delegator_id ?? "").toLowerCase();
    const amount = BigInt(row.lastKnownAmount ?? "0");
    if (amount <= 0n) continue;
    totals.set(delegator, (totals.get(delegator) ?? 0n) + amount);
  }

  const entitlements: Entitlement[] = [];
  for (const [accountLower, delegatedWei] of totals.entries()) {
    const credits = computeCreditsFromDelegatedWei(delegatedWei, creditsPerTnt);
    if (credits < minCredits) continue;
    entitlements.push({ account: getAddress(accountLower), amount: credits.toString() });
  }

  entitlements.sort((a, b) => a.account.toLowerCase().localeCompare(b.account.toLowerCase()));
  writeFileSync(output, JSON.stringify(entitlements, null, 2));
  // eslint-disable-next-line no-console
  console.log(`Wrote: ${output}`);
  // eslint-disable-next-line no-console
  console.log(`Accounts: ${entitlements.length}`);
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
