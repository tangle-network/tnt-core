// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @title ICrossChainMessage
/// @notice Defines the structure for cross-chain deposit messages
interface ICrossChainDepositMessage {
    /// @notice Structure for cross-chain asset deposit messages
    struct AssetMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
        bytes delegateData;
    }

    /// @notice Encode an asset message into bytes
    /// @param message The asset message to encode
    /// @return The encoded message
    function encodeMessage(AssetMessage memory message) external pure returns (bytes memory);

    /// @notice Decode bytes into an asset message
    /// @param data The bytes to decode
    /// @return The decoded asset message
    function decodeMessage(bytes memory data) external pure returns (AssetMessage memory);
}
