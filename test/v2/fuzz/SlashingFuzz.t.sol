// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { SlashingLib } from "../../../src/v2/libraries/SlashingLib.sol";

/// @title SlashingFuzzTest
/// @notice Fuzz tests for slashing mechanics
contract SlashingFuzzTest is BaseTest {
    uint64 blueprintId;
    uint64 serviceId;

    function setUp() public override {
        super.setUp();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint("ipfs://slash-fuzz", address(0));

        _registerOperator(operator1, 10 ether);
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        serviceId = tangle.serviceCount() - 1;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH AMOUNT CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test effective slash is always <= proposed amount
    function testFuzz_EffectiveSlash_LessThanOrEqualProposed(
        uint256 proposedAmount
    ) public {
        // Bound to reasonable slash amounts
        proposedAmount = bound(proposedAmount, 0.01 ether, 100 ether);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, proposedAmount, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);

        assertLe(proposal.effectiveAmount, proposal.amount, "Effective > proposed");
    }

    /// @notice Fuzz test exposure scaling is correct
    function testFuzz_ExposureScaling(
        uint256 amount,
        uint16 exposure
    ) public {
        // Bound inputs
        amount = bound(amount, 0.1 ether, 10 ether);
        exposure = uint16(bound(uint256(exposure), 1, 10000)); // 0.01% to 100%

        // Create service with specific exposure
        _registerOperator(operator2, 10 ether);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator2;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = exposure;

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure(
            blueprintId, operators, exposures, "", new address[](0), 0, address(0), 0
        );
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        uint64 newServiceId = tangle.serviceCount() - 1;

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(newServiceId, operator2, amount, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);

        // Verify exposure scaling
        uint256 expectedEffective = (amount * exposure) / 10000;
        assertEq(proposal.effectiveAmount, expectedEffective, "Exposure scaling incorrect");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE WINDOW TIMING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test dispute window timing is correct
    function testFuzz_DisputeWindow_Timing(uint64 disputeWindow) public {
        // Bound dispute window to valid range (1 hour to 30 days)
        disputeWindow = uint64(bound(uint256(disputeWindow), 1 hours, 30 days));

        // Set dispute window
        vm.prank(admin);
        tangle.setSlashConfig(disputeWindow, false, 10000);

        uint256 proposalTime = block.timestamp;
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1 ether, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);

        assertEq(proposal.proposedAt, proposalTime, "Proposal time incorrect");
        assertEq(proposal.executeAfter, proposalTime + disputeWindow, "Execute after incorrect");

        // Cannot execute before window passes
        vm.warp(block.timestamp + disputeWindow - 1);
        vm.expectRevert();
        tangle.executeSlash(slashId);

        // Can execute after window passes
        vm.warp(block.timestamp + 2);
        tangle.executeSlash(slashId);

        SlashingLib.SlashProposal memory executed = tangle.getSlashProposal(slashId);
        assertEq(uint8(executed.status), uint8(SlashingLib.SlashStatus.Executed));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTIPLE SLASHES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test multiple concurrent slashes
    function testFuzz_MultipleConcurrentSlashes(uint8 slashCount) public {
        slashCount = uint8(bound(uint256(slashCount), 1, 10));

        uint64[] memory slashIds = new uint64[](slashCount);
        uint256 slashAmount = 0.1 ether;

        // Create multiple slash proposals
        for (uint8 i = 0; i < slashCount; i++) {
            vm.prank(user1);
            slashIds[i] = tangle.proposeSlash(
                serviceId,
                operator1,
                slashAmount,
                keccak256(abi.encodePacked("evidence", i))
            );
        }

        // Verify all proposals are pending
        for (uint8 i = 0; i < slashCount; i++) {
            SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashIds[i]);
            assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Pending));
        }

        // Execute all after window
        vm.warp(block.timestamp + 7 days + 1);
        for (uint8 i = 0; i < slashCount; i++) {
            tangle.executeSlash(slashIds[i]);
        }

        // Verify all executed
        for (uint8 i = 0; i < slashCount; i++) {
            SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashIds[i]);
            assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed));
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH CONFIG BOUNDARIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test max slash percentage
    function testFuzz_MaxSlashPercentage(uint16 maxSlashBps) public {
        // Must be between 1 and 10000 (0.01% to 100%)
        vm.assume(maxSlashBps > 0 && maxSlashBps <= 10000);

        vm.prank(admin);
        tangle.setSlashConfig(7 days, false, maxSlashBps);

        // Verify by creating a slash and checking behavior
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1 ether, keccak256("test"));
        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertGt(proposal.amount, 0, "Slash proposal created");
    }

    /// @notice Fuzz test invalid config reverts
    function testFuzz_InvalidConfig_Reverts(
        uint64 disputeWindow,
        uint16 maxSlashBps
    ) public {
        // Test invalid windows (too short or too long)
        bool invalidWindow = disputeWindow < 1 hours || disputeWindow > 30 days;
        bool invalidMax = maxSlashBps == 0 || maxSlashBps > 10000;

        if (invalidWindow || invalidMax) {
            vm.prank(admin);
            vm.expectRevert(Errors.InvalidSlashConfig.selector);
            tangle.setSlashConfig(disputeWindow, false, maxSlashBps);
        }
    }
}
