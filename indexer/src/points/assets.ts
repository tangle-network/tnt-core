export type AssetCategory = "RESTAKING" | "VAULT" | "STABLE" | "REWARD";

export type AssetMetadata = {
  address: string;
  symbol: string;
  decimals: number;
  priceId?: string;
  category: AssetCategory;
  /**
   * Static USD price to use when the asset is not listed on CoinGecko (e.g. vault shares).
   */
  fallbackPriceUsd?: number;
  /**
   * Address of the underlying asset this token derives its value from.
   * Used when vault shares represent proportional ownership of another ERC20.
   */
  derivedFrom?: string;
  /**
   * Optional multiplier applied when deriving a price from another asset.
   * Example: 1 vault share translates to X units of the underlying asset.
   */
  derivedScale?: number;
  description?: string;
};

export const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

const registry = new Map<string, AssetMetadata>();

export const registerAssetMetadata = (metadata: AssetMetadata) => {
  registry.set(metadata.address.toLowerCase(), metadata);
};

const STATIC_ASSETS: AssetMetadata[] = [
  {
    address: ZERO_ADDRESS,
    symbol: "TNT",
    decimals: 18,
    priceId: process.env.TNT_COINGECKO_ID || "tangle",
    category: "RESTAKING",
    description: "Native TNT staking/bond asset",
  },
  {
    address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
    symbol: "WETH",
    decimals: 18,
    priceId: "weth",
    category: "RESTAKING",
    description: "Canonical wrapped ETH",
  },
  {
    address: "0xae7ab96520de3a18e5e111b5eaab095312d7fe84",
    symbol: "stETH",
    decimals: 18,
    priceId: "staked-ether",
    category: "RESTAKING",
    description: "Lido staked ETH",
  },
  {
    address: "0x7f39c581f595b53c5cb9546a3f048c57f8d9aefc",
    symbol: "wstETH",
    decimals: 18,
    priceId: "wrapped-steth",
    category: "RESTAKING",
    description: "Wrapped stETH (non-rebasing)",
  },
  {
    address: "0xae78736cd615f374d3085123a210448e74fc6393",
    symbol: "rETH",
    decimals: 18,
    priceId: "rocket-pool-eth",
    category: "RESTAKING",
    description: "Rocket Pool staked ETH",
  },
  {
    address: "0xbe9895146f7af43049ca1c1ae358b0541ea49704",
    symbol: "cbETH",
    decimals: 18,
    priceId: "coinbase-wrapped-staked-eth",
    category: "RESTAKING",
    description: "Coinbase wrapped staked ETH",
  },
  {
    address: "0xa2e3356610840701bdf5611a53974510e5ab5773",
    symbol: "WBETH",
    decimals: 18,
    priceId: "wrapped-beacon-eth",
    category: "RESTAKING",
    description: "Binance wrapped beacon ETH",
  },
  {
    address: "0xa3c322ad15218fbfaed26cde2222926b9f2a9cc9",
    symbol: "ETHx",
    decimals: 18,
    priceId: "stader-ethx",
    category: "RESTAKING",
    description: "Stader ETHx",
  },
  {
    address: "0xac3e018457b222d93114458476f3e3416abbe38f",
    symbol: "sfrxETH",
    decimals: 18,
    priceId: "frax-ether",
    category: "RESTAKING",
    description: "Frax staked ETH",
  },
  {
    address: "0x2416092f143378750bb29b79ed961ab195cce9b1",
    symbol: "ezETH",
    decimals: 18,
    priceId: "renzo-restaked-eth",
    category: "RESTAKING",
    description: "Renzo ezETH",
  },
  {
    address: "0x04c154b66cb340f3ae24111cc767e0184ed00cc6",
    symbol: "rsETH",
    decimals: 18,
    priceId: "kelp-dao-restaked-eth",
    category: "RESTAKING",
    description: "Kelp DAO rsETH",
  },
  {
    address: "0xbfedbcbe27171c418cdabc2477042554b1904857",
    symbol: "mETH",
    decimals: 18,
    priceId: "mantle-staked-ether",
    category: "RESTAKING",
    description: "Mantle staked ETH",
  },
  {
    address: "0xe95a203b1a91a908f9b9ce46459d101078c2c3cb",
    symbol: "ankrETH",
    decimals: 18,
    priceId: "ankreth",
    category: "RESTAKING",
    description: "Ankr liquid staking token",
  },
  {
    address: "0xf951e335afb289353dc249e82926178eac7ded78",
    symbol: "swETH",
    decimals: 18,
    priceId: "swell-staked-eth",
    category: "RESTAKING",
    description: "Swell swETH",
  },
  {
    address: "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599",
    symbol: "WBTC",
    decimals: 8,
    priceId: "wrapped-bitcoin",
    category: "RESTAKING",
    description: "Wrapped Bitcoin",
  },
  {
    address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    symbol: "USDC",
    decimals: 6,
    priceId: "usd-coin",
    category: "STABLE",
    description: "Circle USD Coin",
  },
  {
    address: "0xdac17f958d2ee523a2206206994597c13d831ec7",
    symbol: "USDT",
    decimals: 6,
    priceId: "tether",
    category: "STABLE",
    description: "Tether USD",
  },
  {
    address: "0x6b175474e89094c44da98b954eedeac495271d0f",
    symbol: "DAI",
    decimals: 18,
    priceId: "dai",
    category: "STABLE",
    description: "MakerDAO DAI stablecoin",
  },
  {
    address: "0x853d955acef822db058eb8505911ed77f175b99e",
    symbol: "FRAX",
    decimals: 18,
    priceId: "frax",
    category: "STABLE",
    description: "Frax stablecoin",
  },
];

STATIC_ASSETS.forEach(registerAssetMetadata);

export const listRegisteredAssets = () => Array.from(registry.values());

export const getAssetMetadata = (address: string | undefined | null): AssetMetadata => {
  const key = (address ?? ZERO_ADDRESS).toLowerCase();
  const existing = registry.get(key);
  if (existing) {
    return existing;
  }
  const metadata: AssetMetadata = {
    address: key,
    symbol: `token-${key.slice(2, 6)}`,
    decimals: 18,
    category: "RESTAKING",
  };
  registry.set(key, metadata);
  return metadata;
};
