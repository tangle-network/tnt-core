// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";

/// @title OperatorLifecycleTest
/// @notice Tests for operator registration, blueprint participation, and service lifecycle
contract OperatorLifecycleTest is BaseTest {
    uint64 blueprintId;

    function setUp() public override {
        super.setUp();

        // Create a blueprint
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://operator-test", address(0)));

        // Register operators with restaking
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION FOR BLUEPRINTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RegisterOperator_Success() public {
        _directRegisterOperator(operator1, blueprintId, "operator-preferences");

        Types.OperatorRegistration memory reg = tangle.getOperatorRegistration(blueprintId, operator1);
        assertEq(reg.registeredAt, block.timestamp);
        assertTrue(reg.active);
        assertEq(reg.bondToken, address(0));
        assertEq(reg.bondAmount, 0);
    }

    function test_RegisterOperator_RevertNotStaked() public {
        address unstaked = makeAddr("unstaked");

        vm.prank(unstaked);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotActive.selector, unstaked));
        tangle.registerOperator(blueprintId, "", "");
    }

    function test_RegisterOperator_RevertAlreadyRegistered() public {
        _directRegisterOperator(operator1, blueprintId, "");

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorAlreadyRegistered.selector, blueprintId, operator1));
        tangle.registerOperator(blueprintId, "", "");
    }

    function test_RegisterOperator_RevertBlueprintNotFound() public {
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.BlueprintNotFound.selector, 999));
        tangle.registerOperator(999, "", "");
    }

    function test_PreRegisterRequiresActiveOperator() public {
        address inactive = makeAddr("inactive-operator");
        vm.deal(inactive, 10 ether);
        vm.prank(inactive);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotActive.selector, inactive));
        tangle.preRegister(blueprintId);

        _registerOperator(inactive);
        vm.prank(inactive);
        tangle.preRegister(blueprintId);
    }

    function test_RegisterOperator_RevertDuplicateKey() public {
        _directRegisterOperator(operator1, blueprintId, "");

        bytes memory key = _operatorGossipKey(operator1, 0);
        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.DuplicateOperatorKey.selector, blueprintId, keccak256(key)));
        tangle.registerOperator(blueprintId, key, "");
    }

    function test_RegisterOperator_RespectsMaxBlueprintLimit() public {
        _directRegisterOperator(operator1, blueprintId, "");

        vm.prank(admin);
        tangle.setMaxBlueprintsPerOperator(1);

        vm.prank(developer);
        uint64 bp2 = tangle.createBlueprint(_blueprintDefinition("ipfs://bp-limit", address(0)));

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.MaxBlueprintsPerOperatorExceeded.selector, operator1, 1));
        tangle.registerOperator(bp2, _operatorGossipKey(operator1, 1), "");
    }

    function test_RegisterOperator_RequiresBondWhenConfigured() public {
        uint256 bond = 1 ether;
        vm.prank(admin);
        tangle.setOperatorBlueprintBond(bond);

        bytes memory key = _operatorGossipKey(operator1, 0);
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorBondMismatch.selector, blueprintId, bond, 0));
        tangle.registerOperator(blueprintId, key, "");

        uint256 contractBalanceBefore = address(tangle).balance;
        vm.prank(operator1);
        tangle.registerOperator{ value: bond }(blueprintId, key, "");
        assertEq(address(tangle).balance, contractBalanceBefore + bond);

        vm.prank(operator1);
        tangle.unregisterOperator(blueprintId);
        assertEq(address(tangle).balance, contractBalanceBefore);
    }

    function test_RegisterOperator_WithERC20Bond() public {
        MockERC20 token = new MockERC20();
        token.mint(operator1, 500 ether);

        vm.prank(admin);
        tangle.setOperatorBondAsset(address(token));
        vm.prank(admin);
        tangle.setOperatorBlueprintBond(100 ether);
        assertEq(tangle.operatorBondToken(), address(token));

        vm.prank(operator1);
        token.approve(address(tangle), type(uint256).max);

        vm.prank(operator1);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator1, 4), "");

        Types.OperatorRegistration memory reg = tangle.getOperatorRegistration(blueprintId, operator1);
        assertEq(reg.bondAmount, 100 ether);
        assertEq(reg.bondToken, address(token));

        vm.prank(operator1);
        tangle.unregisterOperator(blueprintId);
        assertEq(token.balanceOf(operator1), 500 ether);
    }

    function test_UnregisterOperator_Success() public {
        _directRegisterOperator(operator1, blueprintId, "");

        vm.prank(operator1);
        tangle.unregisterOperator(blueprintId);

        Types.OperatorRegistration memory reg = tangle.getOperatorRegistration(blueprintId, operator1);
        assertEq(reg.active, false);
    }

    function test_UnregisterOperator_RevertNotRegistered() public {
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotRegistered.selector, blueprintId, operator1));
        tangle.unregisterOperator(blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE APPROVAL
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ApproveService_SingleOperator() public {
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceActive(serviceId));
        assertTrue(tangle.isServiceOperator(serviceId, operator1));
    }

    function test_ApproveService_MultipleOperators() public {
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        // First operator approves
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Service not active yet
        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertEq(req.approvalCount, 1);

        // Second operator approves
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // Now service is active
        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceActive(serviceId));
        assertTrue(tangle.isServiceOperator(serviceId, operator1));
        assertTrue(tangle.isServiceOperator(serviceId, operator2));
    }

    function test_ApproveService_RevertNotInRequest() public {
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        // Operator2 was not in the request
        vm.prank(operator2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.approveService(requestId, 0);
    }

    function test_ApproveService_RevertAlreadyApproved() public {
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        // Need 2 operators so first approval doesn't activate the service
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Try to approve again
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.AlreadyApproved.selector, requestId, operator1));
        tangle.approveService(requestId, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REJECTION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RejectService_ByOperator() public {
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        vm.prank(operator1);
        tangle.rejectService(requestId);

        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertTrue(req.rejected);
    }

    function test_RejectService_RefundsPayment() public {
        _registerForBlueprint(operator1, blueprintId);

        uint256 payment = 5 ether;
        uint256 userBalanceBefore = user1.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);
        assertEq(user1.balance, userBalanceBefore - payment);

        vm.prank(operator1);
        tangle.rejectService(requestId);

        assertEq(user1.balance, userBalanceBefore);
    }

    function test_RejectService_RevertNotInRequest() public {
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        vm.prank(operator2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.rejectService(requestId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RequestServiceWithExposure() public {
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 5000; // 50%
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure(
            blueprintId, operators, exposures, "", callers, 0, address(0), 0
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.ServiceOperator memory opInfo = tangle.getServiceOperator(serviceId, operator1);
        assertEq(opInfo.exposureBps, 5000);
    }

    function test_RequestServiceWithExposure_DefaultExposure() public {
        _registerForBlueprint(operator1, blueprintId);

        // Regular request (no exposure specified) should default to 100%
        uint64 requestId = _requestService(user1, blueprintId, operator1);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        Types.ServiceOperator memory opInfo = tangle.getServiceOperator(serviceId, operator1);
        assertEq(opInfo.exposureBps, 10000); // 100%
    }

    function test_RequestService_AddsDefaultTntSecurityRequirement() public {
        _registerForBlueprint(operator1, blueprintId);

        MockERC20 tnt = new MockERC20();
        vm.prank(admin);
        tangle.setTntToken(address(tnt));

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        Types.AssetSecurityRequirement[] memory reqs = tangle.getServiceRequestSecurityRequirements(requestId);
        assertEq(reqs.length, 1);
        assertEq(uint8(reqs[0].asset.kind), uint8(Types.AssetKind.ERC20));
        assertEq(reqs[0].asset.token, address(tnt));
        assertEq(reqs[0].minExposureBps, 1000); // 10%
        assertEq(reqs[0].maxExposureBps, 10000);
    }

    function test_ApproveService_AutoCommitsDefaultTntExposure() public {
        _registerForBlueprint(operator1, blueprintId);

        MockERC20 tnt = new MockERC20();
        vm.prank(admin);
        tangle.setTntToken(address(tnt));

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        Types.AssetSecurityCommitment[] memory commits =
            tangle.getServiceRequestSecurityCommitments(requestId, operator1);
        assertEq(commits.length, 1);
        assertEq(uint8(commits[0].asset.kind), uint8(Types.AssetKind.ERC20));
        assertEq(commits[0].asset.token, address(tnt));
        assertEq(commits[0].exposureBps, 1000); // 10%
    }

    function test_ApproveService_RevertsWhenExtraSecurityRequirementsPresent() public {
        _registerForBlueprint(operator1, blueprintId);

        MockERC20 tnt = new MockERC20();
        vm.prank(admin);
        tangle.setTntToken(address(tnt));

        // Add an extra security requirement (native)
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 5000,
            maxExposureBps: 10000
        });

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, operators, requirements, "", callers, 0, address(0), 0
        );

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.SecurityCommitmentsRequired.selector, requestId));
        tangle.approveService(requestId, 0);
    }


    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC SERVICE MEMBERSHIP
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JoinDynamicService() public {
        // Create dynamic blueprint
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0,
            operatorBond: 0
        });

        vm.prank(developer);
        uint64 dynamicBp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        _registerForBlueprint(operator1, dynamicBp);
        _registerForBlueprint(operator2, dynamicBp);

        // Create service with one operator
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(dynamicBp, operators, "", callers, 0, address(0), 0);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Second operator joins
        vm.prank(operator2);
        tangle.joinService(serviceId, 8000);

        assertTrue(tangle.isServiceOperator(serviceId, operator2));
        Types.ServiceOperator memory opInfo = tangle.getServiceOperator(serviceId, operator2);
        assertEq(opInfo.exposureBps, 8000);
    }

    function test_JoinService_RevertNotDynamic() public {
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Blueprint is Fixed, not Dynamic
        vm.prank(operator2);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.joinService(serviceId, 10000);
    }

    function test_LeaveService() public {
        // Create dynamic blueprint
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0,
            operatorBond: 0
        });

        vm.prank(developer);
        uint64 dynamicBp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://dynamic", address(0), config));

        _registerForBlueprint(operator1, dynamicBp);
        _registerForBlueprint(operator2, dynamicBp);

        // Create service with two operators
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(dynamicBp, operators, "", callers, 0, address(0), 0);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceOperator(serviceId, operator2));

        // Warp past minimum commitment duration (1 day default for no BSM)
        vm.warp(block.timestamp + 1 days + 1);

        // Schedule exit
        vm.prank(operator2);
        tangle.scheduleExit(serviceId);
        assertEq(uint(tangle.getExitStatus(serviceId, operator2)), uint(Types.ExitStatus.Scheduled));

        // Warp past exit queue duration (7 days default)
        vm.warp(block.timestamp + 7 days + 1);
        assertEq(uint(tangle.getExitStatus(serviceId, operator2)), uint(Types.ExitStatus.Executable));

        // Execute exit
        vm.prank(operator2);
        tangle.executeExit(serviceId);

        assertFalse(tangle.isServiceOperator(serviceId, operator2));
        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(svc.operatorCount, 1);
    }

    function test_LeaveService_RevertBelowMinimum() public {
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Cannot leave if would drop below minimum
        vm.prank(operator1);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.leaveService(serviceId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE TERMINATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_TerminateService_ByOwner() public {
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceActive(serviceId));

        vm.prank(user1);
        tangle.terminateService(serviceId);

        assertFalse(tangle.isServiceActive(serviceId));
        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(uint8(svc.status), uint8(Types.ServiceStatus.Terminated));
    }

    function test_TerminateService_RevertNotOwner() public {
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotServiceOwner.selector, serviceId, user2));
        tangle.terminateService(serviceId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PERMITTED CALLERS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ServiceWithPermittedCallers() public {
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](2);
        callers[0] = makeAddr("caller1");
        callers[1] = makeAddr("caller2");

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Owner is always permitted
        assertTrue(tangle.isPermittedCaller(serviceId, user1));
        // Specified callers are permitted
        assertTrue(tangle.isPermittedCaller(serviceId, callers[0]));
        assertTrue(tangle.isPermittedCaller(serviceId, callers[1]));
        // Others are not
        assertFalse(tangle.isPermittedCaller(serviceId, user2));
    }

    function test_AddPermittedCaller() public {
        _registerForBlueprint(operator1, blueprintId);

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        address newCaller = makeAddr("newCaller");

        assertFalse(tangle.isPermittedCaller(serviceId, newCaller));

        vm.prank(user1);
        tangle.addPermittedCaller(serviceId, newCaller);

        assertTrue(tangle.isPermittedCaller(serviceId, newCaller));
    }

    function test_RemovePermittedCaller() public {
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](1);
        callers[0] = makeAddr("removable");

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isPermittedCaller(serviceId, callers[0]));

        vm.prank(user1);
        tangle.removePermittedCaller(serviceId, callers[0]);

        assertFalse(tangle.isPermittedCaller(serviceId, callers[0]));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTIPLE BLUEPRINT REGISTRATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RegisterForMultipleBlueprints() public {
        vm.prank(developer);
        uint64 bp2 = tangle.createBlueprint(_blueprintDefinition("ipfs://bp2", address(0)));
        vm.prank(developer);
        uint64 bp3 = tangle.createBlueprint(_blueprintDefinition("ipfs://bp3", address(0)));

        vm.startPrank(operator1);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator1, 1), "");
        tangle.registerOperator(bp2, _operatorGossipKey(operator1, 2), "");
        tangle.registerOperator(bp3, _operatorGossipKey(operator1, 3), "");
        vm.stopPrank();

        Types.OperatorRegistration memory reg1 = tangle.getOperatorRegistration(blueprintId, operator1);
        Types.OperatorRegistration memory reg2 = tangle.getOperatorRegistration(bp2, operator1);
        Types.OperatorRegistration memory reg3 = tangle.getOperatorRegistration(bp3, operator1);

        assertTrue(reg1.active);
        assertTrue(reg2.active);
        assertTrue(reg3.active);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE TTL
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ServiceExpiration() public {
        _registerForBlueprint(operator1, blueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, operators, "", callers, 100, address(0), 0 // 100 block TTL
        );
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceActive(serviceId));

        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(svc.ttl, 100);
        assertGt(svc.createdAt, 0);
    }
}
