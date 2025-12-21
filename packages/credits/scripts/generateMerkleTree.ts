/**
 * Generate Merkle Tree for Credits Claims
 *
 * Input:  [{ "account": "0x...", "amount": "123..." }, ...]
 * Output: { root, totalValue, entryCount, epochId, entries: { [account]: { amount, proof } } }
 *
 * Leaf format: (uint256 epochId, address account, uint256 amount)
 * Leaf hash: keccak256(bytes.concat(keccak256(abi.encode(epochId, account, amount))))
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import { getAddress, isAddress } from "viem";

type Entitlement = { account: string; amount: string };

type OutputEntry = { amount: string; proof: string[] };

type Output = {
  epochId: string;
  root: string;
  totalValue: string;
  entryCount: number;
  entries: Record<string, OutputEntry>;
};

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

const main = () => {
  const args = parseArgs();
  const epochId = args["epoch-id"];
  const input = args["input"];
  const output = args["output"] ?? "credits-tree.json";
  if (!epochId) throw new Error("--epoch-id required");
  if (!input) throw new Error("--input required");

  const entitlements = JSON.parse(readFileSync(resolve(input), "utf-8")) as Entitlement[];
  if (!Array.isArray(entitlements)) throw new Error("input must be a JSON array");

  const normalized: Array<{ account: string; amount: string }> = [];
  for (const row of entitlements) {
    if (!row || typeof row !== "object") continue;
    const account = String((row as any).account ?? "");
    const amount = String((row as any).amount ?? "");
    if (!isAddress(account)) throw new Error(`Invalid account: ${account}`);
    if (!/^[0-9]+$/.test(amount)) throw new Error(`Invalid amount for ${account}: ${amount}`);
    normalized.push({ account: getAddress(account), amount });
  }

  const values = normalized.map((e) => [epochId, e.account, e.amount] as [string, string, string]);
  const tree = StandardMerkleTree.of(values, ["uint256", "address", "uint256"]);

  const entries: Output["entries"] = {};
  let total = 0n;
  for (const [i, v] of tree.entries()) {
    const account = v[1] as string;
    const amount = v[2] as string;
    const proof = tree.getProof(i);
    entries[account.toLowerCase()] = { amount, proof };
    total += BigInt(amount);
  }

  const out: Output = {
    epochId,
    root: tree.root,
    totalValue: total.toString(),
    entryCount: normalized.length,
    entries,
  };

  const outPath = resolve(output);
  writeFileSync(outPath, JSON.stringify(out, null, 2));
  // eslint-disable-next-line no-console
  console.log(`Wrote: ${outPath}`);
  // eslint-disable-next-line no-console
  console.log(`ROOT=${tree.root}`);
};

main();

