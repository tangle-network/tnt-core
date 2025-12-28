use axum::{
    extract::{Path, State},
    http::{HeaderValue, StatusCode},
    response::IntoResponse,
    routing::{get, post},
    Json, Router,
};
use alloy_primitives::{Bytes, FixedBytes};
use alloy_sol_types::{sol, SolCall};
use alloy_primitives::U256;
use serde::{Deserialize, Serialize};
use sp1_sdk::{network::NetworkMode, Prover, ProverClient, SP1Stdin};
use sr25519_claim_lib::{ss58_decode, ProgramInput, PublicValues};
use std::{
    collections::HashMap,
    env,
    sync::Arc,
    time::{SystemTime, UNIX_EPOCH},
};
use tokio::sync::Mutex;
use tower_http::cors::{Any, CorsLayer};
use tracing::{error, info};
use uuid::Uuid;

const ELF: &[u8] = include_bytes!("../../program/elf/riscv32im-succinct-zkvm-elf");

#[derive(Clone)]
struct AppState {
    jobs: Arc<Mutex<HashMap<String, JobEntry>>>,
    verify_proof: bool,
    verify_onchain: Option<VerifyOnchainConfig>,
    prover_mode: String,
}

#[derive(Clone)]
struct VerifyOnchainConfig {
    rpc_url: String,
    verifier_address: [u8; 20],
    program_vkey: [u8; 32],
}

#[derive(Clone)]
struct JobEntry {
    status: JobStatus,
    updated_at: u64,
}

#[derive(Clone)]
enum JobStatus {
    Pending,
    Running,
    Completed { zk_proof: String, public_values: String },
    Failed { error: String },
}

#[derive(Deserialize)]
struct ProveRequest {
    #[serde(rename = "ss58Address")]
    ss58_address: String,
    signature: String,
    #[serde(rename = "evmAddress")]
    evm_address: String,
    challenge: String,
    amount: String,
}

#[derive(Serialize)]
struct JobResponse {
    #[serde(rename = "jobId")]
    job_id: String,
}

#[derive(Serialize)]
struct StatusResponse {
    status: String,
    #[serde(rename = "zkProof", skip_serializing_if = "Option::is_none")]
    zk_proof: Option<String>,
    #[serde(rename = "publicValues", skip_serializing_if = "Option::is_none")]
    public_values: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<String>,
}

#[derive(Serialize)]
struct HealthResponse {
    status: String,
    prover_mode: String,
    verify_proof: bool,
    verify_onchain: bool,
    jobs: usize,
}

sol! {
    function verifyProof(bytes32 programVKey, bytes publicValues, bytes proofBytes) external view;
}

#[tokio::main]
async fn main() {
    // Install the default crypto provider for rustls (required for TLS with SP1 SDK)
    rustls::crypto::ring::default_provider()
        .install_default()
        .expect("Failed to install rustls crypto provider");

    tracing_subscriber::fmt::init();

    let port: u16 = env::var("PORT")
        .ok()
        .and_then(|value| value.parse().ok())
        .unwrap_or(8080);

    let prover_mode = env::var("SP1_PROVER").unwrap_or_else(|_| "network".to_string());
    let allow_mock = env::var("ALLOW_MOCK")
        .map(|value| value == "true")
        .unwrap_or(false);
    let verify_proof = env::var("VERIFY_PROOF")
        .map(|value| value == "true")
        .unwrap_or(false);
    let verify_onchain = env::var("VERIFY_ONCHAIN")
        .map(|value| value == "true")
        .unwrap_or(false);
    let cors_origins = env::var("CORS_ALLOWED_ORIGINS").ok();

    if prover_mode == "mock" && !allow_mock {
        error!("SP1_PROVER=mock is disabled. Set ALLOW_MOCK=true to enable.");
        std::process::exit(1);
    }

    if prover_mode == "network" && env::var("NETWORK_PRIVATE_KEY").is_err() {
        error!("NETWORK_PRIVATE_KEY is required when SP1_PROVER=network.");
        std::process::exit(1);
    }

    let verify_onchain_config = if verify_onchain {
        let rpc_url = env::var("VERIFY_ONCHAIN_RPC_URL")
            .or_else(|_| env::var("RPC_URL"))
            .unwrap_or_else(|_| "http://localhost:8545".to_string());
        let verifier_address = env::var("SP1_VERIFIER_ADDRESS")
            .unwrap_or_else(|_| "0x397A5f7f3dBd538f23DE225B51f532c34448dA9B".to_string());
        let program_vkey = env::var("SP1_PROGRAM_VKEY").unwrap_or_else(|_| {
            error!("SP1_PROGRAM_VKEY is required when VERIFY_ONCHAIN=true");
            std::process::exit(1);
        });
        let program_vkey = parse_hex_bytes::<32>(&program_vkey).unwrap_or_else(|err| {
            error!("Invalid SP1_PROGRAM_VKEY: {err}");
            std::process::exit(1);
        });
        let verifier_bytes = parse_hex_bytes::<20>(&verifier_address).unwrap_or_else(|err| {
            error!("Invalid SP1_VERIFIER_ADDRESS: {err}");
            std::process::exit(1);
        });

        Some(VerifyOnchainConfig {
            rpc_url,
            verifier_address: verifier_bytes,
            program_vkey,
        })
    } else {
        None
    };

    let state = AppState {
        jobs: Arc::new(Mutex::new(HashMap::new())),
        verify_proof,
        verify_onchain: verify_onchain_config,
        prover_mode: prover_mode.clone(),
    };

    let cors = match &cors_origins {
        Some(origins) if !origins.is_empty() => {
            let origins: Vec<HeaderValue> = origins
                .split(',')
                .filter_map(|s| s.trim().parse().ok())
                .collect();
            CorsLayer::new()
                .allow_origin(origins)
                .allow_methods(Any)
                .allow_headers(Any)
        }
        _ => CorsLayer::new()
            .allow_origin(Any)
            .allow_methods(Any)
            .allow_headers(Any),
    };

    let app = Router::new()
        .route("/", post(submit_job))
        .route("/status/:job_id", get(job_status))
        .route("/health", get(health))
        .layer(cors)
        .with_state(state);

    let cors_display = cors_origins.as_deref().unwrap_or("*");
    info!("SP1 prover API listening on 0.0.0.0:{port}");
    info!(
        "SP1_PROVER={prover_mode} VERIFY_PROOF={verify_proof} VERIFY_ONCHAIN={verify_onchain} CORS_ALLOWED_ORIGINS={cors_display}"
    );

    let listener = tokio::net::TcpListener::bind(("0.0.0.0", port))
        .await
        .expect("Failed to bind port");
    axum::serve(listener, app)
        .await
        .expect("Server error");
}

