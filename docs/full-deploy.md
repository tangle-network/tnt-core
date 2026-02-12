# Full Deploy Orchestration

`script/FullDeploy.s.sol` is the production entrypoint for a complete TNT Core deployment. It composes the existing slice scripts (`Deploy.s.sol`, `AddRestakingAsset.s.sol`, inflation + rewards setup, migration helpers) so mainnet/testnet/Sepolia rollouts only need to supply a single configuration file.

The script performs the following sequence:

1. Deploy or reuse the core protocol (MultiAssetDelegation, Tangle, OperatorStatusRegistry, TNT token, MBSM registry).
2. Deploy and wire the incentives stack (TangleMetrics, RewardVaults, InflationPool) as requested.
3. Register every ERC20 restaking asset and optionally enforce adapters/guards/delays.
4. Apply operator limits and pausers on both the restaking and protocol contracts.
5. Emit a manifest JSON file with every deployed address and the applied configuration.
6. Optionally emit a migration metadata JSON (TNT token + optional Merkle path string) for downstream tooling.

This script does **not** deploy the TNT claim contract or generate Merkle snapshots. The v2 TNT migration/distribution flow lives under `packages/migration-claim` (see `docs/tnt-migration-v2.md`).

## Configuration

The script reads a JSON config pointed to by the `FULL_DEPLOY_CONFIG` environment variable. Copy one of the samples under `deploy/config/` and tweak the values per environment:

```jsonc
{
  "network": "base-sepolia",
  "roles": {
    "admin": "0xAdmin",
    "treasury": "0xTreasury",
    "timelock": "0xTimelock",
    "multisig": "0xMultisig",
    "revokeBootstrap": false
  },
  "core": {
    "deploy": true,
    "minOperatorStake": 1e18,
    "minDelegation": 1e17,
    "operatorCommissionBps": 1000,
    "maxBlueprintsPerOperator": 48
  },
  "restakeAssets": [
    {
      "symbol": "USDC",
      "token": "0xToken",
      "adapter": "0xAdapter",
      "minOperatorStake": 0,
      "minDelegation": 0,
      "depositCap": 5_000_000 * 1e6,
      "rewardMultiplierBps": 12_000
    }
  ],
  "incentives": {
    "deployMetrics": true,
    "deployRewardVaults": true,
    "deployInflationPool": true,
    "tntToken": "0xExistingTNT (optional)",
    "vaultOperatorCommissionBps": 1500,
    "epochLength": 50400,
    "weights": {
      "stakingBps": 5000,
      "operatorsBps": 2500,
      "customersBps": 1000,
      "developersBps": 1500,
      "restakersBps": 0
    },
    "vaults": [
      {
        "asset": "0x0000000000000000000000000000000000000000",
        "apyBps": 900,
        "depositCap": 1_000_000 ether,
        "incentiveCap": 500_000 ether,
        "boostMultiplierBps": 0,
        "active": true
      }
    ]
  },
  "guards": {
    "pauseRestaking": false,
    "pauseTangle": false,
    "requireAdapters": false,
    "delegatorDelay": 7,
    "operatorDelay": 7,
    "bondLessDelay": 7,
    "maxBlueprintsPerOperator": 48
  },
  "manifest": { "path": "deployments/base-sepolia/latest.json", "logSummary": true },
  "migration": {
    "emitArtifacts": true,
    "artifactsPath": "deployments/base-sepolia/migration.json",
    "merklePath": "deployments/base-sepolia/merkle-tree.json",
    "notes": "Optional text copied into the UI bundle"
  }
}
```

- **roles** – admin/treasury overrides plus optional timelock + multisig targets. When `revokeBootstrap` is true, the bootstrap admin (deployer/admin) is removed after roles are granted.
- **core** – toggles for reusing an existing deployment and overriding the restaking defaults. When `deploy` is `false`, populate `restaking`, `tangle`, and `statusRegistry` in the config.
- **restakeAssets** – array of ERC20 assets onboarded via `enableAsset`/`enableAssetWithAdapter`.
- **incentives** – optionally deploy the metrics/RewardVaults/InflationPool stack, configure vaults, and set epoch/weight parameters. If any `weights.*Bps` fields are non-zero they must sum to 10_000. If the TNT token already exists, set `tntToken`; otherwise the script deploys a fresh TNT token.
- **guards** – pause switches, adapter enforcement, delay overrides, and operator blueprint limits.
- **manifest** – output file for the final address snapshot (directories are created automatically).
- **migration** – optional metadata bundle (tntToken/restaking/tangle plus an optional `merklePath` string for consumers). The actual v2 claim contract + Merkle artifacts are produced by `packages/migration-claim`.

