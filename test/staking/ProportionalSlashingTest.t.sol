// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { IMultiAssetDelegation } from "../../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/staking/MultiAssetDelegation.sol";
import { Types } from "../../src/libraries/Types.sol";
import { DelegationErrors } from "../../src/staking/DelegationErrors.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { StakingOperatorsFacet } from "../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../src/facets/staking/StakingAdminFacet.sol";

/// @title ProportionalSlashingTest
/// @notice Tests for O(1) share-based proportional slashing
contract ProportionalSlashingTest is Test {
    IMultiAssetDelegation public staking;

    // Test accounts
    address public admin = makeAddr("admin");
    address public slasher = makeAddr("slasher");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public delegator1 = makeAddr("delegator1");
    address public delegator2 = makeAddr("delegator2");
    address public delegator3 = makeAddr("delegator3");

    // Constants
    uint256 constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 constant PRECISION = 1e18;

    // Events to test - updated for O(1) share-based slashing
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
    event SlashRecorded(
        address indexed operator,
        uint64 indexed slashId,
        bytes32 assetHash,
        uint16 slashBps,
        uint256 totalSlashed,
        uint256 exchangeRateBefore,
        uint256 exchangeRateAfter
    );

    function setUp() public {
        // Deploy implementation
        MultiAssetDelegation impl = new MultiAssetDelegation();

        // Deploy proxy
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, MIN_OPERATOR_STAKE, 0, 1000) // 10% commission
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        staking = IMultiAssetDelegation(payable(address(proxy)));

        _registerFacets(address(proxy));

        // Fund accounts
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(delegator1, 100 ether);
        vm.deal(delegator2, 100 ether);
        vm.deal(delegator3, 100 ether);

        // Grant slasher role
        vm.prank(admin);
        staking.addSlasher(slasher);
    }

    function _registerFacets(address proxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(proxy));
        vm.startPrank(admin);
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));
        vm.stopPrank();
    }

    /// @notice Test proportional slashing distributes correctly between operator and delegators
    function test_ProportionalSlashing_CorrectDistribution() public {
        // Setup: Operator with 10 ETH, Delegators with 20 ETH and 30 ETH
        _setupOperatorWithDelegators();

        // Total stake = 60 ETH (10 operator + 20 d1 + 30 d2)
        uint256 totalStake = staking.getOperatorSelfStake(operator1) + staking.getDelegation(delegator1, operator1)
            + staking.getDelegation(delegator2, operator1);
        assertEq(totalStake, 60 ether, "Total stake should be 60 ETH");

        // Slash 10% of total
        uint16 slashBps = 1000;

        // Expected distribution:
        // Operator: 6 * 10/60 = 1 ETH
        // Delegators: 6 - 1 = 5 ETH
        // D1: 5 * 20/50 = 2 ETH
        // D2: 5 * 30/50 = 3 ETH

        uint256 operatorBefore = staking.getOperatorSelfStake(operator1);
        uint256 d1Before = staking.getDelegation(delegator1, operator1);
        uint256 d2Before = staking.getDelegation(delegator2, operator1);

        // Execute slash
        vm.prank(slasher);
        staking.slash(operator1, 0, slashBps, keccak256("test_evidence"));

        uint256 operatorAfter = staking.getOperatorSelfStake(operator1);
        uint256 d1After = staking.getDelegation(delegator1, operator1);
        uint256 d2After = staking.getDelegation(delegator2, operator1);

        // Verify proportional slashing
        uint256 operatorSlashed = operatorBefore - operatorAfter;
        uint256 d1Slashed = d1Before - d1After;
        uint256 d2Slashed = d2Before - d2After;

        // Operator should lose ~1 ETH (10/60 of 6 ETH)
        assertEq(operatorSlashed, 1 ether, "Operator should lose 1 ETH");

        // Delegators should lose ~5 ETH total
        assertEq(d1Slashed + d2Slashed, 5 ether, "Delegators should lose 5 ETH total");

        // D2 should lose 1.5x what D1 loses (30 vs 20 ETH stake)
        assertEq(d2Slashed, (d1Slashed * 3) / 2, "D2 should lose 1.5x D1");
    }

    /// @notice Test slash record is created with correct exchange rates
    /// @dev O(1) slashing uses exchange rate reduction instead of per-delegator events
    function test_SlashRecord_CreatedWithExchangeRates() public {
        _setupOperatorWithDelegators();

        uint16 slashBps = 1000;

        // Get exchange rate before slash
        Types.OperatorRewardPool memory poolBefore = staking.getOperatorRewardPool(operator1);
        uint256 rateBefore = (poolBefore.totalAssets * PRECISION) / poolBefore.totalShares;

        // Execute slash
        vm.prank(slasher);
        staking.slash(operator1, 0, slashBps, keccak256("test_evidence"));

        // Get exchange rate after slash
        Types.OperatorRewardPool memory poolAfter = staking.getOperatorRewardPool(operator1);
        uint256 rateAfter = (poolAfter.totalAssets * PRECISION) / poolAfter.totalShares;

        // Exchange rate should have decreased
        assertTrue(rateAfter < rateBefore, "Exchange rate should decrease after slash");

        // Total slashed = 6 ETH, delegator portion = 5 ETH
        // Original pool: 50 ETH, after slash: 45 ETH
        // Exchange rate drop = 10% for delegators
        assertEq(poolAfter.totalAssets, 45 ether, "Pool should have 45 ETH after 5 ETH slashed");
    }

    /// @notice Test slashing actually reduces delegator balances
    function test_Slashing_ReducesDelegatorBalances() public {
        _setupOperatorWithDelegators();

        uint256 d1Before = staking.getDelegation(delegator1, operator1);
        uint256 d2Before = staking.getDelegation(delegator2, operator1);

        assertEq(d1Before, 20 ether, "D1 should have 20 ETH delegated");
        assertEq(d2Before, 30 ether, "D2 should have 30 ETH delegated");

        // Slash 50% of total (30 ETH)
        vm.prank(slasher);
        staking.slash(operator1, 0, 5000, keccak256("evidence"));

        uint256 d1After = staking.getDelegation(delegator1, operator1);
        uint256 d2After = staking.getDelegation(delegator2, operator1);

        // Both delegators should have reduced balances
        assertTrue(d1After < d1Before, "D1 balance should be reduced");
        assertTrue(d2After < d2Before, "D2 balance should be reduced");
    }

    /// @notice Test operator -> delegators mapping is maintained correctly
    function test_OperatorDelegatorsMapping_MaintainedCorrectly() public {
        // Register operator
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);

        // Initially no delegators
        address[] memory delegators = staking.getOperatorDelegators(operator1);
        assertEq(delegators.length, 0, "Should have no delegators initially");

        // Delegator1 deposits and delegates
        vm.startPrank(delegator1);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator1, 20 ether);
        vm.stopPrank();

        delegators = staking.getOperatorDelegators(operator1);
        assertEq(delegators.length, 1, "Should have 1 delegator");
        assertEq(delegators[0], delegator1, "Delegator1 should be in set");

        // Delegator2 deposits and delegates
        vm.startPrank(delegator2);
        staking.deposit{ value: 30 ether }();
        staking.delegate(operator1, 30 ether);
        vm.stopPrank();

        delegators = staking.getOperatorDelegators(operator1);
        assertEq(delegators.length, 2, "Should have 2 delegators");
    }

    /// @notice Test slashing with single delegator
    function test_Slashing_SingleDelegator() public {
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);

        vm.startPrank(delegator1);
        staking.deposit{ value: 10 ether }();
        staking.delegate(operator1, 10 ether);
        vm.stopPrank();

        // Slash 10% from total of 20 ETH
        // O(1) slashing: just reduces totalAssets, exchange rate drops
        vm.prank(slasher);
        staking.slash(operator1, 0, 1000, keccak256("evidence"));

        assertEq(staking.getOperatorSelfStake(operator1), 9 ether, "Operator should have 9 ETH");
        assertEq(staking.getDelegation(delegator1, operator1), 9 ether, "Delegator should have 9 ETH");
    }

    /// @notice Test slashing with three delegators
    function test_Slashing_ThreeDelegators() public {
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);

        // D1: 10 ETH, D2: 20 ETH, D3: 30 ETH = 60 ETH delegated
        vm.startPrank(delegator1);
        staking.deposit{ value: 10 ether }();
        staking.delegate(operator1, 10 ether);
        vm.stopPrank();

        vm.startPrank(delegator2);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator1, 20 ether);
        vm.stopPrank();

        vm.startPrank(delegator3);
        staking.deposit{ value: 30 ether }();
        staking.delegate(operator1, 30 ether);
        vm.stopPrank();

        // Total = 70 ETH (10 op + 60 delegated)
        // Slash 10%
        // Operator: 7 * 10/70 = 1 ETH
        // Delegators: 6 ETH split by 10:20:30 ratio
        // D1: 6 * 10/60 = 1 ETH
        // D2: 6 * 20/60 = 2 ETH
        // D3: 6 * 30/60 = 3 ETH

        vm.prank(slasher);
        staking.slash(operator1, 0, 1000, keccak256("evidence"));

        assertEq(staking.getOperatorSelfStake(operator1), 9 ether, "Operator should have 9 ETH");
        assertEq(staking.getDelegation(delegator1, operator1), 9 ether, "D1 should have 9 ETH");
        assertEq(staking.getDelegation(delegator2, operator1), 18 ether, "D2 should have 18 ETH");
        assertEq(staking.getDelegation(delegator3, operator1), 27 ether, "D3 should have 27 ETH");
    }

    /// @notice Test slashing doesn't affect other operators' delegators
    function test_Slashing_IsolatedToOperator() public {
        // Setup two operators with delegators
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);

        vm.prank(operator2);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator2);
        staking.setDelegationMode(Types.DelegationMode.Open);

        // D1 delegates to operator1
        vm.startPrank(delegator1);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator1, 20 ether);
        vm.stopPrank();

        // D2 delegates to operator2
        vm.startPrank(delegator2);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator2, 20 ether);
        vm.stopPrank();

        // Slash operator1 only
        vm.prank(slasher);
        staking.slash(operator1, 0, 2000, keccak256("evidence"));

        // Operator2 and D2 should be unaffected
        assertEq(staking.getOperatorSelfStake(operator2), 10 ether, "Operator2 should be unchanged");
        assertEq(staking.getDelegation(delegator2, operator2), 20 ether, "D2 delegation to op2 unchanged");
    }

    /// @notice Test slashing caps at total stake
    function test_Slashing_CapsAtTotalStake() public {
        _setupOperatorWithDelegators();

        // Try to slash full stake
        vm.prank(slasher);
        staking.slash(operator1, 0, 10_000, keccak256("evidence"));

        uint256 totalAfter = staking.getOperatorSelfStake(operator1) + staking.getDelegation(delegator1, operator1)
            + staking.getDelegation(delegator2, operator1);

        // Total should be 0 (capped slash)
        assertEq(totalAfter, 0, "Total stake should be 0 after max slash");
    }

    /// @notice Test delegator count is maintained correctly after slashing
    function test_DelegatorCount_MaintainedAfterSlashing() public {
        _setupOperatorWithDelegators();

        uint256 countBefore = staking.getOperatorDelegatorCount(operator1);
        assertEq(countBefore, 2, "Should have 2 delegators before slash");

        // Slash but not enough to remove delegators
        vm.prank(slasher);
        staking.slash(operator1, 0, 1000, keccak256("evidence"));

        uint256 countAfter = staking.getOperatorDelegatorCount(operator1);
        assertEq(countAfter, 2, "Should still have 2 delegators after slash");
    }

    /// @notice Test main slash event is emitted with correct totals
    function test_Slashing_MainEventEmitted() public {
        _setupOperatorWithDelegators();

        // Calculate expected new exchange rate after slash
        // With C-1 virtual shares fix: shares = amount * VIRTUAL_SHARES (1e8)
        // Original: 50 ETH totalAssets, 50e26 shares (with 1e8 virtual offset)
        // After: 45 ETH totalAssets, 50e26 shares
        // New rate = 45e18 * 1e18 / 50e26 = 9e9
        uint256 VIRTUAL_SHARES = 1e8;
        uint256 expectedNewRate = (45 ether * PRECISION) / (50 ether * VIRTUAL_SHARES);

        // Expect main Slashed event with new exchange rate
        vm.expectEmit(true, true, true, true);
        bytes32 assetHash = keccak256(abi.encode(Types.AssetKind.Native, address(0)));
        emit Slashed(operator1, 0, 0, assetHash, 1000, 1 ether, 5 ether, expectedNewRate);

        vm.prank(slasher);
        staking.slash(operator1, 0, 1000, keccak256("evidence"));
    }

    /// @notice Test slashing operator with no delegators
    function test_Slashing_OperatorNoDelegators() public {
        // Register operator with stake but no delegators
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);

        // Slash 50%
        vm.prank(slasher);
        staking.slash(operator1, 0, 5000, keccak256("evidence"));

        // Only operator should be slashed
        assertEq(staking.getOperatorSelfStake(operator1), 5 ether, "Operator should have 5 ETH");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _setupOperatorWithDelegators() internal {
        // Operator with 10 ETH
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);

        // Delegator1 with 20 ETH
        vm.startPrank(delegator1);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator1, 20 ether);
        vm.stopPrank();

        // Delegator2 with 30 ETH
        vm.startPrank(delegator2);
        staking.deposit{ value: 30 ether }();
        staking.delegate(operator1, 30 ether);
        vm.stopPrank();
    }
}
