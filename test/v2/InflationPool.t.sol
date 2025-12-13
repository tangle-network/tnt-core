// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { InflationPool } from "../../src/v2/rewards/InflationPool.sol";
import { TangleMetrics } from "../../src/v2/rewards/TangleMetrics.sol";
import { RewardVaults } from "../../src/v2/rewards/RewardVaults.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";

/// @title InflationPoolTest
/// @notice Tests for pre-funded TNT inflation distribution
contract InflationPoolTest is Test {
    InflationPool public pool;
    TangleMetrics public metrics;
    RewardVaults public vaults;
    TangleToken public tnt;

    address public admin = address(0x1);
    address public operator1 = address(0x2);
    address public operator2 = address(0x3);
    address public customer1 = address(0x4);
    address public customer2 = address(0x5);
    address public delegator1 = address(0x6);
    address public treasury = address(0x7);
    address public developer1 = address(0x8);

    uint256 public constant INITIAL_SUPPLY = 50_000_000 * 1e18;
    uint256 public constant POOL_FUNDING = 500_000 * 1e18; // 1% of supply for year 1
    uint256 public constant EPOCH_LENGTH = 100; // 100 seconds for testing

    function setUp() public {
        vm.startPrank(admin);

        // Deploy TNT token
        TangleToken tntImpl = new TangleToken();
        bytes memory tntData = abi.encodeCall(TangleToken.initialize, (admin, INITIAL_SUPPLY));
        ERC1967Proxy tntProxy = new ERC1967Proxy(address(tntImpl), tntData);
        tnt = TangleToken(address(tntProxy));

        // Deploy Metrics
        TangleMetrics metricsImpl = new TangleMetrics();
        bytes memory metricsData = abi.encodeCall(TangleMetrics.initialize, (admin));
        ERC1967Proxy metricsProxy = new ERC1967Proxy(address(metricsImpl), metricsData);
        metrics = TangleMetrics(address(metricsProxy));

        // Deploy RewardVaults
        RewardVaults vaultsImpl = new RewardVaults();
        bytes memory vaultsData = abi.encodeCall(RewardVaults.initialize, (admin, address(tnt), 1500));
        ERC1967Proxy vaultsProxy = new ERC1967Proxy(address(vaultsImpl), vaultsData);
        vaults = RewardVaults(address(vaultsProxy));

        // Deploy InflationPool
        InflationPool poolImpl = new InflationPool();
        bytes memory poolData = abi.encodeCall(
            InflationPool.initialize,
            (admin, address(tnt), address(metrics), address(vaults), EPOCH_LENGTH)
        );
        ERC1967Proxy poolProxy = new ERC1967Proxy(address(poolImpl), poolData);
        pool = InflationPool(address(poolProxy));

        // Grant RECORDER_ROLE to test contract for metrics
        metrics.grantRecorderRole(address(this));

        // Grant REWARDS_MANAGER_ROLE to pool for vaults
        vaults.grantRole(vaults.REWARDS_MANAGER_ROLE(), address(pool));

        // Create a vault for testing
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        // Fund the inflation pool (simulating governance funding)
        tnt.transfer(admin, POOL_FUNDING); // Admin has initial supply
        tnt.approve(address(pool), POOL_FUNDING);
        pool.fund(POOL_FUNDING);

        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Initialization() public view {
        assertEq(pool.epochLength(), EPOCH_LENGTH);
        assertEq(pool.currentEpoch(), 1);
        assertEq(pool.poolBalance(), POOL_FUNDING);

        (uint16 staking, uint16 operators, uint16 customers, uint16 developers) = pool.getWeights();
        assertEq(staking, 5000);
        assertEq(operators, 2500);
        assertEq(customers, 1000);
        assertEq(developers, 1500);
    }

    function test_Initialize_RevertEpochTooShort() public {
        InflationPool poolImpl = new InflationPool();
        bytes memory poolData = abi.encodeCall(
            InflationPool.initialize,
            (admin, address(tnt), address(metrics), address(vaults), 59)
        );

        vm.expectRevert(InflationPool.InvalidEpochLength.selector);
        new ERC1967Proxy(address(poolImpl), poolData);
    }

    function test_Initialize_RevertEpochTooLong() public {
        InflationPool poolImpl = new InflationPool();
        bytes memory poolData = abi.encodeCall(
            InflationPool.initialize,
            (admin, address(tnt), address(metrics), address(vaults), 365 days + 1)
        );

        vm.expectRevert(InflationPool.InvalidEpochLength.selector);
        new ERC1967Proxy(address(poolImpl), poolData);
    }

    function test_PoolBalance() public view {
        assertEq(pool.poolBalance(), POOL_FUNDING);
        assertEq(tnt.balanceOf(address(pool)), POOL_FUNDING);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNDING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Fund() public {
        uint256 balanceBefore = pool.poolBalance();

        vm.startPrank(admin);
        tnt.approve(address(pool), 100_000 ether);
        pool.fund(100_000 ether);
        vm.stopPrank();

        assertEq(pool.poolBalance(), balanceBefore + 100_000 ether);
        assertEq(pool.totalFunded(), POOL_FUNDING + 100_000 ether);
    }

    function test_Fund_RevertZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert(InflationPool.ZeroAmount.selector);
        pool.fund(0);
    }

    function test_FundingHistory() public view {
        assertEq(pool.fundingHistoryCount(), 1);

        InflationPool.FundingRecord memory record = pool.getFundingRecord(0);
        assertEq(record.amount, POOL_FUNDING);
        assertEq(record.funder, admin);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WEIGHT CONFIGURATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetWeights() public {
        vm.prank(admin);
        pool.setWeights(4000, 3000, 2000, 1000);

        (uint16 staking, uint16 operators, uint16 customers, uint16 developers) = pool.getWeights();
        assertEq(staking, 4000);
        assertEq(operators, 3000);
        assertEq(customers, 2000);
        assertEq(developers, 1000);
    }

    function test_SetWeights_RevertInvalid() public {
        vm.prank(admin);
        vm.expectRevert(InflationPool.InvalidWeights.selector);
        pool.setWeights(5000, 3000, 1000, 500); // Doesn't sum to 10000
    }

    function test_SetEpochLength() public {
        vm.prank(admin);
        pool.setEpochLength(200);

        assertEq(pool.epochLength(), 200);
    }

    function test_SetEpochLength_RevertTooShort() public {
        vm.prank(admin);
        vm.expectRevert(InflationPool.InvalidEpochLength.selector);
        pool.setEpochLength(59);
    }

    function test_SetEpochLength_RevertTooLong() public {
        vm.prank(admin);
        vm.expectRevert(InflationPool.InvalidEpochLength.selector);
        pool.setEpochLength(365 days + 1);
    }

    function test_SetFundingPeriodSeconds_RevertZero() public {
        vm.prank(admin);
        vm.expectRevert(InflationPool.InvalidEpochLength.selector);
        pool.setFundingPeriodSeconds(0);
    }

    function test_SetFundingPeriodSeconds_RevertWhenNotAdmin() public {
        vm.prank(operator1);
        vm.expectRevert();
        pool.setFundingPeriodSeconds(30 days);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EPOCH DISTRIBUTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_EpochNotReady() public {
        vm.expectRevert(InflationPool.EpochNotReady.selector);
        pool.distributeEpoch();
    }

    function test_DistributeEpoch() public {
        // Register operators and customers
        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerOperator(operator2);
        pool.registerCustomer(customer1);

        // Record stake in vault so staking rewards can be distributed
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vm.stopPrank();

        // Add some metrics data
        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        metrics.recordOperatorRegistered(operator2, address(0), 200 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordJobCompletion(operator2, 1, 1, true);
        metrics.recordPayment(customer1, 1, address(0), 10 ether);

        // Advance to end of epoch
        vm.warp(block.timestamp + EPOCH_LENGTH + 1);

        // Distribute epoch
        uint256 poolBefore = pool.poolBalance();
        pool.distributeEpoch();
        uint256 poolAfter = pool.poolBalance();

        // Verify staking distribution occurred (pool balance decreased from staking transfer to vaults)
        assertLt(poolAfter, poolBefore);

        // Verify epoch advanced
        assertEq(pool.currentEpoch(), 2);

        // Verify epoch was marked distributed
        InflationPool.EpochData memory epoch = pool.getEpoch(1);
        assertTrue(epoch.distributed);
    }

    function test_DistributeEpoch_NoFunds() public {
        // Deploy a new pool without funding
        vm.startPrank(admin);
        InflationPool poolImpl = new InflationPool();
        bytes memory poolData = abi.encodeCall(
            InflationPool.initialize,
            (admin, address(tnt), address(metrics), address(vaults), EPOCH_LENGTH)
        );
        ERC1967Proxy poolProxy = new ERC1967Proxy(address(poolImpl), poolData);
        InflationPool emptyPool = InflationPool(address(poolProxy));
        vm.stopPrank();

        // Advance to end of epoch
        vm.warp(block.timestamp + EPOCH_LENGTH + 1);

        // Distribution should succeed but distribute nothing
        emptyPool.distributeEpoch();
        assertEq(emptyPool.currentEpoch(), 2);
        assertEq(emptyPool.totalDistributed(), 0);
    }

    function test_DistributeEpoch_DoesNotAllowCatchUpSpam() public {
        // Warp far into the future; a single call should advance only one epoch and
        // schedule the next epoch relative to `block.timestamp`.
        vm.warp(block.timestamp + (EPOCH_LENGTH * 100) + 1);
        pool.distributeEpoch();

        InflationPool.EpochData memory epoch2 = pool.getEpoch(2);
        assertEq(epoch2.startTimestamp, block.timestamp);
        assertEq(epoch2.endTimestamp, block.timestamp + pool.epochLength());

        vm.expectRevert(InflationPool.EpochNotReady.selector);
        pool.distributeEpoch();
    }

    function test_MultipleEpochs() public {
        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerCustomer(customer1);

        // Record stake in vault so staking rewards can be distributed
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vm.stopPrank();

        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        metrics.recordPayment(customer1, 1, address(0), 10 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        uint256 poolStart = pool.poolBalance();

        // Distribute 3 epochs
        for (uint256 i = 0; i < 3; i++) {
            InflationPool.EpochData memory epoch = pool.getEpoch(pool.currentEpoch());
            vm.warp(epoch.endTimestamp + 1);
            pool.distributeEpoch();
        }

        assertEq(pool.currentEpoch(), 4);
        assertGt(pool.totalDistributed(), 0);
        assertLt(pool.poolBalance(), poolStart);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REWARDS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_OperatorRewards() public {
        vm.prank(admin);
        pool.registerOperator(operator1);

        // Operator does some work
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordJobCompletion(operator1, 1, 1, true);
        metrics.recordHeartbeat(operator1, 1, uint64(block.timestamp));

        // Distribute epoch
        vm.warp(block.timestamp + EPOCH_LENGTH + 1);
        pool.distributeEpoch();

        // Operator should have pending rewards
        uint256 pending = pool.pendingOperatorRewards(operator1);
        assertGt(pending, 0);

        // Claim rewards
        vm.prank(operator1);
        uint256 claimed = pool.claimOperatorRewards();

        assertEq(claimed, pending);
        assertEq(tnt.balanceOf(operator1), claimed);
    }

    function test_OperatorRewards_ProportionalToWork() public {
        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerOperator(operator2);
        vm.stopPrank();

        // Operator1 does more work
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordOperatorRegistered(operator2, address(0), 1000 ether);

        // Op1: 10 jobs, Op2: 2 jobs
        for (uint256 i = 0; i < 10; i++) {
            metrics.recordJobCompletion(operator1, 1, uint64(i), true);
        }
        metrics.recordJobCompletion(operator2, 1, 0, true);
        metrics.recordJobCompletion(operator2, 1, 1, true);

        vm.warp(block.timestamp + EPOCH_LENGTH + 1);
        pool.distributeEpoch();

        uint256 pending1 = pool.pendingOperatorRewards(operator1);
        uint256 pending2 = pool.pendingOperatorRewards(operator2);

        // Operator1 should have more rewards (did 5x the work)
        assertGt(pending1, pending2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CUSTOMER REWARDS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CustomerRewards() public {
        vm.prank(admin);
        pool.registerCustomer(customer1);

        // Customer pays fees
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        vm.warp(block.timestamp + EPOCH_LENGTH + 1);
        pool.distributeEpoch();

        uint256 pending = pool.pendingCustomerRewards(customer1);
        assertGt(pending, 0);

        vm.prank(customer1);
        uint256 claimed = pool.claimCustomerRewards();

        assertEq(claimed, pending);
        assertEq(tnt.balanceOf(customer1), claimed);
    }

    function test_CustomerRewards_ProportionalToFees() public {
        vm.startPrank(admin);
        pool.registerCustomer(customer1);
        pool.registerCustomer(customer2);
        vm.stopPrank();

        // Customer1 pays 3x more fees
        metrics.recordPayment(customer1, 1, address(0), 300 ether);
        metrics.recordPayment(customer2, 1, address(0), 100 ether);

        vm.warp(block.timestamp + EPOCH_LENGTH + 1);
        pool.distributeEpoch();

        uint256 pending1 = pool.pendingCustomerRewards(customer1);
        uint256 pending2 = pool.pendingCustomerRewards(customer2);

        // Customer1 should have ~3x the rewards
        assertApproxEqRel(pending1, pending2 * 3, 0.01e18); // 1% tolerance
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BUDGET TRACKING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DistributedTracking() public {
        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerCustomer(customer1);

        // Record stake in vault so staking rewards can be distributed
        vaults.recordStake(address(0), delegator1, operator1, 100 ether, RewardVaults.LockDuration.None);
        vm.stopPrank();

        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordPayment(customer1, 1, address(0), 10 ether);

        // Distribute several epochs
        for (uint256 i = 0; i < 10; i++) {
            InflationPool.EpochData memory epoch = pool.getEpoch(pool.currentEpoch());
            vm.warp(epoch.endTimestamp + 1);
            pool.distributeEpoch();
        }

        uint256 distributed = pool.totalDistributed();
        assertGt(distributed, 0);

        // Verify pending rewards accumulated
        uint256 pendingOp = pool.pendingOperatorRewards(operator1);
        uint256 pendingCust = pool.pendingCustomerRewards(customer1);
        assertGt(pendingOp, 0, "Operator should have pending rewards");
        assertGt(pendingCust, 0, "Customer should have pending rewards");

        // Claim all pending rewards
        uint256 poolBeforeClaims = pool.poolBalance();

        vm.prank(operator1);
        uint256 claimedOp = pool.claimOperatorRewards();
        assertEq(claimedOp, pendingOp, "Operator should claim full pending amount");
        assertEq(tnt.balanceOf(operator1), claimedOp, "Operator should receive TNT");

        vm.prank(customer1);
        uint256 claimedCust = pool.claimCustomerRewards();
        assertEq(claimedCust, pendingCust, "Customer should claim full pending amount");
        assertEq(tnt.balanceOf(customer1), claimedCust, "Customer should receive TNT");

        // After claims, pool balance should decrease by claimed amounts
        uint256 poolAfterClaims = pool.poolBalance();
        assertEq(poolAfterClaims, poolBeforeClaims - claimedOp - claimedCust, "Pool balance should decrease by claimed amounts");

        // Verify no more pending rewards
        assertEq(pool.pendingOperatorRewards(operator1), 0, "No pending after claim");
        assertEq(pool.pendingCustomerRewards(customer1), 0, "No pending after claim");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EMERGENCY WITHDRAW TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_EmergencyWithdraw() public {
        uint256 poolBalance = pool.poolBalance();

        vm.prank(admin);
        pool.emergencyWithdraw(treasury);

        assertEq(pool.poolBalance(), 0);
        assertEq(tnt.balanceOf(treasury), poolBalance);
    }

    function test_EmergencyWithdraw_RevertZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(InflationPool.ZeroAddress.selector);
        pool.emergencyWithdraw(address(0));
    }

    function test_EmergencyWithdraw_OnlyAdmin() public {
        vm.prank(operator1);
        vm.expectRevert();
        pool.emergencyWithdraw(treasury);
    }

    function test_ResetFundingPeriodResetsBudgetAndTimestamp() public {
        _activateAllRewardStreams();
        InflationPool.EpochData memory epoch = _distributeCurrentEpoch();
        assertGt(pool.distributedThisPeriod(), 0);
        assertGt(epoch.stakingDistributed + epoch.operatorsDistributed + epoch.customersDistributed + epoch.developersDistributed, 0);

        uint256 balanceBefore = pool.poolBalance();
        uint256 nowTs = block.timestamp;

        vm.prank(admin);
        pool.resetFundingPeriod();

        assertEq(pool.distributedThisPeriod(), 0);
        assertEq(pool.periodBudget(), balanceBefore);
        assertEq(pool.fundingPeriodStartTimestamp(), nowTs);
    }

    function test_ResetFundingPeriod_RevertWhenNotAdmin() public {
        vm.prank(operator1);
        vm.expectRevert();
        pool.resetFundingPeriod();
    }

    function test_DistributeEpoch_AutoFundingPeriodReset() public {
        _activateAllRewardStreams();
        uint256 originalStart = pool.fundingPeriodStartTimestamp();

        uint256 targetTs = originalStart + pool.fundingPeriodSeconds() + pool.epochLength() + 1;
        vm.warp(targetTs);
        pool.distributeEpoch();

        assertEq(pool.fundingPeriodStartTimestamp(), targetTs);
        assertGt(pool.distributedThisPeriod(), 0);
    }

    function test_DistributeEpoch_RedistributesToActiveStaking() public {
        vm.prank(admin);
        vaults.recordStake(address(0), delegator1, operator1, 1_000 ether, RewardVaults.LockDuration.None);

        InflationPool.EpochData memory epoch = _distributeCurrentEpoch();

        uint256 totalDistributed = epoch.stakingDistributed +
            epoch.operatorsDistributed +
            epoch.customersDistributed +
            epoch.developersDistributed;

        assertGt(totalDistributed, 0);
        assertEq(epoch.stakingDistributed, totalDistributed);
        assertEq(epoch.operatorsDistributed, 0);
        assertEq(epoch.customersDistributed, 0);
        assertEq(epoch.developersDistributed, 0);
    }

    function test_MultiEpochWeightAccounting() public {
        _activateAllRewardStreams();

        vm.prank(admin);
        pool.setWeights(7000, 1000, 1000, 1000);
        InflationPool.EpochData memory epochOne = _distributeCurrentEpoch();

        vm.prank(admin);
        pool.setWeights(1000, 7000, 1000, 1000);
        InflationPool.EpochData memory epochTwo = _distributeCurrentEpoch();

        uint256 totalOne = epochOne.stakingDistributed + epochOne.operatorsDistributed + epochOne.customersDistributed + epochOne.developersDistributed;
        uint256 totalTwo = epochTwo.stakingDistributed + epochTwo.operatorsDistributed + epochTwo.customersDistributed + epochTwo.developersDistributed;

        assertGt(epochOne.operatorsDistributed, 0);
        assertGt(epochTwo.operatorsDistributed, 0);

        // Operators capture a much larger share in epoch two once weights change.
        assertGt(epochTwo.operatorsDistributed * totalOne, epochOne.operatorsDistributed * totalTwo);
        // Staking sees the inverse relationship across epochs.
        assertGt(epochOne.stakingDistributed * totalTwo, epochTwo.stakingDistributed * totalOne);
        assertGt(epochOne.customersDistributed, 0);
        assertGt(epochOne.developersDistributed, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_BlocksUntilNextEpoch() public view {
        uint256 secondsUntil = pool.blocksUntilNextEpoch();
        assertGt(secondsUntil, 0);
        assertLe(secondsUntil, EPOCH_LENGTH);

        assertEq(secondsUntil, pool.secondsUntilNextEpoch());
    }

    function test_SecondsUntilNextEpoch_ZeroWhenReady() public {
        InflationPool.EpochData memory epoch = pool.getEpoch(pool.currentEpoch());
        vm.warp(epoch.endTimestamp);
        assertEq(pool.secondsUntilNextEpoch(), 0);
        assertEq(pool.blocksUntilNextEpoch(), 0);
    }

    function test_IsEpochReady() public {
        assertFalse(pool.isEpochReady());

        vm.warp(block.timestamp + EPOCH_LENGTH + 1);
        assertTrue(pool.isEpochReady());
    }

    function test_TrackedCounts() public {
        assertEq(pool.trackedOperatorCount(), 0);
        assertEq(pool.trackedCustomerCount(), 0);

        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerOperator(operator2);
        pool.registerCustomer(customer1);
        vm.stopPrank();

        assertEq(pool.trackedOperatorCount(), 2);
        assertEq(pool.trackedCustomerCount(), 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTEGRATION TEST
    // ═══════════════════════════════════════════════════════════════════════════

    function test_FullInflationCycle() public {
        // Setup participants
        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerOperator(operator2);
        pool.registerCustomer(customer1);
        pool.registerCustomer(customer2);

        // Record stakes in vault so staking rewards can be distributed
        vaults.recordStake(address(0), delegator1, operator1, 500 ether, RewardVaults.LockDuration.None);
        vm.stopPrank();

        // Record activity
        metrics.recordOperatorRegistered(operator1, address(0), 500 ether);
        metrics.recordOperatorRegistered(operator2, address(0), 500 ether);

        for (uint256 i = 0; i < 5; i++) {
            metrics.recordJobCompletion(operator1, 1, uint64(i), true);
            metrics.recordJobCompletion(operator2, 1, uint64(i + 5), true);
        }

        metrics.recordPayment(customer1, 1, address(0), 50 ether);
        metrics.recordPayment(customer2, 1, address(0), 50 ether);

        // Run 5 epochs
        uint256 poolStart = pool.poolBalance();
        for (uint256 i = 0; i < 5; i++) {
            InflationPool.EpochData memory epoch = pool.getEpoch(pool.currentEpoch());
            vm.warp(epoch.endTimestamp + 1);
            pool.distributeEpoch();
        }

        // Verify distribution from pool
        assertLt(pool.poolBalance(), poolStart);
        assertGt(pool.totalDistributed(), 0);

        // All participants should have rewards
        assertGt(pool.pendingOperatorRewards(operator1), 0);
        assertGt(pool.pendingOperatorRewards(operator2), 0);
        assertGt(pool.pendingCustomerRewards(customer1), 0);
        assertGt(pool.pendingCustomerRewards(customer2), 0);

        // Claim all rewards
        vm.prank(operator1);
        pool.claimOperatorRewards();
        vm.prank(operator2);
        pool.claimOperatorRewards();
        vm.prank(customer1);
        pool.claimCustomerRewards();
        vm.prank(customer2);
        pool.claimCustomerRewards();

        // Verify all participants received TNT
        assertGt(tnt.balanceOf(operator1), 0);
        assertGt(tnt.balanceOf(operator2), 0);
        assertGt(tnt.balanceOf(customer1), 0);
        assertGt(tnt.balanceOf(customer2), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SECURITY TESTS - TOKEN ISOLATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CannotMintTokens() public view {
        // Verify pool does NOT have MINTER_ROLE
        assertFalse(tnt.hasRole(tnt.MINTER_ROLE(), address(pool)));
    }

    function test_CanOnlyDistributePoolBalance() public {
        vm.prank(admin);
        pool.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        // Distribute until pool is nearly empty
        uint256 epochsToDistribute = 100;
        for (uint256 i = 0; i < epochsToDistribute; i++) {
            InflationPool.EpochData memory epoch = pool.getEpoch(pool.currentEpoch());
            vm.warp(epoch.endTimestamp + 1);
            pool.distributeEpoch();

            if (pool.poolBalance() == 0) break;
        }

        // Total distributed should never exceed what was funded
        assertLe(pool.totalDistributed(), POOL_FUNDING);
    }

    function _distributeCurrentEpoch() internal returns (InflationPool.EpochData memory) {
        InflationPool.EpochData memory epoch = pool.getEpoch(pool.currentEpoch());
        vm.warp(epoch.endTimestamp + 1);
        pool.distributeEpoch();
        return pool.getEpoch(pool.currentEpoch() - 1);
    }

    function _activateAllRewardStreams() internal {
        vm.startPrank(admin);
        pool.registerOperator(operator1);
        pool.registerCustomer(customer1);
        pool.registerDeveloper(developer1);
        vaults.recordStake(address(0), delegator1, operator1, 500 ether, RewardVaults.LockDuration.None);
        vm.stopPrank();

        metrics.recordOperatorRegistered(operator1, address(0), 500 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordHeartbeat(operator1, 1, uint64(block.timestamp));

        metrics.recordBlueprintCreated(1, developer1);
        metrics.recordServiceCreated(1, 1, developer1, 1);
        metrics.recordJobCall(1, customer1, 1);

        metrics.recordPayment(customer1, 1, address(0), 200 ether);
    }
}
