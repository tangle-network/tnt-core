// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { Errors } from "../../src/v2/libraries/Errors.sol";
import { SlashingLib } from "../../src/v2/libraries/SlashingLib.sol";
import { DelegationErrors } from "../../src/v2/restaking/DelegationErrors.sol";
import { IBlueprintServiceManager } from "../../src/v2/interfaces/IBlueprintServiceManager.sol";
import { BlueprintServiceManagerBase } from "../../src/v2/BlueprintServiceManagerBase.sol";
import { ITangle, ITangleFull } from "../../src/v2/interfaces/ITangle.sol";

/// @title EndToEndSlashingTest
/// @notice Comprehensive E2E tests verifying all balance changes during slashing
contract EndToEndSlashingTest is BaseTest {
    ChallengingSquareBSM public challengeBSM;

    function setUp() public override {
        super.setUp();
        challengeBSM = new ChallengingSquareBSM();
    }

    /// @notice Full E2E: Proportional slashing with exact balance verification for all parties
    function test_E2E_ProportionalSlashing_AllBalancesVerified() public {
        // Setup blueprint
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://slash-test", address(0));

        // Operator: 10 ETH
        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        // Delegator1: 20 ETH, Delegator2: 30 ETH (total pool = 60 ETH)
        vm.startPrank(delegator1);
        restaking.deposit{ value: 20 ether }();
        restaking.delegate(operator1, 20 ether);
        vm.stopPrank();

        vm.startPrank(delegator2);
        restaking.deposit{ value: 30 ether }();
        restaking.delegate(operator1, 30 ether);
        vm.stopPrank();

        // Record ALL balances before slash
        uint256 opBefore = restaking.getOperatorSelfStake(operator1);
        uint256 d1Before = restaking.getDelegation(delegator1, operator1);
        uint256 d2Before = restaking.getDelegation(delegator2, operator1);
        uint256 totalBefore = opBefore + d1Before + d2Before;

        assertEq(opBefore, 10 ether, "Pre: Op=10 ETH");
        assertEq(d1Before, 20 ether, "Pre: D1=20 ETH");
        assertEq(d2Before, 30 ether, "Pre: D2=30 ETH");
        assertEq(totalBefore, 60 ether, "Pre: Total=60 ETH");

        // Create service and propose slash
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = 0;

        // Slash 6 ETH (10% of total)
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 6 ether, keccak256("evidence"));

        // Verify proposal storage
        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.amount, 6 ether, "Proposal: amount=6 ETH");
        assertEq(proposal.effectiveAmount, 6 ether, "Proposal: effective=6 ETH (100% exposure)");
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Pending), "Proposal: Pending");

        // Execute slash after dispute window
        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Verify proposal status updated
        proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Executed), "Proposal: Executed");

        // Calculate expected slashing:
        // Total = 60 ETH, Slash = 6 ETH
        // Operator: 6 * 10/60 = 1 ETH slashed → 9 ETH remaining
        // Delegators: 6 - 1 = 5 ETH (split by 20:30 ratio)
        // D1: 5 * 20/50 = 2 ETH slashed → 18 ETH remaining
        // D2: 5 * 30/50 = 3 ETH slashed → 27 ETH remaining

        uint256 opAfter = restaking.getOperatorSelfStake(operator1);
        uint256 d1After = restaking.getDelegation(delegator1, operator1);
        uint256 d2After = restaking.getDelegation(delegator2, operator1);
        uint256 totalAfter = opAfter + d1After + d2After;

        assertEq(opAfter, 9 ether, "Post: Op=9 ETH (slashed 1)");
        assertEq(d1After, 18 ether, "Post: D1=18 ETH (slashed 2)");
        assertEq(d2After, 27 ether, "Post: D2=27 ETH (slashed 3)");
        assertEq(totalAfter, 54 ether, "Post: Total=54 ETH");
        assertEq(totalBefore - totalAfter, 6 ether, "Exactly 6 ETH slashed");
    }

    /// @notice Multi-operator: slashing one doesn't affect others' balances
    function test_E2E_MultiOperator_IsolatedSlashing() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://multi-op", address(0));

        // Op1: 10 ETH, Op2: 8 ETH
        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        vm.prank(operator2);
        restaking.registerOperator{ value: 8 ether }();
        vm.prank(operator2);
        tangle.registerOperator(blueprintId, "", "");

        // D1 delegates 10 ETH to each operator
        vm.startPrank(delegator1);
        restaking.deposit{ value: 20 ether }();
        restaking.delegate(operator1, 10 ether);
        restaking.delegate(operator2, 10 ether);
        vm.stopPrank();

        // Record ALL balances
        uint256 op1Before = restaking.getOperatorSelfStake(operator1);
        uint256 op2Before = restaking.getOperatorSelfStake(operator2);
        uint256 d1ToOp1Before = restaking.getDelegation(delegator1, operator1);
        uint256 d1ToOp2Before = restaking.getDelegation(delegator1, operator2);

        // Create service with both operators
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", new address[](0), 0, address(0), 0);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // Slash ONLY operator1 for 4 ETH
        // Op1 pool = 20 ETH (10 self + 10 delegated)
        // Op1 loses: 4 * 10/20 = 2 ETH
        // D1->Op1 loses: 4 * 10/20 = 2 ETH
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 4 ether, keccak256("op1_fault"));
        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Verify Op1 pool slashed
        assertEq(restaking.getOperatorSelfStake(operator1), 8 ether, "Op1: 10-2=8 ETH");
        assertEq(restaking.getDelegation(delegator1, operator1), 8 ether, "D1->Op1: 10-2=8 ETH");

        // Verify Op2 pool UNCHANGED
        assertEq(restaking.getOperatorSelfStake(operator2), op2Before, "Op2: unchanged");
        assertEq(restaking.getDelegation(delegator1, operator2), d1ToOp2Before, "D1->Op2: unchanged");
    }

    /// @notice Challenge flow: verify invalid square result and slash signers
    function test_E2E_Challenge_InvalidSquare_SlashesOperator() public {
        // Setup blueprint with challenge BSM
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://square", address(challengeBSM));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        vm.startPrank(delegator1);
        restaking.deposit{ value: 20 ether }();
        restaking.delegate(operator1, 20 ether);
        vm.stopPrank();

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = 0;

        // Submit job: square(5) should = 25
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, abi.encode(uint256(5)));

        // Record balances before challenge
        uint256 opBefore = restaking.getOperatorSelfStake(operator1);
        uint256 d1Before = restaking.getDelegation(delegator1, operator1);

        // Operator submits WRONG result: 26 instead of 25
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, abi.encode(uint256(26)));

        // BSM should have recorded the invalid result
        assertTrue(challengeBSM.invalidResults(serviceId, callId), "BSM detected invalid result");

        // Anyone can challenge - BSM verifies and proposes slash
        vm.prank(user2); // Random user challenges
        uint64 slashId = challengeBSM.challenge(serviceId, callId);

        // Verify slash proposal created
        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.operator, operator1, "Slash targets operator1");
        assertEq(proposal.amount, 3 ether, "Slash amount = 3 ETH (CHALLENGE_SLASH_AMOUNT)");

        // Execute slash
        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Verify proportional slashing: 30 ETH total, 3 ETH slash
        // Op: 3 * 10/30 = 1 ETH → 9 ETH
        // D1: 3 * 20/30 = 2 ETH → 18 ETH
        assertEq(restaking.getOperatorSelfStake(operator1), 9 ether, "Op: 10-1=9 ETH");
        assertEq(restaking.getDelegation(delegator1, operator1), 18 ether, "D1: 20-2=18 ETH");
    }

    /// @notice Valid result cannot be challenged
    function test_E2E_Challenge_ValidResult_Reverts() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://square", address(challengeBSM));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Submit job: square(5) = 25
        vm.prank(user1);
        uint64 callId = tangle.submitJob(0, 0, abi.encode(uint256(5)));

        // Operator submits CORRECT result: 25
        vm.prank(operator1);
        tangle.submitResult(0, callId, abi.encode(uint256(25)));

        // Result should be valid
        assertFalse(challengeBSM.invalidResults(0, callId), "Result is valid");

        // Challenge should revert
        vm.expectRevert("Result is valid");
        challengeBSM.challenge(0, callId);
    }

    /// @notice Cumulative slashing: multiple slashes deplete stake
    function test_E2E_CumulativeSlashing_DepletesStake() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://cumulative", address(0));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 baseTime = block.timestamp;

        // First slash: 3 ETH
        vm.prank(user1);
        uint64 slash1 = tangle.proposeSlash(0, operator1, 3 ether, keccak256("e1"));
        vm.warp(baseTime + 8 days);
        tangle.executeSlash(slash1);
        assertEq(restaking.getOperatorSelfStake(operator1), 7 ether, "After slash1: 7 ETH");

        // Second slash: 3 ETH (propose at new time)
        vm.prank(user1);
        uint64 slash2 = tangle.proposeSlash(0, operator1, 3 ether, keccak256("e2"));
        vm.warp(baseTime + 16 days);
        tangle.executeSlash(slash2);
        assertEq(restaking.getOperatorSelfStake(operator1), 4 ether, "After slash2: 4 ETH");

        // Third slash: 3 ETH (propose at new time)
        vm.prank(user1);
        uint64 slash3 = tangle.proposeSlash(0, operator1, 3 ether, keccak256("e3"));
        vm.warp(baseTime + 24 days);
        tangle.executeSlash(slash3);
        assertEq(restaking.getOperatorSelfStake(operator1), 1 ether, "After slash3: 1 ETH");

        // Fourth slash: 5 ETH (caps at remaining 1 ETH)
        vm.prank(user1);
        uint64 slash4 = tangle.proposeSlash(0, operator1, 5 ether, keccak256("e4"));
        vm.warp(baseTime + 32 days);
        tangle.executeSlash(slash4);
        assertEq(restaking.getOperatorSelfStake(operator1), 0, "After slash4: 0 ETH (capped)");
    }

    /// @notice Slashing with exposure scaling
    function test_E2E_ExposureScaling_ReducesEffectiveSlash() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://exposure", address(0));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        // Create service with 50% exposure
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 5000; // 50%

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure(blueprintId, ops, exposures, "", new address[](0), 0, address(0), 0);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Propose 6 ETH slash, but effective = 3 ETH (50%)
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 6 ether, keccak256("ev"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.amount, 6 ether, "Proposed: 6 ETH");
        assertEq(proposal.effectiveAmount, 3 ether, "Effective: 3 ETH (50%)");

        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Only 3 ETH actually slashed
        assertEq(restaking.getOperatorSelfStake(operator1), 7 ether, "Post: 10-3=7 ETH");
    }

    /// @notice Slashing below minimum deactivates operator
    function test_E2E_SlashBelowMinimum_DeactivatesOperator() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://deactivate", address(0));

        // Register with exactly minimum + buffer
        vm.prank(operator1);
        restaking.registerOperator{ value: MIN_OPERATOR_STAKE + 0.5 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Slash to go below minimum
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 0.75 ether, keccak256("ev"));
        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Verify operator deactivated - new delegations fail
        vm.startPrank(delegator1);
        restaking.deposit{ value: 5 ether }();
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.OperatorNotActive.selector, operator1));
        restaking.delegate(operator1, 5 ether);
        vm.stopPrank();
    }

    /// @notice Dispute prevents execution
    function test_E2E_Dispute_PreventsExecution() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://dispute", address(0));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 stakeBefore = restaking.getOperatorSelfStake(operator1);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 2 ether, keccak256("ev"));

        // Operator disputes
        vm.prank(operator1);
        tangle.disputeSlash(slashId, "Invalid evidence");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Disputed));

        // Try to execute after window - should fail
        vm.warp(block.timestamp + 7 days + 1);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);

        // Stake unchanged
        assertEq(restaking.getOperatorSelfStake(operator1), stakeBefore, "Stake unchanged after dispute");
    }

    /// @notice Verify slashing is recorded in metrics recorder (for rewards deduction)
    function test_E2E_SlashingRecordedInMetrics() public {
        MockMetricsRecorder mockMetrics = new MockMetricsRecorder();

        // Set metrics recorder on Tangle
        vm.prank(admin);
        tangle.setMetricsRecorder(address(mockMetrics));

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://metrics", address(0));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = 0;

        // Propose and execute slash for 3 ETH
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 3 ether, keccak256("evidence"));
        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Verify metrics recorder was called with correct values
        assertEq(mockMetrics.slashCount(), 1, "recordSlash should be called once");
        assertEq(mockMetrics.lastSlashedOperator(), operator1, "Correct operator recorded");
        assertEq(mockMetrics.lastSlashedServiceId(), serviceId, "Correct serviceId recorded");
        assertEq(mockMetrics.lastSlashedAmount(), 3 ether, "Correct amount recorded");
    }

    /// @notice Verify batch slashing records all slashes in metrics
    function test_E2E_BatchSlashingRecordedInMetrics() public {
        MockMetricsRecorder mockMetrics = new MockMetricsRecorder();

        vm.prank(admin);
        tangle.setMetricsRecorder(address(mockMetrics));

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://batch-metrics", address(0));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "", "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = 0;

        // Create 3 slash proposals
        uint64[] memory slashIds = new uint64[](3);
        vm.startPrank(user1);
        slashIds[0] = tangle.proposeSlash(serviceId, operator1, 1 ether, keccak256("e1"));
        slashIds[1] = tangle.proposeSlash(serviceId, operator1, 1.5 ether, keccak256("e2"));
        slashIds[2] = tangle.proposeSlash(serviceId, operator1, 0.5 ether, keccak256("e3"));
        vm.stopPrank();

        // Execute batch
        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlashBatch(slashIds);

        // Verify all 3 slashes recorded in metrics
        assertEq(mockMetrics.slashCount(), 3, "recordSlash should be called 3 times");
        assertEq(mockMetrics.totalSlashedAmount(), 3 ether, "Total slashed amount correct");
    }
}

