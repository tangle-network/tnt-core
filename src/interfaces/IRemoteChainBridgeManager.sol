// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { ICrossChainMessenger } from "./ICrossChainMessenger.sol";

/// @title IRemoteChainBridgeManager
/// @notice Interface for managing cross-chain message dispatch to Tangle
interface IRemoteChainBridgeManager {
    /// @dev Emitted when a message is dispatched to Tangle
    event MessageDispatched(uint256 indexed bridgeId, bytes32 indexed messageId, bytes message);

    /// @dev Emitted when a dispatch fails
    event DispatchError(uint256 indexed bridgeId, string reason);

    /// @dev Emitted when a bridge is configured
    event BridgeConfigured(uint256 indexed bridgeId, address messenger, uint32 tangleChainId, bytes32 adapter);

    /// @notice Dispatch a message to Tangle through all configured bridges
    /// @param message The message to dispatch
    function dispatchMessage(bytes calldata message) external payable;

    /// @notice Get the fee required to send a message through a specific bridge
    /// @param message The message to send
    /// @return fee The required fee
    function getMessageFee(bytes calldata message) external view returns (uint256 fee);
}
