# TNT Core Fixtures

This crate packages the LocalTestnet fixtures (Anvil state snapshot and the
deployment broadcast) used for deterministic local testing.

Update the fixtures by running:

```bash
./scripts/update-localtestnet-fixtures.sh
```

## Usage

```rust
use tnt_core_fixtures::{
    localtestnet_broadcast_json, localtestnet_state_json, LOCALTESTNET_STATE_JSON,
};

let state = localtestnet_state_json();
let broadcast = localtestnet_broadcast_json();
let _raw = LOCALTESTNET_STATE_JSON;

// Example: write to disk for anvil --load-state.
std::fs::write("localtestnet-state.json", state)?;
std::fs::write("localtestnet-broadcast.json", broadcast)?;
# Ok::<(), std::io::Error>(())
```
