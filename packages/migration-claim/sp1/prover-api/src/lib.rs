//! SP1 Prover API library
//!
//! This crate provides a REST API for generating ZK proofs using the SP1 SDK.
//! The modules are separated to allow testing of non-SP1-dependent code independently.

pub mod cache;
pub mod config;
pub mod jobs;
pub mod rate_limit;
pub mod types;
pub mod validation;

// These modules depend on SP1 and are only available when sp1-sdk feature is enabled
#[cfg(feature = "sp1-sdk")]
pub mod handlers;
#[cfg(feature = "sp1-sdk")]
pub mod prover;
#[cfg(feature = "sp1-sdk")]
pub mod queue;

// Re-export commonly used types
pub use types::{
    error_codes, AppConfig, AppState, CachedProof, ClaimContractConfig, HealthResponse,
    JobEntry, JobMessage, JobResponse, JobStatus, ProveRequest, RateLimitEntry, StatusResponse,
    VerifyOnchainConfig,
};
