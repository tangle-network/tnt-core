use alloy_primitives::{Bytes, FixedBytes};
use alloy_sol_types::{sol, SolCall};
use sp1_sdk::{network::NetworkMode, Prover, ProverClient, SP1Stdin};
use sr25519_claim_lib::{ss58_decode, ProgramInput, PublicValues};
use std::time::Duration;
use tracing::info;

use crate::types::{ClaimContractConfig, ProveRequest, VerifyOnchainConfig};
use crate::validation::parse_hex_bytes;

const ELF: &[u8] = include_bytes!("../../program/elf/riscv32im-succinct-zkvm-elf");

sol! {
    function verifyProof(bytes32 programVKey, bytes publicValues, bytes proofBytes) external view;
    function claimed(bytes32 pubkey) external view returns (uint256);
}

/// Generate a ZK proof for the given request
///
/// # Arguments
/// * `request` - The proof request containing signature and claim details
/// * `verify_proof` - Whether to verify the proof after generation
/// * `verify_onchain` - Optional on-chain verification config
/// * `prover_mode` - The prover mode: "mock", "local", or "network"
pub fn generate_proof(
    request: ProveRequest,
    verify_proof: bool,
    verify_onchain: Option<VerifyOnchainConfig>,
    prover_mode: &str,
) -> Result<(String, String), String> {
    let signature = parse_hex_bytes::<64>(&request.signature).map_err(err_to_string)?;
    let evm_address = parse_hex_bytes::<20>(&request.evm_address).map_err(err_to_string)?;
    let challenge = parse_hex_bytes::<32>(&request.challenge).map_err(err_to_string)?;
    let amount = crate::validation::parse_amount(&request.amount).map_err(err_to_string)?;
    let ss58_address = request.ss58_address;

    let input = ProgramInput {
        substrate_address: ss58_address.clone(),
        signature,
        evm_address,
        amount,
        challenge,
    };

    let mut stdin = SP1Stdin::new();
    stdin.write(&input);

    // Generate proof based on configured mode
    // For network mode, we must explicitly use Mainnet - from_env() defaults to Reserved
    // which has an invalid domain for the mainnet network
    let (proof, _vk) = match prover_mode {
        "mock" => {
            info!("Using SP1 mock prover (test mode)");
            std::env::set_var("SP1_PROVER", "mock");
            let client = ProverClient::from_env();
            let (pk, vk) = client.setup(ELF);
            let proof = client
                .prove(&pk, &stdin)
                .groth16()
                .run()
                .map_err(err_to_string)?;
            if verify_proof {
                client.verify(&proof, &vk).map_err(err_to_string)?;
            }
            (proof, vk)
        }
        "local" => {
            info!("Using SP1 local prover");
            std::env::set_var("SP1_PROVER", "local");
            let client = ProverClient::from_env();
            let (pk, vk) = client.setup(ELF);
            let proof = client
                .prove(&pk, &stdin)
                .groth16()
                .run()
                .map_err(err_to_string)?;
            if verify_proof {
                client.verify(&proof, &vk).map_err(err_to_string)?;
            }
            (proof, vk)
        }
        _ => {
            info!("Using SP1 network prover (mainnet)");
            // Explicitly use Mainnet mode - from_env() defaults to Reserved
            // which has an invalid domain for the mainnet network
            let client = ProverClient::builder()
                .network_for(NetworkMode::Mainnet)
                .build();
            let (pk, vk) = client.setup(ELF);
            let proof = client
                .prove(&pk, &stdin)
                .groth16()
                .run()
                .map_err(err_to_string)?;
            if verify_proof {
                client.verify(&proof, &vk).map_err(err_to_string)?;
            }
            (proof, vk)
        }
    };

    // Log the committed public values for debugging
    let committed_public_values = proof.public_values.to_vec();
    info!(
        "Committed public values (hex): 0x{}",
        hex::encode(&committed_public_values)
    );
    info!(
        "Committed public values length: {} bytes",
        committed_public_values.len()
    );

    // Decode and log the individual fields
    if let Ok(decoded) = PublicValues::abi_decode(&committed_public_values) {
        info!("Decoded pubkey: 0x{}", hex::encode(&decoded.pubkey));
        info!(
            "Decoded evm_address: 0x{}",
            hex::encode(&decoded.evm_address)
        );
        info!("Decoded amount: 0x{}", hex::encode(&decoded.amount));
        info!("Decoded challenge: 0x{}", hex::encode(&decoded.challenge));
    }

    let proof_bytes = proof.bytes();

    if let Some(config) = verify_onchain {
        let pubkey = ss58_decode(&ss58_address).map_err(err_to_string)?;
        let public_values = PublicValues {
            pubkey,
            evm_address,
            amount,
            challenge,
        };
        verify_onchain_proof(&config, public_values, proof_bytes.clone())
            .map_err(|err| format!("On-chain verify failed: {err}"))?;
    }

    let proof_hex = format!("0x{}", hex::encode(proof_bytes));
    let public_values_hex = format!("0x{}", hex::encode(&committed_public_values));
    Ok((proof_hex, public_values_hex))
}

