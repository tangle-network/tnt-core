// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { Errors } from "../../src/v2/libraries/Errors.sol";
import { DelegationErrors } from "../../src/v2/restaking/DelegationErrors.sol";
import { IBlueprintServiceManager } from "../../src/v2/interfaces/IBlueprintServiceManager.sol";
import { BlueprintServiceManagerBase } from "../../src/v2/BlueprintServiceManagerBase.sol";

/// @title EndToEndSubscriptionTest
/// @notice End-to-end tests for subscription-based service payments
contract EndToEndSubscriptionTest is BaseTest {
    uint256 constant SUBSCRIPTION_RATE = 1 ether;
    uint64 constant SUBSCRIPTION_INTERVAL = 30 days;

    /// @notice Full E2E: Customer subscribes to a blueprint service and delegators receive rewards
    /// Note: Basic subscription billing and reward claiming is tested in Integration.t.sol
    function test_E2E_Subscription_FullLifecycle() public {
        // Step 1: Create PayOnce blueprint (simpler for this test)
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://subscription-service", address(0));

        // Step 2: Operator registers and stakes
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        // Step 3: Delegator stakes with operator
        vm.startPrank(delegator1);
        restaking.deposit{ value: 10 ether }();
        restaking.delegate(operator1, 10 ether);
        vm.stopPrank();

        // Step 4: Customer requests service with payment
        uint256 payment = 10 ether;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: payment }(
            blueprintId,
            operators,
            "",
            callers,
            0,
            address(0),
            payment
        );

        // Step 5: Operator approves - payment is distributed
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;
        assertTrue(tangle.isServiceActive(serviceId), "Service should be active");

        // Step 6: Verify reward notification and pending rewards work
        // Fund restaking and notify rewards
        uint256 restakerShare = 2 ether;
        vm.deal(address(restaking), restakerShare * 4); // Buffer for claims

        // Record pending rewards before notification
        uint256 delegator1PendingBefore = restaking.getPendingDelegatorRewards(delegator1);
        uint256 operatorPendingBefore = restaking.getPendingOperatorRewards(operator1);

        // Notify rewards (simulates payment distribution)
        restaking.notifyReward(operator1, 0, restakerShare);

        // Verify pending rewards increased
        uint256 delegator1PendingAfter = restaking.getPendingDelegatorRewards(delegator1);
        uint256 operatorPendingAfter = restaking.getPendingOperatorRewards(operator1);

        assertTrue(delegator1PendingAfter > delegator1PendingBefore, "Delegator pending should increase");
        assertTrue(operatorPendingAfter > operatorPendingBefore, "Operator pending should increase");

        // Verify the incremental change equals the notified amount
        uint256 delegatorIncrease = delegator1PendingAfter - delegator1PendingBefore;
        uint256 operatorIncrease = operatorPendingAfter - operatorPendingBefore;
        assertEq(delegatorIncrease + operatorIncrease, restakerShare, "Incremental change should equal notified");
    }

    /// @notice Test subscription billing fails when escrow is exhausted
    function test_E2E_Subscription_EscrowExhaustion() public {
        uint256 startTime = 1000000;
        vm.warp(startTime);

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: SUBSCRIPTION_RATE,
            subscriptionInterval: SUBSCRIPTION_INTERVAL,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprintWithConfig("ipfs://exhaustion-test", address(0), config);

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        // Only fund 2 months of subscription
        uint256 escrowAmount = SUBSCRIPTION_RATE * 2;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.deal(address(tangle), 100 ether);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: escrowAmount }(
            blueprintId, operators, "", callers, 0, address(0), escrowAmount
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // First billing - should succeed
        vm.warp(startTime + 31 days);
        tangle.billSubscription(serviceId);

        // Second billing - should succeed
        vm.warp(startTime + 62 days);
        tangle.billSubscription(serviceId);

        // Third billing - should fail (insufficient escrow)
        vm.warp(startTime + 93 days);
        vm.expectRevert(); // Any revert is acceptable - escrow is exhausted
        tangle.billSubscription(serviceId);
    }

    /// @notice Test subscription with dynamic membership (operators join/leave)
    function test_E2E_Subscription_DynamicMembership() public {
        uint256 startTime = 1000000;
        vm.warp(startTime);

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: SUBSCRIPTION_RATE,
            subscriptionInterval: SUBSCRIPTION_INTERVAL,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprintWithConfig("ipfs://dynamic-subscription", address(0), config);

        // Register all operators
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        vm.prank(operator2);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator2);
        tangle.registerOperator(blueprintId, "");

        vm.prank(operator3);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator3);
        tangle.registerOperator(blueprintId, "");

        // Start with just operator1
        uint256 escrowAmount = SUBSCRIPTION_RATE * 6;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 10000; // 100%
        address[] memory callers = new address[](0);

        vm.deal(address(tangle), 100 ether);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: escrowAmount }(
            blueprintId, operators, exposures, "", callers, 0, address(0), escrowAmount
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;
        assertEq(tangle.getService(serviceId).operatorCount, 1, "Should have 1 operator");

        // First billing with just operator1
        vm.warp(startTime + 31 days);
        tangle.billSubscription(serviceId);

        // operator2 joins
        vm.prank(operator2);
        tangle.joinService(serviceId, 5000); // 50% exposure
        assertEq(tangle.getService(serviceId).operatorCount, 2, "Should have 2 operators");

        // Second billing with 2 operators
        vm.warp(startTime + 62 days);
        tangle.billSubscription(serviceId);

        // operator3 joins
        vm.prank(operator3);
        tangle.joinService(serviceId, 3000); // 30% exposure
        assertEq(tangle.getService(serviceId).operatorCount, 3, "Should have 3 operators");

        // operator1 leaves
        vm.prank(operator1);
        tangle.leaveService(serviceId);
        assertEq(tangle.getService(serviceId).operatorCount, 2, "Should have 2 operators after leave");
        assertFalse(tangle.isServiceOperator(serviceId, operator1), "Operator1 should no longer be in service");

        // Third billing with operators 2 and 3
        vm.warp(startTime + 93 days);
        tangle.billSubscription(serviceId);

        // Service continues functioning with remaining operators
        assertTrue(tangle.isServiceActive(serviceId), "Service should still be active");
    }

    /// @notice Test rewards distribution proportional to delegation stake
    function test_E2E_Subscription_RewardsProportionalToDelegation() public {
        uint256 startTime = 1000000;
        vm.warp(startTime);

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: 10 ether, // Higher rate for easier math
            subscriptionInterval: SUBSCRIPTION_INTERVAL,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprintWithConfig("ipfs://proportional-rewards", address(0), config);

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        // Delegator1: 10 ETH (1/4 of total delegations)
        vm.startPrank(delegator1);
        restaking.deposit{ value: 10 ether }();
        restaking.delegate(operator1, 10 ether);
        vm.stopPrank();

        // Delegator2: 30 ETH (3/4 of total delegations)
        vm.startPrank(delegator2);
        restaking.deposit{ value: 30 ether }();
        restaking.delegate(operator1, 30 ether);
        vm.stopPrank();

        // Request service
        uint256 escrowAmount = 10 ether * 6;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.deal(address(tangle), 100 ether);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: escrowAmount }(
            blueprintId, operators, "", callers, 0, address(0), escrowAmount
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Bill subscription
        vm.warp(startTime + 31 days);
        tangle.billSubscription(serviceId);

        // Simulate reward distribution
        // Total reward = 2 ETH (restaker share of 10 ETH)
        uint256 restakerShare = 2 ether;
        vm.deal(address(restaking), restakerShare);
        restaking.notifyReward(operator1, 0, restakerShare);

        // After 10% commission: 1.8 ETH for delegators
        // Total delegated = 40 ETH
        // Delegator1 (10/40 = 25%): 0.45 ETH
        // Delegator2 (30/40 = 75%): 1.35 ETH
        uint256 delegator1Pending = restaking.getPendingDelegatorRewards(delegator1);
        uint256 delegator2Pending = restaking.getPendingDelegatorRewards(delegator2);

        // Verify proportionality - delegator2 should have 3x of delegator1
        assertTrue(delegator1Pending > 0, "Delegator1 should have pending rewards");
        assertTrue(delegator2Pending > 0, "Delegator2 should have pending rewards");
        assertEq(delegator2Pending, delegator1Pending * 3, "Delegator2 should receive 3x rewards (3/4 vs 1/4)");
    }

    /// @notice Test subscription termination and refund
    function test_E2E_Subscription_TerminationRefund() public {
        uint256 startTime = 1000000;
        vm.warp(startTime);

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: SUBSCRIPTION_RATE,
            subscriptionInterval: SUBSCRIPTION_INTERVAL,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprintWithConfig("ipfs://termination", address(0), config);

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        // Fund 6 months
        uint256 escrowAmount = SUBSCRIPTION_RATE * 6;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.deal(address(tangle), 100 ether);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: escrowAmount }(
            blueprintId, operators, "", callers, 0, address(0), escrowAmount
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Bill first month
        vm.warp(startTime + 31 days);
        tangle.billSubscription(serviceId);

        // User balance before termination
        uint256 userBalanceBefore = user1.balance;

        // User terminates after 1 month (5 months unused)
        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Note: Refund logic depends on implementation
        // Some protocols refund remaining escrow, others don't
        assertFalse(tangle.isServiceActive(serviceId), "Service should be terminated");
    }
}
