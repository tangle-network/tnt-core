# Blueprint SDK Updates

Minimal changes needed for Tangle v2 EVM-native protocol.

## Overview

The SDK is already well-architected for multi-protocol support:
- Core abstractions (`Job`, `JobCall`, `JobResult`, `Router`) are protocol-agnostic
- `evm-extra` crate already exists with `EVMProducer`
- Only need to make EVM the primary target

## Changes Summary

| Component | Change Level | Description |
|-----------|--------------|-------------|
| Core types | None | Job, JobCall, JobResult, Router unchanged |
| Macros | None | debug_job, FromRef work as-is |
| TangleProducer | Deprecate | Move to legacy/compat module |
| EVMProducer | Primary | Enhance for L3 support |
| Extractors | Add new | ABI-based extractors for EVM |
| Registration | Rewrite | Contract-based registration |
| Consumer | Update | EVM transaction submission |

## New EVM-First Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Application Layer                             │
│                  (Unchanged - Developer Code)                    │
│  #[debug_job]                                                   │
│  async fn my_job(args: AbiArgs<MyInput>) -> impl IntoJobResult  │
└─────────────────────────────────────────────────────────────────┘
                               │
                   Protocol-Agnostic Core
                               │
┌─────────────────────────────────────────────────────────────────┐
│                      Core Layer (Unchanged)                      │
│  - Job<T, Ctx> trait                                            │
│  - JobCall, JobResult                                           │
│  - Router                                                        │
│  - FromJobCall/FromJobCallParts extractors                      │
└─────────────────────────────────────────────────────────────────┘
                               │
                    Protocol Layer (Updated)
                               │
┌─────────────────────────────────────────────────────────────────┐
│                    EVM Protocol Layer                            │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────────┐   │
│  │ EVMProducer   │  │ EVMConsumer   │  │ EVMRegistration   │   │
│  │ (Enhanced)    │  │ (Enhanced)    │  │ (New)             │   │
│  └───────────────┘  └───────────────┘  └───────────────────┘   │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────────┐   │
│  │ AbiArgs<T>    │  │ Events<T>     │  │ ServiceContext    │   │
│  │ (New)         │  │ (Existing)    │  │ (New)             │   │
│  └───────────────┘  └───────────────┘  └───────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## New Extractors

### AbiArgs - ABI-Encoded Arguments

```rust
use alloy_sol_types::{sol, SolType};
use blueprint_sdk::evm::extract::AbiArgs;

// Define your job input types using Alloy's sol! macro
sol! {
    struct ComputeInput {
        uint256 x;
        uint256 y;
        string operation;
    }
}

#[debug_job]
async fn compute(
    AbiArgs(input): AbiArgs<ComputeInput>,
) -> impl IntoJobResult {
    match input.operation.as_str() {
        "add" => AbiResult((input.x + input.y,)),
        "mul" => AbiResult((input.x * input.y,)),
        _ => Err(JobError::InvalidOperation),
    }
}
```

**Implementation:**

```rust
// crates/evm-extra/src/extract/abi_args.rs
use alloy_sol_types::SolType;

pub struct AbiArgs<T>(pub T);

impl<T, Ctx> FromJobCall<Ctx> for AbiArgs<T>
where
    T: SolType + Send + Sync,
    T::RustType: Send + Sync,
{
    type Rejection = AbiDecodeError;

    async fn from_job_call(call: JobCall, _ctx: &Ctx) -> Result<Self, Self::Rejection> {
        let decoded = T::abi_decode(call.body(), true)
            .map_err(|e| AbiDecodeError::DecodeFailed(e.to_string()))?;
        Ok(AbiArgs(decoded))
    }
}

pub struct AbiResult<T>(pub T);

impl<T> IntoJobResult for AbiResult<T>
where
    T: SolType,
{
    fn into_job_result(self) -> Option<JobResult> {
        let encoded = T::abi_encode(&self.0);
        Some(JobResult::ok(Bytes::from(encoded)))
    }
}
```

### ServiceContext - Service Metadata

```rust
use blueprint_sdk::evm::extract::ServiceContext;

#[debug_job]
async fn my_job(
    ctx: ServiceContext,
    AbiArgs(input): AbiArgs<MyInput>,
) -> impl IntoJobResult {
    println!("Service ID: {}", ctx.service_id);
    println!("Blueprint ID: {}", ctx.blueprint_id);
    println!("Caller: {:?}", ctx.caller);
    // ...
}
```

**Implementation:**

