use crate::eligibility::EligibilityData;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::{SystemTime, UNIX_EPOCH};
use tokio::sync::Mutex;

/// Request payload for proof generation
#[derive(Debug, Clone, Deserialize)]
pub struct ProveRequest {
    #[serde(rename = "ss58Address")]
    pub ss58_address: String,
    pub signature: String,
    #[serde(rename = "evmAddress")]
    pub evm_address: String,
    pub challenge: String,
    pub amount: String,
}

/// Response with job ID after submission
#[derive(Debug, Clone, Serialize)]
pub struct JobResponse {
    #[serde(rename = "jobId")]
    pub job_id: String,
}

/// Status response for job queries
#[derive(Debug, Clone, Serialize)]
pub struct StatusResponse {
    pub status: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub code: Option<String>,
    #[serde(rename = "zkProof", skip_serializing_if = "Option::is_none")]
    pub zk_proof: Option<String>,
    #[serde(rename = "publicValues", skip_serializing_if = "Option::is_none")]
    pub public_values: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<String>,
    #[serde(rename = "retryAfter", skip_serializing_if = "Option::is_none")]
    pub retry_after: Option<u64>,
}

impl StatusResponse {
    pub fn pending() -> Self {
        Self {
            status: "pending".to_string(),
            code: None,
            zk_proof: None,
            public_values: None,
            error: None,
            retry_after: None,
        }
    }

    pub fn running() -> Self {
        Self {
            status: "running".to_string(),
            code: None,
            zk_proof: None,
            public_values: None,
            error: None,
            retry_after: None,
        }
    }

    pub fn completed(zk_proof: String, public_values: String) -> Self {
        Self {
            status: "completed".to_string(),
            code: None,
            zk_proof: Some(zk_proof),
            public_values: Some(public_values),
            error: None,
            retry_after: None,
        }
    }

    pub fn failed(code: &str, error: String) -> Self {
        Self {
            status: "failed".to_string(),
            code: Some(code.to_string()),
            zk_proof: None,
            public_values: None,
            error: Some(error),
            retry_after: None,
        }
    }

    pub fn failed_with_retry(code: &str, error: String, retry_after: u64) -> Self {
        Self {
            status: "failed".to_string(),
            code: Some(code.to_string()),
            zk_proof: None,
            public_values: None,
            error: Some(error),
            retry_after: Some(retry_after),
        }
    }
}

/// Health check response
#[derive(Debug, Clone, Serialize)]
pub struct HealthResponse {
    pub status: String,
    pub prover_mode: String,
    pub verify_proof: bool,
    pub verify_onchain: bool,
    pub jobs: usize,
    pub cache_size: usize,
    pub queue_size: usize,
    pub queue_capacity: usize,
    /// Proof generation metrics for monitoring
    pub proof_metrics: ProofMetricsSnapshot,
}

/// Job status enum
#[derive(Debug, Clone)]
pub enum JobStatus {
    Pending,
    Running,
    Completed {
        zk_proof: String,
        public_values: String,
    },
    Failed {
        error: String,
    },
}

/// Job entry in the jobs map
#[derive(Debug, Clone)]
pub struct JobEntry {
    pub status: JobStatus,
    pub updated_at: u64,
}

impl JobEntry {
    pub fn new(status: JobStatus) -> Self {
        Self {
            status,
            updated_at: now_ts(),
        }
    }
}

/// Cached proof result
#[derive(Debug, Clone)]
pub struct CachedProof {
    pub zk_proof: String,
    pub public_values: String,
    pub created_at: u64,
}

impl CachedProof {
    pub fn new(zk_proof: String, public_values: String) -> Self {
        Self {
            zk_proof,
            public_values,
            created_at: now_ts(),
        }
    }

    pub fn is_expired(&self, ttl_seconds: u64) -> bool {
        now_ts() - self.created_at > ttl_seconds
    }
}

/// Rate limit entry
#[derive(Debug, Clone)]
pub struct RateLimitEntry {
    pub last_request_at: u64,
    pub request_count: u32,
}

