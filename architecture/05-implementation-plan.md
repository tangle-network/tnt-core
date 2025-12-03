# Implementation Plan

Full rebuild on `v2` branch across all repositories.

## Repository Setup

### tnt-core (This Repo)
```bash
git checkout -b v2
# Contains: All protocol Solidity contracts
```

### blueprint-sdk
```bash
git checkout -b v2
# Contains: Updated SDK with EVM-first approach
```

### tangle (Reference Only)
```bash
# Keep as reference for migration
# No v2 branch needed - protocol moves to pure EVM
```

## Build Order

```
Phase 1: Core Contracts (tnt-core)
    │
    ▼
Phase 2: Security Interfaces (tnt-core)
    │
    ▼
Phase 3: Hook System (tnt-core)
    │
    ▼
Phase 4: SDK Updates (blueprint-sdk)
    │
    ▼
Phase 5: Integration Testing
    │
    ▼
Phase 6: L3 Deployment
```

## Phase 1: Core Contracts

**Location:** `tnt-core/src/core/`

### 1.1 Interfaces

```
src/
├── interfaces/
│   ├── IBlueprintRegistry.sol
│   ├── IServiceManager.sol
│   ├── IJobManager.sol
│   └── IRewardsDistributor.sol
```

**Tasks:**
- [ ] Define `IBlueprintRegistry` interface
- [ ] Define `IServiceManager` interface
- [ ] Define `IJobManager` interface
- [ ] Define `IRewardsDistributor` interface

### 1.2 Core Implementations

```
src/
├── core/
│   ├── TangleCore.sol
│   ├── BlueprintRegistry.sol
│   ├── ServiceManager.sol
│   └── JobManager.sol
```

**Tasks:**
- [ ] Implement `BlueprintRegistry`
  - Blueprint creation
  - Operator registration per blueprint
  - Metadata storage
- [ ] Implement `ServiceManager`
  - Service request flow
  - Approval/rejection handling
  - Service activation
  - Service termination
- [ ] Implement `JobManager`
  - Job call creation
  - Result submission
  - Batch operations
- [ ] Implement `TangleCore` facade
  - Coordinate between modules
  - Payment handling
  - Access control

### 1.3 Rewards

```
src/
├── rewards/
│   └── RewardsDistributor.sol
```

**Tasks:**
- [ ] Implement Masterchef-style pool
- [ ] Operator commission handling
- [ ] Delegator reward accumulation
- [ ] Claim functions

### 1.4 Libraries

```
src/
├── libraries/
│   ├── Assets.sol           # Existing, update
│   ├── ServiceOperators.sol # Existing, update
│   └── Errors.sol           # New
```

**Tasks:**
- [ ] Update `Assets.sol` for v2
- [ ] Update `ServiceOperators.sol` for v2
- [ ] Create unified `Errors.sol`

## Phase 2: Security Interfaces

**Location:** `tnt-core/src/security/`

### 2.1 Interface

```
src/
├── security/
│   ├── ISecurityManager.sol
│   └── ISecurityManagerAdmin.sol
```

**Tasks:**
- [ ] Define `ISecurityManager` interface
  - Operator queries
  - Delegation queries
  - Stake requirements
  - Slashing interface
  - Rewards notification

### 2.2 Native Implementation

```
src/
├── security/
│   └── NativeSecurityManager.sol
```

**Tasks:**
- [ ] Implement operator registration
- [ ] Implement stake deposits (native + ERC20)
- [ ] Implement delegation flow
- [ ] Implement slashing logic
- [ ] Implement unstaking with delays

### 2.3 EigenLayer Adapter

```
src/
├── security/
│   └── EigenLayerSecurityManager.sol
```

**Tasks:**
- [ ] AVS registration
- [ ] Read stake from EigenLayer contracts
- [ ] Map operators to blueprints
- [ ] Route slashing through EigenLayer

### 2.4 Symbiotic Adapter

```
src/
├── security/
│   └── SymbioticSecurityManager.sol
```

**Tasks:**
- [ ] Symbiotic vault integration
- [ ] Operator registration
- [ ] Stake queries
- [ ] Slashing integration

