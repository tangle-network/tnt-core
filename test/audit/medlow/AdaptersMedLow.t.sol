// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { IAssetAdapter } from "../../../src/staking/adapters/IAssetAdapter.sol";
import { StandardAssetAdapter } from "../../../src/staking/adapters/StandardAssetAdapter.sol";
import { RebasingAssetAdapter } from "../../../src/staking/adapters/RebasingAssetAdapter.sol";

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract AdaptersMockERC20 is ERC20 {
    constructor() ERC20("Mock", "MOCK") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @title AdaptersMedLow
/// @notice M (access-control): adapters custody 100% of delegated balances, and
///         the delegation manager is the only address that can withdraw the pool.
///         A plain `onlyOwner` repoint of `delegationManager` let a single
///         compromised owner key swing custody to an attacker EOA and drain
///         everything in one transaction.
///
///         ROOT-CAUSE FIX (asserted here as the SECURE invariant):
///           - `setDelegationManager` is bootstrap-only: it works exactly once,
///             while the manager is unset (deploy-time wiring, pool empty), and
///             reverts `DelegationManagerAlreadySet` thereafter.
///           - Rotating a live manager requires the 2-step propose/accept flow:
///             owner `proposeDelegationManager` (observable event), then the
///             PENDING address itself `acceptDelegationManager`. The owner key
///             alone can no longer make a repoint take effect.
///
///         Every test fails if the fix is reverted (the old code would let the
///         second `setDelegationManager` succeed and let the owner instantly
///         drain via the repointed manager).
contract AdaptersMedLowTest is Test {
    AdaptersMockERC20 internal token;
    StandardAssetAdapter internal std;
    RebasingAssetAdapter internal reb;

    address internal owner = makeAddr("owner");
    address internal manager = makeAddr("manager");
    address internal attacker = makeAddr("attacker");
    address internal attackerSink = makeAddr("attackerSink");
    address internal newManager = makeAddr("newManager");
    address internal depositor = makeAddr("depositor");

    function setUp() public {
        token = new AdaptersMockERC20();

        vm.startPrank(owner);
        std = new StandardAssetAdapter(address(token), owner);
        std.setDelegationManager(manager); // bootstrap (allowed: manager unset)
        reb = new RebasingAssetAdapter(address(token), owner);
        reb.setDelegationManager(manager); // bootstrap (allowed: manager unset)
        vm.stopPrank();

        token.mint(depositor, 1_000 ether);
        vm.prank(depositor);
        token.approve(address(std), type(uint256).max);
        vm.prank(depositor);
        token.approve(address(reb), type(uint256).max);
    }

    // ── Bootstrap is one-shot ──────────────────────────────────────────────────

    function test_setDelegationManager_bootstrapOnce_thenBlocked_Standard_M() public {
        assertEq(std.delegationManager(), manager, "bootstrap wired the manager");

        // SECURE INVARIANT: a second direct set must revert; the owner cannot
        // re-point an already-wired adapter via the plain setter.
        vm.prank(owner);
        vm.expectRevert(StandardAssetAdapter.DelegationManagerAlreadySet.selector);
        std.setDelegationManager(attacker);

        assertEq(std.delegationManager(), manager, "manager unchanged after blocked re-set");
    }

    function test_setDelegationManager_bootstrapOnce_thenBlocked_Rebasing_M() public {
        assertEq(reb.delegationManager(), manager, "bootstrap wired the manager");

        vm.prank(owner);
        vm.expectRevert(RebasingAssetAdapter.DelegationManagerAlreadySet.selector);
        reb.setDelegationManager(attacker);

        assertEq(reb.delegationManager(), manager, "manager unchanged after blocked re-set");
    }

    // ── The drain attack the finding describes is now impossible ───────────────

    function test_ownerCannotInstantlyRepointAndDrain_Standard_M() public {
        // Pool is funded through the legitimate manager.
        vm.prank(manager);
        std.deposit(depositor, 500 ether);
        assertEq(token.balanceOf(address(std)), 500 ether, "pool funded");

        // Compromised owner tries the old one-shot repoint to an attacker sink.
        vm.prank(owner);
        vm.expectRevert(StandardAssetAdapter.DelegationManagerAlreadySet.selector);
        std.setDelegationManager(attackerSink);

        // attackerSink never became the manager, so it cannot withdraw the pool.
        vm.prank(attackerSink);
        vm.expectRevert(StandardAssetAdapter.OnlyDelegationManager.selector);
        std.withdraw(attackerSink, 500 ether);

        assertEq(token.balanceOf(address(std)), 500 ether, "pool not drained");
        assertEq(token.balanceOf(attackerSink), 0, "attacker got nothing");
    }

    function test_ownerCannotInstantlyRepointAndDrain_Rebasing_M() public {
        vm.prank(manager);
        reb.deposit(depositor, 500 ether);
        assertEq(token.balanceOf(address(reb)), 500 ether, "pool funded");

        vm.prank(owner);
        vm.expectRevert(RebasingAssetAdapter.DelegationManagerAlreadySet.selector);
        reb.setDelegationManager(attackerSink);

        vm.prank(attackerSink);
        vm.expectRevert(RebasingAssetAdapter.OnlyDelegationManager.selector);
        reb.withdraw(attackerSink, 100 ether);

        assertEq(token.balanceOf(address(reb)), 500 ether, "pool not drained");
        assertEq(token.balanceOf(attackerSink), 0, "attacker got nothing");
    }

    // ── 2-step rotation: proposal does not take effect until accepted ──────────

    function test_proposeDoesNotMoveCustodyUntilAccepted_Standard_M() public {
        vm.prank(manager);
        std.deposit(depositor, 300 ether);

        // Owner proposes a new manager — custody MUST still belong to the old one.
        vm.prank(owner);
        vm.expectEmit(true, true, false, false, address(std));
        emit StandardAssetAdapter.DelegationManagerProposed(manager, newManager);
        std.proposeDelegationManager(newManager);

        assertEq(std.delegationManager(), manager, "live manager unchanged by proposal");
        assertEq(std.pendingDelegationManager(), newManager, "pending recorded");

        // SECURE INVARIANT: the merely-proposed manager cannot act yet.
        vm.prank(newManager);
        vm.expectRevert(StandardAssetAdapter.OnlyDelegationManager.selector);
        std.withdraw(newManager, 300 ether);

        // And the old manager still works (rotation is not yet live).
        vm.prank(manager);
        uint256 out = std.withdraw(depositor, 100 ether);
        assertEq(out, 100 ether, "old manager still operational pre-acceptance");
    }

    function test_onlyPendingCanAccept_Standard_M() public {
        vm.prank(owner);
        std.proposeDelegationManager(newManager);

        // An arbitrary address (even the owner) cannot accept on the pending's behalf.
        vm.prank(attacker);
        vm.expectRevert(StandardAssetAdapter.NotPendingDelegationManager.selector);
        std.acceptDelegationManager();

        vm.prank(owner);
        vm.expectRevert(StandardAssetAdapter.NotPendingDelegationManager.selector);
        std.acceptDelegationManager();

        assertEq(std.delegationManager(), manager, "manager unchanged until pending accepts");
    }

    function test_fullRotation_endToEnd_Standard_M() public {
        vm.prank(manager);
        std.deposit(depositor, 200 ether);

        vm.prank(owner);
        std.proposeDelegationManager(newManager);

        // Pending claims the role.
        vm.prank(newManager);
        vm.expectEmit(true, true, false, false, address(std));
        emit StandardAssetAdapter.DelegationManagerSet(manager, newManager);
        std.acceptDelegationManager();

        assertEq(std.delegationManager(), newManager, "rotation now live");
        assertEq(std.pendingDelegationManager(), address(0), "pending cleared");

        // Old manager is demoted.
        vm.prank(manager);
        vm.expectRevert(StandardAssetAdapter.OnlyDelegationManager.selector);
        std.withdraw(depositor, 1 ether);

        // New manager is operational.
        vm.prank(newManager);
        uint256 out = std.withdraw(depositor, 200 ether);
        assertEq(out, 200 ether, "new manager operational post-acceptance");
    }

    function test_fullRotation_endToEnd_Rebasing_M() public {
        vm.prank(manager);
        reb.deposit(depositor, 200 ether);

        vm.prank(owner);
        reb.proposeDelegationManager(newManager);
        assertEq(reb.delegationManager(), manager, "live manager unchanged by proposal");

        vm.prank(newManager);
        reb.acceptDelegationManager();
        assertEq(reb.delegationManager(), newManager, "rotation now live");
        assertEq(reb.pendingDelegationManager(), address(0), "pending cleared");

        vm.prank(manager);
        vm.expectRevert(RebasingAssetAdapter.OnlyDelegationManager.selector);
        reb.withdraw(depositor, 1 ether);
    }

    // ── Auth gates on the new entry points ────────────────────────────────────

    function test_proposeIsOwnerGated_Standard_M() public {
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, attacker));
        std.proposeDelegationManager(newManager);
    }

    function test_proposeIsOwnerGated_Rebasing_M() public {
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, attacker));
        reb.proposeDelegationManager(newManager);
    }

    // ── Preserved pre-existing behaviors (no regressions) ─────────────────────

    function test_proposeRejectsZeroAddress_Standard() public {
        vm.prank(owner);
        vm.expectRevert(IAssetAdapter.ZeroAddress.selector);
        std.proposeDelegationManager(address(0));
    }

    function test_bootstrapRejectsZeroAddress_Standard() public {
        StandardAssetAdapter fresh = new StandardAssetAdapter(address(token), owner);
        vm.prank(owner);
        vm.expectRevert(IAssetAdapter.ZeroAddress.selector);
        fresh.setDelegationManager(address(0));
    }

    function test_bootstrapRejectsZeroAddress_Rebasing() public {
        RebasingAssetAdapter fresh = new RebasingAssetAdapter(address(token), owner);
        vm.prank(owner);
        vm.expectRevert(IAssetAdapter.ZeroAddress.selector);
        fresh.setDelegationManager(address(0));
    }
}
