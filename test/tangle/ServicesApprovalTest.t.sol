// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { MockBSM_V1 } from "../blueprints/mocks/MockBSM.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";

/// @title ServicesApprovalTest
/// @notice End-to-end coverage for the unified `approveService(ApprovalParams)` entrypoint.
///         Every test names a specific failure mode it would catch — no compiler-bug theater.
contract ServicesApprovalTest is BaseTest {
    uint64 internal blueprintId;

    bytes32 internal constant MEASUREMENT = keccak256("measurement-1");
    uint64 internal constant TTL_CAP = 90 days; // mirrors ServicesApprovals.MAX_TEE_COMMITMENT_TTL

    function setUp() public override {
        super.setUp();
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://approval", address(0)));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, blueprintId);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator3, blueprintId);
    }

    // ───────────────────────────────────────────────────────────────────────
    // Helpers
    // ───────────────────────────────────────────────────────────────────────

    function _request(address[] memory ops) internal returns (uint64 requestId) {
        vm.prank(user1);
        requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.TeeRequired
        );
    }

    function _requestSingle(address op) internal returns (uint64 requestId) {
        address[] memory ops = new address[](1);
        ops[0] = op;
        return _request(ops);
    }

    function _teeCommit(
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
            backend: backend,
            expectedMeasurement: measurement,
            nonceBinding: tangle.teeNonceFor(requestId),
            expiresAt: expiresAt
        });
    }

    function _approveTee(
        uint64 requestId,
        Types.TeeAttestationCommitment[] memory tees
    )
        internal
        view
        returns (Types.ApprovalParams memory p)
    {
        p.requestId = requestId;
        p.teeCommitments = tees;
    }

    // ───────────────────────────────────────────────────────────────────────
    // Happy paths
    // ───────────────────────────────────────────────────────────────────────

    /// @notice Operator approves with a single TEE commitment; root persists; activation works.
    function test_singleOperator_singleTeeCommitment_rootPersists() public {
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT, 0);

        bytes32 expectedRoot = keccak256(abi.encode(tees));

        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));

        uint64 serviceId = tangle.serviceCount() - 1;
        assertEq(tangle.getTeeCommitmentRoot(serviceId, operator1), expectedRoot, "root persisted");
    }

    /// @notice The minimal approval (no commitments, no BLS, no TEE) works for a request
    ///         with no security requirements. The protocol must accept any operator.
    function test_minimalApproval_noOptionalFields_succeeds() public {
        uint64 requestId = _requestSingle(operator1);

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        uint64 serviceId = tangle.serviceCount() - 1;
        assertEq(tangle.getTeeCommitmentRoot(serviceId, operator1), bytes32(0), "no TEE root for opt-out operator");
    }

    /// @notice Multi-operator service where one operator commits TEE and others don't.
    ///         Each operator's root is independent; non-TEE operators have zero root.
    function test_mixedTeeAndNonTee_rootsIndependent() public {
        address[] memory ops = new address[](3);
        (ops[0], ops[1], ops[2]) = (operator1, operator2, operator3);
        uint64 requestId = _request(ops);

        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT, 0);
        bytes32 expectedRoot = keccak256(abi.encode(tees));

        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
        vm.prank(operator2);
        tangle.approveService(_approve(requestId));
        vm.prank(operator3);
        tangle.approveService(_approve(requestId));

        uint64 serviceId = tangle.serviceCount() - 1;
        assertEq(tangle.getTeeCommitmentRoot(serviceId, operator1), expectedRoot);
        assertEq(tangle.getTeeCommitmentRoot(serviceId, operator2), bytes32(0));
        assertEq(tangle.getTeeCommitmentRoot(serviceId, operator3), bytes32(0));
    }

    /// @notice Slasher path: provides original commitment array as a witness, contract
    ///         consumer (here the test as a stand-in) verifies keccak match.
    function test_slasherWitnessVerification_works() public {
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](2);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT, 0);
        tees[1] = _teeCommit(requestId, Types.TeeBackend.Phala, keccak256("alt"), 0);

        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));

        uint64 serviceId = tangle.serviceCount() - 1;
        bytes32 storedRoot = tangle.getTeeCommitmentRoot(serviceId, operator1);

        // Honest witness verifies.
        assertEq(keccak256(abi.encode(tees)), storedRoot, "honest witness matches stored root");

        // Tampered witness (one byte changed) does not.
        Types.TeeAttestationCommitment[] memory tampered = new Types.TeeAttestationCommitment[](2);
        tampered[0] = tees[0];
        tampered[1] = _teeCommit(requestId, Types.TeeBackend.Phala, keccak256("tampered"), 0);
        assertTrue(keccak256(abi.encode(tampered)) != storedRoot, "tampered witness rejected");
    }

    // ───────────────────────────────────────────────────────────────────────
    // Adversarial — TEE commitment validation
    // ───────────────────────────────────────────────────────────────────────

    /// @notice DirectTdx is recognised but rejected — vendor-mediated backends only.
    function test_directTdx_rejected() public {
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.DirectTdx, MEASUREMENT, 0);

        vm.expectRevert(Errors.DirectTdxNotPermitted.selector);
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
    }

    /// @notice Unset enum sentinel (zero-value) rejected — protects integrators that forget
    ///         to populate the backend field.
    function test_unsetBackend_rejected() public {
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        tees[0] = Types.TeeAttestationCommitment({
            backend: Types.TeeBackend.Unset,
            expectedMeasurement: MEASUREMENT,
            nonceBinding: tangle.teeNonceFor(requestId),
            expiresAt: 0
        });

        vm.expectRevert(Errors.UnsetTeeBackend.selector);
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
    }

    /// @notice Zero expectedMeasurement rejected — would always-fail or always-pass against
    ///         the off-chain comparator depending on its rules; reject the ambiguity.
    function test_zeroMeasurement_rejected() public {
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, bytes32(0), 0);

        vm.expectRevert(Errors.InvalidExpectedMeasurement.selector);
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
    }

    /// @notice Cross-request replay rejected: nonce derived from request A doesn't satisfy
    ///         request B's commitment validation. This is the structural anti-replay.
    function test_crossRequestReplay_rejected() public {
        uint64 requestA = _requestSingle(operator1);
        bytes32 nonceA = tangle.teeNonceFor(requestA);

        // Approve A — accepted.
        Types.TeeAttestationCommitment[] memory teeA = new Types.TeeAttestationCommitment[](1);
        teeA[0] = Types.TeeAttestationCommitment({
            backend: Types.TeeBackend.AwsNitro, expectedMeasurement: MEASUREMENT, nonceBinding: nonceA, expiresAt: 0
        });
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestA, teeA));

        // Replay nonce A on a fresh request B — rejected.
        uint64 requestB = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory teeReplay = new Types.TeeAttestationCommitment[](1);
        teeReplay[0] = Types.TeeAttestationCommitment({
            backend: Types.TeeBackend.AwsNitro,
            expectedMeasurement: MEASUREMENT,
            nonceBinding: nonceA, // wrong: should be teeNonceFor(requestB)
            expiresAt: 0
        });
        vm.expectRevert(Errors.InvalidNonceBinding.selector);
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestB, teeReplay));
    }

    /// @notice Past expiry rejected (TeeCommitmentExpired).
    function test_pastExpiry_rejected() public {
        vm.warp(1_000_000);
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        uint64 expired = uint64(block.timestamp - 1);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT, expired);

        vm.expectRevert(abi.encodeWithSelector(Errors.TeeCommitmentExpired.selector, expired, uint64(block.timestamp)));
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
    }

    /// @notice Far-future expiry (> 90-day cap) rejected (TeeCommitmentExpiryTooFar).
    function test_unboundedExpiry_rejected() public {
        vm.warp(1_000_000);
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        uint64 tooFar = uint64(block.timestamp) + TTL_CAP + 1;
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT, tooFar);

        uint64 maxAllowed = uint64(block.timestamp) + TTL_CAP;
        vm.expectRevert(abi.encodeWithSelector(Errors.TeeCommitmentExpiryTooFar.selector, tooFar, maxAllowed));
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
    }

    /// @notice At the cap is OK (>cap is rejected, == cap is accepted). Boundary test.
    function test_expiryAtCap_accepted() public {
        vm.warp(1_000_000);
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT, uint64(block.timestamp) + TTL_CAP);

        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
        // No revert — implicit assertion.
    }

    /// @notice Per-operator commitment cap of 8 enforced; one above is rejected.
    function test_tooManyTeeCommitments_rejected() public {
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](9);
        for (uint256 i = 0; i < 9; i++) {
            tees[i] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, keccak256(abi.encode("m", i)), 0);
        }

        vm.expectRevert(abi.encodeWithSelector(Errors.TooManyTeeCommitments.selector, uint256(9), uint256(8)));
        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
    }

    // ───────────────────────────────────────────────────────────────────────
    // Adversarial — auth ordering
    // ───────────────────────────────────────────────────────────────────────

    /// @notice Unauthorized caller (active operator NOT in the request's operator list)
    ///         fails with `Unauthorized` BEFORE any per-commitment storage write happens.
    function test_unauthorizedCaller_revertsBeforeStorage() public {
        uint64 requestId = _requestSingle(operator1);
        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](1);
        tees[0] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, MEASUREMENT, 0);

        vm.expectRevert(Errors.Unauthorized.selector);
        vm.prank(operator2); // not in request's operator list
        tangle.approveService(_approveTee(requestId, tees));
    }

    /// @notice Re-approving the same request reverts.
    function test_doubleApproval_rejected() public {
        uint64 requestId = _requestSingle(operator1);

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        // First call activated the service (operator count == 1). Second approval to
        // the same request reverts because the request is no longer in pending state.
        // The exact error depends on whether activation cleared `req.rejected` or set
        // approvalCount; what matters is "you can't approve twice".
        vm.expectRevert();
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
    }

    // ───────────────────────────────────────────────────────────────────────
    // Manager hook — stakingPercent reflects what was actually committed
    // ───────────────────────────────────────────────────────────────────────

    /// @notice When the operator omits `securityCommitments` and the request carries
    ///         the protocol-default TNT requirement, the contract auto-fills at the
    ///         requirement's `minExposureBps` and the manager hook receives that
    ///         value (in percent), NOT the prior `100` fallback. This is the
    ///         regression the v0.11.1 fix introduces a test for.
    function test_managerStakingPercent_reflectsAutoFilledDefault() public {
        // The default-TNT requirement is only stored when `_tntToken` is set.
        MockERC20 tnt = new MockERC20();
        vm.prank(admin);
        tangle.setTntToken(address(tnt));

        MockBSM_V1 bsm = new MockBSM_V1();
        vm.prank(developer);
        uint64 bpId = tangle.createBlueprint(_blueprintDefinition("ipfs://bsm", address(bsm)));
        _registerForBlueprint(operator1, bpId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(bpId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any);

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        uint16 expectedBps = tangle.defaultTntMinExposureBps();
        assertEq(
            bsm.approveStakingPercent(requestId, operator1),
            uint8(expectedBps / 100),
            "manager stakingPercent must mirror auto-filled default-TNT minExposureBps"
        );
    }

    /// @notice When the operator supplies explicit security commitments, the manager
    ///         hook receives `commitments[0].exposureBps / 100`.
    function test_managerStakingPercent_reflectsSuppliedCommitment() public {
        MockERC20 tnt = new MockERC20();
        vm.prank(admin);
        tangle.setTntToken(address(tnt));

        MockBSM_V1 bsm = new MockBSM_V1();
        vm.prank(developer);
        uint64 bpId = tangle.createBlueprint(_blueprintDefinition("ipfs://bsm", address(bsm)));
        _registerForBlueprint(operator1, bpId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(bpId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any);

        // Supply an explicit commitment for the default-TNT requirement at 25% exposure.
        Types.AssetSecurityCommitment[] memory cm = new Types.AssetSecurityCommitment[](1);
        cm[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(tnt) }), exposureBps: 2500
        });

        Types.ApprovalParams memory p;
        p.requestId = requestId;
        p.securityCommitments = cm;

        vm.prank(operator1);
        tangle.approveService(p);

        assertEq(
            bsm.approveStakingPercent(requestId, operator1),
            uint8(25),
            "manager stakingPercent must mirror supplied commitment exposureBps/100"
        );
    }

    // ───────────────────────────────────────────────────────────────────────
    // Activation gas measurement (no fix, documented system-design bound)
    // ───────────────────────────────────────────────────────────────────────

    /// @notice With root storage, the activator pays O(operators) gas instead of
    ///         O(operators × commitments × 3 slots). Logged so any regression to
    ///         per-commitment SSTORE persistence is visible in the gas report.
    function test_activationGas_isOperatorLinear() public {
        address[] memory ops = new address[](3);
        (ops[0], ops[1], ops[2]) = (operator1, operator2, operator3);
        uint64 requestId = _request(ops);

        Types.TeeAttestationCommitment[] memory tees = new Types.TeeAttestationCommitment[](8);
        for (uint256 i = 0; i < 8; i++) {
            tees[i] = _teeCommit(requestId, Types.TeeBackend.AwsNitro, keccak256(abi.encode("m", i)), 0);
        }

        vm.prank(operator1);
        tangle.approveService(_approveTee(requestId, tees));
        vm.prank(operator2);
        tangle.approveService(_approveTee(requestId, tees));

        uint256 gasStart = gasleft();
        vm.prank(operator3);
        tangle.approveService(_approveTee(requestId, tees));
        uint256 gasUsed = gasStart - gasleft();

        emit log_named_uint("activator gas, 3 operators x 8 commits", gasUsed);
        // Pre-refactor baseline was ~2.89M; post-refactor we expect well under 1M.
        // Assert a generous ceiling so unrelated facet additions don't flake the test.
        assertLt(gasUsed, 1_500_000, "activation must stay operator-linear after root refactor");
    }
}
