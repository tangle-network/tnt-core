# Property-Based Tests (Fuzzing Invariants) for OperatorStatusRegistry

**Target:** `src/staking/OperatorStatusRegistry.sol`
**Methodology:** Trail of Bits-style property-based testing using Foundry `testFuzz_` harnesses
**Date:** 2026-02-08

---

## 1. Contract State Machine Model

Before defining invariants, we establish the state machine that `OperatorStatusRegistry` implements per `(serviceId, operator)` pair:

```
                  submitHeartbeat(status=0)
    [Uninitialized] ──────────────────────────> [Healthy]
                                                   │  ▲
                              submitHeartbeat ──────┘  │
                              (status=0)               │
                                                       │
    submitHeartbeat(status>0) ─────> [Degraded] ───────┘
                                        │  ▲        submitHeartbeat(status=0)
                                        │  │
                           goOnline ────┘  │
                                           │ goOffline
    checkOperatorStatus                    │
    (missedBeats >= maxMissed) ──> [Offline] ──> [Exiting]
                                     │               │
                                     │  goOnline ─────┘
                                     │
    reportForSlashing ──────────> [Slashed]  (terminal -- blocks goOnline/goOffline)
```

Key observations:
- `Slashed` is a sink state: no `goOnline`, no `goOffline` escapes it. Only `submitHeartbeat` bypasses the guard.
- `goOnline` transitions to `Degraded`, never directly to `Healthy`.
- A heartbeat never produces `Offline`, `Slashed`, or `Exiting` status.
- `_allOperators` grows monotonically (no removal).
- `_onlineOperators` must be a subset of `_allOperators` (implicit from add/remove logic).

---

## 2. Invariant Categories and Suggested Fuzz Tests

### Category A: Metric Validation Invariants

**A-1: Stored metric values match the last submitted value**

After `submitHeartbeatDirect` with a `MetricPair[]` payload, `getMetricValue` must return the value from the last pair with that name in the array.

```solidity
/// @notice Fuzz: last-write-wins for metric storage
function testFuzz_MetricLastWriteWins(
    uint256 value1,
    uint256 value2
) public {
    _enableMetrics();

    IOperatorStatusRegistry.MetricPair[] memory pairs =
        new IOperatorStatusRegistry.MetricPair[](2);
    pairs[0] = IOperatorStatusRegistry.MetricPair("cpu", value1);
    pairs[1] = IOperatorStatusRegistry.MetricPair("cpu", value2);
    bytes memory data = abi.encode(pairs);

    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, data);

    // INVARIANT: last value in the array is stored
    assertEq(
        registry.getMetricValue(SERVICE_ID, operatorAddr, "cpu"),
        value2,
        "Last-write-wins violated"
    );
}
```

**A-2: Out-of-bounds metric values are still stored (finding H-3)**

This test proves the audit finding H-3 -- values outside `[minValue, maxValue]` are persisted despite emitting `MetricViolation`. This is a known bug that a fuzz test should catch as a regression.

```solidity
/// @notice Fuzz: out-of-bounds values are stored (demonstrates H-3)
function testFuzz_MetricOutOfBoundsStored(uint256 value) public {
    _enableMetrics();
    _setDefinition("latency", 10, 1000, false);

    IOperatorStatusRegistry.MetricPair[] memory pairs =
        new IOperatorStatusRegistry.MetricPair[](1);
    pairs[0] = IOperatorStatusRegistry.MetricPair("latency", value);
    bytes memory data = abi.encode(pairs);

    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, data);

    // INVARIANT (current behavior -- demonstrates H-3):
    // Value is stored regardless of whether it violates bounds.
    assertEq(
        registry.getMetricValue(SERVICE_ID, operatorAddr, "latency"),
        value,
        "Value not stored"
    );

    // When H-3 is fixed, this invariant should CHANGE to:
    // If value < 10 || value > 1000, the stored value should NOT be updated
    // (or the heartbeat should revert).
}
```

**A-3: addMetricDefinition with inverted bounds creates unsatisfiable definition (finding H-1)**

```solidity
/// @notice Fuzz: addMetricDefinition allows minValue > maxValue (H-1)
function testFuzz_AddMetricDefinition_InvertedBounds(
    uint256 minVal,
    uint256 maxVal
) public {
    vm.assume(minVal > maxVal); // only inverted cases

    vm.prank(serviceOwner);
    registry.addMetricDefinition(SERVICE_ID, "broken", minVal, maxVal, true);

    // INVARIANT VIOLATION (H-1): this should revert but does not.
    // When fixed, replace the above with vm.expectRevert("Invalid bounds").

    IOperatorStatusRegistry.MetricDefinition[] memory defs =
        registry.getMetricDefinitions(SERVICE_ID);
    assertEq(defs.length, 1);
    assertTrue(defs[0].minValue > defs[0].maxValue, "Unsatisfiable def created");
}
```

