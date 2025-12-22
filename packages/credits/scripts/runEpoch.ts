/**
 * End-to-end epoch runner:
 *  1) Computes time-windowed entitlements from the indexer (delegated TNT only)
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
 * - --start-ts <unix seconds>        (optional; inferred from --end-ts and --epoch-seconds)
 * - --end-ts <unix seconds>          (optional; inferred from --start-ts and --epoch-seconds)
 * - --epoch-seconds <int>            (default: 604800)
 * - --credits-per-tnt <int>          (default: 1) credits per 1 TNT staked for the full epoch
 * - --min-credits <int>              (default: 1)
 * - --out <path>                     (default: ../credits-tree.json)
 * - --page-size <int>                (default: 500)
 * - --state <path>                   (default: .credits-state.json)
 * - --publish                        (optional)
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { createPublicClient, createWalletClient, http, isAddress, parseAbi } from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { getAddress } from "viem";
import { parseArgs } from "./_shared.ts";
import { computeTimeWindowedEntitlements } from "./timeWindowedEntitlements.ts";

type Entitlement = { account: string; amount: string };

type Manifest = { tntToken?: string; credits?: string };

const loadManifest = (path: string): Manifest => {
  const raw = readFileSync(path, "utf-8");
  return JSON.parse(raw) as Manifest;
};

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
  const epochSeconds = BigInt((args["epoch-seconds"] as string | undefined) ?? "604800");
  const startTsArg = args["start-ts"] as string | undefined;
  const endTsArg = args["end-ts"] as string | undefined;
  if (!startTsArg && !endTsArg) {
    throw new Error("--start-ts or --end-ts required (use --epoch-seconds to infer the other boundary)");
  }
  const startTs = BigInt(startTsArg ?? (BigInt(endTsArg!) - epochSeconds).toString());
  const endTs = BigInt(endTsArg ?? (startTs + epochSeconds).toString());
  if (endTs <= startTs) throw new Error("endTs must be > startTs");
  const outPath = resolve((args["out"] as string | undefined) ?? "../credits-tree.json");
  const pageSize = Number((args["page-size"] as string | undefined) ?? "500");
  const statePath = (args["state"] as string | undefined) ?? ".credits-state.json";
  const publish = Boolean(args["publish"]);

  const { entitlements, tokenLower } = await computeTimeWindowedEntitlements({
    graphqlUrl,
    token: tntToken,
    window: { startTs, endTs, epochSeconds },
    creditsPerTntPerEpoch: creditsPerTnt,
    minCredits,
    pageSize,
    statePath,
  });

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
    startTs: startTs.toString(),
    endTs: endTs.toString(),
    epochSeconds: epochSeconds.toString(),
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
