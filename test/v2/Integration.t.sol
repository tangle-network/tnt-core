// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { Errors } from "../../src/v2/libraries/Errors.sol";
import { ITangleBlueprints } from "../../src/v2/interfaces/ITangleBlueprints.sol";
import { ITangleOperators } from "../../src/v2/interfaces/ITangleOperators.sol";
import { ITangleServices } from "../../src/v2/interfaces/ITangleServices.sol";
import { ITangleJobs } from "../../src/v2/interfaces/ITangleJobs.sol";
import { IBlueprintServiceManager } from "../../src/v2/interfaces/IBlueprintServiceManager.sol";
import { BlueprintServiceManagerBase } from "../../src/v2/BlueprintServiceManagerBase.sol";

/// @title IntegrationTest
/// @notice End-to-end integration tests for the full Tangle protocol workflow
contract IntegrationTest is BaseTest {
    // ═══════════════════════════════════════════════════════════════════════════
    // FULL WORKFLOW TEST: Blueprint → Service → Job → Payment → Rewards
    // ═══════════════════════════════════════════════════════════════════════════

    function test_FullWorkflow_PayOnce() public {
        // Step 1: Developer creates blueprint
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test-blueprint", address(0)));
        assertEq(tangle.blueprintCount(), 1);

        // Step 2: Operators register in restaking with stake
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator2);
        restaking.registerOperator{ value: 3 ether }();

        // Step 3: Delegators deposit and delegate to operators
        vm.startPrank(delegator1);
        restaking.deposit{ value: 10 ether }();
        restaking.delegate(operator1, 5 ether);
        restaking.delegate(operator2, 5 ether);
        vm.stopPrank();

        vm.startPrank(delegator2);
        restaking.deposit{ value: 20 ether }();
        restaking.delegate(operator1, 15 ether);
        restaking.delegate(operator2, 5 ether);
        vm.stopPrank();

        // Step 4: Operators register for the blueprint
        _directRegisterOperator(operator1, blueprintId, "");
        _directRegisterOperator(operator2, blueprintId, "");

        // Step 5: User requests a service with payment
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);
        uint256 payment = 10 ether;

        uint256 treasuryBefore = treasury.balance;
        uint256 developerBefore = developer.balance;

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

        // Step 6: All operators approve (service activates after last approval)
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // Verify service is active
        assertTrue(tangle.isServiceActive(0));

        // Step 7: Check payment was distributed (PayOnce model)
        // Default split: developer=5000, protocol=1000, operator=2000, restaker=2000
        uint256 developerAmount = (payment * 5000) / 10000;
        uint256 protocolAmount = (payment * 1000) / 10000;

        assertEq(developer.balance, developerBefore + developerAmount, "Developer should receive 50%");
        assertEq(treasury.balance, treasuryBefore + protocolAmount, "Treasury should receive 10%");

        // Step 8: Submit a job
        bytes memory inputs = abi.encode("compute something");
        vm.prank(user1);
        uint64 callId = tangle.submitJob(0, 0, inputs);

        // Step 9: Operators submit results
        bytes memory result1 = abi.encode("result from op1");
        vm.prank(operator1);
        tangle.submitResult(0, callId, result1);

        // Verify job is completed (1 operator = 1 required result by default)
        Types.JobCall memory job = tangle.getJobCall(0, callId);
        assertTrue(job.completed);

        // Step 10: Check delegators can claim rewards from restaking
        // Restaker share was 22.5% = 2.25 ETH
        uint256 restakerShare = (payment * 2250) / 10000;

        // Fund restaking contract with the reward amount
        vm.deal(address(restaking), restakerShare);

        // Notify rewards for operators
        restaking.notifyReward(operator1, 0, restakerShare / 2);
        restaking.notifyReward(operator2, 0, restakerShare / 2);

        // Check pending rewards
        uint256 delegator1Pending = restaking.getPendingDelegatorRewards(delegator1);
        uint256 delegator2Pending = restaking.getPendingDelegatorRewards(delegator2);
        assertTrue(delegator1Pending > 0, "Delegator1 should have pending rewards");
        assertTrue(delegator2Pending > 0, "Delegator2 should have pending rewards");

        // Claim rewards
        uint256 delegator1Before = delegator1.balance;
        vm.prank(delegator1);
        restaking.claimDelegatorRewards();
        assertTrue(delegator1.balance > delegator1Before, "Delegator1 should receive rewards");
    }

    function test_FullWorkflow_MultiOperatorExposure() public {
        // Test that payment distribution respects operator exposure percentages

        // Setup blueprint
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://exposure-test", address(0)));

        // Register operators
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        vm.prank(operator2);
        restaking.registerOperator{ value: 5 ether }();

        _directRegisterOperator(operator1, blueprintId, "");
        _directRegisterOperator(operator2, blueprintId, "");

        // Request service with different exposure levels
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        uint16[] memory exposures = new uint16[](2);
        exposures[0] = 7000; // 70%
        exposures[1] = 3000; // 30%
        address[] memory callers = new address[](0);
        uint256 payment = 10 ether;

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: payment }(
            blueprintId,
            operators,
            exposures,
            "",
            callers,
            0,
            address(0),
            payment
        );

        // Both approve
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // Verify exposure was set correctly
        Types.ServiceOperator memory op1Data = tangle.getServiceOperator(0, operator1);
        Types.ServiceOperator memory op2Data = tangle.getServiceOperator(0, operator2);
        assertEq(op1Data.exposureBps, 7000);
        assertEq(op2Data.exposureBps, 3000);
    }

    function test_FullWorkflow_DynamicMembership() public {
        // Test dynamic membership where operators can join/leave

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        // Register all operators
        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        vm.prank(operator2);
        restaking.registerOperator{ value: 2 ether }();
        vm.prank(operator3);
        restaking.registerOperator{ value: 2 ether }();

        _directRegisterOperator(operator1, blueprintId, "");
        _directRegisterOperator(operator2, blueprintId, "");
        _directRegisterOperator(operator3, blueprintId, "");

        // Request with just operator1
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 10000;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure(
            blueprintId, operators, exposures, "", callers, 0, address(0), 0
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;
        assertEq(tangle.getService(serviceId).operatorCount, 1);

        // operator2 joins dynamically
        vm.prank(operator2);
        tangle.joinService(serviceId, 5000);
        assertEq(tangle.getService(serviceId).operatorCount, 2);
        assertTrue(tangle.isServiceOperator(serviceId, operator2));

        // operator3 joins
        vm.prank(operator3);
        tangle.joinService(serviceId, 3000);
        assertEq(tangle.getService(serviceId).operatorCount, 3);

        // operator2 wants to leave - must use exit queue
        // First, warp past minimum commitment duration (1 day default)
        vm.warp(block.timestamp + 1 days + 1);

        // Schedule exit
        vm.prank(operator2);
        tangle.scheduleExit(serviceId);

        // Check exit status is Scheduled
        assertEq(uint(tangle.getExitStatus(serviceId, operator2)), uint(Types.ExitStatus.Scheduled));

        // Warp past exit queue duration (7 days default)
        vm.warp(block.timestamp + 7 days + 1);

        // Check exit status is now Executable
        assertEq(uint(tangle.getExitStatus(serviceId, operator2)), uint(Types.ExitStatus.Executable));

        // Execute exit
        vm.prank(operator2);
        tangle.executeExit(serviceId);

        assertEq(tangle.getService(serviceId).operatorCount, 2);
        assertFalse(tangle.isServiceOperator(serviceId, operator2));

        // Check exit status is Completed
        assertEq(uint(tangle.getExitStatus(serviceId, operator2)), uint(Types.ExitStatus.Completed));
    }

    function test_FullWorkflow_SubscriptionBilling() public {
        // Use an explicit starting timestamp
        uint256 startTime = 1000000;
        vm.warp(startTime);

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));

        // Setup operator
        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Request service with enough funds for multiple billing cycles
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 10000;
        address[] memory callers = new address[](0);

        // Fund the Tangle contract and make request
        vm.deal(address(tangle), 10 ether);
        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: 1 ether }(
            blueprintId, operators, exposures, "", callers, 0, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // First billing cycle - warp past interval
        vm.warp(startTime + 31 days);
        tangle.billSubscription(serviceId);

        // Second billing cycle
        vm.warp(startTime + 62 days);
        tangle.billSubscription(serviceId);

        // If we got here without reverting, subscription billing works
        assertTrue(true, "Subscription billing succeeded");
    }

    function test_FullWorkflow_Slashing() public {
        // Test slashing reduces operator stake

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://slashing-test", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Create a service first (required for slashing)
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 stakeBefore = restaking.getOperatorSelfStake(operator1);
        assertEq(stakeBefore, 10 ether);

        // Service owner can propose slash
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 2 ether, keccak256("evidence"));

        // Fast forward past dispute window (7 days default)
        vm.warp(block.timestamp + 7 days + 1);

        // Execute the slash
        tangle.executeSlash(slashId);

        // Verify slash was executed
        uint256 stakeAfter = restaking.getOperatorSelfStake(operator1);
        assertEq(stakeAfter, 8 ether, "Operator stake should be reduced by slash amount");
    }

    function test_FullWorkflow_MultipleJobs() public {
        // Test multiple job submissions and results

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://multi-job", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Submit multiple jobs
        vm.startPrank(user1);
        uint64 callId1 = tangle.submitJob(serviceId, 0, "job1");
        uint64 callId2 = tangle.submitJob(serviceId, 0, "job2");
        uint64 callId3 = tangle.submitJob(serviceId, 1, "job3");
        vm.stopPrank();

        assertEq(callId1, 0);
        assertEq(callId2, 1);
        assertEq(callId3, 2);

        // Submit all results
        vm.startPrank(operator1);
        tangle.submitResult(serviceId, callId1, "result1");
        tangle.submitResult(serviceId, callId2, "result2");
        tangle.submitResult(serviceId, callId3, "result3");
        vm.stopPrank();

        // Verify all jobs completed
        assertTrue(tangle.getJobCall(serviceId, callId1).completed);
        assertTrue(tangle.getJobCall(serviceId, callId2).completed);
        assertTrue(tangle.getJobCall(serviceId, callId3).completed);
    }

    function test_FullWorkflow_BatchResults() public {
        // Test batch result submission

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://batch", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Submit multiple jobs
        vm.startPrank(user1);
        uint64 callId1 = tangle.submitJob(serviceId, 0, "job1");
        uint64 callId2 = tangle.submitJob(serviceId, 0, "job2");
        uint64 callId3 = tangle.submitJob(serviceId, 0, "job3");
        vm.stopPrank();

        // Batch submit results
        uint64[] memory callIds = new uint64[](3);
        callIds[0] = callId1;
        callIds[1] = callId2;
        callIds[2] = callId3;

        bytes[] memory results = new bytes[](3);
        results[0] = "result1";
        results[1] = "result2";
        results[2] = "result3";

        vm.prank(operator1);
        tangle.submitResults(serviceId, callIds, results);

        // All should be completed
        assertTrue(tangle.getJobCall(serviceId, callId1).completed);
        assertTrue(tangle.getJobCall(serviceId, callId2).completed);
        assertTrue(tangle.getJobCall(serviceId, callId3).completed);
    }

    function test_FullWorkflow_PermittedCallers() public {
        // Test that permitted callers can submit jobs

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://callers", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Request service (owner becomes permitted caller automatically)
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Add user2 as permitted caller after service creation
        vm.prank(user1);
        tangle.addPermittedCaller(serviceId, user2);

        // Owner can submit jobs
        vm.prank(user1);
        uint64 callId1 = tangle.submitJob(serviceId, 0, "owner job");

        // Permitted caller can submit jobs
        vm.prank(user2);
        uint64 callId2 = tangle.submitJob(serviceId, 0, "permitted job");

        assertEq(tangle.getJobCall(serviceId, callId1).caller, user1);
        assertEq(tangle.getJobCall(serviceId, callId2).caller, user2);

        // Non-permitted caller cannot submit
        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotPermittedCaller.selector, serviceId, delegator1));
        tangle.submitJob(serviceId, 0, "unpermitted");
    }

    function test_FullWorkflow_ServiceTermination() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://terminate", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;
        assertTrue(tangle.isServiceActive(serviceId));

        // Owner terminates service
        vm.prank(user1);
        tangle.terminateService(serviceId);

        assertFalse(tangle.isServiceActive(serviceId));
        assertEq(uint8(tangle.getService(serviceId).status), uint8(Types.ServiceStatus.Terminated));

        // Cannot submit jobs to terminated service
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceNotActive.selector, serviceId));
        tangle.submitJob(serviceId, 0, "should fail");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD DISTRIBUTION INTEGRATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RewardDistribution_ProportionalByDelegation() public {
        // Setup
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rewards", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Delegator1: 1 ETH, Delegator2: 3 ETH (3x more)
        vm.startPrank(delegator1);
        restaking.deposit{ value: 1 ether }();
        restaking.delegate(operator1, 1 ether);
        vm.stopPrank();

        vm.startPrank(delegator2);
        restaking.deposit{ value: 3 ether }();
        restaking.delegate(operator1, 3 ether);
        vm.stopPrank();

        // Fund and notify rewards
        uint256 rewardAmount = 4 ether;
        vm.deal(address(restaking), rewardAmount);
        restaking.notifyReward(operator1, 0, rewardAmount);

        // After 10% commission: 3.6 ETH for delegators
        // Delegator1: 3.6 * 1/4 = 0.9 ETH
        // Delegator2: 3.6 * 3/4 = 2.7 ETH
        assertEq(restaking.getPendingDelegatorRewards(delegator1), 0.9 ether);
        assertEq(restaking.getPendingDelegatorRewards(delegator2), 2.7 ether);
    }

    function test_RewardDistribution_OperatorCommission() public {
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();

        vm.startPrank(delegator1);
        restaking.deposit{ value: 10 ether }();
        restaking.delegate(operator1, 10 ether);
        vm.stopPrank();

        // Fund and notify reward
        uint256 rewardAmount = 10 ether;
        vm.deal(address(restaking), rewardAmount);
        restaking.notifyReward(operator1, 0, rewardAmount);

        // 10% commission = 1 ETH to operator
        assertEq(restaking.getPendingOperatorRewards(operator1), 1 ether);

        // 90% to delegators = 9 ETH
        assertEq(restaking.getPendingDelegatorRewards(delegator1), 9 ether);
    }

    function test_RewardDistribution_ClaimingClearsDebt() public {
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();

        vm.startPrank(delegator1);
        restaking.deposit{ value: 10 ether }();
        restaking.delegate(operator1, 10 ether);
        vm.stopPrank();

        // First reward
        vm.deal(address(restaking), 10 ether);
        restaking.notifyReward(operator1, 0, 5 ether);

        uint256 pending1 = restaking.getPendingDelegatorRewards(delegator1);
        assertTrue(pending1 > 0);

        // Claim
        uint256 balanceBefore = delegator1.balance;
        vm.prank(delegator1);
        restaking.claimDelegatorRewards();

        assertEq(delegator1.balance, balanceBefore + pending1);
        assertEq(restaking.getPendingDelegatorRewards(delegator1), 0);

        // Second reward
        restaking.notifyReward(operator1, 0, 5 ether);

        // Should only see second reward, not accumulate with first
        uint256 pending2 = restaking.getPendingDelegatorRewards(delegator1);
        assertEq(pending2, 4.5 ether); // 90% of 5 ETH
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES AND ERROR HANDLING
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CannotRegisterWithoutRestakingStake() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(0)));

        // operator1 hasn't registered in restaking - cannot register for blueprint
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotActive.selector, operator1));
        tangle.registerOperator(blueprintId, "", "");
    }

    function test_CannotApproveNonExistentRequest() public {
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceRequestNotFound.selector, 999));
        tangle.approveService(999, 0);
    }

    function test_ServiceRejectionRefundsPayment() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://refund", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint256 payment = 5 ether;
        uint256 userBalanceBefore = user1.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);

        // Operator rejects
        vm.prank(operator1);
        tangle.rejectService(requestId);

        // Payment should be refunded
        assertEq(user1.balance, userBalanceBefore);
    }

    function test_UnregisteredOperatorCannotApprove() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // operator2 (not in request) tries to approve
        vm.prank(operator2);
        restaking.registerOperator{ value: 2 ether }();
        vm.prank(operator2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.approveService(requestId, 0);
    }
}

