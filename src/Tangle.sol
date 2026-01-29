// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./core/Base.sol";
import { Errors } from "./libraries/Errors.sol";
import { IFacetSelectors } from "./interfaces/IFacetSelectors.sol";

/// @title Tangle
/// @notice Router contract that dispatches calls to protocol facets
contract Tangle is Base {
    event FacetRegistered(address indexed facet);
    event FacetSelectorSet(bytes4 indexed selector, address indexed facet);
    event FacetSelectorCleared(bytes4 indexed selector);

    /// @notice Initialize the contract
    function initialize(
        address admin,
        address staking_,
        address payable treasury_
    ) external initializer {
        __Base_init(admin, staking_, treasury_);
    }

    /// @notice Register selectors exposed by a facet
    function registerFacet(address facet) external onlyRole(UPGRADER_ROLE) {
        bytes4[] memory selectors = IFacetSelectors(facet).selectors();
        _setFacetSelectors(facet, selectors);
        emit FacetRegistered(facet);
    }

    /// @notice Register specific selectors for a facet
    function registerFacetSelectors(address facet, bytes4[] calldata selectors) external onlyRole(UPGRADER_ROLE) {
        _setFacetSelectors(facet, selectors);
    }

    /// @notice Remove selectors from the router
    function clearFacetSelectors(bytes4[] calldata selectors) external onlyRole(UPGRADER_ROLE) {
        for (uint256 i = 0; i < selectors.length; i++) {
            delete _facetForSelector[selectors[i]];
            emit FacetSelectorCleared(selectors[i]);
        }
    }

    /// @notice Resolve the facet for a selector
    function facetForSelector(bytes4 selector) external view returns (address) {
        return _facetForSelector[selector];
    }

    function _setFacetSelectors(address facet, bytes4[] memory selectors) internal {
        if (facet == address(0)) revert Errors.ZeroAddress();
        if (facet.code.length == 0) revert Errors.NotAContract(facet);
        for (uint256 i = 0; i < selectors.length; i++) {
            address existing = _facetForSelector[selectors[i]];
            if (existing != address(0) && existing != facet) {
                revert Errors.SelectorAlreadyRegistered(selectors[i], existing);
            }
            _facetForSelector[selectors[i]] = facet;
            emit FacetSelectorSet(selectors[i], facet);
        }
    }

    fallback() external payable {
        address facet = _facetForSelector[msg.sig];
        if (facet == address(0)) revert Errors.UnknownSelector(msg.sig);
        _delegateTo(facet);
    }

    /// @notice Delegate call to target facet using low-level assembly
    /// @dev Assembly is used here for gas efficiency and to properly forward
    ///      all calldata and return data. The pattern:
    ///      1. Copy all calldata to memory starting at position 0
    ///      2. Execute delegatecall to target with full calldata
    ///      3. Copy all return data to memory starting at position 0
    ///      4. Revert with return data if call failed, otherwise return with return data
    function _delegateTo(address target) private {
        assembly {
            // Copy calldata to memory at position 0
            calldatacopy(0, 0, calldatasize())
            // Execute delegatecall: gas, target address, input offset, input size, output offset, output size
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            // Copy return data to memory at position 0
            returndatacopy(0, 0, returndatasize())
            // Branch based on call result
            switch result
            case 0 { revert(0, returndatasize()) }  // Call failed: revert with return data
            default { return(0, returndatasize()) } // Call succeeded: return with return data
        }
    }
}
