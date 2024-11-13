// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AssetDelegator } from "./AssetDelegator.sol";

/// @title AssetVault
/// @notice Base vault for handling ERC20 asset deposits and withdrawals
abstract contract AssetVault is AssetDelegator {
    using SafeERC20 for IERC20;

    error InvalidAmount();
    error InvalidAsset(address asset);
    error TransferFailed();

    event AssetDeposited(address indexed asset, address indexed from, uint256 amount);
    event AssetWithdrawn(address indexed asset, address indexed to, uint256 amount);

    /// @notice Check if an asset is a cross-chain asset
    ///         This is useful for preventing the withdrawal or deposit
    ///         of cross-chain assets in the base vault contract
    /// @param asset The asset to check
    /// @return bool True if the asset is a cross-chain asset
    function isCrossChainAsset(address asset) internal view virtual returns (bool);

    function depositERC20(address asset, uint256 amount) external returns (bool) {
        if (amount == 0) revert InvalidAmount();
        if (isCrossChainAsset(asset)) revert InvalidAsset(asset);
        if (!IERC20(asset).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        emit AssetDeposited(asset, msg.sender, amount);
        return true;
    }

    function withdrawERC20(address asset, address to, uint256 amount) external returns (bool) {
        if (amount == 0) revert InvalidAmount();
        if (isCrossChainAsset(asset)) revert InvalidAsset(asset);
        if (!IERC20(asset).transfer(to, amount)) revert TransferFailed();
        emit AssetWithdrawn(asset, to, amount);
        return true;
    }
}
