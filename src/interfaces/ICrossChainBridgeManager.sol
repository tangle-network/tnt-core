// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { ICrossChainMessenger } from "./ICrossChainMessenger.sol";

/// @title ICrossChainBridgeManager
/// @dev Interface for managing cross-chain bridge configurations and message dispatch
interface ICrossChainBridgeManager {
    /// @dev Struct defining a bridge configuration
    struct BridgeConfig {
        ICrossChainMessenger messenger;
        bool isActive;
        string bridgeName;
    }

    /// @dev Struct defining a chain configuration
    struct ChainConfig {
        uint32 chainId;
        bytes32 recipient;
        bool isActive;
        string chainName;
    }

    /// @dev Emitted when a new bridge is added
    event BridgeAdded(uint256 indexed bridgeId, address messenger, string bridgeName);

    /// @dev Emitted when a bridge is removed
    event BridgeRemoved(uint256 indexed bridgeId);

    /// @dev Emitted when a new chain is added to a bridge
    event ChainAdded(uint256 indexed bridgeId, uint32 chainId, bytes32 recipient, string chainName);

    /// @dev Emitted when a chain is removed from a bridge
    event ChainRemoved(uint256 indexed bridgeId, uint32 chainId);

    /// @dev Emitted when a blueprint contract is authorized
    event BlueprintAuthorized(address indexed blueprint);

    /// @dev Emitted when a blueprint contract is deauthorized
    event BlueprintDeauthorized(address indexed blueprint);

    /// @dev Emitted when a message is successfully dispatched
    event MessageDispatched(
        address indexed sender, uint256 indexed bridgeId, uint32 indexed chainId, bytes32 recipient, bytes32 messageId
    );

    /// @dev Emitted when a message dispatch fails
    event DispatchError(address indexed sender, uint256 indexed bridgeId, uint32 indexed chainId, string reason);

    /// @dev Authorize a blueprint contract to use the bridge manager
    /// @param blueprint Address of the blueprint contract to authorize
    function authorizeBlueprint(address blueprint) external;

    /// @dev Deauthorize a blueprint contract
    /// @param blueprint Address of the blueprint contract to deauthorize
    function deauthorizeBlueprint(address blueprint) external;

    /// @dev Add a new bridge configuration
    /// @param bridgeId Unique identifier for the bridge
    /// @param messenger Address of the messenger contract
    /// @param bridgeName Human-readable name for the bridge
    function addBridge(uint256 bridgeId, address messenger, string calldata bridgeName) external;

    /// @dev Remove a bridge configuration
    /// @param bridgeId ID of the bridge to remove
    function removeBridge(uint256 bridgeId) external;

    /// @dev Add a new chain configuration for a bridge
    /// @param bridgeId ID of the bridge
    /// @param chainId ID of the chain to add
    /// @param recipient Address of the recipient contract on the destination chain
    /// @param chainName Human-readable name for the chain
    function addChain(uint256 bridgeId, uint32 chainId, bytes32 recipient, string calldata chainName) external;

    /// @dev Remove a chain configuration from a bridge
    /// @param bridgeId ID of the bridge
    /// @param chainId ID of the chain to remove
    function removeChain(uint256 bridgeId, uint32 chainId) external;

    /// @dev Get all active bridges
    /// @return bridgeIds Array of active bridge IDs
    /// @return bridgeNames Array of bridge names corresponding to the IDs
    function getActiveBridges() external view returns (uint256[] memory bridgeIds, string[] memory bridgeNames);

    /// @dev Get all active chains for a bridge
    /// @param bridgeId ID of the bridge
    /// @return chainIds Array of chain IDs
    /// @return chainNames Array of chain names
    /// @return recipients Array of recipient addresses
    function getActiveChainsForBridge(uint256 bridgeId)
        external
        view
        returns (uint32[] memory chainIds, string[] memory chainNames, bytes32[] memory recipients);

    /// @dev Dispatch a message to all configured bridges and chains
    /// @param message The message to dispatch
    function dispatchMessage(bytes memory message) external payable;

    /// @dev Query if a blueprint is authorized
    /// @param blueprint Address of the blueprint to check
    /// @return bool True if the blueprint is authorized
    function authorizedBlueprints(address blueprint) external view returns (bool);

    /// @dev Query bridge configuration
    /// @param bridgeId ID of the bridge
    /// @return BridgeConfig Configuration of the bridge
    function get_bridges(uint256 bridgeId) external view returns (BridgeConfig memory);
}
