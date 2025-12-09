// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { TangleMetrics } from "../../src/v2/rewards/TangleMetrics.sol";
import { RewardVaults } from "../../src/v2/rewards/RewardVaults.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";

/// @title RewardsTest
/// @notice Tests for the TNT rewards/incentives system
contract RewardsTest is Test {
    TangleMetrics public metrics;
    RewardVaults public vaults;
    TangleToken public tnt;

    address public admin = address(0x1);
    address public operator1 = address(0x2);
    address public operator2 = address(0x3);
    address public delegator1 = address(0x4);
    address public delegator2 = address(0x5);

    function setUp() public {
        vm.startPrank(admin);

        // Deploy TNT token
        TangleToken tntImpl = new TangleToken();
        bytes memory tntData = abi.encodeCall(TangleToken.initialize, (admin, 50_000_000 * 1e18));
        ERC1967Proxy tntProxy = new ERC1967Proxy(address(tntImpl), tntData);
        tnt = TangleToken(address(tntProxy));

        // Deploy Metrics
        TangleMetrics metricsImpl = new TangleMetrics();
        bytes memory metricsData = abi.encodeCall(TangleMetrics.initialize, (admin));
        ERC1967Proxy metricsProxy = new ERC1967Proxy(address(metricsImpl), metricsData);
        metrics = TangleMetrics(address(metricsProxy));

        // Deploy RewardVaults
        RewardVaults vaultsImpl = new RewardVaults();
        bytes memory vaultsData = abi.encodeCall(RewardVaults.initialize, (admin, address(tnt), 1500)); // 15% commission
        ERC1967Proxy vaultsProxy = new ERC1967Proxy(address(vaultsImpl), vaultsData);
        vaults = RewardVaults(address(vaultsProxy));

        // Fund vaults with TNT for reward distribution (new pre-funded model - no minting)
        tnt.transfer(address(vaults), 1_000_000 ether);

        // Grant RECORDER_ROLE to this test contract
        metrics.grantRecorderRole(address(this));

        // Grant REWARDS_MANAGER_ROLE to this test contract
        vaults.grantRole(vaults.REWARDS_MANAGER_ROLE(), address(this));

        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // METRICS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Metrics_RecordStake() public {
        address asset = address(0); // native

        metrics.recordStake(delegator1, operator1, asset, 100 ether);

        assertEq(metrics.totalStakedByAsset(asset), 100 ether);
        assertEq(metrics.delegatorStakeByAsset(delegator1, asset), 100 ether);
        assertEq(metrics.operatorTotalStake(operator1), 100 ether);
    }

    function test_Metrics_RecordUnstake() public {
        address asset = address(0);

        // Stake first
        metrics.recordStake(delegator1, operator1, asset, 100 ether);

        // Unstake half
        metrics.recordUnstake(delegator1, operator1, asset, 50 ether);

        assertEq(metrics.totalStakedByAsset(asset), 50 ether);
        assertEq(metrics.delegatorStakeByAsset(delegator1, asset), 50 ether);
        assertEq(metrics.operatorTotalStake(operator1), 50 ether);
    }

    function test_Metrics_RecordOperatorRegistered() public {
        address asset = address(0);

        metrics.recordOperatorRegistered(operator1, asset, 10 ether);

        assertEq(metrics.totalStakedByAsset(asset), 10 ether);
        assertEq(metrics.operatorTotalStake(operator1), 10 ether);
    }

    function test_Metrics_RecordHeartbeat() public {
        metrics.recordHeartbeat(operator1, 1, uint64(block.timestamp));

        assertEq(metrics.operatorHeartbeats(operator1), 1);
        assertEq(metrics.operatorLastHeartbeat(operator1), block.timestamp);
    }

    function test_Metrics_RecordJobCompletion() public {
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordJobCompletion(operator1, 1, 1, false);

        assertEq(metrics.operatorJobsCompleted(operator1), 2);
        assertEq(metrics.operatorJobsSuccessful(operator1), 1);
        assertEq(metrics.getOperatorSuccessRate(operator1), 5000); // 50%
    }

    function test_Metrics_RecordPayment() public {
        metrics.recordPayment(delegator1, 1, address(0), 1 ether);

        assertEq(metrics.totalFeesPaid(delegator1), 1 ether);
        assertEq(metrics.totalPaymentsRecorded(), 1);
    }

    function test_Metrics_RecordServiceCreated() public {
        metrics.recordServiceCreated(1, 0, admin, 3);

        assertEq(metrics.totalServicesCreated(), 1);
    }

    function test_Metrics_RecordJobCall() public {
        metrics.recordJobCall(1, delegator1, 0);

        assertEq(metrics.totalJobsCalled(), 1);
    }

    function test_Metrics_HeartbeatRecency() public {
        metrics.recordHeartbeat(operator1, 1, uint64(block.timestamp));

        assertTrue(metrics.isHeartbeatRecent(operator1, 60)); // Within 60 seconds

        vm.warp(block.timestamp + 120);
        assertFalse(metrics.isHeartbeatRecent(operator1, 60)); // Now too old
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD VAULTS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Vaults_CreateVault() public {
        vm.prank(admin);
        vaults.createVault(
            address(0),      // native asset
            500,             // 5% APY
            1_000_000 ether, // 1M deposit cap
            100_000 ether,   // 100k incentive cap
            10000            // 1x boost
        );

        (uint256 apy, uint256 depCap, uint256 incCap, uint256 boost, bool active) = vaults.vaultConfigs(address(0));
        assertEq(apy, 500);
        assertEq(depCap, 1_000_000 ether);
        assertEq(incCap, 100_000 ether);
        assertEq(boost, 10000);
        assertTrue(active);
    }

    function test_Vaults_CreateVault_RevertInvalidAPY() public {
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(RewardVaults.InvalidAPY.selector, 15000));
        vaults.createVault(address(0), 15000, 1_000_000 ether, 100_000 ether, 10000); // 150% APY - too high
    }

    function test_Vaults_RecordStake() public {
        // Create vault first
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        // Record stake
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);

        (uint256 totalDep,,,) = vaults.vaultStates(address(0));
        assertEq(totalDep, 100 ether);
    }

    function test_Vaults_RecordDelegateAndUndelegate() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordDelegate(delegator1, operator1, address(0), 500 ether, 12000);
        (uint256 totalDeposits, uint256 totalScore,,) = vaults.vaultStates(address(0));
        assertEq(totalDeposits, 500 ether);
        assertEq(totalScore, 600 ether); // 1.2x multiplier

        vaults.recordUndelegate(delegator1, operator1, address(0), 200 ether);

        (totalDeposits, totalScore,,) = vaults.vaultStates(address(0));
        assertEq(totalDeposits, 300 ether);
        assertEq(totalScore, 360 ether); // Maintains proportional boosted score

        (, uint256 totalStaked,,) = vaults.operatorPools(address(0), operator1);
        assertEq(totalStaked, 300 ether);
    }

    function test_Vaults_DistributeRewards() public {
        // Create vault
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        // Record stake
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);

        // Distribute rewards
        vaults.distributeRewards(address(0), operator1, 10 ether);

        // Check operator commission (15% of 10 ether = 1.5 ether)
        uint256 commission = vaults.pendingOperatorCommission(address(0), operator1);
        assertEq(commission, 1.5 ether);
    }

    function test_Vaults_ClaimOperatorCommission() public {
        // Setup
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.distributeRewards(address(0), operator1, 10 ether);

        // Claim commission
        uint256 balanceBefore = tnt.balanceOf(operator1);
        vm.prank(operator1);
        vaults.claimOperatorCommission(address(0));
        uint256 balanceAfter = tnt.balanceOf(operator1);

        assertEq(balanceAfter - balanceBefore, 1.5 ether); // 15% commission
    }

    function test_Vaults_ClaimDelegatorRewards() public {
        // Setup
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.distributeRewards(address(0), operator1, 10 ether);

        // Claim delegator rewards (85% of 10 ether = 8.5 ether)
        uint256 balanceBefore = tnt.balanceOf(delegator1);
        vm.prank(delegator1);
        vaults.claimDelegatorRewards(address(0), operator1);
        uint256 balanceAfter = tnt.balanceOf(delegator1);

        assertEq(balanceAfter - balanceBefore, 8.5 ether); // 85% to pool, delegator has 100% of pool
    }

    function test_Vaults_LockMultiplier() public {
        // Create vault
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        // Record stake with 6-month lock (1.6x multiplier)
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.SixMonths);

        // Check score includes multiplier (100 * 1.6 = 160)
        (, uint256 totalScore,,) = vaults.vaultStates(address(0));
        assertEq(totalScore, 160 ether);
    }

    function test_Vaults_RecordStake_RevertWhenVaultInactive() public {
        vm.startPrank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);
        vaults.deactivateVault(address(0));
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(RewardVaults.VaultNotActive.selector, address(0)));
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
    }

    function test_Vaults_RecordStake_RevertWhenDepositCapExceeded() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 100 ether, 100 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 80 ether, RewardVaults.LockDuration.None);

        vm.expectRevert(abi.encodeWithSelector(RewardVaults.DepositCapExceeded.selector, address(0)));
        vaults.recordStake(address(0), delegator1, operator1, 30 ether, RewardVaults.LockDuration.SixMonths);
    }

    function test_Vaults_RecordDelegate_RevertWhenDepositCapExceeded() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 100 ether, 100 ether, 10000);

        vaults.recordDelegate(delegator1, operator1, address(0), 90 ether, 10000);

        vm.expectRevert(abi.encodeWithSelector(RewardVaults.DepositCapExceeded.selector, address(0)));
        vaults.recordDelegate(delegator2, operator1, address(0), 20 ether, 15000);
    }

    function test_Vaults_RecordDelegate_RevertWhenVaultInactive() public {
        vm.startPrank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);
        vaults.deactivateVault(address(0));
        vm.stopPrank();

        vm.expectRevert(abi.encodeWithSelector(RewardVaults.VaultNotActive.selector, address(0)));
        vaults.recordDelegate(delegator1, operator1, address(0), 10 ether, 10000);
    }

    function test_Vaults_MultipleOperators() public {
        // Create vault
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        // Delegator1 stakes to operator1, delegator2 stakes to operator2
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.recordStake(address(0), delegator2, operator2, 200 ether, RewardVaults.LockDuration.None);

        // Distribute rewards to both operators
        vaults.distributeRewards(address(0), operator1, 10 ether);
        vaults.distributeRewards(address(0), operator2, 20 ether);

        // Claim rewards
        vm.prank(delegator1);
        uint256 claimed1 = vaults.claimDelegatorRewards(address(0), operator1);

        vm.prank(delegator2);
        uint256 claimed2 = vaults.claimDelegatorRewards(address(0), operator2);

        assertEq(claimed1, 8.5 ether);  // 85% of 10
        assertEq(claimed2, 17 ether);   // 85% of 20
    }

    function test_Vaults_EpochRewardDistributesAcrossOperators() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.recordStake(address(0), delegator2, operator2, 300 ether, RewardVaults.LockDuration.None);

        vaults.distributeEpochReward(address(0), 80 ether);

        vm.prank(delegator1);
        uint256 claimed1 = vaults.claimDelegatorRewards(address(0), operator1);

        vm.prank(delegator2);
        uint256 claimed2 = vaults.claimDelegatorRewards(address(0), operator2);

        assertEq(claimed1, 17 ether);
        assertEq(claimed2, 51 ether);
        assertEq(vaults.pendingOperatorCommission(address(0), operator1), 3 ether);
        assertEq(vaults.pendingOperatorCommission(address(0), operator2), 9 ether);
    }

    function test_Vaults_UtilizationView() public {
        // Create vault with 1000 cap
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1000 ether, 100 ether, 10000);

        // Stake 100 (10% of cap)
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);

        uint256 utilization = vaults.getVaultUtilization(address(0));
        assertEq(utilization, 1000); // 10% = 1000 bps
    }

    function test_Vaults_DeactivateVault() public {
        // Create and deactivate vault
        vm.startPrank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);
        vaults.deactivateVault(address(0));
        vm.stopPrank();

        (,,,, bool active) = vaults.vaultConfigs(address(0));
        assertFalse(active);
    }

    function test_Vaults_UpdateConfig() public {
        // Create vault
        vm.startPrank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        // Update config
        vaults.updateVaultConfig(address(0), 1000, 2_000_000 ether, 200_000 ether, 12000);
        vm.stopPrank();

        (uint256 apy, uint256 depCap, uint256 incCap, uint256 boost,) = vaults.vaultConfigs(address(0));
        assertEq(apy, 1000);
        assertEq(depCap, 2_000_000 ether);
        assertEq(incCap, 200_000 ether);
        assertEq(boost, 12000);
    }

    function test_Vaults_SetOperatorCommission() public {
        vm.prank(admin);
        vaults.setOperatorCommission(2000); // 20%

        assertEq(vaults.operatorCommissionBps(), 2000);
    }

    function test_Vaults_SetDecayConfig() public {
        vm.prank(admin);
        vaults.setDecayConfig(1_000_000, 100); // Start at block 1M, 1% rate

        assertEq(vaults.decayStartBlock(), 1_000_000);
        assertEq(vaults.decayRateBps(), 100);
    }

    function test_Vaults_LargeBalanceRewardAccrual() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 10_000_000 ether, 2_000_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 5_000_000 ether, RewardVaults.LockDuration.None);

        vaults.distributeRewards(address(0), operator1, 400_000 ether);
        vaults.distributeRewards(address(0), operator1, 100_000 ether);

        uint256 pendingCommission = vaults.pendingOperatorCommission(address(0), operator1);
        assertEq(pendingCommission, 75_000 ether); // 15% of 500k

        vm.prank(delegator1);
        uint256 claimedRewards = vaults.claimDelegatorRewards(address(0), operator1);
        assertEq(claimedRewards, 425_000 ether); // Remaining 85%

        uint256 operatorBalanceBefore = tnt.balanceOf(operator1);
        vm.prank(operator1);
        uint256 claimedCommission = vaults.claimOperatorCommission(address(0));
        assertEq(claimedCommission, 75_000 ether);
        assertEq(tnt.balanceOf(operator1) - operatorBalanceBefore, 75_000 ether);
    }

    function test_Vaults_RecordUndelegateClearsBoostedScore() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordDelegate(delegator1, operator1, address(0), 400 ether, 15000); // Score = 600

        (, uint256 totalScore,,) = vaults.vaultStates(address(0));
        assertEq(totalScore, 600 ether);

        vaults.recordUndelegate(delegator1, operator1, address(0), 400 ether);

        (, totalScore,,) = vaults.vaultStates(address(0));
        assertEq(totalScore, 0);

        (, uint256 totalStaked,,) = vaults.operatorPools(address(0), operator1);
        assertEq(totalStaked, 0);
    }

    function test_Vaults_VaultSummaryAndAllSummaries() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 16000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.SixMonths);

        RewardVaults.VaultSummary memory summary = vaults.getVaultSummary(address(0));
        assertEq(summary.asset, address(0));
        assertEq(summary.totalDeposits, 100 ether);
        assertEq(summary.totalScore, 160 ether);
        assertEq(summary.depositCapRemaining, 1_000_000 ether - 160 ether);

        RewardVaults.VaultSummary[] memory summaries = vaults.getAllVaultSummaries();
        assertEq(summaries.length, 1);
        assertEq(summaries[0].totalDeposits, 100 ether);
    }

    function test_Vaults_GetDelegatorPositionsAndPending() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.recordStake(address(0), delegator1, operator2, 50 ether, RewardVaults.LockDuration.OneMonth);

        vaults.distributeRewards(address(0), operator1, 10 ether);
        vaults.distributeRewards(address(0), operator2, 8 ether);

        (RewardVaults.PendingRewardsView[] memory pending, uint256 total) =
            vaults.pendingDelegatorRewardsAll(address(0), delegator1);
        assertEq(pending.length, 2);
        assertEq(total, 15.3 ether);

        RewardVaults.DelegatorPosition[] memory positions =
            vaults.getDelegatorPositions(address(0), delegator1);
        assertEq(positions.length, 2);
        assertEq(positions[0].pendingRewards, 8.5 ether);
        assertEq(positions[1].pendingRewards, 6.8 ether);
    }

    function test_Vaults_ClaimDelegatorRewardsBatch() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.recordStake(address(0), delegator1, operator2, 100 ether, RewardVaults.LockDuration.None);

        vaults.distributeRewards(address(0), operator1, 10 ether);
        vaults.distributeRewards(address(0), operator2, 5 ether);

        address[] memory operatorsList = new address[](2);
        operatorsList[0] = operator1;
        operatorsList[1] = operator2;

        uint256 balanceBefore = tnt.balanceOf(delegator1);
        vm.prank(delegator1);
        uint256 claimed = vaults.claimDelegatorRewardsBatch(address(0), operatorsList);
        uint256 balanceAfter = tnt.balanceOf(delegator1);

        assertEq(claimed, 8.5 ether + 4.25 ether);
        assertEq(balanceAfter - balanceBefore, claimed);

        (, uint256 totalPending) = vaults.pendingDelegatorRewardsAll(address(0), delegator1);
        assertEq(totalPending, 0);
    }

    function test_Vaults_ClaimDelegatorRewardsBatch_RevertWhenNothingOwed() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        address[] memory operatorsList = new address[](1);
        operatorsList[0] = operator1;

        vm.prank(delegator1);
        vm.expectRevert(RewardVaults.NoRewardsToClaim.selector);
        vaults.claimDelegatorRewardsBatch(address(0), operatorsList);
    }

    function test_Vaults_ClaimDelegatorRewardsFor() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.distributeRewards(address(0), operator1, 10 ether);

        uint256 balanceBefore = tnt.balanceOf(delegator1);
        vm.prank(admin);
        uint256 claimed = vaults.claimDelegatorRewardsFor(address(0), operator1, delegator1);
        uint256 balanceAfter = tnt.balanceOf(delegator1);

        assertEq(claimed, 8.5 ether);
        assertEq(balanceAfter - balanceBefore, claimed);
    }

    function test_Vaults_ClaimDelegatorRewardsFor_RevertWhenNothingOwed() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vm.prank(admin);
        vm.expectRevert(RewardVaults.NoRewardsToClaim.selector);
        vaults.claimDelegatorRewardsFor(address(0), operator1, delegator1);
    }

    function test_Vaults_DelegatorOperatorTracking() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.recordStake(address(0), delegator1, operator2, 50 ether, RewardVaults.LockDuration.None);

        address[] memory operatorsBefore = vaults.getDelegatorOperators(address(0), delegator1);
        assertEq(operatorsBefore.length, 2);

        vaults.recordUnstake(address(0), delegator1, operator1, 100 ether);

        address[] memory operatorsAfter = vaults.getDelegatorOperators(address(0), delegator1);
        assertEq(operatorsAfter.length, 1);
        assertEq(operatorsAfter[0], operator2);
    }

    function test_Vaults_DelegatorOperatorTracking_NoDuplicates() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        // stake additional amount to same operator - should not duplicate entry
        vaults.recordStake(address(0), delegator1, operator1, 50 ether, RewardVaults.LockDuration.None);

        address[] memory operators = vaults.getDelegatorOperators(address(0), delegator1);
        assertEq(operators.length, 1);
        assertEq(operators[0], operator1);
    }

    function test_Vaults_PendingRewardsAllAfterClaimIsZero() public {
        vm.prank(admin);
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vaults.distributeRewards(address(0), operator1, 10 ether);

        vm.prank(delegator1);
        vaults.claimDelegatorRewards(address(0), operator1);

        (, uint256 totalPending) = vaults.pendingDelegatorRewardsAll(address(0), delegator1);
        assertEq(totalPending, 0);
    }
}
