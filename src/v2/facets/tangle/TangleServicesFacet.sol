// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { ServicesApprovals } from "../../core/ServicesApprovals.sol";
import { Types } from "../../libraries/Types.sol";
import { IBlueprintServiceManager } from "../../interfaces/IBlueprintServiceManager.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleServicesFacet
/// @notice Facet for service approvals and activation
contract TangleServicesFacet is ServicesApprovals, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](3);
        selectorList[0] = this.approveService.selector;
        selectorList[1] = bytes4(keccak256("approveServiceWithCommitments(uint64,((uint8,address),uint16)[])"));
        selectorList[2] = this.rejectService.selector;
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
        _persistServiceSecurity(serviceId, requestId);

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
            ITanglePaymentsInternal(address(this)).distributePayment(
                serviceId,
                blueprintId,
                paymentToken,
                paymentAmount,
                operators,
                exposures,
                totalExposure
            );
        } else if (pricing == Types.PricingModel.Subscription) {
            ITanglePaymentsInternal(address(this)).depositToEscrow(serviceId, paymentToken, paymentAmount);
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
}
