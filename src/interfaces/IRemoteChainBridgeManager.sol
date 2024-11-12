// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainMessenger } from "./ICrossChainMessenger.sol";

/// @title IRemoteChainBridgeManager
/// @notice Interface for managing cross-chain message dispatch to Tangle
interface IRemoteChainBridgeManager {
    /// @dev Configuration for a bridge to Tangle
    struct BridgeConfig {
        ICrossChainMessenger messenger;
        uint32 tangleChainId;
        bytes32 tangleRecipient;
        bool isActive;
    }

    /// @dev Emitted when a message is dispatched to Tangle
    event MessageDispatched(uint256 indexed bridgeId, bytes32 indexed messageId, bytes message);

    /// @dev Emitted when a dispatch fails
    event DispatchError(uint256 indexed bridgeId, string reason);

    /// @dev Emitted when a bridge is configured
    event BridgeConfigured(uint256 indexed bridgeId, address messenger, uint32 tangleChainId, bytes32 tangleRecipient);

    /// @notice Configure a bridge for sending messages to Tangle
    /// @param bridgeId The bridge identifier
    /// @param messenger The messenger contract address
    /// @param tangleChainId Tangle's chain ID
    /// @param tangleRecipient Recipient address on Tangle
    function configureBridge(uint256 bridgeId, address messenger, uint32 tangleChainId, bytes32 tangleRecipient) external;

    /// @notice Dispatch a message to Tangle through all configured bridges
    /// @param message The message to dispatch
    function dispatchMessage(bytes calldata message) external payable;

    /// @notice Get the fee required to send a message through a specific bridge
    /// @param bridgeId The bridge to query
    /// @param message The message to send
    /// @return fee The required fee
    function getMessageFee(uint256 bridgeId, bytes calldata message) external view returns (uint256 fee);
}
