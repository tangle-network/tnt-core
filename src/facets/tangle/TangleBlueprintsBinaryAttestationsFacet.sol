// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintsBinaryAttestations } from "../../core/BlueprintsBinaryAttestations.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleBlueprintsBinaryAttestationsFacet
/// @notice Facet exposing permissionless attestations against blueprint binary versions.
contract TangleBlueprintsBinaryAttestationsFacet is BlueprintsBinaryAttestations, IFacetSelectors {
    /// @dev `listAttestations` is intentionally NOT exposed via Tangle's selector
    ///      router. It returns an unbounded array, which is fine for off-chain
    ///      `eth_call` enumeration but a footgun for any on-chain consumer that
    ///      tried to invoke it through the Tangle proxy (spammed attestations
    ///      would brick the consumer with OOG). On-chain reads should iterate
    ///      via `getAttestationCount` + `getAttestation(id)` instead.
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](4);
        selectorList[0] = this.attestBinaryVersion.selector;
        selectorList[1] = this.revokeAttestation.selector;
        selectorList[2] = this.getAttestation.selector;
        selectorList[3] = this.getAttestationCount.selector;
    }
}
