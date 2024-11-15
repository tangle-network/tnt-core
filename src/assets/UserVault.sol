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

    function restakingDeposit(uint128 assetId, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), assetId, amount, Operation.Deposit);
    }

    function restakingDelegate(uint128 assetId, uint256 amount, bytes32 operator) external onlyMasterVault returns (bool) {
        return op(operator, assetId, amount, Operation.Delegate);
    }

    function restakingScheduleUnstake(uint128 assetId, uint256 amount, bytes32 operator) external onlyMasterVault returns (bool) {
        return op(operator, assetId, amount, Operation.ScheduleUnstake);
    }

    function restakingCancelUnstake(uint128 assetId, uint256 amount, bytes32 operator) external onlyMasterVault returns (bool) {
        return op(operator, assetId, amount, Operation.CancelUnstake);
    }

    function restakingExecuteUnstake(uint128 assetId, uint256 amount, bytes32 operator) external onlyMasterVault returns (bool) {
        return op(operator, assetId, amount, Operation.ExecuteUnstake);
    }

    function restakingScheduleWithdraw(uint128 assetId, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), assetId, amount, Operation.ScheduleWithdraw);
    }

    function restakingCancelWithdraw(uint128 assetId, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), assetId, amount, Operation.CancelWithdraw);
    }

    function restakingExecuteWithdraw(uint128 assetId, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), assetId, amount, Operation.ExecuteWithdraw);
    }
}
