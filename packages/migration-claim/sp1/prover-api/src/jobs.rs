use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::info;

use crate::types::{now_ts, JobEntry, JobStatus};

/// Job manager for TTL-based cleanup
pub struct JobManager {
    jobs: Arc<Mutex<HashMap<String, JobEntry>>>,
    ttl_seconds: u64,
}

impl JobManager {
    pub fn new(jobs: Arc<Mutex<HashMap<String, JobEntry>>>, ttl_seconds: u64) -> Self {
        Self { jobs, ttl_seconds }
    }

    /// Clean up old completed/failed jobs
    /// Keeps pending and running jobs regardless of age
    pub async fn cleanup(&self) -> usize {
        let mut jobs = self.jobs.lock().await;
        let before = jobs.len();
        let now = now_ts();

        jobs.retain(|_, entry| {
            // Always keep pending and running jobs
            match &entry.status {
                JobStatus::Pending | JobStatus::Running => true,
                // Remove completed/failed jobs older than TTL
                JobStatus::Completed { .. } | JobStatus::Failed { .. } => {
                    now - entry.updated_at < self.ttl_seconds
                }
            }
        });

        let removed = before - jobs.len();
        if removed > 0 {
            info!("Jobs cleanup: removed {} old entries", removed);
        }
        removed
    }
}

/// Start a background task to periodically clean up old jobs
pub fn start_jobs_cleanup_task(
    jobs: Arc<Mutex<HashMap<String, JobEntry>>>,
    ttl_seconds: u64,
    cleanup_interval_seconds: u64,
) {
    let job_manager = JobManager::new(jobs, ttl_seconds);
    tokio::spawn(async move {
        let mut interval =
            tokio::time::interval(std::time::Duration::from_secs(cleanup_interval_seconds));
        loop {
            interval.tick().await;
            job_manager.cleanup().await;
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_cleanup_keeps_pending_jobs() {
        let jobs = Arc::new(Mutex::new(HashMap::new()));

        // Insert an old pending job
        {
            let mut j = jobs.lock().await;
            j.insert(
                "pending_job".to_string(),
                JobEntry {
                    status: JobStatus::Pending,
                    updated_at: now_ts() - 1000, // Old job
                },
            );
        }

        let manager = JobManager::new(jobs.clone(), 60);
        let removed = manager.cleanup().await;

        assert_eq!(removed, 0);
        assert_eq!(jobs.lock().await.len(), 1);
    }

    #[tokio::test]
    async fn test_cleanup_keeps_running_jobs() {
        let jobs = Arc::new(Mutex::new(HashMap::new()));

        // Insert an old running job
        {
            let mut j = jobs.lock().await;
            j.insert(
                "running_job".to_string(),
                JobEntry {
                    status: JobStatus::Running,
                    updated_at: now_ts() - 1000, // Old job
                },
            );
        }

        let manager = JobManager::new(jobs.clone(), 60);
        let removed = manager.cleanup().await;

        assert_eq!(removed, 0);
        assert_eq!(jobs.lock().await.len(), 1);
    }

    #[tokio::test]
    async fn test_cleanup_removes_old_completed_jobs() {
        let jobs = Arc::new(Mutex::new(HashMap::new()));

        // Insert an old completed job
        {
            let mut j = jobs.lock().await;
            j.insert(
                "old_completed".to_string(),
                JobEntry {
                    status: JobStatus::Completed {
                        zk_proof: "0x123".to_string(),
                        public_values: "0x456".to_string(),
                    },
                    updated_at: now_ts() - 120, // 2 minutes ago
                },
            );
            // Insert a fresh completed job
            j.insert(
                "fresh_completed".to_string(),
                JobEntry {
                    status: JobStatus::Completed {
                        zk_proof: "0x789".to_string(),
                        public_values: "0xabc".to_string(),
                    },
                    updated_at: now_ts() - 30, // 30 seconds ago
                },
            );
        }

        let manager = JobManager::new(jobs.clone(), 60); // 1 minute TTL
        let removed = manager.cleanup().await;

        assert_eq!(removed, 1);
        assert_eq!(jobs.lock().await.len(), 1);

        // Verify the fresh one is still there
        let j = jobs.lock().await;
        assert!(j.contains_key("fresh_completed"));
        assert!(!j.contains_key("old_completed"));
    }

    #[tokio::test]
    async fn test_cleanup_removes_old_failed_jobs() {
        let jobs = Arc::new(Mutex::new(HashMap::new()));

        // Insert an old failed job
        {
            let mut j = jobs.lock().await;
            j.insert(
                "old_failed".to_string(),
                JobEntry {
                    status: JobStatus::Failed {
                        error: "some error".to_string(),
                    },
                    updated_at: now_ts() - 120, // 2 minutes ago
                },
            );
        }

        let manager = JobManager::new(jobs.clone(), 60); // 1 minute TTL
        let removed = manager.cleanup().await;

        assert_eq!(removed, 1);
        assert_eq!(jobs.lock().await.len(), 0);
    }

    #[tokio::test]
    async fn test_mixed_cleanup() {
        let jobs = Arc::new(Mutex::new(HashMap::new()));
        let now = now_ts();

        {
            let mut j = jobs.lock().await;
            // Old jobs
            j.insert(
                "old_pending".to_string(),
                JobEntry {
                    status: JobStatus::Pending,
                    updated_at: now - 200,
                },
            );
            j.insert(
                "old_running".to_string(),
                JobEntry {
                    status: JobStatus::Running,
                    updated_at: now - 200,
                },
            );
            j.insert(
                "old_completed".to_string(),
                JobEntry {
                    status: JobStatus::Completed {
                        zk_proof: "0x".to_string(),
                        public_values: "0x".to_string(),
                    },
                    updated_at: now - 200,
                },
            );
            j.insert(
                "old_failed".to_string(),
                JobEntry {
                    status: JobStatus::Failed {
                        error: "err".to_string(),
                    },
                    updated_at: now - 200,
                },
            );
            // Fresh jobs
            j.insert(
                "fresh_completed".to_string(),
                JobEntry {
                    status: JobStatus::Completed {
                        zk_proof: "0x".to_string(),
                        public_values: "0x".to_string(),
                    },
                    updated_at: now - 30,
                },
            );
        }

        let manager = JobManager::new(jobs.clone(), 60);
        let removed = manager.cleanup().await;

        // Should remove old_completed and old_failed, keep pending/running and fresh_completed
        assert_eq!(removed, 2);
        assert_eq!(jobs.lock().await.len(), 3);

        let j = jobs.lock().await;
        assert!(j.contains_key("old_pending"));
        assert!(j.contains_key("old_running"));
        assert!(j.contains_key("fresh_completed"));
        assert!(!j.contains_key("old_completed"));
        assert!(!j.contains_key("old_failed"));
    }
}
