// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DelegationManagerLib } from "./DelegationManagerLib.sol";
import { Types } from "../libraries/Types.sol";
import { IRewardsManager } from "../interfaces/IRewardsManager.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";

/// @title RewardsManager
/// @notice Tracks pool totals for slashing/exchange-rate accounting and forwards delegation updates to external reward systems.
abstract contract RewardsManager is DelegationManagerLib {
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
        address /* delegator */,
        address operator,
        uint256 shares,
        uint256 amount,
        bool isIncrease
    ) internal {
        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        if (isIncrease) {
            pool.totalShares += shares;
            pool.totalAssets += amount;
        } else {
            pool.totalShares = shares > pool.totalShares ? 0 : pool.totalShares - shares;
            pool.totalAssets = amount > pool.totalAssets ? 0 : pool.totalAssets - amount;
        }
    }

    /// @notice Update reward pools for Fixed mode delegations
    /// @dev Fixed mode delegators are only exposed to rewards/slashes from selected blueprints
    function _updateFixedModePools(
        address /* delegator */,
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

            // Update pool
            if (isIncrease) {
                pool.totalShares += sharesPerBlueprint;
                pool.totalAssets += amountPerBlueprint;
            } else {
                pool.totalShares = sharesPerBlueprint > pool.totalShares ? 0 : pool.totalShares - sharesPerBlueprint;
                pool.totalAssets = amountPerBlueprint > pool.totalAssets ? 0 : pool.totalAssets - amountPerBlueprint;
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
}
