// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";

/// @title TntExposureApprovalTest
/// @notice Tests for the approveService overload that accepts custom TNT exposure bps
contract TntExposureApprovalTest is BaseTest {
    uint64 blueprintId;
    MockERC20 tnt;

    function setUp() public override {
        super.setUp();

        tnt = new MockERC20();

        vm.prank(admin);
        tangle.setTntToken(address(tnt));

        // Register operators in staking
        _registerOperator(operator1);
        _registerOperator(operator2);

        // Create a blueprint
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://tnt-exposure-test", address(0)));

        // Register operators for blueprint
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
    }

    function test_ApproveService_WithTntExposure() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Approve with 50% TNT exposure (5000 bps)
        vm.prank(operator1);
        tangle.approveService(requestId, 0, 5000);

        Types.AssetSecurityCommitment[] memory commits =
            tangle.getServiceRequestSecurityCommitments(requestId, operator1);
        assertEq(commits.length, 1, "Should have exactly one commitment");
        assertEq(commits[0].asset.token, address(tnt), "Commitment should be for TNT token");
        assertEq(commits[0].exposureBps, 5000, "Exposure should be 5000 bps (50%)");
    }

    function test_ApproveService_WithTntExposure_Zero_UsesDefault() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Approve with tntExposureBps=0 -> should use default min (1000 bps / 10%)
        vm.prank(operator1);
        tangle.approveService(requestId, 0, 0);

        Types.AssetSecurityCommitment[] memory commits =
            tangle.getServiceRequestSecurityCommitments(requestId, operator1);
        assertEq(commits.length, 1, "Should have exactly one commitment");
        assertEq(commits[0].exposureBps, 1000, "Exposure should be default 1000 bps (10%)");
    }

    function test_ApproveService_WithTntExposure_RevertBelowMinimum() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Try to approve with 500 bps (5%) which is below min of 1000 bps (10%)
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.CommitmentBelowMinimum.selector, address(tnt), 500, 1000));
        tangle.approveService(requestId, 0, 500);
    }

    function test_ApproveService_WithTntExposure_RevertAboveMaximum() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Try to approve with 10001 bps which exceeds max of 10000 bps (100%)
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.CommitmentAboveMaximum.selector, address(tnt), 10001, 10000));
        tangle.approveService(requestId, 0, 10001);
    }

    function test_ApproveService_WithTntExposure_MaxExposure() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Approve with 100% TNT exposure (10000 bps)
        vm.prank(operator1);
        tangle.approveService(requestId, 0, 10000);

        Types.AssetSecurityCommitment[] memory commits =
            tangle.getServiceRequestSecurityCommitments(requestId, operator1);
        assertEq(commits.length, 1, "Should have exactly one commitment");
        assertEq(commits[0].exposureBps, 10000, "Exposure should be 10000 bps (100%)");
    }

    function test_ApproveService_WithTntExposure_DifferentOperatorExposures() public {
        // Request a service with two operators
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        // Operator1 approves at 20% TNT exposure
        vm.prank(operator1);
        tangle.approveService(requestId, 0, 2000);

        // Operator2 approves at 80% TNT exposure
        vm.prank(operator2);
        tangle.approveService(requestId, 0, 8000);

        // Verify different commitments
        Types.AssetSecurityCommitment[] memory commits1 =
            tangle.getServiceRequestSecurityCommitments(requestId, operator1);
        Types.AssetSecurityCommitment[] memory commits2 =
            tangle.getServiceRequestSecurityCommitments(requestId, operator2);

        assertEq(commits1[0].exposureBps, 2000, "Operator1 should have 2000 bps (20%)");
        assertEq(commits2[0].exposureBps, 8000, "Operator2 should have 8000 bps (80%)");
    }

    function test_ApproveService_OldSignature_StillUsesDefault() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Use the old 2-arg signature (backwards compatible)
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        Types.AssetSecurityCommitment[] memory commits =
            tangle.getServiceRequestSecurityCommitments(requestId, operator1);
        assertEq(commits.length, 1, "Should have exactly one commitment");
        assertEq(commits[0].exposureBps, 1000, "Old signature should use default 1000 bps");
    }

    function test_ApproveService_WithTntExposure_MinExposureBoundary() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Approve with exactly the min exposure (1000 bps / 10%)
        vm.prank(operator1);
        tangle.approveService(requestId, 0, 1000);

        Types.AssetSecurityCommitment[] memory commits =
            tangle.getServiceRequestSecurityCommitments(requestId, operator1);
        assertEq(commits[0].exposureBps, 1000, "Should accept min exposure boundary");
    }
}
