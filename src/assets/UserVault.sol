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

    function restakingDeposit(address _asset, uint256 _amount, uint8 _lockMultiplier) external onlyMasterVault {
        uint256 assetId = uint256(uint160(_asset));
        DELEGATION.deposit(assetId, _asset, _amount, _lockMultiplier);
    }

    function restakingDelegate(
        bytes32 _operator,
        address _asset,
        uint256 _amount,
        uint64[] memory _blueprintSelection
    )
        external
        onlyMasterVault
    {
        uint256 assetId = uint256(uint160(_asset));
        DELEGATION.delegate(_operator, assetId, _asset, _amount, _blueprintSelection);
    }

    function restakingScheduleUnstake(bytes32 _operator, address _asset, uint256 _amount) external onlyMasterVault {
        uint256 assetId = uint256(uint160(_asset));
        DELEGATION.scheduleDelegatorUnstake(_operator, assetId, _asset, _amount);
    }

    function restakingCancelUnstake(bytes32 _operator, address _asset, uint256 _amount) external onlyMasterVault {
        uint256 assetId = uint256(uint160(_asset));
        DELEGATION.cancelDelegatorUnstake(_operator, assetId, _asset, _amount);
    }

    function restakingExecuteUnstake() external onlyMasterVault {
        DELEGATION.executeDelegatorUnstake();
    }

    function restakingScheduleWithdraw(address _asset, uint256 _amount) external onlyMasterVault {
        uint256 assetId = uint256(uint160(_asset));
        DELEGATION.scheduleWithdraw(assetId, _asset, _amount);
    }

    function restakingCancelWithdraw(address _asset, uint256 _amount) external onlyMasterVault {
        uint256 assetId = uint256(uint160(_asset));
        DELEGATION.cancelWithdraw(assetId, _asset, _amount);
    }

    function restakingExecuteWithdraw() external onlyMasterVault {
        DELEGATION.executeWithdraw();
    }

    function claim() external {
        // TODO: Implement
    }
}
