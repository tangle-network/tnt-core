# Deployment Runbook (TNT / Tangle Protocol)

This repo uses Foundry scripts for deployment. The two “production” entrypoints are:

- `script/v2/FullDeploy.s.sol:FullDeploy` (protocol core + optional incentives)
- `script/v2/DeployBeaconSlashing.s.sol:*` + `script/v2/DeployL2Slashing.s.sol:*` (beacon-slashing cross-chain wiring)

## Script Inventory (what exists today)

**Core / Incentives**
- `script/v2/Deploy.s.sol:DeployV2`: deploys core stack (UUPS proxies) and optionally deploys `TangleToken` (TNT).
- `script/v2/FullDeploy.s.sol:FullDeploy`: orchestrates `DeployV2` plus:
  - Restake asset enablement (with optional adapters)
  - Optional `TangleMetrics`, `RewardVaults`, `InflationPool`
  - Writes a manifest JSON (see `deploy/config/*` -> `.manifest.path`)
  - Wires permissions so `RewardVaults` can be called by `MultiAssetDelegation` and `InflationPool`

**Beacon slashing (L1 → L2)**
- `script/v2/DeployBeaconSlashing.s.sol:DeployBeaconSlashingL1*`: deploys:
  - `ValidatorPodManager`
  - `L2SlashingConnector`
  - bridge messenger (`HyperlaneCrossChainMessenger` or `LayerZeroCrossChainMessenger`)
  - Optional manifest output via `BEACON_SLASHING_MANIFEST`
  - Supports `SKIP_CHAIN_CONFIG=true` for two-step wiring (deploy first, configure later).
- `script/v2/DeployL2Slashing.s.sol:DeployL2SlashingHyperlane` / `DeployL2SlashingLayerZero`:
  - deploys `TangleL2Slasher` + `L2SlashingReceiver`
  - deploys the *destination* receiver adapter (`HyperlaneReceiver` / `LayerZeroReceiver`)
  - sets `L2SlashingReceiver.messenger` to the adapter
  - optional manifest output via `L2_SLASHING_MANIFEST`

**Local / E2E**
- `script/v2/LocalTestnet.s.sol:LocalTestnetSetup`: local Anvil full stack (mock tokens, blueprints, pods).
- `scripts/e2e-local.sh`: spins up Anvil + deploy + indexer.

**Token distribution**
- `script/v2/DistributeTNT.s.sol:DistributeTNT`: batch ERC20 transfers from the deployer using `DISTRIBUTION_FILE` (example: `deploy/config/tnt-distribution.example.json`).
- `script/v2/DistributeTNTWithLockup.s.sol:DistributeTNTWithLockup`: batch ERC20 transfers with a configurable unlocked/locked split and a per-recipient cliff lock.

**Substrate → EVM migration (SP1 / ZK)**
- `packages/migration-claim/`: Foundry subpackage containing `TangleMigration` + `SP1ZKVerifier` and scripts for generating Merkle roots/proofs from real snapshot data.

**Legacy / likely obsolete**
- `scripts/MBSMDeployer.s.sol`: appears to target a pre-v2 path (`src/MasterBlueprintServiceManager.sol`), and is not used by the v2 deploy orchestrators.

## Recommended Deploy Order (Base Sepolia + Holesky)

### 0) Preconditions
- Decide `ADMIN` and `TREASURY` (EOA vs multisig) and fund the deployer on both chains.
- Prepare `FULL_DEPLOY_CONFIG` (start from `deploy/config/base-sepolia-holesky.json` and replace zero addresses / TODOs).
- Decide the TNT token plan:
  - If you want a stable, pre-announced TNT address, deploy TNT first and set `OPERATOR_BOND_TOKEN` / `TNT_TOKEN` when running `FullDeploy` so it doesn’t auto-deploy a token.
  - If you are running Substrate→EVM migration, also decide the Merkle root source (`packages/migration-claim/merkle-tree.json` vs regenerated from snapshot) and the lock cliff date.

### 1) Deploy protocol core on Base Sepolia
- Run `script/v2/FullDeploy.s.sol:FullDeploy` on Base Sepolia.
- Output: manifest at `.manifest.path` (e.g. `deployments/base-sepolia-holesky/latest.json`) containing `tangle`, `restaking`, `tntToken`, and incentives addresses.

### 2) Deploy beacon slashing infra on Holesky (without L2 wiring)
- Run `script/v2/DeployBeaconSlashing.s.sol:DeployBeaconSlashingL1Holesky` (or `...HoleskyLayerZero`) on Holesky with:
  - `SKIP_CHAIN_CONFIG=true`
  - `TANGLE_CHAIN_ID=84532` (destination chain id)
  - `BEACON_SLASHING_MANIFEST=deployments/base-sepolia-holesky/beacon-slashing.json`

