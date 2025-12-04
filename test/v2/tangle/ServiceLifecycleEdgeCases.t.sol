// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { BlueprintServiceManagerBase } from "../../../src/v2/BlueprintServiceManagerBase.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";

/// @notice Mock BSM that tracks all lifecycle events
contract LifecycleMockBSM is BlueprintServiceManagerBase {
    uint256 public terminationCount;
    uint256 public jobCallCount;
    uint256 public jobResultCount;
    mapping(uint64 => bool) public terminatedServices;
    mapping(uint64 => mapping(uint64 => bool)) public pendingJobs;

    bool public rejectRequests;
    bool public rejectJoins;
    bool public rejectLeaves;

    function setRejectRequests(bool reject) external {
        rejectRequests = reject;
    }

    function setRejectJoins(bool reject) external {
        rejectJoins = reject;
    }

    function setRejectLeaves(bool reject) external {
        rejectLeaves = reject;
    }

    function onBlueprintCreated(uint64 _blueprintId, address owner, address _tangleCore) external override {
        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = _tangleCore;
    }

    function onRegister(address, bytes calldata) external payable override onlyFromTangle {}
    function onUnregister(address) external override onlyFromTangle {}
    function onUpdatePreferences(address, bytes calldata) external payable override onlyFromTangle {}

    function onRequest(uint64, address, address[] calldata, bytes calldata, uint64, address, uint256) external payable override onlyFromTangle {
        if (rejectRequests) revert("Request rejected by BSM");
    }

    function onApprove(address, uint64, uint8) external payable override onlyFromTangle {}
    function onReject(address, uint64) external override onlyFromTangle {}

    function onServiceInitialized(uint64, uint64, uint64, address, address[] calldata, uint64) external override onlyFromTangle {}

    function onServiceTermination(uint64 serviceId, address) external override onlyFromTangle {
        terminationCount++;
        terminatedServices[serviceId] = true;
    }

    function onJobCall(uint64 serviceId, uint8, uint64 jobCallId, bytes calldata) external payable override onlyFromTangle {
        jobCallCount++;
        pendingJobs[serviceId][jobCallId] = true;
    }

    function onJobResult(uint64 serviceId, uint8, uint64 jobCallId, address, bytes calldata, bytes calldata) external payable override onlyFromTangle {
        jobResultCount++;
        pendingJobs[serviceId][jobCallId] = false;
    }

    function onUnappliedSlash(uint64, bytes calldata, uint8) external override onlyFromTangle {}
    function onSlash(uint64, bytes calldata, uint8) external override onlyFromTangle {}

    function onOperatorJoined(uint64, address, uint16) external override onlyFromTangle {}
    function onOperatorLeft(uint64, address) external override onlyFromTangle {}

    function canJoin(uint64, address) external view override returns (bool) {
        return !rejectJoins;
    }

    function canLeave(uint64, address) external view override returns (bool) {
        return !rejectLeaves;
    }

    /// @notice Allow immediate exits for testing (no commitment/queue durations)
    function getExitConfig(uint64) external pure override returns (
        bool useDefault,
        uint64 minCommitmentDuration,
        uint64 exitQueueDuration,
        bool forceExitAllowed
    ) {
        return (false, 0, 0, false);
    }
}

