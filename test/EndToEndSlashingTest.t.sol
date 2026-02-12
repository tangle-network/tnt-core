// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../src/libraries/Types.sol";
import { Errors } from "../src/libraries/Errors.sol";
import { SlashingLib } from "../src/libraries/SlashingLib.sol";
import { DelegationErrors } from "../src/staking/DelegationErrors.sol";
import { IBlueprintServiceManager } from "../src/interfaces/IBlueprintServiceManager.sol";
import { BlueprintServiceManagerBase } from "../src/BlueprintServiceManagerBase.sol";
import { ITangle, ITangleFull } from "../src/interfaces/ITangle.sol";

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
        uint64 blueprintId = _createBlueprintAsSender("ipfs://slash-test", address(0));

        // Operator: 10 ETH
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        // Delegator1: 20 ETH, Delegator2: 30 ETH (total pool = 60 ETH)
        vm.startPrank(delegator1);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator1, 20 ether);
        vm.stopPrank();

        vm.startPrank(delegator2);
        staking.deposit{ value: 30 ether }();
        staking.delegate(operator1, 30 ether);
        vm.stopPrank();

        // Record ALL balances before slash
        uint256 opBefore = staking.getOperatorSelfStake(operator1);
        uint256 d1Before = staking.getDelegation(delegator1, operator1);
        uint256 d2Before = staking.getDelegation(delegator2, operator1);
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

        // Slash 10% (1000 bps) of total
        vm.prank(user1);
        uint16 slashBps = 1000;
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, slashBps, keccak256("evidence"));

        // Verify proposal storage
        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.slashBps, slashBps, "Proposal: slashBps=1000");
        assertEq(proposal.effectiveSlashBps, slashBps, "Proposal: effectiveSlashBps=1000");
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Pending), "Proposal: Pending");

        // Execute slash after dispute window
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
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

        uint256 opAfter = staking.getOperatorSelfStake(operator1);
        uint256 d1After = staking.getDelegation(delegator1, operator1);
        uint256 d2After = staking.getDelegation(delegator2, operator1);
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
        uint64 blueprintId = _createBlueprintAsSender("ipfs://multi-op", address(0));

        // Op1: 10 ETH, Op2: 8 ETH
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        vm.prank(operator2);
        staking.registerOperator{ value: 8 ether }();
        vm.prank(operator2);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator2, blueprintId, "");

        // D1 delegates 10 ETH to each operator
        vm.startPrank(delegator1);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator1, 10 ether);
        staking.delegate(operator2, 10 ether);
        vm.stopPrank();

        // Record ALL balances
        uint256 op1Before = staking.getOperatorSelfStake(operator1);
        uint256 op2Before = staking.getOperatorSelfStake(operator2);
        uint256 d1ToOp1Before = staking.getDelegation(delegator1, operator1);
        uint256 d1ToOp2Before = staking.getDelegation(delegator1, operator2);

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

        // Slash ONLY operator1 for 20% (2000 bps)
        // Op1 pool = 20 ETH (10 self + 10 delegated)
        // Op1 loses: 4 * 10/20 = 2 ETH
        // D1->Op1 loses: 4 * 10/20 = 2 ETH
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 2000, keccak256("op1_fault"));
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        // Verify Op1 pool slashed
        assertEq(staking.getOperatorSelfStake(operator1), 8 ether, "Op1: 10-2=8 ETH");
        assertEq(staking.getDelegation(delegator1, operator1), 8 ether, "D1->Op1: 10-2=8 ETH");

        // Verify Op2 pool UNCHANGED
        assertEq(staking.getOperatorSelfStake(operator2), op2Before, "Op2: unchanged");
        assertEq(staking.getDelegation(delegator1, operator2), d1ToOp2Before, "D1->Op2: unchanged");
    }

    /// @notice Challenge flow: verify invalid square result and slash signers
    function test_E2E_Challenge_InvalidSquare_SlashesOperator() public {
        // Setup blueprint with challenge BSM
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://square", address(challengeBSM));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        vm.startPrank(delegator1);
        staking.deposit{ value: 20 ether }();
        staking.delegate(operator1, 20 ether);
        vm.stopPrank();

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = 0;

        // Submit job: square(5) should = 25
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, abi.encode(uint256(5)));

        // Record balances before challenge
        uint256 opBefore = staking.getOperatorSelfStake(operator1);
        uint256 d1Before = staking.getDelegation(delegator1, operator1);

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
        assertEq(proposal.slashBps, challengeBSM.CHALLENGE_SLASH_BPS(), "Slash bps = 1000 (CHALLENGE_SLASH_BPS)");

        // Execute slash
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        // Verify proportional slashing: 30 ETH total, 3 ETH slash
        // Op: 3 * 10/30 = 1 ETH → 9 ETH
        // D1: 3 * 20/30 = 2 ETH → 18 ETH
        assertEq(staking.getOperatorSelfStake(operator1), 9 ether, "Op: 10-1=9 ETH");
        assertEq(staking.getDelegation(delegator1, operator1), 18 ether, "D1: 20-2=18 ETH");
    }

    /// @notice Valid result cannot be challenged
    function test_E2E_Challenge_ValidResult_Reverts() public {
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://square", address(challengeBSM));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

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
        uint64 blueprintId = _createBlueprintAsSender("ipfs://cumulative", address(0));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 baseTime = block.timestamp;

        // First slash: 30% (3 ETH)
        vm.prank(user1);
        uint64 slash1 = tangle.proposeSlash(0, operator1, 3000, keccak256("e1"));
        vm.warp(baseTime + 8 days);
        tangle.executeSlash(slash1);
        assertEq(staking.getOperatorSelfStake(operator1), 7 ether, "After slash1: 7 ETH");

        // Second slash: 50% of 7 ETH = 3.5 ETH slashed
        vm.prank(user1);
        uint64 slash2 = tangle.proposeSlash(0, operator1, 5000, keccak256("e2"));
        vm.warp(baseTime + 16 days);
        tangle.executeSlash(slash2);
        assertEq(staking.getOperatorSelfStake(operator1), 3.5 ether, "After slash2: 3.5 ETH");

        // Third slash: 75% of 3.5 ETH = 2.625 ETH slashed
        vm.prank(user1);
        uint64 slash3 = tangle.proposeSlash(0, operator1, 7500, keccak256("e3"));
        vm.warp(baseTime + 24 days);
        tangle.executeSlash(slash3);
        assertEq(staking.getOperatorSelfStake(operator1), 0.875 ether, "After slash3: 0.875 ETH");

        // Fourth slash: 100% (caps at remaining 1 ETH)
        vm.prank(user1);
        uint64 slash4 = tangle.proposeSlash(0, operator1, 10_000, keccak256("e4"));
        vm.warp(baseTime + 32 days);
        tangle.executeSlash(slash4);
        assertEq(staking.getOperatorSelfStake(operator1), 0, "After slash4: 0 ETH (capped)");
    }

    /// @notice Slashing with exposure scaling
    function test_E2E_ExposureScaling_ReducesEffectiveSlash() public {
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://exposure", address(0));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        // Create service with 50% exposure
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 5000; // 50%

        vm.prank(user1);
        uint64 requestId =
            tangle.requestServiceWithExposure(blueprintId, ops, exposures, "", new address[](0), 0, address(0), 0);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Propose 60% slash, but effective = 30% (50% exposure)
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 6000, keccak256("ev"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(proposal.slashBps, 6000, "Proposed: 6000 bps");
        assertEq(proposal.effectiveSlashBps, 3000, "Effective: 3000 bps (50%)");

        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        // Only 3 ETH actually slashed
        assertEq(staking.getOperatorSelfStake(operator1), 7 ether, "Post: 10-3=7 ETH");
    }

    /// @notice Slashing below minimum deactivates operator
    function test_E2E_SlashBelowMinimum_DeactivatesOperator() public {
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://deactivate", address(0));

        // Register with exactly minimum + buffer
        vm.prank(operator1);
        staking.registerOperator{ value: MIN_OPERATOR_STAKE + 0.5 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Slash to go below minimum (50%)
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 5000, keccak256("ev"));
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashId);

        // Verify operator deactivated - new delegations fail
        vm.startPrank(delegator1);
        staking.deposit{ value: 5 ether }();
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.OperatorNotActive.selector, operator1));
        staking.delegate(operator1, 5 ether);
        vm.stopPrank();
    }

    /// @notice Dispute prevents execution
    function test_E2E_Dispute_PreventsExecution() public {
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://dispute", address(0));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 stakeBefore = staking.getOperatorSelfStake(operator1);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(0, operator1, 2000, keccak256("ev"));

        // Operator disputes
        vm.prank(operator1);
        tangle.disputeSlash(slashId, "Invalid evidence");

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
        assertEq(uint8(proposal.status), uint8(SlashingLib.SlashStatus.Disputed));

        // Try to execute after window - should fail
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        vm.expectRevert(abi.encodeWithSelector(Errors.SlashNotExecutable.selector, slashId));
        tangle.executeSlash(slashId);

        // Stake unchanged
        assertEq(staking.getOperatorSelfStake(operator1), stakeBefore, "Stake unchanged after dispute");
    }

    /// @notice Verify slashing is recorded in metrics recorder (for rewards deduction)
    function test_E2E_SlashingRecordedInMetrics() public {
        MockMetricsRecorder mockMetrics = new MockMetricsRecorder();

        // Set metrics recorder on Tangle
        vm.prank(admin);
        tangle.setMetricsRecorder(address(mockMetrics));

        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://metrics", address(0));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = 0;

        // Propose and execute slash for 30% (3 ETH)
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 3000, keccak256("evidence"));
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
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
        uint64 blueprintId = _createBlueprintAsSender("ipfs://batch-metrics", address(0));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = 0;

        // Create 3 slash proposals
        uint64[] memory slashIds = new uint64[](3);
        vm.startPrank(user1);
        slashIds[0] = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("e1"));
        slashIds[1] = tangle.proposeSlash(serviceId, operator1, 1500, keccak256("e2"));
        slashIds[2] = tangle.proposeSlash(serviceId, operator1, 500, keccak256("e3"));
        vm.stopPrank();

        // Execute batch
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlashBatch(slashIds);

        // Verify all 3 slashes recorded in metrics
        // Cumulative slashing: 10% of 10 = 1, 15% of 9 = 1.35, 5% of 7.65 = 0.3825
        // Total = 2.7325 ETH
        assertEq(mockMetrics.slashCount(), 3, "recordSlash should be called 3 times");
        assertEq(mockMetrics.totalSlashedAmount(), 2.7325 ether, "Total slashed amount correct");
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
    function recordStake(address, address, address, uint256) external { }
    function recordUnstake(address, address, address, uint256) external { }
    function recordOperatorRegistered(address, address, uint256) external { }
    function recordHeartbeat(address, uint64, uint64) external { }
    function recordJobCompletion(address, uint64, uint64, bool) external { }
    function recordServiceCreated(uint64, uint64, address, uint256) external { }
    function recordServiceTerminated(uint64, uint256) external { }
    function recordJobCall(uint64, address, uint64) external { }
    function recordPayment(address, uint64, address, uint256) external { }
    function recordBlueprintCreated(uint64, address) external { }
    function recordBlueprintRegistration(uint64, address) external { }
}

/// @title ChallengingSquareBSM
/// @notice BSM that validates square(x) results and allows anyone to challenge invalid results
contract ChallengingSquareBSM is BlueprintServiceManagerBase {
    uint16 public constant CHALLENGE_SLASH_BPS = 1000;

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

    function onRegister(address, bytes calldata) external payable override { }
    function onRequest(
        uint64,
        address,
        address[] calldata,
        bytes calldata,
        uint64,
        address,
        uint256
    )
        external
        payable
        override
    { }
    function onApprove(address, uint64, uint8) external payable override { }
    function onServiceInitialized(uint64, uint64, uint64, address, address[] calldata, uint64) external override { }

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
    )
        external
        payable
        override
    {
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
        return ITangleFull(tangleCore)
            .proposeSlash(
                serviceId,
                operator,
                CHALLENGE_SLASH_BPS,
                keccak256(
                    abi.encode("invalid_square", callId, jobInputs[serviceId][callId], jobOutputs[serviceId][callId])
                )
            );
    }

    function querySlashingOrigin(uint64) external view override returns (address) {
        return address(this); // BSM can propose slashes
    }
}