## Phase 3: Hook System

**Location:** `tnt-core/src/hooks/`

### 3.1 Interface (Preserve Existing)

```
src/
├── hooks/
│   ├── IBlueprintServiceManager.sol  # Existing, minor updates
│   └── BlueprintServiceManagerBase.sol  # Existing, update
```

**Tasks:**
- [ ] Review and update `IBlueprintServiceManager`
  - Ensure compatibility with new flow
  - Add any new hooks needed
- [ ] Update `BlueprintServiceManagerBase`
  - Update internal references
  - Maintain developer API

### 3.2 Example Implementation

```
src/
├── examples/
│   └── SimpleServiceManager.sol
```

**Tasks:**
- [ ] Create minimal example
- [ ] Document hook implementation

## Phase 4: SDK Updates

**Location:** `blueprint-sdk/`

### 4.1 New EVM Extractors

```
crates/evm-extra/src/extract/
├── abi_args.rs    # New
├── context.rs     # New
├── events.rs      # Update
└── mod.rs
```

**Tasks:**
- [ ] Implement `AbiArgs<T>` extractor
- [ ] Implement `AbiResult<T>` return type
- [ ] Implement `ServiceContext` extractor
- [ ] Update `Events<T>` for new event format

### 4.2 Enhanced Producer

```
crates/evm-extra/src/producer/
├── mod.rs
├── polling.rs     # Update
└── config.rs      # New
```

**Tasks:**
- [ ] Add L3-specific configuration
- [ ] Implement reorg handling
- [ ] Add batch event processing
- [ ] Add metrics/logging

### 4.3 Enhanced Consumer

```
crates/evm-extra/src/consumer/
├── mod.rs
├── submission.rs  # New
└── batching.rs    # New
```

**Tasks:**
- [ ] Implement result submission
- [ ] Add batch submission support
- [ ] Add retry logic
- [ ] Add gas estimation

### 4.4 Registration

```
crates/evm-extra/src/registration/
├── mod.rs         # New
├── blueprint.rs   # New
└── operator.rs    # New
```

**Tasks:**
- [ ] Implement blueprint registration
- [ ] Implement operator registration
- [ ] Implement `EVMBlueprintConfig`

### 4.5 Runner Updates

```
crates/runner/src/
├── lib.rs         # Update
└── config.rs      # Update
```

**Tasks:**
- [ ] Make EVM default protocol
- [ ] Update builder pattern for EVM
- [ ] Deprecate Tangle-specific code

## Phase 5: Testing

### 5.1 Contract Tests (Foundry)

```
test/
├── core/
│   ├── TangleCore.t.sol
│   ├── BlueprintRegistry.t.sol
│   ├── ServiceManager.t.sol
│   └── JobManager.t.sol
├── security/
│   ├── NativeSecurityManager.t.sol
│   └── EigenLayerSecurityManager.t.sol
├── rewards/
│   └── RewardsDistributor.t.sol
├── hooks/
│   └── BlueprintServiceManager.t.sol
└── integration/
    ├── FullFlow.t.sol
    └── SecuritySwitch.t.sol
```

**Tasks:**
- [ ] Unit tests for each contract
- [ ] Integration tests for full flows
- [ ] Fuzz tests for edge cases
- [ ] Invariant tests for critical properties

### 5.2 SDK Tests

**Tasks:**
- [ ] Unit tests for new extractors
- [ ] Integration tests with anvil
- [ ] End-to-end blueprint tests

### 5.3 E2E Tests

**Tasks:**
- [ ] Deploy to local L3 testnet
- [ ] Full operator registration flow
- [ ] Service request → job → result flow
- [ ] Slashing scenarios
- [ ] Security manager switching

## Phase 6: L3 Deployment

### 6.1 L3 Setup

**Tasks:**
- [ ] Choose L3 framework (Arbitrum Orbit recommended)
- [ ] Configure chain parameters
- [ ] Set up sequencer
- [ ] Configure DA layer

### 6.2 Contract Deployment

