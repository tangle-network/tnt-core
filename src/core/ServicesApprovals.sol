// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { BN254 } from "../libraries/BN254.sol";
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
    event ServiceRequestExpired(uint64 indexed requestId, address indexed expiredBy);

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
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Per-operator cap on TEE attestation commitments at approval.
    /// @dev Bounds calldata + validation cost. With root storage, activation
    ///      gas is operator-linear regardless of this cap; the cap exists to
    ///      keep the validation loop cheap and the witness array small.
    uint256 internal constant MAX_TEE_COMMITMENTS_PER_OPERATOR = 8;

    /// @notice Maximum TTL on an operator's TEE attestation commitment.
    /// @dev `expiresAt = type(uint64).max` would otherwise be effectively
    ///      never-expiring. 90 days is enough headroom for any realistic
    ///      service lifetime; longer-lived services should re-commit.
    uint64 internal constant MAX_TEE_COMMITMENT_TTL = 90 days;

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

        // Pure validation — reverts before any SSTORE if anything is malformed.
        Types.AssetSecurityRequirement[] storage requirements = _requestSecurityRequirements[p.requestId];
        bool hasRequirements = requirements.length > 0;
        bool hasSuppliedCommitments = p.securityCommitments.length > 0;

        if (hasRequirements && hasSuppliedCommitments) {
            _validateSecurityCommitments(requirements, p.securityCommitments);
        } else if (hasRequirements && !hasSuppliedCommitments) {
            // Operator omitted commitments — this is only acceptable if the
            // request's only security requirement is the protocol-default TNT
            // requirement, which we auto-fill below at the requirement's min.
            if (!_isOnlyDefaultTntRequirement(p.requestId)) {
                revert Errors.SecurityCommitmentsRequired(p.requestId);
            }
        }

        bytes32 teeRoot;
        if (p.teeCommitments.length > 0) {
            _validateTeeCommitments(p.requestId, p.teeCommitments);
            teeRoot = keccak256(abi.encode(p.teeCommitments));
        }

        bool registeringBls = _isNonZeroBlsPubkey(p.blsPubkey);
        if (registeringBls) {
            _requireBlsProofOfPossession(msg.sender, p.blsPubkey, p.blsPopSignature);
        }

        // Storage writes — every gate above passed.
        if (hasRequirements && !hasSuppliedCommitments) {
            _storeDefaultTntCommitment(p.requestId, msg.sender);
        } else if (hasSuppliedCommitments) {
            for (uint256 i = 0; i < p.securityCommitments.length; i++) {
                _requestSecurityCommitments[p.requestId][msg.sender].push(p.securityCommitments[i]);
            }
        }

        if (teeRoot != bytes32(0)) {
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
            uint8 stakingPercent =
                p.securityCommitments.length > 0 ? uint8(p.securityCommitments[0].exposureBps / 100) : 100;
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onApprove, (msg.sender, p.requestId, stakingPercent))
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
    // PUBLIC VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Canonical TEE attestation nonce for `requestId` on this contract on this chain.
    /// @dev Operators MUST set `TeeAttestationCommitment.nonceBinding` to this exact value.
    ///      Cross-request attestation replay is structurally impossible: an attestation
    ///      document binding to nonce N_A cannot satisfy a commitment requiring nonce N_B.
    function teeNonceFor(uint64 requestId) public view returns (bytes32) {
        return keccak256(abi.encode("tangle.tee.nonce", requestId, address(this), block.chainid));
    }

    /// @notice Domain-separated message every operator must sign with their BLS secret key
    ///         to register a public key. Bound to chainId + verifying contract + operator
    ///         address so a PoP from one chain or operator cannot be replayed.
    function blsPopMessage(address operator, uint256[4] memory blsPubkey) public view returns (bytes memory) {
        return abi.encode("TANGLE_BLS_POP_v1", block.chainid, address(this), operator, blsPubkey);
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

    /// @notice Validate operator-supplied TEE attestation commitments.
    /// @dev Reverts on: list too long; `Unset` or `DirectTdx` backend; nonce binding
    ///      that isn't the request-derived value; zero expected-measurement; expiry
    ///      in the past or further out than `MAX_TEE_COMMITMENT_TTL`.
    function _validateTeeCommitments(
        uint64 requestId,
        Types.TeeAttestationCommitment[] calldata teeCommitments
    )
        internal
        view
    {
        if (teeCommitments.length > MAX_TEE_COMMITMENTS_PER_OPERATOR) {
            revert Errors.TooManyTeeCommitments(teeCommitments.length, MAX_TEE_COMMITMENTS_PER_OPERATOR);
        }
        bytes32 expectedNonce = teeNonceFor(requestId);
        uint64 nowTs = uint64(block.timestamp);
        uint64 maxExpiresAt = nowTs + MAX_TEE_COMMITMENT_TTL;
        for (uint256 i = 0; i < teeCommitments.length; i++) {
            Types.TeeBackend backend = teeCommitments[i].backend;
            if (backend == Types.TeeBackend.Unset) revert Errors.UnsetTeeBackend();
            if (backend == Types.TeeBackend.DirectTdx) revert Errors.DirectTdxNotPermitted();
            if (teeCommitments[i].nonceBinding != expectedNonce) revert Errors.InvalidNonceBinding();
            if (teeCommitments[i].expectedMeasurement == bytes32(0)) revert Errors.InvalidExpectedMeasurement();
            uint64 expiresAt = teeCommitments[i].expiresAt;
            if (expiresAt != 0) {
                if (expiresAt <= nowTs) revert Errors.TeeCommitmentExpired(expiresAt, nowTs);
                if (expiresAt > maxExpiresAt) revert Errors.TeeCommitmentExpiryTooFar(expiresAt, maxExpiresAt);
            }
        }
    }

    /// @notice Validate operator security commitments against on-chain requirements.
    function _validateSecurityCommitments(
        Types.AssetSecurityRequirement[] storage requirements,
        Types.AssetSecurityCommitment[] calldata commitments
    )
        internal
        view
    {
        for (uint256 i = 0; i < commitments.length; i++) {
            for (uint256 j = i + 1; j < commitments.length; j++) {
                if (
                    commitments[i].asset.token == commitments[j].asset.token
                        && commitments[i].asset.kind == commitments[j].asset.kind
                ) {
                    revert Errors.DuplicateAssetCommitment(uint8(commitments[i].asset.kind), commitments[i].asset.token);
                }
            }
        }

        for (uint256 i = 0; i < requirements.length; i++) {
            Types.AssetSecurityRequirement storage req = requirements[i];
            bool found = false;

            for (uint256 j = 0; j < commitments.length; j++) {
                if (commitments[j].asset.token == req.asset.token && commitments[j].asset.kind == req.asset.kind) {
                    if (commitments[j].exposureBps < req.minExposureBps) {
                        revert Errors.CommitmentBelowMinimum(
                            req.asset.token, commitments[j].exposureBps, req.minExposureBps
                        );
                    }
                    if (commitments[j].exposureBps > req.maxExposureBps) {
                        revert Errors.CommitmentAboveMaximum(
                            req.asset.token, commitments[j].exposureBps, req.maxExposureBps
                        );
                    }
                    found = true;
                    break;
                }
            }

            if (!found) revert Errors.MissingAssetCommitment(req.asset.token);
        }
    }

    /// @notice Returns true unless every component of `key` is zero.
    function _isNonZeroBlsPubkey(uint256[4] memory key) private pure returns (bool) {
        return key[0] != 0 || key[1] != 0 || key[2] != 0 || key[3] != 0;
    }

    /// @dev Reverts unless `popSignature` is a valid BLS G1 signature over `blsPopMessage`
    ///      under `blsPubkey`. A successful PoP also implies subgroup membership of the G2
    ///      pubkey since `pk = sk * G2_generator` for any honest signer.
    function _requireBlsProofOfPossession(
        address operator,
        uint256[4] memory blsPubkey,
        uint256[2] memory popSignature
    )
        internal
        view
    {
        bool ok = BN254.verifyBls(
            blsPopMessage(operator, blsPubkey),
            Types.BN254G1Point({ x: popSignature[0], y: popSignature[1] }),
            Types.BN254G2Point({ x: [blsPubkey[0], blsPubkey[1]], y: [blsPubkey[2], blsPubkey[3]] })
        );
        if (!ok) revert Errors.InvalidBLSSignature();
    }

    /// @notice Permissionlessly expire a stale service request and refund the requester.
    /// @dev Anyone can call this once `block.timestamp > req.createdAt + grace`. The grace
    ///      period is `_requestExpiryGracePeriod` (or `ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD`
    ///      when unset). Without this path stale unapproved requests would linger indefinitely
    ///      with their payment locked; cleanup is now permissionless and incentive-aligned
    ///      (the requester gets refunded, the caller pays the gas).
    ///      Once a request is fully approved and activated (`req.activated == true`) the
    ///      escrowed payment has been transferred to the service; refunding from here
    ///      would double-spend, so activated requests are no longer expirable.
    function expireServiceRequest(uint64 requestId) external nonReentrant {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected || req.activated) revert Errors.ServiceRequestAlreadyProcessed(requestId);

        uint64 grace = _requestExpiryGracePeriod;
        if (grace == 0) grace = ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD;
        if (block.timestamp <= uint256(req.createdAt) + grace) {
            revert Errors.ServiceRequestNotExpired(requestId);
        }

        req.rejected = true;
        PaymentLib.refundPayment(req.requester, req.paymentToken, req.paymentAmount);

        emit ServiceRequestExpired(requestId, msg.sender);
    }

    /// @dev Reverts if the request has lingered past its grace window or has already
    ///      been activated. Activated requests are functionally closed: their escrow
    ///      has been routed to the service record and any further mutation here would
    ///      contradict that state.
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
