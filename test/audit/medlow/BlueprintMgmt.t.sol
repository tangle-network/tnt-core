// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { UpgradeFlowHarness } from "../../support/UpgradeFlowHarness.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { Errors } from "../../../src/libraries/Errors.sol";
import { BlueprintsManage } from "../../../src/core/BlueprintsManage.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

/// @title BlueprintMgmtAuditTest
/// @notice Regression coverage for the blueprint-management med/low audit unit.
///
///         Finding 1 (MEDIUM, access-control): one operator must not be able to
///         move the binary version another operator of the same service runs.
///         The authoritative dispatch path is the per-operator resolver
///         `effectiveBinaryVersionForOperator`, whose `(serviceId, operator)`-keyed
///         policy/ack cannot be clobbered by a different operator. These tests pin
///         that isolation invariant end-to-end (set policy + ack), so a regression
///         that re-routed dispatch through the griefable service-wide scalar — or
///         that keyed the per-operator writes by anything other than `msg.sender` —
///         would fail here.
///
///         Finding 2 (LOW, business-logic): the cold-start source-repoint and
///         ownership-lifecycle mutators were missing `whenNotPaused`, so an
///         emergency pause could not freeze a supply-chain incident while the
///         in-place upgrade path WAS frozen. These tests assert every one of those
///         mutators now reverts under pause and resumes after unpause.
contract BlueprintMgmtAuditTest is UpgradeFlowHarness {
    bytes32 internal constant HASH_V0 = bytes32(uint256(0x11));
    bytes32 internal constant HASH_V1 = bytes32(uint256(0x22));
    bytes32 internal constant HASH_V2 = bytes32(uint256(0x33));

    BlueprintsManage internal mgmt;

    function setUp() public override {
        super.setUp();
        mgmt = BlueprintsManage(payable(address(tangleProxy)));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Finding 1 (MEDIUM) — per-operator version isolation
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Build a single service with two active operators on one blueprint.
    function _twoOperatorService() internal returns (uint64 bp, uint64 sid) {
        _registerOperator(operator1);
        _registerOperator(operator2);
        bp = _createBlueprint(developer);
        _registerForBlueprint(operator1, bp);
        _registerForBlueprint(operator2, bp);

        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 reqId =
            tangle.requestService(bp, ops, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any);
        _approveService(operator1, reqId);
        _approveService(operator2, reqId);
        sid = tangle.serviceCount() - 1;

        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V2, "ipfs://v2", bytes32(0));
        vm.stopPrank();
    }

    /// @notice One operator's ack cannot move the version another operator runs.
    ///         This is the core MEDIUM invariant: the per-operator resolver isolates
    ///         each operator's choice. If the fix were reverted (dispatch routed
    ///         through the clobberable service-wide scalar, or per-operator writes
    ///         not keyed by msg.sender), op2 would be dragged onto op1's ack and
    ///         this assertion would fail.
    function test_med_ack_isPerOperator_noCrossOperatorMove() public {
        (, uint64 sid) = _twoOperatorService();

        // op1 acks v2; op2 acks nothing (defaults: APPROVE, genesis).
        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 2);

        assertEq(
            versions.effectiveBinaryVersionForOperator(sid, operator1).sha256Hash,
            HASH_V2,
            "op1 resolves to its own ack (v2)"
        );
        assertEq(
            versions.effectiveBinaryVersionForOperator(sid, operator2).sha256Hash,
            HASH_V0,
            "op2 must NOT be moved by op1's ack: stays at genesis"
        );

        // Per-operator ack storage is isolated.
        assertEq(versions.getOperatorAckedVersionId(sid, operator1), 2, "op1 ack recorded");
        assertEq(versions.getOperatorAckedVersionId(sid, operator2), 0, "op2 ack untouched by op1");
    }

    /// @notice One operator's policy switch cannot flip the policy another operator
    ///         runs under. Mirrors the ack isolation for the policy axis.
    function test_med_policy_isPerOperator_noCrossOperatorMove() public {
        (uint64 bp, uint64 sid) = _twoOperatorService();

        // Owner moves the active version to v2 (only AUTO services follow it).
        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 2);

        // op1 opts into AUTO and so should follow active=v2.
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);

        // op2 made no policy change → default APPROVE, no ack → genesis. op1's AUTO
        // switch must not drag op2 onto the owner-driven active version.
        assertEq(
            versions.effectiveBinaryVersionForOperator(sid, operator1).sha256Hash,
            HASH_V2,
            "op1 (AUTO) follows owner active = v2"
        );
        assertEq(
            versions.effectiveBinaryVersionForOperator(sid, operator2).sha256Hash,
            HASH_V0,
            "op2 (default APPROVE, no ack) stays at genesis despite op1's AUTO switch"
        );

        assertEq(
            uint8(versions.getOperatorServiceUpgradePolicy(sid, operator1)),
            uint8(Types.UpgradePolicy.AUTO),
            "op1 policy recorded"
        );
        assertEq(
            uint8(versions.getOperatorServiceUpgradePolicy(sid, operator2)),
            uint8(Types.UpgradePolicy.APPROVE),
            "op2 policy untouched by op1 (default APPROVE)"
        );
    }

    /// @notice An attacker who acks a known-weak older build for itself cannot pin a
    ///         co-operator to that build. Both directions of the griefing vector are
    ///         covered: rolling forward (test above) and rolling back (here).
    function test_med_ackRollback_doesNotDragCoOperator() public {
        (, uint64 sid) = _twoOperatorService();

        // Both operators independently ack v2 (latest).
        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 2);
        vm.prank(operator2);
        versions.ackBinaryVersion(sid, 2);
        assertEq(versions.effectiveBinaryVersionForOperator(sid, operator1).sha256Hash, HASH_V2);
        assertEq(versions.effectiveBinaryVersionForOperator(sid, operator2).sha256Hash, HASH_V2);

        // Attacker op1 rolls ITSELF back to v0; op2 must remain on v2.
        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 0);
        assertEq(
            versions.effectiveBinaryVersionForOperator(sid, operator1).sha256Hash, HASH_V0, "op1 rolled itself back"
        );
        assertEq(
            versions.effectiveBinaryVersionForOperator(sid, operator2).sha256Hash,
            HASH_V2,
            "co-operator op2 not dragged back to v0"
        );
    }

    /// @notice Only an active operator of the service may write per-operator state.
    ///         (Authorization grain that backs the isolation guarantee.)
    function test_med_nonOperatorCannotWritePerOperatorState() public {
        (, uint64 sid) = _twoOperatorService();

        vm.prank(user2);
        vm.expectRevert(Errors.NotServiceOperator.selector);
        versions.ackBinaryVersion(sid, 1);

        vm.prank(user2);
        vm.expectRevert(Errors.NotServiceOperator.selector);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Finding 2 (LOW) — pause must freeze the cold-start / lifecycle mutators
    // ═══════════════════════════════════════════════════════════════════════════

    function _pause() internal {
        vm.prank(admin);
        tangle.pause();
    }

    function _unpause() internal {
        vm.prank(admin);
        tangle.unpause();
    }

    function _oneSource() internal pure returns (Types.BlueprintSource[] memory s) {
        s = new Types.BlueprintSource[](1);
        s[0] = _defaultBlueprintSource();
    }

    /// @notice setBlueprintSources (cold-start binary repoint) is frozen by pause.
    ///         This is the supply-chain freeze the finding is about: without the
    ///         guard a compromised owner could repoint the executable mid-incident
    ///         even after the protocol was paused.
    function test_low_setBlueprintSources_frozenByPause() public {
        uint64 bp = _createBlueprint(developer);
        _pause();

        vm.prank(developer);
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        mgmt.setBlueprintSources(bp, _oneSource());

        // Resumes after unpause — proves the guard is the only thing blocking it.
        _unpause();
        vm.prank(developer);
        mgmt.setBlueprintSources(bp, _oneSource());
    }

    /// @notice transferBlueprint (ownership / binary-distribution authority) is frozen.
    function test_low_transferBlueprint_frozenByPause() public {
        uint64 bp = _createBlueprint(developer);
        _pause();

        vm.prank(developer);
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        mgmt.transferBlueprint(bp, operator1);

        _unpause();
        vm.prank(developer);
        mgmt.transferBlueprint(bp, operator1);
        assertEq(mgmt.pendingBlueprintOwner(bp), operator1, "transfer proposes after unpause");
    }

    /// @notice acceptBlueprintOwnership (the step that actually moves ownership) is frozen.
    function test_low_acceptBlueprintOwnership_frozenByPause() public {
        uint64 bp = _createBlueprint(developer);
        vm.prank(developer);
        mgmt.transferBlueprint(bp, operator1);

        _pause();
        vm.prank(operator1);
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        mgmt.acceptBlueprintOwnership(bp);

        _unpause();
        vm.prank(operator1);
        mgmt.acceptBlueprintOwnership(bp);
    }

    /// @notice cancelBlueprintTransfer is frozen by pause.
    function test_low_cancelBlueprintTransfer_frozenByPause() public {
        uint64 bp = _createBlueprint(developer);
        vm.prank(developer);
        mgmt.transferBlueprint(bp, operator1);

        _pause();
        vm.prank(developer);
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        mgmt.cancelBlueprintTransfer(bp);

        _unpause();
        vm.prank(developer);
        mgmt.cancelBlueprintTransfer(bp);
        assertEq(mgmt.pendingBlueprintOwner(bp), address(0), "transfer cancelled after unpause");
    }

    /// @notice ackBlueprintSources (operator cold-start opt-in) is frozen by pause.
    function test_low_ackBlueprintSources_frozenByPause() public {
        uint64 bp = _createBlueprint(developer);
        _registerOperator(operator1);
        _registerForBlueprint(operator1, bp);
        bytes32 live = mgmt.blueprintSourcesHash(bp);

        _pause();
        vm.prank(operator1);
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        mgmt.ackBlueprintSources(bp, live);

        _unpause();
        vm.prank(operator1);
        mgmt.ackBlueprintSources(bp, live);
        assertTrue(mgmt.operatorAckedCurrentSources(bp, operator1), "ack lands after unpause");
    }

    /// @notice deactivateBlueprint is frozen by pause.
    function test_low_deactivateBlueprint_frozenByPause() public {
        uint64 bp = _createBlueprint(developer);
        _pause();

        vm.prank(developer);
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        mgmt.deactivateBlueprint(bp);

        _unpause();
        vm.prank(developer);
        mgmt.deactivateBlueprint(bp);
    }
}
