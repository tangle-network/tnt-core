// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { ITangleServices } from "../../src/interfaces/ITangleServices.sol";
import { ITangleSlashing } from "../../src/interfaces/ITangleSlashing.sol";
import { ProtocolConfig } from "../../src/config/ProtocolConfig.sol";

/// @title AuditFixesTest
/// @notice Regression tests pinning behaviors fixed during the multi-subsystem audit.
///         Each test names the audit finding it backs up. If any of these reverts
///         silently in the future, the corresponding fix has rotted.
contract AuditFixesTest is BaseTest {
    uint64 internal blueprintId;

    function setUp() public override {
        super.setUp();
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://audit", address(0)));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, blueprintId);
    }

    // ───────────────────────────────────────────────────────────────────────
    // svc-lc H-1: `expireServiceRequest` is reachable via the proxy.
    // The `aa511c2` fix added the function to ITangleServices and the impl
    // already existed, but the selector was never registered on
    // TangleServicesFacet so the call routed through the unknown-selector
    // fallback. This test would have failed with `UnknownSelector`.
    // ───────────────────────────────────────────────────────────────────────
    function test_expireServiceRequest_reachableViaProxy() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        // Push past the grace window and call the freshly-routed selector.
        vm.warp(block.timestamp + ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD + 1);
        ITangleServices(address(tangle)).expireServiceRequest(requestId);

        // Once expired, late approvals must revert (svc-lc M-1).
        vm.expectRevert();
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
    }

    // ───────────────────────────────────────────────────────────────────────
    // svc-lc M-1: approveService rejects requests past the grace window so an
    // operator can't quietly activate a request the requester thought was
    // cleanable via expireServiceRequest.
    // ───────────────────────────────────────────────────────────────────────
    function test_approveService_revertsAfterGracePeriod() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        vm.warp(block.timestamp + ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD + 1);
        vm.expectRevert();
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
    }

    // ───────────────────────────────────────────────────────────────────────
    // svc-lc M-2: duplicate operator entries in a request are rejected at
    // creation time. Without this, `req.operatorCount` exceeds the unique
    // approver count and the request can never reach activation.
    // ───────────────────────────────────────────────────────────────────────
    function test_requestService_duplicateOperators_reverts() public {
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator1; // duplicate

        vm.expectRevert();
        vm.prank(user1);
        tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
    }

    // ───────────────────────────────────────────────────────────────────────
    // svc-lc H-3: dynamic-membership service entrypoints must reject when the
    // service has been terminated. Without these gates, a stale operator can
    // schedule/execute exits and fire OperatorLeftService for a dead service,
    // double-decrementing operator counts and confusing indexers.
    // ───────────────────────────────────────────────────────────────────────
    function test_exitEntrypoints_revertOnTerminatedService() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        uint64 serviceId = tangle.serviceCount() - 1;

        // Terminate the service. The status check on each exit entrypoint runs
        // before any membership / authorisation gate, so even non-Dynamic
        // services that would otherwise revert at a later gate must revert at
        // the status check now.
        vm.prank(user1);
        tangle.terminateService(serviceId);

        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceNotActive.selector, serviceId));
        vm.prank(operator1);
        tangle.scheduleExit(serviceId);

        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceNotActive.selector, serviceId));
        vm.prank(operator1);
        tangle.leaveService(serviceId);
    }

    // ───────────────────────────────────────────────────────────────────────
    // slash B-3: proposeSlash rejects bytes32(0) evidence so off-chain monitors
    // keying off a non-zero evidence hash never see a zero-evidence slash.
    // ───────────────────────────────────────────────────────────────────────
    function test_proposeSlash_revertsOnZeroEvidence() public {
        // Stand up a minimal active service.
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        uint64 serviceId = tangle.serviceCount() - 1;

        vm.expectRevert();
        vm.prank(user1);
        ITangleSlashing(address(tangle)).proposeSlash(serviceId, operator1, 100, bytes32(0));
    }

    // ───────────────────────────────────────────────────────────────────────
    // — gov #4: SLASH_ADMIN cannot self-dispute their own slash.
    // Without this gate, an admin who is also the proposer can propose, then
    // immediately self-dispute for free, freezing operator stake for the full
    // disputeResolutionDeadline window and (when treasury == admin) capturing
    // the operator's bond on auto-execution.
    // ───────────────────────────────────────────────────────────────────────
    function test_disputeSlash_adminCannotSelfDisputeOwnProposal() public {
        // Build an active service.
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        uint64 serviceId = tangle.serviceCount() - 1;

        // Admin already holds SLASH_ADMIN_ROLE via Base.sol bootstrap.

        // Admin proposes the slash (also being SLASH_ADMIN, this passes the
        // existing authorization since admin is also the service owner of
        // their own services — but here we make admin the slasher via the
        // blueprint owner override path. Simplest: admin proposes as themselves
        // through any authorized origin; for this test we make admin both
        // proposer and disputer by routing via the blueprint owner role too.)
        vm.prank(developer); // blueprint owner == developer
        uint64 slashId = ITangleSlashing(address(tangle)).proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Admin is NOT the proposer here, so they CAN dispute as escalation.
        vm.prank(admin);
        ITangleSlashing(address(tangle)).disputeSlash(slashId, "admin escalation");

        // Now show the inverse: when admin IS the proposer, dispute reverts.
        // Make admin the blueprint owner of a fresh blueprint so they can both
        // propose and try to self-dispute.
        vm.prank(admin);
        uint64 adminBp = tangle.createBlueprint(_blueprintDefinition("ipfs://admin-owned", address(0)));
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator3, adminBp);
        address[] memory ops2 = new address[](1);
        ops2[0] = operator3;
        vm.prank(user1);
        uint64 reqId2 = tangle.requestService(
            adminBp, ops2, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
        vm.prank(operator3);
        tangle.approveService(_approve(reqId2));
        uint64 svcId2 = tangle.serviceCount() - 1;

        vm.prank(admin);
        uint64 selfSlashId =
            ITangleSlashing(address(tangle)).proposeSlash(svcId2, operator3, 1000, keccak256("admin-evidence"));

        // Admin is the proposer; self-dispute must revert.
        vm.expectRevert();
        vm.prank(admin);
        ITangleSlashing(address(tangle)).disputeSlash(selfSlashId, "self-dispute");
    }
}
