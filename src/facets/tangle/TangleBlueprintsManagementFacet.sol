// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsManage } from "../../core/BlueprintsManage.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsManagementFacet
/// @notice Facet for blueprint metadata and ownership
contract TangleBlueprintsManagementFacet is BlueprintsManage, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](13);
        selectorList[0] = this.blueprintCount.selector;
        selectorList[1] = this.blueprintMetadata.selector;
        selectorList[2] = this.blueprintSources.selector;
        selectorList[3] = this.blueprintSupportedMemberships.selector;
        selectorList[4] = this.blueprintMasterRevision.selector;
        selectorList[5] = this.getBlueprintDefinition.selector;
        selectorList[6] = this.updateBlueprint.selector;
        selectorList[7] = this.transferBlueprint.selector;
        selectorList[8] = this.deactivateBlueprint.selector;
        selectorList[9] = this.setJobEventRates.selector;
        selectorList[10] = this.getJobEventRate.selector;
        selectorList[11] = bytes4(keccak256("setBlueprintResourceRequirements(uint64,(uint8,uint64)[])"));
        selectorList[12] = bytes4(keccak256("getBlueprintResourceRequirements(uint64)"));
    }
}
