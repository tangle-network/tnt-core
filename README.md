# TNT Core

Tangle Network's EVM-native staking and service blueprint protocol. Build decentralized services with customizable operator networks, multi-asset staking, and flexible payment models.

## Installation

```bash
forge soldeer install tnt-core~0.8.0
```

Or add to `foundry.toml`:
```toml
[dependencies]
tnt-core = "0.8.0"
```

## Quick Start

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

- [Architecture Deep Dive](https://github.com/tangle-network/tnt-core/tree/main/architecture)
- [Deployment Guide](https://github.com/tangle-network/tnt-core/blob/main/DEPLOYMENT_RUNBOOK.md)
- [API Reference](https://github.com/tangle-network/tnt-core/tree/main/src/interfaces)

## Rust Bindings

```bash
cargo add tnt-core-bindings
```

See [crates.io/crates/tnt-core-bindings](https://crates.io/crates/tnt-core-bindings)

## License

MIT
