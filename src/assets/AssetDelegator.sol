// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

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
    /// @return success Whether the operation was successful
    function op(bytes32 _operator, address _asset, uint256 _amount, Operation _operation) public virtual returns (bool) {
        uint8 result;
        uint256 assetId = uint256(uint160(_asset));

        if (_operation == Operation.Deposit) {
            result = DELEGATION.deposit(assetId, _amount);
            if (result != 0) revert DelegationFailed();
        } else if (_operation == Operation.Delegate) {
            result = DELEGATION.delegate(_operator, assetId, _amount);
            if (result != 0) revert DelegationFailed();
        } else if (_operation == Operation.ScheduleUnstake) {
            result = DELEGATION.scheduleDelegatorUnstake(_operator, assetId, _amount);
            if (result != 0) revert UnstakeFailed();
        } else if (_operation == Operation.CancelUnstake) {
            result = DELEGATION.cancelDelegatorUnstake(_operator, assetId, _amount);
            if (result != 0) revert UnstakeFailed();
        } else if (_operation == Operation.ExecuteUnstake) {
            result = DELEGATION.executeDelegatorUnstake();
            if (result != 0) revert UnstakeFailed();
        } else if (_operation == Operation.ScheduleWithdraw) {
            result = DELEGATION.scheduleWithdraw(assetId, _amount);
            if (result != 0) revert WithdrawalFailed();
        } else if (_operation == Operation.CancelWithdraw) {
            result = DELEGATION.cancelWithdraw(assetId, _amount);
            if (result != 0) revert WithdrawalFailed();
        } else if (_operation == Operation.ExecuteWithdraw) {
            result = DELEGATION.executeWithdraw();
            if (result != 0) revert WithdrawalFailed();
        }

        emit OperationExecuted(_asset, _operator, _operation, _amount);
        return true;
    }
}
