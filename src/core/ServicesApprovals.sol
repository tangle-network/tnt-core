// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title ServicesApprovals
/// @notice Service approval and rejection flows
abstract contract ServicesApprovals is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceApproved(uint64 indexed requestId, address indexed operator);
    event ServiceRejected(uint64 indexed requestId, address indexed operator);

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
    function approveServiceWithBls(
        uint64 requestId,
        uint8 stakingPercent,
        uint256[4] calldata blsPubkey
    )
        external
        whenNotPaused
        nonReentrant
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
    function approveServiceWithCommitmentsAndBls(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256[4] calldata blsPubkey
    )
        external
        whenNotPaused
        nonReentrant
    {
        _approveServiceWithCommitmentsInternal(requestId, commitments, blsPubkey);
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
