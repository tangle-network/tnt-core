//! Local testnet fixture data for TNT Core.

use std::io;
use std::path::{Path, PathBuf};

/// Default filename for the LocalTestnet state snapshot.
pub const LOCALTESTNET_STATE_FILENAME: &str = "localtestnet-state.json";

/// Default filename for the LocalTestnet broadcast snapshot.
pub const LOCALTESTNET_BROADCAST_FILENAME: &str = "localtestnet-broadcast.json";

/// Raw JSON for the LocalTestnet anvil state snapshot.
pub const LOCALTESTNET_STATE_JSON: &str = include_str!("../fixtures/localtestnet-state.json");

/// Raw JSON for the LocalTestnet deployment broadcast.
pub const LOCALTESTNET_BROADCAST_JSON: &str = include_str!("../fixtures/localtestnet-broadcast.json");

/// Returns the LocalTestnet state snapshot JSON.
pub fn localtestnet_state_json() -> &'static str {
    LOCALTESTNET_STATE_JSON
}

/// Returns the LocalTestnet state snapshot JSON as bytes.
pub fn localtestnet_state_bytes() -> &'static [u8] {
    LOCALTESTNET_STATE_JSON.as_bytes()
}

/// Returns the LocalTestnet broadcast JSON.
pub fn localtestnet_broadcast_json() -> &'static str {
    LOCALTESTNET_BROADCAST_JSON
}

/// Returns the LocalTestnet broadcast JSON as bytes.
pub fn localtestnet_broadcast_bytes() -> &'static [u8] {
    LOCALTESTNET_BROADCAST_JSON.as_bytes()
}

/// Writes both fixtures to disk using the default filenames.
pub fn write_localtestnet_fixtures<P: AsRef<Path>>(dir: P) -> io::Result<(PathBuf, PathBuf)> {
    let dir = dir.as_ref();
    std::fs::create_dir_all(dir)?;

    let state_path = dir.join(LOCALTESTNET_STATE_FILENAME);
    let broadcast_path = dir.join(LOCALTESTNET_BROADCAST_FILENAME);

    std::fs::write(&state_path, LOCALTESTNET_STATE_JSON)?;
    std::fs::write(&broadcast_path, LOCALTESTNET_BROADCAST_JSON)?;

    Ok((state_path, broadcast_path))
}
