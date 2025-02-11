// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { AssetDelegator } from "./AssetDelegator.sol";

contract UserVault is AssetDelegator {
    bytes32 public immutable owner;
    address public immutable masterVault;

    error Unauthorized();
    error InsufficientBalance();

    modifier onlyMasterVault() {
        if (msg.sender != masterVault) revert Unauthorized();
        _;
    }

    constructor(bytes32 _owner, address _masterVault) {
        owner = _owner;
        masterVault = _masterVault;
    }

    function restakingDeposit(
        bytes32,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(bytes32(0), _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.Deposit);
    }

    function restakingDelegate(
        bytes32 operator,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(operator, _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.Delegate);
    }

    function restakingScheduleUnstake(
        bytes32 operator,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(operator, _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.ScheduleUnstake);
    }

    function restakingCancelUnstake(
        bytes32 operator,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(operator, _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.CancelUnstake);
    }

    function restakingExecuteUnstake(
        bytes32 operator,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(operator, _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.ExecuteUnstake);
    }

    function restakingScheduleWithdraw(
        bytes32,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(bytes32(0), _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.ExecuteUnstake);
    }

    function restakingCancelWithdraw(
        bytes32,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(bytes32(0), _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.CancelWithdraw);
    }

    function restakingExecuteWithdraw(
        bytes32,
        address _asset,
        uint256 _amount,
        uint8 _lockMultiplier,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        op(bytes32(0), _asset, _amount, _lockMultiplier, _blueprintSelection, Operation.ExecuteWithdraw);
    }

    function claim(bytes32 _claimant) external {
        if (_claimant != owner) revert Unauthorized();
        
    }
}
