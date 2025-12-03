// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BeaconTestBase} from "./BeaconTestBase.sol";
import {ValidatorPod} from "../../../src/v2/beacon/ValidatorPod.sol";
import {ValidatorPodManager} from "../../../src/v2/beacon/ValidatorPodManager.sol";
import {ValidatorTypes} from "../../../src/v2/beacon/ValidatorTypes.sol";
import {console2} from "forge-std/Test.sol";

/// @title ValidatorPodManagerTest
/// @notice Tests for ValidatorPodManager contract
/// @dev Tests pod factory, shares management, operators, delegation, and slashing
contract ValidatorPodManagerTest is BeaconTestBase {
    // ═══════════════════════════════════════════════════════════════════════════
    // POD FACTORY TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_createPod_Success() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        assertTrue(podAddr != address(0), "Pod should be created");
        assertEq(podManager.ownerToPod(podOwner1), podAddr, "Owner to pod mapping should be set");
        assertEq(podManager.podToOwner(podAddr), podOwner1, "Pod to owner mapping should be set");
        assertEq(podManager.podCount(), 1, "Pod count should be 1");
    }

    function test_createPod_AlreadyExists() public {
        vm.prank(podOwner1);
        podManager.createPod();

        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.PodAlreadyExists.selector);
        podManager.createPod();
    }

    function test_getOrCreatePod_CreatesNew() public {
        vm.prank(podOwner1);
        address podAddr = podManager.getOrCreatePod();

        assertTrue(podAddr != address(0), "Pod should be created");
        assertEq(podManager.podCount(), 1, "Pod count should be 1");
    }

    function test_getOrCreatePod_ReturnsExisting() public {
        vm.prank(podOwner1);
        address pod1 = podManager.createPod();

        vm.prank(podOwner1);
        address pod2 = podManager.getOrCreatePod();

        assertEq(pod1, pod2, "Should return existing pod");
        assertEq(podManager.podCount(), 1, "Pod count should still be 1");
    }

    function test_getPod_Exists() public {
        vm.prank(podOwner1);
        address expected = podManager.createPod();

        address actual = podManager.getPod(podOwner1);
        assertEq(actual, expected, "Should return correct pod");
    }

    function test_getPod_NotExists() public view {
        address pod = podManager.getPod(podOwner1);
        assertEq(pod, address(0), "Should return zero address for non-existent pod");
    }

    function test_hasPod_True() public {
        vm.prank(podOwner1);
        podManager.createPod();

        assertTrue(podManager.hasPod(podOwner1), "Should return true for existing pod");
    }

    function test_hasPod_False() public view {
        assertFalse(podManager.hasPod(podOwner1), "Should return false for non-existent pod");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_registerOperator_Success() public {
        vm.prank(operator1);
        podManager.registerOperator{value: MIN_OPERATOR_STAKE}();

        assertTrue(podManager.isOperator(operator1), "Should be registered as operator");
        assertTrue(podManager.isOperatorActive(operator1), "Should be active operator");
        assertEq(podManager.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE, "Self stake should be recorded");
    }

    function test_registerOperator_InsufficientStake() public {
        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.InsufficientStake.selector);
        podManager.registerOperator{value: MIN_OPERATOR_STAKE - 1}();
    }

    function test_registerOperator_AlreadyOperator() public {
        vm.prank(operator1);
        podManager.registerOperator{value: MIN_OPERATOR_STAKE}();

        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.AlreadyOperator.selector);
        podManager.registerOperator{value: MIN_OPERATOR_STAKE}();
    }

    function test_increaseOperatorStake_Success() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(operator1);
        podManager.increaseOperatorStake{value: 1 ether}();

        assertEq(
            podManager.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE + 1 ether, "Stake should be increased"
        );
    }

    function test_increaseOperatorStake_NotOperator() public {
        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.NotOperator.selector);
        podManager.increaseOperatorStake{value: 1 ether}();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_delegateTo_NotOperator() public {
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.NotOperator.selector);
        podManager.delegateTo(operator1, 1 ether);
    }

    function test_delegateTo_ZeroAmount() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.ZeroAmount.selector);
        podManager.delegateTo(operator1, 0);
    }

    function test_delegateTo_InsufficientShares() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // podOwner1 has no shares
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.InsufficientShares.selector);
        podManager.delegateTo(operator1, 1 ether);
    }

    function test_undelegateFrom_InsufficientDelegation() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // No delegation exists
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.InsufficientShares.selector);
        podManager.undelegateFrom(operator1, 1 ether);
    }

    function test_getDelegation() public view {
        uint256 delegation = podManager.getDelegation(podOwner1, operator1);
        assertEq(delegation, 0, "Initial delegation should be zero");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_slash_NotAuthorized() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(attacker);
        vm.expectRevert(ValidatorPodManager.NotAuthorizedSlasher.selector);
        podManager.slash(operator1, 1, 0.5 ether, bytes32(0));
    }

    function test_slash_Success() public {
        _registerOperator(operator1, 2 ether);

        uint256 stakeBefore = podManager.getOperatorSelfStake(operator1);

        vm.prank(slasher);
        uint256 slashed = podManager.slash(operator1, 1, 0.5 ether, keccak256("evidence"));

        assertEq(slashed, 0.5 ether, "Should slash requested amount");
        assertEq(podManager.getOperatorSelfStake(operator1), stakeBefore - 0.5 ether, "Stake should be reduced");
    }

    function test_slash_ExceedsStake() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(slasher);
        uint256 slashed = podManager.slash(operator1, 1, 10 ether, keccak256("evidence"));

        assertEq(slashed, MIN_OPERATOR_STAKE, "Should slash only available stake");
        assertEq(podManager.getOperatorSelfStake(operator1), 0, "Stake should be zero");
    }

    function test_slashForBlueprint_Success() public {
        _registerOperator(operator1, 2 ether);

        vm.prank(slasher);
        uint256 slashed = podManager.slashForBlueprint(operator1, 1, 1, 0.5 ether, keccak256("evidence"));

        assertEq(slashed, 0.5 ether, "Should slash requested amount");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHER MANAGEMENT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_addSlasher_Success() public {
        address newSlasher = makeAddr("newSlasher");

        vm.prank(admin);
        podManager.addSlasher(newSlasher);

        assertTrue(podManager.isSlasher(newSlasher), "New slasher should be authorized");
    }

    function test_addSlasher_NotOwner() public {
        vm.prank(attacker);
        vm.expectRevert();
        podManager.addSlasher(attacker);
    }

    function test_removeSlasher_Success() public {
        vm.prank(admin);
        podManager.removeSlasher(slasher);

        assertFalse(podManager.isSlasher(slasher), "Slasher should be removed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_setMinOperatorStake() public {
        uint256 newMin = 5 ether;

        vm.prank(admin);
        podManager.setMinOperatorStake(newMin);

        assertEq(podManager.minOperatorStake(), newMin, "Min stake should be updated");
    }

    function test_setMinOperatorStake_NotOwner() public {
        vm.prank(attacker);
        vm.expectRevert();
        podManager.setMinOperatorStake(5 ether);
    }

    function test_setBeaconOracle_Success() public {
        address newOracle = makeAddr("newOracle");

        vm.prank(admin);
        podManager.setBeaconOracle(newOracle);

        assertEq(address(podManager.beaconOracle()), newOracle, "Oracle should be updated");
    }

    function test_setBeaconOracle_ZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(ValidatorPodManager.ZeroAddress.selector);
        podManager.setBeaconOracle(address(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // IRESTAKING INTERFACE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_isOperator() public {
        assertFalse(podManager.isOperator(operator1), "Should not be operator initially");

        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        assertTrue(podManager.isOperator(operator1), "Should be operator after registration");
    }

    function test_isOperatorActive() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        assertTrue(podManager.isOperatorActive(operator1), "Should be active with min stake");

        // Slash below minimum
        vm.prank(slasher);
        podManager.slash(operator1, 1, MIN_OPERATOR_STAKE, keccak256("evidence"));

        assertFalse(podManager.isOperatorActive(operator1), "Should be inactive after slash below min");
    }

    function test_getOperatorStake() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // Total stake = self stake + delegated (no delegations yet)
        assertEq(podManager.getOperatorStake(operator1), MIN_OPERATOR_STAKE, "Total stake should equal self stake");
    }

    function test_getOperatorDelegatedStake() public view {
        assertEq(podManager.getOperatorDelegatedStake(operator1), 0, "Initial delegated stake should be zero");
    }

    function test_meetsStakeRequirement() public {
        _registerOperator(operator1, 5 ether);

        assertTrue(podManager.meetsStakeRequirement(operator1, 4 ether), "Should meet lower requirement");
        assertTrue(podManager.meetsStakeRequirement(operator1, 5 ether), "Should meet exact requirement");
        assertFalse(podManager.meetsStakeRequirement(operator1, 6 ether), "Should not meet higher requirement");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE MANAGEMENT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_getShares_Initial() public view {
        assertEq(podManager.getShares(podOwner1), 0, "Initial shares should be zero");
    }

    function test_recordBeaconChainETHBalanceUpdate_OnlyPod() public {
        vm.prank(podOwner1);
        podManager.createPod();

        // Non-pod caller should fail
        vm.prank(attacker);
        vm.expectRevert(ValidatorPodManager.OnlyPod.selector);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 1 ether);
    }

    function test_recordBeaconChainETHBalanceUpdate_Success() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        // Pod calls to record balance update
        vm.prank(podAddr);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);

        assertEq(podManager.getShares(podOwner1), 32 ether, "Shares should be updated");
        assertEq(podManager.totalShares(), 32 ether, "Total shares should be updated");
    }

    function test_recordBeaconChainETHBalanceUpdate_NegativeDelta() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        // Initial positive update
        vm.prank(podAddr);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);

        // Negative delta (slashing)
        vm.prank(podAddr);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, -5 ether);

        assertEq(podManager.getShares(podOwner1), 27 ether, "Shares should be reduced");
        assertEq(podManager.totalShares(), 27 ether, "Total shares should be reduced");
    }

    function test_recordBeaconChainETHBalanceUpdate_MultiplePods() public {
        // Create two pods
        vm.prank(podOwner1);
        address pod1 = podManager.createPod();

        vm.prank(podOwner2);
        address pod2 = podManager.createPod();

        // Record updates for both
        vm.prank(pod1);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);

        vm.prank(pod2);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner2, 64 ether);

        assertEq(podManager.getShares(podOwner1), 32 ether, "Pod1 shares correct");
        assertEq(podManager.getShares(podOwner2), 64 ether, "Pod2 shares correct");
        assertEq(podManager.totalShares(), 96 ether, "Total shares correct");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_constructor_ZeroBeaconOracle() public {
        vm.expectRevert(ValidatorPodManager.ZeroAddress.selector);
        new ValidatorPodManager(address(0), MIN_OPERATOR_STAKE);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD NOTIFICATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_notifyReward_NoOp() public {
        // These are placeholder functions that should not revert
        podManager.notifyReward(operator1, 1, 1 ether);
        podManager.notifyRewardForBlueprint(operator1, 1, 1, 1 ether);
        // If we got here without reverting, the test passes
    }
}
