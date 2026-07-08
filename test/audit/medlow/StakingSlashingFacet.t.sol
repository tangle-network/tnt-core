// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { IMultiAssetDelegation } from "../../../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../../src/staking/MultiAssetDelegation.sol";
import { Types } from "../../../src/libraries/Types.sol";

import { StakingOperatorsFacet } from "../../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingUnstakeWithdrawFacet } from "../../../src/facets/staking/StakingUnstakeWithdrawFacet.sol";
import { StakingSlashingFacet } from "../../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../../src/facets/staking/StakingAdminFacet.sol";

/// @title StakingSlashingFacet audit regression tests (MED/LOW unit: staking-slashing-facet)
/// @notice Covers [F-SLA-2]: advanceRound()/snapshotOperator() were permissionless, and
///         snapshotOperator() was re-writable within a round. Each test asserts the SECURE
///         invariant after remediation — reverting the fix in StakingSlashingFacet.sol makes
///         the matching test fail.
contract StakingSlashingFacetAuditTest is Test {
    IMultiAssetDelegation internal delegation;
    // Concrete handle for views (e.g. getSnapshot) that live on the router, not the interface.
    MultiAssetDelegation internal router;

    address internal admin = makeAddr("admin");
    address internal slasher = makeAddr("slasher");
    address internal attacker = makeAddr("attacker");
    address internal operator = makeAddr("operator");

    uint256 internal constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 internal constant MIN_DELEGATION = 0.1 ether;
    uint16 internal constant OPERATOR_COMMISSION_BPS = 1000;
    uint256 internal constant OPERATOR_BOND = 10 ether;

    // Mirrors DelegationStorage.SLASHER_ROLE = keccak256("SLASHER_ROLE").
    bytes32 internal constant SLASHER_ROLE = keccak256("SLASHER_ROLE");

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
        router.registerFacet(address(new StakingUnstakeWithdrawFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));

        // Grant SLASHER_ROLE only to `slasher`; `attacker` and `address(this)` stay unprivileged.
        delegation.addSlasher(slasher);
        vm.stopPrank();

        vm.deal(operator, 100 ether);
        vm.prank(operator);
        delegation.registerOperator{ value: OPERATOR_BOND }();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // [F-SLA-2] advanceRound() is a PERMISSIONLESS, rate-limited crank
    // ─────────────────────────────────────────────────────────────────────────
    // Gating advanceRound behind SLASHER_ROLE would let an offline slasher freeze
    // time-based unbonding/withdrawal delays protocol-wide (a liveness hazard worse
    // than the LOW finding). Racing is prevented by _advanceRound's roundDuration rate
    // limit, and snapshot integrity is protected separately (gated + write-once below).

    function test_advanceRound_isPermissionlessCrank() public {
        uint64 roundBefore = delegation.currentRound();

        // Any caller may crank the round — withdrawals must not depend on a privileged actor.
        vm.prank(attacker);
        delegation.advanceRound();

        assertEq(delegation.currentRound(), roundBefore + 1, "permissionless crank could not advance round");
    }

    function test_advanceRound_succeedsForSlasher() public {
        uint64 roundBefore = delegation.currentRound();

        vm.prank(slasher);
        delegation.advanceRound();

        assertEq(delegation.currentRound(), roundBefore + 1, "slasher could not advance round");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // [F-SLA-2] snapshotOperator() must be SLASHER_ROLE-gated
    // ─────────────────────────────────────────────────────────────────────────

    function test_snapshotOperator_revertsForNonSlasher() public {
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, attacker, SLASHER_ROLE)
        );
        vm.prank(attacker);
        delegation.snapshotOperator(operator);

        // No snapshot must have been written by the unauthorized caller.
        Types.OperatorSnapshot memory snap = router.getSnapshot(delegation.currentRound(), operator);
        assertEq(snap.stake, 0, "unauthorized caller wrote a snapshot");
        assertEq(snap.totalDelegated, 0, "unauthorized caller wrote a snapshot");
    }

    function test_snapshotOperator_succeedsForSlasherAndRecordsStake() public {
        uint64 round = delegation.currentRound();

        vm.prank(slasher);
        delegation.snapshotOperator(operator);

        // Snapshot must record the operator's actual self-bond as the slashing basis.
        Types.OperatorSnapshot memory snap = router.getSnapshot(round, operator);
        assertEq(snap.stake, OPERATOR_BOND, "snapshot stake mismatch");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // [F-SLA-2] snapshotOperator() must be write-once per round
    // ─────────────────────────────────────────────────────────────────────────

    function test_snapshotOperator_writeOncePerRound() public {
        uint64 round = delegation.currentRound();

        vm.prank(slasher);
        delegation.snapshotOperator(operator);

        // A second snapshot in the same round must revert, even from an authorized slasher,
        // so the historical stake basis a slash is computed against cannot be rewritten.
        vm.expectRevert(
            abi.encodeWithSelector(StakingSlashingFacet.SnapshotAlreadyTaken.selector, round, operator)
        );
        vm.prank(slasher);
        delegation.snapshotOperator(operator);
    }

    function test_snapshotOperator_writeOnceIsPerRoundNotPermanent() public {
        vm.prank(slasher);
        delegation.snapshotOperator(operator);

        // Advance the round (time-gated), then a fresh snapshot for the new round must succeed.
        vm.prank(slasher);
        delegation.advanceRound();

        uint64 newRound = delegation.currentRound();
        vm.prank(slasher);
        delegation.snapshotOperator(operator);

        Types.OperatorSnapshot memory snap = router.getSnapshot(newRound, operator);
        assertEq(snap.stake, OPERATOR_BOND, "new-round snapshot not recorded");
    }
}
