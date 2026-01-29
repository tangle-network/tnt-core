// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IRewardsManager
/// @notice Interface for reward vault management - called by MultiAssetDelegation
/// @dev Mirrors the Substrate RewardsManager trait pattern
interface IRewardsManager {
    /// @notice Records a delegation for reward tracking
    /// @param delegator The account making the delegation
    /// @param operator The operator being delegated to
    /// @param asset The asset being delegated (address(0) for native)
    /// @param amount The amount being delegated
    /// @param lockMultiplierBps Lock multiplier in basis points (10000 = 1x, 0 = no lock)
    function recordDelegate(
        address delegator,
        address operator,
        address asset,
        uint256 amount,
        uint16 lockMultiplierBps
    ) external;

    /// @notice Records an undelegation
    /// @param delegator The account making the undelegation
    /// @param operator The operator being undelegated from
    /// @param asset The asset being undelegated
    /// @param amount The amount being undelegated
    function recordUndelegate(
        address delegator,
        address operator,
        address asset,
        uint256 amount
    ) external;

    /// @notice Records a service reward for an operator
    /// @param operator The operator receiving the reward
    /// @param asset The reward asset
    /// @param amount The reward amount
    function recordServiceReward(
        address operator,
        address asset,
        uint256 amount
    ) external;

    /// @notice Get remaining deposit capacity for an asset vault
    /// @param asset The asset to query
    /// @return remaining The remaining deposit capacity
    function getAssetDepositCapRemaining(address asset) external view returns (uint256 remaining);
}
