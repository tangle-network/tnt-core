// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, Vm} from "forge-std/Test.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {OperatorStatusRegistry, IOperatorStatusRegistry} from "../../src/staking/OperatorStatusRegistry.sol";
import {IMetricsRecorder} from "../../src/interfaces/IMetricsRecorder.sol";

contract MockMetricsRecorder is IMetricsRecorder {
    uint256 public heartbeatCount;
    address public lastOperator;
    uint64 public lastServiceId;

    function recordStake(address, address, address, uint256) external {}
    function recordUnstake(address, address, address, uint256) external {}
    function recordOperatorRegistered(address, address, uint256) external {}

    function recordHeartbeat(address operator, uint64 serviceId, uint64) external override {
        heartbeatCount++;
        lastOperator = operator;
        lastServiceId = serviceId;
    }

    function recordJobCompletion(address, uint64, uint64, bool) external {}
    function recordSlash(address, uint64, uint256) external {}
    function recordServiceCreated(uint64, uint64, address, uint256) external {}
    function recordServiceTerminated(uint64, uint256) external {}
    function recordJobCall(uint64, address, uint64) external {}
    function recordPayment(address, uint64, address, uint256) external {}
    function recordBlueprintCreated(uint64, address) external {}
    function recordBlueprintRegistration(uint64, address) external {}
}

