/**
 * Compute time-windowed TNT-delegation credit entitlements from the indexer (Hasura GraphQL).
 *
 * Credits are computed from delegated stake×time over a window:
 *   credits = (stakeWeiSeconds / (epochSeconds * 1e18)) * creditsPerTntPerEpoch
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
 * - --start-ts <unix seconds>        (optional; inferred from --end-ts and --epoch-seconds)
 * - --end-ts <unix seconds>          (optional; inferred from --start-ts and --epoch-seconds)
 * - --epoch-seconds <int>            (default: 604800)
 * - --credits-per-tnt <int>          (default: 1) credits per 1 TNT staked for the full epoch
 * - --min-credits <int>             (default: 1) filter dust
 * - --output <path>                 (default: entitlements.json)
 * - --page-size <int>               (default: 500)
 * - --state <path>                  (default: .credits-state.json)
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { isAddress } from "viem";
import { parseArgs } from "./_shared.ts";
import { computeTimeWindowedEntitlements } from "./timeWindowedEntitlements.ts";

type Entitlement = { account: string; amount: string };

type Manifest = { tntToken?: string };

const loadManifest = (path: string): Manifest => {
  const raw = readFileSync(path, "utf-8");
  return JSON.parse(raw) as Manifest;
};

async function main() {
  const args = parseArgs();
  const graphqlUrl = process.env.GRAPHQL_URL || "http://localhost:8080/v1/graphql";
  let tntToken = args["tnt-token"] as string | undefined;
  const manifestPath = args["manifest"];
  if (manifestPath) {
    const manifest = loadManifest(manifestPath);
    if (!tntToken && manifest.tntToken) tntToken = manifest.tntToken;
  }
  if (!tntToken) throw new Error("--tnt-token required (or --manifest)");
  if (!isAddress(tntToken)) throw new Error(`Invalid --tnt-token: ${tntToken}`);

  const creditsPerTnt = BigInt((args["credits-per-tnt"] as string | undefined) ?? "1");
  const minCredits = BigInt((args["min-credits"] as string | undefined) ?? "1");
  const epochSeconds = BigInt((args["epoch-seconds"] as string | undefined) ?? "604800");
  const startTsArg = args["start-ts"] as string | undefined;
  const endTsArg = args["end-ts"] as string | undefined;
  if (!startTsArg && !endTsArg) {
    throw new Error("--start-ts or --end-ts required (use --epoch-seconds to infer the other boundary)");
  }
  const startTs = BigInt(startTsArg ?? (BigInt(endTsArg!) - epochSeconds).toString());
  const endTs = BigInt(endTsArg ?? (startTs + epochSeconds).toString());
  const output = resolve(((args["output"] as string | undefined) ?? "entitlements.json") as string);
  const pageSize = Number((args["page-size"] as string | undefined) ?? "500");
  const statePath = ((args["state"] as string | undefined) ?? ".credits-state.json") as string;
  if (!Number.isFinite(pageSize) || pageSize <= 0) throw new Error("--page-size must be > 0");

  const { entitlements } = await computeTimeWindowedEntitlements({
    graphqlUrl,
    token: tntToken,
    window: { startTs, endTs, epochSeconds },
    creditsPerTntPerEpoch: creditsPerTnt,
    minCredits,
    pageSize,
    statePath,
  });

  writeFileSync(output, JSON.stringify(entitlements satisfies Entitlement[], null, 2));
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
