use std::collections::HashMap;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::{mpsc, Mutex};
use tracing::{error, info, warn};

use crate::prover::generate_proof;
use crate::types::{error_codes, AppConfig, CachedProof, JobEntry, JobMessage, JobStatus, ProofMetrics};
use crate::validation::cache_key;

/// Job queue for managing proof generation work
pub struct JobQueue {
    pub sender: mpsc::Sender<JobMessage>,
    pub queue_size: Arc<AtomicUsize>,
    pub capacity: usize,
}

/// Result of trying to enqueue a job
#[derive(Debug)]
pub enum EnqueueResult {
    /// Job was successfully queued
    Queued,
    /// Queue is full
    QueueFull,
}

impl JobQueue {
    /// Create a new job queue with the given capacity
    pub fn new(capacity: usize) -> (Self, mpsc::Receiver<JobMessage>) {
        let (sender, receiver) = mpsc::channel(capacity);
        let queue = Self {
            sender,
            queue_size: Arc::new(AtomicUsize::new(0)),
            capacity,
        };
        (queue, receiver)
    }

    /// Try to enqueue a job
    pub async fn try_enqueue(&self, message: JobMessage) -> EnqueueResult {
        // Check if queue is full before trying to send
        let current_size = self.queue_size.load(Ordering::SeqCst);
        if current_size >= self.capacity {
            return EnqueueResult::QueueFull;
        }

        match self.sender.try_send(message) {
            Ok(()) => {
                self.queue_size.fetch_add(1, Ordering::SeqCst);
                EnqueueResult::Queued
            }
            Err(mpsc::error::TrySendError::Full(_)) => EnqueueResult::QueueFull,
            Err(mpsc::error::TrySendError::Closed(_)) => {
                error!("Job queue channel closed");
                EnqueueResult::QueueFull
            }
        }
    }

    /// Get a handle to the queue size counter
    pub fn size_counter(&self) -> Arc<AtomicUsize> {
        self.queue_size.clone()
    }
}

/// Worker pool for processing jobs
pub struct WorkerPool {
    worker_count: usize,
}

impl WorkerPool {
    pub fn new(worker_count: usize) -> Self {
        Self { worker_count }
    }

    /// Start workers that process jobs from the receiver
    pub fn start(
        &self,
        mut receiver: mpsc::Receiver<JobMessage>,
        jobs: Arc<Mutex<HashMap<String, JobEntry>>>,
        cache: Arc<Mutex<HashMap<String, CachedProof>>>,
        config: Arc<AppConfig>,
        queue_size: Arc<AtomicUsize>,
        metrics: Arc<ProofMetrics>,
    ) {
        let worker_count = self.worker_count;
        let proof_timeout = Duration::from_secs(config.proof_timeout_seconds);

        // Spawn a task that distributes work to workers
        let jobs_clone = jobs.clone();
        let cache_clone = cache.clone();
        let config_clone = config.clone();
        let metrics_clone = metrics.clone();

        tokio::spawn(async move {
            info!("Starting {} workers for job processing", worker_count);

            // Use a semaphore to limit concurrent proof generation
            let semaphore = Arc::new(tokio::sync::Semaphore::new(worker_count));

            while let Some(message) = receiver.recv().await {
                queue_size.fetch_sub(1, Ordering::SeqCst);

                let jobs = jobs_clone.clone();
                let cache = cache_clone.clone();
                let config = config_clone.clone();
                let metrics = metrics_clone.clone();
                let sem = semaphore.clone();
                let timeout = proof_timeout;

                tokio::spawn(async move {
                    // Acquire semaphore permit
                    let _permit = match sem.acquire().await {
                        Ok(p) => p,
                        Err(_) => {
                            error!("Semaphore closed");
                            return;
                        }
                    };

                    process_job(message, jobs, cache, config, timeout, metrics).await;
                });
            }

            warn!("Job receiver closed, workers stopping");
        });
    }
}

