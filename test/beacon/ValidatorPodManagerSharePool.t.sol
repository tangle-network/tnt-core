// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";
import { ValidatorPodManager } from "../../src/beacon/ValidatorPodManager.sol";

/// @title ValidatorPodManagerSharePoolTest
/// @notice G-02 : Tests for share-pool accounting in ValidatorPodManager.
/// @dev Verifies:
///        - Proportional share minting on multiple deposits.
///        - Rebase up: shareholders see proportional asset gain.
///        - Rebase down (slash): shareholders see proportional asset loss; shares unchanged.
///        - First-depositor inflation defense via virtual offset.
///        - Per-pod isolation: a slash on pod A does not affect pod B.
///        - convertToShares / convertToAssets symmetry within virtual-offset precision.
///        - Withdrawal flow burns shares against the pool and pays out the live (or
///          snapshot, whichever is smaller) asset value.
contract ValidatorPodManagerSharePoolTest is BeaconTestBase {
    /// @notice Maximum precision dust from the 1e3 virtual offset.
    uint256 internal constant VIRTUAL_OFFSET_DUST = 1000;

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE MINTING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Two consecutive deposits from a fresh pool mint shares proportional to assets.
    function test_shares_proportionalMintingAcrossDeposits() public {
        ValidatorPod pod = _createPod(podOwner1);

        // First deposit: 10 ETH.
        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 10 ether);

        uint256 sharesAfterFirst = podManager.getSharesUint(podOwner1);
        // First mint is 1:1 due to virtual offset symmetry on empty pool.
        assertEq(sharesAfterFirst, 10 ether, "first deposit mints 1:1");

        // Second deposit: 5 ETH at the same exchange rate (no rebases happened in between).
        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 5 ether);

        uint256 sharesAfterSecond = podManager.getSharesUint(podOwner1);
        // Should mint approximately +5 ether shares (within virtual-offset dust).
        assertApproxEqAbs(
            sharesAfterSecond, 15 ether, VIRTUAL_OFFSET_DUST, "second deposit proportional shares"
        );
        assertEq(podManager.totalAssetsOf(podOwner1), 15 ether, "totalAssets sums deposits");
    }

    /// @notice After a rebase-up (rewards), shareholders see proportional gain in assets.
    function test_rebase_up_assetsIncreaseSharesUnchanged() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        uint256 sharesBefore = podManager.getSharesUint(podOwner1);
        assertEq(podManager.getRestakedAssets(podOwner1), 32 ether, "pre-rebase assets");

        // Beacon-chain rewards: +1 ETH.
        vm.prank(address(pod));
        podManager.recordBeaconChainRebase(podOwner1, int256(1 ether));

        // Shares unchanged; assets up by 1 ETH (modulo virtual-offset dust).
        assertEq(podManager.getSharesUint(podOwner1), sharesBefore, "shares unchanged on rebase up");
        assertApproxEqAbs(
            podManager.getRestakedAssets(podOwner1), 33 ether, VIRTUAL_OFFSET_DUST, "assets up by reward"
        );
    }

    /// @notice After a rebase-down (slash), shareholders see proportional loss; shares unchanged.
    function test_rebase_down_proportionalLoss() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        uint256 sharesBefore = podManager.getSharesUint(podOwner1);

        // Beacon-chain slash: -8 ETH (-25%).
        vm.prank(address(pod));
        podManager.recordBeaconChainRebase(podOwner1, -int256(8 ether));

        assertEq(podManager.getSharesUint(podOwner1), sharesBefore, "shares unchanged on slash");
        assertApproxEqAbs(
            podManager.getRestakedAssets(podOwner1), 24 ether, VIRTUAL_OFFSET_DUST, "assets reduced by slash"
        );
        assertEq(podManager.totalAssetsOf(podOwner1), 24 ether, "totalAssets reduced exactly");
    }

    /// @notice An over-large slash saturates totalAssets at zero (no underflow).
    function test_rebase_down_saturatesAtZero() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Slash bigger than the pool: should clamp to zero, not revert.
        vm.prank(address(pod));
        podManager.recordBeaconChainRebase(podOwner1, -int256(100 ether));

        assertEq(podManager.totalAssetsOf(podOwner1), 0, "totalAssets clamped to zero");
        // shares still positive (32 ether), but each share now claims only the virtual-offset dust.
        assertEq(podManager.getSharesUint(podOwner1), 32 ether, "shares still outstanding");
        assertLt(
            podManager.getRestakedAssets(podOwner1), VIRTUAL_OFFSET_DUST, "assets <= virtual offset on full slash"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFLATION ATTACK DEFENSE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The classic ERC4626 first-depositor inflation attack is impossible because
    ///         each pod has a single owner. We still verify the virtual-offset math:
    ///         a 1-wei deposit followed by a large donation does not let the attacker
    ///         skim the second-depositor's funds (here, the second deposit is the same owner).
    /// @dev This test exercises the conversion math that guards against share inflation,
    ///      even though the multi-shareholder attack vector is structurally absent.
    function test_inflation_firstDepositOneWeiThenLargeDonation() public {
        ValidatorPod pod = _createPod(podOwner1);

        // Step 1: depositor seeds the pool with a 1-wei deposit.
        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 1);

        uint256 sharesAfterSeed = podManager.getSharesUint(podOwner1);
        // Virtual-offset math: shares = 1 * (0 + 1e3) / (0 + 1e3) = 1.
        assertEq(sharesAfterSeed, 1, "seed deposit mints 1 share");

        // Step 2: a "donation" arrives via rebase-up of 1000 ETH.
        // In a multi-depositor design, this is the inflation attack: the seed depositor
        // would have a 1-share claim on a 1000 ETH pool. With the virtual offset, the
        // second depositor is still protected.
        vm.prank(address(pod));
        podManager.recordBeaconChainRebase(podOwner1, int256(1000 ether));

        // Step 3: simulate a "second" deposit on top of the inflated pool. Same owner here
        // since one pod = one owner; we exercise the math.
        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 100 ether);

        // The new mint must reflect proportional ownership of the new contribution.
        // Without the virtual offset, the second deposit would mint 0 shares (rounding to 0).
        // With virtual offset (1e3), it mints a proportionally-correct number of shares
        // bounded below by the inflation-defense floor.
        uint256 totalSharesAfter = podManager.totalSharesOf(podOwner1);
        uint256 totalAssetsAfter = podManager.totalAssetsOf(podOwner1);
        assertEq(totalAssetsAfter, 1 + 1000 ether + 100 ether, "totalAssets sums all contributions");
        // totalShares should still grow: virtual offset prevents zero-mint.
        assertGt(totalSharesAfter, sharesAfterSeed, "second deposit mints non-zero shares");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PER-POD ISOLATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice A slash on one pod does not affect another pod's share/asset accounting.
    /// @dev This is the per-pod-isolation invariant we preserve over the Lido-style
    ///      global-pool model.
    function test_isolation_slashOnPodADoesNotAffectPodB() public {
        ValidatorPod podA = _createPod(podOwner1);
        ValidatorPod podB = _createPod(podOwner2);

        vm.prank(address(podA));
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);
        vm.prank(address(podB));
        podManager.recordBeaconChainDeposit(podOwner2, 32 ether);

        // Slash pod A by 16 ETH.
        vm.prank(address(podA));
        podManager.recordBeaconChainRebase(podOwner1, -int256(16 ether));

        assertEq(podManager.totalAssetsOf(podOwner1), 16 ether, "podA assets reduced");
        assertEq(podManager.totalAssetsOf(podOwner2), 32 ether, "podB assets unaffected");
        assertEq(podManager.getSharesUint(podOwner2), 32 ether, "podB shares unaffected");
        assertEq(
            podManager.getRestakedAssets(podOwner2), 32 ether, "podB asset-equivalent unchanged"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONVERSION HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice convertToShares / convertToAssets are inverses up to virtual-offset rounding.
    function test_conversion_roundTripStable() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 100 ether);

        uint256 assets = 17 ether;
        uint256 shares = podManager.convertToShares(podOwner1, assets);
        uint256 assetsBack = podManager.convertToAssets(podOwner1, shares);

        // Floor rounding on both directions yields assetsBack <= assets, with bounded loss.
        assertLe(assetsBack, assets, "round-trip is non-increasing (floor rounding)");
        assertApproxEqAbs(assetsBack, assets, VIRTUAL_OFFSET_DUST, "round-trip precision");
    }

    /// @notice convertToShares deposit-direction rounds shares DOWN.
    function test_conversion_depositRoundsDown() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 1 ether);

        // After a small odd-amount rebase up, the price is 1.5x (not exact).
        // Then convertToShares of 1 wei should round DOWN to zero shares.
        vm.prank(address(pod));
        podManager.recordBeaconChainRebase(podOwner1, int256(1 ether));

        uint256 oneWeiShares = podManager.convertToShares(podOwner1, 1);
        assertEq(oneWeiShares, 0, "1 wei converts to 0 shares (rounds down)");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL FLOW (G-02: SHARE-DENOMINATED)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Withdrawal queues shares; on completion the staker receives min(snapshot, live).
    function test_withdrawal_normalFlow() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Fund pod with ETH for withdrawal.
        vm.deal(address(pod), 32 ether);

        // Queue a 10-share withdrawal. At 1:1 rate this snapshots 10 ETH.
        vm.prank(podOwner1);
        bytes32 root = podManager.queueWithdrawal(10 ether);

        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        podManager.completeWithdrawal(root);

        // Payout is exactly 10 ETH (snapshot == live, no rebase happened).
        assertEq(podOwner1.balance, balBefore + 10 ether, "exact payout at unchanged rate");
        assertEq(podManager.getSharesUint(podOwner1), 22 ether, "remaining shares decreased");
        assertEq(podManager.totalAssetsOf(podOwner1), 22 ether, "pool totalAssets reduced");
        assertEq(podManager.totalSharesOf(podOwner1), 22 ether, "pool totalShares reduced");
    }

    /// @notice If the pool rebases DOWN between queue and complete, staker absorbs the slash.
    function test_withdrawal_slashBetweenQueueAndComplete() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Queue 16 shares (snapshot = 16 ETH at current rate).
        vm.prank(podOwner1);
        bytes32 root = podManager.queueWithdrawal(16 ether);

        // Slash 50%: pool now totalAssets = 16 ETH, totalShares = 32 ETH.
        // Live convertToAssets(16) = 16 * (16e18 + 1e3) / (32e18 + 1e3) ~= 8 ETH.
        vm.prank(address(pod));
        podManager.recordBeaconChainRebase(podOwner1, -int256(16 ether));

        // Fund pod for the (reduced) payout. Slightly over-fund to absorb any virtual-offset dust.
        vm.deal(address(pod), 9 ether);

        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        podManager.completeWithdrawal(root);

        // Payout ~= 8 ETH (live), bounded above by the 16 ETH snapshot.
        uint256 received = podOwner1.balance - balBefore;
        assertApproxEqAbs(received, 8 ether, VIRTUAL_OFFSET_DUST, "payout reflects slash");
        assertLe(received, 16 ether, "payout <= queue-time snapshot");
    }

    /// @notice If the pool rebases UP between queue and complete, payout is capped at snapshot.
    function test_withdrawal_rewardsBetweenQueueAndCompleteCappedAtSnapshot() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Queue 8 shares (snapshot = 8 ETH).
        vm.prank(podOwner1);
        bytes32 root = podManager.queueWithdrawal(8 ether);

        // Rewards: +16 ETH. Pool: assets=48, shares=32. Live convertToAssets(8) = 12 ETH.
        vm.prank(address(pod));
        podManager.recordBeaconChainRebase(podOwner1, int256(16 ether));

        vm.deal(address(pod), 16 ether);

        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        podManager.completeWithdrawal(root);

        // Payout capped at 8 ETH snapshot (post-queue rebase up stays with the pool).
        uint256 received = podOwner1.balance - balBefore;
        assertEq(received, 8 ether, "payout capped at snapshot");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ACCESS CONTROL
    // ═══════════════════════════════════════════════════════════════════════════

    function test_recordBeaconChainDeposit_OnlyPod() public {
        _createPod(podOwner1);

        vm.prank(attacker);
        vm.expectRevert(ValidatorPodManager.OnlyPod.selector);
        podManager.recordBeaconChainDeposit(podOwner1, 1 ether);
    }

    function test_recordBeaconChainRebase_OnlyPod() public {
        _createPod(podOwner1);

        vm.prank(attacker);
        vm.expectRevert(ValidatorPodManager.OnlyPod.selector);
        podManager.recordBeaconChainRebase(podOwner1, int256(1 ether));
    }

    function test_recordBeaconChainDeposit_ZeroAmountReverts() public {
        ValidatorPod pod = _createPod(podOwner1);

        vm.prank(address(pod));
        vm.expectRevert(ValidatorPodManager.ZeroAmount.selector);
        podManager.recordBeaconChainDeposit(podOwner1, 0);
    }
}
