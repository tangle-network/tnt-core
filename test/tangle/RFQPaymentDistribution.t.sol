// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Tangle } from "../../src/Tangle.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";
import { TangleJobsRFQFacet } from "../../src/facets/tangle/TangleJobsRFQFacet.sol";
import { MockServiceFeeDistributor } from "../mocks/MockServiceFeeDistributor.sol";

/// @title RFQPaymentDistributionTest
/// @notice Security-focused tests for RFQ payment distribution.
///         Verifies that RFQ jobs go through the same dev/protocol/operator/staker split
///         as market-order jobs, and probes edge cases around multi-operator payment.
contract RFQPaymentDistributionTest is BaseTest {
    uint256 constant OPERATOR1_PK = 0x1;
    uint256 constant OPERATOR2_PK = 0x2;
    uint256 constant OPERATOR3_PK = 0x3;

    uint64 blueprintId;
    uint64 serviceId;
    uint64 internal quoteNonce;

    // Default split: 20% dev, 20% protocol, 40% operator, 20% staker
    uint16 constant DEV_BPS = 2000;
    uint16 constant PROTOCOL_BPS = 2000;
    uint16 constant OPERATOR_BPS = 4000;
    uint16 constant STAKER_BPS = 2000;

    function setUp() public override {
        super.setUp();

        // Deterministic keys for EIP-712 signing
        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);
        operator3 = vm.addr(OPERATOR3_PK);

        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(operator3, 100 ether);

        // Register RFQ facet
        vm.startPrank(admin);
        Tangle(payable(address(tangleProxy))).registerFacet(address(new TangleJobsRFQFacet()));
        vm.stopPrank();

        // EventDriven blueprint with 0.5 ETH default rate
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 0,
            maxOperators: 0,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0.5 ether
        });

        blueprintId = _createBlueprintWithConfig(developer, address(0), config);

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);

        // Service with operator1 and operator2
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
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SPLIT VERIFICATION: RFQ goes through full dev/protocol/operator/staker split
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RFQPayment_DeveloperGetsCut() public {
        uint256 payment = 10 ether;
        uint256 devBalBefore = developer.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        // Developer should receive developerBps share
        uint256 expectedDev = (payment * DEV_BPS) / 10_000;
        assertEq(developer.balance - devBalBefore, expectedDev, "developer should get 20% of RFQ payment");
    }

    function test_RFQPayment_ProtocolTreasuryGetsCut() public {
        uint256 payment = 10 ether;
        uint256 treasuryBalBefore = treasury.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        uint256 expectedProtocol = (payment * PROTOCOL_BPS) / 10_000;
        assertEq(treasury.balance - treasuryBalBefore, expectedProtocol, "treasury should get 20% of RFQ payment");
    }

    function test_RFQPayment_OperatorGetsPendingRewards() public {
        uint256 payment = 10 ether;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        // Operator should have pending rewards.
        // No restakers → operator gets operatorBps + stakerBps (merged).
        uint256 expectedOp = (payment * OPERATOR_BPS) / 10_000;
        uint256 expectedStaker = payment - (payment * DEV_BPS) / 10_000 - (payment * PROTOCOL_BPS) / 10_000 - expectedOp;
        uint256 expectedTotal = expectedOp + expectedStaker; // No restakers → merged
        uint256 pending = tangle.pendingRewards(operator1);

        assertEq(pending, expectedTotal, "operator should receive operator+staker share (no restakers)");
    }

    function test_RFQPayment_FullSplitSumsToPayment() public {
        uint256 payment = 10 ether;
        uint256 devBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;
        uint256 contractBefore = address(tangleProxy).balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        uint256 devGot = developer.balance - devBefore;
        uint256 treasuryGot = treasury.balance - treasuryBefore;
        uint256 opPending = tangle.pendingRewards(operator1);

        // All payment should be accounted for (no funds stuck in contract)
        // Dev + protocol transferred out; operator pending sits in contract balance
        assertEq(devGot + treasuryGot + opPending, payment, "full payment must be distributed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // COMPARISON: Market-order vs RFQ use same split proportions
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MarketVsRFQ_SameSplitProportions() public {
        uint256 payment = 4 ether;

        // --- Market-order job ---
        uint8[] memory indexes = new uint8[](1);
        indexes[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = payment;
        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        uint256 devBefore1 = developer.balance;
        uint256 treasuryBefore1 = treasury.balance;

        vm.prank(user1);
        uint64 callId1 = tangle.submitJob{ value: payment }(serviceId, 0, "");

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId1, "result");

        uint256 marketDevGot = developer.balance - devBefore1;
        uint256 marketTreasuryGot = treasury.balance - treasuryBefore1;

        // --- RFQ job (same total payment, single operator) ---
        // Reset the per-job rate so market-order and RFQ are independent
        rates[0] = 0.5 ether; // restore default
        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        uint256 devBefore2 = developer.balance;
        uint256 treasuryBefore2 = treasury.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId2 = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId2, "result");

        uint256 rfqDevGot = developer.balance - devBefore2;
        uint256 rfqTreasuryGot = treasury.balance - treasuryBefore2;

        // Developer and protocol portions should be identical for same payment amount
        assertEq(rfqDevGot, marketDevGot, "developer share should match between market and RFQ");
        assertEq(rfqTreasuryGot, marketTreasuryGot, "protocol share should match between market and RFQ");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-OPERATOR RFQ SPLIT
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultiOpRFQ_EachOperatorPriceGoesthroughSplitIndependently() public {
        uint256 price1 = 3 ether;
        uint256 price2 = 7 ether;
        uint256 totalPayment = price1 + price2;

        uint256 devBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, price1);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, price2);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: totalPayment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        // Developer gets DEV_BPS of each operator's price (applied independently)
        uint256 expectedDev = (price1 * DEV_BPS) / 10_000 + (price2 * DEV_BPS) / 10_000;
        uint256 expectedTreasury = (price1 * PROTOCOL_BPS) / 10_000 + (price2 * PROTOCOL_BPS) / 10_000;

        assertEq(developer.balance - devBefore, expectedDev, "dev gets split from each op's price");
        assertEq(treasury.balance - treasuryBefore, expectedTreasury, "treasury gets split from each op's price");

        // Each operator should have independent pending rewards
        uint256 op1Pending = tangle.pendingRewards(operator1);
        uint256 op2Pending = tangle.pendingRewards(operator2);
        assertTrue(op1Pending > 0, "operator1 should have pending rewards");
        assertTrue(op2Pending > 0, "operator2 should have pending rewards");

        // Operator2 quoted more, should have proportionally more pending
        assertTrue(op2Pending > op1Pending, "operator2 quoted more, should get more rewards");
    }

    function test_MultiOpRFQ_TotalDistributedEqualsPayment() public {
        uint256 price1 = 2 ether;
        uint256 price2 = 5 ether;
        uint256 totalPayment = price1 + price2;

        uint256 devBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, price1);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, price2);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: totalPayment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        uint256 devGot = developer.balance - devBefore;
        uint256 treasuryGot = treasury.balance - treasuryBefore;
        uint256 op1Pending = tangle.pendingRewards(operator1);
        uint256 op2Pending = tangle.pendingRewards(operator2);

        // No funds should be unaccounted for
        assertEq(
            devGot + treasuryGot + op1Pending + op2Pending,
            totalPayment,
            "all payment must be distributed across recipients"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FIX: Sub-minimum individual quote now reverts at submission (not finalization)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Sub-MINIMUM_PAYMENT_AMOUNT individual quote in multi-operator RFQ
    ///         is now rejected at submission time, preventing bricked jobs.
    function test_SubMinimumQuoteRevertsAtSubmission() public {
        uint256 legitimatePrice = 1 ether;
        uint256 dustPrice = 50; // 50 wei — below MINIMUM_PAYMENT_AMOUNT (100)
        uint256 totalPayment = legitimatePrice + dustPrice;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, legitimatePrice);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, dustPrice);

        // Now correctly reverts at submission — individual quote below minimum
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.PaymentTooSmall.selector, dustPrice, 100));
        tangle.submitJobFromQuote{ value: totalPayment }(serviceId, 0, "", quotes);
    }

    /// @notice Single-operator RFQ with sub-minimum price correctly reverts at submission
    function test_SingleOpRFQ_SubMinimumRevertsAtSubmission() public {
        uint256 dustPrice = 50; // Below MINIMUM_PAYMENT_AMOUNT

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, dustPrice);

        // This correctly reverts at collectPayment — single-op is protected
        vm.prank(user1);
        vm.expectRevert(); // PaymentTooSmall
        tangle.submitJobFromQuote{ value: dustPrice }(serviceId, 0, "", quotes);
    }

    /// @notice Price of exactly MINIMUM_PAYMENT_AMOUNT should work for both paths
    function test_RFQ_ExactMinimumPayment() public {
        uint256 minPayment = 100; // MINIMUM_PAYMENT_AMOUNT

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, minPayment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: minPayment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed, "job at MINIMUM_PAYMENT_AMOUNT should complete");
    }

    /// @notice Multi-operator where both prices are at minimum — should work
    function test_MultiOpRFQ_BothAtMinimumPayment() public {
        uint256 minPayment = 100;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, minPayment);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, minPayment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: minPayment * 2 }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed, "both at minimum should complete");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // NON-DELIVERING OPERATOR IN MULTI-QUOTE: payment goes to all quoted operators
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice When 2 operators are quoted but requiredResultCount=1 (default),
    ///         both operators get paid even though only one submitted results.
    ///         This is by design but should be understood by consumers.
    function test_MultiOpRFQ_NonDeliveringOperatorStillGetsPaid() public {
        uint256 price1 = 2 ether;
        uint256 price2 = 3 ether;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, price1);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, price2);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: price1 + price2 }(serviceId, 0, "", quotes);

        // Only operator1 submits a result — job completes (requiredResultCount=1)
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed);

        // Operator2 never submitted results but still gets paid
        uint256 op2Pending = tangle.pendingRewards(operator2);
        assertTrue(op2Pending > 0, "non-delivering operator2 still receives payment");

        // Operator1 also gets paid
        uint256 op1Pending = tangle.pendingRewards(operator1);
        assertTrue(op1Pending > 0, "delivering operator1 receives payment");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ZERO-PRICE QUOTE IN MULTI-OP RFQ
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultiOpRFQ_ZeroPriceOperatorSkipped() public {
        uint256 price1 = 5 ether;
        uint256 price2 = 0;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, price1);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, price2);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: price1 }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        // Zero-price operator should have no pending rewards
        assertEq(tangle.pendingRewards(operator2), 0, "zero-price operator should get nothing");

        // Full payment distributed to operator1's split
        uint256 devExpected = (price1 * DEV_BPS) / 10_000;
        uint256 treasuryExpected = (price1 * PROTOCOL_BPS) / 10_000;
        uint256 op1Pending = tangle.pendingRewards(operator1);

        assertEq(
            devExpected + treasuryExpected + op1Pending, price1, "all funds accounted for with zero-price operator"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OVERPAYMENT: excess ETH stays in contract (not refunded)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RFQ_OverpaymentNotRefunded() public {
        uint256 quotePrice = 1 ether;
        uint256 overpay = 2 ether;

        uint256 userBefore = user1.balance;
        uint256 contractBefore = address(tangleProxy).balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, quotePrice);

        vm.prank(user1);
        tangle.submitJobFromQuote{ value: overpay }(serviceId, 0, "", quotes);

        // User paid full overpay amount (no refund)
        assertEq(user1.balance, userBefore - overpay, "user loses full msg.value including overpay");

        // Excess sits in contract
        uint256 excess = overpay - quotePrice;
        assertEq(address(tangleProxy).balance, contractBefore + overpay, "contract holds full msg.value");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CUSTOM PAYMENT SPLIT
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RFQPayment_CustomSplitApplied() public {
        // Set a custom split: 10% dev, 5% protocol, 80% operator, 5% staker
        Types.PaymentSplit memory customSplit =
            Types.PaymentSplit({ developerBps: 1000, protocolBps: 500, operatorBps: 8000, stakerBps: 500 });
        vm.prank(admin);
        tangle.setPaymentSplit(customSplit);

        uint256 payment = 10 ether;
        uint256 devBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        assertEq(developer.balance - devBefore, (payment * 1000) / 10_000, "custom dev split");
        assertEq(treasury.balance - treasuryBefore, (payment * 500) / 10_000, "custom protocol split");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUZZ: Verify split math for arbitrary RFQ prices
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_RFQPaymentSplit(uint128 rawPrice) public {
        uint256 payment = uint256(rawPrice);
        vm.assume(payment >= 100 && payment <= 100 ether);

        vm.deal(user1, payment);

        uint256 devBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        uint256 devGot = developer.balance - devBefore;
        uint256 treasuryGot = treasury.balance - treasuryBefore;
        uint256 opPending = tangle.pendingRewards(operator1);

        // No value lost or created
        assertEq(devGot + treasuryGot + opPending, payment, "fuzz: total distributed must equal payment");

        // Dev gets floor(payment * 2000 / 10000)
        assertEq(devGot, (payment * DEV_BPS) / 10_000, "fuzz: developer share");
        assertEq(treasuryGot, (payment * PROTOCOL_BPS) / 10_000, "fuzz: protocol share");
    }

    function testFuzz_MultiOpRFQPaymentSplit(uint64 rawPrice1, uint64 rawPrice2) public {
        uint256 price1 = uint256(rawPrice1);
        uint256 price2 = uint256(rawPrice2);
        vm.assume(price1 >= 100 && price1 <= 50 ether);
        vm.assume(price2 >= 100 && price2 <= 50 ether);

        uint256 total = price1 + price2;
        vm.deal(user1, total);

        uint256 devBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, price1);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, price2);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: total }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        uint256 devGot = developer.balance - devBefore;
        uint256 treasuryGot = treasury.balance - treasuryBefore;
        uint256 op1Pending = tangle.pendingRewards(operator1);
        uint256 op2Pending = tangle.pendingRewards(operator2);

        // All funds accounted for
        assertEq(devGot + treasuryGot + op1Pending + op2Pending, total, "fuzz multi-op: total must equal payment");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RESTAKER SHARE FORWARDING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice When a ServiceFeeDistributor is set and there are security commitments,
    ///         the restaker share should be forwarded to the distributor (not merged into operator).
    ///         Without actual delegations, restaker share merges into operator pool.
    function test_RFQPayment_RestakerShareBehavior() public {
        // With the default test setup there are no restakers, so restaker share
        // should be merged into operator pool. Verify this explicitly.
        uint256 payment = 10 ether;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        uint256 expectedDev = (payment * DEV_BPS) / 10_000;
        uint256 expectedProtocol = (payment * PROTOCOL_BPS) / 10_000;
        uint256 expectedOpBase = (payment * OPERATOR_BPS) / 10_000;
        uint256 expectedStaker = payment - expectedDev - expectedProtocol - expectedOpBase;

        // No restakers → staker share merges into operator pending rewards
        uint256 opPending = tangle.pendingRewards(operator1);
        assertEq(opPending, expectedOpBase + expectedStaker, "no restakers: staker share merges into operator");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUNDING EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RFQPayment_OddPaymentNoFundsLost() public {
        // Payment not cleanly divisible by split denominator (10000)
        uint256 payment = 10_001;

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, payment);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: payment }(serviceId, 0, "", quotes);

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        uint256 devGot = developer.balance - 100 ether; // started with 100 ether
        uint256 treasuryGot = treasury.balance;
        uint256 opPending = tangle.pendingRewards(operator1);

        // M-5 fix: restaker (last recipient) gets rounding dust
        assertEq(devGot + treasuryGot + opPending, payment, "odd payment: no dust lost");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _createJobQuote(
        address operator,
        uint256 privateKey,
        uint64 _serviceId,
        uint8 jobIndex,
        uint256 price
    )
        internal
        returns (Types.SignedJobQuote memory)
    {
        uint64 baseTimestamp = uint64(block.timestamp) + quoteNonce;
        quoteNonce++;

        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: _serviceId,
            jobIndex: jobIndex,
            price: price,
            timestamp: baseTimestamp,
            expiry: baseTimestamp + 1 hours
        });

        bytes memory signature = _signJobQuote(details, privateKey);

        return Types.SignedJobQuote({ details: details, signature: signature, operator: operator });
    }

    function _signJobQuote(
        Types.JobQuoteDetails memory details,
        uint256 privateKey
    )
        internal
        view
        returns (bytes memory)
    {
        bytes32 JOB_QUOTE_TYPEHASH_LOCAL = keccak256(
            "JobQuoteDetails(uint64 serviceId,uint8 jobIndex,uint256 price,uint64 timestamp,uint64 expiry)"
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("TangleQuote"),
                keccak256("1"),
                block.chainid,
                address(tangle)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                JOB_QUOTE_TYPEHASH_LOCAL,
                details.serviceId,
                details.jobIndex,
                details.price,
                details.timestamp,
                details.expiry
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return abi.encodePacked(r, s, v);
    }
}
