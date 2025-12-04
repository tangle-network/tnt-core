// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { DelegationErrors } from "../../src/v2/restaking/DelegationErrors.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { MockERC20 } from "./mocks/MockERC20.sol";

contract MultiAssetDelegationTest is Test {
    MultiAssetDelegation public delegation;
    MockERC20 public token;

    address public admin = makeAddr("admin");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public delegator1 = makeAddr("delegator1");
    address public delegator2 = makeAddr("delegator2");

    uint256 public constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 public constant MIN_DELEGATION = 0.1 ether;
    uint16 public constant OPERATOR_COMMISSION_BPS = 1000; // 10%

    function setUp() public {
        // Deploy mock token
        token = new MockERC20();

        // Deploy delegation
        MultiAssetDelegation impl = new MultiAssetDelegation();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(
                MultiAssetDelegation.initialize,
                (admin, MIN_OPERATOR_STAKE, MIN_DELEGATION, OPERATOR_COMMISSION_BPS)
            )
        );
        delegation = MultiAssetDelegation(payable(address(proxy)));

        // Fund actors
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(delegator1, 100 ether);
        vm.deal(delegator2, 100 ether);
        token.mint(delegator1, 100 ether);
        token.mint(delegator2, 100 ether);

        // Enable ERC20 token
        vm.prank(admin);
        delegation.enableAsset(address(token), 1 ether, 0.1 ether, 0, 10000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RegisterOperator() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertTrue(delegation.isOperator(operator1));
        assertTrue(delegation.isOperatorActive(operator1));
        assertEq(delegation.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE);
    }

    function test_RegisterOperator_RevertInsufficientStake() public {
        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationErrors.InsufficientStake.selector,
                MIN_OPERATOR_STAKE,
                MIN_OPERATOR_STAKE - 1
            )
        );
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE - 1 }();
    }

    function test_RegisterOperator_RevertAlreadyRegistered() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.OperatorAlreadyRegistered.selector, operator1)
        );
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();
    }

    function test_IncreaseStake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.increaseStake{ value: 1 ether }();

        assertEq(delegation.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE + 1 ether);
    }

    function test_AddBlueprint() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.addBlueprint(1);

        uint256[] memory blueprints = delegation.getOperatorBlueprints(operator1);
        assertEq(blueprints.length, 1);
        assertEq(blueprints[0], 1);
    }

    function test_StartLeaving() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.startLeaving();

        assertFalse(delegation.isOperatorActive(operator1));
    }

    function test_CompleteLeaving() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.startLeaving();

        // Advance rounds
        for (uint256 i = 0; i < 7; i++) {
            delegation.advanceRound();
        }

        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        delegation.completeLeaving();

        assertEq(operator1.balance, balanceBefore + MIN_OPERATOR_STAKE);
        assertFalse(delegation.isOperator(operator1));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPOSIT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DepositNative() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 1 ether);
        assertEq(dep.delegatedAmount, 0);
    }

    function test_DepositWithLock() public {
        vm.prank(delegator1);
        delegation.depositWithLock{ value: 1 ether }(Types.LockMultiplier.ThreeMonths);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 1 ether);
    }

    function test_DepositERC20() public {
        vm.startPrank(delegator1);
        token.approve(address(delegation), 1 ether);
        delegation.depositERC20(address(token), 1 ether);
        vm.stopPrank();

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(token));
        assertEq(dep.amount, 1 ether);
    }

    function test_ScheduleWithdraw() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 0.5 ether);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 0.5 ether);
    }

    function test_ExecuteWithdraw() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 0.5 ether);

        // Advance rounds
        for (uint256 i = 0; i < 7; i++) {
            delegation.advanceRound();
        }

        uint256 balanceBefore = delegator1.balance;

        vm.prank(delegator1);
        delegation.executeWithdraw();

        assertEq(delegator1.balance, balanceBefore + 0.5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Delegate() public {
        // Setup operator
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Deposit and delegate
        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 0.5 ether);
        vm.stopPrank();

        assertEq(delegation.getDelegation(delegator1, operator1), 0.5 ether);
        assertEq(delegation.getOperatorDelegatedStake(operator1), 0.5 ether);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.delegatedAmount, 0.5 ether);
    }

    function test_DepositAndDelegate_SingleTransaction() public {
        // Setup operator
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Single transaction: deposit + delegate
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 1 ether }(operator1);

        // Verify delegation
        assertEq(delegation.getDelegation(delegator1, operator1), 1 ether);
        assertEq(delegation.getOperatorDelegatedStake(operator1), 1 ether);

        // Verify deposit tracking
        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 1 ether);
        assertEq(dep.delegatedAmount, 1 ether);
    }

    function test_DelegateWithBlueprintSelection() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        uint64[] memory blueprints = new uint64[](2);
        blueprints[0] = 1;
        blueprints[1] = 2;

        vm.prank(delegator1);
        delegation.delegateWithOptions(
            operator1,
            address(0),
            0.5 ether,
            Types.BlueprintSelectionMode.Fixed,
            blueprints
        );

        uint64[] memory selectedBlueprints = delegation.getDelegationBlueprints(delegator1, 0);
        assertEq(selectedBlueprints.length, 2);
        assertEq(selectedBlueprints[0], 1);
        assertEq(selectedBlueprints[1], 2);
    }

    function test_DelegateMultipleOperators() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator2);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 2 ether }();
        delegation.delegate(operator1, 0.5 ether);
        delegation.delegate(operator2, 0.5 ether);
        vm.stopPrank();

        assertEq(delegation.getDelegation(delegator1, operator1), 0.5 ether);
        assertEq(delegation.getDelegation(delegator1, operator2), 0.5 ether);
        assertEq(delegation.getTotalDelegation(delegator1), 1 ether);
    }

    function test_ScheduleUnstake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 0.5 ether);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 0.25 ether);
        vm.stopPrank();

        // Still delegated until execution
        assertEq(delegation.getDelegation(delegator1, operator1), 0.5 ether);
    }

    function test_ExecuteUnstake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 0.5 ether);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 0.25 ether);
        vm.stopPrank();

        // Advance rounds
        for (uint256 i = 0; i < 7; i++) {
            delegation.advanceRound();
        }

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 0.25 ether);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.delegatedAmount, 0.25 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_NotifyReward() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 1 ether);
        vm.stopPrank();

        // Fund contract and notify reward
        vm.deal(address(delegation), 10 ether);
        delegation.notifyReward(operator1, 0, 1 ether);

        // Check operator pending rewards (10% commission)
        assertEq(delegation.getPendingOperatorRewards(operator1), 0.1 ether);

        // Check delegator pending rewards (90%)
        assertEq(delegation.getPendingDelegatorRewards(delegator1), 0.9 ether);
    }

    function test_ClaimDelegatorRewards() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 1 ether);
        vm.stopPrank();

        vm.deal(address(delegation), 10 ether);
        delegation.notifyReward(operator1, 0, 1 ether);

        uint256 balanceBefore = delegator1.balance;

        vm.prank(delegator1);
        delegation.claimDelegatorRewards();

        assertEq(delegator1.balance, balanceBefore + 0.9 ether);
        assertEq(delegation.getPendingDelegatorRewards(delegator1), 0);
    }

    function test_ClaimOperatorRewards() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 1 ether);
        vm.stopPrank();

        vm.deal(address(delegation), 10 ether);
        delegation.notifyReward(operator1, 0, 1 ether);

        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        delegation.claimOperatorRewards();

        assertEq(operator1.balance, balanceBefore + 0.1 ether);
        assertEq(delegation.getPendingOperatorRewards(operator1), 0);
    }

    function test_RewardsProportionalToStake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Delegator1 delegates 1 ether
        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 1 ether);
        vm.stopPrank();

        // Delegator2 delegates 3 ether (3x more)
        vm.startPrank(delegator2);
        delegation.deposit{ value: 3 ether }();
        delegation.delegate(operator1, 3 ether);
        vm.stopPrank();

        vm.deal(address(delegation), 10 ether);
        delegation.notifyReward(operator1, 0, 4 ether);

        // Total delegator share: 3.6 ether (90% of 4)
        // Delegator1: 3.6 * 1/4 = 0.9 ether
        // Delegator2: 3.6 * 3/4 = 2.7 ether
        assertEq(delegation.getPendingDelegatorRewards(delegator1), 0.9 ether);
        assertEq(delegation.getPendingDelegatorRewards(delegator2), 2.7 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Slash() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        vm.prank(admin);
        delegation.addSlasher(admin);

        vm.prank(admin);
        uint256 slashed = delegation.slash(operator1, 0, 1 ether, bytes32(0));

        assertEq(slashed, 1 ether);
        assertEq(delegation.getOperatorSelfStake(operator1), 9 ether);
    }

    function test_Slash_RevertNotSlasher() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        vm.prank(delegator1);
        vm.expectRevert();
        delegation.slash(operator1, 0, 1 ether, bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERC20 DELEGATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DelegateERC20() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        token.approve(address(delegation), 1 ether);
        delegation.depositERC20(address(token), 1 ether);

        uint64[] memory empty = new uint64[](0);
        delegation.delegateWithOptions(
            operator1,
            address(token),
            0.5 ether,
            Types.BlueprintSelectionMode.All,
            empty
        );
        vm.stopPrank();

        Types.BondInfoDelegator[] memory delegations = delegation.getDelegations(delegator1);
        assertEq(delegations.length, 1);
        // Shares = amount for first delegation (1:1 exchange rate)
        assertEq(delegations[0].shares, 0.5 ether);
        assertEq(delegations[0].asset.token, address(token));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetOperatorCommission() public {
        vm.prank(admin);
        delegation.setOperatorCommission(2000); // 20%

        assertEq(delegation.operatorCommissionBps(), 2000);
    }

    function test_SetDelays() public {
        vm.prank(admin);
        delegation.setDelays(14, 14, 14);

        assertEq(delegation.delegationBondLessDelay(), 14);
        assertEq(delegation.leaveDelegatorsDelay(), 14);
        assertEq(delegation.leaveOperatorsDelay(), 14);
    }

    function test_DisableAsset() public {
        vm.prank(admin);
        delegation.disableAsset(address(token));

        Types.AssetConfig memory config = delegation.getAssetConfig(address(token));
        assertFalse(config.enabled);
    }

    function test_Pause() public {
        vm.prank(admin);
        delegation.pause();

        vm.prank(delegator1);
        vm.expectRevert();
        delegation.deposit{ value: 1 ether }();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GetOperatorStake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 5 ether }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 3 ether }();
        delegation.delegate(operator1, 3 ether);
        vm.stopPrank();

        // Total = self-stake + delegated
        assertEq(delegation.getOperatorStake(operator1), 8 ether);
    }

    function test_MeetsStakeRequirement() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 5 ether }();

        assertTrue(delegation.meetsStakeRequirement(operator1, 5 ether));
        assertTrue(delegation.meetsStakeRequirement(operator1, 1 ether));
        assertFalse(delegation.meetsStakeRequirement(operator1, 10 ether));
    }

    function test_OperatorCount() public {
        assertEq(delegation.operatorCount(), 0);

        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertEq(delegation.operatorCount(), 1);

        vm.prank(operator2);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertEq(delegation.operatorCount(), 2);
    }
}
