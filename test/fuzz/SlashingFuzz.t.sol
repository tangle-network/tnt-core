// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { SlashingLib } from "../../src/libraries/SlashingLib.sol";

/// @title SlashingFuzzTest
/// @notice Fuzz tests for slashing mechanics with comprehensive balance verification
contract SlashingFuzzTest is BaseTest {
    uint64 blueprintId;
    uint64 serviceId;

    function setUp() public override {
        super.setUp();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://slash-fuzz", address(0)));

        _registerOperator(operator1, 10 ether);
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        serviceId = tangle.serviceCount() - 1;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PROPORTIONAL SLASHING WITH BALANCE VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz: slashing bps correctly reduces balances proportionally
    function testFuzz_ProportionalSlashing_BalancesCorrect(uint256 opStake, uint256 d1Stake, uint16 slashBps) public {
        // Bound inputs to reasonable ranges
        opStake = bound(opStake, MIN_OPERATOR_STAKE, 50 ether);
        d1Stake = bound(d1Stake, MIN_DELEGATION, 50 ether);
        slashBps = uint16(bound(uint256(slashBps), 1, 10_000));

        // Fresh operator setup
        _registerOperator(operator2, opStake);
        _registerForBlueprint(operator2, blueprintId);

        vm.startPrank(delegator1);
        staking.deposit{ value: d1Stake }();
        staking.delegate(operator2, d1Stake);
        vm.stopPrank();

        // Create service
        uint64 reqId = _requestService(user1, blueprintId, operator2);
        vm.prank(operator2);
        tangle.approveService(reqId, 0);
        uint64 svcId = tangle.serviceCount() - 1;

        // Record balances before
        uint256 opBefore = staking.getOperatorSelfStake(operator2);
        uint256 d1Before = staking.getDelegation(delegator1, operator2);
        uint256 totalBefore = opBefore + d1Before;

        // Propose and execute slash
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(svcId, operator2, slashBps, keccak256("fuzz"));
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        // Verify balances after
        uint256 opAfter = staking.getOperatorSelfStake(operator2);
        uint256 d1After = staking.getDelegation(delegator1, operator2);
        uint256 totalAfter = opAfter + d1After;

        // Total slashed should equal bps of total stake
        // Allow 1 wei tolerance for rounding in share-based accounting
        uint256 actualSlashed = totalBefore - totalAfter;
        uint256 expectedSlashed = (totalBefore * slashBps) / 10_000;
        assertApproxEqAbs(actualSlashed, expectedSlashed, 1, "Total slashed incorrect");

        // Operator stake reduced
        assertTrue(opAfter <= opBefore, "Op stake should decrease");

        // Delegator stake reduced (if there was delegated stake)
        if (d1Before > 0) {
            assertTrue(d1After <= d1Before, "D1 stake should decrease");
        }

        // Proportionality check: ratio of remaining stakes should roughly match original
        // Skip ratio check when remaining stake is very small (rounding errors dominate)
        if (totalAfter > 1 ether && opAfter > 0.1 ether && d1After > 0.1 ether) {
            // (opAfter/totalAfter) ≈ (opBefore/totalBefore)
            uint256 opRatioBefore = (opBefore * 1e18) / totalBefore;
            uint256 opRatioAfter = (opAfter * 1e18) / totalAfter;
            // Allow 5% tolerance for rounding in extreme cases
            assertApproxEqRel(opRatioAfter, opRatioBefore, 0.05e18, "Op ratio should be preserved");
        }
    }

    /// @notice Fuzz: multiple delegators slashed proportionally
    function testFuzz_MultipleDelegators_ProportionalSlash(uint256 d1Stake, uint256 d2Stake, uint256 slashPct) public {
        // Bound inputs
        d1Stake = bound(d1Stake, MIN_DELEGATION, 30 ether);
        d2Stake = bound(d2Stake, MIN_DELEGATION, 30 ether);
        slashPct = bound(slashPct, 1, 50); // 1-50% slash

        uint256 opStake = 10 ether;
        uint256 totalStake = opStake + d1Stake + d2Stake;
        uint16 slashBps = uint16(slashPct * 100);

        // Fresh setup
        _registerOperator(operator3, opStake);
        _registerForBlueprint(operator3, blueprintId);

        vm.startPrank(delegator1);
        staking.deposit{ value: d1Stake }();
        staking.delegate(operator3, d1Stake);
        vm.stopPrank();

        vm.startPrank(delegator2);
        staking.deposit{ value: d2Stake }();
        staking.delegate(operator3, d2Stake);
        vm.stopPrank();

        uint64 reqId = _requestService(user1, blueprintId, operator3);
        vm.prank(operator3);
        tangle.approveService(reqId, 0);
        uint64 svcId = tangle.serviceCount() - 1;

        // Record before
        uint256 opBefore = staking.getOperatorSelfStake(operator3);
        uint256 d1Before = staking.getDelegation(delegator1, operator3);
        uint256 d2Before = staking.getDelegation(delegator2, operator3);

        // Slash
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(svcId, operator3, slashBps, keccak256("multi"));
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        // Verify
        uint256 opAfter = staking.getOperatorSelfStake(operator3);
        uint256 d1After = staking.getDelegation(delegator1, operator3);
        uint256 d2After = staking.getDelegation(delegator2, operator3);

        uint256 opSlashed = opBefore - opAfter;
        uint256 d1Slashed = d1Before - d1After;
        uint256 d2Slashed = d2Before - d2After;
        uint256 totalSlashed = opSlashed + d1Slashed + d2Slashed;

        // Total slashed matches (allow 1 wei tolerance for rounding)
        uint256 totalBefore = opBefore + d1Before + d2Before;
        uint256 expectedSlashed = (totalBefore * slashBps) / 10_000;
        assertApproxEqAbs(totalSlashed, expectedSlashed, 1, "Total slashed amount");

        // D1 and D2 slashed proportionally to their stakes
        if (d1Slashed > 0 && d2Slashed > 0) {
            uint256 d1Ratio = (d1Slashed * 1e18) / (d1Slashed + d2Slashed);
            uint256 expectedD1Ratio = (d1Before * 1e18) / (d1Before + d2Before);
            assertApproxEqRel(d1Ratio, expectedD1Ratio, 0.01e18, "D1 slash ratio");
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE SCALING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz: exposure scaling correctly reduces effective slash
    function testFuzz_ExposureScaling_ReducesSlash(uint16 slashBps, uint16 exposure) public {
        // Bound to minimum 100 each so that effectiveBps = slashBps * exposure / 10000 >= 1
        // This avoids InvalidSlashAmount when the product rounds to 0
        slashBps = uint16(bound(uint256(slashBps), 100, 10_000));
        exposure = uint16(bound(uint256(exposure), 100, 10_000));

        // Create service with exposure
        _registerOperator(operator2, 10 ether);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator2;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = exposure;

        vm.prank(user1);
        uint64 reqId =
            tangle.requestServiceWithExposure(blueprintId, ops, exposures, "", new address[](0), 0, address(0), 0);
        vm.prank(operator2);
        tangle.approveService(reqId, 0);
        uint64 svcId = tangle.serviceCount() - 1;

        uint256 stakeBefore = staking.getOperatorSelfStake(operator2);

        // Propose slash
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(svcId, operator2, slashBps, keccak256("exp"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        uint256 expectedEffective = (uint256(slashBps) * exposure) / 10_000;

        // Verify proposal storage
        assertEq(proposal.slashBps, slashBps, "Proposed bps stored");
        assertEq(proposal.effectiveSlashBps, expectedEffective, "Effective bps scaled");

        // Execute and verify balance
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        uint256 stakeAfter = staking.getOperatorSelfStake(operator2);
        uint256 actualSlashed = stakeBefore - stakeAfter;

        // Only effective amount should be slashed
        uint256 expectedSlashed = (stakeBefore * expectedEffective) / 10_000;
        assertEq(actualSlashed, expectedSlashed, "Only effective amount slashed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONCURRENT SLASHES WITH BALANCE TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz: multiple concurrent slashes correctly cumulate
    function testFuzz_ConcurrentSlashes_CumulativeBalance(uint8 slashCount) public {
        slashCount = uint8(bound(uint256(slashCount), 1, 5));
        uint16 slashBpsPerRound = 500;

        uint256 stakeBefore = staking.getOperatorSelfStake(operator1);
        uint64[] memory slashIds = new uint64[](slashCount);

        // Create all slash proposals
        for (uint8 i = 0; i < slashCount; i++) {
            vm.prank(user1);
            slashIds[i] = tangle.proposeSlash(
                serviceId, operator1, slashBpsPerRound, keccak256(abi.encodePacked("concurrent", i))
            );
        }

        // Verify all pending
        for (uint8 i = 0; i < slashCount; i++) {
            SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashIds[i]);
            assertEq(uint8(p.status), uint8(SlashingLib.SlashStatus.Pending), "Should be pending");
        }

        // Execute all
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        for (uint8 i = 0; i < slashCount; i++) {
            tangle.executeSlash(slashIds[i]);
        }

        // Verify cumulative effect
        uint256 stakeAfter = staking.getOperatorSelfStake(operator1);
        uint256 actualSlashed = stakeBefore - stakeAfter;

        uint256 expectedStake = stakeBefore;
        for (uint8 i = 0; i < slashCount; i++) {
            expectedStake -= (expectedStake * slashBpsPerRound) / 10_000;
        }
        uint256 expectedSlashed = stakeBefore - expectedStake;
        assertApproxEqAbs(actualSlashed, expectedSlashed, 1, "Cumulative slash correct");

        // Verify all executed
        for (uint8 i = 0; i < slashCount; i++) {
            SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashIds[i]);
            assertEq(uint8(p.status), uint8(SlashingLib.SlashStatus.Executed), "Should be executed");
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE WINDOW TIMING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz: dispute window timing is enforced correctly
    function testFuzz_DisputeWindow_Enforcement(uint64 disputeWindow) public {
        disputeWindow = uint64(bound(uint256(disputeWindow), 1 hours, 30 days));

        vm.prank(admin);
        tangle.setSlashConfig(disputeWindow, false, 10_000);

        uint256 stakeBefore = staking.getOperatorSelfStake(operator1);
        uint256 proposalTime = block.timestamp;

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("timing"));

        // Verify proposal storage
        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.proposedAt, proposalTime, "Proposal timestamp");
        assertEq(proposal.executeAfter, proposalTime + disputeWindow, "Execute after");

        // Try execute 1 second before window ends - should fail
        vm.warp(proposalTime + disputeWindow - 1);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);

        // Balance unchanged
        assertEq(staking.getOperatorSelfStake(operator1), stakeBefore, "Balance unchanged before window");

        // Execute exactly at window end - should succeed
        vm.warp(proposalTime + disputeWindow);
        tangle.executeSlash(slashId);

        // Balance now reduced
        uint256 expectedSlash = (stakeBefore * 1000) / 10_000;
        assertEq(staking.getOperatorSelfStake(operator1), stakeBefore - expectedSlash, "Balance reduced after execute");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH CAPS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz: slash bps are capped by maxSlashBps
    function testFuzz_SlashCaps_AtMaxBps(uint16 proposedBps) public {
        proposedBps = uint16(bound(uint256(proposedBps), 1, 10_000));

        vm.prank(admin);
        tangle.setSlashConfig(7 days, false, 3000);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, proposedBps, keccak256("cap"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        uint16 expected = proposedBps > 3000 ? 3000 : proposedBps;
        assertEq(proposal.slashBps, expected, "Slash bps should be capped by max");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIG VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz: invalid config reverts
    function testFuzz_InvalidConfig_Reverts(uint64 disputeWindow, uint16 maxSlashBps) public {
        bool invalidWindow = disputeWindow < 1 hours || disputeWindow > 30 days;
        bool invalidMax = maxSlashBps == 0 || maxSlashBps > 10_000;

        if (invalidWindow || invalidMax) {
            vm.prank(admin);
            vm.expectRevert(Errors.InvalidSlashConfig.selector);
            tangle.setSlashConfig(disputeWindow, false, maxSlashBps);
        } else {
            // Valid config should succeed
            vm.prank(admin);
            tangle.setSlashConfig(disputeWindow, false, maxSlashBps);
        }
    }

    /// @notice Fuzz: valid config is applied
    function testFuzz_ValidConfig_Applied(uint64 disputeWindow, uint16 maxSlashBps) public {
        disputeWindow = uint64(bound(uint256(disputeWindow), 1 hours, 30 days));
        maxSlashBps = uint16(bound(uint256(maxSlashBps), 1, 10_000));

        vm.prank(admin);
        tangle.setSlashConfig(disputeWindow, false, maxSlashBps);

        // Verify config applied by creating slash with new window
        uint256 proposalTime = block.timestamp;
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 100, keccak256("cfg"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.executeAfter, proposalTime + disputeWindow, "Config applied");
    }
}
