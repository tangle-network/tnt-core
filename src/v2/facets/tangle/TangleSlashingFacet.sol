// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Slashing } from "../../core/Slashing.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleSlashingFacet
/// @notice Facet for slashing flows
contract TangleSlashingFacet is Slashing, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](8);
        selectorList[0] = bytes4(keccak256("proposeSlash(uint64,address,uint256,bytes32)"));
        selectorList[1] = this.disputeSlash.selector;
        selectorList[2] = this.executeSlash.selector;
        selectorList[3] = this.executeSlashBatch.selector;
        selectorList[4] = this.getExecutableSlashes.selector;
        selectorList[5] = this.cancelSlash.selector;
        selectorList[6] = this.setSlashConfig.selector;
        selectorList[7] = this.getSlashProposal.selector;
    }
}
