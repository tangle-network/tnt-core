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

        ITanglePaymentsInternal(address(this)).distributePayment(
            serviceId,
            svc.blueprintId,
            address(0),
            payment,
            operators
        );
    }

    /// @notice Get the list of operators for a service (called from Jobs mixin for aggregation)
    function _getServiceOperatorList(uint64 serviceId) internal view override returns (address[] memory) {
        return _serviceOperatorSet[serviceId].values();
    }
}