### 3) Deploy L2 slashing receiver on Base Sepolia
- Run `script/v2/DeployL2Slashing.s.sol:DeployL2SlashingHyperlane` (or `...LayerZero`) on Base Sepolia with:
  - `RESTAKING=<restaking from FullDeploy manifest>`
  - `SOURCE_CHAIN_ID=17000`
  - `L1_CONNECTOR=<connector from Holesky manifest>`
  - `L1_MESSENGER=<messenger from Holesky manifest>`
  - `L2_SLASHING_MANIFEST=deployments/base-sepolia-holesky/l2-slashing.json`
  - For LayerZero + Holesky: set `LAYERZERO_SOURCE_EID` (LayerZero EID for Holesky).

### 4) Wire Holesky connector → Base Sepolia receiver
- Run `script/v2/DeployBeaconSlashing.s.sol:ConfigureL2SlashingConnector` on Holesky with:
  - `CONNECTOR=<connector from Holesky manifest>`
  - `MESSENGER=<messenger from Holesky manifest>`
  - `TANGLE_CHAIN_ID=84532`
  - `L2_RECEIVER=<receiver from Base manifest>`

### One-command helper
- `scripts/deploy-testnet-base-sepolia-holesky.sh` automates the above (requires `jq`).
- Optional: set `DEPLOY_MIGRATION=true` to run `scripts/deploy-migration-base-sepolia.sh` after core/slashing deploy (you must also set `TREASURY_RECIPIENT` and `PROGRAM_VKEY` unless you use `USE_MOCK_VERIFIER=true`).

## Recommended Deploy Order (Base mainnet + Ethereum mainnet)

- Use `scripts/deploy-mainnet-base-ethereum.sh` with:
  - `BASE_RPC` (Base mainnet RPC)
  - `MAINNET_RPC` (Ethereum mainnet RPC)
  - `FULL_DEPLOY_CONFIG=deploy/config/base-mainnet.json`

Optional: set `DEPLOY_MIGRATION=true` to deploy the full migration system on Base mainnet after core/slashing (same snapshot artifacts and lock config).

## Swapping Base for another chain (Arbitrum/Tempo/any EVM)

**Core + incentives (`FullDeploy`)**
- Chain-agnostic: run `script/v2/FullDeploy.s.sol:FullDeploy` against any EVM RPC, and create a matching `deploy/config/<network>.json` for addresses/policy.

**Beacon slashing cross-chain (L1 ↔ L2)**
- `script/v2/DeployL2Slashing.s.sol:*` already supports overrides for non-Base chains via env vars:
  - `HYPERLANE_MAILBOX` (for Hyperlane receiver deployments)
  - `LAYERZERO_ENDPOINT` and `LAYERZERO_SOURCE_EID` (for LayerZero)
- `script/v2/DeployBeaconSlashing.s.sol:DeployBeaconSlashingL1` supports deploying the L1 messenger on additional chains by setting:
  - `L1_HYPERLANE_MAILBOX` + `L1_HYPERLANE_IGP` (Hyperlane)
  - `L1_LAYERZERO_ENDPOINT` (LayerZero)

If you’re targeting a chain not in the hardcoded defaults, set those env vars explicitly (using the bridge’s canonical deployment addresses).

### One-command helper (generic L1 → destination)

Use `scripts/deploy-l1-to-evm-destination.sh` when you want to treat the destination chain (Base/Arbitrum/Tempo/etc) the same way:
- `L1_RPC` is Ethereum (or other L1) RPC
- `DEST_RPC` is the destination EVM chain RPC
- `SOURCE_CHAIN_ID` is the L1 chainId
- `DEST_CHAIN_ID` is the destination chainId
- `SLASHING_BRIDGE=hyperlane|layerzero`

Optional: set `DEPLOY_MIGRATION=true` to deploy the full TNT migration system on the destination chain after core/slashing.

## Migration Rollout (optional, TNT launch)

If doing Substrate→EVM migration + EVM airdrop:
- Substrate claims: deploy and fund `TangleMigration` from `packages/migration-claim/` using the Merkle root from `packages/migration-claim/merkle-tree.json` (and configure `unlockTimestamp`/`unlockedBps` *before the first claim* via `setLockConfig` if you need to override defaults).
- EVM airdrop: use `packages/migration-claim/scripts/evmClaimsToDistribution.ts` to produce batched JSON files, then run `script/v2/DistributeTNTWithLockup.s.sol:DistributeTNTWithLockup` against each batch.

