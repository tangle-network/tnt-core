// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ICrossChainAssetVault } from "../interfaces/ICrossChainAssetVault.sol";
import { ICrossChainReceiver } from "../interfaces/ICrossChainReceiver.sol";
import { ICrossChainDelegatorMessage } from "../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../libs/CrossChainDelegatorMessage.sol";
import { SyntheticRestakeAsset } from "./SyntheticRestakeAsset.sol";
import { AssetVault } from "./AssetVault.sol";

contract CrossChainAssetVault is ICrossChainAssetVault, ICrossChainReceiver, AssetVault {
    using CrossChainDelegatorMessage for *;

    mapping(uint32 => mapping(uint256 => address)) public syntheticAssets;
    mapping(address => bool) public authorizedAdapters;

    error UnauthorizedAdapter(address adapter);
    error ZeroAddress();
    error InvalidMessage();
    error Unauthorized(bytes32 sender);
    error InvalidUnlockTime();
    error InvalidRecipient();

    event SyntheticAssetCreated(
        address indexed syntheticAsset, uint32 indexed originChainId, uint256 indexed originAsset, uint256 bridgeId
    );

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
        uint8 messageType = CrossChainDelegatorMessage.getMessageType(message);
        bytes calldata payload = message[1:];

        if (messageType == CrossChainDelegatorMessage.DEPOSIT_MESSAGE) {
            return _handleDepositMessage(originChainId, sender, payload);
        } else if (messageType == CrossChainDelegatorMessage.DELEGATION_MESSAGE) {
            return _handleDelegationMessage(originChainId, sender, payload);
        } else if (messageType == CrossChainDelegatorMessage.SCHEDULE_UNSTAKE_MESSAGE) {
            return _handleScheduleUnstakeMessage(originChainId, sender, payload);
        } else if (messageType == CrossChainDelegatorMessage.CANCEL_UNSTAKE_MESSAGE) {
            return _handleCancelUnstakeMessage(originChainId, sender, payload);
        } else if (messageType == CrossChainDelegatorMessage.EXECUTE_UNSTAKE_MESSAGE) {
            return _handleExecuteUnstakeMessage(originChainId, sender, payload);
        } else if (messageType == CrossChainDelegatorMessage.SCHEDULE_WITHDRAWAL_MESSAGE) {
            return _handleScheduleWithdrawalMessage(originChainId, sender, payload);
        } else if (messageType == CrossChainDelegatorMessage.CANCEL_WITHDRAWAL_MESSAGE) {
            return _handleCancelWithdrawalMessage(originChainId, sender, payload);
        } else if (messageType == CrossChainDelegatorMessage.EXECUTE_WITHDRAWAL_MESSAGE) {
            return _handleExecuteWithdrawalMessage(originChainId, sender, payload);
        }

        revert InvalidMessage();
    }

    function _handleDepositMessage(uint32 originChainId, bytes32 sender, bytes calldata payload) internal returns (bytes memory) {
        ICrossChainDelegatorMessage.DepositMessage memory message = CrossChainDelegatorMessage.decodeDepositMessage(payload);

        address syntheticAsset = getOrCreateSyntheticAsset(originChainId, message.originAsset, message.bridgeId);

        SyntheticRestakeAsset(syntheticAsset).mint(address(this), message.amount);
        op(bytes32(0), syntheticAsset, message.amount, Operation.Deposit);

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

        op(message.operator, syntheticAsset, message.amount, Operation.Delegate);

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

        op(sender, syntheticAsset, message.amount, Operation.ScheduleUnstake);

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

        op(sender, syntheticAsset, message.amount, Operation.CancelUnstake);

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

        op(sender, syntheticAsset, message.amount, Operation.ExecuteUnstake);
        SyntheticRestakeAsset(syntheticAsset).burn(address(this), message.amount);

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

        op(sender, syntheticAsset, message.amount, Operation.ScheduleWithdraw);

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

        op(sender, syntheticAsset, message.amount, Operation.CancelWithdraw);

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

        op(sender, syntheticAsset, message.amount, Operation.ExecuteWithdraw);
        SyntheticRestakeAsset(syntheticAsset).burn(address(this), message.amount);

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

    /// @notice Check if an asset is a synthetic cross-chain asset managed by this vault
    /// @param asset The address to check
    /// @return bool True if the asset is a synthetic cross-chain asset
    function isCrossChainAsset(address asset) internal view override returns (bool) {
        // Check if this asset exists in any of our mappings
        // We need to check the originChainId and originAsset mappings
        try SyntheticRestakeAsset(asset).vault() returns (address vaultAddress) {
            // Verify this asset was created by this vault
            return vaultAddress == address(this);
        } catch {
            return false;
        }
    }

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
