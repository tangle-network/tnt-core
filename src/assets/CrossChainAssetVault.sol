// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ICrossChainAssetVault } from "../interfaces/ICrossChainAssetVault.sol";
import { ICrossChainReceiver } from "../interfaces/ICrossChainReceiver.sol";
import { ICrossChainDepositMessage } from "../interfaces/ICrossChainDepositMessage.sol";
import { CrossChainDepositMessage } from "../libs/CrossChainDepositMessage.sol";
import { AssetDelegationBase } from "../delegation/AssetDelegationBase.sol";
import { SyntheticRestakeAsset } from "./SyntheticRestakeAsset.sol";

/// @title CrossChainAssetVault
/// @notice Vault that mints synthetic assets based on cross-chain messages
contract CrossChainAssetVault is ICrossChainAssetVault, ICrossChainReceiver, AssetDelegationBase {
    using CrossChainDepositMessage for bytes;

    /// @dev Maps origin chain+asset to synthetic asset
    mapping(uint32 => mapping(uint256 => address)) public syntheticAssets;
    mapping(address => CrossChainAsset) public crossChainAssets;
    mapping(address => bool) public authorizedAdapters;

    error UnauthorizedAdapter(address adapter);
    error InvalidAsset(address asset);
    error InvalidAmount(uint256 amount);
    error WithdrawalBlocked(address asset);
    error TransferFailed();
    error ZeroAddress();

    event AssetDeposited(address indexed asset, address indexed depositor, uint256 amount);
    event AssetWithdrawn(address indexed asset, address indexed to, uint256 amount);

    modifier onlyAuthorizedAdapter() {
        if (!authorizedAdapters[msg.sender]) revert UnauthorizedAdapter(msg.sender);
        _;
    }

    function handleCrossChainMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata message
    )
        external
        payable
        onlyAuthorizedAdapter
        returns (bytes memory)
    {
        emit MessageReceived(originChainId, sender, message);

        ICrossChainDepositMessage.AssetMessage memory asset_message = message.decode();
        emit CrossChainAssetDeposited(asset_message.originAsset, asset_message.sender, asset_message.amount);
        // Get or create synthetic asset
        address syntheticAsset = getOrCreateSyntheticAsset(originChainId, asset_message.originAsset, asset_message.bridgeId);

        // Mint synthetic tokens
        SyntheticRestakeAsset(syntheticAsset).mint(address(this), asset_message.amount);

        // Handle delegation if requested
        if (asset_message.delegateData.length > 0) {
            handleDelegation(syntheticAsset, asset_message.amount, asset_message.delegateData);
        }

        return abi.encode(true);
    }

    /// @notice Gets existing or creates new synthetic asset
    /// @param originChainId The origin chain ID
    /// @param originAsset The original asset address
    /// @param bridgeId The bridge identifier
    /// @return address The synthetic asset address
    function getOrCreateSyntheticAsset(uint32 originChainId, uint256 originAsset, uint256 bridgeId) internal returns (address) {
        address synthetic = syntheticAssets[originChainId][originAsset];

        if (synthetic == address(0)) {
            // Create new synthetic asset
            string memory name = string(abi.encodePacked("Synthetic Restake ", originAsset));
            string memory symbol = string(abi.encodePacked("sr", originAsset));

            synthetic = address(new SyntheticRestakeAsset(name, symbol, originChainId, originAsset, bridgeId));

            syntheticAssets[originChainId][originAsset] = synthetic;
            emit CrossChainAssetRegistered(synthetic, originChainId, originAsset, bridgeId);
        }

        return synthetic;
    }

    function deposit(address asset, uint256 amount) external returns (bool) {
        if (amount == 0) revert InvalidAmount(amount);
        if (isCrossChainAsset(asset)) revert InvalidAsset(asset);
        if (!IERC20(asset).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();
        emit AssetDeposited(asset, msg.sender, amount);
        return true;
    }

    function withdraw(address asset, address to, uint256 amount) external returns (bool) {
        if (amount == 0) revert InvalidAmount(amount);
        if (isCrossChainAsset(asset)) revert InvalidAsset(asset);
        if (!IERC20(asset).transfer(to, amount)) revert TransferFailed();
        emit AssetWithdrawn(asset, to, amount);
        return true;
    }

    /// @inheritdoc ICrossChainAssetVault
    function isCrossChainAsset(address asset) public view override returns (bool) {
        // Check if this is a SyntheticRestakeAsset by checking if it was deployed by us
        try SyntheticRestakeAsset(asset).vault() returns (address vault) {
            return vault == address(this);
        } catch {
            return false;
        }
    }

    /// @inheritdoc ICrossChainAssetVault
    function authorizeAdapter(address adapter) external {
        if (adapter == address(0)) revert ZeroAddress();
        authorizedAdapters[adapter] = true;
        emit AdapterAuthorized(adapter);
    }

    function unauthorizeAdapter(address adapter) external {
        authorizedAdapters[adapter] = false;
        emit AdapterUnauthorized(adapter);
    }
}
