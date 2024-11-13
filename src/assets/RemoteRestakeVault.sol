// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IRemoteChainBridgeManager } from "../interfaces/IRemoteChainBridgeManager.sol";
import { ICrossChainDelegatorMessage } from "../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../libs/CrossChainDelegatorMessage.sol";

contract RemoteRestakeVault {
    using SafeERC20 for IERC20;
    using CrossChainDelegatorMessage for *;

    IRemoteChainBridgeManager public immutable bridgeManager;

    error InvalidBridgeManager();
    error InvalidAmount();
    error InvalidToken();
    error BridgeDispatchFailed();

    event AssetDeposited(address indexed token, address indexed sender, uint256 amount);

    event DelegationUpdated(address indexed token, address indexed sender, uint256 amount, bytes32 operator);

    event UnstakeScheduled(address indexed token, address indexed sender, uint256 amount);

    event UnstakeCancelled(address indexed token, address indexed sender, uint256 amount);

    event UnstakeExecuted(address indexed token, address indexed sender, uint256 amount, address recipient);

    event WithdrawalScheduled(address indexed token, address indexed sender, uint256 amount);

    event WithdrawalCancelled(address indexed token, address indexed sender, uint256 amount);

    event WithdrawalExecuted(address indexed token, address indexed sender, address indexed recipient, uint256 amount);

    constructor(address _bridgeManager) {
        if (_bridgeManager == address(0)) revert InvalidBridgeManager();
        bridgeManager = IRemoteChainBridgeManager(_bridgeManager);
    }

    function deposit(address token, uint256 amount, uint256 bridgeId) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        ICrossChainDelegatorMessage.DepositMessage memory message = ICrossChainDelegatorMessage.DepositMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender)))
        });

        _dispatchMessage(bridgeId, message.encode());
        emit AssetDeposited(token, msg.sender, amount);
    }

    function delegate(address token, uint256 amount, uint256 bridgeId, bytes32 operator) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        ICrossChainDelegatorMessage.DelegationMessage memory message = ICrossChainDelegatorMessage.DelegationMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _dispatchMessage(bridgeId, message.encode());
        emit DelegationUpdated(token, msg.sender, amount, operator);
    }

    function scheduleUnstake(address token, uint256 amount, uint256 bridgeId, bytes32 operator) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        ICrossChainDelegatorMessage.ScheduleUnstakeMessage memory message = ICrossChainDelegatorMessage.ScheduleUnstakeMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _dispatchMessage(bridgeId, message.encode());
        emit UnstakeScheduled(token, msg.sender, amount);
    }

    function cancelUnstake(address token, uint256 amount, uint256 bridgeId, bytes32 operator) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        ICrossChainDelegatorMessage.CancelUnstakeMessage memory message = ICrossChainDelegatorMessage.CancelUnstakeMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _dispatchMessage(bridgeId, message.encode());
        emit UnstakeCancelled(token, msg.sender, amount);
    }

    function executeUnstake(
        address token,
        uint256 amount,
        address recipient,
        uint256 bridgeId,
        bytes32 operator
    )
        external
        payable
    {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        ICrossChainDelegatorMessage.ExecuteUnstakeMessage memory message = ICrossChainDelegatorMessage.ExecuteUnstakeMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _dispatchMessage(bridgeId, message.encode());
        emit UnstakeExecuted(token, msg.sender, amount, recipient);
    }

    function scheduleWithdrawal(address token, uint256 amount, uint256 bridgeId) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        ICrossChainDelegatorMessage.ScheduleWithdrawalMessage memory message = ICrossChainDelegatorMessage.ScheduleWithdrawalMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender)))
        });

        _dispatchMessage(bridgeId, message.encode());
        emit WithdrawalScheduled(token, msg.sender, amount);
    }

    function cancelWithdrawal(address token, uint256 amount, address recipient, uint256 bridgeId) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        ICrossChainDelegatorMessage.CancelWithdrawalMessage memory message = ICrossChainDelegatorMessage.CancelWithdrawalMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender)))
        });

        _dispatchMessage(bridgeId, message.encode());
        emit WithdrawalCancelled(token, msg.sender, amount);
    }

    function executeWithdrawal(address token, uint256 amount, address recipient, uint256 bridgeId) external payable {
        if (token == address(0)) revert InvalidToken();
        if (amount == 0) revert InvalidAmount();

        ICrossChainDelegatorMessage.ExecuteWithdrawalMessage memory message = ICrossChainDelegatorMessage.ExecuteWithdrawalMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            recipient: bytes32(uint256(uint160(recipient)))
        });

        _dispatchMessage(bridgeId, message.encode());
        emit WithdrawalExecuted(token, msg.sender, recipient, amount);
    }

    function getRequiredFee(uint256 bridgeId, bytes calldata message) external view returns (uint256) {
        return bridgeManager.getMessageFee(bridgeId, message);
    }

    function _dispatchMessage(uint256 bridgeId, bytes memory message) internal {
        uint256 requiredFee = bridgeId != 0 ? bridgeManager.getMessageFee(bridgeId, message) : msg.value;

        try bridgeManager.dispatchMessage{ value: requiredFee }(message) {
            // Success case handled by events
        } catch {
            revert BridgeDispatchFailed();
        }
    }

    function recoverTokens(address token, uint256 amount) external {
        // TODO: Add owner/governance check
        IERC20(token).safeTransfer(msg.sender, amount);
    }
}