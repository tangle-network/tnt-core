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
        selectorList[0] = bytes4(keccak256("extendServiceFromQuotes(uint64,((uint64,uint64,uint256,uint64,uint64,((uint8,address),uint16)[]),bytes,address)[],uint64)"));
    }

    /// @notice Distribute extension payment as streaming (called from Quotes mixin)
    /// @dev Creates streaming payments starting from extensionStart
    function _distributeExtensionPayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint64 startTime,
        uint64 endTime
    ) internal override {
        if (amount == 0) return;

        // Payments currently distribute "immediate" amounts; streaming is handled by ServiceFeeDistributor/StreamingPaymentManager.
        startTime;
        endTime;

        uint16[] memory exposures = new uint16[](operators.length);
        uint256 totalExposure = 0;
        for (uint256 i = 0; i < operators.length; i++) {
            uint16 exposure = _serviceOperators[serviceId][operators[i]].exposureBps;
            exposures[i] = exposure;
            totalExposure += exposure;
        }
        if (totalExposure == 0) return;

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
