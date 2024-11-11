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

interface ICrossChainAssetReceiver {
    /// @notice Event emitted when a cross-chain asset is received
    event AssetReceived(uint256 indexed assetId, uint32 originChainId, address originAsset, uint256 amount);

    /// @notice Receive a cross-chain asset from any supported bridge
    /// @param assetId The ID of the asset on Tangle
    /// @param originChainId The chain ID where the asset originated
    /// @param originAsset The address of the original asset
    /// @param amount The amount of the asset received
    /// @param data Additional data specific to the asset transfer
    function receiveAsset(
        uint256 assetId,
        uint32 originChainId,
        address originAsset,
        uint256 amount,
        bytes calldata data
    )
        external
        returns (bool);
}
