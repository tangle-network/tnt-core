// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleRewards
/// @notice Reward distribution and claiming interface
interface ITangleRewards {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event RewardsDistributed(
        uint64 indexed serviceId,
        uint256 developerAmount,
        uint256 protocolAmount,
        uint256 operatorAmount,
        uint256 restakerAmount
    );

    event RewardsClaimed(address indexed account, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim accumulated rewards (native token)
    function claimRewards() external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pending rewards for an account (native token)
    function pendingRewards(address account) external view returns (uint256);
}
