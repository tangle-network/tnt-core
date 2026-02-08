# Security Audit Report: OperatorStatusRegistry Contract

**Target Files:**
- `src/staking/OperatorStatusRegistry.sol`
- `test/staking/OperatorStatusRegistry.t.sol`

**Scope:** `setMetricDefinitions`, metric validation in `_processMetrics`, `getSlashableOperators` with `_allOperators` tracking, expanded `IOperatorStatusRegistry` interface.

**Compiler:** Solidity ^0.8.26 (overflow/underflow checked by default)
**Date:** 2026-02-08
**Auditor:** Claude Opus 4.6

---

## CRITICAL SEVERITY

### C-1: Unbounded `_allOperators` Set Causes DoS in `getSlashableOperators`

**Location:** `getSlashableOperators()` at lines 730-757

The `_allOperators[serviceId]` set grows monotonically -- operators are added in `_processHeartbeat` but are **never removed**. `getSlashableOperators` iterates over this entire set **twice** (count pass + collect pass). Each iteration reads from storage (`_allOperators[serviceId].at(i)`) and then reads the full `OperatorState` struct.

With N operators having ever heartbeated for a service, gas cost scales as approximately `2 * N * (SLOAD for EnumerableSet.at + multiple SLOADs for OperatorState)`. At roughly 4,000-5,000 gas per operator per pass, a service with ~3,000 historical operators would exceed the 30M block gas limit, permanently bricking this view function.

**Impact:** Permanent denial of service for `getSlashableOperators` after sufficient operator churn. Any contract or keeper relying on this function for automated slashing would stop functioning.

**Test gap:** The test `test_getSlashableOperators_ReturnsOffline` only tests with a single operator.

---

## HIGH SEVERITY

### H-1: `addMetricDefinition` Lacks `maxValue >= minValue` Validation

**Location:** `addMetricDefinition()` at line 584

`setMetricDefinitions` correctly validates `definitions[i].maxValue >= definitions[i].minValue`. However, `addMetricDefinition` performs **no such validation**. A service owner can call `addMetricDefinition(serviceId, "metric", 100, 0, true)` where `minValue=100` and `maxValue=0`.

This creates an impossible-to-satisfy metric definition. The validation check would fire a `MetricViolation` event for **every** value submitted.

**Impact:** Service owner can create metric definitions that are impossible to satisfy, potentially triggering unjust slashing for all operators on that service.

### H-2: `_processMetrics` O(D*P) Quadratic Gas Complexity

**Location:** `_processMetrics()` at lines 402-426

The metric validation loop is O(D * P) where D = number of metric definitions and P = number of metric pairs submitted. Both D and P are unbounded. The validation loop is **not** wrapped in try/catch. If it runs out of gas, the entire `submitHeartbeat` transaction reverts.

**Impact:** A service owner who adds excessive metric definitions can inadvertently or deliberately prevent operators from submitting heartbeats.

### H-3: Metric Values Stored Before Validation

**Location:** `_processMetrics()` at lines 396-426

Metric values are written to `metricValues` storage and `MetricReported` events are emitted **before** the validation loop. Invalid metric values are persisted in storage. `MetricReported` events are emitted for values that subsequently fail validation.

**Impact:** Invalid metric values pollute storage and event logs. Downstream consumers reading `metricValues` get unvalidated data.

---

## MEDIUM SEVERITY

### M-1: `submitHeartbeatDirect` Has No Access Control

**Location:** `submitHeartbeatDirect()` at line 308

Any address can call `submitHeartbeatDirect` for any `serviceId`. No check that the caller is actually a registered operator. This means any address can register itself in `_allOperators`, set its own `OperatorState` to `Healthy`, and bloat `_allOperators` (contributing to C-1 DoS).

**Impact:** Unauthorized addresses can inject themselves into operator tracking sets, corrupt online/offline status, and inflate `_allOperators` sets.

### M-2: `setMetricDefinitions` Unbounded Array Replacement Gas Cost

**Location:** `setMetricDefinitions()` at lines 602-609

`delete serviceMetrics[serviceId]` followed by unbounded push loop. If the existing array is large, the operation could hit gas limits. Only callable by service owner, so self-inflicted.

### M-3: `uint8` Truncation in Missed Beats Calculation

**Location:** `checkOperatorStatus()` at line 472

```solidity
uint8 missedBeats = uint8(elapsed / config.interval);
```

The result is a `uint256` cast to `uint8`, silently truncating values > 255. With `interval=60`, truncation occurs after ~4.3 hours. An operator offline long enough could falsely appear healthy.