async fn submit_job(
    State(state): State<AppState>,
    Json(request): Json<ProveRequest>,
) -> Result<Json<JobResponse>, (StatusCode, Json<StatusResponse>)> {
    if request.ss58_address.trim().is_empty()
        || request.signature.trim().is_empty()
        || request.evm_address.trim().is_empty()
        || request.challenge.trim().is_empty()
        || request.amount.trim().is_empty()
    {
        return Err(bad_request("Missing required fields"));
    }

    if !is_decimal(&request.amount) {
        return Err(bad_request("Amount must be a base-10 string"));
    }

    let job_id = Uuid::new_v4().to_string();
    {
        let mut jobs = state.jobs.lock().await;
        jobs.insert(
            job_id.clone(),
            JobEntry {
                status: JobStatus::Pending,
                updated_at: now_ts(),
            },
        );
    }

    let jobs = Arc::clone(&state.jobs);
    let verify_proof = state.verify_proof;
    let verify_onchain = state.verify_onchain.clone();
    let job_id_for_response = job_id.clone();
    tokio::spawn(async move {
        update_job(&jobs, &job_id, JobStatus::Running).await;
        let result = tokio::task::spawn_blocking(move || {
            generate_proof(request, verify_proof, verify_onchain)
        })
        .await;
        match result {
            Ok(Ok((zk_proof, public_values))) => update_job(&jobs, &job_id, JobStatus::Completed { zk_proof, public_values }).await,
            Ok(Err(err)) => {
                update_job(&jobs, &job_id, JobStatus::Failed { error: err }).await
            }
            Err(err) => update_job(
                &jobs,
                &job_id,
                JobStatus::Failed {
                    error: format!("Job join error: {err}"),
                },
            )
            .await,
        }
    });

    Ok(Json(JobResponse { job_id: job_id_for_response }))
}

async fn job_status(
    State(state): State<AppState>,
    Path(job_id): Path<String>,
) -> Result<Json<StatusResponse>, (StatusCode, Json<StatusResponse>)> {
    let jobs = state.jobs.lock().await;
    let entry = jobs.get(&job_id);
    match entry {
        Some(job) => Ok(Json(status_response(&job.status))),
        None => Err((StatusCode::NOT_FOUND, Json(StatusResponse {
            status: "not_found".to_string(),
            zk_proof: None,
            public_values: None,
            error: Some("Job not found".to_string()),
        }))),
    }
}

async fn health(State(state): State<AppState>) -> impl IntoResponse {
    let jobs = state.jobs.lock().await;
    let response = HealthResponse {
        status: "ok".to_string(),
        prover_mode: state.prover_mode.clone(),
        verify_proof: state.verify_proof,
        verify_onchain: state.verify_onchain.is_some(),
        jobs: jobs.len(),
    };
    (StatusCode::OK, Json(response))
}

