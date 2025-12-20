// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Jobs } from "../../core/Jobs.sol";
import { Payments } from "../../core/Payments.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleJobsFacet
/// @notice Facet for job submission and results
contract TangleJobsFacet is Jobs, Payments, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](4);
        selectorList[0] = this.submitJob.selector;
        selectorList[1] = this.submitResult.selector;
        selectorList[2] = this.submitResults.selector;
        selectorList[3] = this.submitAggregatedResult.selector;
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

        _distributePayment(serviceId, svc.blueprintId, address(0), payment, operators, exposures, totalExposure);
    }

    /// @notice Get the list of operators for a service (called from Jobs mixin for aggregation)
    function _getServiceOperatorList(uint64 serviceId) internal view override returns (address[] memory) {
        return _serviceOperatorSet[serviceId].values();
    }
}
