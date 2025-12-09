// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseTest} from "../BaseTest.sol";
import {BlueprintServiceManagerBase} from "../../../src/v2/BlueprintServiceManagerBase.sol";
import {IOperatorStatusRegistry} from "../../../src/v2/restaking/OperatorStatusRegistry.sol";

contract MockStatusRegistry is IOperatorStatusRegistry {
    bool public registerCalled;
    bool public configureCalled;
    uint64 public lastServiceId;
    address public lastOwner;
    uint64 public configuredInterval;
    uint8 public configuredMaxMissed;

    function submitHeartbeat(
        uint64,
        uint64,
        uint8,
        bytes calldata,
        bytes calldata
    ) external override {}

    function isOnline(uint64, address) external pure override returns (bool) {
        return false;
    }

    function getOperatorStatus(uint64, address) external pure override returns (IOperatorStatusRegistry.StatusCode) {
        return IOperatorStatusRegistry.StatusCode.Healthy;
    }

    function getLastHeartbeat(uint64, address) external pure override returns (uint256) {
        return 0;
    }

    function registerServiceOwner(uint64 serviceId, address owner) external override {
        registerCalled = true;
        lastServiceId = serviceId;
        lastOwner = owner;
    }

    function configureHeartbeat(uint64 serviceId, uint64 interval, uint8 maxMissed) external override {
        configureCalled = true;
        lastServiceId = serviceId;
        configuredInterval = interval;
        configuredMaxMissed = maxMissed;
    }
}

contract HeartbeatBSM is BlueprintServiceManagerBase {
    uint64 public constant CUSTOM_INTERVAL = 900;
    uint8 public constant CUSTOM_THRESHOLD = 90;

    function onBlueprintCreated(uint64 _blueprintId, address owner, address core) external override {
        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = core;
    }

    function getHeartbeatInterval(uint64) external pure override returns (bool useDefault, uint64 interval) {
        return (false, CUSTOM_INTERVAL);
    }

    function getHeartbeatThreshold(uint64) external pure override returns (bool useDefault, uint8 threshold) {
        return (false, CUSTOM_THRESHOLD);
    }
}

contract HeartbeatConfigTest is BaseTest {
    MockStatusRegistry internal registry;
    HeartbeatBSM internal manager;

    function setUp() public override {
        super.setUp();
        registry = new MockStatusRegistry();
        manager = new HeartbeatBSM();
        _registerOperator(operator1);
        vm.prank(admin);
        tangle.setOperatorStatusRegistry(address(registry));
    }

    function test_ConfigureHeartbeat_UsesManagerOverrides() public {
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://heartbeat", address(manager));
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;

        assertTrue(registry.registerCalled(), "service owner registered");
        assertEq(registry.lastOwner(), user1);
        assertTrue(registry.configureCalled(), "heartbeat configured");
        assertEq(registry.lastServiceId(), serviceId);
        assertEq(registry.configuredInterval(), manager.CUSTOM_INTERVAL());
        assertEq(registry.configuredMaxMissed(), 1); // threshold 90% => maxMissed = 1
    }
}