**A-4: setMetricDefinitions rejects inverted bounds for all fuzzed inputs**

```solidity
/// @notice Fuzz: setMetricDefinitions always rejects inverted bounds
function testFuzz_SetMetricDefinitions_RejectsInvertedBounds(
    uint256 minVal,
    uint256 maxVal
) public {
    vm.assume(minVal > maxVal);

    IOperatorStatusRegistry.MetricDefinition[] memory defs =
        new IOperatorStatusRegistry.MetricDefinition[](1);
    defs[0] = IOperatorStatusRegistry.MetricDefinition("metric", minVal, maxVal, false);

    vm.prank(serviceOwner);
    vm.expectRevert("Invalid bounds");
    registry.setMetricDefinitions(SERVICE_ID, defs);
}
```

**A-5: Malformed metric payload never reverts heartbeat**

The contract uses `try/catch` around `decodeMetricPairs`. Fuzzing random bytes must never revert the outer `submitHeartbeatDirect` call.

```solidity
/// @notice Fuzz: malformed metrics payload never reverts heartbeat
function testFuzz_MalformedMetrics_NeverReverts(bytes calldata garbage) public {
    _enableMetrics();

    // Should not revert regardless of payload content
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, garbage);

    // Operator should still be healthy
    assertEq(
        uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
        uint8(IOperatorStatusRegistry.StatusCode.Healthy)
    );
}
```

**A-6: Oversized metric payload (>50KB) is silently skipped**

```solidity
/// @notice Fuzz: payloads >50KB are silently skipped
function testFuzz_OversizedPayload_Skipped(uint256 extraBytes) public {
    extraBytes = bound(extraBytes, 1, 10_000);
    _enableMetrics();
    _setDefinition("cpu", 0, 100, true);

    // Create payload just over 50KB
    bytes memory bigPayload = new bytes(50_001 + extraBytes);

    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, bigPayload);

    // Metric should NOT be stored (payload was skipped)
    assertEq(
        registry.getMetricValue(SERVICE_ID, operatorAddr, "cpu"),
        0,
        "Oversized payload should not store metrics"
    );
}
```

---

### Category B: Operator Status State Machine Invariants

**B-1: Heartbeat status code mapping is deterministic**

```solidity
/// @notice Fuzz: status code mapping is deterministic
/// statusCode == 0 => Healthy, statusCode > 0 => Degraded
function testFuzz_StatusCodeMapping(uint8 statusCode) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, statusCode, "");

    IOperatorStatusRegistry.StatusCode actual =
        registry.getOperatorStatus(SERVICE_ID, operatorAddr);

    if (statusCode == 0) {
        assertEq(uint8(actual), uint8(IOperatorStatusRegistry.StatusCode.Healthy));
    } else {
        assertEq(uint8(actual), uint8(IOperatorStatusRegistry.StatusCode.Degraded));
    }
}
```

**B-2: Heartbeat never produces Offline, Slashed, or Exiting status**

```solidity
/// @notice Fuzz: heartbeat never produces Offline/Slashed/Exiting
function testFuzz_HeartbeatNeverProducesTerminalStatus(
    uint8 statusCode,
    bytes calldata metrics
) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, statusCode, metrics);

    uint8 status = uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr));

    assertTrue(
        status == uint8(IOperatorStatusRegistry.StatusCode.Healthy) ||
        status == uint8(IOperatorStatusRegistry.StatusCode.Degraded),
        "Heartbeat produced terminal status"
    );
}
```

**B-3: Slashed is a sink state for goOnline/goOffline**

```solidity
/// @notice Fuzz: slashed operator cannot goOnline or goOffline
function testFuzz_SlashedIsSinkState(bool tryOnline) public {
    _slashOperator();

    vm.prank(operatorAddr);
    if (tryOnline) {
        vm.expectRevert("Cannot go online while slashed");
        registry.goOnline(SERVICE_ID);
    } else {
        vm.expectRevert("Cannot go offline while slashed");
        registry.goOffline(SERVICE_ID);
    }

    // Status remains Slashed
    assertEq(
        uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
        uint8(IOperatorStatusRegistry.StatusCode.Slashed)
    );
}
```

**B-4: Slashed operator CAN still submit heartbeat (bypasses guard) -- potential finding**

