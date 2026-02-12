// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { QuotesExtend } from "../../core/QuotesExtend.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleQuotesExtensionFacet
/// @notice Facet for RFQ-based service extension
contract TangleQuotesExtensionFacet is QuotesExtend, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](1);
        selectorList[0] = bytes4(
            keccak256(
                "extendServiceFromQuotes(uint64,((uint64,uint64,uint256,uint64,uint64,((uint8,address),uint16)[],(uint8,uint64)[]),bytes,address)[],uint64)"
            )
        );
    }

    /// @notice Distribute extension payment as streaming (called from Quotes mixin)
    /// @dev Payment is distributed based on effective exposure (delegation × exposureBps)
    function _distributeExtensionPayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint64 startTime,
        uint64 endTime
    )
        internal
        override
    {
        if (amount == 0) return;

        // Payments currently distribute "immediate" amounts; streaming is handled by
        // ServiceFeeDistributor/StreamingPaymentManager.
        startTime;
        endTime;

        ITanglePaymentsInternal(address(this)).distributePayment(serviceId, blueprintId, address(0), amount, operators);
    }
}
