# Current Tangle Protocol Architecture

## Overview

Tangle is a Substrate-based restaking protocol where:
- **Operators** stake assets and register to provide off-chain services
- **Developers** deploy Blueprints (service templates) that operators can run
- **Customers** request service instances, pay for them, and submit jobs
- **Delegators** stake assets to operators and earn rewards

## Core Components

### 1. Services Pallet (`tangle/pallets/services`)

The heart of the protocol. Manages:

**Storage:**
- `Blueprints` - Blueprint definitions (metadata, constraints, hooks contract)
- `Operators` - Per-blueprint operator registrations with preferences
- `ServiceRequests` - Pending service instantiation requests
- `Instances` - Active service instances with operators and config
- `ServiceHeartbeats` - Operator liveness tracking per service

**Key Extrinsics:**
- `create_blueprint` - Developer deploys blueprint definition
- `register/unregister` - Operator joins/leaves blueprint
- `request` - Customer requests service instance
- `approve/reject` - Operators approve/reject requests
- `call` - Submit job to service
- `submit_result` - Operator submits job result
- `slash/dispute` - Slashing and dispute mechanism
- `heartbeat` - Operator liveness proof

**EVM Integration:**
- Calls into `IBlueprintServiceManager` contracts for hooks
- Uses `EvmRunner` trait to execute EVM transactions
- Address mapping between Substrate AccountId and EVM H160

### 2. Multi-Asset-Delegation Pallet (`tangle/pallets/multi-asset-delegation`)

Manages staking and delegation:

**Operators:**
- `join_operators` - Register as operator with stake
- `operator_bond_more/schedule_operator_unstake` - Stake management
- `go_offline/go_online` - Availability status

**Delegators:**
- `deposit` - Deposit assets (native or ERC20)
- `delegate` - Delegate to operator with blueprint selection
- `schedule_delegator_unstake` - Begin unstaking
- Supports `DelegatorBlueprintSelection::Fixed(vec![])` or `All`

**Slashing:**
- `SlashManager` trait implementation
- Proportional slashing of operator and delegators
- Round-based snapshots for reward calculation

### 3. Rewards Pallet (`tangle/pallets/rewards`)

Pool-based reward distribution:

**Mechanism:**
- `record_reward(operator, service_id, amount)` - Record service rewards
- Commission split: operator gets `DefaultOperatorCommission`, rest goes to delegator pool
- `OperatorRewardPools` - Accumulated rewards per share (Masterchef-style)
- `DelegatorRewardDebts` - Delegator claim checkpoint
- O(1) claims via accumulated-per-share math

**Vaults:**
- Asset vaults with APY configuration
- Deposit caps and incentive caps
- Lock multipliers for boosted rewards

### 4. Credits Pallet (`tangle/pallets/credits`)

Off-chain credit accrual:

- Stake-tier based credit emission
- Window-based claiming (prevents infinite accrual)
- `burn()` - Burn TNT for immediate credits
- `claim_credits()` - Claim accrued staking credits
- Events emitted for off-chain processing

## Blueprint SDK Architecture

### Core Abstractions

```
Job<T, Ctx> trait
├── Async function handlers
├── Tower Service integration
└── Middleware via Layer pattern

JobCall { head: Parts, body: Bytes }
├── JobId (256-bit identifier)
├── MetadataMap (key-value strings)
└── Extensions (type-erased storage)

JobResult { head: Parts, body: Bytes | Error }
```

### Event Flow

```
Blockchain Events
      ↓
TangleProducer (Stream<JobCall>)
      ↓
BlueprintRunner
      ↓
Router.call(job_call)
      ↓
Job extraction & execution
      ↓
JobResult
      ↓
TangleConsumer (Sink<JobResult>)
      ↓
submit_result extrinsic
```

### Key SDK Components

- **BlueprintRunner** - Main orchestrator, manages lifecycle
- **Router** - Job routing by JobId
- **TangleProducer** - Listens to Substrate events, converts to JobCall
- **TangleConsumer** - Submits results back to chain
- **Extractors** - Dependency injection (Context, CallId, ServiceId, TangleArg)
- **BlueprintConfig** - Protocol-specific registration

## TNT-Core Contracts

### Current Hook Architecture

```solidity
interface IBlueprintServiceManager {
    // Blueprint lifecycle
    function onBlueprintCreated(uint64 blueprintId, address owner, address mbsm) external;

    // Operator lifecycle
    function onRegister(OperatorPreferences calldata operator, bytes calldata inputs) external payable;
    function onUnregister(OperatorPreferences calldata operator) external;

    // Service lifecycle
    function onRequest(RequestParams calldata params) external payable;
    function onApprove(OperatorPreferences calldata op, uint64 reqId, uint8 restakingPct) external payable;
    function onReject(OperatorPreferences calldata op, uint64 reqId) external;
    function onServiceInitialized(uint64 reqId, uint64 svcId, address owner, address[] callers, uint64 ttl) external;

    // Job lifecycle
    function onJobCall(uint64 svcId, uint8 job, uint64 callId, bytes calldata inputs) external payable;
    function onJobResult(uint64 svcId, uint8 job, uint64 callId, OperatorPreferences calldata op, bytes inputs, bytes outputs) external payable;

    // Slashing
    function onUnappliedSlash(uint64 svcId, bytes calldata offender, uint8 pct) external;
    function onSlash(uint64 svcId, bytes calldata offender, uint8 pct) external;

    // Dynamic membership
    function canJoin(uint64 svcId, OperatorPreferences calldata op) external view returns (bool);
    function canLeave(uint64 svcId, OperatorPreferences calldata op) external view returns (bool);
}
```

### Payment Distribution (MBSM)

```
Default Tranches:
├── Developer: 50%
├── Protocol:  20%
├── Operators: 10% → REWARDS_PALLET
└── Restakers: 20% → REWARDS_PALLET
```

## Current Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     SUBSTRATE RUNTIME                            │
│  ┌──────────────┐  ┌────────────────────┐  ┌────────────────┐  │
│  │   Services   │──│  MultiAssetDeleg   │──│    Rewards     │  │
│  │    Pallet    │  │      Pallet        │  │    Pallet      │  │
│  └──────┬───────┘  └────────────────────┘  └────────────────┘  │
│         │                                                        │
│         │ EVM Precompile Calls                                  │
│         ↓                                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    pallet-evm                             │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │     MasterBlueprintServiceManager (MBSM)           │  │   │
│  │  │              ↓                                      │  │   │
│  │  │     BlueprintServiceManager (per-blueprint)        │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Events (JobCalled, etc.)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     BLUEPRINT SDK                                │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────────────┐   │
│  │TangleProducer│──│ BlueprintRunner│──│  TangleConsumer    │   │
│  └──────────────┘  └────────────────┘  └────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Key Observations

### Strengths
1. **Flexible hook system** - Developers can customize all lifecycle events
2. **Multi-asset support** - Native + ERC20 + custom asset IDs
3. **Pool-based rewards** - O(1) delegator claims
4. **Clean SDK abstractions** - Tower-based, extractors, middleware

### Substrate Dependencies
1. **Storage** - All state in pallet storage items
2. **Extrinsics** - Substrate transaction format
3. **Events** - Substrate event emission
4. **Address format** - 32-byte AccountId vs 20-byte EVM
5. **Weight system** - Substrate weight vs EVM gas
6. **parity-scale-codec** - SCALE encoding in SDK

### EVM Integration Points Already Present
1. Hook contracts in tnt-core
2. ERC20 deposit/transfer in multi-asset-delegation
3. Address mapping utilities
4. EvmRunner trait for EVM calls from pallets
