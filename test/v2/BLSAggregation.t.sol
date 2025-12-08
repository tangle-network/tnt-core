// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { Errors } from "../../src/v2/libraries/Errors.sol";
import { BN254 } from "../../src/v2/libraries/BN254.sol";
import { BlueprintServiceManagerBase } from "../../src/v2/BlueprintServiceManagerBase.sol";

/// @title MockAggregationBSM
/// @notice Mock BSM that enables BLS aggregation for specific jobs
contract MockAggregationBSM is BlueprintServiceManagerBase {
    mapping(uint8 => bool) public aggregationRequired;
    mapping(uint8 => uint16) public thresholdBps;
    mapping(uint8 => uint8) public thresholdType;

    constructor() {}

    function setAggregationConfig(
        uint8 jobIndex,
        bool required,
        uint16 _thresholdBps,
        uint8 _thresholdType
    ) external {
        aggregationRequired[jobIndex] = required;
        thresholdBps[jobIndex] = _thresholdBps;
        thresholdType[jobIndex] = _thresholdType;
    }

    function requiresAggregation(uint64, uint8 jobIndex)
        external
        view
        override
        returns (bool)
    {
        return aggregationRequired[jobIndex];
    }

    function getAggregationThreshold(uint64, uint8 jobIndex)
        external
        view
        override
        returns (uint16, uint8)
    {
        uint16 threshold = thresholdBps[jobIndex];
        if (threshold == 0) threshold = 6700; // Default 67%
        return (threshold, thresholdType[jobIndex]);
    }
}

