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
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[req.blueprintId];

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

        uint256 totalExposure = 0;
        address[] memory operators = _requestOperators[requestId];
        uint16[] memory exposures = new uint16[](operators.length);

        for (uint256 i = 0; i < operators.length; i++) {
            address op = operators[i];
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

        _permittedCallers[serviceId].add(req.requester);
        for (uint256 i = 0; i < _requestCallers[requestId].length; i++) {
            _permittedCallers[serviceId].add(_requestCallers[requestId][i]);
        }

        emit ServiceActivated(serviceId, requestId, req.blueprintId);

        // Configure heartbeat settings from BSM
        _configureHeartbeat(serviceId, bp.manager, req.requester);

        if (bp.pricing == Types.PricingModel.PayOnce && req.paymentAmount > 0) {
            _distributePayment(serviceId, req.blueprintId, req.paymentToken, req.paymentAmount, operators, exposures, totalExposure);
        } else if (bp.pricing == Types.PricingModel.Subscription && req.paymentAmount > 0) {
            _depositToEscrow(serviceId, req.paymentToken, req.paymentAmount);
        }

        if (bp.manager != address(0)) {
            address[] memory callers = new address[](_requestCallers[requestId].length + 1);
            callers[0] = req.requester;
            for (uint256 i = 0; i < _requestCallers[requestId].length; i++) {
                callers[i + 1] = _requestCallers[requestId][i];
            }

            _tryCallManager(
                bp.manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onServiceInitialized,
                    (req.blueprintId, requestId, serviceId, req.requester, callers, req.ttl)
                )
            );
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
}
