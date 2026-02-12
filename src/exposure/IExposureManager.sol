// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";
import { ExposureTypes } from "./ExposureTypes.sol";

/// @title IExposureManager
/// @notice Interface for managing operator per-asset exposure limits
/// @dev Aligns with Tangle pallet exposure model
interface IExposureManager {
    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error ExposureTooHigh(address operator, address token, uint16 requested, uint16 limit);
    error ExposureTooLow(address operator, address token, uint16 requested, uint16 minimum);
    error AssetNotEnabled(address operator, address token);
    error InsufficientDelegation(address operator, address token, uint256 required, uint256 actual);
    error InvalidExposureConfig(string reason);
    error NotOperator(address account);

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when operator sets per-asset exposure limit
    event AssetExposureLimitSet(
        address indexed operator, Types.Asset asset, uint16 maxExposureBps, uint16 defaultExposureBps, bool enabled
    );

    /// @notice Emitted when operator updates global config
    event OperatorExposureConfigUpdated(
        address indexed operator, uint16 globalMaxExposureBps, bool requireExplicitApproval
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set exposure limit for a specific asset
    /// @param asset The asset to configure
    /// @param maxExposureBps Maximum exposure operator will commit (in basis points)
    /// @param defaultExposureBps Default exposure if not specified (0 = use max)
    /// @param enabled Whether operator accepts this asset
    function setAssetExposureLimit(
        Types.Asset calldata asset,
        uint16 maxExposureBps,
        uint16 defaultExposureBps,
        bool enabled
    )
        external;

    /// @notice Batch set exposure limits for multiple assets
    function batchSetAssetExposureLimits(ExposureTypes.OperatorAssetExposureLimit[] calldata limits) external;

    /// @notice Set global exposure configuration
    /// @param globalMaxExposureBps Default max for assets without explicit limit
    /// @param requireExplicitApproval If true, all assets must have explicit limits
    function setOperatorExposureConfig(uint16 globalMaxExposureBps, bool requireExplicitApproval) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Validate operator's security commitments against their limits and delegation
    /// @param operator The operator address
    /// @param requirements Service security requirements
    /// @param commitments Operator's proposed commitments
    /// @return valid True if all commitments are valid
    /// @return result Detailed validation result (for debugging)
    function validateCommitments(
        address operator,
        Types.AssetSecurityRequirement[] calldata requirements,
        Types.AssetSecurityCommitment[] calldata commitments
    )
        external
        view
        returns (bool valid, ExposureTypes.CommitmentValidationResult memory result);

    /// @notice Check if operator can accept a specific exposure for an asset
    /// @param operator The operator address
    /// @param asset The asset
    /// @param exposureBps Requested exposure in basis points
    /// @return canAccept True if operator's limits allow this exposure
    /// @return effectiveLimit The operator's effective limit for this asset
    function canAcceptExposure(
        address operator,
        Types.Asset calldata asset,
        uint16 exposureBps
    )
        external
        view
        returns (bool canAccept, uint16 effectiveLimit);

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate exposed amount for an operator-asset pair
    /// @param operator The operator
    /// @param asset The asset
    /// @param exposureBps Exposure percentage in basis points
    /// @return delegatedAmount Total delegation to operator for this asset
    /// @return exposedAmount Amount exposed based on percentage
    function calculateExposedAmount(
        address operator,
        Types.Asset calldata asset,
        uint16 exposureBps
    )
        external
        view
        returns (uint256 delegatedAmount, uint256 exposedAmount);

    /// @notice Get full exposure breakdown for an operator in a service
    /// @param operator The operator
    /// @param serviceId The service ID
    /// @return exposure Aggregate exposure information
    function getOperatorServiceExposure(
        address operator,
        uint64 serviceId
    )
        external
        view
        returns (ExposureTypes.AggregateExposure memory exposure);

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get operator's exposure limit for an asset
    /// @param operator The operator address
    /// @param asset The asset
    /// @return limit The exposure limit (zero if not set)
    function getAssetExposureLimit(
        address operator,
        Types.Asset calldata asset
    )
        external
        view
        returns (ExposureTypes.OperatorAssetExposureLimit memory limit);

    /// @notice Get operator's global exposure config
    /// @param operator The operator address
    /// @return config The exposure configuration
    function getOperatorExposureConfig(address operator)
        external
        view
        returns (ExposureTypes.OperatorExposureConfig memory config);

    /// @notice Get the effective exposure limit for an operator-asset pair
    /// @dev Returns per-asset limit if set, else global limit
    /// @param operator The operator
    /// @param asset The asset
    /// @return effectiveLimit The effective limit in basis points
    /// @return isExplicit True if limit is from per-asset config
    function getEffectiveExposureLimit(
        address operator,
        Types.Asset calldata asset
    )
        external
        view
        returns (uint16 effectiveLimit, bool isExplicit);
}
