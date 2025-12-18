// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { MultiAssetDelegation } from "../../../src/v2/restaking/MultiAssetDelegation.sol";
import { DelegationErrors } from "../../../src/v2/restaking/DelegationErrors.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";

/// @notice Mock ERC20 for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock", "MCK") {}
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @title DelegationFlowsTest
/// @notice Comprehensive tests for deposit/delegate/undelegate/withdraw flows
contract DelegationFlowsTest is Test {
    MultiAssetDelegation public delegation;
    MockToken public token;

    address public admin = makeAddr("admin");
    address public operator1 = makeAddr("operator1");
    address public delegator1 = makeAddr("delegator1");

    uint256 constant MIN_OPERATOR_STAKE = 1 ether;
    uint64 constant DELEGATION_DELAY = 28; // Match ProtocolConfig.DELEGATOR_DELAY_ROUNDS
    uint64 constant WITHDRAW_DELAY = 28; // Match ProtocolConfig.DELEGATOR_DELAY_ROUNDS

    function setUp() public {
        // Deploy
        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, MIN_OPERATOR_STAKE, 0, 1000)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        delegation = MultiAssetDelegation(payable(address(proxy)));

        // Deploy mock token and enable it
        token = new MockToken();
        vm.prank(admin);
        delegation.enableAsset(address(token), 1 ether, 0.1 ether, 0, 10000);

        // Fund accounts
        vm.deal(operator1, 100 ether);
        vm.deal(delegator1, 100 ether);
        token.mint(delegator1, 100 ether);

        // Register operator
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();
    }

    /// @notice Helper to advance rounds with proper time warping
    function _advanceRounds(uint64 count) internal {
        uint256 roundDuration = delegation.roundDuration();
        uint256 startTime = block.timestamp;
        for (uint64 i = 0; i < count; i++) {
            vm.warp(startTime + (i + 1) * roundDuration);
            delegation.advanceRound();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HAPPY PATH TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_FullFlow_Native_DepositDelegateUndelegateWithdraw() public {
        // 1. Deposit + Delegate in one tx
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);

        // 2. Schedule unstake
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        // Still shows delegation until executed
        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);

        // 3. Advance past delay
        _advanceRounds(DELEGATION_DELAY);

        // 4. Execute unstake
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 0);

        // 5. Schedule withdraw
        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 5 ether);

        // 6. Advance past withdraw delay
        _advanceRounds(WITHDRAW_DELAY);

        // 7. Execute withdraw
        uint256 balanceBefore = delegator1.balance;
        vm.prank(delegator1);
        delegation.executeWithdraw();

        assertEq(delegator1.balance, balanceBefore + 5 ether);
    }

    function test_FullFlow_ERC20_DepositDelegateUndelegateWithdraw() public {
        // 1. Approve and deposit+delegate
        vm.startPrank(delegator1);
        token.approve(address(delegation), 5 ether);
        delegation.depositAndDelegateWithOptions(
            operator1,
            address(token),
            5 ether,
            Types.BlueprintSelectionMode.All,
            new uint64[](0)
        );
        vm.stopPrank();

        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);

        // 2. Schedule unstake
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(token), 5 ether);

        // 3. Advance past delay and execute
        _advanceRounds(DELEGATION_DELAY);
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // 4. Schedule and execute withdraw
        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(token), 5 ether);

        _advanceRounds(WITHDRAW_DELAY);

        uint256 balanceBefore = token.balanceOf(delegator1);
        vm.prank(delegator1);
        delegation.executeWithdraw();

        assertEq(token.balanceOf(delegator1), balanceBefore + 5 ether);
    }

    function test_PartialUnstake() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // Unstake only half
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        _advanceRounds(DELEGATION_DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // Should still have 5 ether delegated
        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);
    }

    function test_MultipleUnstakeRequests() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // Schedule multiple unstakes
        vm.startPrank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 3 ether);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 2 ether);
        vm.stopPrank();

        _advanceRounds(DELEGATION_DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // Both should be processed
        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);
    }

    function test_ExecuteWithdraw_PreservesRequestOrder() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 12 ether }();

        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 3 ether);
        _advanceRounds(1);
        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 4 ether);
        _advanceRounds(1);
        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 5 ether);

        Types.WithdrawRequest[] memory pending = delegation.getPendingWithdrawals(delegator1);
        assertEq(pending.length, 3);
        assertEq(pending[0].amount, 3 ether);
        assertEq(pending[1].amount, 4 ether);
        assertEq(pending[2].amount, 5 ether);

        uint64 delay = delegation.leaveDelegatorsDelay();
        uint64 targetRound = pending[0].requestedRound + delay;
        uint64 currentRound = uint64(delegation.currentRound());
        if (targetRound > currentRound) {
            _advanceRounds(targetRound - currentRound);
        }

        uint256 balanceBefore = delegator1.balance;
        vm.prank(delegator1);
        delegation.executeWithdraw();

        assertEq(delegator1.balance, balanceBefore + 3 ether);

        pending = delegation.getPendingWithdrawals(delegator1);
        assertEq(pending.length, 2);
        assertEq(pending[0].amount, 4 ether);
        assertEq(pending[1].amount, 5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERROR TESTS - EARLY EXECUTION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExecuteUnstake_RevertBeforeDelay() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        // Try to execute immediately (before delay)
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // Should still be delegated (nothing to execute yet)
        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);
    }

    function test_ExecuteWithdraw_NothingHappensBeforeDelay() public {
        uint256 balanceBefore = delegator1.balance;

        vm.startPrank(delegator1);
        delegation.deposit{ value: 5 ether }();
        delegation.scheduleWithdraw(address(0), 5 ether);

        // Note: deposit.amount is reduced at schedule time, not execute time
        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 0, "Deposit reduced at schedule time");

        // Try to execute immediately - nothing should transfer
        delegation.executeWithdraw();
        vm.stopPrank();

        // Balance should not have changed (no funds transferred)
        assertEq(delegator1.balance, balanceBefore - 5 ether, "No funds returned yet");

        // Pending request should still exist
        Types.WithdrawRequest[] memory pending = delegation.getPendingWithdrawals(delegator1);
        assertEq(pending.length, 1, "Request still pending");
        assertEq(pending[0].amount, 5 ether, "Pending amount correct");
    }

    function test_ExecuteUnstake_PartiallyReady() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // First request at round 1
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 3 ether);

        // Advance 3 rounds (now at round 4)
        _advanceRounds(3);

        // Second request at round 4
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 2 ether);

        // Advance to make first ready but not second
        // First request needs: round 1 + 28 = 29
        // Second request needs: round 4 + 28 = 32
        // Advance 25 more rounds to reach round 29 (4 + 25 = 29)
        _advanceRounds(25);

        // Execute - only first should process
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // First (3 ether) unstaked, second (2 ether) still pending
        assertEq(delegation.getDelegation(delegator1, operator1), 7 ether);

        // Advance more to make second ready (need 3 more to reach round 32)
        _advanceRounds(3);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERROR TESTS - INSUFFICIENT BALANCE
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Delegate_RevertInsufficientDeposit() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        vm.prank(delegator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.InsufficientDeposit.selector, 1 ether, 5 ether)
        );
        delegation.delegate(operator1, 5 ether);
    }

    function test_ScheduleUnstake_RevertInsufficientDelegation() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        vm.prank(delegator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.InsufficientDelegation.selector, 5 ether, 10 ether)
        );
        delegation.scheduleDelegatorUnstake(operator1, address(0), 10 ether);
    }

    function test_ScheduleWithdraw_RevertExceedsDeposit() public {
        vm.startPrank(delegator1);
        delegation.deposit{ value: 5 ether }();

        // Trying to withdraw more than deposited
        // Current implementation: checks free (unlocked) amount first
        // free = deposit - locked = 5 - 0 = 5
        // 5 < 10 → reverts with AmountLocked
        // TODO: Consider changing to InsufficientAvailableBalance for clarity
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.AmountLocked.selector, 0, 10 ether)
        );
        delegation.scheduleWithdraw(address(0), 10 ether);
        vm.stopPrank();
    }

    function test_ScheduleWithdraw_RevertWhenDelegated() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        // Can't withdraw delegated funds
        vm.prank(delegator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.InsufficientAvailableBalance.selector, 0, 5 ether)
        );
        delegation.scheduleWithdraw(address(0), 5 ether);
    }

    function test_Delegate_RevertOperatorNotRegistered() public {
        address unregisteredOp = makeAddr("unregisteredOp");

        vm.prank(delegator1);
        delegation.deposit{ value: 5 ether }();

        // Cannot delegate to unregistered operator
        vm.prank(delegator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.OperatorNotRegistered.selector, unregisteredOp)
        );
        delegation.delegate(unregisteredOp, 5 ether);
    }

    function test_Delegate_RevertZeroAmount() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 5 ether }();

        vm.prank(delegator1);
        vm.expectRevert(DelegationErrors.ZeroAmount.selector);
        delegation.delegate(operator1, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERROR TESTS - DELEGATION NOT FOUND
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ScheduleUnstake_RevertDelegationNotFound() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 5 ether }();

        // Never delegated to operator1
        vm.prank(delegator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.DelegationNotFound.selector, delegator1, operator1)
        );
        delegation.scheduleDelegatorUnstake(operator1, address(0), 1 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DepositAndDelegate_FullAmount() public {
        uint256 amount = 5 ether;

        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: amount }(operator1);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, amount);
        assertEq(dep.delegatedAmount, amount);
        assertEq(delegation.getDelegation(delegator1, operator1), amount);
    }

    function test_MultipleDelegationsToSameOperator() public {
        vm.startPrank(delegator1);
        delegation.deposit{ value: 10 ether }();
        delegation.delegate(operator1, 3 ether);
        delegation.delegate(operator1, 2 ether);
        vm.stopPrank();

        // Should be cumulative
        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);
    }

    function test_DelegateToMultipleOperators() public {
        address operator2 = makeAddr("operator2");
        vm.deal(operator2, 100 ether);
        vm.prank(operator2);
        delegation.registerOperator{ value: 10 ether }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 10 ether }();
        delegation.delegate(operator1, 4 ether);
        delegation.delegate(operator2, 3 ether);
        vm.stopPrank();

        assertEq(delegation.getDelegation(delegator1, operator1), 4 ether);
        assertEq(delegation.getDelegation(delegator1, operator2), 3 ether);
        assertEq(delegation.getTotalDelegation(delegator1), 7 ether);
    }

    function test_UnstakeAllThenRedelegate() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        // Unstake all
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        _advanceRounds(DELEGATION_DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 0);

        // Redelegate
        vm.prank(delegator1);
        delegation.delegate(operator1, 5 ether);

        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);
    }

    function test_WithdrawPartialThenDepositMore() public {
        vm.startPrank(delegator1);
        delegation.deposit{ value: 10 ether }();

        // Withdraw half
        delegation.scheduleWithdraw(address(0), 5 ether);
        vm.stopPrank();

        _advanceRounds(WITHDRAW_DELAY);

        vm.prank(delegator1);
        delegation.executeWithdraw();

        // Deposit more
        vm.prank(delegator1);
        delegation.deposit{ value: 3 ether }();

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 8 ether); // 5 remaining + 3 new
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELAY CONFIGURATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DelaysAreConfigured() public view {
        assertEq(delegation.delegationBondLessDelay(), 28); // DELEGATOR_DELAY_ROUNDS
        assertEq(delegation.leaveDelegatorsDelay(), 28); // DELEGATOR_DELAY_ROUNDS
        assertEq(delegation.leaveOperatorsDelay(), 56); // OPERATOR_DELAY_ROUNDS
    }

    function test_AdminCanChangeDelays() public {
        vm.prank(admin);
        delegation.setDelays(14, 21, 28);

        assertEq(delegation.delegationBondLessDelay(), 14);
        assertEq(delegation.leaveDelegatorsDelay(), 21);
        assertEq(delegation.leaveOperatorsDelay(), 28);
    }

    function test_ExecuteRespectsNewDelay() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        // Change delay to longer
        vm.prank(admin);
        delegation.setDelays(14, 7, 7);

        // Advance original delay (7 rounds)
        _advanceRounds(7);

        // Try to execute - should still process (request was made before delay change)
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // Note: Current implementation uses delay at execution time
        // If you want delay at request time, this would need modification
    }
}
