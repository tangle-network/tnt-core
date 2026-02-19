// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { SignatureLib } from "../libraries/SignatureLib.sol";

/// @title QuotesExtend
/// @notice RFQ service extension flows
abstract contract QuotesExtend is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    event ResourcesCommitted(
        uint64 indexed serviceId, address indexed operator, Types.ResourceCommitment[] commitments
    );

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
    )
        external
        payable
        whenNotPaused
        nonReentrant
    {
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

        if (msg.value > 0) {
            _requireManagerAllowsNativeExtension(bp.manager, serviceId);
        }

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

        // Update resource commitments if changed during extension
        for (uint256 i = 0; i < quoteOperators.length; i++) {
            Types.ResourceCommitment[] calldata resources = quotes[i].details.resourceCommitments;
            if (resources.length > 0) {
                _serviceResourceCommitmentHash[serviceId][quoteOperators[i]] =
                    SignatureLib.hashResourceCommitments(resources);
                emit ResourcesCommitted(serviceId, quoteOperators[i], resources);
            }
        }

        // Distribute payment as streaming starting from extension start
        if (totalCost > 0) {
            uint64 extensionEnd = extensionStart + additionalTtl;
            _distributeExtensionPayment(
                serviceId, svc.blueprintId, totalCost, quoteOperators, extensionStart, extensionEnd
            );
        }
    }

    function _gatherQuoteOperators(Types.SignedQuote[] calldata quotes) private returns (address[] memory operators) {
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
    )
        private
        returns (uint256 totalCost)
    {
        (totalCost,) = SignatureLib.verifyQuoteBatch(_usedQuotes, _domainSeparator, quotes, blueprintId, ttl);
    }

    function _collectQuotePayment(uint256 totalCost) private {
        if (msg.value < totalCost) {
            revert Errors.InsufficientPaymentForQuotes(totalCost, msg.value);
        }
        if (msg.value > totalCost) {
            revert Errors.InvalidMsgValue(totalCost, msg.value);
        }
    }

    function _requireManagerAllowsNativeExtension(address manager, uint64 serviceId) private view {
        if (manager == address(0)) return;
        if (!_isPaymentAssetAllowedByManager(manager, serviceId, address(0))) {
            revert Errors.TokenNotAllowed(address(0));
        }
    }

    function _requireBlueprintActive(Types.Blueprint storage bp, uint64 blueprintId) private view {
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);
    }

    /// @notice Distribute extension payment - to be implemented in final contract
    function _distributeExtensionPayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint64 startTime,
        uint64 endTime
    )
        internal
        virtual;
}