/// Verify a proof on-chain using eth_call
fn verify_onchain_proof(
    config: &VerifyOnchainConfig,
    public_values: PublicValues,
    proof: Vec<u8>,
) -> Result<(), String> {
    let call = verifyProofCall {
        programVKey: FixedBytes::<32>::from_slice(&config.program_vkey),
        publicValues: Bytes::from(public_values.abi_encode()),
        proofBytes: Bytes::from(proof),
    };
    let data = format!("0x{}", hex::encode(call.abi_encode()));
    let to = format!("0x{}", hex::encode(config.verifier_address));

    let payload = serde_json::json!({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "eth_call",
        "params": [
            { "to": to, "data": data },
            "latest"
        ]
    });

    let client = reqwest::blocking::Client::builder()
        .timeout(Duration::from_secs(config.timeout_seconds))
        .build()
        .map_err(err_to_string)?;

    let response = client
        .post(&config.rpc_url)
        .json(&payload)
        .send()
        .map_err(err_to_string)?;

    let status = response.status();
    let body: serde_json::Value = response.json().map_err(err_to_string)?;
    if !status.is_success() {
        return Err(format!("RPC HTTP error {status}"));
    }

    if let Some(error) = body.get("error") {
        return Err(format!("eth_call reverted: {error}"));
    }

    if body.get("result").is_none() {
        return Err("Missing eth_call result".to_string());
    }

    Ok(())
}

/// Check if a user has already claimed tokens on-chain
pub async fn check_already_claimed(
    config: &ClaimContractConfig,
    ss58_address: &str,
    timeout_seconds: u64,
) -> Result<bool, String> {
    // Decode SS58 to get the 32-byte pubkey
    let pubkey = ss58_decode(ss58_address).map_err(err_to_string)?;

    // Build the eth_call for claimed(bytes32)
    let call = claimedCall {
        pubkey: FixedBytes::<32>::from_slice(&pubkey),
    };
    let data = format!("0x{}", hex::encode(call.abi_encode()));
    let to = format!("0x{}", hex::encode(config.contract_address));

    let payload = serde_json::json!({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "eth_call",
        "params": [
            { "to": to, "data": data },
            "latest"
        ]
    });

    let client = reqwest::Client::builder()
        .timeout(Duration::from_secs(timeout_seconds))
        .build()
        .map_err(err_to_string)?;

    let response = client
        .post(&config.rpc_url)
        .json(&payload)
        .send()
        .await
        .map_err(err_to_string)?;

    let status = response.status();
    let body: serde_json::Value = response.json().await.map_err(err_to_string)?;

    if !status.is_success() {
        return Err(format!("RPC HTTP error {status}"));
    }

    if let Some(error) = body.get("error") {
        return Err(format!("eth_call error: {error}"));
    }

    let result = body
        .get("result")
        .and_then(|v| v.as_str())
        .ok_or("Missing eth_call result")?;

    // Parse the returned uint256 - if > 0, user has claimed
    let result_bytes = hex::decode(result.strip_prefix("0x").unwrap_or(result))
        .map_err(|e| format!("Invalid hex result: {e}"))?;

    // uint256 is 32 bytes, check if any byte is non-zero
    let claimed_amount = result_bytes.iter().any(|&b| b != 0);

    Ok(claimed_amount)
}

