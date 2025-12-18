// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { RewardsManager } from "./RewardsManager.sol";
import { DelegationErrors } from "./DelegationErrors.sol";
import { Types } from "../libraries/Types.sol";

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

    /// @notice Emitted when an operator and their delegators are slashed
    /// @param operator The slashed operator
    /// @param serviceId The service where violation occurred
    /// @param operatorSlashed Amount slashed from operator's self-stake
    /// @param delegatorsSlashed Amount slashed from delegator pool (reduces totalAssets)
    /// @param newExchangeRate New exchange rate after slash (scaled by PRECISION)
    event Slashed(
        address indexed operator,
        uint64 indexed serviceId,
        uint256 operatorSlashed,
        uint256 delegatorsSlashed,
        uint256 newExchangeRate
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
    // O(1) SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slash an operator for a specific blueprint - O(1) operation
    /// @dev Only affects delegators exposed to this blueprint:
    ///      - All mode delegators (exposed to ALL blueprints)
    ///      - Fixed mode delegators who selected this specific blueprint
    /// @param operator Operator to slash
    /// @param blueprintId Blueprint where violation occurred
    /// @param serviceId Service where violation occurred
    /// @param amount Total amount to slash
    /// @param evidence Evidence hash for the violation
    /// @return actualSlashed Total amount actually slashed
    function _slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    ) internal returns (uint256 actualSlashed) {
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];
        if (!_operators.contains(operator)) {
            revert DelegationErrors.OperatorNotRegistered(operator);
        }

        // Get both pools that are exposed to this blueprint
        Types.OperatorRewardPool storage allPool = _rewardPools[operator];
        Types.OperatorRewardPool storage bpPool = _blueprintPools[operator][blueprintId];

        // Calculate total exposed stake (operator + All mode delegators + Fixed mode delegators for this blueprint)
        uint256 operatorStake = meta.stake;
        uint256 allModeStake = allPool.totalAssets;
        uint256 fixedModeStake = bpPool.totalAssets;
        uint256 totalExposedStake = operatorStake + allModeStake + fixedModeStake;

        if (totalExposedStake == 0) {
            return 0;
        }

        // Cap slash to total exposed stake
        if (amount > totalExposedStake) {
            amount = totalExposedStake;
        }

        // Calculate proportional slash amounts
        uint256 operatorSlashAmount = (amount * operatorStake) / totalExposedStake;
        uint256 allModeSlashAmount = (amount * allModeStake) / totalExposedStake;
        uint256 fixedModeSlashAmount = amount - operatorSlashAmount - allModeSlashAmount;

        // Record exchange rates before slash
        uint256 allExchangeRateBefore = _getExchangeRate(operator);

        // Slash operator's self-stake
        uint256 actualOperatorSlash = _slashOperatorStake(operator, operatorSlashAmount);

        // Slash All mode delegators (exposed to all blueprints)
        uint256 actualAllModeSlash = _slashAllModePool(operator, allModeSlashAmount);

        // Slash Fixed mode delegators who selected this blueprint
        uint256 actualFixedModeSlash = _slashBlueprintPool(operator, blueprintId, fixedModeSlashAmount);

        actualSlashed = actualOperatorSlash + actualAllModeSlash + actualFixedModeSlash;

        // Record exchange rate after slash
        uint256 allExchangeRateAfter = _getExchangeRate(operator);

        // Deactivate operator if below minimum
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        uint256 minStake = _assetConfigs[nativeHash].minOperatorStake;
        if (meta.stake < minStake) {
            meta.status = Types.OperatorStatus.Inactive;
        }

        // Record slash for historical queries
        uint64 slashId = nextSlashId[operator]++;
        slashHistory[operator][slashId] = SlashRecord({
            round: currentRound,
            serviceId: serviceId,
            blueprintId: blueprintId,
            totalSlashed: actualSlashed,
            exchangeRateBefore: allExchangeRateBefore,
            exchangeRateAfter: allExchangeRateAfter,
            evidence: evidence
        });

        // Increment per-service and per-blueprint slash counts
        serviceSlashCount[serviceId][operator]++;
        blueprintSlashCount[blueprintId][operator]++;

        // Update slash factor for lazy slashing of pending unstakes
        if (totalExposedStake > 0) {
            uint256 slashBps = (actualSlashed * BPS_DENOMINATOR) / totalExposedStake;
            _updateSlashFactor(operator, slashBps);
        }

        emit Slashed(operator, serviceId, actualOperatorSlash, actualAllModeSlash + actualFixedModeSlash, allExchangeRateAfter);
        emit SlashRecorded(operator, slashId, actualSlashed, allExchangeRateBefore, allExchangeRateAfter);
    }

    /// @notice Slash an operator for a specific service - only slashing committed assets
    /// @dev Slashes proportionally based on the operator's asset commitments for the service.
    ///      For each committed asset, calculates exposed value = stake * exposureBps / 10000
    ///      Then slashes that proportion from the appropriate pools.
    /// @param operator Operator to slash
    /// @param blueprintId Blueprint where violation occurred
    /// @param serviceId Service where violation occurred
    /// @param commitments The operator's security commitments for this service
    /// @param amount Total amount to slash
    /// @param evidence Evidence hash for the violation
    /// @return actualSlashed Total amount actually slashed
    function _slashForService(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256 amount,
        bytes32 evidence
    ) internal returns (uint256 actualSlashed) {
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];
        if (!_operators.contains(operator)) {
            revert DelegationErrors.OperatorNotRegistered(operator);
        }

        // If no commitments provided, fall back to blueprint-level slashing
        if (commitments.length == 0) {
            return _slashForBlueprint(operator, blueprintId, serviceId, amount, evidence);
        }

        // Get pools that are exposed to this blueprint
        Types.OperatorRewardPool storage allPool = _rewardPools[operator];
        Types.OperatorRewardPool storage bpPool = _blueprintPools[operator][blueprintId];

        // Calculate total committed value across all assets
        // For each commitment, the exposed value is: asset_stake * exposureBps / BPS_DENOMINATOR
        uint256 totalCommittedValue = 0;
        uint256 operatorStake = meta.stake;
        uint256 allModeStake = allPool.totalAssets;
        uint256 fixedModeStake = bpPool.totalAssets;

        // Calculate exposed value for each commitment
        // Native assets use operator stake + delegator pools
        // ERC20 assets would use their respective pools (future enhancement)
        for (uint256 i = 0; i < commitments.length; i++) {
            Types.AssetSecurityCommitment calldata commitment = commitments[i];

            if (commitment.asset.kind == Types.AssetKind.Native) {
                // Native asset: use operator stake + delegated native tokens
                uint256 nativeStake = operatorStake + allModeStake + fixedModeStake;
                uint256 exposedValue = (nativeStake * commitment.exposureBps) / BPS_DENOMINATOR;
                totalCommittedValue += exposedValue;
            } else {
                // ERC20 assets: for now, we track them but they contribute to total
                // Full per-asset pool support would require additional storage
                // For now, ERC20 commitments are tracked but slashed from native pools
                // proportionally to maintain fairness
                uint256 erc20Stake = operatorStake + allModeStake + fixedModeStake;
                uint256 exposedValue = (erc20Stake * commitment.exposureBps) / BPS_DENOMINATOR;
                totalCommittedValue += exposedValue;
            }
        }

        if (totalCommittedValue == 0) {
            return 0;
        }

        // Cap slash to total committed value
        if (amount > totalCommittedValue) {
            amount = totalCommittedValue;
        }

        // Record exchange rates before slash
        uint256 allExchangeRateBefore = _getExchangeRate(operator);

        // Calculate slash distribution proportionally
        // Operator's share: operator stake proportion of committed value
        uint256 totalNativeStake = operatorStake + allModeStake + fixedModeStake;
        if (totalNativeStake == 0) {
            return 0;
        }

        // Calculate how much of the total committed value each pool represents
        uint256 operatorCommittedValue = 0;
        uint256 allModeCommittedValue = 0;
        uint256 fixedModeCommittedValue = 0;

        for (uint256 i = 0; i < commitments.length; i++) {
            Types.AssetSecurityCommitment calldata commitment = commitments[i];
            // For simplicity, distribute based on stake ratios
            // More sophisticated: track per-asset pools
            uint256 exposureFactor = commitment.exposureBps;
            operatorCommittedValue += (operatorStake * exposureFactor) / BPS_DENOMINATOR;
            allModeCommittedValue += (allModeStake * exposureFactor) / BPS_DENOMINATOR;
            fixedModeCommittedValue += (fixedModeStake * exposureFactor) / BPS_DENOMINATOR;
        }

        // Now slash each pool proportionally based on committed value
        uint256 operatorSlashAmount = (amount * operatorCommittedValue) / totalCommittedValue;
        uint256 allModeSlashAmount = (amount * allModeCommittedValue) / totalCommittedValue;
        uint256 fixedModeSlashAmount = amount - operatorSlashAmount - allModeSlashAmount;

        // Slash operator's self-stake
        uint256 actualOperatorSlash = _slashOperatorStake(operator, operatorSlashAmount);

        // Slash All mode delegators
        uint256 actualAllModeSlash = _slashAllModePool(operator, allModeSlashAmount);

        // Slash Fixed mode delegators who selected this blueprint
        uint256 actualFixedModeSlash = _slashBlueprintPool(operator, blueprintId, fixedModeSlashAmount);

        actualSlashed = actualOperatorSlash + actualAllModeSlash + actualFixedModeSlash;

        // Record exchange rate after slash
        uint256 allExchangeRateAfter = _getExchangeRate(operator);

        // Deactivate operator if below minimum
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        uint256 minStake = _assetConfigs[nativeHash].minOperatorStake;
        if (meta.stake < minStake) {
            meta.status = Types.OperatorStatus.Inactive;
        }

        // Record slash for historical queries
        uint64 slashId = nextSlashId[operator]++;
        slashHistory[operator][slashId] = SlashRecord({
            round: currentRound,
            serviceId: serviceId,
            blueprintId: blueprintId,
            totalSlashed: actualSlashed,
            exchangeRateBefore: allExchangeRateBefore,
            exchangeRateAfter: allExchangeRateAfter,
            evidence: evidence
        });

        // Increment per-service and per-blueprint slash counts
        serviceSlashCount[serviceId][operator]++;
        blueprintSlashCount[blueprintId][operator]++;

        // Update slash factor for lazy slashing of pending unstakes
        if (totalCommittedValue > 0) {
            uint256 slashBps = (actualSlashed * BPS_DENOMINATOR) / totalCommittedValue;
            _updateSlashFactor(operator, slashBps);
        }

        emit SlashedForService(operator, serviceId, blueprintId, actualSlashed, commitments.length);
        emit SlashRecorded(operator, slashId, actualSlashed, allExchangeRateBefore, allExchangeRateAfter);
    }

    /// @notice Slash an operator and their delegators proportionally - O(1) operation (legacy)
    /// @dev Slashes ALL delegators regardless of blueprint selection
    /// @param operator Operator to slash
    /// @param serviceId Service where violation occurred
    /// @param amount Total amount to slash
    /// @param evidence Evidence hash for the violation
    /// @return actualSlashed Total amount actually slashed
    function _slash(
        address operator,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    ) internal returns (uint256 actualSlashed) {
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];
        if (!_operators.contains(operator)) {
            revert DelegationErrors.OperatorNotRegistered(operator);
        }

        if (_hasFixedModeStake(operator)) {
            revert DelegationErrors.LegacySlashRequiresAllMode(operator);
        }

        Types.OperatorRewardPool storage pool = _rewardPools[operator];

        // Calculate total stake (operator self-stake + delegated assets)
        uint256 slashAmount = amount;
        uint256 operatorStake = meta.stake;
        uint256 totalStake = operatorStake + pool.totalAssets;

        if (totalStake == 0) {
            return 0;
        }

        // Cap slash to total stake
        if (slashAmount > totalStake) {
            slashAmount = totalStake;
        }

        // Calculate proportional slash amounts
        uint256 operatorSlashAmount = (slashAmount * operatorStake) / totalStake;

        // Record exchange rate before slash
        uint256 exchangeRateBefore = _getExchangeRate(operator);

        // Slash operator's self-stake
        uint256 actualOperatorSlash = _slashOperatorStake(operator, operatorSlashAmount);

        // Slash delegators by reducing totalAssets - O(1)!
        // Shares stay constant, but each share is now worth less
        uint256 actualDelegatorSlash = _slashAllModePool(operator, slashAmount - operatorSlashAmount);

        actualSlashed = actualOperatorSlash + actualDelegatorSlash;

        // Record exchange rate after slash
        uint256 exchangeRateAfter = _getExchangeRate(operator);

        // Deactivate operator if below minimum
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        uint256 minStake = _assetConfigs[nativeHash].minOperatorStake;
        if (meta.stake < minStake) {
            meta.status = Types.OperatorStatus.Inactive;
        }

        // Record slash for historical queries
        // Note: Legacy slash doesn't have blueprintId, so we use 0
        uint64 slashId = nextSlashId[operator]++;
        slashHistory[operator][slashId] = SlashRecord({
            round: currentRound,
            serviceId: serviceId,
            blueprintId: 0, // Legacy slash - blueprint unknown
            totalSlashed: actualSlashed,
            exchangeRateBefore: exchangeRateBefore,
            exchangeRateAfter: exchangeRateAfter,
            evidence: evidence
        });

        // Increment per-service slash count (no blueprint for legacy slash)
        serviceSlashCount[serviceId][operator]++;

        // Update slash factor for lazy slashing of pending unstakes
        if (totalStake > 0) {
            uint256 slashBps = (actualSlashed * BPS_DENOMINATOR) / totalStake;
            _updateSlashFactor(operator, slashBps);
        }

        emit Slashed(operator, serviceId, actualOperatorSlash, actualDelegatorSlash, exchangeRateAfter);
        emit SlashRecorded(operator, slashId, actualSlashed, exchangeRateBefore, exchangeRateAfter);
    }

    function _hasFixedModeStake(address operator) internal view returns (bool) {
        EnumerableSet.UintSet storage blueprints = _operatorBlueprints[operator];
        uint256 length = blueprints.length();
        if (length == 0) {
            return false;
        }

        for (uint256 i = 0; i < length; i++) {
            uint64 blueprintId = uint64(blueprints.at(i));
            if (_blueprintPools[operator][blueprintId].totalAssets > 0) {
                return true;
            }
        }
        return false;
    }

    /// @notice Slash operator's self-stake
    function _slashOperatorStake(
        address operator,
        uint256 amount
    ) internal returns (uint256 slashed) {
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
    function _slashAllModePool(
        address operator,
        uint256 amount
    ) internal returns (uint256 slashed) {
        Types.OperatorRewardPool storage pool = _rewardPools[operator];

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
        uint256 amount
    ) internal returns (uint256 slashed) {
        Types.OperatorRewardPool storage pool = _blueprintPools[operator][blueprintId];

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

    /// @notice Slash with percentage for a specific blueprint
    /// @param operator Operator to slash
    /// @param blueprintId Blueprint where violation occurred
    /// @param serviceId Service ID
    /// @param percentageBps Slash percentage in basis points
    /// @param evidence Evidence hash
    function _slashByPercentageForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint16 percentageBps,
        bytes32 evidence
    ) internal returns (uint256 actualSlashed) {
        require(percentageBps <= BPS_DENOMINATOR, "Invalid percentage");

        // Calculate total exposed stake for this blueprint
        uint256 operatorStake = _operatorMetadata[operator].stake;
        uint256 allModeStake = _rewardPools[operator].totalAssets;
        uint256 fixedModeStake = _blueprintPools[operator][blueprintId].totalAssets;
        uint256 totalExposedStake = operatorStake + allModeStake + fixedModeStake;

        uint256 amount = (totalExposedStake * percentageBps) / BPS_DENOMINATOR;
        return _slashForBlueprint(operator, blueprintId, serviceId, amount, evidence);
    }

    /// @notice Slash with percentage (alternative interface) - legacy
    /// @param operator Operator to slash
    /// @param serviceId Service ID
    /// @param percentageBps Slash percentage in basis points
    /// @param evidence Evidence hash
    function _slashByPercentage(
        address operator,
        uint64 serviceId,
        uint16 percentageBps,
        bytes32 evidence
    ) internal returns (uint256 actualSlashed) {
        require(percentageBps <= BPS_DENOMINATOR, "Invalid percentage");

        uint256 operatorStake = _operatorMetadata[operator].stake;
        uint256 delegatedStake = _rewardPools[operator].totalAssets;
        uint256 totalStake = operatorStake + delegatedStake;

        uint256 amount = (totalStake * percentageBps) / BPS_DENOMINATOR;
        return _slash(operator, serviceId, amount, evidence);
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
    ) external view returns (uint256 lostAmount) {
        SlashRecord memory record = slashHistory[operator][slashId];
        if (record.round == 0) return 0; // Slash doesn't exist

        uint256 delegatorShares = _getDelegatorSharesForOperator(delegator, operator);
        if (delegatorShares == 0) return 0;

        // Calculate value lost: shares * (rateBefore - rateAfter) / PRECISION
        if (record.exchangeRateBefore > record.exchangeRateAfter) {
            uint256 rateDiff = record.exchangeRateBefore - record.exchangeRateAfter;
            lostAmount = (delegatorShares * rateDiff) / PRECISION;
        }
    }

    /// @notice Get total slashes for an operator
    function getSlashCount(address operator) external view returns (uint64) {
        return nextSlashId[operator];
    }

    /// @notice Get slash record details
    function getSlashRecord(
        address operator,
        uint64 slashId
    ) external view returns (SlashRecord memory) {
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
    // ROUND SNAPSHOTS (for historical slashing)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Take snapshot of operator state at round start
    /// @param operator Operator to snapshot
    function _snapshotOperator(address operator) internal {
        Types.OperatorMetadata storage meta = _operatorMetadata[operator];
        require(meta.status == Types.OperatorStatus.Active, "Not active");

        _atStake[currentRound][operator] = Types.OperatorSnapshot({
            stake: meta.stake,
            totalDelegated: _rewardPools[operator].totalAssets
        });
    }

    /// @notice Get snapshot for an operator at a specific round
    function getSnapshot(
        uint64 round,
        address operator
    ) public view returns (Types.OperatorSnapshot memory) {
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
    /// @dev Called from high-traffic functions to opportunistically advance rounds
    /// @return advanced True if the round was advanced, false if too early
    function _tryAdvanceRound() internal returns (bool advanced) {
        // Allow first advance if lastRoundAdvance is 0 (not yet initialized)
        if (lastRoundAdvance == 0 || block.timestamp >= lastRoundAdvance + roundDuration) {
            lastRoundAdvance = uint64(block.timestamp);
            currentRound++;
            return true;
        }
        return false;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // LAZY SLASHING FOR PENDING UNSTAKES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update slash factor after a slash - O(1) operation
    /// @dev Called internally after slashing to update factor for pending unstakes
    /// @param operator Operator whose factor to update
    /// @param slashBps Slash percentage in basis points
    function _updateSlashFactor(address operator, uint256 slashBps) internal {
        if (slashBps == 0 || slashBps > BPS_DENOMINATOR) return;

        uint256 currentFactor = getOperatorSlashFactor(operator);
        // New factor = current * (1 - slashBps/10000)
        uint256 newFactor = (currentFactor * (BPS_DENOMINATOR - slashBps)) / BPS_DENOMINATOR;
        _operatorSlashFactor[operator] = newFactor;
    }
}
