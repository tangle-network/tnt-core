use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::Mutex;
use tracing::info;

use crate::types::CachedProof;

/// Proof cache for deduplication
pub struct ProofCache {
    cache: Arc<Mutex<HashMap<String, CachedProof>>>,
    ttl_seconds: u64,
}

impl ProofCache {
    pub fn new(cache: Arc<Mutex<HashMap<String, CachedProof>>>, ttl_seconds: u64) -> Self {
        Self { cache, ttl_seconds }
    }

    /// Get a cached proof if it exists and is not expired
    pub async fn get(&self, key: &str) -> Option<CachedProof> {
        let cache = self.cache.lock().await;
        if let Some(proof) = cache.get(key) {
            if !proof.is_expired(self.ttl_seconds) {
                return Some(proof.clone());
            }
        }
        None
    }

    /// Clean up expired entries
    pub async fn cleanup(&self) -> usize {
        let mut cache = self.cache.lock().await;
        let before = cache.len();
        cache.retain(|_, v| !v.is_expired(self.ttl_seconds));
        let removed = before - cache.len();
        if removed > 0 {
            info!("Cache cleanup: removed {} expired entries", removed);
        }
        removed
    }
}

/// Start a background task to periodically clean up the cache
pub fn start_cache_cleanup_task(
    cache: Arc<Mutex<HashMap<String, CachedProof>>>,
    ttl_seconds: u64,
    cleanup_interval_seconds: u64,
) {
    let proof_cache = ProofCache::new(cache, ttl_seconds);
    tokio::spawn(async move {
        let mut interval =
            tokio::time::interval(std::time::Duration::from_secs(cleanup_interval_seconds));
        loop {
            interval.tick().await;
            proof_cache.cleanup().await;
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::types::now_ts;

    #[tokio::test]
    async fn test_cache_get() {
        let cache = Arc::new(Mutex::new(HashMap::new()));

        // Insert directly into the HashMap (as production code does)
        {
            let mut c = cache.lock().await;
            c.insert(
                "key1".to_string(),
                CachedProof::new("proof1".to_string(), "values1".to_string()),
            );
        }

        let proof_cache = ProofCache::new(cache, 60);
        let result = proof_cache.get("key1").await;
        assert!(result.is_some());
        let cached = result.unwrap();
        assert_eq!(cached.zk_proof, "proof1");
        assert_eq!(cached.public_values, "values1");
    }

    #[tokio::test]
    async fn test_cache_miss() {
        let cache = Arc::new(Mutex::new(HashMap::new()));
        let proof_cache = ProofCache::new(cache, 60);

        let result = proof_cache.get("nonexistent").await;
        assert!(result.is_none());
    }

    #[tokio::test]
    async fn test_cache_expired() {
        let cache = Arc::new(Mutex::new(HashMap::new()));

        // Insert an already-expired entry
        {
            let mut c = cache.lock().await;
            c.insert(
                "expired_key".to_string(),
                CachedProof {
                    zk_proof: "old_proof".to_string(),
                    public_values: "old_values".to_string(),
                    created_at: now_ts() - 120, // 2 minutes ago
                },
            );
        }

        let proof_cache = ProofCache::new(cache, 60); // 1 minute TTL

        // Should return None because entry is expired
        let result = proof_cache.get("expired_key").await;
        assert!(result.is_none());
    }

    #[tokio::test]
    async fn test_cache_cleanup() {
        let cache = Arc::new(Mutex::new(HashMap::new()));

        // Insert a mix of fresh and expired entries
        {
            let mut c = cache.lock().await;
            c.insert(
                "fresh".to_string(),
                CachedProof::new("proof".to_string(), "values".to_string()),
            );
            c.insert(
                "expired1".to_string(),
                CachedProof {
                    zk_proof: "old".to_string(),
                    public_values: "old".to_string(),
                    created_at: now_ts() - 120,
                },
            );
            c.insert(
                "expired2".to_string(),
                CachedProof {
                    zk_proof: "old".to_string(),
                    public_values: "old".to_string(),
                    created_at: now_ts() - 200,
                },
            );
        }

        let proof_cache = ProofCache::new(cache.clone(), 60);

        assert_eq!(cache.lock().await.len(), 3);
        let removed = proof_cache.cleanup().await;
        assert_eq!(removed, 2);
        assert_eq!(cache.lock().await.len(), 1);

        // Fresh entry should still be there
        assert!(proof_cache.get("fresh").await.is_some());
    }
}
