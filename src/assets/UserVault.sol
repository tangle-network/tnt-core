// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AssetVault } from "./AssetVault.sol";
import { ICrossChainAssetVault } from "../interfaces/ICrossChainAssetVault.sol";
import { ISyntheticRestakeAsset } from "../interfaces/ISyntheticRestakeAsset.sol";

contract UserVault is AssetVault {
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

    function deposit(address syntheticAsset, uint256 amount) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.Deposit);
    }

    function delegate(
        address syntheticAsset, 
        uint256 amount, 
        bytes32 operator
    ) external onlyMasterVault returns (bool) {
        return op(operator, syntheticAsset, amount, Operation.Delegate);
    }

    function scheduleUnstake(
        address syntheticAsset,
        uint256 amount,
        bytes32 operator
    ) external onlyMasterVault returns (bool) {
        return op(operator, syntheticAsset, amount, Operation.ScheduleUnstake);
    }

    function cancelUnstake(
        address syntheticAsset,
        uint256 amount,
        bytes32 operator
    ) external onlyMasterVault returns (bool) {
        return op(operator, syntheticAsset, amount, Operation.CancelUnstake);
    }

    function executeUnstake(
        address syntheticAsset,
        uint256 amount,
        bytes32 operator
    ) external onlyMasterVault returns (bool) {
        return op(operator, syntheticAsset, amount, Operation.ExecuteUnstake);
    }

    function scheduleWithdraw(
        address syntheticAsset,
        uint256 amount
    ) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.ScheduleWithdraw);
    }

    function cancelWithdraw(
        address syntheticAsset,
        uint256 amount
    ) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.CancelWithdraw);
    }

    function executeWithdraw(
        address syntheticAsset,
        uint256 amount
    ) external onlyMasterVault returns (bool) {
        return op(bytes32(0), syntheticAsset, amount, Operation.ExecuteWithdraw);
    }

    function isCrossChainAsset(address asset) internal view override returns (bool) {
        // Delegate to master vault's check
        return ISyntheticRestakeAsset(asset).originChainId() != 0;
    }
}