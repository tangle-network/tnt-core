// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";
import { ValidatorPodManager } from "../../src/beacon/ValidatorPodManager.sol";
import { ValidatorTypes } from "../../src/beacon/ValidatorTypes.sol";
import { console2 } from "forge-std/Test.sol";

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
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertTrue(podManager.isOperator(operator1), "Should be registered as operator");
        assertTrue(podManager.isOperatorActive(operator1), "Should be active operator");
        assertEq(podManager.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE, "Self stake should be recorded");
    }

    function test_registerOperator_InsufficientStake() public {
        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.InsufficientStake.selector);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE - 1 }();
    }

    function test_registerOperator_AlreadyOperator() public {
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.AlreadyOperator.selector);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();
    }

    function test_increaseOperatorStake_Success() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(operator1);
        podManager.increaseOperatorStake{ value: 1 ether }();

        assertEq(podManager.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE + 1 ether, "Stake should be increased");
    }

    function test_increaseOperatorStake_NotOperator() public {
        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.NotOperator.selector);
        podManager.increaseOperatorStake{ value: 1 ether }();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR DEREGISTRATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_deregisterOperator_Success() public {
        // Register operator with stake
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        uint256 balanceBefore = operator1.balance;

        // Deregister
        vm.prank(operator1);
        podManager.deregisterOperator();

        // Verify operator status cleared
        assertFalse(podManager.isOperator(operator1), "Should no longer be operator");
        assertFalse(podManager.isOperatorActive(operator1), "Should not be active");
        assertEq(podManager.getOperatorSelfStake(operator1), 0, "Self stake should be zero");

        // Verify stake returned
        assertEq(operator1.balance, balanceBefore + MIN_OPERATOR_STAKE, "Stake should be returned");
    }

    function test_deregisterOperator_EmitsEvent() public {
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        vm.expectEmit(true, false, false, false);
        emit ValidatorPodManager.OperatorDeregistered(operator1);
        podManager.deregisterOperator();
    }

    function test_deregisterOperator_NotOperator() public {
        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.NotOperator.selector);
        podManager.deregisterOperator();
    }

    function test_deregisterOperator_HasPendingDelegations() public {
        // Setup: Register operator and create pod with shares
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Create pod and add shares for podOwner1
        vm.prank(podOwner1);
        address pod = podManager.createPod();

        // Simulate shares being added (via beacon chain proof in real scenario)
        // We need to call recordBeaconChainDeposit / recordBeaconChainRebase from the pod
        vm.prank(pod);
        podManager.recordBeaconChainDeposit(podOwner1, 10 ether);

        // Delegate to operator
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 5 ether);

        // Attempt to deregister should fail
        vm.prank(operator1);
        vm.expectRevert(ValidatorPodManager.HasPendingDelegations.selector);
        podManager.deregisterOperator();
    }

    function test_deregisterOperator_AfterDelegatorsUndelegate() public {
        // Setup: Register operator
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Create pod and add shares
        vm.prank(podOwner1);
        address pod = podManager.createPod();

        vm.prank(pod);
        podManager.recordBeaconChainDeposit(podOwner1, 10 ether);

        // Delegate then undelegate (queue-based)
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 5 ether);

        vm.prank(podOwner1);
        bytes32 undelegationRoot = podManager.queueUndelegation(operator1, 5 ether);

        // Move past delay period
        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        vm.prank(podOwner1);
        podManager.completeUndelegation(undelegationRoot);

        // Now deregister should succeed
        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        podManager.deregisterOperator();

        assertFalse(podManager.isOperator(operator1), "Should no longer be operator");
        assertEq(operator1.balance, balanceBefore + MIN_OPERATOR_STAKE, "Stake should be returned");
    }

    function test_deregisterOperator_ZeroStake() public {
        // Register with minimum stake
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Get slashed to zero (need to setup slasher)
        vm.prank(admin);
        podManager.addSlasher(admin);

        vm.prank(admin);
        podManager.slash(operator1, 1, 10_000, bytes32(0));

        // Stake should be zero now
        assertEq(podManager.getOperatorSelfStake(operator1), 0, "Stake should be zero after slash");

        // Deregister should still work (no ETH to return)
        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        podManager.deregisterOperator();

        assertFalse(podManager.isOperator(operator1), "Should no longer be operator");
        assertEq(operator1.balance, balanceBefore, "Balance unchanged (no stake to return)");
    }

    function test_deregisterOperator_CanReregister() public {
        // Register
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Deregister
        vm.prank(operator1);
        podManager.deregisterOperator();

        // Re-register should work
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertTrue(podManager.isOperator(operator1), "Should be operator again");
        assertEq(podManager.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE, "Stake should be set");
    }

    function test_deregisterOperator_WithIncreasedStake() public {
        // Register with minimum
        vm.prank(operator1);
        podManager.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Increase stake
        vm.prank(operator1);
        podManager.increaseOperatorStake{ value: 5 ether }();

        uint256 totalStake = MIN_OPERATOR_STAKE + 5 ether;
        assertEq(podManager.getOperatorSelfStake(operator1), totalStake, "Total stake should be sum");

        // Deregister and verify full stake returned
        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        podManager.deregisterOperator();

        assertEq(operator1.balance, balanceBefore + totalStake, "Full stake should be returned");
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

    function test_queueUndelegation_InsufficientDelegation() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // No delegation exists
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.InsufficientShares.selector);
        podManager.queueUndelegation(operator1, 1 ether);
    }

    function test_queueUndelegation_Success() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        _createPodWithShares(podOwner1, 10 ether);

        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 5 ether);

        vm.prank(podOwner1);
        bytes32 undelegationRoot = podManager.queueUndelegation(operator1, 3 ether);

        // Check queued state
        (
            address delegator,
            address operator,
            uint256 amount,
            uint32 startBlock,
            uint32 completableBlock,
            bool completed
        ) = podManager.getUndelegationInfo(undelegationRoot);

        assertEq(delegator, podOwner1, "Delegator mismatch");
        assertEq(operator, operator1, "Operator mismatch");
        assertEq(amount, 3 ether, "Amount mismatch");
        assertEq(startBlock, block.number, "Start block mismatch");
        assertFalse(completed, "Should not be completed");

        // Delegation should still be active until completed
        assertEq(podManager.getDelegation(podOwner1, operator1), 5 ether, "Delegation should remain");
        assertEq(podManager.getOperatorDelegatedStake(operator1), 5 ether, "Operator delegated stake should remain");
    }

    function test_completeUndelegation_BeforeDelay() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        _createPodWithShares(podOwner1, 10 ether);

        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 5 ether);

        vm.prank(podOwner1);
        bytes32 undelegationRoot = podManager.queueUndelegation(operator1, 3 ether);

        // Try to complete before delay
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.UndelegationNotReady.selector);
        podManager.completeUndelegation(undelegationRoot);
    }

    function test_completeUndelegation_Success() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        _createPodWithShares(podOwner1, 10 ether);

        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 5 ether);

        vm.prank(podOwner1);
        bytes32 undelegationRoot = podManager.queueUndelegation(operator1, 3 ether);

        // Move past delay
        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        vm.prank(podOwner1);
        podManager.completeUndelegation(undelegationRoot);

        // Check final state
        assertEq(podManager.getDelegation(podOwner1, operator1), 2 ether, "Delegation should decrease");
        assertEq(podManager.getOperatorDelegatedStake(operator1), 2 ether, "Operator delegated stake should decrease");
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 2 ether, "Total delegated should decrease");
    }

    function test_completeUndelegation_AlreadyCompleted() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        _createPodWithShares(podOwner1, 10 ether);

        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 5 ether);

        vm.prank(podOwner1);
        bytes32 undelegationRoot = podManager.queueUndelegation(operator1, 3 ether);

        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        vm.prank(podOwner1);
        podManager.completeUndelegation(undelegationRoot);

        // Try to complete again
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.UndelegationAlreadyCompleted.selector);
        podManager.completeUndelegation(undelegationRoot);
    }

    function test_getEffectiveDelegation() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        _createPodWithShares(podOwner1, 10 ether);

        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 5 ether);

        // Before queuing, effective = actual
        assertEq(podManager.getEffectiveDelegation(podOwner1, operator1), 5 ether, "Before queue");

        vm.prank(podOwner1);
        podManager.queueUndelegation(operator1, 2 ether);

        // After queuing, effective = actual - queued
        assertEq(podManager.getEffectiveDelegation(podOwner1, operator1), 3 ether, "After queue");
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
        podManager.slash(operator1, 1, 1000, bytes32(0));
    }

    function test_slash_Success() public {
        _registerOperator(operator1, 2 ether);

        uint256 stakeBefore = podManager.getOperatorSelfStake(operator1);
        uint16 slashBps = 2500;

        vm.prank(slasher);
        uint256 slashed = podManager.slash(operator1, 1, slashBps, keccak256("evidence"));

        uint256 expectedSlashed = (stakeBefore * slashBps) / 10_000;
        assertEq(slashed, expectedSlashed, "Should slash requested amount");
        assertEq(podManager.getOperatorSelfStake(operator1), stakeBefore - expectedSlashed, "Stake should be reduced");
    }

    function test_slash_ExceedsStake() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(slasher);
        uint256 slashed = podManager.slash(operator1, 1, 10_000, keccak256("evidence"));

        assertEq(slashed, MIN_OPERATOR_STAKE, "Should slash only available stake");
        assertEq(podManager.getOperatorSelfStake(operator1), 0, "Stake should be zero");
    }

    function test_slashForBlueprint_Success() public {
        _registerOperator(operator1, 2 ether);

        vm.prank(slasher);
        uint256 slashed = podManager.slashForBlueprint(operator1, 1, 1, 2500, keccak256("evidence"));

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
        podManager.slash(operator1, 1, 10_000, keccak256("evidence"));

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
        assertEq(podManager.getSharesUint(podOwner1), 0, "Initial shares should be zero");
    }

    function test_recordBeaconChainDeposit_OnlyPod() public {
        vm.prank(podOwner1);
        podManager.createPod();

        // Non-pod caller should fail
        vm.prank(attacker);
        vm.expectRevert(ValidatorPodManager.OnlyPod.selector);
        podManager.recordBeaconChainDeposit(podOwner1, 1 ether);
    }

    function test_recordBeaconChainDeposit_Success() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        // Pod calls to record balance update
        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        assertEq(podManager.getSharesUint(podOwner1), 32 ether, "Shares should be updated");
        assertEq(podManager.totalShares(), 32 ether, "Total shares should be updated");
    }

    /// @notice G-02: Share-pool semantics replace raw amount accounting.
    /// @dev Negative deltas (slashes) reduce `totalAssets` only. The owner's `shares`
    ///      balance is invariant on rebases.
    function test_recordBeaconChainRebase_NegativeDelta() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        // Initial positive update mints shares 1:1.
        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Negative delta (slashing) is a rebase-down: assets fall, shares unchanged.
        vm.prank(podAddr);
        podManager.recordBeaconChainRebase(podOwner1, -int256(5 ether));

        assertEq(podManager.getSharesUint(podOwner1), 32 ether, "Shares unchanged on rebase");
        assertEq(podManager.totalShares(), 32 ether, "Aggregate shares unchanged");
        assertEq(podManager.totalAssetsOf(podOwner1), 27 ether, "Pool assets reduced");
        // Asset-equivalent has tiny dust due to virtual offset (1e3 wei). Tolerate it.
        assertApproxEqAbs(podManager.getRestakedAssets(podOwner1), 27 ether, 1000, "Owner asset-equivalent reduced");
    }

    function test_recordBeaconChainDeposit_MultiplePods() public {
        // Create two pods
        vm.prank(podOwner1);
        address pod1 = podManager.createPod();

        vm.prank(podOwner2);
        address pod2 = podManager.createPod();

        // Record updates for both
        vm.prank(pod1);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        vm.prank(pod2);
        podManager.recordBeaconChainDeposit(podOwner2, 64 ether);

        assertEq(podManager.getSharesUint(podOwner1), 32 ether, "Pod1 shares correct");
        assertEq(podManager.getSharesUint(podOwner2), 64 ether, "Pod2 shares correct");
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
    // WITHDRAWAL QUEUE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_queueWithdrawal_Success() public {
        // Create pod and record shares
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Queue withdrawal
        vm.prank(podOwner1);
        bytes32 withdrawalRoot = podManager.queueWithdrawal(10 ether);

        assertTrue(withdrawalRoot != bytes32(0), "Withdrawal root should be generated");
        assertEq(podManager.queuedShares(podOwner1), 10 ether, "Queued shares should be tracked");

        // Check withdrawal info (G-02: tuple now includes asset snapshot).
        (address staker, uint256 shares, uint256 assets, uint32 startBlock, bool completed, bool canComplete) =
            podManager.getWithdrawalInfo(withdrawalRoot);

        assertEq(staker, podOwner1, "Staker should match");
        assertEq(shares, 10 ether, "Shares should match");
        assertEq(assets, 10 ether, "Asset snapshot should equal queued amount at 1:1 rate");
        assertEq(startBlock, block.number, "Start block should match");
        assertFalse(completed, "Should not be completed");
        assertFalse(canComplete, "Should not be able to complete yet");
    }

    function test_queueWithdrawal_ZeroAmount() public {
        vm.prank(podOwner1);
        podManager.createPod();

        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.ZeroAmount.selector);
        podManager.queueWithdrawal(0);
    }

    function test_queueWithdrawal_InsufficientShares() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        // Only have 10 ETH shares
        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 10 ether);

        // Try to queue more than available
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.InsufficientShares.selector);
        podManager.queueWithdrawal(20 ether);
    }

    function test_queueWithdrawal_HasPendingDelegations() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Delegate some shares
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 16 ether);

        // Try to queue withdrawal while delegated
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.HasPendingDelegations.selector);
        podManager.queueWithdrawal(10 ether);
    }

    function test_queueWithdrawal_MultipleQueued() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Queue multiple withdrawals
        vm.prank(podOwner1);
        bytes32 root1 = podManager.queueWithdrawal(10 ether);

        vm.prank(podOwner1);
        bytes32 root2 = podManager.queueWithdrawal(10 ether);

        assertTrue(root1 != root2, "Withdrawal roots should be unique");
        assertEq(podManager.queuedShares(podOwner1), 20 ether, "Total queued should be sum");

        // Should not be able to queue more than remaining
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.InsufficientShares.selector);
        podManager.queueWithdrawal(15 ether); // Only 12 ETH remaining
    }

    function test_completeWithdrawal_Success() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        // Fund the pod with actual ETH
        vm.deal(podAddr, 32 ether);

        // Queue withdrawal
        vm.prank(podOwner1);
        bytes32 withdrawalRoot = podManager.queueWithdrawal(10 ether);

        // Advance past delay
        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        // Check can complete (G-02: tuple now includes asset snapshot at index 2).
        (,,,,, bool canComplete) = podManager.getWithdrawalInfo(withdrawalRoot);
        assertTrue(canComplete, "Should be able to complete now");

        uint256 balanceBefore = podOwner1.balance;

        // Complete withdrawal
        vm.prank(podOwner1);
        podManager.completeWithdrawal(withdrawalRoot);

        // Verify completion (G-02: tuple now includes asset snapshot at index 2).
        (,,,, bool completed,) = podManager.getWithdrawalInfo(withdrawalRoot);
        assertTrue(completed, "Should be completed");

        assertEq(podOwner1.balance, balanceBefore + 10 ether, "ETH should be transferred");
        assertEq(podManager.queuedShares(podOwner1), 0, "Queued shares should be cleared");
        assertEq(podManager.getSharesUint(podOwner1), 22 ether, "Remaining shares should be reduced");
    }

    function test_completeWithdrawal_NotFound() public {
        bytes32 fakeRoot = keccak256("fake");

        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.WithdrawalNotFound.selector);
        podManager.completeWithdrawal(fakeRoot);
    }

    function test_completeWithdrawal_NotReady() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        vm.prank(podOwner1);
        bytes32 withdrawalRoot = podManager.queueWithdrawal(10 ether);

        // Try to complete before delay
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.WithdrawalNotReady.selector);
        podManager.completeWithdrawal(withdrawalRoot);
    }

    function test_completeWithdrawal_AlreadyCompleted() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 32 ether);

        vm.deal(podAddr, 32 ether);

        vm.prank(podOwner1);
        bytes32 withdrawalRoot = podManager.queueWithdrawal(10 ether);

        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);

        vm.prank(podOwner1);
        podManager.completeWithdrawal(withdrawalRoot);

        // Try to complete again
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.WithdrawalAlreadyCompleted.selector);
        podManager.completeWithdrawal(withdrawalRoot);
    }

    function test_getAvailableToWithdraw() public {
        vm.prank(podOwner1);
        address podAddr = podManager.createPod();

        vm.prank(podAddr);
        podManager.recordBeaconChainDeposit(podOwner1, 100 ether);

        assertEq(podManager.getAvailableToWithdraw(podOwner1), 100 ether, "Initially all available");

        // Queue some
        vm.prank(podOwner1);
        podManager.queueWithdrawal(30 ether);

        assertEq(podManager.getAvailableToWithdraw(podOwner1), 70 ether, "Reduced by queued");
    }

    function test_setWithdrawalDelay_Success() public {
        uint32 newDelay = 100_000;

        vm.prank(admin);
        podManager.setWithdrawalDelay(newDelay);

        assertEq(podManager.withdrawalDelayBlocks(), newDelay, "Delay should be updated");
    }

    function test_setWithdrawalDelay_ExceedsMax() public {
        // MAX_WITHDRAWAL_DELAY + 1 exceeds maximum allowed
        uint32 exceedsMax = uint32(podManager.MAX_WITHDRAWAL_DELAY() + 1);

        vm.prank(admin);
        vm.expectRevert(ValidatorPodManager.ExceedsMaxDelay.selector);
        podManager.setWithdrawalDelay(exceedsMax);
    }

    function test_setWithdrawalDelay_OnlyOwner() public {
        vm.prank(attacker);
        vm.expectRevert();
        podManager.setWithdrawalDelay(100_000);
    }

    function test_withdrawalConstants() public view {
        assertEq(podManager.DEFAULT_WITHDRAWAL_DELAY(), 302_400, "Default delay ~7 days");
        assertEq(podManager.MAX_WITHDRAWAL_DELAY(), 1_296_000, "Max delay ~30 days");
        assertEq(podManager.withdrawalDelayBlocks(), 302_400, "Initial delay is default");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION SHARE-POOL SEMANTICS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice After a slash, every delegator's effective claim drops proportionally
    ///         even though no per-delegator storage was written. This is the central
    ///         correctness property of the O(1) share-pool slash.
    function test_slashAffectsAllDelegatorsProportionally() public {
        _registerOperator(operator1, 1 ether);

        address[5] memory delegators = [makeAddr("d0"), makeAddr("d1"), makeAddr("d2"), makeAddr("d3"), makeAddr("d4")];
        uint256[5] memory amounts = [uint256(10 ether), 20 ether, 5 ether, 15 ether, 50 ether];

        uint256 totalDelegated;
        for (uint256 i = 0; i < delegators.length; i++) {
            address pod = address(_createPodWithShares(delegators[i], amounts[i]));
            assertTrue(pod != address(0));
            vm.prank(delegators[i]);
            podManager.delegateTo(operator1, amounts[i]);
            totalDelegated += amounts[i];
        }

        assertEq(
            podManager.getOperatorDelegatedStake(operator1),
            totalDelegated,
            "pool totalAssets equals sum of delegate inputs (initial 1:1 rate)"
        );

        // Snapshot pre-slash live valuations
        uint256[5] memory before_;
        for (uint256 i = 0; i < delegators.length; i++) {
            before_[i] = podManager.getDelegation(delegators[i], operator1);
            assertEq(before_[i], amounts[i], "pre-slash live value equals input");
        }

        // 25% slash applied to the operator
        vm.prank(slasher);
        podManager.slash(operator1, 1, 2500, keccak256("evidence"));

        // Slash math: amount = (selfStake + delegated) * bps / 10_000.
        // Self-stake (1 ether) absorbs first; the remainder hits the pool.
        uint256 totalAmount = (1 ether + totalDelegated) * 2500 / 10_000;
        uint256 selfSlash = totalAmount > 1 ether ? 1 ether : totalAmount;
        uint256 poolSlash = totalAmount - selfSlash;
        uint256 expectedPoolAfter = totalDelegated - poolSlash;
        assertEq(
            podManager.getOperatorDelegatedStake(operator1),
            expectedPoolAfter,
            "pool totalAssets drops by the delegated portion of the slash"
        );

        // Each delegator's live value should be ~ totalAssetsAfter/totalAssetsBefore * before.
        // The virtual offset biases convertToAssets upward by at most ~VIRTUAL_ASSETS
        // distributed across shareholders; with our amounts that's well under 1e6 wei.
        uint256 totalAssetsBefore = totalDelegated;
        uint256 totalAssetsAfter = expectedPoolAfter;
        for (uint256 i = 0; i < delegators.length; i++) {
            uint256 live = podManager.getDelegation(delegators[i], operator1);
            uint256 expected = (before_[i] * totalAssetsAfter) / totalAssetsBefore;
            uint256 diff = live > expected ? live - expected : expected - live;
            assertLe(diff, 1e6, "per-delegator slash within virtual-offset dust");
        }
    }

    /// @notice Gas used by `_slash` must be bounded -- not grow with the number of delegators.
    function test_slashGas_BoundedRegardlessOfDelegatorCount() public {
        _registerOperator(operator1, 1 ether);
        _registerOperator(operator2, 1 ether);

        // Operator 1 gets 1 delegator
        address d = makeAddr("solo");
        _createPodWithShares(d, 5 ether);
        vm.prank(d);
        podManager.delegateTo(operator1, 5 ether);

        // Operator 2 gets 50 delegators
        for (uint256 i = 0; i < 50; i++) {
            address di = makeAddr(string(abi.encodePacked("crowd-", vm.toString(i))));
            _createPodWithShares(di, 5 ether);
            vm.prank(di);
            podManager.delegateTo(operator2, 5 ether);
        }

        vm.prank(slasher);
        uint256 gasA0 = gasleft();
        podManager.slash(operator1, 1, 1000, bytes32("a"));
        uint256 gasA = gasA0 - gasleft();

        vm.prank(slasher);
        uint256 gasB0 = gasleft();
        podManager.slash(operator2, 2, 1000, bytes32("b"));
        uint256 gasB = gasB0 - gasleft();

        // The 50-delegator slash must not cost meaningfully more than the 1-delegator slash.
        // 5x is a generous ceiling for warm-vs-cold storage variance; a legacy O(D) loop
        // would scale ~30-40x at this size.
        emit log_named_uint("gas slash op1 (1 delegator)", gasA);
        emit log_named_uint("gas slash op2 (50 delegators)", gasB);
        assertLt(gasB, gasA * 5, "slash gas does not scale with delegator count");
    }

    /// @notice Invariant: for every operator, the operator delegation pool's totalAssets
    ///         equals the live sum of per-delegator asset valuations (within rounding dust
    ///         introduced by virtual offsets and Floor rounding).
    function test_invariant_poolTotalAssetsMatchesSumOfDelegations() public {
        _registerOperator(operator1, 1 ether);

        address[3] memory dels = [makeAddr("ia"), makeAddr("ib"), makeAddr("ic")];
        uint256[3] memory ams = [uint256(7 ether), 13 ether, 21 ether];

        for (uint256 i = 0; i < dels.length; i++) {
            _createPodWithShares(dels[i], ams[i]);
            vm.prank(dels[i]);
            podManager.delegateTo(operator1, ams[i]);
        }

        // Apply a 33% slash
        vm.prank(slasher);
        podManager.slash(operator1, 1, 3333, bytes32("inv"));

        uint256 sumLive;
        for (uint256 i = 0; i < dels.length; i++) {
            sumLive += podManager.getDelegation(dels[i], operator1);
        }

        uint256 totalAssets = podManager.getOperatorDelegatedStake(operator1);

        // sumLive may exceed or undershoot totalAssets within bounded dust set by the
        // virtual offset (VIRTUAL_ASSETS) plus per-delegator Floor rounding (~1 wei each).
        // The point of the invariant is that the bound is constant in delegator count,
        // not that the sum equals totalAssets exactly.
        uint256 diff = sumLive > totalAssets ? sumLive - totalAssets : totalAssets - sumLive;
        assertLt(diff, 1e6, "sum vs pool totalAssets is bounded dust (not delegator-count scaled)");
    }
}
