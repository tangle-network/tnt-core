// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { QuotesCreate } from "../../core/QuotesCreate.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleQuotesFacet
/// @notice Facet for RFQ-based service creation
contract TangleQuotesFacet is QuotesCreate, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](1);
        selectorList[0] = bytes4(keccak256("createServiceFromQuotes(uint64,((uint64,uint64,uint256,uint64,uint64,((uint8,address),uint16)[]),bytes,address)[],bytes,address[],uint64)"));
    }

    /// @notice Distribute quote payment (called from Quotes mixin)
    function _distributeQuotePayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint16[] memory exposures,
        uint256 totalExposure
    ) internal override {
        ITanglePaymentsInternal(address(this)).distributePayment(
            serviceId,
            blueprintId,
            address(0),
            amount,
            operators,
            exposures,
            totalExposure
        );
    }
}
