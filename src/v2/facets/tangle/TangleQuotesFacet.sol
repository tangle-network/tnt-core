// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Quotes } from "../../core/Quotes.sol";
import { Payments } from "../../core/Payments.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleQuotesFacet
/// @notice Facet for RFQ-based service creation and extension
contract TangleQuotesFacet is Quotes, Payments, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](2);
        selectorList[0] = bytes4(keccak256("createServiceFromQuotes(uint64,((uint64,uint64,uint256,uint64,uint64,((uint8,address),uint16)[]),bytes,address)[],bytes,address[],uint64)"));
        selectorList[1] = bytes4(keccak256("extendServiceFromQuotes(uint64,((uint64,uint64,uint256,uint64,uint64,((uint8,address),uint16)[]),bytes,address)[],uint64)"));
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
        _distributePayment(serviceId, blueprintId, address(0), amount, operators, exposures, totalExposure);
    }

    /// @notice Distribute extension payment as streaming (called from Quotes mixin)
    /// @dev Creates streaming payments starting from extensionStart
    function _distributeExtensionPayment(
        uint64 serviceId,
        uint64 blueprintId,
        uint256 amount,
        address[] memory operators,
        uint16[] memory exposures,
        uint256 totalExposure,
        uint64 startTime,
        uint64 endTime
    ) internal override {
        if (amount == 0 || totalExposure == 0) return;

        // Extension payments go through the standard distribution which handles streaming
        // The service TTL has already been updated, so _distributePayment will stream correctly
        _distributePayment(serviceId, blueprintId, address(0), amount, operators, exposures, totalExposure);
    }
}
