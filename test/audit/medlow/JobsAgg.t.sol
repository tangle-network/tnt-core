// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { Errors } from "../../../src/libraries/Errors.sol";
import { JobsAggregation } from "../../../src/core/JobsAggregation.sol";
import { BlueprintServiceManagerBase } from "../../../src/BlueprintServiceManagerBase.sol";

/// @title MockAggBSM
/// @notice Minimal BSM that toggles BLS aggregation + threshold per job index.
contract MockAggBSM is BlueprintServiceManagerBase {
    mapping(uint8 => bool) public aggregationRequired;
    mapping(uint8 => uint16) public thresholdBps;
    mapping(uint8 => uint8) public thresholdType;

    function setAggregationConfig(uint8 jobIndex, bool required, uint16 _thresholdBps, uint8 _thresholdType) external {
        aggregationRequired[jobIndex] = required;
        thresholdBps[jobIndex] = _thresholdBps;
        thresholdType[jobIndex] = _thresholdType;
    }

    function requiresAggregation(uint64, uint8 jobIndex) external view override returns (bool) {
        return aggregationRequired[jobIndex];
    }

    function getAggregationThreshold(uint64, uint8 jobIndex) external view override returns (uint16, uint8) {
        uint16 threshold = thresholdBps[jobIndex];
        if (threshold == 0) threshold = 6700;
        return (threshold, thresholdType[jobIndex]);
    }
}

