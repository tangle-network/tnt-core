// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, Vm} from "forge-std/Test.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {OperatorStatusRegistry, IOperatorStatusRegistry} from "../../../src/v2/restaking/OperatorStatusRegistry.sol";
import {IMetricsRecorder} from "../../../src/v2/interfaces/IMetricsRecorder.sol";

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
    address internal serviceOwner = makeAddr("serviceOwner");
    address internal slashingOracle = makeAddr("oracle");

    uint64 internal constant SERVICE_ID = 1;
    uint64 internal constant BLUEPRINT_ID = 77;

    uint256 internal operatorKey = uint256(keccak256("operator"));
    address internal operatorAddr;

    function setUp() public {
        registry = new OperatorStatusRegistry(tangle);
        metrics = new MockMetricsRecorder();
        operatorAddr = vm.addr(operatorKey);

        vm.prank(tangle);
        registry.registerServiceOwner(SERVICE_ID, serviceOwner);

        vm.prank(serviceOwner);
        registry.configureHeartbeat(SERVICE_ID, 120, 2);
    }

    function _signHeartbeat(bytes memory metricsData) internal view returns (bytes memory) {
        bytes32 messageHash = keccak256(abi.encodePacked(SERVICE_ID, BLUEPRINT_ID, metricsData));
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operatorKey, ethSignedHash);
        return abi.encodePacked(r, s, v);
    }

    function test_submitHeartbeat_WithSignatureUpdatesState() public {
        bytes memory metricsData = abi.encode("status", uint256(1));
        bytes memory signature = _signHeartbeat(metricsData);

        vm.prank(operatorAddr);
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 0, metricsData, signature);

        IOperatorStatusRegistry.StatusCode status =
            registry.getOperatorStatus(SERVICE_ID, operatorAddr);
        assertEq(uint8(status), uint8(IOperatorStatusRegistry.StatusCode.Healthy));
        assertEq(registry.getLastHeartbeat(SERVICE_ID, operatorAddr), block.timestamp);
        assertTrue(registry.isHeartbeatCurrent(SERVICE_ID, operatorAddr));
    }

    function test_submitHeartbeat_InvalidSignatureReverts() public {
        bytes memory signature = abi.encodePacked(bytes32(0), bytes32(0), uint8(27));
        vm.prank(operatorAddr);
        vm.expectRevert(ECDSA.ECDSAInvalidSignature.selector);
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 0, "", signature);
    }

    function test_customMetricsStoredWhenEnabled() public {
        vm.prank(serviceOwner);
        registry.enableCustomMetrics(SERVICE_ID, true);

        bytes memory metricsData = abi.encode("cpu", uint256(42));
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
        registry.setMetricsRecorder(address(metrics));

        bytes memory signature = _signHeartbeat("");
        vm.prank(operatorAddr);
        registry.submitHeartbeat(SERVICE_ID, BLUEPRINT_ID, 0, "", signature);

        assertEq(metrics.heartbeatCount(), 1);
        assertEq(metrics.lastOperator(), operatorAddr);
        assertEq(metrics.lastServiceId(), SERVICE_ID);
    }

    function test_setSlashingOracleAndReport() public {
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
