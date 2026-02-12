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
    using EnumerableSet for EnumerableSet.UintSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event Delegated(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 amount, // The actual ETH/token amount deposited
        uint256 shares, // The shares received
        Types.BlueprintSelectionMode selectionMode
    );
    event DelegatorUnstakeScheduled(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 shares, // Shares scheduled for unstake
        uint256 estimatedAmount, // Estimated amount at current rate
        uint64 readyRound
    );
    event DelegatorUnstakeExecuted(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 shares, // Shares burned
        uint256 amount // Actual amount returned
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE CONVERSION HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Convert an asset amount to shares (for depositing)
    /// @dev Like ERC4626.convertToShares - rounds DOWN to protect the pool
    ///      C-1 FIX: Uses virtual shares/assets offset to prevent first depositor inflation attack.
    ///      The formula: shares = amount * (totalShares + VIRTUAL_SHARES) / (totalAssets + VIRTUAL_ASSETS)
    ///      ensures that even for empty pools, the exchange rate is well-defined and resistant
    ///      to manipulation via donation attacks.
    /// @param operator The operator's pool
    /// @param assetHash Asset hash for the pool
    /// @param amount The asset amount to convert
    /// @return shares The number of shares
    function _amountToShares(
        address operator,
        bytes32 assetHash,
        uint256 amount
    )
        internal
        view
        returns (uint256 shares)
    {
        Types.OperatorRewardPool storage pool = _rewardPools[operator][assetHash];
        // C-1 FIX: Use virtual offset to prevent inflation attack
        // This works even for empty pools (totalShares=0, totalAssets=0)
        shares = (amount * (pool.totalShares + VIRTUAL_SHARES)) / (pool.totalAssets + VIRTUAL_ASSETS);
    }

    /// @notice Convert shares to asset amount (for withdrawing)
    /// @dev Like ERC4626.convertToAssets - rounds DOWN to protect the pool
    ///      C-1 FIX: Uses virtual shares/assets offset to prevent inflation attack.
    /// @param operator The operator's pool
    /// @param assetHash Asset hash for the pool
    /// @param shares The number of shares to convert
    /// @return amount The asset amount
    function _sharesToAmount(
        address operator,
        bytes32 assetHash,
        uint256 shares
    )
        internal
        view
        returns (uint256 amount)
    {
        Types.OperatorRewardPool storage pool = _rewardPools[operator][assetHash];
        // C-1 FIX: Use virtual offset - consistent with _amountToShares
        // amount = shares * (totalAssets + VIRTUAL_ASSETS) / (totalShares + VIRTUAL_SHARES)
        return (shares * (pool.totalAssets + VIRTUAL_ASSETS)) / (pool.totalShares + VIRTUAL_SHARES);
    }

    /// @notice Get the current exchange rate (scaled by PRECISION)
    /// @dev C-1 FIX: Uses virtual offset for consistent exchange rate
    /// @param operator The operator's pool
    /// @param assetHash Asset hash for the pool
    /// @return rate Exchange rate: assets per share * PRECISION
    function _getExchangeRate(address operator, bytes32 assetHash) internal view returns (uint256 rate) {
        Types.OperatorRewardPool storage pool = _rewardPools[operator][assetHash];
        // C-1 FIX: Use virtual offset - rate is well-defined even for empty pools
        return ((pool.totalAssets + VIRTUAL_ASSETS) * PRECISION) / (pool.totalShares + VIRTUAL_SHARES);
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
    )
        internal
    {
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
    )
        internal
    {
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

        // Check delegation mode permissions
        if (!_canDelegate(operator, msg.sender)) {
            Types.DelegationMode mode = _operatorDelegationMode[operator];
            if (mode == Types.DelegationMode.Disabled) {
                revert DelegationErrors.DelegationDisabled(operator);
            } else {
                revert DelegationErrors.DelegatorNotWhitelisted(operator, msg.sender);
            }
        }

        bytes32 assetHash = _assetHash(asset);
        Types.Deposit storage dep = _deposits[msg.sender][assetHash];

        uint256 available = dep.amount - dep.delegatedAmount;
        if (available < amount) {
            revert DelegationErrors.InsufficientDeposit(available, amount);
        }

        uint256 shares = 0;
        uint256[] memory blueprintShares;
        if (selectionMode == Types.BlueprintSelectionMode.All) {
            // Convert amount to shares BEFORE updating pool
            shares = _amountToShares(operator, assetHash, amount);
            if (shares == 0) revert DelegationErrors.ZeroAmount();
        } else {
            for (uint256 i = 0; i < blueprintIds.length; i++) {
                for (uint256 j = i + 1; j < blueprintIds.length; j++) {
                    if (blueprintIds[i] == blueprintIds[j]) {
                        revert DelegationErrors.DuplicateBlueprint(blueprintIds[i]);
                    }
                }
            }
            blueprintShares = new uint256[](blueprintIds.length);
            uint256 remaining = amount;
            for (uint256 i = 0; i < blueprintIds.length; i++) {
                uint256 splitAmount = i == blueprintIds.length - 1 ? remaining : amount / blueprintIds.length;
                remaining -= splitAmount;

                uint256 bpShares = _amountToSharesForBlueprint(operator, blueprintIds[i], assetHash, splitAmount);
                if (bpShares == 0) revert DelegationErrors.ZeroAmount();
                blueprintShares[i] = bpShares;
                shares += bpShares;
            }
        }

        // Update deposit tracking (in amounts, not shares)
        dep.delegatedAmount += amount;

        _upsertDelegationPosition(operator, asset, assetHash, shares, selectionMode, blueprintIds, blueprintShares);

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
            blueprintShares,
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
        uint64[] memory blueprintIds,
        uint256[] memory blueprintShares
    )
        private
    {
        Types.BondInfoDelegator[] storage delegations = _delegations[msg.sender];

        for (uint256 i = 0; i < delegations.length; i++) {
            Types.BondInfoDelegator storage d = delegations[i];
            if (d.operator != operator || _assetHash(d.asset) != assetHash) continue;
            if (d.selectionMode != selectionMode) revert DelegationErrors.SelectionModeMismatch();

            d.shares += shares;
            if (selectionMode == Types.BlueprintSelectionMode.Fixed) {
                _increaseDelegatorBlueprintShares(msg.sender, operator, assetHash, blueprintIds, blueprintShares);
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
            _increaseDelegatorBlueprintShares(msg.sender, operator, assetHash, blueprintIds, blueprintShares);
        }

        _operatorMetadata[operator].delegationCount++;
        _addOperatorDelegator(operator, msg.sender);
    }

    function _addOperatorDelegator(address operator, address delegator) private {
        _operatorDelegators[operator].add(delegator);
    }

    function _increaseDelegatorBlueprintShares(
        address delegator,
        address operator,
        bytes32 assetHash,
        uint64[] memory blueprintIds,
        uint256[] memory blueprintShares
    )
        private
    {
        if (blueprintIds.length == 0) return;
        if (blueprintIds.length != blueprintShares.length) {
            revert DelegationErrors.InvalidBlueprintShares();
        }
        for (uint256 i = 0; i < blueprintIds.length; i++) {
            _delegatorBlueprintShares[delegator][operator][assetHash][blueprintIds[i]] += blueprintShares[i];
        }
    }

    function _setDelegatorBlueprintPosition(
        address delegator,
        address operator,
        bytes32 assetHash,
        uint64 blueprintId,
        uint256 newShares,
        uint256 newAmount
    )
        private
    {
        uint256 currentShares = _delegatorBlueprintShares[delegator][operator][assetHash][blueprintId];
        uint256 currentAmount = _sharesToAmountForBlueprint(operator, blueprintId, assetHash, currentShares);
        if (currentShares == newShares && currentAmount == newAmount) return;

        Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId][assetHash];

        if (newShares > currentShares) {
            pool.totalShares += newShares - currentShares;
        } else if (currentShares > newShares) {
            uint256 deltaShares = currentShares - newShares;
            pool.totalShares = deltaShares > pool.totalShares ? 0 : pool.totalShares - deltaShares;
        }

        if (newAmount > currentAmount) {
            pool.totalAssets += newAmount - currentAmount;
        } else if (currentAmount > newAmount) {
            uint256 deltaAmount = currentAmount - newAmount;
            pool.totalAssets = deltaAmount > pool.totalAssets ? 0 : pool.totalAssets - deltaAmount;
        }

        _delegatorBlueprintShares[delegator][operator][assetHash][blueprintId] = newShares;
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

    function _previewDelegatorUnstakeShares(
        address delegator,
        address operator,
        bytes32 assetHash,
        uint256 amount
    )
        internal
        view
        returns (uint256 sharesToUnstake, Types.BlueprintSelectionMode selectionMode)
    {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            if (d.operator != operator || _assetHash(d.asset) != assetHash) continue;

            selectionMode = d.selectionMode;

            uint256 totalAmount;
            if (selectionMode == Types.BlueprintSelectionMode.All) {
                Types.OperatorRewardPool storage pool = _rewardPools[operator][assetHash];
                if (pool.totalAssets == 0 || pool.totalShares == 0) {
                    sharesToUnstake = amount;
                } else {
                    sharesToUnstake = (amount * pool.totalShares + pool.totalAssets - 1) / pool.totalAssets;
                }
            } else {
                uint64[] storage blueprints = _delegationBlueprints[delegator][i];
                for (uint256 j = 0; j < blueprints.length; j++) {
                    uint256 bpShares = _delegatorBlueprintShares[delegator][operator][assetHash][blueprints[j]];
                    totalAmount += _sharesToAmountForBlueprint(operator, blueprints[j], assetHash, bpShares);
                }
                if (totalAmount == 0 || d.shares == 0) {
                    sharesToUnstake = amount;
                } else {
                    sharesToUnstake = (amount * d.shares + totalAmount - 1) / totalAmount;
                }
            }

            uint256 pendingUnstakeShares = _getPendingUnstakeShares(delegator, operator, assetHash);
            uint256 availableShares = d.shares - pendingUnstakeShares;

            if (availableShares < sharesToUnstake) {
                uint256 availableAmount;
                if (selectionMode == Types.BlueprintSelectionMode.All) {
                    availableAmount = _sharesToAmount(operator, assetHash, availableShares);
                } else if (d.shares > 0) {
                    availableAmount = (totalAmount * availableShares) / d.shares;
                }
                revert DelegationErrors.InsufficientDelegation(availableAmount, amount);
            }

            return (sharesToUnstake, selectionMode);
        }

        revert DelegationErrors.DelegationNotFound(delegator, operator);
    }

    /// @notice Schedule undelegation
    /// @param operator Operator to undelegate from
    /// @param token Token address
    /// @param amount Amount to undelegate (at current exchange rate)
    function _scheduleDelegatorUnstake(address operator, address token, uint256 amount) internal {
        if (amount == 0) revert DelegationErrors.ZeroAmount();

        // M-9 FIX: Block withdrawals if operator has pending slashes
        // This prevents delegators from front-running slash execution
        uint64 pendingSlashes = _operatorPendingSlashCount[operator];
        if (pendingSlashes > 0) {
            revert DelegationErrors.PendingSlashExists(operator, pendingSlashes);
        }

        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        bytes32 assetHash = _assetHash(asset);

        (uint256 sharesToUnstake, Types.BlueprintSelectionMode selectionMode) =
            _previewDelegatorUnstakeShares(msg.sender, operator, assetHash, amount);

        _unstakeRequests[msg.sender].push(
            Types.BondLessRequest({
                operator: operator,
                asset: asset,
                shares: sharesToUnstake, // Store shares, not amount
                requestedRound: currentRound,
                selectionMode: selectionMode,
                slashFactorSnapshot: 0
            })
        );

        emit DelegatorUnstakeScheduled(
            msg.sender,
            operator,
            token,
            sharesToUnstake,
            amount, // Estimated amount at request time
            currentRound + delegationBondLessDelay
        );
    }

    /// @notice Execute pending unstakes
    /// @return totalUnstaked Total amount unstaked (in underlying assets)
    function _executeDelegatorUnstake() internal returns (uint256 totalUnstaked) {
        Types.BondLessRequest[] storage requests = _unstakeRequests[msg.sender];
        uint256 i = 0;

        while (i < requests.length) {
            Types.BondLessRequest storage req = requests[i];

            // M-5 FIX: Skip requests for operators with pending slashes
            // This prevents delegators from front-running slash execution at unstake time
            if (_operatorPendingSlashCount[req.operator] > 0) {
                i++;
                continue;
            }

            if (currentRound >= req.requestedRound + delegationBondLessDelay) {
                bytes32 assetHash = _assetHash(req.asset);
                uint256 amountToReturn = 0;

                // Update delegation
                for (uint256 j = 0; j < _delegations[msg.sender].length; j++) {
                    Types.BondInfoDelegator storage d = _delegations[msg.sender][j];
                    if (d.operator == req.operator && _assetHash(d.asset) == assetHash) {
                        // Get blueprint info for the hook
                        uint64[] memory blueprintIds = d.selectionMode == Types.BlueprintSelectionMode.Fixed
                            ? _delegationBlueprints[msg.sender][j]
                            : new uint64[](0);

                        uint256[] memory blueprintShares = new uint256[](blueprintIds.length);
                        if (d.selectionMode == Types.BlueprintSelectionMode.Fixed && blueprintIds.length > 0) {
                            amountToReturn = _computeUnstakeAmountsWithBlueprints(
                                msg.sender, req, assetHash, blueprintIds, blueprintShares
                            );
                        } else {
                            amountToReturn = _sharesToAmount(req.operator, assetHash, req.shares);
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
                            blueprintShares,
                            _getLockMultiplierBps(Types.LockMultiplier.None)
                        );

                        // H-4 FIX: Protect against underflow in case slashing occurred
                        // between request time and execution. Cap shares to burn at available.
                        d.shares = req.shares > d.shares ? 0 : d.shares - req.shares;

                        // Update deposit (with actual amount returned)
                        Types.Deposit storage dep = _deposits[msg.sender][assetHash];
                        // Cap at delegatedAmount to handle slashing edge cases
                        uint256 depReduction =
                            amountToReturn > dep.delegatedAmount ? dep.delegatedAmount : amountToReturn;
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

    function _computeUnstakeAmountsWithBlueprints(
        address delegator,
        Types.BondLessRequest storage req,
        bytes32 assetHash,
        uint64[] memory blueprintIds,
        uint256[] memory blueprintShares
    )
        internal
        returns (uint256 amountToReturn)
    {
        uint256 totalBpShares = 0;
        for (uint256 k = 0; k < blueprintIds.length; k++) {
            totalBpShares += _delegatorBlueprintShares[delegator][req.operator][assetHash][blueprintIds[k]];
        }

        uint256 remainingShares = req.shares;
        for (uint256 k = 0; k < blueprintIds.length; k++) {
            uint256 currentBpShares = _delegatorBlueprintShares[delegator][req.operator][assetHash][blueprintIds[k]];
            uint256 bpShare = 0;
            if (totalBpShares > 0) {
                bpShare =
                    k == blueprintIds.length - 1 ? remainingShares : (req.shares * currentBpShares) / totalBpShares;
            } else {
                bpShare = k == blueprintIds.length - 1 ? remainingShares : req.shares / blueprintIds.length;
            }
            remainingShares = remainingShares > bpShare ? remainingShares - bpShare : 0;
            blueprintShares[k] = bpShare;
            amountToReturn += _sharesToAmountForBlueprint(req.operator, blueprintIds[k], assetHash, bpShare);

            _delegatorBlueprintShares[delegator][req.operator][assetHash][blueprintIds[k]] =
                bpShare > currentBpShares ? 0 : currentBpShares - bpShare;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get all delegations for a delegator (returns shares, use _sharesToAmount for values)
    function _getDelegations(address delegator) internal view returns (Types.BondInfoDelegator[] memory) {
        return _delegations[delegator];
    }

    /// @notice Get delegation blueprints for Fixed mode
    function _getDelegationBlueprints(
        address delegator,
        uint256 delegationIndex
    )
        internal
        view
        returns (uint64[] memory)
    {
        return _delegationBlueprints[delegator][delegationIndex];
    }

    /// @notice Get total delegation across all operators (in underlying amounts)
    function _getTotalDelegation(address delegator) internal view returns (uint256 total) {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            bytes32 assetHash = _assetHash(d.asset);
            if (d.selectionMode == Types.BlueprintSelectionMode.All) {
                total += _sharesToAmount(d.operator, assetHash, d.shares);
            } else {
                uint64[] storage blueprints = _delegationBlueprints[delegator][i];
                for (uint256 j = 0; j < blueprints.length; j++) {
                    uint256 bpShares = _delegatorBlueprintShares[delegator][d.operator][assetHash][blueprints[j]];
                    total += _sharesToAmountForBlueprint(d.operator, blueprints[j], assetHash, bpShares);
                }
            }
        }
    }

    /// @notice Get operator's total delegated stake across all assets (in underlying units per asset)
    function _getOperatorDelegatedStake(address operator) internal view returns (uint256 total) {
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        if (nativeEnabled) {
            total += _getOperatorDelegatedStakeForAsset(operator, nativeHash);
        }

        uint256 erc20Count = _enabledErc20s.length();
        for (uint256 i = 0; i < erc20Count; i++) {
            address token = _enabledErc20s.at(i);
            bytes32 assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));
            total += _getOperatorDelegatedStakeForAsset(operator, assetHash);
        }
    }

    /// @notice Get operator's total delegated stake for a specific asset
    function _getOperatorDelegatedStakeForAsset(
        address operator,
        bytes32 assetHash
    )
        internal
        view
        returns (uint256 total)
    {
        total += _rewardPools[operator][assetHash].totalAssets;

        uint256 bpCount = _operatorBlueprints[operator].length();
        for (uint256 i = 0; i < bpCount; i++) {
            uint64 blueprintId = uint64(_operatorBlueprints[operator].at(i));
            total += _blueprintPools[operator][blueprintId][assetHash].totalAssets;
        }
    }

    /// @notice Get operator's total stake for the bond asset (self + delegated)
    function _getOperatorTotalStake(address operator) internal view returns (uint256) {
        bytes32 bondHash = _operatorBondToken == address(0)
            ? _assetHash(Types.Asset(Types.AssetKind.Native, address(0)))
            : _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));
        return _operatorMetadata[operator].stake + _getOperatorDelegatedStakeForAsset(operator, bondHash);
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
    function _getPendingUnstakes(address delegator) internal view returns (Types.BondLessRequest[] memory) {
        return _unstakeRequests[delegator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get delegator's shares for a specific operator
    function _getDelegatorSharesForOperator(
        address delegator,
        address operator
    )
        internal
        view
        returns (uint256 totalShares)
    {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            if (_delegations[delegator][i].operator == operator) {
                totalShares += _delegations[delegator][i].shares;
            }
        }
    }

    /// @notice Get total delegation to a specific operator (in underlying amount)
    /// @dev Converts shares to amount at current exchange rate, handling both All and Fixed modes
    function _getDelegationToOperator(address delegator, address operator) internal view returns (uint256 totalAmount) {
        // Need to calculate separately for All mode vs Fixed mode delegations
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            if (d.operator != operator) continue;
            bytes32 assetHash = _assetHash(d.asset);

            if (d.selectionMode == Types.BlueprintSelectionMode.All) {
                // All mode: use main pool exchange rate
                totalAmount += _sharesToAmount(operator, assetHash, d.shares);
            } else {
                // Fixed mode: use blueprint pool exchange rates
                uint64[] storage blueprints = _delegationBlueprints[delegator][i];
                for (uint256 j = 0; j < blueprints.length; j++) {
                    uint256 bpShares = _delegatorBlueprintShares[delegator][operator][assetHash][blueprints[j]];
                    totalAmount += _sharesToAmountForBlueprint(operator, blueprints[j], assetHash, bpShares);
                }
            }
        }
    }

    /// @notice Convert shares to amount for a specific blueprint pool
    /// @dev C-1 FIX: Uses virtual offset to prevent inflation attack on blueprint pools
    function _sharesToAmountForBlueprint(
        address operator,
        uint64 blueprintId,
        bytes32 assetHash,
        uint256 shares
    )
        internal
        view
        returns (uint256 amount)
    {
        Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId][assetHash];
        // C-1 FIX: Use virtual offset - consistent with main pool
        return (shares * (pool.totalAssets + VIRTUAL_ASSETS)) / (pool.totalShares + VIRTUAL_SHARES);
    }

    /// @notice Convert an asset amount to shares for a specific blueprint pool
    /// @dev C-1 FIX: Uses virtual offset to prevent inflation attack on blueprint pools
    function _amountToSharesForBlueprint(
        address operator,
        uint64 blueprintId,
        bytes32 assetHash,
        uint256 amount
    )
        internal
        view
        returns (uint256 shares)
    {
        Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId][assetHash];
        // C-1 FIX: Use virtual offset - consistent with main pool
        shares = (amount * (pool.totalShares + VIRTUAL_SHARES)) / (pool.totalAssets + VIRTUAL_ASSETS);
    }

    /// @notice Get pending unstake shares for a specific delegation
    function _getPendingUnstakeShares(
        address delegator,
        address operator,
        bytes32 assetHash
    )
        internal
        view
        returns (uint256 pendingShares)
    {
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
    )
        internal
        view
        returns (uint256 lockedAmount, uint256 weightedBpsSum)
    {
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
    )
        internal
        view
        returns (uint16)
    {
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
        uint256[] memory blueprintShares,
        uint16 lockMultiplierBps
    )
        internal
        virtual;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT FOR DELEGATORS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintAddedToDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);
    event BlueprintRemovedFromDelegation(
        address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId
    );

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
        bytes32 assetHash = _assetHash(d.asset);

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

        uint256 oldBlueprintCount = blueprints.length;
        uint256 totalAmount;

        for (uint256 i = 0; i < oldBlueprintCount; i++) {
            uint64 bpId = blueprints[i];
            uint256 bpShares = _delegatorBlueprintShares[msg.sender][d.operator][assetHash][bpId];
            totalAmount += _sharesToAmountForBlueprint(d.operator, bpId, assetHash, bpShares);
        }

        uint256 newCount = oldBlueprintCount + 1;
        uint256 baseAmount = newCount == 0 ? 0 : totalAmount / newCount;
        uint256 remainder = totalAmount - (baseAmount * newCount);

        uint256 totalShares;
        for (uint256 i = 0; i < oldBlueprintCount; i++) {
            uint64 bpId = blueprints[i];
            uint256 targetShares = _amountToSharesForBlueprint(d.operator, bpId, assetHash, baseAmount);
            totalShares += targetShares;
            _setDelegatorBlueprintPosition(msg.sender, d.operator, assetHash, bpId, targetShares, baseAmount);
        }

        uint256 newBlueprintAmount = baseAmount + remainder;
        uint256 newBlueprintShares = _amountToSharesForBlueprint(d.operator, blueprintId, assetHash, newBlueprintAmount);
        _setDelegatorBlueprintPosition(
            msg.sender, d.operator, assetHash, blueprintId, newBlueprintShares, newBlueprintAmount
        );
        totalShares += newBlueprintShares;
        d.shares = totalShares;

        // Add the blueprint
        blueprints.push(blueprintId);

        emit BlueprintAddedToDelegation(msg.sender, delegationIndex, blueprintId);

        if (_serviceFeeDistributor != address(0)) {
            uint256 updatedCount = blueprints.length;
            uint64[] memory updatedBlueprintIds = new uint64[](updatedCount);
            uint256[] memory blueprintAmounts = new uint256[](updatedCount);

            for (uint256 i = 0; i < updatedCount; i++) {
                updatedBlueprintIds[i] = blueprints[i];
                blueprintAmounts[i] = i == updatedCount - 1 ? baseAmount + remainder : baseAmount;
            }

            try IServiceFeeDistributor(_serviceFeeDistributor)
                .onBlueprintsRebalanced(msg.sender, d.operator, d.asset, updatedBlueprintIds, blueprintAmounts) { }
                catch { }
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
        bytes32 assetHash = _assetHash(d.asset);

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

        uint256 totalAmount;
        for (uint256 i = 0; i < blueprints.length; i++) {
            uint64 bpId = blueprints[i];
            uint256 bpShares = _delegatorBlueprintShares[msg.sender][d.operator][assetHash][bpId];
            totalAmount += _sharesToAmountForBlueprint(d.operator, bpId, assetHash, bpShares);
        }

        _setDelegatorBlueprintPosition(msg.sender, d.operator, assetHash, blueprintId, 0, 0);

        // Swap and pop to remove the blueprint
        blueprints[foundIndex] = blueprints[blueprints.length - 1];
        blueprints.pop();

        uint256 remainingCount = blueprints.length;
        uint256 baseAmount = remainingCount == 0 ? 0 : totalAmount / remainingCount;
        uint256 remainder = totalAmount - (baseAmount * remainingCount);

        uint256 totalShares;
        for (uint256 i = 0; i < blueprints.length; i++) {
            uint64 bpId = blueprints[i];
            uint256 targetAmount = i == blueprints.length - 1 ? baseAmount + remainder : baseAmount;
            uint256 targetShares = _amountToSharesForBlueprint(d.operator, bpId, assetHash, targetAmount);
            totalShares += targetShares;
            _setDelegatorBlueprintPosition(msg.sender, d.operator, assetHash, bpId, targetShares, targetAmount);
        }
        d.shares = totalShares;

        emit BlueprintRemovedFromDelegation(msg.sender, delegationIndex, blueprintId);

        if (_serviceFeeDistributor != address(0)) {
            uint256 newCount = blueprints.length;
            uint64[] memory updatedBlueprintIds = new uint64[](newCount);
            uint256[] memory blueprintAmounts = new uint256[](newCount);

            for (uint256 i = 0; i < newCount; i++) {
                updatedBlueprintIds[i] = blueprints[i];
                blueprintAmounts[i] = i == newCount - 1 ? baseAmount + remainder : baseAmount;
            }

            try IServiceFeeDistributor(_serviceFeeDistributor)
                .onBlueprintsRebalanced(msg.sender, d.operator, d.asset, updatedBlueprintIds, blueprintAmounts) { }
                catch { }
        }
    }
}
