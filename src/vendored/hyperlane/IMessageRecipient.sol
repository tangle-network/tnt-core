// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.19;

/// @title IMessageRecipient Interface
/// @notice Interface for contracts that can receive interchain messages via Hyperlane
/// @dev Implement this interface to enable your contract to process messages from other chains
interface IMessageRecipient {
    /// @notice Handle an interchain message
    /// @param _origin Domain of origin chain
    /// @param _sender Address of sender on origin chain as bytes32
    /// @param _message Raw bytes content of message body
    /// @return bytes Response bytes
    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable returns (bytes memory);
}