impl RateLimitEntry {
    pub fn new() -> Self {
        Self {
            last_request_at: now_ts(),
            request_count: 1,
        }
    }
}

impl Default for RateLimitEntry {
    fn default() -> Self {
        Self::new()
    }
}

/// Metrics for monitoring proof generation
///
/// Tracks completions, timeouts, and timed-out tasks that continue running
/// in the background (since spawn_blocking cannot be cancelled).
pub struct ProofMetrics {
    /// Total number of successful proof completions
    pub total_completions: AtomicUsize,
    /// Total number of proof timeouts
    pub total_timeouts: AtomicUsize,
    /// Number of timed-out tasks still running in background
    /// Note: This counter increases on timeout and decreases when the task eventually completes
    pub timed_out_still_running: AtomicUsize,
}

impl ProofMetrics {
    pub fn new() -> Self {
        Self {
            total_completions: AtomicUsize::new(0),
            total_timeouts: AtomicUsize::new(0),
            timed_out_still_running: AtomicUsize::new(0),
        }
    }

    /// Record a successful completion
    pub fn record_completion(&self) {
        self.total_completions.fetch_add(1, Ordering::Relaxed);
    }

    /// Record a timeout (task continues running in background)
    pub fn record_timeout(&self) {
        self.total_timeouts.fetch_add(1, Ordering::Relaxed);
        self.timed_out_still_running.fetch_add(1, Ordering::Relaxed);
    }

    /// Get current metrics snapshot
    pub fn snapshot(&self) -> ProofMetricsSnapshot {
        ProofMetricsSnapshot {
            total_completions: self.total_completions.load(Ordering::Relaxed),
            total_timeouts: self.total_timeouts.load(Ordering::Relaxed),
            timed_out_still_running: self.timed_out_still_running.load(Ordering::Relaxed),
        }
    }
}

impl Default for ProofMetrics {
    fn default() -> Self {
        Self::new()
    }
}

/// Serializable snapshot of proof metrics
#[derive(Debug, Clone, Serialize)]
pub struct ProofMetricsSnapshot {
    pub total_completions: usize,
    pub total_timeouts: usize,
    pub timed_out_still_running: usize,
}

/// Job queue message
#[derive(Debug, Clone)]
pub struct JobMessage {
    pub job_id: String,
    pub request: ProveRequest,
}

/// Shared application state
#[derive(Clone)]
pub struct AppState {
    pub jobs: Arc<Mutex<HashMap<String, JobEntry>>>,
    pub cache: Arc<Mutex<HashMap<String, CachedProof>>>,
    pub rate_limits: Arc<Mutex<HashMap<String, RateLimitEntry>>>,
    /// IP-based rate limits (separate from pubkey rate limits)
    pub ip_rate_limits: Arc<Mutex<HashMap<String, RateLimitEntry>>>,
    /// Eligibility data loaded from merkle-tree.json
    pub eligibility: Arc<EligibilityData>,
    pub config: Arc<AppConfig>,
    pub job_sender: Option<tokio::sync::mpsc::Sender<JobMessage>>,
    pub queue_size: Option<Arc<std::sync::atomic::AtomicUsize>>,
    /// Metrics for monitoring proof generation
    pub metrics: Arc<ProofMetrics>,
}

/// Application configuration
#[derive(Debug, Clone)]
pub struct AppConfig {
    pub prover_mode: String,
    pub verify_proof: bool,
    pub verify_onchain: Option<VerifyOnchainConfig>,
    pub claim_contract: Option<ClaimContractConfig>,
    pub cache_ttl_seconds: u64,
    pub rate_limit_window_seconds: u64,
    pub rate_limit_max_requests: u32,
    /// IP-based rate limit window in seconds
    pub ip_rate_limit_window_seconds: u64,
    /// Maximum requests per IP per window
    pub ip_rate_limit_max_requests: u32,
    pub queue_capacity: usize,
    pub worker_count: usize,
    pub proof_timeout_seconds: u64,
    pub rpc_timeout_seconds: u64,
    pub max_body_bytes: usize,
    pub jobs_ttl_seconds: u64,
    /// Path to the eligibility file (merkle-tree.json)
    pub eligibility_file: String,
    /// Whether to verify signatures before proof generation
    pub verify_signatures: bool,
}

