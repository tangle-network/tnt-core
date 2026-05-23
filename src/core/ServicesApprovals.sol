// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { AttestationLib } from "../libraries/AttestationLib.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { ServiceValidationLib } from "../libraries/ServiceValidationLib.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";

/// @title ServicesApprovals
/// @notice Single approval entrypoint for service requests.
/// @dev One `approveService(ApprovalParams)` replaces the prior matrix of
///      five `approveServiceWith…` variants. Every optional capability —
///      security commitments, BLS aggregate-signature key, TEE attestation
///      commitments — is opt-in via empty-or-zero fields on the param struct.
///
///      Anti-DoS architecture: TEE commitments are stored as a single keccak256
///      root per (request, operator) and emitted in full via event. Activation
///      copies one bytes32 per operator forward instead of N×3 storage slots.
///      Slashing and provisioning hooks supply the original commitment array
///      as a witness and verify keccak match against the on-chain root.
///
///      BLS is OPT-IN. Operators that do not register a BLS pubkey can still
///      approve and run services; they simply cannot participate in aggregated
///      job-result submissions (`JobsAggregation`). This is by design — the
///      protocol must accept any operator, not just BLS-enabled ones.
abstract contract ServicesApprovals is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceApproved(uint64 indexed requestId, address indexed operator);
    event ServiceRejected(uint64 indexed requestId, address indexed operator);

    /// @notice Emitted on every approval that carries TEE commitments. The
    ///         `commitments` payload is the full array exactly as supplied —
    ///         indexers reconstruct from this; slashing supplies the same
    ///         array as a witness to verify against `_serviceTeeCommitmentRoot`.
    /// @param requestId The service request being approved.
    /// @param operator The approving operator.
    /// @param root keccak256(abi.encode(commitments)) — what the contract stores.
    /// @param commitments Full array of operator-supplied TEE commitments.
    event TeeCommitmentsRecorded(
        uint64 indexed requestId,
        address indexed operator,
        bytes32 indexed root,
        Types.TeeAttestationCommitment[] commitments
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE APPROVAL — single entrypoint
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Approve a service request. Every optional capability is opt-in.
    /// @dev Empty / zero fields are no-ops:
    ///      - `securityCommitments.length == 0`: only allowed when the request has no security
    ///        requirements OR the only requirement is the protocol-default TNT requirement
    ///        (auto-filled at min-exposure).
    ///      - `blsPubkey == [0,0,0,0]`: operator is not registering a BLS pubkey.
    ///      - `teeCommitments.length == 0`: operator opts out of TEE attestation commitments.
    ///
    ///      Order of checks: authorize → validate (no state changes) → write storage → emit
    ///      → manager hook → activate if threshold met. Failing fast keeps the per-commitment
    ///      SSTORE path off the critical path for unauthorized callers.
    function approveService(Types.ApprovalParams calldata p) external whenNotPaused nonReentrant {
        _requireApprovingOperator(p.requestId);
        // Reject late approvals after the request has crossed its expiry grace.
        // Without this, an operator can race `expireServiceRequest` and quietly
        // activate a stale request the requester thought they could clean up.
        // Mirrors the symmetric check that `rejectService` already performs.
        _requireRequestNotExpired(_getServiceRequest(p.requestId), p.requestId);

        // Pure validation — reverts before any SSTORE if anything is malformed.
        Types.AssetSecurityRequirement[] storage requirements = _requestSecurityRequirements[p.requestId];
        bool hasRequirements = requirements.length > 0;
        bool hasSuppliedCommitments = p.securityCommitments.length > 0;
        bool hasTeeCommitments = p.teeCommitments.length > 0;
        bool registeringBls = _isNonZeroBlsPubkey(p.blsPubkey);

        if (hasRequirements && hasSuppliedCommitments) {
            ServiceValidationLib.validateSecurityCommitments(requirements, p.securityCommitments);
        } else if (hasRequirements && !hasSuppliedCommitments) {
            // Operator omitted commitments — this is only acceptable if the
            // request's only security requirement is the protocol-default TNT
            // requirement, which we auto-fill below at the requirement's min.
            if (!_isOnlyDefaultTntRequirement(p.requestId)) {
                revert Errors.SecurityCommitmentsRequired(p.requestId);
            }
        }

        bytes32 teeRoot;
        if (hasTeeCommitments) {
            ServiceValidationLib.validateTeeCommitments(
                p.requestId, p.teeCommitments, AttestationLib.teeNonce(p.requestId, address(this), block.chainid)
            );
            teeRoot = keccak256(abi.encode(p.teeCommitments));
        }

        if (registeringBls) {
            ServiceValidationLib.requireBlsProofOfPossession(
                msg.sender, p.blsPubkey, p.blsPopSignature, address(this), block.chainid
            );
        }

        // Storage writes — every gate above passed. The effective per-operator
        // exposure (in percent) is what the manager hook receives; it must
        // mirror what was actually committed, including the auto-fill case.
        uint8 effectiveStakingPercent;
        if (hasSuppliedCommitments) {
            for (uint256 i = 0; i < p.securityCommitments.length; i++) {
                _requestSecurityCommitments[p.requestId][msg.sender].push(p.securityCommitments[i]);
            }
            effectiveStakingPercent = uint8(p.securityCommitments[0].exposureBps / 100);
        } else if (hasRequirements) {
            _storeDefaultTntCommitment(p.requestId, msg.sender);
            effectiveStakingPercent = uint8(requirements[0].minExposureBps / 100);
        } else {
            effectiveStakingPercent = 100;
        }

        if (hasTeeCommitments) {
            _requestTeeCommitmentRoot[p.requestId][msg.sender] = teeRoot;
            emit TeeCommitmentsRecorded(p.requestId, msg.sender, teeRoot, p.teeCommitments);
        }

        if (registeringBls) {
            _storeRequestBlsPubkey(p.requestId, msg.sender, p.blsPubkey);
        }

        Types.ServiceRequest storage req = _getServiceRequest(p.requestId);
        _requestApprovals[p.requestId][msg.sender] = true;
        req.approvalCount++;
        emit ServiceApproved(p.requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onApprove, (msg.sender, p.requestId, effectiveStakingPercent))
            );
        }

        if (req.approvalCount == req.operatorCount) {
            _activateService(p.requestId);
        }
    }

    /// @notice Reject a service request as one of its operators.
    /// @dev First rejection wins — short-circuits the request and refunds the requester.
    function rejectService(uint64 requestId) external nonReentrant {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);
        if (req.activated) revert Errors.ServiceRequestAlreadyProcessed(requestId);
        _requireRequestNotExpired(req, requestId);
        if (!_staking.isOperatorActive(msg.sender)) revert Errors.OperatorNotActive(msg.sender);

        if (!_isRequestOperator(requestId, msg.sender)) revert Errors.Unauthorized();

        req.rejected = true;
        PaymentLib.refundPayment(req.requester, req.paymentToken, req.paymentAmount);

        emit ServiceRejected(requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(bp.manager, abi.encodeCall(IBlueprintServiceManager.onReject, (msg.sender, requestId)));
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL — auth, validation, helpers
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Pre-flight authorization check shared by all state-mutating paths.
    /// @dev Reverts unless: request not rejected, caller is an active staking operator,
    ///      caller is in the request's operator list, caller has not already approved.
    function _requireApprovingOperator(uint64 requestId) internal view {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);
        if (!_staking.isOperatorActive(msg.sender)) revert Errors.OperatorNotActive(msg.sender);
        if (!_isRequestOperator(requestId, msg.sender)) revert Errors.Unauthorized();
        if (_requestApprovals[requestId][msg.sender]) revert Errors.AlreadyApproved(requestId, msg.sender);
    }

    function _isRequestOperator(uint64 requestId, address candidate) private view returns (bool) {
        address[] storage ops = _requestOperators[requestId];
        for (uint256 i = 0; i < ops.length; i++) {
            if (ops[i] == candidate) return true;
        }
        return false;
    }

    /// @notice Returns true unless every component of `key` is zero.
    function _isNonZeroBlsPubkey(uint256[4] memory key) private pure returns (bool) {
        return key[0] != 0 || key[1] != 0 || key[2] != 0 || key[3] != 0;
    }

    /// @dev Reverts if the request has lingered past its grace window or has already
    ///      been activated. Activated requests are functionally closed: their escrow
    ///      has been routed to the service record and any further mutation here would
    ///      contradict that state. Operators that let a request sit too long must wait
    ///      for someone to call `expireServiceRequest` before requesting again.
    function _requireRequestNotExpired(Types.ServiceRequest storage req, uint64 requestId) private view {
        if (req.activated) revert Errors.ServiceRequestAlreadyProcessed(requestId);
        uint64 grace = _requestExpiryGracePeriod;
        if (grace == 0) grace = ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD;
        if (block.timestamp > uint256(req.createdAt) + grace) {
            revert Errors.ServiceRequestExpiredError(requestId);
        }
    }

    /// @notice True iff the request's only security requirement is the protocol-default
    ///         TNT requirement (so we can auto-fill the operator's commitment at min).
    function _isOnlyDefaultTntRequirement(uint64 requestId) private view returns (bool) {
        if (_tntToken == address(0)) return false;

        Types.AssetSecurityRequirement[] storage requirements = _requestSecurityRequirements[requestId];
        if (requirements.length != 1) return false;

        Types.AssetSecurityRequirement storage req = requirements[0];
        if (req.asset.kind != Types.AssetKind.ERC20) return false;
        if (req.asset.token != _tntToken) return false;
        if (req.maxExposureBps != BPS_DENOMINATOR) return false;
        return req.minExposureBps == _defaultTntMinExposureBps;
    }

    function _storeDefaultTntCommitment(uint64 requestId, address operator) private {
        Types.AssetSecurityCommitment[] storage existing = _requestSecurityCommitments[requestId][operator];
        if (existing.length > 0) return;

        Types.AssetSecurityRequirement storage req = _requestSecurityRequirements[requestId][0];
        existing.push(Types.AssetSecurityCommitment({ asset: req.asset, exposureBps: req.minExposureBps }));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIRTUAL — implemented by the facet
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Activate a fully approved service.
    function _activateService(uint64 requestId) internal virtual;

    /// @notice Persist BLS pubkey on the request (transferred to service on activation).
    function _storeRequestBlsPubkey(uint64 requestId, address operator, uint256[4] memory blsPubkey) internal virtual;

    /// @notice Transfer BLS pubkeys from request to service during activation.
    function _transferBlsPubkeysToService(uint64 requestId, uint64 serviceId) internal virtual;
}