```rust
pub struct ServiceContext {
    pub service_id: u64,
    pub blueprint_id: u64,
    pub caller: Address,
    pub block_number: u64,
    pub timestamp: u64,
}

impl<Ctx> FromJobCallParts<Ctx> for ServiceContext {
    type Rejection = MissingMetadata;

    async fn from_job_call_parts(parts: &mut Parts, _ctx: &Ctx) -> Result<Self, Self::Rejection> {
        Ok(ServiceContext {
            service_id: parts.metadata.get_u64("service_id")?,
            blueprint_id: parts.metadata.get_u64("blueprint_id")?,
            caller: parts.metadata.get_address("caller")?,
            block_number: parts.metadata.get_u64("block_number")?,
            timestamp: parts.metadata.get_u64("timestamp")?,
        })
    }
}
```

### Events - Typed Event Extraction

```rust
use blueprint_sdk::evm::extract::Events;
use alloy_sol_types::sol;

sol! {
    event JobCalled(uint64 indexed serviceId, uint8 indexed jobId, uint64 callId, address caller, bytes inputs);
}

#[debug_job]
async fn handle_job_called(
    Events(events): Events<JobCalled>,
) -> impl IntoJobResult {
    for event in events {
        println!("Job {} called on service {}", event.jobId, event.serviceId);
    }
    // ...
}
```

## Enhanced EVMProducer

```rust
// crates/evm-extra/src/producer/mod.rs

use alloy_provider::Provider;
use alloy_rpc_types::{Filter, Log};

pub struct EVMProducerConfig {
    /// RPC endpoint URL
    pub rpc_url: String,
    /// Contract address to watch
    pub contract_address: Address,
    /// Events to listen for (empty = all events from contract)
    pub event_signatures: Vec<B256>,
    /// Polling interval
    pub poll_interval: Duration,
    /// Starting block (None = latest)
    pub from_block: Option<u64>,
    /// Confirmations to wait (for reorg safety)
    pub confirmations: u64,
}

pub struct EVMProducer<P: Provider> {
    provider: P,
    config: EVMProducerConfig,
    last_block: u64,
    pending_logs: VecDeque<Log>,
}

impl<P: Provider> EVMProducer<P> {
    pub fn new(provider: P, config: EVMProducerConfig) -> Self {
        Self {
            provider,
            config,
            last_block: 0,
            pending_logs: VecDeque::new(),
        }
    }

    /// Create producer for Tangle L3
    pub async fn tangle_l3(rpc_url: &str, core_address: Address) -> Result<Self, Error> {
        let provider = ProviderBuilder::new().on_http(rpc_url.parse()?);

        Ok(Self::new(provider, EVMProducerConfig {
            rpc_url: rpc_url.to_string(),
            contract_address: core_address,
            event_signatures: vec![
                keccak256("JobCalled(uint64,uint8,uint64,address,bytes32)"),
            ],
            poll_interval: Duration::from_secs(1),
            from_block: None,
            confirmations: 1,  // L3 has fast finality
        }))
    }
}

impl<P: Provider + Clone + Send + Sync + 'static> Stream for EVMProducer<P> {
    type Item = Result<JobCall, Error>;

    fn poll_next(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        // Return buffered logs first
        if let Some(log) = self.pending_logs.pop_front() {
            return Poll::Ready(Some(Ok(self.log_to_job_call(log))));
        }

        // Poll for new logs
        let filter = Filter::new()
            .address(self.config.contract_address)
            .from_block(self.last_block + 1);

        // ... polling implementation
    }
}

impl<P: Provider> EVMProducer<P> {
    fn log_to_job_call(&self, log: Log) -> JobCall {
        let job_id = JobId::from(log.topics()[1]);

        let mut metadata = MetadataMap::new();
        metadata.insert("service_id", log.topics()[1].to_string());
        metadata.insert("job_id", log.topics()[2].to_string());
        metadata.insert("call_id", log.topics()[3].to_string());
        metadata.insert("block_number", log.block_number.unwrap().to_string());
        metadata.insert("tx_hash", log.transaction_hash.unwrap().to_string());

        let mut extensions = Extensions::new();
        extensions.insert(log.clone());

        JobCall::from_parts(
            Parts {
                job_id,
                metadata,
                extensions,
            },
            Bytes::from(log.data.data.to_vec()),
        )
    }
}
```

## Enhanced EVMConsumer

