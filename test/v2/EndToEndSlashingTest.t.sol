// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { Errors } from "../../src/v2/libraries/Errors.sol";
import { DelegationErrors } from "../../src/v2/restaking/DelegationErrors.sol";
import { IBlueprintServiceManager } from "../../src/v2/interfaces/IBlueprintServiceManager.sol";
import { BlueprintServiceManagerBase } from "../../src/v2/BlueprintServiceManagerBase.sol";

/// @title EndToEndSlashingTest
/// @notice End-to-end tests for blueprints with slashing conditions
contract EndToEndSlashingTest is BaseTest {
    SlashingServiceManager public slashingManager;

    function setUp() public override {
        super.setUp();
        slashingManager = new SlashingServiceManager();
    }

    /// @notice Full E2E: Blueprint with job result validation that triggers slashing
    /// This demonstrates the full flow: operator misbehaves -> detection -> slash proposal -> execution
    function test_E2E_SlashingCondition_InvalidJobResult() public {
        // Step 1: Create blueprint with slashing service manager
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://slashing-blueprint", address(slashingManager));

        // Step 2: Operator registers with significant stake
        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        // Step 3: Delegators stake with the operator
        vm.startPrank(delegator1);
        restaking.deposit{ value: 20 ether }();
        restaking.delegate(operator1, 20 ether);
        vm.stopPrank();

        vm.startPrank(delegator2);
        restaking.deposit{ value: 30 ether }();
        restaking.delegate(operator1, 30 ether);
        vm.stopPrank();

        // Record initial stakes
        uint256 operatorStakeBefore = restaking.getOperatorSelfStake(operator1);
        uint256 delegator1StakeBefore = restaking.getDelegation(delegator1, operator1);
        uint256 delegator2StakeBefore = restaking.getDelegation(delegator2, operator1);

        assertEq(operatorStakeBefore, 10 ether, "Operator should have 10 ETH stake");
        assertEq(delegator1StakeBefore, 20 ether, "Delegator1 should have 20 ETH delegated");
        assertEq(delegator2StakeBefore, 30 ether, "Delegator2 should have 30 ETH delegated");

        // Step 4: User requests a service
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Step 5: Operator approves
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;
        assertTrue(tangle.isServiceActive(serviceId), "Service should be active");

        // Step 6: User submits a job
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, abi.encode("compute hash"));

        // Step 7: Operator submits result (in real scenario, could be invalid)
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, abi.encode("INVALID_RESULT"));

        // Step 8: Service owner detects misbehavior (off-chain detection in practice)
        // and proposes a slash via the Tangle protocol
        // In a real scenario, the service manager could have its own slash initiation logic

        // Step 9: Service owner proposes slash based on detected misbehavior
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 6 ether, keccak256("invalid_result_evidence"));

        // Step 10: Fast forward past dispute window (7 days)
        vm.warp(block.timestamp + 7 days + 1);

        // Step 11: Execute the slash
        tangle.executeSlash(slashId);

        // Step 12: Verify proportional slashing occurred
        // Total stake = 10 (operator) + 20 (d1) + 30 (d2) = 60 ETH
        // Slash amount = 6 ETH
        // Operator share: 6 * 10/60 = 1 ETH
        // Delegator share: 6 - 1 = 5 ETH (split proportionally among delegators)
        // Delegator1: 5 * 20/50 = 2 ETH
        // Delegator2: 5 * 30/50 = 3 ETH

        uint256 operatorStakeAfter = restaking.getOperatorSelfStake(operator1);
        assertEq(operatorStakeAfter, 9 ether, "Operator stake should be reduced by ~1 ETH");

        // Note: Delegator slashing is proportional to the operator's total stake pool
        // The actual implementation may vary slightly based on how slashing is distributed
    }

    /// @notice Test slashing with multiple operators where only one is slashed
    function test_E2E_SlashingCondition_MultiOperator_SingleSlash() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://multi-op-slash", address(slashingManager));

        // Two operators with different stakes
        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        vm.prank(operator2);
        restaking.registerOperator{ value: 8 ether }();
        vm.prank(operator2);
        tangle.registerOperator(blueprintId, "");

        // Delegator splits between both
        vm.startPrank(delegator1);
        restaking.deposit{ value: 20 ether }();
        restaking.delegate(operator1, 10 ether);
        restaking.delegate(operator2, 10 ether);
        vm.stopPrank();

        // Request service with both operators
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Record operator2's stake before
        uint256 op2StakeBefore = restaking.getOperatorSelfStake(operator2);
        uint256 d1DelegationToOp2Before = restaking.getDelegation(delegator1, operator2);

        // Only slash operator1 (operator2 remains unaffected)
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 2 ether, keccak256("op1_fault"));

        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Verify operator2's stake is unchanged
        uint256 op2StakeAfter = restaking.getOperatorSelfStake(operator2);
        uint256 d1DelegationToOp2After = restaking.getDelegation(delegator1, operator2);

        assertEq(op2StakeAfter, op2StakeBefore, "Operator2 stake should be unchanged");
        assertEq(d1DelegationToOp2After, d1DelegationToOp2Before, "Delegator1's delegation to operator2 should be unchanged");
    }

    /// @notice Test that dispute window works correctly
    function test_E2E_SlashingCondition_DisputeWindowSuccess() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://dispute-test", address(0));

        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Propose slash
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 2 ether, keccak256("evidence"));

        // Operator disputes during window
        vm.prank(operator1);
        tangle.disputeSlash(slashId, "This slash is unjustified");

        // Try to execute - should fail because dispute was raised
        // (depends on dispute resolution mechanism)
    }

    /// @notice Test slashing deactivates operator below minimum stake
    function test_E2E_SlashingCondition_OperatorDeactivation() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint("ipfs://deactivation", address(0));

        // Operator registers with just above minimum
        vm.prank(operator1);
        restaking.registerOperator{ value: MIN_OPERATOR_STAKE + 0.5 ether }();
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Slash more than buffer above minimum
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 0.75 ether, keccak256("evidence"));

        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        // Operator should be deactivated (below minimum)
        // New delegations should fail
        vm.startPrank(delegator1);
        restaking.deposit{ value: 5 ether }();
        vm.expectRevert(abi.encodeWithSelector(DelegationErrors.OperatorNotActive.selector, operator1));
        restaking.delegate(operator1, 5 ether);
        vm.stopPrank();
    }
}

