//! Local testnet fixture data for TNT Core.

/// Raw JSON for the LocalTestnet anvil state snapshot.
pub const LOCALTESTNET_STATE_JSON: &str = include_str!("../fixtures/localtestnet-state.json");

/// Raw JSON for the LocalTestnet deployment broadcast.
pub const LOCALTESTNET_BROADCAST_JSON: &str = include_str!("../fixtures/localtestnet-broadcast.json");

/// Returns the LocalTestnet state snapshot JSON.
pub fn localtestnet_state_json() -> &'static str {
    LOCALTESTNET_STATE_JSON
}

/// Returns the LocalTestnet broadcast JSON.
pub fn localtestnet_broadcast_json() -> &'static str {
    LOCALTESTNET_BROADCAST_JSON
}
