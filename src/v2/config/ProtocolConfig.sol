// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ProtocolConfig
/// @notice Central default parameters for the Tangle protocol
/// @dev Keeps network-wide defaults in one place for consistency
library ProtocolConfig {
    // Restaking round/lock configuration (assuming ~12s blocks)
    uint64 internal constant ROUND_DURATION_BLOCKS = 7_200; // ≈ 1 day
    uint64 internal constant DELEGATOR_DELAY_ROUNDS = 7;     // ≈ 1 week
    uint64 internal constant OPERATOR_DELAY_ROUNDS = 7;      // ≈ 1 week

    // Service exit defaults
    uint64 internal constant MIN_COMMITMENT_DURATION = 1 days;
    uint64 internal constant EXIT_QUEUE_DURATION = 7 days;

    // Operator registration defaults
    uint32 internal constant MAX_BLUEPRINTS_PER_OPERATOR = 1_024;
    uint256 internal constant DEFAULT_OPERATOR_BOND = 0; // set via admin per network
    address internal constant DEFAULT_OPERATOR_BOND_TOKEN = address(0); // native until TNT configured
}
