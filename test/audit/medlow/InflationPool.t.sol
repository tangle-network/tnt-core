// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { InflationPool } from "../../../src/rewards/InflationPool.sol";
import { TangleMetrics } from "../../../src/rewards/TangleMetrics.sol";
import { RewardVaults } from "../../../src/rewards/RewardVaults.sol";
import { TangleToken } from "../../../src/governance/TangleToken.sol";

/// @title InflationPool audit regression (medium/low)
/// @notice Asserts the SECURE invariants for the inflation-unit audit findings. Each test is
///         written so that reverting the corresponding fix in InflationPool.sol makes it fail.
///
/// Findings covered (deduped):
///  - MEDIUM: epoch budget recounts unclaimed pending rewards -> over-accrual.
///            Root fix: pendingRewardsLiability is incremented on accrual / decremented on claim
///            so calculateEpochBudget() (via freeBalance()) excludes earmarked tokens.
///  - LOW (F7): permissionless distributeEpoch() (empty serviceIds) must NOT reallocate the
///         epoch's stakersTarget into the other streams — an attacker who is an operator/customer/
///         developer could front-run the keeper to redirect staker inflation to themselves. Root
///         fix: the staker shortfall is reallocated ONLY when staker distribution was attempted
///         (serviceIds provided); otherwise the staker slice is retained in the pool and rolls
///         into a later epoch.
///  - LOW (x3, same root): _distributeStakingRewards split cross-vault by raw deposits (ignoring
///         lock-multiplier score) AND transferred TNT before the swallowed notify try/catch,
///         stranding tokens on revert. Root fix: weight by totalScore; transfer only after the
///         vault accepts the reward.
contract InflationPoolAuditMedLowTest is Test {
    InflationPool internal pool;
    TangleMetrics internal metrics;
    RewardVaults internal vaults;
    TangleToken internal tnt;

    address internal admin = address(0xA11CE);
    address internal operator1 = address(0x0F1);
    address internal operator2 = address(0x0F2);
    address internal customer1 = address(0xC051);
    address internal developer1 = address(0xDE7);
    address internal delegator1 = address(0xDE1);
    address internal delegator2 = address(0xDE2);
    address internal stranger = address(0xBAD);

    // A second, non-native vault asset (only needs a distinct non-zero address: recordStake
    // is pure accounting and never touches the asset token).
    address internal asset2 = address(0xA552);

    uint256 internal constant INITIAL_SUPPLY = 50_000_000 ether;
    uint256 internal constant POOL_FUNDING = 500_000 ether;
    uint256 internal constant EPOCH_LENGTH = 100; // seconds
    // funding period seconds default = 365 days; with 100s epochs epochsRemaining starts large.

    function setUp() public {
        vm.startPrank(admin);

        TangleToken tntImpl = new TangleToken();
        ERC1967Proxy tntProxy =
            new ERC1967Proxy(address(tntImpl), abi.encodeCall(TangleToken.initialize, (admin, INITIAL_SUPPLY)));
        tnt = TangleToken(address(tntProxy));

        TangleMetrics metricsImpl = new TangleMetrics();
        ERC1967Proxy metricsProxy =
            new ERC1967Proxy(address(metricsImpl), abi.encodeCall(TangleMetrics.initialize, (admin)));
        metrics = TangleMetrics(address(metricsProxy));

        RewardVaults vaultsImpl = new RewardVaults();
        ERC1967Proxy vaultsProxy = new ERC1967Proxy(
            address(vaultsImpl), abi.encodeCall(RewardVaults.initialize, (admin, address(tnt), 1500))
        );
        vaults = RewardVaults(address(vaultsProxy));

        InflationPool poolImpl = new InflationPool();
        ERC1967Proxy poolProxy = new ERC1967Proxy(
            address(poolImpl),
            abi.encodeCall(
                InflationPool.initialize, (admin, address(tnt), address(metrics), address(vaults), EPOCH_LENGTH)
            )
        );
        pool = InflationPool(address(poolProxy));

        metrics.grantRecorderRole(address(this));
        vaults.grantRole(vaults.REWARDS_MANAGER_ROLE(), address(pool));
        // Test contract also needs the role to seed vault stakes directly for the cross-vault test.
        vaults.grantRole(vaults.REWARDS_MANAGER_ROLE(), address(this));

        vaults.createVault(address(0), 1_000_000 ether);
        vaults.createVault(asset2, 1_000_000 ether);

        tnt.transfer(admin, POOL_FUNDING);
        tnt.approve(address(pool), POOL_FUNDING);
        pool.fund(POOL_FUNDING);

        pool.setMinStakeEpochs(1);

        vm.stopPrank();
    }

    // ────────────────────────────────────────────────────────────────────────────
    // helpers
    // ────────────────────────────────────────────────────────────────────────────

    function _warpToEpochEnd() internal {
        InflationPool.EpochData memory e = pool.getEpoch(pool.currentEpoch());
        vm.warp(e.endTimestamp + 1);
    }

    // ────────────────────────────────────────────────────────────────────────────
    // MEDIUM: epoch budget must NOT recount earmarked (accrued-but-unclaimed) rewards.
    // ────────────────────────────────────────────────────────────────────────────

    /// @notice Accruing operator rewards must raise pendingRewardsLiability so freeBalance()
    ///         drops and the next budget is computed off the un-earmarked balance only.
    ///         Before the fix the liability slot stayed 0, so freeBalance()==poolBalance()
    ///         and the same earmarked tokens were re-budgeted every epoch.
    function test_LiabilityTracksAccrual_BudgetUsesFreeBalance() public {
        vm.prank(admin);
        pool.registerOperator(operator1);

        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordHeartbeat(operator1, 1, uint64(block.timestamp));

        // Epoch 1: operator registered this epoch, not yet eligible (minStakeEpochs=1).
        _warpToEpochEnd();
        pool.distributeEpoch();
        assertEq(pool.pendingRewardsLiability(), 0, "no accrual before eligibility");

        // Epoch 2: operator eligible -> rewards accrue -> liability must rise by exactly the
        // pending amount, and freeBalance() must equal poolBalance() - liability.
        _warpToEpochEnd();
        pool.distributeEpoch();

        uint256 pendingOp = pool.pendingOperatorRewards(operator1);
        assertGt(pendingOp, 0, "operator accrued rewards");
        assertEq(pool.pendingRewardsLiability(), pendingOp, "liability == accrued pending");
        assertEq(pool.freeBalance(), pool.poolBalance() - pendingOp, "freeBalance excludes earmarked rewards");
        // The budget is computed off the FREE balance, so it is bounded by it.
        assertLe(pool.calculateEpochBudget(), pool.freeBalance(), "budget bounded by free balance");
    }

    /// @notice Claiming must release the liability so it returns to its pre-accrual level.
    function test_LiabilityReleasedOnClaim() public {
        vm.prank(admin);
        pool.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        _warpToEpochEnd();
        pool.distributeEpoch(); // warmup
        _warpToEpochEnd();
        pool.distributeEpoch(); // accrual

        uint256 pendingOp = pool.pendingOperatorRewards(operator1);
        assertEq(pool.pendingRewardsLiability(), pendingOp);

        vm.prank(operator1);
        pool.claimOperatorRewards();

        assertEq(pool.pendingRewardsLiability(), 0, "liability fully released on claim");
        assertEq(pool.freeBalance(), pool.poolBalance(), "free == balance after all claims");
    }

    /// @notice Core anti-over-accrual invariant: with rewards sitting unclaimed across many
    ///         epochs, the per-epoch budget must keep shrinking toward the free balance rather
    ///         than re-budgeting the earmarked tokens. We assert the budget never exceeds the
    ///         free balance and that liability monotonically reflects unclaimed accruals.
    function test_BudgetNeverExceedsFreeBalanceAcrossEpochs() public {
        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerCustomer(customer1);
        vm.stopPrank();

        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        for (uint256 i = 0; i < 8; i++) {
            _warpToEpochEnd();
            pool.distributeEpoch();
            // Invariant after every epoch: the next budget is bounded by the un-earmarked balance.
            assertLe(pool.calculateEpochBudget(), pool.freeBalance(), "budget <= free balance");
            // Liability never exceeds the contract balance (tokens are actually held).
            assertLe(pool.pendingRewardsLiability(), pool.poolBalance(), "liability backed by balance");
        }

        // Unclaimed rewards have accumulated; liability must be strictly positive and equal
        // the sum of outstanding pending rewards.
        uint256 outstanding = pool.pendingOperatorRewards(operator1) + pool.pendingCustomerRewards(customer1);
        assertGt(outstanding, 0, "rewards outstanding");
        assertEq(pool.pendingRewardsLiability(), outstanding, "liability == outstanding pending sum");
    }

    /// @notice emergencyWithdraw moves the whole balance out; the liability counter must reset
    ///         so a migrated/redeployed pool does not carry a phantom earmark.
    function test_EmergencyWithdrawResetsLiability() public {
        vm.prank(admin);
        pool.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        _warpToEpochEnd();
        pool.distributeEpoch();
        _warpToEpochEnd();
        pool.distributeEpoch();
        assertGt(pool.pendingRewardsLiability(), 0, "liability accrued");

        vm.prank(admin);
        pool.emergencyWithdraw(address(0xBEEF));

        assertEq(pool.poolBalance(), 0, "all tokens withdrawn");
        assertEq(pool.pendingRewardsLiability(), 0, "liability reset on full withdraw");
    }

    // ────────────────────────────────────────────────────────────────────────────
    // LOW: permissionless distributeEpoch() must not silently swallow stakersTarget.
    // ────────────────────────────────────────────────────────────────────────────

    /// @notice With a non-zero stakersBps and NO staker-inflation config (so stakers cannot be
    ///         paid via the empty-serviceIds permissionless path), the stakersTarget must be
    ///         reallocated to the other active categories — not dropped. We assert that the
    ///         epoch's total distribution still consumes the full per-category budget that the
    ///         active streams can absorb, with stakersDistributed == 0 but the staker slice
    ///         folded into staking/operator/customer/developer actuals.
    function test_PermissionlessDistributeRetainsStakerSlice() public {
        // 50% stakers weight, the rest spread so every other stream is active.
        vm.startPrank(admin);
        pool.setWeights(2000, 1000, 1000, 1000, 5000);
        pool.registerOperator(operator1);
        pool.registerCustomer(customer1);
        pool.registerDeveloper(developer1);
        vm.stopPrank();

        // Seed a native-vault stake so staking stream is active.
        vm.prank(admin);
        vaults.recordStake(address(0), delegator1, operator1, 1000 ether, RewardVaults.LockDuration.None);

        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordHeartbeat(operator1, 1, uint64(block.timestamp));
        metrics.recordBlueprintCreated(1, developer1);
        metrics.recordServiceCreated(1, 1, developer1, 1);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        // Warmup epoch so participants pass minStakeEpochs.
        _warpToEpochEnd();
        pool.distributeEpoch();

        // Read the budget right before the measured distribution so the derived targets match
        // the budget the contract actually uses (epochsRemaining is time-dependent).
        _warpToEpochEnd();
        uint256 budget = pool.calculateEpochBudget();
        uint256 stakersTarget = (budget * 5000) / 10_000;
        assertGt(stakersTarget, 0, "staker slice is large");

        // Permissionless caller advances the epoch with empty serviceIds.
        vm.prank(stranger);
        pool.distributeEpoch();

        InflationPool.EpochData memory e = pool.getEpoch(pool.currentEpoch() - 1);

        // Stakers got nothing (no config + empty serviceIds)...
        assertEq(e.stakersDistributed, 0, "no staker exposure distribution");

        // F7: ...and the staker slice is NOT reallocated into the other streams. With every
        // non-staker stream active, those distribute their own targets (the non-staker 50% base)
        // and nothing more — the staker 50% is retained in the pool and rolls into a later epoch,
        // so a permissionless front-runner cannot redirect staker inflation to themselves.
        uint256 totalDist = e.stakingDistributed + e.operatorsDistributed + e.customersDistributed
            + e.developersDistributed + e.stakersDistributed;
        uint256 nonStakerBase = budget - stakersTarget; // 50% of budget
        // Total paid out is bounded by the non-staker base (allow tiny rounding dust); the staker
        // slice was NOT redirected.
        assertLe(totalDist, nonStakerBase + 1e9, "staker slice retained, not reallocated");
        assertLt(totalDist, nonStakerBase + (stakersTarget / 10), "staker slice not redirected to other streams");
    }

    // ────────────────────────────────────────────────────────────────────────────
    // LOW: cross-vault staking split must use lock-multiplier SCORE, not raw deposits.
    // ────────────────────────────────────────────────────────────────────────────

    /// @notice Two vaults with EQUAL deposits but different lock multipliers must receive
    ///         reward shares proportional to score, not 50/50 by deposit. The locked vault
    ///         (1.6x) must get strictly more TNT than the unlocked vault (1.0x).
    function test_CrossVaultSplitWeightedByScoreNotDeposits() public {
        // Equal deposits in both vaults; vault asset2 is fully locked at 6 months (1.6x).
        vaults.recordStake(address(0), delegator1, operator1, 1000 ether, RewardVaults.LockDuration.None);
        vaults.recordStake(asset2, delegator2, operator2, 1000 ether, RewardVaults.LockDuration.SixMonths);

        // Sanity: deposits equal, scores differ.
        (uint256 dep0, uint256 score0,) = vaults.vaultStates(address(0));
        (uint256 dep2, uint256 score2,) = vaults.vaultStates(asset2);
        assertEq(dep0, dep2, "deposits equal across vaults");
        assertGt(score2, score0, "locked vault has higher score");

        // Drive one staking-only distribution: 100% weight to staking.
        vm.prank(admin);
        pool.setWeights(10_000, 0, 0, 0, 0);

        uint256 vault0Before = tnt.balanceOf(address(vaults));
        // Track per-vault accounting via rewardsDistributed (third field).
        (,, uint256 rd0Before) = vaults.vaultStates(address(0));
        (,, uint256 rd2Before) = vaults.vaultStates(asset2);

        _warpToEpochEnd();
        pool.distributeEpoch();

        (,, uint256 rd0After) = vaults.vaultStates(address(0));
        (,, uint256 rd2After) = vaults.vaultStates(asset2);

        uint256 reward0 = rd0After - rd0Before;
        uint256 reward2 = rd2After - rd2Before;

        assertGt(reward0, 0, "unlocked vault rewarded");
        assertGt(reward2, 0, "locked vault rewarded");
        // The locked vault must get strictly more (this FAILS under the old deposit-weighted
        // split, which would give an exact 50/50 tie).
        assertGt(reward2, reward0, "locked vault out-earns unlocked vault");

        // Ratio must track the score ratio (1.6x vs 1.0x -> 16:10), within rounding tolerance.
        // reward2 / reward0 ~= score2 / score0
        assertApproxEqRel(reward2 * score0, reward0 * score2, 0.01e18, "split tracks score ratio");

        // TNT actually moved into the vault for the accounted rewards.
        assertEq(tnt.balanceOf(address(vaults)) - vault0Before, reward0 + reward2, "transferred == accounted");
    }

    // ────────────────────────────────────────────────────────────────────────────
    // LOW: a vault notify revert must NOT strand TNT (no transfer without accounting).
    // ────────────────────────────────────────────────────────────────────────────

    /// @notice If distributeEpochReward reverts for a vault, the pool must NOT transfer TNT to
    ///         that vault (no orphaned tokens) and must NOT count it as distributed. We force
    ///         the revert by revoking the pool's REWARDS_MANAGER_ROLE on the vaults contract,
    ///         which makes vaults.distributeEpochReward revert on the onlyRole check — caught by
    ///         the try/catch. Under the old code the safeTransfer ran BEFORE the catch, stranding
    ///         the tokens; under the fix no transfer occurs.
    function test_NotifyRevertDoesNotStrandTNT() public {
        vaults.recordStake(address(0), delegator1, operator1, 1000 ether, RewardVaults.LockDuration.None);

        vm.startPrank(admin);
        pool.setWeights(10_000, 0, 0, 0, 0); // all to staking
        // Revoke the role so vaults.distributeEpochReward reverts inside _notifyVaultReward.
        vaults.revokeRole(vaults.REWARDS_MANAGER_ROLE(), address(pool));
        vm.stopPrank();

        uint256 poolBalBefore = pool.poolBalance();
        uint256 vaultBalBefore = tnt.balanceOf(address(vaults));

        _warpToEpochEnd();
        pool.distributeEpoch();

        // No tokens stranded in the vault, none left the pool for staking.
        assertEq(tnt.balanceOf(address(vaults)), vaultBalBefore, "no TNT transferred to vault on revert");
        assertEq(pool.poolBalance(), poolBalBefore, "pool balance unchanged when notify reverts");

        // The epoch advanced but recorded zero staking distribution.
        InflationPool.EpochData memory e = pool.getEpoch(pool.currentEpoch() - 1);
        assertEq(e.stakingDistributed, 0, "nothing counted as distributed on revert");
    }
}
