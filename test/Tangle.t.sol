// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../src/libraries/Types.sol";
import { Errors } from "../src/libraries/Errors.sol";
import { ITangle } from "../src/interfaces/ITangle.sol";
import { ITangleBlueprints } from "../src/interfaces/ITangleBlueprints.sol";
import { ITangleOperators } from "../src/interfaces/ITangleOperators.sol";
import { ITangleServices } from "../src/interfaces/ITangleServices.sol";
import { ITangleJobs } from "../src/interfaces/ITangleJobs.sol";
import { BlueprintServiceManagerBase } from "../src/BlueprintServiceManagerBase.sol";

/// @notice Minimal mock BSM with zero exit delays for testing
contract ZeroDelayMockBSM is BlueprintServiceManagerBase {
    function onBlueprintCreated(uint64 _blueprintId, address owner, address _tangleCore) external override {
        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = _tangleCore;
    }

    function getExitConfig(uint64)
        external
        pure
        override
        returns (bool useDefault, uint64 minCommitmentDuration, uint64 exitQueueDuration, bool forceExitAllowed)
    {
        return (false, 0, 0, false);
    }
}

contract TangleTest is BaseTest {
    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateBlueprint() public {
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(0)));

        assertEq(blueprintId, 0);
        assertEq(tangle.blueprintCount(), 1);

        Types.Blueprint memory bp = tangle.getBlueprint(blueprintId);
        assertEq(bp.owner, developer);
        assertEq(bp.manager, address(0));
        assertTrue(bp.active);
        assertEq(bp.operatorCount, 0);
    }

    function test_CreateMultipleBlueprints() public {
        vm.startPrank(developer);
        uint64 id1 = tangle.createBlueprint(_blueprintDefinition("ipfs://test1", address(0)));
        uint64 id2 = tangle.createBlueprint(_blueprintDefinition("ipfs://test2", address(0)));
        uint64 id3 = tangle.createBlueprint(_blueprintDefinition("ipfs://test3", address(0)));
        vm.stopPrank();

        assertEq(id1, 0);
        assertEq(id2, 1);
        assertEq(id3, 2);
        assertEq(tangle.blueprintCount(), 3);
    }

    function test_UpdateBlueprint() public {
        uint64 blueprintId = _createBlueprint(developer);

        vm.prank(developer);
        vm.expectEmit(true, false, false, true);
        emit ITangleBlueprints.BlueprintUpdated(blueprintId, "ipfs://newUri");
        tangle.updateBlueprint(blueprintId, "ipfs://newUri");
    }

    function test_UpdateBlueprint_RevertNotOwner() public {
        uint64 blueprintId = _createBlueprint(developer);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, blueprintId, user1));
        tangle.updateBlueprint(blueprintId, "ipfs://newUri");
    }

    function test_TransferBlueprint() public {
        uint64 blueprintId = _createBlueprint(developer);

        vm.prank(developer);
        tangle.transferBlueprint(blueprintId, user1);

        Types.Blueprint memory bp = tangle.getBlueprint(blueprintId);
        assertEq(bp.owner, user1);
    }

    function test_TransferBlueprint_RevertZeroAddress() public {
        uint64 blueprintId = _createBlueprint(developer);

        vm.prank(developer);
        vm.expectRevert(Errors.ZeroAddress.selector);
        tangle.transferBlueprint(blueprintId, address(0));
    }

    function test_DeactivateBlueprint() public {
        uint64 blueprintId = _createBlueprint(developer);

        vm.prank(developer);
        tangle.deactivateBlueprint(blueprintId);

        Types.Blueprint memory bp = tangle.getBlueprint(blueprintId);
        assertFalse(bp.active);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RegisterOperator() public {
        // Setup: operator has stake, blueprint exists
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);

        bytes memory key = _operatorGossipKey(operator1, 0);
        // Register
        vm.prank(operator1);
        vm.expectEmit(true, true, false, true);
        emit ITangleOperators.OperatorRegistered(blueprintId, operator1, key, "");
        tangle.registerOperator(blueprintId, key, "");

        assertTrue(tangle.isOperatorRegistered(blueprintId, operator1));
        assertEq(tangle.blueprintOperatorCount(blueprintId), 1);
    }

    function test_RegisterOperator_WithPreferences() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);

        _directRegisterOperator(operator1, blueprintId, "https://rpc.example.com");

        assertTrue(tangle.isOperatorRegistered(blueprintId, operator1));
    }

    function test_RegisterOperator_RevertNotActive() public {
        uint64 blueprintId = _createBlueprint(developer);

        // operator1 has no stake
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotActive.selector, operator1));
        tangle.registerOperator(blueprintId, "", "");
    }

    function test_RegisterOperator_RevertBlueprintNotActive() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);

        vm.prank(developer);
        tangle.deactivateBlueprint(blueprintId);

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.BlueprintNotActive.selector, blueprintId));
        tangle.registerOperator(blueprintId, "", "");
    }

    function test_RegisterOperator_RevertAlreadyRegistered() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);

        _registerForBlueprint(operator1, blueprintId);

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorAlreadyRegistered.selector, blueprintId, operator1));
        tangle.registerOperator(blueprintId, "", "");
    }

    function test_UnregisterOperator() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        vm.prank(operator1);
        tangle.unregisterOperator(blueprintId);

        assertFalse(tangle.isOperatorRegistered(blueprintId, operator1));
        assertEq(tangle.blueprintOperatorCount(blueprintId), 0);
    }

    function test_UpdateOperatorPreferences() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        vm.prank(operator1);
        tangle.updateOperatorPreferences(blueprintId, "", "newPrefs");

        Types.OperatorRegistration memory reg = tangle.getOperatorRegistration(blueprintId, operator1);
        assertTrue(reg.updatedAt >= reg.registeredAt);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RequestService() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        assertEq(requestId, 0);

        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertEq(req.blueprintId, blueprintId);
        assertEq(req.requester, user1);
        assertEq(req.operatorCount, 1);
        assertEq(req.approvalCount, 0);
        assertFalse(req.rejected);
    }

    function test_RequestService_WithPayment() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        uint256 payment = 1 ether;
        uint256 balanceBefore = address(tangle).balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);

        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertEq(req.paymentAmount, payment);
        assertEq(req.paymentToken, address(0));
        assertEq(address(tangle).balance, balanceBefore + payment);
    }

    function test_RequestService_MultipleOperators() public {
        _registerOperator(operator1);
        _registerOperator(operator2);
        _registerOperator(operator3);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);

        address[] memory operators = new address[](3);
        operators[0] = operator1;
        operators[1] = operator2;
        operators[2] = operator3;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertEq(req.operatorCount, 3);
    }

    function test_RequestService_RevertNoOperators() public {
        uint64 blueprintId = _createBlueprint(developer);

        address[] memory operators = new address[](0);
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(Errors.NoOperators.selector);
        tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);
    }

    function test_RequestService_RevertOperatorNotRegistered() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        // Note: operator1 NOT registered for blueprint

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotRegistered.selector, blueprintId, operator1));
        tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE APPROVAL TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ApproveService() public {
        _registerOperator(operator1);
        _registerOperator(operator2);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        _approveService(operator1, requestId);

        // Service should be activated after all approvals
        assertEq(tangle.serviceCount(), 1);
        assertTrue(tangle.isServiceActive(0));
    }

    function test_ApproveService_MultipleOperators() public {
        _registerOperator(operator1);
        _registerOperator(operator2);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        // First approval - not activated yet
        _approveService(operator1, requestId);
        assertEq(tangle.serviceCount(), 0);

        // Second approval - now activated
        _approveService(operator2, requestId);
        assertEq(tangle.serviceCount(), 1);
        assertTrue(tangle.isServiceActive(0));
    }

    function test_ApproveService_RevertNotOperator() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotActive.selector, operator2));
        tangle.approveService(requestId, 0);
    }

    function test_RejectService() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        uint256 payment = 1 ether;
        uint256 userBalanceBefore = user1.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);

        vm.prank(operator1);
        tangle.rejectService(requestId);

        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertTrue(req.rejected);

        // Payment should be refunded
        assertEq(user1.balance, userBalanceBefore);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE LIFECYCLE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_TerminateService() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(user1);
        tangle.terminateService(serviceId);

        assertFalse(tangle.isServiceActive(serviceId));
        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(uint8(svc.status), uint8(Types.ServiceStatus.Terminated));
    }

    function test_TerminateService_RevertNotOwner() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotServiceOwner.selector, 0, user2));
        tangle.terminateService(0);
    }

    function test_AddPermittedCaller() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(user1);
        tangle.addPermittedCaller(serviceId, user2);

        assertTrue(tangle.isPermittedCaller(serviceId, user2));
    }

    function test_RemovePermittedCaller() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(user1);
        tangle.addPermittedCaller(serviceId, user2);

        vm.prank(user1);
        tangle.removePermittedCaller(serviceId, user2);

        assertFalse(tangle.isPermittedCaller(serviceId, user2));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SubmitJob() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;
        bytes memory inputs = abi.encode("test input");

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, inputs);

        assertEq(callId, 0);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.jobIndex, 0);
        assertEq(job.caller, user1);
        assertFalse(job.completed);
    }

    function test_SubmitJob_RevertNotPermittedCaller() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotPermittedCaller.selector, serviceId, user2));
        tangle.submitJob(serviceId, 0, "");
    }

    function test_SubmitResult() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "input");

        bytes memory result = abi.encode("result data");

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, result);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.resultCount, 1);
        assertTrue(job.completed);
    }

    function test_SubmitResult_RevertNotServiceOperator() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "input");

        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotInService.selector, serviceId, operator2));
        tangle.submitResult(serviceId, callId, "result");
    }

    function test_SubmitResult_RevertJobAlreadyCompleted() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, "input");

        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, "result1");

        // Job is already completed (1 result = 1 required by default)
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.JobAlreadyCompleted.selector, serviceId, callId));
        tangle.submitResult(serviceId, callId, "result2");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetPaymentSplit() public {
        Types.PaymentSplit memory split =
            Types.PaymentSplit({ developerBps: 6000, protocolBps: 500, operatorBps: 1750, stakerBps: 1750 });

        vm.prank(admin);
        tangle.setPaymentSplit(split);

        (uint16 dev, uint16 proto, uint16 op, uint16 rest) = tangle.paymentSplit();
        assertEq(dev, 6000);
        assertEq(proto, 500);
        assertEq(op, 1750);
        assertEq(rest, 1750);
    }

    function test_SetPaymentSplit_RevertInvalidTotal() public {
        Types.PaymentSplit memory split =
            Types.PaymentSplit({ developerBps: 5000, protocolBps: 5000, operatorBps: 5000, stakerBps: 5000 });

        vm.prank(admin);
        vm.expectRevert(Errors.InvalidPaymentSplit.selector);
        tangle.setPaymentSplit(split);
    }

    function test_Pause() public {
        vm.prank(admin);
        tangle.pause();

        vm.prank(developer);
        vm.expectRevert();
        tangle.createBlueprint(_blueprintDefinition("test", address(0)));
    }

    function test_Unpause() public {
        vm.prank(admin);
        tangle.pause();

        vm.prank(admin);
        tangle.unpause();

        vm.prank(developer);
        tangle.createBlueprint(_blueprintDefinition("test", address(0)));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateBlueprintWithConfig_Dynamic() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        assertEq(blueprintId, 0);
        Types.Blueprint memory bp = tangle.getBlueprint(blueprintId);
        assertEq(uint8(bp.membership), uint8(Types.MembershipModel.Dynamic));
    }

    function test_JoinService() public {
        // Setup: create dynamic blueprint
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        // Register operators
        _registerOperator(operator1);
        _registerOperator(operator2);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        // Request service with operator1
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 5000; // 50%
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestServiceWithExposure(blueprintId, operators, exposures, "", callers, 0, address(0), 0);

        // Approve to activate service
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;
        assertTrue(tangle.isServiceActive(serviceId));
        assertEq(tangle.getService(serviceId).operatorCount, 1);

        // operator2 joins the service
        vm.prank(operator2);
        vm.expectEmit(true, true, false, true);
        emit ITangleServices.OperatorJoinedService(serviceId, operator2, 5000);
        tangle.joinService(serviceId, 5000);

        assertTrue(tangle.isServiceOperator(serviceId, operator2));
        assertEq(tangle.getService(serviceId).operatorCount, 2);

        Types.ServiceOperator memory op2 = tangle.getServiceOperator(serviceId, operator2);
        assertEq(op2.exposureBps, 5000);
        assertTrue(op2.active);
    }

    function test_JoinService_RevertNotDynamic() public {
        // Default blueprint is Fixed
        _registerOperator(operator1);
        _registerOperator(operator2);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        vm.prank(operator2);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.joinService(serviceId, 5000);
    }

    function test_JoinService_RevertMaxOperators() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 1, // Only 1 allowed
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        _registerOperator(operator1);
        _registerOperator(operator2);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 5000;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestServiceWithExposure(blueprintId, operators, exposures, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        vm.prank(operator2);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.joinService(0, 5000);
    }

    function test_LeaveService() public {
        // Setup dynamic service with 2 operators
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        _registerOperator(operator1);
        _registerOperator(operator2);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        uint16[] memory exposures = new uint16[](2);
        exposures[0] = 5000;
        exposures[1] = 5000;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestServiceWithExposure(blueprintId, operators, exposures, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;
        assertEq(tangle.getService(serviceId).operatorCount, 2);

        // Warp past minimum commitment duration (1 day default)
        vm.warp(block.timestamp + 1 days + 1);

        // operator1 schedules exit
        vm.prank(operator1);
        tangle.scheduleExit(serviceId);

        // Warp past exit queue duration (7 days default)
        vm.warp(block.timestamp + 7 days + 1);

        // Execute exit
        vm.prank(operator1);
        vm.expectEmit(true, true, false, false);
        emit ITangleServices.OperatorLeftService(serviceId, operator1);
        tangle.executeExit(serviceId);

        assertFalse(tangle.isServiceOperator(serviceId, operator1));
        assertEq(tangle.getService(serviceId).operatorCount, 1);
    }

    function test_LeaveService_RevertMinOperators() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 2,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        // Use mock BSM with zero exit delays to test min operators check directly
        ZeroDelayMockBSM zeroDelayBsm = new ZeroDelayMockBSM();
        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(zeroDelayBsm), config));

        _registerOperator(operator1);
        _registerOperator(operator2);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        uint16[] memory exposures = new uint16[](2);
        exposures[0] = 5000;
        exposures[1] = 5000;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestServiceWithExposure(blueprintId, operators, exposures, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // Try to leave - should fail as it would go below min
        vm.prank(operator1);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.leaveService(0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE COMMITMENT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RequestServiceWithExposure() public {
        _registerOperator(operator1);
        _registerOperator(operator2);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        uint16[] memory exposures = new uint16[](2);
        exposures[0] = 5000; // 50%
        exposures[1] = 7500; // 75%
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestServiceWithExposure(blueprintId, operators, exposures, "", callers, 0, address(0), 0);

        assertEq(requestId, 0);
    }

    function test_RequestServiceWithExposure_RevertInvalidExposure() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 15_000; // > 100% - invalid
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.requestServiceWithExposure(blueprintId, operators, exposures, "", callers, 0, address(0), 0);
    }

    function test_GetServiceOperators() public {
        _registerOperator(operator1);
        _registerOperator(operator2);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

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
        address[] memory serviceOps = tangle.getServiceOperators(serviceId);
        assertEq(serviceOps.length, 2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBSCRIPTION PRICING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateBlueprintWithConfig_Subscription() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));

        Types.Blueprint memory bp = tangle.getBlueprint(blueprintId);
        assertEq(uint8(bp.pricing), uint8(Types.PricingModel.Subscription));
    }

    function test_CreateBlueprintWithConfig_Subscription_RevertZeroRate() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://invalid-sub-zero-rate", address(0), config));
    }

    function test_CreateBlueprintWithConfig_Subscription_RevertZeroInterval() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://invalid-sub-zero-interval", address(0), config));
    }

    function test_BillSubscription() public {
        // Create subscription blueprint
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));

        _registerOperator(operator1);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 10_000;
        address[] memory callers = new address[](0);

        // Request with payment for subscription
        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: 1 ether }(
            blueprintId, operators, exposures, "", callers, 0, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = 0;

        // Fast forward past interval
        vm.warp(block.timestamp + 31 days);

        // Bill subscription
        vm.expectEmit(true, false, false, false);
        emit ITangleServices.SubscriptionBilled(serviceId, 0.1 ether, 0);
        tangle.billSubscription(serviceId);
    }

    function test_BillSubscription_RevertNotSubscription() public {
        _registerOperator(operator1);
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        vm.expectRevert(Errors.InvalidState.selector);
        tangle.billSubscription(0);
    }

    function test_BillSubscription_RevertTooEarly() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 blueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));

        _registerOperator(operator1);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 10_000;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: 1 ether }(
            blueprintId, operators, exposures, "", callers, 0, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Try to bill immediately - should fail
        vm.expectRevert(Errors.DeadlineExpired.selector);
        tangle.billSubscription(0);
    }
}
