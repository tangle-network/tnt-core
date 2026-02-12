// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DelegationTestHarness, MockERC20 } from "./DelegationTestHarness.sol";
import { DelegationErrors } from "../../src/staking/DelegationErrors.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @title BlueprintSelectionTest
/// @notice Tests for blueprint selection filtering in rewards and slashing
/// @dev Verifies that Fixed mode delegators are only exposed to selected blueprints
contract BlueprintSelectionTest is DelegationTestHarness {
    // Blueprint IDs for testing
    uint64 constant BLUEPRINT_1 = 1;
    uint64 constant BLUEPRINT_2 = 2;
    uint64 constant BLUEPRINT_3 = 3;

    // ═══════════════════════════════════════════════════════════════════════════
    // SETUP
    // ═══════════════════════════════════════════════════════════════════════════

    function setUp() public override {
        super.setUp();
        // Register additional operators for multi-operator tests
        _registerOperator(operator2, 10 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit and delegate with Fixed mode to specific blueprints
    function _depositAndDelegateFixed(
        address delegator,
        address operator,
        uint256 amount,
        uint64[] memory blueprintIds
    )
        internal
    {
        vm.prank(delegator);
        delegation.depositAndDelegateWithOptions{ value: amount }(
            operator,
            address(0), // native
            amount,
            Types.BlueprintSelectionMode.Fixed,
            blueprintIds
        );
    }

    /// @notice Deposit and delegate with All mode
    function _depositAndDelegateAll(address delegator, address operator, uint256 amount) internal {
        vm.prank(delegator);
        delegation.depositAndDelegateWithOptions{ value: amount }(
            operator,
            address(0), // native
            amount,
            Types.BlueprintSelectionMode.All,
            new uint64[](0)
        );
    }

    /// @notice Slash for a specific blueprint
    function _slashForBlueprint(address operator, uint64 blueprintId, uint16 slashBps) internal {
        vm.prank(slasher);
        delegation.slashForBlueprint(operator, blueprintId, 0, slashBps, keccak256("evidence"));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION MODE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test that All mode delegation works correctly
    function test_AllModeDelegation() public {
        _depositAndDelegateAll(delegator1, operator1, 5 ether);

        // Verify delegation
        uint256 delegated = delegation.getDelegation(delegator1, operator1);
        assertEq(delegated, 5 ether, "All mode delegation amount incorrect");
    }

    function test_AllModeDisallowsBlueprintList() public {
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;

        vm.prank(delegator1);
        vm.expectRevert(DelegationErrors.AllModeDisallowsBlueprints.selector);
        delegation.depositAndDelegateWithOptions{ value: 5 ether }(
            operator1,
            address(0), // native
            5 ether,
            Types.BlueprintSelectionMode.All,
            blueprints
        );
    }

    /// @notice Test that Fixed mode delegation with blueprints works correctly
    function test_FixedModeDelegation() public {
        uint64[] memory blueprints = new uint64[](2);
        blueprints[0] = BLUEPRINT_1;
        blueprints[1] = BLUEPRINT_2;

        _depositAndDelegateFixed(delegator1, operator1, 5 ether, blueprints);

        // Verify delegation
        uint256 delegated = delegation.getDelegation(delegator1, operator1);
        assertEq(delegated, 5 ether, "Fixed mode delegation amount incorrect");
    }

    function test_FixedModeRequiresNonEmptyBlueprintList() public {
        vm.prank(delegator1);
        vm.expectRevert(DelegationErrors.FixedModeRequiresBlueprints.selector);
        delegation.depositAndDelegateWithOptions{ value: 5 ether }(
            operator1,
            address(0), // native
            5 ether,
            Types.BlueprintSelectionMode.Fixed,
            new uint64[](0)
        );
    }

    function test_FixedModeRejectsDuplicateBlueprints() public {
        uint64[] memory blueprints = new uint64[](2);
        blueprints[0] = BLUEPRINT_1;
        blueprints[1] = BLUEPRINT_1;

        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.DuplicateBlueprint.selector, BLUEPRINT_1));
        delegation.depositAndDelegateWithOptions{ value: 5 ether }(
            operator1,
            address(0), // native
            5 ether,
            Types.BlueprintSelectionMode.Fixed,
            blueprints
        );
    }

    /// @notice Test mixed mode delegations to same operator
    function test_MixedModeDelegations() public {
        // Delegator1 uses All mode
        _depositAndDelegateAll(delegator1, operator1, 5 ether);

        // Delegator2 uses Fixed mode with specific blueprints
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator2, operator1, 5 ether, blueprints);

        // Both delegations should exist
        assertEq(delegation.getDelegation(delegator1, operator1), 5 ether, "All mode delegation incorrect");
        assertEq(delegation.getDelegation(delegator2, operator1), 5 ether, "Fixed mode delegation incorrect");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING TESTS - BLUEPRINT FILTERING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test that All mode delegators are slashed for ANY blueprint
    function test_AllModeSlashedForAnyBlueprint() public {
        // Setup: All mode delegation
        _depositAndDelegateAll(delegator1, operator1, 10 ether);
        uint256 delegationBefore = delegation.getDelegation(delegator1, operator1);

        // Slash for blueprint 1
        _slashForBlueprint(operator1, BLUEPRINT_1, 2000);

        // All mode delegator should be slashed
        uint256 delegationAfter = delegation.getDelegation(delegator1, operator1);
        assertTrue(delegationAfter < delegationBefore, "All mode delegator should be slashed");
    }

    /// @notice Test that Fixed mode delegators are only slashed for selected blueprints
    function test_FixedModeOnlySlashedForSelectedBlueprints() public {
        // Setup: Fixed mode delegation to blueprint 1 only
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        uint256 delegationBefore = delegation.getDelegation(delegator1, operator1);

        // Slash for blueprint 2 (not selected by delegator1)
        _slashForBlueprint(operator1, BLUEPRINT_2, 2000);

        // Fixed mode delegator should NOT be slashed (didn't select blueprint 2)
        uint256 delegationAfter = delegation.getDelegation(delegator1, operator1);
        assertEq(
            delegationAfter, delegationBefore, "Fixed mode delegator should not be slashed for unselected blueprint"
        );
    }

    /// @notice Test that Fixed mode delegators ARE slashed for their selected blueprints
    function test_FixedModeSlashedForSelectedBlueprint() public {
        // Setup: Fixed mode delegation to blueprint 1
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        uint256 delegationBefore = delegation.getDelegation(delegator1, operator1);

        // Slash for blueprint 1 (selected by delegator1)
        _slashForBlueprint(operator1, BLUEPRINT_1, 2000);

        // Fixed mode delegator SHOULD be slashed
        uint256 delegationAfter = delegation.getDelegation(delegator1, operator1);
        assertTrue(delegationAfter < delegationBefore, "Fixed mode delegator should be slashed for selected blueprint");
    }

    /// @notice Test mixed slashing scenario
    function test_MixedModeSlashing() public {
        // Delegator1: All mode (exposed to all)
        _depositAndDelegateAll(delegator1, operator1, 10 ether);

        // Delegator2: Fixed mode, only blueprint 1
        uint64[] memory bp1 = new uint64[](1);
        bp1[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator2, operator1, 10 ether, bp1);

        // Delegator3: Fixed mode, only blueprint 2
        uint64[] memory bp2 = new uint64[](1);
        bp2[0] = BLUEPRINT_2;
        _depositAndDelegateFixed(delegator3, operator1, 10 ether, bp2);

        uint256 del1Before = delegation.getDelegation(delegator1, operator1);
        uint256 del2Before = delegation.getDelegation(delegator2, operator1);
        uint256 del3Before = delegation.getDelegation(delegator3, operator1);

        // Slash for blueprint 1
        _slashForBlueprint(operator1, BLUEPRINT_1, 3000);

        uint256 del1After = delegation.getDelegation(delegator1, operator1);
        uint256 del2After = delegation.getDelegation(delegator2, operator1);
        uint256 del3After = delegation.getDelegation(delegator3, operator1);

        // Delegator1 (All mode) should be slashed
        assertTrue(del1After < del1Before, "All mode delegator should be slashed");

        // Delegator2 (Fixed, bp1) should be slashed
        assertTrue(del2After < del2Before, "Fixed mode delegator with bp1 should be slashed");

        // Delegator3 (Fixed, bp2) should NOT be slashed
        assertEq(del3After, del3Before, "Fixed mode delegator with bp2 should not be slashed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test adding a blueprint to Fixed mode delegation
    function test_AddBlueprintToDelegation() public {
        // Setup: Fixed mode delegation with blueprint 1
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        // Add blueprint 2
        vm.prank(delegator1);
        delegation.addBlueprintToDelegation(0, BLUEPRINT_2);

        // Now should be exposed to both blueprints
        uint256 delegationBefore = delegation.getDelegation(delegator1, operator1);

        // Slash for blueprint 2 - should now affect delegator1
        _slashForBlueprint(operator1, BLUEPRINT_2, 1000);

        uint256 delegationAfter = delegation.getDelegation(delegator1, operator1);
        assertTrue(delegationAfter < delegationBefore, "Should be slashed after adding blueprint");
    }

    /// @notice Test removing a blueprint from Fixed mode delegation
    function test_RemoveBlueprintFromDelegation() public {
        // Setup: Fixed mode delegation with 2 blueprints
        uint64[] memory blueprints = new uint64[](2);
        blueprints[0] = BLUEPRINT_1;
        blueprints[1] = BLUEPRINT_2;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        // Remove blueprint 2
        vm.prank(delegator1);
        delegation.removeBlueprintFromDelegation(0, BLUEPRINT_2);

        uint256 delegationBefore = delegation.getDelegation(delegator1, operator1);

        // Slash for blueprint 2 - should NOT affect delegator1 anymore
        _slashForBlueprint(operator1, BLUEPRINT_2, 1000);

        uint256 delegationAfter = delegation.getDelegation(delegator1, operator1);
        assertEq(delegationAfter, delegationBefore, "Should not be slashed after removing blueprint");
    }

    /// @notice Test cannot remove last blueprint
    function test_CannotRemoveLastBlueprint() public {
        // Setup: Fixed mode delegation with 1 blueprint
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        // Try to remove the only blueprint - should fail
        vm.prank(delegator1);
        vm.expectRevert(DelegationErrors.CannotRemoveLastBlueprint.selector);
        delegation.removeBlueprintFromDelegation(0, BLUEPRINT_1);
    }

    /// @notice Test cannot add duplicate blueprint
    function test_CannotAddDuplicateBlueprint() public {
        // Setup: Fixed mode delegation with blueprint 1
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        // Try to add blueprint 1 again - should fail
        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.BlueprintAlreadySelected.selector, BLUEPRINT_1));
        delegation.addBlueprintToDelegation(0, BLUEPRINT_1);
    }

    /// @notice Test cannot modify All mode delegation
    function test_CannotModifyAllModeDelegation() public {
        // Setup: All mode delegation
        _depositAndDelegateAll(delegator1, operator1, 10 ether);

        // Try to add blueprint - should fail (not Fixed mode)
        vm.prank(delegator1);
        vm.expectRevert(DelegationErrors.NotFixedMode.selector);
        delegation.addBlueprintToDelegation(0, BLUEPRINT_1);
    }

    /// @notice Test cannot remove non-existent blueprint
    function test_CannotRemoveNonExistentBlueprint() public {
        // Setup: Fixed mode delegation with 2 blueprints
        uint64[] memory blueprints = new uint64[](2);
        blueprints[0] = BLUEPRINT_1;
        blueprints[1] = BLUEPRINT_2;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        // Try to remove blueprint 3 (not selected) - should fail
        vm.prank(delegator1);
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.BlueprintNotSelected.selector, BLUEPRINT_3));
        delegation.removeBlueprintFromDelegation(0, BLUEPRINT_3);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test slashing with no delegators for a blueprint
    function test_SlashWithNoDelegatorsForBlueprint() public {
        // Only All mode delegator
        _depositAndDelegateAll(delegator1, operator1, 10 ether);

        // Slash for a blueprint with no Fixed mode delegators
        // Should only affect All mode delegators
        uint256 delegationBefore = delegation.getDelegation(delegator1, operator1);
        _slashForBlueprint(operator1, BLUEPRINT_1, 2000);
        uint256 delegationAfter = delegation.getDelegation(delegator1, operator1);

        assertTrue(delegationAfter < delegationBefore, "All mode should still be slashed");
    }

    /// @notice Test multiple Fixed mode delegations with different blueprints
    function test_MultipleDelegationsWithDifferentBlueprints() public {
        // Delegator1 delegates to operator1 with blueprint 1
        uint64[] memory bp1 = new uint64[](1);
        bp1[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator1, operator1, 5 ether, bp1);

        // Delegator1 ALSO delegates to operator2 with blueprint 2
        uint64[] memory bp2 = new uint64[](1);
        bp2[0] = BLUEPRINT_2;
        vm.prank(delegator1);
        delegation.depositAndDelegateWithOptions{ value: 5 ether }(
            operator2, address(0), 5 ether, Types.BlueprintSelectionMode.Fixed, bp2
        );

        // Slash operator1 for blueprint 1 - should affect first delegation
        uint256 op1DelegationBefore = delegation.getDelegation(delegator1, operator1);
        _slashForBlueprint(operator1, BLUEPRINT_1, 1000);
        uint256 op1DelegationAfter = delegation.getDelegation(delegator1, operator1);
        assertTrue(op1DelegationAfter < op1DelegationBefore, "Op1 delegation should be slashed");

        // Slash operator2 for blueprint 1 - should NOT affect second delegation (wrong blueprint)
        uint256 op2DelegationBefore = delegation.getDelegation(delegator1, operator2);
        _slashForBlueprint(operator2, BLUEPRINT_1, 1000);
        uint256 op2DelegationAfter = delegation.getDelegation(delegator1, operator2);
        assertEq(op2DelegationAfter, op2DelegationBefore, "Op2 delegation should not be slashed for bp1");
    }

    /// @notice Test unstaking preserves blueprint exposure correctly
    function test_UnstakingPreservesBlueprintExposure() public {
        // Fixed mode with blueprint 1
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_1;
        _depositAndDelegateFixed(delegator1, operator1, 10 ether, blueprints);

        // Schedule partial unstake
        vm.prank(delegator1);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 3 ether);

        // Advance rounds
        _advanceRounds(8);

        // Execute unstake
        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        // Remaining delegation should still be Fixed mode with blueprint 1
        uint256 remaining = delegation.getDelegation(delegator1, operator1);
        assertTrue(remaining > 0, "Should have remaining delegation");

        // Verify still exposed to blueprint 1 by testing slash impact
        uint256 delegationBefore = delegation.getDelegation(delegator1, operator1);
        _slashForBlueprint(operator1, BLUEPRINT_1, 1000);
        uint256 delegationAfter = delegation.getDelegation(delegator1, operator1);
        assertTrue(delegationAfter < delegationBefore, "Remaining delegation should still be exposed to bp1");
    }
}
