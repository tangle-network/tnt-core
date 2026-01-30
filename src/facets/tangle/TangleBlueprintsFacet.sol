// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsCreate } from "../../core/BlueprintsCreate.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsFacet
/// @notice Facet for blueprint creation
contract TangleBlueprintsFacet is BlueprintsCreate, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](1);
        selectorList[0] = this.createBlueprint.selector;
    }
}