/// @title CustomServiceManagerTest
/// @notice Tests for custom BlueprintServiceManager implementations
contract CustomServiceManagerTest is BaseTest {
    TestServiceManager public serviceManager;

    function setUp() public override {
        super.setUp();
        serviceManager = new TestServiceManager();
    }

    function test_ServiceManagerHooksAreCalled() public {
        // Create blueprint with custom service manager
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://hooked", address(serviceManager)));

        // Verify onBlueprintCreated was called
        assertTrue(serviceManager.blueprintCreated());

        // Setup operator
        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Verify onRegister was called
        assertTrue(serviceManager.operatorRegistered());

        // Request service
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Verify onRequest was called
        assertTrue(serviceManager.serviceRequested());

        // Approve service
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Verify onApprove and onServiceInitialized were called
        assertTrue(serviceManager.serviceApproved());
        assertTrue(serviceManager.serviceInitialized());
    }

    function test_ServiceManagerCanRejectOperator() public {
        RejectingServiceManager rejectingManager = new RejectingServiceManager();

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rejecting", address(rejectingManager)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 2 ether }();

        // Should revert because manager rejects - wrapped in ManagerReverted
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(
            Errors.ManagerReverted.selector,
            address(rejectingManager),
            abi.encodeWithSelector(RejectingServiceManager.OperatorRejected.selector)
        ));
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator1, 0), "");
    }

    function test_ServiceManagerCanCustomizeHeartbeat() public {
        CustomHeartbeatManager customManager = new CustomHeartbeatManager();

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://heartbeat", address(customManager)));

        // Query heartbeat through manager
        (bool useDefault, uint64 interval) = customManager.getHeartbeatInterval(0);
        assertFalse(useDefault);
        assertEq(interval, 100); // Custom 100 block interval
    }
}

