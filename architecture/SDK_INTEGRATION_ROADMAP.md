# Blueprint SDK v2 Integration Roadmap

## Current State

### Bindings (Complete)
The following v2 contract bindings are generated and available:

| Contract | Binding | Status |
|----------|---------|--------|
| Tangle.sol | `tangle.rs`, `itangle.rs`, `itanglefull.rs` | Complete |
| MultiAssetDelegation.sol | `multiassetdelegation.rs` | Complete |
| InflationPool.sol | `inflationpool.rs` | Complete |
| TangleGovernor.sol | `tanglegovernor.rs` | Complete |
| TangleToken.sol | `tangletoken.rs` | Complete |
| TangleTimelock.sol | `tangletimelock.rs` | Complete |
| TangleL2Slasher.sol | `tanglel2slasher.rs` | Complete |
| TangleMetrics.sol | `tanglemetrics.rs` | Complete |
| IBlueprintServiceManager | `iblueprintservicemanager.rs` | Complete |

### SDK Client Features (Implemented)

| Feature | Location | Status |
|---------|----------|--------|
| Job event subscription | `TangleEvmProducer` | Complete |
| Job result submission | `TangleEvmConsumer` | Complete |
| Aggregated result submission | `client.rs:submit_aggregated_result` | Complete |
| Blueprint queries | `client.rs` | Complete |
| Service queries | `client.rs` | Complete |
| Operator stake queries | `client.rs` | Complete |
| BLS aggregation queries | `client.rs` | Complete |
| Exposure/weight queries | `client.rs:get_service_operator_weights` | Complete |
| Service config cache | `cache.rs` | Complete |
| BLS aggregation strategy | `strategy.rs` | Complete |

---

## Gaps: SDK Features Needed

### Priority 1: Core Operator Lifecycle

**Not covered by Solidity tests alone** - requires SDK integration tests.

| Feature | Contract Function | SDK Method Needed |
|---------|-------------------|-------------------|
| Register as operator | `MultiAssetDelegation.registerOperator()` | `register_operator()` |
| Increase stake | `MultiAssetDelegation.increaseStake()` | `increase_stake()` |
| Schedule unstake | `MultiAssetDelegation.scheduleOperatorUnstake()` | `schedule_operator_unstake()` |
| Execute unstake | `MultiAssetDelegation.executeOperatorUnstake()` | `execute_operator_unstake()` |
| Add blueprint | `MultiAssetDelegation.addBlueprint()` | `add_blueprint()` |
| Remove blueprint | `MultiAssetDelegation.removeBlueprint()` | `remove_blueprint()` |
| Start leaving | `MultiAssetDelegation.startLeaving()` | `start_leaving()` |
| Complete leaving | `MultiAssetDelegation.completeLeaving()` | `complete_leaving()` |

**Why SDK tests are needed:**
- Tests node software operator onboarding flow
- Validates keystore integration works end-to-end
- Ensures transaction signing works correctly
- Verifies state machine transitions over network

### Priority 2: Service Lifecycle (Operator Side)

| Feature | Contract Function | SDK Method Needed |
|---------|-------------------|-------------------|
| Approve service | `Tangle.approveService()` | `approve_service()` |
| Reject service | `Tangle.rejectService()` | `reject_service()` |
| Join service | `Tangle.joinService()` | `join_service()` |
| Leave service | `Tangle.leaveService()` | `leave_service()` |

**Why SDK tests are needed:**
- Validates operator approval flow before going live
- Tests exposure selection logic
- Ensures operators can dynamically join/leave services

### Priority 3: Slashing Operations

| Feature | Contract Function | SDK Method Needed |
|---------|-------------------|-------------------|
| Query slash proposal | `Tangle.getSlashProposal()` | `get_slash_proposal()` |
| Dispute slash | `Tangle.disputeSlash()` | `dispute_slash()` |
| Execute slash | `Tangle.executeSlash()` | `execute_slash()` |
| Get executable slashes | `Tangle.getExecutableSlashes()` | `get_executable_slashes()` |

**Why SDK tests are needed:**
- Slashing execution happens via operator nodes
- Operators need to monitor and dispute invalid slashes
- Execution timing (dispute window) needs real-time testing

### Priority 4: Rewards & Payments

| Feature | Contract Function | SDK Method Needed |
|---------|-------------------|-------------------|
| Claim operator rewards | `MultiAssetDelegation.claimOperatorRewards()` | `claim_operator_rewards()` |
| Query pending rewards | `MultiAssetDelegation.getPendingRewards()` | `get_pending_rewards()` |
| Query escrow balance | `Tangle.getServiceEscrow()` | `get_service_escrow()` |

