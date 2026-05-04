// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";

/// @title TeeCommitmentApprovalTest
/// @notice Foundry coverage for `approveServiceWithTeeCommitments` + `getTeeCommitment`.
/// @dev Exercises:
///      - Happy path with a single Nitro commitment (BLS pubkey omitted).
///      - DirectTdx rejection at approval.
///      - Past-expiry commitment rejection.
///      - Multiple operators with distinct backends in one quote.
///      - Commitment persistence onto the activated service via `getTeeCommitment`.
contract TeeCommitmentApprovalTest is BaseTest {
    uint64 internal blueprintId;

    bytes32 internal constant MEASUREMENT_NITRO = keccak256("measurement-nitro");
    bytes32 internal constant MEASUREMENT_PHALA = keccak256("measurement-phala");
    bytes32 internal constant MEASUREMENT_GCP = keccak256("measurement-gcp");

    function _nonceFor(uint64 requestId) internal view returns (bytes32) {
        return tangle.teeNonceFor(requestId);
    }

    function setUp() public override {
        super.setUp();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://tee-commitment", address(0)));

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);
    }

    // ─────────────────────────── helpers
    // ───────────────────────────

    function _zeroBls() internal pure returns (uint256[4] memory pk, uint256[2] memory sig) { }

    function _requestSingleOperator(address op) internal returns (uint64 requestId) {
        address[] memory ops = new address[](1);
        ops[0] = op;
        vm.prank(user1);
        requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.TeeRequired
        );
    }

    function _requestThreeOperators() internal returns (uint64 requestId) {
        address[] memory ops = new address[](3);
        ops[0] = operator1;
        ops[1] = operator2;
        ops[2] = operator3;
        vm.prank(user1);
        requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.TeeRequired
        );
    }

    function _teeCommitment(
        uint64 requestId,
        Types.TeeBackend backend,
        bytes32 measurement,
        uint64 expiresAt
    )
        internal
        view
        returns (Types.TeeAttestationCommitment memory)
    {
        return Types.TeeAttestationCommitment({
            backend: backend, expectedMeasurement: measurement, nonceBinding: _nonceFor(requestId), expiresAt: expiresAt
        });
    }

    // ─────────────────────────── tests
    // ─────────────────────────────

    function test_approve_withNitroCommitment_persistsOnActivation() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        // Expect the recording event before the call so we catch the args.
        vm.expectEmit(true, true, false, true);
        emit TeeCommitmentRecorded(requestId, operator1, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO);

        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);

        // Service activated immediately because operator count == 1.
        uint64 serviceId = tangle.serviceCount() - 1;
        Types.TeeAttestationCommitment[] memory stored = tangle.getTeeCommitment(serviceId, operator1);
        assertEq(stored.length, 1, "one commitment persisted");
        assertEq(uint8(stored[0].backend), uint8(Types.TeeBackend.AwsNitro));
        assertEq(stored[0].expectedMeasurement, MEASUREMENT_NITRO);
        assertEq(stored[0].nonceBinding, _nonceFor(requestId));
        assertEq(stored[0].expiresAt, uint64(0));
    }

    function test_approve_directTdx_reverts() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.DirectTdx, MEASUREMENT_NITRO, 0);

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(Errors.DirectTdxNotPermitted.selector);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_zeroNonceBinding_reverts() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = Types.TeeAttestationCommitment({
            backend: Types.TeeBackend.AwsNitro,
            expectedMeasurement: MEASUREMENT_NITRO,
            nonceBinding: bytes32(0),
            expiresAt: 0
        });

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(Errors.InvalidNonceBinding.selector);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_directTdxInSecondSlot_reverts() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](2);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);
        teeCommits[1] = _teeCommitment(requestId, Types.TeeBackend.DirectTdx, MEASUREMENT_NITRO, 0);

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(Errors.DirectTdxNotPermitted.selector);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_expiredCommitment_reverts() public {
        // Push the EVM clock forward so we can set an expiry comfortably in the past.
        vm.warp(1_000_000);
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        uint64 expired = uint64(block.timestamp - 1);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, expired);

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(abi.encodeWithSelector(Errors.TeeCommitmentExpired.selector, expired, uint64(block.timestamp)));
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_expiryAtCurrentTimestamp_reverts() public {
        vm.warp(1_000_000);
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        uint64 atNow = uint64(block.timestamp);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, atNow);

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(abi.encodeWithSelector(Errors.TeeCommitmentExpired.selector, atNow, uint64(block.timestamp)));
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_futureExpiry_persists() public {
        vm.warp(1_000_000);
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        uint64 future = uint64(block.timestamp + 1 days);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, future);

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.TeeAttestationCommitment[] memory stored = tangle.getTeeCommitment(serviceId, operator1);
        assertEq(stored.length, 1);
        assertEq(stored[0].expiresAt, future);
    }

    function test_multipleOperators_distinctBackends_persistedPerOperator() public {
        uint64 requestId = _requestThreeOperators();

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        // Operator 1: Nitro
        Types.TeeAttestationCommitment[] memory tee1 = new Types.TeeAttestationCommitment[](1);
        tee1[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, tee1);

        // Operator 2: Phala (with two commitments to exercise the array-store path)
        Types.TeeAttestationCommitment[] memory tee2 = new Types.TeeAttestationCommitment[](2);
        tee2[0] = _teeCommitment(requestId, Types.TeeBackend.Phala, MEASUREMENT_PHALA, 0);
        tee2[1] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);
        vm.prank(operator2);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, tee2);

        // Operator 3: GCP Confidential
        Types.TeeAttestationCommitment[] memory tee3 = new Types.TeeAttestationCommitment[](1);
        tee3[0] = _teeCommitment(requestId, Types.TeeBackend.GcpConfidential, MEASUREMENT_GCP, 0);
        vm.prank(operator3);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, tee3);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.TeeAttestationCommitment[] memory got1 = tangle.getTeeCommitment(serviceId, operator1);
        Types.TeeAttestationCommitment[] memory got2 = tangle.getTeeCommitment(serviceId, operator2);
        Types.TeeAttestationCommitment[] memory got3 = tangle.getTeeCommitment(serviceId, operator3);

        assertEq(got1.length, 1);
        assertEq(uint8(got1[0].backend), uint8(Types.TeeBackend.AwsNitro));
        assertEq(got1[0].expectedMeasurement, MEASUREMENT_NITRO);

        assertEq(got2.length, 2);
        assertEq(uint8(got2[0].backend), uint8(Types.TeeBackend.Phala));
        assertEq(got2[0].expectedMeasurement, MEASUREMENT_PHALA);
        assertEq(uint8(got2[1].backend), uint8(Types.TeeBackend.AwsNitro));
        assertEq(got2[1].expectedMeasurement, MEASUREMENT_NITRO);

        assertEq(got3.length, 1);
        assertEq(uint8(got3[0].backend), uint8(Types.TeeBackend.GcpConfidential));
        assertEq(got3[0].expectedMeasurement, MEASUREMENT_GCP);
    }

    function test_emptyTeeCommitments_doesNotPersistAnything() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.TeeAttestationCommitment[] memory stored = tangle.getTeeCommitment(serviceId, operator1);
        assertEq(stored.length, 0, "no TEE commitment recorded");
    }

    function test_getTeeCommitment_unknownOperator_returnsEmpty() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.TeeAttestationCommitment[] memory none = tangle.getTeeCommitment(serviceId, operator2);
        assertEq(none.length, 0);
    }

    function test_approve_zeroExpectedMeasurement_reverts() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = Types.TeeAttestationCommitment({
            backend: Types.TeeBackend.AwsNitro,
            expectedMeasurement: bytes32(0),
            nonceBinding: _nonceFor(requestId),
            expiresAt: 0
        });

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(Errors.InvalidExpectedMeasurement.selector);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_unsetBackend_reverts() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        // `Unset` is the enum sentinel at index 0; callers who forget to populate
        // the backend field would default to it.
        teeCommits[0] = Types.TeeAttestationCommitment({
            backend: Types.TeeBackend.Unset,
            expectedMeasurement: MEASUREMENT_NITRO,
            nonceBinding: _nonceFor(requestId),
            expiresAt: 0
        });

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(Errors.UnsetTeeBackend.selector);
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_tooManyCommitments_reverts() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        // 9 entries — one above the MAX_TEE_COMMITMENTS_PER_OPERATOR cap.
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](9);
        for (uint256 i = 0; i < 9; i++) {
            teeCommits[i] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);
        }

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.expectRevert(abi.encodeWithSelector(Errors.TooManyTeeCommitments.selector, uint256(9), uint256(8)));
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_approve_atCommitmentCap_succeeds() public {
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](8);
        for (uint256 i = 0; i < 8; i++) {
            teeCommits[i] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);
        }

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.TeeAttestationCommitment[] memory stored = tangle.getTeeCommitment(serviceId, operator1);
        assertEq(stored.length, 8);
    }

    function test_approve_unauthorizedCaller_revertsBeforeStorage() public {
        // Verifies the validate-before-write ordering: an operator NOT in the
        // request list must hit `Unauthorized` before any per-commitment SSTORE
        // runs. The revert rolls back state so we can't directly observe gas
        // savings, but we can assert the right error fires (i.e. auth check
        // happened, not e.g. AlreadyApproved or ServiceRequestNotFound).
        uint64 requestId = _requestSingleOperator(operator1);

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);

        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();

        // operator2 is registered + active but NOT in this single-operator request.
        vm.expectRevert(Errors.Unauthorized.selector);
        vm.prank(operator2);
        tangle.approveServiceWithTeeCommitments(requestId, commits, pk, sig, teeCommits);
    }

    function test_mixedTeeAndNonTee_acrossOperators_persistsCorrectly() public {
        // operator1 approves with a TEE commitment; operator2 approves with the
        // plain `approveServiceWithCommitments` path (no TEE). Service activates
        // on the second approval. `_persistTeeCommitments` must skip operator2
        // (no commitments stored) and copy operator1's array onto the service.
        uint64 requestId = _requestThreeOperators();
        // Trim to two operators by replacing _requestThreeOperators behaviour
        // — but the helper only does 3. Easier: have the third use plain BLS too.

        // operator1: TEE
        Types.AssetSecurityCommitment[] memory empty = new Types.AssetSecurityCommitment[](0);
        Types.TeeAttestationCommitment[] memory teeCommits = new Types.TeeAttestationCommitment[](1);
        teeCommits[0] = _teeCommitment(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT_NITRO, 0);
        (uint256[4] memory pk, uint256[2] memory sig) = _zeroBls();
        vm.prank(operator1);
        tangle.approveServiceWithTeeCommitments(requestId, empty, pk, sig, teeCommits);

        // operator2: plain commitments path (no TEE)
        vm.prank(operator2);
        tangle.approveServiceWithCommitments(requestId, empty);

        // operator3: plain commitments path (no TEE) — triggers activation
        vm.prank(operator3);
        tangle.approveServiceWithCommitments(requestId, empty);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.TeeAttestationCommitment[] memory op1Stored = tangle.getTeeCommitment(serviceId, operator1);
        assertEq(op1Stored.length, 1, "operator1 TEE commitment persisted");
        assertEq(uint8(op1Stored[0].backend), uint8(Types.TeeBackend.AwsNitro));

        // Operators that approved without TEE must have empty commitment arrays
        // (the skip branch in `_persistTeeCommitments` exercised).
        assertEq(tangle.getTeeCommitment(serviceId, operator2).length, 0, "operator2 has no TEE entries");
        assertEq(tangle.getTeeCommitment(serviceId, operator3).length, 0, "operator3 has no TEE entries");
    }

    // ─────────────────── event re-declaration
    // ──────────────────────
    // The TeeCommitmentRecorded event is defined inside ServicesApprovals.
    // Re-declare it here so vm.expectEmit can match on the topic+data layout.
    // Signature MUST match the one in ServicesApprovals exactly.
    event TeeCommitmentRecorded(
        uint64 indexed requestId, address indexed operator, Types.TeeBackend backend, bytes32 expectedMeasurement
    );
}
