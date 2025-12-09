import type { AssetMetadata } from "./assets";
import { getAssetMetadata, listRegisteredAssets } from "./assets";

type AssetPriceEntity = {
  id: string;
  asset: string;
  symbol: string;
  price: bigint;
  source: string;
  blockNumber: bigint;
  updatedAt: bigint;
};

type AssetPriceSampleEntity = {
  id: string;
  asset: string;
  symbol: string;
  price?: bigint;
  source: string;
  status: PriceSampleStatus;
  reason?: string;
  blockNumber: bigint;
  fetchedAt: bigint;
};

type PriceCacheEntry = {
  price: number;
  fetchedAt: number;
};

type PriceComputation = {
  price?: number;
  source: PriceSource;
  status: PriceSampleStatus;
  reason?: string;
};

const DEFAULT_CACHE_MS = 5 * 60 * 1000;
const DEFAULT_BATCH_SIZE = 30;
const MAX_RETRIES = 3;
const BASE_BACKOFF_MS = 250;

export const PRICE_SCALE = 10n ** 8n;

export type PriceSource = "COINGECKO" | "STATIC" | "DERIVED" | "FALLBACK";
export type PriceSampleStatus = "SUCCESS" | "FAILURE" | "FALLBACK";

export class PriceOracle {
  private cache = new Map<string, PriceCacheEntry>();

  constructor(private readonly cacheTtlMs: number = DEFAULT_CACHE_MS) {}

  clear() {
    this.cache.clear();
  }

  async getPriceById(priceId: string): Promise<number | null> {
    if (!priceId) return null;
    const cached = this.cache.get(priceId);
    if (cached && Date.now() - cached.fetchedAt < this.cacheTtlMs) {
      return cached.price;
    }
    const fetched = await this.fetchBatch([priceId]);
    return typeof fetched[priceId] === "number" ? fetched[priceId] : null;
  }

  async fetchBatch(priceIds: string[]): Promise<Record<string, number>> {
    const filtered = [...new Set(priceIds.filter((id): id is string => Boolean(id)))];
    if (filtered.length === 0) {
      return {};
    }
    const result: Record<string, number> = {};
    for (let i = 0; i < filtered.length; i += DEFAULT_BATCH_SIZE) {
      const slice = filtered.slice(i, i + DEFAULT_BATCH_SIZE);
      const fetched = await this.fetchFromApi(slice);
      for (const id of Object.keys(fetched)) {
        const price = fetched[id];
        if (typeof price === "number") {
          result[id] = price;
          this.cache.set(id, { price, fetchedAt: Date.now() });
        }
      }
    }
    return result;
  }

  private async fetchFromApi(ids: string[]): Promise<Record<string, number>> {
    if (ids.length === 0) {
      return {};
    }
    const joined = ids.join(",");
    const url = `https://api.coingecko.com/api/v3/simple/price?ids=${joined}&vs_currencies=usd`;
    for (let attempt = 0; attempt < MAX_RETRIES; attempt += 1) {
      try {
        const response = await fetch(url, { headers: { accept: "application/json" } });
        if (!response.ok) {
          throw new Error(`coingecko ${response.status}`);
        }
        const data = (await response.json()) as Record<string, { usd?: number }>;
        const output: Record<string, number> = {};
        for (const id of ids) {
          const value = data[id]?.usd;
          if (typeof value === "number" && Number.isFinite(value) && value > 0) {
            output[id] = value;
          }
        }
        return output;
      } catch (error) {
        if (attempt === MAX_RETRIES - 1) {
          throw error;
        }
        await new Promise((resolve) => setTimeout(resolve, BASE_BACKOFF_MS * 2 ** attempt));
      }
    }
    return {};
  }
}

export const priceOracle = new PriceOracle();

let priceSampleCounter = 0;

const toScaledPrice = (price: number) => BigInt(Math.round(price * Number(PRICE_SCALE)));

const recordPriceSample = (
  context: any,
  metadata: AssetMetadata,
  price: number | undefined,
  source: PriceSource,
  status: PriceSampleStatus,
  blockNumber: bigint,
  timestamp: bigint,
  reason?: string
) => {
  const sample: AssetPriceSampleEntity = {
    id: `${metadata.address}-${timestamp.toString()}-${priceSampleCounter++}`,
    asset: metadata.address,
    symbol: metadata.symbol,
    price: typeof price === "number" ? toScaledPrice(price) : undefined,
    source,
    status,
    reason,
    blockNumber,
    fetchedAt: timestamp,
  };
  context.AssetPriceSample.set(sample);
  if (typeof price === "number" && status !== "FAILURE") {
    const entity: AssetPriceEntity = {
      id: metadata.address,
      asset: metadata.address,
      symbol: metadata.symbol,
      price: toScaledPrice(price),
      source,
      blockNumber,
      updatedAt: timestamp,
    };
    context.AssetPrice.set(entity);
  }
};

