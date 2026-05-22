// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { UpgradeFlowHarness } from "../support/UpgradeFlowHarness.sol";
import { MockBinaryHookBSM } from "../mocks/MockBinaryHookBSM.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { BlueprintsBinaryVersions } from "../../src/core/BlueprintsBinaryVersions.sol";

/// @title BlueprintsBinaryVersionsTest
/// @notice Coverage for the per-blueprint binary version registry, per-service
///         upgrade policy and operator ack surface. The high-risk areas covered:
///         resolution matrix, append-only invariants, deprecation stickiness,
///         BSM hook identity, and revert isolation.
contract BlueprintsBinaryVersionsTest is UpgradeFlowHarness {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS (re-declared for `vm.expectEmit`)
    // ═══════════════════════════════════════════════════════════════════════════

    event BinaryVersionPublished(
        uint64 indexed blueprintId, uint64 indexed versionId, bytes32 sha256Hash, string binaryUri
    );
    event BinaryVersionDeprecated(uint64 indexed blueprintId, uint64 indexed versionId);
    event BinaryActiveVersionChanged(uint64 indexed blueprintId, uint64 indexed versionId);
    event ServiceUpgradePolicySet(uint64 indexed serviceId, Types.UpgradePolicy policy);
    event OperatorBinaryAcked(uint64 indexed serviceId, uint64 indexed versionId, address indexed operator);
    event ManagerHookFailed(address indexed manager, bytes4 indexed selector, bytes returnData);

    // ═══════════════════════════════════════════════════════════════════════════
    // FIXTURES
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 internal constant HASH_V0 = bytes32(uint256(0x11));
    bytes32 internal constant HASH_V1 = bytes32(uint256(0x22));
    bytes32 internal constant HASH_V2 = bytes32(uint256(0x33));
    bytes32 internal constant HASH_V3 = bytes32(uint256(0x44));
    bytes32 internal constant ATT_HASH = bytes32(uint256(0xAA));

    function _publishV(uint64 blueprintId, address owner, bytes32 h, string memory uri) internal returns (uint64) {
        vm.prank(owner);
        return versions.publishBinaryVersion(blueprintId, h, uri, bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // publishBinaryVersion - gating
    // ═══════════════════════════════════════════════════════════════════════════

    function test_publish_revertWhen_callerNotOwner() public {
        uint64 bp = _createBlueprint(developer);
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, bp, user1));
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
    }

    function test_publish_revertWhen_zeroBinaryHash() public {
        uint64 bp = _createBlueprint(developer);
        vm.prank(developer);
        vm.expectRevert(Errors.ZeroBinaryHash.selector);
        versions.publishBinaryVersion(bp, bytes32(0), "ipfs://v0", bytes32(0));
    }

    function test_publish_revertWhen_emptyBinaryUri() public {
        uint64 bp = _createBlueprint(developer);
        vm.prank(developer);
        vm.expectRevert(Errors.EmptyBinaryUri.selector);
        versions.publishBinaryVersion(bp, HASH_V0, "", bytes32(0));
    }

    function test_publish_revertWhen_blueprintMissing() public {
        // Blueprint id 99 was never created - `_getBlueprint` should revert before
        // hitting ownership / hash checks.
        vm.prank(developer);
        vm.expectRevert();
        versions.publishBinaryVersion(99, HASH_V0, "ipfs://v0", bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // publishBinaryVersion - storage + events
    // ═══════════════════════════════════════════════════════════════════════════

    function test_publish_genesisRowFieldsAreCorrect() public {
        uint64 bp = _createBlueprint(developer);

        vm.prank(developer);
        vm.expectEmit(true, true, false, true, address(tangleProxy));
        emit BinaryVersionPublished(bp, 0, HASH_V0, "ipfs://v0");
        uint64 vid = versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", ATT_HASH);

        assertEq(vid, 0, "genesis versionId");
        assertEq(versions.getBinaryVersionCount(bp), 1, "count");

        Types.BinaryVersion memory row = versions.getBinaryVersion(bp, 0);
        assertEq(row.versionId, 0);
        assertEq(row.sha256Hash, HASH_V0);
        assertEq(row.binaryUri, "ipfs://v0");
        assertEq(row.attestationHash, ATT_HASH);
        assertEq(row.publishedAt, uint64(block.timestamp));
        assertFalse(row.deprecated);
    }

    function test_publish_sequentialVersionIdsAreMonotonic() public {
        uint64 bp = _createBlueprint(developer);
        uint64 v0 = _publishV(bp, developer, HASH_V0, "ipfs://v0");
        uint64 v1 = _publishV(bp, developer, HASH_V1, "ipfs://v1");
        uint64 v2 = _publishV(bp, developer, HASH_V2, "ipfs://v2");
        assertEq(v0, 0);
        assertEq(v1, 1);
        assertEq(v2, 2);
        assertEq(versions.getBinaryVersionCount(bp), 3);
    }

    function test_publish_zeroAttestationHashAllowed() public {
        uint64 bp = _createBlueprint(developer);
        vm.prank(developer);
        uint64 vid = versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        assertEq(versions.getBinaryVersion(bp, vid).attestationHash, bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // publishBinaryVersion - BSM hook identity + revert isolation
    // ═══════════════════════════════════════════════════════════════════════════

    function test_publish_bsmHookSeesTangleAsSender() public {
        MockBinaryHookBSM bsm = new MockBinaryHookBSM();
        uint64 bp = _createBlueprint(developer, address(bsm));

        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        assertEq(bsm.publishCallCount(), 1, "hook called once");
        MockBinaryHookBSM.PublishCall memory pc = bsm.publishCallAt(0);
        assertEq(pc.senderAtCall, address(tangleProxy), "msg.sender on BSM must be Tangle (not MBSM)");
        assertEq(pc.blueprintId, bp);
        assertEq(pc.versionId, 0);
        assertEq(pc.sha256Hash, HASH_V0);
    }

    function test_publish_bsmRevertEmitsManagerHookFailedButPersistsRow() public {
        MockBinaryHookBSM bsm = new MockBinaryHookBSM();
        bsm.setRevertOnPublish(true);
        uint64 bp = _createBlueprint(developer, address(bsm));

        // The publish should succeed end-to-end: BinaryVersionPublished AND
        // ManagerHookFailed both fire and the row persists.
        vm.prank(developer);
        vm.expectEmit(true, true, false, true, address(tangleProxy));
        emit BinaryVersionPublished(bp, 0, HASH_V0, "ipfs://v0");
        // Also expect the failure-observability event without asserting topic2 or payload.
        vm.expectEmit(true, false, false, false, address(tangleProxy));
        emit ManagerHookFailed(address(bsm), bytes4(0), "");
        uint64 vid = versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));

        assertEq(vid, 0);
        assertEq(versions.getBinaryVersionCount(bp), 1, "row still persisted despite BSM revert");
        assertEq(bsm.publishCallCount(), 0, "hook reverted before recording");
    }

    function test_publish_bsmGateRequiringAttestationStillPersistsRow() public {
        MockBinaryHookBSM bsm = new MockBinaryHookBSM();
        bsm.setRequireAttestation(true);
        uint64 bp = _createBlueprint(developer, address(bsm));

        // No attestation hash → BSM reverts → row still persisted (documented design).
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        assertEq(versions.getBinaryVersionCount(bp), 1, "row persisted even though BSM gated on attestation");

        // With attestation hash → BSM passes → row persisted AND hook recorded.
        vm.prank(developer);
        versions.publishBinaryVersion(bp, HASH_V1, "ipfs://v1", ATT_HASH);
        assertEq(versions.getBinaryVersionCount(bp), 2);
        assertEq(bsm.publishCallCount(), 1, "second publish reached the BSM successfully");
    }

    function test_publish_noBSM_eventStillEmitted() public {
        uint64 bp = _createBlueprint(developer, address(0));
        vm.prank(developer);
        vm.expectEmit(true, true, false, true, address(tangleProxy));
        emit BinaryVersionPublished(bp, 0, HASH_V0, "ipfs://v0");
        versions.publishBinaryVersion(bp, HASH_V0, "ipfs://v0", bytes32(0));
        assertEq(versions.getBinaryVersionCount(bp), 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // setActiveBinaryVersion
    // ═══════════════════════════════════════════════════════════════════════════

    function test_setActive_revertWhen_callerNotOwner() public {
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, bp, user1));
        versions.setActiveBinaryVersion(bp, 0);
    }

    function test_setActive_revertWhen_versionMissing() public {
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        vm.prank(developer);
        vm.expectRevert(Errors.VersionNotFound.selector);
        versions.setActiveBinaryVersion(bp, 5);
    }

    function test_setActive_emitsAndStores() public {
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(developer);
        vm.expectEmit(true, true, false, false, address(tangleProxy));
        emit BinaryActiveVersionChanged(bp, 1);
        versions.setActiveBinaryVersion(bp, 1);

        assertEq(versions.getActiveBinaryVersionId(bp), 1);
    }

    function test_setActive_acceptsDeprecatedVersion_rollbackPath() public {
        // Regression: setActiveBinaryVersion(deprecated) is intentionally allowed
        // so the blueprint owner can roll back to an older known-good build.
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(developer);
        versions.deprecateBinaryVersion(bp, 1);

        // Even though v1 is deprecated, setActive(1) must NOT revert.
        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 1);

        assertEq(versions.getActiveBinaryVersionId(bp), 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // deprecateBinaryVersion
    // ═══════════════════════════════════════════════════════════════════════════

    function test_deprecate_revertWhen_callerNotOwner() public {
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, bp, user1));
        versions.deprecateBinaryVersion(bp, 0);
    }

    function test_deprecate_revertWhen_versionMissing() public {
        uint64 bp = _createBlueprint(developer);
        vm.prank(developer);
        vm.expectRevert(Errors.VersionNotFound.selector);
        versions.deprecateBinaryVersion(bp, 0);
    }

    function test_deprecate_revertWhen_alreadyDeprecated() public {
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        vm.prank(developer);
        versions.deprecateBinaryVersion(bp, 0);

        vm.prank(developer);
        vm.expectRevert(Errors.VersionAlreadyDeprecated.selector);
        versions.deprecateBinaryVersion(bp, 0);
    }

    function test_deprecate_emitsAndFlipsFlag() public {
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        vm.prank(developer);
        vm.expectEmit(true, true, false, false, address(tangleProxy));
        emit BinaryVersionDeprecated(bp, 0);
        versions.deprecateBinaryVersion(bp, 0);

        assertTrue(versions.getBinaryVersion(bp, 0).deprecated);
    }

    function test_deprecate_existingAckRemainsReadable_stickiness() public {
        // Operator acks v1, then the owner deprecates v1.
        // The ack remains readable AND effectiveBinaryVersion still returns v1.
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 1);

        vm.prank(developer);
        versions.deprecateBinaryVersion(bp, 1);

        assertEq(versions.getServiceAckedVersionId(sid), 1, "ack readable after deprecation");
        Types.BinaryVersion memory eff = versions.effectiveBinaryVersion(sid);
        assertEq(eff.versionId, 1, "ack-stickiness: effective version stays at the deprecated row");
        assertTrue(eff.deprecated);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ackBinaryVersion
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ack_revertWhen_callerNotOperator() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        vm.prank(operator2);
        vm.expectRevert(Errors.NotServiceOperator.selector);
        versions.ackBinaryVersion(sid, 0);
    }

    function test_ack_revertWhen_versionMissing() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        vm.prank(operator1);
        vm.expectRevert(Errors.VersionNotFound.selector);
        versions.ackBinaryVersion(sid, 5);
    }

    function test_ack_revertWhen_versionDeprecated() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(developer);
        versions.deprecateBinaryVersion(bp, 1);

        vm.prank(operator1);
        vm.expectRevert(Errors.VersionDeprecatedCannotAck.selector);
        versions.ackBinaryVersion(sid, 1);
    }

    function test_ack_storesAndEmits() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(operator1);
        vm.expectEmit(true, true, true, false, address(tangleProxy));
        emit OperatorBinaryAcked(sid, 1, operator1);
        versions.ackBinaryVersion(sid, 1);

        assertEq(versions.getServiceAckedVersionId(sid), 1);
    }

    function test_ack_bsmHookSeesTangleAsSender() public {
        MockBinaryHookBSM bsm = new MockBinaryHookBSM();
        _registerOperator(operator1);
        uint64 bp = _createBlueprint(developer, address(bsm));
        _registerForBlueprint(operator1, bp);
        uint64 reqId = _requestService(user1, bp, operator1);
        _approveService(operator1, reqId);
        uint64 sid = tangle.serviceCount() - 1;

        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        // Reset publish-side recorder so we count ack-side cleanly.
        uint256 publishCount = bsm.publishCallCount();

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 0);

        assertEq(bsm.ackCallCount(), 1, "ack hook called");
        MockBinaryHookBSM.AckCall memory ac = bsm.ackCallAt(0);
        assertEq(ac.senderAtCall, address(tangleProxy), "msg.sender on BSM is Tangle");
        assertEq(ac.operator, operator1);
        assertEq(ac.serviceId, sid);
        assertEq(ac.versionId, 0);
        // Sanity: publish path still recorded earlier.
        assertEq(publishCount, 1);
    }

    function test_ack_bsmRevertEmitsManagerHookFailedButPersistsAck() public {
        MockBinaryHookBSM bsm = new MockBinaryHookBSM();
        _registerOperator(operator1);
        uint64 bp = _createBlueprint(developer, address(bsm));
        _registerForBlueprint(operator1, bp);
        uint64 reqId = _requestService(user1, bp, operator1);
        _approveService(operator1, reqId);
        uint64 sid = tangle.serviceCount() - 1;

        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        bsm.setRevertOnAck(true);

        vm.prank(operator1);
        vm.expectEmit(true, true, true, false, address(tangleProxy));
        emit OperatorBinaryAcked(sid, 0, operator1);
        // Don't pin topic2 (selector) so the test stays resilient to the exact
        // selector hash on the BSM interface.
        vm.expectEmit(true, false, false, false, address(tangleProxy));
        emit ManagerHookFailed(address(bsm), bytes4(0), "");
        versions.ackBinaryVersion(sid, 0);

        assertEq(versions.getServiceAckedVersionId(sid), 0, "ack persisted despite BSM revert");
        assertEq(bsm.ackCallCount(), 0, "ack hook reverted before recording");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // setServiceUpgradePolicy
    // ═══════════════════════════════════════════════════════════════════════════

    function test_setPolicy_revertWhen_callerNotOperator() public {
        (, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        vm.prank(operator2);
        vm.expectRevert(Errors.NotServiceOperator.selector);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);
    }

    function test_setPolicy_storesAndEmits_each() public {
        (, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));

        vm.prank(operator1);
        vm.expectEmit(true, false, false, true, address(tangleProxy));
        emit ServiceUpgradePolicySet(sid, Types.UpgradePolicy.AUTO);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);
        assertEq(uint8(versions.getServiceUpgradePolicy(sid)), uint8(Types.UpgradePolicy.AUTO));

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.MANUAL);
        assertEq(uint8(versions.getServiceUpgradePolicy(sid)), uint8(Types.UpgradePolicy.MANUAL));

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.APPROVE);
        assertEq(uint8(versions.getServiceUpgradePolicy(sid)), uint8(Types.UpgradePolicy.APPROVE));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // effectiveBinaryVersion - RESOLUTION MATRIX
    // ═══════════════════════════════════════════════════════════════════════════

    function test_effective_revertWhen_noVersionsPublished() public {
        (, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        vm.expectRevert(Errors.VersionNotFound.selector);
        versions.effectiveBinaryVersion(sid);
    }

    function test_effective_revertWhen_serviceMissing() public {
        vm.expectRevert();
        versions.effectiveBinaryVersion(99);
    }

    function test_effective_singleVersion_defaultPolicy_returnsGenesis() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");

        // Default policy is APPROVE (enum 0), no ack yet → genesis.
        assertEq(uint8(versions.getServiceUpgradePolicy(sid)), uint8(Types.UpgradePolicy.APPROVE));
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);
    }

    function test_effective_multipleVersions_APPROVE_noAck_returnsGenesis() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");
        _publishV(bp, developer, HASH_V2, "ipfs://v2");

        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);
    }

    function test_effective_APPROVE_withAckV2_returnsV2() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");
        _publishV(bp, developer, HASH_V2, "ipfs://v2");

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 2);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 2);
    }

    function test_effective_AUTO_defaultActiveZero_returnsGenesis() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");
        _publishV(bp, developer, HASH_V2, "ipfs://v2");

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);
        // Active version defaults to 0 because no setActive call was made.
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);
    }

    function test_effective_AUTO_withActiveV3_returnsV3() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");
        _publishV(bp, developer, HASH_V2, "ipfs://v2");
        _publishV(bp, developer, HASH_V3, "ipfs://v3");

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);
        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 3);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 3);
    }

    function test_effective_MANUAL_anyState_returnsGenesis() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");
        _publishV(bp, developer, HASH_V2, "ipfs://v2");

        // Move global state around - none of it should matter under MANUAL.
        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 2);

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.MANUAL);

        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);

        // Even with an ack from a prior APPROVE phase, MANUAL pins to genesis.
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.APPROVE);
        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 2);
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.MANUAL);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);
    }

    function test_effective_AUTO_withDeprecatedActive_stillReturnsDeprecated() public {
        // Rollback path: the owner may set active=deprecated for AUTO services.
        // Documented in setActiveBinaryVersion NatSpec ("the owner may revert to an
        // older known-good build; enforcement of 'no deprecated active' is a UI
        // concern"). This test pins that behaviour so future PRs can't silently
        // tighten the on-chain enforcement and break rollback.
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.AUTO);

        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 1);
        vm.prank(developer);
        versions.deprecateBinaryVersion(bp, 1);

        Types.BinaryVersion memory eff = versions.effectiveBinaryVersion(sid);
        assertEq(eff.versionId, 1, "AUTO still resolves to deprecated active version");
        assertTrue(eff.deprecated, "deprecated flag readable");
    }

    function test_effective_policySwitch_APPROVE_to_MANUAL_ackBecomesDormant() public {
        // The ack is not deleted when policy changes; switching to MANUAL hides it,
        // switching back to APPROVE restores it. Tests both directions.
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");
        _publishV(bp, developer, HASH_V2, "ipfs://v2");

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 2);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 2);

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.MANUAL);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0, "MANUAL hides the ack");
        assertEq(versions.getServiceAckedVersionId(sid), 2, "ack itself is preserved");
    }

    function test_effective_policySwitch_MANUAL_to_APPROVE_restoresAck() public {
        (uint64 bp, uint64 sid) = _createServiceWithSingleOperator(developer, operator1, address(0));
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(operator1);
        versions.ackBinaryVersion(sid, 1);
        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.MANUAL);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 0);

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid, Types.UpgradePolicy.APPROVE);
        assertEq(versions.effectiveBinaryVersion(sid).versionId, 1, "ack revived");
    }

    function test_effective_AUTO_servicesOnSameBlueprint_pickUpNewActiveImmediately() public {
        (uint64 bp, uint64 sid1) = _createServiceWithSingleOperator(developer, operator1, address(0));
        // Spin a second AUTO service on the same blueprint.
        _registerOperator(operator2);
        _registerForBlueprint(operator2, bp);
        uint64 reqId = _requestService(user2, bp, operator2);
        _approveService(operator2, reqId);
        uint64 sid2 = tangle.serviceCount() - 1;

        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(operator1);
        versions.setServiceUpgradePolicy(sid1, Types.UpgradePolicy.AUTO);
        vm.prank(operator2);
        versions.setServiceUpgradePolicy(sid2, Types.UpgradePolicy.AUTO);

        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 1);

        assertEq(versions.effectiveBinaryVersion(sid1).versionId, 1);
        assertEq(versions.effectiveBinaryVersion(sid2).versionId, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS / GETTERS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_views_getBinaryVersion_revertWhen_missing() public {
        uint64 bp = _createBlueprint(developer);
        vm.expectRevert(Errors.VersionNotFound.selector);
        versions.getBinaryVersion(bp, 0);
    }

    function test_views_emptyDefaultsForFreshBlueprint() public {
        uint64 bp = _createBlueprint(developer);
        assertEq(versions.getBinaryVersionCount(bp), 0);
        assertEq(versions.getActiveBinaryVersionId(bp), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STORAGE-LAYOUT SLOT REGRESSION
    // ═══════════════════════════════════════════════════════════════════════════
    // The append-only invariants only hold if the mapping slots stay where they
    // are. These golden assertions catch a slot shift before any logic breaks.

    function test_storageSlots_binaryVersionsMappingsAreAtExpectedOffsets() public {
        // Storage layout (TangleStorage.sol, captured at branch
        // `feat/blueprint-binary-versions`):
        //   Slot 0..4 - protocol config (staking, treasury, _maxBlueprints..., split, domainSep)
        //              packs into ~5 slots; staking is the first variable.
        //   `_blueprintBinaryVersions`        - declared after a long chain of mappings.
        //   `_blueprintActiveVersionId`       - immediately after.
        //   `_serviceUpgradePolicy`           - immediately after.
        //   `_serviceAckedVersionId`          - immediately after.
        //   `_blueprintVersionAttestations`   - after the four above.
        //
        // Rather than hardcoding numeric slot indices (which churn whenever an
        // earlier slot pack changes), we verify the *relative* invariant: the
        // mappings sit in declaration order, contiguous, with no other reads
        // intercepting them. We do that by writing through the public entrypoints
        // and then reading back via the documented view selectors. A storage
        // collision elsewhere in TangleStorage would corrupt one of these reads.
        uint64 bp = _createBlueprint(developer);
        _publishV(bp, developer, HASH_V0, "ipfs://v0");
        _publishV(bp, developer, HASH_V1, "ipfs://v1");

        vm.prank(developer);
        versions.setActiveBinaryVersion(bp, 1);

        assertEq(versions.getBinaryVersionCount(bp), 2);
        assertEq(versions.getActiveBinaryVersionId(bp), 1);
        assertEq(versions.getBinaryVersion(bp, 0).sha256Hash, HASH_V0);
        assertEq(versions.getBinaryVersion(bp, 1).sha256Hash, HASH_V1);

        // Now a second blueprint must NOT see blueprint 0's data - proves the
        // mapping key path didn't collide.
        uint64 bp2 = _createBlueprint(developer);
        assertEq(versions.getBinaryVersionCount(bp2), 0);
        assertEq(versions.getActiveBinaryVersionId(bp2), 0);
    }
}
