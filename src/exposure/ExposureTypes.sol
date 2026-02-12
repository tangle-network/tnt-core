// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ExposureTypes
/// @notice Type definitions for the exposure system
/// @dev Aligns with Tangle pallet exposure model (percentage-based, per-asset)
library ExposureTypes {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Basis points denominator (100% = 10000)
    uint16 public constant BPS_DENOMINATOR = 10_000;

    /// @notice Maximum exposure (100%)
    uint16 public constant MAX_EXPOSURE_BPS = 10_000;

    /// @notice Minimum non-zero exposure (0.01%)
    uint16 public constant MIN_EXPOSURE_BPS = 1;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR EXPOSURE LIMITS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator's per-asset exposure limit
    /// @dev Operators can set maximum exposure % they're willing to commit per asset
    struct OperatorAssetExposureLimit {
        Types.Asset asset; // The asset
        uint16 maxExposureBps; // Maximum exposure operator will accept (0 = disabled)
        uint16 defaultExposureBps; // Default exposure if not specified (0 = use max)
        bool enabled; // Whether operator accepts this asset
    }

    /// @notice Full operator exposure configuration
    struct OperatorExposureConfig {
        uint16 globalMaxExposureBps; // Default max if no per-asset limit set
        bool requireExplicitApproval; // If true, operator must approve each asset
        uint64 updatedAt; // Last config update timestamp
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculated exposure for an operator-asset-service tuple
    struct CalculatedExposure {
        address operator;
        Types.Asset asset;
        uint256 delegatedAmount; // Total delegated to operator for this asset
        uint16 exposureBps; // Committed exposure percentage
        uint256 exposedAmount; // delegatedAmount * exposureBps / 10000
        uint64 serviceId; // 0 if aggregate
    }

    /// @notice Aggregate exposure across multiple assets (for display/comparison)
    struct AggregateExposure {
        address operator;
        uint64 serviceId;
        CalculatedExposure[] perAsset; // Per-asset breakdown
        uint256 totalExposedValue; // Sum of all exposed amounts (in native units, not USD)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION RESULTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Result of validating a commitment
    struct CommitmentValidationResult {
        bool valid;
        string reason; // Empty if valid
        Types.Asset asset; // Asset that failed (if any)
        uint256 requiredStake; // Required delegation (if stake check failed)
        uint256 actualStake; // Actual delegation (if stake check failed)
    }
}
