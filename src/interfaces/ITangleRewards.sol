// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ITangleRewards
/// @notice Reward distribution and claiming interface
interface ITangleRewards {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event PaymentDistributed(
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        address indexed token,
        uint256 grossAmount,
        address developerRecipient,
        uint256 developerAmount,
        uint256 protocolAmount,
        uint256 operatorPoolAmount,
        uint256 restakerPoolAmount
    );

    event OperatorRewardAccrued(
        uint64 indexed serviceId,
        address indexed operator,
        address indexed token,
        uint64 blueprintId,
        uint256 amount
    );

    event RewardsClaimed(address indexed account, address indexed token, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim accumulated rewards (native token)
    function claimRewards() external;

    /// @notice Claim accumulated rewards for a specific token
    function claimRewards(address token) external;

    /// @notice Claim accumulated rewards for multiple tokens
    function claimRewardsBatch(address[] calldata tokens) external;

    /// @notice Claim accumulated rewards for all pending tokens
    function claimRewardsAll() external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pending rewards for an account (native token)
    function pendingRewards(address account) external view returns (uint256);

    /// @notice Get pending rewards for an account and token
    function pendingRewards(address account, address token) external view returns (uint256);

    /// @notice List tokens with non-zero pending rewards for an account
    /// @dev Convenience view; mappings are not enumerable.
    function rewardTokens(address account) external view returns (address[] memory);
}
