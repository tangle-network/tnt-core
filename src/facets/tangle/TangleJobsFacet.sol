// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { JobsSubmission } from "../../core/JobsSubmission.sol";
import { Types } from "../../libraries/Types.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleJobsFacet
/// @notice Facet for job submission and results
contract TangleJobsFacet is JobsSubmission, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](3);
        selectorList[0] = this.submitJob.selector;
        selectorList[1] = this.submitResult.selector;
        selectorList[2] = this.submitResults.selector;
    }

    /// @notice Distribute job payment (called from Jobs mixin)
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal override {
        Types.Service storage svc = _services[serviceId];

        address[] memory operators = _serviceOperatorSet[serviceId].values();
        uint16[] memory exposures = new uint16[](operators.length);
        uint256 totalExposure = 0;

        uint256 operatorsLength = operators.length;
        for (uint256 i = 0; i < operatorsLength;) {
            exposures[i] = _serviceOperators[serviceId][operators[i]].exposureBps;
            totalExposure += exposures[i];
            unchecked { ++i; }
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
}
