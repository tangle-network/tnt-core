use std::env;

use crate::types::{AppConfig, ClaimContractConfig, VerifyOnchainConfig};
use crate::validation::parse_hex_bytes;

/// Load configuration from environment variables
pub fn load_config() -> Result<AppConfig, String> {
    let prover_mode = env::var("SP1_PROVER").unwrap_or_else(|_| "network".to_string());
    let allow_mock = env::var("ALLOW_MOCK")
        .map(|value| value == "true")
        .unwrap_or(false);

    // Validate prover mode
    if prover_mode == "mock" && !allow_mock {
        return Err("SP1_PROVER=mock is disabled. Set ALLOW_MOCK=true to enable.".to_string());
    }

    if prover_mode == "network" && env::var("NETWORK_PRIVATE_KEY").is_err() {
        return Err("NETWORK_PRIVATE_KEY is required when SP1_PROVER=network.".to_string());
    }

    // Parse verify settings
    let verify_proof = env::var("VERIFY_PROOF")
        .map(|value| value == "true")
        .unwrap_or(false);

    let verify_onchain = env::var("VERIFY_ONCHAIN")
        .map(|value| value == "true")
        .unwrap_or(false);

    // Enforce verification in production (SP1_PROVER=network)
    if prover_mode == "network" && !verify_proof {
        return Err(
            "VERIFY_PROOF=true is required when SP1_PROVER=network for production safety."
                .to_string(),
        );
    }

    // Parse on-chain verification config
    let verify_onchain_config = if verify_onchain {
        let rpc_url = env::var("VERIFY_ONCHAIN_RPC_URL")
            .or_else(|_| env::var("RPC_URL"))
            .unwrap_or_else(|_| "http://localhost:8545".to_string());

        let verifier_address = env::var("SP1_VERIFIER_ADDRESS")
            .unwrap_or_else(|_| "0x397A5f7f3dBd538f23DE225B51f532c34448dA9B".to_string());

        let program_vkey = env::var("SP1_PROGRAM_VKEY")
            .map_err(|_| "SP1_PROGRAM_VKEY is required when VERIFY_ONCHAIN=true")?;

        let program_vkey = parse_hex_bytes::<32>(&program_vkey)
            .map_err(|e| format!("Invalid SP1_PROGRAM_VKEY: {e}"))?;

        let verifier_bytes = parse_hex_bytes::<20>(&verifier_address)
            .map_err(|e| format!("Invalid SP1_VERIFIER_ADDRESS: {e}"))?;

        Some(VerifyOnchainConfig {
            rpc_url,
            verifier_address: verifier_bytes,
            program_vkey,
        })
    } else {
        None
    };

    // Parse claim contract config
    let claim_contract = match env::var("CLAIM_CONTRACT_ADDRESS") {
        Ok(address) => {
            let rpc_url = env::var("CLAIM_CONTRACT_RPC_URL")
                .or_else(|_| env::var("VERIFY_ONCHAIN_RPC_URL"))
                .or_else(|_| env::var("RPC_URL"))
                .unwrap_or_else(|_| "http://localhost:8545".to_string());

            let contract_bytes = parse_hex_bytes::<20>(&address)
                .map_err(|e| format!("Invalid CLAIM_CONTRACT_ADDRESS: {e}"))?;

            Some(ClaimContractConfig {
                rpc_url,
                contract_address: contract_bytes,
            })
        }
        Err(_) => None,
    };

    // Parse numeric settings with defaults
    let cache_ttl_seconds = env::var("CACHE_TTL_SECONDS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(3600); // 1 hour - proofs are deterministic and expensive

    let rate_limit_window_seconds = env::var("RATE_LIMIT_WINDOW_SECONDS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(300); // 5 minutes

    let rate_limit_max_requests = env::var("RATE_LIMIT_MAX_REQUESTS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(3);

    let queue_capacity = env::var("QUEUE_CAPACITY")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(50); // ~1 hour max wait with 4 workers

    let worker_count = env::var("WORKER_COUNT")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(4);

    let proof_timeout_seconds = env::var("PROOF_TIMEOUT_SECONDS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(600); // 10 minutes

    let rpc_timeout_seconds = env::var("RPC_TIMEOUT_SECONDS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(10);

    let max_body_bytes = env::var("MAX_BODY_BYTES")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(4096); // 4 KB

    let jobs_ttl_seconds = env::var("JOBS_TTL_SECONDS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(3600); // 1 hour - let users come back for their proof

    // IP-based rate limiting (separate from pubkey rate limiting)
    let ip_rate_limit_window_seconds = env::var("IP_RATE_LIMIT_WINDOW_SECONDS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(60); // 1 minute

    let ip_rate_limit_max_requests = env::var("IP_RATE_LIMIT_MAX_REQUESTS")
        .ok()
        .and_then(|v| v.parse().ok())
        .unwrap_or(10); // 10 requests per minute per IP

    // Eligibility file path (default works for local dev, Dockerfile overrides for production)
    let eligibility_file = env::var("ELIGIBILITY_FILE")
        .unwrap_or_else(|_| "../merkle-tree.json".to_string());

    // Signature verification (enabled by default, can be disabled for testing)
    let verify_signatures = env::var("VERIFY_SIGNATURES")
        .map(|v| v != "false")
        .unwrap_or(true);

    Ok(AppConfig {
        prover_mode,
        verify_proof,
        verify_onchain: verify_onchain_config,
        claim_contract,
        cache_ttl_seconds,
        rate_limit_window_seconds,
        rate_limit_max_requests,
        ip_rate_limit_window_seconds,
        ip_rate_limit_max_requests,
        queue_capacity,
        worker_count,
        proof_timeout_seconds,
        rpc_timeout_seconds,
        max_body_bytes,
        jobs_ttl_seconds,
        eligibility_file,
        verify_signatures,
    })
}

/// Validate CORS configuration
pub fn validate_cors(prover_mode: &str) -> Result<Option<String>, String> {
    let cors_origins = env::var("CORS_ALLOWED_ORIGINS").ok();

    match &cors_origins {
        Some(origins) if !origins.is_empty() => {
            let trimmed = origins.trim();

            // Handle wildcard - return None to use Any mode
            if trimmed == "*" {
                return Ok(None);
            }

            // Validate that origins are parseable
            let valid: Vec<_> = origins
                .split(',')
                .filter_map(|s| {
                    let trimmed = s.trim();
                    if trimmed.is_empty() {
                        None
                    } else {
                        Some(trimmed.to_string())
                    }
                })
                .collect();

            if valid.is_empty() {
                return Err("CORS_ALLOWED_ORIGINS contains no valid origins".to_string());
            }

            Ok(Some(origins.clone()))
        }
        _ if prover_mode == "network" => {
            Err("CORS_ALLOWED_ORIGINS is required when SP1_PROVER=network".to_string())
        }
        _ => Ok(None), // Allow all origins for local/mock testing
    }
}

/// Get the port from environment
pub fn get_port() -> u16 {
    env::var("PORT")
        .ok()
        .and_then(|value| value.parse().ok())
        .unwrap_or(8080)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;

    // Note: These tests modify environment variables so they should be run serially
    // In practice, you'd use a test framework that handles this

    #[allow(dead_code)]
    fn clear_env_vars() {
        env::remove_var("SP1_PROVER");
        env::remove_var("ALLOW_MOCK");
        env::remove_var("NETWORK_PRIVATE_KEY");
        env::remove_var("VERIFY_PROOF");
        env::remove_var("VERIFY_ONCHAIN");
        env::remove_var("CORS_ALLOWED_ORIGINS");
        env::remove_var("CLAIM_CONTRACT_ADDRESS");
        env::remove_var("SP1_PROGRAM_VKEY");
        env::remove_var("CACHE_TTL_SECONDS");
        env::remove_var("RATE_LIMIT_WINDOW_SECONDS");
        env::remove_var("RATE_LIMIT_MAX_REQUESTS");
        env::remove_var("QUEUE_CAPACITY");
        env::remove_var("WORKER_COUNT");
        env::remove_var("PROOF_TIMEOUT_SECONDS");
        env::remove_var("RPC_TIMEOUT_SECONDS");
    }

    // These tests use the same env var so must be run together to avoid race conditions
    #[test]
    fn test_validate_cors_all_cases() {
        // Allow all origins in mock mode (no env var)
        env::remove_var("CORS_ALLOWED_ORIGINS");
        let result = validate_cors("mock");
        assert!(result.is_ok(), "mock mode should allow no CORS config");

        // Required in network/production mode
        let result = validate_cors("network");
        assert!(result.is_err(), "network mode should require CORS config");
        assert!(result.unwrap_err().contains("CORS_ALLOWED_ORIGINS"));

        // Empty origins not allowed
        env::set_var("CORS_ALLOWED_ORIGINS", "   ");
        let result = validate_cors("network");
        assert!(result.is_err(), "empty origins should be rejected");

        // Valid origins work
        env::set_var("CORS_ALLOWED_ORIGINS", "http://localhost:3000");
        let result = validate_cors("network");
        assert!(result.is_ok(), "valid origins should work");

        // Cleanup
        env::remove_var("CORS_ALLOWED_ORIGINS");
    }

    // These tests use the same env var so must be run together to avoid race conditions
    #[test]
    fn test_get_port_all_cases() {
        // Default case
        env::remove_var("PORT");
        assert_eq!(get_port(), 8080, "default port should be 8080");

        // Custom valid port
        env::set_var("PORT", "9000");
        assert_eq!(get_port(), 9000, "custom port should work");

        // Invalid port uses default
        env::set_var("PORT", "not_a_number");
        assert_eq!(get_port(), 8080, "invalid port should use default");

        // Cleanup
        env::remove_var("PORT");
    }
}
