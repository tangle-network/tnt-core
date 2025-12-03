// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { DelegationStorage } from "./DelegationStorage.sol";
import { DelegationErrors } from "./DelegationErrors.sol";
import { Types } from "../libraries/Types.sol";

/// @title DepositManager
/// @notice Manages delegator deposits, withdrawals, and locks
/// @dev Inherits storage layout from DelegationStorage
abstract contract DepositManager is DelegationStorage {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event Deposited(
        address indexed delegator,
        address indexed token,
        uint256 amount,
        Types.LockMultiplier lock
    );
    event WithdrawScheduled(
        address indexed delegator,
        address indexed token,
        uint256 amount,
        uint64 readyRound
    );
    event Withdrawn(address indexed delegator, address indexed token, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPOSITS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit native token
    function _depositNative() internal {
        _depositAsset(
            Types.Asset(Types.AssetKind.Native, address(0)),
            msg.value,
            Types.LockMultiplier.None
        );
    }

    /// @notice Deposit native token with lock
    /// @param lockMultiplier Lock duration for bonus multiplier
    function _depositNativeWithLock(Types.LockMultiplier lockMultiplier) internal {
        _depositAsset(
            Types.Asset(Types.AssetKind.Native, address(0)),
            msg.value,
            lockMultiplier
        );
    }

    /// @notice Deposit ERC20 token
    /// @param token Token address
    /// @param amount Amount to deposit
    function _depositERC20(address token, uint256 amount) internal {
        if (token == address(0)) revert DelegationErrors.AssetNotEnabled(address(0));

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _depositAsset(
            Types.Asset(Types.AssetKind.ERC20, token),
            amount,
            Types.LockMultiplier.None
        );
    }

    /// @notice Deposit ERC20 token with lock
    /// @param token Token address
    /// @param amount Amount to deposit
    /// @param lockMultiplier Lock duration for bonus multiplier
    function _depositERC20WithLock(
        address token,
        uint256 amount,
        Types.LockMultiplier lockMultiplier
    ) internal {
        if (token == address(0)) revert DelegationErrors.AssetNotEnabled(address(0));

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        _depositAsset(
            Types.Asset(Types.AssetKind.ERC20, token),
            amount,
            lockMultiplier
        );
    }

    /// @notice Internal deposit logic
    function _depositAsset(
        Types.Asset memory asset,
        uint256 amount,
        Types.LockMultiplier lockMultiplier
    ) internal {
        if (amount == 0) revert DelegationErrors.ZeroAmount();

        bytes32 assetHash = _assetHash(asset);
        Types.AssetConfig storage config = _assetConfigs[assetHash];

        if (!config.enabled) revert DelegationErrors.AssetNotEnabled(asset.token);
        if (amount < config.minDelegation) {
            revert DelegationErrors.BelowMinimumDeposit(config.minDelegation, amount);
        }
        if (config.depositCap > 0 && config.currentDeposits + amount > config.depositCap) {
            revert DelegationErrors.DepositCapExceeded(config.depositCap, config.currentDeposits, amount);
        }

        config.currentDeposits += amount;

        Types.Deposit storage dep = _deposits[msg.sender][assetHash];
        dep.amount += amount;

        // Handle lock if specified
        if (lockMultiplier != Types.LockMultiplier.None) {
            uint64 lockDuration = _getLockDuration(lockMultiplier);
            _depositLocks[msg.sender][assetHash].push(Types.LockInfo({
                amount: amount,
                multiplier: lockMultiplier,
                expiryBlock: uint64(block.number) + lockDuration
            }));
        }

        emit Deposited(msg.sender, asset.token, amount, lockMultiplier);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWALS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Schedule withdrawal
    /// @param token Token address (address(0) for native)
    /// @param amount Amount to withdraw
    function _scheduleWithdraw(address token, uint256 amount) internal {
        if (amount == 0) revert DelegationErrors.ZeroAmount();

        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        bytes32 assetHash = _assetHash(asset);

        Types.Deposit storage dep = _deposits[msg.sender][assetHash];
        uint256 available = dep.amount - dep.delegatedAmount;

        // Check locks
        uint256 locked = _getLockedAmount(msg.sender, assetHash);
        uint256 free = dep.amount > locked ? dep.amount - locked : 0;

        if (free < amount) {
            revert DelegationErrors.AmountLocked(locked, amount);
        }
        if (available < amount) {
            revert DelegationErrors.InsufficientAvailableBalance(available, amount);
        }

        dep.amount -= amount;

        _withdrawRequests[msg.sender].push(Types.WithdrawRequest({
            asset: asset,
            amount: amount,
            requestedRound: currentRound
        }));

        emit WithdrawScheduled(msg.sender, token, amount, currentRound + leaveDelegatorsDelay);
    }

    /// @notice Execute pending withdrawals
    /// @dev Uses checks-effects-interactions pattern to prevent reentrancy
    /// @return totalWithdrawn Total amount withdrawn across all pending requests
    function _executeWithdraw() internal returns (uint256 totalWithdrawn) {
        Types.WithdrawRequest[] storage requests = _withdrawRequests[msg.sender];

        // First pass: identify ready withdrawals and update state (CHECKS + EFFECTS)
        // Store withdrawal data in memory before modifying storage
        uint256 readyCount = 0;
        uint256[] memory readyIndices = new uint256[](requests.length);
        Types.Asset[] memory readyAssets = new Types.Asset[](requests.length);
        uint256[] memory readyAmounts = new uint256[](requests.length);

        for (uint256 i = 0; i < requests.length; i++) {
            if (currentRound >= requests[i].requestedRound + leaveDelegatorsDelay) {
                readyIndices[readyCount] = i;
                readyAssets[readyCount] = requests[i].asset;
                readyAmounts[readyCount] = requests[i].amount;
                totalWithdrawn += requests[i].amount;
                readyCount++;
            }
        }

        // Remove processed requests from storage (EFFECTS - complete before any external calls)
        // Process in reverse order to maintain correct indices
        for (uint256 i = readyCount; i > 0; i--) {
            uint256 idx = readyIndices[i - 1];
            // Swap with last element and pop
            if (idx < requests.length - 1) {
                requests[idx] = requests[requests.length - 1];
            }
            requests.pop();
        }

        // Second pass: perform all transfers (INTERACTIONS - after all state changes)
        for (uint256 i = 0; i < readyCount; i++) {
            _transferAsset(readyAssets[i], msg.sender, readyAmounts[i]);
            emit Withdrawn(msg.sender, readyAssets[i].token, readyAmounts[i]);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get deposit for a delegator and token
    /// @param delegator Delegator address
    /// @param token Token address (address(0) for native)
    function _getDeposit(
        address delegator,
        address token
    ) internal view returns (Types.Deposit memory) {
        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        return _deposits[delegator][_assetHash(asset)];
    }

    /// @notice Get locked amount for a delegator and asset
    /// @param delegator Delegator address
    /// @param assetHash Hash of the asset
    function _getLockedAmount(
        address delegator,
        bytes32 assetHash
    ) internal view returns (uint256 locked) {
        Types.LockInfo[] storage locks = _depositLocks[delegator][assetHash];
        for (uint256 i = 0; i < locks.length; i++) {
            if (locks[i].expiryBlock > block.number) {
                locked += locks[i].amount;
            }
        }
    }

    /// @notice Get pending withdrawals for a delegator
    /// @param delegator Delegator address
    function _getPendingWithdrawals(
        address delegator
    ) internal view returns (Types.WithdrawRequest[] memory) {
        return _withdrawRequests[delegator];
    }

    /// @notice Get lock info for a delegator and token
    /// @param delegator Delegator address
    /// @param token Token address
    function _getLocks(
        address delegator,
        address token
    ) internal view returns (Types.LockInfo[] memory) {
        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        return _depositLocks[delegator][_assetHash(asset)];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Transfer asset to recipient
    function _transferAsset(Types.Asset memory asset, address to, uint256 amount) internal {
        if (asset.kind == Types.AssetKind.Native) {
            (bool success,) = to.call{ value: amount }("");
            require(success, "Native transfer failed");
        } else {
            IERC20(asset.token).safeTransfer(to, amount);
        }
    }
}
