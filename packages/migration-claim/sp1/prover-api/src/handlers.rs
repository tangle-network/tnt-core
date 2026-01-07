use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    Json,
};
use tracing::{error, info, warn};
use uuid::Uuid;

use crate::cache::ProofCache;
use crate::prover::check_already_claimed;
use crate::queue::{EnqueueResult, JobQueue};
use crate::rate_limit::{RateLimitResult, RateLimiter};
use crate::types::{
    error_codes, AppState, HealthResponse, JobEntry, JobMessage, JobResponse, JobStatus,
    ProveRequest, StatusResponse,
};
use crate::validation::{cache_key, rate_limit_key_pubkey, validate_request};

/// Submit a new proof generation job
pub async fn submit_job(
    State(state): State<AppState>,
    Json(request): Json<ProveRequest>,
) -> Result<Json<JobResponse>, (StatusCode, Json<StatusResponse>)> {
    // 1. Validate input
    let validated = validate_request(&request).map_err(|e| {
        warn!("Invalid request: {}", e.message);
        (
            StatusCode::BAD_REQUEST,
            Json(StatusResponse::failed(error_codes::INVALID_INPUT, e.message)),
        )
    })?;

    // 2. Check rate limit (by pubkey for stronger protection)
    let rate_limit_key = rate_limit_key_pubkey(&validated.pubkey);
    let rate_limiter = RateLimiter::new(
        state.rate_limits.clone(),
        state.config.rate_limit_window_seconds,
        state.config.rate_limit_max_requests,
    );

    match rate_limiter.check_and_update(&rate_limit_key).await {
        RateLimitResult::Limited { retry_after } => {
            warn!(
                "Rate limited: {} (retry after {}s)",
                request.ss58_address, retry_after
            );
            return Err((
                StatusCode::TOO_MANY_REQUESTS,
                Json(StatusResponse::failed_with_retry(
                    error_codes::RATE_LIMITED,
                    format!(
                        "Too many requests. Please wait {} seconds before trying again.",
                        retry_after
                    ),
                    retry_after,
                )),
            ));
        }
        RateLimitResult::Allowed => {}
    }

    // 3. Check cache for existing proof
    let cache_key = cache_key(&request);
    let proof_cache = ProofCache::new(state.cache.clone(), state.config.cache_ttl_seconds);

    if let Some(cached) = proof_cache.get(&cache_key).await {
        info!("Cache hit for {}", request.ss58_address);
        // Return a synthetic completed job with the cached proof
        let job_id = Uuid::new_v4().to_string();
        {
            let mut jobs = state.jobs.lock().await;
            jobs.insert(
                job_id.clone(),
                JobEntry::new(JobStatus::Completed {
                    zk_proof: cached.zk_proof,
                    public_values: cached.public_values,
                }),
            );
        }
        return Ok(Json(JobResponse { job_id }));
    }

    // 4. Check if user has already claimed on-chain
    if let Some(ref claim_config) = state.config.claim_contract {
        match check_already_claimed(
            claim_config,
            &request.ss58_address,
            state.config.rpc_timeout_seconds,
        )
        .await
        {
            Ok(true) => {
                info!(
                    "Rejecting request: {} has already claimed",
                    request.ss58_address
                );
                return Err((
                    StatusCode::CONFLICT,
                    Json(StatusResponse::failed(
                        error_codes::ALREADY_CLAIMED,
                        "This address has already claimed tokens".to_string(),
                    )),
                ));
            }
            Ok(false) => {
                // User hasn't claimed, proceed
            }
            Err(e) => {
                error!(
                    "Failed to check claim status for {}: {}",
                    request.ss58_address, e
                );
                return Err((
                    StatusCode::SERVICE_UNAVAILABLE,
                    Json(StatusResponse::failed(
                        error_codes::RPC_UNAVAILABLE,
                        format!("Unable to verify claim status: {e}. Please try again."),
                    )),
                ));
            }
        }
    }

    // 5. Create job and try to enqueue
    let job_id = Uuid::new_v4().to_string();

    // Try to enqueue if we have a queue
    if let Some(ref sender) = state.job_sender {
        let queue = JobQueue::from_sender(sender.clone(), state.config.queue_capacity);

        match queue.try_enqueue(JobMessage {
            job_id: job_id.clone(),
            request: request.clone(),
        }).await {
            EnqueueResult::Queued => {
                // Create pending job entry
                {
                    let mut jobs = state.jobs.lock().await;
                    jobs.insert(job_id.clone(), JobEntry::new(JobStatus::Pending));
                }
                info!("Job {} queued for {}", job_id, request.ss58_address);
            }
            EnqueueResult::QueueFull => {
                warn!("Queue full, rejecting job for {}", request.ss58_address);
                return Err((
                    StatusCode::SERVICE_UNAVAILABLE,
                    Json(StatusResponse::failed(
                        error_codes::QUEUE_FULL,
                        "Server is at capacity. Please try again later.".to_string(),
                    )),
                ));
            }
        }
    } else {
        // Legacy mode: spawn task directly (for backward compatibility during transition)
        {
            let mut jobs = state.jobs.lock().await;
            jobs.insert(job_id.clone(), JobEntry::new(JobStatus::Pending));
        }

        let jobs = state.jobs.clone();
        let cache = state.cache.clone();
        let verify_proof = state.config.verify_proof;
        let verify_onchain = state.config.verify_onchain.clone();
        let job_id_clone = job_id.clone();
        let cache_key_clone = cache_key.clone();
        let config = state.config.clone();
        let ss58_address = request.ss58_address.clone();

        tokio::spawn(async move {
            use crate::prover::generate_proof;
            use crate::types::{now_ts, CachedProof};

            // Update to running
            {
                let mut jobs = jobs.lock().await;
                if let Some(entry) = jobs.get_mut(&job_id_clone) {
                    entry.status = JobStatus::Running;
                    entry.updated_at = now_ts();
                }
            }

            // Generate proof with timeout
            let timeout = std::time::Duration::from_secs(config.proof_timeout_seconds);
            let result = tokio::time::timeout(timeout, async {
                let req = request.clone();
                tokio::task::spawn_blocking(move || {
                    generate_proof(req, verify_proof, verify_onchain)
                })
                .await
            })
            .await;

            let final_status = match result {
                Ok(Ok(Ok((zk_proof, public_values)))) => {
                    // Store in cache
                    {
                        let mut c = cache.lock().await;
                        c.insert(
                            cache_key_clone,
                            CachedProof::new(zk_proof.clone(), public_values.clone()),
                        );
                    }
                    JobStatus::Completed {
                        zk_proof,
                        public_values,
                    }
                }
                Ok(Ok(Err(err))) => {
                    error!("Proof generation failed for job {}: {}", job_id_clone, err);
                    JobStatus::Failed {
                        error: format!("{}: {}", error_codes::PROOF_FAILED, err),
                    }
                }
                Ok(Err(join_err)) => {
                    error!("Job {} panicked: {}", job_id_clone, join_err);
                    JobStatus::Failed {
                        error: format!("{}: task panicked", error_codes::INTERNAL_ERROR),
                    }
                }
                Err(_) => {
                    error!("Job {} timed out after {:?}", job_id_clone, timeout);
                    JobStatus::Failed {
                        error: format!(
                            "{}: proof generation exceeded {} seconds",
                            error_codes::TIMEOUT,
                            timeout.as_secs()
                        ),
                    }
                }
            };

            // Update job status
            {
                let mut jobs = jobs.lock().await;
                if let Some(entry) = jobs.get_mut(&job_id_clone) {
                    entry.status = final_status;
                    entry.updated_at = now_ts();
                }
            }
        });

        info!("Job {} spawned for {}", job_id, ss58_address);
    }

    Ok(Json(JobResponse { job_id }))
}

