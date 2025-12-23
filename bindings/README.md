# tnt-core-bindings

Rust bindings for [TNT Core](https://github.com/tangle-network/tnt-core) Solidity contracts, generated using [Alloy](https://github.com/alloy-rs/alloy).

## Installation

```toml
[dependencies]
tnt-core-bindings = "0.1"
```

## Usage

```rust
use alloy::providers::ProviderBuilder;
use tnt_core_bindings::{ITangle, IMultiAssetDelegation};

#[tokio::main]
async fn main() -> eyre::Result<()> {
    let provider = ProviderBuilder::new()
        .on_builtin("https://rpc.tangle.tools")
        .await?;

    // Interact with the Tangle contract
    let tangle = ITangle::new(tangle_address, &provider);
    let blueprint = tangle.getBlueprint(0.into()).call().await?;
    println!("Blueprint owner: {:?}", blueprint.owner);

    // Interact with MultiAssetDelegation interface (facet ABI)
    let mad = IMultiAssetDelegation::new(mad_address, &provider);
    let operator = mad.operators(operator_address).call().await?;
    println!("Operator stake: {:?}", operator.stake);

    Ok(())
}
```

## Available Bindings

| Contract | Description |
|----------|-------------|
| `ITangle` | Main Tangle protocol interface (blueprints, services, jobs) |
| `ITangleFull` | Full Tangle surface (includes slashing + admin) |
| `ITangleBlueprints` | Blueprint registration and management |
| `ITangleServices` | Service lifecycle management |
| `ITangleJobs` | Job submission and results |
| `ITangleOperators` | Operator registration and status |
| `ITangleSlashing` | Slashing mechanism |
| `ITangleRewards` | Reward distribution |
| `IMultiAssetDelegation` | Multi-asset restaking and delegation (facet ABI) |
| `MultiAssetDelegation` | Router/diamond management ABI |
| `IBlueprintServiceManager` | Blueprint service manager interface |
| `IOperatorStatusRegistry` | Operator status tracking |

## Raw ABIs

JSON ABIs are available for downstream tooling:

```rust
use tnt_core_bindings::abi;

// Access raw ABI JSON strings
let tangle_abi = abi::ITANGLE;
let tangle_full_abi = abi::ITANGLE_FULL;
let mad_abi = abi::IMULTI_ASSET_DELEGATION;
```

## Version Tracking

Each release is tied to a specific TNT Core commit:

```rust
use tnt_core_bindings::TNT_CORE_VERSION;

println!("Built from commit: {}", TNT_CORE_VERSION);
```

## Regenerating Bindings

To regenerate bindings from the Solidity source:

```bash
cargo xtask gen-bindings
```

This requires [Foundry](https://getfoundry.sh/) to be installed.

## License

Licensed under either of:

- Apache License, Version 2.0 ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contributing

Contributions are welcome! Please see the [main repository](https://github.com/tangle-network/tnt-core) for contribution guidelines.
