// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @title Root Chain Enabled
/// @dev This contract defines the root chain address and provides a modifier to restrict access to the root chain
/// @notice This contract is used to restrict access of certain functions to the root chain only.
contract RootChainEnabled {
    /// @notice The address of the root chain
    address public constant ROOT_CHAIN = 0x1111111111111111111111111111111111111111;

    /// @dev Get the root chain address
    /// @return rootChainAddress The address of the root chain
    function rootChain() external pure returns (address rootChainAddress) {
        return ROOT_CHAIN;
    }

    /// @dev Only root chain can call this function
    /// @notice This function can only be called by the root chain
    modifier onlyFromRootChain() {
        require(msg.sender == ROOT_CHAIN, "RootChain: Only root chain can call this function");
        _;
    }
}