fn generate_proof(
    request: ProveRequest,
    verify_proof: bool,
    verify_onchain: Option<VerifyOnchainConfig>,
) -> Result<(String, String), String> {
    let signature = parse_hex_bytes::<64>(&request.signature).map_err(err_to_string)?;
    let evm_address = parse_hex_bytes::<20>(&request.evm_address).map_err(err_to_string)?;
    let challenge = parse_hex_bytes::<32>(&request.challenge).map_err(err_to_string)?;
    let amount = parse_amount(&request.amount).map_err(err_to_string)?;
    let ss58_address = request.ss58_address;

    let input = ProgramInput {
        substrate_address: ss58_address.clone(),
        signature,
        evm_address,
        amount,
        challenge,
    };

    // Explicitly use Mainnet mode instead of relying on default (Reserved)
    // This ensures we use the correct domain for the mainnet network
    let client = ProverClient::builder()
        .network_for(NetworkMode::Mainnet)
        .build();
    let (pk, vk) = client.setup(ELF);

    let mut stdin = SP1Stdin::new();
    stdin.write(&input);

    let proof = client
        .prove(&pk, &stdin)
        .groth16()
        .run()
        .map_err(err_to_string)?;

    if verify_proof {
        client.verify(&proof, &vk).map_err(err_to_string)?;
    }

    // Log the committed public values for debugging
    let committed_public_values = proof.public_values.to_vec();
    info!("Committed public values (hex): 0x{}", hex::encode(&committed_public_values));
    info!("Committed public values length: {} bytes", committed_public_values.len());

    // Decode and log the individual fields
    if let Ok(decoded) = PublicValues::abi_decode(&committed_public_values) {
        info!("Decoded pubkey: 0x{}", hex::encode(&decoded.pubkey));
        info!("Decoded evm_address: 0x{}", hex::encode(&decoded.evm_address));
        info!("Decoded amount: 0x{}", hex::encode(&decoded.amount));
        info!("Decoded challenge: 0x{}", hex::encode(&decoded.challenge));
    }

    let proof_bytes = proof.bytes();
    let committed_public_values = committed_public_values.clone();

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

    // Return both proof and public values
    let proof_hex = format!("0x{}", hex::encode(proof_bytes));
    let public_values_hex = format!("0x{}", hex::encode(&committed_public_values));
    Ok((proof_hex, public_values_hex))
}

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

    let client = reqwest::blocking::Client::new();
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

async fn update_job(
    jobs: &Arc<Mutex<HashMap<String, JobEntry>>>,
    job_id: &str,
    status: JobStatus,
) {
    let mut jobs = jobs.lock().await;
    if let Some(entry) = jobs.get_mut(job_id) {
        entry.status = status;
        entry.updated_at = now_ts();
    }
}

fn status_response(status: &JobStatus) -> StatusResponse {
    match status {
        JobStatus::Pending => StatusResponse {
            status: "pending".to_string(),
            zk_proof: None,
            public_values: None,
            error: None,
        },
        JobStatus::Running => StatusResponse {
            status: "running".to_string(),
            zk_proof: None,
            public_values: None,
            error: None,
        },
        JobStatus::Completed { zk_proof, public_values } => StatusResponse {
            status: "completed".to_string(),
            zk_proof: Some(zk_proof.clone()),
            public_values: Some(public_values.clone()),
            error: None,
        },
        JobStatus::Failed { error } => StatusResponse {
            status: "failed".to_string(),
            zk_proof: None,
            public_values: None,
            error: Some(error.clone()),
        },
    }
}

fn bad_request(message: &str) -> (StatusCode, Json<StatusResponse>) {
    (
        StatusCode::BAD_REQUEST,
        Json(StatusResponse {
            status: "failed".to_string(),
            zk_proof: None,
            public_values: None,
            error: Some(message.to_string()),
        }),
    )
}

fn parse_hex_bytes<const N: usize>(value: &str) -> anyhow::Result<[u8; N]> {
    let trimmed = value.strip_prefix("0x").unwrap_or(value);
    let bytes = hex::decode(trimmed)?;
    if bytes.len() != N {
        anyhow::bail!("Expected {} bytes, got {}", N, bytes.len());
    }
    let mut out = [0u8; N];
    out.copy_from_slice(&bytes);
    Ok(out)
}

fn parse_amount(value: &str) -> anyhow::Result<[u8; 32]> {
    let amount: U256 = value.parse().map_err(|_| anyhow::anyhow!("Invalid amount"))?;
    Ok(amount.to_be_bytes())
}

fn err_to_string(err: impl std::fmt::Display) -> String {
    err.to_string()
}

fn is_decimal(value: &str) -> bool {
    !value.is_empty() && value.chars().all(|c| c.is_ascii_digit())
}

fn now_ts() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}
