// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { MultiAssetDelegation } from "../precompiles/MultiAssetDelegation.sol";

/// @title AssetDelegator
/// @notice Base contract implementing delegation logic for all assets
abstract contract AssetDelegator {
    /// @dev The MultiAssetDelegation contract's address.
    address constant MULTI_ASSET_DELEGATION = 0x0000000000000000000000000000000000000822;

    /// @dev The MultiAssetDelegation contract's instance.
    MultiAssetDelegation constant DELEGATION = MultiAssetDelegation(MULTI_ASSET_DELEGATION);

    error DelegationFailed();
    error UnstakeFailed();
    error WithdrawalFailed();

    /// @notice Enum representing different delegation operations
    enum Operation {
        Deposit,
        Delegate,
        ScheduleUnstake,
        CancelUnstake,
        ExecuteUnstake,
        ScheduleWithdraw,
        CancelWithdraw,
        ExecuteWithdraw
    }

    /// @notice Emitted when a delegation operation is executed
    /// @param _asset The asset being operated on
    /// @param _operator The operator (if applicable) for the operation
    /// @param _operation The type of operation performed
    /// @param _amount The amount involved in the operation
    event OperationExecuted(address indexed _asset, bytes32 indexed _operator, Operation indexed _operation, uint256 _amount);

    /// @notice Execute a delegation operation
    /// @param _operator The operator address (if applicable)
    /// @param _asset The asset to operate on
    /// @param _amount The amount to operate with
    /// @param _operation The operation to perform
    function op(
        bytes32 _operator,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection,
        Operation _operation
    )
        public
        virtual
    {
        uint256 assetId = uint256(uint160(_asset));

        if (_operation == Operation.Deposit) {
            DELEGATION.deposit(assetId, _asset, _amount, _lockMultiplier);
        } else if (_operation == Operation.Delegate) {
            DELEGATION.delegate(_operator, assetId, _asset, _amount, _blueprintSelection);
        } else if (_operation == Operation.ScheduleUnstake) {
            DELEGATION.scheduleDelegatorUnstake(_operator, assetId, _asset, _amount);
        } else if (_operation == Operation.CancelUnstake) {
            DELEGATION.cancelDelegatorUnstake(_operator, assetId, _asset, _amount);
        } else if (_operation == Operation.ExecuteUnstake) {
            DELEGATION.executeDelegatorUnstake();
        } else if (_operation == Operation.ScheduleWithdraw) {
            DELEGATION.scheduleWithdraw(assetId, _asset, _amount);
        } else if (_operation == Operation.CancelWithdraw) {
            DELEGATION.cancelWithdraw(assetId, _asset, _amount);
        } else if (_operation == Operation.ExecuteWithdraw) {
            DELEGATION.executeWithdraw();
        }

        emit OperationExecuted(_asset, _operator, _operation, _amount);
    }
}
