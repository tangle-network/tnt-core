// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { UpgradeFlowHarness } from "../support/UpgradeFlowHarness.sol";
import { MockBinaryHookBSM } from "../mocks/MockBinaryHookBSM.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";

/// @title UpgradeFlowScenarioTest
/// @notice End-to-end scenario coverage for the binary-version upgrade flow.
///         These tests assemble realistic sequences (publish → activate → ack,
///         deprecate → rollback, BSM-gated publish) to surface integration bugs
///         that single-mixin tests miss.
contract UpgradeFlowScenarioTest is UpgradeFlowHarness {
    bytes32 internal constant HASH_V0 = bytes32(uint256(0x11));
    bytes32 internal constant HASH_V1 = bytes32(uint256(0x22));
    bytes32 internal constant HASH_V2 = bytes32(uint256(0x33));

    // ═══════════════════════════════════════════════════════════════════════════
    // 1. GENESIS FLOW
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_genesis_allPoliciesResolveToV0() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        vm.prank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));

        // Default APPROVE.
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);

        // AUTO without setActive → genesis.
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);

        // MANUAL → genesis.
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.MANUAL);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 2. AUTO UPGRADE - owner publishes new version, AUTO services follow
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_AUTO_upgradeFollowsActiveVersionImmediately() public {
        (uint64 bp, uint64 sidAuto) = _createServiceWithSingleOperator(developer, operator1, address(0));

        // Second service on the same blueprint with APPROVE policy; third with MANUAL.
        _registerOperator(operator2);
        _registerForBlueprint(operator2, bp);
        uint64 reqId2 = _requestService(user2, bp, operator2);
        _approveService(operator2, reqId2);
        uint64 sidApprove = tangle.serviceCount() - 1;

        _registerOperator(operator3);
        _registerForBlueprint(operator3, bp);
        uint64 reqId3 = _requestService(user1, bp, operator3);
        _approveService(operator3, reqId3);
        uint64 sidManual = tangle.serviceCount() - 1;

        // Two versions live.
        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        vm.stopPrank();

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sidAuto, Types.UpgradePolicy.AUTO);
        vm.prank(operator3);
        versions.setServiceUpgradePolicy(sidManual, Types.UpgradePolicy.MANUAL);

        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 1);

        assertEq(versions.effectiveBinaryVersion(sidAuto).versionId, 1, "AUTO follows owner");
        assertEq(versions.effectiveBinaryVersion(sidApprove).versionId, 0, "APPROVE waits for ack");
        assertEq(versions.effectiveBinaryVersion(sidManual).versionId, 0, "MANUAL pinned");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 3. APPROVE FLOW - operator opts in via ack
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_APPROVE_operatorAckPromotesEffectiveVersion() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        vm.stopPrank();

        // APPROVE is the default; explicit set here for documentation.
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.APPROVE);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 1);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 4. AUTO ROLLBACK - owner rolls back from v2 → v0
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_AUTO_rollbackFromV2ToV0Allowed() public {
        // Documented behaviour: blueprint owner can re-point AUTO at an earlier
        // version. Off-chain UI is expected to warn against rolling onto a
        // deprecated row, but the protocol does NOT block it.
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V2, "ipfs://v2", bytes32(0));
        vm.stopPrank();

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);

        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 2);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 2);

        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 0);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0, "rolled back to genesis");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 5. DEPRECATION + ACK STICKINESS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_deprecation_ackStickinessAndReAckBlocked() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        vm.stopPrank();

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 1);

        vm.prank(developer);
        versions.deprecateBinaryVersion(bp, 1);

        // Effective version stays at the deprecated row - the operator is on a
        // build that the owner has flagged obsolete, but did not migrate from.
        Types.BinaryVersion memory eff = versions.effectiveBinaryVersion(sid);
        assertEq(eff.versionId, 1);
        assertTrue(eff.deprecated);

        // Re-acking the deprecated version fails - that's the one-way guard.
        vm.prank(operator1);
        vm.expectRevert(Errors.VersionDeprecatedCannotAck.selector);
        versions.ackBinaryVersion(sid, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 6. MULTI-OPERATOR SERVICE - ack is per-service, not per-operator
    // ═══════════════════════════════════════════════════════════════════════════
    //
    // CURRENT DESIGN NOTE: `_serviceAckedVersionId[serviceId]` is a single uint64
    // per service. Any active operator of the service may overwrite the ack with
    // a different version. The behaviour is locked in below so a future change
    // to per-operator ack semantics surfaces as a test diff rather than a silent
    // regression. Discussion of whether per-service is the right shape is out of
    // scope for this branch.

    function test_scenario_multiOperator_lastAckWinsPerService() public {
        _registerOperator(operator1);
        _registerOperator(operator2);
        uint64 bp = _createBlueprint(developer);
        _registerForBlueprint(operator1, bp);
        _registerForBlueprint(operator2, bp);

        // Build a Dynamic blueprint membership so we can have 2 operators.
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 reqId = tangle.requestService(bp, ops, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any);
        _approveService(operator1, reqId);
        _approveService(operator2, reqId);
        uint64 sid = tangle.serviceCount() - 1;

        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V2, "ipfs://v2", bytes32(0));
        vm.stopPrank();

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 1);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 1);

        // op2 can clobber the ack - currently the design choice.
        vm.prank(operator2);
        versions.ackBinaryVersion(sid, 2);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 2, "ack is per-service: latest wins");

        // op1 can clobber back the other way.
        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 0);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 7. BSM GATE - custom BSM rejects publishes without attestation
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_BSMGate_revertingBSMDoesNotRollBackPublish() public {
        MockBinaryHookBSM bsm = new MockBinaryHookBSM();
        bsm.setRequireAttestation(true);
        uint64 bp = _createBlueprint(developer, address(bsm));

        // Publish v0 without attestation - BSM reverts, but the row is still
        // persisted (documented design).
        vm.prank(developer);
        uint64 vid0 = versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        assertEq(vid0, 0);
        assertEq(versions.getBinaryVersionCount(bp), 1);
        assertEq(bsm.publishCallCount(), 0, "BSM rejected publish");

        // Publish v1 with attestation - BSM passes; both rows now present.
        vm.prank(developer);
        uint64 vid1 = versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(uint256(0xAA)));
        assertEq(vid1, 1);
        assertEq(versions.getBinaryVersionCount(bp), 2);
        assertEq(bsm.publishCallCount(), 1, "BSM recorded v1");

        // The recorded call has Tangle as msg.sender (not the MBSM).
        assertEq(bsm.publishCallAt(0).senderAtCall, address(tangleProxy));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 8. ACK on AUTO is harmless but persisted (cross-policy mutation)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_ackUnderAUTODoesNotChangeResolution_butSwitchToAPPROVERevealsIt() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V2, "ipfs://v2", bytes32(0));
        vm.stopPrank();

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);
        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 2);

        // Under AUTO the ack is moot - effective stays at active=2 even after op acks v1.
        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 1);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 2);

        // Switching to APPROVE reveals the persisted ack.
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.APPROVE);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 1, "ack from AUTO phase now governs");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // 9. DEPRECATE-THEN-PUBLISH - counts stay monotonic
    // ═══════════════════════════════════════════════════════════════════════════

    function test_scenario_deprecatedRowsDoNotBlockFuturePublishes() public {
        uint64 bp = _createBlueprint(developer);
        vm.startPrank(developer);
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", bytes32(0));
        versions.deprecateBinaryVersion(bp, 0);
        uint64 vid = versions.publishBinaryVersion(bp, HASH_V2, "ipfs://v2", bytes32(0));
        vm.stopPrank();

        assertEq(vid, 2, "new publishes still get sequential ids");
        assertEq(versions.getBinaryVersionCount(bp), 3);
        assertTrue(versions.getBinaryVersion(bp, 0).deprecated);
        assertFalse(versions.getBinaryVersion(bp, 1).deprecated);
        assertFalse(versions.getBinaryVersion(bp, 2).deprecated);
    }
}
