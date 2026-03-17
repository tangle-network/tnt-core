import { existsSync } from "fs";
import { mkdir, writeFile } from "fs/promises";
import { join } from "path";
import { homedir } from "os";
import type { CircuitArtifacts } from "./prover.js";

const DEFAULT_BASE_URL =
  "https://protocol-solidity-fixtures.s3.amazonaws.com/solidity-fixtures";

const DEFAULT_CACHE_DIR = join(homedir(), ".tangle", "circuits");

/// Resolve the base URL for circuit artifacts.
/// Override with TANGLE_CIRCUIT_BASE_URL env var or pass explicitly.
function getBaseUrl(override?: string): string {
  return override ?? process.env.TANGLE_CIRCUIT_BASE_URL ?? DEFAULT_BASE_URL;
}

/// Build the URL for a circuit artifact.
function artifactUrl(
  inputs: 2 | 16,
  maxEdges: 2 | 8,
  kind: "wasm" | "zkey",
  baseUrl?: string
): string {
  const base = getBaseUrl(baseUrl);
  const size = maxEdges;
  if (kind === "wasm") {
    return `${base}/vanchor_${inputs}/${size}/poseidon_vanchor_${inputs}_${size}.wasm`;
  }
  return `${base}/vanchor_${inputs}/${size}/circuit_final.zkey`;
}

/// Download a file if it doesn't already exist at destPath.
export async function downloadIfMissing(
  url: string,
  destPath: string
): Promise<void> {
  if (existsSync(destPath)) return;

  const dir = destPath.substring(0, destPath.lastIndexOf("/"));
  await mkdir(dir, { recursive: true });

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download ${url}: ${response.status} ${response.statusText}`);
  }
  const buffer = new Uint8Array(await response.arrayBuffer());
  await writeFile(destPath, buffer);
}

/// Download and cache circuit artifacts, returning paths to the local files.
export async function getCircuitArtifacts(
  inputs: 2 | 16,
  maxEdges: 2 | 8,
  cacheDir: string = DEFAULT_CACHE_DIR,
  baseUrl?: string
): Promise<CircuitArtifacts> {
  const subdir = join(cacheDir, `vanchor_${inputs}`, `${maxEdges}`);
  const wasmPath = join(subdir, `poseidon_vanchor_${inputs}_${maxEdges}.wasm`);
  const zkeyPath = join(subdir, "circuit_final.zkey");

  await Promise.all([
    downloadIfMissing(artifactUrl(inputs, maxEdges, "wasm", baseUrl), wasmPath),
    downloadIfMissing(artifactUrl(inputs, maxEdges, "zkey", baseUrl), zkeyPath),
  ]);

  return { wasmPath, zkeyPath };
}
