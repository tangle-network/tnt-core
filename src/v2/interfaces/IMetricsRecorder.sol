// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IMetricsRecorder
/// @notice Minimal interface for recording protocol activity metrics
/// @dev Implemented by TangleMetrics, called by core contracts
interface IMetricsRecorder {
    // ═══════════════════════════════════════════════════════════════════════════
    // STAKING & DELEGATION METRICS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record a stake/delegation event
    /// @param delegator The delegator address
    /// @param operator The operator receiving delegation
    /// @param asset The asset being staked (address(0) for native)
    /// @param amount The amount staked
    function recordStake(
        address delegator,
        address operator,
        address asset,
        uint256 amount
    ) external;

    /// @notice Record an unstake event
    /// @param delegator The delegator address
    /// @param operator The operator losing delegation
    /// @param asset The asset being unstaked
    /// @param amount The amount unstaked
    function recordUnstake(
        address delegator,
        address operator,
        address asset,
        uint256 amount
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR METRICS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record operator registration
    /// @param operator The operator address
    /// @param asset The asset staked
    /// @param amount Initial stake amount
    function recordOperatorRegistered(
        address operator,
        address asset,
        uint256 amount
    ) external;

    /// @notice Record operator heartbeat (liveness proof)
    /// @param operator The operator address
    /// @param serviceId The service ID
    /// @param timestamp Block timestamp of heartbeat
    function recordHeartbeat(
        address operator,
        uint64 serviceId,
        uint64 timestamp
    ) external;

    /// @notice Record job completion by operator
    /// @param operator The operator address
    /// @param serviceId The service ID
    /// @param jobCallId The job call ID
    /// @param success Whether the job succeeded
    function recordJobCompletion(
        address operator,
        uint64 serviceId,
        uint64 jobCallId,
        bool success
    ) external;

    /// @notice Record operator slashing (negative metric)
    /// @param operator The operator address
    /// @param serviceId The service ID
    /// @param amount Amount slashed
    function recordSlash(
        address operator,
        uint64 serviceId,
        uint256 amount
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE METRICS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record service creation/activation
    /// @param serviceId The service ID
    /// @param blueprintId The blueprint ID
    /// @param owner The service owner
    /// @param operatorCount Number of operators
    function recordServiceCreated(
        uint64 serviceId,
        uint64 blueprintId,
        address owner,
        uint256 operatorCount
    ) external;

    /// @notice Record service termination
    /// @param serviceId The service ID
    /// @param duration How long the service ran (seconds)
    function recordServiceTerminated(
        uint64 serviceId,
        uint256 duration
    ) external;

    /// @notice Record a job call on a service
    /// @param serviceId The service ID
    /// @param caller Who initiated the job
    /// @param jobCallId The job call ID
    function recordJobCall(
        uint64 serviceId,
        address caller,
        uint64 jobCallId
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT/FEE METRICS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record fee payment for a service
    /// @param payer Who paid the fee
    /// @param serviceId The service ID
    /// @param token The payment token (address(0) for native)
    /// @param amount The amount paid
    function recordPayment(
        address payer,
        uint64 serviceId,
        address token,
        uint256 amount
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT METRICS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record blueprint creation
    /// @param blueprintId The blueprint ID
    /// @param developer The developer address
    function recordBlueprintCreated(
        uint64 blueprintId,
        address developer
    ) external;

    /// @notice Record operator registration to a blueprint
    /// @param blueprintId The blueprint ID
    /// @param operator The operator address
    function recordBlueprintRegistration(
        uint64 blueprintId,
        address operator
    ) external;
}