/// Process a single job
async fn process_job(
    message: JobMessage,
    jobs: Arc<Mutex<HashMap<String, JobEntry>>>,
    cache: Arc<Mutex<HashMap<String, CachedProof>>>,
    config: Arc<AppConfig>,
    timeout: Duration,
    metrics: Arc<ProofMetrics>,
) {
    let job_id = message.job_id.clone();
    let cache_key = cache_key(&message.request);

    // Update job to running
    update_job(&jobs, &job_id, JobStatus::Running).await;

    // Generate proof with timeout
    let verify_proof = config.verify_proof;
    let verify_onchain = config.verify_onchain.clone();
    let prover_mode = config.prover_mode.clone();
    let request = message.request.clone();

    // Spawn the blocking task - we keep the handle to track completion after timeout
    let handle = tokio::task::spawn_blocking(move || {
        generate_proof(request, verify_proof, verify_onchain, &prover_mode)
    });

    // Wait with timeout
    let result = tokio::time::timeout(timeout, handle).await;

    match result {
        Ok(Ok(Ok((zk_proof, public_values)))) => {
            // Record successful completion
            metrics.record_completion();

            // Store in cache
            {
                let mut c = cache.lock().await;
                c.insert(
                    cache_key,
                    CachedProof::new(zk_proof.clone(), public_values.clone()),
                );
            }

            // Update job status
            update_job(
                &jobs,
                &job_id,
                JobStatus::Completed {
                    zk_proof,
                    public_values,
                },
            )
            .await;
        }
        Ok(Ok(Err(err))) => {
            error!("Proof generation failed for job {}: {}", job_id, err);
            update_job(
                &jobs,
                &job_id,
                JobStatus::Failed {
                    error: format!("{}: {}", error_codes::PROOF_FAILED, err),
                },
            )
            .await;
        }
        Ok(Err(join_err)) => {
            error!("Job {} panicked: {}", job_id, join_err);
            update_job(
                &jobs,
                &job_id,
                JobStatus::Failed {
                    error: format!("{}: task panicked", error_codes::INTERNAL_ERROR),
                },
            )
            .await;
        }
        Err(_elapsed) => {
            // Timeout fired - record it in metrics
            // Note: The spawn_blocking task continues running in the background!
            metrics.record_timeout();

            error!(
                "Job {} timed out after {:?} - task continues in background (timed_out_still_running={})",
                job_id,
                timeout,
                metrics.timed_out_still_running.load(Ordering::Relaxed)
            );

            update_job(
                &jobs,
                &job_id,
                JobStatus::Failed {
                    error: format!(
                        "{}: proof generation exceeded {} seconds",
                        error_codes::TIMEOUT,
                        timeout.as_secs()
                    ),
                },
            )
            .await;

            // Note: We cannot cancel spawn_blocking tasks. The task will continue
            // running until completion, consuming resources. The metrics track this
            // so operators can monitor for resource exhaustion.
            // When the background task eventually completes, the semaphore permit
            // will be released, but we've already marked the job as failed.
        }
    }
}

/// Update a job's status
async fn update_job(
    jobs: &Arc<Mutex<HashMap<String, JobEntry>>>,
    job_id: &str,
    status: JobStatus,
) {
    let mut jobs = jobs.lock().await;
    if let Some(entry) = jobs.get_mut(job_id) {
        entry.status = status;
        entry.updated_at = crate::types::now_ts();
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::ProveRequest;

    fn test_request() -> ProveRequest {
        ProveRequest {
            ss58_address: "5GrwvaEF5zXb26Fz9rcQpDWS57CtERHpNehXCPcNoHGKutQY".to_string(),
            signature: format!("0x{}", "ab".repeat(64)),
            evm_address: "0x742d35Cc6634C0532925a3b844Bc9e7595f4a3b2".to_string(),
            challenge: format!("0x{}", "12".repeat(32)),
            amount: "1000000000000000000".to_string(),
        }
    }

    #[tokio::test]
    async fn test_queue_enqueue() {
        let (queue, _receiver) = JobQueue::new(10);

        let result = queue
            .try_enqueue(JobMessage {
                job_id: "job1".to_string(),
                request: test_request(),
            })
            .await;

        assert!(matches!(result, EnqueueResult::Queued));
        assert_eq!(queue.queue_size.load(Ordering::SeqCst), 1);
    }

    #[tokio::test]
    async fn test_queue_full() {
        let (queue, _receiver) = JobQueue::new(2);

        // Fill the queue
        queue
            .try_enqueue(JobMessage {
                job_id: "job1".to_string(),
                request: test_request(),
            })
            .await;
        queue
            .try_enqueue(JobMessage {
                job_id: "job2".to_string(),
                request: test_request(),
            })
            .await;

        // Third should fail
        let result = queue
            .try_enqueue(JobMessage {
                job_id: "job3".to_string(),
                request: test_request(),
            })
            .await;

        assert!(matches!(result, EnqueueResult::QueueFull));
        assert_eq!(queue.queue_size.load(Ordering::SeqCst), 2);
    }

    #[tokio::test]
    async fn test_queue_dequeue_updates_size() {
        let (queue, mut receiver) = JobQueue::new(10);

        queue
            .try_enqueue(JobMessage {
                job_id: "job1".to_string(),
                request: test_request(),
            })
            .await;

        assert_eq!(queue.queue_size.load(Ordering::SeqCst), 1);

        // Receive the message and decrement size (simulating worker behavior)
        let _msg = receiver.recv().await;
        queue.queue_size.fetch_sub(1, Ordering::SeqCst);

        assert_eq!(queue.queue_size.load(Ordering::SeqCst), 0);
    }

    #[tokio::test]
    async fn test_multiple_enqueues() {
        let (queue, _receiver) = JobQueue::new(100);

        for i in 0..50 {
            let result = queue
                .try_enqueue(JobMessage {
                    job_id: format!("job{}", i),
                    request: test_request(),
                })
                .await;
            assert!(matches!(result, EnqueueResult::Queued));
        }

        assert_eq!(queue.queue_size.load(Ordering::SeqCst), 50);
    }
}