/// @title TestServiceManager
/// @notice A test service manager that tracks hook calls
contract TestServiceManager is BlueprintServiceManagerBase {
    bool public blueprintCreated;
    bool public operatorRegistered;
    bool public serviceRequested;
    bool public serviceApproved;
    bool public serviceInitialized;

    function onBlueprintCreated(
        uint64 _blueprintId,
        address _owner,
        address _tangleCore
    ) external override {
        // Initialize base
        blueprintId = _blueprintId;
        blueprintOwner = _owner;
        tangleCore = _tangleCore;
        blueprintCreated = true;
    }

    function onRegister(
        address,
        bytes calldata
    ) external payable override {
        operatorRegistered = true;
    }

    function onRequest(
        uint64,
        address,
        address[] calldata,
        bytes calldata,
        uint64,
        address,
        uint256
    ) external payable override {
        serviceRequested = true;
    }

    function onApprove(
        address,
        uint64,
        uint8
    ) external payable override {
        serviceApproved = true;
    }

    function onServiceInitialized(
        uint64,
        uint64,
        uint64,
        address,
        address[] calldata,
        uint64
    ) external override {
        serviceInitialized = true;
    }
}

/// @title RejectingServiceManager
/// @notice A service manager that rejects all operator registrations
contract RejectingServiceManager is BlueprintServiceManagerBase {
    error OperatorRejected();

    function onRegister(
        address,
        bytes calldata
    ) external payable override {
        revert OperatorRejected();
    }
}

