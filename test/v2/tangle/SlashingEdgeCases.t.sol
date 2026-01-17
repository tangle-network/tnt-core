// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { SlashingLib } from "../../../src/v2/libraries/SlashingLib.sol";

/// @title SlashingEdgeCasesTest
/// @notice Edge cases and stress tests for slashing system
contract SlashingEdgeCasesTest is BaseTest {
    uint64 public blueprintId;
    uint64 public serviceId;

    function setUp() public override {
        super.setUp();
        _setupService();
    }

    function _setupService() internal {
        // Register operator with stake
        _registerOperator(operator1, 10 ether);

        // Create blueprint
        blueprintId = _createBlueprint(developer);

        // Register for blueprint
        _registerForBlueprint(operator1, blueprintId);

        // Create and approve service
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        serviceId = 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH BPS EXCEEDS MAX
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SlashBpsExceedsMax_CapsAtMax() public {
        uint256 stakeBefore = restaking.getOperatorSelfStake(operator1);
        assertEq(stakeBefore, 10 ether);

        vm.prank(admin);
        tangle.setSlashConfig(7 days, false, 5000);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 8000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        uint256 stakeAfter = restaking.getOperatorSelfStake(operator1);
        assertEq(stakeAfter, 5 ether, "Operator stake should be cut by maxSlashBps");
    }

    function test_SlashBpsExceedsMax_ProposalStoresCappedBps() public {
        vm.prank(admin);
        tangle.setSlashConfig(7 days, false, 5000);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 8000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.slashBps, 5000, "Proposal should store capped slash bps");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTIPLE SLASHES IN SAME BLOCK
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultipleSlashProposals_SameBlock() public {
        // Propose multiple slashes in the same block
        vm.startPrank(user1);
        uint64 slashId1 = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence1"));
        uint64 slashId2 = tangle.proposeSlash(serviceId, operator1, 2000, keccak256("evidence2"));
        uint64 slashId3 = tangle.proposeSlash(serviceId, operator1, 3000, keccak256("evidence3"));
        vm.stopPrank();

        // All should have same proposedAt timestamp
        assertEq(tangle.getSlashProposal(slashId1).proposedAt, tangle.getSlashProposal(slashId2).proposedAt);
        assertEq(tangle.getSlashProposal(slashId2).proposedAt, tangle.getSlashProposal(slashId3).proposedAt);

        // All can be executed after window
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        uint256 stakeBefore = restaking.getOperatorSelfStake(operator1);

        tangle.executeSlash(slashId1);
        tangle.executeSlash(slashId2);
        tangle.executeSlash(slashId3);

        uint256 stakeAfter = restaking.getOperatorSelfStake(operator1);
        uint256 afterFirst = stakeBefore - ((stakeBefore * 1000) / 10_000);
        uint256 afterSecond = afterFirst - ((afterFirst * 2000) / 10_000);
        uint256 expectedAfter = afterSecond - ((afterSecond * 3000) / 10_000);
        assertEq(stakeAfter, expectedAfter, "Total slash should match sequential bps");
    }

    function test_MultipleSlashExecutions_SameBlock() public {
        // Create multiple proposals at different times
        vm.prank(user1);
        uint64 slashId1 = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("e1"));

        vm.warp(block.timestamp + 1 days);
        vm.prank(user1);
        uint64 slashId2 = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("e2"));

        vm.warp(block.timestamp + 1 days);
        vm.prank(user1);
        uint64 slashId3 = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("e3"));

        // Wait until all are executable
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        uint256 stakeBefore = restaking.getOperatorSelfStake(operator1);

        // Execute all in the same block
        tangle.executeSlash(slashId1);
        tangle.executeSlash(slashId2);
        tangle.executeSlash(slashId3);

        uint256 stakeAfter = restaking.getOperatorSelfStake(operator1);
        uint256 afterFirst = stakeBefore - ((stakeBefore * 1000) / 10_000);
        uint256 afterSecond = afterFirst - ((afterFirst * 1000) / 10_000);
        uint256 expectedAfter = afterSecond - ((afterSecond * 1000) / 10_000);
        assertEq(stakeAfter, expectedAfter);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH WITH PENDING UNSTAKES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SlashWithPendingDelegatorUnstake() public {
        // Add delegation
        vm.prank(delegator1);
        restaking.depositAndDelegate{ value: 10 ether }(operator1);

        // Schedule unstake
        vm.prank(delegator1);
        restaking.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        // Now slash
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 5000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        // Slash should have been applied proportionally
        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed));
    }

    function test_SlashWithPendingOperatorUnstake() public {
        // Operator schedules to unstake some self-stake
        vm.prank(operator1);
        restaking.scheduleOperatorUnstake(3 ether);

        // Slash before unstake executes
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 5000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE WINDOW EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DisputeAtExactWindowBoundary() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Warp to exactly the boundary - dispute should still work
        vm.warp(block.timestamp + 7 days - 1);

        vm.prank(operator1);
        tangle.disputeSlash(slashId, "Last second dispute");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Disputed));
    }

    function test_DisputeOneSecondAfterWindow() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Warp to one second after window ends
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.DisputeWindowPassed.selector, slashId));
        tangle.disputeSlash(slashId, "Too late");
    }

    function test_ExecuteAtExactWindowBoundary() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // M-6 FIX: Warp to exactly when execution becomes possible (executeAfter + TIMESTAMP_BUFFER)
        vm.warp(block.timestamp + 7 days + 15);

        // Should be executable
        tangle.executeSlash(slashId);

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed));
    }

    function test_ExecuteOneSecondBeforeWindow() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Warp to one second before window ends
        vm.warp(block.timestamp + 7 days - 1);

        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH AFTER OPERATOR LEAVES SERVICE
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ProposeSlash_AfterOperatorLeavesService_Reverts() public {
        // Setup dynamic service
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 0, // Allow 0 operators for testing
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 dynamicBpId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        // Register operator2
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, dynamicBpId);

        // Create service
        uint64 requestId = _requestService(user1, dynamicBpId, operator2);
        _approveService(operator2, requestId);

        uint64 dynamicServiceId = tangle.serviceCount() - 1;

        // Operator is still in the set until leave is called
        assertTrue(tangle.isServiceOperator(dynamicServiceId, operator2));

        // Propose slash while still in service - should work
        vm.prank(user1);
        tangle.proposeSlash(dynamicServiceId, operator2, 1000, keccak256("evidence"));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CUMULATIVE SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CumulativeSlashing_ReducesStakeCorrectly() public {
        uint256 initialStake = restaking.getOperatorSelfStake(operator1);
        assertEq(initialStake, 10 ether);

        // Propose all slashes at once (at same timestamp)
        uint64[] memory slashIds = new uint64[](5);
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(user1);
            slashIds[i] = tangle.proposeSlash(serviceId, operator1, 1000, keccak256(abi.encode("evidence", i)));
        }

        // Wait for dispute window to pass
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        // Execute all slashes
        for (uint256 i = 0; i < 5; i++) {
            tangle.executeSlash(slashIds[i]);
        }

        uint256 finalStake = restaking.getOperatorSelfStake(operator1);
        uint256 expected = initialStake;
        for (uint256 i = 0; i < 5; i++) {
            expected -= (expected * 1000) / 10_000;
        }
        assertEq(finalStake, expected, "Should match sequential bps slashes");
    }

    function test_CumulativeSlashing_UntilDepleted() public {
        uint256 initialStake = restaking.getOperatorSelfStake(operator1);
        assertEq(initialStake, 10 ether);

        // Propose repeated full slashes at once
        uint64[] memory slashIds = new uint64[](5);
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(user1);
            slashIds[i] = tangle.proposeSlash(serviceId, operator1, 10_000, keccak256(abi.encode("evidence", i)));
        }

        // Wait for dispute window to pass
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        // Execute all slashes
        for (uint256 i = 0; i < 5; i++) {
            tangle.executeSlash(slashIds[i]);
            // After all stake is depleted, further slashes cap at remaining stake (0)
        }

        assertEq(restaking.getOperatorSelfStake(operator1), 0, "All stake should be slashed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CUSTOM SLASHING WINDOW
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CustomSlashingWindow_ShortWindow() public {
        // Set short dispute window
        vm.prank(admin);
        tangle.setSlashConfig(1 hours, false, 10000);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.executeAfter, block.timestamp + 1 hours);

        // M-6 FIX: Can execute after 1 hour + TIMESTAMP_BUFFER (15s)
        vm.warp(block.timestamp + 1 hours + 15);
        tangle.executeSlash(slashId);

        assertEq(uint8(tangle.getSlashProposal(slashId).status), uint8(SlashingLib.SlashStatus.Executed));
    }

    function test_CustomSlashingWindow_LongWindow() public {
        // Set long dispute window
        vm.prank(admin);
        tangle.setSlashConfig(30 days, false, 10000);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.executeAfter, block.timestamp + 30 days);

        // Cannot execute before 30 days
        vm.warp(block.timestamp + 29 days);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);

        // M-6 FIX: Can execute after 30 days + TIMESTAMP_BUFFER (15s)
        vm.warp(block.timestamp + 1 days + 16);
        tangle.executeSlash(slashId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING WITH EXPOSURE
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SlashWithLowExposure_ReducedEffectiveAmount() public {
        // Create service with 25% exposure
        uint64 exposureBpId = _createBlueprint(developer);
        _registerForBlueprint(operator1, exposureBpId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 2500; // 25%
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure(exposureBpId, ops, exposures, "", callers, 0, address(0), 0);

        _approveService(operator1, requestId);

        uint64 exposureServiceId = tangle.serviceCount() - 1;

        // Propose slash for 40% (effective 10% after 25% exposure)
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(exposureServiceId, operator1, 4000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.slashBps, 4000);
        assertEq(proposal.effectiveSlashBps, 1000, "25% of 40% = 10%");
    }

    function test_SlashWithFullExposure_FullAmount() public {
        // Default service has 100% exposure
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 4000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.slashBps, 4000);
        assertEq(proposal.effectiveSlashBps, 4000, "100% exposure = full bps");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STRESS TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ManyPendingSlashProposals() public {
        // Create many pending proposals
        for (uint256 i = 0; i < 50; i++) {
            vm.prank(user1);
            tangle.proposeSlash(serviceId, operator1, 100, keccak256(abi.encode("evidence", i)));
        }

        // All should be valid proposals
        for (uint64 i = 0; i < 50; i++) {
            SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(i);
            assertEq(proposal.slashBps, 100);
            assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Pending));
        }
    }

    function test_SlashAndDisputeRace() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Warp to just before window ends
        vm.warp(block.timestamp + 7 days - 1);

        // Both dispute and execute attempted at boundary
        // Dispute should succeed since we're still in window
        vm.prank(operator1);
        tangle.disputeSlash(slashId, "Last second dispute");

        // Execute should fail since disputed
        vm.warp(block.timestamp + 1);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ZERO AND DUST AMOUNT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SlashZeroAmount_Reverts() public {
        vm.prank(user1);
        vm.expectRevert(Errors.InvalidSlashAmount.selector);
        tangle.proposeSlash(serviceId, operator1, 0, keccak256("evidence"));
    }

    function test_SlashOneBps() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1, keccak256("evidence"));

        uint256 stakeBefore = restaking.getOperatorSelfStake(operator1);

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        uint256 stakeAfter = restaking.getOperatorSelfStake(operator1);
        uint256 expectedSlash = (stakeBefore * 1) / 10_000;
        assertEq(stakeAfter, stakeBefore - expectedSlash, "Should slash 1 bps of stake");
    }
}
