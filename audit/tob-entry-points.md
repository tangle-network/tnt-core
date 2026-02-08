# OperatorStatusRegistry Entry-Point Analysis

**Contract**: `src/staking/OperatorStatusRegistry.sol`
**Solidity**: `^0.8.26`
**Inheritance**: `IOperatorStatusRegistry`, `Ownable2Step` (OpenZeppelin)
**Date**: 2026-02-08

---

## Table of Contents

1. [Contract Overview](#1-contract-overview)
2. [Privileged Roles](#2-privileged-roles)
3. [State-Changing Entry Points](#3-state-changing-entry-points)
4. [View / Pure Entry Points](#4-view--pure-entry-points)
5. [Access Control Matrix](#5-access-control-matrix)
6. [Attack Surface Analysis](#6-attack-surface-analysis)
7. [Finding Summary](#7-finding-summary)

---

## 1. Contract Overview

`OperatorStatusRegistry` tracks operator liveness for services deployed through the Tangle protocol. Operators prove they are online by submitting periodic heartbeats (signed or unsigned). The contract manages heartbeat configuration, custom metrics collection and validation, offline detection, voluntary availability toggling, and slashing integration.

Key external dependencies:
- `ECDSA` (OpenZeppelin) for signature recovery in `submitHeartbeat`.
- `EnumerableSet` (OpenZeppelin) for tracking online/all operator sets.
- `IMetricsRecorder` for recording heartbeats to an external rewards system.

Immutable state set at construction:
- `tangleCore` -- the Tangle core contract address, used as a privileged caller.
- `DOMAIN_SEPARATOR` -- EIP-712 domain separator (computed but unused in signing logic).

---

## 2. Privileged Roles

| Role | Holder | How Set | Powers |
|------|--------|---------|--------|
| **Owner** (Ownable2Step) | `initialOwner` constructor arg | Two-step transfer via `transferOwnership` / `acceptOwnership` | `setSlashingOracle`, `setMetricsRecorder` |
| **tangleCore** | Constructor arg (immutable) | Cannot change post-deploy | `registerServiceOwner`, `configureHeartbeat` |
| **serviceOwners[serviceId]** | Set by `tangleCore` via `registerServiceOwner` | One-shot, cannot be changed once set | `configureHeartbeat`, `enableCustomMetrics`, `addMetricDefinition`, `setMetricDefinitions` |
| **slashingOracle** | Set by owner via `setSlashingOracle` | Mutable by owner | `reportForSlashing` |
| **metricsRecorder** | Set by owner via `setMetricsRecorder` | Mutable by owner | Called on every heartbeat via `try/catch` |

---

## 3. State-Changing Entry Points

### 3.1 `submitHeartbeat(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes metrics, bytes signature)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | Any caller, but `signature` must recover to `msg.sender` |
| **State Modified** | `operatorStates[serviceId][msg.sender]`, `_allOperators`, `_onlineOperators`, `metricValues`, `_lastCriticalAlert` |
| **Events Emitted** | `HeartbeatReceived`, `OperatorCameOnline`, `StatusChanged`, `MetricReported`, `MetricViolation`, `SlashingTriggered` |
| **External Calls** | `IMetricsRecorder.recordHeartbeat` (try/catch), `this.decodeMetricPairs` (try/catch) |

**Flow**: Recovers ECDSA signer from `keccak256(abi.encodePacked(serviceId, blueprintId, metrics))` prefixed with `"\x19Ethereum Signed Message:\n32"`. Requires `signer == msg.sender`. Delegates to `_processHeartbeat`.

### 3.2 `submitHeartbeatDirect(uint64 serviceId, uint64 blueprintId, uint8 statusCode, bytes metrics)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | **None** -- any address can call for any `serviceId` |
| **State Modified** | Same as `submitHeartbeat` |
| **Events Emitted** | Same as `submitHeartbeat` |
| **External Calls** | Same as `submitHeartbeat` |

**Flow**: Directly calls `_processHeartbeat` with `msg.sender` as the operator. No signature or registration check.

### 3.3 `checkOperatorStatus(uint64 serviceId, address operator)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | **None** -- any address can call |
| **State Modified** | `operatorStates[serviceId][operator]` (missedBeats, consecutiveBeats, status), `_onlineOperators` |
| **Events Emitted** | `OperatorWentOffline`, `StatusChanged` |
| **External Calls** | None |

**Flow**: Calculates missed heartbeats from `block.timestamp - state.lastHeartbeat`. If missed beats exceed `maxMissed`, marks operator `Offline` and removes from online set.

### 3.4 `checkOperatorsStatus(uint64 serviceId, address[] operators)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | **None** -- any address can call |
| **State Modified** | Same as `checkOperatorStatus`, for each operator |
| **Events Emitted** | Same as `checkOperatorStatus`, for each operator |
| **External Calls** | `this.checkOperatorStatus` (external self-call in loop) |

**Flow**: Iterates over `operators` array, calling `this.checkOperatorStatus` for each. No length bound on the input array.

### 3.5 `goOffline(uint64 serviceId)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender` is the operator (acts on own state). Reverts if status is `Slashed`. |
| **State Modified** | `operatorStates[serviceId][msg.sender].status`, `_onlineOperators` |
| **Events Emitted** | `StatusChanged` |
| **External Calls** | None |

**Flow**: Sets operator status to `Exiting`, removes from online set. Prevents voluntary exit while slashed.

### 3.6 `goOnline(uint64 serviceId)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender` is the operator (acts on own state). Reverts if status is `Slashed`. |
| **State Modified** | `operatorStates[serviceId][msg.sender]` (status, missedBeats), `_onlineOperators` |
| **Events Emitted** | `OperatorCameOnline`, `StatusChanged` |
| **External Calls** | None |

**Flow**: Sets operator status to `Degraded`, resets missed beats to 0, adds to online set.

### 3.7 `configureHeartbeat(uint64 serviceId, uint64 interval, uint8 maxMissed)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender == tangleCore` OR `msg.sender == serviceOwners[serviceId]` OR `serviceOwners[serviceId] == address(0)` |
| **State Modified** | `heartbeatConfigs[serviceId]` |
| **Events Emitted** | `HeartbeatConfigUpdated` |
| **External Calls** | None |

**Flow**: Sets interval (min 60s) and maxMissed (min 1). Preserves existing `customMetrics` flag.

### 3.8 `registerServiceOwner(uint64 serviceId, address owner)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender == tangleCore` only. Also requires `serviceOwners[serviceId] == address(0)`. |
| **State Modified** | `serviceOwners[serviceId]` |
| **Events Emitted** | None |
| **External Calls** | None |

**Flow**: One-shot registration of a service owner. Cannot be changed once set.

### 3.9 `enableCustomMetrics(uint64 serviceId, bool enabled)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender == serviceOwners[serviceId]` |
| **State Modified** | `heartbeatConfigs[serviceId].customMetrics` |
| **Events Emitted** | None |
| **External Calls** | None |

### 3.10 `addMetricDefinition(uint64 serviceId, string name, uint256 minValue, uint256 maxValue, bool required)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender == serviceOwners[serviceId]` |
| **State Modified** | `serviceMetrics[serviceId]` (push) |
| **Events Emitted** | None |
| **External Calls** | None |

**Note**: No validation that `maxValue >= minValue`. No limit on number of definitions that can be pushed (unbounded array growth).

### 3.11 `setMetricDefinitions(uint64 serviceId, MetricDefinition[] definitions)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender == serviceOwners[serviceId]` |
| **State Modified** | `serviceMetrics[serviceId]` (delete + push loop) |
| **Events Emitted** | None |
| **External Calls** | None |

**Flow**: Deletes existing definitions then pushes new ones. Validates `maxValue >= minValue` per entry. No upper bound on array length.

### 3.12 `reportForSlashing(uint64 serviceId, address operator, string reason)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `msg.sender == slashingOracle` |
| **State Modified** | `operatorStates[serviceId][operator].status`, `_onlineOperators`, `_lastCriticalAlert` |
| **Events Emitted** | `SlashingTriggered` |
| **External Calls** | None |

**Flow**: Sets operator status to `Slashed`, removes from online set, updates last critical alert timestamp.

### 3.13 `setSlashingOracle(address oracle)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `onlyOwner` (Ownable2Step) |
| **State Modified** | `slashingOracle` |
| **Events Emitted** | None |
| **External Calls** | None |

### 3.14 `setMetricsRecorder(address recorder)`

| Property | Value |
|----------|-------|
| **Visibility** | `external` |
| **Access Control** | `onlyOwner` (Ownable2Step) |
| **State Modified** | `metricsRecorder` |
| **Events Emitted** | None |
| **External Calls** | None |

### 3.15 `decodeMetricPairs(bytes payload)` (external pure)

| Property | Value |
|----------|-------|
| **Visibility** | `external pure` |
| **Access Control** | None |
| **State Modified** | None (pure) |

Used as a try/catch target for `_processMetrics`. Although it modifies no state, it is callable externally by anyone, which is intentional for the try/catch pattern.

### 3.16 Inherited from Ownable2Step

- `transferOwnership(address newOwner)` -- `onlyOwner`, sets pending owner.
- `acceptOwnership()` -- pending owner only, completes transfer.
- `renounceOwnership()` -- `onlyOwner`, sets owner to `address(0)`.

---

## 4. View / Pure Entry Points

| Function | Returns | Notes |
|----------|---------|-------|
| `isOnline(serviceId, operator)` | `bool` | Checks `Healthy` or `Degraded` status |
| `getOperatorStatus(serviceId, operator)` | `StatusCode` | Direct mapping read |
| `getLastHeartbeat(serviceId, operator)` | `uint256` | Timestamp of last heartbeat |
| `getOperatorState(serviceId, operator)` | `OperatorState` | Full state struct |
| `getOnlineOperators(serviceId)` | `address[]` | Iterates EnumerableSet; unbounded gas |
| `getOnlineOperatorCount(serviceId)` | `uint256` | O(1) count |
| `getHeartbeatConfig(serviceId)` | `HeartbeatConfig` | With defaults applied |
| `getMetricValue(serviceId, operator, name)` | `uint256` | Nested mapping read |
| `getMetricDefinitions(serviceId)` | `MetricDefinition[]` | Returns full array; unbounded gas |
| `isHeartbeatCurrent(serviceId, operator)` | `bool` | Compares timestamp to interval |
| `getSlashableOperators(serviceId)` | `address[]` | Two-pass iteration over `_allOperators`; unbounded gas |
| `getLastCriticalHeartbeat(serviceId, operator)` | `uint64` | Direct mapping read |

---

## 5. Access Control Matrix

| Function | Anyone | Operator (self) | Service Owner | tangleCore | slashingOracle | Owner (Governance) |
|----------|--------|-----------------|---------------|------------|----------------|-------------------|
| `submitHeartbeat` | X (with valid sig) | | | | | |
| `submitHeartbeatDirect` | X | | | | | |
| `checkOperatorStatus` | X | | | | | |
| `checkOperatorsStatus` | X | | | | | |
| `goOffline` | | X | | | | |
| `goOnline` | | X | | | | |
| `configureHeartbeat` | X (if no owner set) | | X | X | | |
| `registerServiceOwner` | | | | X | | |
| `enableCustomMetrics` | | | X | | | |
| `addMetricDefinition` | | | X | | | |
| `setMetricDefinitions` | | | X | | | |
| `reportForSlashing` | | | | | X | |
| `setSlashingOracle` | | | | | | X |
| `setMetricsRecorder` | | | | | | X |

---

## 6. Attack Surface Analysis

### 6.1 CRITICAL: `submitHeartbeatDirect` Has No Access Control

**Severity**: Critical
**Entry Point**: `submitHeartbeatDirect`
**Issue**: Any address can submit heartbeats for any `serviceId` without any authentication, signature, or operator registration check. This means:

- An attacker can register themselves in `_allOperators[serviceId]` for any service by submitting a single heartbeat.
- An attacker can maintain `Healthy` status indefinitely for services they have no legitimate relationship with.
- The `_onlineOperators` set can be polluted with arbitrary addresses.
- `getOnlineOperators` and `getSlashableOperators` return attacker-controlled addresses alongside legitimate operators.
- If downstream systems use `isOnline()` or `getOnlineOperators()` for task routing, reward distribution, or governance, an attacker can inject themselves into those flows.

**Recommendation**: Require operator registration (e.g., check against a registry of operators for the given `serviceId`) or restrict to `tangleCore` / service owner authorization, or remove this function entirely in favor of the signed variant.

### 6.2 HIGH: `configureHeartbeat` Allows Anyone When Service Owner Is Unset

**Severity**: High
**Entry Point**: `configureHeartbeat`
**Issue**: The authorization check includes `serviceOwners[serviceId] == address(0)` as a valid condition. This means for any `serviceId` that has not had an owner registered via `registerServiceOwner`, **any caller** can set heartbeat configuration. An attacker could:

- Set `interval` to `60` (minimum) and `maxMissed` to `1`, causing legitimate operators to be marked offline very quickly.
- Set `interval` to `type(uint64).max` and `maxMissed` to `255`, making it effectively impossible for operators to be marked offline regardless of their actual status.
- Front-run the `registerServiceOwner` transaction to set a malicious configuration before the legitimate owner is registered.

**Recommendation**: Remove the `serviceOwners[serviceId] == address(0)` fallback and require either `tangleCore` or a registered service owner.

### 6.3 HIGH: No Operator Registration Gating

**Severity**: High
**Entry Points**: `submitHeartbeat`, `submitHeartbeatDirect`, `goOnline`, `goOffline`
**Issue**: There is no concept of "registered operators" for a service. Any address that calls `submitHeartbeatDirect` (or `submitHeartbeat` with a valid self-signature) is immediately tracked in `_allOperators` and can appear in `_onlineOperators`. The `goOnline` and `goOffline` functions operate on `msg.sender`'s state without verifying the caller is a legitimate operator for the given service.

**Impact**: An attacker can call `goOnline` for a service they were never registered with, adding themselves to the online set with `Degraded` status.

### 6.4 HIGH: `getSlashableOperators` Unbounded Gas / DoS

**Severity**: High
**Entry Point**: `getSlashableOperators` (view), `getOnlineOperators` (view)
**Issue**: These functions iterate over `_allOperators[serviceId]` or `_onlineOperators[serviceId]` with no pagination. Because `submitHeartbeatDirect` is permissionless, an attacker can inflate `_allOperators` by submitting heartbeats from many addresses. This makes `getSlashableOperators` consume unbounded gas, potentially exceeding block gas limits for on-chain callers.

**Impact**: Any contract that calls `getSlashableOperators` on-chain could be permanently bricked if the operator set grows large enough. Off-chain consumers are less affected but still face performance degradation.

### 6.5 MEDIUM: `checkOperatorsStatus` Unbounded Loop

**Severity**: Medium
**Entry Point**: `checkOperatorsStatus`
**Issue**: The `operators` array parameter has no length limit. A caller could pass a very large array, but since the caller pays gas, the direct DoS risk is self-inflicted. However, the function uses `this.checkOperatorStatus(...)` (external self-call), which has higher gas overhead per iteration than an internal call. This is an unnecessary gas cost amplifier.

### 6.6 MEDIUM: Operator Can Self-Report Critical Status to Trigger `SlashingTriggered` Events

**Severity**: Medium
**Entry Point**: `submitHeartbeat`, `submitHeartbeatDirect`
**Issue**: An operator can submit a heartbeat with `statusCode >= 200`, which triggers a `SlashingTriggered` event via `_checkSlashingCondition`. While the event is rate-limited by `SLASH_ALERT_COOLDOWN` (1 hour), any operator can generate these events for their own address. If off-chain systems monitor `SlashingTriggered` events without distinguishing self-reports from oracle reports, the signal is unreliable.

**Note**: The contract emits the same `SlashingTriggered` event from both `_checkSlashingCondition` (self-reported) and `reportForSlashing` (oracle-initiated). There is no way for event consumers to distinguish the source.

### 6.7 MEDIUM: `metricsRecorder` Failure Is Silently Swallowed

**Severity**: Medium
**Entry Point**: `submitHeartbeat`, `submitHeartbeatDirect` (via `_processHeartbeat`)
**Issue**: The call to `IMetricsRecorder(metricsRecorder).recordHeartbeat(...)` is wrapped in `try {} catch {}` with no error logging or event. If the metrics recorder reverts (due to misconfiguration, access control, or bugs), heartbeats still succeed but the rewards system silently stops recording operator activity. This violates the repo's stated "no silent fallbacks" policy.

### 6.8 MEDIUM: `addMetricDefinition` Missing Bounds Validation

**Severity**: Medium
**Entry Point**: `addMetricDefinition`
**Issue**: Unlike `setMetricDefinitions`, the `addMetricDefinition` function does not validate that `maxValue >= minValue`. A service owner can add a definition where `minValue > maxValue`, which would cause every metric submission to trigger a `MetricViolation` event regardless of the reported value (since no value can satisfy `value >= minValue && value <= maxValue` when `minValue > maxValue`).

### 6.9 MEDIUM: No Upper Bound on `serviceMetrics` Array Length

**Severity**: Medium
**Entry Points**: `addMetricDefinition`, `setMetricDefinitions`
**Issue**: There is no limit on how many metric definitions a service owner can create. A large number of definitions increases gas cost for every heartbeat submitted (due to the validation loop in `_processMetrics`), potentially making heartbeat submission too expensive and effectively DoS-ing operators for that service.

### 6.10 MEDIUM: `registerServiceOwner` Is One-Shot With No Recovery

**Severity**: Medium
**Entry Point**: `registerServiceOwner`
**Issue**: Once a service owner is registered, it cannot be updated or transferred. If the owner address is compromised or loses access, there is no governance escape hatch. The owner's configuration capabilities (heartbeat settings, metrics) are permanently locked to that address.

### 6.11 LOW: ECDSA Signature Does Not Include Chain ID or Contract Address

**Severity**: Low
**Entry Point**: `submitHeartbeat`
**Issue**: The signed message is `keccak256(abi.encodePacked(serviceId, blueprintId, metrics))`. This does not include `block.chainid` or `address(this)`. The `DOMAIN_SEPARATOR` is computed in the constructor but never used in the signing/verification logic. This means a valid signature for one chain or one deployment of the contract is valid on all chains and all deployments with the same `serviceId` / `blueprintId` / `metrics` combination.

**Impact**: Cross-chain replay of heartbeat signatures. An attacker who observes a signed heartbeat on chain A can replay it on chain B (if the same contract is deployed and the same `serviceId`/`blueprintId` exist). The practical impact is limited because the signature must recover to `msg.sender`, so the attacker would need to control the operator's address on both chains.

### 6.12 LOW: ECDSA Signature Does Not Include Nonce or Timestamp

**Severity**: Low
**Entry Point**: `submitHeartbeat`
**Issue**: The signed message has no nonce, timestamp, or block number. A single valid signature can be replayed any number of times on the same chain. This allows anyone who intercepts a signed heartbeat to keep replaying it to maintain the operator's online status indefinitely without the operator's continued participation.

**Mitigation**: The signature must recover to `msg.sender`, meaning only the operator's own EOA can submit it. However, if the operator's key is compromised or if a contract holds the key, replay is possible.

### 6.13 LOW: `_processMetrics` Decoding via External Self-Call

**Severity**: Low
**Entry Point**: `decodeMetricPairs` (called via `this.decodeMetricPairs`)
**Issue**: The try/catch pattern uses an external self-call (`this.decodeMetricPairs(metrics)`), which incurs the overhead of a `CALL` opcode and ABI encoding/decoding round trip. While functionally correct (and intentional to catch reverts from malformed payloads), it means `decodeMetricPairs` is publicly callable. An attacker can call it with arbitrary data, but since it is `pure`, the only impact is wasted gas for the caller.

### 6.14 LOW: `consecutiveBeats` Overflow

**Severity**: Low
**Entry Point**: `submitHeartbeat`, `submitHeartbeatDirect`
**Issue**: `state.consecutiveBeats` is `uint64` and is incremented by 1 on every heartbeat with no overflow check. At the default 5-minute interval, overflow would take approximately 1.7 trillion years, so this is not practically exploitable.

### 6.15 LOW: Slashed Operator Can Still Submit Heartbeats

**Severity**: Low
**Entry Points**: `submitHeartbeat`, `submitHeartbeatDirect`
**Issue**: A slashed operator can continue submitting heartbeats. `_processHeartbeat` does not check whether the operator's current status is `Slashed`. A heartbeat with `statusCode == 0` would overwrite the `Slashed` status with `Healthy`, effectively un-slashing the operator.

**Impact**: The slashing mechanism is ineffective because a slashed operator can immediately restore their status by submitting a heartbeat. This undermines the entire slashing/punishment flow.

### 6.16 INFORMATIONAL: Unused `DOMAIN_SEPARATOR`

The `DOMAIN_SEPARATOR` is computed in the constructor following EIP-712 conventions but is never referenced in any signing or verification logic. The actual signature scheme uses raw `keccak256` with the Ethereum signed message prefix. This is confusing and may mislead auditors or integrators into believing EIP-712 signing is in use.

### 6.17 INFORMATIONAL: No Events for Configuration Setters

`setSlashingOracle`, `setMetricsRecorder`, `enableCustomMetrics`, `addMetricDefinition`, `setMetricDefinitions`, and `registerServiceOwner` do not emit events. This makes off-chain monitoring and auditing of configuration changes more difficult.

### 6.18 INFORMATIONAL: `getSlashableOperators` Skips `Exiting` Operators

Operators with `StatusCode.Exiting` are excluded from the slashable set. This is likely intentional (operators voluntarily going offline should not be slashed), but it means an operator can call `goOffline` to immediately avoid being listed as slashable, even if they were already delinquent.

---

## 7. Finding Summary

| ID | Severity | Entry Point | Title |
|----|----------|-------------|-------|
| 6.1 | Critical | `submitHeartbeatDirect` | No access control on direct heartbeat submission |
| 6.2 | High | `configureHeartbeat` | Anyone can configure services with no registered owner |
| 6.3 | High | Multiple | No operator registration gating on any heartbeat/availability function |
| 6.4 | High | `getSlashableOperators` | Unbounded iteration enables DoS of on-chain consumers |
| 6.5 | Medium | `checkOperatorsStatus` | Unbounded loop with external self-call overhead |
| 6.6 | Medium | `submitHeartbeat*` | Self-reported critical status indistinguishable from oracle slashing |
| 6.7 | Medium | `submitHeartbeat*` | `metricsRecorder` failures silently swallowed |
| 6.8 | Medium | `addMetricDefinition` | Missing `maxValue >= minValue` validation |
| 6.9 | Medium | `addMetricDefinition` | No upper bound on metric definitions array |
| 6.10 | Medium | `registerServiceOwner` | One-shot registration with no recovery path |
| 6.11 | Low | `submitHeartbeat` | Signature lacks chain ID / contract address binding |
| 6.12 | Low | `submitHeartbeat` | Signature lacks nonce / timestamp (replay possible) |
| 6.13 | Low | `decodeMetricPairs` | External pure function exposed for try/catch pattern |
| 6.14 | Low | `submitHeartbeat*` | `consecutiveBeats` theoretical overflow |
| 6.15 | Low | `submitHeartbeat*` | Slashed operator can un-slash themselves via heartbeat |
| 6.16 | Info | -- | `DOMAIN_SEPARATOR` computed but unused |
| 6.17 | Info | Multiple | No events emitted for configuration changes |
| 6.18 | Info | `goOffline` | Exiting operators excluded from slashable set (escape hatch) |
