// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DelegationTestHarness } from "../staking/DelegationTestHarness.sol";
import { StakingAssetsFacet } from "../../src/facets/staking/StakingAssetsFacet.sol";
import { StandardAssetAdapter } from "../../src/staking/adapters/StandardAssetAdapter.sol";

/// @title AdapterChangeWhileDepositsExistTest
/// @notice Round 4 audit S-2: `registerAdapter` and `removeAdapter` must reject
///         when the asset has live deposits (`currentDeposits != 0`). Switching
///         the adapter under load either strands held balances in the old
///         adapter or double-counts them in the new one. The protocol exposes
///         `startAdapterMigration` (M-8) for the controlled drain path; raw
///         register/remove is now restricted to the zero-deposits case.
contract AdapterChangeWhileDepositsExistTest is DelegationTestHarness {
    StandardAssetAdapter internal adapter;
    StandardAssetAdapter internal newAdapter;

    function setUp() public override {
        super.setUp();
        // The harness enables `token` with no adapter. Build two real adapters
        // pointing at the same token so we can exercise both register and
        // remove paths.
        adapter = new StandardAssetAdapter(address(token), admin);
        newAdapter = new StandardAssetAdapter(address(token), admin);
        vm.startPrank(admin);
        adapter.setDelegationManager(address(delegation));
        newAdapter.setDelegationManager(address(delegation));
        vm.stopPrank();
    }

    function test_registerAdapter_blockedWhileDepositsExist_S2() public {
        // Bootstrap deposits via the no-adapter path (the harness leaves the
        // token enabled with no adapter). Approval target is `delegation`.
        vm.startPrank(delegator1);
        token.approve(address(delegation), 10 ether);
        delegation.depositERC20(address(token), 10 ether);
        vm.stopPrank();

        // Now `currentDeposits == 10 ether`. Registering an adapter for the
        // first time must revert because admin cannot retroactively migrate
        // the live balance into the adapter without going through M-8.
        vm.prank(admin);
        vm.expectRevert(
            abi.encodeWithSelector(
                StakingAssetsFacet.AdapterChangeWhileDepositsExist.selector, address(token), 10 ether
            )
        );
        delegation.registerAdapter(address(token), address(adapter));
    }

    function test_removeAdapter_blockedWhileDepositsExist_S2() public {
        // Register adapter first (zero deposits, so allowed).
        vm.prank(admin);
        delegation.registerAdapter(address(token), address(adapter));

        // Deposit through the adapter — approval target is the adapter.
        vm.startPrank(delegator1);
        token.approve(address(adapter), 10 ether);
        delegation.depositERC20(address(token), 10 ether);
        vm.stopPrank();

        // Removing while balances live in the adapter would silently strand
        // them — must revert.
        vm.prank(admin);
        vm.expectRevert(
            abi.encodeWithSelector(
                StakingAssetsFacet.AdapterChangeWhileDepositsExist.selector, address(token), 10 ether
            )
        );
        delegation.removeAdapter(address(token));
    }

    function test_registerAdapter_allowedWhenDepositsAreZero_S2() public {
        // No deposits yet — register/remove should still be free.
        vm.prank(admin);
        delegation.registerAdapter(address(token), address(adapter));
        vm.prank(admin);
        delegation.removeAdapter(address(token));
        // And again after both ops, deposits are still zero.
        vm.prank(admin);
        delegation.registerAdapter(address(token), address(newAdapter));
    }
}
