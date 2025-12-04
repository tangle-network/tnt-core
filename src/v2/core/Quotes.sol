// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { SignatureLib } from "../libraries/SignatureLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Quotes
/// @notice RFQ system for instant service creation from signed quotes
abstract contract Quotes is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ServiceActivated event inherited from Base.sol

    // ═══════════════════════════════════════════════════════════════════════════
    // RFQ SERVICE CREATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create service from signed operator quotes
    function createServiceFromQuotes(
        uint64 blueprintId,
        Types.SignedQuote[] calldata quotes,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl
    ) external payable whenNotPaused nonReentrant returns (uint64 serviceId) {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);

        (uint256 totalCost, address[] memory operators) = SignatureLib.verifyQuoteBatch(
            _usedQuotes,
            _domainSeparator,
            quotes,
            blueprintId,
            ttl
        );

        for (uint256 i = 0; i < operators.length; i++) {
            if (_operatorRegistrations[blueprintId][operators[i]].registeredAt == 0) {
                revert Errors.OperatorNotRegistered(blueprintId, operators[i]);
            }
        }

        // Validate payment asset with manager if present
        if (bp.manager != address(0) && totalCost > 0) {
            try IBlueprintServiceManager(bp.manager).queryIsPaymentAssetAllowed(0, address(0)) returns (bool allowed) {
                if (!allowed) {
                    revert Errors.TokenNotAllowed(address(0));
                }
            } catch {
                // If hook not implemented, allow any token (backwards compatible)
            }
        }

        if (msg.value < totalCost) {
            revert Errors.InsufficientPaymentForQuotes(totalCost, msg.value);
        }

        if (msg.value > totalCost) {
            PaymentLib.transferPayment(msg.sender, address(0), msg.value - totalCost);
        }

        // Call onRequest hook - allow manager to validate/reject
        if (bp.manager != address(0)) {
            _callManager(
                bp.manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onRequest,
                    (0, msg.sender, operators, config, ttl, address(0), totalCost)
                )
            );
        }

        serviceId = _serviceCount++;
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[blueprintId];

        _services[serviceId] = Types.Service({
            blueprintId: blueprintId,
            owner: msg.sender,
            createdAt: uint64(block.timestamp),
            ttl: ttl,
            terminatedAt: 0,
            lastPaymentAt: uint64(block.timestamp),
            operatorCount: uint32(operators.length),
            minOperators: bpConfig.minOperators > 0 ? bpConfig.minOperators : 1,
            maxOperators: bpConfig.maxOperators,
            membership: bp.membership,
            pricing: bp.pricing,
            status: Types.ServiceStatus.Active
        });

        uint16[] memory exposures = new uint16[](operators.length);
        uint256 totalExposure = _processOperatorQuotes(serviceId, quotes, operators, exposures);

        _permittedCallers[serviceId].add(msg.sender);
        for (uint256 i = 0; i < permittedCallers.length; i++) {
            _permittedCallers[serviceId].add(permittedCallers[i]);
        }

        emit ServiceActivated(serviceId, 0, blueprintId);
        _recordServiceCreated(serviceId, blueprintId, msg.sender, operators.length);

        // Configure heartbeat settings from BSM
        _configureHeartbeat(serviceId, bp.manager, msg.sender);

        // Call onServiceInitialized hook
        if (bp.manager != address(0)) {
            address[] memory callers = new address[](permittedCallers.length + 1);
            callers[0] = msg.sender;
            for (uint256 i = 0; i < permittedCallers.length; i++) {
                callers[i + 1] = permittedCallers[i];
            }
            _tryCallManager(
                bp.manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onServiceInitialized,
                    (blueprintId, 0, serviceId, msg.sender, callers, ttl)
                )
            );
        }

        if (totalCost > 0) {
            _distributeQuotePayment(serviceId, blueprintId, totalCost, operators, exposures, totalExposure);
        }
    }

    /// @notice Process operator quotes and register them for the service
    /// @dev Extracted to separate function to avoid stack too deep
    function _processOperatorQuotes(
        uint64 serviceId,
        Types.SignedQuote[] calldata quotes,
        address[] memory operators,
        uint16[] memory exposures
    ) internal returns (uint256 totalExposure) {
        for (uint256 i = 0; i < operators.length; i++) {
            uint16 exposure = BPS_DENOMINATOR;
            if (quotes[i].details.securityCommitments.length > 0) {
                exposure = quotes[i].details.securityCommitments[0].exposureBps;
            }
            exposures[i] = exposure;

            _serviceOperators[serviceId][operators[i]] = Types.ServiceOperator({
                exposureBps: exposure,
                joinedAt: uint64(block.timestamp),
                leftAt: 0,
                active: true
            });
            _serviceOperatorSet[serviceId].add(operators[i]);
            totalExposure += exposure;
        }
    }

    /// @notice Distribute payment from quotes - to be implemented in final contract
    function _distributeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint16[] memory exposures,
        uint256 totalExposure
    ) internal virtual;
}
