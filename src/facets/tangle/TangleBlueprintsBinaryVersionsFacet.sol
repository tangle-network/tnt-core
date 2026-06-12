// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsBinaryVersions } from "../../core/BlueprintsBinaryVersions.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsBinaryVersionsFacet
/// @notice Facet exposing the per-blueprint binary version registry and the
///         per-service upgrade policy / operator-ack surface.
contract TangleBlueprintsBinaryVersionsFacet is BlueprintsBinaryVersions, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](14);
        selectorList[0] = this.publishBinaryVersion.selector;
        selectorList[1] = this.setActiveBinaryVersion.selector;
        selectorList[2] = this.deprecateBinaryVersion.selector;
        selectorList[3] = this.setServiceUpgradePolicy.selector;
        selectorList[4] = this.ackBinaryVersion.selector;
        selectorList[5] = this.getBinaryVersion.selector;
        selectorList[6] = this.getBinaryVersionCount.selector;
        selectorList[7] = this.getActiveBinaryVersionId.selector;
        selectorList[8] = this.getServiceUpgradePolicy.selector;
        selectorList[9] = this.getServiceAckedVersionId.selector;
        selectorList[10] = this.effectiveBinaryVersion.selector;
        selectorList[11] = this.getOperatorServiceUpgradePolicy.selector;
        selectorList[12] = this.getOperatorAckedVersionId.selector;
        selectorList[13] = this.effectiveBinaryVersionForOperator.selector;
    }
}