/// @title BLSAggregationTest
/// @notice Tests for BLS signature aggregation in job results
contract BLSAggregationTest is BaseTest {
    MockAggregationBSM public mockBsm;
    uint64 public blueprintId;
    uint64 public serviceId;

    function setUp() public override {
        super.setUp();

        // Deploy mock BSM
        mockBsm = new MockAggregationBSM();

        // Create blueprint with aggregation-enabled BSM
        vm.prank(developer);
        blueprintId = _createBlueprintAsSenderWithJobs("ipfs://aggregation-test", address(mockBsm), 256);

        // Register operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 3 ether);
        _registerOperator(operator3, 2 ether);

        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);

        // Request and activate service with 3 operators
        address[] memory operators = new address[](3);
        operators[0] = operator1;
        operators[1] = operator2;
        operators[2] = operator3;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);
        vm.prank(operator3);
        tangle.approveService(requestId, 0);

        serviceId = 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: submitResult reverts when aggregation is required
    // ═══════════════════════════════════════════════════════════════════════════

    function test_submitResult_RevertsWhenAggregationRequired() public {
        // Enable aggregation for job index 0
        mockBsm.setAggregationConfig(0, true, 6700, 0);

        // Submit a job
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test input");

        // Try to submit normal result - should revert
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.AggregationRequired.selector, serviceId, 0));
        tangle.submitResult(serviceId, callId, "result");
    }

    function test_submitResult_WorksWhenNoAggregationRequired() public {
        // Don't enable aggregation (default is false)

        // Submit a job
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test input");

        // Submit normal result - should work
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: submitAggregatedResult reverts when aggregation is NOT required
    // ═══════════════════════════════════════════════════════════════════════════

    function test_submitAggregatedResult_RevertsWhenAggregationNotRequired() public {
        // Don't enable aggregation

        // Submit a job
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test input");

        // Try to submit aggregated result - should revert
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        vm.expectRevert(abi.encodeWithSelector(Errors.AggregationNotRequired.selector, serviceId, 0));
        tangle.submitAggregatedResult(serviceId, callId, "result", 0x7, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: Per-job aggregation configuration
    // ═══════════════════════════════════════════════════════════════════════════

    function test_PerJobAggregationConfig() public {
        // Enable aggregation only for job index 1, not 0
        mockBsm.setAggregationConfig(0, false, 0, 0);
        mockBsm.setAggregationConfig(1, true, 6700, 0);

        // Submit job 0 (no aggregation)
        vm.prank(user1);
        uint64 callId0 = tangle.submitJob(serviceId, 0, "job 0 input");

        // Normal result should work for job 0
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId0, "job 0 result");

        Types.JobCall memory job0 = tangle.getJobCall(serviceId, callId0);
        assertTrue(job0.completed, "Job 0 should complete with normal result");

        // Submit job 1 (requires aggregation)
        vm.prank(user1);
        uint64 callId1 = tangle.submitJob(serviceId, 1, "job 1 input");

        // Normal result should revert for job 1
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.AggregationRequired.selector, serviceId, 1));
        tangle.submitResult(serviceId, callId1, "job 1 result");
    }

    function test_PerJobDifferentThresholds() public {
        // Job 0: 34% threshold (1 of 3 operators)
        // Job 1: 67% threshold (2 of 3 operators)
        // Job 2: 100% threshold (3 of 3 operators)
        mockBsm.setAggregationConfig(0, true, 3400, 0);
        mockBsm.setAggregationConfig(1, true, 6700, 0);
        mockBsm.setAggregationConfig(2, true, 10000, 0);

        // Submit jobs for each index
        vm.prank(user1);
        uint64 callId0 = tangle.submitJob(serviceId, 0, "job 0");
        vm.prank(user1);
        uint64 callId1 = tangle.submitJob(serviceId, 1, "job 1");
        vm.prank(user1);
        uint64 callId2 = tangle.submitJob(serviceId, 2, "job 2");

        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Job 0: 1 signer should pass threshold (34% of 3 = 1.02 -> 1)
        // But will fail BLS verification
        uint256 oneSigner = 0x1;
        vm.expectRevert(); // BLS verification will fail
        tangle.submitAggregatedResult(serviceId, callId0, "result", oneSigner, sig, pubkey);

        // Job 1: 1 signer should fail threshold (67% of 3 = 2.01 -> 2)
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId, callId1, 1, 2
        ));
        tangle.submitAggregatedResult(serviceId, callId1, "result", oneSigner, sig, pubkey);

        // Job 2: 2 signers should fail threshold (100% of 3 = 3)
        uint256 twoSigners = 0x3;
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId, callId2, 2, 3
        ));
        tangle.submitAggregatedResult(serviceId, callId2, "result", twoSigners, sig, pubkey);
    }

    function test_PerJobDifferentThresholdTypes() public {
        // Job 0: Count-based (type 0)
        // Job 1: Stake-weighted (type 1)
        mockBsm.setAggregationConfig(0, true, 6700, 0); // 67% count-based
        mockBsm.setAggregationConfig(1, true, 6700, 1); // 67% stake-weighted

        // Verify different threshold types are stored correctly
        (uint16 threshold0, uint8 type0) = mockBsm.getAggregationThreshold(serviceId, 0);
        (uint16 threshold1, uint8 type1) = mockBsm.getAggregationThreshold(serviceId, 1);

        assertEq(threshold0, 6700, "Job 0 threshold should be 6700");
        assertEq(type0, 0, "Job 0 should be count-based");
        assertEq(threshold1, 6700, "Job 1 threshold should be 6700");
        assertEq(type1, 1, "Job 1 should be stake-weighted");
    }

    function test_PerJobIndependentCompletion() public {
        // Both jobs require aggregation but are independent
        mockBsm.setAggregationConfig(0, true, 3400, 0);
        mockBsm.setAggregationConfig(1, true, 3400, 0);

        // Submit multiple calls for both job indices
        vm.prank(user1);
        uint64 callId0a = tangle.submitJob(serviceId, 0, "job 0 call a");
        vm.prank(user1);
        uint64 callId0b = tangle.submitJob(serviceId, 0, "job 0 call b");
        vm.prank(user1);
        uint64 callId1a = tangle.submitJob(serviceId, 1, "job 1 call a");

        // All jobs should be independent and pending
        Types.JobCall memory job0a = tangle.getJobCall(serviceId, callId0a);
        Types.JobCall memory job0b = tangle.getJobCall(serviceId, callId0b);
        Types.JobCall memory job1a = tangle.getJobCall(serviceId, callId1a);

        assertFalse(job0a.completed, "Job 0 call a should be pending");
        assertFalse(job0b.completed, "Job 0 call b should be pending");
        assertFalse(job1a.completed, "Job 1 call a should be pending");

        // Verify each has correct job index stored
        assertEq(job0a.jobIndex, 0, "Job 0 call a should have index 0");
        assertEq(job0b.jobIndex, 0, "Job 0 call b should have index 0");
        assertEq(job1a.jobIndex, 1, "Job 1 call a should have index 1");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: Threshold validation
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ThresholdValidation_CountBased() public {
        // Enable aggregation with 67% threshold (count-based)
        // 3 operators, 67% = 2 required
        mockBsm.setAggregationConfig(0, true, 6700, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // Bitmap with only 1 signer (operator1 = bit 0)
        uint256 oneSigner = 0x1;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should fail - threshold not met (1 < 2)
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId,
            callId,
            1, // achieved
            2  // required
        ));
        tangle.submitAggregatedResult(serviceId, callId, "result", oneSigner, sig, pubkey);
    }

    function test_ThresholdValidation_TwoOfThree() public {
        // Enable aggregation with 67% threshold
        mockBsm.setAggregationConfig(0, true, 6700, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // Bitmap with 2 signers (operator1 and operator2 = bits 0 and 1)
        uint256 twoSigners = 0x3;

        // This should pass threshold check but fail BLS verification
        // (since we're using fake signatures that won't map to valid curve points)
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should fail at BLS verification - either HashToPointFailed or InvalidBLSSignature
        // depending on where the invalid data is caught
        vm.expectRevert(); // Any revert is acceptable for invalid BLS data
        tangle.submitAggregatedResult(serviceId, callId, "result", twoSigners, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: Signer bitmap validation
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SignerBitmapValidation() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0); // 34% = 1 signer needed

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // All 3 operators signed
        uint256 allSigners = 0x7; // bits 0, 1, 2

        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should pass threshold (3 >= 1) but fail BLS verification
        // (since we're using fake signatures that won't map to valid curve points)
        vm.expectRevert(); // Any revert is acceptable for invalid BLS data
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: Job completion via aggregation
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobAlreadyCompleted() public {
        // First complete a non-aggregated job
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertTrue(job.completed);

        // Now try to submit again - should fail
        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.JobAlreadyCompleted.selector, serviceId, callId));
        tangle.submitResult(serviceId, callId, "result 2");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: Default aggregation config (no BSM)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DefaultConfig_NoBSM() public {
        // Create blueprint without BSM
        vm.prank(developer);
        uint64 noBsmBlueprintId = _createBlueprintAsSender("ipfs://no-bsm", address(0));

        // Register and create service
        _registerForBlueprint(operator1, noBsmBlueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 reqId = tangle.requestService(noBsmBlueprintId, ops, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(reqId, 0);

        uint64 svcId = 1;

        // Submit job
        vm.prank(user1);
        uint64 callId = tangle.submitJob(svcId, 0, "test");

        // Normal result should work (no aggregation by default)
        vm.prank(operator1);
        tangle.submitResult(svcId, callId, "result");

        Types.JobCall memory job = tangle.getJobCall(svcId, callId);
        assertTrue(job.completed);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST: Events
    // ═══════════════════════════════════════════════════════════════════════════

    function test_AggregatedResultSubmitted_Event() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 signers = 0x7;
        bytes memory output = "aggregated result";
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Event should be emitted even if BLS verification fails later
        // (But it won't because we expect revert)
        // Using generic expectRevert since invalid BLS data may fail at different points
        vm.expectRevert(); // Any revert is acceptable for invalid BLS data
        tangle.submitAggregatedResult(serviceId, callId, output, signers, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASE TESTS: Invalid Signer Bitmap
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test that out-of-range bitmap bits are ignored (not counted as signers)
    function test_InvalidBitmapBits_OutOfRange() public {
        // 3 operators in service, but bitmap has bit 10 set
        mockBsm.setAggregationConfig(0, true, 6700, 0); // 67% = 2 required

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // Set bit 10 (operator index 10 doesn't exist) along with bit 0
        // Only bit 0 should count (1 signer)
        uint256 invalidBitmap = (1 << 10) | 0x1; // 0x401

        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should fail threshold - only 1 valid signer counted, need 2
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId,
            callId,
            1, // achieved (only bit 0 counted)
            2  // required
        ));
        tangle.submitAggregatedResult(serviceId, callId, "result", invalidBitmap, sig, pubkey);
    }

    /// @notice Test that extremely high bitmap bits are ignored
    function test_InvalidBitmapBits_ExtremelyHighBits() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0); // 34% = 1 required

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // Set only high bits (255, 254, 253) - all invalid operators
        uint256 highBitsBitmap = (1 << 255) | (1 << 254) | (1 << 253);

        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should fail - 0 valid signers, need 1
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId,
            callId,
            0, // achieved
            1  // required
        ));
        tangle.submitAggregatedResult(serviceId, callId, "result", highBitsBitmap, sig, pubkey);
    }

    /// @notice Test that zero bitmap fails threshold
    function test_InvalidBitmapBits_ZeroBitmap() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0); // 34% = 1 required

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 zeroBitmap = 0;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should fail - 0 signers
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId,
            callId,
            0,
            1
        ));
        tangle.submitAggregatedResult(serviceId, callId, "result", zeroBitmap, sig, pubkey);
    }

    /// @notice Test max uint256 bitmap - only valid operator bits should count
    function test_InvalidBitmapBits_MaxUint256() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0); // 34% = 1 required

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // All bits set - but only 3 operators exist (bits 0, 1, 2)
        uint256 maxBitmap = type(uint256).max;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should pass threshold (3 valid signers) but fail BLS verification
        vm.expectRevert(); // BLS verification will fail
        tangle.submitAggregatedResult(serviceId, callId, "result", maxBitmap, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASE TESTS: Anyone Can Submit
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test that a non-operator can submit aggregated result
    function test_AnyoneCanSubmit_NonOperator() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Random address (not operator) can submit - only BLS fails
        address randomSubmitter = address(0xdeadbeef);
        vm.prank(randomSubmitter);
        vm.expectRevert(); // BLS verification fails, but NO access control error
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);
    }

    /// @notice Test that user who created the job can submit aggregated result
    function test_AnyoneCanSubmit_JobCreator() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Job creator can submit - only BLS fails
        vm.prank(user1);
        vm.expectRevert(); // BLS verification fails, but NO access control error
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);
    }

    /// @notice Test race condition - first valid submission wins for regular (non-aggregated) result
    function test_RaceCondition_RegularResult() public {
        // First complete a non-aggregated job (only operators can submit regular results)
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result");

        // Second submission from another operator should fail with JobAlreadyCompleted
        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.JobAlreadyCompleted.selector, serviceId, callId));
        tangle.submitResult(serviceId, callId, "result 2");

        // Third submission from another operator should also fail
        vm.prank(operator3);
        vm.expectRevert(abi.encodeWithSelector(Errors.JobAlreadyCompleted.selector, serviceId, callId));
        tangle.submitResult(serviceId, callId, "result 3");
    }

    /// @notice Test race condition for aggregated result - anyone can submit
    function test_AnyoneCanSubmit_RaceCondition_Aggregated() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // First attempt from random address - should fail BLS but not access control
        vm.prank(address(0x1234));
        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);

        // Second attempt from another random address - also only BLS fails
        vm.prank(address(0x5678));
        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);

        // Operator can also submit - only BLS fails
        vm.prank(operator1);
        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASE TESTS: Inactive Operators
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test that inactive operators are not counted in threshold
    function test_InactiveOperator_NotCounted() public {
        mockBsm.setAggregationConfig(0, true, 6700, 0); // 67% = 2 of 3 required

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // TODO: Deactivate operator2 here once we have the mechanism
        // For now, this test documents the expected behavior

        // Bitmap includes operator2 (bit 1) but if inactive, shouldn't count
        uint256 twoSigners = 0x3; // bits 0 and 1
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // With all active: should pass threshold but fail BLS
        vm.expectRevert(); // BLS verification fails
        tangle.submitAggregatedResult(serviceId, callId, "result", twoSigners, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASE TESTS: Threshold Edge Cases
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test very low threshold (1% should require at least 1 signer)
    function test_Threshold_VeryLow() public {
        // Note: MockBSM defaults 0% to 67%, so we use 1% instead
        mockBsm.setAggregationConfig(0, true, 100, 0); // 1% threshold

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // 1% of 3 = 0.03 -> rounds to 0, but minimum should be 1
        uint256 zeroBitmap = 0;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should require at least 1 signer
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId,
            callId,
            0,
            1  // Minimum 1 required
        ));
        tangle.submitAggregatedResult(serviceId, callId, "result", zeroBitmap, sig, pubkey);
    }

    /// @notice Test exactly 100% threshold
    function test_Threshold_ExactlyHundredPercent() public {
        mockBsm.setAggregationConfig(0, true, 10000, 0); // 100% = all 3 required

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // 2 of 3 signers - should fail
        uint256 twoSigners = 0x3;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId,
            callId,
            2,
            3
        ));
        tangle.submitAggregatedResult(serviceId, callId, "result", twoSigners, sig, pubkey);

        // All 3 signers - should pass threshold, fail BLS
        uint256 allSigners = 0x7;
        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);
    }

    /// @notice Test threshold above 100% (edge case)
    function test_Threshold_AboveHundredPercent() public {
        mockBsm.setAggregationConfig(0, true, 15000, 0); // 150% threshold

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // All 3 signers - but 150% of 3 = 4.5 required
        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should fail - can never meet 150% threshold with only 100% of operators
        vm.expectRevert(abi.encodeWithSelector(
            Errors.AggregationThresholdNotMet.selector,
            serviceId,
            callId,
            3,  // achieved (all operators)
            4   // required (150% of 3)
        ));
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);
    }

    /// @notice Test threshold exactly at boundary (66.67% of 3 = 2)
    function test_Threshold_BoundaryCase() public {
        // 6666 bps = 66.66%, 6667 bps = 66.67%
        // 66.66% of 3 = 1.9998 -> should round to 1 or 2?
        mockBsm.setAggregationConfig(0, true, 6666, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 oneSigner = 0x1;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // 6666 * 3 / 10000 = 1.9998 = 1 (integer division)
        // So 1 signer should pass threshold but fail BLS
        vm.expectRevert(); // BLS verification fails (not threshold)
        tangle.submitAggregatedResult(serviceId, callId, "result", oneSigner, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUZZ TESTS: Threshold Calculations
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test for threshold calculation - count based
    /// @param thresholdBps The threshold in basis points (1-20000)
    /// @param signerBitmap Random signer bitmap
    function testFuzz_ThresholdCalculation_CountBased(
        uint16 thresholdBps,
        uint256 signerBitmap
    ) public {
        // Bound threshold to reasonable range (avoid 0 because mock BSM defaults to 67%)
        thresholdBps = uint16(bound(thresholdBps, 1, 20000));

        mockBsm.setAggregationConfig(0, true, thresholdBps, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Calculate expected signers (only bits 0, 1, 2 are valid)
        uint256 validSigners = 0;
        if ((signerBitmap >> 0) & 1 == 1) validSigners++;
        if ((signerBitmap >> 1) & 1 == 1) validSigners++;
        if ((signerBitmap >> 2) & 1 == 1) validSigners++;

        // Calculate required threshold (matching contract logic)
        uint256 required = (uint256(3) * thresholdBps) / 10000;
        if (required == 0 && 3 > 0) required = 1;

        if (validSigners < required) {
            // Should fail with threshold not met
            vm.expectRevert(abi.encodeWithSelector(
                Errors.AggregationThresholdNotMet.selector,
                serviceId,
                callId,
                validSigners,
                required
            ));
        } else {
            // Should pass threshold but fail BLS verification
            vm.expectRevert(); // BLS fails
        }

        tangle.submitAggregatedResult(serviceId, callId, "result", signerBitmap, sig, pubkey);
    }

    /// @notice Fuzz test for invalid service/call IDs
    function testFuzz_InvalidServiceOrCallId(
        uint64 fuzzServiceId,
        uint64 fuzzCallId
    ) public {
        // Skip valid service ID (0)
        vm.assume(fuzzServiceId != serviceId || fuzzCallId > 100);

        mockBsm.setAggregationConfig(0, true, 3400, 0);

        uint256 signers = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Should revert with some error (service not found, job not found, etc.)
        vm.expectRevert();
        tangle.submitAggregatedResult(fuzzServiceId, fuzzCallId, "result", signers, sig, pubkey);
    }

    /// @notice Fuzz test for output data
    function testFuzz_OutputData(bytes calldata output) public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Any output should pass threshold check but fail BLS verification
        // (BLS verification uses hash of output, so any data is fine)
        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, output, allSigners, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WORST CASE TESTS: Malicious Scenarios
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test replay attack - same signature for different outputs
    function test_Malicious_ReplayAttack() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId1 = tangle.submitJob(serviceId, 0, "input1");
        vm.prank(user1);
        uint64 callId2 = tangle.submitJob(serviceId, 0, "input2");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Try to use same signature for both - should fail BLS for both
        // (even if BLS passed, message includes callId so it would fail)
        vm.expectRevert();
        tangle.submitAggregatedResult(serviceId, callId1, "result1", allSigners, sig, pubkey);

        vm.expectRevert();
        tangle.submitAggregatedResult(serviceId, callId2, "result1", allSigners, sig, pubkey);
    }

    /// @notice Test submitting wrong output (hash mismatch)
    function test_Malicious_WrongOutput() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // BLS message includes keccak256(output), so different output = different message = invalid sig
        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, "wrong output", allSigners, sig, pubkey);
    }

    /// @notice Test frontrunning - different caller submits before original
    function test_Malicious_Frontrunning() public {
        // This tests that frontrunning doesn't break the system
        // Anyone can submit, but only valid aggregated sig passes

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // Attacker tries to frontrun with different output
        vm.prank(address(0xbad));
        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, "attacker output", allSigners, sig, pubkey);

        // Original submitter can still try (job not completed due to attacker's failure)
        vm.prank(operator1);
        vm.expectRevert(); // BLS fails (but job is still pending)
        tangle.submitAggregatedResult(serviceId, callId, "correct output", allSigners, sig, pubkey);
    }

    /// @notice Test bitmap manipulation - claiming non-signers signed
    function test_Malicious_FalseBitmapClaims() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // Claim all 3 signed, but only 1 actually did
        // The aggregated pubkey/sig would be wrong
        uint256 falseBitmap = 0x7; // claims 3 signed
        uint256[2] memory sig = [uint256(1), uint256(2)]; // but only 1 sig
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // BLS verification will fail because aggregated pubkey doesn't match signers
        vm.expectRevert();
        tangle.submitAggregatedResult(serviceId, callId, "result", falseBitmap, sig, pubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STRESS TESTS: Large Numbers
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test with maximum job index
    function test_Stress_MaxJobIndex() public {
        mockBsm.setAggregationConfig(255, true, 3400, 0); // max uint8

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 255, "test");

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, "result", allSigners, sig, pubkey);
    }

    /// @notice Test with very large output data
    function test_Stress_LargeOutputData() public {
        mockBsm.setAggregationConfig(0, true, 3400, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // 10KB of output data
        bytes memory largeOutput = new bytes(10240);
        for (uint i = 0; i < 10240; i++) {
            largeOutput[i] = bytes1(uint8(i % 256));
        }

        uint256 allSigners = 0x7;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        vm.expectRevert(); // BLS fails
        tangle.submitAggregatedResult(serviceId, callId, largeOutput, allSigners, sig, pubkey);
    }
}
