# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

tnt-core is Tangle's EVM-native staking protocol for creating service blueprints. It contains Solidity smart contracts, a TypeScript Envio indexer, and Rust bindings.

## Build & Test Commands

### Solidity (Foundry)

```bash
# Install dependencies
forge soldeer update

# Build contracts
forge build

# Run all tests
forge test

# Run specific test file
forge test --match-path test/v2/Tangle.t.sol

# Run single test function
forge test --match-test testServiceRequest

# Coverage
./coverage.sh

# Format
forge fmt
```

### Indexer (TypeScript/Envio)

```bash
cd indexer
npm install
npm run codegen     # Generate types from schema
npm run dev         # Start with hot reload
npm run build       # TypeScript compile
npm run test        # Run unit tests
```

### Rust Bindings

```bash
# Regenerate bindings after contract changes
cargo xtask gen-bindings

# Bump version and publish
cargo xtask bump-version 0.3.0
cargo xtask publish
```

## Architecture

### Core Contract Structure

The protocol uses a mixin pattern where `Tangle.sol` composes all functionality:

```
src/v2/Tangle.sol          # Main entry point, composes mixins
src/v2/core/
├── Base.sol               # Shared state, access control, UUPS upgrade
├── Blueprints.sol         # Blueprint registration
├── Operators.sol          # Operator management
├── Services.sol           # Service lifecycle
├── Jobs.sol               # Job submission/results
├── Payments.sol           # Payment processing
├── Slashing.sol           # Slashing with dispute window
└── Quotes.sol             # Quote verification
```

### Staking Layer

Pluggable staking backend via `IStaking` interface:

```
src/v2/staking/
├── MultiAssetDelegation.sol    # Native O(1) share accounting
├── OperatorManager.sol         # Operator status tracking
├── SlashingManager.sol         # Slashing execution
├── LiquidDelegationVault.sol   # ERC-7540 vault for liquid staking
└── RewardsManager.sol          # Reward distribution
```

### Blueprint Service Managers

```
src/v2/MasterBlueprintServiceManager.sol  # Manages MBSM versions
src/v2/MBSMRegistry.sol                    # Version registry
src/v2/BlueprintServiceManagerBase.sol     # Base for custom BSMs
```

### Key Abstractions

- **Blueprint**: Template defining a service type, created by developers
- **Service**: Running instance of a blueprint with assigned operators
- **Operator**: Staked entity running services
- **Job**: Task submitted to a service

### Governance

```
src/v2/governance/
├── TangleToken.sol      # ERC20Votes governance token
├── TangleGovernor.sol   # OpenZeppelin Governor
└── TangleTimelock.sol   # Timelock controller
```

### Beacon Chain Integration

Native ETH staking via validator pods:

```
src/v2/beacon/
├── ValidatorPod.sol           # Per-operator validator management
├── ValidatorPodManager.sol    # Pod factory
├── BeaconChainProofs.sol      # Merkle proof verification
└── bridges/                   # Cross-chain messaging (Arbitrum, Base, LayerZero, Hyperlane)
```

## Testing

Tests are in `test/v2/` and use `BaseTest.sol` as the foundation. Key test patterns:

- Unit tests: `test/v2/tangle/`, `test/v2/staking/`, `test/v2/blueprints/`
- Integration: `test/v2/Integration.t.sol`, `test/v2/scenario/FullStackScenario.t.sol`
- Fuzz tests: `test/v2/fuzz/`
- Beacon tests: `test/v2/beacon/`

## Deployment

Config-driven deployment via `script/v2/FullDeploy.s.sol`:

```bash
export PRIVATE_KEY=0x...
export FULL_DEPLOY_CONFIG=deploy/config/base-sepolia.example.json
forge script script/v2/FullDeploy.s.sol:FullDeploy --rpc-url $RPC_URL --broadcast --slow
```

Local development:
```bash
scripts/local-env/start-local-env.sh
```

## Key Environment Variables

- `OPERATOR_BOND_TOKEN` / `TNT_TOKEN`: TNT ERC20 address for operator bonds
- `OPERATOR_BOND_AMOUNT`: Bond amount in wei (default 100 TNT)
- `FULL_DEPLOY_CONFIG`: Path to deployment config JSON

## Tech Stack

- Solidity 0.8.26, Cancun EVM, via-IR enabled
- Foundry with soldeer for dependency management
- OpenZeppelin 5.x for access control, upgrades, governance
- alloy-rs for Rust bindings

## Key Conventions

- All core contracts are upgradeable (UUPS pattern)
- O(1) share-based accounting for delegations
- Events over storage for gas optimization
- Fuzz testing required for financial logic
