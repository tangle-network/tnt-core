// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Operators } from "../../core/Operators.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleOperatorsFacet
/// @notice Facet for operator registration and preferences
contract TangleOperatorsFacet is Operators, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](5);
        selectorList[0] = this.preRegister.selector;
        selectorList[1] = bytes4(keccak256("registerOperator(uint64,bytes,string)"));
        selectorList[2] = bytes4(keccak256("registerOperator(uint64,bytes,string,bytes)"));
        selectorList[3] = this.unregisterOperator.selector;
        selectorList[4] = this.updateOperatorPreferences.selector;
    }
}
