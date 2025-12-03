# Tangle v2: EVM-Native Protocol Architecture

Full protocol rebuild targeting an L3 app-chain on Base or Arbitrum.

## Design Principles

1. **Shared Security Agnostic** - Abstract interfaces for any restaking protocol (native, EigenLayer, Symbiotic)
2. **Gas Optimized** - Merkle state, batching, lazy evaluation
3. **Modern Solidity** - Foundry, latest patterns, comprehensive testing
4. **SDK Minimal Changes** - Preserve developer experience

## Documents

| # | Document | Description |
|---|----------|-------------|
| 00 | [Current State](./00-current-state.md) | Analysis of existing architecture (reference only) |
| 01 | [Design Principles](./01-design-principles.md) | Core principles and L3 considerations |
| 02 | [Shared Security Interface](./02-shared-security-interface.md) | Protocol-agnostic restaking abstraction |
| 03 | [Protocol Contracts](./03-protocol-contracts.md) | Core Solidity contracts |
| 04 | [SDK Updates](./04-sdk-updates.md) | Blueprint SDK changes |
| 05 | [Implementation Plan](./05-implementation-plan.md) | Build order and milestones |

## Repository Structure (v2)

```
tnt-core/
├── src/
│   ├── core/                    # Core protocol
│   │   ├── TangleCore.sol       # Main entry point
│   │   ├── BlueprintRegistry.sol
│   │   ├── ServiceManager.sol
│   │   └── JobManager.sol
│   ├── security/                # Shared security abstraction
│   │   ├── ISecurityManager.sol # Interface
│   │   ├── NativeSecurityManager.sol
│   │   ├── EigenLayerSecurityManager.sol
│   │   └── SymbioticSecurityManager.sol
│   ├── rewards/
│   │   └── RewardsDistributor.sol
│   ├── hooks/                   # Blueprint hooks (existing, refined)
│   │   ├── IBlueprintServiceManager.sol
│   │   └── BlueprintServiceManagerBase.sol
│   └── libraries/
│       ├── Assets.sol
│       ├── Operators.sol
│       └── MerkleState.sol
├── test/
├── script/
└── foundry.toml
```

## Tech Stack

- **Solidity 0.8.24+** - Latest stable
- **Foundry** - Testing, deployment, scripting
- **OpenZeppelin 5.x** - Access control, upgrades, utilities
- **L3 Framework** - Arbitrum Orbit or Base (OP Stack)