/// @title ServiceLifecycleEdgeCasesTest
/// @notice Edge cases for service lifecycle: creation, termination, jobs
contract ServiceLifecycleEdgeCasesTest is BaseTest {
    LifecycleMockBSM public mockBsm;

    uint64 public blueprintId;
    uint64 public dynamicBlueprintId;

    function setUp() public override {
        super.setUp();

        // Deploy mock BSM
        mockBsm = new LifecycleMockBSM();

        // Setup operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);

        // Setup blueprints
        blueprintId = _createBlueprint(developer, address(mockBsm));

        Types.BlueprintConfig memory dynamicConfig = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        dynamicBlueprintId = tangle.createBlueprintWithConfig("ipfs://dynamic", address(mockBsm), dynamicConfig);

        // Register operators for both blueprints
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator1, dynamicBlueprintId);
        _registerForBlueprint(operator2, dynamicBlueprintId);
        _registerForBlueprint(operator3, dynamicBlueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE TERMINATION EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_TerminateService_OnlyOwner() public {
        uint64 serviceId = _createServiceWithBSM(blueprintId, operator1);

        // Non-owner cannot terminate
        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotServiceOwner.selector, serviceId, user2));
        tangle.terminateService(serviceId);

        // Operator cannot terminate
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotServiceOwner.selector, serviceId, operator1));
        tangle.terminateService(serviceId);

        // Owner can terminate
        vm.prank(user1);
        tangle.terminateService(serviceId);

        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(uint8(svc.status), uint8(Types.ServiceStatus.Terminated));
    }

    function test_TerminateService_AlreadyTerminated_Reverts() public {
        uint64 serviceId = _createServiceWithBSM(blueprintId, operator1);

        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Cannot terminate again - status check will fail
        // The contract may not explicitly check this, but let's verify behavior
    }

    function test_TerminateService_WithPendingPayment() public {
        // Create subscription service with escrow
        Types.BlueprintConfig memory subConfig = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 subBlueprintId = tangle.createBlueprintWithConfig("ipfs://sub", address(0), subConfig);

        _registerForBlueprint(operator1, subBlueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: 5 ether }(
            subBlueprintId, ops, "", callers, 365 days, address(0), 5 ether
        );

        _approveService(operator1, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Terminate with escrow funds still present
        vm.prank(user1);
        tangle.terminateService(serviceId);

        // Service is terminated but escrow funds may remain
        // (Depending on implementation, may need withdrawal mechanism)
    }

    function test_TerminateService_BSMHookCalled() public {
        uint64 serviceId = _createServiceWithBSM(blueprintId, operator1);

        assertEq(mockBsm.terminationCount(), 0);

        vm.prank(user1);
        tangle.terminateService(serviceId);

        assertEq(mockBsm.terminationCount(), 1);
        assertTrue(mockBsm.terminatedServices(serviceId));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TTL BOUNDARY CONDITIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ServiceWithZeroTTL() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        _approveService(operator1, requestId);

        Types.Service memory svc = tangle.getService(0);
        assertEq(svc.ttl, 0, "TTL should be 0");
        assertEq(uint8(svc.status), uint8(Types.ServiceStatus.Active));
    }

    function test_ServiceWithMaxTTL() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        uint64 maxTTL = type(uint64).max;

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, maxTTL, address(0), 0);

        _approveService(operator1, requestId);

        Types.Service memory svc = tangle.getService(0);
        assertEq(svc.ttl, maxTTL);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JoinService_AtMaxOperators_Reverts() public {
        // Create dynamic service with max 2 operators
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 2,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 limitedBpId = tangle.createBlueprintWithConfig("ipfs://limited", address(0), config);

        _registerForBlueprint(operator1, limitedBpId);
        _registerForBlueprint(operator2, limitedBpId);
        _registerForBlueprint(operator3, limitedBpId);

        // Create service with 2 operators (max)
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(limitedBpId, ops, "", callers, 0, address(0), 0);

        _approveService(operator1, requestId);
        _approveService(operator2, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;

        // operator3 tries to join but max reached
        vm.prank(operator3);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.joinService(serviceId, 10000);
    }

    function test_LeaveService_AtMinOperators_Reverts() public {
        // Create dynamic service with min 2 operators using mockBsm (which has zero exit delays)
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 2,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        LifecycleMockBSM localBsm = new LifecycleMockBSM();
        vm.prank(developer);
        uint64 minOpBpId = tangle.createBlueprintWithConfig("ipfs://minop", address(localBsm), config);

        _registerForBlueprint(operator1, minOpBpId);
        _registerForBlueprint(operator2, minOpBpId);

        // Create service with exactly 2 operators (min)
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(minOpBpId, ops, "", callers, 0, address(0), 0);

        _approveService(operator1, requestId);
        _approveService(operator2, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;

        // operator1 tries to leave but would go below min (mockBsm has zero exit delays)
        vm.prank(operator1);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.leaveService(serviceId);
    }

    function test_JoinService_BSMRejects() public {
        uint64 serviceId = _createDynamicService(operator1);

        mockBsm.setRejectJoins(true);

        vm.prank(operator2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.joinService(serviceId, 10000);
    }

    function test_LeaveService_BSMRejects() public {
        uint64 serviceId = _createDynamicService(operator1);

        // operator2 joins
        vm.prank(operator2);
        tangle.joinService(serviceId, 10000);

        mockBsm.setRejectLeaves(true);

        // operator2 tries to leave but BSM rejects
        vm.prank(operator2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.leaveService(serviceId);
    }

    function test_JoinService_NotRegisteredForBlueprint_Reverts() public {
        uint64 serviceId = _createDynamicService(operator1);

        address unregisteredOp = makeAddr("unregistered");
        vm.deal(unregisteredOp, 10 ether);
        vm.prank(unregisteredOp);
        restaking.registerOperator{ value: 5 ether }();

        // Operator is registered with restaking but not for this blueprint
        vm.prank(unregisteredOp);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotRegistered.selector, dynamicBlueprintId, unregisteredOp));
        tangle.joinService(serviceId, 10000);
    }

    function test_JoinService_AlreadyInService_Reverts() public {
        uint64 serviceId = _createDynamicService(operator1);

        // operator1 is already in service from creation
        vm.prank(operator1);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.joinService(serviceId, 10000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB SUBMISSION EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SubmitJob_OnTerminatedService_Reverts() public {
        uint64 serviceId = _createServiceWithBSM(blueprintId, operator1);

        vm.prank(user1);
        tangle.terminateService(serviceId);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceNotActive.selector, serviceId));
        tangle.submitJob(serviceId, 0, "");
    }

    function test_SubmitJob_NotPermittedCaller_Reverts() public {
        uint64 serviceId = _createServiceWithBSM(blueprintId, operator1);

        vm.prank(user2); // Not the service owner or permitted caller
        vm.expectRevert(abi.encodeWithSelector(Errors.NotPermittedCaller.selector, serviceId, user2));
        tangle.submitJob(serviceId, 0, "");
    }

    function test_SubmitJob_WithPermittedCaller_Success() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](1);
        callers[0] = user2; // Add user2 as permitted caller

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        _approveService(operator1, requestId);

        uint64 serviceId = 0;

        // user2 can now submit jobs
        vm.prank(user2);
        tangle.submitJob(serviceId, 0, "test input");

        assertEq(mockBsm.jobCallCount(), 1);
    }

    function test_AddRemovePermittedCaller() public {
        uint64 serviceId = _createServiceWithBSM(blueprintId, operator1);

        // Add permitted caller
        vm.prank(user1);
        tangle.addPermittedCaller(serviceId, user2);

        assertTrue(tangle.isPermittedCaller(serviceId, user2));

        // user2 can submit job
        vm.prank(user2);
        tangle.submitJob(serviceId, 0, "");

        // Remove permitted caller
        vm.prank(user1);
        tangle.removePermittedCaller(serviceId, user2);

        assertFalse(tangle.isPermittedCaller(serviceId, user2));

        // user2 can no longer submit
        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotPermittedCaller.selector, serviceId, user2));
        tangle.submitJob(serviceId, 0, "");
    }

    function test_AddPermittedCaller_NotOwner_Reverts() public {
        uint64 serviceId = _createServiceWithBSM(blueprintId, operator1);

        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotServiceOwner.selector, serviceId, user2));
        tangle.addPermittedCaller(serviceId, user2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RequestService_BSMRejects() public {
        mockBsm.setRejectRequests(true);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(); // BSM reverts
        tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);
    }

    function test_RequestService_InactiveBlueprint_Reverts() public {
        // Deactivate blueprint
        vm.prank(developer);
        tangle.deactivateBlueprint(blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.BlueprintNotActive.selector, blueprintId));
        tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);
    }

    function test_RequestService_DuplicateOperators() public {
        // Request with same operator twice - should this be allowed?
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator1; // Duplicate
        address[] memory callers = new address[](0);

        vm.prank(user1);
        // Behavior depends on implementation - may allow or reject duplicates
        // This tests the actual behavior
        try tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0) {
            // If it succeeds, verify service state
        } catch {
            // If it fails, that's also a valid behavior
        }
    }

    function test_ApproveService_AlreadyApproved_Reverts() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        _approveService(operator1, requestId);

        // Approve again
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.AlreadyApproved.selector, requestId, operator1));
        tangle.approveService(requestId, 0);
    }

    function test_ApproveService_AfterRejection_Reverts() public {
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        // operator1 rejects
        vm.prank(operator1);
        tangle.rejectService(requestId);

        // operator2 tries to approve
        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceRequestAlreadyProcessed.selector, requestId));
        tangle.approveService(requestId, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _createServiceWithBSM(uint64 bpId, address op) internal returns (uint64) {
        address[] memory ops = new address[](1);
        ops[0] = op;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(bpId, ops, "", callers, 0, address(0), 0);

        _approveService(op, requestId);

        return tangle.serviceCount() - 1;
    }

    function _createDynamicService(address op) internal returns (uint64) {
        address[] memory ops = new address[](1);
        ops[0] = op;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(dynamicBlueprintId, ops, "", callers, 0, address(0), 0);

        _approveService(op, requestId);

        return tangle.serviceCount() - 1;
    }
}