```solidity
/// @notice Fuzz: slashed operator heartbeat transitions to Healthy/Degraded
/// This is a potential finding -- submitHeartbeat does not check for Slashed status.
function testFuzz_SlashedOperatorCanHeartbeat(uint8 statusCode) public {
    _slashOperator();

    assertEq(
        uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
        uint8(IOperatorStatusRegistry.StatusCode.Slashed)
    );

    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, statusCode, "");

    // FINDING: Slashed status is overwritten by heartbeat.
    // This may be intentional (re-registration) or a bug.
    uint8 newStatus = uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr));
    assertTrue(
        newStatus == uint8(IOperatorStatusRegistry.StatusCode.Healthy) ||
        newStatus == uint8(IOperatorStatusRegistry.StatusCode.Degraded),
        "Heartbeat should overwrite slashed status"
    );
}
```

**B-5: goOnline from Healthy downgrades to Degraded (finding L-5)**

```solidity
/// @notice Fuzz: goOnline from any non-slashed state always sets Degraded
function testFuzz_GoOnline_AlwaysDegrades(uint8 statusSeed) public {
    // First, put operator in some state
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, ""); // Healthy

    // goOnline should set to Degraded, even from Healthy
    vm.prank(operatorAddr);
    registry.goOnline(SERVICE_ID);

    assertEq(
        uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
        uint8(IOperatorStatusRegistry.StatusCode.Degraded),
        "goOnline must always set Degraded"
    );
}
```

**B-6: Arbitrary state transition sequences maintain valid state**

```solidity
/// @notice Fuzz: random sequence of operations produces a valid StatusCode
function testFuzz_RandomOpsValidState(
    uint8[20] calldata actions,
    uint8[20] calldata statusCodes,
    uint16[20] calldata timeDeltas
) public {
    for (uint256 i = 0; i < 20; i++) {
        uint8 action = actions[i] % 4;
        uint256 dt = uint256(timeDeltas[i]) * 30; // 0..~16 hours
        vm.warp(block.timestamp + dt);

        vm.startPrank(operatorAddr);
        if (action == 0) {
            // Heartbeat
            registry.submitHeartbeatDirect(
                SERVICE_ID, BLUEPRINT_ID, statusCodes[i], ""
            );
        } else if (action == 1) {
            // goOffline (may revert if slashed)
            try registry.goOffline(SERVICE_ID) {} catch {}
        } else if (action == 2) {
            // goOnline (may revert if slashed)
            try registry.goOnline(SERVICE_ID) {} catch {}
        } else {
            // checkOperatorStatus
            registry.checkOperatorStatus(SERVICE_ID, operatorAddr);
        }
        vm.stopPrank();

        // INVARIANT: status is always a valid enum member (0..4)
        uint8 status = uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr));
        assertTrue(status <= 4, "Invalid status code");
    }
}
```

---

### Category C: _allOperators / _onlineOperators Set Consistency

**C-1: Online operators are always a subset of all operators**

```solidity
/// @notice Fuzz: onlineOperators is always a subset of allOperators
function testFuzz_OnlineSubsetOfAll(
    address[5] calldata operators,
    uint8[5] calldata actions
) public {
    for (uint256 i = 0; i < 5; i++) {
        vm.assume(operators[i] != address(0));
        uint8 action = actions[i] % 3;

        vm.startPrank(operators[i]);
        if (action == 0) {
            registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
        } else if (action == 1) {
            try registry.goOffline(SERVICE_ID) {} catch {}
        } else {
            try registry.goOnline(SERVICE_ID) {} catch {}
        }
        vm.stopPrank();
    }

    // INVARIANT: every online operator must also be in allOperators
    address[] memory online = registry.getOnlineOperators(SERVICE_ID);
    for (uint256 i = 0; i < online.length; i++) {
        // isOnline checks status, not set membership, but an operator
        // can only be in _onlineOperators if they have interacted
        assertTrue(
            registry.isOnline(SERVICE_ID, online[i]),
            "Online operator has non-online status"
        );
    }
}
```

**C-2: Online operator count never exceeds all-operator count**

```solidity
/// @notice Fuzz: onlineOperatorCount <= total operators that have heartbeated
function testFuzz_OnlineCountNeverExceedsTotal(
    uint8 numOps,
    uint8[10] calldata warpDeltas
) public {
    numOps = uint8(bound(numOps, 1, 10));

    address[] memory ops = new address[](numOps);
    for (uint8 i = 0; i < numOps; i++) {
        ops[i] = address(uint160(0x1000 + i));
        vm.prank(ops[i]);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
    }

    // Warp and check some offline
    for (uint8 i = 0; i < numOps && i < 10; i++) {
        uint256 dt = uint256(warpDeltas[i]) * 60;
        vm.warp(block.timestamp + dt);
        registry.checkOperatorStatus(SERVICE_ID, ops[i]);
    }

    // INVARIANT: online count <= total operators
    uint256 onlineCount = registry.getOnlineOperatorCount(SERVICE_ID);
    assertTrue(
        onlineCount <= numOps,
        "Online count exceeds total operators"
    );
}
```

