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

        address[] memory operators = _gatherQuoteOperators(quotes);
        _ensureOperatorsRegistered(blueprintId, operators);

        uint16[] memory exposures = _extractQuoteExposures(quotes);

        (uint256 totalCost,) = SignatureLib.verifyQuoteBatch(
            _usedQuotes,
            _domainSeparator,
            quotes,
            blueprintId,
            ttl
        );

        _ensureQuotePaymentAsset(bp.manager, totalCost);
        _collectQuotePayment(totalCost);
        _notifyManagerQuoteRequest(bp.manager, operators, config, ttl, totalCost);

        uint256 totalExposure;
        (serviceId, totalExposure) = _activateQuoteService(
            blueprintId,
            bp,
            operators,
            exposures,
            ttl
        );

        _addInitialQuoteCallers(serviceId, msg.sender, permittedCallers);
        _notifyManagerQuoteInitialization(
            bp.manager,
            blueprintId,
            serviceId,
            msg.sender,
            permittedCallers,
            ttl
        );

        _finalizeQuotePayment(serviceId, blueprintId, totalCost, operators, exposures, totalExposure);
    }

    function _gatherQuoteOperators(
        Types.SignedQuote[] calldata quotes
    ) private returns (address[] memory operators) {
        uint256 length = quotes.length;
        operators = new address[](length);
        for (uint256 i = 0; i < length; ++i) {
            address operator = quotes[i].operator;
            if (_quoteOperatorSeen[operator]) {
                revert Errors.DuplicateOperatorQuote(operator);
            }
            _quoteOperatorSeen[operator] = true;
            operators[i] = operator;
        }

        for (uint256 i = 0; i < length; ++i) {
            _quoteOperatorSeen[operators[i]] = false;
        }
    }

    function _extractQuoteExposures(
        Types.SignedQuote[] calldata quotes
    ) private pure returns (uint16[] memory exposures) {
        uint256 length = quotes.length;
        exposures = new uint16[](length);
        for (uint256 i = 0; i < length; ++i) {
            exposures[i] = _quoteExposure(quotes[i]);
        }
    }

    function _ensureOperatorsRegistered(uint64 blueprintId, address[] memory operators) private view {
        for (uint256 i = 0; i < operators.length; i++) {
            if (_operatorRegistrations[blueprintId][operators[i]].registeredAt == 0) {
                revert Errors.OperatorNotRegistered(blueprintId, operators[i]);
            }
        }
    }

    function _ensureQuotePaymentAsset(address manager, uint256 totalCost) private view {
        if (manager != address(0) && totalCost > 0) {
            try IBlueprintServiceManager(manager).queryIsPaymentAssetAllowed(0, address(0)) returns (bool allowed) {
                if (!allowed) revert Errors.TokenNotAllowed(address(0));
            } catch {}
        }
    }

    function _notifyManagerQuoteRequest(
        address manager,
        address[] memory operators,
        bytes calldata config,
        uint64 ttl,
        uint256 totalCost
    ) private {
        if (manager == address(0)) return;
        _callManager(
            manager,
            abi.encodeCall(
                IBlueprintServiceManager.onRequest,
                (0, msg.sender, operators, config, ttl, address(0), totalCost)
            )
        );
    }

    function _collectQuotePayment(uint256 totalCost) private {
        if (msg.value < totalCost) {
            revert Errors.InsufficientPaymentForQuotes(totalCost, msg.value);
        }
        if (msg.value > totalCost) {
            PaymentLib.transferPayment(msg.sender, address(0), msg.value - totalCost);
        }
    }

    function _activateQuoteService(
        uint64 blueprintId,
        Types.Blueprint storage bp,
        address[] memory operators,
        uint16[] memory exposures,
        uint64 ttl
    ) private returns (uint64 serviceId, uint256 totalExposure) {
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

        totalExposure = _processOperatorQuotes(serviceId, operators, exposures);

        emit ServiceActivated(serviceId, 0, blueprintId);
        _recordServiceCreated(serviceId, blueprintId, msg.sender, operators.length);
        _configureHeartbeat(serviceId, bp.manager, msg.sender);
    }

    function _addInitialQuoteCallers(
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers
    ) private {
        _permittedCallers[serviceId].add(owner);
        for (uint256 i = 0; i < permittedCallers.length; i++) {
            _permittedCallers[serviceId].add(permittedCallers[i]);
        }
    }

    function _notifyManagerQuoteInitialization(
        address manager,
        uint64 blueprintId,
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers,
        uint64 ttl
    ) private {
        if (manager == address(0)) {
            return;
        }
        address[] memory callers = new address[](permittedCallers.length + 1);
        callers[0] = owner;
        for (uint256 i = 0; i < permittedCallers.length; i++) {
            callers[i + 1] = permittedCallers[i];
        }
        _tryCallManager(
            manager,
            abi.encodeCall(
                IBlueprintServiceManager.onServiceInitialized,
                (blueprintId, 0, serviceId, owner, callers, ttl)
            )
        );
    }

    function _finalizeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 totalCost,
        address[] memory operators,
        uint16[] memory exposures,
        uint256 totalExposure
    ) private {
        if (totalCost == 0) {
            return;
        }
        _distributeQuotePayment(serviceId, blueprintId, totalCost, operators, exposures, totalExposure);
    }

    /// @notice Process operator quotes and register them for the service
    /// @dev Extracted to separate function to avoid stack too deep
    function _processOperatorQuotes(
        uint64 serviceId,
        address[] memory operators,
        uint16[] memory exposures
    ) internal returns (uint256 totalExposure) {
        for (uint256 i = 0; i < operators.length; i++) {
            uint16 exposure = exposures[i];
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

    function _quoteExposure(Types.SignedQuote calldata quote) private pure returns (uint16) {
        Types.QuoteDetails calldata details = quote.details;
        Types.AssetSecurityCommitment[] calldata commitments = details.securityCommitments;
        if (commitments.length == 0) {
            return BPS_DENOMINATOR;
        }
        return commitments[0].exposureBps;
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
