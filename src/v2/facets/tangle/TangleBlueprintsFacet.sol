// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Blueprints } from "../../core/Blueprints.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsFacet
/// @notice Facet for blueprint management
contract TangleBlueprintsFacet is Blueprints, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](5);
        selectorList[0] = this.createBlueprint.selector;
        selectorList[1] = this.getBlueprintDefinition.selector;
        selectorList[2] = this.updateBlueprint.selector;
        selectorList[3] = this.transferBlueprint.selector;
        selectorList[4] = this.deactivateBlueprint.selector;
    }
}
