// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintTestHarness } from "./TestHarness.sol";
import { MockBSM_V1, MockBSM_V2, MockBSM_V3 } from "./mocks/MockBSM.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";

/// @title BSMHooksLifecycleTest
/// @notice Comprehensive tests for BSM hook lifecycle across versions
contract BSMHooksLifecycleTest is BlueprintTestHarness {
    // ═══════════════════════════════════════════════════════════════════════════
    // HARNESS IMPLEMENTATION
    // ═══════════════════════════════════════════════════════════════════════════

    function _deployManager(uint256 version) internal override returns (address) {
        if (version == 1) {
            return address(new MockBSM_V1());
        } else if (version == 2) {
            return address(new MockBSM_V2());
        } else if (version == 3) {
            return address(new MockBSM_V3());
        }
        revert("Unknown version");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT CREATION HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V1_OnBlueprintCreated_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);

        MockBSM_V1 bsm = MockBSM_V1(manager);
        assertEq(bsm.blueprintId(), blueprintId);
        assertEq(bsm.blueprintOwner(), blueprintOwner);
        assertEq(bsm.tangleCore(), address(tangle));
        assertEq(bsm.getHookCalls().onBlueprintCreated, 1);
    }

    function test_V2_OnBlueprintCreated_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(2);

        MockBSM_V2 bsm = MockBSM_V2(manager);
        assertEq(bsm.blueprintId(), blueprintId);
        assertEq(bsm.version(), 2);
        assertEq(bsm.getHookCalls().onBlueprintCreated, 1);
    }

    function test_V3_OnBlueprintCreated_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(3);

        MockBSM_V3 bsm = MockBSM_V3(manager);
        assertEq(bsm.blueprintId(), blueprintId);
        assertEq(bsm.version(), 3);
        assertEq(bsm.getHookCalls().onBlueprintCreated, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V1_OnRegister_TracksOperators() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerAllOperatorsForBlueprint(blueprintId);

        assertEq(bsm.getHookCalls().onRegister, 3);
        assertEq(bsm.getRegisteredOperatorCount(), 3);
    }

    function test_V1_OnRegister_StoresInputs() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        bytes memory customInputs = abi.encode("custom", 123);
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, customInputs);

        assertEq(bsm.operatorRegistrationInputs(operator1), customInputs);
    }

    function test_V2_OnRegister_AllowlistEnforced() public {
        (uint64 blueprintId, address manager) = deployBlueprint(2);
        MockBSM_V2 bsm = MockBSM_V2(manager);

        // Enable allowlist
        bsm.setOperatorAllowlistEnabled(true);
        bsm.setAllowedOperator(operator1, true);

        // Allowed operator succeeds
        vm.prank(operator1);
        tangle.registerOperator(blueprintId, "");
        assertEq(bsm.getHookCalls().onRegister, 1);

        // Non-allowed operator fails - error is wrapped in ManagerReverted
        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(
            Errors.ManagerReverted.selector,
            manager,
            abi.encodeWithSelector(MockBSM_V2.OperatorNotAllowed.selector, operator2)
        ));
        tangle.registerOperator(blueprintId, "");
    }

    function test_V1_OnUnregister_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);

        vm.prank(operator1);
        tangle.unregisterOperator(blueprintId);

        assertEq(bsm.getHookCalls().onUnregister, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V1_OnRequest_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(serviceOwner);
        tangle.requestService{ value: 1 ether }(blueprintId, ops, "test-inputs", new address[](0), 0, address(0), 1 ether);

        assertEq(bsm.getHookCalls().onRequest, 1);
    }

    function test_V2_OnRequest_EnforcesMinimumPayment() public {
        (uint64 blueprintId, address manager) = deployBlueprint(2);
        MockBSM_V2 bsm = MockBSM_V2(manager);

        // Set minimum payment
        bsm.setMinimumPayment(1 ether);

        registerOperatorForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        // Below minimum fails - error is wrapped in ManagerReverted
        vm.prank(serviceOwner);
        vm.expectRevert(abi.encodeWithSelector(
            Errors.ManagerReverted.selector,
            manager,
            abi.encodeWithSelector(MockBSM_V2.InsufficientPayment.selector, 1 ether, 0.5 ether)
        ));
        tangle.requestService{ value: 0.5 ether }(blueprintId, ops, "", new address[](0), 0, address(0), 0.5 ether);

        // At minimum succeeds
        vm.prank(serviceOwner);
        tangle.requestService{ value: 1 ether }(blueprintId, ops, "", new address[](0), 0, address(0), 1 ether);
        assertEq(bsm.getHookCalls().onRequest, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE APPROVAL & INITIALIZATION HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V1_OnApprove_CalledPerOperator() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        registerOperatorForBlueprint(operator2, blueprintId);

        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;

        vm.prank(serviceOwner);
        uint64 requestId = tangle.requestService{ value: 1 ether }(
            blueprintId, ops, "", new address[](0), 0, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        assertEq(bsm.getHookCalls().onApprove, 1);

        vm.prank(operator2);
        tangle.approveService(requestId, 0);
        assertEq(bsm.getHookCalls().onApprove, 2);
    }

    function test_V1_OnServiceInitialized_CalledAfterAllApprovals() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        assertEq(bsm.getHookCalls().onServiceInitialized, 1);
        assertEq(bsm.getInitializedServiceCount(), 1);
    }

    function test_V1_OnReject_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(serviceOwner);
        uint64 requestId = tangle.requestService{ value: 1 ether }(
            blueprintId, ops, "", new address[](0), 0, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.rejectService(requestId);

        assertEq(bsm.getHookCalls().onReject, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB LIFECYCLE HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V1_OnJobCall_TracksInputs() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        bytes memory jobInputs = abi.encode("job", "inputs", 42);
        uint64 callId = submitJob(serviceId, 0, jobInputs);

        // onJobCall hook was called
        assertEq(bsm.getHookCalls().onJobCall, 1);
        assertEq(bsm.jobCallCounts(serviceId), 1);
        assertEq(bsm.jobInputs(serviceId, callId), jobInputs);
    }

    function test_V1_OnJobResult_TracksOutputs() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        uint64 callId = submitJob(serviceId, 0, "inputs");

        bytes memory outputs = abi.encode("result", 100);
        submitJobResult(serviceId, callId, operator1, outputs);

        // onJobResult hook was called
        assertEq(bsm.getHookCalls().onJobResult, 1);
        assertEq(bsm.jobOutputs(serviceId, callId), outputs);
    }

    function test_V2_OnJobCall_EnforcesMaxJobIndex() public {
        (uint64 blueprintId, address manager) = deployBlueprint(2);
        MockBSM_V2 bsm = MockBSM_V2(manager);

        // Set max job index to 5
        bsm.setMaxJobIndex(5);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Job index 0-5 should work
        submitJob(serviceId, 0, "inputs");
        assertEq(bsm.getHookCalls().onJobCall, 1);

        // Job index 6 should fail (wrapped in ManagerReverted)
        vm.prank(serviceOwner);
        vm.expectRevert(abi.encodeWithSelector(
            Errors.ManagerReverted.selector,
            manager,
            abi.encodeWithSelector(MockBSM_V2.InvalidJobIndex.selector, 6)
        ));
        tangle.submitJob(serviceId, 6, "inputs");
    }

    function test_V3_ServiceActive_TrackedByBSM() public {
        (uint64 blueprintId, address manager) = deployBlueprint(3);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // BSM tracks service as active via onServiceInitialized
        assertTrue(bsm.serviceActive(serviceId));

        // Job works on active service with hook called
        submitJob(serviceId, 0, "inputs");
        assertEq(bsm.getHookCalls().onJobCall, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE TERMINATION HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V1_OnServiceTermination_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        vm.prank(serviceOwner);
        tangle.terminateService(serviceId);

        assertEq(bsm.getHookCalls().onServiceTermination, 1);
    }

    function test_V3_OnServiceTermination_UpdatesState() public {
        (uint64 blueprintId, address manager) = deployBlueprint(3);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        assertTrue(bsm.serviceActive(serviceId));

        vm.prank(serviceOwner);
        tangle.terminateService(serviceId);

        assertFalse(bsm.serviceActive(serviceId));
        assertEq(bsm.getHookCalls().onServiceTermination, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V1_OnSlash_Called() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        uint64 slashId = proposeSlash(serviceId, operator1, 0.5 ether);
        executeSlash(slashId);

        assertEq(bsm.getHookCalls().onSlash, 1);
    }

    /// @notice Custom slashing origin is ADDITIVE - service owner and blueprint owner
    /// are always authorized. The custom origin just adds another authorized party.
    function test_V3_CustomSlashingOrigin_Works() public {
        (uint64 blueprintId, address manager) = deployBlueprint(3);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Set custom slashing origin
        address customSlasher = makeAddr("customSlasher");
        bsm.setCustomSlashingOrigin(serviceId, customSlasher);
        assertEq(bsm.querySlashingOrigin(serviceId), customSlasher);

        // Service owner can STILL slash (authorization is additive)
        vm.prank(serviceOwner);
        uint64 slashId1 = tangle.proposeSlash(serviceId, operator1, 0.1 ether, keccak256("evidence1"));

        // Custom slasher can ALSO slash
        vm.deal(customSlasher, 1 ether);
        vm.prank(customSlasher);
        uint64 slashId2 = tangle.proposeSlash(serviceId, operator1, 0.2 ether, keccak256("evidence2"));

        // Random address cannot slash
        address randomUser = makeAddr("randomUser");
        vm.prank(randomUser);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.proposeSlash(serviceId, operator1, 0.1 ether, keccak256("evidence3"));

        // Execute one of the slashes
        executeSlash(slashId1);
        assertEq(bsm.getHookCalls().onSlash, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V3_MembershipControls_CanBlockJoin() public {
        // Create dynamic membership blueprint
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        (uint64 blueprintId, address manager) = deployBlueprintWithConfig(3, blueprintOwner, config);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        registerOperatorForBlueprint(operator2, blueprintId);

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Block operator2 from joining
        bsm.setBlockedFromJoining(serviceId, operator2, true);

        // operator2 can't join
        assertFalse(bsm.canJoin(serviceId, operator2));

        // operator3 (not blocked) can be checked
        assertTrue(bsm.canJoin(serviceId, operator3));
    }

    function test_V3_MembershipControls_CanBlockLeave() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        (uint64 blueprintId, address manager) = deployBlueprintWithConfig(3, blueprintOwner, config);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Block operator1 from leaving
        bsm.setBlockedFromLeaving(serviceId, operator1, true);

        assertFalse(bsm.canLeave(serviceId, operator1));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT QUERY HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V3_CustomDeveloperAddress_Works() public {
        (uint64 blueprintId, address manager) = deployBlueprint(3);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);

        // Set custom developer address before creating service
        address payable customDev = payable(makeAddr("customDev"));
        bsm.setCustomDeveloperAddress(0, customDev); // Pre-set for serviceId 0

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);
        bsm.setCustomDeveloperAddress(serviceId, customDev);

        assertEq(bsm.queryDeveloperPaymentAddress(serviceId), customDev);
    }

    function test_V1_DefaultDeveloperAddress_IsBlueprintOwner() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        assertEq(bsm.queryDeveloperPaymentAddress(0), blueprintOwner);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB CONFIG QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V3_CustomResultCount_Works() public {
        (uint64 blueprintId, address manager) = deployBlueprint(3);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Default is 1
        assertEq(bsm.getRequiredResultCount(serviceId, 0), 1);

        // Set custom count
        bsm.setCustomResultCount(serviceId, 0, 3);
        assertEq(bsm.getRequiredResultCount(serviceId, 0), 3);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE CONFIG QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_V2_CustomHeartbeatInterval_Works() public {
        (uint64 blueprintId, address manager) = deployBlueprint(2);
        MockBSM_V2 bsm = MockBSM_V2(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Default uses protocol default
        (bool useDefault, uint64 interval) = bsm.getHeartbeatInterval(serviceId);
        assertTrue(useDefault);

        // Set custom interval
        bsm.setCustomHeartbeatInterval(serviceId, 100);
        (useDefault, interval) = bsm.getHeartbeatInterval(serviceId);
        assertFalse(useDefault);
        assertEq(interval, 100);
    }

    function test_V2_CustomSlashingWindow_Works() public {
        (uint64 blueprintId, address manager) = deployBlueprint(2);
        MockBSM_V2 bsm = MockBSM_V2(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Set custom slashing window
        bsm.setCustomSlashingWindow(serviceId, 3 days);
        (bool useDefault, uint64 window) = bsm.getSlashingWindow(serviceId);
        assertFalse(useDefault);
        assertEq(window, 3 days);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FULL LIFECYCLE TEST
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Full lifecycle test - all hooks are called
    function test_FullLifecycle_AllHooksCalled() public {
        (uint64 blueprintId, address manager) = deployBlueprint(1);
        MockBSM_V1 bsm = MockBSM_V1(manager);

        // 1. Blueprint created
        assertEq(bsm.getHookCalls().onBlueprintCreated, 1);

        // 2. Operator registers
        registerOperatorForBlueprint(operator1, blueprintId);
        assertEq(bsm.getHookCalls().onRegister, 1);

        // 3. Service requested
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(serviceOwner);
        uint64 requestId = tangle.requestService{ value: 1 ether }(
            blueprintId, ops, "test", new address[](0), 0, address(0), 1 ether
        );
        assertEq(bsm.getHookCalls().onRequest, 1);

        // 4. Operator approves
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        assertEq(bsm.getHookCalls().onApprove, 1);

        // 5. Service initialized
        assertEq(bsm.getHookCalls().onServiceInitialized, 1);
        uint64 serviceId = tangle.serviceCount() - 1;

        // 6. Job submitted - onJobCall hook called
        uint64 callId = submitJob(serviceId, 0, "job-input");
        assertEq(bsm.getHookCalls().onJobCall, 1);

        // 7. Job result submitted - onJobResult hook called
        submitJobResult(serviceId, callId, operator1, "job-output");
        assertEq(bsm.getHookCalls().onJobResult, 1);

        // 8. Slashing
        uint64 slashId = proposeSlash(serviceId, operator1, 0.1 ether);
        executeSlash(slashId);
        assertEq(bsm.getHookCalls().onSlash, 1);

        // 9. Service terminated
        vm.prank(serviceOwner);
        tangle.terminateService(serviceId);
        assertEq(bsm.getHookCalls().onServiceTermination, 1);

        // 10. Operator unregisters
        vm.prank(operator1);
        tangle.unregisterOperator(blueprintId);
        assertEq(bsm.getHookCalls().onUnregister, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP HOOK TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test that onOperatorJoined hook is called when operator joins dynamic service
    function test_V3_OnOperatorJoined_CalledOnJoin() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        (uint64 blueprintId, address manager) = deployBlueprintWithConfig(3, blueprintOwner, config);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        registerOperatorForBlueprint(operator2, blueprintId);

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // operator2 joins the service
        vm.prank(operator2);
        tangle.joinService(serviceId, 5000); // 50% exposure

        assertEq(bsm.getHookCalls().onOperatorJoined, 1);
    }

    /// @notice Test that onOperatorLeft hook is called when operator leaves dynamic service
    function test_V3_OnOperatorLeft_CalledOnLeave() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        (uint64 blueprintId, address manager) = deployBlueprintWithConfig(3, blueprintOwner, config);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        registerOperatorForBlueprint(operator2, blueprintId);

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // operator2 joins then leaves
        vm.prank(operator2);
        tangle.joinService(serviceId, 5000);

        vm.prank(operator2);
        tangle.leaveService(serviceId);

        assertEq(bsm.getHookCalls().onOperatorLeft, 1);
    }

    /// @notice Test that canJoin=false blocks operator from joining
    function test_V3_CanJoin_BlocksOperator() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        (uint64 blueprintId, address manager) = deployBlueprintWithConfig(3, blueprintOwner, config);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        registerOperatorForBlueprint(operator2, blueprintId);

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // Block operator2 from joining
        bsm.setBlockedFromJoining(serviceId, operator2, true);

        // operator2 cannot join
        vm.prank(operator2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.joinService(serviceId, 5000);
    }

    /// @notice Test that canLeave=false blocks operator from leaving
    function test_V3_CanLeave_BlocksOperator() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        (uint64 blueprintId, address manager) = deployBlueprintWithConfig(3, blueprintOwner, config);
        MockBSM_V3 bsm = MockBSM_V3(manager);

        registerOperatorForBlueprint(operator1, blueprintId);
        registerOperatorForBlueprint(operator2, blueprintId);

        uint64 serviceId = createService(blueprintId, operator1, 1 ether);

        // operator2 joins
        vm.prank(operator2);
        tangle.joinService(serviceId, 5000);

        // Block operator2 from leaving
        bsm.setBlockedFromLeaving(serviceId, operator2, true);

        // operator2 cannot leave
        vm.prank(operator2);
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.leaveService(serviceId);
    }
}
