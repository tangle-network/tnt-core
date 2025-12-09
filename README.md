# tnt-core

This repo contains interfaces and abstractions for using Tangle's restaking infrastructure for the creation of new
service blueprints. The service blueprint is a set of smart contracts that define the rules of the service and allow the gadget developer to customize the service to their needs, how it is used, how it is paid for, and how it is managed.

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

### Envio indexer

An Envio indexer is included under `indexer/` to track on-chain protocol data. The handler stack is now modular:

- `indexer/src/EventHandlers.ts` is a tiny registry that wires every contract-specific module.
- `indexer/src/handlers/*.ts` group logic by domain (`tangle`, `restaking`, `rewardVaults`, `blueprintManager`, `credits`, `hourly`).
- `indexer/src/lib/handlerUtils.ts` centralises common helpers (entity upsert helpers, ID builders, etc.).
- Incentive logic lives under `indexer/src/points/` (`programs.ts` for program definitions, `awards.ts` for reusable award helpers, `participation.ts` for hourly ticking).

The schema is defined in `indexer/schema.graphql`, and contract coverage is configured in `indexer/config.yaml`. To work on the indexer locally:

```sh
cd indexer
npm install
npm run codegen     # generates the ./generated package
npm run dev         # starts the indexer with live auto-reload
```

* `npm run build` runs the TypeScript compiler so you can type-check handlers.
* `npm run start` runs the compiled indexer once (useful in CI).
* Update/add contract stanzas in `indexer/config.yaml` before targeting another deployment, then re-run `npm run codegen`.

#### Indexer incentives

Points programs are defined in `indexer/src/points/programs.ts` and exposed via helper functions in `points/awards.ts`. The current coverage incentivises:

- Developers – blueprint creation/definition events (`developer-blueprint`).
- Customers – service requests/activations and recurring escrow top-ups (`customer-service` / `customer-escrow`).
- Operators – stake, registration, hourly participation, and heartbeat uptime (`operator-registration`, `operator-stake`, `operator-hourly`, `operator-uptime`).
- Restakers – deposits, delegations, and vault staking (`delegator-deposit`, `delegation`, `restaker-vault`).

Contract modules call the award helpers, so adding a new incentive is as simple as wiring the relevant event to a helper (or introducing a new helper/program when needed).

### Additional Documentation

- [Points & Pricing Pipeline](docs/points-pipeline.md) – covers the asset
  registry policy, USD conversion flow, and the runbooks for updating assets or
  responding to price API outages.
