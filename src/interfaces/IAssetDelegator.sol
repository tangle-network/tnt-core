// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @title IAssetDelegator
/// @notice Interface for delegating assets to operators
interface IAssetDelegator {
    /// @notice Delegation operation types
    enum DelegationOp {
        Delegate,
        ScheduleUnstake,
        CancelUnstake
    }

    /// @notice Event emitted when a delegation operation is performed
    event DelegationExecuted(
        address indexed asset, address indexed sender, DelegationOp operation, bytes32 operator, uint256 amount
    );

    /// @notice Delegate assets to an operator
    function delegate(bytes32 operator, address asset, uint256 amount, DelegationOp op) external returns (bool);

    /// @notice Handle delegation from bridge transfer
    function handleDelegation(address asset, uint256 amount, bytes calldata delegateData) external returns (bool);
}