const resolvePriceFromMap = (
  metadata: AssetMetadata,
  priceMap: Record<string, number>,
  visited: Set<string>
): PriceComputation => {
  if (metadata.priceId) {
    const price = priceMap[metadata.priceId];
    if (typeof price === "number") {
      return { price, source: "COINGECKO", status: "SUCCESS" };
    }
  }
  if (metadata.derivedFrom) {
    if (visited.has(metadata.derivedFrom)) {
      return { source: "DERIVED", status: "FAILURE", reason: "derivation-cycle" };
    }
    visited.add(metadata.derivedFrom);
    const baseMetadata = getAssetMetadata(metadata.derivedFrom);
    const basePrice = resolvePriceFromMap(baseMetadata, priceMap, visited);
    visited.delete(metadata.derivedFrom);
    if (typeof basePrice.price === "number") {
      const multiplier = metadata.derivedScale ?? 1;
      return {
        price: basePrice.price * multiplier,
        source: "DERIVED",
        status: basePrice.status,
        reason: basePrice.reason,
      };
    }
  }
  if (typeof metadata.fallbackPriceUsd === "number") {
    return {
      price: metadata.fallbackPriceUsd,
      source: metadata.priceId ? "FALLBACK" : "STATIC",
      status: metadata.priceId ? "FALLBACK" : "SUCCESS",
      reason: metadata.priceId ? "coingecko-miss" : undefined,
    };
  }
  if (metadata.priceId) {
    return { source: "FALLBACK", status: "FAILURE", reason: "coingecko-miss" };
  }
  return { source: "STATIC", status: "FAILURE", reason: "missing-price-config" };
};

const resolvePriceAsync = async (
  metadata: AssetMetadata,
  visited: Set<string>
): Promise<PriceComputation> => {
  if (metadata.priceId) {
    const price = await priceOracle.getPriceById(metadata.priceId);
    if (typeof price === "number" && Number.isFinite(price) && price > 0) {
      return { price, source: "COINGECKO", status: "SUCCESS" };
    }
  }
  if (metadata.derivedFrom) {
    if (visited.has(metadata.derivedFrom)) {
      return { source: "DERIVED", status: "FAILURE", reason: "derivation-cycle" };
    }
    visited.add(metadata.derivedFrom);
    const baseMetadata = getAssetMetadata(metadata.derivedFrom);
    const base = await resolvePriceAsync(baseMetadata, visited);
    visited.delete(metadata.derivedFrom);
    if (typeof base.price === "number") {
      const multiplier = metadata.derivedScale ?? 1;
      return {
        price: base.price * multiplier,
        source: "DERIVED",
        status: base.status,
        reason: base.reason,
      };
    }
  }
  if (typeof metadata.fallbackPriceUsd === "number") {
    return {
      price: metadata.fallbackPriceUsd,
      source: metadata.priceId ? "FALLBACK" : "STATIC",
      status: metadata.priceId ? "FALLBACK" : "SUCCESS",
      reason: metadata.priceId ? "coingecko-miss" : undefined,
    };
  }
  if (metadata.priceId) {
    return { source: "FALLBACK", status: "FAILURE", reason: "coingecko-miss" };
  }
  return { source: "STATIC", status: "FAILURE", reason: "missing-price-config" };
};

export const refreshRegisteredAssetPrices = async (context: any, blockNumber: bigint, timestamp: bigint) => {
  const assets = listRegisteredAssets();
  const ids = assets
    .map((asset) => asset.priceId)
    .filter((value): value is string => Boolean(value));
  let priceMap: Record<string, number> = {};
  try {
    priceMap = await priceOracle.fetchBatch(ids);
  } catch {
    priceMap = {};
  }
  for (const metadata of assets) {
    const resolved = resolvePriceFromMap(metadata, priceMap, new Set());
    recordPriceSample(context, metadata, resolved.price, resolved.source, resolved.status, blockNumber, timestamp, resolved.reason);
  }
};

export const getStoredAssetPrice = async (context: any, metadata: AssetMetadata) => {
  const entity = (await context.AssetPrice.get(metadata.address.toLowerCase())) as AssetPriceEntity | undefined;
  return entity?.price ?? null;
};

export const ensureAssetPrice = async (
  context: any,
  metadata: AssetMetadata,
  blockNumber: bigint,
  timestamp: bigint
): Promise<bigint | null> => {
  const existing = await getStoredAssetPrice(context, metadata);
  if (existing && existing > 0n) {
    return existing;
  }
  const resolved = await resolvePriceAsync(metadata, new Set());
  recordPriceSample(context, metadata, resolved.price, resolved.source, resolved.status, blockNumber, timestamp, resolved.reason);
  return typeof resolved.price === "number" ? toScaledPrice(resolved.price) : null;
};
