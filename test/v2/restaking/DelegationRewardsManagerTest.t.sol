// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DelegationTestHarness, MultiAssetDelegation, Types } from "./DelegationTestHarness.sol";
import { IRewardsManager } from "../../../src/v2/interfaces/IRewardsManager.sol";

contract MockRewardsManager is IRewardsManager {
    struct DelegateCall {
        address delegator;
        address operator;
        address asset;
        uint256 amount;
        uint16 lockMultiplierBps;
    }

    DelegateCall[] public delegateCalls;

    function recordDelegate(
        address delegator,
        address operator,
        address asset,
        uint256 amount,
        uint16 lockMultiplierBps
    ) external override {
        delegateCalls.push(DelegateCall(delegator, operator, asset, amount, lockMultiplierBps));
    }

    function recordUndelegate(
        address,
        address,
        address,
        uint256
    ) external pure override {}

    function recordServiceReward(
        address,
        address,
        uint256
    ) external pure override {}

    function getAssetDepositCapRemaining(address) external pure override returns (uint256) {
        return type(uint256).max;
    }

    function getAssetIncentiveCap(address) external pure override returns (uint256) {
        return type(uint256).max;
    }

    function lastDelegateCall() external view returns (DelegateCall memory) {
        return delegateCalls[delegateCalls.length - 1];
    }
}

contract DelegationRewardsManagerTest is DelegationTestHarness {
  MockRewardsManager internal rewardsManager;
  uint16 internal constant BASE_BPS = 10000;

  function setUp() public override {
    super.setUp();
    rewardsManager = new MockRewardsManager();
    vm.prank(admin);
        delegation.setRewardsManager(address(rewardsManager));
    }

    function test_LockMultiplierForwarded() public {
        // Deposit 10 ETH with the longest lock (1.6x)
        _depositNativeWithLock(delegator1, 10 ether, Types.LockMultiplier.SixMonths);

        vm.prank(delegator1);
        delegation.delegate(operator1, 6 ether);

        MockRewardsManager.DelegateCall memory first = rewardsManager.lastDelegateCall();
        assertEq(first.lockMultiplierBps, delegation.MULTIPLIER_SIX_MONTHS());

        // Add 5 ETH without lock and delegate it – only 4 ETH still locked
        _depositNative(delegator1, 5 ether);
        vm.prank(delegator1);
        delegation.delegate(operator1, 5 ether);

        MockRewardsManager.DelegateCall memory second = rewardsManager.lastDelegateCall();
        uint16 sixMonth = delegation.MULTIPLIER_SIX_MONTHS();
        uint16 none = delegation.MULTIPLIER_NONE();
        uint16 expected = uint16((4 * uint256(sixMonth) + uint256(none)) / 5);
        assertEq(second.lockMultiplierBps, expected);

        // Fast-forward past the lock expiry and delegate again – multiplier returns to base
        vm.roll(block.number + delegation.LOCK_SIX_MONTHS() + 1);
        vm.prank(delegator1);
        delegation.delegate(operator1, 1 ether);

        MockRewardsManager.DelegateCall memory third = rewardsManager.lastDelegateCall();
    assertEq(third.lockMultiplierBps, delegation.MULTIPLIER_NONE());
  }

  function _assertLastLockBps(uint16 expected) internal view {
    MockRewardsManager.DelegateCall memory call = rewardsManager.lastDelegateCall();
    assertEq(call.lockMultiplierBps, expected);
  }

  function _weighted(uint256 lockedAmount, uint16 lockedBps, uint256 totalAmount, uint16 baseBps) internal pure returns (uint16) {
    if (totalAmount == 0) return baseBps;
    uint256 numerator = lockedAmount * uint256(lockedBps) + (totalAmount - lockedAmount) * uint256(baseBps);
    return uint16(numerator / totalAmount);
  }

  function test_LockMultiplierMultipleLockTiers() public {
    _depositNativeWithLock(delegator1, 3 ether, Types.LockMultiplier.OneMonth);
    _depositNativeWithLock(delegator1, 7 ether, Types.LockMultiplier.ThreeMonths);

    vm.prank(delegator1);
    delegation.delegate(operator1, 5 ether);
    uint16 avg = uint16(
      (
        3 * uint256(delegation.MULTIPLIER_ONE_MONTH()) +
        7 * uint256(delegation.MULTIPLIER_THREE_MONTHS())
      ) / 10
    );
    _assertLastLockBps(avg);

    _depositNative(delegator1, 6 ether);
    vm.prank(delegator1);
    delegation.delegate(operator1, 6 ether);
    uint16 expectedSecond = _weighted(5, avg, 6, delegation.MULTIPLIER_NONE());
    _assertLastLockBps(expectedSecond);
  }

  function test_LockMultiplierExhaustedAndRefreshed() public {
    _depositNativeWithLock(delegator1, 2 ether, Types.LockMultiplier.OneMonth);
    vm.prank(delegator1);
    delegation.delegate(operator1, 2 ether);
    _assertLastLockBps(delegation.MULTIPLIER_ONE_MONTH());

    _depositNative(delegator1, 1 ether);
    vm.prank(delegator1);
    delegation.delegate(operator1, 1 ether);
    _assertLastLockBps(delegation.MULTIPLIER_NONE());

    _depositNativeWithLock(delegator1, 4 ether, Types.LockMultiplier.ThreeMonths);
    vm.prank(delegator1);
    delegation.delegate(operator1, 3 ether);

    uint16 weightedBps = uint16(
      (
        (2 * uint256(delegation.MULTIPLIER_ONE_MONTH())) +
        (4 * uint256(delegation.MULTIPLIER_THREE_MONTHS()))
      ) / 6
    );
    uint16 expected = _weighted(3, weightedBps, 3, delegation.MULTIPLIER_NONE());
    _assertLastLockBps(expected);
  }
}