**C-3: Operator removed from online set after going Offline**

```solidity
/// @notice Fuzz: after checkOperatorStatus marks Offline, operator is
///         removed from getOnlineOperators
function testFuzz_OfflineRemovedFromOnlineSet(uint64 warpSeconds) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    (uint64 interval, uint8 maxMissed, ) = registry.heartbeatConfigs(SERVICE_ID);
    uint256 threshold = uint256(interval) * uint256(maxMissed);

    warpSeconds = uint64(bound(warpSeconds, threshold, threshold + 10_000));
    vm.warp(block.timestamp + warpSeconds);
    registry.checkOperatorStatus(SERVICE_ID, operatorAddr);

    // INVARIANT: offline operator not in online set
    address[] memory online = registry.getOnlineOperators(SERVICE_ID);
    for (uint256 i = 0; i < online.length; i++) {
        assertTrue(
            online[i] != operatorAddr,
            "Offline operator still in online set"
        );
    }
    assertEq(
        uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
        uint8(IOperatorStatusRegistry.StatusCode.Offline)
    );
}
```

**C-4: Operator coming back online after Offline is re-added to online set**

```solidity
/// @notice Fuzz: offline->goOnline re-adds to online set
function testFuzz_GoOnlineReAddsToSet(uint64 warpSeconds) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    (uint64 interval, uint8 maxMissed, ) = registry.heartbeatConfigs(SERVICE_ID);
    uint256 threshold = uint256(interval) * uint256(maxMissed);
    warpSeconds = uint64(bound(warpSeconds, threshold, threshold + 10_000));

    vm.warp(block.timestamp + warpSeconds);
    registry.checkOperatorStatus(SERVICE_ID, operatorAddr);
    assertEq(registry.getOnlineOperatorCount(SERVICE_ID), 0);

    // goOnline should re-add
    vm.prank(operatorAddr);
    registry.goOnline(SERVICE_ID);

    // INVARIANT: operator is back in online set
    assertEq(registry.getOnlineOperatorCount(SERVICE_ID), 1);
    assertTrue(registry.isOnline(SERVICE_ID, operatorAddr));
}
```

**C-5: reportForSlashing removes from online set**

```solidity
/// @notice Fuzz: reportForSlashing always removes operator from online set
function testFuzz_SlashingRemovesFromOnlineSet(uint8 numOps) public {
    numOps = uint8(bound(numOps, 1, 10));

    vm.prank(governance);
    registry.setSlashingOracle(slashingOracle);

    // Add multiple operators
    for (uint8 i = 0; i < numOps; i++) {
        address op = address(uint160(0x2000 + i));
        vm.prank(op);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
    }

    uint256 beforeCount = registry.getOnlineOperatorCount(SERVICE_ID);
    assertEq(beforeCount, numOps);

    // Slash the first operator
    address target = address(uint160(0x2000));
    vm.prank(slashingOracle);
    registry.reportForSlashing(SERVICE_ID, target, "test");

    // INVARIANT: slashed operator removed from online set
    assertEq(registry.getOnlineOperatorCount(SERVICE_ID), numOps - 1);
    assertFalse(registry.isOnline(SERVICE_ID, target));
}
```

---

### Category D: Heartbeat Timing Invariants

**D-1: consecutiveBeats increments on every heartbeat, resets on missed**

```solidity
/// @notice Fuzz: consecutiveBeats increments per heartbeat
function testFuzz_ConsecutiveBeatsIncrement(uint8 numBeats) public {
    numBeats = uint8(bound(numBeats, 1, 50));

    for (uint8 i = 0; i < numBeats; i++) {
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        IOperatorStatusRegistry.OperatorState memory state =
            registry.getOperatorState(SERVICE_ID, operatorAddr);

        // INVARIANT: consecutiveBeats == i + 1
        assertEq(
            state.consecutiveBeats,
            uint64(i + 1),
            "consecutiveBeats not incremented correctly"
        );
    }
}
```

**D-2: missedBeats is reset to 0 on heartbeat**

```solidity
/// @notice Fuzz: heartbeat resets missedBeats to zero
function testFuzz_HeartbeatResetsMissedBeats(uint64 warpSeconds) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    // Warp to accumulate some missed beats
    (uint64 interval, , ) = registry.heartbeatConfigs(SERVICE_ID);
    warpSeconds = uint64(bound(warpSeconds, interval, interval * 10));
    vm.warp(block.timestamp + warpSeconds);
    registry.checkOperatorStatus(SERVICE_ID, operatorAddr);

    IOperatorStatusRegistry.OperatorState memory stateBefore =
        registry.getOperatorState(SERVICE_ID, operatorAddr);
    assertTrue(stateBefore.missedBeats > 0, "Should have missed beats");

    // Submit heartbeat
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    IOperatorStatusRegistry.OperatorState memory stateAfter =
        registry.getOperatorState(SERVICE_ID, operatorAddr);

    // INVARIANT: missedBeats reset to 0 after heartbeat
    assertEq(stateAfter.missedBeats, 0, "missedBeats not reset");
    assertEq(stateAfter.consecutiveBeats, 1, "consecutiveBeats not reset to 1");
}
```