/// @title MockMetricsRecorder
/// @notice Mock for testing metrics recording of slash events
contract MockMetricsRecorder {
    uint256 public slashCount;
    address public lastSlashedOperator;
    uint64 public lastSlashedServiceId;
    uint256 public lastSlashedAmount;
    uint256 public totalSlashedAmount;

    function recordSlash(address operator, uint64 serviceId, uint256 amount) external {
        slashCount++;
        lastSlashedOperator = operator;
        lastSlashedServiceId = serviceId;
        lastSlashedAmount = amount;
        totalSlashedAmount += amount;
    }

    // Stub remaining IMetricsRecorder functions
    function recordStake(address, address, address, uint256) external {}
    function recordUnstake(address, address, address, uint256) external {}
    function recordOperatorRegistered(address, address, uint256) external {}
    function recordHeartbeat(address, uint64, uint64) external {}
    function recordJobCompletion(address, uint64, uint64, bool) external {}
    function recordServiceCreated(uint64, uint64, address, uint256) external {}
    function recordServiceTerminated(uint64, uint256) external {}
    function recordJobCall(uint64, address, uint64) external {}
    function recordPayment(address, uint64, address, uint256) external {}
    function recordBlueprintCreated(uint64, address) external {}
    function recordBlueprintRegistration(uint64, address) external {}
}

