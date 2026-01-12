// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { DelegationErrors } from "./DelegationErrors.sol";
import { OperatorManager } from "./OperatorManager.sol";
import { Types } from "../libraries/Types.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";

/// @title DelegationManagerLib
/// @notice Manages delegation of deposits to operators using share-based accounting
/// @dev Uses ERC4626-style shares for O(1) slashing. Shares represent ownership
///      of the operator's delegation pool. Exchange rate = totalAssets / totalShares.
abstract contract DelegationManagerLib is OperatorManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event Delegated(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 amount,                 // The actual ETH/token amount deposited
        uint256 shares,                 // The shares received
        Types.BlueprintSelectionMode selectionMode
    );
    event DelegatorUnstakeScheduled(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 shares,                 // Shares scheduled for unstake
        uint256 estimatedAmount,        // Estimated amount at current rate
        uint64 readyRound
    );
    event DelegatorUnstakeExecuted(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 shares,                 // Shares burned
        uint256 amount                  // Actual amount returned
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE CONVERSION HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Convert an asset amount to shares (for depositing)
    /// @dev Like ERC4626.convertToShares - rounds DOWN to protect the pool
    /// @param operator The operator's pool
    /// @param amount The asset amount to convert
    /// @return shares The number of shares
    function _amountToShares(address operator, uint256 amount) internal view returns (uint256 shares) {
        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        if (pool.totalShares == 0 || pool.totalAssets == 0) {
            // First deposit: 1:1 ratio
            return amount;
        }
        // shares = amount * totalShares / totalAssets (rounds down)
        shares = (amount * pool.totalShares) / pool.totalAssets;
        if (shares == 0) {
            // Prevent dust amounts from getting stuck by ensuring a minimum share is minted
            shares = 1;
        }
    }

    /// @notice Convert shares to asset amount (for withdrawing)
    /// @dev Like ERC4626.convertToAssets - rounds DOWN to protect the pool
    /// @param operator The operator's pool
    /// @param shares The number of shares to convert
    /// @return amount The asset amount
    function _sharesToAmount(address operator, uint256 shares) internal view returns (uint256 amount) {
        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        if (pool.totalShares == 0) {
            return 0;
        }
        // amount = shares * totalAssets / totalShares (rounds down)
        return (shares * pool.totalAssets) / pool.totalShares;
    }

    /// @notice Get the current exchange rate (scaled by PRECISION)
    /// @param operator The operator's pool
    /// @return rate Exchange rate: assets per share * PRECISION
    function _getExchangeRate(address operator) internal view returns (uint256 rate) {
        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        if (pool.totalShares == 0) {
            return PRECISION; // 1:1 for empty pool
        }
        return (pool.totalAssets * PRECISION) / pool.totalShares;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delegate native tokens to an operator (simple interface)
    /// @param operator Operator to delegate to
    /// @param amount Amount to delegate
    function _delegateNative(address operator, uint256 amount) internal {
        _delegate(
            operator,
            Types.Asset(Types.AssetKind.Native, address(0)),
            amount,
            Types.BlueprintSelectionMode.All,
            new uint64[](0)
        );
    }

    /// @notice Delegate with full options
    /// @param operator Operator to delegate to
    /// @param token Token address (address(0) for native)
    /// @param amount Amount to delegate
    /// @param selectionMode Blueprint selection mode
    /// @param blueprintIds Blueprint IDs for Fixed mode
    function _delegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] memory blueprintIds
    ) internal {
        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        _delegate(operator, asset, amount, selectionMode, blueprintIds);
    }

    /// @notice Internal delegation logic with share-based accounting
    function _delegate(
        address operator,
        Types.Asset memory asset,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] memory blueprintIds
    ) internal {
        if (amount == 0) revert DelegationErrors.ZeroAmount();

        // Enforce invariant: "All blueprints" is a distinct mode from "Fixed".
        // - All mode must not provide a blueprint list (future blueprints included).
        // - Fixed mode must provide at least one blueprint (empty would mean "none").
        if (selectionMode == Types.BlueprintSelectionMode.All) {
            if (blueprintIds.length != 0) revert DelegationErrors.AllModeDisallowsBlueprints();
        } else {
            if (blueprintIds.length == 0) revert DelegationErrors.FixedModeRequiresBlueprints();
        }

        // Must be registered operator
        if (!_operators.contains(operator)) {
            revert DelegationErrors.OperatorNotRegistered(operator);
        }

        Types.OperatorMetadata storage opMeta = _operatorMetadata[operator];
        if (opMeta.status != Types.OperatorStatus.Active) {
            revert DelegationErrors.OperatorNotActive(operator);
        }

        bytes32 assetHash = _assetHash(asset);
        Types.Deposit storage dep = _deposits[msg.sender][assetHash];

        uint256 available = dep.amount - dep.delegatedAmount;
        if (available < amount) {
            revert DelegationErrors.InsufficientDeposit(available, amount);
        }

        // Convert amount to shares BEFORE updating pool
        uint256 shares = _amountToShares(operator, amount);
        if (shares == 0) revert DelegationErrors.ZeroAmount(); // Protection against rounding to 0

        // Update deposit tracking (in amounts, not shares)
        dep.delegatedAmount += amount;

        _upsertDelegationPosition(operator, asset, assetHash, shares, selectionMode, blueprintIds);

        // Update reward pool - pass shares, amount, and selection mode for proper pool routing
        uint16 lockMultiplierBps = _calculateLockMultiplierBps(msg.sender, assetHash, dep.delegatedAmount, amount);

        _onDelegationChanged(
            msg.sender,
            operator,
            asset,
            shares,
            amount,
            true,
            selectionMode,
            blueprintIds,
            lockMultiplierBps
        );

        emit Delegated(msg.sender, operator, asset.token, amount, shares, selectionMode);
    }

    function _upsertDelegationPosition(
        address operator,
        Types.Asset memory asset,
        bytes32 assetHash,
        uint256 shares,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] memory blueprintIds
    ) private {
        Types.BondInfoDelegator[] storage delegations = _delegations[msg.sender];

        for (uint256 i = 0; i < delegations.length; i++) {
            Types.BondInfoDelegator storage d = delegations[i];
            if (d.operator != operator || _assetHash(d.asset) != assetHash) continue;
            if (d.selectionMode != selectionMode) revert DelegationErrors.SelectionModeMismatch();

            d.shares += shares;
            if (selectionMode == Types.BlueprintSelectionMode.Fixed) {
                uint64[] storage bpsExisting = _delegationBlueprints[msg.sender][i];
                _increaseDelegatorBlueprintSharesFromStorage(msg.sender, operator, bpsExisting, shares);
            }
            return;
        }

        uint256 idx = delegations.length;
        delegations.push(
            Types.BondInfoDelegator({ operator: operator, shares: shares, asset: asset, selectionMode: selectionMode })
        );

        if (selectionMode == Types.BlueprintSelectionMode.All) {
            _delegationIsAllMode[msg.sender][operator][idx] = true;
        } else {
            _delegationBlueprints[msg.sender][idx] = blueprintIds;
            _increaseDelegatorBlueprintSharesFromMemory(msg.sender, operator, blueprintIds, shares);
        }

        _operatorMetadata[operator].delegationCount++;
        _addOperatorDelegator(operator, msg.sender);
    }

    function _addOperatorDelegator(address operator, address delegator) private {
        _operatorDelegators[operator].add(delegator);
    }

    function _increaseDelegatorBlueprintSharesFromMemory(
        address delegator,
        address operator,
        uint64[] memory blueprintIds,
        uint256 shares
    ) private {
        uint256 sharesPerBlueprint = blueprintIds.length > 0 ? shares / blueprintIds.length : 0;
        for (uint256 i = 0; i < blueprintIds.length; i++) {
            _delegatorBlueprintShares[delegator][operator][blueprintIds[i]] += sharesPerBlueprint;
        }
    }

    function _increaseDelegatorBlueprintSharesFromStorage(
        address delegator,
        address operator,
        uint64[] storage blueprintIds,
        uint256 shares
    ) private {
        uint256 sharesPerBlueprint = blueprintIds.length > 0 ? shares / blueprintIds.length : 0;
        for (uint256 i = 0; i < blueprintIds.length; i++) {
            _delegatorBlueprintShares[delegator][operator][blueprintIds[i]] += sharesPerBlueprint;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UNDELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Schedule undelegation of native tokens
    /// @param operator Operator to undelegate from
    /// @param amount Amount to undelegate (at current exchange rate)
    function _undelegateNative(address operator, uint256 amount) internal {
        _scheduleDelegatorUnstake(operator, address(0), amount);
    }

    /// @notice Schedule undelegation
    /// @param operator Operator to undelegate from
    /// @param token Token address
    /// @param amount Amount to undelegate (at current exchange rate)
    function _scheduleDelegatorUnstake(
        address operator,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) revert DelegationErrors.ZeroAmount();

        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        bytes32 assetHash = _assetHash(asset);

        // Convert requested amount to shares at current exchange rate
        Types.OperatorRewardPool storage pool = _rewardPools[operator];
        uint256 sharesToUnstake;
        if (pool.totalAssets == 0 || pool.totalShares == 0) {
            sharesToUnstake = amount;
        } else {
            // shares = amount * totalShares / totalAssets (round UP to ensure user gets at least 'amount')
            sharesToUnstake = (amount * pool.totalShares + pool.totalAssets - 1) / pool.totalAssets;
        }

        // Find delegation
        bool found = false;
        for (uint256 i = 0; i < _delegations[msg.sender].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[msg.sender][i];
            if (d.operator == operator && _assetHash(d.asset) == assetHash) {
                // Calculate available shares (not already scheduled for unstake)
                uint256 pendingUnstakeShares = _getPendingUnstakeShares(msg.sender, operator, assetHash);
                uint256 availableShares = d.shares - pendingUnstakeShares;

                if (availableShares < sharesToUnstake) {
                    // Convert to amount for error message
                    uint256 availableAmount = _sharesToAmount(operator, availableShares);
                    revert DelegationErrors.InsufficientDelegation(availableAmount, amount);
                }

                _unstakeRequests[msg.sender].push(Types.BondLessRequest({
                    operator: operator,
                    asset: asset,
                    shares: sharesToUnstake,  // Store shares, not amount
                    requestedRound: currentRound,
                    selectionMode: d.selectionMode,
                    slashFactorSnapshot: getOperatorSlashFactor(operator)
                }));

                found = true;
                emit DelegatorUnstakeScheduled(
                    msg.sender,
                    operator,
                    token,
                    sharesToUnstake,
                    amount,  // Estimated amount at request time
                    currentRound + delegationBondLessDelay
                );
                break;
            }
        }

        if (!found) {
            revert DelegationErrors.DelegationNotFound(msg.sender, operator);
        }
    }

    /// @notice Execute pending unstakes
    /// @return totalUnstaked Total amount unstaked (in underlying assets)
    function _executeDelegatorUnstake() internal returns (uint256 totalUnstaked) {
        Types.BondLessRequest[] storage requests = _unstakeRequests[msg.sender];
        uint256 i = 0;

        while (i < requests.length) {
            Types.BondLessRequest storage req = requests[i];

            if (currentRound >= req.requestedRound + delegationBondLessDelay) {
                bytes32 assetHash = _assetHash(req.asset);

                // Convert shares to amount at CURRENT exchange rate (may differ from request time)
                uint256 amountToReturn = _sharesToAmount(req.operator, req.shares);

                // Apply lazy slashing: reduce amount if slashes occurred since request
                amountToReturn = _applyLazySlash(
                    amountToReturn,
                    req.slashFactorSnapshot,
                    getOperatorSlashFactor(req.operator)
                );

                // Update delegation
                for (uint256 j = 0; j < _delegations[msg.sender].length; j++) {
                    Types.BondInfoDelegator storage d = _delegations[msg.sender][j];
                    if (d.operator == req.operator && _assetHash(d.asset) == assetHash) {
                        // Get blueprint info for the hook
                        uint64[] memory blueprintIds = d.selectionMode == Types.BlueprintSelectionMode.Fixed
                            ? _delegationBlueprints[msg.sender][j]
                            : new uint64[](0);

                        // Update blueprint shares for Fixed mode
                        if (d.selectionMode == Types.BlueprintSelectionMode.Fixed && blueprintIds.length > 0) {
                            uint256 sharesPerBlueprint = req.shares / blueprintIds.length;
                            for (uint256 k = 0; k < blueprintIds.length; k++) {
                                uint256 currentBpShares = _delegatorBlueprintShares[msg.sender][req.operator][blueprintIds[k]];
                                _delegatorBlueprintShares[msg.sender][req.operator][blueprintIds[k]] =
                                    sharesPerBlueprint > currentBpShares ? 0 : currentBpShares - sharesPerBlueprint;
                            }
                        }

                        // Notify rewards manager before changing shares
                        _onDelegationChanged(
                            msg.sender,
                            req.operator,
                            req.asset,
                            req.shares,
                            amountToReturn,
                            false,
                            d.selectionMode,
                            blueprintIds,
                            _getLockMultiplierBps(Types.LockMultiplier.None)
                        );

                        d.shares -= req.shares;

                        // Update deposit (with actual amount returned)
                        Types.Deposit storage dep = _deposits[msg.sender][assetHash];
                        // Cap at delegatedAmount to handle slashing edge cases
                        uint256 depReduction = amountToReturn > dep.delegatedAmount
                            ? dep.delegatedAmount
                            : amountToReturn;
                        dep.delegatedAmount -= depReduction;

                        // Remove delegation if zero shares
                        if (d.shares == 0) {
                            _operatorMetadata[req.operator].delegationCount--;
                            // Swap and pop
                            _delegations[msg.sender][j] = _delegations[msg.sender][_delegations[msg.sender].length - 1];
                            _delegations[msg.sender].pop();
                            // Remove from operator's delegator set if no remaining delegations
                            if (_getDelegatorSharesForOperator(msg.sender, req.operator) == 0) {
                                _operatorDelegators[req.operator].remove(msg.sender);
                            }
                        }
                        break;
                    }
                }

                totalUnstaked += amountToReturn;
                emit DelegatorUnstakeExecuted(msg.sender, req.operator, req.asset.token, req.shares, amountToReturn);

                // Remove processed request
                requests[i] = requests[requests.length - 1];
                requests.pop();
            } else {
                i++;
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get all delegations for a delegator (returns shares, use _sharesToAmount for values)
    function _getDelegations(
        address delegator
    ) internal view returns (Types.BondInfoDelegator[] memory) {
        return _delegations[delegator];
    }

    /// @notice Get delegation blueprints for Fixed mode
    function _getDelegationBlueprints(
        address delegator,
        uint256 delegationIndex
    ) internal view returns (uint64[] memory) {
        return _delegationBlueprints[delegator][delegationIndex];
    }

    /// @notice Get total delegation across all operators (in underlying amounts)
    function _getTotalDelegation(address delegator) internal view returns (uint256 total) {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            total += _sharesToAmount(d.operator, d.shares);
        }
    }

    /// @notice Get operator's total delegated stake (in underlying assets)
    function _getOperatorDelegatedStake(address operator) internal view returns (uint256) {
        return _rewardPools[operator].totalAssets;
    }

    /// @notice Get operator's total stake (self + delegated, in underlying assets)
    function _getOperatorTotalStake(address operator) internal view returns (uint256) {
        return _operatorMetadata[operator].stake + _rewardPools[operator].totalAssets;
    }

    /// @notice Get all delegators for an operator
    function _getOperatorDelegators(address operator) internal view returns (address[] memory delegators) {
        uint256 count = _operatorDelegators[operator].length();
        delegators = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            delegators[i] = _operatorDelegators[operator].at(i);
        }
    }

    /// @notice Get the number of delegators for an operator
    function _getOperatorDelegatorCount(address operator) internal view returns (uint256) {
        return _operatorDelegators[operator].length();
    }

    /// @notice Get pending unstake requests (returns shares)
    function _getPendingUnstakes(
        address delegator
    ) internal view returns (Types.BondLessRequest[] memory) {
        return _unstakeRequests[delegator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get delegator's shares for a specific operator
    function _getDelegatorSharesForOperator(
        address delegator,
        address operator
    ) internal view returns (uint256 totalShares) {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            if (_delegations[delegator][i].operator == operator) {
                totalShares += _delegations[delegator][i].shares;
            }
        }
    }

    /// @notice Get total delegation to a specific operator (in underlying amount)
    /// @dev Converts shares to amount at current exchange rate, handling both All and Fixed modes
    function _getDelegationToOperator(
        address delegator,
        address operator
    ) internal view returns (uint256 totalAmount) {
        // Need to calculate separately for All mode vs Fixed mode delegations
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            if (d.operator != operator) continue;

            if (d.selectionMode == Types.BlueprintSelectionMode.All) {
                // All mode: use main pool exchange rate
                totalAmount += _sharesToAmount(operator, d.shares);
            } else {
                // Fixed mode: use blueprint pool exchange rates
                uint64[] storage blueprints = _delegationBlueprints[delegator][i];
                for (uint256 j = 0; j < blueprints.length; j++) {
                    uint256 bpShares = _delegatorBlueprintShares[delegator][operator][blueprints[j]];
                    totalAmount += _sharesToAmountForBlueprint(operator, blueprints[j], bpShares);
                }
            }
        }
    }

    /// @notice Convert shares to amount for a specific blueprint pool
    function _sharesToAmountForBlueprint(
        address operator,
        uint64 blueprintId,
        uint256 shares
    ) internal view returns (uint256 amount) {
        Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId];
        if (pool.totalShares == 0) {
            return shares; // 1:1 ratio for empty pool
        }
        return (shares * pool.totalAssets) / pool.totalShares;
    }

    /// @notice Get pending unstake shares for a specific delegation
    function _getPendingUnstakeShares(
        address delegator,
        address operator,
        bytes32 assetHash
    ) internal view returns (uint256 pendingShares) {
        Types.BondLessRequest[] storage requests = _unstakeRequests[delegator];
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].operator == operator && _assetHash(requests[i].asset) == assetHash) {
                pendingShares += requests[i].shares;
            }
        }
    }

    function _getActiveLockTotals(
        address delegator,
        bytes32 assetHash
    ) internal view returns (uint256 lockedAmount, uint256 weightedBpsSum) {
        Types.LockInfo[] storage locks = _depositLocks[delegator][assetHash];
        for (uint256 i = 0; i < locks.length; i++) {
            Types.LockInfo storage info = locks[i];
            if (info.expiryBlock > block.number) {
                uint16 lockBps = _getLockMultiplierBps(info.multiplier);
                lockedAmount += info.amount;
                weightedBpsSum += Math.mulDiv(info.amount, lockBps, 1);
            }
        }
    }

    function _calculateLockMultiplierBps(
        address delegator,
        bytes32 assetHash,
        uint256 delegatedAfter,
        uint256 amount
    ) internal view returns (uint16) {
        if (amount == 0) {
            return _getLockMultiplierBps(Types.LockMultiplier.None);
        }

        (uint256 lockedAmount, uint256 weightedBpsSum) = _getActiveLockTotals(delegator, assetHash);
        if (lockedAmount == 0) {
            return _getLockMultiplierBps(Types.LockMultiplier.None);
        }

        uint256 delegatedBefore = delegatedAfter >= amount ? delegatedAfter - amount : 0;
        uint256 lockedUsedBefore = delegatedBefore < lockedAmount ? delegatedBefore : lockedAmount;
        uint256 lockedAvailable = lockedAmount > lockedUsedBefore ? lockedAmount - lockedUsedBefore : 0;
        uint256 lockedPortion = amount < lockedAvailable ? amount : lockedAvailable;
        if (lockedPortion == 0) {
            return _getLockMultiplierBps(Types.LockMultiplier.None);
        }

        uint256 avgLockedBps = weightedBpsSum / lockedAmount;
        uint256 baseBps = _getLockMultiplierBps(Types.LockMultiplier.None);
        uint256 numerator = lockedPortion * avgLockedBps + (amount - lockedPortion) * baseBps;
        return uint16(numerator / amount);
    }

    /// @notice Hook for rewards manager to update on delegation changes
    /// @dev Override in RewardsManager. Supports both All and Fixed blueprint selection modes.
    /// @param delegator The delegator address
    /// @param operator The operator address
    /// @param shares Number of shares changing
    /// @param amount The underlying amount (for totalAssets tracking)
    /// @param isIncrease True if adding, false if removing
    /// @param selectionMode Blueprint selection mode (All or Fixed)
    /// @param blueprintIds Blueprint IDs for Fixed mode (empty for All mode)
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
    ) internal virtual;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT FOR DELEGATORS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintAddedToDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);
    event BlueprintRemovedFromDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);

    /// @notice Add a blueprint to a Fixed mode delegation
    /// @dev Only works for Fixed mode delegations. Liquid vaults are safe because
    ///      vault depositors don't have separate delegations - the vault is the delegator.
    /// @param delegationIndex The index of the delegation in the delegator's array
    /// @param blueprintId The blueprint ID to add
    function _addBlueprintToDelegation(uint256 delegationIndex, uint64 blueprintId) internal {
        if (delegationIndex >= _delegations[msg.sender].length) {
            revert DelegationErrors.InvalidDelegationIndex(delegationIndex);
        }

        Types.BondInfoDelegator storage d = _delegations[msg.sender][delegationIndex];

        // Only Fixed mode delegations can modify blueprints
        if (d.selectionMode != Types.BlueprintSelectionMode.Fixed) {
            revert DelegationErrors.NotFixedMode();
        }

        uint64[] storage blueprints = _delegationBlueprints[msg.sender][delegationIndex];

        // Check if blueprint already selected
        for (uint256 i = 0; i < blueprints.length; i++) {
            if (blueprints[i] == blueprintId) {
                revert DelegationErrors.BlueprintAlreadySelected(blueprintId);
            }
        }

        // Calculate current shares per blueprint before adding
        uint256 oldBlueprintCount = blueprints.length;
        uint256 newSharesPerBlueprint = d.shares / (oldBlueprintCount + 1);

        // Reduce existing blueprint shares and pool tracking proportionally
        if (oldBlueprintCount > 0) {
            uint256 currentSharesPerBlueprint = d.shares / oldBlueprintCount;
            uint256 sharesToRedistribute = currentSharesPerBlueprint - newSharesPerBlueprint;

            for (uint256 i = 0; i < blueprints.length; i++) {
                uint64 bpId = blueprints[i];
                uint256 currentShares = _delegatorBlueprintShares[msg.sender][d.operator][bpId];
                uint256 reduction = sharesToRedistribute > currentShares ? currentShares : sharesToRedistribute;

                // Update delegator's shares for this blueprint
                _delegatorBlueprintShares[msg.sender][d.operator][bpId] = currentShares - reduction;

                // Update the blueprint pool
                Types.OperatorRewardPool storage oldPool = _blueprintPools[d.operator][bpId];
                if (oldPool.totalShares >= reduction) {
                    oldPool.totalShares -= reduction;
                    // Calculate proportional asset reduction
                    uint256 assetReduction = oldPool.totalAssets > 0 && oldPool.totalShares > 0
                        ? (reduction * oldPool.totalAssets) / (oldPool.totalShares + reduction)
                        : reduction;
                    oldPool.totalAssets = assetReduction > oldPool.totalAssets ? 0 : oldPool.totalAssets - assetReduction;
                }
            }
        }

        // Add new blueprint with its share
        _delegatorBlueprintShares[msg.sender][d.operator][blueprintId] = newSharesPerBlueprint;

        // Update the new blueprint's pool
        Types.OperatorRewardPool storage newPool = _blueprintPools[d.operator][blueprintId];
        newPool.totalShares += newSharesPerBlueprint;
        // Calculate proportional asset addition (use 1:1 if first deposit)
        uint256 assetAddition = newPool.totalShares == newSharesPerBlueprint
            ? newSharesPerBlueprint  // First deposit: 1:1
            : (newSharesPerBlueprint * newPool.totalAssets) / (newPool.totalShares - newSharesPerBlueprint);
        newPool.totalAssets += assetAddition;

        // Add the blueprint
        blueprints.push(blueprintId);

        emit BlueprintAddedToDelegation(msg.sender, delegationIndex, blueprintId);

        if (_serviceFeeDistributor != address(0)) {
            try IServiceFeeDistributor(_serviceFeeDistributor).onBlueprintAdded(
                msg.sender,
                d.operator,
                d.asset,
                blueprintId
            ) {} catch {}
        }
    }

    /// @notice Remove a blueprint from a Fixed mode delegation
    /// @dev Only works for Fixed mode delegations. Cannot remove the last blueprint.
    ///      Liquid vaults are safe because vault depositors don't have separate delegations.
    /// @param delegationIndex The index of the delegation in the delegator's array
    /// @param blueprintId The blueprint ID to remove
    function _removeBlueprintFromDelegation(uint256 delegationIndex, uint64 blueprintId) internal {
        if (delegationIndex >= _delegations[msg.sender].length) {
            revert DelegationErrors.InvalidDelegationIndex(delegationIndex);
        }

        Types.BondInfoDelegator storage d = _delegations[msg.sender][delegationIndex];

        // Only Fixed mode delegations can modify blueprints
        if (d.selectionMode != Types.BlueprintSelectionMode.Fixed) {
            revert DelegationErrors.NotFixedMode();
        }

        uint64[] storage blueprints = _delegationBlueprints[msg.sender][delegationIndex];

        // Cannot remove last blueprint (would make delegation undefined)
        if (blueprints.length <= 1) {
            revert DelegationErrors.CannotRemoveLastBlueprint();
        }

        // Find the blueprint
        uint256 foundIndex = type(uint256).max;
        for (uint256 i = 0; i < blueprints.length; i++) {
            if (blueprints[i] == blueprintId) {
                foundIndex = i;
                break;
            }
        }

        if (foundIndex == type(uint256).max) {
            revert DelegationErrors.BlueprintNotSelected(blueprintId);
        }

        // Get shares being freed from this blueprint
        uint256 freedShares = _delegatorBlueprintShares[msg.sender][d.operator][blueprintId];

        // Remove the blueprint's shares
        delete _delegatorBlueprintShares[msg.sender][d.operator][blueprintId];

        // Redistribute freed shares to remaining blueprints
        uint256 remainingCount = blueprints.length - 1;
        uint256 sharesPerRemaining = freedShares / remainingCount;

        // Swap and pop to remove the blueprint
        blueprints[foundIndex] = blueprints[blueprints.length - 1];
        blueprints.pop();

        // Add redistributed shares to remaining blueprints
        for (uint256 i = 0; i < blueprints.length; i++) {
            _delegatorBlueprintShares[msg.sender][d.operator][blueprints[i]] += sharesPerRemaining;
        }

        emit BlueprintRemovedFromDelegation(msg.sender, delegationIndex, blueprintId);

        if (_serviceFeeDistributor != address(0)) {
            try IServiceFeeDistributor(_serviceFeeDistributor).onBlueprintRemoved(
                msg.sender,
                d.operator,
                d.asset,
                blueprintId
            ) {} catch {}
        }
    }
}
