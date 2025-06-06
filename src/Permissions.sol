// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Root Chain Enabled
/// @dev This contract defines the root chain address and provides a modifier to restrict access to the root chain
/// @notice This contract is used to restrict access of certain functions to the root chain only.
contract RootChainEnabled {
    /// @notice The address of the root chain
    address public constant ROOT_CHAIN = 0x09dF6A941ee03B1e632904E382e10862fA9cc0e3;
    /// @notice The address of the rewards pallet
    address public constant REWARDS_PALLET = address(0x7e87d5);

    address public masterBlueprintServiceManager;

    /// @notice Error message for unauthorized access
    error OnlyRootChainAllowed(address caller, address rootChain);

    /// @notice Error message for unauthorized access
    error OnlyMasterBlueprintServiceManagerAllowed(address caller, address masterBlueprintServiceManager);

    /// @dev Get the root chain address
    /// @return rootChainAddress The address of the root chain
    function rootChain() external pure returns (address rootChainAddress) {
        return ROOT_CHAIN;
    }

    /// @dev Get the rewards pallet address
    /// @return rewardsPalletAddress The address of the rewards pallet
    function rewardsPallet() external pure returns (address rewardsPalletAddress) {
        return REWARDS_PALLET;
    }

    /// @dev Get the master blueprint service manager address
    /// @return mbsm The address of the master blueprint service manager
    function masterBlueprintServiceManagerAddress() external view returns (address mbsm) {
        return masterBlueprintServiceManager;
    }

    /// @dev Only root chain can call this function
    /// @notice This function can only be called by the root chain
    modifier onlyFromRootChain() {
        if (msg.sender != ROOT_CHAIN) {
            revert OnlyRootChainAllowed(msg.sender, ROOT_CHAIN);
        }
        _;
    }

    /// @dev Only master blueprint service manager can call this function
    /// @notice This function can only be called by the master blueprint service manager
    modifier onlyFromMaster() {
        if (msg.sender != masterBlueprintServiceManager) {
            revert OnlyMasterBlueprintServiceManagerAllowed(msg.sender, masterBlueprintServiceManager);
        }
        _;
    }
}