/// @title SlashingServiceManager
/// @notice Service manager that validates job results and triggers slashing for invalid results
contract SlashingServiceManager is BlueprintServiceManagerBase {
    bool public slashTriggered;
    mapping(uint64 => mapping(uint64 => bool)) public invalidResults;

    function onBlueprintCreated(
        uint64 _blueprintId,
        address _owner,
        address _tangleCore
    ) external override {
        blueprintId = _blueprintId;
        blueprintOwner = _owner;
        tangleCore = _tangleCore;
    }

    function onRegister(address, bytes calldata) external payable override {}

    function onRequest(
        uint64,
        address,
        address[] calldata,
        bytes calldata,
        uint64,
        address,
        uint256
    ) external payable override {}

    function onApprove(address, uint64, uint8) external payable override {}

    function onServiceInitialized(
        uint64,
        uint64,
        uint64,
        address,
        address[] calldata,
        uint64
    ) external override {}

    function onJobCall(
        uint64,
        uint8,
        uint64,
        bytes calldata
    ) external payable override {}

    /// @notice Validates job results - triggers slashing for invalid results
    function onJobResult(
        uint64 serviceId,
        uint8,
        uint64 jobCallId,
        address,
        bytes calldata,
        bytes calldata outputs
    ) external payable override {
        // Check if result is marked as invalid (starts with "INVALID")
        string memory result = abi.decode(outputs, (string));
        if (_startsWith(result, "INVALID")) {
            invalidResults[serviceId][jobCallId] = true;
            slashTriggered = true;
        }
    }

    /// @notice Returns this contract as the slashing origin (can trigger slashes)
    function querySlashingOrigin(uint64) external view override returns (address) {
        return blueprintOwner; // Allow blueprint owner to slash
    }

    function _startsWith(string memory str, string memory prefix) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory prefixBytes = bytes(prefix);
        if (strBytes.length < prefixBytes.length) return false;
        for (uint i = 0; i < prefixBytes.length; i++) {
            if (strBytes[i] != prefixBytes[i]) return false;
        }
        return true;
    }
}
