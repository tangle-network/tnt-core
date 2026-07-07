// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { ServicesApprovals } from "../../core/ServicesApprovals.sol";
import { Types } from "../../libraries/Types.sol";
import { Errors } from "../../libraries/Errors.sol";
import { SignatureLib } from "../../libraries/SignatureLib.sol";
import { IBlueprintServiceManager } from "../../interfaces/IBlueprintServiceManager.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleServicesFacet
/// @notice Facet for service approvals and activation
contract TangleServicesFacet is ServicesApprovals, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](2);
        selectorList[0] = this.approveService.selector;
        selectorList[1] = this.rejectService.selector;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CROSS-MIXIN IMPLEMENTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Activate a fully approved service (called from Services mixin)
    function _activateService(uint64 requestId) internal override {
        Types.ServiceRequest storage req = _serviceRequests[requestId];
        // Close the request lifecycle BEFORE any other state writes or external
        // calls. Once flipped, expireServiceRequest cannot refund this escrow and
        // late approve/reject paths revert. Set first so a malicious manager hook
        // re-entering through any of those paths sees the closed state.
        req.activated = true;

        uint64 serviceId = _serviceCount++;
        Types.Blueprint storage bp = _blueprints[req.blueprintId];

        _createServiceRecord(serviceId, req, bp);
        _persistServiceSecurity(serviceId, requestId);

        // Transfer BLS pubkeys from request to service for aggregated signature verification
        _transferBlsPubkeysToService(requestId, serviceId);

        // Persist resource commitments from request to service (hash per operator)
        _persistResourceCommitments(serviceId, requestId);

        // Persist TEE attestation commitments from request to service (per operator).
        _persistTeeCommitments(serviceId, requestId);

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
            requestId, serviceId, req.blueprintId, req.requester, req.ttl, bp.manager, req.confidentiality
        );
    }

    function _persistServiceSecurity(uint64 serviceId, uint64 requestId) private {
        Types.AssetSecurityRequirement[] storage reqs = _requestSecurityRequirements[requestId];
        if (reqs.length == 0) return;

        for (uint256 i = 0; i < reqs.length; i++) {
            _serviceSecurityRequirements[serviceId].push(reqs[i]);
        }

        address[] storage operators = _requestOperators[requestId];
        for (uint256 i = 0; i < operators.length; i++) {
            Types.AssetSecurityCommitment[] storage commits = _requestSecurityCommitments[requestId][operators[i]];
            for (uint256 j = 0; j < commits.length; j++) {
                _serviceSecurityCommitments[serviceId][operators[i]].push(commits[j]);
                // forge-lint: disable-next-line(asm-keccak256)
                bytes32 assetHash = keccak256(abi.encode(commits[j].asset.kind, commits[j].asset.token));
                _serviceSecurityCommitmentBps[serviceId][operators[i]][assetHash] = commits[j].exposureBps;
            }
        }
    }

    function _createServiceRecord(
        uint64 serviceId,
        Types.ServiceRequest storage req,
        Types.Blueprint storage bp
    )
        private
    {
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
            confidentiality: req.confidentiality,
            status: Types.ServiceStatus.Active
        });
    }

    function _assignOperatorsFromRequest(
        uint64 serviceId,
        uint64 requestId
    )
        private
        returns (uint16[] memory exposures, uint256 totalExposure)
    {
        address[] storage requestOperators = _requestOperators[requestId];
        exposures = new uint16[](requestOperators.length);
        uint64 blueprintId = _serviceRequests[requestId].blueprintId;

        for (uint256 i = 0; i < requestOperators.length; i++) {
            address op = requestOperators[i];
            uint16 exposure = _requestExposures[requestId][op];
            exposures[i] = exposure;

            _serviceOperators[serviceId][op] = Types.ServiceOperator({
                exposureBps: exposure, joinedAt: uint64(block.timestamp), leftAt: 0, active: true
            });
            _serviceOperatorSet[serviceId].add(op);
            totalExposure += exposure;

            // Track active service count per blueprint for operator unregistration checks
            _operatorActiveServiceCount[blueprintId][op]++;
        }
    }

    function _grantPermittedCallers(uint64 serviceId, uint64 requestId, address requester) private {
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
        uint16[] memory, // exposures - unused, effective exposures computed internally
        uint256, // totalExposure - unused
        uint64 requestId
    )
        private
    {
        if (pricing == Types.PricingModel.Subscription) {
            // Persist selected settlement token even when initial deposit is zero so
            // later top-ups land in the same currency.
            if (_serviceEscrows[serviceId].totalDeposited == 0) {
                _serviceEscrows[serviceId].token = paymentToken;
            }
            if (paymentAmount > 0) {
                ITanglePaymentsInternal(address(this)).depositToEscrow(serviceId, paymentToken, paymentAmount);
            }
            // Seed per-operator TWAP cursors and pin the baseline at activation. The
            // first bill will then measure cumDelta against the activation snapshot
            // rather than against state captured at first bill (which could let
            // post-activation stake changes shift the contract the customer signed).
            address[] memory operators = _copyRequestOperators(requestId);
            ITanglePaymentsInternal(address(this)).initSubscriptionBaseline(serviceId, operators);
            return;
        }

        if (pricing == Types.PricingModel.EventDriven) {
            // EventDriven services are funded by per-job `msg.value`, not by an upfront
            // lump sum. `paymentAmount` is rejected at request-time by
            // `_validatePricingPaymentConsistency`; nothing to do here.
            return;
        }

        // PayOnce: single upfront amount distributed immediately to all stakeholders.
        if (paymentAmount == 0) return;
        address[] memory payOnceOperators = _copyRequestOperators(requestId);
        ITanglePaymentsInternal(address(this))
            .distributePayment(serviceId, blueprintId, paymentToken, paymentAmount, payOnceOperators);
    }

    function _triggerManagerOnActivation(
        uint64 requestId,
        uint64 serviceId,
        uint64 blueprintId,
        address requester,
        uint64 ttl,
        address manager,
        Types.ConfidentialityPolicy confidentiality
    )
        private
    {
        emit ServiceActivated(serviceId, requestId, blueprintId, confidentiality);

        address[] memory operators = _copyRequestOperators(requestId);
        _configureHeartbeat(serviceId, manager, requester, operators);

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

    // ═══════════════════════════════════════════════════════════════════════════
    // RESOURCE COMMITMENT PERSISTENCE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Persist resource commitments from request to service
    /// @dev Computes hash of requirements and stores per-operator (same storage as RFQ flow)
    function _persistResourceCommitments(uint64 serviceId, uint64 requestId) private {
        Types.ResourceCommitment[] storage reqs = _requestResourceRequirements[requestId];
        if (reqs.length == 0) return;

        // Copy to memory for hashing
        Types.ResourceCommitment[] memory commitments = new Types.ResourceCommitment[](reqs.length);
        for (uint256 i = 0; i < reqs.length; i++) {
            commitments[i] = reqs[i];
        }

        bytes32 commitmentHash = SignatureLib.hashResourceCommitments(commitments);

        address[] storage operators = _requestOperators[requestId];
        for (uint256 i = 0; i < operators.length; i++) {
            _serviceResourceCommitmentHash[serviceId][operators[i]] = commitmentHash;
            emit ResourcesCommitted(serviceId, operators[i], commitments);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLS PUBKEY STORAGE IMPLEMENTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Store BLS pubkey for an operator in the request
    function _storeRequestBlsPubkey(uint64 requestId, address operator, uint256[4] memory blsPubkey) internal override {
        _requestOperatorBlsPubkeys[requestId][operator] = Types.BLSPubkey({ key: blsPubkey });
    }

    /// @notice Transfer BLS pubkeys from request to service (called during activation)
    function _transferBlsPubkeysToService(uint64 requestId, uint64 serviceId) internal override {
        address[] storage requestOperators = _requestOperators[requestId];
        for (uint256 i = 0; i < requestOperators.length; i++) {
            address op = requestOperators[i];
            Types.BLSPubkey storage reqKey = _requestOperatorBlsPubkeys[requestId][op];
            // Only transfer if non-zero
            if (reqKey.key[0] != 0 || reqKey.key[1] != 0 || reqKey.key[2] != 0 || reqKey.key[3] != 0) {
                _serviceOperatorBlsPubkeys[serviceId][op] = reqKey;
            }
        }
    }

    /// @notice Copy TEE attestation commitment root from request to service for every operator.
    /// @dev O(operators) — one bytes32 SSTORE per operator that supplied a non-empty TEE
    ///      commitment array. Operators that approved without TEE commitments are skipped
    ///      (their request-side root is `bytes32(0)`). The full commitment array was already
    ///      emitted in `TeeCommitmentsRecorded` at approval time; nothing else to copy.
    function _persistTeeCommitments(uint64 serviceId, uint64 requestId) private {
        address[] storage requestOperators = _requestOperators[requestId];
        for (uint256 i = 0; i < requestOperators.length; i++) {
            address op = requestOperators[i];
            bytes32 root = _requestTeeCommitmentRoot[requestId][op];
            if (root == bytes32(0)) continue;
            _serviceTeeCommitmentRoot[serviceId][op] = root;
            // Don't `delete` the request-side entry — the slashing branch and other facets
            // may still want to read the request-time commitments before a future cleanup
            // pass. Refund-via-delete is a follow-up perf optimisation, not a correctness
            // concern.
        }
    }
}
