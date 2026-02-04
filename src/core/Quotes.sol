// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { SignatureLib } from "../libraries/SignatureLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";

/// @title Quotes
/// @notice RFQ system for instant service creation from signed quotes
abstract contract Quotes is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct QuoteActivation {
        uint64 serviceId;
        uint256 totalExposure;
    }

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
        _requireBlueprintActive(bp, blueprintId);

        address[] memory operators = _gatherQuoteOperators(quotes);
        _ensureOperatorsRegistered(blueprintId, operators);
        uint16[] memory exposures = _extractQuoteExposures(quotes);

        uint256 totalCost = _verifyQuotesAndGetCost(quotes, blueprintId, ttl);

        _ensureQuotePaymentAsset(bp.manager, totalCost);
        _collectQuotePayment(totalCost);
        _notifyManagerQuoteRequest(bp.manager, operators, config, ttl, totalCost);

        QuoteActivation memory activation =
            _activateQuoteService(blueprintId, bp, operators, exposures, ttl);
        serviceId = activation.serviceId;

        _addInitialQuoteCallers(serviceId, msg.sender, permittedCallers);
        _notifyManagerQuoteInitialization(
            bp.manager,
            blueprintId,
            serviceId,
            msg.sender,
            permittedCallers,
            ttl
        );

        _finalizeQuotePayment(
            serviceId,
            blueprintId,
            totalCost,
            operators
        );
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

    function _requireBlueprintActive(Types.Blueprint storage bp, uint64 blueprintId) private view {
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);
    }

    function _verifyQuotesAndGetCost(
        Types.SignedQuote[] calldata quotes,
        uint64 blueprintId,
        uint64 ttl
    ) private returns (uint256 totalCost) {
        // M-4 fix: Validate quote timestamps for staleness
        _validateQuoteTimestamps(quotes);

        (totalCost,) = SignatureLib.verifyQuoteBatch(
            _usedQuotes,
            _domainSeparator,
            quotes,
            blueprintId,
            ttl
        );
    }

    /// @notice Validate that quote timestamps are not too old (M-4 fix)
    function _validateQuoteTimestamps(Types.SignedQuote[] calldata quotes) private view {
        uint64 maxAge = _maxQuoteAge > 0 ? _maxQuoteAge : ProtocolConfig.MAX_QUOTE_AGE;
        uint64 minTimestamp = uint64(block.timestamp) - maxAge;

        for (uint256 i = 0; i < quotes.length; i++) {
            if (quotes[i].details.timestamp < minTimestamp) {
                revert Errors.QuoteTimestampTooOld(
                    quotes[i].operator,
                    quotes[i].details.timestamp,
                    maxAge
                );
            }
        }
    }

    function _activateQuoteService(
        uint64 blueprintId,
        Types.Blueprint storage bp,
        address[] memory operators,
        uint16[] memory exposures,
        uint64 ttl
    ) private returns (QuoteActivation memory activation) {
        activation.serviceId = _serviceCount++;
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[blueprintId];

        _services[activation.serviceId] = Types.Service({
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

        activation.totalExposure = _processOperatorQuotes(activation.serviceId, operators, exposures);

        emit ServiceActivated(activation.serviceId, 0, blueprintId);
        _recordServiceCreated(activation.serviceId, blueprintId, msg.sender, operators.length);
        _configureHeartbeat(activation.serviceId, bp.manager, msg.sender);
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
        address[] memory operators
    ) private {
        if (totalCost == 0) {
            return;
        }
        _distributeQuotePayment(serviceId, blueprintId, totalCost, operators);
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
    /// @dev Payment is distributed based on effective exposure (delegation × exposureBps)
    function _distributeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators
    ) internal virtual;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE EXTENSION
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceExtended(uint64 indexed serviceId, uint64 oldTtl, uint64 newTtl, uint256 payment);

    /// @notice Extend an existing service's TTL with new quotes from current operators
    /// @param serviceId The service to extend
    /// @param quotes Signed quotes from current service operators
    /// @param additionalTtl How much time to add to the service
    function extendServiceFromQuotes(
        uint64 serviceId,
        Types.SignedQuote[] calldata quotes,
        uint64 additionalTtl
    ) external payable whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);

        // Only owner can extend
        if (svc.owner != msg.sender) {
            revert Errors.Unauthorized();
        }

        // Service must be active
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }

        // Must have TTL (streaming service)
        if (svc.ttl == 0) {
            revert Errors.InvalidState();
        }

        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        _requireBlueprintActive(bp, svc.blueprintId);

        // Gather operators from quotes and verify they're current service operators
        address[] memory quoteOperators = _gatherQuoteOperators(quotes);
        _verifyQuoteOperatorsInService(serviceId, quoteOperators);

        // Verify quotes and get total cost
        uint256 totalCost = _verifyExtensionQuotes(quotes, svc.blueprintId, additionalTtl);

        // Collect payment
        _collectQuotePayment(totalCost);

        // Calculate new TTL timing
        uint64 currentEndTime = svc.createdAt + svc.ttl;
        uint64 extensionStart = currentEndTime > uint64(block.timestamp) ? currentEndTime : uint64(block.timestamp);
        uint64 oldTtl = svc.ttl;

        // Extend TTL
        svc.ttl = (extensionStart - svc.createdAt) + additionalTtl;

        emit ServiceExtended(serviceId, oldTtl, svc.ttl, totalCost);

        // Distribute payment as streaming starting from extension start
        if (totalCost > 0) {
            uint64 extensionEnd = extensionStart + additionalTtl;
            _distributeExtensionPayment(
                serviceId,
                svc.blueprintId,
                totalCost,
                quoteOperators,
                extensionStart,
                extensionEnd
            );
        }
    }

    function _verifyQuoteOperatorsInService(uint64 serviceId, address[] memory operators) private view {
        for (uint256 i = 0; i < operators.length; i++) {
            Types.ServiceOperator storage opData = _serviceOperators[serviceId][operators[i]];
            if (!opData.active) {
                revert Errors.OperatorNotInService(serviceId, operators[i]);
            }
        }
    }

    function _verifyExtensionQuotes(
        Types.SignedQuote[] calldata quotes,
        uint64 blueprintId,
        uint64 ttl
    ) private returns (uint256 totalCost) {
        // M-4 fix: Validate quote timestamps for staleness
        _validateQuoteTimestamps(quotes);

        (totalCost,) = SignatureLib.verifyQuoteBatch(
            _usedQuotes,
            _domainSeparator,
            quotes,
            blueprintId,
            ttl
        );
    }

    /// @notice Distribute extension payment - to be implemented in final contract
    function _distributeExtensionPayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint64 startTime,
        uint64 endTime
    ) internal virtual;
}
