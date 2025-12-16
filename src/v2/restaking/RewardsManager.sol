// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DelegationManagerLib } from "./DelegationManagerLib.sol";
import { DelegationErrors } from "./DelegationErrors.sol";
import { Types } from "../libraries/Types.sol";
import { IRewardsManager } from "../interfaces/IRewardsManager.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";

/// @title RewardsManager
/// @notice Manages Masterchef-style reward distribution with share-based accounting
/// @dev Uses shares for reward calculation, with totalAssets tracking underlying value
abstract contract RewardsManager is DelegationManagerLib {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event RewardDistributed(address indexed operator, uint256 amount);
    event RewardClaimed(address indexed account, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Notify reward for an operator from a specific blueprint
    /// @dev Distributes to appropriate pools based on delegator blueprint exposure
    /// @param operator Operator receiving the reward
    /// @param blueprintId Blueprint that generated the reward
    /// @param amount Total reward amount
    function _notifyRewardForBlueprint(address operator, uint64 blueprintId, uint256 amount) internal {
        // Split: operator commission vs delegator share
        uint256 operatorShare = (amount * operatorCommissionBps) / BPS_DENOMINATOR;
        uint256 delegatorShare = amount - operatorShare;

        // Add operator's commission to pending rewards
        _operatorPendingRewards[operator] += operatorShare;

        // Distribute to All mode pool (delegators exposed to ALL blueprints)
        _updateRewardPool(operator);
        Types.OperatorRewardPool storage allPool = _rewardPools[operator];
        if (allPool.totalShares > 0) {
            // All mode delegators get rewards from this blueprint
            allPool.accRewardPerShare += (delegatorShare * PRECISION) / allPool.totalShares;
        }

        // Distribute to Fixed mode pool for this specific blueprint
        Types.OperatorRewardPool storage bpPool = _blueprintPools[operator][blueprintId];
        bpPool.lastUpdateRound = currentRound;
        if (bpPool.totalShares > 0) {
            // Fixed mode delegators who selected this blueprint also get rewards
            bpPool.accRewardPerShare += (delegatorShare * PRECISION) / bpPool.totalShares;
        }

        // If no delegators in either pool, operator gets everything
        if (allPool.totalShares == 0 && bpPool.totalShares == 0) {
            _operatorPendingRewards[operator] += delegatorShare;
        }

        emit RewardDistributed(operator, amount);
    }

    /// @notice Notify reward for an operator (legacy - distributes to All mode pool only)
    /// @param operator Operator receiving the reward
    /// @param amount Total reward amount
    function _notifyReward(address operator, uint256 amount) internal {
        // Split: operator commission vs delegator share
        uint256 operatorShare = (amount * operatorCommissionBps) / BPS_DENOMINATOR;
        uint256 delegatorShare = amount - operatorShare;

        // Add operator's commission to pending rewards
        _operatorPendingRewards[operator] += operatorShare;

        // Update pool with delegator share
        _updateRewardPool(operator);
        Types.OperatorRewardPool storage pool = _rewardPools[operator];

        if (pool.totalShares > 0) {
            // Distribute rewards proportional to SHARES (not underlying value)
            pool.accRewardPerShare += (delegatorShare * PRECISION) / pool.totalShares;
        } else {
            // No delegators - operator gets everything
            _operatorPendingRewards[operator] += delegatorShare;
        }

        emit RewardDistributed(operator, amount);
    }

    /// @notice Update reward pool timestamp
    function _updateRewardPool(address operator) internal {
        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        pool.lastUpdateRound = currentRound;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim delegator rewards from all delegations
    /// @dev Handles both All mode (operator pool) and Fixed mode (blueprint pools)
    /// @return totalRewards Total rewards claimed
    function _claimDelegatorRewards() internal returns (uint256 totalRewards) {
        for (uint256 i = 0; i < _delegations[msg.sender].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[msg.sender][i];

            if (d.selectionMode == Types.BlueprintSelectionMode.All) {
                // All mode: claim from operator's main pool
                totalRewards += _claimFromAllModePool(d.operator, d.shares);
            } else {
                // Fixed mode: claim from each selected blueprint's pool
                uint64[] storage blueprintIds = _delegationBlueprints[msg.sender][i];
                totalRewards += _claimFromFixedModePools(d.operator, blueprintIds);
            }
        }

        if (totalRewards > 0) {
            (bool success,) = msg.sender.call{ value: totalRewards }("");
            if (!success) revert DelegationErrors.TransferFailed();
            emit RewardClaimed(msg.sender, totalRewards);
        }
    }

    /// @notice Claim rewards from All mode pool
    function _claimFromAllModePool(address operator, uint256 shares) internal returns (uint256 rewards) {
        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        Types.DelegatorRewardDebt storage debt = _rewardDebts[msg.sender][operator];

        uint256 accumulated = (pool.accRewardPerShare * shares) / PRECISION;
        uint256 pending = accumulated > debt.rewardDebt
            ? accumulated - debt.rewardDebt
            : 0;

        rewards = pending + debt.pendingRewards;
        debt.pendingRewards = 0;
        debt.rewardDebt = accumulated;
    }

    /// @notice Claim rewards from Fixed mode pools for selected blueprints
    function _claimFromFixedModePools(address operator, uint64[] storage blueprintIds) internal returns (uint256 rewards) {
        for (uint256 j = 0; j < blueprintIds.length; j++) {
            uint64 blueprintId = blueprintIds[j];
            Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId];
            Types.DelegatorRewardDebt storage debt = _blueprintRewardDebts[msg.sender][operator][blueprintId];

            uint256 shares = _delegatorBlueprintShares[msg.sender][operator][blueprintId];
            uint256 accumulated = (pool.accRewardPerShare * shares) / PRECISION;
            uint256 pending = accumulated > debt.rewardDebt
                ? accumulated - debt.rewardDebt
                : 0;

            rewards += pending + debt.pendingRewards;
            debt.pendingRewards = 0;
            debt.rewardDebt = accumulated;
        }
    }

    /// @notice Claim operator rewards
    /// @param recipient Address that should receive the payout
    /// @return amount Amount claimed
    function _claimOperatorRewards(address payable recipient) internal returns (uint256 amount) {
        if (recipient == address(0)) revert DelegationErrors.ZeroAddress();
        amount = _operatorPendingRewards[msg.sender];
        if (amount == 0) revert DelegationErrors.NoRewardsToClaim();

        _operatorPendingRewards[msg.sender] = 0;
        (bool success,) = recipient.call{ value: amount }("");
        if (!success) revert DelegationErrors.TransferFailed();

        emit RewardClaimed(msg.sender, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION HOOK
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when delegation changes to update reward tracking
    /// @dev Implements the hook from DelegationManagerLib with share-based accounting.
    ///      Routes to appropriate pools based on blueprint selection mode.
    /// @param delegator The delegator address
    /// @param operator The operator address
    /// @param shares Number of shares changing
    /// @param amount The underlying amount (for totalAssets tracking)
    /// @param isIncrease True if adding, false if removing
    /// @param selectionMode Blueprint selection mode (All or Fixed)
    /// @param blueprintIds Blueprint IDs for Fixed mode
    function _onDelegationChanged(
        address delegator,
        address operator,
        Types.Asset memory asset,
        uint256 shares,
        uint256 amount,
        bool isIncrease,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] memory blueprintIds,
        uint16 lockMultiplierBps
    ) internal override {
        if (selectionMode == Types.BlueprintSelectionMode.All) {
            // All mode: use the operator's main pool (exposed to ALL blueprints)
            _updateAllModePool(delegator, operator, shares, amount, isIncrease);
        } else {
            // Fixed mode: update per-blueprint pools for selected blueprints only
            _updateFixedModePools(delegator, operator, shares, amount, isIncrease, blueprintIds);
        }

        // Notify external rewards manager for TNT incentives (if configured)
        _notifyExternalRewardsManager(delegator, operator, asset, amount, isIncrease, lockMultiplierBps);

        // Notify external service-fee distributor for multi-token fee accrual (if configured)
        _notifyServiceFeeDistributor(delegator, operator, asset, amount, isIncrease, selectionMode, blueprintIds, lockMultiplierBps);
    }

    /// @notice Update reward pool for All mode delegations
    /// @dev All mode delegators are exposed to rewards/slashes from ALL operator blueprints
    function _updateAllModePool(
        address delegator,
        address operator,
        uint256 shares,
        uint256 amount,
        bool isIncrease
    ) internal {
        _updateRewardPool(operator);

        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        Types.DelegatorRewardDebt storage debt = _rewardDebts[delegator][operator];

        // Get current shares BEFORE this change (All mode shares only)
        uint256 currentShares = _getDelegatorAllModeShares(delegator, operator);
        if (isIncrease) {
            // For increase, current shares already includes new shares from _delegate
            currentShares -= shares;
        }

        // Harvest pending rewards before updating shares
        if (currentShares > 0) {
            uint256 accumulated = (pool.accRewardPerShare * currentShares) / PRECISION;
            uint256 pending = accumulated > debt.rewardDebt
                ? accumulated - debt.rewardDebt
                : 0;
            debt.pendingRewards += pending;
        }

        // Update pool: both shares AND totalAssets
        if (isIncrease) {
            pool.totalShares += shares;
            pool.totalAssets += amount;
        } else {
            pool.totalShares -= shares;
            pool.totalAssets = amount > pool.totalAssets ? 0 : pool.totalAssets - amount;
        }

        // Update debt to current accumulated based on NEW share count
        uint256 newShares = isIncrease ? currentShares + shares : (currentShares > shares ? currentShares - shares : 0);
        debt.rewardDebt = (pool.accRewardPerShare * newShares) / PRECISION;
    }

    /// @notice Update reward pools for Fixed mode delegations
    /// @dev Fixed mode delegators are only exposed to rewards/slashes from selected blueprints
    function _updateFixedModePools(
        address delegator,
        address operator,
        uint256 shares,
        uint256 amount,
        bool isIncrease,
        uint64[] memory blueprintIds
    ) internal {
        if (blueprintIds.length == 0) return;

        // Distribute shares equally across selected blueprints
        uint256 sharesPerBlueprint = shares / blueprintIds.length;
        uint256 amountPerBlueprint = amount / blueprintIds.length;

        for (uint256 i = 0; i < blueprintIds.length; i++) {
            uint64 blueprintId = blueprintIds[i];
            Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId];
            Types.DelegatorRewardDebt storage debt = _blueprintRewardDebts[delegator][operator][blueprintId];

            pool.lastUpdateRound = currentRound;

            // Get current shares for this blueprint
            uint256 currentShares = _delegatorBlueprintShares[delegator][operator][blueprintId];
            if (isIncrease) {
                currentShares -= sharesPerBlueprint; // Already added in _delegate
            }

            // Harvest pending rewards
            if (currentShares > 0) {
                uint256 accumulated = (pool.accRewardPerShare * currentShares) / PRECISION;
                uint256 pending = accumulated > debt.rewardDebt
                    ? accumulated - debt.rewardDebt
                    : 0;
                debt.pendingRewards += pending;
            }

            // Update pool
            if (isIncrease) {
                pool.totalShares += sharesPerBlueprint;
                pool.totalAssets += amountPerBlueprint;
            } else {
                pool.totalShares = sharesPerBlueprint > pool.totalShares ? 0 : pool.totalShares - sharesPerBlueprint;
                pool.totalAssets = amountPerBlueprint > pool.totalAssets ? 0 : pool.totalAssets - amountPerBlueprint;
            }

            // Update debt
            uint256 newShares = isIncrease
                ? currentShares + sharesPerBlueprint
                : (currentShares > sharesPerBlueprint ? currentShares - sharesPerBlueprint : 0);
            debt.rewardDebt = (pool.accRewardPerShare * newShares) / PRECISION;
        }
    }

    /// @notice Get delegator's shares in All mode for a specific operator
    function _getDelegatorAllModeShares(address delegator, address operator) internal view returns (uint256 totalShares) {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            if (d.operator == operator && d.selectionMode == Types.BlueprintSelectionMode.All) {
                totalShares += d.shares;
            }
        }
    }

    /// @notice Notify external rewards manager of delegation change
    /// @dev Silent failure - if call fails, internal rewards still work
    function _notifyExternalRewardsManager(
        address delegator,
        address operator,
        Types.Asset memory asset,
        uint256 amount,
        bool isIncrease,
        uint16 lockMultiplierBps
    ) internal {
        if (_rewardsManager == address(0)) return;

        address assetAddress = asset.kind == Types.AssetKind.Native ? address(0) : asset.token;

        if (isIncrease) {
            try IRewardsManager(_rewardsManager).recordDelegate(
                delegator,
                operator,
                assetAddress,
                amount,
                lockMultiplierBps
            ) {} catch {}
        } else {
            try IRewardsManager(_rewardsManager).recordUndelegate(
                delegator,
                operator,
                assetAddress,
                amount
            ) {} catch {}
        }
    }

    function _notifyServiceFeeDistributor(
        address delegator,
        address operator,
        Types.Asset memory asset,
        uint256 amount,
        bool isIncrease,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] memory blueprintIds,
        uint16 lockMultiplierBps
    ) internal {
        if (_serviceFeeDistributor == address(0)) return;
        try IServiceFeeDistributor(_serviceFeeDistributor).onDelegationChanged(
            delegator,
            operator,
            asset,
            amount,
            isIncrease,
            selectionMode,
            blueprintIds,
            lockMultiplierBps
        ) {} catch {}
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get operator reward pool info
    function _getOperatorRewardPool(
        address operator
    ) internal view returns (Types.OperatorRewardPool memory) {
        return _rewardPools[operator];
    }

    /// @notice Get pending delegator rewards
    /// @dev Handles both All mode and Fixed mode delegations
    function _getPendingDelegatorRewards(address delegator) internal view returns (uint256 total) {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];

            if (d.selectionMode == Types.BlueprintSelectionMode.All) {
                // All mode: calculate from operator's main pool
                Types.OperatorRewardPool storage pool = _rewardPools[d.operator];
                Types.DelegatorRewardDebt storage debt = _rewardDebts[delegator][d.operator];

                uint256 accumulated = (pool.accRewardPerShare * d.shares) / PRECISION;
                uint256 pending = accumulated > debt.rewardDebt
                    ? accumulated - debt.rewardDebt
                    : 0;
                total += pending + debt.pendingRewards;
            } else {
                // Fixed mode: calculate from each selected blueprint's pool
                uint64[] storage blueprintIds = _delegationBlueprints[delegator][i];
                for (uint256 j = 0; j < blueprintIds.length; j++) {
                    uint64 blueprintId = blueprintIds[j];
                    Types.OperatorRewardPool storage pool = _blueprintPools[d.operator][blueprintId];
                    Types.DelegatorRewardDebt storage debt = _blueprintRewardDebts[delegator][d.operator][blueprintId];

                    uint256 shares = _delegatorBlueprintShares[delegator][d.operator][blueprintId];
                    uint256 accumulated = (pool.accRewardPerShare * shares) / PRECISION;
                    uint256 pending = accumulated > debt.rewardDebt
                        ? accumulated - debt.rewardDebt
                        : 0;
                    total += pending + debt.pendingRewards;
                }
            }
        }
    }

    /// @notice Get pending operator rewards
    function _getPendingOperatorRewards(address operator) internal view returns (uint256) {
        return _operatorPendingRewards[operator];
    }
}
