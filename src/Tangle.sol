// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./core/Base.sol";
import { FacetRouterBase } from "./facets/FacetRouterBase.sol";
import { Errors } from "./libraries/Errors.sol";

/// @title Tangle
/// @notice Router contract that dispatches calls to protocol facets
contract Tangle is Base, FacetRouterBase {
    /// @notice Initialize the contract
    function initialize(address admin, address staking_, address payable treasury_) external initializer {
        __Base_init(admin, staking_, treasury_);
    }

    function _authorizeFacetRegistryChange() internal view override onlyRole(UPGRADER_ROLE) { }

    function _getFacetForSelector(bytes4 selector) internal view override returns (address) {
        return _facetForSelector[selector];
    }

    function _setFacetForSelector(bytes4 selector, address facet) internal override {
        _facetForSelector[selector] = facet;
    }

    function _clearFacetForSelector(bytes4 selector) internal override {
        delete _facetForSelector[selector];
    }

    function _revertZeroAddress() internal pure override {
        revert Errors.ZeroAddress();
    }

    function _revertNotAContract(address facet) internal pure override {
        revert Errors.NotAContract(facet);
    }

    function _revertSelectorAlreadyRegistered(bytes4 selector, address existingFacet) internal pure override {
        revert Errors.SelectorAlreadyRegistered(selector, existingFacet);
    }

    fallback() external payable {
        _fallbackToFacet();
    }

    function _revertUnknownSelector(bytes4 selector) internal pure override {
        revert Errors.UnknownSelector(selector);
    }
}
