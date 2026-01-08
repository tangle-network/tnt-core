mod cache;
mod config;
mod eligibility;
mod handlers;
mod jobs;
mod prover;
mod queue;
mod rate_limit;
mod signature;
mod types;
mod validation;

use axum::{
    extract::DefaultBodyLimit,
    http::HeaderValue,
    routing::{get, post},
    Router,
};
use std::{collections::HashMap, net::SocketAddr, sync::Arc};
use tokio::sync::Mutex;
use tower_http::cors::{Any, CorsLayer};
use tracing::{error, info};

use cache::start_cache_cleanup_task;
use config::{get_port, load_config, validate_cors};
use eligibility::EligibilityData;
use handlers::{health, job_status, submit_job};
use jobs::start_jobs_cleanup_task;
use queue::{JobQueue, WorkerPool};
use rate_limit::start_rate_limit_cleanup_task;
use types::{AppState, CachedProof, JobEntry, ProofMetrics, RateLimitEntry};

#[tokio::main]
async fn main() {
    // Install the default crypto provider for rustls (required for TLS with SP1 SDK)
    rustls::crypto::ring::default_provider()
        .install_default()
        .expect("Failed to install rustls crypto provider");

    tracing_subscriber::fmt::init();

    // Load configuration
    let config = match load_config() {
        Ok(c) => c,
        Err(e) => {
            error!("{}", e);
            std::process::exit(1);
        }
    };

    // Validate CORS configuration
    let cors_origins = match validate_cors(&config.prover_mode) {
        Ok(origins) => origins,
        Err(e) => {
            error!("{}", e);
            std::process::exit(1);
        }
    };

    let port = get_port();

    // Log configuration
    info!("Configuration loaded:");
    info!("  SP1_PROVER={}", config.prover_mode);
    info!("  VERIFY_PROOF={}", config.verify_proof);
    info!("  VERIFY_ONCHAIN={}", config.verify_onchain.is_some());
    info!(
        "  CLAIM_CONTRACT={}",
        config
            .claim_contract
            .as_ref()
            .map(|c| format!("0x{}", hex::encode(c.contract_address)))
            .unwrap_or_else(|| "disabled".to_string())
    );
    info!("  CACHE_TTL_SECONDS={}", config.cache_ttl_seconds);
    info!(
        "  RATE_LIMIT={}/{}s",
        config.rate_limit_max_requests, config.rate_limit_window_seconds
    );
    info!(
        "  QUEUE_CAPACITY={} WORKERS={}",
        config.queue_capacity, config.worker_count
    );
    info!("  PROOF_TIMEOUT_SECONDS={}", config.proof_timeout_seconds);
    info!("  MAX_BODY_BYTES={}", config.max_body_bytes);
    info!("  JOBS_TTL_SECONDS={}", config.jobs_ttl_seconds);
    info!(
        "  IP_RATE_LIMIT={}/{}s",
        config.ip_rate_limit_max_requests, config.ip_rate_limit_window_seconds
    );
    info!("  ELIGIBILITY_FILE={}", config.eligibility_file);
    info!("  VERIFY_SIGNATURES={}", config.verify_signatures);
    info!(
        "  CORS_ALLOWED_ORIGINS={}",
        cors_origins.as_deref().unwrap_or("*")
    );

    // Load eligibility data
    info!("Loading eligibility data from {}", config.eligibility_file);
    let eligibility = match EligibilityData::load_from_file(&config.eligibility_file) {
        Ok(data) => {
            info!("Loaded {} eligible addresses", data.entry_count());
            Arc::new(data)
        }
        Err(e) => {
            error!("Failed to load eligibility data: {}", e);
            std::process::exit(1);
        }
    };

    // Initialize shared state
    let jobs: Arc<Mutex<HashMap<String, JobEntry>>> = Arc::new(Mutex::new(HashMap::new()));
    let cache: Arc<Mutex<HashMap<String, CachedProof>>> = Arc::new(Mutex::new(HashMap::new()));
    let rate_limits: Arc<Mutex<HashMap<String, RateLimitEntry>>> =
        Arc::new(Mutex::new(HashMap::new()));
    let ip_rate_limits: Arc<Mutex<HashMap<String, RateLimitEntry>>> =
        Arc::new(Mutex::new(HashMap::new()));
    let metrics = Arc::new(ProofMetrics::new());
    let config = Arc::new(config);

    // Start cleanup tasks
    start_cache_cleanup_task(cache.clone(), config.cache_ttl_seconds, 60);
    start_rate_limit_cleanup_task(
        rate_limits.clone(),
        config.rate_limit_window_seconds,
        config.rate_limit_max_requests,
        60,
    );
    // IP rate limit cleanup task
    start_rate_limit_cleanup_task(
        ip_rate_limits.clone(),
        config.ip_rate_limit_window_seconds,
        config.ip_rate_limit_max_requests,
        60,
    );
    start_jobs_cleanup_task(jobs.clone(), config.jobs_ttl_seconds, 60);

    // Create job queue and worker pool
    let (job_queue, receiver) = JobQueue::new(config.queue_capacity);
    let worker_pool = WorkerPool::new(config.worker_count);

    // Start workers
    worker_pool.start(
        receiver,
        jobs.clone(),
        cache.clone(),
        config.clone(),
        job_queue.size_counter(),
        metrics.clone(),
    );

    let state = AppState {
        jobs,
        cache,
        rate_limits,
        ip_rate_limits,
        eligibility,
        config: config.clone(),
        job_sender: Some(job_queue.sender.clone()),
        queue_size: Some(job_queue.size_counter()),
        metrics,
    };

    // Configure CORS
    let cors = match cors_origins {
        Some(origins) => {
            let origins: Vec<HeaderValue> = origins
                .split(',')
                .filter_map(|s| s.trim().parse().ok())
                .collect();
            CorsLayer::new()
                .allow_origin(origins)
                .allow_methods(Any)
                .allow_headers(Any)
        }
        None => CorsLayer::new()
            .allow_origin(Any)
            .allow_methods(Any)
            .allow_headers(Any),
    };

    // Build router
    let app = Router::new()
        .route("/", post(submit_job))
        .route("/status/:job_id", get(job_status))
        .route("/health", get(health))
        .layer(DefaultBodyLimit::max(config.max_body_bytes))
        .layer(cors)
        .with_state(state);

    info!("SP1 prover API listening on 0.0.0.0:{port}");

    let listener = tokio::net::TcpListener::bind(("0.0.0.0", port))
        .await
        .expect("Failed to bind port");

    // Use into_make_service_with_connect_info to enable IP extraction
    axum::serve(
        listener,
        app.into_make_service_with_connect_info::<SocketAddr>(),
    )
    .await
    .expect("Server error");
}
