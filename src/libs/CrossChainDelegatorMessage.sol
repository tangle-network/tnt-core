// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainDelegatorMessage } from "../interfaces/ICrossChainDelegatorMessage.sol";

/// @title CrossChainDelegatorMessage
/// @notice Library for handling cross-chain message encoding/decoding
library CrossChainDelegatorMessage {
    // Message type constants for initial operations
    uint8 constant DEPOSIT_MESSAGE = 1;
    uint8 constant DELEGATION_MESSAGE = 2;

    // Message type constants for unstaking flow
    uint8 constant SCHEDULE_UNSTAKE_MESSAGE = 3;
    uint8 constant CANCEL_UNSTAKE_MESSAGE = 4;
    uint8 constant EXECUTE_UNSTAKE_MESSAGE = 5;

    // Message type constants for withdrawal flow
    uint8 constant SCHEDULE_WITHDRAWAL_MESSAGE = 6;
    uint8 constant CANCEL_WITHDRAWAL_MESSAGE = 7;
    uint8 constant EXECUTE_WITHDRAWAL_MESSAGE = 8;

    error InvalidMessageType();
    error EmptyMessage();

    /// @notice Get the message type from encoded data
    /// @param data The encoded message
    /// @return The message type identifier
    function getMessageType(bytes calldata data) internal pure returns (uint8) {
        if (data.length == 0) revert EmptyMessage();
        return uint8(data[0]);
    }

    /// @notice Encode a deposit message
    /// @param message The deposit message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.DepositMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(DEPOSIT_MESSAGE, encoded);
    }

    /// @notice Decode a deposit message
    /// @param data The encoded message
    /// @return The decoded deposit message
    function decodeDepositMessage(bytes calldata data) internal pure returns (ICrossChainDelegatorMessage.DepositMessage memory) {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != DEPOSIT_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.DepositMessage));
    }

    /// @notice Encode a delegation message
    /// @param message The delegation message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.DelegationMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(DELEGATION_MESSAGE, encoded);
    }

    /// @notice Decode a delegation message
    /// @param data The encoded message
    /// @return The decoded delegation message
    function decodeDelegationMessage(bytes calldata data)
        internal
        pure
        returns (ICrossChainDelegatorMessage.DelegationMessage memory)
    {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != DELEGATION_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.DelegationMessage));
    }

    /// @notice Encode a schedule unstake message
    /// @param message The schedule unstake message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.ScheduleUnstakeMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(SCHEDULE_UNSTAKE_MESSAGE, encoded);
    }

    /// @notice Decode a schedule unstake message
    /// @param data The encoded message
    /// @return The decoded schedule unstake message
    function decodeScheduleUnstakeMessage(bytes calldata data)
        internal
        pure
        returns (ICrossChainDelegatorMessage.ScheduleUnstakeMessage memory)
    {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != SCHEDULE_UNSTAKE_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.ScheduleUnstakeMessage));
    }

    /// @notice Encode a cancel unstake message
    /// @param message The cancel unstake message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.CancelUnstakeMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(CANCEL_UNSTAKE_MESSAGE, encoded);
    }

    /// @notice Decode a cancel unstake message
    /// @param data The encoded message
    /// @return The decoded cancel unstake message
    function decodeCancelUnstakeMessage(bytes calldata data)
        internal
        pure
        returns (ICrossChainDelegatorMessage.CancelUnstakeMessage memory)
    {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != CANCEL_UNSTAKE_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.CancelUnstakeMessage));
    }

    /// @notice Encode an execute unstake message
    /// @param message The execute unstake message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.ExecuteUnstakeMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(EXECUTE_UNSTAKE_MESSAGE, encoded);
    }

    /// @notice Decode an execute unstake message
    /// @param data The encoded message
    /// @return The decoded execute unstake message
    function decodeExecuteUnstakeMessage(bytes calldata data)
        internal
        pure
        returns (ICrossChainDelegatorMessage.ExecuteUnstakeMessage memory)
    {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != EXECUTE_UNSTAKE_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.ExecuteUnstakeMessage));
    }

    /// @notice Encode a schedule withdrawal message
    /// @param message The schedule withdrawal message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.ScheduleWithdrawalMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(SCHEDULE_WITHDRAWAL_MESSAGE, encoded);
    }

    /// @notice Decode a schedule withdrawal message
    /// @param data The encoded message
    /// @return The decoded schedule withdrawal message
    function decodeScheduleWithdrawalMessage(bytes calldata data)
        internal
        pure
        returns (ICrossChainDelegatorMessage.ScheduleWithdrawalMessage memory)
    {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != SCHEDULE_WITHDRAWAL_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.ScheduleWithdrawalMessage));
    }

    /// @notice Encode a cancel withdrawal message
    /// @param message The cancel withdrawal message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.CancelWithdrawalMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(CANCEL_WITHDRAWAL_MESSAGE, encoded);
    }

    /// @notice Decode a cancel withdrawal message
    /// @param data The encoded message
    /// @return The decoded cancel withdrawal message
    function decodeCancelWithdrawalMessage(bytes calldata data)
        internal
        pure
        returns (ICrossChainDelegatorMessage.CancelWithdrawalMessage memory)
    {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != CANCEL_WITHDRAWAL_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.CancelWithdrawalMessage));
    }

    /// @notice Encode an execute withdrawal message
    /// @param message The execute withdrawal message to encode
    /// @return The encoded message with type prefix
    function encode(ICrossChainDelegatorMessage.ExecuteWithdrawalMessage memory message) internal pure returns (bytes memory) {
        bytes memory encoded = abi.encode(message);
        return abi.encodePacked(EXECUTE_WITHDRAWAL_MESSAGE, encoded);
    }

    /// @notice Decode an execute withdrawal message
    /// @param data The encoded message
    /// @return The decoded execute withdrawal message
    function decodeExecuteWithdrawalMessage(bytes calldata data)
        internal
        pure
        returns (ICrossChainDelegatorMessage.ExecuteWithdrawalMessage memory)
    {
        if (data.length == 0) revert EmptyMessage();
        if (uint8(data[0]) != EXECUTE_WITHDRAWAL_MESSAGE) revert InvalidMessageType();
        return abi.decode(data[1:], (ICrossChainDelegatorMessage.ExecuteWithdrawalMessage));
    }

    /// @notice Convert a bytes32 to an address
    /// @param _buf The bytes32 to convert
    /// @return The resulting address
    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }
}