/// Get job status
pub async fn job_status(
    State(state): State<AppState>,
    Path(job_id): Path<String>,
) -> Result<Json<StatusResponse>, (StatusCode, Json<StatusResponse>)> {
    let jobs = state.jobs.lock().await;
    match jobs.get(&job_id) {
        Some(job) => Ok(Json(status_from_job(&job.status))),
        None => Err((
            StatusCode::NOT_FOUND,
            Json(StatusResponse::failed(
                error_codes::NOT_FOUND,
                "Job not found".to_string(),
            )),
        )),
    }
}

/// Health check endpoint
pub async fn health(State(state): State<AppState>) -> impl IntoResponse {
    let jobs = state.jobs.lock().await;
    let cache = state.cache.lock().await;

    let queue_size = state
        .queue_size
        .as_ref()
        .map(|counter| counter.load(std::sync::atomic::Ordering::SeqCst))
        .unwrap_or(0);

    let response = HealthResponse {
        status: "ok".to_string(),
        prover_mode: state.config.prover_mode.clone(),
        verify_proof: state.config.verify_proof,
        verify_onchain: state.config.verify_onchain.is_some(),
        jobs: jobs.len(),
        cache_size: cache.len(),
        queue_size,
        queue_capacity: state.config.queue_capacity,
    };
    (StatusCode::OK, Json(response))
}

