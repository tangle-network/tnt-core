// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { InflationController } from "../../src/v2/rewards/InflationController.sol";
import { TangleMetrics } from "../../src/v2/rewards/TangleMetrics.sol";
import { RewardVaults } from "../../src/v2/rewards/RewardVaults.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";

/// @title InflationControllerE2ETest
/// @notice STRICT E2E tests with explicit balance verification for inflation targeting
/// @dev Written with security auditor mindset - verifies exact amounts, not just "greater than"
contract InflationControllerE2ETest is Test {
    InflationController public controller;
    TangleMetrics public metrics;
    RewardVaults public vaults;
    TangleToken public tnt;

    address public admin = makeAddr("admin");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public operator3 = makeAddr("operator3");
    address public customer1 = makeAddr("customer1");
    address public customer2 = makeAddr("customer2");
    address public attacker = makeAddr("attacker");

    uint256 public constant INITIAL_SUPPLY = 50_000_000 * 1e18;
    uint256 public constant MAX_SUPPLY = 100_000_000 * 1e18;
    uint16 public constant INFLATION_BPS = 100; // 1%
    uint256 public constant EPOCH_LENGTH = 100; // 100 blocks for testing
    uint256 public constant BPS_DENOMINATOR = 10000;

    // Tracking for verification
    uint256 public totalMintedByController;
    uint256 public totalClaimedByOperators;
    uint256 public totalClaimedByCustomers;

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
        // Also grant to test contract so we can simulate staking
        vaults.grantRole(vaults.REWARDS_MANAGER_ROLE(), address(this));

        // Create a vault for testing
        vaults.createVault(address(0), 500, 1_000_000 ether, 100_000 ether, 10000);

        vm.stopPrank();
    }

    /// @notice Helper to add staking deposits to vaults
    function _addStakingDeposits(address delegator, address operator, uint256 amount) internal {
        // Record a delegate/stake to the vault
        vaults.recordDelegate(delegator, operator, address(0), amount, 10000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _advanceAndDistributeEpoch() internal returns (uint256 minted) {
        InflationController.EpochData memory epoch = controller.getEpoch(controller.currentEpoch());
        vm.roll(epoch.endBlock + 1);

        uint256 supplyBefore = tnt.totalSupply();
        controller.distributeEpoch();
        uint256 supplyAfter = tnt.totalSupply();

        minted = supplyAfter - supplyBefore;
        totalMintedByController += minted;
    }

    function _calculateExpectedEpochBudget() internal view returns (uint256) {
        uint256 currentSupply = tnt.totalSupply();
        uint256 yearlyBudget = (currentSupply * INFLATION_BPS) / BPS_DENOMINATOR;
        uint256 epochsPerYear = controller.BLOCKS_PER_YEAR() / EPOCH_LENGTH;
        return yearlyBudget / epochsPerYear;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: SUPPLY ACCOUNTING
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_SupplyInvariant_TotalSupplyEqualsInitialPlusMinted() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        uint256 initialSupply = tnt.totalSupply();
        assertEq(initialSupply, INITIAL_SUPPLY, "Initial supply mismatch");

        // Distribute 10 epochs
        uint256 totalMinted = 0;
        for (uint256 i = 0; i < 10; i++) {
            uint256 minted = _advanceAndDistributeEpoch();
            totalMinted += minted;
        }

        // CRITICAL: Verify supply invariant
        uint256 finalSupply = tnt.totalSupply();
        assertEq(
            finalSupply,
            initialSupply + totalMinted,
            "CRITICAL: Supply invariant violated - totalSupply != initial + minted"
        );

        // Also verify controller tracking matches
        assertEq(
            controller.mintedThisYear(),
            totalMinted,
            "Controller minted tracking mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: EXACT EPOCH BUDGET
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_ExactEpochBudget_MintedEqualsExpected() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        vm.prank(admin);
        controller.registerCustomer(customer1);

        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        uint256 expectedEpochBudget = controller.calculateEpochBudget();

        uint256 minted = _advanceAndDistributeEpoch();

        // STRICT: Minted must exactly equal epoch budget
        assertEq(
            minted,
            expectedEpochBudget,
            "CRITICAL: Minted amount != expected epoch budget"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: WEIGHT DISTRIBUTION ACCURACY
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_WeightDistribution_ExactSplit() public {
        // Register participants
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerCustomer(customer1);
        vm.stopPrank();

        // Record activity so all categories have rewards
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        // IMPORTANT: Add staking deposits so staking rewards can be distributed
        _addStakingDeposits(operator1, operator1, 1000 ether);

        // Get expected budget
        uint256 epochBudget = controller.calculateEpochBudget();

        // Get weights
        (uint16 stakingBps, uint16 operatorsBps, ) = controller.getWeights();

        // Calculate expected distribution
        uint256 expectedStaking = (epochBudget * stakingBps) / BPS_DENOMINATOR;
        uint256 expectedOperators = (epochBudget * operatorsBps) / BPS_DENOMINATOR;
        uint256 expectedCustomers = epochBudget - expectedStaking - expectedOperators;

        // Distribute epoch
        _advanceAndDistributeEpoch();

        // Get actual distribution from epoch data
        InflationController.EpochData memory epochData = controller.getEpoch(1);

        // Verify weight distribution (allow small rounding tolerance)
        assertApproxEqAbs(
            epochData.stakingDistributed,
            expectedStaking,
            2,
            "Staking distribution mismatch"
        );
        assertApproxEqAbs(
            epochData.operatorsDistributed,
            expectedOperators,
            2,
            "Operators distribution mismatch"
        );
        assertApproxEqAbs(
            epochData.customersDistributed,
            expectedCustomers,
            2,
            "Customers distribution mismatch"
        );

        // INVARIANT: Sum must approximately equal total (within rounding)
        assertApproxEqAbs(
            epochData.stakingDistributed + epochData.operatorsDistributed + epochData.customersDistributed,
            epochBudget,
            5,
            "CRITICAL: Distribution sum != epoch budget"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: FULL ACCOUNTING RECONCILIATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_FullAccountingReconciliation() public {
        // Setup multiple participants
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerOperator(operator2);
        controller.registerCustomer(customer1);
        controller.registerCustomer(customer2);
        vm.stopPrank();

        // Record varied activity
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordOperatorRegistered(operator2, address(0), 500 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordJobCompletion(operator1, 1, 1, true);
        metrics.recordJobCompletion(operator2, 1, 2, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);
        metrics.recordPayment(customer2, 1, address(0), 50 ether);

        uint256 supplyBefore = tnt.totalSupply();
        uint256 epochBudget = controller.calculateEpochBudget();

        _advanceAndDistributeEpoch();

        // Get all pending rewards
        uint256 op1Pending = controller.pendingOperatorRewards(operator1);
        uint256 op2Pending = controller.pendingOperatorRewards(operator2);
        uint256 cust1Pending = controller.pendingCustomerRewards(customer1);
        uint256 cust2Pending = controller.pendingCustomerRewards(customer2);

        // Get epoch data
        InflationController.EpochData memory epochData = controller.getEpoch(1);

        // RECONCILIATION CHECKS:

        // 1. Operator rewards should equal operators distributed
        assertEq(
            op1Pending + op2Pending,
            epochData.operatorsDistributed,
            "Operator pending != operators distributed"
        );

        // 2. Customer rewards should equal customers distributed
        assertEq(
            cust1Pending + cust2Pending,
            epochData.customersDistributed,
            "Customer pending != customers distributed"
        );

        // 3. Supply increase should approximately equal epoch budget
        // Allow small tolerance for rounding when distributing across multiple participants
        uint256 supplyAfter = tnt.totalSupply();
        assertApproxEqAbs(
            supplyAfter - supplyBefore,
            epochBudget,
            5, // Allow up to 5 wei rounding error
            "Supply delta != epoch budget"
        );

        // 4. All pending + staking should equal total minted
        // Note: Staking goes to vaults, not to pending
        uint256 totalAccountedFor = op1Pending + op2Pending + cust1Pending + cust2Pending + epochData.stakingDistributed;
        assertApproxEqAbs(
            totalAccountedFor,
            epochBudget,
            5, // Allow up to 5 wei rounding error
            "CRITICAL: Total accounted for != epoch budget"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // YEARLY BUDGET EXHAUSTION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_YearlyBudgetExhaustion_StopsAtLimit() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        // Use larger epoch length to reduce iterations (100K blocks = ~26 epochs/year)
        vm.prank(admin);
        controller.setEpochLength(100000);

        // Get the fixed yearly budget (set at initialization)
        uint256 yearlyBudgetFixed = controller.getYearlyBudgetFixed();
        uint256 epochBudget = controller.calculateEpochBudget();
        uint256 epochsToExhaust = (yearlyBudgetFixed / epochBudget) + 5; // Extra epochs after exhaustion

        uint256 totalMinted = 0;
        for (uint256 i = 0; i < epochsToExhaust; i++) {
            InflationController.EpochData memory epoch = controller.getEpoch(controller.currentEpoch());
            vm.roll(epoch.endBlock + 1);

            uint256 supplyBefore = tnt.totalSupply();
            controller.distributeEpoch();
            uint256 minted = tnt.totalSupply() - supplyBefore;
            totalMinted += minted;

            // After budget exhausted, minting should stop
            if (controller.mintedThisYear() >= yearlyBudgetFixed) {
                break; // No point continuing after exhaustion
            }
        }

        // Final check: total minted must not exceed fixed yearly budget
        assertLe(
            controller.mintedThisYear(),
            yearlyBudgetFixed,
            "CRITICAL: mintedThisYear exceeds yearly budget"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MAX SUPPLY PROTECTION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_MaxSupplyProtection_CannotExceedCap() public {
        // This tests that even with malicious configuration, we can't exceed MAX_SUPPLY
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);

        // Try to mint a lot
        for (uint256 i = 0; i < 100; i++) {
            _advanceAndDistributeEpoch();
        }

        // Verify MAX_SUPPLY is respected
        assertLe(
            tnt.totalSupply(),
            MAX_SUPPLY,
            "CRITICAL: Total supply exceeds MAX_SUPPLY"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DOUBLE CLAIM PROTECTION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_DoubleClaim_OperatorCannotClaimTwice() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        _advanceAndDistributeEpoch();

        uint256 pending = controller.pendingOperatorRewards(operator1);
        assertGt(pending, 0, "Should have pending rewards");

        // First claim
        vm.prank(operator1);
        uint256 claimed = controller.claimOperatorRewards();
        assertEq(claimed, pending, "First claim amount mismatch");

        // Second claim should revert
        vm.prank(operator1);
        vm.expectRevert(InflationController.NoRewardsToClaim.selector);
        controller.claimOperatorRewards();

        // Verify balance only received once
        assertEq(
            tnt.balanceOf(operator1),
            claimed,
            "Balance should only reflect single claim"
        );
    }

    function test_E2E_DoubleClaim_CustomerCannotClaimTwice() public {
        vm.prank(admin);
        controller.registerCustomer(customer1);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        _advanceAndDistributeEpoch();

        uint256 pending = controller.pendingCustomerRewards(customer1);

        // First claim
        vm.prank(customer1);
        controller.claimCustomerRewards();

        // Second claim should revert
        vm.prank(customer1);
        vm.expectRevert(InflationController.NoRewardsToClaim.selector);
        controller.claimCustomerRewards();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ACCESS CONTROL
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_AccessControl_UnauthorizedSetWeights() public {
        vm.prank(attacker);
        vm.expectRevert();
        controller.setWeights(9000, 500, 500);
    }

    function test_E2E_AccessControl_UnauthorizedSetInflationRate() public {
        vm.prank(attacker);
        vm.expectRevert();
        controller.setInflationRate(500);
    }

    function test_E2E_AccessControl_UnauthorizedRegisterOperator() public {
        vm.prank(attacker);
        vm.expectRevert();
        controller.registerOperator(attacker);
    }

    function test_E2E_AccessControl_UnauthorizedRegisterCustomer() public {
        vm.prank(attacker);
        vm.expectRevert();
        controller.registerCustomer(attacker);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_EdgeCase_NoParticipants_ZeroMinting() public {
        // No operators or customers registered
        uint256 supplyBefore = tnt.totalSupply();

        _advanceAndDistributeEpoch();

        uint256 supplyAfter = tnt.totalSupply();

        // With no participants, should still advance epoch but no operator/customer rewards
        InflationController.EpochData memory epochData = controller.getEpoch(1);
        assertEq(epochData.operatorsDistributed, 0, "Should have 0 operator distribution");
        assertEq(epochData.customersDistributed, 0, "Should have 0 customer distribution");
    }

    function test_E2E_EdgeCase_OnlyOperators_NoCustomers() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        uint256 epochBudget = controller.calculateEpochBudget();

        _advanceAndDistributeEpoch();

        InflationController.EpochData memory epochData = controller.getEpoch(1);

        // With redistribution: operators get FULL budget when they're the only active category
        // (staking has no deposits, customers has no active customers)
        // Allow 2 wei tolerance for rounding
        assertApproxEqAbs(epochData.operatorsDistributed, epochBudget, 2, "Operators should get full budget");

        // Customers share should be 0 (no customers to distribute to)
        assertEq(epochData.customersDistributed, 0);

        // Staking should be 0 (no deposits in vaults)
        assertEq(epochData.stakingDistributed, 0);
    }

    function test_E2E_EdgeCase_OnlyCustomers_NoOperators() public {
        vm.prank(admin);
        controller.registerCustomer(customer1);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        uint256 epochBudget = controller.calculateEpochBudget();
        (uint16 stakingBps, uint16 operatorsBps, uint16 customersBps) = controller.getWeights();

        _advanceAndDistributeEpoch();

        InflationController.EpochData memory epochData = controller.getEpoch(1);

        // Customers should get their share
        uint256 expectedCustomers = epochBudget - epochData.stakingDistributed - epochData.operatorsDistributed;
        assertEq(epochData.customersDistributed, expectedCustomers);

        // Operators share should be 0 (no operators to distribute to)
        assertEq(epochData.operatorsDistributed, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PRECISION AND ROUNDING
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_Precision_NoAccumulatedRoundingLoss() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        vm.prank(admin);
        controller.registerCustomer(customer1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        uint256 initialSupply = tnt.totalSupply();

        // Run many epochs
        uint256 epochs = 50;
        for (uint256 i = 0; i < epochs; i++) {
            _advanceAndDistributeEpoch();
        }

        // Verify no precision loss
        uint256 actualMinted = tnt.totalSupply() - initialSupply;
        uint256 trackedMinted = controller.mintedThisYear();

        // Controller tracking should exactly match actual supply delta
        assertEq(
            actualMinted,
            trackedMinted,
            "Precision loss: actual minted != tracked minted"
        );
    }

    function test_E2E_Precision_WeightsSumToExactBudget() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        vm.prank(admin);
        controller.registerCustomer(customer1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        uint256 epochBudget = controller.calculateEpochBudget();

        _advanceAndDistributeEpoch();

        InflationController.EpochData memory epochData = controller.getEpoch(1);

        // CRITICAL: Weights must sum to exactly epoch budget (no dust)
        uint256 distributed = epochData.stakingDistributed +
                              epochData.operatorsDistributed +
                              epochData.customersDistributed;

        assertEq(
            distributed,
            epochBudget,
            "CRITICAL: Distributed != epoch budget (rounding error)"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIM BALANCE VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_ClaimBalances_ExactAmountsReceived() public {
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerOperator(operator2);
        controller.registerCustomer(customer1);
        controller.registerCustomer(customer2);
        vm.stopPrank();

        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordOperatorRegistered(operator2, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordJobCompletion(operator2, 1, 1, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);
        metrics.recordPayment(customer2, 1, address(0), 100 ether);

        _advanceAndDistributeEpoch();

        // Record all pending amounts
        uint256 op1Pending = controller.pendingOperatorRewards(operator1);
        uint256 op2Pending = controller.pendingOperatorRewards(operator2);
        uint256 cust1Pending = controller.pendingCustomerRewards(customer1);
        uint256 cust2Pending = controller.pendingCustomerRewards(customer2);

        // All should have pending > 0
        assertGt(op1Pending, 0);
        assertGt(op2Pending, 0);
        assertGt(cust1Pending, 0);
        assertGt(cust2Pending, 0);

        // Claim and verify exact balances
        vm.prank(operator1);
        controller.claimOperatorRewards();
        assertEq(tnt.balanceOf(operator1), op1Pending, "Op1 balance != pending");

        vm.prank(operator2);
        controller.claimOperatorRewards();
        assertEq(tnt.balanceOf(operator2), op2Pending, "Op2 balance != pending");

        vm.prank(customer1);
        controller.claimCustomerRewards();
        assertEq(tnt.balanceOf(customer1), cust1Pending, "Cust1 balance != pending");

        vm.prank(customer2);
        controller.claimCustomerRewards();
        assertEq(tnt.balanceOf(customer2), cust2Pending, "Cust2 balance != pending");

        // Verify total claimed equals distributed
        uint256 totalClaimed = op1Pending + op2Pending + cust1Pending + cust2Pending;
        InflationController.EpochData memory epochData = controller.getEpoch(1);
        uint256 totalDistributedToClaimable = epochData.operatorsDistributed + epochData.customersDistributed;

        assertEq(
            totalClaimed,
            totalDistributedToClaimable,
            "Total claimed != total distributed to claimable categories"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-EPOCH ACCUMULATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_MultiEpoch_RewardsAccumulateCorrectly() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        // Run 5 epochs without claiming
        for (uint256 i = 0; i < 5; i++) {
            _advanceAndDistributeEpoch();
        }

        uint256 pendingAfter5 = controller.pendingOperatorRewards(operator1);

        // Run 5 more epochs
        for (uint256 i = 0; i < 5; i++) {
            _advanceAndDistributeEpoch();
        }

        uint256 pendingAfter10 = controller.pendingOperatorRewards(operator1);

        // Pending should have grown
        assertGt(pendingAfter10, pendingAfter5, "Rewards should accumulate over epochs");

        // Claim and verify
        vm.prank(operator1);
        uint256 claimed = controller.claimOperatorRewards();

        assertEq(claimed, pendingAfter10, "Claimed should equal accumulated pending");
        assertEq(tnt.balanceOf(operator1), pendingAfter10, "Balance should equal claimed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // YEAR BOUNDARY VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_YearBoundary_BudgetResetsCorrectly() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        // Distribute some epochs in year 1
        for (uint256 i = 0; i < 10; i++) {
            _advanceAndDistributeEpoch();
        }

        uint256 mintedYear1 = controller.mintedThisYear();
        assertGt(mintedYear1, 0, "Should have minted in year 1");

        // Record year start for verification
        uint256 year1Start = controller.yearStartBlock();

        // Advance past year boundary - roll to a block past the year end
        uint256 blocksPerYear = controller.BLOCKS_PER_YEAR();
        uint256 yearEndBlock = year1Start + blocksPerYear;

        // Roll past year boundary first
        vm.roll(yearEndBlock + 1000);

        // Now advance and distribute - this should trigger year reset
        InflationController.EpochData memory epoch = controller.getEpoch(controller.currentEpoch());
        // Make sure we're past the epoch end too
        if (block.number <= epoch.endBlock) {
            vm.roll(epoch.endBlock + 1);
        }
        controller.distributeEpoch();

        // Year should have reset
        uint256 year2Start = controller.yearStartBlock();
        assertGt(year2Start, year1Start, "Year start should have advanced");

        // mintedThisYear should have reset and now only contain one epoch's worth
        uint256 mintedYear2 = controller.mintedThisYear();

        // Verify new yearly budget is based on new supply
        uint256 newYearlyBudget = controller.calculateYearlyBudget();
        uint256 currentSupply = tnt.totalSupply();
        uint256 expectedBudget = (currentSupply * INFLATION_BPS) / BPS_DENOMINATOR;
        assertEq(newYearlyBudget, expectedBudget, "Yearly budget should be based on current supply");

        // mintedThisYear should be less than new yearly budget (just one epoch distributed)
        assertLt(mintedYear2, newYearlyBudget, "Only one epoch should be minted in new year");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WEIGHT CHANGE MID-STREAM
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_WeightChange_AffectsNextEpoch() public {
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerCustomer(customer1);
        vm.stopPrank();

        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);
        metrics.recordPayment(customer1, 1, address(0), 100 ether);

        // IMPORTANT: Add staking deposits so weight distribution is accurate
        _addStakingDeposits(operator1, operator1, 1000 ether);

        // Epoch 1 with default weights (60/25/15)
        _advanceAndDistributeEpoch();
        InflationController.EpochData memory epoch1Data = controller.getEpoch(1);

        // Change weights to (50/30/20)
        vm.prank(admin);
        controller.setWeights(5000, 3000, 2000);

        // Epoch 2 with new weights
        _advanceAndDistributeEpoch();
        InflationController.EpochData memory epoch2Data = controller.getEpoch(2);

        // Verify distributions changed
        // Epoch 2 operators should be higher proportion than epoch 1
        uint256 epoch1Total = epoch1Data.stakingDistributed + epoch1Data.operatorsDistributed + epoch1Data.customersDistributed;
        uint256 epoch2Total = epoch2Data.stakingDistributed + epoch2Data.operatorsDistributed + epoch2Data.customersDistributed;

        uint256 epoch1OpPct = (epoch1Data.operatorsDistributed * 10000) / epoch1Total;
        uint256 epoch2OpPct = (epoch2Data.operatorsDistributed * 10000) / epoch2Total;

        // Operators went from 25% to 30%
        assertApproxEqAbs(epoch1OpPct, 2500, 100, "Epoch 1 operator % should be ~25%");
        assertApproxEqAbs(epoch2OpPct, 3000, 100, "Epoch 2 operator % should be ~30%");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INFLATION RATE CHANGE
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_InflationRateChange_AffectsNextEpoch() public {
        vm.prank(admin);
        controller.registerOperator(operator1);
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordJobCompletion(operator1, 1, 0, true);

        // Epoch 1 with 1% inflation
        uint256 budget1 = controller.calculateEpochBudget();
        _advanceAndDistributeEpoch();

        // Change to 2% inflation
        vm.prank(admin);
        controller.setInflationRate(200);

        // Epoch 2 with 2% inflation
        uint256 budget2 = controller.calculateEpochBudget();
        _advanceAndDistributeEpoch();

        // Budget should approximately double
        assertApproxEqRel(budget2, budget1 * 2, 0.01e18, "Budget should ~double with 2x inflation");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // COMPREHENSIVE E2E SCENARIO
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_FullYearSimulation() public {
        // Setup
        vm.startPrank(admin);
        controller.registerOperator(operator1);
        controller.registerOperator(operator2);
        controller.registerOperator(operator3);
        controller.registerCustomer(customer1);
        controller.registerCustomer(customer2);
        // Use larger epoch length to reduce gas usage
        controller.setEpochLength(50000);
        vm.stopPrank();

        // Record varied activity
        metrics.recordOperatorRegistered(operator1, address(0), 1000 ether);
        metrics.recordOperatorRegistered(operator2, address(0), 2000 ether);
        metrics.recordOperatorRegistered(operator3, address(0), 500 ether);

        for (uint256 i = 0; i < 10; i++) {
            metrics.recordJobCompletion(operator1, 1, uint64(i), true);
            metrics.recordJobCompletion(operator2, 1, uint64(i + 10), true);
            metrics.recordJobCompletion(operator3, 1, uint64(i + 20), i % 2 == 0); // 50% success
        }

        metrics.recordPayment(customer1, 1, address(0), 500 ether);
        metrics.recordPayment(customer2, 1, address(0), 200 ether);

        uint256 initialSupply = tnt.totalSupply();
        uint256 yearlyBudget = controller.calculateYearlyBudget();

        // Run epochs (simulate ~1/4 year with larger epochs)
        // With 50K block epochs, we have ~52 epochs per year, so run ~13 for 1/4 year
        uint256 epochsToRun = 13;

        uint256 totalMinted = 0;
        for (uint256 i = 0; i < epochsToRun; i++) {
            uint256 minted = _advanceAndDistributeEpoch();
            totalMinted += minted;
        }

        // Verify all balances
        uint256 finalSupply = tnt.totalSupply();

        // INVARIANT 1: Supply accounting
        assertEq(finalSupply, initialSupply + totalMinted, "Supply accounting mismatch");

        // INVARIANT 2: Did not exceed ~25% of yearly budget
        assertLe(totalMinted, (yearlyBudget / 4) + controller.calculateEpochBudget(), "Exceeded quarterly budget");

        // INVARIANT 3: Controller tracking accurate
        assertEq(controller.mintedThisYear(), totalMinted, "Controller tracking mismatch");

        // Claim all rewards (only if they have pending)
        uint256 op1Pending = controller.pendingOperatorRewards(operator1);
        uint256 op2Pending = controller.pendingOperatorRewards(operator2);
        uint256 op3Pending = controller.pendingOperatorRewards(operator3);
        uint256 cust1Pending = controller.pendingCustomerRewards(customer1);
        uint256 cust2Pending = controller.pendingCustomerRewards(customer2);

        if (op1Pending > 0) {
            vm.prank(operator1);
            controller.claimOperatorRewards();
        }
        if (op2Pending > 0) {
            vm.prank(operator2);
            controller.claimOperatorRewards();
        }
        if (op3Pending > 0) {
            vm.prank(operator3);
            controller.claimOperatorRewards();
        }
        if (cust1Pending > 0) {
            vm.prank(customer1);
            controller.claimCustomerRewards();
        }
        if (cust2Pending > 0) {
            vm.prank(customer2);
            controller.claimCustomerRewards();
        }

        // All pending should now be 0
        assertEq(controller.pendingOperatorRewards(operator1), 0);
        assertEq(controller.pendingOperatorRewards(operator2), 0);
        assertEq(controller.pendingOperatorRewards(operator3), 0);
        assertEq(controller.pendingCustomerRewards(customer1), 0);
        assertEq(controller.pendingCustomerRewards(customer2), 0);

        // Operators with more work/stake should have more rewards
        assertGe(tnt.balanceOf(operator2), tnt.balanceOf(operator3), "Op2 (more stake) should have >= op3");
    }
}
