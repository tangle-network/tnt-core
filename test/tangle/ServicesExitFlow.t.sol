// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";

contract CustomExitManager is BlueprintServiceManagerBase {
    uint64 public constant MIN_COMMITMENT = 0;
    uint64 public constant EXIT_QUEUE = 2 days;

    function getExitConfig(uint64)
        external
        pure
        override
        returns (bool useDefault, uint64 minCommitmentDuration, uint64 exitQueueDuration, bool forceExitAllowed)
    {
        return (false, MIN_COMMITMENT, EXIT_QUEUE, true);
    }
}

contract ServicesExitFlowTest is BaseTest {
    CustomExitManager internal exitManager;

    function setUp() public override {
        super.setUp();
        exitManager = new CustomExitManager();
    }

    function test_GetExitConfig_UsesManagerOverrides() public {
        uint64 serviceId = _deployDynamicService(address(exitManager));
        Types.ExitConfig memory config = tangle.getExitConfig(serviceId);
        assertEq(config.minCommitmentDuration, exitManager.MIN_COMMITMENT());
        assertEq(config.exitQueueDuration, exitManager.EXIT_QUEUE());
        assertTrue(config.forceExitAllowed);
    }

    function test_ScheduleAndExecuteExitFlow() public {
        uint64 serviceId = _deployDynamicService(address(exitManager));

        vm.prank(operator1);
        tangle.scheduleExit(serviceId);

        Types.ExitRequest memory request = tangle.getExitRequest(serviceId, operator1);
        assertTrue(request.pending);
        assertEq(request.serviceId, serviceId);

        Types.ExitStatus status = tangle.getExitStatus(serviceId, operator1);
        assertEq(uint8(status), uint8(Types.ExitStatus.Scheduled));

        vm.warp(request.executeAfter + 1);

        status = tangle.getExitStatus(serviceId, operator1);
        assertEq(uint8(status), uint8(Types.ExitStatus.Executable));

        vm.prank(operator1);
        tangle.executeExit(serviceId);

        status = tangle.getExitStatus(serviceId, operator1);
        assertEq(uint8(status), uint8(Types.ExitStatus.Completed));
        assertFalse(tangle.isServiceOperator(serviceId, operator1));
    }

    function test_CancelExit_ClearsState() public {
        uint64 serviceId = _deployDynamicService(address(exitManager));
        vm.prank(operator1);
        tangle.scheduleExit(serviceId);

        vm.prank(operator1);
        tangle.cancelExit(serviceId);

        Types.ExitRequest memory request = tangle.getExitRequest(serviceId, operator1);
        assertEq(request.pending, false);
        assertEq(uint8(tangle.getExitStatus(serviceId, operator1)), uint8(Types.ExitStatus.None));
    }

    function test_ForceExit_RemovesOperator() public {
        uint64 serviceId = _deployDynamicService(address(exitManager));

        vm.prank(user1);
        tangle.forceExit(serviceId, operator2);

        assertFalse(tangle.isServiceOperator(serviceId, operator2));
    }

    function test_LeaveService_RevertsWhenExitQueueRequired() public {
        uint64 serviceId = _deployDynamicService(address(exitManager));
        vm.startPrank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.ExitNotExecutable.selector,
                serviceId,
                operator1,
                uint64(block.timestamp) + exitManager.EXIT_QUEUE(),
                uint64(block.timestamp)
            )
        );
        tangle.leaveService(serviceId);
        vm.stopPrank();
    }

    function test_CanScheduleExit_ReflectsCommitmentWindow() public {
        uint64 serviceId = _deployDynamicService(address(0));
        (bool canExit, string memory reason) = tangle.canScheduleExit(serviceId, operator1);
        assertFalse(canExit);
        assertEq(reason, "Minimum commitment not met");

        vm.warp(block.timestamp + 2 days);
        (canExit, reason) = tangle.canScheduleExit(serviceId, operator1);
        assertTrue(canExit);
        assertEq(bytes(reason).length, 0);
    }

    function test_AddAndRemovePermittedCaller() public {
        uint64 serviceId = _deployDynamicService(address(exitManager));
        vm.prank(user1);
        tangle.addPermittedCaller(serviceId, user2);
        assertTrue(tangle.isPermittedCaller(serviceId, user2));

        vm.prank(user1);
        tangle.removePermittedCaller(serviceId, user2);
        assertFalse(tangle.isPermittedCaller(serviceId, user2));
    }

    function _deployDynamicService(address manager) internal returns (uint64 serviceId) {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic-exit", manager, config));

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceOperator(serviceId, operator1), "operator1 inactive");
        assertTrue(tangle.isServiceOperator(serviceId, operator2), "operator2 inactive");
    }
}
