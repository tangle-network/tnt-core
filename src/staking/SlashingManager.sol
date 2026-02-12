// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { RewardsManager } from "./RewardsManager.sol";
import { DelegationErrors } from "./DelegationErrors.sol";
import { Types } from "../libraries/Types.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";

/// @title SlashingManager
/// @notice Manages O(1) proportional slashing using share-based accounting
/// @dev Slashing reduces totalAssets while keeping shares constant.
///      This means each share becomes worth less - a "virtual" slash of all delegators.
///      When delegators withdraw, they automatically receive less due to reduced exchange rate.
///      This is the same pattern used by Lido, Rocket Pool, and ERC4626 vaults.
abstract contract SlashingManager is RewardsManager {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when an operator and their delegators are slashed for an asset
    /// @param operator The slashed operator
    /// @param serviceId The service where violation occurred
    /// @param blueprintId The blueprint where violation occurred (0 for consensus/native slash)
    /// @param assetHash Asset hash for the pool
    /// @param slashBps Slash percentage in basis points
    /// @param operatorSlashed Amount slashed from operator's self-stake
    /// @param delegatorsSlashed Amount slashed from delegator pools (reduces totalAssets)
    /// @param exchangeRateAfter Exchange rate after slash (scaled by PRECISION)
    event Slashed(
        address indexed operator,
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        bytes32 assetHash,
        uint16 slashBps,
        uint256 operatorSlashed,
        uint256 delegatorsSlashed,
        uint256 exchangeRateAfter
    );

    /// @notice Emitted when an operator is slashed for a specific service with per-asset commitments
    /// @param operator The slashed operator
    /// @param serviceId The service where violation occurred
    /// @param blueprintId The blueprint ID
    /// @param totalSlashed Total amount slashed across all committed assets
    /// @param commitmentCount Number of asset commitments that were slashed
    event SlashedForService(
        address indexed operator,
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        uint256 totalSlashed,
        uint256 commitmentCount
    );

    /// @notice Emitted when slash is recorded (for off-chain indexing of per-delegator impact)
    /// @dev Individual delegator amounts can be computed: shares * (oldRate - newRate) / PRECISION
    event SlashRecorded(
        address indexed operator,
        uint64 indexed slashId,
        bytes32 assetHash,
        uint16 slashBps,
        uint256 totalSlashed,
        uint256 exchangeRateBefore,
        uint256 exchangeRateAfter
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH TRACKING (for historical queries)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slash event record for historical tracking
    struct SlashRecord {
        uint64 round;
        uint64 serviceId;
        uint64 blueprintId;
        bytes32 assetHash;
        uint16 slashBps;
        uint256 totalSlashed;
        uint256 exchangeRateBefore;
        uint256 exchangeRateAfter;
        bytes32 evidence;
    }

    /// @notice Slash history per operator: operator => slashId => record
    mapping(address => mapping(uint64 => SlashRecord)) public slashHistory;

    /// @notice Next slash ID per operator
    mapping(address => uint64) public nextSlashId;

    /// @notice Slash count per service: serviceId => operator => count
    mapping(uint64 => mapping(address => uint64)) public serviceSlashCount;

    /// @notice Slash count per blueprint: blueprintId => operator => count
    mapping(uint64 => mapping(address => uint64)) public blueprintSlashCount;

    // ═══════════════════════════════════════════════════════════════════════════
    // M-9 FIX: PENDING SLASH TRACKING
    // ═══════════════════════════════════════════════════════════════════════════
    // These functions are called by Tangle core to track pending slashes.
    // When an operator has pending slashes, delegators cannot withdraw.
    // ═══════════════════════════════════════════════════════════════════════════

    event PendingSlashIncremented(address indexed operator, uint64 newCount);
    event PendingSlashDecremented(address indexed operator, uint64 newCount);
    event PendingSlashCountReset(address indexed operator, uint64 newCount);

    /// @notice Increment pending slash count for an operator
    /// @dev Called by Tangle when a slash is proposed
    /// @param operator The operator with a new pending slash
    function _incrementPendingSlash(address operator) internal {
        _operatorPendingSlashCount[operator]++;
        emit PendingSlashIncremented(operator, _operatorPendingSlashCount[operator]);
    }

    /// @notice Decrement pending slash count for an operator
    /// @dev Called by Tangle when a slash is executed or cancelled
    /// @param operator The operator whose pending slash was resolved
    function _decrementPendingSlash(address operator) internal {
        if (_operatorPendingSlashCount[operator] > 0) {
            _operatorPendingSlashCount[operator]--;
            emit PendingSlashDecremented(operator, _operatorPendingSlashCount[operator]);
        }
    }

    /// @notice Get pending slash count for an operator
    /// @param operator The operator to query
    /// @return count Number of pending slashes
    function getPendingSlashCount(address operator) external view virtual returns (uint64) {
        return _operatorPendingSlashCount[operator];
    }

    /// @notice H-1 FIX: Reset pending slash count when it drifts from actual pending slashes
    /// @dev Admin-only recovery function for when count becomes inconsistent.
    ///      Default implementation reverts - must be overridden with access control.
    /// @param operator The operator to reset
    /// @param count The correct pending slash count
    function resetPendingSlashCount(address operator, uint64 count) external virtual {
        // Silence unused variable warnings - this default reverts for security
        operator;
        count;
        revert DelegationErrors.Unauthorized();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // O(1) SLASHING
    // ═══════════════════════════════════════════════════════════════════════════
    // NOTE: Slashing is O(1) because we use share-based accounting (ERC4626 pattern).
    // Instead of iterating through all delegators, we reduce totalAssets in the pool.
    // Each delegator's shares remain constant, but the exchange rate (totalAssets/totalShares)
    // decreases, effectively slashing everyone proportionally without iteration.
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slash an operator for a specific blueprint - O(1) operation
    /// @dev Only affects delegators exposed to this blueprint:
    ///      - All mode delegators (exposed to ALL blueprints)
    ///      - Fixed mode delegators who selected this specific blueprint
    /// @param operator Operator to slash
    /// @param blueprintId Blueprint where violation occurred
    /// @param serviceId Service where violation occurred
    /// @param slashBps Slash percentage in basis points
    /// @param evidence Evidence hash for the violation
    /// @return actualSlashed Total amount actually slashed
    function _slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    )
        internal
        returns (uint256 actualSlashed)
    {
        if (slashBps == 0) return 0;
        if (slashBps > BPS_DENOMINATOR) revert DelegationErrors.InvalidSlashBps(slashBps);
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];
        if (!_operators.contains(operator)) {
            revert DelegationErrors.OperatorNotRegistered(operator);
        }

        bytes32 bondHash = _operatorBondToken == address(0)
            ? _assetHash(Types.Asset(Types.AssetKind.Native, address(0)))
            : _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));

        uint256 totalSlashed = 0;
        bool slashed = false;

        if (nativeEnabled) {
            Types.Asset memory asset = Types.Asset(Types.AssetKind.Native, address(0));
            bytes32 assetHash = _assetHash(asset);
            totalSlashed += _slashBlueprintPoolsForAsset(
                operator, blueprintId, serviceId, asset, assetHash, bondHash, slashBps, evidence, meta
            );
            if (totalSlashed > 0) slashed = true;
        }

        uint256 erc20Count = _enabledErc20s.length();
        for (uint256 i = 0; i < erc20Count;) {
            address token = _enabledErc20s.at(i);
            Types.Asset memory asset = Types.Asset(Types.AssetKind.ERC20, token);
            bytes32 assetHash = _assetHash(asset);
            uint256 assetSlashed = _slashBlueprintPoolsForAsset(
                operator, blueprintId, serviceId, asset, assetHash, bondHash, slashBps, evidence, meta
            );
            if (assetSlashed > 0) {
                totalSlashed += assetSlashed;
                slashed = true;
            }
            unchecked {
                ++i;
            }
        }

        if (!slashed) return 0;
        actualSlashed = totalSlashed;

        uint256 minStake = _assetConfigs[bondHash].minOperatorStake;
        if (meta.stake < minStake) {
            meta.status = Types.OperatorStatus.Inactive;
        }

        serviceSlashCount[serviceId][operator]++;
        blueprintSlashCount[blueprintId][operator]++;
    }

    /// @notice Slash an operator for a specific service - only slashing committed assets
    /// @dev Slashes proportionally based on the operator's asset commitments for the service.
    ///      For each committed asset, calculates exposed value = stake * exposureBps / 10000
    ///      Then slashes that proportion from the appropriate pools.
    /// @param operator Operator to slash
    /// @param blueprintId Blueprint where violation occurred
    /// @param serviceId Service where violation occurred
    /// @param commitments The operator's security commitments for this service
    /// @param slashBps Slash percentage in basis points
    /// @param evidence Evidence hash for the violation
    /// @return actualSlashed Total amount actually slashed
    function _slashForService(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint16 slashBps,
        bytes32 evidence
    )
        internal
        returns (uint256 actualSlashed)
    {
        if (slashBps == 0) return 0;
        if (slashBps > BPS_DENOMINATOR) revert DelegationErrors.InvalidSlashBps(slashBps);
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];
        if (!_operators.contains(operator)) {
            revert DelegationErrors.OperatorNotRegistered(operator);
        }

        if (commitments.length == 0) {
            return _slashForBlueprint(operator, blueprintId, serviceId, slashBps, evidence);
        }

        bytes32 bondHash = _operatorBondToken == address(0)
            ? _assetHash(Types.Asset(Types.AssetKind.Native, address(0)))
            : _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));

        uint256 totalSlashed = 0;
        uint256 commitmentsLength = commitments.length;
        for (uint256 i = 0; i < commitmentsLength;) {
            Types.AssetSecurityCommitment calldata commitment = commitments[i];
            uint256 effectiveBps = (uint256(slashBps) * commitment.exposureBps) / BPS_DENOMINATOR;
            // M-19 FIX: Ensure minimum 1 bps if both inputs are non-zero
            // This prevents rounding to zero when small percentages are multiplied
            if (slashBps > 0 && commitment.exposureBps > 0 && effectiveBps == 0) {
                effectiveBps = 1;
            }
            if (effectiveBps == 0) {
                unchecked {
                    ++i;
                }
                continue;
            }

            bytes32 assetHash = _assetHash(commitment.asset);
            uint256 assetSlashed = _slashBlueprintPoolsForAsset(
                operator,
                blueprintId,
                serviceId,
                commitment.asset,
                assetHash,
                bondHash,
                uint16(effectiveBps),
                evidence,
                meta
            );
            totalSlashed += assetSlashed;
            unchecked {
                ++i;
            }
        }

        if (totalSlashed == 0) return 0;
        actualSlashed = totalSlashed;

        uint256 minStake = _assetConfigs[bondHash].minOperatorStake;
        if (meta.stake < minStake) {
            meta.status = Types.OperatorStatus.Inactive;
        }

        serviceSlashCount[serviceId][operator]++;
        blueprintSlashCount[blueprintId][operator]++;

        emit SlashedForService(operator, serviceId, blueprintId, actualSlashed, commitments.length);
    }

    /// @notice Consensus slashing for native asset only
    /// @param operator Operator to slash
    /// @param serviceId Service where violation occurred
    /// @param slashBps Slash percentage in basis points
    /// @param evidence Evidence hash for the violation
    /// @return actualSlashed Total amount actually slashed
    function _slash(
        address operator,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    )
        internal
        returns (uint256 actualSlashed)
    {
        if (slashBps == 0) return 0;
        if (slashBps > BPS_DENOMINATOR) revert DelegationErrors.InvalidSlashBps(slashBps);
        if (!_operators.contains(operator)) {
            revert DelegationErrors.OperatorNotRegistered(operator);
        }

        if (!nativeEnabled) return 0;
        Types.Asset memory asset = Types.Asset(Types.AssetKind.Native, address(0));
        bytes32 assetHash = _assetHash(asset);
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];

        uint256 exchangeRateBefore = _getExchangeRate(operator, assetHash);

        uint256 actualOperatorSlash = 0;
        if (_operatorBondToken == address(0)) {
            uint256 operatorSlash = (meta.stake * slashBps) / BPS_DENOMINATOR;
            actualOperatorSlash = operatorSlash > 0 ? _slashOperatorStake(operator, operatorSlash) : 0;
        }

        bool allHasDelegators = _rewardPools[operator][assetHash].totalShares > 0;
        uint256 allSlash = (_rewardPools[operator][assetHash].totalAssets * slashBps) / BPS_DENOMINATOR;
        uint256 actualAllSlash = _slashAllModePool(operator, assetHash, allSlash);
        uint256 totalFixedSlash = 0;
        uint256 totalSlashed = actualOperatorSlash + actualAllSlash;

        // H-6 FIX: Collect callback data during loop, execute after state updates
        uint256 bpCount = _operatorBlueprints[operator].length();
        uint64[] memory callbackBlueprintIds = new uint64[](bpCount);
        uint256 callbackCount = 0;

        for (uint256 i = 0; i < bpCount;) {
            uint64 blueprintId = uint64(_operatorBlueprints[operator].at(i));
            Types.OperatorRewardPool storage bpPool = _blueprintPools[operator][blueprintId][assetHash];
            bool fixedHasDelegators = bpPool.totalShares > 0;
            uint256 bpSlash = (bpPool.totalAssets * slashBps) / BPS_DENOMINATOR;
            uint256 actualFixedSlash = _slashBlueprintPool(operator, blueprintId, assetHash, bpSlash);
            totalFixedSlash += actualFixedSlash;
            totalSlashed += actualFixedSlash;

            // Collect callback data instead of making external call during iteration
            if (fixedHasDelegators && actualFixedSlash > 0) {
                callbackBlueprintIds[callbackCount] = blueprintId;
                unchecked {
                    ++callbackCount;
                }
            }
            unchecked {
                ++i;
            }
        }

        if (totalSlashed == 0) return 0;

        uint256 exchangeRateAfter = _getExchangeRate(operator, assetHash);
        uint64 slashId = nextSlashId[operator]++;
        slashHistory[operator][slashId] = SlashRecord({
            round: currentRound,
            serviceId: serviceId,
            blueprintId: 0,
            assetHash: assetHash,
            slashBps: slashBps,
            totalSlashed: totalSlashed,
            exchangeRateBefore: exchangeRateBefore,
            exchangeRateAfter: exchangeRateAfter,
            evidence: evidence
        });

        // H-6 FIX: Execute all callbacks AFTER state updates complete
        if (_serviceFeeDistributor != address(0)) {
            if (allHasDelegators && actualAllSlash > 0) {
                try IServiceFeeDistributor(_serviceFeeDistributor).onAllModeSlashed(operator, asset, slashBps) { }
                    catch { }
            }
            for (uint256 i = 0; i < callbackCount;) {
                try IServiceFeeDistributor(_serviceFeeDistributor)
                    .onFixedModeSlashed(operator, callbackBlueprintIds[i], asset, slashBps) { }
                    catch { }
                unchecked {
                    ++i;
                }
            }
        }

        uint256 minStake = _assetConfigs[assetHash].minOperatorStake;
        if (meta.stake < minStake) {
            meta.status = Types.OperatorStatus.Inactive;
        }

        serviceSlashCount[serviceId][operator]++;

        emit Slashed(
            operator,
            serviceId,
            0,
            assetHash,
            slashBps,
            actualOperatorSlash,
            actualAllSlash + totalFixedSlash,
            exchangeRateAfter
        );
        emit SlashRecorded(operator, slashId, assetHash, slashBps, totalSlashed, exchangeRateBefore, exchangeRateAfter);
        actualSlashed = totalSlashed;
    }

    /// @notice Slash operator's self-stake
    function _slashOperatorStake(address operator, uint256 amount) internal returns (uint256 slashed) {
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];

        if (meta.stake >= amount) {
            meta.stake -= amount;
            slashed = amount;
        } else {
            slashed = meta.stake;
            meta.stake = 0;
        }
    }

    /// @notice Slash the All mode delegator pool by reducing totalAssets - O(1) operation!
    /// @dev This is the key insight: instead of iterating N delegators, we just
    ///      reduce totalAssets. Since exchangeRate = totalAssets / totalShares,
    ///      reducing totalAssets makes each share worth less.
    ///      When delegators withdraw, they get: shares * totalAssets / totalShares
    ///      which is automatically less after the slash.
    /// @param operator Operator whose pool to slash
    /// @param amount Amount to slash from the pool
    /// @return slashed Actual amount slashed
    function _slashAllModePool(address operator, bytes32 assetHash, uint256 amount) internal returns (uint256 slashed) {
        Types.OperatorRewardPool storage pool = _rewardPools[operator][assetHash];

        if (pool.totalAssets == 0 || amount == 0) {
            return 0;
        }

        if (pool.totalAssets >= amount) {
            pool.totalAssets -= amount;
            slashed = amount;
        } else {
            slashed = pool.totalAssets;
            pool.totalAssets = 0;
        }

        // That's it! No iteration needed.
        // All mode delegator balances are now effectively reduced because
        // their shares are worth less at the new exchange rate.
    }

    /// @notice Slash a specific blueprint pool for Fixed mode delegators - O(1) operation!
    /// @dev Only affects Fixed mode delegators who selected this blueprint
    /// @param operator Operator whose blueprint pool to slash
    /// @param blueprintId Blueprint whose pool to slash
    /// @param amount Amount to slash from the pool
    /// @return slashed Actual amount slashed
    function _slashBlueprintPool(
        address operator,
        uint64 blueprintId,
        bytes32 assetHash,
        uint256 amount
    )
        internal
        returns (uint256 slashed)
    {
        Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId][assetHash];

        if (pool.totalAssets == 0 || amount == 0) {
            return 0;
        }

        if (pool.totalAssets >= amount) {
            pool.totalAssets -= amount;
            slashed = amount;
        } else {
            slashed = pool.totalAssets;
            pool.totalAssets = 0;
        }

        // Fixed mode delegators for this blueprint now have reduced balance
        // because their shares in this pool are worth less.
    }

    function _slashBlueprintPoolsForAsset(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.Asset memory asset,
        bytes32 assetHash,
        bytes32 bondHash,
        uint16 slashBps,
        bytes32 evidence,
        Types.OperatorMetadata storage meta
    )
        internal
        returns (uint256 assetSlashed)
    {
        Types.OperatorRewardPool storage allPool = _rewardPools[operator][assetHash];
        Types.OperatorRewardPool storage bpPool = _blueprintPools[operator][blueprintId][assetHash];
        bool allHasDelegators = allPool.totalShares > 0;
        bool fixedHasDelegators = bpPool.totalShares > 0;

        uint256 operatorStake = assetHash == bondHash ? meta.stake : 0;
        if (operatorStake == 0 && allPool.totalAssets == 0 && bpPool.totalAssets == 0) {
            return 0;
        }

        uint256 exchangeRateBefore = _getExchangeRate(operator, assetHash);

        uint256 operatorSlashAmount = (operatorStake * slashBps) / BPS_DENOMINATOR;
        uint256 allModeSlashAmount = (allPool.totalAssets * slashBps) / BPS_DENOMINATOR;
        uint256 fixedModeSlashAmount = (bpPool.totalAssets * slashBps) / BPS_DENOMINATOR;

        uint256 actualOperatorSlash = operatorSlashAmount > 0 ? _slashOperatorStake(operator, operatorSlashAmount) : 0;
        uint256 actualAllModeSlash = _slashAllModePool(operator, assetHash, allModeSlashAmount);
        uint256 actualFixedModeSlash = _slashBlueprintPool(operator, blueprintId, assetHash, fixedModeSlashAmount);

        assetSlashed = actualOperatorSlash + actualAllModeSlash + actualFixedModeSlash;
        if (assetSlashed == 0) {
            return 0;
        }

        uint256 exchangeRateAfter = _getExchangeRate(operator, assetHash);
        uint64 slashId = nextSlashId[operator]++;
        slashHistory[operator][slashId] = SlashRecord({
            round: currentRound,
            serviceId: serviceId,
            blueprintId: blueprintId,
            assetHash: assetHash,
            slashBps: slashBps,
            totalSlashed: assetSlashed,
            exchangeRateBefore: exchangeRateBefore,
            exchangeRateAfter: exchangeRateAfter,
            evidence: evidence
        });

        if (_serviceFeeDistributor != address(0)) {
            if (allHasDelegators && actualAllModeSlash > 0) {
                try IServiceFeeDistributor(_serviceFeeDistributor).onAllModeSlashed(operator, asset, slashBps) { }
                    catch { }
            }
            if (fixedHasDelegators && actualFixedModeSlash > 0) {
                try IServiceFeeDistributor(_serviceFeeDistributor)
                    .onFixedModeSlashed(operator, blueprintId, asset, slashBps) { }
                    catch { }
            }
        }

        emit Slashed(
            operator,
            serviceId,
            blueprintId,
            assetHash,
            slashBps,
            actualOperatorSlash,
            actualAllModeSlash + actualFixedModeSlash,
            exchangeRateAfter
        );
        emit SlashRecorded(operator, slashId, assetHash, slashBps, assetSlashed, exchangeRateBefore, exchangeRateAfter);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH QUERIES (for delegators to understand their loss)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate how much a delegator lost from a specific slash
    /// @param operator The operator that was slashed
    /// @param slashId The slash event ID
    /// @param delegator The delegator to check
    /// @return lostAmount Approximate amount lost due to this slash
    function getSlashImpact(
        address operator,
        uint64 slashId,
        address delegator
    )
        external
        view
        returns (uint256 lostAmount)
    {
        SlashRecord memory record = slashHistory[operator][slashId];
        if (record.round == 0) return 0; // Slash doesn't exist

        uint256 delegatorShares = _getDelegatorSharesForOperatorAsset(delegator, operator, record.assetHash);
        if (delegatorShares == 0) return 0;

        // Calculate value lost: shares * (rateBefore - rateAfter) / PRECISION
        if (record.exchangeRateBefore > record.exchangeRateAfter) {
            uint256 rateDiff = record.exchangeRateBefore - record.exchangeRateAfter;
            lostAmount = (delegatorShares * rateDiff) / PRECISION;
        }
    }

    function _getDelegatorSharesForOperatorAsset(
        address delegator,
        address operator,
        bytes32 assetHash
    )
        internal
        view
        returns (uint256 totalShares)
    {
        Types.BondInfoDelegator[] storage delegations = _delegations[delegator];
        uint256 delegationsLength = delegations.length;
        for (uint256 i = 0; i < delegationsLength;) {
            Types.BondInfoDelegator storage d = delegations[i];
            if (d.operator == operator && _assetHash(d.asset) == assetHash) {
                totalShares += d.shares;
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Get total slashes for an operator
    function getSlashCount(address operator) external view returns (uint64) {
        return nextSlashId[operator];
    }

    /// @notice Get slash record details
    function getSlashRecord(address operator, uint64 slashId) external view returns (SlashRecord memory) {
        return slashHistory[operator][slashId];
    }

    /// @notice Get slash count for an operator in a specific service
    /// @param serviceId The service ID
    /// @param operator The operator address
    /// @return count Number of times operator was slashed in this service
    function getSlashCountForService(uint64 serviceId, address operator) external view returns (uint64) {
        return serviceSlashCount[serviceId][operator];
    }

    /// @notice Get slash count for an operator in a specific blueprint
    /// @param blueprintId The blueprint ID
    /// @param operator The operator address
    /// @return count Number of times operator was slashed in services of this blueprint
    function getSlashCountForBlueprint(uint64 blueprintId, address operator) external view returns (uint64) {
        return blueprintSlashCount[blueprintId][operator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STORAGE GAP
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Reserved storage gap for future upgrades.
    /// SlashingManager uses ~6 storage slots (slashHistory, nextSlashId, serviceSlashCount,
    /// blueprintSlashCount, plus inherited state). Gap size: 50 - 6 = 44 slots.
    uint256[44] private __slashingGap;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUND SNAPSHOTS (for historical slashing)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Take snapshot of operator state at round start
    /// @param operator Operator to snapshot
    function _snapshotOperator(address operator) internal {
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];
        if (meta.status != Types.OperatorStatus.Active) {
            revert DelegationErrors.OperatorNotActive(operator);
        }

        bytes32 bondHash = _operatorBondToken == address(0)
            ? _assetHash(Types.Asset(Types.AssetKind.Native, address(0)))
            : _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));

        _atStake[currentRound][operator] = Types.OperatorSnapshot({
            stake: meta.stake, totalDelegated: _getOperatorDelegatedStakeForAsset(operator, bondHash)
        });
    }

    /// @notice Get snapshot for an operator at a specific round
    function getSnapshot(uint64 round, address operator) public view returns (Types.OperatorSnapshot memory) {
        return _atStake[round][operator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUND MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Advance to next round with time-based rate limiting
    /// @dev Prevents rapid round advancement that could bypass time-based delays
    function _advanceRound() internal {
        uint64 nextAllowedTime = lastRoundAdvance + roundDuration;

        // Allow first advance if lastRoundAdvance is 0 (not yet initialized in upgraded contracts)
        if (lastRoundAdvance != 0 && block.timestamp < nextAllowedTime) {
            revert DelegationErrors.RoundAdvanceTooSoon(nextAllowedTime, uint64(block.timestamp));
        }

        lastRoundAdvance = uint64(block.timestamp);
        currentRound++;
    }

    /// @notice Try to advance round if enough time has passed (silent no-op if too early)
    /// @dev Called from high-traffic functions to opportunistically advance rounds.
    ///      Does NOT advance on first call when lastRoundAdvance is 0 - use advanceRound() for that.
    /// @return advanced True if the round was advanced, false if too early
    function _tryAdvanceRound() internal returns (bool advanced) {
        // Only advance if lastRoundAdvance is set AND enough time has passed
        // First round advancement should be done via explicit advanceRound() call
        if (lastRoundAdvance != 0 && block.timestamp >= lastRoundAdvance + roundDuration) {
            lastRoundAdvance = uint64(block.timestamp);
            currentRound++;
            return true;
        }
        return false;
    }
}
