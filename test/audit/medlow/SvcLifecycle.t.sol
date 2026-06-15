// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { BlueprintServiceManagerBase } from "../../../src/BlueprintServiceManagerBase.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { ServicesLifecycle } from "../../../src/core/ServicesLifecycle.sol";

/// @notice Vanilla BSM for the join paths. `BlueprintServiceManagerBase` already defaults
///         `canJoin`/`canLeave` to `true` and all lifecycle hooks to no-ops, so no overrides
///         are needed — the goal is simply a registered manager whose `onBlueprintCreated`
///         wires `tangleCore` so the diamond's manager callbacks succeed.
contract JoinPermissiveBSM is BlueprintServiceManagerBase { }

/// @title SvcLifecycleAuditTest
/// @notice Regression coverage for the svc-lifecycle audit unit.
/// @dev Finding (medium, launch-gating): `joinService` / `joinServiceWithCommitments`
///      previously accepted an unchecked `exposureBps` parameter and stored it verbatim on
///      `ServiceOperator.exposureBps`. A value > `BPS_DENOMINATOR` (10_000) then scaled the
///      operator's TWAP billing/reward weight above 100% in `PaymentsBilling` /
///      `PaymentsDistribution` (`delta * exposureBps / BPS_DENOMINATOR`), inflating their
///      share of the bill pool relative to the honest operator set and distorting slash
///      scaling. The fix mirrors the request-path bound in `ServicesRequests._validateOperators`.
contract SvcLifecycleAuditTest is BaseTest {
    JoinPermissiveBSM internal bsm;
    uint64 internal dynamicBlueprintId;

    uint16 internal constant BPS = 10_000;

    function setUp() public override {
        super.setUp();

        bsm = new JoinPermissiveBSM();

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);

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
        dynamicBlueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://svc-lifecycle-audit", address(bsm), dynamicConfig));

        _registerForBlueprint(operator1, dynamicBlueprintId);
        _registerForBlueprint(operator2, dynamicBlueprintId);
        _registerForBlueprint(operator3, dynamicBlueprintId);
    }

    function _createDynamicService(address op) internal returns (uint64) {
        address[] memory ops = new address[](1);
        ops[0] = op;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            dynamicBlueprintId, ops, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
        _approveService(op, requestId);
        return tangle.serviceCount() - 1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MEDIUM: exposure-bound guard on the join paths
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev SECURE INVARIANT: an exposure strictly above 100% is rejected. Reverting the
    ///      guard would let `BPS + 1` through and inflate the joiner's billing/reward weight.
    function test_JoinService_RejectsExposureAboveBps() public {
        uint64 serviceId = _createDynamicService(operator1);

        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(ServicesLifecycle.InvalidExposureBps.selector, uint16(BPS + 1)));
        tangle.joinService(serviceId, BPS + 1);

        // The rejected join must leave no state behind: operator2 is not in the service.
        assertFalse(tangle.isServiceOperator(serviceId, operator2), "rejected join must not register operator");
    }

    /// @dev Boundary: a maxed-out exposure of exactly `BPS_DENOMINATOR` is the largest
    ///      legal value and must succeed, storing the value verbatim. Asserts the guard is a
    ///      strict `>` bound (not `>=`), matching the request path.
    function test_JoinService_AcceptsExposureAtBpsBoundary() public {
        uint64 serviceId = _createDynamicService(operator1);

        vm.prank(operator2);
        tangle.joinService(serviceId, BPS);

        assertTrue(tangle.isServiceOperator(serviceId, operator2), "boundary exposure must join");
        Types.ServiceOperator memory opData = tangle.getServiceOperator(serviceId, operator2);
        assertEq(opData.exposureBps, BPS, "stored exposure must equal the supplied boundary value");
    }

    /// @dev The most extreme attacker value (uint16 max) is also rejected, confirming the
    ///      guard covers the whole out-of-range domain rather than a single magic number.
    function test_JoinService_RejectsMaxUint16Exposure() public {
        uint64 serviceId = _createDynamicService(operator1);

        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(ServicesLifecycle.InvalidExposureBps.selector, type(uint16).max));
        tangle.joinService(serviceId, type(uint16).max);
    }

    /// @dev `joinServiceWithCommitments` shares the same guard and must reject an
    ///      out-of-range top-level exposure BEFORE touching any commitment storage.
    function test_JoinServiceWithCommitments_RejectsExposureAboveBps() public {
        uint64 serviceId = _createDynamicService(operator1);

        // Dynamic blueprint has no per-asset security requirements, so an empty
        // commitments array is valid input; the only thing under test is the top-level bound.
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](0);

        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(ServicesLifecycle.InvalidExposureBps.selector, uint16(BPS + 1)));
        tangle.joinServiceWithCommitments(serviceId, BPS + 1, commitments);

        assertFalse(tangle.isServiceOperator(serviceId, operator2), "rejected commitment-join must not register operator");
    }

    /// @dev Companion success case for the commitment path at the legal boundary.
    function test_JoinServiceWithCommitments_AcceptsExposureAtBpsBoundary() public {
        uint64 serviceId = _createDynamicService(operator1);

        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](0);

        vm.prank(operator2);
        tangle.joinServiceWithCommitments(serviceId, BPS, commitments);

        assertTrue(tangle.isServiceOperator(serviceId, operator2), "boundary commitment-join must succeed");
        Types.ServiceOperator memory opData = tangle.getServiceOperator(serviceId, operator2);
        assertEq(opData.exposureBps, BPS, "stored exposure must equal the supplied boundary value");
    }
}
