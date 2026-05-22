// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsBinaryAttestations } from "../../core/BlueprintsBinaryAttestations.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsBinaryAttestationsFacet
/// @notice Facet exposing permissionless attestations against blueprint binary versions.
contract TangleBlueprintsBinaryAttestationsFacet is BlueprintsBinaryAttestations, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](5);
        selectorList[0] = this.attestBinaryVersion.selector;
        selectorList[1] = this.revokeAttestation.selector;
        selectorList[2] = this.getAttestation.selector;
        selectorList[3] = this.getAttestationCount.selector;
        selectorList[4] = this.listAttestations.selector;
    }
}
