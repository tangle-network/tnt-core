// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { TokenizedBlueprintBase } from "../../../src/extensions/TokenizedBlueprintBase.sol";
import { MockERC20 } from "../../MockERC20.sol";

// ═════════════════════════════════════════════════════════════════════════════
// TEST HARNESS
// ═════════════════════════════════════════════════════════════════════════════

/// @dev Exposes the internal configuration / payment hooks of the abstract base
///      so the audit regressions can drive instant + streaming reward flows and
///      tune the stake-lock window.
contract TokenizedExtHarness is TokenizedBlueprintBase {
    constructor() TokenizedBlueprintBase("Tokenized Audit Token", "TAT") { }

    function bootstrap(uint64 blueprintId, address owner, address tangle) external {
        this.onBlueprintCreated(blueprintId, owner, tangle);
    }

    function mintToken(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setStreamingConfig(bool enabled, uint256 duration) external {
        _setStreamingMode(enabled);
        _setRewardDuration(duration);
    }

    function setStakeLock(uint256 duration) external {
        _setStakeLockDuration(duration);
    }

    /// @dev Simulates the native receive() hook path for either token type.
    function externalPayment(address token, uint256 amount) external {
        _onPaymentReceived(token, amount);
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// AUDIT REGRESSIONS — src/extensions/TokenizedBlueprintBase.sol
// ═════════════════════════════════════════════════════════════════════════════

contract TokenizedExtAuditTest is Test {
    TokenizedExtHarness internal bp;

    address internal owner = address(0xA11CE);
    address internal tangle = address(0x7A6);
    address internal attacker = address(0xBAD);
    address internal honest = address(0x600D);

    MockERC20 internal revenueToken;

    function setUp() public {
        bp = new TokenizedExtHarness();
        bp.bootstrap(1, owner, tangle);
        revenueToken = new MockERC20();
        // Ensure block.timestamp is well past 0 so lock arithmetic is meaningful.
        vm.warp(1_000_000);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FINDING 1 (medium): JIT staking steals instant-mode rewards.
    // SECURE INVARIANT: a freshly-deposited stake cannot be withdrawn until the
    // stake-lock window elapses. Reverting the lock (lock duration == 0) lets the
    // attacker round-trip; the guard must block the withdrawal.
    // ─────────────────────────────────────────────────────────────────────────

    function test_Finding1_WithdrawRevertsWhileStakeLocked() public {
        bp.setStakeLock(1 days); // production blueprints opt into the JIT guard
        bp.mintToken(attacker, 100 ether);

        vm.prank(attacker);
        bp.stake(100 ether);

        uint256 unlock = bp.stakeUnlockTime(attacker);
        assertEq(unlock, block.timestamp + 1 days, "lock should reflect configured window");

        // Immediate withdrawal (the JIT round-trip) must revert.
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(TokenizedBlueprintBase.StakeLocked.selector, unlock));
        bp.withdraw(100 ether);
    }

    function test_Finding1_SecureDefaultLockBlocksJIT() public {
        // F4: the base now ships a NON-ZERO default stake-lock so a blueprint that forgets to
        // configure one is not silently exposed to the JIT instant-mode reward-capture vector.
        // (Previously the default was 0 and immediate withdraw succeeded — the hole.)
        assertEq(bp.stakeLockDuration(), bp.DEFAULT_STAKE_LOCK_DURATION(), "default == failsafe window");
        assertGt(bp.stakeLockDuration(), 0, "default lock must be non-zero (fail safe)");

        bp.mintToken(honest, 10 ether);
        vm.prank(honest);
        bp.stake(10 ether);
        uint256 unlock = bp.stakeUnlockTime(honest);

        // Immediate withdrawal is now blocked by default.
        vm.prank(honest);
        vm.expectRevert(abi.encodeWithSelector(TokenizedBlueprintBase.StakeLocked.selector, unlock));
        bp.withdraw(10 ether);

        // Once the default window elapses, withdrawal succeeds (lock is a delay, not a freeze).
        vm.warp(block.timestamp + bp.DEFAULT_STAKE_LOCK_DURATION());
        vm.prank(honest);
        bp.withdraw(10 ether);
        assertEq(bp.stakedBalance(honest), 0);
    }

    function test_Finding1_JitStakerCannotExtractAndDilute() public {
        bp.setStakeLock(1 days);
        // Honest staker is in for the long haul.
        bp.mintToken(honest, 100 ether);
        vm.prank(honest);
        bp.stake(100 ether);

        // Attacker front-runs a known incoming payment.
        bp.mintToken(attacker, 100 ether);
        vm.prank(attacker);
        bp.stake(100 ether);

        // Revenue arrives (native ETH instant mode).
        vm.deal(address(this), 2 ether);
        (bool ok,) = address(bp).call{ value: 2 ether }("");
        require(ok, "payment failed");

        // Attacker tries to exit immediately to bank the reward with no time-at-risk.
        // Cache the unlock time BEFORE the prank: evaluating bp.stakeUnlockTime(attacker) as the
        // expectRevert argument consumes the prank, running withdraw as the test contract
        // (which has no stake) and reverting InsufficientStake instead of StakeLocked.
        uint256 attackerUnlock = bp.stakeUnlockTime(attacker);
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(TokenizedBlueprintBase.StakeLocked.selector, attackerUnlock));
        bp.withdraw(100 ether);

        // After the lock expires the withdrawal is allowed (lock is a delay, not a freeze).
        vm.warp(block.timestamp + 1 days);
        vm.prank(attacker);
        bp.withdraw(100 ether);
    }

    function test_Finding1_WithdrawAllowedAfterLock() public {
        bp.setStakeLock(1 days);
        bp.mintToken(honest, 50 ether);
        vm.prank(honest);
        bp.stake(50 ether);

        vm.warp(block.timestamp + 1 days);
        vm.prank(honest);
        bp.withdraw(50 ether);
        assertEq(bp.stakedBalance(honest), 0, "withdrawal should succeed post-lock");
    }

    function test_Finding1_StakeRefreshesLockWindow() public {
        bp.setStakeLock(1 days);
        bp.mintToken(honest, 100 ether);

        vm.prank(honest);
        bp.stake(40 ether);
        uint256 firstUnlock = bp.stakeUnlockTime(honest);

        // Let most of the window pass, then top up: lock must extend, not ride the old one.
        vm.warp(block.timestamp + 12 hours);
        vm.prank(honest);
        bp.stake(60 ether);
        uint256 secondUnlock = bp.stakeUnlockTime(honest);
        assertGt(secondUnlock, firstUnlock, "topping up must refresh the lock");
        assertEq(secondUnlock, block.timestamp + 1 days);

        // The original window has elapsed, but the refreshed window has not.
        vm.warp(firstUnlock + 1);
        vm.prank(honest);
        vm.expectRevert(abi.encodeWithSelector(TokenizedBlueprintBase.StakeLocked.selector, secondUnlock));
        bp.withdraw(10 ether);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FINDING 2 (medium): ERC20 developer revenue stranded (no hook, no rescue).
    // SECURE INVARIANT: ERC20 revenue delivered via a plain transfer (no hook)
    // can be reconciled into the reward stream via syncReward() and claimed.
    // ─────────────────────────────────────────────────────────────────────────

    function test_Finding2_SyncRescuesStrandedErc20Revenue() public {
        bp.mintToken(honest, 100 ether);
        vm.prank(honest);
        bp.stake(100 ether);

        // Revenue arrives as a bare ERC20 transfer — NO _onPaymentReceived hook fires.
        revenueToken.mint(address(bp), 500 ether);

        // Before sync, nothing is tracked: the staker has earned zero.
        assertEq(bp.earned(honest, address(revenueToken)), 0, "no hook => untracked");

        // Permissionless reconciliation pulls the surplus into the reward stream.
        uint256 synced = bp.syncReward(address(revenueToken));
        assertEq(synced, 500 ether, "all stranded revenue reconciled");

        // The staker can now claim it (mirrors pending-distribution double-claim pattern).
        vm.prank(honest);
        bp.claimReward(address(revenueToken));
        vm.prank(honest);
        bp.claimReward(address(revenueToken));

        assertEq(revenueToken.balanceOf(honest), 500 ether, "stranded revenue recovered to staker");
        assertEq(bp.rewards(honest, address(revenueToken)), 0);
    }

    function test_Finding2_SyncDoesNotDoubleCountHookedRevenue() public {
        bp.mintToken(honest, 100 ether);
        vm.prank(honest);
        bp.stake(100 ether);

        // Revenue that DID flow through the hook is already accounted.
        revenueToken.mint(address(bp), 300 ether);
        bp.externalPayment(address(revenueToken), 300 ether);

        // A redundant sync must find no untracked surplus (no re-crediting).
        uint256 synced = bp.syncReward(address(revenueToken));
        assertEq(synced, 0, "hooked revenue must not be re-credited");

        // Only the genuine surplus from a fresh bare transfer is reconciled.
        revenueToken.mint(address(bp), 200 ether);
        synced = bp.syncReward(address(revenueToken));
        assertEq(synced, 200 ether, "only the untracked surplus is synced");
    }

    function test_Finding2_SyncRejectsStakingToken() public {
        // Syncing the staking token would credit staked principal as revenue.
        vm.expectRevert(TokenizedBlueprintBase.CannotSyncStakingToken.selector);
        bp.syncReward(address(bp));
    }

    function test_Finding2_SyncRejectsNativeToken() public {
        vm.expectRevert(TokenizedBlueprintBase.CannotSyncStakingToken.selector);
        bp.syncReward(address(0));
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FINDING 3 (low): streaming rewards accrued while totalStaked == 0 are lost.
    // SECURE INVARIANT: rewards streamed during a zero-stake window are captured
    // and paid to the staker who arrives later, not silently discarded.
    // ─────────────────────────────────────────────────────────────────────────

    function test_Finding3_StreamingRewardsDuringZeroStakeNotLost() public {
        bp.setStreamingConfig(true, 7 days);

        // Revenue starts streaming while NOBODY is staked.
        vm.deal(address(this), 1 ether);
        (bool ok,) = address(bp).call{ value: 1 ether }("");
        require(ok, "payment failed");

        // The entire streaming period elapses with zero stake.
        vm.warp(block.timestamp + 7 days);

        // First staker arrives only now.
        bp.mintToken(honest, 100 ether);
        vm.prank(honest);
        bp.stake(100 ether);

        // The previously-unattributable streamed reward is now pending for them.
        // Two claims flush the pending distribution into the user balance
        // (pending is credited after the snapshot, same as instant-mode pending).
        vm.prank(honest);
        bp.claimReward();
        vm.prank(honest);
        bp.claimReward();

        // Without the fix this would be 0 (lastUpdateTime advanced past the window).
        assertApproxEqAbs(honest.balance, 1 ether, 1e9, "zero-stake streamed reward must be recovered");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FINDING 4 (low): instant-mode reward rounding truncates small payments to 0.
    // SECURE INVARIANT: the truncation residue of (amount * 1e18)/totalStaked is
    // carried forward, so a sequence of sub-threshold payments still accrues.
    // ─────────────────────────────────────────────────────────────────────────

    function test_Finding4_RoundingResidueCarriesForward() public {
        // Stake 1.5 tokens so that a 1-wei payment truncates on its own:
        //   (1 * 1e18) / 1.5e18 == 0  (floored)
        // but two such payments cross the per-token threshold:
        //   (2 * 1e18 + residue) / 1.5e18 == 1
        uint256 stakeAmt = 1.5e18;
        bp.mintToken(honest, stakeAmt);
        vm.prank(honest);
        bp.stake(stakeAmt);

        // First sub-threshold payment: alone it truncates to zero per-token.
        bp.externalPayment(address(revenueToken), 1);
        assertEq(bp.rewardPerToken(address(revenueToken)), 0, "single sub-threshold payment truncates");

        // Second sub-threshold payment: residue from the first is folded in and crosses 1.
        bp.externalPayment(address(revenueToken), 1);
        assertEq(bp.rewardPerToken(address(revenueToken)), 1, "carried residue must credit on the next payment");

        // The staker earns the accrued amount; without the residue carry this is 0.
        uint256 earned = bp.earned(honest, address(revenueToken));
        assertEq(earned, 1, "staker earns the residue-recovered reward");
    }

    function test_Finding4_PendingDistributionAlsoCarriesResidue() public {
        // pendingRewards distribution path (first staker after a zero-stake credit)
        // must also use the residue-carrying accumulator.
        // Credit while no one is staked -> goes to pendingRewards.
        bp.externalPayment(address(revenueToken), 1);
        bp.externalPayment(address(revenueToken), 1);

        // Stake 1.5 tokens; on the reward update the 2 wei pending crosses threshold.
        uint256 stakeAmt = 1.5e18;
        bp.mintToken(honest, stakeAmt);
        vm.prank(honest);
        bp.stake(stakeAmt);

        // Flush pending into the accumulator (credited after the stake snapshot).
        vm.prank(honest);
        bp.claimReward(address(revenueToken));

        assertEq(bp.rewardPerToken(address(revenueToken)), 1, "pending path carries residue and credits");
    }
}
