# Tangle v2: EVM-Native Protocol Architecture

Production-ready EVM-native restaking protocol for Tempo L1.

## Status: COMPLETE

**926 tests passing** - See [PROGRESS.md](./PROGRESS.md) for details.

## Design Principles

1. **Shared Security Agnostic** - Abstract interfaces for any restaking protocol
2. **Gas Optimized** - O(1) share accounting, packed structs, batch operations
3. **Modern Solidity** - Foundry, Solidity 0.8.26, comprehensive fuzz testing
4. **SDK Compatible** - Rust bindings via `forge bind`

## Documents

| # | Document | Description |
|---|----------|-------------|
| 00 | [V1 Substrate Architecture](./00-v1-substrate-architecture.md) | Legacy Substrate architecture (historical reference) |
| 01 | [Design Principles](./01-design-principles.md) | Core principles and considerations |
| 02 | [Shared Security Interface](./02-shared-security-interface.md) | Protocol-agnostic restaking abstraction |
| 03 | [Protocol Contracts](./03-protocol-contracts.md) | Core Solidity contracts |
| 04 | [SDK Updates](./04-sdk-updates.md) | Blueprint SDK changes |
| 05 | [Implementation Plan](./05-implementation-plan.md) | Build order and milestones |
| 06 | [Beacon Chain Restaking](./06-beacon-chain-validator-restaking.md) | Validator pod system |
| -- | [Design](./DESIGN.md) | Architecture design document |
| -- | [Slashing](./SLASHING_ARCHITECTURE.md) | Slashing system architecture |
| -- | [Progress](./PROGRESS.md) | Implementation status |

## Repository Structure

```
src/v2/
├── Tangle.sol                      # Core protocol entry point
├── core/
│   ├── Base.sol                    # Shared state, access control
│   ├── Blueprints.sol              # Blueprint registration
│   ├── Services.sol                # Service lifecycle
│   ├── Jobs.sol                    # Job submission and results
│   ├── Payments.sol                # Payment processing
│   ├── Rewards.sol                 # O(1) reward distribution
│   └── Slashing.sol                # Slashing with dispute window
├── interfaces/
│   ├── ITangle.sol                 # Main interface
│   ├── ITangleFull.sol             # Complete interface
│   ├── IRestaking.sol              # Staking abstraction
│   └── IBlueprintServiceManager.sol # Hook interface
├── restaking/
│   └── MultiAssetDelegation.sol    # Native staking with share accounting
├── rewards/
│   └── InflationPool.sol           # Pre-funded reward distribution
├── governance/
│   ├── TangleGovernor.sol          # OpenZeppelin Governor
│   ├── TangleToken.sol             # Governance token (ERC20Votes)
│   └── TangleTimelock.sol          # Timelock controller
└── libraries/
    ├── Types.sol                   # Shared types
    ├── Errors.sol                  # Custom errors
    ├── SlashingLib.sol             # Slashing utilities
    └── BN254.sol                   # BLS signature support
```

## Tech Stack

- **Solidity 0.8.26** - Cancun EVM target
- **Foundry** - Testing, deployment, scripting
- **OpenZeppelin 5.x** - Access control, upgrades, governance
- **alloy-rs** - Rust bindings via `forge bind`
