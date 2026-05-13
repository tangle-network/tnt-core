// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ProtocolConfig
/// @notice Central default parameters for the Tangle protocol
/// @dev Keeps network-wide defaults in one place for consistency
library ProtocolConfig {
    // ═══════════════════════════════════════════════════════════════════════════
    // TIMING (all time-based, no block assumptions)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Duration of a single round in seconds (6 hours)
    uint64 internal constant ROUND_DURATION_SECONDS = 21_600;

    /// @notice Number of rounds per epoch (28 rounds = 7 days)
    uint64 internal constant ROUNDS_PER_EPOCH = 28;

    /// @notice Delay for delegator unstaking (1 epoch = 7 days)
    uint64 internal constant DELEGATOR_DELAY_ROUNDS = 28;

    /// @notice Delay for operator exit (2 epochs = 14 days)
    uint64 internal constant OPERATOR_DELAY_ROUNDS = 56;

    /// @notice Dispute window for slashing (14 rounds = 3.5 days)
    uint64 internal constant DISPUTE_WINDOW_ROUNDS = 14;

    /// @notice Grace period before new stake earns rewards (4 rounds = 24 hours)
    uint64 internal constant REWARD_GRACE_PERIOD_ROUNDS = 4;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE EXIT
    // ═══════════════════════════════════════════════════════════════════════════

    uint64 internal constant MIN_COMMITMENT_DURATION = 1 days;
    uint64 internal constant EXIT_QUEUE_DURATION = 7 days;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION
    // ═══════════════════════════════════════════════════════════════════════════

    uint32 internal constant MAX_BLUEPRINTS_PER_OPERATOR = 1024;

    /// @notice Hard ceiling on `maxOperators` per service.
    /// @dev Bounds every per-operator loop in the billing / distribute / terminate paths.
    ///      Blueprint configs setting `maxOperators = 0` ("unlimited") are clamped to
    ///      this value at request validation time so a malicious blueprint cannot
    ///      unbound the bill loop.
    uint32 internal constant MAX_OPERATORS_PER_SERVICE = 64;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST TTL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Minimum TTL for service requests (1 hour)
    uint64 internal constant MIN_SERVICE_TTL = 1 hours;

    /// @notice Maximum TTL for service requests (365 days)
    uint64 internal constant MAX_SERVICE_TTL = 365 days;

    /// @notice Maximum cumulative TTL a service may accumulate across extensions.
    /// @dev Per-call validation bounds `additionalTtl` to `MAX_SERVICE_TTL`; without a
    ///      cumulative cap a long-lived service could grow `svc.ttl` arbitrarily by
    ///      chaining extensions. Four years is large enough for any realistic
    ///      production deployment yet small enough to keep escrow exposure bounded.
    uint64 internal constant MAX_CUMULATIVE_SERVICE_TTL = 4 * MAX_SERVICE_TTL;

    /// @notice Default request expiry grace period (1 hour)
    /// @dev Operators have this additional time to approve after expiry
    uint64 internal constant REQUEST_EXPIRY_GRACE_PERIOD = 1 hours;

    // ═══════════════════════════════════════════════════════════════════════════
    // QUOTE VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Maximum quote age (1 hour)
    /// @dev Quotes with timestamps older than this are rejected
    uint64 internal constant MAX_QUOTE_AGE = 1 hours;
}
