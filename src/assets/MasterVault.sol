// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { GlacisClientCalldata } from "../cross_chain/GlacisClientCalldata.sol";
import { IMasterVault } from "../interfaces/IMasterVault.sol";
import { ICrossChainBridgeManager } from "../interfaces/ICrossChainBridgeManager.sol";
import { ICrossChainDelegatorMessage } from "../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../libs/CrossChainDelegatorMessage.sol";
import { SyntheticRestakeAsset } from "./SyntheticRestakeAsset.sol";
import { UserVault } from "./UserVault.sol";

contract MasterVault is IMasterVault, GlacisClientCalldata {
    using CrossChainDelegatorMessage for *;

    ICrossChainBridgeManager public immutable bridgeManager;

    mapping(uint32 => mapping(uint256 => address)) public syntheticAssets;
    mapping(address => bool) public authorizedAdapters;
    mapping(bytes32 => address) public userVaults;

    error InvalidMessage();
    error BridgeDispatchFailed();

    event SyntheticAssetCreated(
        address indexed syntheticAsset, uint32 indexed originChainId, uint256 indexed originAsset, uint256 bridgeId
    );

    constructor(address _bridgeManager, address _glacisRouter, uint256 _quorum) GlacisClientCalldata(_glacisRouter, _quorum) {
        require(_bridgeManager != address(0), "Invalid bridge manager");
        bridgeManager = ICrossChainBridgeManager(_bridgeManager);
    }

    function _getOrCreateUserVault(bytes32 sender) internal returns (address vault) {
        vault = userVaults[sender];
        if (vault == address(0)) {
            vault = address(new UserVault(sender, address(this)));
            userVaults[sender] = vault;
        }
        return vault;
    }

    function _receiveMessage(
        address[] memory,
        uint256 fromChainId,
        bytes32 fromAddress,
        bytes calldata message
    ) internal override {
        uint8 messageType = CrossChainDelegatorMessage.getMessageType(message);
        bytes calldata payload = message[1:];

        if (messageType == CrossChainDelegatorMessage.DEPOSIT_MESSAGE) {
            _handleDepositMessage(uint32(fromChainId), fromAddress, payload);
        } else if (messageType == CrossChainDelegatorMessage.DELEGATION_MESSAGE) {
            _handleDelegationMessage(uint32(fromChainId), fromAddress, payload);
        } else if (messageType == CrossChainDelegatorMessage.SCHEDULE_UNSTAKE_MESSAGE) {
            _handleScheduleUnstakeMessage(uint32(fromChainId), fromAddress, payload);
        } else if (messageType == CrossChainDelegatorMessage.CANCEL_UNSTAKE_MESSAGE) {
            _handleCancelUnstakeMessage(uint32(fromChainId), fromAddress, payload);
        } else if (messageType == CrossChainDelegatorMessage.EXECUTE_UNSTAKE_MESSAGE) {
            _handleExecuteUnstakeMessage(uint32(fromChainId), fromAddress, payload);
        } else if (messageType == CrossChainDelegatorMessage.SCHEDULE_WITHDRAWAL_MESSAGE) {
            _handleScheduleWithdrawalMessage(uint32(fromChainId), fromAddress, payload);
        } else if (messageType == CrossChainDelegatorMessage.CANCEL_WITHDRAWAL_MESSAGE) {
            _handleCancelWithdrawalMessage(uint32(fromChainId), fromAddress, payload);
        } else if (messageType == CrossChainDelegatorMessage.EXECUTE_WITHDRAWAL_MESSAGE) {
            _handleExecuteWithdrawalMessage(uint32(fromChainId), fromAddress, payload);
        }

        revert InvalidMessage();
    }

    function _handleDepositMessage(uint32 originChainId, bytes32 sender, bytes calldata payload) internal returns (bytes memory) {
        ICrossChainDelegatorMessage.DepositMessage memory message = CrossChainDelegatorMessage.decodeDepositMessage(payload);

        address syntheticAsset = getOrCreateSyntheticAsset(originChainId, message.originAsset, message.bridgeId);
        address userVault = _getOrCreateUserVault(message.sender);

        // Mint directly to user vault
        SyntheticRestakeAsset(syntheticAsset).mint(userVault, message.amount);
        UserVault(userVault).restakingDeposit(syntheticAsset, message.amount);

        return abi.encode(true);
    }

    function _handleDelegationMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata payload
    )
        internal
        returns (bytes memory)
    {
        ICrossChainDelegatorMessage.DelegationMessage memory message = CrossChainDelegatorMessage.decodeDelegationMessage(payload);

        address syntheticAsset = syntheticAssets[originChainId][message.originAsset];
        if (syntheticAsset == address(0)) revert InvalidAsset(address(0));

        address userVault = _getOrCreateUserVault(message.sender);
        UserVault(userVault).restakingDelegate(syntheticAsset, message.amount, message.operator);

        return abi.encode(true);
    }

    function _handleScheduleUnstakeMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata payload
    )
        internal
        returns (bytes memory)
    {
        ICrossChainDelegatorMessage.ScheduleUnstakeMessage memory message =
            CrossChainDelegatorMessage.decodeScheduleUnstakeMessage(payload);

        address syntheticAsset = syntheticAssets[originChainId][message.originAsset];
        if (syntheticAsset == address(0)) revert InvalidAsset(address(0));

        address userVault = _getOrCreateUserVault(message.sender);
        UserVault(userVault).restakingScheduleUnstake(syntheticAsset, message.amount, message.operator);

        return abi.encode(true);
    }

    function _handleCancelUnstakeMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata payload
    )
        internal
        returns (bytes memory)
    {
        ICrossChainDelegatorMessage.CancelUnstakeMessage memory message =
            CrossChainDelegatorMessage.decodeCancelUnstakeMessage(payload);

        address syntheticAsset = syntheticAssets[originChainId][message.originAsset];
        if (syntheticAsset == address(0)) revert InvalidAsset(address(0));

        address userVault = _getOrCreateUserVault(message.sender);
        UserVault(userVault).restakingCancelUnstake(syntheticAsset, message.amount, message.operator);

        return abi.encode(true);
    }

    function _handleExecuteUnstakeMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata payload
    )
        internal
        returns (bytes memory)
    {
        ICrossChainDelegatorMessage.ExecuteUnstakeMessage memory message =
            CrossChainDelegatorMessage.decodeExecuteUnstakeMessage(payload);

        address syntheticAsset = syntheticAssets[originChainId][message.originAsset];
        if (syntheticAsset == address(0)) revert InvalidAsset(address(0));

        address userVault = _getOrCreateUserVault(message.sender);
        // Just execute unstake, keep assets in vault
        UserVault(userVault).restakingExecuteUnstake(syntheticAsset, message.amount, message.operator);

        return abi.encode(true);
    }

    function _handleScheduleWithdrawalMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata payload
    )
        internal
        returns (bytes memory)
    {
        ICrossChainDelegatorMessage.ScheduleWithdrawalMessage memory message =
            CrossChainDelegatorMessage.decodeScheduleWithdrawalMessage(payload);

        address syntheticAsset = syntheticAssets[originChainId][message.originAsset];
        if (syntheticAsset == address(0)) revert InvalidAsset(address(0));

        address userVault = _getOrCreateUserVault(message.sender);
        UserVault(userVault).restakingScheduleWithdraw(syntheticAsset, message.amount);

        return abi.encode(true);
    }

    function _handleCancelWithdrawalMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata payload
    )
        internal
        returns (bytes memory)
    {
        ICrossChainDelegatorMessage.CancelWithdrawalMessage memory message =
            CrossChainDelegatorMessage.decodeCancelWithdrawalMessage(payload);

        address syntheticAsset = syntheticAssets[originChainId][message.originAsset];
        if (syntheticAsset == address(0)) revert InvalidAsset(address(0));

        address userVault = _getOrCreateUserVault(message.sender);
        UserVault(userVault).restakingCancelWithdraw(syntheticAsset, message.amount);

        return abi.encode(true);
    }

    function _handleExecuteWithdrawalMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata payload
    )
        internal
        returns (bytes memory)
    {
        ICrossChainDelegatorMessage.ExecuteWithdrawalMessage memory message =
            CrossChainDelegatorMessage.decodeExecuteWithdrawalMessage(payload);

        address syntheticAsset = syntheticAssets[originChainId][message.originAsset];
        if (syntheticAsset == address(0)) revert InvalidAsset(address(0));

        address userVault = _getOrCreateUserVault(message.sender);

        // First execute withdrawal in user vault
        UserVault(userVault).restakingExecuteWithdraw(syntheticAsset, message.amount);

        // Then dispatch message back to origin chain
        ICrossChainDelegatorMessage.WithdrawalExecutedMessage memory withdrawalMessage = ICrossChainDelegatorMessage
            .WithdrawalExecutedMessage({
            bridgeId: message.bridgeId,
            originAsset: message.originAsset,
            amount: message.amount,
            sender: message.sender,
            recipient: message.recipient
        });

        // Only burn after successful message dispatch
        try bridgeManager.dispatchMessage(withdrawalMessage.encode()) {
            // If message dispatch succeeds, burn the synthetic asset
            SyntheticRestakeAsset(syntheticAsset).burn(userVault, message.amount);
        } catch {
            revert BridgeDispatchFailed();
        }

        return abi.encode(true);
    }

    function getOrCreateSyntheticAsset(uint32 originChainId, uint256 originAsset, uint256 bridgeId) internal returns (address) {
        address synthetic = syntheticAssets[originChainId][originAsset];

        if (synthetic == address(0)) {
            string memory name = string(abi.encodePacked("Synthetic Restake ", originAsset));
            string memory symbol = string(abi.encodePacked("sr", originAsset));

            synthetic = address(new SyntheticRestakeAsset(name, symbol, originChainId, originAsset, bridgeId));
            syntheticAssets[originChainId][originAsset] = synthetic;

            emit SyntheticAssetCreated(synthetic, originChainId, originAsset, bridgeId);
        }

        return synthetic;
    }
}
