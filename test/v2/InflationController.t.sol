// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { InflationController } from "../../src/v2/rewards/InflationController.sol";
import { TangleMetrics } from "../../src/v2/rewards/TangleMetrics.sol";
import { RewardVaults } from "../../src/v2/rewards/RewardVaults.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";

/// @title InflationControllerTest
/// @notice Tests for TNT inflation targeting and distribution
contract InflationControllerTest is Test {
    InflationController public controller;
    TangleMetrics public metrics;
    RewardVaults public vaults;
    TangleToken public tnt;

    address public admin = address(0x1);
    address public operator1 = address(0x2);
    address public operator2 = address(0x3);
    address public customer1 = address(0x4);
    address public customer2 = address(0x5);
    address public delegator1 = address(0x6);

    uint256 public constant INITIAL_SUPPLY = 50_000_000 * 1e18;
    uint16 public constant INFLATION_BPS = 100; // 1%
    uint256 public constant EPOCH_LENGTH = 100; // 100 blocks for testing

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

        // Deploy InflationController
        InflationController controllerImpl = new InflationController();
        bytes memory controllerData = abi.encodeCall(
            InflationController.initialize,
            (admin, address(tnt), address(metrics), address(vaults), INFLATION_BPS, EPOCH_LENGTH)
        );
        ERC1967Proxy controllerProxy = new ERC1967Proxy(address(controllerImpl), controllerData);
        controller = InflationController(address(controllerProxy));

        // Grant MINTER_ROLE to controller
        tnt.grantRole(tnt.MINTER_ROLE(), address(controller));

        // Grant RECORDER_ROLE to test contract for metrics
        metrics.grantRecorderRole(address(this));

        // Grant REWARDS_MANAGER_ROLE to controller for vaults
        vaults.grantRole(vaults.REWARDS_MANAGER_ROLE(), address(controller));

        // Create a vault for testing
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Initialization() public view {
        assertEq(controller.inflationBps(), INFLATION_BPS);
        assertEq(controller.epochLength(), EPOCH_LENGTH);
        assertEq(controller.currentEpoch(), 1);

        (uint16 staking, uint16 operators, uint16 customers) = controller.getWeights();
        assertEq(staking, 6000);
        assertEq(operators, 2500);
        assertEq(customers, 1500);
    }

    function test_YearlyBudget() public view {
        uint256 expectedBudget = (INITIAL_SUPPLY * INFLATION_BPS) / 10000;
        assertEq(controller.calculateYearlyBudget(), expectedBudget);
        // 1% of 50M = 500k TNT
        assertEq(expectedBudget, 500_000 * 1e18);
    }

    function test_EpochBudget() public view {
        uint256 yearlyBudget = controller.calculateYearlyBudget();
        uint256 epochsPerYear = controller.BLOCKS_PER_YEAR() / EPOCH_LENGTH;
        uint256 expectedEpochBudget = yearlyBudget / epochsPerYear;

        assertEq(controller.calculateEpochBudget(), expectedEpochBudget);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WEIGHT CONFIGURATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetWeights() public {
        vm.prank(admin);
        controller.setWeights(5000, 3000, 2000);

        (uint16 staking, uint16 operators, uint16 customers) = controller.getWeights();
        assertEq(staking, 5000);
        assertEq(operators, 3000);
        assertEq(customers, 2000);
    }

    function test_SetWeights_RevertInvalid() public {
        vm.prank(admin);
        vm.expectRevert(InflationController.InvalidWeights.selector);
        controller.setWeights(5000, 3000, 1000); // Doesn't sum to 10000
    }

    function test_SetInflationRate() public {
        vm.prank(admin);
        controller.setInflationRate(200); // 2%

        assertEq(controller.inflationBps(), 200);
        // New yearly budget should be 2% of supply
        assertEq(controller.calculateYearlyBudget(), 1_000_000 * 1e18);
    }

    function test_SetInflationRate_RevertTooHigh() public {
        vm.prank(admin);
        vm.expectRevert(InflationController.InvalidInflationRate.selector);
        controller.setInflationRate(1500); // 15% - too high
    }

    function test_SetEpochLength() public {
        vm.prank(admin);
        controller.setEpochLength(200);

        assertEq(controller.epochLength(), 200);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EPOCH DISTRIBUTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_EpochNotReady() public {
        vm.expectRevert(InflationController.EpochNotReady.selector);
        controller.distributeEpoch();
    }

    function test_DistributeEpoch() public {
        // Register operators and customers
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerOperator(operator2);
        controller.registerCustomer(customer1);
        vm.stopPrank();

        // Add some metrics data
        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        metrics.recordOperatorRegistered(operator2, address(0), 200 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordJobCompletion(operator2, 1, 1, true);
        metrics.recordPayment(customer1, 1, address(0), 10 ether);

        // Advance to end of epoch
        vm.roll(block.number + EPOCH_LENGTH + 1);

        // Distribute epoch
        uint256 supplyBefore = tnt.totalSupply();
        controller.distributeEpoch();
        uint256 supplyAfter = tnt.totalSupply();

        // Verify minting occurred
        assertGt(supplyAfter, supplyBefore);

        // Verify epoch advanced
        assertEq(controller.currentEpoch(), 2);

        // Verify epoch was marked distributed
        InflationController.EpochData memory epoch = controller.getEpoch(1);
        assertTrue(epoch.distributed);
    }

    function test_DistributeEpoch_SecondEpochNeedsAdvance() public {
        // Advance to end of first epoch and distribute
        InflationController.EpochData memory epoch1 = controller.getEpoch(1);
        vm.roll(epoch1.endBlock + 1);
        controller.distributeEpoch();
        assertEq(controller.currentEpoch(), 2);

        // Second epoch just started, not ready yet
        vm.expectRevert(InflationController.EpochNotReady.selector);
        controller.distributeEpoch();

        // Need to advance to end of second epoch
        InflationController.EpochData memory epoch2 = controller.getEpoch(2);
        vm.roll(epoch2.endBlock + 1);
        controller.distributeEpoch(); // Should succeed
        assertEq(controller.currentEpoch(), 3);
    }

    function test_MultipleEpochs() public {
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerCustomer(customer1);
        vm.stopPrank();

        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        metrics.recordPayment(customer1, 1, address(0), 10 ether);

        // Distribute 3 epochs - need to advance enough blocks for each
        uint256 startBlock = block.number;
        for (uint256 i = 0; i < 3; i++) {
            // Advance to end of current epoch
            InflationController.EpochData memory epoch = controller.getEpoch(controller.currentEpoch());
            vm.roll(epoch.endBlock + 1);
            controller.distributeEpoch();
        }

        assertEq(controller.currentEpoch(), 4);
        assertGt(controller.mintedThisYear(), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REWARDS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_OperatorRewards() public {
        vm.prank(admin);
        controller.registerOperator(operator1);

        // Operator does some work
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordJobCompletion(operator1, 1, 1, true);
        metrics.recordHeartbeat(operator1, 1, uint64(block.timestamp));

        // Distribute epoch
        vm.roll(block.number + EPOCH_LENGTH + 1);
        controller.distributeEpoch();

        // Operator should have pending rewards
        uint256 pending = controller.pendingOperatorRewards(operator1);
        assertGt(pending, 0);

        // Claim rewards
        vm.prank(operator1);
        uint256 claimed = controller.claimOperatorRewards();

        assertEq(claimed, pending);
        assertEq(tnt.balanceOf(operator1), claimed);
    }

    function test_OperatorRewards_ProportionalToWork() public {
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerOperator(operator2);
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

        vm.roll(block.number + EPOCH_LENGTH + 1);
        controller.distributeEpoch();

        uint256 pending1 = controller.pendingOperatorRewards(operator1);
        uint256 pending2 = controller.pendingOperatorRewards(operator2);

        // Operator1 should have more rewards (did 5x the work)
        assertGt(pending1, pending2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CUSTOMER REWARDS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CustomerRewards() public {
        vm.prank(admin);
        controller.registerCustomer(customer1);

        // Customer pays fees
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        vm.roll(block.number + EPOCH_LENGTH + 1);
        controller.distributeEpoch();

        uint256 pending = controller.pendingCustomerRewards(customer1);
        assertGt(pending, 0);

        vm.prank(customer1);
        uint256 claimed = controller.claimCustomerRewards();

        assertEq(claimed, pending);
        assertEq(tnt.balanceOf(customer1), claimed);
    }

    function test_CustomerRewards_ProportionalToFees() public {
        vm.startPrank(admin);
        controller.registerCustomer(customer1);
        controller.registerCustomer(customer2);
        vm.stopPrank();

        // Customer1 pays 3x more fees
        metrics.recordPayment(customer1, 1, address(0), 300 ether);
        metrics.recordPayment(customer2, 1, address(0), 100 ether);

        vm.roll(block.number + EPOCH_LENGTH + 1);
        controller.distributeEpoch();

        uint256 pending1 = controller.pendingCustomerRewards(customer1);
        uint256 pending2 = controller.pendingCustomerRewards(customer2);

        // Customer1 should have ~3x the rewards
        assertApproxEqRel(pending1, pending2 * 3, 0.01e18); // 1% tolerance
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // YEARLY BUDGET TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_YearlyBudgetTracking() public {
        vm.prank(admin);
        controller.registerOperator(operator1);

        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        // Must record job completion for operator to have non-zero score
        metrics.recordJobCompletion(operator1, 1, 0, true);

        uint256 yearlyBudget = controller.getYearlyBudgetFixed();
        uint256 epochBudget = controller.calculateEpochBudget();

        // Distribute several epochs
        for (uint256 i = 0; i < 10; i++) {
            InflationController.EpochData memory epoch = controller.getEpoch(controller.currentEpoch());
            vm.roll(epoch.endBlock + 1);
            controller.distributeEpoch();
        }

        uint256 minted = controller.mintedThisYear();
        assertApproxEqAbs(minted, epochBudget * 10, 1e18); // Allow small rounding error

        // Remaining budget should decrease
        uint256 remaining = controller.remainingYearlyBudget();
        assertEq(remaining, yearlyBudget - minted);
    }

    function test_YearReset() public {
        vm.prank(admin);
        controller.registerOperator(operator1);

        metrics.recordOperatorRegistered(operator1, address(0), 100 ether);
        // Must record job completion for operator to have non-zero score
        metrics.recordJobCompletion(operator1, 1, 0, true);

        // Distribute one epoch
        InflationController.EpochData memory epoch = controller.getEpoch(controller.currentEpoch());
        vm.roll(epoch.endBlock + 1);
        controller.distributeEpoch();

        uint256 mintedBefore = controller.mintedThisYear();
        assertGt(mintedBefore, 0, "Should have minted in first epoch");

        uint256 yearStartBefore = controller.yearStartBlock();

        // Advance past one full year
        uint256 yearEnd = controller.yearStartBlock() + controller.BLOCKS_PER_YEAR();
        vm.roll(yearEnd + EPOCH_LENGTH + 1);
        controller.distributeEpoch();

        // Year should have reset
        uint256 yearStartAfter = controller.yearStartBlock();
        assertGt(yearStartAfter, yearStartBefore, "Year start should have advanced");

        // After year reset, mintedThisYear should be just the current epoch's minting
        uint256 mintedAfter = controller.mintedThisYear();
        assertLe(mintedAfter, controller.calculateEpochBudget() + 1e18);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_BlocksUntilNextEpoch() public view {
        uint256 blocks = controller.blocksUntilNextEpoch();
        assertGt(blocks, 0);
        assertLe(blocks, EPOCH_LENGTH);
    }

    function test_IsEpochReady() public {
        assertFalse(controller.isEpochReady());

        vm.roll(block.number + EPOCH_LENGTH + 1);
        assertTrue(controller.isEpochReady());
    }

    function test_TrackedCounts() public {
        assertEq(controller.trackedOperatorCount(), 0);
        assertEq(controller.trackedCustomerCount(), 0);

        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerOperator(operator2);
        controller.registerCustomer(customer1);
        vm.stopPrank();

        assertEq(controller.trackedOperatorCount(), 2);
        assertEq(controller.trackedCustomerCount(), 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTEGRATION TEST
    // ═══════════════════════════════════════════════════════════════════════════

    function test_FullInflationCycle() public {
        // Setup participants
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerOperator(operator2);
        controller.registerCustomer(customer1);
        controller.registerCustomer(customer2);
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
        uint256 totalMinted = 0;
        for (uint256 i = 0; i < 5; i++) {
            InflationController.EpochData memory epoch = controller.getEpoch(controller.currentEpoch());
            vm.roll(epoch.endBlock + 1);
            uint256 supplyBefore = tnt.totalSupply();
            controller.distributeEpoch();
            totalMinted += tnt.totalSupply() - supplyBefore;
        }

        // Verify inflation stayed within budget
        uint256 yearlyBudget = controller.calculateYearlyBudget();
        assertLe(totalMinted, yearlyBudget);

        // All participants should have rewards
        assertGt(controller.pendingOperatorRewards(operator1), 0);
        assertGt(controller.pendingOperatorRewards(operator2), 0);
        assertGt(controller.pendingCustomerRewards(customer1), 0);
        assertGt(controller.pendingCustomerRewards(customer2), 0);

        // Claim all rewards
        vm.prank(operator1);
        controller.claimOperatorRewards();
        vm.prank(operator2);
        controller.claimOperatorRewards();
        vm.prank(customer1);
        controller.claimCustomerRewards();
        vm.prank(customer2);
        controller.claimCustomerRewards();

        // Verify all participants received TNT
        assertGt(tnt.balanceOf(operator1), 0);
        assertGt(tnt.balanceOf(operator2), 0);
        assertGt(tnt.balanceOf(customer1), 0);
        assertGt(tnt.balanceOf(customer2), 0);
    }
}
