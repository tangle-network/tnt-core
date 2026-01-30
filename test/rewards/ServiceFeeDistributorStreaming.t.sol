// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";
import { MockPriceOracle } from "../exposure/MockPriceOracle.sol";
import { ServiceFeeDistributor } from "../../src/rewards/ServiceFeeDistributor.sol";
import { StreamingPaymentManager } from "../../src/rewards/StreamingPaymentManager.sol";
import { Errors } from "../../src/libraries/Errors.sol";

/// @title ServiceFeeDistributorStreamingTest
/// @notice Tests for streaming payment distribution over service TTL
contract ServiceFeeDistributorStreamingTest is BaseTest {
    MockERC20 internal stakeToken;
    MockERC20 internal payToken;
    MockPriceOracle internal oracle;
    ServiceFeeDistributor internal distributor;
    StreamingPaymentManager internal streamingManager;
    uint64 internal blueprintId;

    uint64 constant TTL = 30 days;

    function setUp() public override {
        super.setUp();

        stakeToken = new MockERC20();
        payToken = new MockERC20();
        oracle = new MockPriceOracle();

        oracle.setPrice(address(0), 1e18);
        oracle.setPrice(address(stakeToken), 1e18);

        // Deploy ServiceFeeDistributor
        ServiceFeeDistributor impl = new ServiceFeeDistributor();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(ServiceFeeDistributor.initialize, (admin, address(staking), address(tangle), address(oracle)))
        );
        distributor = ServiceFeeDistributor(payable(address(proxy)));

        // Deploy StreamingPaymentManager
        StreamingPaymentManager streamingImpl = new StreamingPaymentManager();
        ERC1967Proxy streamingProxy = new ERC1967Proxy(
            address(streamingImpl),
            abi.encodeCall(StreamingPaymentManager.initialize, (admin, address(tangle), address(distributor)))
        );
        streamingManager = StreamingPaymentManager(payable(address(streamingProxy)));

        vm.startPrank(admin);
        // Configure distributor to use streaming manager
        distributor.setStreamingManager(address(streamingManager));
        tangle.setServiceFeeDistributor(address(distributor));
        tangle.setPriceOracle(address(oracle));
        staking.setServiceFeeDistributor(address(distributor));
        staking.enableAsset(address(stakeToken), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);
        vm.stopPrank();

        // Create blueprint with TTL pricing
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://streaming", address(0), config));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);

        // Setup delegator with stake
        vm.prank(delegator1);
        staking.depositAndDelegate{ value: 10 ether }(operator1);

        payToken.mint(user1, 1_000 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STREAMING PAYMENT CREATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Streaming_CreatesStreamForTTLService() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Verify stream was created
        (
            uint64 svcId, , address op, address token,
            uint256 totalAmount, uint256 distributed,
            uint64 startTime, uint64 endTime,
        ) = streamingManager.getStreamingPayment(serviceId, operator1);

        assertEq(svcId, serviceId);
        assertEq(op, operator1);
        assertEq(token, address(payToken));
        assertGt(totalAmount, 0, "Stream should have payment amount");
        assertEq(distributed, 0, "Nothing distributed yet");
        assertEq(endTime - startTime, TTL, "Duration should match TTL");
    }

    function test_Streaming_NoStreamForZeroTTL() public {
        // Create service without TTL
        uint64 serviceId = _createServiceWithoutTTL(100 ether);

        // Verify no stream exists
        (,,,, uint256 totalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        assertEq(totalAmount, 0, "No stream for zero TTL");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DRIP FUNCTIONALITY
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Streaming_DripDistributesProRata() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        (,,,, uint256 totalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator1);

        // Advance 50% of TTL
        vm.warp(block.timestamp + TTL / 2);

        // Drip
        distributor.drip(serviceId, operator1);

        (,,,,, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);

        // Should have distributed ~50%
        assertApproxEqRel(distributed, totalAmount / 2, 0.01e18, "Should distribute ~50%");
    }

    function test_Streaming_DripNothingBeforeStart() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Try to drip immediately (should do nothing, stream hasn't accumulated)
        uint256 pending = distributor.pendingDrip(serviceId, operator1);
        assertEq(pending, 0, "No pending drip at start");
    }

    function test_Streaming_DripFullAmountAfterTTL() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        (,,,, uint256 totalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator1);

        // Advance past TTL
        vm.warp(block.timestamp + TTL + 1);

        // Drip should distribute everything
        distributor.drip(serviceId, operator1);

        (,,,,, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        assertEq(distributed, totalAmount, "Should distribute full amount");
    }

    function test_Streaming_MultipleDripsAccumulate() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        (,,,, uint256 totalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator1);

        // Drip at 25%
        vm.warp(block.timestamp + TTL / 4);
        distributor.drip(serviceId, operator1);
        (,,,,, uint256 firstDrip,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        assertApproxEqRel(firstDrip, totalAmount / 4, 0.01e18);

        // Drip at 50%
        vm.warp(block.timestamp + TTL / 4);
        distributor.drip(serviceId, operator1);
        (,,,,, uint256 afterSecond,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        uint256 secondDrip = afterSecond - firstDrip;
        assertApproxEqRel(secondDrip, totalAmount / 4, 0.01e18);

        // Drip at 100%
        vm.warp(block.timestamp + TTL / 2);
        distributor.drip(serviceId, operator1);
        (,,,,, uint256 finalDistributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        assertApproxEqRel(finalDistributed, totalAmount, 0.01e18);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR LEAVING HOOK
    // ═══════════════════════════════════════════════════════════════════════════

    function test_OnOperatorLeaving_DripsBeforeRemoval() public {
        // Create service with two operators
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, blueprintId);

        // Setup delegator for operator2
        vm.prank(delegator2);
        staking.depositAndDelegate{ value: 10 ether }(operator2);

        uint64 serviceId = _createServiceWithTTLAndOperators(100 ether);

        (,,,, uint256 op2TotalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator2);

        // Advance 50% of TTL
        vm.warp(block.timestamp + TTL / 2);

        // Simulate operator leaving - this should drip before removal
        vm.prank(address(tangle));
        distributor.onOperatorLeaving(serviceId, operator2);

        // Verify drip happened
        (,,,,, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator2);
        assertApproxEqRel(distributed, op2TotalAmount / 2, 0.01e18, "Should drip ~50% before leaving");
    }

    function test_OnOperatorLeaving_RevertNotTangle() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        vm.prank(user1);
        vm.expectRevert(ServiceFeeDistributor.NotTangle.selector);
        distributor.onOperatorLeaving(serviceId, operator1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION CHANGES DURING STREAM
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Streaming_DelegationChange_DripsBeforeScoreUpdate() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Advance 50% of TTL
        vm.warp(block.timestamp + TTL / 2);

        // New delegator joins - this should trigger drip for the operator
        vm.prank(delegator2);
        staking.depositAndDelegate{ value: 10 ether }(operator1);

        // Check that stream was dripped
        (,,,,, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        assertGt(distributed, 0, "Should have dripped before delegation change");
    }

    function test_Streaming_NewJoinerGetsOnlyFutureRewards() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Advance 50% of TTL
        vm.warp(block.timestamp + TTL / 2);

        // Record delegator1's pending before new delegator joins
        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });

        // New delegator joins (triggers drip)
        vm.prank(delegator2);
        staking.depositAndDelegate{ value: 10 ether }(operator1);

        // Advance to 100%
        vm.warp(block.timestamp + TTL / 2);

        // Drip remaining
        distributor.drip(serviceId, operator1);

        // Both delegators claim
        vm.prank(delegator1);
        uint256 d1Claimed = distributor.claimFor(address(payToken), operator1, nativeAsset);

        vm.prank(delegator2);
        uint256 d2Claimed = distributor.claimFor(address(payToken), operator1, nativeAsset);

        // Delegator1 should have more rewards (was there for full duration)
        // Delegator2 only gets rewards from the second half
        assertGt(d1Claimed, d2Claimed, "Original delegator should have more rewards");

        // Delegator1 gets 100% of first half + 50% of second half = 75% of total
        // Delegator2 gets 0% of first half + 50% of second half = 25% of total
        // Ratio should be 3:1
        assertApproxEqRel(d1Claimed, d2Claimed * 3, 0.05e18, "Reward ratio should be ~3:1");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIMING STREAMING REWARDS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Streaming_ClaimTriggersDrip() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Advance 50% of TTL
        vm.warp(block.timestamp + TTL / 2);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });

        // Claim should trigger drip and return rewards
        uint256 balBefore = payToken.balanceOf(delegator1);
        vm.prank(delegator1);
        distributor.claimFor(address(payToken), operator1, nativeAsset);
        uint256 balAfter = payToken.balanceOf(delegator1);

        assertGt(balAfter - balBefore, 0, "Should receive rewards");

        // Verify stream was dripped
        (,,,,, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        assertGt(distributed, 0, "Stream should have been dripped");
    }

    function test_Streaming_PendingRewardsView() public {
        _createServiceWithTTL(100 ether);

        // Advance 50% of TTL
        vm.warp(block.timestamp + TTL / 2);

        // Note: pendingRewards view doesn't trigger drip, so it shows current claimable only
        // Manual drip first to see pending
        distributor.dripAll(operator1);

        uint256 pending = distributor.pendingRewards(delegator1, address(payToken));
        assertGt(pending, 0, "Should have pending rewards after drip");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Streaming_GetOperatorActiveStreams() public {
        uint64 serviceId1 = _createServiceWithTTL(50 ether);
        uint64 serviceId2 = _createServiceWithTTL(50 ether);

        uint64[] memory streams = distributor.getOperatorActiveStreams(operator1);
        assertEq(streams.length, 2, "Should have 2 active streams");
        assertEq(streams[0], serviceId1);
        assertEq(streams[1], serviceId2);
    }

    function test_Streaming_PendingDrip() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        (,,,, uint256 totalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator1);

        // Advance 50%
        vm.warp(block.timestamp + TTL / 2);

        uint256 pending = distributor.pendingDrip(serviceId, operator1);
        assertApproxEqRel(pending, totalAmount / 2, 0.01e18, "Pending should be ~50%");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Streaming_ZeroPayment_NoStream() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", callers, TTL, address(payToken), 0
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        (,,,, uint256 totalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        assertEq(totalAmount, 0, "No stream for zero payment");
    }

    function test_Streaming_DripAllOperatorStreams() public {
        // Create multiple services for same operator
        _createServiceWithTTL(50 ether);
        _createServiceWithTTL(50 ether);

        // Advance time
        vm.warp(block.timestamp + TTL / 2);

        // Drip all at once
        distributor.dripAll(operator1);

        // Verify all streams were dripped
        uint64[] memory streams = distributor.getOperatorActiveStreams(operator1);
        for (uint256 i = 0; i < streams.length; i++) {
            (,,,,, uint256 distributed,,,) = streamingManager.getStreamingPayment(streams[i], operator1);
            assertGt(distributed, 0, "Each stream should have been dripped");
        }
    }

    function test_Streaming_CompletedStreamRemoved() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Verify stream is active
        uint64[] memory streamsBefore = distributor.getOperatorActiveStreams(operator1);
        assertEq(streamsBefore.length, 1, "Should have 1 active stream");

        // Advance past TTL and drip
        vm.warp(block.timestamp + TTL + 1);
        distributor.drip(serviceId, operator1);

        // Verify stream is removed from active list
        uint64[] memory streamsAfter = distributor.getOperatorActiveStreams(operator1);
        assertEq(streamsAfter.length, 0, "Completed stream should be removed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE TERMINATION REFUND
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Termination_RefundsRemainingPayment() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        (,,,, uint256 totalAmount,,,,) = streamingManager.getStreamingPayment(serviceId, operator1);

        // Advance 25% of TTL
        vm.warp(block.timestamp + TTL / 4);

        // Drip to distribute 25%
        distributor.drip(serviceId, operator1);
        (,,,,, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);

        // Record owner balance before termination
        uint256 ownerBalBefore = payToken.balanceOf(user1);

        // Terminate service (by owner)
        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Check owner received refund (remaining 75%)
        uint256 ownerBalAfter = payToken.balanceOf(user1);
        uint256 refund = ownerBalAfter - ownerBalBefore;

        assertApproxEqRel(refund, totalAmount - distributed, 0.01e18, "Should refund remaining amount");
        assertApproxEqRel(refund, totalAmount * 3 / 4, 0.05e18, "Should refund ~75%");
    }

    function test_Termination_DripsBeforeRefund() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Advance 50% of TTL without dripping
        vm.warp(block.timestamp + TTL / 2);

        // Verify stream has pending drip
        uint256 pendingBefore = distributor.pendingDrip(serviceId, operator1);
        assertGt(pendingBefore, 0, "Should have pending drip");

        // Terminate service
        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Check that stream was dripped before refund
        (,,,, uint256 totalAmount, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        // Stream should show distributed equal to total (marked as complete after refund)
        assertEq(distributed, totalAmount, "Stream should be marked complete");
    }

    function test_Termination_NoRefundForCompletedStream() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Advance past TTL and drip all
        vm.warp(block.timestamp + TTL + 1);
        distributor.drip(serviceId, operator1);

        // Record owner balance
        uint256 ownerBalBefore = payToken.balanceOf(user1);

        // Terminate (no refund should happen)
        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Owner balance unchanged
        uint256 ownerBalAfter = payToken.balanceOf(user1);
        assertEq(ownerBalAfter, ownerBalBefore, "No refund for completed stream");
    }

    function test_Termination_MultipleOperatorsRefund() public {
        // Register second operator
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, blueprintId);
        vm.prank(delegator2);
        staking.depositAndDelegate{ value: 10 ether }(operator2);

        uint64 serviceId = _createServiceWithTTLAndOperators(100 ether);

        // Advance 25% of TTL
        vm.warp(block.timestamp + TTL / 4);

        uint256 ownerBalBefore = payToken.balanceOf(user1);

        // Terminate
        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Both operators' streams should be refunded
        uint256 ownerBalAfter = payToken.balanceOf(user1);
        uint256 totalRefund = ownerBalAfter - ownerBalBefore;

        // Total refund should be 75% of both operators' streams combined
        assertGt(totalRefund, 0, "Should have refund from both operators");
    }

    function test_Termination_StreamRemovedFromActive() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Verify stream is active
        uint64[] memory streamsBefore = distributor.getOperatorActiveStreams(operator1);
        assertEq(streamsBefore.length, 1, "Should have 1 active stream");

        // Advance 50% and terminate
        vm.warp(block.timestamp + TTL / 2);
        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Stream should be removed
        uint64[] memory streamsAfter = distributor.getOperatorActiveStreams(operator1);
        assertEq(streamsAfter.length, 0, "Stream should be removed after termination");
    }

    function test_Termination_EmitsEvent() public {
        uint64 serviceId = _createServiceWithTTL(100 ether);

        // Advance 25% of TTL
        vm.warp(block.timestamp + TTL / 4);

        // Drip first to get a baseline
        distributor.drip(serviceId, operator1);
        (,,,, uint256 totalAmount, uint256 distributed,,,) = streamingManager.getStreamingPayment(serviceId, operator1);
        uint256 remaining = totalAmount - distributed;

        // Expect event from StreamingPaymentManager
        vm.expectEmit(true, true, false, true);
        emit StreamingPaymentManager.StreamingPaymentCancelled(serviceId, operator1, remaining, user1);

        vm.prank(user1);
        tangle.terminateService(serviceId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _createServiceWithTTL(uint256 payment) internal returns (uint64 serviceId) {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.startPrank(user1);
        payToken.approve(address(tangle), payment);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", callers, TTL, address(payToken), payment
        );
        vm.stopPrank();

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        serviceId = tangle.serviceCount() - 1;
    }

    function _createServiceWithoutTTL(uint256 payment) internal returns (uint64 serviceId) {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.startPrank(user1);
        payToken.approve(address(tangle), payment);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", callers, 0, address(payToken), payment
        );
        vm.stopPrank();

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        serviceId = tangle.serviceCount() - 1;
    }

    function _createServiceWithTTLAndOperators(uint256 payment) internal returns (uint64 serviceId) {
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.startPrank(user1);
        payToken.approve(address(tangle), payment);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", callers, TTL, address(payToken), payment
        );
        vm.stopPrank();

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        serviceId = tangle.serviceCount() - 1;
    }
}