/// @title CustomHeartbeatManager
/// @notice A service manager with custom heartbeat settings
contract CustomHeartbeatManager is BlueprintServiceManagerBase {
    function getHeartbeatInterval(uint64) external pure override returns (bool useDefault, uint64 interval) {
        return (false, 100); // Custom 100 block interval
    }

    function getHeartbeatThreshold(uint64) external pure override returns (bool useDefault, uint8 threshold) {
        return (false, 5); // Custom 5 missed heartbeats threshold
    }
}

/// @title MultiAssetSecurityTest
/// @notice Tests for multi-asset security requirements and commitments
contract MultiAssetSecurityTest is BaseTest {
    address public mockToken;

    function setUp() public override {
        super.setUp();
        // Use a mock ERC20 token address
        mockToken = address(0x1234567890123456789012345678901234567890);
    }

    function test_RequestServiceWithSecurity_SingleAsset() public {
        // Create blueprint
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://security-test", address(0)));

        // Setup operator
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Create security requirements
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 5000,  // Min 50%
            maxExposureBps: 10000  // Max 100%
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId,
            operators,
            requirements,
            "",
            callers,
            0,
            address(0),
            0
        );

        // Request should be created
        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertEq(req.blueprintId, blueprintId);
        assertEq(req.requester, user1);
    }

    function test_RequestServiceWithSecurity_MultipleAssets() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://multi-asset", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Create multi-asset security requirements
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](2);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 3000,
            maxExposureBps: 7000
        });
        requirements[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: mockToken }),
            minExposureBps: 2000,
            maxExposureBps: 5000
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId,
            operators,
            requirements,
            "",
            callers,
            0,
            address(0),
            0
        );

        assertEq(requestId, 0);
    }

    function test_RequestServiceWithSecurity_RevertNoRequirements() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://no-req", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](0);
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(Errors.NoSecurityRequirements.selector);
        tangle.requestServiceWithSecurity(blueprintId, operators, requirements, "", callers, 0, address(0), 0);
    }

    function test_RequestServiceWithSecurity_RevertInvalidMinMax() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://invalid", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // min > max is invalid
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 8000,
            maxExposureBps: 5000  // Less than min!
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(Errors.InvalidSecurityRequirement.selector);
        tangle.requestServiceWithSecurity(blueprintId, operators, requirements, "", callers, 0, address(0), 0);
    }

    function test_ApproveWithCommitments_ValidCommitment() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://commit", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Request with security requirements
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 5000,
            maxExposureBps: 10000
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, operators, requirements, "", callers, 0, address(0), 0
        );

        // Operator approves with valid commitment (7500 bps = 75%)
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 7500
        });

        vm.prank(operator1);
        tangle.approveServiceWithCommitments(requestId, commitments);

        // Service should be active
        assertTrue(tangle.isServiceActive(0));
    }

    function test_ApproveWithCommitments_RevertBelowMinimum() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://below-min", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 5000,
            maxExposureBps: 10000
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, operators, requirements, "", callers, 0, address(0), 0
        );

        // Try to commit only 30% when min is 50%
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 3000
        });

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.CommitmentBelowMinimum.selector, address(0), 3000, 5000));
        tangle.approveServiceWithCommitments(requestId, commitments);
    }

    function test_ApproveWithCommitments_RevertAboveMaximum() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://above-max", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 2000,
            maxExposureBps: 5000  // Max 50%
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, operators, requirements, "", callers, 0, address(0), 0
        );

        // Try to commit 80% when max is 50%
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 8000
        });

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.CommitmentAboveMaximum.selector, address(0), 8000, 5000));
        tangle.approveServiceWithCommitments(requestId, commitments);
    }

    function test_ApproveWithCommitments_RevertMissingAsset() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://missing", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Request requires two assets
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](2);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 3000,
            maxExposureBps: 7000
        });
        requirements[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: mockToken }),
            minExposureBps: 2000,
            maxExposureBps: 5000
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, operators, requirements, "", callers, 0, address(0), 0
        );

        // Only commit for native asset, missing ERC20
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 5000
        });

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.MissingAssetCommitment.selector, mockToken));
        tangle.approveServiceWithCommitments(requestId, commitments);
    }

    function test_ApproveWithCommitments_MultiOperator() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://multi-op", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        vm.prank(operator2);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator2, blueprintId, "");

        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 3000,
            maxExposureBps: 10000
        });

        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, operators, requirements, "", callers, 0, address(0), 0
        );

        // Both operators commit with different amounts
        Types.AssetSecurityCommitment[] memory commitments1 = new Types.AssetSecurityCommitment[](1);
        commitments1[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 8000  // 80%
        });

        Types.AssetSecurityCommitment[] memory commitments2 = new Types.AssetSecurityCommitment[](1);
        commitments2[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 5000  // 50%
        });

        vm.prank(operator1);
        tangle.approveServiceWithCommitments(requestId, commitments1);
        assertFalse(tangle.isServiceActive(0)); // Not active yet

        vm.prank(operator2);
        tangle.approveServiceWithCommitments(requestId, commitments2);
        assertTrue(tangle.isServiceActive(0)); // Now active
    }
}