```rust
// crates/evm-extra/src/consumer/mod.rs

pub struct EVMConsumerConfig {
    pub rpc_url: String,
    pub core_address: Address,
    pub signer: LocalWallet,
    pub gas_limit: u64,
    pub max_fee_per_gas: Option<u128>,
}

pub struct EVMConsumer<P: Provider, S: Signer> {
    provider: P,
    signer: S,
    core_contract: TangleCoreInstance<P>,
    config: EVMConsumerConfig,
}

impl<P, S> EVMConsumer<P, S>
where
    P: Provider + Clone,
    S: Signer,
{
    pub async fn submit_result(
        &self,
        service_id: u64,
        call_id: u64,
        result: Bytes,
    ) -> Result<TxHash, Error> {
        let tx = self.core_contract
            .submitResult(service_id, call_id, result)
            .gas(self.config.gas_limit);

        let pending = tx.send().await?;
        let receipt = pending.get_receipt().await?;

        Ok(receipt.transaction_hash)
    }

    pub async fn submit_result_batch(
        &self,
        service_id: u64,
        results: Vec<(u64, Bytes)>,
    ) -> Result<TxHash, Error> {
        let call_ids: Vec<u64> = results.iter().map(|(id, _)| *id).collect();
        let outputs: Vec<Bytes> = results.into_iter().map(|(_, out)| out).collect();

        let tx = self.core_contract
            .submitResultBatch(service_id, call_ids, outputs)
            .gas(self.config.gas_limit * results.len() as u64);

        let pending = tx.send().await?;
        let receipt = pending.get_receipt().await?;

        Ok(receipt.transaction_hash)
    }
}

impl<P, S> Sink<JobResult> for EVMConsumer<P, S>
where
    P: Provider + Clone + Send + Sync + 'static,
    S: Signer + Send + Sync + 'static,
{
    type Error = Error;

    fn poll_ready(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        Poll::Ready(Ok(()))
    }

    fn start_send(self: Pin<&mut Self>, result: JobResult) -> Result<(), Self::Error> {
        let service_id = result.metadata().get_u64("service_id")?;
        let call_id = result.metadata().get_u64("call_id")?;

        // Spawn submission task
        tokio::spawn(async move {
            self.submit_result(service_id, call_id, result.into_body()).await
        });

        Ok(())
    }

    fn poll_flush(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        Poll::Ready(Ok(()))
    }

    fn poll_close(self: Pin<&mut Self>, _cx: &mut Context<'_>) -> Poll<Result<(), Self::Error>> {
        Poll::Ready(Ok(()))
    }
}
```

## New Registration Flow

```rust
// crates/evm-extra/src/registration/mod.rs

use alloy_contract::ContractInstance;

pub struct EVMRegistration {
    core: TangleCoreInstance,
    signer: LocalWallet,
}

impl EVMRegistration {
    /// Register a new blueprint
    pub async fn register_blueprint(&self, definition: BlueprintDefinition) -> Result<u64, Error> {
        let tx = self.core
            .createBlueprint(definition)
            .send()
            .await?;

        let receipt = tx.get_receipt().await?;

        // Extract blueprint ID from event
        let event = receipt
            .logs()
            .iter()
            .find(|log| log.topics()[0] == keccak256("BlueprintCreated(uint64,address,address,string)"))
            .ok_or(Error::EventNotFound)?;

        let blueprint_id = u64::from_be_bytes(event.topics()[1].0[24..32].try_into()?);
        Ok(blueprint_id)
    }

    /// Register operator to blueprint
    pub async fn register_operator(
        &self,
        blueprint_id: u64,
        preferences: Bytes,
        registration_inputs: Bytes,
    ) -> Result<TxHash, Error> {
        let tx = self.core
            .registerOperator(blueprint_id, preferences, registration_inputs)
            .send()
            .await?;

        Ok(tx.get_receipt().await?.transaction_hash)
    }
}

/// BlueprintConfig implementation for EVM
pub struct EVMBlueprintConfig {
    pub blueprint_id: Option<u64>,
    pub metadata_uri: String,
    pub manager_address: Address,
    pub code_hash: B256,
}

impl BlueprintConfig for EVMBlueprintConfig {
    async fn register(&self, env: &BlueprintEnvironment) -> Result<(), Error> {
        let registration = EVMRegistration::new(env)?;

        let blueprint_id = registration.register_blueprint(
            self.metadata_uri.clone(),
            self.manager_address,
            self.code_hash,
        ).await?;

        println!("Blueprint registered with ID: {}", blueprint_id);
        Ok(())
    }

    async fn requires_registration(&self, env: &BlueprintEnvironment) -> Result<bool, Error> {
        // Check if already registered
        Ok(self.blueprint_id.is_none())
    }

    fn should_exit_after_registration(&self) -> bool {
        false
    }
}
```

## Updated BlueprintRunner Usage

```rust
use blueprint_sdk::{
    BlueprintRunner,
    evm::{EVMProducer, EVMConsumer, EVMBlueprintConfig},
    Router,
};

#[tokio::main]
async fn main() -> Result<()> {
    // Load environment
    let env = BlueprintEnvironment::load()?;

    // Create router with job handlers
    let router = Router::new()
        .route(JobId::from(1u8), compute_job)
        .route(JobId::from(2u8), verify_job)
        .fallback(unknown_job);

    // Create EVM config
    let config = EVMBlueprintConfig {
        blueprint_id: env.get_blueprint_id(),
        metadata_uri: env.get_metadata_uri()?,
        manager_address: env.get_manager_address()?,
        code_hash: env.get_code_hash()?,
    };

    // Run
    BlueprintRunner::builder(config, env)
        .router(router)
        .evm_producer(EVMProducerConfig {
            rpc_url: env.rpc_url(),
            contract_address: env.core_address(),
            poll_interval: Duration::from_secs(1),
            ..Default::default()
        })
        .evm_consumer(EVMConsumerConfig {
            rpc_url: env.rpc_url(),
            core_address: env.core_address(),
            signer: env.signer()?,
            ..Default::default()
        })
        .with_heartbeat(HeartbeatConfig::default())
        .with_metrics(MetricsConfig::default())
        .run()
        .await
}
```

