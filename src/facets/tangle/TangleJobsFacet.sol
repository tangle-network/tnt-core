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
    /// @dev Payment is distributed based on effective exposure (delegation × exposureBps)
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal override {
        Types.Service storage svc = _services[serviceId];
        address[] memory operators = _serviceOperatorSet[serviceId].values();

        ITanglePaymentsInternal(address(this))
            .distributePayment(serviceId, svc.blueprintId, address(0), payment, operators);
    }

    /// @notice Distribute RFQ job payment to quoted operators at their individual prices
    function _distributeRFQJobPayment(uint64 serviceId, uint64 callId, uint256 totalPayment) internal override {
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
}