/// @title ChallengingSquareBSM
/// @notice BSM that validates square(x) results and allows anyone to challenge invalid results
contract ChallengingSquareBSM is BlueprintServiceManagerBase {
    uint256 public constant CHALLENGE_SLASH_AMOUNT = 3 ether;

    // serviceId => callId => input
    mapping(uint64 => mapping(uint64 => uint256)) public jobInputs;
    // serviceId => callId => output
    mapping(uint64 => mapping(uint64 => uint256)) public jobOutputs;
    // serviceId => callId => operator who submitted
    mapping(uint64 => mapping(uint64 => address)) public resultSubmitters;
    // serviceId => callId => is invalid
    mapping(uint64 => mapping(uint64 => bool)) public invalidResults;
    // serviceId => callId => already challenged
    mapping(uint64 => mapping(uint64 => bool)) public challenged;

    function onBlueprintCreated(uint64 _blueprintId, address _owner, address _tangleCore) external override {
        blueprintId = _blueprintId;
        blueprintOwner = _owner;
        tangleCore = _tangleCore;
    }

    function onRegister(address, bytes calldata) external payable override {}
    function onRequest(uint64, address, address[] calldata, bytes calldata, uint64, address, uint256) external payable override {}
    function onApprove(address, uint64, uint8) external payable override {}
    function onServiceInitialized(uint64, uint64, uint64, address, address[] calldata, uint64) external override {}

    function onJobCall(uint64 serviceId, uint8, uint64 callId, bytes calldata inputs) external payable override {
        jobInputs[serviceId][callId] = abi.decode(inputs, (uint256));
    }

    function onJobResult(
        uint64 serviceId,
        uint8,
        uint64 callId,
        address operator,
        bytes calldata,
        bytes calldata outputs
    ) external payable override {
        uint256 output = abi.decode(outputs, (uint256));
        uint256 input = jobInputs[serviceId][callId];

        jobOutputs[serviceId][callId] = output;
        resultSubmitters[serviceId][callId] = operator;

        // Check if result is invalid (output != input^2)
        if (output != input * input) {
            invalidResults[serviceId][callId] = true;
        }
    }

    /// @notice Anyone can challenge an invalid result
    /// @return slashId The ID of the slash proposal created
    function challenge(uint64 serviceId, uint64 callId) external returns (uint64) {
        require(!challenged[serviceId][callId], "Already challenged");
        require(invalidResults[serviceId][callId], "Result is valid");

        challenged[serviceId][callId] = true;
        address operator = resultSubmitters[serviceId][callId];

        // Propose slash via Tangle (use ITangleFull which includes slashing)
        return ITangleFull(tangleCore).proposeSlash(
            serviceId,
            operator,
            CHALLENGE_SLASH_AMOUNT,
            keccak256(abi.encode("invalid_square", callId, jobInputs[serviceId][callId], jobOutputs[serviceId][callId]))
        );
    }

    function querySlashingOrigin(uint64) external view override returns (address) {
        return address(this); // BSM can propose slashes
    }
}
