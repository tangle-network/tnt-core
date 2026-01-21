// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { DelegationManagerLib } from "./DelegationManagerLib.sol";
import { Types } from "../libraries/Types.sol";
import { DelegationErrors } from "./DelegationErrors.sol";
import { IRewardsManager } from "../interfaces/IRewardsManager.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";

/// @title RewardsManager
/// @notice Tracks pool totals for slashing/exchange-rate accounting and forwards delegation updates to external reward systems.
/// @dev M-7 FIX: Includes dust tracking and sweep functionality to handle rounding in reward distributions.
abstract contract RewardsManager is DelegationManagerLib {
    using SafeERC20 for IERC20;
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when dust is accumulated from rounding
    event DustAccumulated(address indexed token, uint256 amount, uint256 totalDust);

    /// @notice Emitted when accumulated dust is swept to treasury
    event DustSwept(address indexed token, address indexed recipient, uint256 amount);
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
        uint256[] memory blueprintShares,
        uint16 lockMultiplierBps
    ) internal override {
        bytes32 assetHash = _assetHash(asset);
        uint256[] memory blueprintAmounts = new uint256[](0);
        if (selectionMode == Types.BlueprintSelectionMode.All) {
            // All mode: use the operator's main pool (exposed to ALL blueprints)
            _updateAllModePool(delegator, operator, assetHash, shares, amount, isIncrease);
        } else {
            blueprintAmounts = new uint256[](blueprintIds.length);
            if (blueprintIds.length != blueprintShares.length) {
                revert DelegationErrors.InvalidBlueprintShares();
            }

            if (isIncrease) {
                uint256 remaining = amount;
                for (uint256 i = 0; i < blueprintIds.length; i++) {
                    uint256 amountForBlueprint = i == blueprintIds.length - 1
                        ? remaining
                        : amount / blueprintIds.length;
                    remaining -= amountForBlueprint;
                    blueprintAmounts[i] = amountForBlueprint;
                }
            } else {
                for (uint256 i = 0; i < blueprintIds.length; i++) {
                    blueprintAmounts[i] = _sharesToAmountForBlueprint(
                        operator,
                        blueprintIds[i],
                        assetHash,
                        blueprintShares[i]
                    );
                }
            }
            // Fixed mode: update per-blueprint pools for selected blueprints only
            _updateFixedModePools(
                delegator,
                operator,
                assetHash,
                shares,
                amount,
                isIncrease,
                blueprintIds,
                blueprintShares,
                blueprintAmounts
            );
        }

        // Notify external rewards manager for TNT incentives (if configured)
        _notifyExternalRewardsManager(delegator, operator, asset, amount, isIncrease, lockMultiplierBps);

        // Notify external service-fee distributor for multi-token fee accrual (if configured)
        _notifyServiceFeeDistributor(
            delegator,
            operator,
            asset,
            amount,
            isIncrease,
            selectionMode,
            blueprintIds,
            blueprintAmounts,
            lockMultiplierBps
        );
    }

    /// @notice Update reward pool for All mode delegations
    /// @dev All mode delegators are exposed to rewards/slashes from ALL operator blueprints
    function _updateAllModePool(
        address /* delegator */,
        address operator,
        bytes32 assetHash,
        uint256 shares,
        uint256 amount,
        bool isIncrease
    ) internal {
        Types.OperatorRewardPool storage pool = _rewardPools[operator][assetHash];
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
        bytes32 assetHash,
        uint256 /* shares */,
        uint256 amount,
        bool isIncrease,
        uint64[] memory blueprintIds,
        uint256[] memory blueprintShares,
        uint256[] memory blueprintAmounts
    ) internal {
        if (blueprintIds.length == 0) return;

        if (blueprintIds.length != blueprintShares.length || blueprintIds.length != blueprintAmounts.length) {
            revert DelegationErrors.InvalidBlueprintShares();
        }

        uint256 remaining = amount;
        for (uint256 i = 0; i < blueprintIds.length; i++) {
            uint64 blueprintId = blueprintIds[i];
            Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId][assetHash];

            uint256 sharesForBlueprint = blueprintShares[i];
            uint256 amountForBlueprint = blueprintAmounts[i];
            if (isIncrease && i == blueprintIds.length - 1) {
                amountForBlueprint = remaining;
            }
            if (isIncrease) {
                remaining -= amountForBlueprint;
            }

            // Update pool
            if (isIncrease) {
                pool.totalShares += sharesForBlueprint;
                pool.totalAssets += amountForBlueprint;
            } else {
                pool.totalShares = sharesForBlueprint > pool.totalShares ? 0 : pool.totalShares - sharesForBlueprint;
                pool.totalAssets = amountForBlueprint > pool.totalAssets ? 0 : pool.totalAssets - amountForBlueprint;
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
        uint256[] memory blueprintAmounts,
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
            blueprintAmounts,
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
        bytes32 bondHash = _operatorBondToken == address(0)
            ? _assetHash(Types.Asset(Types.AssetKind.Native, address(0)))
            : _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));
        return _rewardPools[operator][bondHash];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // M-7 FIX: DUST MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Accumulate dust from rounding in reward calculations
    /// @dev Called internally when rounding produces leftover amounts
    /// @param token The token address (address(0) for native)
    /// @param amount The dust amount to accumulate
    function _accumulateDust(address token, uint256 amount) internal {
        if (amount == 0) return;
        _accumulatedDust[token] += amount;
        emit DustAccumulated(token, amount, _accumulatedDust[token]);
    }

    /// @notice Get accumulated dust for a token
    /// @param token The token address (address(0) for native)
    /// @return The accumulated dust amount
    function getAccumulatedDust(address token) external view returns (uint256) {
        return _accumulatedDust[token];
    }

    /// @notice Sweep accumulated dust to a recipient (admin only)
    /// @dev This function should be called by an admin facet that checks ADMIN_ROLE
    /// @param token The token address (address(0) for native)
    /// @param recipient The address to receive the dust
    /// @return amount The amount of dust swept
    function _sweepDust(address token, address recipient) internal returns (uint256 amount) {
        amount = _accumulatedDust[token];
        if (amount == 0) return 0;

        _accumulatedDust[token] = 0;

        if (token == address(0)) {
            (bool success,) = payable(recipient).call{value: amount}("");
            if (!success) revert DelegationErrors.TransferFailed();
        } else {
            IERC20(token).safeTransfer(recipient, amount);
        }

        emit DustSwept(token, recipient, amount);
    }

    /// @notice M-7 FIX: Calculate proportional shares for batch distribution with dust tracking
    /// @dev Calculates amount per recipient based on shares, accumulates dust from rounding.
    ///      Uses floor division for N-1 recipients, remainder to final recipient.
    /// @param totalAmount Total amount to distribute
    /// @param shares Array of shares for each recipient
    /// @param totalShares Sum of all shares
    /// @param token Token address for dust tracking (address(0) for native)
    /// @return amounts Array of amounts for each recipient (includes dust for final)
    function _calculateBatchDistribution(
        uint256 totalAmount,
        uint256[] memory shares,
        uint256 totalShares,
        address token
    ) internal returns (uint256[] memory amounts) {
        if (shares.length == 0 || totalShares == 0 || totalAmount == 0) {
            return new uint256[](shares.length);
        }

        amounts = new uint256[](shares.length);
        uint256 distributed = 0;

        for (uint256 i = 0; i < shares.length; i++) {
            if (i == shares.length - 1) {
                // M-7 FIX: Final recipient gets remainder to capture all rounding dust
                amounts[i] = totalAmount - distributed;
            } else {
                // Floor division for all but last recipient
                amounts[i] = (totalAmount * shares[i]) / totalShares;
                distributed += amounts[i];
            }
        }

        // Track any dust that would be lost in integer division (for accounting purposes)
        // Note: In the above logic, dust is given to the final recipient, so this is informational
        uint256 theoreticalSum = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            theoreticalSum += (totalAmount * shares[i]) / totalShares;
        }
        uint256 dust = totalAmount - theoreticalSum;
        if (dust > 0) {
            // Emit event for tracking but don't accumulate (final recipient gets it)
            emit DustAccumulated(token, dust, _accumulatedDust[token]);
        }

        return amounts;
    }

    /// @notice M-7 FIX: Distribute rewards with explicit dust handling
    /// @dev For cases where dust should accumulate in protocol rather than going to last recipient
    /// @param totalAmount Total amount to distribute
    /// @param shares Array of shares for each recipient
    /// @param totalShares Sum of all shares
    /// @param token Token address for dust tracking
    /// @return amounts Array of amounts for each recipient
    /// @return dustAmount Amount of dust accumulated
    function _calculateBatchDistributionWithDustAccumulation(
        uint256 totalAmount,
        uint256[] memory shares,
        uint256 totalShares,
        address token
    ) internal returns (uint256[] memory amounts, uint256 dustAmount) {
        if (shares.length == 0 || totalShares == 0 || totalAmount == 0) {
            return (new uint256[](shares.length), 0);
        }

        amounts = new uint256[](shares.length);
        uint256 distributed = 0;

        // Use floor division for all recipients
        for (uint256 i = 0; i < shares.length; i++) {
            amounts[i] = (totalAmount * shares[i]) / totalShares;
            distributed += amounts[i];
        }

        // M-7 FIX: Accumulate dust from rounding
        dustAmount = totalAmount - distributed;
        if (dustAmount > 0) {
            _accumulateDust(token, dustAmount);
        }

        return (amounts, dustAmount);
    }
}