## Migration Guide for Existing Blueprints

### Step 1: Update Dependencies

```toml
# Cargo.toml
[dependencies]
blueprint-sdk = { version = "2.0", features = ["evm"] }
alloy-sol-types = "0.7"
alloy-primitives = "0.7"
```

### Step 2: Convert Types

```rust
// Before (Substrate/SCALE)
use blueprint_sdk::tangle::TangleArg;

#[debug_job]
async fn my_job(
    TangleArg(x): TangleArg<u64>,
    TangleArg(y): TangleArg<String>,
) -> impl IntoJobResult {
    // ...
}

// After (EVM/ABI)
use blueprint_sdk::evm::AbiArgs;
use alloy_sol_types::sol;

sol! {
    struct MyJobInput {
        uint64 x;
        string y;
    }
}

#[debug_job]
async fn my_job(
    AbiArgs(input): AbiArgs<MyJobInput>,
) -> impl IntoJobResult {
    let x = input.x;
    let y = input.y;
    // ... same logic
}
```

### Step 3: Update Result Types

```rust
// Before
fn my_job() -> impl IntoJobResult {
    MyResult { value: 42 }  // SCALE encoded
}

// After
use blueprint_sdk::evm::AbiResult;

sol! {
    struct MyResult {
        uint256 value;
    }
}

fn my_job() -> impl IntoJobResult {
    AbiResult(MyResult { value: U256::from(42) })
}
```

### Step 4: Update Runner Configuration

```rust
// Before
BlueprintRunner::builder(TangleConfig::default(), env)
    .router(router)
    .run()
    .await

// After
BlueprintRunner::builder(EVMBlueprintConfig::new(env)?, env)
    .router(router)
    .evm_producer(EVMProducerConfig::from_env(&env)?)
    .evm_consumer(EVMConsumerConfig::from_env(&env)?)
    .run()
    .await
```

## Backwards Compatibility

For gradual migration, support both protocols:

```rust
#[cfg(feature = "tangle-legacy")]
mod tangle {
    // Existing Substrate-based implementation
}

#[cfg(feature = "evm")]
mod evm {
    // New EVM-based implementation
}

// Generic extractor that works with both
pub struct Args<T>(pub T);

impl<T, Ctx> FromJobCall<Ctx> for Args<T>
where
    T: Decode + SolType,  // Support both
{
    async fn from_job_call(call: JobCall, _ctx: &Ctx) -> Result<Self, Rejection> {
        // Try ABI first, fall back to SCALE
        if let Ok(decoded) = T::abi_decode(call.body(), true) {
            return Ok(Args(decoded));
        }
        if let Ok(decoded) = T::decode(&mut call.body().as_ref()) {
            return Ok(Args(decoded));
        }
        Err(Rejection::DecodeFailed)
    }
}
```

## Testing

```rust
#[cfg(test)]
mod tests {
    use blueprint_sdk::testing::*;

    #[tokio::test]
    async fn test_job_handler() {
        // Create test job call with ABI-encoded input
        let input = MyJobInput { x: 42, y: "hello".to_string() };
        let call = JobCall::new(
            JobId::from(1u8),
            Bytes::from(input.abi_encode()),
        );

        // Execute handler
        let result = my_job.call(call, ()).await;

        // Verify result
        assert!(result.is_some());
        let output: MyResult = result.unwrap().abi_decode()?;
        assert_eq!(output.value, expected);
    }
}
```

## File Structure

```
blueprint-sdk/
├── crates/
│   ├── core/                    # Unchanged
│   │   ├── src/
│   │   │   ├── job/
│   │   │   ├── extract/
│   │   │   └── ...
│   ├── router/                  # Unchanged
│   ├── runner/                  # Minor updates
│   ├── macros/                  # Unchanged
│   ├── evm-extra/               # Primary protocol (enhanced)
│   │   ├── src/
│   │   │   ├── producer/
│   │   │   ├── consumer/
│   │   │   ├── extract/
│   │   │   │   ├── abi_args.rs  # New
│   │   │   │   ├── events.rs
│   │   │   │   └── context.rs   # New
│   │   │   ├── registration/    # New
│   │   │   └── lib.rs
│   └── tangle-extra/            # Legacy (deprecated)
│       └── ...
```
