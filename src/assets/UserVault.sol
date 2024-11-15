// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

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

    function restakingDeposit(address syntheticAsset, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.Deposit);
    }

    function restakingDelegate(address syntheticAsset, uint256 amount, bytes32 operator) external onlyMasterVault returns (bool) {
        return op(operator, syntheticAsset, amount, Operation.Delegate);
    }

    function restakingScheduleUnstake(
        address syntheticAsset,
        uint256 amount,
        bytes32 operator
    )
        external
        onlyMasterVault
        returns (bool)
    {
        return op(operator, syntheticAsset, amount, Operation.ScheduleUnstake);
    }

    function restakingCancelUnstake(
        address syntheticAsset,
        uint256 amount,
        bytes32 operator
    )
        external
        onlyMasterVault
        returns (bool)
    {
        return op(operator, syntheticAsset, amount, Operation.CancelUnstake);
    }

    function restakingExecuteUnstake(
        address syntheticAsset,
        uint256 amount,
        bytes32 operator
    )
        external
        onlyMasterVault
        returns (bool)
    {
        return op(operator, syntheticAsset, amount, Operation.ExecuteUnstake);
    }

    function restakingScheduleWithdraw(address syntheticAsset, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.ScheduleWithdraw);
    }

    function restakingCancelWithdraw(address syntheticAsset, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.CancelWithdraw);
    }

    function restakingExecuteWithdraw(address syntheticAsset, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.ExecuteWithdraw);
    }
}
