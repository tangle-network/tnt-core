# tnt-core

This repo contains interfaces and abstractions for using Tangle's restaking infrastructure for the creation of new
service blueprints. The service blueprint is a set of smart contracts that define the rules of the service and allow the blueprint developer to customize the service to their needs, how it is used, how it is paid for, and how it is managed.

## Getting Started

## Usage

Here's a list of the most frequently needed commands.

### Install

Install the dependencies
```sh
forge soldeer update
```

### Build

Build the contracts:

```sh
forge build
```

### Deployment Notes

Every deployment must register at least one Master Blueprint Service Manager (MBSM) version and configure it on `Tangle` before blueprint creation. The provided deploy scripts already deploy an `MBSMRegistry`, add the first version, and call `setMBSMRegistry` on the Tangle proxy. If you roll your own tooling, replicate those steps (or call `setMBSMRegistry` with an existing registry) before attempting `createBlueprint`; the call now enforces that dependency and will revert if the registry is unset.

#### Full Deploy pipeline

- The config-driven orchestrator lives at `script/v2/FullDeploy.s.sol`. Point `FULL_DEPLOY_CONFIG` at a JSON file under `deploy/config/` (see [`docs/full-deploy.md`](docs/full-deploy.md) for the schema) and run:
  ```bash
  export PRIVATE_KEY=0x...
  export FULL_DEPLOY_CONFIG=deploy/config/base-sepolia.example.json
  forge script script/v2/FullDeploy.s.sol:FullDeploy --rpc-url $RPC_URL --broadcast --slow
  ```
- The script deploys or reuses the core stack, onboards restake assets, configures the inflation/reward modules, and writes a manifest/migration bundle under `deployments/`.
- Additional skeleton profiles are staged for upcoming rollouts:
  - `deploy/config/base-sepolia-holesky.json` – Base Sepolia ↔ Holesky bridge rehearsal (placeholders + TODOs for every address).
  - `deploy/config/base-mainnet.json` – Base mainnet deployment (with placeholder TNT/restake asset data).
- Local developers can bootstrap Anvil with `scripts/local-env/start-local-env.sh`, which wraps the same entrypoint using `deploy/config/local.anvil.json`.
- Set `TNT_TOKEN` (alias for `OPERATOR_BOND_TOKEN`) when reusing an existing TNT deployment. The deployment scripts, migration helpers, inflation setup, and governance deployer all reuse that single address instead of spinning up duplicate tokens; leave it unset to auto-deploy a fresh `TangleToken`.

Operator onboarding also requires a TNT bond. The deployment script enforces this automatically:

1. Provide the TNT ERC20 address (and optional bond amount) via environment variables:
   ```bash
   export OPERATOR_BOND_TOKEN=0xYourTNTAddress
   export OPERATOR_BOND_AMOUNT=100000000000000000000   # 100 TNT (18 decimals)
   ```
   If `OPERATOR_BOND_TOKEN` is omitted, the script deploys a fresh `TangleToken` proxy and uses it for bonding.
2. After deployment you can modify the defaults with `setOperatorBondAsset` / `setOperatorBlueprintBond`; per-blueprint overrides still set the amount but stay denominated in the selected TNT token.

A starter `deploy.env.example` file is included—copy it to `.env`, fill in the TNT token address (and other fields), then run the deploy script so every operator bond is captured in TNT out of the box.

Operators must approve the TNT bond token before calling `registerOperator`, and `unregisterOperator` refunds the same asset automatically.

### Integrator notes

- Operator liveness is tracked via `OperatorStatusRegistry` heartbeats submitted by the operator runtime/CLI. Use `submitHeartbeat` for liveness proofs and read `isOnline`, `getOperatorStatus`, or `getLastHeartbeat` for status. There is no `setOperatorOnline` call in core.
- `JobCompleted` emits only `(serviceId, callId)`. Derive `resultCount` from `getJobCall(serviceId, callId)`. Indexers must match the minimal event signatures configured in `indexer/config.yaml`.

### Envio indexer

An Envio indexer is included under `indexer/` to track on-chain protocol data. The handler stack is now modular:

- `indexer/src/EventHandlers.ts` is a tiny registry that wires every contract-specific module.
- `indexer/src/handlers/*.ts` group logic by domain (`tangle`, `restaking`, `rewardVaults`, `blueprintManager`, `credits`, `hourly`, `liquidDelegation`, `validatorPods`).
- `indexer/src/lib/handlerUtils.ts` centralises common helpers (entity upsert helpers, ID builders, etc.).
- Incentive logic lives under `indexer/src/points/` (`programs.ts` for program definitions, `awards.ts` for reusable award helpers, `participation.ts` for hourly ticking).

The schema is defined in `indexer/schema.graphql`, and contract coverage is configured in `indexer/config.yaml`. A detailed breakdown of point weights/programs lives in [`docs/points.md`](docs/points.md). To work on the indexer locally:

```sh
cd indexer
npm install
npm run codegen     # generates the ./generated package
npm run dev         # starts the indexer with live auto-reload
```

- `npm run build` runs the TypeScript compiler so you can type-check handlers.
- `npm run start` runs the compiled indexer once (useful in CI).
- `npm run test` executes the lightweight points tests under `src/points/__tests__`.
- Update/add contract stanzas in `indexer/config.yaml` before targeting another deployment, then re-run `npm run codegen`.

#### Indexer incentives

Points programs are defined in `indexer/src/points/programs.ts` and exposed via helper functions in `points/awards.ts`. The current coverage incentivises:

- Developers – blueprint creation/definition events (`developer-blueprint`).
- Customers – service requests/activations and recurring escrow top-ups (`customer-service` / `customer-escrow`).
- Operators – stake, registration, hourly participation, and heartbeat uptime (`operator-registration`, `operator-stake`, `operator-hourly`, `operator-uptime`).
- Restakers – deposits, delegations, and vault staking (`delegator-deposit`, `delegation`, `restaker-vault`).

Contract modules call the award helpers, so adding a new incentive is as simple as wiring the relevant event to a helper (or introducing a new helper/program when needed).

### Rust Bindings

The `bindings/` crate provides Rust bindings for TNT Core contracts, published to crates.io as [`tnt-core-bindings`](https://crates.io/crates/tnt-core-bindings).

```bash
# Regenerate bindings after contract changes
cargo xtask gen-bindings

# Bump version and publish
cargo xtask bump-version 0.3.0
cargo xtask publish
```

See [xtask/README.md](xtask/README.md) for full documentation.

### Additional Documentation

- [Points & Pricing Pipeline](docs/points-pipeline.md) – covers the asset
  registry policy, USD conversion flow, and the runbooks for updating assets or
  responding to price API outages.
- [Points Program Reference](docs/points.md) – lists every program, weight, and award helper.
