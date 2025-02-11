// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title ICrossChainDelegatorMessage
/// @notice Defines the structure for cross-chain delegator messages
interface ICrossChainDelegatorMessage {
    /// @notice Structure for cross-chain asset deposit messages
    struct DepositMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
    }

    /// @notice Structure for cross-chain delegation update messages
    struct DelegationMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
        bytes32 operator;
    }

    /// @notice Structure for scheduling an unstake operation
    struct ScheduleUnstakeMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
        bytes32 operator;
    }

    /// @notice Structure for cancelling a scheduled unstake
    struct CancelUnstakeMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
        bytes32 operator;
    }

    /// @notice Structure for executing a scheduled unstake
    struct ExecuteUnstakeMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
        bytes32 operator;
    }

    /// @notice Structure for scheduling a withdrawal
    struct ScheduleWithdrawalMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
    }

    /// @notice Structure for cancelling a scheduled withdrawal
    struct CancelWithdrawalMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
    }

    /// @notice Structure for executing a scheduled withdrawal
    struct ExecuteWithdrawalMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
        bytes32 recipient;
    }

    /// @notice Structure for cross-chain withdrawal executed messages
    /// This message is sent by the origin chain to the remote chain to
    /// inform about the successful withdrawal execution and before burning
    /// the synthetic asset.
    struct WithdrawalExecutedMessage {
        uint256 bridgeId;
        uint256 originAsset;
        uint256 amount;
        bytes32 sender;
        bytes32 recipient;
    }
}