/// Convert job status to response
fn status_from_job(status: &JobStatus) -> StatusResponse {
    match status {
        JobStatus::Pending => StatusResponse::pending(),
        JobStatus::Running => StatusResponse::running(),
        JobStatus::Completed {
            zk_proof,
            public_values,
        } => StatusResponse::completed(zk_proof.clone(), public_values.clone()),
        JobStatus::Failed { error } => {
            // Parse the error code from the error message if present
            let (code, message) = if let Some(idx) = error.find(':') {
                let code = &error[..idx];
                let msg = error[idx + 1..].trim();
                (code, msg.to_string())
            } else {
                (error_codes::PROOF_FAILED, error.clone())
            };
            StatusResponse::failed(code, message)
        }
    }
}

/// Extension trait for JobQueue to create from sender
impl JobQueue {
    pub fn from_sender(sender: tokio::sync::mpsc::Sender<JobMessage>, capacity: usize) -> Self {
        Self {
            sender,
            queue_size: std::sync::Arc::new(std::sync::atomic::AtomicUsize::new(0)),
            capacity,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_status_from_job_pending() {
        let status = JobStatus::Pending;
        let resp = status_from_job(&status);
        assert_eq!(resp.status, "pending");
    }

    #[test]
    fn test_status_from_job_running() {
        let status = JobStatus::Running;
        let resp = status_from_job(&status);
        assert_eq!(resp.status, "running");
    }

    #[test]
    fn test_status_from_job_completed() {
        let status = JobStatus::Completed {
            zk_proof: "0x123".to_string(),
            public_values: "0x456".to_string(),
        };
        let resp = status_from_job(&status);
        assert_eq!(resp.status, "completed");
        assert_eq!(resp.zk_proof, Some("0x123".to_string()));
        assert_eq!(resp.public_values, Some("0x456".to_string()));
    }

    #[test]
    fn test_status_from_job_failed_with_code() {
        let status = JobStatus::Failed {
            error: "timeout: proof generation exceeded 600 seconds".to_string(),
        };
        let resp = status_from_job(&status);
        assert_eq!(resp.status, "failed");
        assert_eq!(resp.code, Some("timeout".to_string()));
        assert!(resp.error.unwrap().contains("600 seconds"));
    }

    #[test]
    fn test_status_from_job_failed_without_code() {
        let status = JobStatus::Failed {
            error: "some error without code".to_string(),
        };
        let resp = status_from_job(&status);
        assert_eq!(resp.status, "failed");
        assert_eq!(resp.code, Some(error_codes::PROOF_FAILED.to_string()));
    }
}