**NOTE:** This was identified in PR review and a fix was prepared (cap at `type(uint8).max`) but not yet pushed.

### M-4: `configureHeartbeat` Allows Unregistered Service Configuration

**Location:** `configureHeartbeat()` at line 553

Authorization includes `serviceOwners[serviceId] == address(0)` as valid. Anyone can configure heartbeat settings for a service with no registered owner.

### M-5: `_processHeartbeat` Silently Swallows `metricsRecorder` Failures

**Location:** `_processHeartbeat()` at lines 371-376

```solidity
try IMetricsRecorder(metricsRecorder).recordHeartbeat(...) {} catch {}
```

All failures are silently swallowed. No event or error log.

---

## LOW SEVERITY

### L-1: `decodeMetricPairs` is `external` and Publicly Callable

Pure function unnecessarily in public API. `this.decodeMetricPairs()` also costs extra gas (~2,600 base gas for CALL) compared to internal try mechanism.

### L-2: `MetricViolation` Events Are Advisory Only

Violations emit events only. No state change, no enforcement. The naming "violation" overstates the severity.

### L-3: No Limit on `setMetricDefinitions` Array Size

Contributes to H-2 gas amplification. Consider adding a reasonable upper bound (e.g., 50 definitions).

### L-4: String Comparison via `keccak256` Hash Collision

If two `MetricPair` entries have the same `name`, only the first match is used for validation, but the **last** value is stored (storage loop runs first without deduplication). Validated value and stored value could differ.

### L-5: `goOnline` Allows Transition From Any Non-Slashed State

An operator can call `goOnline` even if `Healthy`, which actually *downgrades* status to `Degraded`.

---

## INFORMATIONAL

### I-1: `DOMAIN_SEPARATOR` is Unused

Computed in constructor but never referenced in `submitHeartbeat`. Dead code.

### I-2: `_allOperators` Has No Removal Mechanism

Root cause of C-1.

### I-3: Test Coverage Gaps

Missing: gas consumption tests at scale, empty array edge cases, duplicate metric names, unauthorized `submitHeartbeatDirect`, `addMetricDefinition` with invalid bounds, `uint8` truncation with large time gaps.

### I-4: `checkOperatorsStatus` Uses External Self-Call

Unnecessary gas overhead per operator.

### I-5: `reportForSlashing` Does Not Check if Operator Exists

Can slash non-existent operators, blocking them from future registration.

---

## Reentrancy Assessment

Reentrancy risk is **low**. The only external calls are:
1. `IMetricsRecorder(metricsRecorder).recordHeartbeat(...)` -- wrapped in try/catch, state fully updated before call.
2. `this.decodeMetricPairs(metrics)` -- self-call, no reentrancy risk.
3. `this.checkOperatorStatus(...)` -- self-call, no reentrancy risk.

No ETH transfers, no token transfers, no delegate calls.

## Storage Collision Assessment

OpenZeppelin's `EnumerableSet.AddressSet` uses well-tested storage layout. Separate `mapping(uint64 => EnumerableSet.AddressSet)` declarations at different storage slots. **No storage collision issues found.**

---

## Summary Table

| ID | Severity | Title |
|----|----------|-------|
| C-1 | Critical | Unbounded `_allOperators` causes DoS in `getSlashableOperators` |
| H-1 | High | `addMetricDefinition` lacks `maxValue >= minValue` check |
| H-2 | High | `_processMetrics` O(D*P) quadratic complexity, non-try/catch |
| H-3 | High | Metric values stored before validation |
| M-1 | Medium | `submitHeartbeatDirect` has no operator authorization |
| M-2 | Medium | `setMetricDefinitions` unbounded gas cost |
| M-3 | Medium | `uint8` truncation in missed beats calculation |
| M-4 | Medium | `configureHeartbeat` allows phantom service creation |
| M-5 | Medium | Silent swallowing of `metricsRecorder` failures |
| L-1 | Low | `decodeMetricPairs` unnecessary public surface + gas cost |
| L-2 | Low | `MetricViolation` events are advisory only |
| L-3 | Low | No max limit on metric definitions count |
| L-4 | Low | Duplicate metric name causes store/validate mismatch |
| L-5 | Low | `goOnline` downgrades Healthy to Degraded |
| I-1 | Info | `DOMAIN_SEPARATOR` / `HEARTBEAT_TYPEHASH` are dead code |
| I-2 | Info | `_allOperators` has no removal mechanism |
| I-3 | Info | Significant test coverage gaps |
| I-4 | Info | `checkOperatorsStatus` uses external self-call |
| I-5 | Info | `reportForSlashing` doesn't verify operator existence |
