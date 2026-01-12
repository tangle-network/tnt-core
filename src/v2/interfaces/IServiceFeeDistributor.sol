// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title IServiceFeeDistributor
/// @notice Tracks service-fee payouts to restakers across payment tokens
/// @dev Receives delegation-change hooks from MultiAssetDelegation and fee-distribution calls from Tangle.
interface IServiceFeeDistributor {
    function distributeServiceFee(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    ) external payable;

    /// @notice Distribute inflation-funded restaker rewards using service exposure weights
    /// @dev Intended for InflationPool; rewards are paid in the provided token (TNT).
    function distributeInflationReward(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    ) external payable;

    /// @notice Claim rewards for a specific delegator position and token
    function claimFor(
        address token,
        address operator,
        Types.Asset calldata asset
    ) external returns (uint256 amount);

    /// @notice Claim all pending rewards across all positions for a token
    function claimAll(address token) external returns (uint256 totalAmount);

    /// @notice Claim all pending rewards for multiple tokens
    function claimAllBatch(address[] calldata tokens) external returns (uint256[] memory amounts);

    /// @notice Preview pending rewards for a delegator across all positions for a token
    function pendingRewards(address delegator, address token) external view returns (uint256 pending);

    /// @notice Return all operators a delegator has positions with
    function delegatorOperators(address delegator) external view returns (address[] memory operators);

    /// @notice Return all asset hashes a delegator has positions for with an operator
    function delegatorAssets(address delegator, address operator) external view returns (bytes32[] memory assetHashes);

    /// @notice Return a delegator's position details
    function getPosition(
        address delegator,
        address operator,
        bytes32 assetHash
    ) external view returns (uint8 mode, uint256 principal, uint256 score);

    /// @notice Return reward tokens ever distributed for an operator
    function operatorRewardTokens(address operator) external view returns (address[] memory tokens);

    function onDelegationChanged(
        address delegator,
        address operator,
        Types.Asset calldata asset,
        uint256 amount,
        bool isIncrease,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds,
        uint16 lockMultiplierBps
    ) external;

    function onBlueprintAdded(
        address delegator,
        address operator,
        Types.Asset calldata asset,
        uint64 blueprintId
    ) external;

    function onBlueprintRemoved(
        address delegator,
        address operator,
        Types.Asset calldata asset,
        uint64 blueprintId
    ) external;

    function getPoolScore(
        address operator,
        uint64 blueprintId,
        Types.Asset calldata asset
    ) external view returns (uint256 allScore, uint256 fixedScore);

    /// @notice Get USD-weighted exposure for an operator/service
    /// @dev Returns total USD exposure across All+Fixed pools for the service.
    function getOperatorServiceUsdExposure(
        uint64 serviceId,
        uint64 blueprintId,
        address operator
    ) external view returns (uint256 totalUsdExposure);

    /// @notice Called when an operator is about to leave a service
    /// @dev Drips all active streams for the operator BEFORE they're removed
    function onOperatorLeaving(uint64 serviceId, address operator) external;

    /// @notice Called when a service is terminated early
    /// @dev Cancels streaming payments and refunds remaining amounts to the service owner
    /// @param serviceId The terminated service ID
    /// @param refundRecipient Where to send the remaining payment (typically service owner)
    function onServiceTerminated(uint64 serviceId, address refundRecipient) external;
}