### Testnet (Base Sepolia) migration deploy (feature parity)

This deploys the full migration system on Base Sepolia using the in-repo snapshot artifacts:
- `packages/migration-claim/merkle-tree.json` (Substrate claims; excludes the non-claimable `modlpy/trsry` module treasury leaf)
- `packages/migration-claim/evm-claims.json` (direct EVM list)
- `packages/migration-claim/treasury-carveout.json` (treasury allocation you must send to a real EVM address)

**Prereqs**
- A TNT token address to distribute (recommended: the `tntToken` from your `FullDeploy` manifest so the dApp/protocol use the same token).
- Deployer has enough TNT balance to fund:
  - `TOTAL_SUBSTRATE` into `TangleMigration`
  - `TOTAL_EVM` for the EVM airdrop
  - `TREASURY_AMOUNT` sent to `TREASURY_RECIPIENT`
- For SP1 parity, set `PROGRAM_VKEY` and ensure `SP1_VERIFIER` (gateway) is correct for Base Sepolia.

**Deploy migration (no EVM airdrop yet)**
- `BASE_SEPOLIA_RPC=... PRIVATE_KEY=... FULL_DEPLOY_MANIFEST=deployments/base-sepolia-holesky/latest.json TREASURY_RECIPIENT=0x... PROGRAM_VKEY=0x... ./scripts/deploy-migration-base-sepolia.sh`

**Deploy migration + execute full EVM airdrop**
- `BASE_SEPOLIA_RPC=... PRIVATE_KEY=... FULL_DEPLOY_MANIFEST=deployments/base-sepolia-holesky/latest.json TREASURY_RECIPIENT=0x... PROGRAM_VKEY=0x... ./scripts/deploy-migration-base-sepolia.sh --airdrop`

Notes:
- The script writes `deployments/base-sepolia/migration.json` (override with `MIGRATION_MANIFEST_PATH`).
- It uses the migration contract’s `unlockTimestamp` + `unlockedBps` for the EVM lockups so both paths match.
- `TangleMigration` includes an owner-only `adminClaim` window (default 60 days) for edge-case recovery; set `MIGRATION_OWNER` to a multisig/timelock.

## What’s “ready” vs still missing for production

**Ready / in-repo**
- Core + incentives deploy orchestration (`FullDeploy`) with JSON configs and manifest outputs.
- Beacon slashing infra deployment on L1 and L2, including destination receiver adapters and manifests.
- Targeted deployment-script tests: `test/v2/scripts/DeploymentScriptsTest.t.sol`.

**Not production-complete yet (gaps)**
- Mainnet configs (`deploy/config/base-mainnet.json`) still contain placeholder addresses and TODO policy values.
- “Token genesis” is still policy-dependent (who mints/holds supply, vesting/lockups). The repo has:
  - `DistributeTNTWithLockup` for direct EVM lists (batched).
  - `packages/migration-claim` for Substrate→EVM Merkle+ZK claims with the same lock split.
  But these are not yet orchestrated by `FullDeploy` (they’re run as separate rollout steps).
- Governance deployment is present as contracts (`src/v2/governance/GovernanceDeployer.sol`) but not integrated into `FullDeploy` (role transfer / timelock hardening is still a manual step).
- LayerZero Holesky EID is not hardcoded; you must provide `LAYERZERO_SOURCE_EID`.

## Rewards / Inflation (current model)

Today, rewards are designed to be **pre-funded**:
- `InflationPool` cannot mint; it only distributes the TNT it already holds.
- `RewardVaults` cannot mint; it only pays out the TNT it already holds.

Chain note: `InflationPool` budgets are timestamp-based (epochs in seconds, funding period in seconds), so the same config works
across L1/L2 without needing block-time assumptions.

To start rewards (e.g. “1% yearly inflation budget”), governance/treasury should:
- Transfer TNT into the `InflationPool` using `InflationPool.fund(amount)` (recommended for accounting; it updates `periodBudget` and emits `PoolFunded`).
- Anyone can call `InflationPool.distributeEpoch()` when an epoch ends (it’s permissionless).

If you later decide to make TNT truly inflationary (minting new supply):
- Keep the same reward system, but mint via governance (TangleTimelock with `MINTER_ROLE`) and then `fund()` the `InflationPool`.
- Do not give `MINTER_ROLE` to `InflationPool`/`RewardVaults` (it breaks the “risk isolation” model).
