// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../../src/v2/restaking/MultiAssetDelegation.sol";
import { DelegationErrors } from "../../../src/v2/restaking/DelegationErrors.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { RestakingOperatorsFacet } from "../../../src/v2/facets/restaking/RestakingOperatorsFacet.sol";
import { RestakingDepositsFacet } from "../../../src/v2/facets/restaking/RestakingDepositsFacet.sol";
import { RestakingDelegationsFacet } from "../../../src/v2/facets/restaking/RestakingDelegationsFacet.sol";
import { RestakingSlashingFacet } from "../../../src/v2/facets/restaking/RestakingSlashingFacet.sol";
import { RestakingAssetsFacet } from "../../../src/v2/facets/restaking/RestakingAssetsFacet.sol";
import { RestakingViewsFacet } from "../../../src/v2/facets/restaking/RestakingViewsFacet.sol";
import { RestakingAdminFacet } from "../../../src/v2/facets/restaking/RestakingAdminFacet.sol";

/// @notice Mock ERC20 for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock", "MCK") {}
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @notice Malicious ERC20 that reenters on transfer
contract ReentrantToken is ERC20 {
    IMultiAssetDelegation public target;
    bool public attacking;

    constructor() ERC20("Evil", "EVIL") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setTarget(address _target) external {
        target = IMultiAssetDelegation(payable(_target));
    }

    function _update(address from, address to, uint256 amount) internal override {
        super._update(from, to, amount);

        // Try to reenter on transfer out
        if (attacking && from == address(target) && to != address(0)) {
            attacking = false;
            // Try to withdraw again
            try target.executeWithdraw() {} catch {}
        }
    }

    function setAttacking(bool _attacking) external {
        attacking = _attacking;
    }
}