/// @title JobsAggMedLowTest
/// @notice Regression coverage for the medium audit finding:
///         "[business-logic] Aggregated result accepted with empty signer set + zero-sig
///          when no operator is staking-active -> result spoofing".
///
/// Root cause (src/core/JobsAggregation.sol `_validateSignersAndThreshold`): when every
/// service operator is staking-inactive the eligible-operator count is 0, so the required
/// quorum computes to 0 and the downstream `achieved < required` check degenerates to
/// `0 < 0` (false). The call then sails past the threshold gate with an EMPTY signer
/// bitmap and a zero (point-at-infinity) signature, spoofing a completed result and — for
/// EventDriven jobs — drawing payment for work no live operator performed.
///
/// The fix fails closed: a quorum over an empty active-operator set is never satisfiable,
/// so the call reverts with `JobsAggregation.NoActiveOperators` BEFORE any signature path.
contract JobsAggMedLowTest is BaseTest {
    MockAggBSM internal bsm;
    uint64 internal blueprintId;
    uint64 internal serviceId;

    // Single-operator service: slashing this one operator below the minimum self-stake
    // empties the active-operator set entirely (operatorCount == 0), which is the exact
    // precondition the finding exploits.
    function setUp() public override {
        super.setUp();

        bsm = new MockAggBSM();

        vm.prank(developer);
        blueprintId = _createBlueprintAsSenderWithJobs("ipfs://jobs-agg-medlow", address(bsm), 4);

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, operators, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        serviceId = tangle.serviceCount() - 1;
    }

    /// @dev Drive operator1 to staking-inactive the production way: slash 100% of its
    ///      self-stake so it drops below MIN_OPERATOR_STAKE. user1 is the service owner
    ///      and is authorized to propose. After execution the service set has zero
    ///      staking-active operators while the service itself stays Active.
    function _slashOnlyOperatorToInactive() internal {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 10_000, keccak256("op1-fault"));
        vm.warp(block.timestamp + 7 days + 16); // clear the dispute window (DEFAULT_DISPUTE_WINDOW = 7 days)
        tangle.executeSlash(slashId);
        assertFalse(staking.isOperatorActive(operator1), "operator1 should be slashed to inactive");
    }

    // ════════════════════════════════════════════════════════════════════════════
    // SECURE INVARIANT: empty active-operator set => unsatisfiable quorum (fail closed)
    // ════════════════════════════════════════════════════════════════════════════

    /// @notice Count-based threshold. With operatorCount == 0 an empty bitmap + zero
    ///         signature must NOT be accepted. Pre-fix this returned (achieved=0,
    ///         required=0) and `0 < 0` passed, then BLS over the infinity pubkey would
    ///         be the only remaining barrier. The fix reverts at the threshold gate.
    function test_EmptyOperatorSet_CountBased_RevertsNoActiveOperators() public {
        bsm.setAggregationConfig(0, true, 6700, 0); // 67% count-based

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        _slashOnlyOperatorToInactive();

        // Empty bitmap + zero (point-at-infinity) signature & pubkey: the spoof payload.
        uint256 emptyBitmap = 0;
        uint256[2] memory zeroSig = [uint256(0), uint256(0)];
        uint256[4] memory zeroPubkey = [uint256(0), uint256(0), uint256(0), uint256(0)];

        vm.expectRevert(abi.encodeWithSelector(JobsAggregation.NoActiveOperators.selector, serviceId));
        tangle.submitAggregatedResult(serviceId, callId, "spoofed result", emptyBitmap, zeroSig, zeroPubkey);

        // Invariant: the job must remain incomplete — no spoofed completion was recorded.
        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertFalse(job.completed, "job must not be completed by an empty-signer-set submission");
    }

    /// @notice Stake-weighted threshold takes the same fail-closed path: with no active
    ///         operators totalWeight is 0, required is 0, and the unguarded check would
    ///         accept an empty result.
    function test_EmptyOperatorSet_StakeWeighted_RevertsNoActiveOperators() public {
        bsm.setAggregationConfig(0, true, 6700, 1); // 67% stake-weighted

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        _slashOnlyOperatorToInactive();

        uint256 emptyBitmap = 0;
        uint256[2] memory zeroSig = [uint256(0), uint256(0)];
        uint256[4] memory zeroPubkey = [uint256(0), uint256(0), uint256(0), uint256(0)];

        vm.expectRevert(abi.encodeWithSelector(JobsAggregation.NoActiveOperators.selector, serviceId));
        tangle.submitAggregatedResult(serviceId, callId, "spoofed result", emptyBitmap, zeroSig, zeroPubkey);
    }

    /// @notice An attacker may set arbitrary out-of-range bitmap bits and a non-zero
    ///         signature to dodge a naive "empty bitmap" check. The guard keys off the
    ///         active-operator COUNT, not the bitmap, so it still fails closed: with zero
    ///         active operators no bit can ever map to a counted signer.
    function test_EmptyOperatorSet_GarbageBitmap_StillRevertsNoActiveOperators() public {
        bsm.setAggregationConfig(0, true, 6700, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        _slashOnlyOperatorToInactive();

        uint256 garbageBitmap = type(uint256).max; // every bit set, but no active operator backs any
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        vm.expectRevert(abi.encodeWithSelector(JobsAggregation.NoActiveOperators.selector, serviceId));
        tangle.submitAggregatedResult(serviceId, callId, "spoofed result", garbageBitmap, sig, pubkey);
    }

    /// @notice Finalization safety: the finding's concrete impact is a spoofed completion
    ///         that, for EventDriven jobs, would draw payment for nonexistent work. The
    ///         guard reverts in the threshold gate (`_validateSignersAndThreshold`),
    ///         strictly before `_finalizeAggregatedResult` — the function that marks the
    ///         job completed, emits JobCompleted, and runs any EventDriven payment
    ///         distribution. So no completion is recorded and no value can be released.
    function test_EmptyOperatorSet_NoFinalizationReached() public {
        bsm.setAggregationConfig(0, true, 6700, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "job");

        _slashOnlyOperatorToInactive();

        uint256 emptyBitmap = 0;
        uint256[2] memory zeroSig = [uint256(0), uint256(0)];
        uint256[4] memory zeroPubkey = [uint256(0), uint256(0), uint256(0), uint256(0)];

        vm.expectRevert(abi.encodeWithSelector(JobsAggregation.NoActiveOperators.selector, serviceId));
        tangle.submitAggregatedResult(serviceId, callId, "spoofed result", emptyBitmap, zeroSig, zeroPubkey);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertFalse(job.completed, "job must not finalize without a real quorum");
    }

    // ════════════════════════════════════════════════════════════════════════════
    // NON-REGRESSION: the guard must NOT change behavior while operators are active
    // ════════════════════════════════════════════════════════════════════════════

    /// @notice With the operator still active, the legitimate threshold logic is intact:
    ///         a sub-quorum submission fails with the normal AggregationThresholdNotMet
    ///         (not NoActiveOperators), and the new guard is never triggered.
    function test_ActiveOperator_BelowQuorum_StillThresholdNotMet() public {
        bsm.setAggregationConfig(0, true, 6700, 0); // 67% of 1 operator -> 1 required

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        // Empty bitmap with the operator active: achieved 0, required 1 -> threshold error.
        uint256 emptyBitmap = 0;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        vm.expectRevert(
            abi.encodeWithSelector(Errors.AggregationThresholdNotMet.selector, serviceId, callId, 0, 1)
        );
        tangle.submitAggregatedResult(serviceId, callId, "result", emptyBitmap, sig, pubkey);
    }

    /// @notice With the operator active and the bitmap claiming it signed, the call clears
    ///         the threshold gate (1 >= 1) and reaches BLS verification — proving the new
    ///         guard does not over-block a quorum-meeting submission. The fake signature
    ///         then fails BLS (any revert other than NoActiveOperators is acceptable).
    function test_ActiveOperator_MeetsQuorum_ReachesBlsLayer() public {
        bsm.setAggregationConfig(0, true, 6700, 0);

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "test");

        uint256 oneSigner = 0x1;
        uint256[2] memory sig = [uint256(1), uint256(2)];
        uint256[4] memory pubkey = [uint256(1), uint256(2), uint256(3), uint256(4)];

        // The fake BLS data must revert, but NOT with NoActiveOperators: a quorum-meeting
        // submission over an active operator set must clear the threshold gate and reach
        // the signature layer. Capture the revert and assert the selector is not the guard.
        bool reverted;
        bytes4 sel;
        try tangle.submitAggregatedResult(serviceId, callId, "result", oneSigner, sig, pubkey) {
            // unreachable: invalid BLS data always reverts
        } catch (bytes memory reason) {
            reverted = true;
            if (reason.length >= 4) sel = bytes4(reason);
        }
        assertTrue(reverted, "invalid BLS submission should revert");
        assertTrue(
            sel != JobsAggregation.NoActiveOperators.selector,
            "active-operator quorum-meeting submission must not be blocked by NoActiveOperators"
        );
    }
}
