// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsManage } from "../../core/BlueprintsManage.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsManagementFacet
/// @notice Facet for blueprint metadata and ownership
contract TangleBlueprintsManagementFacet is BlueprintsManage, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](20);
        selectorList[0] = this.blueprintCount.selector;
        selectorList[1] = this.blueprintMetadata.selector;
        selectorList[2] = this.blueprintSupportedMemberships.selector;
        selectorList[3] = this.blueprintMasterRevision.selector;
        selectorList[4] = this.getBlueprintDefinition.selector;
        selectorList[5] = this.updateBlueprint.selector;
        selectorList[6] = this.transferBlueprint.selector;
        selectorList[7] = this.deactivateBlueprint.selector;
        selectorList[8] = this.setJobEventRates.selector;
        selectorList[9] = this.getJobEventRate.selector;
        selectorList[10] = bytes4(keccak256("setBlueprintResourceRequirements(uint64,(uint8,uint64)[])"));
        selectorList[11] = bytes4(keccak256("getBlueprintResourceRequirements(uint64)"));
        selectorList[12] = this.setBlueprintSources.selector;
        selectorList[13] = this.acceptBlueprintOwnership.selector;
        selectorList[14] = this.cancelBlueprintTransfer.selector;
        selectorList[15] = this.pendingBlueprintOwner.selector;
        selectorList[16] = this.ackBlueprintSources.selector;
        selectorList[17] = this.blueprintSourcesHash.selector;
        selectorList[18] = this.operatorAckedCurrentSources.selector;
        selectorList[19] = this.blueprintDefinitionHash.selector;
    }
}
