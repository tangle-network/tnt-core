// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { JobsAggregation } from "../../core/JobsAggregation.sol";
import { Types } from "../../libraries/Types.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleJobsAggregationFacet
/// @notice Facet for aggregated job results
contract TangleJobsAggregationFacet is JobsAggregation, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](1);
        selectorList[0] = this.submitAggregatedResult.selector;
    }

    /// @notice Distribute job payment (called from Jobs mixin)
    /// @dev Payment is distributed based on effective exposure (delegation × exposureBps)
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal override {
        Types.Service storage svc = _services[serviceId];
        address[] memory operators = _serviceOperatorSet[serviceId].values();

        ITanglePaymentsInternal(address(this))
            .distributePayment(serviceId, svc.blueprintId, address(0), payment, operators);
    }

    /// @notice Distribute RFQ job payment to quoted operators at their individual prices
    function _distributeRFQJobPayment(uint64 serviceId, uint64 callId, uint256) internal override {
        Types.Service storage svc = _services[serviceId];
        address[] memory quotedOps = _jobQuotedOperators[serviceId][callId].values();

        for (uint256 i = 0; i < quotedOps.length; i++) {
            uint256 opPayment = _jobQuotedPrices[serviceId][callId][quotedOps[i]];
            if (opPayment == 0) continue;

            address[] memory singleOp = new address[](1);
            singleOp[0] = quotedOps[i];

            ITanglePaymentsInternal(address(this))
                .distributePayment(serviceId, svc.blueprintId, address(0), opPayment, singleOp);
        }
    }

    /// @notice Get the list of operators for a service (called from Jobs mixin for aggregation)
    function _getServiceOperatorList(uint64 serviceId) internal view override returns (address[] memory) {
        return _serviceOperatorSet[serviceId].values();
    }
}