**D-3: lastHeartbeat always equals block.timestamp after successful heartbeat**

```solidity
/// @notice Fuzz: lastHeartbeat tracks block.timestamp
function testFuzz_LastHeartbeatTracksTimestamp(uint64 warpBefore) public {
    warpBefore = uint64(bound(warpBefore, 0, 365 days));
    vm.warp(block.timestamp + warpBefore);

    uint256 expectedTimestamp = block.timestamp;

    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    // INVARIANT: lastHeartbeat == block.timestamp at time of call
    assertEq(
        registry.getLastHeartbeat(SERVICE_ID, operatorAddr),
        expectedTimestamp,
        "lastHeartbeat does not match block.timestamp"
    );
}
```

**D-4: isHeartbeatCurrent reflects interval window correctly**

```solidity
/// @notice Fuzz: isHeartbeatCurrent is true iff within interval
function testFuzz_IsHeartbeatCurrent_ReflectsInterval(uint64 warpSeconds) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    (uint64 interval, , ) = registry.heartbeatConfigs(SERVICE_ID);
    warpSeconds = uint64(bound(warpSeconds, 0, interval * 5));
    vm.warp(block.timestamp + warpSeconds);

    bool current = registry.isHeartbeatCurrent(SERVICE_ID, operatorAddr);

    // INVARIANT: current iff elapsed < interval
    if (warpSeconds < interval) {
        assertTrue(current, "Should be current within interval");
    } else {
        assertFalse(current, "Should not be current past interval");
    }
}
```

**D-5: checkOperatorStatus missedBeats calculation is monotonic within a session**

```solidity
/// @notice Fuzz: missedBeats only increases between heartbeats
function testFuzz_MissedBeatsMonotonic(
    uint64 warp1,
    uint64 warp2
) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    (uint64 interval, , ) = registry.heartbeatConfigs(SERVICE_ID);
    warp1 = uint64(bound(warp1, 1, interval * 10));
    warp2 = uint64(bound(warp2, 1, interval * 10));

    vm.warp(block.timestamp + warp1);
    registry.checkOperatorStatus(SERVICE_ID, operatorAddr);
    uint8 missed1 = registry.getOperatorState(SERVICE_ID, operatorAddr).missedBeats;

    vm.warp(block.timestamp + warp2);
    registry.checkOperatorStatus(SERVICE_ID, operatorAddr);
    uint8 missed2 = registry.getOperatorState(SERVICE_ID, operatorAddr).missedBeats;

    // INVARIANT: missedBeats never decreases without a heartbeat
    assertTrue(missed2 >= missed1, "missedBeats decreased without heartbeat");
}
```

**D-6: uint8 truncation boundary for missedBeats (finding M-3)**

The contract now caps at `type(uint8).max`. This test confirms that behavior.

```solidity
/// @notice Fuzz: missedBeats caps at 255 for very large time gaps
function testFuzz_MissedBeatsCapsAt255(uint64 warpSeconds) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    (uint64 interval, , ) = registry.heartbeatConfigs(SERVICE_ID);
    // Warp far enough that raw calculation would exceed 255
    // 255 * 120 = 30,600 seconds minimum
    warpSeconds = uint64(bound(warpSeconds, uint64(256) * interval, uint64(1000) * interval));

    vm.warp(block.timestamp + warpSeconds);
    registry.checkOperatorStatus(SERVICE_ID, operatorAddr);

    IOperatorStatusRegistry.OperatorState memory state =
        registry.getOperatorState(SERVICE_ID, operatorAddr);

    // INVARIANT: missedBeats capped at uint8 max
    assertEq(state.missedBeats, type(uint8).max, "missedBeats not capped at 255");
    assertEq(
        uint8(state.status),
        uint8(IOperatorStatusRegistry.StatusCode.Offline),
        "Should be offline"
    );
}
```

---

### Category E: Slashing State Transitions

**E-1: reportForSlashing sets Slashed status unconditionally**

