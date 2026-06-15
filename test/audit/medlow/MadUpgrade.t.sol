// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { IMultiAssetDelegation } from "../../../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../../src/staking/MultiAssetDelegation.sol";
import { IFacetSelectors } from "../../../src/interfaces/IFacetSelectors.sol";
import { StakingViewsFacet } from "../../../src/facets/staking/StakingViewsFacet.sol";

/// @notice Minimal attacker-controlled facet whose single selector overlaps nothing
///         else, used to prove the facet-registry write path is gated.
contract MaliciousFacet is IFacetSelectors {
    /// @dev Arbitrary, unused selector so registration never collides with the real
    ///      staking facets in these tests.
    bytes4 internal constant PWN_SELECTOR = bytes4(keccak256("__pwn_attacker_takeover()"));

    function selectors() external pure override returns (bytes4[] memory s) {
        s = new bytes4[](1);
        s[0] = PWN_SELECTOR;
    }
}

/// @title MultiAssetDelegation upgrade-surface audit regression tests (unit: mad-upgrade)
/// @notice MEDIUM (launch-gating, access-control): the facet registry is a SECOND
///         logic-replacement path. `registerFacet` / `registerFacetSelectors` /
///         `clearFacetSelectors` map call selectors to facet contracts that are reached
///         via `fallback()` -> `delegatecall` and therefore execute arbitrary code in
///         THIS contract's storage context. That is functionally equivalent to a UUPS
///         upgrade. The bug: `_authorizeFacetRegistryChange()` was gated by ADMIN_ROLE
///         while `_authorizeUpgrade()` is gated by UPGRADER_ROLE (held by the timelock
///         post-handoff). An ADMIN_ROLE holder could thus install arbitrary logic without
///         going through UPGRADER_ROLE/timelock — an ADMIN_ROLE -> arbitrary-code
///         privilege escalation and an un-gated second upgrade path.
///
///         Remediation: `_authorizeFacetRegistryChange()` now requires UPGRADER_ROLE,
///         matching `_authorizeUpgrade()`. These tests assert the SECURE invariant
///         (registry mutation requires UPGRADER_ROLE, not ADMIN_ROLE). They fail if the
///         fix is reverted — under the old code the ADMIN_ROLE-only caller would succeed.
contract MadUpgradeAuditTest is Test {
    IMultiAssetDelegation internal delegation;
    MultiAssetDelegation internal router;

    address internal admin = makeAddr("admin");
    // Holds ADMIN_ROLE only — NOT UPGRADER_ROLE. Represents a lower-trust operations
    // admin that must NOT be able to swap protocol logic.
    address internal opsAdmin = makeAddr("opsAdmin");
    // Holds UPGRADER_ROLE only — the role that legitimately governs upgrades.
    address internal upgrader = makeAddr("upgrader");
    address internal stranger = makeAddr("stranger");

    uint256 internal constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 internal constant MIN_DELEGATION = 0.1 ether;
    uint16 internal constant OPERATOR_COMMISSION_BPS = 1000;

    // Mirror DelegationStorage role ids (constants are public on the router too).
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 internal constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    bytes4 internal constant PWN_SELECTOR = bytes4(keccak256("__pwn_attacker_takeover()"));

    function setUp() public {
        MultiAssetDelegation impl = new MultiAssetDelegation();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(
                MultiAssetDelegation.initialize, (admin, MIN_OPERATOR_STAKE, MIN_DELEGATION, OPERATOR_COMMISSION_BPS)
            )
        );
        delegation = IMultiAssetDelegation(payable(address(proxy)));
        router = MultiAssetDelegation(payable(address(proxy)));

        // Split the two roles onto distinct holders so a positive ADMIN_ROLE test
        // cannot accidentally pass via an incidental UPGRADER_ROLE grant.
        // `admin` is the genesis DEFAULT_ADMIN_ROLE holder and can administer roles.
        vm.startPrank(admin);
        router.grantRole(ADMIN_ROLE, opsAdmin);
        router.grantRole(UPGRADER_ROLE, upgrader);
        // Strip UPGRADER_ROLE from opsAdmin to be explicit it never had it.
        // (opsAdmin was only granted ADMIN_ROLE above; this is a belt-and-suspenders no-op.)
        vm.stopPrank();
    }

    // Sanity: role separation actually holds in this fixture.
    function test_roleSeparation_sanity() public view {
        assertTrue(router.hasRole(ADMIN_ROLE, opsAdmin), "opsAdmin must hold ADMIN_ROLE");
        assertFalse(router.hasRole(UPGRADER_ROLE, opsAdmin), "opsAdmin must NOT hold UPGRADER_ROLE");
        assertTrue(router.hasRole(UPGRADER_ROLE, upgrader), "upgrader must hold UPGRADER_ROLE");
        assertFalse(router.hasRole(ADMIN_ROLE, upgrader), "upgrader must NOT hold ADMIN_ROLE");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SECURE INVARIANT (the finding): ADMIN_ROLE alone CANNOT mutate the registry.
    // Pre-fix these calls succeeded (ADMIN_ROLE gating) — the priv-esc.
    // ─────────────────────────────────────────────────────────────────────────

    function test_registerFacet_rejectsAdminRoleOnly_M() public {
        MaliciousFacet evil = new MaliciousFacet();
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, opsAdmin, UPGRADER_ROLE)
        );
        vm.prank(opsAdmin);
        router.registerFacet(address(evil));
    }

    function test_registerFacetSelectors_rejectsAdminRoleOnly_M() public {
        MaliciousFacet evil = new MaliciousFacet();
        bytes4[] memory sel = new bytes4[](1);
        sel[0] = PWN_SELECTOR;
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, opsAdmin, UPGRADER_ROLE)
        );
        vm.prank(opsAdmin);
        router.registerFacetSelectors(address(evil), sel);
    }

    function test_clearFacetSelectors_rejectsAdminRoleOnly_M() public {
        // Upgrader installs a real facet first so there's something to clear.
        StakingViewsFacet views = new StakingViewsFacet();
        vm.prank(upgrader);
        router.registerFacet(address(views));

        bytes4[] memory sel = views.selectors();
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, opsAdmin, UPGRADER_ROLE)
        );
        vm.prank(opsAdmin);
        router.clearFacetSelectors(sel);
    }

    function test_registerFacet_rejectsUnprivileged_M() public {
        MaliciousFacet evil = new MaliciousFacet();
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, stranger, UPGRADER_ROLE)
        );
        vm.prank(stranger);
        router.registerFacet(address(evil));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POSITIVE PATH: UPGRADER_ROLE (same role that gates _authorizeUpgrade) CAN
    // mutate the registry. Proves the fix narrows, not breaks, the surface — and
    // keeps the deploy/test wiring (deployer holds UPGRADER_ROLE at registration).
    // ─────────────────────────────────────────────────────────────────────────

    function test_registerFacet_allowsUpgraderRole_M() public {
        StakingViewsFacet views = new StakingViewsFacet();
        bytes4[] memory sel = views.selectors();
        require(sel.length > 0, "fixture: facet must expose selectors");

        vm.prank(upgrader);
        router.registerFacet(address(views));

        // The selector now routes to the installed facet — registry write took effect.
        assertEq(
            router.facetForSelector(sel[0]),
            address(views),
            "UPGRADER_ROLE registration must install the facet"
        );
    }

    function test_clearFacetSelectors_allowsUpgraderRole_M() public {
        StakingViewsFacet views = new StakingViewsFacet();
        bytes4[] memory sel = views.selectors();

        vm.prank(upgrader);
        router.registerFacet(address(views));
        assertEq(router.facetForSelector(sel[0]), address(views), "precondition: facet installed");

        vm.prank(upgrader);
        router.clearFacetSelectors(sel);

        assertEq(router.facetForSelector(sel[0]), address(0), "UPGRADER_ROLE clear must remove the route");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // The two logic-replacement paths are now gated by the SAME role: both the
    // UUPS upgrade path (_authorizeUpgrade) and the facet registry path require
    // UPGRADER_ROLE. ADMIN_ROLE governs neither. (Reverting the fix breaks this:
    // the registry would fall back to ADMIN_ROLE and the parity assertion fails.)
    // ─────────────────────────────────────────────────────────────────────────

    function test_upgradeAndRegistry_gatedBySameRole_M() public {
        // Registry path: ADMIN_ROLE-only holder is rejected (asserted above);
        // here we assert UPGRADER_ROLE is the gate, which is the upgrade gate too.
        MaliciousFacet evil = new MaliciousFacet();

        // ADMIN_ROLE-only -> rejected on the UPGRADER_ROLE check.
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, opsAdmin, UPGRADER_ROLE)
        );
        vm.prank(opsAdmin);
        router.registerFacet(address(evil));

        // UPGRADER_ROLE -> accepted.
        vm.prank(upgrader);
        router.registerFacet(address(evil));
        assertEq(router.facetForSelector(PWN_SELECTOR), address(evil), "upgrader install must take effect");
    }
}
