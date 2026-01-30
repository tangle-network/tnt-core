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
    localtestnet_broadcast_json, localtestnet_state_json, write_localtestnet_fixtures,
    LOCALTESTNET_STATE_JSON, LOCALTESTNET_STATE_FILENAME,
};

let state = localtestnet_state_json();
let broadcast = localtestnet_broadcast_json();
let _raw = LOCALTESTNET_STATE_JSON;

// Example: write to disk for anvil --load-state.
std::fs::write(LOCALTESTNET_STATE_FILENAME, state)?;
std::fs::write("localtestnet-broadcast.json", broadcast)?;

// Example: write both fixtures to a directory.
let _paths = write_localtestnet_fixtures("./fixtures")?;
# Ok::<(), std::io::Error>(())
```
