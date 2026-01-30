/**
 * Sync `indexer/config.yaml` contract addresses from a `FullDeploy` manifest JSON.
 *
 * This keeps the indexer aligned when the protocol is redeployed (including facet/diamond refactors where
 * the proxy address changes).
 *
 * Usage (from repo root):
 * - `node indexer/scripts/sync-config-from-manifest.ts --manifest deployments/base-sepolia/latest.json --config indexer/config.yaml`
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

type Manifest = {
  chainId?: number;
  tangle?: string;
  restaking?: string;
  statusRegistry?: string;
  rewardVaults?: string;
  inflationPool?: string;
  credits?: string;
};

const parseArgs = () => {
  const args = process.argv.slice(2);
  const out: Record<string, string> = {};
  for (let i = 0; i < args.length; i++) {
    const key = args[i];
    if (key === "--") continue;
    if (!key.startsWith("--")) continue;
    const value = args[i + 1];
    if (!value || value.startsWith("--")) continue;
    out[key.slice(2)] = value;
    i++;
  }
  return out;
};

const isAddress = (value: unknown): value is string => typeof value === "string" && /^0x[0-9a-fA-F]{40}$/.test(value);

const updateContractAddress = (yaml: string, contractName: string, address: string | null) => {
  const lines = yaml.split(/\r?\n/);
  const target = address ? address.toLowerCase() : null;

  const findBlockStart = () => {
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].trim() === `- name: ${contractName}`) return i;
    }
    return -1;
  };

  const start = findBlockStart();
  if (start === -1) {
    throw new Error(`Could not find \`- name: ${contractName}\` block in config.yaml`);
  }

  // Walk forward until we hit the address line inside this contract entry.
  let addrLine = -1;
  for (let i = start + 1; i < lines.length; i++) {
    const trimmed = lines[i].trim();
    if (trimmed.startsWith("- name: ")) break;
    if (trimmed.startsWith("unordered_multichain_mode:")) break;
    if (/^address\s*:/.test(trimmed)) {
      addrLine = i;
      break;
    }
  }
  if (addrLine === -1) {
    throw new Error(`Could not find \`address:\` line under ${contractName} contract entry`);
  }

  const indent = lines[addrLine].match(/^\s*/)?.[0] ?? "";
  // Remove existing address line + any following list items.
  let end = addrLine + 1;
  while (end < lines.length && lines[end].match(/^\s*-\s*\"0x[0-9a-fA-F]{40}\"/)) {
    end++;
  }

  const replacement = target
    ? [`${indent}address:`, `${indent}  - "${target}"`]
    : [`${indent}address: []`];

  lines.splice(addrLine, end - addrLine, ...replacement);
  return lines.join("\n");
};

function main() {
  const args = parseArgs();
  const manifestPath = args["manifest"];
  const configPath = args["config"] ?? "indexer/config.yaml";
  if (!manifestPath) throw new Error("--manifest required");

  const manifest = JSON.parse(readFileSync(resolve(manifestPath), "utf-8")) as Manifest;
  const updates: Array<{ name: string; address: string | null }> = [
    { name: "Tangle", address: isAddress(manifest.tangle) ? manifest.tangle : null },
    { name: "MultiAssetDelegation", address: isAddress(manifest.restaking) ? manifest.restaking : null },
    { name: "OperatorStatusRegistry", address: isAddress(manifest.statusRegistry) ? manifest.statusRegistry : null },
    { name: "RewardVaults", address: isAddress(manifest.rewardVaults) ? manifest.rewardVaults : null },
    { name: "InflationPool", address: isAddress(manifest.inflationPool) ? manifest.inflationPool : null },
    { name: "Credits", address: isAddress(manifest.credits) ? manifest.credits : null },
  ];

  const yamlPath = resolve(configPath);
  const yaml = readFileSync(yamlPath, "utf-8");
  let updated = yaml;
  for (const { name, address } of updates) {
    // Skip contracts that are not present in the manifest (keeps local overrides intact).
    if (!address) continue;
    updated = updateContractAddress(updated, name, address);
  }
  writeFileSync(yamlPath, updated);
  // eslint-disable-next-line no-console
  console.log(`Updated indexer config from manifest: ${yamlPath}`);
}

main();
