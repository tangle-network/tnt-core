// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";

/// @title TeeCommitmentHardenTest
/// @notice Adversarial coverage proving the hardening fixes from
///         `.evolve/harden/2026-05-04-report.md` actually hold:
///
///         T1 — `nonceBinding` is request-derived; replay across requests is
///              rejected at approval.
///         T2 — Activation gas with multiple operators × commitment cap is
///              measured (no fix, this is a documented system-design bound).
///         T4 — `expiresAt` cannot exceed `MAX_TEE_COMMITMENT_TTL`; far-future
///              and unbounded values are rejected.
contract TeeCommitmentHardenTest is BaseTest {
    uint64 internal blueprintId;

    bytes32 internal constant MEASUREMENT_NITRO = keccak256("measurement-nitro");
    uint64 internal constant TTL_CAP = 90 days; // matches ServicesApprovals.MAX_TEE_COMMITMENT_TTL

    function setUp() public override {
        super.setUp();
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://harden", address(0)));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, blueprintId);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator3, blueprintId);
    }

    function _zeroBls() internal pure returns (uint256[4] memory pk, uint256[2] memory sig) { }

    function _commitment(
        Types.TeeBackend backend,
        bytes32 measurement,
        bytes32 nonce,
        uint64 expiresAt
    )
        internal
        pure
        returns (Types.TeeAttestationCommitment memory)
    {
        return Types.TeeAttestationCommitment({
            backend: backend, expectedMeasurement: measurement, nonceBinding: nonce, expiresAt: expiresAt
        });
    }

    function _requestSingleOperator(address op) internal returns (uint64 requestId) {
        address[] memory ops = new address[](1);
        ops[0] = op;
        vm.prank(user1);
        requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.TeeRequired
        );
    }

    // ───────────────────────────────────────────────────────────────────────
    // T1 — `nonceBinding` is request-derived; cross-request replay rejected
    // ───────────────────────────────────────────────────────────────────────

    /// @notice PROOF: a commitment carrying request A's nonce cannot be reused
    ///         on request B. The contract derives the canonical nonce from
    ///         requestId at validation time and rejects any other value.
    function test_T1_replayAcrossRequests_rejected() public {
        uint64 requestA = _requestSingleOperator(operator1);
        bytes32 nonceA = tangle.teeNonceFor(requestA);

        Types.AssetSecurityCommitment[] memory empty = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeA = new Types.TeeAttestationCommitment[](1);
        teeA[0] = _commitment(Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, nonceA, 0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        // Approve request A — nonce matches, accepted.
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestA, empty, pk, sig, teeA);

        // Attempt to replay nonce A on request B — must revert.
        uint64 requestB = _requestSingleOperator(operator1);
        Types.TeeAttestationCommitment[] memory teeReplay = new Types.TeeAttestationCommitment[](1);
        teeReplay[0] = _commitment(Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, nonceA, 0);

        vm.expectRevert(Errors.InvalidNonceBinding.selector);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestB, empty, pk, sig, teeReplay);
    }

    /// @notice PROOF: an arbitrary 32-byte value that isn't the request-derived
    ///         nonce is rejected. Catches operators that fabricate nonces or
    ///         use stale ones from off-chain logs.
    function test_T1_arbitraryNonce_rejected() public {
        uint64 requestId = _requestSingleOperator(operator1);
        bytes32 wrongNonce = keccak256("definitely-not-the-derived-value");

        Types.AssetSecurityCommitment[] memory empty = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = _commitment(Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, wrongNonce, 0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(Errors.InvalidNonceBinding.selector);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, empty, pk, sig, teeCommits);
    }

    /// @notice PROOF: `teeNonceFor` is deterministic and request-unique. Two
    ///         consecutive requests have distinct nonces; the same request
    ///         queried twice returns the same nonce.
    function test_T1_teeNonceFor_uniquePerRequest() public {
        uint64 requestA = _requestSingleOperator(operator1);
        uint64 requestB = _requestSingleOperator(operator1);

        bytes32 nonceA = tangle.teeNonceFor(requestA);
        bytes32 nonceB = tangle.teeNonceFor(requestB);

        assertTrue(nonceA != nonceB, "different requests yield different nonces");
        assertEq(tangle.teeNonceFor(requestA), nonceA, "same request yields same nonce");
        assertTrue(nonceA != bytes32(0), "nonce never zero");
    }

    // ───────────────────────────────────────────────────────────────────────
    // T2 — Activation gas measurement (system-design bound, documented)
    // ───────────────────────────────────────────────────────────────────────

    /// @notice PROOF/MEASUREMENT: the operator who triggers activation pays gas
    ///         linear in (operator_count × commitments_per_operator). With the
    ///         per-operator cap of 8 and 3 operators, the activator pays ~3M
    ///         gas for the TEE persistence layer alone. This is a documented
    ///         operator-economics concern, NOT a contract bug. Logged so the
    ///         number is visible in CI gas-report output.
    function test_T2_activation_gasScalesWithOperatorsTimesCap() public {
        address[] memory ops = new address[](3);
        ops[0] = operator1;
        ops[1] = operator2;
        ops[2] = operator3;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.TeeRequired
        );
        bytes32 nonce = tangle.teeNonceFor(requestId);

        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](8);
        for (uint256 i = 0; i < 8; i++) {
            teeCommits[i] = _commitment(Types.TeeBackend.AwsNitro, keccak256(abi.encode("m", i)), nonce, 0);
        }
        Types.AssetSecurityCommitment[] memory empty = new Types.AssetSecurityCommitment[](0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, empty, pk, sig, teeCommits);
        vm.prank(operator2);
        tangle.approveServiceWithTeeCommitments(requestId, empty, pk, sig, teeCommits);

        uint256 gasStart = gasleft();
        vm.prank(operator3);
        tangle.approveServiceWithTeeCommitments(requestId, empty, pk, sig, teeCommits);
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("T2 activator gas, 3 operators x 8 commits", gasUsed);

        uint64 serviceId = tangle.serviceCount() - 1;
        for (uint256 i = 0; i < 3; i++) {
            assertEq(tangle.getTeeCommitment(serviceId, ops[i]).length, 8, "8 commits per operator persisted");
        }
    }

    // ───────────────────────────────────────────────────────────────────────
    // T4 — `expiresAt` capped at MAX_TEE_COMMITMENT_TTL
    // ───────────────────────────────────────────────────────────────────────

    /// @notice PROOF: `expiresAt = type(uint64).max` is rejected — no commitment
    ///         can effectively be never-expiring.
    function test_T4_uint64Max_rejected() public {
        uint64 requestId = _requestSingleOperator(operator1);
        bytes32 nonce = tangle.teeNonceFor(requestId);

        Types.AssetSecurityCommitment[] memory empty = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = _commitment(Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, nonce, type(uint64).max);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(); // TeeCommitmentExpiryTooFar with computed bounds
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, empty, pk, sig, teeCommits);
    }

    /// @notice PROOF: 91-day expiry is rejected (one day past the cap).
    function test_T4_oneDayPastCap_rejected() public {
        vm.warp(1_000_000_000); // realistic clock so subtraction is safe
        uint64 requestId = _requestSingleOperator(operator1);
        bytes32 nonce = tangle.teeNonceFor(requestId);

        Types.AssetSecurityCommitment[] memory empty = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        uint64 tooFar = uint64(block.timestamp) + TTL_CAP + 1 days;
        teeCommits[0] = _commitment(Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, nonce, tooFar);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        uint64 maxAllowed = uint64(block.timestamp) + TTL_CAP;
        vm.expectRevert(abi.encodeWithSelector(Errors.TeeCommitmentExpiryTooFar.selector, tooFar, maxAllowed));
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, empty, pk, sig, teeCommits);
    }

    /// @notice PROOF: exactly-at-cap (`now + 90 days`) is accepted; one-second-
    ///         past-cap is rejected. Boundary is precise.
    function test_T4_exactlyAtCap_accepted_oneSecondPast_rejected() public {
        vm.warp(1_000_000_000);

        // Accepted at exactly the cap.
        uint64 requestA = _requestSingleOperator(operator1);
        bytes32 nonceA = tangle.teeNonceFor(requestA);
        Types.TeeAttestationCommitment[] memory teeAccept = new Types.TeeAttestationCommitment[](1);
        teeAccept[0] =
            _commitment(Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, nonceA, uint64(block.timestamp) + TTL_CAP);
        Types.AssetSecurityCommitment[] memory empty = new Types.AssetSecurityCommitment[](0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestA, empty, pk, sig, teeAccept);

        // Rejected at cap + 1 second.
        uint64 requestB = _requestSingleOperator(operator1);
        bytes32 nonceB = tangle.teeNonceFor(requestB);
        Types.TeeAttestationCommitment[] memory teeReject = new Types.TeeAttestationCommitment[](1);
        uint64 oneSecondPast = uint64(block.timestamp) + TTL_CAP + 1;
        teeReject[0] = _commitment(Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, nonceB, oneSecondPast);

        uint64 maxAllowed = uint64(block.timestamp) + TTL_CAP;
        vm.expectRevert(abi.encodeWithSelector(Errors.TeeCommitmentExpiryTooFar.selector, oneSecondPast, maxAllowed));
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestB, empty, pk, sig, teeReject);
    }
}
