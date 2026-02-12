// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { QuotesCreate } from "../../core/QuotesCreate.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleQuotesFacet
/// @notice Facet for RFQ-based service creation
contract TangleQuotesFacet is QuotesCreate, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](2);
        selectorList[0] = bytes4(
            keccak256(
                "createServiceFromQuotes(uint64,((uint64,uint64,uint256,uint64,uint64,((uint8,address),uint16)[],(uint8,uint64)[]),bytes,address)[],bytes,address[],uint64)"
            )
        );
        selectorList[1] = bytes4(keccak256("getServiceResourceCommitmentHash(uint64,address)"));
    }

    /// @notice Distribute quote payment (called from Quotes mixin)
    /// @dev Payment is distributed based on effective exposure (delegation × exposureBps)
    function _distributeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators
    )
        internal
        override
    {
        ITanglePaymentsInternal(address(this)).distributePayment(serviceId, blueprintId, address(0), amount, operators);
    }
}
