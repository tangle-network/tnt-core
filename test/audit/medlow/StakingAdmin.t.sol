// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { IMultiAssetDelegation } from "../../../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../../src/staking/MultiAssetDelegation.sol";

import { StakingOperatorsFacet } from "../../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../../src/facets/staking/StakingAdminFacet.sol";

/// @title StakingAdminFacet audit regression tests (MED/LOW unit: staking-admin)
/// @notice Covers the launch-gating LOW finding: `setTangle` granted TANGLE_ROLE to the new
///         core but never revoked it from the previously configured core. A stale core kept
///         TANGLE_ROLE and could keep calling add/removeBlueprintForOperator after governance
///         had rotated away from it. The remediation revokes TANGLE_ROLE from the prior
///         `_tangleCore` before granting it to the new one (grant/revoke toggle, exactly one
///         holder at a time). Reverting the fix in StakingAdminFacet.setTangle makes the
///         "old core loses access" tests fail.
contract StakingAdminAuditTest is Test {
    IMultiAssetDelegation internal delegation;
    // Concrete handle for AccessControl views (hasRole) that live on the router.
    MultiAssetDelegation internal router;

    address internal admin = makeAddr("admin");
    address internal oldCore = makeAddr("oldTangleCore");
    address internal newCore = makeAddr("newTangleCore");
    address internal operator = makeAddr("operator");

    uint256 internal constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 internal constant MIN_DELEGATION = 0.1 ether;
    uint16 internal constant OPERATOR_COMMISSION_BPS = 1000;
    uint256 internal constant OPERATOR_BOND = 10 ether;

    uint64 internal constant BLUEPRINT_ID = 7;

    // Mirrors DelegationStorage.TANGLE_ROLE = keccak256("TANGLE_ROLE").
    bytes32 internal constant TANGLE_ROLE = keccak256("TANGLE_ROLE");

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

        vm.startPrank(admin);
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));
        vm.stopPrank();

        // Register an Active operator so add/removeBlueprintForOperator reach the real
        // TANGLE_ROLE-gated write path (an unauthorized caller must revert on the role
        // check BEFORE any operator-status check).
        vm.deal(operator, 100 ether);
        vm.prank(operator);
        delegation.registerOperator{ value: OPERATOR_BOND }();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Rotation revokes TANGLE_ROLE from the stale core (the core finding).
    // ─────────────────────────────────────────────────────────────────────────

    function test_setTangle_rotation_revokesPriorCoreRole() public {
        vm.prank(admin);
        delegation.setTangle(oldCore);
        assertTrue(router.hasRole(TANGLE_ROLE, oldCore), "old core should start with TANGLE_ROLE");

        vm.prank(admin);
        delegation.setTangle(newCore);

        // SECURE INVARIANT: rotating away revokes the stale core's role and grants only the new one.
        assertFalse(router.hasRole(TANGLE_ROLE, oldCore), "stale core retained TANGLE_ROLE after rotation");
        assertTrue(router.hasRole(TANGLE_ROLE, newCore), "new core was not granted TANGLE_ROLE");
    }

    function test_staleCore_cannotAddBlueprintAfterRotation() public {
        vm.prank(admin);
        delegation.setTangle(oldCore);
        // Sanity: while configured, the old core can write.
        vm.prank(oldCore);
        delegation.addBlueprintForOperator(operator, BLUEPRINT_ID);

        vm.prank(admin);
        delegation.setTangle(newCore);

        // SECURE INVARIANT: after rotation the stale core is rejected on the role check.
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, oldCore, TANGLE_ROLE)
        );
        vm.prank(oldCore);
        delegation.addBlueprintForOperator(operator, BLUEPRINT_ID);
    }

    function test_staleCore_cannotRemoveBlueprintAfterRotation() public {
        vm.prank(admin);
        delegation.setTangle(oldCore);

        vm.prank(admin);
        delegation.setTangle(newCore);

        // SECURE INVARIANT: stale core cannot call the removal path either.
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, oldCore, TANGLE_ROLE)
        );
        vm.prank(oldCore);
        delegation.removeBlueprintForOperator(operator, BLUEPRINT_ID);
    }

    function test_newCore_canManageBlueprintsAfterRotation() public {
        vm.prank(admin);
        delegation.setTangle(oldCore);
        vm.prank(admin);
        delegation.setTangle(newCore);

        // The freshly configured core retains full blueprint-management access.
        vm.prank(newCore);
        delegation.addBlueprintForOperator(operator, BLUEPRINT_ID);
        vm.prank(newCore);
        delegation.removeBlueprintForOperator(operator, BLUEPRINT_ID);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Edge cases that must not regress the rotation logic.
    // ─────────────────────────────────────────────────────────────────────────

    function test_setTangle_firstGrant_fromZeroCore() public {
        // _tangleCore starts at address(0); first set must just grant, never attempt a
        // spurious revoke of the zero address.
        vm.prank(admin);
        delegation.setTangle(newCore);

        assertTrue(router.hasRole(TANGLE_ROLE, newCore), "first core not granted TANGLE_ROLE");
        assertFalse(router.hasRole(TANGLE_ROLE, address(0)), "zero address must never hold TANGLE_ROLE");
    }

    function test_setTangle_idempotentForSameCore() public {
        vm.prank(admin);
        delegation.setTangle(newCore);
        // Re-setting the same address is a no-op and must NOT revoke the role we just granted.
        vm.prank(admin);
        delegation.setTangle(newCore);

        assertTrue(router.hasRole(TANGLE_ROLE, newCore), "idempotent re-set wrongly dropped TANGLE_ROLE");
    }

    function test_setTangle_rotateToZero_revokesPriorCore() public {
        vm.prank(admin);
        delegation.setTangle(oldCore);

        // Disabling the core (set to zero) must revoke the prior holder and grant no one.
        vm.prank(admin);
        delegation.setTangle(address(0));

        assertFalse(router.hasRole(TANGLE_ROLE, oldCore), "rotation to zero did not revoke prior core");
        assertFalse(router.hasRole(TANGLE_ROLE, address(0)), "zero address must never hold TANGLE_ROLE");

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, oldCore, TANGLE_ROLE)
        );
        vm.prank(oldCore);
        delegation.addBlueprintForOperator(operator, BLUEPRINT_ID);
    }

    function test_setTangle_onlyAdmin() public {
        bytes32 adminRole = keccak256("ADMIN_ROLE");
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, oldCore, adminRole)
        );
        vm.prank(oldCore);
        delegation.setTangle(newCore);
    }

    function test_setTangle_emitsRotationEvent() public {
        vm.prank(admin);
        delegation.setTangle(oldCore);

        vm.expectEmit(true, true, false, false, address(delegation));
        emit StakingAdminFacet.TangleCoreRotated(oldCore, newCore);
        vm.prank(admin);
        delegation.setTangle(newCore);
    }
}
