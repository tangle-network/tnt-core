// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintTestHarness } from "./TestHarness.sol";
import { MockBSM_V1, MockBSM_V2, MockBSM_V3 } from "./mocks/MockBSM.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { SlashingLib } from "../../../src/v2/libraries/SlashingLib.sol";

/// @title CrossVersionCompatibilityTest
/// @notice Tests multiple blueprint versions coexisting and slashing across versions
contract CrossVersionCompatibilityTest is BlueprintTestHarness {
    // Deployed blueprints by version
    uint64 public blueprintV1;
    uint64 public blueprintV2;
    uint64 public blueprintV3;

    MockBSM_V1 public bsmV1;
    MockBSM_V2 public bsmV2;
    MockBSM_V3 public bsmV3;

    function _deployManager(uint256 version) internal override returns (address) {
        if (version == 1) return address(new MockBSM_V1());
        if (version == 2) return address(new MockBSM_V2());
        if (version == 3) return address(new MockBSM_V3());
        revert("Unknown version");
    }

    function setUp() public override {
        super.setUp();

        // Deploy all three versions
        address m1;
        address m2;
        address m3;
        (blueprintV1, m1) = deployBlueprint(1);
        (blueprintV2, m2) = deployBlueprint(2);
        (blueprintV3, m3) = deployBlueprint(3);

        bsmV1 = MockBSM_V1(payable(m1));
        bsmV2 = MockBSM_V2(payable(m2));
        bsmV3 = MockBSM_V3(payable(m3));

        // Register all operators for all blueprints
        registerAllOperatorsForBlueprint(blueprintV1);
        registerAllOperatorsForBlueprint(blueprintV2);
        registerAllOperatorsForBlueprint(blueprintV3);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTIPLE VERSIONS COEXISTING
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultipleVersions_CanCoexist() public {
        // All blueprints should be created
        assertEq(bsmV1.version(), 1);
        assertEq(bsmV2.version(), 2);
        assertEq(bsmV3.version(), 3);

        // All should have registered operators
        assertEq(bsmV1.getRegisteredOperatorCount(), 3);
        assertEq(bsmV2.getRegisteredOperatorCount(), 3);
        assertEq(bsmV3.getRegisteredOperatorCount(), 3);
    }

    function test_SameOperator_MultipleVersions() public {
        // operator1 should be registered on all versions
        // Create services on each version with operator1
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);
        uint64 serviceV2 = createService(blueprintV2, operator1, 1 ether);
        uint64 serviceV3 = createService(blueprintV3, operator1, 1 ether);

        assertTrue(tangle.isServiceActive(serviceV1));
        assertTrue(tangle.isServiceActive(serviceV2));
        assertTrue(tangle.isServiceActive(serviceV3));

        // Each BSM should have its own service initialized
        assertEq(bsmV1.getInitializedServiceCount(), 1);
        assertEq(bsmV2.getInitializedServiceCount(), 1);
        assertEq(bsmV3.getInitializedServiceCount(), 1);
    }

    /// @notice Jobs work across different versions independently with hooks called
    function test_ServicesOnDifferentVersions_Independent() public {
        // Create services
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);
        uint64 serviceV2 = createService(blueprintV2, operator2, 1 ether);
        uint64 serviceV3 = createService(blueprintV3, operator3, 1 ether);

        // Submit jobs on each
        uint64 callIdV1 = submitJob(serviceV1, 0, "v1-input");
        uint64 callIdV2 = submitJob(serviceV2, 0, "v2-input");
        uint64 callIdV3 = submitJob(serviceV3, 0, "v3-input");

        // Verify each BSM tracks its own jobs via onJobCall
        assertEq(bsmV1.jobCallCounts(serviceV1), 1);
        assertEq(bsmV2.jobCallCounts(serviceV2), 1);
        assertEq(bsmV3.jobCallCounts(serviceV3), 1);

        // Submit results
        submitJobResult(serviceV1, callIdV1, operator1, "v1-output");
        submitJobResult(serviceV2, callIdV2, operator2, "v2-output");
        submitJobResult(serviceV3, callIdV3, operator3, "v3-output");

        // Verify onJobResult hooks called
        assertEq(bsmV1.getHookCalls().onJobResult, 1);
        assertEq(bsmV2.getHookCalls().onJobResult, 1);
        assertEq(bsmV3.getHookCalls().onJobResult, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING ACROSS BLUEPRINT VERSIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Slashing_V1Blueprint_Works() public {
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);

        uint64 slashId = proposeSlash(serviceV1, operator1, 0.5 ether);
        executeSlash(slashId);

        assertEq(bsmV1.getHookCalls().onSlash, 1);
    }

    function test_Slashing_V2Blueprint_Works() public {
        uint64 serviceV2 = createService(blueprintV2, operator1, 1 ether);

        uint64 slashId = proposeSlash(serviceV2, operator1, 0.5 ether);
        executeSlash(slashId);

        assertEq(bsmV2.getHookCalls().onSlash, 1);
    }

    function test_Slashing_V3Blueprint_Works() public {
        uint64 serviceV3 = createService(blueprintV3, operator1, 1 ether);

        uint64 slashId = proposeSlash(serviceV3, operator1, 0.5 ether);
        executeSlash(slashId);

        assertEq(bsmV3.getHookCalls().onSlash, 1);
    }

    function test_Slashing_MultipleBlueprintVersions_Concurrent() public {
        // Create services on all versions
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);
        uint64 serviceV2 = createService(blueprintV2, operator1, 1 ether);
        uint64 serviceV3 = createService(blueprintV3, operator1, 1 ether);

        // Propose slashes on all three
        uint64 slashIdV1 = proposeSlash(serviceV1, operator1, 0.2 ether);
        uint64 slashIdV2 = proposeSlash(serviceV2, operator1, 0.3 ether);
        uint64 slashIdV3 = proposeSlash(serviceV3, operator1, 0.4 ether);

        // Fast forward and execute all
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);

        tangle.executeSlash(slashIdV1);
        tangle.executeSlash(slashIdV2);
        tangle.executeSlash(slashIdV3);

        // Each BSM should have received its slash callback
        assertEq(bsmV1.getHookCalls().onSlash, 1);
        assertEq(bsmV2.getHookCalls().onSlash, 1);
        assertEq(bsmV3.getHookCalls().onSlash, 1);
    }

    function test_Slashing_V3CustomSlashingOrigin_DoesNotAffectOtherVersions() public {
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);
        uint64 serviceV3 = createService(blueprintV3, operator2, 1 ether);

        // Set custom slashing origin for V3 service
        address customSlasher = makeAddr("customSlasher");
        bsmV3.setCustomSlashingOrigin(serviceV3, customSlasher);

        // V1 service still uses default slashing origin (service owner)
        uint64 slashIdV1 = proposeSlash(serviceV1, operator1, 0.2 ether);

        // V3 service requires custom slasher
        vm.deal(customSlasher, 1 ether);
        vm.prank(customSlasher);
        uint64 slashIdV3 = tangle.proposeSlash(serviceV3, operator2, 3000, keccak256("evidence"));

        // Execute both
        // M-6 FIX: Add TIMESTAMP_BUFFER (15s) to account for manipulation protection
        vm.warp(block.timestamp + 7 days + 16);
        tangle.executeSlash(slashIdV1);
        tangle.executeSlash(slashIdV3);

        assertEq(bsmV1.getHookCalls().onSlash, 1);
        assertEq(bsmV3.getHookCalls().onSlash, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OLD BLUEPRINTS CONTINUE WORKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Old blueprints continue working after new versions are deployed
    function test_OldBlueprint_ContinuesWorking_AfterNewBlueprintDeployed() public {
        // V1 was deployed first, V2 and V3 deployed after
        // Create service on V1 (the "old" blueprint)
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);

        // Deploy another V3 blueprint (simulating protocol evolution)
        address m;
        uint64 blueprintV3_2;
        (blueprintV3_2, m) = deployBlueprint(3);
        MockBSM_V3 bsmV3_2 = MockBSM_V3(payable(m));
        registerOperatorForBlueprint(operator1, blueprintV3_2);

        // V1 service still works - with hooks called
        uint64 callId = submitJob(serviceV1, 0, "still-working");
        submitJobResult(serviceV1, callId, operator1, "v1-result");

        assertEq(bsmV1.getHookCalls().onJobCall, 1);
        assertEq(bsmV1.getHookCalls().onJobResult, 1);

        // New V3 service also works independently
        uint64 serviceV3_2 = createService(blueprintV3_2, operator1, 1 ether);
        uint64 callIdV3 = submitJob(serviceV3_2, 0, "new-v3-input");
        submitJobResult(serviceV3_2, callIdV3, operator1, "v3-result");

        assertEq(bsmV3_2.getHookCalls().onJobCall, 1);
        assertEq(bsmV3_2.getHookCalls().onJobResult, 1);
    }

    function test_OldBlueprint_CanStillSlash_AfterNewVersions() public {
        // Create old V1 service
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);

        // Deploy more blueprints
        deployBlueprint(2);
        deployBlueprint(3);
        deployBlueprint(3);

        // V1 slashing still works
        uint64 slashId = proposeSlash(serviceV1, operator1, 0.5 ether);
        executeSlash(slashId);

        assertEq(bsmV1.getHookCalls().onSlash, 1);
    }

    function test_OldBlueprint_CanStillTerminate() public {
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);

        // Deploy new versions
        deployBlueprint(3);
        deployBlueprint(3);

        // Old service terminates normally
        vm.prank(serviceOwner);
        tangle.terminateService(serviceV1);

        assertEq(bsmV1.getHookCalls().onServiceTermination, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR ACROSS VERSIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slashing on one version doesn't affect services on other versions
    function test_OperatorSlashed_OnOneVersion_IndependentOfOthers() public {
        // operator1 has services on V1 and V3
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);
        uint64 serviceV3 = createService(blueprintV3, operator1, 1 ether);

        // Slash on V1 only
        uint64 slashId = proposeSlash(serviceV1, operator1, 0.5 ether);
        executeSlash(slashId);

        // V3 service should still be active
        assertTrue(tangle.isServiceActive(serviceV3));

        // V3 jobs should still work with hooks called
        uint64 callId = submitJob(serviceV3, 0, "still-working");
        submitJobResult(serviceV3, callId, operator1, "result");

        assertEq(bsmV3.getHookCalls().onJobCall, 1);
        assertEq(bsmV3.getHookCalls().onJobResult, 1);
    }

    /// @notice Unregistering from one version doesn't affect other versions
    function test_OperatorUnregisters_OneVersion_StillWorksOnOthers() public {
        // Create services on V1 and V2
        uint64 serviceV1 = createService(blueprintV1, operator1, 1 ether);
        uint64 serviceV2 = createService(blueprintV2, operator1, 1 ether);

        // Terminate V1 service and unregister
        vm.prank(serviceOwner);
        tangle.terminateService(serviceV1);

        vm.prank(operator1);
        tangle.unregisterOperator(blueprintV1);

        // V2 service still works with hooks called
        uint64 callId = submitJob(serviceV2, 0, "v2-works");
        submitJobResult(serviceV2, callId, operator1, "v2-result");

        assertEq(bsmV2.getHookCalls().onJobCall, 1);
        assertEq(bsmV2.getHookCalls().onJobResult, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VERSION-SPECIFIC FEATURES DON'T BREAK OTHERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice V2 allowlist doesn't affect V1 services
    function test_V2AllowList_DoesNotAffectV1() public {
        // Enable allowlist on V2 (restrictive)
        bsmV2.setOperatorAllowlistEnabled(true);
        bsmV2.setAllowedOperator(operator1, true);
        // operator2 not allowed on V2

        // operator2 can still register on V1 (no allowlist)
        // Already registered in setUp, but let's verify service works
        uint64 serviceV1 = createService(blueprintV1, operator2, 1 ether);

        // Verify service works with hooks called
        uint64 callId = submitJob(serviceV1, 0, "v1-op2");
        submitJobResult(serviceV1, callId, operator2, "result");

        assertEq(bsmV1.getHookCalls().onJobCall, 1);
    }

    /// @notice V2 minimum payment doesn't affect V1 services
    function test_V2MinPayment_DoesNotAffectV1() public {
        // Set minimum payment on V2
        bsmV2.setMinimumPayment(5 ether);

        // V1 accepts any payment
        uint64 serviceV1 = createService(blueprintV1, operator1, 0.1 ether);
        assertTrue(tangle.isServiceActive(serviceV1));

        // V2 requires minimum - error is wrapped in ManagerReverted
        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(serviceOwner);
        vm.expectRevert(abi.encodeWithSelector(
            Errors.ManagerReverted.selector,
            address(bsmV2),
            abi.encodeWithSelector(MockBSM_V2.InsufficientPayment.selector, 5 ether, 1 ether)
        ));
        tangle.requestService{ value: 1 ether }(blueprintV2, ops, "", new address[](0), 0, address(0), 1 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TRACKING HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GetBlueprintsOfVersion_Works() public {
        // Deploy more V1 blueprints
        deployBlueprint(1);
        deployBlueprint(1);

        // Deploy more V3 blueprints
        deployBlueprint(3);

        uint64[] memory v1Blueprints = getBlueprintsOfVersion(1);
        uint64[] memory v2Blueprints = getBlueprintsOfVersion(2);
        uint64[] memory v3Blueprints = getBlueprintsOfVersion(3);

        assertEq(v1Blueprints.length, 3); // Original + 2 new
        assertEq(v2Blueprints.length, 1); // Original only
        assertEq(v3Blueprints.length, 2); // Original + 1 new
    }
}
