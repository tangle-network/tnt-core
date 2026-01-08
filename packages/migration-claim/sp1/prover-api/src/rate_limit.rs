use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::info;

use crate::types::{now_ts, RateLimitEntry};

/// Rate limiter for controlling request frequency
pub struct RateLimiter {
    limits: Arc<Mutex<HashMap<String, RateLimitEntry>>>,
    window_seconds: u64,
    max_requests: u32,
}

/// Result of rate limit check
#[derive(Debug, Clone)]
pub enum RateLimitResult {
    /// Request is allowed
    Allowed,
    /// Request is rate limited, with seconds until reset
    Limited { retry_after: u64 },
}

impl RateLimiter {
    pub fn new(
        limits: Arc<Mutex<HashMap<String, RateLimitEntry>>>,
        window_seconds: u64,
        max_requests: u32,
    ) -> Self {
        Self {
            limits,
            window_seconds,
            max_requests,
        }
    }

    /// Check if a request is allowed and update the rate limit state
    pub async fn check_and_update(&self, key: &str) -> RateLimitResult {
        let mut limits = self.limits.lock().await;

        match limits.get_mut(key) {
            Some(entry) => {
                let elapsed = now_ts() - entry.last_request_at;

                if elapsed >= self.window_seconds {
                    // Window expired, reset
                    entry.last_request_at = now_ts();
                    entry.request_count = 1;
                    RateLimitResult::Allowed
                } else if entry.request_count >= self.max_requests {
                    // Rate limited
                    let retry_after = self.window_seconds - elapsed;
                    RateLimitResult::Limited { retry_after }
                } else {
                    // Within limit, increment
                    entry.request_count += 1;
                    RateLimitResult::Allowed
                }
            }
            None => {
                // First request from this key
                limits.insert(key.to_string(), RateLimitEntry::new());
                RateLimitResult::Allowed
            }
        }
    }

    /// Clean up expired entries
    pub async fn cleanup(&self) -> usize {
        let mut limits = self.limits.lock().await;
        let before = limits.len();

        // Remove entries that haven't been used in 2x the window
        let expiry_threshold = now_ts() - (self.window_seconds * 2);
        limits.retain(|_, v| v.last_request_at > expiry_threshold);

        let removed = before - limits.len();
        if removed > 0 {
            info!("Rate limit cleanup: removed {} stale entries", removed);
        }
        removed
    }
}

/// Start a background task to periodically clean up rate limit entries
pub fn start_rate_limit_cleanup_task(
    limits: Arc<Mutex<HashMap<String, RateLimitEntry>>>,
    window_seconds: u64,
    max_requests: u32,
    cleanup_interval_seconds: u64,
) {
    let limiter = RateLimiter::new(limits, window_seconds, max_requests);
    tokio::spawn(async move {
        let mut interval =
            tokio::time::interval(std::time::Duration::from_secs(cleanup_interval_seconds));
        loop {
            interval.tick().await;
            limiter.cleanup().await;
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_first_request_allowed() {
        let limits = Arc::new(Mutex::new(HashMap::new()));
        let limiter = RateLimiter::new(limits, 60, 3);

        let result = limiter.check_and_update("user1").await;
        assert!(matches!(result, RateLimitResult::Allowed));
    }

    #[tokio::test]
    async fn test_within_limit_allowed() {
        let limits = Arc::new(Mutex::new(HashMap::new()));
        let limiter = RateLimiter::new(limits, 60, 3);

        // First 3 requests should be allowed
        assert!(matches!(
            limiter.check_and_update("user1").await,
            RateLimitResult::Allowed
        ));
        assert!(matches!(
            limiter.check_and_update("user1").await,
            RateLimitResult::Allowed
        ));
        assert!(matches!(
            limiter.check_and_update("user1").await,
            RateLimitResult::Allowed
        ));
    }

    #[tokio::test]
    async fn test_exceeds_limit_blocked() {
        let limits = Arc::new(Mutex::new(HashMap::new()));
        let limiter = RateLimiter::new(limits, 60, 3);

        // Use up the limit
        limiter.check_and_update("user1").await;
        limiter.check_and_update("user1").await;
        limiter.check_and_update("user1").await;

        // 4th request should be blocked
        let result = limiter.check_and_update("user1").await;
        match result {
            RateLimitResult::Limited { retry_after } => {
                assert!(retry_after > 0);
                assert!(retry_after <= 60);
            }
            _ => panic!("Expected rate limited"),
        }
    }

    #[tokio::test]
    async fn test_different_users_independent() {
        let limits = Arc::new(Mutex::new(HashMap::new()));
        let limiter = RateLimiter::new(limits, 60, 1);

        // User1 uses their limit
        limiter.check_and_update("user1").await;

        // User2 should still be allowed
        let result = limiter.check_and_update("user2").await;
        assert!(matches!(result, RateLimitResult::Allowed));

        // User1 should be blocked
        let result = limiter.check_and_update("user1").await;
        assert!(matches!(result, RateLimitResult::Limited { .. }));
    }

    #[tokio::test]
    async fn test_window_reset() {
        let limits = Arc::new(Mutex::new(HashMap::new()));

        // Insert an old entry (window expired)
        {
            let mut l = limits.lock().await;
            l.insert(
                "user1".to_string(),
                RateLimitEntry {
                    last_request_at: now_ts() - 120, // 2 minutes ago
                    request_count: 10,
                },
            );
        }

        let limiter = RateLimiter::new(limits.clone(), 60, 3);

        // Should be allowed because window expired
        let result = limiter.check_and_update("user1").await;
        assert!(matches!(result, RateLimitResult::Allowed));

        // Check that count was reset
        let l = limits.lock().await;
        assert_eq!(l.get("user1").unwrap().request_count, 1);
    }

    #[tokio::test]
    async fn test_cleanup() {
        let limits = Arc::new(Mutex::new(HashMap::new()));

        // Insert a mix of fresh and stale entries
        {
            let mut l = limits.lock().await;
            l.insert(
                "fresh".to_string(),
                RateLimitEntry {
                    last_request_at: now_ts(),
                    request_count: 1,
                },
            );
            l.insert(
                "stale".to_string(),
                RateLimitEntry {
                    last_request_at: now_ts() - 300, // 5 minutes ago
                    request_count: 1,
                },
            );
        }

        let limiter = RateLimiter::new(limits.clone(), 60, 3); // 2x window = 120s

        assert_eq!(limits.lock().await.len(), 2);
        let removed = limiter.cleanup().await;
        assert_eq!(removed, 1);
        assert_eq!(limits.lock().await.len(), 1);
    }

    #[tokio::test]
    async fn test_retry_after_calculation() {
        let limits = Arc::new(Mutex::new(HashMap::new()));

        // Insert an entry at specific time
        let start_time = now_ts();
        {
            let mut l = limits.lock().await;
            l.insert(
                "user1".to_string(),
                RateLimitEntry {
                    last_request_at: start_time,
                    request_count: 3,
                },
            );
        }

        let limiter = RateLimiter::new(limits, 60, 3);

        // This will check and update, but since limit is reached, will return Limited
        let result = limiter.check_and_update("user1").await;
        match result {
            RateLimitResult::Limited { retry_after } => {
                // Should be close to 60 seconds (might be slightly less due to timing)
                assert!(retry_after <= 60);
                assert!(retry_after >= 59);
            }
            _ => panic!("Expected rate limited"),
        }
    }
}
