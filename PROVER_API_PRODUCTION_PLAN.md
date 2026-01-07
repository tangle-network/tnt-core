Prover API Production Plan (No Database)

## Implementation Status: PARTIAL

This plan is partially implemented. See the modular implementation in:
- `src/types.rs` - Core types and error codes
- `src/validation.rs` - Input validation with comprehensive tests
- `src/cache.rs` - Proof deduplication cache with TTL
- `src/rate_limit.rs` - Per-address rate limiting
- `src/queue.rs` - Bounded job queue with worker pool
- `src/jobs.rs` - Job map TTL cleanup
- `src/prover.rs` - Proof generation with timeouts
- `src/handlers.rs` - HTTP handlers with structured error responses
- `src/config.rs` - Configuration loading and validation
- `src/main.rs` - Application entry point

Only item 9 (API authentication) remains unimplemented.

### Running Tests
```bash
# Run unit tests (doesn't require SP1)
cargo test --lib --no-default-features

# Run integration tests (requires running server)
./scripts/test-api.sh
```

---

Scope
- This plan applies to the SP1 prover API in `packages/migration-claim/sp1/prover-api/src/main.rs`.
- Goal: prevent redundant proof generation and harden the API for production without adding a database.
- Constraint: all state is in memory and resets on restart.

1) Block already-claimed users before proving ✅ IMPLEMENTED
What it is
- A check that determines whether a user has already claimed on the EVM contract.
- If the user has already claimed, the API rejects the request and does not generate a proof.

Why it is needed
- Generating a proof costs money and CPU.
- If a user already claimed, the proof is useless and wastes resources.
- This is the most direct way to stop redundant proofs.

Approach
- Add a contract read call (eth_call) to the claim contract’s `claimed` (or equivalent) view function.
- Run this check at the start of the request handler, before job creation and before any prover work starts.
- If the contract returns `true`, return 409 (or 400) with a clear error message.
- If the contract call fails, return a retriable error (503) so clients can try again.

Implementation notes
- Build a minimal ABI call using `alloy_sol_types::sol!` for the `claimed(address)` view function.
- Use a reqwest client with a timeout (e.g., 5-10 seconds).
- Use the same RPC URL as `VERIFY_ONCHAIN_RPC_URL` or `RPC_URL` so configuration stays consistent.

2) In-memory proof deduplication cache ✅ IMPLEMENTED
What it is
- A cache that stores completed proof results so repeated identical requests return instantly.

Why it is needed
- Users may retry the same request due to frontend refreshes, network errors, or impatience.
- Without caching, each retry triggers full proof generation and cost.

Approach
- Create a cache key using immutable request fields:
  `cache_key = ss58_address + "|" + evm_address + "|" + amount + "|" + challenge`
- Store `proof`, `public_values`, and `created_at` in a HashMap.
- When a new request arrives:
  - If the cache has a fresh entry, return it immediately and skip proof generation.
  - If not, proceed to create a job and generate a new proof.
- Add a TTL (e.g., 10-60 minutes) so the cache does not grow forever.

Implementation notes
- Use `Arc<Mutex<HashMap<String, CachedProof>>>`.
- Add a background cleanup task that runs every N minutes and removes expired entries.
- TTL can be a config value, e.g. `CACHE_TTL_SECONDS`.
- If the signature is part of authorization (not just a circuit input), include it in the
  cache key to avoid returning a cached proof to a request with a bad signature.

3) Per-address rate limiting ✅ IMPLEMENTED
What it is
- A simple limiter that prevents the same address from requesting too frequently.

Why it is needed
- Even with cache, attackers can rotate inputs slightly to force new proofs.
- Rate limits reduce abuse and lower cost.

Approach
- Track the last request time per address in memory.
- Reject if a new request is within a configured window (e.g., 1 per 5 minutes).
- Return 429 with a message like "Too many requests. Try again later."

Implementation notes
- Use `Arc<Mutex<HashMap<String, u64>>>` keyed by EVM address or ss58 address.
- Optionally, separate limits per address and per IP for broader protection.

4) Bounded job queue and worker pool ✅ IMPLEMENTED
What it is
- A fixed-size queue with a fixed number of workers that process jobs.
- The API refuses new jobs when the queue is full.

Why it is needed
- `tokio::spawn` per request can create unbounded concurrent work.
- A surge can exhaust CPU and memory and take the service down.
- Bounded queues create backpressure and predictable performance.

Approach
- Create a bounded channel (e.g., capacity 100).
- Spawn N workers on startup (e.g., 2-8 based on CPU).
- The request handler pushes a job onto the queue.
- If the queue is full, return 503 or 429.

Implementation notes
- Use `tokio::sync::mpsc::channel(capacity)`.
- Each worker reads from the channel and calls `generate_proof`.
- Track job status updates the same way as now, but processing is centralized.
- Ensure queue size is tracked from the same counter used by the worker pool.
  Do not create a new counter from a sender-only handle.

5) Enforce proof verification in production ✅ IMPLEMENTED
What it is
- A rule that proofs must be verified before they are returned when running in production mode.

Why it is needed
- Returning unverified proofs can lead to invalid claims, failed user flows, or security risk.
- In production, correctness should be guaranteed.

