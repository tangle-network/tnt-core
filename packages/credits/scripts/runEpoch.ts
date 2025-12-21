/**
 * End-to-end epoch runner:
 *  1) Computes snapshot entitlements from the indexer (delegated TNT only)
 *  2) Generates a Merkle tree + proofs
 *  3) Optionally publishes the root on-chain (Credits.setMerkleRoot)
 *
 * Env:
 * - GRAPHQL_URL (defaults to http://localhost:8080/v1/graphql)
 * - HASURA_GRAPHQL_ADMIN_SECRET (if required)
 * - HASURA_GRAPHQL_ROLE (if required)
 *
 * Publish env (when --publish is set):
 * - RPC_URL
 * - PRIVATE_KEY
 * - CREDITS_ADDRESS
 *
 * Args:
 * - --epoch-id <uint>                (required)
 * - --tnt-token <0x...>              (required)
 * - --credits-per-tnt <int>          (default: 1) credits per 1 TNT (1e18 wei)
 * - --min-credits <int>              (default: 1)
 * - --out <path>                     (default: credits-tree.json)
 * - --page-size <int>                (default: 500)
 * - --publish                        (optional)
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { createPublicClient, createWalletClient, http, isAddress, parseAbi } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { getAddress } from "viem";

type Entitlement = { account: string; amount: string };

const parseArgs = () => {
  const args = process.argv.slice(2);
  const out: Record<string, string | boolean> = {};
  for (let i = 0; i < args.length; i++) {
    const key = args[i];
    if (!key.startsWith("--")) continue;
    const name = key.slice(2);
    const next = args[i + 1];
    if (!next || next.startsWith("--")) {
      out[name] = true;
      continue;
    }
    out[name] = next;
    i++;
  }
  return out;
};

type Manifest = { tntToken?: string; credits?: string };

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
  throw new Error(`Could not find DelegationPosition query field in GraphQL schema.`);
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
  const epochId = args["epoch-id"];
  let tntToken = args["tnt-token"];
  if (!epochId || typeof epochId !== "string") throw new Error("--epoch-id required");
  const manifestPath = args["manifest"];
  if (manifestPath && typeof manifestPath === "string") {
    const manifest = loadManifest(manifestPath);
    if (!tntToken && manifest.tntToken) tntToken = manifest.tntToken;
    if (args["publish"] && !process.env.CREDITS_ADDRESS && manifest.credits) {
      process.env.CREDITS_ADDRESS = manifest.credits;
    }
  }
  if (!tntToken || typeof tntToken !== "string") throw new Error("--tnt-token required (or --manifest)");
  if (!isAddress(tntToken)) throw new Error(`Invalid --tnt-token: ${tntToken}`);

  const graphqlUrl = process.env.GRAPHQL_URL || "http://localhost:8080/v1/graphql";
  const creditsPerTnt = BigInt((args["credits-per-tnt"] as string | undefined) ?? "1");
  const minCredits = BigInt((args["min-credits"] as string | undefined) ?? "1");
  const outPath = resolve((args["out"] as string | undefined) ?? "credits-tree.json");
  const pageSize = Number((args["page-size"] as string | undefined) ?? "500");
  const publish = Boolean(args["publish"]);

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

  const values = entitlements.map((e) => [epochId, e.account, e.amount] as [string, string, string]);
  const tree = StandardMerkleTree.of(values, ["uint256", "address", "uint256"]);

  const entries: Record<string, { amount: string; proof: string[] }> = {};
  let totalValue = 0n;
  for (const [i, v] of tree.entries()) {
    const account = (v[1] as string).toLowerCase();
    const amount = v[2] as string;
    entries[account] = { amount, proof: tree.getProof(i) };
    totalValue += BigInt(amount);
  }

  const out = {
    epochId,
    root: tree.root,
    totalValue: totalValue.toString(),
    entryCount: entitlements.length,
    tntToken: tokenLower,
    creditsPerTnt: creditsPerTnt.toString(),
    entries,
  };
  writeFileSync(outPath, JSON.stringify(out, null, 2));
  // eslint-disable-next-line no-console
  console.log(`Wrote: ${outPath}`);
  // eslint-disable-next-line no-console
  console.log(`ROOT=${tree.root}`);

  if (!publish) return;

  const rpcUrl = process.env.RPC_URL;
  const pk = process.env.PRIVATE_KEY;
  const creditsAddress = process.env.CREDITS_ADDRESS as `0x${string}` | undefined;
  if (!rpcUrl) throw new Error("RPC_URL required for --publish");
  if (!pk) throw new Error("PRIVATE_KEY required for --publish");
  if (!creditsAddress) throw new Error("CREDITS_ADDRESS required for --publish");

  const abi = parseAbi(["function setMerkleRoot(uint256 epochId, bytes32 root) external"]);
  const account = privateKeyToAccount(pk as `0x${string}`);
  const publicClient = createPublicClient({ transport: http(rpcUrl) });
  const walletClient = createWalletClient({ account, transport: http(rpcUrl) });
  const hash = await walletClient.writeContract({
    address: creditsAddress,
    abi,
    functionName: "setMerkleRoot",
    args: [BigInt(epochId), tree.root as `0x${string}`],
  });
  // eslint-disable-next-line no-console
  console.log(`tx=${hash}`);
  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  // eslint-disable-next-line no-console
  console.log(`status=${receipt.status}`);
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});