/// @title DelegationEdgeCasesTest
/// @notice Edge cases, security, and worst-case scenario tests
contract DelegationEdgeCasesTest is Test {
    IMultiAssetDelegation public delegation;
    MockToken public token;

    address public admin = makeAddr("admin");
    address public slasher = makeAddr("slasher");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public delegator1 = makeAddr("delegator1");
    address public delegator2 = makeAddr("delegator2");
    address public delegator3 = makeAddr("delegator3");

    uint256 constant MIN_OPERATOR_STAKE = 1 ether;
    uint64 constant DELAY = 28; // Match ProtocolConfig.DELEGATOR_DELAY_ROUNDS

    /// @notice Helper to advance rounds with proper time warping
    function _advanceRounds(uint64 count) internal {
        uint256 roundDuration = delegation.roundDuration();
        uint256 startTime = block.timestamp;
        for (uint64 i = 0; i < count; i++) {
            vm.warp(startTime + (i + 1) * roundDuration);
            delegation.advanceRound();
        }
    }

    function setUp() public {
        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, MIN_OPERATOR_STAKE, 0, 1000)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        delegation = IMultiAssetDelegation(payable(address(proxy)));

        _registerFacets(address(proxy));

        token = new MockToken();
        vm.prank(admin);
        delegation.enableAsset(address(token), 1 ether, 0.1 ether, 0, 10000);

        vm.prank(admin);
        delegation.addSlasher(slasher);

        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(delegator1, 100 ether);
        vm.deal(delegator2, 100 ether);
        vm.deal(delegator3, 100 ether);
        token.mint(delegator1, 100 ether);

        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();
    }

    function _registerFacets(address proxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(proxy));
        vm.startPrank(admin);
        router.registerFacet(address(new RestakingOperatorsFacet()));
        router.registerFacet(address(new RestakingDepositsFacet()));
        router.registerFacet(address(new RestakingDelegationsFacet()));
        router.registerFacet(address(new RestakingSlashingFacet()));
        router.registerFacet(address(new RestakingAssetsFacet()));
        router.registerFacet(address(new RestakingViewsFacet()));
        router.registerFacet(address(new RestakingAdminFacet()));
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING INTERACTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_UnstakeAfterSlashing_ReceivesReducedAmount() public {
        // Delegate 10 ETH
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // Slash 50% of operator's total stake (operator: 10 ETH, delegator: 10 ETH = 20 ETH total)
        // Slashing 10 ETH = 5 ETH from operator, 5 ETH from delegator
        vm.prank(slasher);
        delegation.slash(operator1, 0, 10 ether, keccak256("evidence"));

        // Delegator's share should be worth less now
        uint256 delegationAfterSlash = delegation.getDelegation(delegator1, operator1);
        assertLt(delegationAfterSlash, 10 ether, "Delegation value should be reduced");

        // Schedule unstake for all remaining
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), delegationAfterSlash);

        // Advance and execute
        _advanceRounds(DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // Should have 0 delegation left
        assertEq(delegation.getDelegation(delegator1, operator1), 0);
    }

    function test_CannotUnstakeMoreThanPostSlashValue() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // Slash 50%
        vm.prank(slasher);
        delegation.slash(operator1, 0, 10 ether, keccak256("evidence"));

        // Try to unstake original amount (should fail)
        vm.prank(delegator1);
        vm.expectRevert(); // Should revert - insufficient delegation
        delegation.scheduleDelegatorUnstake(operator1, address(0), 10 ether);
    }

    function test_SlashDuringPendingUnstake() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // Schedule unstake
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        // Slash during delay period
        vm.prank(slasher);
        delegation.slash(operator1, 0, 10 ether, keccak256("evidence"));

        // Advance and execute
        _advanceRounds(DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // Delegation should be reduced by slash
        uint256 remaining = delegation.getDelegation(delegator1, operator1);
        assertLt(remaining, 5 ether, "Remaining should be less due to slash");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR LIFECYCLE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DelegateToInactiveOperator_Reverts() public {
        vm.prank(operator2);
        delegation.registerOperator{ value: 10 ether }();

        // Slash operator below minimum to make inactive
        vm.prank(slasher);
        delegation.slash(operator2, 0, 10 ether, keccak256("evidence"));

        // Try to delegate to now-inactive operator
        vm.prank(delegator1);
        delegation.deposit{ value: 5 ether }();

        vm.prank(delegator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.OperatorNotActive.selector, operator2)
        );
        delegation.delegate(operator2, 5 ether);
    }

    function test_CanUnstakeFromInactiveOperator() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // Slash operator to make inactive
        vm.prank(slasher);
        delegation.slash(operator1, 0, 15 ether, keccak256("evidence"));

        // Should still be able to unstake
        uint256 remaining = delegation.getDelegation(delegator1, operator1);
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), remaining);

        _advanceRounds(DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 0);
    }

    function test_OperatorLeavingWhileDelegated() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);

        // Operator starts leaving
        vm.prank(operator1);
        delegation.startLeaving();

        // Delegator should still be able to unstake
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 10 ether);

        _advanceRounds(DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BOUNDARY CONDITION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExecuteAtExactDelayBoundary() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        uint64 requestRound = uint64(delegation.currentRound());

        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        // Advance exactly DELAY - 1 rounds (should NOT be executable)
        _advanceRounds(DELAY - 1);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();
        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether, "Should not execute before delay");

        // Advance one more (now at exactly requestRound + DELAY)
        _advanceRounds(1);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();
        assertEq(delegation.getDelegation(delegator1, operator1), 0, "Should execute at exact delay");
    }

    function test_DustAmounts() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 1 wei }(operator1);

        assertEq(delegation.getDelegation(delegator1, operator1), 1 wei);

        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 1 wei);

        _advanceRounds(DELAY);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 0);
    }

    function test_LargeAmounts() public {
        uint256 largeAmount = 1000000 ether;
        vm.deal(delegator1, largeAmount + 1 ether);

        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: largeAmount }(operator1);

        assertEq(delegation.getDelegation(delegator1, operator1), largeAmount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-ASSET TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DelegateNativeAndERC20ToSameOperator() public {
        vm.startPrank(delegator1);

        // Delegate native
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        // Delegate ERC20
        token.approve(address(delegation), 5 ether);
        delegation.depositAndDelegateWithOptions(
            operator1,
            address(token),
            5 ether,
            Types.BlueprintSelectionMode.All,
            new uint64[](0)
        );

        vm.stopPrank();

        // Both should show correctly
        // Note: getDelegation sums across assets for the operator
        assertGe(delegation.getTotalDelegation(delegator1), 10 ether);
    }

    function test_UnstakeWrongAssetType_Reverts() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        // Try to unstake as ERC20 when delegated native
        vm.prank(delegator1);
        vm.expectRevert(); // Should fail - no ERC20 delegation
        delegation.scheduleDelegatorUnstake(operator1, address(token), 5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONCURRENT USERS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultipleDelegatorsUnstakingSimultaneously() public {
        // Three delegators
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);
        vm.prank(delegator2);
        delegation.depositAndDelegate{ value: 20 ether }(operator1);
        vm.prank(delegator3);
        delegation.depositAndDelegate{ value: 30 ether }(operator1);

        // All schedule unstake in same round
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);
        vm.prank(delegator2);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 10 ether);
        vm.prank(delegator3);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 15 ether);

        _advanceRounds(DELAY);

        // All execute
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();
        vm.prank(delegator2);
        delegation.executeDelegatorUnstake();
        vm.prank(delegator3);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether);
        assertEq(delegation.getDelegation(delegator2, operator1), 10 ether);
        assertEq(delegation.getDelegation(delegator3, operator1), 15 ether);
    }

    function test_SlashWhileMultiplePendingUnstakes() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 10 ether }(operator1);
        vm.prank(delegator2);
        delegation.depositAndDelegate{ value: 20 ether }(operator1);

        // Both schedule unstake
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);
        vm.prank(delegator2);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 10 ether);

        // Slash during pending
        vm.prank(slasher);
        delegation.slash(operator1, 0, 20 ether, keccak256("evidence"));

        _advanceRounds(DELAY);

        // Both should be able to execute (with reduced amounts)
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();
        vm.prank(delegator2);
        delegation.executeDelegatorUnstake();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAUSED STATE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CannotDepositWhenPaused() public {
        vm.prank(admin);
        delegation.pause();

        vm.prank(delegator1);
        vm.expectRevert(); // EnforcedPause
        delegation.deposit{ value: 5 ether }();
    }

    function test_CannotDelegateWhenPaused() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 5 ether }();

        vm.prank(admin);
        delegation.pause();

        vm.prank(delegator1);
        vm.expectRevert(); // EnforcedPause
        delegation.delegate(operator1, 5 ether);
    }

    function test_CanExecuteUnstakeWhenPaused() public {
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 5 ether }(operator1);

        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        _advanceRounds(DELAY);

        vm.prank(admin);
        delegation.pause();

        // Should still be able to execute (withdrawal is not pausable for safety)
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();
    }

    function test_CanExecuteWithdrawWhenPaused() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 5 ether }();

        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 5 ether);

        _advanceRounds(DELAY);

        vm.prank(admin);
        delegation.pause();

        // Should still be able to execute
        vm.prank(delegator1);
        delegation.executeWithdraw();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ACCESS CONTROL TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_NonAdminCannotChangeDelays() public {
        vm.prank(delegator1);
        vm.expectRevert(); // AccessControl revert
        delegation.setDelays(14, 14, 14);
    }

    function test_NonAdminCannotPause() public {
        vm.prank(delegator1);
        vm.expectRevert();
        delegation.pause();
    }

    function test_NonSlasherCannotSlash() public {
        vm.prank(delegator1);
        vm.expectRevert();
        delegation.slash(operator1, 0, 1 ether, keccak256("evidence"));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REENTRANCY TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ReentrantERC20_CannotDoubleWithdraw() public {
        ReentrantToken evilToken = new ReentrantToken();
        evilToken.setTarget(address(delegation));

        vm.prank(admin);
        delegation.enableAsset(address(evilToken), 0, 0, 0, 10000);

        evilToken.mint(delegator1, 10 ether);

        vm.startPrank(delegator1);
        evilToken.approve(address(delegation), 10 ether);
        delegation.depositERC20(address(evilToken), 10 ether);
        delegation.scheduleWithdraw(address(evilToken), 10 ether);
        vm.stopPrank();

        _advanceRounds(DELAY);

        // Enable attack
        evilToken.setAttacking(true);

        // Execute - reentrancy should be blocked
        vm.prank(delegator1);
        delegation.executeWithdraw();

        // Should only have received once
        assertEq(evilToken.balanceOf(delegator1), 10 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT SELECTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DelegateWithFixedBlueprints() public {
        uint64[] memory blueprints = new uint64[](2);
        blueprints[0] = 1;
        blueprints[1] = 2;

        vm.startPrank(delegator1);
        delegation.deposit{ value: 5 ether }();
        delegation.delegateWithOptions(
            operator1,
            address(0),
            5 ether,
            Types.BlueprintSelectionMode.Fixed,
            blueprints
        );
        vm.stopPrank();

        Types.BondInfoDelegator[] memory delegations = delegation.getDelegations(delegator1);
        assertEq(uint8(delegations[0].selectionMode), uint8(Types.BlueprintSelectionMode.Fixed));

        uint64[] memory storedBps = delegation.getDelegationBlueprints(delegator1, 0);
        assertEq(storedBps.length, 2);
        assertEq(storedBps[0], 1);
        assertEq(storedBps[1], 2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE CONSISTENCY TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_TotalDelegationMatchesSum() public {
        vm.prank(operator2);
        delegation.registerOperator{ value: 10 ether }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 20 ether }();
        delegation.delegate(operator1, 7 ether);
        delegation.delegate(operator2, 5 ether);
        vm.stopPrank();

        uint256 total = delegation.getTotalDelegation(delegator1);
        uint256 sum = delegation.getDelegation(delegator1, operator1) +
                      delegation.getDelegation(delegator1, operator2);

        assertEq(total, sum, "Total should match sum of individual delegations");
        assertEq(total, 12 ether, "Total should be 12 ether");
    }

    function test_DepositTrackingConsistency() public {
        vm.startPrank(delegator1);
        delegation.deposit{ value: 10 ether }();
        delegation.delegate(operator1, 6 ether);
        vm.stopPrank();

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 10 ether, "Total deposit");
        assertEq(dep.delegatedAmount, 6 ether, "Delegated amount");

        // Available should be 4 ether
        uint256 available = dep.amount - dep.delegatedAmount;
        assertEq(available, 4 ether, "Available should be 4 ether");

        // Can delegate remaining
        vm.prank(delegator1);
        delegation.delegate(operator1, 4 ether);

        dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.delegatedAmount, 10 ether, "All should be delegated now");
    }
}
