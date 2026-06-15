// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { SignatureLib } from "../libraries/SignatureLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { ITanglePaymentsInternal } from "../interfaces/ITanglePaymentsInternal.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";

/// @title QuotesCreate
/// @notice RFQ service creation from signed quotes
abstract contract QuotesCreate is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @notice A quote's signed exposureBps exceeded the basis-point denominator (100%).
    /// @dev Declared locally per the quote-signing fix scope (shared Errors lib is off-limits).
    error QuoteExposureExceedsMax(address operator, uint16 exposureBps, uint16 maxBps);

    struct QuoteActivation {
        uint64 serviceId;
        uint256 totalExposure;
        Types.ConfidentialityPolicy confidentiality;
    }

    // ServiceActivated event inherited from Base.sol

    event ResourcesCommitted(
        uint64 indexed serviceId, address indexed operator, Types.ResourceCommitment[] commitments
    );

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
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (uint64 serviceId)
    {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        _requireBlueprintActive(bp, blueprintId);

        address[] memory operators = _gatherQuoteOperators(quotes);
        _ensureOperatorsRegistered(blueprintId, operators);
        uint16[] memory exposures = _extractQuoteExposures(quotes);

        uint256 totalCost = _verifyQuotesAndGetCost(quotes, blueprintId, ttl);

        // EventDriven services are funded per-job via `msg.value` at submission time.
        // A non-zero `totalCost` from the quote path would mean paying operators
        // upfront for work that hasn't happened — the same failure mode the request-side
        // `_validatePricingPaymentConsistency` guard prevents. Reject here so the quote
        // path can't bypass it.
        if (bp.pricing == Types.PricingModel.EventDriven && totalCost != 0) {
            revert Errors.UpfrontPaymentNotAllowedForEventDriven();
        }

        _ensureQuotePaymentAsset(bp.manager, _serviceCount, totalCost);
        _collectQuotePayment(totalCost);
        _notifyManagerQuoteRequest(bp.manager, operators, config, ttl, totalCost);

        QuoteActivation memory activation = _activateQuoteService(blueprintId, bp, operators, exposures, ttl, quotes);
        serviceId = activation.serviceId;

        _addInitialQuoteCallers(serviceId, msg.sender, permittedCallers);
        _notifyManagerQuoteInitialization(bp.manager, blueprintId, serviceId, msg.sender, permittedCallers, ttl);

        // Subscription-pricing quote services need the same per-operator TWAP baseline
        // seed that the non-quote activation path performs, so the first bill measures
        // against activation state.
        if (bp.pricing == Types.PricingModel.Subscription) {
            ITanglePaymentsInternal(address(this)).initSubscriptionBaseline(serviceId, operators);
        }

        _finalizeQuotePayment(serviceId, blueprintId, totalCost, operators);
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

    function _extractQuoteExposures(Types.SignedQuote[] calldata quotes)
        private
        pure
        returns (uint16[] memory exposures)
    {
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

    function _ensureQuotePaymentAsset(address manager, uint64 quoteContextId, uint256 totalCost) private view {
        if (manager != address(0) && totalCost > 0) {
            if (!_isPaymentAssetAllowedByManager(manager, quoteContextId, address(0))) {
                revert Errors.TokenNotAllowed(address(0));
            }
        }
    }

    function _notifyManagerQuoteRequest(
        address manager,
        address[] memory operators,
        bytes calldata config,
        uint64 ttl,
        uint256 totalCost
    )
        private
    {
        if (manager == address(0)) return;
        _callManager(
            manager,
            abi.encodeCall(
                IBlueprintServiceManager.onRequest, (0, msg.sender, operators, config, ttl, address(0), totalCost)
            )
        );
    }

    function _collectQuotePayment(uint256 totalCost) private {
        if (msg.value < totalCost) {
            revert Errors.InsufficientPaymentForQuotes(totalCost, msg.value);
        }
        if (msg.value > totalCost) {
            revert Errors.InvalidMsgValue(totalCost, msg.value);
        }
    }

    function _requireBlueprintActive(Types.Blueprint storage bp, uint64 blueprintId) private view {
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);
    }

    function _verifyQuotesAndGetCost(
        Types.SignedQuote[] calldata quotes,
        uint64 blueprintId,
        uint64 ttl
    )
        private
        returns (uint256 totalCost)
    {
        uint64 effectiveMaxQuoteAge = _maxQuoteAge > 0 ? _maxQuoteAge : ProtocolConfig.MAX_QUOTE_AGE;
        // Create quotes must be signed with operation == Create and serviceId == 0 so an
        // extension quote (low marginal cost) cannot be redeemed as a new service creation.
        (totalCost,) = SignatureLib.verifyQuoteBatch(
            _usedQuotes,
            _domainSeparatorView(),
            quotes,
            blueprintId,
            ttl,
            msg.sender,
            effectiveMaxQuoteAge,
            Types.QuoteOperation.Create,
            0
        );
        _ensureQuoteConfidentialityConsistent(quotes);
    }

    function _ensureQuoteConfidentialityConsistent(Types.SignedQuote[] calldata quotes) private pure {
        if (quotes.length == 0) return;
        Types.ConfidentialityPolicy basePolicy = quotes[0].details.confidentiality;
        for (uint256 i = 1; i < quotes.length; ++i) {
            if (quotes[i].details.confidentiality != basePolicy) {
                revert Errors.InvalidQuoteSignature(quotes[i].operator);
            }
        }
    }

    function _activateQuoteService(
        uint64 blueprintId,
        Types.Blueprint storage bp,
        address[] memory operators,
        uint16[] memory exposures,
        uint64 ttl,
        Types.SignedQuote[] calldata quotes
    )
        private
        returns (QuoteActivation memory activation)
    {
        activation.serviceId = _serviceCount++;
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[blueprintId];
        activation.confidentiality = quotes[0].details.confidentiality;

        // Enforce the blueprint's min/max operator quorum, mirroring the request/approve
        // path (ServicesRequests._validateOperatorBounds). Without this, the quote path
        // could activate a service with fewer operators than the blueprint requires or more
        // than the per-service ceiling that the bill/distribute/terminate loops assume.
        uint32 minOps = bpConfig.minOperators > 0 ? bpConfig.minOperators : 1;
        _validateQuoteOperatorBounds(bpConfig.maxOperators, uint32(operators.length), minOps);

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
            confidentiality: activation.confidentiality,
            status: Types.ServiceStatus.Active
        });

        activation.totalExposure =
            _processOperatorQuotes(blueprintId, activation.serviceId, operators, exposures, quotes);

        emit ServiceActivated(activation.serviceId, 0, blueprintId, activation.confidentiality);
        _recordServiceCreated(activation.serviceId, blueprintId, msg.sender, operators.length);
        _configureHeartbeat(activation.serviceId, bp.manager, msg.sender, operators);
    }

    function _addInitialQuoteCallers(uint64 serviceId, address owner, address[] calldata permittedCallers) private {
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
    )
        private
    {
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
                IBlueprintServiceManager.onServiceInitialized, (blueprintId, 0, serviceId, owner, callers, ttl)
            )
        );
    }

    function _finalizeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 totalCost,
        address[] memory operators
    )
        private
    {
        if (totalCost == 0) {
            return;
        }
        _distributeQuotePayment(serviceId, blueprintId, totalCost, operators);
    }

    /// @notice Process operator quotes and register them for the service
    /// @dev Extracted to separate function to avoid stack too deep
    function _processOperatorQuotes(
        uint64 blueprintId,
        uint64 serviceId,
        address[] memory operators,
        uint16[] memory exposures,
        Types.SignedQuote[] calldata quotes
    )
        internal
        returns (uint256 totalExposure)
    {
        for (uint256 i = 0; i < operators.length; i++) {
            uint16 exposure = exposures[i];
            _serviceOperators[serviceId][operators[i]] = Types.ServiceOperator({
                exposureBps: exposure, joinedAt: uint64(block.timestamp), leftAt: 0, active: true
            });
            _serviceOperatorSet[serviceId].add(operators[i]);
            totalExposure += exposure;

            // INVARIANT: every operator backing a live service — including RFQ/quote
            // services — must be counted in _operatorActiveServiceCount so the
            // unregisterOperator and startLeaving() active-service guards block them
            // from pulling stake while the service is Active. Mirrors the standard
            // request/approve activation path (TangleServicesFacet); _terminateService
            // decrements this for every operator in _serviceOperatorSet on termination.
            _operatorActiveServiceCount[blueprintId][operators[i]]++;

            // Store resource commitment hash for QoS dispute evidence
            Types.ResourceCommitment[] calldata resources = quotes[i].details.resourceCommitments;
            if (resources.length > 0) {
                _serviceResourceCommitmentHash[serviceId][operators[i]] =
                    SignatureLib.hashResourceCommitments(resources);
                emit ResourcesCommitted(serviceId, operators[i], resources);
            }
        }
    }

    /// @notice Get the resource commitment hash for an operator in a service
    function getServiceResourceCommitmentHash(uint64 serviceId, address operator) external view returns (bytes32) {
        return _serviceResourceCommitmentHash[serviceId][operator];
    }

    /// @notice Validate the quote-path operator count against blueprint min and the protocol max.
    /// @dev Mirrors ServicesRequests._validateOperatorBounds (which is private there). A
    ///      `maxOperators == 0` blueprint config means "unlimited" and clamps to the
    ///      governance-tunable `_maxOperatorsPerService` ceiling so every per-operator loop
    ///      in the bill/distribute/terminate paths stays bounded.
    function _validateQuoteOperatorBounds(uint32 maxOperators, uint32 operatorCount, uint32 minOps) private view {
        if (operatorCount < minOps) {
            revert Errors.InsufficientOperators(minOps, operatorCount);
        }
        uint32 protocolCeiling = _maxOperatorsPerService;
        uint32 effectiveMax = (maxOperators == 0 || maxOperators > protocolCeiling) ? protocolCeiling : maxOperators;
        if (operatorCount > effectiveMax) {
            revert Errors.TooManyOperators(effectiveMax, operatorCount);
        }
    }

    function _quoteExposure(Types.SignedQuote calldata quote) private pure returns (uint16) {
        Types.QuoteDetails calldata details = quote.details;
        Types.AssetSecurityCommitment[] calldata commitments = details.securityCommitments;
        if (commitments.length == 0) {
            return BPS_DENOMINATOR;
        }
        uint16 exposure = commitments[0].exposureBps;
        // Mirror the request-path bound (ServicesRequests._validateOperators). A signed
        // exposureBps is stored verbatim into _serviceOperators and used as the payment
        // weight; without this clamp an operator could sign exposureBps far above 100%
        // (e.g. 65535) and over-collect during subscription/event billing.
        if (exposure > BPS_DENOMINATOR) {
            revert QuoteExposureExceedsMax(quote.operator, exposure, BPS_DENOMINATOR);
        }
        return exposure;
    }

    /// @notice Distribute payment from quotes - to be implemented in final contract
    /// @dev Payment is distributed based on effective exposure (delegation × exposureBps)
    function _distributeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators
    )
        internal
        virtual;
}
