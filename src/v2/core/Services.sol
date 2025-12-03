// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Services
/// @notice Service request, approval, and lifecycle management
abstract contract Services is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceRequested(uint64 indexed requestId, uint64 indexed blueprintId, address indexed requester);
    event ServiceRequestedWithSecurity(
        uint64 indexed requestId,
        uint64 indexed blueprintId,
        address indexed requester,
        address[] operators,
        Types.AssetSecurityRequirement[] securityRequirements
    );
    event ServiceApproved(uint64 indexed requestId, address indexed operator);
    event ServiceRejected(uint64 indexed requestId, address indexed operator);
    // ServiceActivated defined in Base.sol
    event ServiceTerminated(uint64 indexed serviceId);
    event OperatorJoinedService(uint64 indexed serviceId, address indexed operator, uint16 exposureBps);
    event OperatorLeftService(uint64 indexed serviceId, address indexed operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Request a new service
    function requestService(
        uint64 blueprintId,
        address[] calldata operators,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    ) external payable whenNotPaused nonReentrant returns (uint64 requestId) {
        uint16[] memory exposures = new uint16[](operators.length);
        for (uint256 i = 0; i < operators.length; i++) {
            exposures[i] = BPS_DENOMINATOR; // Default 100%
        }
        return _requestServiceInternal(
            blueprintId, operators, exposures, config, permittedCallers, ttl, paymentToken, paymentAmount
        );
    }

    /// @notice Request service with custom operator exposures
    function requestServiceWithExposure(
        uint64 blueprintId,
        address[] calldata operators,
        uint16[] calldata exposures,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    ) external payable whenNotPaused nonReentrant returns (uint64 requestId) {
        if (operators.length != exposures.length) revert Errors.LengthMismatch();
        return _requestServiceInternal(
            blueprintId, operators, exposures, config, permittedCallers, ttl, paymentToken, paymentAmount
        );
    }

    /// @notice Request a service with multi-asset security requirements
    function requestServiceWithSecurity(
        uint64 blueprintId,
        address[] calldata operators,
        Types.AssetSecurityRequirement[] calldata securityRequirements,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    ) external payable whenNotPaused nonReentrant returns (uint64 requestId) {
        if (securityRequirements.length == 0) revert Errors.NoSecurityRequirements();
        for (uint256 i = 0; i < securityRequirements.length; i++) {
            Types.AssetSecurityRequirement calldata req = securityRequirements[i];
            if (req.minExposureBps == 0) revert Errors.InvalidSecurityRequirement();
            if (req.minExposureBps > req.maxExposureBps) revert Errors.InvalidSecurityRequirement();
            if (req.maxExposureBps > BPS_DENOMINATOR) revert Errors.InvalidSecurityRequirement();
        }

        uint16[] memory defaultExposures = new uint16[](operators.length);
        for (uint256 i = 0; i < operators.length; i++) {
            defaultExposures[i] = BPS_DENOMINATOR;
        }

        requestId = _requestServiceInternal(
            blueprintId, operators, defaultExposures, config, permittedCallers, ttl, paymentToken, paymentAmount
        );

        for (uint256 i = 0; i < securityRequirements.length; i++) {
            _requestSecurityRequirements[requestId].push(securityRequirements[i]);
        }

        emit ServiceRequestedWithSecurity(requestId, blueprintId, msg.sender, operators, securityRequirements);
    }

    /// @notice Internal service request logic
    function _requestServiceInternal(
        uint64 blueprintId,
        address[] calldata operators,
        uint16[] memory exposures,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    ) internal returns (uint64 requestId) {
        if (operators.length == 0) revert Errors.NoOperators();

        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);

        // Validate payment asset with manager if present
        if (bp.manager != address(0) && paymentAmount > 0) {
            try IBlueprintServiceManager(bp.manager).queryIsPaymentAssetAllowed(0, paymentToken) returns (bool allowed) {
                if (!allowed) {
                    revert Errors.TokenNotAllowed(paymentToken);
                }
            } catch {
                // If hook not implemented, allow any token (backwards compatible)
            }
        }

        for (uint256 i = 0; i < operators.length; i++) {
            if (_operatorRegistrations[blueprintId][operators[i]].registeredAt == 0) {
                revert Errors.OperatorNotRegistered(blueprintId, operators[i]);
            }
            if (exposures[i] > BPS_DENOMINATOR) {
                revert Errors.InvalidState();
            }
        }

        PaymentLib.collectPayment(paymentToken, paymentAmount, msg.value);

        requestId = _serviceRequestCount++;
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[blueprintId];

        // Validate operator count against blueprint config
        uint32 minOps = bpConfig.minOperators > 0 ? bpConfig.minOperators : 1;
        if (operators.length < minOps) {
            revert Errors.InsufficientOperators(minOps, uint32(operators.length));
        }
        if (bpConfig.maxOperators > 0 && operators.length > bpConfig.maxOperators) {
            revert Errors.TooManyOperators(bpConfig.maxOperators, uint32(operators.length));
        }

        _serviceRequests[requestId] = Types.ServiceRequest({
            blueprintId: blueprintId,
            requester: msg.sender,
            createdAt: uint64(block.timestamp),
            ttl: ttl,
            operatorCount: uint32(operators.length),
            approvalCount: 0,
            paymentToken: paymentToken,
            paymentAmount: paymentAmount,
            membership: bp.membership,
            minOperators: bpConfig.minOperators > 0 ? bpConfig.minOperators : 1,
            maxOperators: bpConfig.maxOperators,
            rejected: false
        });

        for (uint256 i = 0; i < operators.length; i++) {
            _requestOperators[requestId].push(operators[i]);
            _requestExposures[requestId][operators[i]] = exposures[i];
        }

        for (uint256 i = 0; i < permittedCallers.length; i++) {
            _requestCallers[requestId].push(permittedCallers[i]);
        }

        emit ServiceRequested(requestId, blueprintId, msg.sender);

        if (bp.manager != address(0)) {
            _callManager(
                bp.manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onRequest,
                    (requestId, msg.sender, operators, config, ttl, paymentToken, paymentAmount)
                )
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE APPROVAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Approve a service request
    function approveService(uint64 requestId, uint8 restakingPercent) external whenNotPaused nonReentrant {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);

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

        _requestApprovals[requestId][msg.sender] = true;
        req.approvalCount++;

        emit ServiceApproved(requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onApprove, (msg.sender, requestId, restakingPercent))
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
    ) external whenNotPaused nonReentrant {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected) revert Errors.ServiceRequestAlreadyProcessed(requestId);

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

        _requestApprovals[requestId][msg.sender] = true;
        req.approvalCount++;

        emit ServiceApproved(requestId, msg.sender);

        Types.Blueprint storage bp = _blueprints[req.blueprintId];
        uint8 restakingPercent = commitments.length > 0 ? uint8(commitments[0].exposureBps / 100) : 100;
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onApprove, (msg.sender, requestId, restakingPercent))
            );
        }

        if (req.approvalCount == req.operatorCount) {
            _activateService(requestId);
        }
    }

    /// @notice Validate security commitments
    function _validateSecurityCommitments(
        Types.AssetSecurityRequirement[] storage requirements,
        Types.AssetSecurityCommitment[] calldata commitments
    ) internal view {
        for (uint256 i = 0; i < requirements.length; i++) {
            Types.AssetSecurityRequirement storage req = requirements[i];
            bool found = false;

            for (uint256 j = 0; j < commitments.length; j++) {
                if (commitments[j].asset.token == req.asset.token &&
                    commitments[j].asset.kind == req.asset.kind) {
                    if (commitments[j].exposureBps < req.minExposureBps) {
                        revert Errors.CommitmentBelowMinimum(req.asset.token, commitments[j].exposureBps, req.minExposureBps);
                    }
                    if (commitments[j].exposureBps > req.maxExposureBps) {
                        revert Errors.CommitmentAboveMaximum(req.asset.token, commitments[j].exposureBps, req.maxExposureBps);
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
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onReject, (msg.sender, requestId))
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE ACTIVATION (internal, called by Payments mixin)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Activate a fully approved service - to be implemented in final contract
    function _activateService(uint64 requestId) internal virtual;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Terminate a service
    function terminateService(uint64 serviceId) external {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }

        svc.status = Types.ServiceStatus.Terminated;
        svc.terminatedAt = uint64(block.timestamp);

        emit ServiceTerminated(serviceId);

        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onServiceTermination, (serviceId, msg.sender))
            );
        }
    }

    /// @notice Add permitted caller
    function addPermittedCaller(uint64 serviceId, address caller) external {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }
        _permittedCallers[serviceId].add(caller);
    }

    /// @notice Remove permitted caller
    function removePermittedCaller(uint64 serviceId, address caller) external {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }
        _permittedCallers[serviceId].remove(caller);
    }

    /// @notice Join a dynamic service
    function joinService(uint64 serviceId, uint16 exposureBps) external whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.membership != Types.MembershipModel.Dynamic) {
            revert Errors.InvalidState();
        }
        if (svc.maxOperators > 0 && svc.operatorCount >= svc.maxOperators) {
            revert Errors.InvalidState();
        }
        if (_operatorRegistrations[svc.blueprintId][msg.sender].registeredAt == 0) {
            revert Errors.OperatorNotRegistered(svc.blueprintId, msg.sender);
        }
        if (_serviceOperators[serviceId][msg.sender].active) {
            revert Errors.InvalidState();
        }

        // Validate minimum stake requirement (re-check in case operator withdrew after registration)
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        uint256 minStake = _restaking.minOperatorStake();
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).getMinOperatorStake() returns (bool useDefault, uint256 customMin) {
                if (!useDefault && customMin > 0) {
                    minStake = customMin;
                }
            } catch {}
        }
        if (!_restaking.meetsStakeRequirement(msg.sender, minStake)) {
            revert Errors.InsufficientStake(msg.sender, minStake, _restaking.getOperatorStake(msg.sender));
        }

        // Check if manager allows this operator to join
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).canJoin(serviceId, msg.sender) returns (bool allowed) {
                if (!allowed) {
                    revert Errors.Unauthorized();
                }
            } catch {}
        }

        _serviceOperators[serviceId][msg.sender] = Types.ServiceOperator({
            exposureBps: exposureBps,
            joinedAt: uint64(block.timestamp),
            leftAt: 0,
            active: true
        });
        _serviceOperatorSet[serviceId].add(msg.sender);
        svc.operatorCount++;

        emit OperatorJoinedService(serviceId, msg.sender, exposureBps);

        // Notify manager of successful join
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onOperatorJoined, (serviceId, msg.sender, exposureBps))
            );
        }
    }

    /// @notice Leave a dynamic service
    function leaveService(uint64 serviceId) external nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.membership != Types.MembershipModel.Dynamic) {
            revert Errors.InvalidState();
        }
        if (svc.operatorCount <= svc.minOperators) {
            revert Errors.InvalidState();
        }

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][msg.sender];
        if (!opData.active) {
            revert Errors.OperatorNotInService(serviceId, msg.sender);
        }

        // Check if manager allows this operator to leave
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).canLeave(serviceId, msg.sender) returns (bool allowed) {
                if (!allowed) {
                    revert Errors.Unauthorized();
                }
            } catch {}
        }

        opData.active = false;
        opData.leftAt = uint64(block.timestamp);
        _serviceOperatorSet[serviceId].remove(msg.sender);
        svc.operatorCount--;

        emit OperatorLeftService(serviceId, msg.sender);

        // Notify manager of successful leave
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onOperatorLeft, (serviceId, msg.sender))
            );
        }
    }
}
