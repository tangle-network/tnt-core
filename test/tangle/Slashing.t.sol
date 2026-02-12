// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { SlashingLib } from "../../src/libraries/SlashingLib.sol";
import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";

/// @title SlashingTest
/// @notice Comprehensive tests for the slashing system with dispute window
contract HookedBSM is BlueprintServiceManagerBase {
    address public allowedOrigin;
    uint8 public lastUnappliedPercent;
    uint8 public lastExecutedPercent;

    function setAllowedOrigin(address origin) external {
        allowedOrigin = origin;
    }

    function onBlueprintCreated(uint64 _blueprintId, address owner, address _tangleCore) external override {
        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = _tangleCore;
    }

    function querySlashingOrigin(uint64) external view override returns (address) {
        return allowedOrigin;
    }

    function onUnappliedSlash(uint64, bytes calldata, uint8 slashPercent) external override onlyFromTangle {
        lastUnappliedPercent = slashPercent;
    }

    function onSlash(uint64, bytes calldata, uint8 slashPercent) external override onlyFromTangle {
        lastExecutedPercent = slashPercent;
    }
}

contract SlashingTest is BaseTest {
    uint64 blueprintId;
    uint64 serviceId;
    address public managerCaller = makeAddr("managerCaller");

    function setUp() public override {
        super.setUp();

        // Setup: create blueprint, register operator, create service
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://slashing-test", address(0)));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();

        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        serviceId = 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PROPOSAL TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ProposeSlash_ByServiceOwner() public {
        vm.prank(user1);
        uint16 slashBps = 2000;
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, slashBps, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.serviceId, serviceId);
        assertEq(proposal.operator, operator1);
        assertEq(proposal.proposer, user1);
        assertEq(proposal.slashBps, slashBps);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Pending));
    }

    function test_ProposeSlash_ByBlueprintOwner() public {
        vm.prank(developer);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.proposer, developer);
    }

    function test_ProposeSlash_RevertUnauthorized() public {
        vm.prank(user2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));
    }

    function test_ProposeSlash_RevertOperatorNotInService() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotInService.selector, serviceId, operator2));
        tangle.proposeSlash(serviceId, operator2, 1000, keccak256("evidence"));
    }

    function test_ProposeSlash_RevertZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(Errors.InvalidSlashAmount.selector);
        tangle.proposeSlash(serviceId, operator1, 0, keccak256("evidence"));
    }

    function test_ProposeSlash_CalculatesEffectiveAmount() public {
        // First set operator exposure to 50%
        uint64 exposureServiceId = _setupServiceWithExposure(5000);

        // Need to get the service owner to propose slash
        Types.Service memory svc = tangle.getService(exposureServiceId);

        vm.prank(svc.owner);
        uint64 slashId = tangle.proposeSlash(exposureServiceId, operator1, 2000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.slashBps, 2000);
        assertEq(proposal.effectiveSlashBps, 1000); // 50% of 20% = 10%
    }

    function test_ProposeSlash_SetsCorrectExecuteAfter() public {
        uint256 proposalTime = block.timestamp;

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.proposedAt, proposalTime);
        assertEq(proposal.executeAfter, proposalTime + 7 days); // Default dispute window
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DisputeSlash_ByOperator() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(operator1);
        tangle.disputeSlash(slashId, "Invalid evidence");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Disputed));
        assertEq(proposal.disputeReason, "Invalid evidence");
    }

    function test_DisputeSlash_BySlashAdmin() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(admin);
        tangle.disputeSlash(slashId, "Admin review needed");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Disputed));
    }

    function test_DisputeSlash_RevertNotAuthorized() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotSlashDisputer.selector, slashId, user2));
        tangle.disputeSlash(slashId, "reason");
    }

    function test_DisputeSlash_RevertAfterWindowPassed() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Fast forward past dispute window
        vm.warp(block.timestamp + 7 days + 1);

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.DisputeWindowPassed.selector, slashId));
        tangle.disputeSlash(slashId, "Too late");
    }

    function test_DisputeSlash_RevertIfAlreadyExecuted() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotPending.selector, slashId));
        tangle.disputeSlash(slashId, "reason");
    }

    function test_DisputeSlash_AtExactWindowBoundary() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Warp to just before the boundary (dispute window uses >= check)
        vm.warp(block.timestamp + 7 days - 1);

        vm.prank(operator1);
        tangle.disputeSlash(slashId, "At boundary");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Disputed));
    }

    function test_ProposeSlash_ByManagerOriginTriggersHook() public {
        HookedBSM manager = new HookedBSM();
        manager.setAllowedOrigin(managerCaller);
        uint64 managedServiceId = _deployManagedService(address(manager));

        vm.prank(managerCaller);
        tangle.proposeSlash(managedServiceId, operator1, 1000, keccak256("hook"));

        assertEq(manager.lastUnappliedPercent(), 10, "manager notified");
    }

    function test_ExecuteSlashBatch_ManagerHookCalled() public {
        HookedBSM manager = new HookedBSM();
        manager.setAllowedOrigin(user1);
        uint64 managedServiceId = _deployManagedService(address(manager));

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(managedServiceId, operator1, 1000, keccak256("hook"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        uint64[] memory ids = new uint64[](1);
        ids[0] = slashId;
        tangle.executeSlashBatch(ids);

        assertEq(manager.lastExecutedPercent(), 10, "manager onSlash called");
    }

    function _deployManagedService(address manager) internal returns (uint64 svcId) {
        vm.prank(developer);
        uint64 managedBlueprint = tangle.createBlueprint(_blueprintDefinition("ipfs://manager", manager));
        _registerForBlueprint(operator1, managedBlueprint);

        uint64 requestId = _requestService(user1, managedBlueprint, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        svcId = tangle.serviceCount() - 1;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXECUTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExecuteSlash_AfterDisputeWindow() public {
        uint256 stakeBefore = staking.getOperatorSelfStake(operator1);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 2000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed));

        uint256 stakeAfter = staking.getOperatorSelfStake(operator1);
        assertEq(stakeAfter, stakeBefore - 2 ether);
    }

    function test_ExecuteSlash_RevertBeforeWindow() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Try to execute before window
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);
    }

    function test_ExecuteSlash_RevertIfDisputed() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(operator1);
        tangle.disputeSlash(slashId, "disputed");

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);
    }

    function test_ExecuteSlash_RevertDoubleExecution() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);
    }

    function test_ExecuteSlash_AtExactWindowEnd() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // M-6 FIX: Warp to exactly when execution becomes possible (executeAfter + TIMESTAMP_BUFFER)
        vm.warp(block.timestamp + 7 days + 15);

        // Should be executable
        tangle.executeSlash(slashId);

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed));
    }

    function test_ExecuteSlash_AnyoneCanExecute() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        // Random address can execute after window
        vm.prank(address(0xdead));
        tangle.executeSlash(slashId);

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CANCELLATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CancelSlash_ByAdmin() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(admin);
        tangle.cancelSlash(slashId, "Invalid slash");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Cancelled));
    }

    function test_CancelSlash_AfterDispute() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(operator1);
        tangle.disputeSlash(slashId, "disputed");

        vm.prank(admin);
        tangle.cancelSlash(slashId, "Dispute upheld");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Cancelled));
    }

    function test_CancelSlash_RevertNotAdmin() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotSlashCanceller.selector, slashId, user1));
        tangle.cancelSlash(slashId, "reason");
    }

    function test_CancelSlash_RevertAlreadyExecuted() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashAlreadyExecuted.selector, slashId));
        tangle.cancelSlash(slashId, "too late");
    }

    function test_CancelSlash_RevertDoubleCancellation() public {
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(admin);
        tangle.cancelSlash(slashId, "cancelled");

        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashAlreadyCancelled.selector, slashId));
        tangle.cancelSlash(slashId, "again");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTIPLE SLASH TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultipleSlashProposals_SameOperator() public {
        vm.startPrank(user1);
        uint64 slashId1 = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence1"));
        uint64 slashId2 = tangle.proposeSlash(serviceId, operator1, 2000, keccak256("evidence2"));
        uint64 slashId3 = tangle.proposeSlash(serviceId, operator1, 500, keccak256("evidence3"));
        vm.stopPrank();

        assertEq(slashId1, 0);
        assertEq(slashId2, 1);
        assertEq(slashId3, 2);

        // All should be pending
        assertEq(uint8(tangle.getSlashProposal(slashId1).status), uint8(SlashingLib.SlashStatus.Pending));
        assertEq(uint8(tangle.getSlashProposal(slashId2).status), uint8(SlashingLib.SlashStatus.Pending));
        assertEq(uint8(tangle.getSlashProposal(slashId3).status), uint8(SlashingLib.SlashStatus.Pending));
    }

    function test_MultipleSlashProposals_ExecuteAll() public {
        uint256 stakeBefore = staking.getOperatorSelfStake(operator1);
        uint16 slashBps1 = 1000;
        uint16 slashBps2 = 2000;

        vm.startPrank(user1);
        uint64 slashId1 = tangle.proposeSlash(serviceId, operator1, slashBps1, keccak256("e1"));
        uint64 slashId2 = tangle.proposeSlash(serviceId, operator1, slashBps2, keccak256("e2"));
        vm.stopPrank();

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        tangle.executeSlash(slashId1);
        tangle.executeSlash(slashId2);

        uint256 stakeAfter = staking.getOperatorSelfStake(operator1);
        uint256 afterFirst = stakeBefore - ((stakeBefore * slashBps1) / 10_000);
        uint256 expectedAfter = afterFirst - ((afterFirst * slashBps2) / 10_000);
        assertEq(stakeAfter, expectedAfter);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIG TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetSlashConfig_UpdatesDisputeWindow() public {
        vm.prank(admin);
        tangle.setSlashConfig(14 days, false, 10_000);

        // New proposal should use updated window
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.executeAfter, block.timestamp + 14 days);
    }

    function test_SetSlashConfig_RevertInvalidWindow() public {
        // Too short
        vm.prank(admin);
        vm.expectRevert(Errors.InvalidSlashConfig.selector);
        tangle.setSlashConfig(30 minutes, false, 10_000);

        // Too long
        vm.prank(admin);
        vm.expectRevert(Errors.InvalidSlashConfig.selector);
        tangle.setSlashConfig(60 days, false, 10_000);
    }

    function test_SetSlashConfig_RevertInvalidMaxSlash() public {
        vm.prank(admin);
        vm.expectRevert(Errors.InvalidSlashConfig.selector);
        tangle.setSlashConfig(7 days, false, 0);

        vm.prank(admin);
        vm.expectRevert(Errors.InvalidSlashConfig.selector);
        tangle.setSlashConfig(7 days, false, 15_000); // > 100%
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _setupServiceWithExposure(uint16 exposure) internal returns (uint64) {
        vm.prank(developer);
        uint64 bpId = tangle.createBlueprint(_blueprintDefinition("ipfs://exposure", address(0)));

        _directRegisterOperator(operator1, bpId, "");

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = exposure;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 reqId = tangle.requestServiceWithExposure(bpId, ops, exposures, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(reqId, 0);

        return tangle.serviceCount() - 1;
    }
}
