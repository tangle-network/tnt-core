// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IFacetSelectors } from "../interfaces/IFacetSelectors.sol";

/// @title FacetRouterBase
/// @notice Shared selector router logic for facet-based protocol entrypoints
/// @dev This contract is intentionally stateless so concrete routers can keep
///      their existing storage layouts and authorization policies unchanged.
abstract contract FacetRouterBase {
    event FacetRegistered(address indexed facet);
    event FacetSelectorSet(bytes4 indexed selector, address indexed facet);
    event FacetSelectorCleared(bytes4 indexed selector);

    /// @notice Register selectors exposed by a facet
    function registerFacet(address facet) external {
        _authorizeFacetRegistryChange();
        bytes4[] memory selectorList = IFacetSelectors(facet).selectors();
        _setFacetSelectors(facet, selectorList);
        emit FacetRegistered(facet);
    }

    /// @notice Register specific selectors for a facet
    function registerFacetSelectors(address facet, bytes4[] calldata selectors) external {
        _authorizeFacetRegistryChange();
        _setFacetSelectors(facet, selectors);
    }

    /// @notice Remove selectors from the router
    function clearFacetSelectors(bytes4[] calldata selectors) external {
        _authorizeFacetRegistryChange();
        for (uint256 i = 0; i < selectors.length; i++) {
            _clearFacetForSelector(selectors[i]);
            emit FacetSelectorCleared(selectors[i]);
        }
    }

    /// @notice Resolve the facet for a selector
    function facetForSelector(bytes4 selector) external view returns (address) {
        return _getFacetForSelector(selector);
    }

    function _fallbackToFacet() internal {
        address facet = _getFacetForSelector(msg.sig);
        if (facet == address(0)) _revertUnknownSelector(msg.sig);
        _delegateTo(facet);
    }

    function _setFacetSelectors(address facet, bytes4[] memory selectors) internal {
        if (facet == address(0)) _revertZeroAddress();
        if (facet.code.length == 0) _revertNotAContract(facet);

        for (uint256 i = 0; i < selectors.length; i++) {
            address existing = _getFacetForSelector(selectors[i]);
            if (existing != address(0) && existing != facet) {
                _revertSelectorAlreadyRegistered(selectors[i], existing);
            }
            _setFacetForSelector(selectors[i], facet);
            emit FacetSelectorSet(selectors[i], facet);
        }
    }

    /// @notice Delegate call to target facet using low-level assembly
    /// @dev Assembly is used here for gas efficiency and to properly forward
    ///      all calldata and return data.
    function _delegateTo(address target) internal {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _authorizeFacetRegistryChange() internal view virtual;
    function _getFacetForSelector(bytes4 selector) internal view virtual returns (address);
    function _setFacetForSelector(bytes4 selector, address facet) internal virtual;
    function _clearFacetForSelector(bytes4 selector) internal virtual;
    function _revertZeroAddress() internal pure virtual;
    function _revertNotAContract(address facet) internal view virtual;
    function _revertSelectorAlreadyRegistered(bytes4 selector, address existingFacet) internal pure virtual;
    function _revertUnknownSelector(bytes4 selector) internal pure virtual;
}
