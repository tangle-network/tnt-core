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
    /// @param asset The asset being operated on
    /// @param operator The operator (if applicable) for the operation
    /// @param operation The type of operation performed
    /// @param amount The amount involved in the operation
    event OperationExecuted(address indexed asset, bytes32 indexed operator, Operation indexed operation, uint256 amount);

    /// @notice Execute a delegation operation
    /// @param operator The operator address (if applicable)
    /// @param asset The asset to operate on
    /// @param amount The amount to operate with
    /// @param operation The operation to perform
    /// @return success Whether the operation was successful
    function op(bytes32 operator, address asset, uint256 amount, Operation operation) public virtual returns (bool) {
        uint8 result;
        uint256 assetId = uint256(uint160(asset));

        if (operation == Operation.Deposit) {
            result = DELEGATION.deposit(assetId, amount);
            if (result != 0) revert DelegationFailed();
        } else if (operation == Operation.Delegate) {
            result = DELEGATION.delegate(operator, assetId, amount);
            if (result != 0) revert DelegationFailed();
        } else if (operation == Operation.ScheduleUnstake) {
            result = DELEGATION.scheduleDelegatorUnstake(operator, assetId, amount);
            if (result != 0) revert UnstakeFailed();
        } else if (operation == Operation.CancelUnstake) {
            result = DELEGATION.cancelDelegatorUnstake(operator, assetId, amount);
            if (result != 0) revert UnstakeFailed();
        } else if (operation == Operation.ExecuteUnstake) {
            result = DELEGATION.executeDelegatorUnstake();
            if (result != 0) revert UnstakeFailed();
        } else if (operation == Operation.ScheduleWithdraw) {
            result = DELEGATION.scheduleWithdraw(assetId, amount);
            if (result != 0) revert WithdrawalFailed();
        } else if (operation == Operation.CancelWithdraw) {
            result = DELEGATION.cancelWithdraw(assetId, amount);
            if (result != 0) revert WithdrawalFailed();
        } else if (operation == Operation.ExecuteWithdraw) {
            result = DELEGATION.executeWithdraw();
            if (result != 0) revert WithdrawalFailed();
        }

        emit OperationExecuted(asset, operator, operation, amount);
        return true;
    }
}
