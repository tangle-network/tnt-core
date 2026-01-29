// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsManage } from "../../core/BlueprintsManage.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsManagementFacet
/// @notice Facet for blueprint metadata and ownership
contract TangleBlueprintsManagementFacet is BlueprintsManage, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](4);
        selectorList[0] = this.getBlueprintDefinition.selector;
        selectorList[1] = this.updateBlueprint.selector;
        selectorList[2] = this.transferBlueprint.selector;
        selectorList[3] = this.deactivateBlueprint.selector;
    }
}
