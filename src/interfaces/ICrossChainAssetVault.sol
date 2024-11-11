// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @title ICrossChainAssetVault
/// @notice Interface for vault that handles both native and cross-chain assets
interface ICrossChainAssetVault {
    struct CrossChainAsset {
        uint32 originChainId;
        address originAsset;
        bool isRegistered;
    }

    event AssetRegistered(address indexed syntheticAsset, uint32 chainId, address originAsset);
    event AssetDeposited(address indexed asset, address indexed depositor, uint256 amount);
    event WithdrawalBlocked(address indexed syntheticAsset, address indexed caller);

    /// @notice Register a synthetic cross-chain asset
    function registerCrossChainAsset(address syntheticAsset, uint32 originChainId, address originAsset) external returns (bool);

    /// @notice Deposit native Tangle ERC20s
    function deposit(address asset, uint256 amount) external returns (bool);

    /// @notice Check if withdrawal is allowed
    function validateWithdrawal(address asset) external returns (bool);

    /// @notice Check if asset is cross-chain
    function isCrossChainAsset(address asset) external view returns (bool);
}
