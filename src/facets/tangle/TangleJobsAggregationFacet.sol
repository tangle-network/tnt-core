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
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal override {
        Types.Service storage svc = _services[serviceId];

        address[] memory operators = _serviceOperatorSet[serviceId].values();
        uint16[] memory exposures = new uint16[](operators.length);
        uint256 totalExposure = 0;

        for (uint256 i = 0; i < operators.length; i++) {
            exposures[i] = _serviceOperators[serviceId][operators[i]].exposureBps;
            totalExposure += exposures[i];
        }

        ITanglePaymentsInternal(address(this)).distributePayment(
            serviceId,
            svc.blueprintId,
            address(0),
            payment,
            operators,
            exposures,
            totalExposure
        );
    }

    /// @notice Get the list of operators for a service (called from Jobs mixin for aggregation)
    function _getServiceOperatorList(uint64 serviceId) internal view override returns (address[] memory) {
        return _serviceOperatorSet[serviceId].values();
    }
}
