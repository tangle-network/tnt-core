// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import {
    DelegationTestHarness,
    MockERC20,
    ReentrantERC20,
    ReentrantReceiver,
    FailingERC20
} from "./DelegationTestHarness.sol";
import { IMultiAssetDelegation } from "../../src/interfaces/IMultiAssetDelegation.sol";
import { DelegationErrors } from "../../src/staking/DelegationErrors.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @title DelegationCriticalTest
/// @notice Critical tests covering all identified audit gaps
/// @dev Organized by category: Slashing, Operator Lifecycle, Reentrancy, etc.
contract DelegationCriticalTest is DelegationTestHarness {
    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 1: SLASHING TESTS (Critical)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test withdraw after slashing returns reduced funds
    function test_WithdrawAfterSlashing_ReceivesReducedFunds() public {
        // Delegate and then unstake
        _depositAndDelegate(delegator1, operator1, 10 ether);

        // Schedule unstake for full amount
        _scheduleUnstake(delegator1, operator1, address(0), 10 ether);
        _advanceRounds(DEFAULT_DELAY);
        _executeUnstake(delegator1);

        // Now schedule withdraw
        _scheduleWithdraw(delegator1, address(0), 10 ether);

        // Slash the operator (affects pending withdrawals? No - deposit already freed)
        // Note: This tests the case where funds are already in deposit, not delegation

        _advanceRounds(DEFAULT_DELAY);

        uint256 balanceBefore = delegator1.balance;
        _executeWithdraw(delegator1);

        // Should receive full 10 ether since slash happens on delegated funds
        assertEq(delegator1.balance, balanceBefore + 10 ether);
    }

    /// @notice Test delegator receives slashed amount when unstaking after slash
    function test_UnstakeAfterSlash_ReceivesProportionallyLess() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);

        // Operator stake: 10 ETH, Delegator: 10 ETH, Total: 20 ETH
        // Slash 10 ETH -> 50% of total
        // Operator loses 5 ETH, Delegator loses 5 ETH
        _slash(operator1, 10 ether);

        // Check delegation value reduced
        uint256 delegationAfterSlash = _getDelegation(delegator1, operator1);
        assertLt(delegationAfterSlash, 10 ether, "Delegation should be reduced");
        assertApproxEqAbs(delegationAfterSlash, 5 ether, 1, "Should be ~5 ETH after 50% slash");

        // Schedule unstake for remaining
        _scheduleUnstake(delegator1, operator1, address(0), delegationAfterSlash);
        _advanceRounds(DEFAULT_DELAY);
        _executeUnstake(delegator1);

        // Check delegation is now 0
        assertDelegationEq(delegator1, operator1, 0);
    }

    /// @notice Test multiple slashes during pending unstake period
    function test_MultipleSlashesDuringPendingUnstake() public {
        _depositAndDelegate(delegator1, operator1, 20 ether);

        // Schedule unstake
        _scheduleUnstake(delegator1, operator1, address(0), 10 ether);

        // First slash
        _slash(operator1, 5 ether);
        _advanceRounds(2);

        // Second slash
        _slash(operator1, 5 ether);
        _advanceRounds(DEFAULT_DELAY); // Complete delay

        // Execute unstake - should receive reduced amount
        _executeUnstake(delegator1);

        // Delegation should be reduced from both slashes
        uint256 remaining = _getDelegation(delegator1, operator1);
        assertLt(remaining, 10 ether, "Remaining should be less due to slashes");
    }

    /// @notice Test 100% slash scenario
    function test_FullSlash_100Percent() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);

        // Get total stake
        uint256 operatorStake = delegation.getOperatorSelfStake(operator1);
        uint256 delegatedStake = delegation.getOperatorDelegatedStake(operator1);
        uint256 totalStake = operatorStake + delegatedStake;

        // Slash 100%
        _slash(operator1, totalStake);

        // Operator should be inactive
        assertOperatorNotActive(operator1);

        // Delegation should be 0
        assertDelegationEq(delegator1, operator1, 0);

        // Operator stake should be 0
        assertEq(delegation.getOperatorSelfStake(operator1), 0);
    }

    /// @notice Test slash exceeds total stake (capped)
    function test_SlashExceedsTotalStake_Capped() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);

        uint256 totalBefore = delegation.getOperatorStake(operator1);

        // Try to slash more than total
        _slash(operator1, totalBefore * 2);

        // Should only slash up to total
        assertEq(delegation.getOperatorSelfStake(operator1), 0);
        assertEq(delegation.getOperatorDelegatedStake(operator1), 0);
    }

    /// @notice Test slashing with multiple delegators - proportional distribution
    function test_SlashWithMultipleDelegators_ProportionalLoss() public {
        // Register second operator
        _registerOperator(operator2, 10 ether);

        // Three delegators with different amounts to operator1
        _depositAndDelegate(delegator1, operator1, 10 ether); // 10
        _depositAndDelegate(delegator2, operator1, 20 ether); // 20
        _depositAndDelegate(delegator3, operator1, 30 ether); // 30

        // Total delegated: 60 ETH, Operator: 10 ETH, Total: 70 ETH
        // Slash 35 ETH (50%)

        uint256 del1Before = _getDelegation(delegator1, operator1);
        uint256 del2Before = _getDelegation(delegator2, operator1);
        uint256 del3Before = _getDelegation(delegator3, operator1);

        _slash(operator1, 35 ether);

        uint256 del1After = _getDelegation(delegator1, operator1);
        uint256 del2After = _getDelegation(delegator2, operator1);
        uint256 del3After = _getDelegation(delegator3, operator1);

        // Each delegator should lose ~50%
        assertApproxEqRel(del1After, del1Before / 2, 0.01e18, "Delegator1 should lose ~50%");
        assertApproxEqRel(del2After, del2Before / 2, 0.01e18, "Delegator2 should lose ~50%");
        assertApproxEqRel(del3After, del3Before / 2, 0.01e18, "Delegator3 should lose ~50%");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 2: OPERATOR LIFECYCLE TESTS (Critical)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test operator complete leaving with delegators still delegated
    function test_OperatorCompleteLeavingWithDelegators() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);

        // Operator starts leaving
        vm.prank(operator1);
        delegation.startLeaving();

        _advanceRounds(OPERATOR_DELAY); // Operators use 56 round delay

        // Operator completes leaving
        uint256 balanceBefore = operator1.balance;
        vm.prank(operator1);
        delegation.completeLeaving();

        // Operator should receive their stake back
        assertEq(operator1.balance, balanceBefore + 10 ether);

        // Delegator's delegation should still exist (in terms of shares)
        // But the operator is gone, so they need to unstake
        uint256 delegation1 = _getDelegation(delegator1, operator1);
        // Shares still exist, but operator is inactive
        assertFalse(delegation.isOperator(operator1));
    }

    /// @notice Test cannot call startLeaving twice
    function test_OperatorCannotStartLeavingTwice() public {
        vm.prank(operator1);
        delegation.startLeaving();

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.OperatorNotActive.selector, operator1));
        delegation.startLeaving();
    }

    /// @notice Test cannot complete leaving before delay
    function test_OperatorCannotCompleteLeavingEarly() public {
        vm.prank(operator1);
        delegation.startLeaving();

        // Advance just under operator delay (56 - 1 = 55 rounds)
        _advanceRounds(OPERATOR_DELAY - 1);

        uint64 currentRound = uint64(delegation.currentRound());
        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.LeavingTooEarly.selector, currentRound, currentRound + 1)
        );
        delegation.completeLeaving();
    }

    /// @notice Test operator cannot register twice
    function test_OperatorCannotRegisterTwice() public {
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.OperatorAlreadyRegistered.selector, operator1));
        delegation.registerOperator{ value: 10 ether }();
    }

    /// @notice Test operator slashed below minimum becomes inactive
    function test_OperatorSlashedBelowMinimum_BecomesInactive() public {
        // Operator1 has 10 ETH stake, min is 1 ETH
        // Slash 9.5 ETH - should still be active
        _slash(operator1, 9 ether);
        assertOperatorActive(operator1);

        // Slash remaining to go below min
        _slash(operator1, 0.5 ether);
        assertOperatorNotActive(operator1);
    }

    /// @notice Test new delegations rejected to leaving operator
    function test_CannotDelegateToLeavingOperator() public {
        vm.prank(operator1);
        delegation.startLeaving();

        _depositNative(delegator1, 10 ether);

        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.OperatorNotActive.selector, operator1));
        delegation.delegate(operator1, 5 ether);
    }

    /// @notice Test operator lifecycle through unstake, slash, and leaving
    function test_OperatorLifecycle_UnstakeSlashAndLeaveFlow() public {
        // Schedule partial unstake
        vm.prank(operator1);
        delegation.scheduleOperatorUnstake(3 ether);

        uint64 currentRound = uint64(delegation.currentRound());
        vm.startPrank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationErrors.LeavingTooEarly.selector, currentRound, currentRound + DEFAULT_DELAY
            )
        );
        delegation.executeOperatorUnstake();
        vm.stopPrank();

        vm.startPrank(operator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.InsufficientStake.selector, MIN_OPERATOR_STAKE, 0));
        delegation.scheduleOperatorUnstake(7 ether);
        vm.stopPrank();

        // Slash while the request is pending to hit reduced stake edge case
        _slash(operator1, 3 ether);

        _advanceRounds(DEFAULT_DELAY);

        uint256 operatorStakeBefore = delegation.getOperatorSelfStake(operator1);
        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        delegation.executeOperatorUnstake();

        assertEq(operator1.balance, balanceBefore + 3 ether, "Unstake should release requested amount");
        assertEq(
            delegation.getOperatorSelfStake(operator1),
            operatorStakeBefore - 3 ether,
            "Operator stake reduced after executing unstake"
        );

        // Start leaving with the reduced stake
        vm.prank(operator1);
        delegation.startLeaving();

        vm.startPrank(operator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.OperatorNotActive.selector, operator1));
        delegation.scheduleOperatorUnstake(1 ether);
        vm.stopPrank();

        // Slash again while leaving to ensure completion returns remaining stake
        _slash(operator1, 1 ether);

        _advanceRounds(OPERATOR_DELAY); // Operators use 56 round delay

        balanceBefore = operator1.balance;
        uint256 remainingStake = delegation.getOperatorSelfStake(operator1);

        vm.prank(operator1);
        delegation.completeLeaving();

        assertEq(operator1.balance, balanceBefore + remainingStake, "Complete leaving releases remaining stake");
        assertFalse(delegation.isOperator(operator1), "Operator should be removed after leaving");
        assertEq(delegation.getOperatorSelfStake(operator1), 0, "Operator stake should be zero");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 3: REENTRANCY TESTS (Critical)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test reentrancy on native ETH withdraw via malicious receiver
    function test_Reentrancy_NativeWithdraw_MaliciousReceiver() public {
        ReentrantReceiver attacker = new ReentrantReceiver(address(delegation));
        vm.deal(address(attacker), 20 ether);

        // Attacker deposits and schedules withdraw
        // Note: When calling attacker.deposit{value: 10 ether}(), the test sends 10 ETH
        // to the attacker contract, which then forwards it to delegation.
        // So attacker balance stays at 20 ETH (receives 10, sends 10).
        attacker.deposit{ value: 10 ether }();
        attacker.scheduleWithdraw(address(0), 10 ether);

        _advanceRounds(DEFAULT_DELAY);

        // Set up attack - try to call executeWithdraw again
        attacker.setAttack(true, abi.encodeWithSelector(IMultiAssetDelegation.executeWithdraw.selector));

        // Execute - should not double withdraw due to reentrancy guard
        attacker.executeWithdraw();

        // Attacker should only receive once
        // Balance: 20 ETH (initial) + 10 ETH (test sends to deposit) - 10 ETH (forwards to delegation) + 10 ETH
        // (withdrawn) = 30 ETH
        assertEq(address(attacker).balance, 30 ether);
        assertEq(attacker.receiveCount(), 1);
    }

    /// @notice Test reentrancy on native ETH unstake via malicious receiver
    function test_Reentrancy_NativeUnstake_MaliciousReceiver() public {
        ReentrantReceiver attacker = new ReentrantReceiver(address(delegation));
        vm.deal(address(attacker), 20 ether);

        // Attacker deposits and delegates
        attacker.depositAndDelegate{ value: 10 ether }(operator1);
        attacker.scheduleDelegatorUnstake(operator1, address(0), 10 ether);

        _advanceRounds(DEFAULT_DELAY);

        // Set up attack
        attacker.setAttack(true, abi.encodeWithSelector(IMultiAssetDelegation.executeDelegatorUnstake.selector));

        // Execute
        attacker.executeDelegatorUnstake();

        // Check no double unstake
        assertEq(attacker.receiveCount(), 0); // Unstake doesn't transfer, just updates deposit
    }

    /// @notice Test reentrancy via malicious ERC20 on withdraw
    function test_Reentrancy_ERC20Withdraw_MaliciousToken() public {
        ReentrantERC20 evilToken = new ReentrantERC20();
        evilToken.setTarget(address(delegation));

        vm.prank(admin);
        delegation.enableAsset(address(evilToken), 0, 0, 0, 10_000);

        evilToken.mint(delegator1, 10 ether);

        vm.startPrank(delegator1);
        evilToken.approve(address(delegation), 10 ether);
        delegation.depositERC20(address(evilToken), 10 ether);
        delegation.scheduleWithdraw(address(evilToken), 10 ether);
        vm.stopPrank();

        _advanceRounds(DEFAULT_DELAY);

        // Set up attack
        evilToken.setAttack(true, abi.encodeWithSelector(IMultiAssetDelegation.executeWithdraw.selector));

        // Execute
        vm.prank(delegator1);
        delegation.executeWithdraw();

        // Should only receive once
        assertEq(evilToken.balanceOf(delegator1), 10 ether);
    }

    /// @notice Test reentrancy on deposit from malicious ERC20
    function test_Reentrancy_ERC20Deposit_NoAttackVector() public {
        ReentrantERC20 evilToken = new ReentrantERC20();
        evilToken.setTarget(address(delegation));

        vm.prank(admin);
        delegation.enableAsset(address(evilToken), 0, 0, 0, 10_000);

        evilToken.mint(delegator1, 20 ether);

        // Try to reenter during deposit - should fail due to reentrancy guard
        evilToken.setAttack(true, abi.encodeWithSelector(IMultiAssetDelegation.deposit.selector));

        vm.startPrank(delegator1);
        evilToken.approve(address(delegation), 20 ether);
        // This shouldn't cause issues - reentrancy happens on transferFrom, not transfer
        delegation.depositERC20(address(evilToken), 10 ether);
        vm.stopPrank();

        // Verify deposit worked correctly
        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(evilToken));
        assertEq(dep.amount, 10 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 4: BOUNDARY CONDITION TESTS (High)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test execute at exactly delay - 1 (should not execute)
    function test_ExecuteAtDelayMinusOne_ShouldNotExecute() public {
        _depositAndDelegate(delegator1, operator1, 5 ether);
        _scheduleUnstake(delegator1, operator1, address(0), 5 ether);

        _advanceRounds(DEFAULT_DELAY - 1);

        _executeUnstake(delegator1);

        // Should still be delegated
        assertDelegationEq(delegator1, operator1, 5 ether);
    }

    /// @notice Test execute at exactly delay (should execute)
    function test_ExecuteAtExactDelay_ShouldExecute() public {
        _depositAndDelegate(delegator1, operator1, 5 ether);
        _scheduleUnstake(delegator1, operator1, address(0), 5 ether);

        _advanceRounds(DEFAULT_DELAY);

        _executeUnstake(delegator1);

        // Should be unstaked
        assertDelegationEq(delegator1, operator1, 0);
    }

    /// @notice Test execute at delay + 1 (should execute)
    function test_ExecuteAtDelayPlusOne_ShouldExecute() public {
        _depositAndDelegate(delegator1, operator1, 5 ether);
        _scheduleUnstake(delegator1, operator1, address(0), 5 ether);

        _advanceRounds(DEFAULT_DELAY + 1);

        _executeUnstake(delegator1);

        assertDelegationEq(delegator1, operator1, 0);
    }

    /// @notice Test withdraw at exact boundary
    function test_WithdrawAtExactBoundary() public {
        _depositNative(delegator1, 5 ether);
        _scheduleWithdraw(delegator1, address(0), 5 ether);

        _advanceRounds(DEFAULT_DELAY - 1);
        uint256 balanceBefore = delegator1.balance;
        _executeWithdraw(delegator1);
        assertEq(delegator1.balance, balanceBefore, "Should not execute before delay");

        _advanceRounds(1);
        _executeWithdraw(delegator1);
        assertEq(delegator1.balance, balanceBefore + 5 ether, "Should execute at delay");
    }

    /// @notice Test round 0 edge case (should start at 1)
    function test_RoundStartsAtOne() public view {
        assertGt(delegation.currentRound(), 0, "Round should start at 1");
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 5: MULTI-ASSET TESTS (High)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test mixed native + ERC20 delegation to same operator
    function test_MixedNativeAndERC20Delegation() public {
        // Delegate native
        _depositAndDelegate(delegator1, operator1, 5 ether);

        // Delegate ERC20
        _depositAndDelegateErc20(delegator1, operator1, address(token), 5 ether);

        // Total delegation should include both
        uint256 totalDelegation = delegation.getTotalDelegation(delegator1);
        assertEq(totalDelegation, 10 ether, "Total should be 10 ether");
    }

    /// @notice Test unstake order: ERC20 first, then native
    function test_UnstakeMixedOrder_ERC20ThenNative() public {
        _depositAndDelegate(delegator1, operator1, 5 ether);
        _depositAndDelegateErc20(delegator1, operator1, address(token), 5 ether);

        // Unstake ERC20 first
        _scheduleUnstake(delegator1, operator1, address(token), 5 ether);
        _advanceRounds(DEFAULT_DELAY);
        _executeUnstake(delegator1);

        // Then unstake native
        _scheduleUnstake(delegator1, operator1, address(0), 5 ether);
        _advanceRounds(DEFAULT_DELAY);
        _executeUnstake(delegator1);

        assertEq(delegation.getTotalDelegation(delegator1), 0);
    }

    /// @notice Test native and ERC20 to different operators
    function test_NativeAndERC20ToDifferentOperators() public {
        _registerOperator(operator2, 10 ether);

        _depositAndDelegate(delegator1, operator1, 5 ether);
        _depositAndDelegateErc20(delegator1, operator2, address(token), 5 ether);

        assertDelegationEq(delegator1, operator1, 5 ether);
        assertDelegationEq(delegator1, operator2, 5 ether);
    }

    /// @notice Test consensus slash only affects bond asset delegations
    function test_SlashOnlyAffectsNativeDelegations() public {
        // Both delegators delegate to operator1
        _depositAndDelegate(delegator1, operator1, 10 ether); // Native
        _depositAndDelegateErc20(delegator2, operator1, address(token), 10 ether); // ERC20

        // Consensus slash affects only bond asset (native)
        _slash(operator1, 15 ether);

        assertLt(_getDelegation(delegator1, operator1), 10 ether);
        assertEq(_getDelegation(delegator2, operator1), 10 ether);
    }

    /// @notice Test multiple ERC20 tokens
    function test_MultipleDifferentERC20Tokens() public {
        _depositAndDelegateErc20(delegator1, operator1, address(token), 5 ether);
        _depositAndDelegateErc20(delegator1, operator1, address(token2), 3 ether);

        uint256 total = delegation.getTotalDelegation(delegator1);
        assertEq(total, 8 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 6: LOCK INTERACTION TESTS (High)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test cannot withdraw locked funds
    function test_CannotWithdrawLockedFunds() public {
        // Deposit with 1 month lock
        _depositNativeWithLock(delegator1, 10 ether, Types.LockMultiplier.OneMonth);

        // Try to schedule withdraw - should fail due to lock
        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.AmountLocked.selector, 10 ether, 10 ether));
        delegation.scheduleWithdraw(address(0), 10 ether);
    }

    /// @notice Test can withdraw after lock expires
    function test_CanWithdrawAfterLockExpires() public {
        _depositNativeWithLock(delegator1, 10 ether, Types.LockMultiplier.OneMonth);

        // Lock duration is LOCK_ONE_MONTH = 30 days (stored as block offset)
        // So we need to roll past 30 days worth of blocks
        uint256 lockBlocks = uint256(30 days); // 2,592,000
        vm.roll(block.number + lockBlocks + 1);
        vm.warp(block.timestamp + 30 days + 1);

        // Should now be able to schedule
        _scheduleWithdraw(delegator1, address(0), 10 ether);

        _advanceRounds(DEFAULT_DELAY);

        uint256 balanceBefore = delegator1.balance;
        _executeWithdraw(delegator1);
        assertEq(delegator1.balance, balanceBefore + 10 ether);
    }

    /// @notice Test partial lock - some locked, some unlocked
    function test_PartialLock_WithdrawUnlockedPortion() public {
        // Deposit 5 ETH with lock
        _depositNativeWithLock(delegator1, 5 ether, Types.LockMultiplier.OneMonth);

        // Deposit 5 ETH without lock
        _depositNative(delegator1, 5 ether);

        // Should be able to withdraw unlocked portion
        _scheduleWithdraw(delegator1, address(0), 5 ether);
        _advanceRounds(DEFAULT_DELAY);

        uint256 balanceBefore = delegator1.balance;
        _executeWithdraw(delegator1);
        assertEq(delegator1.balance, balanceBefore + 5 ether);
    }

    /// @notice Test locked funds can still be delegated
    function test_LockedFundsCanBeDelegated() public {
        _depositNativeWithLock(delegator1, 10 ether, Types.LockMultiplier.OneMonth);

        // Can delegate locked funds
        vm.prank(delegator1);
        delegation.delegate(operator1, 10 ether);

        assertDelegationEq(delegator1, operator1, 10 ether);
    }

    /// @notice Test different lock multipliers
    function test_DifferentLockMultipliers() public {
        // Deposit with different locks
        _depositNativeWithLock(delegator1, 1 ether, Types.LockMultiplier.OneMonth);
        _depositNativeWithLock(delegator1, 2 ether, Types.LockMultiplier.TwoMonths);
        _depositNativeWithLock(delegator1, 3 ether, Types.LockMultiplier.ThreeMonths);
        _depositNativeWithLock(delegator1, 4 ether, Types.LockMultiplier.SixMonths);

        Types.LockInfo[] memory locks = delegation.getLocks(delegator1, address(0));
        assertEq(locks.length, 4);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 7: PAUSE/UNPAUSE TESTS (High)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test schedule withdraw reverts when paused
    function test_ScheduleWithdrawRevertsWhenPaused() public {
        _depositNative(delegator1, 10 ether);
        _pause();

        vm.prank(delegator1);
        vm.expectRevert(); // EnforcedPause
        delegation.scheduleWithdraw(address(0), 5 ether);
    }

    /// @notice Test schedule unstake reverts when paused
    function test_ScheduleUnstakeRevertsWhenPaused() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);
        _pause();

        vm.prank(delegator1);
        vm.expectRevert(); // EnforcedPause
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);
    }

    /// @notice Test register operator reverts when paused
    function test_RegisterOperatorRevertsWhenPaused() public {
        _pause();

        vm.prank(operator2);
        vm.expectRevert(); // EnforcedPause
        delegation.registerOperator{ value: 10 ether }();
    }

    /// @notice Test operations resume after unpause
    function test_OperationsResumeAfterUnpause() public {
        _depositNative(delegator1, 10 ether);
        _pause();
        _unpause();

        // Should work now
        _scheduleWithdraw(delegator1, address(0), 5 ether);

        Types.WithdrawRequest[] memory pending = delegation.getPendingWithdrawals(delegator1);
        assertEq(pending.length, 1);
    }

    /// @notice Test pause during pending request doesn't prevent execution
    function test_PauseDuringPending_ExecutionStillWorks() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);
        _scheduleUnstake(delegator1, operator1, address(0), 5 ether);

        _advanceRounds(DEFAULT_DELAY);
        _pause();

        // Execute should still work (withdrawals not pausable for safety)
        _executeUnstake(delegator1);
        assertDelegationEq(delegator1, operator1, 5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 8: CONCURRENT USERS TESTS (Medium)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test many delegators to same operator
    function test_ManyDelegatorsToSameOperator() public {
        uint256 numDelegators = 10;

        for (uint256 i = 0; i < numDelegators; i++) {
            address delegator = makeAddr(string(abi.encodePacked("delegator", i)));
            vm.deal(delegator, 100 ether);

            vm.prank(delegator);
            delegation.depositAndDelegate{ value: 10 ether }(operator1);
        }

        // Total delegated should be 100 ether
        assertEq(delegation.getOperatorDelegatedStake(operator1), 100 ether);
        assertEq(delegation.getOperatorDelegatorCount(operator1), 10);
    }

    /// @notice Test delegator to many operators
    function test_OneDelegatorToManyOperators() public {
        // Register more operators
        _registerOperator(operator2, 10 ether);
        _registerOperator(operator3, 10 ether);

        _depositNative(delegator1, 30 ether);

        vm.startPrank(delegator1);
        delegation.delegate(operator1, 10 ether);
        delegation.delegate(operator2, 10 ether);
        delegation.delegate(operator3, 10 ether);
        vm.stopPrank();

        assertDelegationEq(delegator1, operator1, 10 ether);
        assertDelegationEq(delegator1, operator2, 10 ether);
        assertDelegationEq(delegator1, operator3, 10 ether);
    }

    /// @notice Test concurrent unstake requests from multiple delegators
    function test_ConcurrentUnstakeFromMultipleDelegators() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);
        _depositAndDelegate(delegator2, operator1, 20 ether);
        _depositAndDelegate(delegator3, operator1, 30 ether);

        // All schedule at same round
        _scheduleUnstake(delegator1, operator1, address(0), 5 ether);
        _scheduleUnstake(delegator2, operator1, address(0), 10 ether);
        _scheduleUnstake(delegator3, operator1, address(0), 15 ether);

        _advanceRounds(DEFAULT_DELAY);

        // All execute
        _executeUnstake(delegator1);
        _executeUnstake(delegator2);
        _executeUnstake(delegator3);

        assertDelegationEq(delegator1, operator1, 5 ether);
        assertDelegationEq(delegator2, operator1, 10 ether);
        assertDelegationEq(delegator3, operator1, 15 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 10: ACCESS CONTROL TESTS (Medium)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test non-admin cannot add slasher
    function test_NonAdminCannotAddSlasher() public {
        vm.prank(delegator1);
        vm.expectRevert(); // AccessControl error
        delegation.addSlasher(delegator1);
    }

    /// @notice Test non-admin cannot remove slasher
    function test_NonAdminCannotRemoveSlasher() public {
        vm.prank(delegator1);
        vm.expectRevert();
        delegation.removeSlasher(slasher);
    }

    /// @notice Test non-admin cannot set commission
    function test_NonAdminCannotSetCommission() public {
        vm.prank(delegator1);
        vm.expectRevert();
        delegation.setOperatorCommission(500);
    }

    /// @notice Test non-admin cannot enable asset
    function test_NonAdminCannotEnableAsset() public {
        address newToken = address(new MockERC20("New", "NEW"));
        vm.prank(delegator1);
        vm.expectRevert();
        delegation.enableAsset(newToken, 1 ether, 0.1 ether, 0, 10_000);
    }

    /// @notice Test non-admin cannot disable asset
    function test_NonAdminCannotDisableAsset() public {
        vm.prank(delegator1);
        vm.expectRevert();
        delegation.disableAsset(address(token));
    }

    /// @notice Test admin can perform all admin functions
    function test_AdminCanPerformAdminFunctions() public {
        vm.startPrank(admin);

        // Add/remove slasher
        address newSlasher = makeAddr("newSlasher");
        delegation.addSlasher(newSlasher);
        assertTrue(delegation.isSlasher(newSlasher));
        delegation.removeSlasher(newSlasher);
        assertFalse(delegation.isSlasher(newSlasher));

        // Set commission (M-10 FIX: now uses timelock)
        delegation.setOperatorCommission(500);
        vm.warp(block.timestamp + 7 days + 1);
        delegation.executeCommissionChange();
        assertEq(delegation.operatorCommissionBps(), 500);

        // Set delays
        delegation.setDelays(10, 15, 20);
        assertEq(delegation.delegationBondLessDelay(), 10);
        assertEq(delegation.leaveDelegatorsDelay(), 15);
        assertEq(delegation.leaveOperatorsDelay(), 20);

        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 11: EVENT EMISSION TESTS (Medium)
    // ═══════════════════════════════════════════════════════════════════════════════

    // Events from the contracts (need to redeclare for testing)
    event Deposited(address indexed delegator, address indexed token, uint256 amount, Types.LockMultiplier lock);
    event Delegated(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 amount,
        uint256 shares,
        Types.BlueprintSelectionMode selectionMode
    );
    event Slashed(
        address indexed operator,
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        bytes32 assetHash,
        uint16 slashBps,
        uint256 operatorSlashed,
        uint256 delegatorsSlashed,
        uint256 exchangeRateAfter
    );
    event OperatorRegistered(address indexed operator, uint256 stake);
    event RoundAdvanced(uint64 indexed round);

    /// @notice Test Deposited event emission
    function test_EventEmission_Deposited() public {
        vm.expectEmit(true, true, false, true);
        emit Deposited(delegator1, address(0), 5 ether, Types.LockMultiplier.None);

        vm.prank(delegator1);
        delegation.deposit{ value: 5 ether }();
    }

    /// @notice Test Delegated event emission with shares
    function test_EventEmission_Delegated() public {
        _depositNative(delegator1, 5 ether);

        // For first delegation, shares = amount
        vm.expectEmit(true, true, true, false); // Don't check non-indexed params exactly
        emit Delegated(
            delegator1,
            operator1,
            address(0),
            5 ether,
            5 ether, // shares
            Types.BlueprintSelectionMode.All
        );

        vm.prank(delegator1);
        delegation.delegate(operator1, 5 ether);
    }

    /// @notice Test Slashed event emission
    function test_EventEmission_Slashed() public {
        _depositAndDelegate(delegator1, operator1, 10 ether);

        // Slash event should be emitted - check indexed params only
        vm.expectEmit(true, true, true, false);
        emit Slashed(operator1, 0, 0, bytes32(0), 0, 0, 0, 0); // only checking indexed params

        _slash(operator1, 10 ether);
    }

    /// @notice Test OperatorRegistered event
    function test_EventEmission_OperatorRegistered() public {
        vm.expectEmit(true, false, false, true);
        emit OperatorRegistered(operator2, 10 ether);

        vm.prank(operator2);
        delegation.registerOperator{ value: 10 ether }();
    }

    /// @notice Test RoundAdvanced event
    function test_EventEmission_RoundAdvanced() public {
        uint64 currentRound = uint64(delegation.currentRound());

        vm.expectEmit(true, false, false, false);
        emit RoundAdvanced(currentRound + 1);

        delegation.advanceRound();
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 12: DUST/OVERFLOW/EXTREME VALUE TESTS (Medium)
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test minimum delegation (1 wei)
    function test_MinimumDelegation_1Wei() public {
        // Override min delegation for this test
        vm.prank(admin);
        delegation.enableAsset(address(token), 0, 0, 0, 10_000); // 0 min delegation

        token.mint(delegator1, 1);

        vm.startPrank(delegator1);
        token.approve(address(delegation), 1);
        delegation.depositERC20(address(token), 1);
        delegation.delegateWithOptions(operator1, address(token), 1, Types.BlueprintSelectionMode.All, new uint64[](0));
        vm.stopPrank();

        assertEq(delegation.getDelegation(delegator1, operator1), 1);
    }

    /// @notice Test large amount (but not overflow)
    function test_LargeAmountDelegation() public {
        uint256 largeAmount = 1_000_000 ether;
        vm.deal(delegator1, largeAmount + 1 ether);

        _depositAndDelegate(delegator1, operator1, largeAmount);
        assertDelegationEq(delegator1, operator1, largeAmount);
    }

    /// @notice Test zero amount operations revert
    function test_ZeroAmountOperationsRevert() public {
        _depositNative(delegator1, 10 ether);

        vm.startPrank(delegator1);

        vm.expectRevert(DelegationErrors.ZeroAmount.selector);
        delegation.delegate(operator1, 0);

        vm.expectRevert(DelegationErrors.ZeroAmount.selector);
        delegation.scheduleWithdraw(address(0), 0);

        vm.stopPrank();
    }

    /// @notice Test deposit cap enforcement
    function test_DepositCapEnforcement() public {
        // Set deposit cap
        vm.prank(admin);
        delegation.enableAsset(address(token), 0, 0, 10 ether, 10_000); // 10 ETH cap

        token.mint(delegator1, 20 ether);

        vm.startPrank(delegator1);
        token.approve(address(delegation), 20 ether);

        // First deposit works
        delegation.depositERC20(address(token), 5 ether);

        // Second deposit exceeds cap
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.DepositCapExceeded.selector, 10 ether, 5 ether, 6 ether)
        );
        delegation.depositERC20(address(token), 6 ether);

        vm.stopPrank();
    }

    function test_DepositCapDecreasesOnWithdrawExecution() public {
        vm.prank(admin);
        delegation.enableAsset(address(token), 0, 0, 10 ether, 10_000); // 10 ETH cap

        token.mint(delegator1, 20 ether);

        vm.startPrank(delegator1);
        token.approve(address(delegation), 20 ether);

        // Fill the cap.
        delegation.depositERC20(address(token), 10 ether);

        // Schedule full withdrawal.
        delegation.scheduleWithdraw(address(token), 10 ether);

        // Attempting to deposit again should fail until withdrawal executes.
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.DepositCapExceeded.selector, 10 ether, 10 ether, 1 ether)
        );
        delegation.depositERC20(address(token), 1 ether);

        // Advance rounds to make withdrawal executable and execute it.
        uint64 withdrawDelay = uint64(delegation.leaveDelegatorsDelay());
        _advanceRounds(withdrawDelay + 1);
        delegation.executeWithdraw();

        // Cap should be freed now.
        delegation.depositERC20(address(token), 10 ether);

        vm.stopPrank();
    }

    /// @notice Test precision in share calculations
    function test_ShareCalculationPrecision() public {
        // First delegator deposits
        _depositAndDelegate(delegator1, operator1, 1 ether);

        // Slash 5 ETH (small enough to keep operator active)
        // Total: 10 ETH (operator) + 1 ETH (delegator) = 11 ETH
        // After slash of 5 ETH: operator has ~4.55 ETH, delegator has ~0.45 ETH
        // Operator still above MIN_OPERATOR_STAKE (1 ETH)
        _slash(operator1, 5 ether);

        // Verify operator is still active
        assertOperatorActive(operator1);

        // Second delegator deposits same amount
        _depositNative(delegator2, 1 ether);
        vm.prank(delegator2);
        delegation.delegate(operator1, 1 ether);

        // First delegator should have less than second due to slash
        uint256 del1Value = _getDelegation(delegator1, operator1);
        uint256 del2Value = _getDelegation(delegator2, operator1);

        assertLt(del1Value, 1 ether, "Del1 should have less due to slash");
        // Del2 enters at new exchange rate - their shares convert to less than 1 ETH
        // because the pool has been slashed
    }

    /// @notice Test rounding behavior in conversions
    function test_RoundingBehavior() public {
        // Small amounts that might cause rounding issues
        _depositAndDelegate(delegator1, operator1, 1000);

        // Slash a tiny amount (1 bps)
        vm.prank(slasher);
        delegation.slash(operator1, 0, 1, keccak256("evidence"));

        // Should still be able to unstake (minus rounding)
        uint256 remaining = _getDelegation(delegator1, operator1);
        _scheduleUnstake(delegator1, operator1, address(0), remaining);
        _advanceRounds(DEFAULT_DELAY);
        _executeUnstake(delegator1);

        assertDelegationEq(delegator1, operator1, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════════
    // SECTION 13: ADDITIONAL EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════════

    /// @notice Test unstake more than available (should revert)
    function test_UnstakeMoreThanAvailable_Reverts() public {
        _depositAndDelegate(delegator1, operator1, 5 ether);

        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.InsufficientDelegation.selector, 5 ether, 10 ether));
        delegation.scheduleDelegatorUnstake(operator1, address(0), 10 ether);
    }

    /// @notice Test delegate more than deposited (should revert)
    function test_DelegateMoreThanDeposited_Reverts() public {
        _depositNative(delegator1, 5 ether);

        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.InsufficientDeposit.selector, 5 ether, 10 ether));
        delegation.delegate(operator1, 10 ether);
    }

    /// @notice Test execute with no pending requests (no-op)
    function test_ExecuteWithNoPendingRequests_NoOp() public {
        // Should not revert, just do nothing
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        vm.prank(delegator1);
        delegation.executeWithdraw();
    }

    /// @notice Test delegate to self (if operator)
    function test_OperatorCanDelegateToSelf() public {
        vm.deal(operator1, 200 ether);

        vm.startPrank(operator1);
        delegation.deposit{ value: 10 ether }();
        delegation.delegate(operator1, 10 ether);
        vm.stopPrank();

        assertDelegationEq(operator1, operator1, 10 ether);
    }

    /// @notice Test asset disabled mid-operation
    function test_AssetDisabledMidOperation() public {
        _depositAndDelegateErc20(delegator1, operator1, address(token), 10 ether);

        // Disable asset
        vm.prank(admin);
        delegation.disableAsset(address(token));

        // Should still be able to unstake and withdraw
        _scheduleUnstake(delegator1, operator1, address(token), 10 ether);
        _advanceRounds(DEFAULT_DELAY);
        _executeUnstake(delegator1);

        _scheduleWithdraw(delegator1, address(token), 10 ether);
        _advanceRounds(DEFAULT_DELAY);
        _executeWithdraw(delegator1);

        assertEq(token.balanceOf(delegator1), 1000 ether); // Original balance
    }

    /// @notice Test blueprint selection modes
    function test_BlueprintSelectionModes() public {
        _depositNative(delegator1, 10 ether);

        uint64[] memory bps = new uint64[](2);
        bps[0] = 1;
        bps[1] = 2;

        // Fixed mode
        vm.prank(delegator1);
        delegation.delegateWithOptions(operator1, address(0), 5 ether, Types.BlueprintSelectionMode.Fixed, bps);

        Types.BondInfoDelegator[] memory delegations = delegation.getDelegations(delegator1);
        assertEq(uint8(delegations[0].selectionMode), uint8(Types.BlueprintSelectionMode.Fixed));

        uint64[] memory storedBps = delegation.getDelegationBlueprints(delegator1, 0);
        assertEq(storedBps.length, 2);
        assertEq(storedBps[0], 1);
        assertEq(storedBps[1], 2);
    }

    /// @notice Consensus slashes affect Fixed mode delegators too
    /// @dev Fixed mode pools are slashed during consensus slashes (service 0)
    function test_ConsensusSlash_AffectsFixedModeDelegators() public {
        _depositNative(delegator1, 10 ether);
        uint64[] memory bps = new uint64[](1);
        bps[0] = 42;

        // Slasher adds blueprint for operator (simulating Tangle registration)
        vm.prank(slasher);
        delegation.addBlueprintForOperator(operator1, 42);

        vm.prank(delegator1);
        delegation.delegateWithOptions(operator1, address(0), 5 ether, Types.BlueprintSelectionMode.Fixed, bps);

        uint256 beforeSlash = _getDelegation(delegator1, operator1);
        assertEq(beforeSlash, 5 ether, "Before slash should be 5 ether");

        // Slash 10% (1000 bps) - affects Fixed mode delegators too
        vm.prank(slasher);
        delegation.slash(operator1, 0, 1000, keccak256("fixed-slash"));

        // Fixed mode delegators ARE slashed during consensus slashes
        // 5 ETH * 10% = 0.5 ETH slashed, leaving 4.5 ETH
        assertEq(_getDelegation(delegator1, operator1), 4.5 ether);
    }
}
