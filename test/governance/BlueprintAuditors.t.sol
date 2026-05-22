// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { BlueprintAuditors } from "../../src/governance/BlueprintAuditors.sol";
import { Errors } from "../../src/libraries/Errors.sol";

/// @title BlueprintAuditorsTest
/// @notice Coverage for the governance-curated auditor registry. High-risk areas:
///         role separation (governance vs first-party admin), append-only weight
///         bounds, soft-delete invariants, and UUPS upgrade authorization.
contract BlueprintAuditorsTest is Test {
    BlueprintAuditors internal auditorsImpl;
    BlueprintAuditors internal auditors;

    address internal admin = makeAddr("admin");
    address internal governor = makeAddr("governor");
    address internal firstPartyAdmin = makeAddr("firstPartyAdmin");

    address internal auditor1 = makeAddr("auditor1");
    address internal auditor2 = makeAddr("auditor2");
    address internal auditor3 = makeAddr("auditor3");
    address internal outsider = makeAddr("outsider");

    // Cached role hashes. Reading `auditors.X_ROLE()` is a proxy call, which
    // would consume `vm.prank` when used inline as an `expectRevert(...)`
    // argument (because the prank applies to the very next call). Caching them
    // here keeps the prank intact for the real assertion target.
    bytes32 internal constant GOV_ROLE = keccak256("GOVERNANCE_ROLE");
    bytes32 internal constant FP_ROLE = keccak256("FIRST_PARTY_ADMIN_ROLE");
    bytes32 internal constant ADMIN_ROLE = bytes32(0);

    // Re-declared for vm.expectEmit
    event AuditorAdmitted(
        address indexed auditor, string name, string metadataUri, uint16 weight, BlueprintAuditors.AuditorTier tier
    );
    event AuditorRemoved(address indexed auditor);
    event AuditorActiveSet(address indexed auditor, bool active);
    event AuditorWeightSet(address indexed auditor, uint16 oldWeight, uint16 newWeight);
    event AuditorMetadataUpdated(address indexed auditor, string metadataUri);

    function setUp() public virtual {
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

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_init_rolesGrantedToExpectedAddresses() public view {
        assertTrue(auditors.hasRole(ADMIN_ROLE, admin));
        assertTrue(auditors.hasRole(GOV_ROLE, governor));
        assertTrue(auditors.hasRole(FP_ROLE, firstPartyAdmin));

        assertFalse(auditors.hasRole(GOV_ROLE, firstPartyAdmin));
        assertFalse(auditors.hasRole(FP_ROLE, governor));
    }

    function test_init_revertWhen_reInitialized() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        auditors.initialize(admin, governor, firstPartyAdmin);
    }

    function test_init_implementation_constructor_disablesInitializer() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        auditorsImpl.initialize(admin, governor, firstPartyAdmin);
    }

    function test_init_revertWhen_zeroAdmin() public {
        BlueprintAuditors fresh = new BlueprintAuditors();
        vm.expectRevert(Errors.ZeroAddress.selector);
        new ERC1967Proxy(
            address(fresh), abi.encodeCall(BlueprintAuditors.initialize, (address(0), governor, firstPartyAdmin))
        );
    }

    function test_init_revertWhen_zeroGovernor() public {
        BlueprintAuditors fresh = new BlueprintAuditors();
        vm.expectRevert(Errors.ZeroAddress.selector);
        new ERC1967Proxy(
            address(fresh), abi.encodeCall(BlueprintAuditors.initialize, (admin, address(0), firstPartyAdmin))
        );
    }

    function test_init_revertWhen_zeroFirstPartyAdmin() public {
        BlueprintAuditors fresh = new BlueprintAuditors();
        vm.expectRevert(Errors.ZeroAddress.selector);
        new ERC1967Proxy(address(fresh), abi.encodeCall(BlueprintAuditors.initialize, (admin, governor, address(0))));
    }

    function test_constants_maxWeightIs1000() public view {
        assertEq(auditors.MAX_AUDITOR_WEIGHT(), 1000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // admitAuditor (governance path)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_admit_revertWhen_callerNotGovernor() public {
        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, outsider, GOV_ROLE)
        );
        auditors.admitAuditor(auditor1, _admitData("Acme", 500, BlueprintAuditors.AuditorTier.INDEPENDENT));
    }

    function test_admit_revertWhen_firstPartyAdminTries() public {
        // FIRST_PARTY_ADMIN_ROLE cannot mutate INDEPENDENT/COMMUNITY entries via the
        // governance entrypoint - confirms tier separation.
        vm.prank(firstPartyAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, firstPartyAdmin, GOV_ROLE)
        );
        auditors.admitAuditor(auditor1, _admitData("Acme", 500, BlueprintAuditors.AuditorTier.INDEPENDENT));
    }

    function test_admit_revertWhen_zeroAddress() public {
        vm.prank(governor);
        vm.expectRevert(Errors.ZeroAddress.selector);
        auditors.admitAuditor(address(0), _admitData("Acme", 500, BlueprintAuditors.AuditorTier.INDEPENDENT));
    }

    function test_admit_revertWhen_emptyName() public {
        vm.prank(governor);
        vm.expectRevert(Errors.EmptyAuditorName.selector);
        auditors.admitAuditor(auditor1, _admitData("", 500, BlueprintAuditors.AuditorTier.INDEPENDENT));
    }

    function test_admit_revertWhen_weightAboveCap() public {
        vm.prank(governor);
        vm.expectRevert(Errors.InvalidWeight.selector);
        auditors.admitAuditor(auditor1, _admitData("Acme", 1001, BlueprintAuditors.AuditorTier.INDEPENDENT));
    }

    function test_admit_acceptsMaxWeight() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 1000, BlueprintAuditors.AuditorTier.INDEPENDENT));
        assertEq(auditors.auditorWeight(auditor1), 1000);
    }

    function test_admit_revertWhen_alreadyAdmitted_evenIfRemoved() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        // Soft-remove - `admittedAt` is preserved.
        vm.prank(governor);
        auditors.removeAuditor(auditor1);

        vm.prank(governor);
        vm.expectRevert(Errors.AuditorAlreadyAdmitted.selector);
        auditors.admitAuditor(auditor1, _admitData("Acme2", 200, BlueprintAuditors.AuditorTier.INDEPENDENT));
    }

    function test_admit_happyPath_storesAndEmits() public {
        vm.warp(12_345);
        BlueprintAuditors.Auditor memory data = _admitData("Acme", 500, BlueprintAuditors.AuditorTier.INDEPENDENT);

        vm.prank(governor);
        vm.expectEmit(true, false, false, true, address(auditors));
        emit AuditorAdmitted(auditor1, "Acme", "ipfs://meta", 500, BlueprintAuditors.AuditorTier.INDEPENDENT);
        auditors.admitAuditor(auditor1, data);

        BlueprintAuditors.Auditor memory row = auditors.getAuditor(auditor1);
        assertEq(row.name, "Acme");
        assertEq(row.metadataUri, "ipfs://meta");
        assertEq(row.weight, 500);
        assertEq(uint8(row.tier), uint8(BlueprintAuditors.AuditorTier.INDEPENDENT));
        assertTrue(row.active);
        assertEq(row.admittedAt, uint64(block.timestamp));

        assertTrue(auditors.isActiveAuditor(auditor1));
        assertEq(auditors.auditorWeight(auditor1), 500);
        assertEq(auditors.auditorCount(), 1);
        assertEq(auditors.auditorAt(0), auditor1);
    }

    function test_admit_ignoresCallerSuppliedActiveAndAdmittedAt() public {
        BlueprintAuditors.Auditor memory data = BlueprintAuditors.Auditor({
            name: "Acme",
            metadataUri: "ipfs://m",
            weight: 100,
            tier: BlueprintAuditors.AuditorTier.COMMUNITY,
            active: false, // caller says inactive
            admittedAt: 9999 // caller-supplied bogus
        });

        vm.warp(1_000_000);
        vm.prank(governor);
        auditors.admitAuditor(auditor1, data);

        BlueprintAuditors.Auditor memory row = auditors.getAuditor(auditor1);
        assertTrue(row.active, "active is contract-controlled");
        assertEq(row.admittedAt, uint64(block.timestamp), "admittedAt is set to now");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // admitFirstPartyAuditor (security council path)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_admitFP_revertWhen_callerNotFirstPartyAdmin() public {
        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, outsider, FP_ROLE)
        );
        auditors.admitFirstPartyAuditor(auditor1, "Tangle Sec", 800);
    }

    function test_admitFP_revertWhen_governorTries() public {
        vm.prank(governor);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, governor, FP_ROLE)
        );
        auditors.admitFirstPartyAuditor(auditor1, "Tangle Sec", 800);
    }

    function test_admitFP_revertWhen_zeroAddress() public {
        vm.prank(firstPartyAdmin);
        vm.expectRevert(Errors.ZeroAddress.selector);
        auditors.admitFirstPartyAuditor(address(0), "Tangle Sec", 800);
    }

    function test_admitFP_revertWhen_emptyName() public {
        vm.prank(firstPartyAdmin);
        vm.expectRevert(Errors.EmptyAuditorName.selector);
        auditors.admitFirstPartyAuditor(auditor1, "", 800);
    }

    function test_admitFP_revertWhen_weightAboveCap() public {
        vm.prank(firstPartyAdmin);
        vm.expectRevert(Errors.InvalidWeight.selector);
        auditors.admitFirstPartyAuditor(auditor1, "Tangle Sec", 1001);
    }

    function test_admitFP_revertWhen_alreadyAdmitted() public {
        vm.prank(firstPartyAdmin);
        auditors.admitFirstPartyAuditor(auditor1, "Tangle Sec", 800);

        vm.prank(firstPartyAdmin);
        vm.expectRevert(Errors.AuditorAlreadyAdmitted.selector);
        auditors.admitFirstPartyAuditor(auditor1, "Tangle Sec V2", 900);
    }

    function test_admitFP_revertWhen_alreadyAdmittedViaGovernance() public {
        // FP admin cannot overwrite a governance-admitted row at any tier.
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("ChainSec", 600, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(firstPartyAdmin);
        vm.expectRevert(Errors.AuditorAlreadyAdmitted.selector);
        auditors.admitFirstPartyAuditor(auditor1, "ChainSec", 600);
    }

    function test_admitFP_happyPath_forcesFirstPartyTier() public {
        vm.warp(7777);
        vm.prank(firstPartyAdmin);
        vm.expectEmit(true, false, false, true, address(auditors));
        emit AuditorAdmitted(auditor1, "Tangle Sec", "", 800, BlueprintAuditors.AuditorTier.FIRST_PARTY);
        auditors.admitFirstPartyAuditor(auditor1, "Tangle Sec", 800);

        BlueprintAuditors.Auditor memory row = auditors.getAuditor(auditor1);
        assertEq(row.name, "Tangle Sec");
        assertEq(row.metadataUri, "");
        assertEq(row.weight, 800);
        assertEq(uint8(row.tier), uint8(BlueprintAuditors.AuditorTier.FIRST_PARTY));
        assertTrue(row.active);
        assertEq(row.admittedAt, uint64(block.timestamp));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // setAuditorWeight
    // ═══════════════════════════════════════════════════════════════════════════

    function test_setWeight_revertWhen_callerNotGovernor() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, outsider, GOV_ROLE)
        );
        auditors.setAuditorWeight(auditor1, 200);
    }

    function test_setWeight_revertWhen_firstPartyAdminTries() public {
        // The FP admin cannot bump the weight even on a FIRST_PARTY-tier auditor.
        vm.prank(firstPartyAdmin);
        auditors.admitFirstPartyAuditor(auditor1, "Tangle Sec", 100);

        vm.prank(firstPartyAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, firstPartyAdmin, GOV_ROLE)
        );
        auditors.setAuditorWeight(auditor1, 200);
    }

    function test_setWeight_revertWhen_auditorNotFound() public {
        vm.prank(governor);
        vm.expectRevert(Errors.AuditorNotFound.selector);
        auditors.setAuditorWeight(auditor1, 100);
    }

    function test_setWeight_revertWhen_aboveCap() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(governor);
        vm.expectRevert(Errors.InvalidWeight.selector);
        auditors.setAuditorWeight(auditor1, 1001);
    }

    function test_setWeight_happyPath_emitsAndUpdates() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(governor);
        vm.expectEmit(true, false, false, true, address(auditors));
        emit AuditorWeightSet(auditor1, 100, 250);
        auditors.setAuditorWeight(auditor1, 250);

        assertEq(auditors.auditorWeight(auditor1), 250);
    }

    function test_setWeight_canSetToZero() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(governor);
        auditors.setAuditorWeight(auditor1, 0);
        assertEq(auditors.auditorWeight(auditor1), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // setAuditorActive
    // ═══════════════════════════════════════════════════════════════════════════

    function test_setActive_revertWhen_callerNotGovernor() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, outsider, GOV_ROLE)
        );
        auditors.setAuditorActive(auditor1, false);
    }

    function test_setActive_revertWhen_auditorNotFound() public {
        vm.prank(governor);
        vm.expectRevert(Errors.AuditorNotFound.selector);
        auditors.setAuditorActive(auditor1, true);
    }

    function test_setActive_togglesAndEmits() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(governor);
        vm.expectEmit(true, false, false, true, address(auditors));
        emit AuditorActiveSet(auditor1, false);
        auditors.setAuditorActive(auditor1, false);

        assertFalse(auditors.isActiveAuditor(auditor1));

        vm.prank(governor);
        auditors.setAuditorActive(auditor1, true);
        assertTrue(auditors.isActiveAuditor(auditor1));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // removeAuditor (soft delete)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_remove_revertWhen_callerNotGovernor() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, outsider, GOV_ROLE)
        );
        auditors.removeAuditor(auditor1);
    }

    function test_remove_revertWhen_auditorNotFound() public {
        vm.prank(governor);
        vm.expectRevert(Errors.AuditorNotFound.selector);
        auditors.removeAuditor(auditor1);
    }

    function test_remove_setsInactiveZerosWeight_preservesAdmittedAt_emits() public {
        vm.warp(5555);
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 400, BlueprintAuditors.AuditorTier.COMMUNITY));
        uint64 admittedAt = auditors.getAuditor(auditor1).admittedAt;

        vm.warp(10_000);
        vm.prank(governor);
        // Both events are emitted in order: weight-set then removed.
        vm.expectEmit(true, false, false, true, address(auditors));
        emit AuditorWeightSet(auditor1, 400, 0);
        vm.expectEmit(true, false, false, false, address(auditors));
        emit AuditorRemoved(auditor1);
        auditors.removeAuditor(auditor1);

        BlueprintAuditors.Auditor memory row = auditors.getAuditor(auditor1);
        assertFalse(row.active);
        assertEq(row.weight, 0);
        assertEq(row.admittedAt, admittedAt, "admittedAt preserved across soft-delete");
        assertFalse(auditors.isActiveAuditor(auditor1));
    }

    function test_remove_doesNotShrinkEnumeration() public {
        vm.startPrank(governor);
        auditors.admitAuditor(auditor1, _admitData("A", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));
        auditors.admitAuditor(auditor2, _admitData("B", 200, BlueprintAuditors.AuditorTier.INDEPENDENT));
        auditors.admitAuditor(auditor3, _admitData("C", 300, BlueprintAuditors.AuditorTier.INDEPENDENT));
        auditors.removeAuditor(auditor2);
        vm.stopPrank();

        assertEq(auditors.auditorCount(), 3, "soft delete keeps enumeration intact");
        assertEq(auditors.auditorAt(0), auditor1);
        assertEq(auditors.auditorAt(1), auditor2);
        assertEq(auditors.auditorAt(2), auditor3);
        // But the middle one is inactive - aggregators filter via isActiveAuditor.
        assertTrue(auditors.isActiveAuditor(auditor1));
        assertFalse(auditors.isActiveAuditor(auditor2));
        assertTrue(auditors.isActiveAuditor(auditor3));
    }

    function test_remove_thenSetActiveTrue_resurrectsButWeightStaysZero() public {
        // Documented re-admission flow: removeAuditor then setAuditorActive(true)
        // brings the row back, but weight must be set again explicitly.
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 400, BlueprintAuditors.AuditorTier.INDEPENDENT));
        vm.prank(governor);
        auditors.removeAuditor(auditor1);
        vm.prank(governor);
        auditors.setAuditorActive(auditor1, true);

        assertTrue(auditors.isActiveAuditor(auditor1));
        assertEq(auditors.auditorWeight(auditor1), 0);

        vm.prank(governor);
        auditors.setAuditorWeight(auditor1, 500);
        assertEq(auditors.auditorWeight(auditor1), 500);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // updateAuditorMetadata (self-service)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_updateMeta_revertWhen_callerNotAdmitted() public {
        vm.prank(outsider);
        vm.expectRevert(Errors.NotAuditorSelf.selector);
        auditors.updateAuditorMetadata("ipfs://new");
    }

    function test_updateMeta_happyPath_updatesAndEmits() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(auditor1);
        vm.expectEmit(true, false, false, true, address(auditors));
        emit AuditorMetadataUpdated(auditor1, "ipfs://new");
        auditors.updateAuditorMetadata("ipfs://new");

        assertEq(auditors.getAuditor(auditor1).metadataUri, "ipfs://new");
    }

    function test_updateMeta_acceptsEmptyString() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(auditor1);
        auditors.updateAuditorMetadata("");
        assertEq(auditors.getAuditor(auditor1).metadataUri, "");
    }

    function test_updateMeta_revertWhen_removedAuditor() public {
        // Documented behaviour: soft-removed auditors CANNOT update metadata.
        // See NatSpec on `updateAuditorMetadata`: "active-only ... so a soft-
        // removed address cannot mutate its historical record post-removal".
        // The guard prevents an ex-auditor from phishing-redirecting a
        // metadataUri while their attestations still resolve through the row.
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));
        vm.prank(governor);
        auditors.removeAuditor(auditor1);

        vm.prank(auditor1);
        vm.expectRevert(Errors.AuditorNotActive.selector);
        auditors.updateAuditorMetadata("ipfs://still-mine");
    }

    function test_updateMeta_revertWhen_inactiveButNotRemoved() public {
        // `setAuditorActive(false)` flips active without zeroing weight. The
        // metadata-update guard must still reject those, otherwise the active
        // flag becomes a soft-suspended state with a hole.
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));
        vm.prank(governor);
        auditors.setAuditorActive(auditor1, false);

        vm.prank(auditor1);
        vm.expectRevert(Errors.AuditorNotActive.selector);
        auditors.updateAuditorMetadata("ipfs://x");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ENUMERATION VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_views_emptyByDefault() public view {
        assertEq(auditors.auditorCount(), 0);
        assertFalse(auditors.isActiveAuditor(auditor1));
        assertEq(auditors.auditorWeight(auditor1), 0);
    }

    function test_views_auditorAt_revertsOutOfBounds() public {
        vm.expectRevert();
        auditors.auditorAt(0);
    }

    function test_views_mixingPathsAppendsInOrder() public {
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("A", 100, BlueprintAuditors.AuditorTier.INDEPENDENT));
        vm.prank(firstPartyAdmin);
        auditors.admitFirstPartyAuditor(auditor2, "B", 200);
        vm.prank(governor);
        auditors.admitAuditor(auditor3, _admitData("C", 300, BlueprintAuditors.AuditorTier.COMMUNITY));

        assertEq(auditors.auditorCount(), 3);
        assertEq(auditors.auditorAt(0), auditor1);
        assertEq(auditors.auditorAt(1), auditor2);
        assertEq(auditors.auditorAt(2), auditor3);

        assertEq(uint8(auditors.getAuditor(auditor1).tier), uint8(BlueprintAuditors.AuditorTier.INDEPENDENT));
        assertEq(uint8(auditors.getAuditor(auditor2).tier), uint8(BlueprintAuditors.AuditorTier.FIRST_PARTY));
        assertEq(uint8(auditors.getAuditor(auditor3).tier), uint8(BlueprintAuditors.AuditorTier.COMMUNITY));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADE AUTHORIZATION (UUPS)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_upgrade_revertWhen_callerNotGovernor() public {
        BlueprintAuditors newImpl = new BlueprintAuditors();
        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, outsider, GOV_ROLE)
        );
        auditors.upgradeToAndCall(address(newImpl), "");
    }

    function test_upgrade_revertWhen_callerIsAdmin_butNotGovernor() public {
        // Admin holds DEFAULT_ADMIN_ROLE only; upgrades require GOVERNANCE_ROLE.
        BlueprintAuditors newImpl = new BlueprintAuditors();
        vm.prank(admin);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, admin, GOV_ROLE)
        );
        auditors.upgradeToAndCall(address(newImpl), "");
    }

    function test_upgrade_revertWhen_callerIsFirstPartyAdmin() public {
        BlueprintAuditors newImpl = new BlueprintAuditors();
        vm.prank(firstPartyAdmin);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, firstPartyAdmin, GOV_ROLE)
        );
        auditors.upgradeToAndCall(address(newImpl), "");
    }

    function test_upgrade_happyPath_governorCanUpgrade() public {
        BlueprintAuditors newImpl = new BlueprintAuditors();
        // Set up data before upgrade so we can verify storage continuity.
        vm.prank(governor);
        auditors.admitAuditor(auditor1, _admitData("Acme", 500, BlueprintAuditors.AuditorTier.INDEPENDENT));

        vm.prank(governor);
        auditors.upgradeToAndCall(address(newImpl), "");

        // Data preserved across upgrade.
        assertEq(auditors.getAuditor(auditor1).weight, 500);
        assertEq(auditors.auditorCount(), 1);
        assertTrue(auditors.isActiveAuditor(auditor1));
    }
}
