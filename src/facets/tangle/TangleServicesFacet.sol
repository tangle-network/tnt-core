// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { ServicesApprovals } from "../../core/ServicesApprovals.sol";
import { Types } from "../../libraries/Types.sol";
import { IBlueprintServiceManager } from "../../interfaces/IBlueprintServiceManager.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";
import { IPriceOracle } from "../../oracles/interfaces/IPriceOracle.sol";

/// @title TangleServicesFacet
/// @notice Facet for service approvals and activation
contract TangleServicesFacet is ServicesApprovals, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](6);
        selectorList[0] = this.approveService.selector;
        selectorList[1] = bytes4(keccak256("approveServiceWithCommitments(uint64,((uint8,address),uint16)[])"));
        selectorList[2] = this.rejectService.selector;
        selectorList[3] = this.approveServiceWithBls.selector;
        selectorList[4] = bytes4(keccak256("approveServiceWithCommitmentsAndBls(uint64,((uint8,address),uint16)[],uint256[4])"));
        selectorList[5] = this.getOperatorBlsPubkey.selector;
    }

    /// @notice Get operator's BLS public key for a service
    /// @param serviceId The service ID
    /// @param operator The operator address
    /// @return blsPubkey The BLS G2 public key [x0, x1, y0, y1], all zeros if not registered
    function getOperatorBlsPubkey(uint64 serviceId, address operator) external view returns (uint256[4] memory blsPubkey) {
        Types.BLSPubkey storage stored = _serviceOperatorBlsPubkeys[serviceId][operator];
        blsPubkey[0] = stored.key[0];
        blsPubkey[1] = stored.key[1];
        blsPubkey[2] = stored.key[2];
        blsPubkey[3] = stored.key[3];
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

        // Transfer BLS pubkeys from request to service for aggregated signature verification
        _transferBlsPubkeysToService(requestId, serviceId);

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
        uint64 blueprintId = _serviceRequests[requestId].blueprintId;

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

            // Track active service count per blueprint for operator unregistration checks
            _operatorActiveServiceCount[blueprintId][op]++;
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
        uint16[] memory, // exposures - unused, we compute effective exposures
        uint256, // totalExposure - unused
        uint64 requestId
    ) private {
        if (paymentAmount == 0) {
            return;
        }
        if (pricing == Types.PricingModel.PayOnce) {
            address[] memory operators = _copyRequestOperators(requestId);
            
            // Compute effective exposures (delegation × exposureBps) for each operator
            (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure) = 
                _computeEffectiveExposures(serviceId, operators);
            
            ITanglePaymentsInternal(address(this)).distributePaymentWithEffectiveExposure(
                serviceId,
                blueprintId,
                paymentToken,
                paymentAmount,
                operators,
                effectiveExposures,
                totalEffectiveExposure
            );
        } else if (pricing == Types.PricingModel.Subscription) {
            ITanglePaymentsInternal(address(this)).depositToEscrow(serviceId, paymentToken, paymentAmount);
        }
    }

    /// @notice Compute effective exposures for operators based on their security commitments
    /// @dev effectiveExposure = Σ (delegation[asset] × exposureBps[asset]) for each operator
    /// @param serviceId The service ID
    /// @param operators Array of operator addresses
    /// @return effectiveExposures Array of effective exposure values
    /// @return totalEffectiveExposure Sum of all effective exposures
    function _computeEffectiveExposures(
        uint64 serviceId,
        address[] memory operators
    ) private view returns (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure) {
        uint256 operatorsLength = operators.length;
        effectiveExposures = new uint256[](operatorsLength);
        
        address priceOracleAddr = _priceOracle;
        bool useOracle = priceOracleAddr != address(0);
        IPriceOracle oracle = IPriceOracle(priceOracleAddr);

        for (uint256 i = 0; i < operatorsLength;) {
            address operator = operators[i];
            Types.AssetSecurityCommitment[] storage commitments = _serviceSecurityCommitments[serviceId][operator];
            
            uint256 operatorEffectiveExposure = 0;
            uint256 commitmentsLength = commitments.length;
            
            for (uint256 j = 0; j < commitmentsLength;) {
                Types.AssetSecurityCommitment storage commitment = commitments[j];
                
                // Get delegation for this asset
                uint256 delegation = _staking.getOperatorStakeForAsset(operator, commitment.asset);
                
                if (delegation > 0) {
                    // Calculate exposed amount: delegation × exposureBps / 10000
                    uint256 exposedAmount = (delegation * commitment.exposureBps) / BPS_DENOMINATOR;
                    
                    if (useOracle && exposedAmount > 0) {
                        // Convert to USD for cross-asset comparison
                        address token = commitment.asset.kind == Types.AssetKind.Native 
                            ? address(0) 
                            : commitment.asset.token;
                        try oracle.toUSD(token, exposedAmount) returns (uint256 usdValue) {
                            operatorEffectiveExposure += usdValue;
                        } catch {
                            // Fallback: use raw amount if oracle fails
                            operatorEffectiveExposure += exposedAmount;
                        }
                    } else {
                        // No oracle: use raw amount
                        operatorEffectiveExposure += exposedAmount;
                    }
                }
                
                unchecked { ++j; }
            }
            
            effectiveExposures[i] = operatorEffectiveExposure;
            totalEffectiveExposure += operatorEffectiveExposure;
            
            unchecked { ++i; }
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

    // ═══════════════════════════════════════════════════════════════════════════
    // BLS PUBKEY STORAGE IMPLEMENTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Store BLS pubkey for an operator in the request
    function _storeRequestBlsPubkey(
        uint64 requestId,
        address operator,
        uint256[4] memory blsPubkey
    ) internal override {
        _requestOperatorBlsPubkeys[requestId][operator] = Types.BLSPubkey({
            key: blsPubkey
        });
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
}
