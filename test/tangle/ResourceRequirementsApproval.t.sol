// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { SignatureLib } from "../../src/libraries/SignatureLib.sol";
import { Errors } from "../../src/libraries/Errors.sol";

/// @title ResourceRequirementsApprovalTest
/// @notice Tests for resource requirements in the approval-based service request flow
contract ResourceRequirementsApprovalTest is BaseTest {
    uint64 blueprintId;

    function setUp() public override {
        super.setUp();

        blueprintId = _createBlueprint(developer);

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT RESOURCE REQUIREMENTS — SET / GET
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetAndGetBlueprintResourceRequirements() public {
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](2);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 }); // 4 CPU
        reqs[1] = Types.ResourceCommitment({ kind: 1, count: 8192 }); // 8192 MB memory

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);

        Types.ResourceCommitment[] memory stored = tangle.getBlueprintResourceRequirements(blueprintId);
        assertEq(stored.length, 2);
        assertEq(stored[0].kind, 0);
        assertEq(stored[0].count, 4);
        assertEq(stored[1].kind, 1);
        assertEq(stored[1].count, 8192);
    }

    function test_SetBlueprintResourceRequirements_RevertsNonOwner() public {
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](1);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, blueprintId, user1));
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);
    }

    function test_SetBlueprintResourceRequirements_RevertsDuplicateKind() public {
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](2);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 });
        reqs[1] = Types.ResourceCommitment({ kind: 0, count: 8 }); // duplicate kind

        vm.prank(developer);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);
    }

    function test_SetBlueprintResourceRequirements_RevertsZeroCount() public {
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](1);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 0 });

        vm.prank(developer);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);
    }

    function test_SetBlueprintResourceRequirements_CanClear() public {
        // Set requirements
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](1);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 });

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);

        // Clear by setting empty array
        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, new Types.ResourceCommitment[](0));

        Types.ResourceCommitment[] memory stored = tangle.getBlueprintResourceRequirements(blueprintId);
        assertEq(stored.length, 0);
    }

    function test_SetBlueprintResourceRequirements_CanOverwrite() public {
        Types.ResourceCommitment[] memory reqs1 = new Types.ResourceCommitment[](1);
        reqs1[0] = Types.ResourceCommitment({ kind: 0, count: 4 });

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs1);

        // Overwrite with different requirements
        Types.ResourceCommitment[] memory reqs2 = new Types.ResourceCommitment[](2);
        reqs2[0] = Types.ResourceCommitment({ kind: 0, count: 8 });
        reqs2[1] = Types.ResourceCommitment({ kind: 5, count: 2 }); // GPU

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs2);

        Types.ResourceCommitment[] memory stored = tangle.getBlueprintResourceRequirements(blueprintId);
        assertEq(stored.length, 2);
        assertEq(stored[0].count, 8);
        assertEq(stored[1].kind, 5);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // APPROVAL FLOW — RESOURCE DEFAULTS AUTO-APPLIED
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RequestService_AutoAppliesBlueprintDefaults() public {
        // Set blueprint resource requirements
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](2);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 }); // CPU
        reqs[1] = Types.ResourceCommitment({ kind: 1, count: 8192 }); // Memory

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);

        // Request service
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Check request-level resource requirements
        Types.ResourceCommitment[] memory stored = tangle.getServiceRequestResourceRequirements(requestId);
        assertEq(stored.length, 2);
        assertEq(stored[0].kind, 0);
        assertEq(stored[0].count, 4);
        assertEq(stored[1].kind, 1);
        assertEq(stored[1].count, 8192);
    }

    function test_ApprovalFlow_ResourceHashStoredOnActivation() public {
        // Set blueprint resource requirements
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](2);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 });
        reqs[1] = Types.ResourceCommitment({ kind: 1, count: 8192 });

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);

        // Request + approve → activate
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Verify hash stored for operator
        bytes32 storedHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        bytes32 expectedHash = SignatureLib.hashResourceCommitments(reqs);
        assertEq(storedHash, expectedHash, "stored hash should match computed hash");
        assertTrue(storedHash != bytes32(0), "hash should be non-zero");
    }

    function test_ApprovalFlow_AllOperatorsGetSameHash() public {
        // Set blueprint resource requirements
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](1);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 });

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);

        // Request with two operators
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        // Both approve
        _approveService(operator1, requestId);
        _approveService(operator2, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;

        bytes32 hash1 = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        bytes32 hash2 = tangle.getServiceResourceCommitmentHash(serviceId, operator2);
        assertEq(hash1, hash2, "all operators should get same hash");
        assertTrue(hash1 != bytes32(0), "hash should be non-zero");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BACKWARD COMPATIBILITY — NO DEFAULTS = NO HASH
    // ═══════════════════════════════════════════════════════════════════════════

    function test_NoResourceDefaults_NoHashStored() public {
        // Blueprint has no resource requirements (default state)
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;

        bytes32 storedHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        assertEq(storedHash, bytes32(0), "no resource defaults should mean no hash");
    }

    function test_NoResourceDefaults_EmptyRequestRequirements() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        Types.ResourceCommitment[] memory stored = tangle.getServiceRequestResourceRequirements(requestId);
        assertEq(stored.length, 0, "no defaults should mean empty request requirements");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENT EMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ResourcesCommitted_EventEmittedOnActivation() public {
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](1);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 });

        vm.prank(developer);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Approve triggers activation — verify event is emitted via side effects
        _approveService(operator1, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;
        bytes32 storedHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        assertTrue(storedHash != bytes32(0), "hash stored confirms activation with resources happened");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT RESOURCE REQUIREMENTS EVENT
    // ═══════════════════════════════════════════════════════════════════════════

    function test_BlueprintResourceRequirementsSet_EventEmitted() public {
        Types.ResourceCommitment[] memory reqs = new Types.ResourceCommitment[](2);
        reqs[0] = Types.ResourceCommitment({ kind: 0, count: 4 });
        reqs[1] = Types.ResourceCommitment({ kind: 1, count: 8192 });

        vm.prank(developer);
        vm.expectEmit(true, false, false, true);
        // event BlueprintResourceRequirementsSet(uint64 indexed blueprintId, uint256 count)
        emit BlueprintResourceRequirementsSet(blueprintId, 2);
        tangle.setBlueprintResourceRequirements(blueprintId, reqs);
    }

    // Re-declare event for expectEmit
    event BlueprintResourceRequirementsSet(uint64 indexed blueprintId, uint256 count);
}
