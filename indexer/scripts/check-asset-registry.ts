#!/usr/bin/env ts-node
import fs from "node:fs/promises";
import path from "node:path";

import { listRegisteredAssets } from "../src/points/assets";

type CliOptions = {
  endpoint?: string;
  file?: string;
  bearerToken?: string;
};

const usage = `
Usage: pnpm ts-node scripts/check-asset-registry.ts --endpoint <graphql-url>
       pnpm ts-node scripts/check-asset-registry.ts --from-file <json-file>

Options:
  --endpoint <url>      GraphQL endpoint exposing RestakingAsset entities
  --from-file <path>    Local JSON file containing an array of token addresses
  --bearer <token>      Optional bearer token for authenticated GraphQL endpoints
`.trim();

const parseArgs = (): CliOptions => {
  const options: CliOptions = {};
  const args = process.argv.slice(2);
  for (let i = 0; i < args.length; i += 1) {
    const arg = args[i];
    if (arg === "--endpoint" && args[i + 1]) {
      options.endpoint = args[++i];
    } else if (arg === "--from-file" && args[i + 1]) {
      options.file = args[++i];
    } else if (arg === "--bearer" && args[i + 1]) {
      options.bearerToken = args[++i];
    } else if (arg === "--help") {
      console.log(usage);
      process.exit(0);
    } else {
      throw new Error(`Unknown argument ${arg}`);
    }
  }
  return options;
};

const fetchGraphAssets = async (endpoint: string, bearerToken?: string): Promise<string[]> => {
  const headers: Record<string, string> = { "content-type": "application/json" };
  if (bearerToken) {
    headers.authorization = `Bearer ${bearerToken}`;
  }
  const query = `
    query RestakingAssets($skip: Int!) {
      restakingAssets(first: 1000, skip: $skip) { token }
    }
  `;
  const tokens: string[] = [];
  let skip = 0;
  while (true) {
    const response = await fetch(endpoint, {
      method: "POST",
      headers,
      body: JSON.stringify({ query, variables: { skip } }),
    });
    if (!response.ok) {
      throw new Error(`Failed to fetch assets: ${response.status} ${response.statusText}`);
    }
    const payload = (await response.json()) as { data?: { restakingAssets?: Array<{ token: string }> }; errors?: Array<{ message: string }> };
    if (payload.errors?.length) {
      throw new Error(`GraphQL error: ${payload.errors.map((err) => err.message).join(", ")}`);
    }
    const batch = payload.data?.restakingAssets ?? [];
    batch.forEach((asset) => tokens.push(asset.token.toLowerCase()));
    if (batch.length < 1000) {
      break;
    }
    skip += 1000;
  }
  return tokens;
};

const readTokensFromFile = async (filePath: string): Promise<string[]> => {
  const absolute = path.isAbsolute(filePath) ? filePath : path.join(process.cwd(), filePath);
  const data = await fs.readFile(absolute, "utf8");
  const parsed = JSON.parse(data) as unknown;
  if (Array.isArray(parsed)) {
    return parsed.map((value) => value.token ?? value).map((value) => String(value).toLowerCase());
  }
  throw new Error("File must contain a JSON array of tokens or objects with a token field.");
};

const main = async () => {
  const options = parseArgs();
  let onChainTokens: string[] = [];
  if (options.file) {
    onChainTokens = await readTokensFromFile(options.file);
  } else if (options.endpoint) {
    onChainTokens = await fetchGraphAssets(options.endpoint, options.bearerToken);
  } else {
    console.error(usage);
    process.exit(1);
  }
  if (onChainTokens.length === 0) {
    console.log("No RestakingAsset entries returned from source.");
    return;
  }
  const registry = new Set(listRegisteredAssets().map((asset) => asset.address.toLowerCase()));
  const missing = onChainTokens.filter((token) => !registry.has(token));
  if (missing.length > 0) {
    console.error(`ERROR: Missing ${missing.length} asset(s) from registry:`);
    missing.forEach((token) => console.error(`  - ${token}`));
    process.exit(1);
  }
  console.log(`All ${onChainTokens.length} on-chain RestakingAsset tokens are registered.`);
};

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
