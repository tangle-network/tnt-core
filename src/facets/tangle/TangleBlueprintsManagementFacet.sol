// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsManage } from "../../core/BlueprintsManage.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsManagementFacet
/// @notice Facet for blueprint metadata and ownership
contract TangleBlueprintsManagementFacet is BlueprintsManage, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](8);
        selectorList[0] = this.getBlueprintDefinition.selector;
        selectorList[1] = this.updateBlueprint.selector;
        selectorList[2] = this.transferBlueprint.selector;
        selectorList[3] = this.deactivateBlueprint.selector;
        selectorList[4] = this.setJobEventRates.selector;
        selectorList[5] = this.getJobEventRate.selector;
        selectorList[6] = bytes4(keccak256("setBlueprintResourceRequirements(uint64,(uint8,uint64)[])"));
        selectorList[7] = bytes4(keccak256("getBlueprintResourceRequirements(uint64)"));
    }
}