fn err_to_string(err: impl std::fmt::Display) -> String {
    err.to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use httpmock::{Method::POST, MockServer};
    use serde_json::json;

    // Note: These tests require the SP1 SDK which is not available in unit tests
    // Integration tests should be used for actual proof generation

    #[test]
    fn test_elf_is_loaded() {
        // Just verify the ELF is included
        assert!(!ELF.is_empty());
    }

    #[test]
    fn test_verify_onchain_proof_success() {
        let server = MockServer::start();
        let mock = server.mock(|when, then| {
            when.method(POST);
            then.status(200).json_body(json!({"result": "0x1"}));
        });

        let config = VerifyOnchainConfig {
            rpc_url: server.url("/"),
            verifier_address: [0x11; 20],
            program_vkey: [0x22; 32],
            timeout_seconds: 5,
        };

        let public_values = PublicValues {
            pubkey: [0x33; 32],
            evm_address: [0x44; 20],
            amount: [0x55; 32],
            challenge: [0x66; 32],
        };

        let result = verify_onchain_proof(&config, public_values, vec![0xaa, 0xbb]);
        assert!(result.is_ok());
        mock.assert();
    }

    #[test]
    fn test_verify_onchain_proof_reverted() {
        let server = MockServer::start();
        let mock = server.mock(|when, then| {
            when.method(POST);
            then.status(200)
                .json_body(json!({"error": {"code": -32000, "message": "revert"}}));
        });

        let config = VerifyOnchainConfig {
            rpc_url: server.url("/"),
            verifier_address: [0x11; 20],
            program_vkey: [0x22; 32],
            timeout_seconds: 5,
        };

        let public_values = PublicValues {
            pubkey: [0x33; 32],
            evm_address: [0x44; 20],
            amount: [0x55; 32],
            challenge: [0x66; 32],
        };

        let err = verify_onchain_proof(&config, public_values, vec![0xaa, 0xbb])
            .expect_err("expected eth_call error");
        assert!(err.contains("eth_call reverted"));
        mock.assert();
    }

    #[tokio::test]
    async fn test_check_already_claimed_true_false() {
        let ss58_address = "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY";

        let claimed_server = MockServer::start();
        let claimed_mock = claimed_server.mock(|when, then| {
            when.method(POST);
            then.status(200)
                .json_body(json!({"result": format!("0x{}01", "00".repeat(31))}));
        });
        let claimed_config = ClaimContractConfig {
            rpc_url: claimed_server.url("/"),
            contract_address: [0x12; 20],
        };
        let claimed = check_already_claimed(&claimed_config, ss58_address, 5)
            .await
            .unwrap();
        assert!(claimed);
        claimed_mock.assert();

        let unclaimed_server = MockServer::start();
        let unclaimed_mock = unclaimed_server.mock(|when, then| {
            when.method(POST);
            then.status(200)
                .json_body(json!({"result": format!("0x{}", "00".repeat(32))}));
        });
        let unclaimed_config = ClaimContractConfig {
            rpc_url: unclaimed_server.url("/"),
            contract_address: [0x12; 20],
        };
        let claimed = check_already_claimed(&unclaimed_config, ss58_address, 5)
            .await
            .unwrap();
        assert!(!claimed);
        unclaimed_mock.assert();
    }
}
