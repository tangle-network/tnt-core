// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ICrossChainReceiver {
    /// @dev Event emitted when a cross-chain message is received
    event MessageReceived(uint32 originChainId, bytes32 sender, bytes message);

    /// @dev Processes an incoming cross-chain message
    /// @param originChainId The chain ID of the origin chain
    /// @param sender The sender's address (in bytes32 format)
    /// @param message The message payload
    /// @return bytes Any response data
    function handleCrossChainMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata message
    )
        external
        payable
        returns (bytes memory);
}
