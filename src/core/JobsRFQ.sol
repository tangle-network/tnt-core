// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { SignatureLib } from "../libraries/SignatureLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";

/// @title JobsRFQ
/// @notice Job submission via signed operator price quotes (RFQ system)
/// @dev Supports single or multi-operator quotes. Each operator signs their own price.
///      Only quoted operators can submit results for RFQ jobs.
abstract contract JobsRFQ is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event JobSubmittedFromQuote(
        uint64 indexed serviceId,
        uint64 indexed callId,
        uint8 jobIndex,
        address caller,
        address[] quotedOperators,
        uint256 totalPrice,
        bytes inputs
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB SUBMISSION FROM QUOTES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a job using signed operator price quotes
    /// @param serviceId The service to submit the job to
    /// @param jobIndex The job type index
    /// @param inputs Encoded job parameters
    /// @param quotes Array of signed quotes from operators (1 or more)
    /// @return callId The created job call ID
    function submitJobFromQuote(
        uint64 serviceId,
        uint8 jobIndex,
        bytes calldata inputs,
        Types.SignedJobQuote[] calldata quotes
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (uint64 callId)
    {
        if (quotes.length == 0) revert Errors.NoQuotes();

        Types.Service storage svc = _getService(serviceId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        // Validate service is active and not expired
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) {
            revert Errors.ServiceExpired(serviceId);
        }

        // Validate caller is permitted
        if (!_permittedCallers[serviceId].contains(msg.sender)) {
            revert Errors.NotPermittedCaller(serviceId, msg.sender);
        }

        // Validate job inputs
        if (jobIndex >= _blueprintJobSchemas[svc.blueprintId].length) {
            revert Errors.InvalidJobIndex(jobIndex);
        }
        Types.StoredJobSchema storage schema = _blueprintJobSchemas[svc.blueprintId][jobIndex];
        SchemaLib.validateJobParams(schema, inputs, svc.blueprintId, jobIndex);

        // Verify quotes and compute total cost
        uint64 effectiveMaxQuoteAge = _maxQuoteAge > 0 ? _maxQuoteAge : ProtocolConfig.MAX_QUOTE_AGE;
        uint256 totalPrice = _verifyQuotesAndRecordOperators(serviceId, jobIndex, quotes, effectiveMaxQuoteAge);

        // Collect payment
        PaymentLib.collectPayment(address(0), totalPrice, msg.value);
        _recordPayment(msg.sender, serviceId, address(0), totalPrice);

        // Create the job call
        callId = _serviceCallCount[serviceId]++;
        _jobCalls[serviceId][callId] = Types.JobCall({
            jobIndex: jobIndex,
            caller: msg.sender,
            createdAt: uint64(block.timestamp),
            resultCount: 0,
            payment: totalPrice,
            completed: false,
            isRFQ: true
        });

        // Record quoted operators and their prices
        address[] memory quotedOperators = new address[](quotes.length);
        for (uint256 i = 0; i < quotes.length; i++) {
            _jobQuotedOperators[serviceId][callId].add(quotes[i].operator);
            _jobQuotedPrices[serviceId][callId][quotes[i].operator] = quotes[i].details.price;
            quotedOperators[i] = quotes[i].operator;
        }

        // Store inputs for manager hook
        _jobInputs[serviceId][callId] = inputs;

        emit JobSubmittedFromQuote(serviceId, callId, jobIndex, msg.sender, quotedOperators, totalPrice, inputs);

        // Notify blueprint manager
        if (bp.manager != address(0)) {
            bytes memory payload =
                abi.encodeCall(IBlueprintServiceManager.onJobCall, (serviceId, jobIndex, callId, inputs));
            _callManager(bp.manager, payload);
        }

        _recordJobCall(serviceId, msg.sender, callId);
    }

    /// @notice Verify all quotes and return total price
    function _verifyQuotesAndRecordOperators(
        uint64 serviceId,
        uint8 jobIndex,
        Types.SignedJobQuote[] calldata quotes,
        uint64 maxQuoteAge
    )
        private
        returns (uint256 totalPrice)
    {
        for (uint256 i = 0; i < quotes.length; i++) {
            Types.SignedJobQuote calldata quote = quotes[i];

            // Validate quote matches this job
            if (quote.details.serviceId != serviceId) {
                revert Errors.JobQuoteServiceMismatch(serviceId, quote.details.serviceId);
            }
            if (quote.details.jobIndex != jobIndex) {
                revert Errors.JobQuoteJobIndexMismatch(jobIndex, quote.details.jobIndex);
            }

            // Check for duplicate operators
            for (uint256 j = 0; j < i; j++) {
                if (quotes[j].operator == quote.operator) {
                    revert Errors.DuplicateOperatorQuote(quote.operator);
                }
            }

            // Verify operator is active in this service
            if (!_serviceOperators[serviceId][quote.operator].active) {
                revert Errors.OperatorNotInService(serviceId, quote.operator);
            }
            if (!_staking.isOperatorActive(quote.operator)) {
                revert Errors.OperatorNotActive(quote.operator);
            }

            // Verify EIP-712 signature and mark as used
            SignatureLib.verifyAndMarkJobQuoteUsed(_usedQuotes, _domainSeparator, quote, maxQuoteAge);

            totalPrice += quote.details.price;
        }
    }

    /// @notice Get the quoted operators for an RFQ job
    /// @param serviceId The service ID
    /// @param callId The job call ID
    /// @return operators Array of quoted operator addresses
    function getJobQuotedOperators(uint64 serviceId, uint64 callId) external view returns (address[] memory operators) {
        return _jobQuotedOperators[serviceId][callId].values();
    }

    /// @notice Get a quoted operator's price for an RFQ job
    /// @param serviceId The service ID
    /// @param callId The job call ID
    /// @param operator The operator address
    /// @return price The quoted price (0 if not quoted)
    function getJobQuotedPrice(uint64 serviceId, uint64 callId, address operator)
        external
        view
        returns (uint256 price)
    {
        return _jobQuotedPrices[serviceId][callId][operator];
    }

    /// @notice Distribute payment for RFQ job - to be implemented by facet
    function _distributeRFQJobPayment(uint64 serviceId, uint64 callId, uint256 totalPayment) internal virtual;
}
