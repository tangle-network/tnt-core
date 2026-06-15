// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { RewardVaults } from "../../../src/rewards/RewardVaults.sol";

/// @dev Minimal ERC20 standing in for TangleToken. RewardVaults only ever calls
///      balanceOf(address) and transfer(address,uint256) on tntToken.
contract MockTNT {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "MockTNT: insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

/// @title RewardVaults — medium/low audit regression suite
/// @notice Asserts the SECURE invariants for the rewardvaults unit findings. Each test
///         fails if the corresponding fix in src/rewards/RewardVaults.sol is reverted.
contract RewardVaultsMedLowTest is Test {
    RewardVaults vault;
    MockTNT tnt;

    address ADMIN = address(this); // holds ADMIN_ROLE + REWARDS_MANAGER_ROLE after init
    address ASSET = address(0xA55E7);
    address OPERATOR = address(0x09E7A);
    address LOCKER = address(0x10C4E5); // 6-month locker (boosted)
    address PLAIN = address(0x914114); // unlocked, equal raw stake
    address GRIEFER = address(0x6217EF);

    uint16 constant LOCK_6MO_BPS = 16_000; // 1.6x boost tier
    uint256 constant STAKE = 1_000 ether;
    uint256 constant REWARD = 100 ether;

    function setUp() public {
        tnt = new MockTNT();

        RewardVaults impl = new RewardVaults();
        // operatorCommissionBps = 0 so 100% of each reward flows to the delegator pool,
        // making the boosted-vs-base split easy to read.
        bytes memory init = abi.encodeCall(RewardVaults.initialize, (ADMIN, address(tnt), uint16(0)));
        vault = RewardVaults(address(new ERC1967Proxy(address(impl), init)));

        vault.createVault(ASSET, type(uint128).max);

        // Plenty of TNT backing for several epochs.
        tnt.mint(address(vault), 10_000 ether);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FINDING (medium): Lock-multiplier reward boost must EXPIRE with the lock.
    // After lockExpiry, the boosted score must decay back to base (raw stake) so a
    // one-time locker stops siphoning a higher share of every future epoch.
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice While the lock is ACTIVE the boost applies; once it EXPIRES, future
    ///         rewards accrue at base (1.0x) weight, equal to an unlocked peer.
    function test_LockBoostDecaysAfterExpiry() public {
        // LOCKER: 1.6x boost via 6-month lock. PLAIN: same raw stake, no lock.
        vault.recordDelegate(LOCKER, OPERATOR, ASSET, STAKE, LOCK_6MO_BPS);
        vault.recordDelegate(PLAIN, OPERATOR, ASSET, STAKE, 0);

        // Scores: LOCKER = 1600, PLAIN = 1000  => pool totalStaked = 2600 (in ether units).
        (, uint256 lockerScore,, uint256 lockExpiry,) = _debt(LOCKER);
        assertEq(lockerScore, 1600 ether, "locker boosted score 1.6x");
        assertGt(lockExpiry, block.timestamp, "lock active");

        // ── EPOCH 1 (lock ACTIVE): boost applies. Of REWARD, locker gets 1600/2600,
        // plain gets 1000/2600. ──
        vault.distributeRewards(ASSET, OPERATOR, REWARD);
        uint256 lockerE1 = vault.pendingDelegatorRewards(ASSET, LOCKER, OPERATOR);
        uint256 plainE1 = vault.pendingDelegatorRewards(ASSET, PLAIN, OPERATOR);
        assertApproxEqAbs(lockerE1, (REWARD * 1600) / 2600, 1e6, "epoch1: locker earns boosted share");
        assertGt(lockerE1, plainE1, "epoch1: boosted locker out-earns plain peer");

        // ── Warp PAST the lock expiry. ──
        vm.warp(lockExpiry + 1);

        // ── EPOCH 2 (lock EXPIRED): decay-aware accrual. The next reward must split
        // by BASE weight. Realize the decay by claiming the locker first (lazy decay
        // collapses 1600 -> 1000 and updates the pool), then distribute. ──
        vm.prank(LOCKER);
        vault.claimDelegatorRewards(ASSET, OPERATOR);

        // Decay applied: locker boosted score collapsed to base == raw stake.
        (uint256 lockerStakeAfter, uint256 lockerScoreAfter,, uint256 expiryAfter,) = _debt(LOCKER);
        assertEq(lockerScoreAfter, lockerStakeAfter, "decay: boosted score back to base");
        assertEq(lockerScoreAfter, 1000 ether, "decay: base == raw stake");
        assertEq(expiryAfter, 0, "decay: lock metadata cleared");

        // Pool total score is now 1000 (locker, decayed) + 1000 (plain) = 2000.
        (, uint256 poolTotal,) = vault.operatorPools(ASSET, OPERATOR);
        assertEq(poolTotal, 2000 ether, "pool total reflects decayed score");

        // Distribute a SECOND, equal reward post-expiry. Locker and plain now have equal
        // weight, so this epoch's reward splits 50/50.
        vault.distributeRewards(ASSET, OPERATOR, REWARD);
        uint256 lockerE2 = vault.pendingDelegatorRewards(ASSET, LOCKER, OPERATOR);
        uint256 plainE2New = vault.pendingDelegatorRewards(ASSET, PLAIN, OPERATOR) - plainE1;

        assertApproxEqAbs(lockerE2, REWARD / 2, 1e6, "epoch2: expired locker earns ONLY base share");
        assertApproxEqAbs(
            lockerE2, plainE2New, 1e6, "epoch2: expired locker == unlocked peer (no lingering boost)"
        );
    }

    /// @notice A pure view (pendingDelegatorRewards) must report decay-aware accrual:
    ///         once the lock expires the unsettled accrual is valued at base weight, not
    ///         the stale boosted weight, so dashboards do not over-promise.
    function test_PendingViewIsDecayAware() public {
        vault.recordDelegate(LOCKER, OPERATOR, ASSET, STAKE, LOCK_6MO_BPS);
        vault.recordDelegate(PLAIN, OPERATOR, ASSET, STAKE, 0);

        (,,, uint256 lockExpiry,) = _debt(LOCKER);

        // Warp past expiry BEFORE any reward, then distribute one reward. No claim/decay
        // has been realized in storage yet — the view alone must value the locker at base.
        vm.warp(lockExpiry + 1);
        vault.distributeRewards(ASSET, OPERATOR, REWARD);

        // accumulatedPerShare advanced over the still-boosted on-chain totalStaked (2600).
        // The decay-aware view must apply BASE weight (1000), matching the plain peer.
        uint256 lockerPending = vault.pendingDelegatorRewards(ASSET, LOCKER, OPERATOR);
        uint256 plainPending = vault.pendingDelegatorRewards(ASSET, PLAIN, OPERATOR);
        assertApproxEqAbs(
            lockerPending, plainPending, 1e6, "view: expired locker valued at base, equal to plain peer"
        );
    }

    /// @notice A top-up AFTER expiry must collapse the stale boost first, so the
    ///         expired multiplier cannot persist or compound onto the new stake.
    function test_TopUpAfterExpiryCollapsesStaleBoost() public {
        vault.recordDelegate(LOCKER, OPERATOR, ASSET, STAKE, LOCK_6MO_BPS);
        (,,, uint256 lockExpiry,) = _debt(LOCKER);
        vm.warp(lockExpiry + 1);

        // Unboosted top-up of STAKE. Pre-fix, boostedScore would be 1600 + 1000 = 2600 on
        // 2000 raw stake (1.3x phantom boost). Post-fix the stale boost decays to 1000
        // first, then +1000, so score == raw stake == 2000.
        vault.recordDelegate(LOCKER, OPERATOR, ASSET, STAKE, 0);

        (uint256 stakeAfter, uint256 scoreAfter,, uint256 expiryAfter,) = _debt(LOCKER);
        assertEq(stakeAfter, 2000 ether, "raw stake after top-up");
        assertEq(scoreAfter, 2000 ether, "no lingering boost: score == raw stake");
        assertEq(expiryAfter, 0, "lock cleared after expiry+unboosted top-up");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FINDING (low): claimDelegatorRewardsFor must be access-controlled. An
    // arbitrary address must NOT be able to force-realize another account's rewards.
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice A random griefer cannot force-claim on behalf of a delegator.
    function test_ClaimForRevertsForUnauthorizedCaller() public {
        vault.recordDelegate(LOCKER, OPERATOR, ASSET, STAKE, 0);
        vault.distributeRewards(ASSET, OPERATOR, REWARD);

        // GRIEFER has no role and is not the position owner.
        vm.prank(GRIEFER);
        vm.expectRevert(
            abi.encodeWithSelector(RewardVaults.NotAuthorizedClaimer.selector, GRIEFER, LOCKER)
        );
        vault.claimDelegatorRewardsFor(ASSET, OPERATOR, LOCKER);
    }

    /// @notice The position owner may still self-claim via claimDelegatorRewardsFor.
    function test_ClaimForAllowedForOwner() public {
        vault.recordDelegate(LOCKER, OPERATOR, ASSET, STAKE, 0);
        vault.distributeRewards(ASSET, OPERATOR, REWARD);

        uint256 before = tnt.balanceOf(LOCKER);
        vm.prank(LOCKER);
        uint256 claimed = vault.claimDelegatorRewardsFor(ASSET, OPERATOR, LOCKER);
        assertApproxEqAbs(claimed, REWARD, 1e6, "owner self-claim pays the full pool reward");
        assertEq(tnt.balanceOf(LOCKER) - before, claimed, "funds delivered to the rightful owner");
    }

    /// @notice The rewards manager (protocol wiring) may still claim on behalf of a
    ///         delegator — funds always route to the delegator, never the caller.
    function test_ClaimForAllowedForRewardsManager() public {
        vault.recordDelegate(LOCKER, OPERATOR, ASSET, STAKE, 0);
        vault.distributeRewards(ASSET, OPERATOR, REWARD);

        // ADMIN (this test contract) holds REWARDS_MANAGER_ROLE from initialize().
        uint256 before = tnt.balanceOf(LOCKER);
        uint256 claimed = vault.claimDelegatorRewardsFor(ASSET, OPERATOR, LOCKER);
        assertGt(claimed, 0, "rewards manager can force-realize");
        assertEq(tnt.balanceOf(LOCKER) - before, claimed, "funds go to the delegator, not the caller");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FINDING (medium, x2 same root): _distributeToOperatorPool must NOT drop the
    // poolReward when an operator's pool has zero staked score. It must be parked in
    // a claimable bucket (pendingCommission) so nothing is burned and accounting
    // (rewardsDistributed) equals what was actually attributed.
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Distributing to an operator with no delegators parks the would-be pool
    ///         reward in pendingCommission instead of silently dropping it.
    function test_UnattributedRewardParkedWhenNoStake() public {
        // Use 15% commission so there is both a commission slice AND a pool slice; the
        // pool slice is the part that would otherwise be dropped (totalStaked == 0).
        // Commission starts at 0, so 1500 is an INCREASE queued behind the 7-day timelock.
        vault.setOperatorCommission(1500);
        vm.warp(block.timestamp + 7 days + 1);
        vault.executeCommissionIncrease();
        assertEq(vault.operatorCommissionBps(), 1500, "commission set to 15%");

        // No delegators recorded for OPERATOR -> pool.totalStaked == 0.
        (, uint256 totalStakedBefore,) = vault.operatorPools(ASSET, OPERATOR);
        assertEq(totalStakedBefore, 0, "precondition: no staked score");

        vm.expectEmit(true, true, false, true, address(vault));
        emit RewardVaults.UnattributedRewardParked(ASSET, OPERATOR, (REWARD * 8500) / 10_000);
        vault.distributeRewards(ASSET, OPERATOR, REWARD);

        // The full REWARD is now accounted: commission (15%) + parked pool reward (85%).
        uint256 pending = vault.pendingOperatorCommission(ASSET, OPERATOR);
        assertEq(pending, REWARD, "entire reward parked as claimable, nothing dropped");

        // rewardsDistributed equals what was actually attributed to a claimable bucket.
        (,, uint256 rewardsDistributed) = vault.vaultStates(ASSET);
        assertEq(rewardsDistributed, REWARD, "accounted reward == attributed reward");

        // accumulatedPerShare did NOT move (no delegators to credit, no div-by-zero burn).
        (uint256 accPerShare,,) = vault.operatorPools(ASSET, OPERATOR);
        assertEq(accPerShare, 0, "per-share rate untouched when no stake");
    }

    /// @notice The parked reward is fully recoverable: a real delegator that joins after
    ///         the operator claims its parked commission is not shortchanged, and the
    ///         contract holds enough TNT to honor the parked claim.
    function test_ParkedRewardIsClaimable() public {
        vault.distributeRewards(ASSET, OPERATOR, REWARD); // 0% commission -> all 100% parked

        uint256 pending = vault.pendingOperatorCommission(ASSET, OPERATOR);
        assertEq(pending, REWARD, "100% parked when commission is 0 and no stake");

        uint256 before = tnt.balanceOf(OPERATOR);
        vm.prank(OPERATOR);
        uint256 claimed = vault.claimOperatorCommission(ASSET);
        assertEq(claimed, REWARD, "operator recovers the full parked reward");
        assertEq(tnt.balanceOf(OPERATOR) - before, REWARD, "funds delivered, nothing burned");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // helper: read the public delegatorDebts mapping into a convenience tuple
    // ordered (stakedAmount, boostedScore, lockDuration, lockExpiry, accruedRewards).
    // ─────────────────────────────────────────────────────────────────────────
    function _debt(address delegator)
        internal
        view
        returns (
            uint256 stakedAmount,
            uint256 boostedScore,
            RewardVaults.LockDuration lockDuration,
            uint256 lockExpiry,
            uint256 accruedRewards
        )
    {
        // The auto-generated getter returns the struct fields in declaration order:
        // (lastAccumulatedPerShare, stakedAmount, lockDuration, lockExpiry, boostedScore, accruedRewards)
        (, uint256 _staked, RewardVaults.LockDuration _lock, uint256 _expiry, uint256 _boosted, uint256 _accrued) =
            vault.delegatorDebts(ASSET, delegator, OPERATOR);
        return (_staked, _boosted, _lock, _expiry, _accrued);
    }
}