contract OperatorStatusRegistryTest is Test {
    OperatorStatusRegistry internal registry;
    MockMetricsRecorder internal metrics;
    bytes32 internal constant SLASHING_SIG = keccak256("SlashingTriggered(uint64,address,string)");

    address internal tangle = makeAddr("tangle");
    address internal governance = makeAddr("governance");
    address internal serviceOwner = makeAddr("serviceOwner");
    address internal slashingOracle = makeAddr("oracle");

    uint64 internal constant SERVICE_ID = 1;
    uint64 internal constant BLUEPRINT_ID = 77;

    uint256 internal operatorKey = uint256(keccak256("operator"));
    address internal operatorAddr;

    function setUp() public {
        registry = new OperatorStatusRegistry(tangle, governance);
        metrics = new MockMetricsRecorder();
        operatorAddr = vm.addr(operatorKey);

        vm.prank(tangle);
        registry.registerServiceOwner(SERVICE_ID, serviceOwner);

        vm.prank(serviceOwner);
        registry.configureHeartbeat(SERVICE_ID, 120, 2);

        // Register default operator
        _registerOp(operatorAddr);
    }

    function _registerOp(address op) internal {
        vm.prank(tangle);
        registry.registerOperator(SERVICE_ID, op);
    }

    function _signHeartbeat(uint8 statusCode, bytes memory metricsData) internal view returns (bytes memory) {
        bytes32 messageHash = keccak256(abi.encodePacked(SERVICE_ID, BLUEPRINT_ID, statusCode, metricsData));
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operatorKey, ethSignedHash);
        return abi.encodePacked(r, s, v);
    }

    function test_submitHeartbeat_WithSignatureUpdatesState() public {
        bytes memory metricsData = abi.encode("status", uint256(1));
        bytes memory signature = _signHeartbeat(0, metricsData);

        vm.prank(operatorAddr);
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 0, metricsData, signature);

        IOperatorStatusRegistry.StatusCode status =
            registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Healthy));
        assertEq(registry.getLastHeartbeat(SERVICE_ID, operatorAddr), block.timestamp);
        assertTrue(registry.isHeartbeatCurrent(SERVICE_ID, operatorAddr));
    }

    function test_submitHeartbeat_InvalidSignatureReverts() public {
        bytes memory signature = abi.encodePacked(bytes32(uint256(1)), bytes32(uint256(2)), uint8(27));
        vm.prank(operatorAddr);
        vm.expectRevert("Invalid signature");
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 0, "", signature);
    }

    function test_customMetricsStoredWhenEnabled() public {
        vm.prank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        // Encode as MetricPair[] array as expected by _processMetrics
        IOperatorStatusRegistry.MetricPair[] memory pairs = new IOperatorStatusRegistry.MetricPair[](1);
        pairs[0] = IOperatorStatusRegistry.MetricPair("cpu", 42);
        bytes memory metricsData = abi.encode(pairs);
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, metricsData);

        uint256 value = registry.getMetricValue(SERVICE_ID, operatorAddr, "cpu");
        assertEq(value, 42);
    }

    function test_checkOperatorStatus_MarksOfflineAfterMissedBeats() public {
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        vm.warp(block.timestamp + 1 hours);
        registry.checkOperatorStatus(SERVICE_ID, operatorAddr);

        IOperatorStatusRegistry.StatusCode status =
            registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Offline));
    }

    function test_goOfflineAndGoOnlineTransitions() public {
        vm.startPrank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
        registry.goOffline(SERVICE_ID);
        IOperatorStatusRegistry.StatusCode status =
            registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Exiting));

        registry.goOnline(SERVICE_ID);
        status = registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Degraded));
        vm.stopPrank();
    }

    function test_configureHeartbeat_AuthorizationPaths() public {
        vm.expectRevert("Not authorized");
        registry.configureHeartbeat(SERVICE_ID, 300, 3);

        vm.prank(tangle);
        registry.configureHeartbeat(SERVICE_ID, 300, 3);

        vm.prank(serviceOwner);
        registry.configureHeartbeat(SERVICE_ID, 600, 5);
    }

    function test_registerServiceOwner_OnlyTangle() public {
        vm.expectRevert("Only Tangle core");
        registry.registerServiceOwner(2, serviceOwner);
    }

    function test_enableCustomMetrics_NotOwnerReverts() public {
        vm.expectRevert("Not service owner");
        registry.enableCustomMetrics(SERVICE_ID, true);
    }

    function test_addMetricDefinition_NotOwnerReverts() public {
        vm.expectRevert("Not service owner");
        registry.addMetricDefinition(SERVICE_ID, "latency", 0, 100, true);
    }

    function test_metricsRecorderHookInvoked() public {
        vm.prank(governance);
        registry.setMetricsRecorder(address(metrics));

        bytes memory signature = _signHeartbeat(0, "");
        vm.prank(operatorAddr);
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 0, "", signature);

        assertEq(metrics.heartbeatCount(), 1);
        assertEq(metrics.lastOperator(), operatorAddr);
        assertEq(metrics.lastServiceId(), SERVICE_ID);
    }

    function test_setSlashingOracleAndReport() public {
        vm.prank(governance);
        registry.setSlashingOracle(slashingOracle);

        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        vm.prank(slashingOracle);
        registry.reportForSlashing(SERVICE_ID, operatorAddr, "misbehavior");

        IOperatorStatusRegistry.StatusCode status =
            registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Slashed));
    }

    function test_reportForSlashing_NotOracleReverts() public {
        vm.expectRevert("Not slashing oracle");
        registry.reportForSlashing(SERVICE_ID, operatorAddr, "bad");
    }

    function test_getSlashableOperators_ReturnsEmpty() public view {
        address[] memory ops = registry.getSlashableOperators(SERVICE_ID);
        assertEq(ops.length, 0);
    }

    function test_SlashingTriggeredRateLimited() public {
        vm.recordLogs();
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 200, "");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        assertEq(_countSlashingEvents(logs), 1);

        vm.recordLogs();
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 201, "");
        logs = vm.getRecordedLogs();
        assertEq(_countSlashingEvents(logs), 0);

        uint64 last = registry.getLastCriticalHeartbeat(SERVICE_ID, operatorAddr);
        assertGt(last, 0);

        vm.warp(block.timestamp + registry.SLASH_ALERT_COOLDOWN() + 1);
        vm.recordLogs();
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 255, "");
        logs = vm.getRecordedLogs();
        assertEq(_countSlashingEvents(logs), 1);
    }

    function _countSlashingEvents(Vm.Log[] memory logs) internal view returns (uint256 count) {
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == SLASHING_SIG) {
                count++;
            }
        }
    }

    function test_goOffline_RevertWhenSlashed() public {
        vm.prank(governance);
        registry.setSlashingOracle(slashingOracle);

        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        vm.prank(slashingOracle);
        registry.reportForSlashing(SERVICE_ID, operatorAddr, "slash");

        vm.startPrank(operatorAddr);
        vm.expectRevert("Cannot go offline while slashed");
        registry.goOffline(SERVICE_ID);
        vm.stopPrank();
    }

    function testFuzz_SubmitHeartbeatStatusCodes(uint8 statusCode) public {
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, statusCode, "");

        IOperatorStatusRegistry.StatusCode expected =
            statusCode == 0 ? IOperatorStatusRegistry.StatusCode.Healthy : IOperatorStatusRegistry.StatusCode.Degraded;
        assertEq(uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)), uint8(expected));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Phase 1: New tests for metric validation, slashing, and batch definitions
    // ═══════════════════════════════════════════════════════════════════════════

    function test_setMetricDefinitions_ReplacesExisting() public {
        vm.startPrank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        // Set initial definitions
        IOperatorStatusRegistry.MetricDefinition[] memory defs1 = new IOperatorStatusRegistry.MetricDefinition[](1);
        defs1[0] = IOperatorStatusRegistry.MetricDefinition("cpu", 0, 100, true);
        registry.setMetricDefinitions(SERVICE_ID, defs1);

        IOperatorStatusRegistry.MetricDefinition[] memory stored = registry.getMetricDefinitions(SERVICE_ID);
        assertEq(stored.length, 1);
        assertEq(stored[0].name, "cpu");

        // Replace with new definitions
        IOperatorStatusRegistry.MetricDefinition[] memory defs2 = new IOperatorStatusRegistry.MetricDefinition[](2);
        defs2[0] = IOperatorStatusRegistry.MetricDefinition("response_time_ms", 0, 5000, true);
        defs2[1] = IOperatorStatusRegistry.MetricDefinition("uptime_percent", 0, 100, false);
        registry.setMetricDefinitions(SERVICE_ID, defs2);

        stored = registry.getMetricDefinitions(SERVICE_ID);
        assertEq(stored.length, 2);
        assertEq(stored[0].name, "response_time_ms");
        assertEq(stored[1].name, "uptime_percent");
        vm.stopPrank();
    }

    function test_setMetricDefinitions_InvalidBounds() public {
        vm.prank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        IOperatorStatusRegistry.MetricDefinition[] memory defs = new IOperatorStatusRegistry.MetricDefinition[](1);
        defs[0] = IOperatorStatusRegistry.MetricDefinition("bad", 100, 0, true); // maxValue < minValue
        vm.prank(serviceOwner);
        vm.expectRevert("Invalid bounds");
        registry.setMetricDefinitions(SERVICE_ID, defs);
    }

    function test_processMetrics_ValidatesRequiredMissing() public {
        vm.startPrank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        IOperatorStatusRegistry.MetricDefinition[] memory defs = new IOperatorStatusRegistry.MetricDefinition[](1);
        defs[0] = IOperatorStatusRegistry.MetricDefinition("required_metric", 0, 100, true);
        registry.setMetricDefinitions(SERVICE_ID, defs);
        vm.stopPrank();

        // Submit heartbeat with a metric that doesn't match the required definition
        IOperatorStatusRegistry.MetricPair[] memory pairs = new IOperatorStatusRegistry.MetricPair[](1);
        pairs[0] = IOperatorStatusRegistry.MetricPair("other_metric", 50);
        bytes memory metricsData = abi.encode(pairs);

        vm.recordLogs();
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, metricsData);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // Check for MetricViolation event
        bytes32 violationSig = keccak256("MetricViolation(uint64,address,string,string)");
        bool foundViolation = false;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == violationSig) {
                foundViolation = true;
                break;
            }
        }
        assertTrue(foundViolation, "Expected MetricViolation event for missing required metric");
    }

    function test_processMetrics_ValidatesOutOfBounds() public {
        vm.startPrank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        IOperatorStatusRegistry.MetricDefinition[] memory defs = new IOperatorStatusRegistry.MetricDefinition[](1);
        defs[0] = IOperatorStatusRegistry.MetricDefinition("response_time_ms", 0, 5000, false);
        registry.setMetricDefinitions(SERVICE_ID, defs);
        vm.stopPrank();

        // Submit heartbeat with out-of-bounds value
        IOperatorStatusRegistry.MetricPair[] memory pairs = new IOperatorStatusRegistry.MetricPair[](1);
        pairs[0] = IOperatorStatusRegistry.MetricPair("response_time_ms", 9999);
        bytes memory metricsData = abi.encode(pairs);

        vm.recordLogs();
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, metricsData);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 violationSig = keccak256("MetricViolation(uint64,address,string,string)");
        bool foundViolation = false;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == violationSig) {
                foundViolation = true;
                break;
            }
        }
        assertTrue(foundViolation, "Expected MetricViolation event for out-of-bounds value");
    }

    function test_processMetrics_PassesValidation() public {
        vm.startPrank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        IOperatorStatusRegistry.MetricDefinition[] memory defs = new IOperatorStatusRegistry.MetricDefinition[](2);
        defs[0] = IOperatorStatusRegistry.MetricDefinition("response_time_ms", 0, 5000, true);
        defs[1] = IOperatorStatusRegistry.MetricDefinition("uptime_percent", 0, 100, false);
        registry.setMetricDefinitions(SERVICE_ID, defs);
        vm.stopPrank();

        // Submit heartbeat with valid metrics
        IOperatorStatusRegistry.MetricPair[] memory pairs = new IOperatorStatusRegistry.MetricPair[](2);
        pairs[0] = IOperatorStatusRegistry.MetricPair("response_time_ms", 150);
        pairs[1] = IOperatorStatusRegistry.MetricPair("uptime_percent", 99);
        bytes memory metricsData = abi.encode(pairs);

        vm.recordLogs();
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, metricsData);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 violationSig = keccak256("MetricViolation(uint64,address,string,string)");
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == violationSig) {
                revert("Unexpected MetricViolation event for valid metrics");
            }
        }

        // Values should be stored
        assertEq(registry.getMetricValue(SERVICE_ID, operatorAddr, "response_time_ms"), 150);
        assertEq(registry.getMetricValue(SERVICE_ID, operatorAddr, "uptime_percent"), 99);
    }

    function test_getSlashableOperators_ReturnsOffline() public {
        // Operator submits a heartbeat
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        // No one should be slashable yet
        address[] memory ops = registry.getSlashableOperators(SERVICE_ID);
        assertEq(ops.length, 0);

        // Warp past the threshold (interval=120, maxMissed=2 => 240s)
        vm.warp(block.timestamp + 241);

        ops = registry.getSlashableOperators(SERVICE_ID);
        assertEq(ops.length, 1);
        assertEq(ops[0], operatorAddr);
    }

    function test_abiEncodingCompatibility() public {
        vm.prank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        // ABI-encode MetricPair[] in Solidity
        IOperatorStatusRegistry.MetricPair[] memory pairs = new IOperatorStatusRegistry.MetricPair[](2);
        pairs[0] = IOperatorStatusRegistry.MetricPair("response_time_ms", 150);
        pairs[1] = IOperatorStatusRegistry.MetricPair("uptime_percent", 99);
        bytes memory metricsData = abi.encode(pairs);

        // Submit via heartbeat and verify storage
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, metricsData);

        assertEq(registry.getMetricValue(SERVICE_ID, operatorAddr, "response_time_ms"), 150);
        assertEq(registry.getMetricValue(SERVICE_ID, operatorAddr, "uptime_percent"), 99);
    }

    function test_crossRepoAbiEncoding() public {
        vm.prank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        // Hex produced by Rust alloy-sol-types encoder for:
        //   [("response_time_ms", 150), ("uptime_percent", 99)]
        bytes memory rustEncoded = hex"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000960000000000000000000000000000000000000000000000000000000000000010726573706f6e73655f74696d655f6d730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000063000000000000000000000000000000000000000000000000000000000000000e757074696d655f70657263656e74000000000000000000000000000000000000";

        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, rustEncoded);

        assertEq(registry.getMetricValue(SERVICE_ID, operatorAddr, "response_time_ms"), 150);
        assertEq(registry.getMetricValue(SERVICE_ID, operatorAddr, "uptime_percent"), 99);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Audit remediation tests
    // ═══════════════════════════════════════════════════════════════════════════

    function test_addMetricDefinition_InvalidBoundsReverts() public {
        vm.prank(serviceOwner);
        vm.expectRevert("Invalid bounds");
        registry.addMetricDefinition(SERVICE_ID, "bad_metric", 100, 0, true);
    }

    function test_addMetricDefinition_CapsAtMax() public {
        vm.startPrank(serviceOwner);
        // Fill to max
        for (uint256 i = 0; i < 50; i++) {
            registry.addMetricDefinition(SERVICE_ID, string(abi.encodePacked("m", i)), 0, 100, false);
        }
        // 51st should fail
        vm.expectRevert("Too many definitions");
        registry.addMetricDefinition(SERVICE_ID, "overflow", 0, 100, false);
        vm.stopPrank();
    }

    function test_setMetricDefinitions_CapsAtMax() public {
        IOperatorStatusRegistry.MetricDefinition[] memory defs = new IOperatorStatusRegistry.MetricDefinition[](51);
        for (uint256 i = 0; i < 51; i++) {
            defs[i] = IOperatorStatusRegistry.MetricDefinition("x", 0, 100, false);
        }
        vm.prank(serviceOwner);
        vm.expectRevert("Too many definitions");
        registry.setMetricDefinitions(SERVICE_ID, defs);
    }

    function test_outOfBoundsMetrics_NotStored() public {
        vm.startPrank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);
        IOperatorStatusRegistry.MetricDefinition[] memory defs = new IOperatorStatusRegistry.MetricDefinition[](1);
        defs[0] = IOperatorStatusRegistry.MetricDefinition("bounded", 10, 100, false);
        registry.setMetricDefinitions(SERVICE_ID, defs);
        vm.stopPrank();

        // Submit out-of-bounds metric
        IOperatorStatusRegistry.MetricPair[] memory pairs = new IOperatorStatusRegistry.MetricPair[](1);
        pairs[0] = IOperatorStatusRegistry.MetricPair("bounded", 999);
        bytes memory metricsData = abi.encode(pairs);

        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, metricsData);

        // Value should NOT be stored since it's out of bounds
        assertEq(registry.getMetricValue(SERVICE_ID, operatorAddr, "bounded"), 0);
    }

    function test_goOnline_NoOpWhenAlreadyHealthy() public {
        vm.startPrank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        IOperatorStatusRegistry.StatusCode status = registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Healthy));

        // goOnline should be a no-op when already Healthy
        registry.goOnline(SERVICE_ID);
        status = registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Healthy));
        vm.stopPrank();
    }

    function test_reportForSlashing_UnregisteredOperatorReverts() public {
        vm.prank(governance);
        registry.setSlashingOracle(slashingOracle);

        vm.prank(slashingOracle);
        vm.expectRevert("Not registered operator");
        registry.reportForSlashing(SERVICE_ID, makeAddr("unknown"), "slash");
    }

    function test_getSlashableOperatorsPaginated() public {
        // Create and register 5 operators
        address[] memory ops = new address[](5);
        for (uint256 i = 0; i < 5; i++) {
            ops[i] = makeAddr(string(abi.encodePacked("op", i)));
            _registerOp(ops[i]);
            vm.prank(ops[i]);
            registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
        }

        // Warp past threshold
        vm.warp(block.timestamp + 241);

        // Get page 1 (first 3)
        (address[] memory page1, uint256 total) = registry.getSlashableOperatorsPaginated(SERVICE_ID, 0, 3);
        assertEq(total, 5);
        assertEq(page1.length, 3);

        // Get page 2 (remaining 2)
        (address[] memory page2,) = registry.getSlashableOperatorsPaginated(SERVICE_ID, 3, 3);
        assertEq(page2.length, 2);
    }

    function test_removeInactiveOperator() public {
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        // Can't remove active operator
        vm.prank(serviceOwner);
        vm.expectRevert("Operator not eligible for removal");
        registry.removeInactiveOperator(SERVICE_ID, operatorAddr);

        // Warp past 10x threshold (interval=120, maxMissed=2, 10x = 2400s)
        vm.warp(block.timestamp + 2401);

        // Now removal should work
        uint256 countBefore = registry.getAllOperatorCount(SERVICE_ID);
        vm.prank(serviceOwner);
        registry.removeInactiveOperator(SERVICE_ID, operatorAddr);
        uint256 countAfter = registry.getAllOperatorCount(SERVICE_ID);
        assertEq(countAfter, countBefore - 1);
    }

    function test_removeInactiveOperator_SlashedAlwaysRemovable() public {
        vm.prank(governance);
        registry.setSlashingOracle(slashingOracle);

        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        vm.prank(slashingOracle);
        registry.reportForSlashing(SERVICE_ID, operatorAddr, "slash");

        // Slashed operators can be removed immediately
        vm.prank(serviceOwner);
        registry.removeInactiveOperator(SERVICE_ID, operatorAddr);
        assertEq(registry.getAllOperatorCount(SERVICE_ID), 0);
    }

    function test_slashedOperator_CannotHeartbeat() public {
        vm.prank(governance);
        registry.setSlashingOracle(slashingOracle);

        // Operator submits heartbeat and becomes Healthy
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
        assertEq(
            uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
            uint8(IOperatorStatusRegistry.StatusCode.Healthy)
        );

        // Slash the operator
        vm.prank(slashingOracle);
        registry.reportForSlashing(SERVICE_ID, operatorAddr, "violation");
        assertEq(
            uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
            uint8(IOperatorStatusRegistry.StatusCode.Slashed)
        );

        // Slashed operator cannot submit heartbeat
        vm.prank(operatorAddr);
        vm.expectRevert("Operator is slashed");
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Operator registration auth tests
    // ═══════════════════════════════════════════════════════════════════════════

    function test_unregisteredOperator_CannotHeartbeat() public {
        address rando = makeAddr("rando");
        vm.prank(rando);
        vm.expectRevert("Not registered operator");
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
    }

    function test_unregisteredOperator_CannotGoOnline() public {
        address rando = makeAddr("rando");
        vm.prank(rando);
        vm.expectRevert("Not registered operator");
        registry.goOnline(SERVICE_ID);
    }

    function test_unregisteredOperator_CannotGoOffline() public {
        address rando = makeAddr("rando");
        vm.prank(rando);
        vm.expectRevert("Not registered operator");
        registry.goOffline(SERVICE_ID);
    }

    function test_registerOperator_OnlyTangleCore() public {
        address rando = makeAddr("rando");
        address newOp = makeAddr("newOp");

        // Random address cannot register
        vm.prank(rando);
        vm.expectRevert("Only Tangle core");
        registry.registerOperator(SERVICE_ID, newOp);

        // Service owner cannot register either — operator set comes from service lifecycle
        vm.prank(serviceOwner);
        vm.expectRevert("Only Tangle core");
        registry.registerOperator(SERVICE_ID, newOp);

        // Only Tangle core can register
        vm.prank(tangle);
        registry.registerOperator(SERVICE_ID, newOp);
        assertTrue(registry.isRegisteredOperator(SERVICE_ID, newOp));
    }

    function test_registerOperator_DuplicateReverts() public {
        vm.prank(tangle);
        vm.expectRevert("Already registered");
        registry.registerOperator(SERVICE_ID, operatorAddr); // already registered in setUp
    }

    function test_deregisterOperator_RemovesAccess() public {
        vm.prank(tangle);
        registry.deregisterOperator(SERVICE_ID, operatorAddr);
        assertFalse(registry.isRegisteredOperator(SERVICE_ID, operatorAddr));

        // Deregistered operator cannot heartbeat
        vm.prank(operatorAddr);
        vm.expectRevert("Not registered operator");
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
    }

    function test_deregisterOperator_OnlyTangleCore() public {
        vm.prank(serviceOwner);
        vm.expectRevert("Only Tangle core");
        registry.deregisterOperator(SERVICE_ID, operatorAddr);
    }

    function test_deregisterOperator_NotRegisteredReverts() public {
        vm.prank(tangle);
        vm.expectRevert("Not registered");
        registry.deregisterOperator(SERVICE_ID, makeAddr("never_registered"));
    }

    function test_exitingOperator_StillSlashable() public {
        // Operator heartbeats, then goes offline
        vm.startPrank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");
        registry.goOffline(SERVICE_ID);
        vm.stopPrank();

        assertEq(
            uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
            uint8(IOperatorStatusRegistry.StatusCode.Exiting)
        );

        // Warp past threshold — Exiting operators should still appear in slashable set
        vm.warp(block.timestamp + 241);
        address[] memory ops = registry.getSlashableOperators(SERVICE_ID);
        assertEq(ops.length, 1);
        assertEq(ops[0], operatorAddr);
    }

    function test_statusCodeIncludedInSignature() public {
        // Sign with statusCode=0, submit with statusCode=1 => should fail
        bytes memory signature = _signHeartbeat(0, "");
        vm.prank(operatorAddr);
        vm.expectRevert("Invalid signature");
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 1, "", signature);

        // Sign with correct statusCode=1, submit with statusCode=1 => should pass
        bytes memory correctSig = _signHeartbeat(1, "");
        vm.prank(operatorAddr);
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 1, "", correctSig);

        assertEq(
            uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)),
            uint8(IOperatorStatusRegistry.StatusCode.Degraded)
        );
    }

    function test_configureHeartbeat_PhantomServiceReverts() public {
        // Service 999 has no registered owner; should fail for random callers
        vm.expectRevert("Not authorized");
        registry.configureHeartbeat(999, 300, 3);
    }

    function testFuzz_checkOperatorStatusHandlesMissedBeats(uint64 warpSeconds) public {
        vm.prank(operatorAddr);
        registry.submitHeartbeatDirect(SERVICE_ID, BLUEPRINT_ID, 0, "");

        (uint64 interval, uint8 maxMissed, ) = registry.heartbeatConfigs(SERVICE_ID);
        uint64 lowerBound = interval > 1 ? interval / 2 : 1;
        uint64 upperBound = interval * (uint64(maxMissed) + 5);
        warpSeconds = uint64(bound(warpSeconds, lowerBound, upperBound));

        vm.warp(block.timestamp + warpSeconds);
        registry.checkOperatorStatus(SERVICE_ID, operatorAddr);

        bool shouldBeOffline = warpSeconds / interval >= maxMissed;
        IOperatorStatusRegistry.StatusCode expected =
            shouldBeOffline ? IOperatorStatusRegistry.StatusCode.Offline : IOperatorStatusRegistry.StatusCode.Healthy;
        assertEq(uint8(registry.getOperatorStatus(SERVICE_ID, operatorAddr)), uint8(expected));
    }
}