**Why SDK tests are needed:**
- Rewards claiming is done by node software
- Need to test reward calculation matches expectations
- Payment flow affects operator economics

### Priority 5: Heartbeat/Liveness

| Feature | Contract Function | SDK Method Needed |
|---------|-------------------|-------------------|
| Submit heartbeat | `OperatorStatusRegistry.submitHeartbeat()` | `submit_heartbeat()` |
| Check operator status | `OperatorStatusRegistry.getOperatorStatus()` | `get_operator_status()` |
| Check if online | `OperatorStatusRegistry.isOperatorOnline()` | `is_operator_online()` |

**Why SDK tests are needed:**
- Heartbeat submission runs in background loop
- Signature generation needs keystore integration
- Liveness affects service availability

---

## Integration Test Scenarios Needed

### Scenario 1: Operator Onboarding
```
1. Generate ECDSA key in keystore
2. Register as operator with stake
3. Add blueprints operator wants to serve
4. Pre-register for specific blueprint
5. Register with preferences (ECDSA pubkey, RPC address)
6. Verify registration via queries
```

### Scenario 2: Service Participation
```
1. Service request created
2. Operator receives notification (event)
3. Operator approves with exposure
4. Service activates
5. Operator starts receiving jobs
```

### Scenario 3: Job Execution (Non-Aggregated)
```
1. Job submitted event received
2. Job processed by blueprint handler
3. Result submitted via `submitResult()`
4. Job completion verified
```

### Scenario 4: Job Execution (BLS Aggregated)
```
1. Job submitted event received
2. All operators compute result
3. Results collected via P2P/HTTP
4. BLS signatures aggregated
5. Threshold verified
6. Aggregated result submitted
7. On-chain verification passes
```

### Scenario 5: Slashing Response
```
1. Slash proposed against operator
2. Operator monitors SlashProposed events
3. If invalid, operator disputes within window
4. After window, execution happens
5. Operator's stake reduced
```

### Scenario 6: Rewards Claiming
```
1. Jobs completed, payments processed
2. Operator queries pending rewards
3. Operator claims rewards
4. Balance verified
```

---

## Implementation Order

### Phase 1: Operator Lifecycle (Critical)
- [ ] `TangleEvmClient::register_operator()`
- [ ] `TangleEvmClient::increase_stake()`
- [ ] `TangleEvmClient::add_blueprint()`
- [ ] `TangleEvmClient::approve_service()`
- [ ] Integration test: Operator onboarding

### Phase 2: Slashing (Critical for Security)
- [ ] `TangleEvmClient::get_slash_proposal()`
- [ ] `TangleEvmClient::dispute_slash()`
- [ ] `TangleEvmClient::execute_slash()`
- [ ] Event subscription for `SlashProposed`
- [ ] Integration test: Slashing response

### Phase 3: Rewards (Important for Economics)
- [ ] `TangleEvmClient::claim_operator_rewards()`
- [ ] `TangleEvmClient::get_pending_rewards()`
- [ ] Integration test: Rewards claiming

### Phase 4: Liveness (Important for Service Quality)
- [ ] `TangleEvmClient::submit_heartbeat()`
- [ ] Background heartbeat loop
- [ ] Integration test: Heartbeat submission

### Phase 5: Full E2E Tests
- [ ] Complete operator lifecycle test
- [ ] BLS aggregation E2E test
- [ ] Slashing E2E test
- [ ] Multi-operator coordination test

---

## Missing Interface Bindings

These interfaces exist in v2 but aren't in the SDK bindings:

| Interface | Purpose | Priority |
|-----------|---------|----------|
| `IRestaking` | Abstract staking interface | Low (implementation used directly) |
| `IMetricsRecorder` | Metrics reporting | Medium (for custom metrics) |
| `IRewardsManager` | Reward distribution interface | Low |
| `IBlueprintHook` | Custom blueprint hooks | Medium |
| `IStreamingPaymentAdapter` | Streaming payments | Low |

---

## Test Infrastructure Needed

### 1. Local Anvil Fork Tests
Run SDK integration tests against Anvil with deployed contracts.

```rust
#[tokio::test]
async fn test_operator_registration() {
    let anvil = Anvil::new().spawn();
    // Deploy contracts
    // Create TangleEvmClient
    // Test registration flow
}
```

### 2. Mock Contract Server
For unit testing without blockchain.

### 3. CI Integration
- Foundry tests run first
- Then SDK integration tests against Anvil
- Coverage reporting for both
