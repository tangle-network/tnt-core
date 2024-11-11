// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ICrossChainAssetVault } from "../../interfaces/ICrossChainAssetVault.sol";
import { AssetDelegationBase } from "../../delegation/AssetDelegationBase.sol";

/// @title CrossChainAssetVault
/// @notice Vault for both native and synthetic crofss-chain assets with delegation capabilities
contract CrossChainAssetVault is ICrossChainAssetVault, AssetDelegationBase {
    /// @dev Maps synthetic assets to their origin information
    mapping(address => CrossChainAsset) public crossChainAssets;

    /// @inheritdoc ICrossChainAssetVault
    function registerCrossChainAsset(address syntheticAsset, uint32 originChainId, address originAsset) public returns (bool) {
        if (!crossChainAssets[syntheticAsset].isRegistered) {
            crossChainAssets[syntheticAsset] =
                CrossChainAsset({ originChainId: originChainId, originAsset: originAsset, isRegistered: true });
            emit AssetRegistered(syntheticAsset, originChainId, originAsset);
        }
        return true;
    }

    /// @inheritdoc ICrossChainAssetVault
    function deposit(address asset, uint256 amount) external returns (bool) {
        require(amount > 0, "Invalid amount");
        require(IERC20(asset).transferFrom(msg.sender, address(this), amount), "Transfer failed");
        emit AssetDeposited(asset, msg.sender, amount);
        return true;
    }

    /// @inheritdoc ICrossChainAssetVault
    function validateWithdrawal(address asset) external returns (bool) {
        if (crossChainAssets[asset].isRegistered) {
            emit WithdrawalBlocked(asset, msg.sender);
            return false;
        }
        return true;
    }

    /// @inheritdoc ICrossChainAssetVault
    function isCrossChainAsset(address asset) public view override returns (bool) {
        return crossChainAssets[asset].isRegistered;
    }

    /// @notice Handle incoming Hyperlane token transfer
    /// @dev Automatically called by Hyperlane's token bridge
    function onERC20Received(
        uint32 _origin,
        bytes32 _sender,
        address _token,
        uint256 _amount,
        bytes calldata _data
    )
        external
        returns (bytes4)
    {
        registerCrossChainAsset(_token, _origin, address(uint160(uint256(_sender))));

        if (_data.length > 0) {
            handleDelegation(_token, _amount, _data);
        }

        return this.onERC20Received.selector;
    }

    /// @notice Handle incoming Router Protocol token transfer
    /// @dev Called by Router's bridge contract
    function handleMessage(address tokenSent, uint256 amount, bytes memory message) external {
        (uint32 originChainId, address originAsset, bytes memory delegateData) = abi.decode(message, (uint32, address, bytes));

        registerCrossChainAsset(tokenSent, originChainId, originAsset);

        if (delegateData.length > 0) {
            handleDelegation(tokenSent, amount, delegateData);
        }
    }
}
