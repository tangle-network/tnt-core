// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { JobsRFQ } from "../../core/JobsRFQ.sol";
import { Types } from "../../libraries/Types.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleJobsRFQFacet
/// @notice Facet for RFQ-based job submission with signed operator quotes
contract TangleJobsRFQFacet is JobsRFQ, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](3);
        selectorList[0] = this.submitJobFromQuote.selector;
        selectorList[1] = this.getJobQuotedOperators.selector;
        selectorList[2] = this.getJobQuotedPrice.selector;
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
