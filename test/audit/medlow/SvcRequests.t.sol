// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { ServicesRequests } from "../../../src/core/ServicesRequests.sol";

/// @title SvcRequestsAuditTest
/// @notice Regression coverage for the svc-requests audit unit.
/// @dev Finding (low, launch-gating, DoS): `_storePermittedCallers` had NO length
///      bound and pushed every supplied entry unconditionally. At activation the
///      FINAL operator approval funnels through `_grantPermittedCallers`
///      (one `EnumerableSet.add` SSTORE per caller) and `_buildCallerList`
///      (an `O(N)` memory array for the manager `onServiceInitialized` callback).
///      A requester could submit an unbounded `permittedCallers` array; the last
///      approver's transaction would then exceed the block gas limit and revert,
///      so the service could never activate (recoverable only via
///      `expireServiceRequest`) — a griefing / denial-of-service on the operators
///      and on the requester's own escrowed funds.
///
///      Fix: bound `permittedCallers.length` at REQUEST time (the single chokepoint
///      all three request entrypoints share via `_requestServiceInternal`),
///      mirroring the operator and security-requirement request-path caps. The
///      bound is `ServicesRequests.MAX_PERMITTED_CALLERS_PER_REQUEST` (128, the
///      operator-per-service ceiling) and reverts with `TooManyPermittedCallers`.
///
///      SECURE INVARIANT under test: a request can never persist more permitted
///      callers than the cap, so activation can never be bricked by caller-list
///      gas. Reverting the fix would let `cap + 1` through and these expectRevert
///      assertions would fail.
contract SvcRequestsAuditTest is BaseTest {
    uint64 internal blueprintId;

    uint256 internal constant CAP = 128;

    function setUp() public override {
        super.setUp();

        _registerOperator(operator1, 5 ether);

        // Manager == address(0): no manager callbacks, no payment-asset gating —
        // isolates the permitted-caller bound as the only thing under test.
        // PayOnce + zero payment keeps the request path free of token transfers.
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(
            _blueprintDefinitionWithConfig("ipfs://svc-requests-audit", address(0), config)
        );

        _registerForBlueprint(operator1, blueprintId);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    function _ops() internal view returns (address[] memory ops) {
        ops = new address[](1);
        ops[0] = operator1;
    }

    /// @dev Deterministic, distinct, non-zero caller addresses. Distinctness is
    ///      not required by the guard (it bounds raw length, not unique count) but
    ///      it makes the activation success-path assertions meaningful.
    function _callers(uint256 n) internal pure returns (address[] memory callers) {
        callers = new address[](n);
        for (uint256 i = 0; i < n; i++) {
            callers[i] = address(uint160(uint256(keccak256(abi.encodePacked("caller", i))) | 1));
        }
    }

    function _expectTooMany(uint256 supplied) internal {
        vm.expectRevert(
            abi.encodeWithSelector(ServicesRequests.TooManyPermittedCallers.selector, supplied, CAP)
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // LOW / DoS: permitted-caller length bound on every request entrypoint
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev `requestService` (default-exposure path) rejects a caller list one over
    ///      the cap. This is the primary griefing vector: an unbounded list bricks
    ///      the last approver's activation.
    function test_RequestService_RejectsPermittedCallersOverCap() public {
        address[] memory callers = _callers(CAP + 1);

        vm.prank(user1);
        _expectTooMany(CAP + 1);
        tangle.requestService(
            blueprintId, _ops(), "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        // The reverted request must not have been created: request 0 has no requester.
        Types.ServiceRequest memory req = tangle.getServiceRequest(0);
        assertEq(req.requester, address(0), "reverted over-cap request must not be persisted");
    }

    /// @dev Boundary: exactly `cap` callers is the largest legal list and must be
    ///      accepted. Asserts the guard is a strict `>` bound, not `>=`.
    function test_RequestService_AcceptsPermittedCallersAtCap() public {
        address[] memory callers = _callers(CAP);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, _ops(), "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        // The at-cap request must be created and fully persisted.
        assertEq(requestId, 0, "first request id");
        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertEq(req.requester, user1, "at-cap request must be persisted with its requester");
    }

    /// @dev The custom-exposure entrypoint shares the same `_requestServiceInternal`
    ///      chokepoint and must enforce the identical bound.
    function test_RequestServiceWithExposure_RejectsPermittedCallersOverCap() public {
        address[] memory ops = _ops();
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 10_000;
        address[] memory callers = _callers(CAP + 1);

        vm.prank(user1);
        _expectTooMany(CAP + 1);
        tangle.requestServiceWithExposure(
            blueprintId, ops, exposures, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
    }

    /// @dev The security-requirement entrypoint also flows through the chokepoint;
    ///      the caller bound fires regardless of the security requirements supplied.
    function test_RequestServiceWithSecurity_RejectsPermittedCallersOverCap() public {
        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](1);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(0xBEEF) }),
            minExposureBps: 1,
            maxExposureBps: 10_000
        });
        address[] memory callers = _callers(CAP + 1);

        vm.prank(user1);
        _expectTooMany(CAP + 1);
        tangle.requestServiceWithSecurity(
            blueprintId, _ops(), reqs, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
    }

    /// @dev The most extreme attacker payload (well past the cap) is also rejected,
    ///      confirming the guard covers the whole out-of-range domain, not a single
    ///      off-by-one value.
    function test_RequestService_RejectsLargePermittedCallerList() public {
        uint256 huge = CAP * 10;
        address[] memory callers = _callers(huge);

        vm.prank(user1);
        _expectTooMany(huge);
        tangle.requestService(
            blueprintId, _ops(), "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
    }

    /// @dev End-to-end proof the bound preserves the legitimate flow: a request with
    ///      a maxed-out (at-cap) caller list still ACTIVATES, and every supplied
    ///      caller is granted on the live service. This is the property the bound
    ///      protects — activation completes within gas precisely because the list is
    ///      capped. An empty caller list is the common case and must also activate.
    function test_AtCapRequest_ActivatesAndGrantsAllCallers() public {
        address[] memory callers = _callers(CAP);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, _ops(), "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        _approveService(operator1, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceOperator(serviceId, operator1), "service must be active with its operator");

        // Requester is always a permitted caller, plus every entry in the at-cap list.
        assertTrue(tangle.isPermittedCaller(serviceId, user1), "requester must be permitted");
        for (uint256 i = 0; i < callers.length; i++) {
            assertTrue(tangle.isPermittedCaller(serviceId, callers[i]), "every supplied caller must be granted");
        }
    }

    /// @dev Empty caller list (the default in most flows) activates cleanly: confirms
    ///      the bound did not regress the zero-caller path.
    function test_EmptyCallerList_Activates() public {
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, _ops(), "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        _approveService(operator1, requestId);

        uint64 serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceOperator(serviceId, operator1), "empty-caller service must activate");
        assertTrue(tangle.isPermittedCaller(serviceId, user1), "requester must still be permitted");
    }
}
