// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { UpgradeFlowHarness } from "../support/UpgradeFlowHarness.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { BlueprintsBinaryAttestations } from "../../src/core/BlueprintsBinaryAttestations.sol";

/// @title BlueprintsBinaryAttestationsTest
/// @notice Coverage for the permissionless attestation registry. High-risk paths
///         covered: input validation (severity, expiry, empty URI), revoke-only-
///         by-attester, and append-only history (revoked rows stay readable).
contract BlueprintsBinaryAttestationsTest is UpgradeFlowHarness {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BinaryVersionAttested(
        uint64 indexed blueprintId,
        uint64 indexed versionId,
        uint64 attestationId,
        address indexed attester,
        Types.AttestationKind kind,
        uint8 severityFound,
        string reportUri
    );
    event BinaryVersionAttestationRevoked(
        uint64 indexed blueprintId, uint64 indexed versionId, uint64 attestationId, string reasonUri
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // FIXTURES
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 internal constant HASH_V0 = bytes32(uint256(0x11));
    bytes32 internal constant REPORT_HASH = bytes32(uint256(0xBB));

    uint64 internal blueprintId;

    function setUp() public virtual override {
        super.setUp();
        blueprintId = _createBlueprint(developer);
        vm.prank(developer);
        versions.publishBinaryVersion(blueprintId, HASH_V0, "ipfs://v0", bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // attestBinaryVersion - gating
    // ═══════════════════════════════════════════════════════════════════════════

    function test_attest_revertWhen_versionMissing() public {
        vm.prank(user1);
        vm.expectRevert(Errors.VersionNotFound.selector);
        attestations.attestBinaryVersion(blueprintId, 5, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, 0);
    }

    function test_attest_revertWhen_blueprintMissing() public {
        vm.prank(user1);
        vm.expectRevert(Errors.VersionNotFound.selector);
        attestations.attestBinaryVersion(99, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, 0);
    }

    function test_attest_revertWhen_emptyReportUri() public {
        vm.prank(user1);
        vm.expectRevert(Errors.EmptyReportUri.selector);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "", Types.AttestationKind.AUDIT, 3, 0);
    }

    function test_attest_revertWhen_severityTooHigh() public {
        vm.prank(user1);
        vm.expectRevert(Errors.InvalidSeverity.selector);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 6, 0);
    }

    function test_attest_severityFiveAccepted() public {
        // Boundary check - 5 (critical) must be accepted, 6 must not.
        vm.prank(user1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 5, 0);
        assertEq(attestations.getAttestationCount(blueprintId, 0), 1);
    }

    function test_attest_severityZeroAccepted() public {
        vm.prank(user1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.SELF, 0, 0);
        assertEq(attestations.getAttestation(blueprintId, 0, 0).severityFound, 0);
    }

    function test_attest_revertWhen_expiresInPast() public {
        vm.warp(2_000_000);
        vm.prank(user1);
        vm.expectRevert(Errors.ExpiresInPast.selector);
        attestations.attestBinaryVersion(
            blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, uint64(block.timestamp - 1)
        );
    }

    function test_attest_revertWhen_expiresEqualsNow() public {
        // The check is `<= block.timestamp` so an expiry equal to now must revert.
        vm.warp(2_000_000);
        vm.prank(user1);
        vm.expectRevert(Errors.ExpiresInPast.selector);
        attestations.attestBinaryVersion(
            blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, uint64(block.timestamp)
        );
    }

    function test_attest_expiresZeroIsTreatedAsNoExpiry() public {
        vm.warp(2_000_000);
        vm.prank(user1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, 0);
        assertEq(attestations.getAttestation(blueprintId, 0, 0).expiresAt, 0);
    }

    function test_attest_futureExpiryAccepted() public {
        vm.warp(2_000_000);
        vm.prank(user1);
        attestations.attestBinaryVersion(
            blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, uint64(block.timestamp + 30 days)
        );
        assertEq(attestations.getAttestation(blueprintId, 0, 0).expiresAt, uint64(block.timestamp + 30 days));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // attestBinaryVersion - happy path
    // ═══════════════════════════════════════════════════════════════════════════

    function test_attest_happyPath_storesAllFieldsAndEmits() public {
        vm.warp(2_000_000);
        uint64 expiry = uint64(block.timestamp + 7 days);

        vm.prank(user1);
        vm.expectEmit(true, true, true, true, address(tangleProxy));
        emit BinaryVersionAttested(blueprintId, 0, 0, user1, Types.AttestationKind.FORMAL, 2, "ipfs://r");
        uint64 aid = attestations.attestBinaryVersion(
            blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.FORMAL, 2, expiry
        );

        assertEq(aid, 0);
        Types.Attestation memory a = attestations.getAttestation(blueprintId, 0, 0);
        assertEq(a.attester, user1);
        assertEq(a.reportHash, REPORT_HASH);
        assertEq(a.reportUri, "ipfs://r");
        assertEq(uint8(a.kind), uint8(Types.AttestationKind.FORMAL));
        assertEq(a.severityFound, 2);
        assertEq(a.attestedAt, uint64(block.timestamp));
        assertEq(a.expiresAt, expiry);
        assertFalse(a.revoked);
    }

    function test_attest_permissionless_anyAddressCanAttest() public {
        vm.prank(user1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "u1", Types.AttestationKind.AUDIT, 1, 0);
        vm.prank(operator1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "op1", Types.AttestationKind.FUZZ, 2, 0);
        vm.prank(developer);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "dev", Types.AttestationKind.SELF, 0, 0);

        assertEq(attestations.getAttestationCount(blueprintId, 0), 3);
    }

    function test_attest_sameSenderCanAttestMultipleTimes_distinctIds() public {
        vm.startPrank(user1);
        uint64 a0 =
            attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r0", Types.AttestationKind.AUDIT, 1, 0);
        uint64 a1 =
            attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r1", Types.AttestationKind.AUDIT, 2, 0);
        uint64 a2 =
            attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r2", Types.AttestationKind.AUDIT, 3, 0);
        vm.stopPrank();

        assertEq(a0, 0);
        assertEq(a1, 1);
        assertEq(a2, 2);
        assertEq(attestations.getAttestationCount(blueprintId, 0), 3);
    }

    function test_attest_zeroReportHashAllowed() public {
        // SELF declarations may carry only a URI; the spec allows reportHash=0.
        vm.prank(user1);
        uint64 aid = attestations.attestBinaryVersion(
            blueprintId, 0, bytes32(0), "ipfs://self", Types.AttestationKind.SELF, 0, 0
        );
        assertEq(attestations.getAttestation(blueprintId, 0, aid).reportHash, bytes32(0));
    }

    function test_attest_indicesMonotonic_acrossVersions_independentArrays() public {
        // Publish a second version and assert that attestation ids are independent
        // per (blueprintId, versionId) - i.e. v1's first attestation is also aid 0.
        vm.prank(developer);
        versions.publishBinaryVersion(blueprintId, bytes32(uint256(0x22)), "ipfs://v1", bytes32(0));

        vm.prank(user1);
        uint64 a0 =
            attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r", Types.AttestationKind.AUDIT, 1, 0);
        vm.prank(user1);
        uint64 b0 =
            attestations.attestBinaryVersion(blueprintId, 1, REPORT_HASH, "r", Types.AttestationKind.AUDIT, 1, 0);

        assertEq(a0, 0);
        assertEq(b0, 0);
        assertEq(attestations.getAttestationCount(blueprintId, 0), 1);
        assertEq(attestations.getAttestationCount(blueprintId, 1), 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // revokeAttestation
    // ═══════════════════════════════════════════════════════════════════════════

    function test_revoke_revertWhen_nonAttesterCaller() public {
        vm.prank(user1);
        uint64 aid = attestations.attestBinaryVersion(
            blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, 0
        );

        vm.prank(user2);
        vm.expectRevert(Errors.NotAttester.selector);
        attestations.revokeAttestation(blueprintId, 0, aid, "ipfs://reason");
    }

    function test_revoke_revertWhen_idMissing() public {
        vm.prank(user1);
        vm.expectRevert(Errors.AttestationNotFound.selector);
        attestations.revokeAttestation(blueprintId, 0, 0, "ipfs://reason");
    }

    function test_revoke_revertWhen_alreadyRevoked() public {
        vm.prank(user1);
        uint64 aid = attestations.attestBinaryVersion(
            blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, 0
        );

        vm.prank(user1);
        attestations.revokeAttestation(blueprintId, 0, aid, "ipfs://reason");

        vm.prank(user1);
        vm.expectRevert(Errors.AttestationAlreadyRevoked.selector);
        attestations.revokeAttestation(blueprintId, 0, aid, "ipfs://reason-second");
    }

    function test_revoke_happyPath_flipsFlagPreservesRow_emits() public {
        vm.prank(user1);
        uint64 aid = attestations.attestBinaryVersion(
            blueprintId, 0, REPORT_HASH, "ipfs://r", Types.AttestationKind.AUDIT, 3, 0
        );

        vm.prank(user1);
        vm.expectEmit(true, true, false, true, address(tangleProxy));
        emit BinaryVersionAttestationRevoked(blueprintId, 0, aid, "ipfs://reason");
        attestations.revokeAttestation(blueprintId, 0, aid, "ipfs://reason");

        Types.Attestation memory a = attestations.getAttestation(blueprintId, 0, aid);
        assertTrue(a.revoked);
        // Other fields untouched: provenance preserved.
        assertEq(a.attester, user1);
        assertEq(a.reportHash, REPORT_HASH);
        assertEq(a.reportUri, "ipfs://r");
    }

    function test_revoke_doesNotChangeAttestationCount() public {
        vm.prank(user1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r0", Types.AttestationKind.AUDIT, 1, 0);
        vm.prank(user2);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r1", Types.AttestationKind.AUDIT, 2, 0);

        vm.prank(user1);
        attestations.revokeAttestation(blueprintId, 0, 0, "reason");

        assertEq(attestations.getAttestationCount(blueprintId, 0), 2, "count is append-only: revoke must not shrink");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_getAttestation_revertWhen_missing() public {
        vm.expectRevert(Errors.AttestationNotFound.selector);
        attestations.getAttestation(blueprintId, 0, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // listAttestations — facet routing policy
    // ═══════════════════════════════════════════════════════════════════════════
    //
    // The TangleBlueprintsBinaryAttestationsFacet intentionally does NOT expose
    // `listAttestations` through the Tangle selector router (see the NatSpec on
    // `selectors()`): the function copies the full unbounded array into memory
    // and an on-chain consumer that called through the proxy would OOG once the
    // list grows. Off-chain enumeration must use `getAttestationCount` +
    // `getAttestation(id)`. The tests below pin that gating and verify the
    // count-based iteration produces the same data the array view would have.

    function test_listAttestations_NotRoutedViaTangle() public {
        // The selector is deliberately omitted from `selectors()`; calling it via
        // the proxy must revert with the router's UnknownSelector error.
        (bool ok, bytes memory ret) = address(tangleProxy)
            .call(
                abi.encodeWithSelector(BlueprintsBinaryAttestations.listAttestations.selector, blueprintId, uint64(0))
            );
        assertFalse(ok, "listAttestations must not be routable through Tangle");
        // Decode error selector (skip 4-byte selector, decode is unnecessary;
        // we only need to confirm the revert came from the router).
        bytes4 errSel;
        assembly {
            errSel := mload(add(ret, 32))
        }
        assertEq(errSel, bytes4(keccak256("UnknownSelector(bytes4)")), "router rejects with UnknownSelector");
    }

    function test_countBasedEnumeration_matchesArrayViewIntent_includingRevoked() public {
        // Even without the array view exposed via Tangle, the documented offchain
        // enumeration pattern (count + getAttestation per index) must return
        // every row including revoked ones. This test pins that invariant.
        vm.prank(user1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r0", Types.AttestationKind.AUDIT, 1, 0);
        vm.prank(user2);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r1", Types.AttestationKind.FUZZ, 2, 0);
        vm.prank(operator1);
        attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r2", Types.AttestationKind.FORMAL, 3, 0);

        vm.prank(user2);
        attestations.revokeAttestation(blueprintId, 0, 1, "reason");

        uint64 count = attestations.getAttestationCount(blueprintId, 0);
        assertEq(count, 3, "count is append-only across revocations");

        Types.Attestation memory a0 = attestations.getAttestation(blueprintId, 0, 0);
        Types.Attestation memory a1 = attestations.getAttestation(blueprintId, 0, 1);
        Types.Attestation memory a2 = attestations.getAttestation(blueprintId, 0, 2);
        assertEq(a0.attester, user1);
        assertEq(a1.attester, user2);
        assertTrue(a1.revoked, "revoked row still readable by id");
        assertEq(a2.attester, operator1);
    }

    function test_countBasedEnumeration_orderMatchesInsertionOrder() public {
        address[3] memory attesters = [user1, user2, operator1];
        for (uint256 i = 0; i < attesters.length; i++) {
            vm.prank(attesters[i]);
            attestations.attestBinaryVersion(blueprintId, 0, REPORT_HASH, "r", Types.AttestationKind.AUDIT, 1, 0);
        }
        for (uint256 i = 0; i < attesters.length; i++) {
            assertEq(attestations.getAttestation(blueprintId, 0, uint64(i)).attester, attesters[i]);
        }
    }
}
