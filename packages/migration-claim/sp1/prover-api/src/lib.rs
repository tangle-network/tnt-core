//! SP1 Prover API library
//!
//! This crate provides a REST API for generating ZK proofs using the SP1 SDK.
//! The modules are separated to allow testing of non-SP1-dependent code independently.

pub mod cache;
pub mod config;
pub mod eligibility;
pub mod handlers;
pub mod jobs;
pub mod prover;
pub mod queue;
pub mod rate_limit;
pub mod signature;
pub mod types;
pub mod validation;

// Re-export commonly used types
pub use types::{
    error_codes, AppConfig, AppState, CachedProof, ClaimContractConfig, HealthResponse,
    JobEntry, JobMessage, JobResponse, JobStatus, ProveRequest, RateLimitEntry, StatusResponse,
    VerifyOnchainConfig,
};