Approach
- If `SP1_PROVER=network`, require `VERIFY_PROOF=true`.
- If not set, exit at startup or reject requests with a clear error.
- Optionally include a response flag `verified: true` for transparency.

Implementation notes
- Add a startup check after reading env vars.
- Keep the flexibility for local testing with `SP1_PROVER=mock`.

6) Timeouts for proof generation and RPC calls ✅ IMPLEMENTED
What it is
- A time limit for expensive operations so they cannot hang forever.

Why it is needed
- Unbounded blocking tasks can tie up workers and prevent progress.
- RPC calls can hang or be slow under network issues.

Approach
- Wrap `spawn_blocking` in `tokio::time::timeout` (e.g., 5-10 minutes).
- Configure reqwest client with connect and read timeouts (e.g., 5-10 seconds).
- If timeouts occur, mark job failed with a clear error.

Implementation notes
- For prover timeout: `tokio::time::timeout(prove_timeout, spawn_blocking(...))`.
- For RPC: `reqwest::Client::builder().timeout(Duration::from_secs(...))`.
- Use a single configured timeout value (e.g., `RPC_TIMEOUT_SECONDS`) consistently.

7) Strong input validation before job creation ✅ IMPLEMENTED
What it is
- Strict checks on input format and sizes before accepting a job.

Why it is needed
- Bad inputs can waste compute or cause confusing errors.
- It is cheaper to reject invalid requests up front.

Approach
- Validate hex lengths before creating the job:
  - `signature` must be 64 bytes
  - `evm_address` must be 20 bytes
  - `challenge` must be 32 bytes
- Validate `amount` as base-10 and within expected range if applicable.
- Validate `ss58_address` with `ss58_decode` before starting proof generation.

Implementation notes
- Move parsing into `submit_job` and return 400 on failure.
- Keep `generate_proof` as a last line of defense.

8) Add clear error responses and client guidance ✅ IMPLEMENTED
What it is
- Consistent error codes and messages so clients can respond correctly.

Why it is needed
- Clients need to know if they should retry, fix input, or stop.
- It reduces support load and improves UX.

Approach
- Use a structured error response with `code` and `message`.
- Example codes: `already_claimed`, `rate_limited`, `invalid_input`, `queue_full`, `timeout`, `rpc_unavailable`.

Implementation notes
- Extend `StatusResponse` or add a new error payload shape for failed submissions.
- Keep a stable contract for frontend consumption.

9) API authentication/authorization ❌ NOT IMPLEMENTED
What it is
- A gate that restricts access to the prover API to trusted clients.

Why it is needed
- Proof generation costs money; open endpoints are easy to abuse.
- Auth also enables better rate limiting and usage tracking.

Approach
- Require `Authorization` header with API key or JWT.
- Reject unauthenticated requests before validation, cache, or chain calls.

Implementation notes
- For API keys, load a comma-separated list from env (e.g., `API_KEYS`).
- For JWT, validate signature and expiry using a shared secret.

10) Request body size limits ✅ IMPLEMENTED
What it is
- A hard cap on the maximum request size.

Why it is needed
- Prevents large payloads from consuming memory or causing slow parsing.

Approach
- Configure an Axum body limit (e.g., 1–4 KB) on the router or per-route.
- Return 413 Payload Too Large if exceeded.

Implementation notes
- `MAX_BODY_BYTES` env var (default: 4096 = 4 KB).
- Uses Axum's `DefaultBodyLimit::max()` layer on the router.

11) Job map TTL cleanup ✅ IMPLEMENTED
What it is
- Periodic removal of old job entries.

Why it is needed
- The jobs map grows forever; long-running services will leak memory.

Approach
- Keep async polling (`/status/:job_id`) but delete old completed/failed jobs after a TTL.
- Keep in-progress jobs until they finish to avoid losing active work.
- Choose a TTL that balances user polling time and memory growth (e.g., 10–60 minutes).

Implementation notes
- `JOBS_TTL_SECONDS` env var (default: 600 = 10 minutes).
- Implemented in `src/jobs.rs` with `start_jobs_cleanup_task`.
- Cleanup runs every 60 seconds.
- Only removes completed/failed jobs; keeps pending/running jobs regardless of age.

12) Accurate queue size reporting ✅ IMPLEMENTED
What it is
- Health endpoint should expose real queue depth.

Why it is needed
- Operators need visibility into backlog and load.

Approach
- Track queue size in a shared atomic counter.
- Expose it in `/health`.

Implementation notes
- Added `queue_size: Option<Arc<AtomicUsize>>` to `AppState`.
- Health endpoint reads from the shared counter using `Ordering::SeqCst`.
- Counter is incremented on enqueue and decremented when workers pick up jobs.

Trade-offs of the in-memory design vs adding a DB
- No persistence: all jobs, cache, and rate limits reset on restart or crash.
- Single-instance only: each instance has its own memory state, so scaling horizontally causes inconsistent results.
- Rate limits are local: users can bypass limits by hitting a different instance.
- No audit trail: you do not get a durable record of who requested proofs.
- Limited observability: you cannot analyze historical usage or cost trends from stored data.
- Simpler operations: no new infrastructure, no migrations, and no DB maintenance.

When a DB or Redis becomes worth it
- You run more than one instance or need autoscaling.
- You need persistent caching across deploys.
- You want reporting, auditing, or cost attribution.
- You want stronger abuse controls across all instances.