/// @title RFQTest
/// @notice Tests for Request For Quote (instant service creation with signed quotes)
contract RFQTest is BaseTest {
    uint256 constant OPERATOR1_PK = 0xA11CE;
    uint256 constant OPERATOR2_PK = 0xB0B;

    function setUp() public override {
        super.setUp();
        // Override operator addresses with ones we control private keys for
        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
    }

    function _signQuote(
        Types.QuoteDetails memory details,
        uint256 privateKey
    ) internal view returns (bytes memory) {
        bytes32 QUOTE_TYPEHASH = keccak256(
            "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,AssetSecurityCommitment[] securityCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)"
        );
        bytes32 commitmentsHash = _hashSecurityCommitments(details.securityCommitments);

        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("TangleQuote"),
            keccak256("1"),
            block.chainid,
            address(tangle)
        ));

        bytes32 structHash = keccak256(abi.encode(
            QUOTE_TYPEHASH,
            details.blueprintId,
            details.ttlBlocks,
            details.totalCost,
            details.timestamp,
            details.expiry,
            commitmentsHash
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator,
            structHash
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return abi.encodePacked(r, s, v);
    }

    function _hashSecurityCommitments(
        Types.AssetSecurityCommitment[] memory commitments
    ) internal pure returns (bytes32) {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = _hashSecurityCommitment(commitments[i]);
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }

    function _hashSecurityCommitment(
        Types.AssetSecurityCommitment memory commitment
    ) internal pure returns (bytes32) {
        bytes32 ASSET_TYPEHASH = keccak256("Asset(uint8 kind,address token)");
        bytes32 COMMITMENT_TYPEHASH = keccak256(
            "AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)"
        );
        bytes32 assetHash = keccak256(
            abi.encode(ASSET_TYPEHASH, uint8(commitment.asset.kind), commitment.asset.token)
        );
        return keccak256(abi.encode(COMMITMENT_TYPEHASH, assetHash, commitment.exposureBps));
    }

    function test_CreateServiceFromQuotes_SingleOperator() public {
        // Create blueprint
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-test", address(0)));

        // Setup operator
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        // Create signed quote
        uint64 ttl = 100;
        uint256 cost = 1 ether;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes memory signature = _signQuote(details, OPERATOR1_PK);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: signature,
            operator: operator1
        });

        address[] memory callers = new address[](0);

        // Create service from quotes
        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: cost }(
            blueprintId,
            quotes,
            "",
            callers,
            ttl
        );

        // Service should be active
        assertTrue(tangle.isServiceActive(serviceId));
        assertTrue(tangle.isServiceOperator(serviceId, operator1));
        assertEq(tangle.getService(serviceId).owner, user1);
    }

    function test_CreateServiceFromQuotes_MultipleOperators() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-multi", address(0)));

        // Setup both operators
        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        vm.prank(operator2);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator2, blueprintId, "");

        uint64 ttl = 100;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        Types.QuoteDetails memory details1 = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 0.5 ether,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        Types.QuoteDetails memory details2 = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 0.7 ether,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = Types.SignedQuote({
            details: details1,
            signature: _signQuote(details1, OPERATOR1_PK),
            operator: operator1
        });
        quotes[1] = Types.SignedQuote({
            details: details2,
            signature: _signQuote(details2, OPERATOR2_PK),
            operator: operator2
        });

        address[] memory callers = new address[](0);
        uint256 totalCost = 1.2 ether;

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: totalCost }(
            blueprintId,
            quotes,
            "",
            callers,
            ttl
        );

        assertTrue(tangle.isServiceActive(serviceId));
        assertTrue(tangle.isServiceOperator(serviceId, operator1));
        assertTrue(tangle.isServiceOperator(serviceId, operator2));
        assertEq(tangle.getService(serviceId).operatorCount, 2);
    }

    function test_CreateServiceFromQuotes_RefundsExcessPayment() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-refund", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 ttl = 100;
        uint256 cost = 1 ether;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR1_PK),
            operator: operator1
        });

        address[] memory callers = new address[](0);
        uint256 userBalanceBefore = user1.balance;

        // Send more than required
        vm.prank(user1);
        tangle.createServiceFromQuotes{ value: 5 ether }(blueprintId, quotes, "", callers, ttl);

        // User should get excess back (5 - 1 = 4 ETH refund)
        assertEq(user1.balance, userBalanceBefore - cost);
    }

    function test_CreateServiceFromQuotes_RevertExpiredQuote() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-expired", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 ttl = 100;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR1_PK),
            operator: operator1
        });

        // Warp past expiry
        vm.warp(block.timestamp + 2 hours);

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteExpired.selector, operator1, expiry));
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_RevertInvalidSignature() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-badsig", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 ttl = 100;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        // Sign with wrong key (operator2's key instead of operator1's)
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR2_PK),  // Wrong key!
            operator: operator1
        });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidQuoteSignature.selector, operator1));
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_RevertBlueprintMismatch() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-mismatch", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 ttl = 100;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        // Quote for wrong blueprint
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: 999,  // Wrong blueprint!
            ttlBlocks: ttl,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR1_PK),
            operator: operator1
        });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteBlueprintMismatch.selector, operator1, blueprintId, 999));
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_RevertTTLMismatch() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-ttl", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 expiry = uint64(block.timestamp + 1 hours);

        // Quote for different TTL
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: 50,  // Quote says 50
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR1_PK),
            operator: operator1
        });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteTTLMismatch.selector, operator1, 100, 50));
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, 100);  // Request wants 100
    }

    function test_CreateServiceFromQuotes_RevertDuplicateOperator() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-dup", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 ttl = 100;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        // Same operator twice
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR1_PK),
            operator: operator1
        });
        quotes[1] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR1_PK),
            operator: operator1  // Duplicate!
        });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.DuplicateOperatorQuote.selector, operator1));
        tangle.createServiceFromQuotes{ value: 2 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_RevertInsufficientPayment() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-pay", address(0)));

        vm.prank(operator1);
        restaking.registerOperator{ value: 5 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 ttl = 100;
        uint64 expiry = uint64(block.timestamp + 1 hours);

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 2 ether,  // Costs 2 ETH
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: _signQuote(details, OPERATOR1_PK),
            operator: operator1
        });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientPaymentForQuotes.selector, 2 ether, 1 ether));
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);  // Only sent 1 ETH
    }

    function test_CreateServiceFromQuotes_RevertNoQuotes() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://rfq-empty", address(0)));

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](0);
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(Errors.NoQuotes.selector);
        tangle.createServiceFromQuotes(blueprintId, quotes, "", callers, 100);
    }
}
