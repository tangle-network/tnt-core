// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ICrossChainMessenger
/// @notice Abstract interface for cross-chain message passing
/// @dev Implement this for different bridges: Base, Arbitrum, Tempo, LayerZero, Axelar, etc.
interface ICrossChainMessenger {
    /// @notice Send a message to another chain
    /// @param destinationChainId The target chain ID
    /// @param target The target contract address on the destination chain
    /// @param payload The encoded message data
    /// @param gasLimit Gas limit for execution on destination (if applicable)
    /// @return messageId Unique identifier for tracking the message
    function sendMessage(
        uint256 destinationChainId,
        address target,
        bytes calldata payload,
        uint256 gasLimit
    )
        external
        payable
        returns (bytes32 messageId);

    /// @notice Estimate the fee for sending a message
    /// @param destinationChainId The target chain ID
    /// @param payload The encoded message data
    /// @param gasLimit Gas limit for execution on destination
    /// @return fee The estimated fee in native currency
    function estimateFee(
        uint256 destinationChainId,
        bytes calldata payload,
        uint256 gasLimit
    )
        external
        view
        returns (uint256 fee);

    /// @notice Check if a destination chain is supported
    /// @param chainId The chain ID to check
    /// @return supported True if the chain is supported
    function isChainSupported(uint256 chainId) external view returns (bool supported);
}

/// @title ICrossChainReceiver
/// @notice Interface for contracts that receive cross-chain messages
interface ICrossChainReceiver {
    /// @notice Handle an incoming cross-chain message
    /// @param sourceChainId The chain ID where the message originated
    /// @param sender The sender address on the source chain
    /// @param payload The message payload
    function receiveMessage(uint256 sourceChainId, address sender, bytes calldata payload) external;
}
