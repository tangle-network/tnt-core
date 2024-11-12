// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IRemoteChainBridgeManager } from "../interfaces/IRemoteChainBridgeManager.sol";
import { ICrossChainDepositMessage } from "../interfaces/ICrossChainDepositMessage.sol";
import { CrossChainDepositMessage } from "../libs/CrossChainDepositMessage.sol";

/// @title RemoteRestakeVault
/// @notice Custodies any ERC20 assets and dispatches cross-chain messages for restaking on Tangle
contract RemoteRestakeVault {
    using SafeERC20 for IERC20;
    using CrossChainDepositMessage for ICrossChainDepositMessage.AssetMessage;

    /// @notice Bridge manager for sending messages to Tangle
    IRemoteChainBridgeManager public immutable bridgeManager;

    error InvalidBridgeManager();
    error InvalidAmount();
    error InvalidToken();
    error BridgeDispatchFailed();

    event AssetLocked(address indexed token, address indexed sender, uint256 amount, bytes delegateData);

    event AssetUnlocked(address indexed token, address indexed recipient, uint256 amount);

    constructor(address _bridgeManager) {
        if (_bridgeManager == address(0)) revert InvalidBridgeManager();
        bridgeManager = IRemoteChainBridgeManager(_bridgeManager);
    }

    /// @notice Lock tokens and dispatch restaking message to Tangle
    /// @param token The ERC20 token to lock
    /// @param amount Amount of tokens to lock
    /// @param delegateData Optional delegation instructions for Tangle
    /// @param bridgeId Specific bridge to use (optional, 0 for any bridge)
    function lockAndDelegate(address token, uint256 amount, bytes calldata delegateData, uint256 bridgeId) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        // Transfer tokens to vault using SafeERC20
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        // Create cross-chain deposit message
        ICrossChainDepositMessage.AssetMessage memory message = ICrossChainDepositMessage.AssetMessage({
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            bridgeId: bridgeId,
            delegateData: delegateData
        });

        // Get required fee if specific bridge is requested
        uint256 requiredFee = bridgeId != 0 ? bridgeManager.getMessageFee(bridgeId, message.encode()) : msg.value;

        // Dispatch through bridge manager
        try bridgeManager.dispatchMessage{ value: requiredFee }(message.encode()) {
            emit AssetLocked(token, msg.sender, amount, delegateData);
        } catch {
            // If bridge dispatch fails, revert the token transfer
            IERC20(token).safeTransfer(msg.sender, amount);
            revert BridgeDispatchFailed();
        }
    }

    /// @notice Process unlock request from Tangle
    /// @dev Only callable by authorized bridge adapters
    /// @param token The token to unlock
    /// @param recipient The recipient of the unlocked tokens
    /// @param amount Amount to unlock
    function processUnlock(address token, address recipient, uint256 amount) external {
        // TODO: Add bridge adapter authorization
        if (amount == 0) revert InvalidAmount();
        IERC20(token).safeTransfer(recipient, amount);

        emit AssetUnlocked(token, recipient, amount);
    }

    /// @notice Get the required fee for using a specific bridge
    /// @param token The token to lock
    /// @param amount Amount of tokens
    /// @param delegateData Delegation instructions
    /// @param bridgeId The bridge to use
    /// @return fee The required fee in native currency
    function getRequiredFee(
        address token,
        uint256 amount,
        bytes calldata delegateData,
        uint256 bridgeId
    )
        external
        view
        returns (uint256)
    {
        ICrossChainDepositMessage.AssetMessage memory message = ICrossChainDepositMessage.AssetMessage({
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            bridgeId: bridgeId,
            delegateData: delegateData
        });

        return bridgeManager.getMessageFee(bridgeId, message.encode());
    }

    /// @notice Emergency function to recover stuck tokens
    /// @param token The token to recover
    /// @param amount Amount to recover
    function recoverTokens(address token, uint256 amount) external {
        // TODO: Add owner/governance check
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}
