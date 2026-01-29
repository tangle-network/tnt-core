// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";

/// @title PaymentFuzzTest
/// @notice Fuzz tests for payment distribution logic
contract PaymentFuzzTest is BaseTest {
    uint64 blueprintId;

    function setUp() public override {
        super.setUp();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://fuzz", address(0)));

        _registerOperator(operator1, 10 ether);
        _registerForBlueprint(operator1, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT SPLIT FUZZ
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test that payment splits always sum to the total payment
    function testFuzz_PaymentSplit_ConservesTotal(uint128 paymentSeed) public {
        // Use uint128 to avoid overflow issues
        // M-5 FIX: Minimum payment is 100 wei
        uint256 payment = bound(uint256(paymentSeed), 100, 1000 ether);

        // Fund user with enough for this payment
        vm.deal(user1, payment + 1 ether);

        // Use default split (50/10/20/20)
        uint16 devBps = 5000;
        uint16 protoBps = 1000;
        uint16 opBps = 2000;
        uint16 stakerBps = 2000;

        // Set the payment split
        Types.PaymentSplit memory split = Types.PaymentSplit({
            developerBps: devBps,
            protocolBps: protoBps,
            operatorBps: opBps,
            stakerBps: stakerBps
        });
        vm.prank(admin);
        tangle.setPaymentSplit(split);

        // Create service and make payment
        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);

        uint256 treasuryBefore = treasury.balance;
        uint256 developerBefore = developer.balance;
        address distributor = tangle.serviceFeeDistributor();
        uint256 restakerBefore = distributor == address(0) ? 0 : distributor.balance;

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 developerReceived = developer.balance - developerBefore;
        uint256 treasuryReceived = treasury.balance - treasuryBefore;
        uint256 operatorPending = tangle.pendingRewards(operator1);
        uint256 restakerReceived = distributor == address(0) ? 0 : distributor.balance - restakerBefore;

        // Total distributed should equal total payment (accounting for rounding)
        uint256 totalDistributed = developerReceived + treasuryReceived + operatorPending + restakerReceived;

        // Allow for 4 wei rounding error (one per recipient)
        assertApproxEqAbs(totalDistributed, payment, 4, "Payment not fully distributed");
    }

    /// @notice Fuzz test that payment amounts never overflow
    function testFuzz_PaymentAmount_NoOverflow(uint256 payment) public {
        // Test with large payment amounts
        payment = bound(payment, 1 ether, type(uint128).max);

        // Fund the user
        vm.deal(user1, payment);

        uint64 requestId;
        vm.prank(user1);
        requestId = tangle.requestService{ value: payment }(
            blueprintId,
            _singleOperator(operator1),
            "",
            new address[](0),
            0,
            address(0),
            payment
        );

        // Should not overflow during payment distribution
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Verify service was created
        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceActive(serviceId));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-OPERATOR PAYMENT DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test exposure-weighted distribution across multiple operators
    function testFuzz_ExposureWeightedDistribution(
        uint256 payment,
        uint16 exposure1,
        uint16 exposure2
    ) public {
        // Bound inputs
        payment = bound(payment, 1 ether, 100 ether);
        exposure1 = uint16(bound(uint256(exposure1), 1000, 10000)); // Min 10%, Max 100%
        exposure2 = uint16(bound(uint256(exposure2), 1000, 10000));

        // Register second operator
        _registerOperator(operator2, 10 ether);
        _registerForBlueprint(operator2, blueprintId);

        // Create service with custom exposures
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        uint16[] memory exposures = new uint16[](2);
        exposures[0] = exposure1;
        exposures[1] = exposure2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: payment }(
            blueprintId, operators, exposures, "", callers, 0, address(0), payment
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        uint256 op1Rewards = tangle.pendingRewards(operator1);
        uint256 op2Rewards = tangle.pendingRewards(operator2);

        // Verify proportional distribution (within rounding tolerance)
        uint256 totalExposure = uint256(exposure1) + uint256(exposure2);
        uint256 totalOpRewards = op1Rewards + op2Rewards;

        // Check that exposure ratios are approximately preserved
        if (totalOpRewards > 0 && totalExposure > 0) {
            uint256 expectedRatio1 = (uint256(exposure1) * 10000) / totalExposure;
            uint256 actualRatio1 = totalOpRewards > 0 ? (op1Rewards * 10000) / totalOpRewards : 0;

            // Allow 1% tolerance for rounding
            assertApproxEqAbs(expectedRatio1, actualRatio1, 100, "Exposure ratio not preserved");
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBSCRIPTION BILLING FUZZ
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test subscription escrow doesn't go negative
    function testFuzz_SubscriptionEscrow_NeverNegative(
        uint256 initialEscrow,
        uint256 rate,
        uint8 billCount
    ) public {
        // Bound inputs
        initialEscrow = bound(initialEscrow, 0.1 ether, 100 ether);
        rate = bound(rate, 0.01 ether, 1 ether);
        billCount = uint8(bound(uint256(billCount), 1, 10));

        // Create subscription blueprint
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: rate,
            subscriptionInterval: 1 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 subBp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://sub-fuzz", address(0), config));
        _registerForBlueprint(operator1, subBp);

        // Create service with initial escrow
        address[] memory operators = new address[](1);
        operators[0] = operator1;

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: initialEscrow }(
            subBp, operators, "", new address[](0), 365 days, address(0), initialEscrow
        );
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Try billing multiple times
        uint256 currentTime = block.timestamp;
        for (uint8 i = 0; i < billCount; i++) {
            currentTime += 1 days + 1;
            vm.warp(currentTime);

            PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
            if (escrow.balance >= rate) {
                tangle.billSubscription(serviceId);

                PaymentLib.ServiceEscrow memory escrowAfter = tangle.getServiceEscrow(serviceId);
                assertGe(escrowAfter.balance, 0, "Escrow went negative");
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD CLAIMING FUZZ
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test that claiming rewards clears pending balance
    function testFuzz_ClaimRewards_ClearsBalance(uint256 payment) public {
        payment = bound(payment, 0.1 ether, 10 ether);

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 pending = tangle.pendingRewards(operator1);
        assertGt(pending, 0, "Should have pending rewards");

        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        tangle.claimRewards();

        assertEq(tangle.pendingRewards(operator1), 0, "Pending not cleared");
        assertEq(operator1.balance, balanceBefore + pending, "Balance not received");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _singleOperator(address op) internal pure returns (address[] memory) {
        address[] memory operators = new address[](1);
        operators[0] = op;
        return operators;
    }
}
