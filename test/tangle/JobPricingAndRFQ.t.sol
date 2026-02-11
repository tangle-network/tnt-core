// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Tangle } from "../../src/Tangle.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { SignatureLib } from "../../src/libraries/SignatureLib.sol";
import { TangleJobsRFQFacet } from "../../src/facets/tangle/TangleJobsRFQFacet.sol";

/// @title JobPricingAndRFQTest
/// @notice Tests for per-job pricing (setJobEventRates) and Job RFQ (submitJobFromQuote)
contract JobPricingAndRFQTest is BaseTest {
    uint256 constant OPERATOR1_PK = 0x1;
    uint256 constant OPERATOR2_PK = 0x2;
    uint256 constant OPERATOR3_PK = 0x3;

    uint64 blueprintId;
    uint64 serviceId;
    uint64 internal quoteNonce;

    function setUp() public override {
        super.setUp();

        // Override operator addresses with deterministic keys (for EIP-712 signing)
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

        // Create an EventDriven blueprint with a default eventRate
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

        // Register operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);

        // Create service with operator1 and operator2
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
    // PER-JOB PRICING: setJobEventRates / getJobEventRate
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetJobEventRates_OverridesDefaultRate() public {
        uint8[] memory indexes = new uint8[](1);
        indexes[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = 1 ether;

        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        assertEq(tangle.getJobEventRate(blueprintId, 0), 1 ether);
    }

    function test_SetJobEventRates_BatchMultipleJobs() public {
        uint8[] memory indexes = new uint8[](3);
        indexes[0] = 0;
        indexes[1] = 1;
        indexes[2] = 2;
        uint256[] memory rates = new uint256[](3);
        rates[0] = 1 ether;
        rates[1] = 2 ether;
        rates[2] = 0.1 ether;

        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        assertEq(tangle.getJobEventRate(blueprintId, 0), 1 ether);
        assertEq(tangle.getJobEventRate(blueprintId, 1), 2 ether);
        assertEq(tangle.getJobEventRate(blueprintId, 2), 0.1 ether);
    }

    function test_GetJobEventRate_FallsBackToDefault() public {
        // No per-job rate set, should return blueprint's eventRate (0.5 ether)
        assertEq(tangle.getJobEventRate(blueprintId, 0), 0.5 ether);
    }

    function test_SetJobEventRates_ClearOverrideRestoresDefault() public {
        // Set a rate
        uint8[] memory indexes = new uint8[](1);
        indexes[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = 2 ether;

        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);
        assertEq(tangle.getJobEventRate(blueprintId, 0), 2 ether);

        // Clear it (set to 0)
        rates[0] = 0;
        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        // Should fall back to blueprint default
        assertEq(tangle.getJobEventRate(blueprintId, 0), 0.5 ether);
    }

    function test_SetJobEventRates_RevertNotBlueprintOwner() public {
        uint8[] memory indexes = new uint8[](1);
        indexes[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = 1 ether;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, blueprintId, user1));
        tangle.setJobEventRates(blueprintId, indexes, rates);
    }

    function test_SetJobEventRates_RevertLengthMismatch() public {
        uint8[] memory indexes = new uint8[](2);
        indexes[0] = 0;
        indexes[1] = 1;
        uint256[] memory rates = new uint256[](1);
        rates[0] = 1 ether;

        vm.prank(developer);
        vm.expectRevert(Errors.LengthMismatch.selector);
        tangle.setJobEventRates(blueprintId, indexes, rates);
    }

    function test_SetJobEventRates_RevertInvalidJobIndex() public {
        uint8[] memory indexes = new uint8[](1);
        indexes[0] = 255; // Way out of bounds
        uint256[] memory rates = new uint256[](1);
        rates[0] = 1 ether;

        vm.prank(developer);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidJobIndex.selector, 255));
        tangle.setJobEventRates(blueprintId, indexes, rates);
    }

    function test_SubmitJob_UsesPerJobRate() public {
        // Set per-job rate for job 0 to 1 ether (instead of default 0.5 ether)
        uint8[] memory indexes = new uint8[](1);
        indexes[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = 1 ether;

        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        // Submit job with the per-job rate
        vm.prank(user1);
        uint64 callId = tangle.submitJob{ value: 1 ether }(serviceId, 0, "");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 1 ether);
    }

    function test_SubmitJob_UsesDefaultRateWhenNoOverride() public {
        // No per-job rate set, uses blueprint default (0.5 ether)
        vm.prank(user1);
        uint64 callId = tangle.submitJob{ value: 0.5 ether }(serviceId, 0, "");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 0.5 ether);
    }

    function test_SubmitJob_DifferentRatesPerJobType() public {
        // Set different rates for job 0 and job 1
        uint8[] memory indexes = new uint8[](2);
        indexes[0] = 0;
        indexes[1] = 1;
        uint256[] memory rates = new uint256[](2);
        rates[0] = 1 ether;
        rates[1] = 3 ether;

        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        vm.prank(user1);
        uint64 callId0 = tangle.submitJob{ value: 1 ether }(serviceId, 0, "");

        vm.prank(user1);
        uint64 callId1 = tangle.submitJob{ value: 3 ether }(serviceId, 1, "");

        assertEq(tangle.getJobCall(serviceId, callId0).payment, 1 ether);
        assertEq(tangle.getJobCall(serviceId, callId1).payment, 3 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB RFQ: submitJobFromQuote
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SubmitJobFromQuote_SingleOperator() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 1 ether);
        assertTrue(job.isRFQ);
        assertFalse(job.completed);

        // Verify quoted operators recorded
        address[] memory quotedOps = tangle.getJobQuotedOperators(serviceId, callId);
        assertEq(quotedOps.length, 1);
        assertEq(tangle.getJobQuotedPrice(serviceId, callId, operator1), 1 ether);
    }

    function test_SubmitJobFromQuote_MultiOperator() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, 2 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 3 ether }(serviceId, 0, "", quotes);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 3 ether);
        assertTrue(job.isRFQ);

        address[] memory quotedOps = tangle.getJobQuotedOperators(serviceId, callId);
        assertEq(quotedOps.length, 2);
        assertEq(tangle.getJobQuotedPrice(serviceId, callId, operator1), 1 ether);
        assertEq(tangle.getJobQuotedPrice(serviceId, callId, operator2), 2 ether);
    }

    function test_SubmitJobFromQuote_RevertNoQuotes() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](0);

        vm.prank(user1);
        vm.expectRevert(Errors.NoQuotes.selector);
        tangle.submitJobFromQuote(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertServiceMismatch() public {
        // Create a quote for a different service
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, 999, 0, 1 ether); // Wrong serviceId

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.JobQuoteServiceMismatch.selector, serviceId, 999));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertJobIndexMismatch() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 1, 1 ether); // Wrong jobIndex

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.JobQuoteJobIndexMismatch.selector, 0, 1));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertDuplicateOperator() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        quotes[1] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 2 ether);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.DuplicateOperatorQuote.selector, operator1));
        tangle.submitJobFromQuote{ value: 3 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertOperatorNotInService() public {
        // operator3 is registered for blueprint but not in this service
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator3, OPERATOR3_PK, serviceId, 0, 1 ether);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotInService.selector, serviceId, operator3));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertExpiredQuote() public {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: serviceId,
            jobIndex: 0,
            price: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp - 1) // Already expired
        });

        bytes memory signature = _signJobQuote(details, OPERATOR1_PK);
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = Types.SignedJobQuote({ details: details, signature: signature, operator: operator1 });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteExpired.selector, operator1, details.expiry));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertInvalidSignature() public {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: serviceId,
            jobIndex: 0,
            price: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours)
        });

        // Sign with wrong key
        bytes memory wrongSig = _signJobQuote(details, OPERATOR2_PK);
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = Types.SignedJobQuote({ details: details, signature: wrongSig, operator: operator1 });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidQuoteSignature.selector, operator1));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertReplayAttack() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        // First submission succeeds
        vm.prank(user1);
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);

        // Replay fails
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteAlreadyUsed.selector, operator1));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertInsufficientPayment() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 2 ether);

        vm.prank(user1);
        vm.expectRevert(); // InsufficientPayment
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_RevertNotPermittedCaller() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        vm.prank(user2); // Not a permitted caller
        vm.expectRevert(abi.encodeWithSelector(Errors.NotPermittedCaller.selector, serviceId, user2));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RFQ RESULT ENFORCEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RFQJob_QuotedOperatorCanSubmitResult() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);

        // Quoted operator can submit
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed);
    }

    function test_RFQJob_NonQuotedOperatorCannotSubmitResult() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);

        // operator2 is in the service but NOT quoted — should revert
        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotQuotedOperator.selector, serviceId, callId));
        tangle.submitResult(serviceId, callId, "result");
    }

    function test_RFQJob_MultiQuoteOperatorsCanBothSubmit() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, 2 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 3 ether }(serviceId, 0, "", quotes);

        // Both quoted operators can submit
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result1");

        // Job should complete after first result (default required count = 1)
        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed);
    }

    function test_NonRFQJob_AnyServiceOperatorCanSubmit() public {
        // Normal (non-RFQ) job — any service operator can submit
        vm.prank(user1);
        uint64 callId = tangle.submitJob{ value: 0.5 ether }(serviceId, 0, "");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertFalse(job.isRFQ);

        // operator2 can submit to non-RFQ job
        vm.prank(operator2);
        tangle.submitResult(serviceId, callId, "result");

        job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_SetJobEventRates_AnyValidIndex(uint8 jobIndex) public {
        // Blueprint has DEFAULT_JOB_COUNT (8) jobs
        vm.assume(jobIndex < 8);

        uint8[] memory indexes = new uint8[](1);
        indexes[0] = jobIndex;
        uint256[] memory rates = new uint256[](1);
        rates[0] = 1 ether;

        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        assertEq(tangle.getJobEventRate(blueprintId, jobIndex), 1 ether);
    }

    function testFuzz_SubmitJobFromQuote_VariablePricing(uint128 price) public {
        vm.assume(price >= 100 && price < 50 ether); // min 100 wei (PaymentLib minimum)

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, price);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: price }(serviceId, 0, "", quotes);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, price);
        assertTrue(job.isRFQ);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SubmitJobFromQuote_ZeroPriceQuote() public {
        // Operator prices job at 0 — should still work (free job via RFQ)
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 0 }(serviceId, 0, "", quotes);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 0);
        assertTrue(job.isRFQ);
    }

    function test_SubmitJobFromQuote_ExactPaymentRequired() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        uint256 balBefore = user1.balance;

        // Send exact amount
        vm.prank(user1);
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);

        assertEq(user1.balance, balBefore - 1 ether);
    }

    function test_SubmitJobFromQuote_QuoteExpiresAtExactBlockTimestamp() public {
        // Quote with expiry == block.timestamp is still valid (check is >)
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: serviceId,
            jobIndex: 0,
            price: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp) // expiry == now — still valid
        });

        bytes memory signature = _signJobQuote(details, OPERATOR1_PK);
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = Types.SignedJobQuote({ details: details, signature: signature, operator: operator1 });

        // Should succeed since expiry == block.timestamp is not expired
        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 1 ether);
        assertTrue(job.isRFQ);
    }

    function test_SubmitJobFromQuote_QuoteExpiredByOneSecond() public {
        // Quote with expiry 1 second before block.timestamp IS expired
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: serviceId,
            jobIndex: 0,
            price: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp - 1)
        });

        bytes memory signature = _signJobQuote(details, OPERATOR1_PK);
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = Types.SignedJobQuote({ details: details, signature: signature, operator: operator1 });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteExpired.selector, operator1, details.expiry));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_SubmitJobFromQuote_MultiOperatorPaymentDistribution() public {
        // Two operators with different prices: verify both get paid after job completion
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, 2 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 3 ether }(serviceId, 0, "", quotes);

        // Complete the job
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result1");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed);
        // 3 ether was collected and distributed
        assertEq(job.payment, 3 ether);
    }

    function test_SubmitJobFromQuote_ServiceNotActive_Reverts() public {
        // Terminate the service (user1 is the service owner)
        vm.prank(user1);
        tangle.terminateService(serviceId);

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceNotActive.selector, serviceId));
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_RFQJob_PerJobRateDoesNotAffectRFQPrice() public {
        // Set per-job rate to 5 ether, but RFQ quote says 1 ether — RFQ uses quote price
        uint8[] memory indexes = new uint8[](1);
        indexes[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = 5 ether;

        vm.prank(developer);
        tangle.setJobEventRates(blueprintId, indexes, rates);

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);

        // RFQ uses the quoted price, not the per-job rate
        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 1 ether);
    }

    function test_RFQJob_QuotedOperatorsViewAfterCompletion() public {
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](2);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        quotes[1] = _createJobQuote(operator2, OPERATOR2_PK, serviceId, 0, 2 ether);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 3 ether }(serviceId, 0, "", quotes);

        // Complete
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "done");

        // Quoted operators should still be queryable after completion
        address[] memory ops = tangle.getJobQuotedOperators(serviceId, callId);
        assertEq(ops.length, 2);
        assertEq(tangle.getJobQuotedPrice(serviceId, callId, operator1), 1 ether);
        assertEq(tangle.getJobQuotedPrice(serviceId, callId, operator2), 2 ether);
    }

    function testFuzz_SubmitJobFromQuote_LargePrice(uint128 rawPrice) public {
        // Test with very large prices (up to ~3.4 × 10^38 wei)
        uint256 price = uint256(rawPrice);
        vm.assume(price >= 100); // PaymentLib minimum
        vm.assume(price <= 1000 ether); // Stay within deal balance

        vm.deal(user1, price);

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, price);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: price }(serviceId, 0, "", quotes);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, price);
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