### Role handoff

If `roles.timelock`/`roles.multisig` are set, `FullDeploy` will grant roles after configuration:
- **Tangle**: `DEFAULT_ADMIN_ROLE`, `ADMIN_ROLE`, `UPGRADER_ROLE` → timelock; `PAUSER_ROLE`, `SLASH_ADMIN_ROLE` → multisig.
- **MultiAssetDelegation**: `DEFAULT_ADMIN_ROLE`, `ADMIN_ROLE` → timelock; `ASSET_MANAGER_ROLE` → multisig.
- **Incentives** (metrics/vaults/inflation/service fee/streaming): admin + upgrader roles → timelock; `InflationPool.FUNDER_ROLE` → treasury.
- **TNT token** (if deployed via `FullDeploy` or using a TangleToken): `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE`, `UPGRADER_ROLE` → timelock.

Set `roles.revokeBootstrap = true` to remove the bootstrap admin once roles are granted.

See:

- `deploy/config/base-sepolia.example.json` – minimal example with deterministic numbers.
- `deploy/config/base-sepolia-holesky.json` – Base Sepolia ↔ Holesky placeholder profile (TODOs attached to every address and limit).
- `deploy/config/base-mainnet.json` – Base mainnet placeholder profile covering TNT + major assets (WETH, stETH, wstETH, EIGEN, USDC, USDT, DAI, WBTC, tBTC, lBTC, USDe).
- `deploy/config/local.anvil.json` – deterministic local environment.

When reusing an existing TNT deployment, set either `TNT_TOKEN` (environment variable) or the `incentives.tntToken` field in your config so every script (deploy, migration, inflation, governance) shares the same ERC20.

## Running the script

1. Export your deployer key and config file:
   ```bash
   export PRIVATE_KEY=0x...
   export FULL_DEPLOY_CONFIG=deploy/config/base-sepolia.example.json
   ```
2. Run the script against the desired RPC endpoint:
   ```bash
   forge script script/FullDeploy.s.sol:FullDeploy \
     --rpc-url $RPC_URL \
     --broadcast \
     --verify \
     --slow
   ```
3. After completion, inspect the manifest and (optional) migration artifacts under `deployments/`.

### Local environment helper

`./scripts/local-env/start-local-env.sh` wraps the script for Anvil-based development. It:

1. Boots an Anvil instance (chain id 31337, block time 1s) if one is not running.
2. Sets `PRIVATE_KEY` to the default Anvil deployer key when not provided.
3. Executes `FullDeploy` with `deploy/config/local.anvil.json`.
4. Stores the manifest under `deployments/anvil/manifest.json`.

```bash
scripts/local-env/start-local-env.sh
```

Override `FULL_DEPLOY_CONFIG` to point at another JSON file for bespoke local setups.

## Post-deploy checklist

The manifest includes:

- Core contract addresses (Tangle, MultiAssetDelegation, OperatorStatusRegistry)

## Liveness & event expectations

- Operator liveness is tracked via `OperatorStatusRegistry` heartbeats submitted by the operator runtime/CLI. Integrators should use `submitHeartbeat` and read `isOnline`, `getOperatorStatus`, or `getLastHeartbeat` from the registry.
- `JobCompleted` emits only `(serviceId, callId)`. Derive `resultCount` via `getJobCall(serviceId, callId)`. Indexers must match the minimal event signatures in `indexer/config.yaml`.
- Incentive stack addresses (TNT token, RewardVaults, InflationPool, Metrics)
- Restaking asset configs and reward vault specs
- Guard/delay settings and migration metadata

Commit the manifest and migration files into the runbook repository you use for change management so reproducible deployments stay auditable. The smoke-test assertions in the script (asset registration + reward manager wiring) run automatically at the tail end; extend those as new modules are added. 
