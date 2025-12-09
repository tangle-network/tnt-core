// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Types} from "../libraries/Types.sol";
import {IRestaking} from "../interfaces/IRestaking.sol";
import {IExposureManager} from "./IExposureManager.sol";
import {ExposureTypes} from "./ExposureTypes.sol";

/// @title ExposureManager
/// @notice Manages operator per-asset exposure limits and validates commitments
/// @dev Aligns with Tangle pallet exposure model (percentage-based, per-asset)
///
/// Architecture:
/// 1. Operators set per-asset exposure limits (max % they'll commit)
/// 2. Service requesters specify security requirements (min/max %)
/// 3. When operators approve, their commitments are validated against:
///    - Their own exposure limits
///    - Min/max from service requirements
///    - Their actual delegation for each asset
/// 4. Exposure used in both reward distribution and slashing calculations
contract ExposureManager is IExposureManager {
    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The restaking contract for delegation queries
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IRestaking public immutable restaking;

    /// @notice Operator global exposure configs
    mapping(address => ExposureTypes.OperatorExposureConfig) public operatorConfigs;

    /// @notice Operator per-asset exposure limits (operator => assetHash => limit)
    mapping(address => mapping(bytes32 => ExposureTypes.OperatorAssetExposureLimit))
        internal _assetExposureLimits;

    /// @notice Track which assets an operator has configured
    mapping(address => bytes32[]) internal _operatorConfiguredAssets;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _restaking) {
        require(_restaking != address(0), "Zero address");
        restaking = IRestaking(_restaking);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IExposureManager
    function setAssetExposureLimit(
        Types.Asset calldata asset,
        uint16 maxExposureBps,
        uint16 defaultExposureBps,
        bool enabled
    ) external override {
        _validateExposureConfig(maxExposureBps, defaultExposureBps);

        bytes32 assetHash = _hashAsset(asset);
        ExposureTypes.OperatorAssetExposureLimit storage limit = _assetExposureLimits[msg.sender][assetHash];

        // Track if this is a new asset for the operator
        if (limit.maxExposureBps == 0 && maxExposureBps > 0) {
            _operatorConfiguredAssets[msg.sender].push(assetHash);
        }

        limit.asset = asset;
        limit.maxExposureBps = maxExposureBps;
        limit.defaultExposureBps = defaultExposureBps;
        limit.enabled = enabled;

        emit AssetExposureLimitSet(msg.sender, asset, maxExposureBps, defaultExposureBps, enabled);
    }

    /// @inheritdoc IExposureManager
    function batchSetAssetExposureLimits(
        ExposureTypes.OperatorAssetExposureLimit[] calldata limits
    ) external override {
        for (uint256 i = 0; i < limits.length; i++) {
            _validateExposureConfig(limits[i].maxExposureBps, limits[i].defaultExposureBps);

            bytes32 assetHash = _hashAsset(limits[i].asset);
            ExposureTypes.OperatorAssetExposureLimit storage limit = _assetExposureLimits[msg.sender][assetHash];

            if (limit.maxExposureBps == 0 && limits[i].maxExposureBps > 0) {
                _operatorConfiguredAssets[msg.sender].push(assetHash);
            }

            limit.asset = limits[i].asset;
            limit.maxExposureBps = limits[i].maxExposureBps;
            limit.defaultExposureBps = limits[i].defaultExposureBps;
            limit.enabled = limits[i].enabled;

            emit AssetExposureLimitSet(
                msg.sender,
                limits[i].asset,
                limits[i].maxExposureBps,
                limits[i].defaultExposureBps,
                limits[i].enabled
            );
        }
    }

    /// @inheritdoc IExposureManager
    function setOperatorExposureConfig(
        uint16 globalMaxExposureBps,
        bool requireExplicitApproval
    ) external override {
        if (globalMaxExposureBps > ExposureTypes.MAX_EXPOSURE_BPS) {
            revert InvalidExposureConfig("Global max exceeds 100%");
        }

        ExposureTypes.OperatorExposureConfig storage config = operatorConfigs[msg.sender];
        config.globalMaxExposureBps = globalMaxExposureBps;
        config.requireExplicitApproval = requireExplicitApproval;
        config.updatedAt = uint64(block.timestamp);

        emit OperatorExposureConfigUpdated(msg.sender, globalMaxExposureBps, requireExplicitApproval);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IExposureManager
    function validateCommitments(
        address operator,
        Types.AssetSecurityRequirement[] calldata requirements,
        Types.AssetSecurityCommitment[] calldata commitments
    ) external view override returns (bool valid, ExposureTypes.CommitmentValidationResult memory result) {
        // 1. Check operator is registered
        if (!restaking.isOperator(operator)) {
            return (false, ExposureTypes.CommitmentValidationResult({
                valid: false,
                reason: "Not an operator",
                asset: Types.Asset(Types.AssetKind.Native, address(0)),
                requiredStake: 0,
                actualStake: 0
            }));
        }

        // 2. Check each requirement has a matching valid commitment
        for (uint256 i = 0; i < requirements.length; i++) {
            Types.AssetSecurityRequirement calldata req = requirements[i];
            bool found = false;

            for (uint256 j = 0; j < commitments.length; j++) {
                if (_assetsMatch(req.asset, commitments[j].asset)) {
                    // Found matching commitment, validate it
                    (bool commitValid, ExposureTypes.CommitmentValidationResult memory commitResult) =
                        _validateSingleCommitment(operator, req, commitments[j]);

                    if (!commitValid) {
                        return (false, commitResult);
                    }
                    found = true;
                    break;
                }
            }

            if (!found) {
                return (false, ExposureTypes.CommitmentValidationResult({
                    valid: false,
                    reason: "Missing commitment for required asset",
                    asset: req.asset,
                    requiredStake: 0,
                    actualStake: 0
                }));
            }
        }

        // 3. Check for unexpected commitments (assets not in requirements)
        for (uint256 j = 0; j < commitments.length; j++) {
            bool expected = false;
            for (uint256 i = 0; i < requirements.length; i++) {
                if (_assetsMatch(requirements[i].asset, commitments[j].asset)) {
                    expected = true;
                    break;
                }
            }
            if (!expected) {
                return (false, ExposureTypes.CommitmentValidationResult({
                    valid: false,
                    reason: "Unexpected asset commitment",
                    asset: commitments[j].asset,
                    requiredStake: 0,
                    actualStake: 0
                }));
            }
        }

        return (true, ExposureTypes.CommitmentValidationResult({
            valid: true,
            reason: "",
            asset: Types.Asset(Types.AssetKind.Native, address(0)),
            requiredStake: 0,
            actualStake: 0
        }));
    }

    /// @notice Validate a single commitment
    function _validateSingleCommitment(
        address operator,
        Types.AssetSecurityRequirement calldata requirement,
        Types.AssetSecurityCommitment calldata commitment
    ) internal view returns (bool, ExposureTypes.CommitmentValidationResult memory) {
        // Check exposure is within requirement bounds
        if (commitment.exposureBps < requirement.minExposureBps) {
            return (false, ExposureTypes.CommitmentValidationResult({
                valid: false,
                reason: "Commitment below minimum",
                asset: requirement.asset,
                requiredStake: 0,
                actualStake: 0
            }));
        }

        if (commitment.exposureBps > requirement.maxExposureBps) {
            return (false, ExposureTypes.CommitmentValidationResult({
                valid: false,
                reason: "Commitment above maximum",
                asset: requirement.asset,
                requiredStake: 0,
                actualStake: 0
            }));
        }

        // Check operator's own exposure limit
        (uint16 effectiveLimit, ) = _getEffectiveExposureLimit(operator, requirement.asset);
        if (effectiveLimit > 0 && commitment.exposureBps > effectiveLimit) {
            return (false, ExposureTypes.CommitmentValidationResult({
                valid: false,
                reason: "Exceeds operator limit",
                asset: requirement.asset,
                requiredStake: 0,
                actualStake: 0
            }));
        }

        // Check operator has sufficient delegation for this asset
        uint256 delegation = _getOperatorDelegationForAsset(operator, requirement.asset);
        if (delegation == 0) {
            return (false, ExposureTypes.CommitmentValidationResult({
                valid: false,
                reason: "No delegation for asset",
                asset: requirement.asset,
                requiredStake: 1, // At least some stake required
                actualStake: 0
            }));
        }

        return (true, ExposureTypes.CommitmentValidationResult({
            valid: true,
            reason: "",
            asset: requirement.asset,
            requiredStake: 0,
            actualStake: delegation
        }));
    }

    /// @inheritdoc IExposureManager
    function canAcceptExposure(
        address operator,
        Types.Asset calldata asset,
        uint16 exposureBps
    ) external view override returns (bool canAccept, uint16 effectiveLimit) {
        (effectiveLimit, ) = _getEffectiveExposureLimit(operator, asset);

        // If no limit set and operator doesn't require explicit approval, allow any exposure
        if (effectiveLimit == 0 && !operatorConfigs[operator].requireExplicitApproval) {
            return (true, ExposureTypes.MAX_EXPOSURE_BPS);
        }

        // Check against operator's limit
        canAccept = exposureBps <= effectiveLimit;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IExposureManager
    function calculateExposedAmount(
        address operator,
        Types.Asset calldata asset,
        uint16 exposureBps
    ) external view override returns (uint256 delegatedAmount, uint256 exposedAmount) {
        delegatedAmount = _getOperatorDelegationForAsset(operator, asset);
        exposedAmount = (delegatedAmount * exposureBps) / ExposureTypes.BPS_DENOMINATOR;
    }

    /// @inheritdoc IExposureManager
    function getOperatorServiceExposure(
        address operator,
        uint64 serviceId
    ) external pure override returns (ExposureTypes.AggregateExposure memory exposure) {
        // This would need access to service storage to get commitments
        // For now, return empty - actual implementation needs Tangle integration
        exposure.operator = operator;
        exposure.serviceId = serviceId;
        exposure.totalExposedValue = 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IExposureManager
    function getAssetExposureLimit(
        address operator,
        Types.Asset calldata asset
    ) external view override returns (ExposureTypes.OperatorAssetExposureLimit memory limit) {
        bytes32 assetHash = _hashAsset(asset);
        return _assetExposureLimits[operator][assetHash];
    }

    /// @inheritdoc IExposureManager
    function getOperatorExposureConfig(
        address operator
    ) external view override returns (ExposureTypes.OperatorExposureConfig memory config) {
        return operatorConfigs[operator];
    }

    /// @inheritdoc IExposureManager
    function getEffectiveExposureLimit(
        address operator,
        Types.Asset calldata asset
    ) external view override returns (uint16 effectiveLimit, bool isExplicit) {
        return _getEffectiveExposureLimit(operator, asset);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _getEffectiveExposureLimit(
        address operator,
        Types.Asset memory asset
    ) internal view returns (uint16 effectiveLimit, bool isExplicit) {
        bytes32 assetHash = _hashAsset(asset);
        ExposureTypes.OperatorAssetExposureLimit storage perAsset = _assetExposureLimits[operator][assetHash];

        if (perAsset.maxExposureBps > 0) {
            return (perAsset.maxExposureBps, true);
        }

        ExposureTypes.OperatorExposureConfig storage config = operatorConfigs[operator];
        if (config.globalMaxExposureBps > 0) {
            return (config.globalMaxExposureBps, false);
        }

        // Default: 100% if no limits set
        return (ExposureTypes.MAX_EXPOSURE_BPS, false);
    }

    function _getOperatorDelegationForAsset(
        address operator,
        Types.Asset memory asset
    ) internal view returns (uint256) {
        if (asset.kind == Types.AssetKind.Native) {
            // Native asset uses operator stake + native delegations
            return restaking.getOperatorStake(operator);
        } else {
            // ERC20 delegations - would need per-asset tracking
            // For now, use total delegation (actual implementation needs asset-specific tracking)
            return restaking.getOperatorDelegatedStake(operator);
        }
    }

    function _hashAsset(Types.Asset memory asset) internal pure returns (bytes32) {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(abi.encode(asset.kind, asset.token));
    }

    function _assetsMatch(Types.Asset memory a, Types.Asset memory b) internal pure returns (bool) {
        return a.kind == b.kind && a.token == b.token;
    }

    function _validateExposureConfig(uint16 maxBps, uint16 defaultBps) internal pure {
        if (maxBps > ExposureTypes.MAX_EXPOSURE_BPS) {
            revert InvalidExposureConfig("Max exceeds 100%");
        }
        if (defaultBps > maxBps && defaultBps != 0) {
            revert InvalidExposureConfig("Default exceeds max");
        }
    }
}
