// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { ServicesRequests } from "../../core/ServicesRequests.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleServicesRequestsFacet
/// @notice Facet for service requests
contract TangleServicesRequestsFacet is ServicesRequests, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](3);
        selectorList[0] = bytes4(keccak256("requestService(uint64,address[],bytes,address[],uint64,address,uint256)"));
        selectorList[1] = bytes4(keccak256("requestServiceWithExposure(uint64,address[],uint16[],bytes,address[],uint64,address,uint256)"));
        selectorList[2] = bytes4(keccak256("requestServiceWithSecurity(uint64,address[],((uint8,address),uint16,uint16)[],bytes,address[],uint64,address,uint256)"));
    }
}
