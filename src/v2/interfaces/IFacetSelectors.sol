// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IFacetSelectors
/// @notice Standard interface for facet selector discovery
interface IFacetSelectors {
    /// @notice Return the selectors this facet wants registered
    function selectors() external pure returns (bytes4[] memory);
}
