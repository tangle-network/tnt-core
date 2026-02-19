// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";

/// @title ServicesRequests
/// @notice Service request flows
abstract contract ServicesRequests is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct BlueprintRequestData {
        address manager;
        Types.MembershipModel membership;
        Types.PricingModel pricing;
    }

    struct RequestBounds {
        uint32 minOperators;
        uint32 maxOperators;
        uint32 operatorCount;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceRequested(uint64 indexed requestId, uint64 indexed blueprintId, address indexed requester);
    event ServiceRequestedWithSecurity(uint64 indexed requestId, uint64 indexed blueprintId, address indexed requester);

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
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (uint64 requestId)
    {
        _validateRequestConfig(blueprintId, config);
        requestId = _requestServiceWithDefaultExposure(
            blueprintId, operators, config, permittedCallers, ttl, paymentToken, paymentAmount
        );
        _storeDefaultTntRequirement(requestId);
        _storeDefaultResourceRequirements(requestId, blueprintId);
        return requestId;
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
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (uint64 requestId)
    {
        if (operators.length != exposures.length) revert Errors.LengthMismatch();
        _validateRequestConfig(blueprintId, config);
        requestId = _requestServiceInternal(
            blueprintId, operators, exposures, config, permittedCallers, ttl, paymentToken, paymentAmount
        );
        _storeDefaultTntRequirement(requestId);
        _storeDefaultResourceRequirements(requestId, blueprintId);
        return requestId;
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
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (uint64 requestId)
    {
        _validateSecurityRequirements(securityRequirements);

        requestId = _requestServiceWithDefaultExposure(
            blueprintId, operators, config, permittedCallers, ttl, paymentToken, paymentAmount
        );

        _storeSecurityRequirementsWithDefaultTnt(requestId, securityRequirements);
        _storeDefaultResourceRequirements(requestId, blueprintId);
        emit ServiceRequestedWithSecurity(requestId, blueprintId, msg.sender);
    }

    function _requestServiceWithDefaultExposure(
        uint64 blueprintId,
        address[] calldata operators,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    )
        private
        returns (uint64 requestId)
    {
        uint16[] memory exposures = _defaultExposures(operators.length);
        _validateRequestConfig(blueprintId, config);
        return _requestServiceInternal(
            blueprintId, operators, exposures, config, permittedCallers, ttl, paymentToken, paymentAmount
        );
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
    )
        internal
        returns (uint64 requestId)
    {
        if (operators.length == 0) revert Errors.NoOperators();

        // Validate TTL bounds (M-1 fix)
        _validateServiceTtl(ttl);

        BlueprintRequestData memory blueprintData = _loadBlueprintRequestData(blueprintId);
        _validatePricingPaymentConsistency(blueprintData.pricing, paymentToken);

        uint64 requestContextId = _serviceRequestCount;
        _validateRequestPaymentAsset(blueprintData.manager, requestContextId, paymentToken, paymentAmount);
        _validateRequestOperators(blueprintId, operators, exposures);

        PaymentLib.collectPayment(paymentToken, paymentAmount, msg.value);

        RequestBounds memory bounds = _computeRequestBounds(blueprintId, uint32(operators.length));

        requestId = _createServiceRequest(blueprintId, ttl, paymentToken, paymentAmount, blueprintData, bounds);

        _storeRequestOperators(requestId, operators, exposures);
        _storePermittedCallers(requestId, permittedCallers);

        emit ServiceRequested(requestId, blueprintId, msg.sender);

        _notifyManagerOnRequest(blueprintData.manager, requestId, operators, config);
    }

    function _validateRequestConfig(uint64 blueprintId, bytes calldata config) private view {
        SchemaLib.validatePayload(_requestSchemas[blueprintId], config, Types.SchemaTarget.Request, blueprintId, 0);
    }

    function _validateRequestPaymentAsset(
        address manager,
        uint64 requestContextId,
        address paymentToken,
        uint256 paymentAmount
    )
        private
        view
    {
        if (manager == address(0) || paymentAmount == 0) {
            return;
        }
        if (!_isPaymentAssetAllowedByManager(manager, requestContextId, paymentToken)) {
            revert Errors.TokenNotAllowed(paymentToken);
        }
    }

    function _validatePricingPaymentConsistency(Types.PricingModel pricing, address paymentToken) private pure {
        // Event-driven services are currently native-settled for both initial and per-job payments.
        if (pricing == Types.PricingModel.EventDriven && paymentToken != address(0)) {
            revert Errors.InvalidPaymentToken();
        }
    }

    function _validateRequestOperators(
        uint64 blueprintId,
        address[] calldata operators,
        uint16[] memory exposures
    )
        private
        view
    {
        for (uint256 i = 0; i < operators.length; i++) {
            if (_operatorRegistrations[blueprintId][operators[i]].registeredAt == 0) {
                revert Errors.OperatorNotRegistered(blueprintId, operators[i]);
            }
            if (!_staking.isOperatorActive(operators[i])) {
                revert Errors.OperatorNotActive(operators[i]);
            }
            if (exposures[i] > BPS_DENOMINATOR) {
                revert Errors.InvalidState();
            }
        }
    }

    function _resolveMinOperators(Types.BlueprintConfig storage bpConfig) private view returns (uint32) {
        return bpConfig.minOperators > 0 ? bpConfig.minOperators : 1;
    }

    function _validateOperatorBounds(uint32 maxOperators, uint32 operatorCount, uint32 minOps) private pure {
        if (operatorCount < minOps) {
            revert Errors.InsufficientOperators(minOps, operatorCount);
        }
        if (maxOperators > 0 && operatorCount > maxOperators) {
            revert Errors.TooManyOperators(maxOperators, operatorCount);
        }
    }

    function _storeRequestOperators(uint64 requestId, address[] calldata operators, uint16[] memory exposures) private {
        for (uint256 i = 0; i < operators.length; i++) {
            _requestOperators[requestId].push(operators[i]);
            _requestExposures[requestId][operators[i]] = exposures[i];
        }
    }

    function _storePermittedCallers(uint64 requestId, address[] calldata permittedCallers) private {
        for (uint256 i = 0; i < permittedCallers.length; i++) {
            _requestCallers[requestId].push(permittedCallers[i]);
        }
    }

    function _notifyManagerOnRequest(
        address manager,
        uint64 requestId,
        address[] calldata operators,
        bytes calldata config
    )
        private
    {
        if (manager == address(0)) {
            return;
        }
        Types.ServiceRequest storage req = _serviceRequests[requestId];
        _callManager(
            manager,
            abi.encodeCall(
                IBlueprintServiceManager.onRequest,
                (requestId, msg.sender, operators, config, req.ttl, req.paymentToken, req.paymentAmount)
            )
        );
    }

    function _defaultExposures(uint256 length) private pure returns (uint16[] memory exposures) {
        exposures = new uint16[](length);
        for (uint256 i = 0; i < length; i++) {
            exposures[i] = BPS_DENOMINATOR;
        }
    }

    function _validateSecurityRequirements(Types.AssetSecurityRequirement[] calldata requirements) private pure {
        if (requirements.length == 0) revert Errors.NoSecurityRequirements();
        for (uint256 i = 0; i < requirements.length; i++) {
            Types.AssetSecurityRequirement calldata req = requirements[i];
            if (req.minExposureBps == 0) revert Errors.InvalidSecurityRequirement();
            if (req.minExposureBps > req.maxExposureBps) revert Errors.InvalidSecurityRequirement();
            if (req.maxExposureBps > BPS_DENOMINATOR) revert Errors.InvalidSecurityRequirement();
        }
    }

    function _storeSecurityRequirements(
        uint64 requestId,
        Types.AssetSecurityRequirement[] calldata requirements
    )
        private
    {
        for (uint256 i = 0; i < requirements.length; i++) {
            _requestSecurityRequirements[requestId].push(requirements[i]);
        }
    }

    function _storeDefaultTntRequirement(uint64 requestId) private {
        if (_tntToken == address(0)) return;

        _requestSecurityRequirements[requestId].push(
            Types.AssetSecurityRequirement({
                asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: _tntToken }),
                minExposureBps: _defaultTntMinExposureBps,
                maxExposureBps: BPS_DENOMINATOR
            })
        );
    }

    function _storeSecurityRequirementsWithDefaultTnt(
        uint64 requestId,
        Types.AssetSecurityRequirement[] calldata requirements
    )
        private
    {
        if (_tntToken == address(0)) {
            _storeSecurityRequirements(requestId, requirements);
            return;
        }

        bool hasTnt = false;
        for (uint256 i = 0; i < requirements.length; i++) {
            Types.AssetSecurityRequirement calldata req = requirements[i];
            if (req.asset.kind == Types.AssetKind.ERC20 && req.asset.token == _tntToken) {
                hasTnt = true;
                if (req.minExposureBps < _defaultTntMinExposureBps) revert Errors.InvalidSecurityRequirement();
            }
            _requestSecurityRequirements[requestId].push(req);
        }

        if (!hasTnt) {
            _storeDefaultTntRequirement(requestId);
        }
    }

    function _loadBlueprintRequestData(uint64 blueprintId) private view returns (BlueprintRequestData memory data) {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);
        data.manager = bp.manager;
        data.membership = bp.membership;
        data.pricing = bp.pricing;
    }

    function _computeRequestBounds(
        uint64 blueprintId,
        uint32 operatorCount
    )
        private
        view
        returns (RequestBounds memory bounds)
    {
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[blueprintId];
        bounds.minOperators = _resolveMinOperators(bpConfig);
        bounds.maxOperators = bpConfig.maxOperators;
        bounds.operatorCount = operatorCount;
        _validateOperatorBounds(bounds.maxOperators, operatorCount, bounds.minOperators);
    }

    function _createServiceRequest(
        uint64 blueprintId,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount,
        BlueprintRequestData memory blueprintData,
        RequestBounds memory bounds
    )
        private
        returns (uint64 requestId)
    {
        requestId = _serviceRequestCount++;
        _serviceRequests[requestId] = Types.ServiceRequest({
            blueprintId: blueprintId,
            requester: msg.sender,
            createdAt: uint64(block.timestamp),
            ttl: ttl,
            operatorCount: bounds.operatorCount,
            approvalCount: 0,
            paymentToken: paymentToken,
            paymentAmount: paymentAmount,
            membership: blueprintData.membership,
            minOperators: bounds.minOperators,
            maxOperators: bounds.maxOperators,
            rejected: false
        });
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUESTS WITH RESOURCE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get resource requirements for a service request
    function getServiceRequestResourceRequirements(uint64 requestId)
        external
        view
        returns (Types.ResourceCommitment[] memory)
    {
        return _requestResourceRequirements[requestId];
    }

    /// @notice Copy blueprint default resource requirements to a request
    function _storeDefaultResourceRequirements(uint64 requestId, uint64 blueprintId) internal {
        Types.ResourceCommitment[] storage defaults = _blueprintResourceRequirements[blueprintId];
        if (defaults.length == 0) return;
        for (uint256 i = 0; i < defaults.length; i++) {
            _requestResourceRequirements[requestId].push(defaults[i]);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TTL VALIDATION (M-1 fix)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Validate service TTL is within bounds
    /// @dev TTL of 0 is allowed for perpetual services
    function _validateServiceTtl(uint64 ttl) private view {
        // TTL of 0 means perpetual service - no validation needed
        if (ttl == 0) return;

        uint64 minTtl = _minServiceTtl > 0 ? _minServiceTtl : ProtocolConfig.MIN_SERVICE_TTL;
        uint64 maxTtl = _maxServiceTtl > 0 ? _maxServiceTtl : ProtocolConfig.MAX_SERVICE_TTL;

        if (ttl < minTtl) {
            revert Errors.TTLBelowMinimum(ttl, minTtl);
        }
        if (ttl > maxTtl) {
            revert Errors.TTLAboveMaximum(ttl, maxTtl);
        }
    }

    /// @notice Get the minimum service TTL
    function minServiceTtl() external view returns (uint64) {
        return _minServiceTtl > 0 ? _minServiceTtl : ProtocolConfig.MIN_SERVICE_TTL;
    }

    /// @notice Get the maximum service TTL
    function maxServiceTtl() external view returns (uint64) {
        return _maxServiceTtl > 0 ? _maxServiceTtl : ProtocolConfig.MAX_SERVICE_TTL;
    }
}
