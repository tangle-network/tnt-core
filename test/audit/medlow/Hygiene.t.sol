// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { ProtocolConfig } from "../../../src/config/ProtocolConfig.sol";
import { BlueprintAuditors } from "../../../src/governance/BlueprintAuditors.sol";
import { Errors } from "../../../src/libraries/Errors.sol";

/// @title HygieneAuditTest
/// @notice Regression coverage for the "hygiene" med/low audit unit.
///
///         Finding 1 (LOW, config): `DEFAULT_MAX_OPERATORS_PER_SERVICE` seeds the
///         per-service operator ceiling that bounds the nested per-operator loops
///         in the billing / distribute / terminate paths. The audit flagged the
///         original seed of 256 as too aggressive for an out-of-the-box deployment.
///         The permanent fix lowers the seed to a conservative 128 (governance can
///         still raise it deliberately via the admin setter once gas headroom is
///         measured). These tests pin the seed at <= 128 so a regression that
///         restored 256 (or any value above the conservative ceiling) fails here.
///
///         Finding 2 (LOW, business-logic): `BlueprintAuditors.setAuditorActive`
///         must preserve the registry's advertised invariant "inactive => weight 0".
///         The original code only flipped the `active` flag, leaving a non-zero
///         weight behind so an aggregator that scored by `weight` (rather than
///         re-checking `active`) kept counting a deactivated auditor's influence.
///         The permanent fix zeroes the weight on every deactivation path. These
///         tests assert weight is zeroed on `setAuditorActive(false)`, that the
///         zeroing emits `AuditorWeightSet`, and that the invariant holds for the
///         `removeAuditor` path too. A regression that dropped the zeroing fails.
contract HygieneAuditTest is Test {
    BlueprintAuditors internal auditorsImpl;
    BlueprintAuditors internal auditors;

    address internal admin = makeAddr("admin");
    address internal governor = makeAddr("governor");
    address internal firstPartyAdmin = makeAddr("firstPartyAdmin");
    address internal auditor1 = makeAddr("auditor1");

    bytes32 internal constant GOV_ROLE = keccak256("GOVERNANCE_ROLE");

    // Re-declared for vm.expectEmit
    event AuditorActiveSet(address indexed auditor, bool active);
    event AuditorWeightSet(address indexed auditor, uint16 oldWeight, uint16 newWeight);

    function setUp() public {
        auditorsImpl = new BlueprintAuditors();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(auditorsImpl), abi.encodeCall(BlueprintAuditors.initialize, (admin, governor, firstPartyAdmin))
        );
        auditors = BlueprintAuditors(address(proxy));
    }

    function _admitData(
        string memory name,
        uint16 weight,
        BlueprintAuditors.AuditorTier tier
    )
        internal
        pure
        returns (BlueprintAuditors.Auditor memory)
    {
        return BlueprintAuditors.Auditor({
            name: name,
            metadataUri: "ipfs://meta",
            weight: weight,
            tier: tier,
            active: false, // ignored by contract
            admittedAt: 0 // ignored by contract
        });
    }

    function _admit(uint16 weight) internal {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Auditor One", weight, BlueprintAuditors.AuditorTier.INDEPENDENT));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Finding 1 (LOW, config) — conservative per-service operator seed default
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev The seed default must stay at the conservative ceiling. A regression
    ///      that restored the audited-against 256 (or any value above 128) would
    ///      blow this assertion, which is the secure invariant: an out-of-the-box
    ///      deployment must bound its worst-case nested per-operator loop gas.
    function test_finding1_defaultMaxOperatorsPerService_isConservative() public pure {
        assertEq(
            ProtocolConfig.DEFAULT_MAX_OPERATORS_PER_SERVICE,
            128,
            "seed default must remain the conservative 128, not the audited-against 256"
        );
        assertLe(
            ProtocolConfig.DEFAULT_MAX_OPERATORS_PER_SERVICE,
            128,
            "seed default must not exceed the conservative ceiling"
        );
        // The original audited value (256) must never be the seed again.
        assertTrue(ProtocolConfig.DEFAULT_MAX_OPERATORS_PER_SERVICE != 256, "must not regress to 256");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Finding 2 (LOW, business-logic) — "inactive => weight 0" invariant
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Deactivating an active auditor with a positive weight must zero the
    ///      weight. This is the core secure invariant: a regression that only
    ///      flipped `active` (leaving weight > 0) fails the weight assertion.
    function test_finding2_setAuditorActiveFalse_zeroesWeight() public {
        _admit(750);
        assertEq(auditors.auditorWeight(auditor1), 750, "precondition: weight set");
        assertTrue(auditors.isActiveAuditor(auditor1), "precondition: active");

        vm.prank(governor);
        auditors.setAuditorActive(auditor1, false);

        assertFalse(auditors.isActiveAuditor(auditor1), "must be inactive");
        assertEq(auditors.auditorWeight(auditor1), 0, "inactive auditor must have weight 0");

        // Invariant must hold on the full record view too.
        BlueprintAuditors.Auditor memory row = auditors.getAuditor(auditor1);
        assertFalse(row.active, "record: inactive");
        assertEq(row.weight, 0, "record: weight zeroed");
        // admittedAt preserved (soft-delete keeps history auditable).
        assertGt(row.admittedAt, 0, "admittedAt preserved across deactivation");
    }

    /// @dev The zeroing must surface to weight-tracking event consumers via
    ///      `AuditorWeightSet(old, 0)` followed by `AuditorActiveSet(false)`.
    ///      A regression that dropped the weight-zeroing also drops this event.
    function test_finding2_setAuditorActiveFalse_emitsWeightZeroed() public {
        _admit(600);

        vm.expectEmit(true, true, true, true, address(auditors));
        emit AuditorWeightSet(auditor1, 600, 0);
        vm.expectEmit(true, true, true, true, address(auditors));
        emit AuditorActiveSet(auditor1, false);

        vm.prank(governor);
        auditors.setAuditorActive(auditor1, false);
    }

    /// @dev Re-activation must restore the auditor with weight 0; governance sets
    ///      the new weight explicitly. Confirms the deactivation truly cleared the
    ///      weight rather than stashing it for silent restore.
    function test_finding2_reactivation_restoresWithZeroWeight() public {
        _admit(500);

        vm.prank(governor);
        auditors.setAuditorActive(auditor1, false);
        assertEq(auditors.auditorWeight(auditor1), 0, "weight cleared on deactivate");

        vm.prank(governor);
        auditors.setAuditorActive(auditor1, true);
        assertTrue(auditors.isActiveAuditor(auditor1), "re-activated");
        assertEq(auditors.auditorWeight(auditor1), 0, "re-activation restores weight 0, not the old weight");
    }

    /// @dev Deactivating an already-zero-weight auditor must NOT emit a spurious
    ///      `AuditorWeightSet` (the fix gates the zeroing on `weight != 0`), but
    ///      the invariant (inactive => weight 0) still holds.
    function test_finding2_setAuditorActiveFalse_noSpuriousWeightEventWhenAlreadyZero() public {
        _admit(0);
        assertEq(auditors.auditorWeight(auditor1), 0, "precondition: zero weight");

        vm.expectEmit(true, true, true, true, address(auditors));
        emit AuditorActiveSet(auditor1, false);

        vm.prank(governor);
        auditors.setAuditorActive(auditor1, false);

        assertFalse(auditors.isActiveAuditor(auditor1), "inactive");
        assertEq(auditors.auditorWeight(auditor1), 0, "invariant holds: weight 0");
    }

    /// @dev The same "inactive => weight 0" invariant must hold for the
    ///      `removeAuditor` soft-delete path (the original code path that already
    ///      zeroed weight). Pins both deactivation paths to one invariant.
    function test_finding2_removeAuditor_zeroesWeight() public {
        _admit(900);

        vm.prank(governor);
        auditors.removeAuditor(auditor1);

        assertFalse(auditors.isActiveAuditor(auditor1), "removed => inactive");
        assertEq(auditors.auditorWeight(auditor1), 0, "removed => weight 0");
    }

    /// @dev Cross-path consistency: after deactivate, `setAuditorWeight` must
    ///      revert (active-only) so a removed auditor cannot regain weight without
    ///      explicit re-activation — closing the "inactive but weighted" loophole.
    function test_finding2_setWeightOnInactive_reverts() public {
        _admit(400);

        vm.prank(governor);
        auditors.setAuditorActive(auditor1, false);

        vm.prank(governor);
        vm.expectRevert(Errors.AuditorNotActive.selector);
        auditors.setAuditorWeight(auditor1, 300);
    }
}