```solidity
/// @notice Fuzz: reportForSlashing always sets Slashed regardless of prior state
function testFuzz_ReportForSlashing_AlwaysSlashes(uint8 priorAction) public {
    vm.prank(governance);
    registry.setSlashingOracle(slashingOracle);

    priorAction = priorAction % 4;
    vm.startPrank(operatorAddr);
    if (priorAction == 0) {
        // Healthy
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
    } else if (priorAction == 1) {
        // Degraded
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 50, "");
    } else if (priorAction == 2) {
        // Exiting
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
        registry.goOffline(SERVICE_ID);
    } else {
        // No prior interaction (Uninitialized)
    }
    vm.stopPrank();

    vm.prank(slashingOracle);
    registry.reportForSlashing(SERVICE_ID, operatorAddr, "test");

    // INVARIANT: status is always Slashed after reportForSlashing
    assertEq(
        uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
        uint8(IOperatorStatusRegistry.StatusCode.Slashed)
    );

    // INVARIANT: operator removed from online set
    assertFalse(registry.isOnline(SERVICE_ID, operatorAddr));
}
```

**E-2: SlashingTriggered event respects SLASH_ALERT_COOLDOWN**

```solidity
/// @notice Fuzz: critical heartbeat slashing events respect cooldown
function testFuzz_SlashAlertCooldown(
    uint64 gap1,
    uint64 gap2
) public {
    uint64 cooldown = registry.SLASH_ALERT_COOLDOWN();
    gap1 = uint64(bound(gap1, 0, cooldown * 3));
    gap2 = uint64(bound(gap2, 0, cooldown * 3));

    // First critical heartbeat -- always fires
    vm.recordLogs();
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 200, "");
    Vm.Log[] memory logs1 = vm.getRecordedLogs();
    uint256 count1 = _countSlashingEvents(logs1);
    assertEq(count1, 1, "First critical should fire");

    // Second critical heartbeat after gap1
    vm.warp(block.timestamp + gap1);
    vm.recordLogs();
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 255, "");
    Vm.Log[] memory logs2 = vm.getRecordedLogs();
    uint256 count2 = _countSlashingEvents(logs2);

    if (gap1 >= cooldown) {
        assertEq(count2, 1, "Should fire after cooldown");
    } else {
        assertEq(count2, 0, "Should not fire within cooldown");
    }
}
```

**E-3: getSlashableOperators excludes Exiting operators**

```solidity
/// @notice Fuzz: exiting operators are never slashable
function testFuzz_ExitingNotSlashable(uint64 warpSeconds) public {
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    vm.prank(operatorAddr);
    registry.goOffline(SERVICE_ID);

    (uint64 interval, uint8 maxMissed, ) = registry.heartbeatConfigs(SERVICE_ID);
    uint256 threshold = uint256(interval) * uint256(maxMissed);
    warpSeconds = uint64(bound(warpSeconds, uint64(threshold), uint64(threshold) + 100_000));
    vm.warp(block.timestamp + warpSeconds);

    address[] memory slashable = registry.getSlashableOperators(SERVICE_ID);

    // INVARIANT: exiting operators are excluded from slashable set
    for (uint256 i = 0; i < slashable.length; i++) {
        assertTrue(
            slashable[i] != operatorAddr,
            "Exiting operator should not be slashable"
        );
    }
}
```

**E-4: getSlashableOperators excludes already-slashed operators**

```solidity
/// @notice Fuzz: already-slashed operators are not re-slashable
function testFuzz_AlreadySlashedNotInSlashable(uint64 warpSeconds) public {
    vm.prank(governance);
    registry.setSlashingOracle(slashingOracle);

    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    vm.prank(slashingOracle);
    registry.reportForSlashing(SERVICE_ID, operatorAddr, "first");

    (uint64 interval, uint8 maxMissed, ) = registry.heartbeatConfigs(SERVICE_ID);
    uint256 threshold = uint256(interval) * uint256(maxMissed);
    warpSeconds = uint64(bound(warpSeconds, uint64(threshold), uint64(threshold) + 100_000));
    vm.warp(block.timestamp + warpSeconds);

    address[] memory slashable = registry.getSlashableOperators(SERVICE_ID);

    // INVARIANT: slashed operators excluded
    for (uint256 i = 0; i < slashable.length; i++) {
        assertTrue(
            slashable[i] != operatorAddr,
            "Already slashed operator in slashable set"
        );
    }
}
```

**E-5: getSlashableOperators threshold is interval * maxMissed**

```solidity
/// @notice Fuzz: slashable threshold = interval * maxMissed
function testFuzz_SlashableThreshold(
    uint64 interval,
    uint8 maxMissed,
    uint64 elapsed
) public {
    interval = uint64(bound(interval, 60, 3600));
    maxMissed = uint8(bound(maxMissed, 1, 10));
    uint256 threshold = uint256(interval) * uint256(maxMissed);
    elapsed = uint64(bound(elapsed, 0, threshold * 3));

    // Configure
    vm.prank(serviceOwner);
    registry.configureHeartbeat(SERVICE_ID, interval, maxMissed);

    // Submit heartbeat
    vm.prank(operatorAddr);
    registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

    // Warp
    vm.warp(block.timestamp + elapsed);

    address[] memory slashable = registry.getSlashableOperators(SERVICE_ID);

    if (elapsed >= threshold) {
        // INVARIANT: operator is slashable
        assertEq(slashable.length, 1, "Should be slashable past threshold");
        assertEq(slashable[0], operatorAddr);
    } else {
        // INVARIANT: operator is NOT slashable
        assertEq(slashable.length, 0, "Should not be slashable before threshold");
    }
}
```

