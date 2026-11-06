// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { BlueprintHookBase } from "../../src/interfaces/IBlueprintHook.sol";

contract BlueprintHookHarness is BlueprintHookBase { }

contract BlueprintHookBaseTest is Test {
    BlueprintHookHarness internal hook;

    function setUp() public {
        hook = new BlueprintHookHarness();
    }

    function test_DefaultLifecycleHooksAcceptOperations() public {
        bool acceptOperator = hook.onOperatorRegister(1, address(0xBEEF), "");
        assertTrue(acceptOperator, "operator registration should be accepted");

        address[] memory operators = new address[](1);
        operators[0] = address(0xCAFE);
        bool acceptRequest = hook.onServiceRequest(1, 1, address(0xFEE), operators, "");
        assertTrue(acceptRequest, "service request should be accepted");

        bool acceptJob = hook.onJobSubmitted(1, 2, 0, address(this), "");
        assertTrue(acceptJob, "job should be accepted");

        bool approveSlash = hook.onSlashProposed(1, operators[0], 1 ether, keccak256("evidence"));
        assertTrue(approveSlash, "slash should be approved");

        bool canJoin = hook.canJoin(3, operators[0], 500);
        bool canLeave = hook.canLeave(3, operators[0]);
        assertTrue(canJoin);
        assertTrue(canLeave);

        assertEq(hook.getDeveloperPaymentAddress(1), address(0));
        assertTrue(hook.isPaymentTokenAllowed(address(0xDEAD)));
        assertEq(hook.getRequiredResultCount(1, 0), 1);
        assertFalse(hook.requiresAggregation(1, 0));

        (uint16 thresholdBps, uint8 thresholdType) = hook.getAggregationThreshold(1, 0);
        assertEq(thresholdBps, 6700);
        assertEq(thresholdType, 0);
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// TOKENIZED BLUEPRINT BASE TESTS
// ═════════════════════════════════════════════════════════════════════════════
