![Tangle Network Banner](https://raw.githubusercontent.com/tangle-network/tangle/refs/heads/main/assets/Tangle%20%20Banner.png)

# TNT Core

[![Discord](https://img.shields.io/badge/Discord-Join%20Chat-7289da?logo=discord&logoColor=white)](https://discord.gg/cv8EfJu3Tn)
[![Twitter](https://img.shields.io/twitter/follow/tangle_network?style=social)](https://twitter.com/tangle_network)

**TNT Core** is an EVM-native staking and service protocol for Tangle Network. It provides multi-asset staking, operator networks, slashing, and x402 payment settlement through a modular Solidity contract architecture.

### How Tangle Staking Compares

| Feature | TNT Core (Tangle) | EigenLayer | Symbiotic |
|---------|-------------------|------------|-----------|
| Multi-asset staking | Native ERC-20 support | ETH and LSTs | Multi-asset via vaults |
| Service registration | On-chain Blueprint registry | AVS contracts (separate) | Vault-based |
| Payment models | PayOnce, Subscription, EventBased | Not built-in | Not built-in |
| x402 payment settlement | Built-in | Not supported | Not supported |
| Liquid delegation | LiquidDelegationVault | Via third-party LRT protocols | Via external vaults |
| Operator management | OperatorStatusRegistry | Operator contract per AVS | Per-vault configuration |

Tangle Network's EVM-native staking and service blueprint protocol. Build decentralized services with customizable operator networks, multi-asset staking, and flexible payment models.

## Installation

```bash
forge soldeer install tnt-core~0.10.4
```

Or add to `foundry.toml`:
```toml
[dependencies]
tnt-core = "0.10.4"
```

## Quick Start

### Local Build

```bash
# Fast local build without compiling test/ and script/
FOUNDRY_PROFILE=local_build forge build

# Full build
forge build
```

Create a custom blueprint by extending `BlueprintServiceManagerBase`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintServiceManagerBase } from "tnt-core/src/BlueprintServiceManagerBase.sol";

contract MyBlueprint is BlueprintServiceManagerBase {
    function onRequest(
        uint64 requestId,
        address requester,
        address[] calldata operators,
        bytes calldata requestInputs,
        uint64 ttl,
        address paymentAsset,
        uint256 paymentAmount
    ) external payable override onlyFromTangle {
        // Validate service configuration
        require(operators.length >= 3, "Need at least 3 operators");
        // Custom logic here
    }

    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        address operator,
        bytes calldata inputs,
        bytes calldata outputs
    ) external payable override onlyFromTangle {
        // Process job results, verify outputs, distribute rewards
    }

    // Optional: customize subscription non-payment grace policy.
    // Default protocol behavior is one extra interval.
    function getNonPaymentTerminationPolicy(uint64)
        external
        pure
        override
        returns (bool useDefault, uint64 graceIntervals)
    {
        return (false, 2); // wait 2 extra intervals
    }
}
```

## Core Contracts

### Service Layer
| Contract | Description |
|----------|-------------|
| `Tangle.sol` | Main entry point - composes all protocol functionality |
| `BlueprintServiceManagerBase.sol` | Base contract for custom blueprints |
| `MasterBlueprintServiceManager.sol` | Protocol-wide blueprint registry |
| `MBSMRegistry.sol` | Versioned MBSM management |

### Staking Layer
| Contract | Description |
|----------|-------------|
| `MultiAssetDelegation.sol` | Multi-asset staking with O(1) share accounting |
| `LiquidDelegationVault.sol` | ERC-7540 vault for liquid staking |
| `OperatorStatusRegistry.sol` | Operator liveness tracking |

### Key Interfaces
| Interface | Description |
|-----------|-------------|
| `ITangle.sol` | Full Tangle interface |
| `IBlueprintServiceManager.sol` | Blueprint hook interface |
| `IMultiAssetDelegation.sol` | Staking interface |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Tangle                               │
│  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────────┐  │
│  │Blueprints│ │ Services │ │   Jobs   │ │    Slashing     │  │
│  └─────────┘ └──────────┘ └──────────┘ └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  MultiAssetDelegation                        │
│  ┌─────────┐ ┌──────────┐ ┌──────────┐ ┌─────────────────┐  │
│  │Operators │ │ Deposits │ │Delegations│ │    Slashing     │  │
│  └─────────┘ └──────────┘ └──────────┘ └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Blueprint Service Managers                      │
│         (Your custom service logic goes here)                │
└─────────────────────────────────────────────────────────────┘
```

## Blueprint Lifecycle

1. **Create Blueprint** - Developer deploys BSM and registers with Tangle
2. **Operators Register** - Operators stake and register to serve the blueprint
3. **Request Service** - Users request service instances with payment
4. **Operators Approve** - Required operators approve the request
5. **Service Active** - Jobs can be submitted and processed
6. **Results & Rewards** - Operators submit results, rewards distributed

## Payment Models

- **PayOnce** - Single upfront payment
- **Subscription** - Recurring billing from escrow
- **EventBased** - Pay per job/event

## Documentation

- [Deployment Guide](https://github.com/tangle-network/tnt-core/blob/main/docs/DEPLOYMENT_RUNBOOK.md)
- [Full Deploy Config](https://github.com/tangle-network/tnt-core/blob/main/docs/full-deploy.md)
- [Pricing Models](https://github.com/tangle-network/tnt-core/blob/main/docs/PRICING.md)
- [Interfaces](https://github.com/tangle-network/tnt-core/tree/main/src/interfaces)

## Rust Bindings

```bash
cargo add tnt-core-bindings
```

See [crates.io/crates/tnt-core-bindings](https://crates.io/crates/tnt-core-bindings)

## Key Concepts

- **Blueprint**: A specification for a verifiable, decentralized service on Tangle Network. Blueprints define jobs, verification logic, and slashing conditions through on-chain smart contracts.
- **Operator**: A node runner who registers to provide services defined by a Blueprint. Operators stake assets via MultiAssetDelegation and earn rewards for honest execution.
- **TNT**: The native token of Tangle Network, used for staking, governance, and payment settlement.
- **Slashing**: The penalty mechanism that deducts staked assets from operators who misbehave or fail to perform their duties. Each Blueprint Service Manager defines its own slashing rules.
- **x402**: An HTTP-native payment protocol (HTTP 402 Payment Required) that enables per-request micropayments for Blueprint services, with on-chain settlement through TNT Core contracts.
- **MultiAssetDelegation**: The core staking contract that manages operator deposits, delegator stakes, and asset accounting across multiple ERC-20 tokens.
- **BlueprintServiceManagerBase**: The base contract that Blueprint developers extend to define custom service logic, including request handling (`onRequest`), result processing (`onJobResult`), and termination policies.

## FAQ

### What is TNT Core?
**TNT Core** is the on-chain smart contract protocol that powers Tangle Network's staking, delegation, and service management system. It is written in Solidity and deployed on Tangle's EVM-compatible chain.

### What assets can be staked?
TNT Core supports **multi-asset staking** through the MultiAssetDelegation contract. Operators and delegators can stake various ERC-20 tokens, not just the native TNT token. Each Blueprint can specify which assets it accepts.

### How does slashing work?
When an operator misbehaves or fails to perform their duties, the **BlueprintServiceManager** can slash their staked assets according to predefined rules. Slashing conditions are defined per-Blueprint and enforced through the MasterBlueprintServiceManager.

### What payment models are available?
TNT Core supports three payment models: **PayOnce** (one-time payment at service creation), **Subscription** (recurring payments), and **EventBased** (pay per event or job execution). These are configured in the Blueprint's pricing contract.

### How do I build a custom Blueprint with TNT Core?
Extend `BlueprintServiceManagerBase` in Solidity and implement the `onRequest` and `onJobResult` hooks. Install TNT Core via `forge soldeer install tnt-core~0.10.4` and import the base contract. See the Quick Start section above for a working example.

## License

MIT
