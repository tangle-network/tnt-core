/**
 * Sync `indexer/config.yaml` contract addresses from a `FullDeploy` manifest JSON.
 *
 * Today this only updates the `Credits` contract entry (so the indexer can ingest CreditsClaimed events),
 * but it can be extended to sync additional contracts as needed.
 *
 * Usage (from repo root):
 * - `node indexer/scripts/sync-config-from-manifest.ts --manifest deployments/base-sepolia/latest.json --config indexer/config.yaml`
 */
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

type Manifest = {
  chainId?: number;
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

const updateCreditsAddress = (yaml: string, address: string) => {
  const lines = yaml.split(/\r?\n/);
  const target = address.toLowerCase();

  const findCreditsBlockStart = () => {
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].trim() === "- name: Credits") return i;
    }
    return -1;
  };

  const start = findCreditsBlockStart();
  if (start === -1) {
    throw new Error("Could not find `- name: Credits` block in config.yaml");
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
    throw new Error("Could not find `address:` line under Credits contract entry");
  }

  const indent = lines[addrLine].match(/^\s*/)?.[0] ?? "";
  // Remove existing address line + any following list items.
  let end = addrLine + 1;
  while (end < lines.length && lines[end].match(/^\s*-\s*\"0x[0-9a-fA-F]{40}\"/)) {
    end++;
  }

  const replacement = [
    `${indent}address:`,
    `${indent}  - "${target}"`,
  ];

  lines.splice(addrLine, end - addrLine, ...replacement);
  return lines.join("\n");
};

function main() {
  const args = parseArgs();
  const manifestPath = args["manifest"];
  const configPath = args["config"] ?? "indexer/config.yaml";
  if (!manifestPath) throw new Error("--manifest required");

  const manifest = JSON.parse(readFileSync(resolve(manifestPath), "utf-8")) as Manifest;
  const credits = manifest.credits;
  if (!credits || !/^0x[0-9a-fA-F]{40}$/.test(credits)) {
    throw new Error(`Manifest missing valid "credits" address: ${credits ?? "undefined"}`);
  }

  const yamlPath = resolve(configPath);
  const yaml = readFileSync(yamlPath, "utf-8");
  const updated = updateCreditsAddress(yaml, credits);
  writeFileSync(yamlPath, updated);
  // eslint-disable-next-line no-console
  console.log(`Updated Credits address in ${yamlPath} -> ${credits}`);
}

main();
