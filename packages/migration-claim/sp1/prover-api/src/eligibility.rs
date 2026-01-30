//! Eligibility data loading and verification
//!
//! Loads the merkle tree JSON file at startup and provides O(1) lookup
//! to check if a public key is eligible for migration claims.
//!
//! Uses pubkey-based lookup to handle SS58 addresses with different network prefixes.

use alloy_primitives::U256;
use serde::Deserialize;
use std::collections::HashMap;
use std::fs;
use tracing::info;

/// Entry in the merkle tree for an eligible address
#[derive(Debug, Clone)]
pub struct EligibilityEntry {
    /// Eligible balance in wei
    pub balance: U256,
}

/// Eligibility data loaded from merkle-tree.json
pub struct EligibilityData {
    /// Entries keyed by lowercase hex pubkey (e.g., "0xabcd...") for O(1) lookup
    /// This handles SS58 addresses with different network prefixes correctly
    entries_by_pubkey: HashMap<String, EligibilityEntry>,
}

/// JSON structure for parsing merkle-tree.json
#[derive(Deserialize)]
struct MerkleTreeJson {
    /// Entries by pubkey (preferred for lookup - handles different SS58 prefixes)
    #[serde(rename = "entriesByPubkey")]
    entries_by_pubkey: Option<HashMap<String, MerkleEntryByPubkeyJson>>,
    /// Entries by SS58 address (fallback if entriesByPubkey not present)
    entries: HashMap<String, MerkleEntryJson>,
}

/// JSON structure for individual merkle tree entries (by SS58)
#[derive(Deserialize)]
struct MerkleEntryJson {
    balance: String,
    /// Pubkey in hex format (lowercase, with 0x prefix)
    pubkey: Option<String>,
}

/// JSON structure for entries by pubkey
#[derive(Deserialize)]
struct MerkleEntryByPubkeyJson {
    balance: String,
}

impl EligibilityData {
    /// Load eligibility data from a merkle-tree.json file
    ///
    /// Prefers `entriesByPubkey` for lookup (handles different SS58 prefixes).
    /// Falls back to `entries` if `entriesByPubkey` is not present.
    ///
    /// # Arguments
    /// * `path` - Path to the merkle-tree.json file
    ///
    /// # Returns
    /// * `Ok(EligibilityData)` - Loaded eligibility data
    /// * `Err(String)` - Error message if loading fails
    pub fn load_from_file(path: &str) -> Result<Self, String> {
        // Read file
        let content = fs::read_to_string(path)
            .map_err(|e| format!("Failed to read eligibility file '{}': {}", path, e))?;

        // Parse JSON
        let merkle_tree: MerkleTreeJson = serde_json::from_str(&content)
            .map_err(|e| format!("Failed to parse eligibility JSON: {}", e))?;

        let mut entries_by_pubkey = HashMap::new();

        // Prefer entriesByPubkey if available (already keyed by pubkey)
        if let Some(by_pubkey) = merkle_tree.entries_by_pubkey {
            for (pubkey, entry) in by_pubkey {
                let balance = U256::from_str_radix(&entry.balance, 10).map_err(|e| {
                    format!(
                        "Invalid balance for pubkey '{}': {} (value: {})",
                        pubkey, e, entry.balance
                    )
                })?;

                // Normalize pubkey to lowercase
                let normalized_pubkey = pubkey.to_lowercase();
                entries_by_pubkey.insert(normalized_pubkey, EligibilityEntry { balance });
            }

            info!(
                "Loaded {} eligible addresses (by pubkey)",
                entries_by_pubkey.len()
            );
        } else {
            // Fallback: use entries and extract pubkey from each entry
            for (ss58_address, entry) in merkle_tree.entries {
                let balance = U256::from_str_radix(&entry.balance, 10).map_err(|e| {
                    format!(
                        "Invalid balance for address '{}': {} (value: {})",
                        ss58_address, e, entry.balance
                    )
                })?;

                // Get pubkey from entry or skip if not available
                if let Some(pubkey) = entry.pubkey {
                    let normalized_pubkey = pubkey.to_lowercase();
                    entries_by_pubkey.insert(normalized_pubkey, EligibilityEntry { balance });
                }
            }

            info!(
                "Loaded {} eligible addresses (from entries with pubkey)",
                entries_by_pubkey.len()
            );
        }

        Ok(Self { entries_by_pubkey })
    }

    /// Check if a public key is eligible
    ///
    /// # Arguments
    /// * `pubkey` - 32-byte public key
    #[inline]
    pub fn is_eligible_by_pubkey(&self, pubkey: &[u8; 32]) -> bool {
        let hex_pubkey = format!("0x{}", hex::encode(pubkey));
        self.entries_by_pubkey.contains_key(&hex_pubkey)
    }

    /// Verify that the requested amount matches the eligible balance
    ///
    /// # Arguments
    /// * `pubkey` - 32-byte public key
    /// * `amount` - Requested amount
    ///
    /// Returns true if the pubkey is eligible AND the amount matches exactly.
    pub fn verify_amount_by_pubkey(&self, pubkey: &[u8; 32], amount: &U256) -> bool {
        let hex_pubkey = format!("0x{}", hex::encode(pubkey));
        self.entries_by_pubkey
            .get(&hex_pubkey)
            .map(|entry| &entry.balance == amount)
            .unwrap_or(false)
    }

    /// Get the number of eligible addresses
    #[inline]
    pub fn entry_count(&self) -> usize {
        self.entries_by_pubkey.len()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_eligibility_data_lookup() {
        let mut entries_by_pubkey = HashMap::new();
        // Test pubkey (32 bytes of 0xab)
        let test_pubkey = [0xab; 32];
        let hex_pubkey = format!("0x{}", hex::encode(test_pubkey));

        entries_by_pubkey.insert(
            hex_pubkey,
            EligibilityEntry {
                balance: U256::from(1000u64),
            },
        );

        let data = EligibilityData { entries_by_pubkey };

        assert!(data.is_eligible_by_pubkey(&test_pubkey));
        assert!(!data.is_eligible_by_pubkey(&[0xcd; 32])); // Different pubkey
    }

    #[test]
    fn test_verify_amount() {
        let mut entries_by_pubkey = HashMap::new();
        let test_pubkey = [0xab; 32];
        let hex_pubkey = format!("0x{}", hex::encode(test_pubkey));

        entries_by_pubkey.insert(
            hex_pubkey,
            EligibilityEntry {
                balance: U256::from(1000u64),
            },
        );

        let data = EligibilityData { entries_by_pubkey };

        assert!(data.verify_amount_by_pubkey(&test_pubkey, &U256::from(1000u64)));
        assert!(!data.verify_amount_by_pubkey(&test_pubkey, &U256::from(999u64)));
        assert!(!data.verify_amount_by_pubkey(&[0xcd; 32], &U256::from(1000u64)));
    }
}
