// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title ICrossChainMessenger
/// @dev Interface for cross-chain messaging implementations
interface ICrossChainMessenger {
    /// @dev Returns the fee required to send a message to the destination chain
    function quoteMessageFee(
        uint32 destinationChainId,
        bytes32 recipient,
        bytes calldata message
    )
        external
        view
        returns (uint256 fee);

    /// @dev Sends a message to the destination chain
    /// @return messageId Unique identifier for the sent message
    function sendMessage(
        uint32 destinationChainId,
        bytes32 recipient,
        bytes calldata message
    )
        external
        payable
        returns (bytes32 messageId);
}
