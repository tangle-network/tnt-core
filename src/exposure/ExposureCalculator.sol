// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Types} from "../libraries/Types.sol";
import {ExposureTypes} from "./ExposureTypes.sol";
import {IPriceOracle} from "../oracles/interfaces/IPriceOracle.sol";

/// @title ExposureCalculator
/// @notice Library for calculating operator exposure across multiple assets
/// @dev Provides both percentage-based (native) and USD-denominated calculations
library ExposureCalculator {
    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate exposed amount from delegation and exposure percentage
    /// @param delegatedAmount Total delegation to operator for an asset
    /// @param exposureBps Exposure percentage in basis points (0-10000)
    /// @return exposedAmount Amount exposed based on percentage
    function calculateExposedAmount(
        uint256 delegatedAmount,
        uint16 exposureBps
    ) internal pure returns (uint256 exposedAmount) {
        return (delegatedAmount * exposureBps) / ExposureTypes.BPS_DENOMINATOR;
    }

    /// @notice Calculate the weighted average exposure across multiple assets
    /// @dev Uses delegation amounts as weights (in native units, not USD)
    /// @param delegations Array of delegation amounts per asset
    /// @param exposureBps Array of exposure percentages per asset
    /// @return weightedExposureBps The weighted average exposure in basis points
    function calculateWeightedExposure(
        uint256[] memory delegations,
        uint16[] memory exposureBps
    ) internal pure returns (uint16 weightedExposureBps) {
        require(delegations.length == exposureBps.length, "Length mismatch");

        if (delegations.length == 0) return 0;

        uint256 totalDelegation = 0;
        uint256 weightedSum = 0;

        for (uint256 i = 0; i < delegations.length; i++) {
            totalDelegation += delegations[i];
            weightedSum += uint256(exposureBps[i]) * delegations[i];
        }

        if (totalDelegation == 0) return 0;

        // Casting is safe because weighted average of basis points stays within 0-10000.
        // forge-lint: disable-next-line(unsafe-typecast)
        return uint16(weightedSum / totalDelegation);
    }

    /// @notice Calculate USD-weighted average exposure using price oracle
    /// @param tokens Array of token addresses (address(0) for native)
    /// @param delegations Array of delegation amounts per asset
    /// @param exposureBps Array of exposure percentages per asset
    /// @param oracle Price oracle for USD conversions
    /// @return weightedExposureBps USD-weighted average exposure
    /// @return totalValueUsd Total value of all delegations in USD (18 decimals)
    // forge-lint: disable-next-line(mixed-case-function)
    function calculateUSDWeightedExposure(
        address[] memory tokens,
        uint256[] memory delegations,
        uint16[] memory exposureBps,
        IPriceOracle oracle
    ) internal view returns (uint16 weightedExposureBps, uint256 totalValueUsd) {
        require(tokens.length == delegations.length, "Length mismatch");
        require(delegations.length == exposureBps.length, "Length mismatch");

        if (delegations.length == 0) return (0, 0);

        uint256[] memory usdValues = new uint256[](delegations.length);

        // Convert each delegation to USD
        for (uint256 i = 0; i < delegations.length; i++) {
            if (delegations[i] > 0) {
                usdValues[i] = oracle.toUSD(tokens[i], delegations[i]);
                totalValueUsd += usdValues[i];
            }
        }

        if (totalValueUsd == 0) return (0, 0);

        // Calculate USD-weighted exposure
        uint256 weightedSum = 0;
        for (uint256 i = 0; i < delegations.length; i++) {
            weightedSum += uint256(exposureBps[i]) * usdValues[i];
        }

        // Casting is safe because weighted average of basis points stays within 0-10000.
        // forge-lint: disable-next-line(unsafe-typecast)
        weightedExposureBps = uint16(weightedSum / totalValueUsd);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH AMOUNT CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate slash amount based on exposure percentage
    /// @dev Slash is applied to the exposed portion of delegation
    /// @param delegatedAmount Total delegation for the asset
    /// @param exposureBps Operator's exposure percentage
    /// @param slashBps Slash percentage (of exposed amount)
    /// @return slashAmount Amount to slash
    function calculateSlashAmount(
        uint256 delegatedAmount,
        uint16 exposureBps,
        uint16 slashBps
    ) internal pure returns (uint256 slashAmount) {
        uint256 exposedAmount = calculateExposedAmount(delegatedAmount, exposureBps);
        return (exposedAmount * slashBps) / ExposureTypes.BPS_DENOMINATOR;
    }

    /// @notice Calculate max slashable amount for an operator-asset pair
    /// @param delegatedAmount Total delegation
    /// @param exposureBps Operator's exposure percentage
    /// @return maxSlashable Maximum amount that can be slashed
    function calculateMaxSlashable(
        uint256 delegatedAmount,
        uint16 exposureBps
    ) internal pure returns (uint256 maxSlashable) {
        return calculateExposedAmount(delegatedAmount, exposureBps);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate reward share based on exposure percentage
    /// @dev Higher exposure = higher risk = higher reward share
    /// @param delegatedAmount Total delegation for the asset
    /// @param exposureBps Operator's exposure percentage
    /// @param totalReward Total reward pool to distribute
    /// @param totalExposedValue Sum of all exposed values in the service
    /// @return rewardShare Operator's share of rewards
    function calculateRewardShare(
        uint256 delegatedAmount,
        uint16 exposureBps,
        uint256 totalReward,
        uint256 totalExposedValue
    ) internal pure returns (uint256 rewardShare) {
        if (totalExposedValue == 0) return 0;

        uint256 exposedAmount = calculateExposedAmount(delegatedAmount, exposureBps);
        return (totalReward * exposedAmount) / totalExposedValue;
    }

    /// @notice Calculate total exposed value for a service across all operators
    /// @param delegations Array of delegation amounts (per operator)
    /// @param exposureBps Array of exposure percentages (per operator)
    /// @return totalExposed Sum of all exposed values
    function calculateTotalExposedValue(
        uint256[] memory delegations,
        uint16[] memory exposureBps
    ) internal pure returns (uint256 totalExposed) {
        require(delegations.length == exposureBps.length, "Length mismatch");

        for (uint256 i = 0; i < delegations.length; i++) {
            totalExposed += calculateExposedAmount(delegations[i], exposureBps[i]);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if exposure is within valid range
    /// @param exposureBps Exposure to validate
    /// @return valid True if exposure is between MIN and MAX
    function isValidExposure(uint16 exposureBps) internal pure returns (bool valid) {
        return exposureBps >= ExposureTypes.MIN_EXPOSURE_BPS &&
               exposureBps <= ExposureTypes.MAX_EXPOSURE_BPS;
    }

    /// @notice Check if exposure is within specified bounds
    /// @param exposureBps Exposure to validate
    /// @param minBps Minimum allowed exposure
    /// @param maxBps Maximum allowed exposure
    /// @return valid True if exposure is within bounds
    function isWithinBounds(
        uint16 exposureBps,
        uint16 minBps,
        uint16 maxBps
    ) internal pure returns (bool valid) {
        return exposureBps >= minBps && exposureBps <= maxBps;
    }

    /// @notice Clamp exposure to valid range
    /// @param exposureBps Exposure to clamp
    /// @return clamped Clamped exposure value
    function clampExposure(uint16 exposureBps) internal pure returns (uint16 clamped) {
        if (exposureBps < ExposureTypes.MIN_EXPOSURE_BPS) {
            return ExposureTypes.MIN_EXPOSURE_BPS;
        }
        if (exposureBps > ExposureTypes.MAX_EXPOSURE_BPS) {
            return ExposureTypes.MAX_EXPOSURE_BPS;
        }
        return exposureBps;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // AGGREGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Build calculated exposure for an operator-asset pair
    /// @param operator Operator address
    /// @param asset The asset
    /// @param delegatedAmount Delegation to operator
    /// @param exposureBps Exposure percentage
    /// @param serviceId Service ID (0 if aggregate)
    /// @return exposure Calculated exposure struct
    function buildCalculatedExposure(
        address operator,
        Types.Asset memory asset,
        uint256 delegatedAmount,
        uint16 exposureBps,
        uint64 serviceId
    ) internal pure returns (ExposureTypes.CalculatedExposure memory exposure) {
        exposure.operator = operator;
        exposure.asset = asset;
        exposure.delegatedAmount = delegatedAmount;
        exposure.exposureBps = exposureBps;
        exposure.exposedAmount = calculateExposedAmount(delegatedAmount, exposureBps);
        exposure.serviceId = serviceId;
    }

    /// @notice Aggregate multiple calculated exposures into a single summary
    /// @param exposures Array of calculated exposures
    /// @param operator Operator address
    /// @param serviceId Service ID
    /// @return aggregate Aggregated exposure
    function aggregateExposures(
        ExposureTypes.CalculatedExposure[] memory exposures,
        address operator,
        uint64 serviceId
    ) internal pure returns (ExposureTypes.AggregateExposure memory aggregate) {
        aggregate.operator = operator;
        aggregate.serviceId = serviceId;
        aggregate.perAsset = exposures;

        for (uint256 i = 0; i < exposures.length; i++) {
            aggregate.totalExposedValue += exposures[i].exposedAmount;
        }
    }
}
