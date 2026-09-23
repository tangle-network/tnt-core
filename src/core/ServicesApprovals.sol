// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { BN254 } from "../libraries/BN254.sol";

/// @title ServicesApprovals
/// @notice Service approval and rejection flows
abstract contract ServicesApprovals is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceApproved(uint64 indexed requestId, address indexed operator);
    event ServiceRejected(uint64 indexed requestId, address indexed operator);

    /// @notice Emitted when an operator's TEE attestation commitment is recorded at approval.
    /// @param requestId The service request ID being approved.
    /// @param operator The approving operator (msg.sender).
    /// @param backend Which TEE backend the operator commits to.
    /// @param expectedMeasurement Measurement the live attestation must match off-chain.
    event TeeCommitmentRecorded(
        uint64 indexed requestId, address indexed operator, Types.TeeBackend backend, bytes32 expectedMeasurement
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE APPROVAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Approve a service request
    function approveService(uint64 requestId, uint8 stakingPercent) external whenNotPaused nonReentrant {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);

        if (!_staking.isOperatorActive(msg.sender)) {
            revert Errors.OperatorNotActive(msg.sender);
        }
        bool isOperator = false;
        for (uint256 i = 0; i < _requestOperators[requestId].length; i++) {
            if (_requestOperators[requestId][i] == msg.sender) {
                isOperator = true;
                break;
            }
        }
        if (!isOperator) revert Errors.Unauthorized();

        if (_requestApprovals[requestId][msg.sender]) {
            revert Errors.AlreadyApproved(requestId, msg.sender);
        }

        if (_requestSecurityRequirements[requestId].length > 0) {
            if (!_isOnlyDefaultTntRequirement(requestId)) {
                revert Errors.SecurityCommitmentsRequired(requestId);
            }
            _storeDefaultTntCommitment(requestId, msg.sender);
        }

        _requestApprovals[requestId][msg.sender] = true;
        req.approvalCount++;

        emit ServiceApproved(requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager, abi.encodeCall(IBlueprintServiceManager.onApprove, (msg.sender, requestId, stakingPercent))
            );
        }

        if (req.approvalCount == req.operatorCount) {
            _activateService(requestId);
        }
    }

    /// @notice Approve with security commitments
    function approveServiceWithCommitments(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments
    )
        external
        whenNotPaused
        nonReentrant
    {
        _approveServiceWithCommitmentsInternal(requestId, commitments, _emptyBlsPubkey());
    }

    /// @notice Approve a service request with BLS public key for aggregated signature verification
    /// @param requestId The service request ID
    /// @param stakingPercent The staking percentage (0-100)
    /// @param blsPubkey The operator's BLS G2 public key [x0, x1, y0, y1]
    /// @param popSignature G1 proof-of-possession signature over `blsPopMessage(operator, blsPubkey)`.
    ///        Required to defeat rogue-key attacks: an attacker cannot register `-P` of someone
    ///        else's key without the secret. Verifying a real signature also implicitly proves
    ///        subgroup membership of the G2 pubkey.
    function approveServiceWithBls(
        uint64 requestId,
        uint8 stakingPercent,
        uint256[4] calldata blsPubkey,
        uint256[2] calldata popSignature
    )
        external
        whenNotPaused
        nonReentrant
    {
        _requireBlsProofOfPossession(msg.sender, blsPubkey, popSignature);
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);

        if (!_staking.isOperatorActive(msg.sender)) {
            revert Errors.OperatorNotActive(msg.sender);
        }
        bool isOperator = false;
        for (uint256 i = 0; i < _requestOperators[requestId].length; i++) {
            if (_requestOperators[requestId][i] == msg.sender) {
                isOperator = true;
                break;
            }
        }
        if (!isOperator) revert Errors.Unauthorized();

        if (_requestApprovals[requestId][msg.sender]) {
            revert Errors.AlreadyApproved(requestId, msg.sender);
        }

        if (_requestSecurityRequirements[requestId].length > 0) {
            if (!_isOnlyDefaultTntRequirement(requestId)) {
                revert Errors.SecurityCommitmentsRequired(requestId);
            }
            _storeDefaultTntCommitment(requestId, msg.sender);
        }

        // Store BLS pubkey for this operator (to be transferred to service on activation)
        _storeRequestBlsPubkey(requestId, msg.sender, blsPubkey);

        _requestApprovals[requestId][msg.sender] = true;
        req.approvalCount++;

        emit ServiceApproved(requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager, abi.encodeCall(IBlueprintServiceManager.onApprove, (msg.sender, requestId, stakingPercent))
            );
        }

        if (req.approvalCount == req.operatorCount) {
            _activateService(requestId);
        }
    }

    /// @notice Approve a service request with both security commitments and BLS public key
    /// @param requestId The service request ID
    /// @param commitments Security commitments matching the request requirements
    /// @param blsPubkey The operator's BLS G2 public key [x0, x1, y0, y1]
    /// @param popSignature G1 proof-of-possession signature (see `approveServiceWithBls`)
    function approveServiceWithCommitmentsAndBls(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256[4] calldata blsPubkey,
        uint256[2] calldata popSignature
    )
        external
        whenNotPaused
        nonReentrant
    {
        if (_isNonZeroBlsPubkey(blsPubkey)) {
            _requireBlsProofOfPossession(msg.sender, blsPubkey, popSignature);
        }
        _approveServiceWithCommitmentsInternal(requestId, commitments, blsPubkey);
    }

    /// @notice Approve a service request with both security commitments, BLS public key,
    ///         and TEE attestation commitments. Each TEE commitment is stored per-operator
    ///         so blueprints can cross-check it against the live attestation produced when
    ///         the workload provisions.
    /// @dev `teeCommitments` may be empty if the request does not require a TEE workload;
    ///      otherwise every entry MUST set a non-`DirectTdx` backend and (if `expiresAt != 0`)
    ///      a future expiry. The list is interpreted as the operator's set of acceptable
    ///      attestation profiles — any one matching at provisioning time satisfies the policy.
    /// @param requestId The service request ID
    /// @param commitments Per-asset security commitments (matches `approveServiceWithCommitments`)
    /// @param blsPubkey BLS G2 pubkey [x0, x1, y0, y1] (zero pubkey allowed if BLS not used)
    /// @param popSignature G1 proof-of-possession (only validated when blsPubkey is non-zero)
    /// @param teeCommitments TEE attestation commitments to record for `msg.sender`
    function approveServiceWithTeeCommitments(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256[4] calldata blsPubkey,
        uint256[2] calldata popSignature,
        Types.TeeAttestationCommitment[] calldata teeCommitments
    )
        external
        whenNotPaused
        nonReentrant
    {
        // Authorize FIRST so an unauthorized caller never reaches the per-commitment
        // SSTORE loop. Pure validation (no state change) of the commitment shape and
        // BLS PoP follows; storage writes happen only after both gates pass.
        _requireApprovingOperator(requestId);
        _validateTeeCommitments(requestId, teeCommitments);
        if (_isNonZeroBlsPubkey(blsPubkey)) {
            _requireBlsProofOfPossession(msg.sender, blsPubkey, popSignature);
        }
        // Store TEE commitments BEFORE the internal approval flow triggers activation.
        // `_approveServiceWithCommitmentsInternal` will call `_activateService` when this
        // is the final approval, and the activation hook copies `_requestTeeCommitments`
        // into `_serviceTeeCommitments`. Order matters: write to the request first.
        _storeRequestTeeCommitments(requestId, msg.sender, teeCommitments);
        _approveServiceWithCommitmentsInternal(requestId, commitments, blsPubkey);
    }

    /// @notice Per-operator cap on TEE attestation commitments at approval.
    /// @dev Cold SSTORE per pushed entry is ~20K gas across 3 slots (~60K gas/entry).
    ///      Without a cap, a malicious operator can submit a list large enough to
    ///      gas-brick `_persistTeeCommitments` during the final operator's activation
    ///      call, permanently stalling the service. 8 is well above any realistic
    ///      number of acceptable backends an operator would commit to.
    uint256 internal constant MAX_TEE_COMMITMENTS_PER_OPERATOR = 8;

    /// @notice Maximum TTL on an operator's TEE attestation commitment.
    /// @dev Without an upper bound, a commitment with `expiresAt = type(uint64).max`
    ///      is effectively never-expiring, which defeats the "expiry forces
    ///      re-attestation" intent of the field. 90 days is enough headroom for any
    ///      realistic service lifetime; longer-lived services should re-commit on
    ///      a renewal cadence rather than pin a single attestation indefinitely.
    uint64 internal constant MAX_TEE_COMMITMENT_TTL = 90 days;

    /// @notice Pre-flight authorization for an operator approving a request.
    /// @dev Mirrors the auth gates inside `_approveServiceWithCommitmentsInternal`
    ///      (request-not-rejected, operator-active, operator-in-request, not-already-approved).
    ///      Hoisted up so storage-mutating paths in newer entrypoints can fail fast.
    function _requireApprovingOperator(uint64 requestId) internal view {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);
        if (!_staking.isOperatorActive(msg.sender)) revert Errors.OperatorNotActive(msg.sender);

        bool isOperator = false;
        address[] storage ops = _requestOperators[requestId];
        for (uint256 i = 0; i < ops.length; i++) {
            if (ops[i] == msg.sender) {
                isOperator = true;
                break;
            }
        }
        if (!isOperator) revert Errors.Unauthorized();

        if (_requestApprovals[requestId][msg.sender]) {
            revert Errors.AlreadyApproved(requestId, msg.sender);
        }
    }

    /// @notice Validate operator-supplied TEE attestation commitments.
    /// @dev Reverts on: list too long; `Unset` or `DirectTdx` backend; wrong
    ///      `nonceBinding` (not the request-derived value); zero expected-measurement;
    ///      expiry in the past or further out than `MAX_TEE_COMMITMENT_TTL`. Empty
    ///      array is allowed (operator opts out of TEE binding for this approval).
    /// @param requestId The service request being approved — used to derive the
    ///        canonical nonce that every commitment must carry.
    /// @param teeCommitments Operator-supplied TEE attestation commitments.
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
            // The attestation document the operator commits to must contain the
            // request-derived nonce. The contract has no off-chain verifier so it
            // enforces the binding directly: any other value (including zero) is
            // rejected, eliminating cross-request replay at the source.
            if (teeCommitments[i].nonceBinding != expectedNonce) {
                revert Errors.InvalidNonceBinding();
            }
            // Zero measurement is not a real hash output. Either always-fail or
            // always-trivially-pass under the off-chain comparator — reject the
            // ambiguity at approval rather than discover it at provision time.
            if (teeCommitments[i].expectedMeasurement == bytes32(0)) {
                revert Errors.InvalidExpectedMeasurement();
            }
            uint64 expiresAt = teeCommitments[i].expiresAt;
            if (expiresAt != 0) {
                if (expiresAt <= nowTs) revert Errors.TeeCommitmentExpired(expiresAt, nowTs);
                if (expiresAt > maxExpiresAt) revert Errors.TeeCommitmentExpiryTooFar(expiresAt, maxExpiresAt);
            }
        }
    }

    /// @notice Canonical TEE nonce binding for `requestId` on this chain/contract.
    /// @dev Operators must use exactly this value as `nonceBinding` in any
    ///      `TeeAttestationCommitment` for the request. Anyone (operator, client,
    ///      verifier, indexer) can derive it deterministically.
    /// @param requestId The service request ID.
    /// @return The 32-byte nonce that uniquely binds an attestation to this
    ///         request on this contract on this chain.
    function teeNonceFor(uint64 requestId) public view returns (bytes32) {
        return keccak256(abi.encode("tangle.tee.nonce", requestId, address(this), block.chainid));
    }

    /// @notice Persist validated TEE commitments and emit recording events.
    function _storeRequestTeeCommitments(
        uint64 requestId,
        address operator,
        Types.TeeAttestationCommitment[] calldata teeCommitments
    )
        internal
    {
        for (uint256 i = 0; i < teeCommitments.length; i++) {
            _requestTeeCommitments[requestId][operator].push(teeCommitments[i]);
            emit TeeCommitmentRecorded(
                requestId, operator, teeCommitments[i].backend, teeCommitments[i].expectedMeasurement
            );
        }
    }

    /// @notice Internal implementation for approving with commitments and optional BLS key
    function _approveServiceWithCommitmentsInternal(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256[4] memory blsPubkey
    )
        private
    {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);

        if (!_staking.isOperatorActive(msg.sender)) {
            revert Errors.OperatorNotActive(msg.sender);
        }
        bool isOperator = false;
        for (uint256 i = 0; i < _requestOperators[requestId].length; i++) {
            if (_requestOperators[requestId][i] == msg.sender) {
                isOperator = true;
                break;
            }
        }
        if (!isOperator) revert Errors.Unauthorized();

        if (_requestApprovals[requestId][msg.sender]) {
            revert Errors.AlreadyApproved(requestId, msg.sender);
        }

        Types.AssetSecurityRequirement[] storage requirements = _requestSecurityRequirements[requestId];
        if (requirements.length > 0) {
            _validateSecurityCommitments(requirements, commitments);
        }

        for (uint256 i = 0; i < commitments.length; i++) {
            _requestSecurityCommitments[requestId][msg.sender].push(commitments[i]);
        }

        // Store BLS pubkey if provided (non-zero)
        if (_isNonZeroBlsPubkey(blsPubkey)) {
            _storeRequestBlsPubkey(requestId, msg.sender, blsPubkey);
        }

        _requestApprovals[requestId][msg.sender] = true;
        req.approvalCount++;

        emit ServiceApproved(requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        uint8 stakingPercent = commitments.length > 0 ? uint8(commitments[0].exposureBps / 100) : 100;
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager, abi.encodeCall(IBlueprintServiceManager.onApprove, (msg.sender, requestId, stakingPercent))
            );
        }

        if (req.approvalCount == req.operatorCount) {
            _activateService(requestId);
        }
    }

    /// @notice Check if a BLS pubkey is non-zero
    function _isNonZeroBlsPubkey(uint256[4] memory key) private pure returns (bool) {
        return key[0] != 0 || key[1] != 0 || key[2] != 0 || key[3] != 0;
    }

    /// @notice Return an empty BLS pubkey
    function _emptyBlsPubkey() private pure returns (uint256[4] memory) {
        return [uint256(0), uint256(0), uint256(0), uint256(0)];
    }

    /// @notice Domain-separated message every operator must sign with their BLS secret key
    ///         to register a public key. Bound to chainId + verifying contract + operator
    ///         address so a PoP from one chain or operator cannot be replayed.
    function blsPopMessage(address operator, uint256[4] memory blsPubkey) public view returns (bytes memory) {
        return abi.encode("TANGLE_BLS_POP_v1", block.chainid, address(this), operator, blsPubkey);
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
        if (!_isNonZeroBlsPubkey(blsPubkey)) revert Errors.InvalidBLSSignature();

        bool ok = BN254.verifyBls(
            blsPopMessage(operator, blsPubkey),
            BN254G1Memory(popSignature[0], popSignature[1]),
            BN254G2Memory(blsPubkey)
        );
        if (!ok) revert Errors.InvalidBLSSignature();
    }

    function BN254G1Memory(uint256 x, uint256 y) private pure returns (Types.BN254G1Point memory p) {
        p.x = x;
        p.y = y;
    }

    function BN254G2Memory(uint256[4] memory k) private pure returns (Types.BN254G2Point memory p) {
        p.x = [k[0], k[1]];
        p.y = [k[2], k[3]];
    }

    /// @notice Store BLS pubkey for an operator in the request (will be transferred to service on activation)
    /// @dev This is virtual to allow different storage strategies
    function _storeRequestBlsPubkey(uint64 requestId, address operator, uint256[4] memory blsPubkey) internal virtual;

    /// @notice Transfer BLS pubkeys from request to service (called during activation)
    function _transferBlsPubkeysToService(uint64 requestId, uint64 serviceId) internal virtual;

    /// @notice Validate security commitments
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

            if (!found) {
                revert Errors.MissingAssetCommitment(req.asset.token);
            }
        }
    }

    /// @notice Reject a service request
    function rejectService(uint64 requestId) external nonReentrant {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);

        if (!_staking.isOperatorActive(msg.sender)) {
            revert Errors.OperatorNotActive(msg.sender);
        }
        bool isOperator = false;
        for (uint256 i = 0; i < _requestOperators[requestId].length; i++) {
            if (_requestOperators[requestId][i] == msg.sender) {
                isOperator = true;
                break;
            }
        }
        if (!isOperator) revert Errors.Unauthorized();

        req.rejected = true;
        PaymentLib.refundPayment(req.requester, req.paymentToken, req.paymentAmount);

        emit ServiceRejected(requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(bp.manager, abi.encodeCall(IBlueprintServiceManager.onReject, (msg.sender, requestId)));
        }
    }

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
    // SERVICE ACTIVATION (internal, implemented by facet)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Activate a fully approved service - to be implemented in final contract
    function _activateService(uint64 requestId) internal virtual;
}
