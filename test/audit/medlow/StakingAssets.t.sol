// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DelegationTestHarness } from "../../staking/DelegationTestHarness.sol";
import { StandardAssetAdapter } from "../../../src/staking/adapters/StandardAssetAdapter.sol";
import { Types } from "../../../src/libraries/Types.sol";

/// @title StakingAssetsFacet med/low regression tests
/// @notice M: `enableAsset` / `enableAssetWithAdapter` must NOT reset the live
///         `currentDeposits` counter when (re-)enabling an asset.
///
///         Root cause: both entry points used to overwrite the whole AssetConfig
///         with `currentDeposits: 0`. DepositManager._executeWithdraw decrements
///         `currentDeposits` with CHECKED arithmetic, so a counter that was reset
///         to 0 while balances are still held underflows and reverts EVERY
///         holder's withdrawal — bricking exits for a live asset. Re-enabling a
///         disabled-but-still-funded asset is a legitimate admin action, so the
///         deposit counter has to survive the disable→enable round-trip.
///
///         These tests assert the SECURE invariant: the counter is preserved and
///         withdrawals continue to settle. They fail if the fix is reverted
///         (the executeWithdraw call underflows).
contract StakingAssetsTest is DelegationTestHarness {
    StandardAssetAdapter internal adapter;

    function setUp() public override {
        super.setUp();
        adapter = new StandardAssetAdapter(address(token), admin);
        vm.startPrank(admin);
        adapter.setDelegationManager(address(delegation));
        vm.stopPrank();
    }

    function _currentDeposits(address tokenAddr) internal view returns (uint256) {
        return delegation.getAssetConfig(tokenAddr).currentDeposits;
    }

    // ── M: re-enable must preserve currentDeposits (enableAsset path) ──────────

    function test_enableAsset_preservesCurrentDeposits_onReEnable_M() public {
        // Live deposit through the no-adapter path the harness configures.
        _depositErc20(delegator1, address(token), 10 ether);
        assertEq(_currentDeposits(address(token)), 10 ether, "counter should track live deposit");

        // Admin disables, then re-enables with brand new params (e.g. raising the cap).
        vm.startPrank(admin);
        delegation.disableAsset(address(token));
        delegation.enableAsset(address(token), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10_000);
        vm.stopPrank();

        // SECURE INVARIANT 1: the deposit counter survived the round-trip.
        assertEq(
            _currentDeposits(address(token)),
            10 ether,
            "currentDeposits must NOT be reset by re-enable"
        );

        // SECURE INVARIANT 2: holder can still exit; the checked decrement in
        // _executeWithdraw does not underflow. (Pre-fix this whole block reverts.)
        uint256 balBefore = token.balanceOf(delegator1);
        _scheduleWithdraw(delegator1, address(token), 10 ether);
        _advanceRounds(DEFAULT_DELAY + 1);
        _executeWithdraw(delegator1);

        assertEq(token.balanceOf(delegator1) - balBefore, 10 ether, "holder must get funds back");
        assertEq(_currentDeposits(address(token)), 0, "counter zeroes only via real withdrawal");
    }

    function test_enableAsset_preservesCurrentDeposits_whileLive_noDisable_M() public {
        // Re-configuring a still-enabled asset (no disable) must also keep the counter.
        _depositErc20(delegator1, address(token), 7 ether);
        assertEq(_currentDeposits(address(token)), 7 ether);

        vm.prank(admin);
        delegation.enableAsset(address(token), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10_000);

        assertEq(_currentDeposits(address(token)), 7 ether, "live re-enable must not reset counter");
    }

    // ── M: same root bug, enableAssetWithAdapter path ─────────────────────────

    function test_enableAssetWithAdapter_preservesCurrentDeposits_onReEnable_M() public {
        // token2 starts adapter-free; deposit, then re-enable WITH an adapter.
        // (token2 has no adapter and no deposits, so attaching one is allowed.)
        _depositErc20(delegator1, address(token2), 5 ether);
        assertEq(_currentDeposits(address(token2)), 5 ether);

        // Need an adapter that supports token2.
        StandardAssetAdapter token2Adapter = new StandardAssetAdapter(address(token2), admin);
        vm.startPrank(admin);
        token2Adapter.setDelegationManager(address(delegation));
        delegation.disableAsset(address(token2));
        // registerAdapter would revert (deposits exist), but enableAssetWithAdapter
        // re-attaches the adapter mapping directly. The accounting counter must persist.
        delegation.enableAssetWithAdapter(
            address(token2), address(token2Adapter), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10_000
        );
        vm.stopPrank();

        assertEq(
            _currentDeposits(address(token2)),
            5 ether,
            "enableAssetWithAdapter must NOT reset currentDeposits on re-enable"
        );
    }

    // ── Non-regression: first-time enable still starts at zero ────────────────

    function test_enableAsset_firstTime_startsAtZero() public {
        // A never-configured asset must read zero before, and start at zero after enabling.
        Types.AssetConfig memory cfgBefore = delegation.getAssetConfig(address(0x1234));
        assertEq(cfgBefore.currentDeposits, 0, "never-configured asset reads 0");
        assertFalse(cfgBefore.enabled);

        vm.prank(admin);
        delegation.enableAsset(address(0x1234), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10_000);

        Types.AssetConfig memory cfgAfter = delegation.getAssetConfig(address(0x1234));
        assertTrue(cfgAfter.enabled, "newly enabled");
        assertEq(cfgAfter.currentDeposits, 0, "first-time enable starts at zero");
        assertEq(cfgAfter.depositCap, 0);
        assertEq(cfgAfter.minDelegation, MIN_DELEGATION);
    }
}