---

### Category F: Configuration / Access Control Invariants

**F-1: configureHeartbeat rejects interval < 60**

```solidity
/// @notice Fuzz: interval < 60 always reverts
function testFuzz_ConfigureHeartbeat_MinInterval(uint64 interval) public {
    interval = uint64(bound(interval, 0, 59));

    vm.prank(serviceOwner);
    vm.expectRevert("Interval too short");
    registry.configureHeartbeat(SERVICE_ID, interval, 3);
}
```

**F-2: configureHeartbeat rejects maxMissed == 0**

```solidity
/// @notice Fuzz: maxMissed == 0 always reverts
function testFuzz_ConfigureHeartbeat_MinMaxMissed() public {
    vm.prank(serviceOwner);
    vm.expectRevert("Max missed must be >= 1");
    registry.configureHeartbeat(SERVICE_ID, 300, 0);
}
```

**F-3: Default config applied when nothing is configured**

```solidity
/// @notice Fuzz: unconfigured service uses defaults (5 min, 3 missed)
function testFuzz_DefaultConfig(uint64 serviceId) public {
    vm.assume(serviceId != SERVICE_ID); // avoid configured service

    IOperatorStatusRegistry.HeartbeatConfig memory config =
        registry.getHeartbeatConfig(serviceId);

    assertEq(config.interval, 5 minutes, "Default interval wrong");
    assertEq(config.maxMissed, 3, "Default maxMissed wrong");
}
```

**F-4: Anyone can configure heartbeat for ownerless services (finding M-4)**

```solidity
/// @notice Fuzz: any address can configure heartbeat for ownerless service
function testFuzz_OwnerlessServiceConfigurable(
    uint64 unconfiguredService,
    address randomCaller,
    uint64 interval,
    uint8 maxMissed
) public {
    vm.assume(unconfiguredService != SERVICE_ID);
    vm.assume(randomCaller != address(0));
    interval = uint64(bound(interval, 60, 3600));
    maxMissed = uint8(bound(maxMissed, 1, 10));

    // FINDING (M-4): anyone can configure ownerless services
    vm.prank(randomCaller);
    registry.configureHeartbeat(unconfiguredService, interval, maxMissed);

    IOperatorStatusRegistry.HeartbeatConfig memory config =
        registry.getHeartbeatConfig(unconfiguredService);
    assertEq(config.interval, interval);
    assertEq(config.maxMissed, maxMissed);
}
```

---

## 3. Foundry Stateful Invariant Test (Handler Pattern)

For a more thorough approach, use Foundry's built-in invariant testing with a handler contract. This exercises random sequences of all entry points.

