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
        if (jobIndex >= _blueprintJobs[svc.blueprintId].length) {
            revert Errors.InvalidJobIndex(jobIndex);
        }
        Types.JobDefinition storage job = _blueprintJobs[svc.blueprintId][jobIndex];
        SchemaLib.validateJobParams(job, inputs, svc.blueprintId, jobIndex);

        // Verify quotes and compute total cost. The operator-signed price is bound to the
        // exact job inputs via keccak256(inputs); a substituted-input redemption reverts.
        uint64 effectiveMaxQuoteAge = _maxQuoteAge > 0 ? _maxQuoteAge : ProtocolConfig.MAX_QUOTE_AGE;
        bytes32 inputsHash = keccak256(inputs);
        uint256 totalPrice = _verifyQuotesAndRecordOperators(
            serviceId, jobIndex, quotes, effectiveMaxQuoteAge, msg.sender, inputsHash
        );

        // Settle the RFQ quote in the service's pinned EventDriven settlement asset
        // (`address(0)` = native, which is also the default for any non-EventDriven service,
        // preserving the prior native-only behavior). For an ERC20-settlement service the
        // manager allow-list is re-checked here (fail-closed) and the quoted price is pulled
        // via `transferFrom`; the matching distribution in `_distributeRFQJobPayment` pays out
        // in the same asset.
        address asset = _serviceEventDrivenAsset[serviceId];
        if (totalPrice > 0 && !_isPaymentAssetAllowedByManager(bp.manager, serviceId, asset)) {
            revert Errors.TokenNotAllowed(asset);
        }

        // Collect payment
        PaymentLib.collectPayment(asset, totalPrice, msg.value);
        _recordPayment(msg.sender, serviceId, asset, totalPrice);

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
        for (uint256 i = 0; i < quotes.length;) {
            _jobQuotedOperators[serviceId][callId].add(quotes[i].operator);
            _jobQuotedPrices[serviceId][callId][quotes[i].operator] = quotes[i].details.price;
            quotedOperators[i] = quotes[i].operator;
            unchecked {
                ++i;
            }
        }

        // Store only the input hash (reuse the keccak already computed at line 86 for quote
        // verification) for the onJobResult witness anchor; raw inputs ride the event below.
        _jobInputsHash[serviceId][callId] = inputsHash;

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
        uint64 maxQuoteAge,
        address expectedRequester,
        bytes32 expectedInputsHash
    )
        private
        returns (uint256 totalPrice)
    {
        // Per-service field is invariant across the per-quote loop (the service is not
        // mutated within this call); hoist the storage read out of the loop.
        uint8 svcConfidentiality = uint8(_services[serviceId].confidentiality);

        for (uint256 i = 0; i < quotes.length;) {
            Types.SignedJobQuote calldata quote = quotes[i];

            // Validate quote matches this job
            if (quote.details.serviceId != serviceId) {
                revert Errors.JobQuoteServiceMismatch(serviceId, quote.details.serviceId);
            }
            if (quote.details.jobIndex != jobIndex) {
                revert Errors.JobQuoteJobIndexMismatch(jobIndex, quote.details.jobIndex);
            }
            if (quote.details.confidentiality != svcConfidentiality) {
                revert Errors.InvalidQuoteSignature(quote.operator);
            }

            // Check for duplicate operators
            for (uint256 j = 0; j < i;) {
                if (quotes[j].operator == quote.operator) {
                    revert Errors.DuplicateOperatorQuote(quote.operator);
                }
                unchecked {
                    ++j;
                }
            }

            // Verify operator is active in this service
            if (!_serviceOperators[serviceId][quote.operator].active) {
                revert Errors.OperatorNotInService(serviceId, quote.operator);
            }
            if (!_staking.isOperatorActive(quote.operator)) {
                revert Errors.OperatorNotActive(quote.operator);
            }

            // Each individual quote must meet minimum payment threshold (or be zero)
            // to prevent bricking job finalization during per-operator distribution
            if (quote.details.price > 0 && quote.details.price < PaymentLib.MINIMUM_PAYMENT_AMOUNT) {
                revert Errors.PaymentTooSmall(quote.details.price, PaymentLib.MINIMUM_PAYMENT_AMOUNT);
            }

            // Verify EIP-712 signature and mark as used. Domain separator is recomputed
            // per-call against current chainid so cross-fork replay is impossible.
            SignatureLib.verifyAndMarkJobQuoteUsed(
                _usedQuotes, _domainSeparatorView(), quote, maxQuoteAge, expectedRequester, expectedInputsHash
            );

            totalPrice += quote.details.price;

            unchecked {
                ++i;
            }
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