impl Default for AppConfig {
    fn default() -> Self {
        Self {
            prover_mode: "network".to_string(),
            verify_proof: false,
            verify_onchain: None,
            claim_contract: None,
            cache_ttl_seconds: 3600,          // 1 hour
            rate_limit_window_seconds: 300,   // 5 minutes
            rate_limit_max_requests: 3,       // 3 requests per window
            ip_rate_limit_window_seconds: 60, // 1 minute
            ip_rate_limit_max_requests: 10,   // 10 requests per IP per minute
            queue_capacity: 50,
            worker_count: 4,
            proof_timeout_seconds: 600, // 10 minutes
            rpc_timeout_seconds: 10,
            max_body_bytes: 4096,  // 4 KB
            jobs_ttl_seconds: 3600, // 1 hour
            eligibility_file: "../merkle-tree.json".to_string(),
            verify_signatures: true, // Enabled by default
        }
    }
}

/// On-chain verification configuration
#[derive(Debug, Clone)]
pub struct VerifyOnchainConfig {
    pub rpc_url: String,
    pub verifier_address: [u8; 20],
    pub program_vkey: [u8; 32],
}

/// Claim contract configuration for checking already-claimed
#[derive(Debug, Clone)]
pub struct ClaimContractConfig {
    pub rpc_url: String,
    pub contract_address: [u8; 20],
}

/// Get current unix timestamp
pub fn now_ts() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}

/// Error codes for structured error responses
pub mod error_codes {
    pub const INVALID_INPUT: &str = "invalid_input";
    pub const ALREADY_CLAIMED: &str = "already_claimed";
    pub const RATE_LIMITED: &str = "rate_limited";
    pub const QUEUE_FULL: &str = "queue_full";
    pub const TIMEOUT: &str = "timeout";
    pub const RPC_UNAVAILABLE: &str = "rpc_unavailable";
    pub const PROOF_FAILED: &str = "proof_failed";
    pub const NOT_FOUND: &str = "not_found";
    pub const INTERNAL_ERROR: &str = "internal_error";
    /// Address is not in the eligibility list
    pub const NOT_ELIGIBLE: &str = "not_eligible";
    /// Requested amount doesn't match the eligible balance
    pub const AMOUNT_MISMATCH: &str = "amount_mismatch";
    /// Signature verification failed
    pub const INVALID_SIGNATURE: &str = "invalid_signature";
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_status_response_pending() {
        let resp = StatusResponse::pending();
        assert_eq!(resp.status, "pending");
        assert!(resp.zk_proof.is_none());
        assert!(resp.error.is_none());
    }

    #[test]
    fn test_status_response_completed() {
        let resp = StatusResponse::completed("0x123".to_string(), "0x456".to_string());
        assert_eq!(resp.status, "completed");
        assert_eq!(resp.zk_proof.unwrap(), "0x123");
        assert_eq!(resp.public_values.unwrap(), "0x456");
    }

    #[test]
    fn test_status_response_failed() {
        let resp = StatusResponse::failed("invalid_input", "bad data".to_string());
        assert_eq!(resp.status, "failed");
        assert_eq!(resp.code.unwrap(), "invalid_input");
        assert_eq!(resp.error.unwrap(), "bad data");
    }

    #[test]
    fn test_cached_proof_expiry() {
        let proof = CachedProof {
            zk_proof: "0x".to_string(),
            public_values: "0x".to_string(),
            created_at: now_ts() - 100,
        };
        assert!(!proof.is_expired(200));
        assert!(proof.is_expired(50));
    }

    #[test]
    fn test_rate_limit_entry_new() {
        let entry = RateLimitEntry::new();
        assert_eq!(entry.request_count, 1);
        assert!(entry.last_request_at > 0);
    }
}
