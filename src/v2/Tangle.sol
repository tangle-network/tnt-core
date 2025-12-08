// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Blueprints } from "./core/Blueprints.sol";
import { Operators } from "./core/Operators.sol";
import { Services } from "./core/Services.sol";
import { Jobs } from "./core/Jobs.sol";
import { Payments } from "./core/Payments.sol";
import { Slashing } from "./core/Slashing.sol";
import { Quotes } from "./core/Quotes.sol";
import { Types } from "./libraries/Types.sol";
import { IBlueprintServiceManager } from "./interfaces/IBlueprintServiceManager.sol";

/// @title Tangle
/// @notice Core Tangle Protocol v2 contract
/// @dev Composes all protocol functionality from modular mixins
contract Tangle is
    Blueprints,
    Operators,
    Services,
    Jobs,
    Payments,
    Slashing,
    Quotes
{
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the contract
    function initialize(
        address admin,
        address restaking_,
        address payable treasury_
    ) external initializer {
        __Base_init(admin, restaking_, treasury_);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CROSS-MIXIN IMPLEMENTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Activate a fully approved service (called from Services mixin)
    function _activateService(uint64 requestId) internal override {
        Types.ServiceRequest storage req = _serviceRequests[requestId];
        uint64 serviceId = _serviceCount++;
        Types.Blueprint storage bp = _blueprints[req.blueprintId];

        _createServiceRecord(serviceId, req, bp);

        (uint16[] memory exposures, uint256 totalExposure) = _assignOperatorsFromRequest(serviceId, requestId);

        _grantPermittedCallers(serviceId, requestId, req.requester);

        _handleInitialPayments(
            serviceId,
            req.blueprintId,
            bp.pricing,
            req.paymentToken,
            req.paymentAmount,
            exposures,
            totalExposure,
            requestId
        );

        _triggerManagerOnActivation(
            requestId,
            serviceId,
            req.blueprintId,
            req.requester,
            req.ttl,
            bp.manager
        );
    }

    function _createServiceRecord(
        uint64 serviceId,
        Types.ServiceRequest storage req,
        Types.Blueprint storage bp
    ) private {
        _services[serviceId] = Types.Service({
            blueprintId: req.blueprintId,
            owner: req.requester,
            createdAt: uint64(block.timestamp),
            ttl: req.ttl,
            terminatedAt: 0,
            lastPaymentAt: uint64(block.timestamp),
            operatorCount: req.operatorCount,
            minOperators: req.minOperators,
            maxOperators: req.maxOperators,
            membership: req.membership,
            pricing: bp.pricing,
            status: Types.ServiceStatus.Active
        });
    }

    function _assignOperatorsFromRequest(
        uint64 serviceId,
        uint64 requestId
    ) private returns (uint16[] memory exposures, uint256 totalExposure) {
        address[] storage requestOperators = _requestOperators[requestId];
        exposures = new uint16[](requestOperators.length);

        for (uint256 i = 0; i < requestOperators.length; i++) {
            address op = requestOperators[i];
            uint16 exposure = _requestExposures[requestId][op];
            exposures[i] = exposure;

            _serviceOperators[serviceId][op] = Types.ServiceOperator({
                exposureBps: exposure,
                joinedAt: uint64(block.timestamp),
                leftAt: 0,
                active: true
            });
            _serviceOperatorSet[serviceId].add(op);
            totalExposure += exposure;
        }
    }

    function _grantPermittedCallers(
        uint64 serviceId,
        uint64 requestId,
        address requester
    ) private {
        _permittedCallers[serviceId].add(requester);
        address[] storage requestCallers = _requestCallers[requestId];
        for (uint256 i = 0; i < requestCallers.length; i++) {
            _permittedCallers[serviceId].add(requestCallers[i]);
        }
    }

    function _handleInitialPayments(
        uint64 serviceId,
        uint64 blueprintId,
        Types.PricingModel pricing,
        address paymentToken,
        uint256 paymentAmount,
        uint16[] memory exposures,
        uint256 totalExposure,
        uint64 requestId
    ) private {
        if (paymentAmount == 0) {
            return;
        }
        if (pricing == Types.PricingModel.PayOnce) {
            address[] memory operators = _copyRequestOperators(requestId);
            _distributePayment(
                serviceId,
                blueprintId,
                paymentToken,
                paymentAmount,
                operators,
                exposures,
                totalExposure
            );
        } else if (pricing == Types.PricingModel.Subscription) {
            _depositToEscrow(serviceId, paymentToken, paymentAmount);
        }
    }

    function _triggerManagerOnActivation(
        uint64 requestId,
        uint64 serviceId,
        uint64 blueprintId,
        address requester,
        uint64 ttl,
        address manager
    ) private {
        emit ServiceActivated(serviceId, requestId, blueprintId);

        _configureHeartbeat(serviceId, manager, requester);

        if (manager == address(0)) {
            return;
        }

        address[] memory callers = _buildCallerList(requestId, requester);

        _tryCallManager(
            manager,
            abi.encodeCall(
                IBlueprintServiceManager.onServiceInitialized,
                (blueprintId, requestId, serviceId, requester, callers, ttl)
            )
        );
    }

    function _buildCallerList(uint64 requestId, address requester) private view returns (address[] memory callers) {
        address[] storage requestCallers = _requestCallers[requestId];
        callers = new address[](requestCallers.length + 1);
        callers[0] = requester;
        for (uint256 i = 0; i < requestCallers.length; i++) {
            callers[i + 1] = requestCallers[i];
        }
    }

    function _copyRequestOperators(uint64 requestId) private view returns (address[] memory operators) {
        address[] storage requestOperators = _requestOperators[requestId];
        operators = new address[](requestOperators.length);
        for (uint256 i = 0; i < requestOperators.length; i++) {
            operators[i] = requestOperators[i];
        }
    }

    /// @notice Distribute job payment (called from Jobs mixin)
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal override {
        Types.Service storage svc = _services[serviceId];

        address[] memory operators = _serviceOperatorSet[serviceId].values();
        uint16[] memory exposures = new uint16[](operators.length);
        uint256 totalExposure = 0;

        for (uint256 i = 0; i < operators.length; i++) {
            exposures[i] = _serviceOperators[serviceId][operators[i]].exposureBps;
            totalExposure += exposures[i];
        }

        _distributePayment(serviceId, svc.blueprintId, address(0), payment, operators, exposures, totalExposure);
    }

    /// @notice Distribute quote payment (called from Quotes mixin)
    function _distributeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint16[] memory exposures,
        uint256 totalExposure
    ) internal override {
        _distributePayment(serviceId, blueprintId, address(0), amount, operators, exposures, totalExposure);
    }

    /// @notice Get the list of operators for a service (called from Jobs mixin for aggregation)
    function _getServiceOperatorList(uint64 serviceId) internal view override returns (address[] memory) {
        return _serviceOperatorSet[serviceId].values();
    }
}