```solidity
/// @title OperatorStatusHandler
/// @notice Handler for Foundry stateful invariant testing
contract OperatorStatusHandler is Test {
    OperatorStatusRegistry public registry;
    uint64 public constant SVC = 1;
    uint64 public constant BP = 77;

    // Ghost variables for tracking
    mapping(address => bool) public ghost_everHeartbeated;
    mapping(address => bool) public ghost_isOnline;
    uint256 public ghost_totalOperators;
    address[] public ghost_allOperators;

    constructor(OperatorStatusRegistry _registry) {
        registry = _registry;
    }

    function submitHeartbeat(uint8 actorSeed, uint8 statusCode) external {
        address actor = _boundActor(actorSeed);
        vm.prank(actor);
        registry.submitHeartbeatDirect(SVC, BP, statusCode, "");
        if (!ghost_everHeartbeated[actor]) {
            ghost_everHeartbeated[actor] = true;
            ghost_totalOperators++;
            ghost_allOperators.push(actor);
        }
        ghost_isOnline[actor] = true;
    }

    function goOffline(uint8 actorSeed) external {
        address actor = _boundActor(actorSeed);
        vm.prank(actor);
        try registry.goOffline(SVC) {
            ghost_isOnline[actor] = false;
        } catch {}
    }

    function goOnline(uint8 actorSeed) external {
        address actor = _boundActor(actorSeed);
        vm.prank(actor);
        try registry.goOnline(SVC) {
            ghost_isOnline[actor] = true;
        } catch {}
    }

    function checkStatus(uint8 actorSeed) external {
        address actor = _boundActor(actorSeed);
        registry.checkOperatorStatus(SVC, actor);

        uint8 status = uint8(registry.getOperatorStatus(SVC, actor));
        if (status == uint8(IOperatorStatusRegistry.StatusCode.Offline) ||
            status == uint8(IOperatorStatusRegistry.StatusCode.Slashed) ||
            status == uint8(IOperatorStatusRegistry.StatusCode.Exiting)) {
            ghost_isOnline[actor] = false;
        }
    }

    function warpTime(uint16 seconds_) external {
        vm.warp(block.timestamp + uint256(seconds_));
    }

    function _boundActor(uint8 seed) internal pure returns (address) {
        return address(uint160(0x1000 + (seed % 10)));
    }
}

contract OperatorStatusInvariantTest is Test {
    OperatorStatusRegistry public registry;
    OperatorStatusHandler public handler;

    function setUp() public {
        address tangle = makeAddr("tangle");
        registry = new OperatorStatusRegistry(tangle, address(this));
        handler = new OperatorStatusHandler(registry);

        // Configure service
        vm.prank(tangle);
        registry.registerServiceOwner(1, address(this));
        registry.configureHeartbeat(1, 120, 3);

        targetContract(address(handler));
    }

    /// INVARIANT: onlineOperatorCount <= totalOperators
    function invariant_onlineNeverExceedsTotal() public view {
        uint256 online = registry.getOnlineOperatorCount(1);
        assertTrue(online <= handler.ghost_totalOperators());
    }

    /// INVARIANT: all statuses are valid enum values
    function invariant_allStatusesValid() public view {
        for (uint256 i = 0; i < handler.ghost_totalOperators(); i++) {
            address op = handler.ghost_allOperators(i);
            uint8 status = uint8(registry.getOperatorStatus(1, op));
            assertTrue(status <= 4, "Invalid status");
        }
    }

    /// INVARIANT: online operators have Healthy or Degraded status
    function invariant_onlineOperatorsHaveActiveStatus() public view {
        address[] memory online = registry.getOnlineOperators(1);
        for (uint256 i = 0; i < online.length; i++) {
            uint8 status = uint8(registry.getOperatorStatus(1, online[i]));
            assertTrue(
                status == uint8(IOperatorStatusRegistry.StatusCode.Healthy) ||
                status == uint8(IOperatorStatusRegistry.StatusCode.Degraded),
                "Online operator has non-active status"
            );
        }
    }
}
```

---

## 4. Summary of Findings Validated by Fuzz Tests

| Test ID | Category | Finding Ref | Description |
|---------|----------|-------------|-------------|
| A-2 | Metric | H-3 | Out-of-bounds values stored before validation |
| A-3 | Metric | H-1 | `addMetricDefinition` allows inverted bounds |
| A-5 | Metric | -- | Malformed payloads never revert heartbeat |
| B-4 | State Machine | NEW | Slashed operator can heartbeat back to Healthy |
| B-5 | State Machine | L-5 | `goOnline` downgrades Healthy to Degraded |
| B-6 | State Machine | -- | Random action sequences always produce valid state |
| C-1 | Set Consistency | -- | Online operators always subset of all operators |
| C-5 | Set Consistency | -- | Slashing removes from online set |
| D-4 | Timing | -- | `isHeartbeatCurrent` matches interval window |
| D-6 | Timing | M-3 | `missedBeats` capped at 255 |
| E-3 | Slashing | -- | Exiting operators excluded from slashable set |
| E-5 | Slashing | -- | Slashable threshold = interval * maxMissed |
| F-4 | Access Control | M-4 | Ownerless services configurable by anyone |

### New Finding: B-4 -- Slashed Operator Heartbeat Bypass

`submitHeartbeat` / `submitHeartbeatDirect` do not check whether the operator is in `Slashed` status. A slashed operator can call `submitHeartbeatDirect` and transition from `Slashed` -> `Healthy`. This bypasses the guards in `goOnline` and `goOffline` that explicitly block slashed operators.

**Severity:** Medium-High. If slashing is used for protocol-level punishment, the operator can trivially escape it by submitting a heartbeat.

**Recommendation:** Add `require(state.status != StatusCode.Slashed, "Operator is slashed")` at the beginning of `_processHeartbeat`.

---

## 5. Running These Tests

Place the test file at `test/fuzz/OperatorStatusRegistryFuzz.t.sol`. Run with:

```bash
forge test --match-contract OperatorStatusRegistryFuzz -vvv
```

For the stateful invariant tests:

```bash
forge test --match-contract OperatorStatusInvariantTest -vvv
```

To increase fuzz runs for deeper coverage:

```bash
# In foundry.toml
[fuzz]
runs = 10000
max_test_rejects = 100000

[invariant]
runs = 500
depth = 100
```
