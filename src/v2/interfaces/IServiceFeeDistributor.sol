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

    /// @notice Called when an operator is about to leave a service
    /// @dev Drips all active streams for the operator BEFORE they're removed
    function onOperatorLeaving(uint64 serviceId, address operator) external;

    /// @notice Called when a service is terminated early
    /// @dev Cancels streaming payments and refunds remaining amounts to the service owner
    /// @param serviceId The terminated service ID
    /// @param refundRecipient Where to send the remaining payment (typically service owner)
    function onServiceTerminated(uint64 serviceId, address refundRecipient) external;
}