```bash
# Deploy script
forge script script/Deploy.s.sol --rpc-url $L3_RPC --broadcast
```

**Deployment Order:**
1. Libraries
2. BlueprintRegistry
3. ServiceManager
4. JobManager
5. RewardsDistributor
6. NativeSecurityManager
7. TangleCore (links all modules)

### 6.3 Configuration

**Tasks:**
- [ ] Set payment config (fee splits)
- [ ] Configure supported assets
- [ ] Set slashing parameters
- [ ] Grant roles

### 6.4 Verification

**Tasks:**
- [ ] Verify all contracts on block explorer
- [ ] Publish ABIs
- [ ] Update SDK with deployed addresses

## Milestone Checklist

### M1: Core Protocol Complete
- [ ] All core contracts implemented
- [ ] Unit tests passing
- [ ] Security interfaces defined

### M2: Security Managers Complete
- [ ] Native manager implemented
- [ ] EigenLayer adapter implemented
- [ ] Symbiotic adapter (skeleton)
- [ ] Integration tests passing

### M3: SDK Updates Complete
- [ ] New extractors implemented
- [ ] Producer/Consumer updated
- [ ] Registration flow working
- [ ] SDK tests passing

### M4: Integration Complete
- [ ] E2E tests passing
- [ ] Example blueprints working
- [ ] Documentation updated

### M5: Testnet Deployment
- [ ] L3 testnet running
- [ ] Contracts deployed
- [ ] SDK pointing to testnet
- [ ] Test operators running

### M6: Mainnet Ready
- [ ] Security audit complete
- [ ] Bug bounty launched
- [ ] Documentation complete
- [ ] L3 mainnet deployed

## File Tree Summary

```
tnt-core/
├── src/
│   ├── core/
│   │   ├── TangleCore.sol
│   │   ├── BlueprintRegistry.sol
│   │   ├── ServiceManager.sol
│   │   └── JobManager.sol
│   ├── security/
│   │   ├── ISecurityManager.sol
│   │   ├── ISecurityManagerAdmin.sol
│   │   ├── NativeSecurityManager.sol
│   │   ├── EigenLayerSecurityManager.sol
│   │   └── SymbioticSecurityManager.sol
│   ├── rewards/
│   │   └── RewardsDistributor.sol
│   ├── hooks/
│   │   ├── IBlueprintServiceManager.sol
│   │   └── BlueprintServiceManagerBase.sol
│   ├── interfaces/
│   │   ├── IBlueprintRegistry.sol
│   │   ├── IServiceManager.sol
│   │   ├── IJobManager.sol
│   │   └── IRewardsDistributor.sol
│   └── libraries/
│       ├── Assets.sol
│       ├── ServiceOperators.sol
│       └── Errors.sol
├── test/
│   ├── core/
│   ├── security/
│   ├── rewards/
│   ├── hooks/
│   └── integration/
├── script/
│   ├── Deploy.s.sol
│   └── Configure.s.sol
├── architecture/
│   └── *.md
└── foundry.toml

blueprint-sdk/
├── crates/
│   ├── core/           # Unchanged
│   ├── router/         # Unchanged
│   ├── runner/         # Minor updates
│   ├── macros/         # Unchanged
│   └── evm-extra/      # Major updates
│       ├── src/
│       │   ├── producer/
│       │   ├── consumer/
│       │   ├── extract/
│       │   ├── registration/
│       │   └── lib.rs
│       └── Cargo.toml
└── examples/
    └── simple-blueprint/
```

## Open Questions

1. **L3 Token:** Use bridged TNT or new L3-native token?
2. **Governance:** On L3 or separate?
3. **Bridge:** Native bridge or LayerZero/Axelar?
4. **Sequencer:** Centralized initially, path to decentralization?
5. **DA:** AnyTrust committee composition?

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Contract bugs | Extensive testing, audit, bug bounty |
| L3 instability | Start on established L2, migrate to L3 |
| EigenLayer integration complexity | Implement native first, add EigenLayer second |
| SDK breaking changes | Maintain backward compat module |
| Gas costs | L3 deployment, batching, optimization |
