// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleJobs
/// @notice Job submission and result management interface
interface ITangleJobs {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event JobSubmitted(
        uint64 indexed serviceId,
        uint64 indexed callId,
        uint8 indexed jobIndex,
        address caller,
        bytes inputs
    );

    event JobResultSubmitted(
        uint64 indexed serviceId,
        uint64 indexed callId,
        address indexed operator,
        bytes result
    );

    event JobCompleted(uint64 indexed serviceId, uint64 indexed callId, uint32 resultCount);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a job to a service
    function submitJob(
        uint64 serviceId,
        uint8 jobIndex,
        bytes calldata inputs
    ) external payable returns (uint64 callId);

    /// @notice Submit multiple jobs in one transaction
    function submitJobs(
        uint64 serviceId,
        uint8[] calldata jobIndices,
        bytes[] calldata inputs
    ) external payable returns (uint64[] memory callIds);

    /// @notice Submit a job result (as operator)
    function submitResult(uint64 serviceId, uint64 callId, bytes calldata result) external;

    /// @notice Submit multiple results in one transaction
    function submitResults(
        uint64 serviceId,
        uint64[] calldata callIds,
        bytes[] calldata results
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get job call info
    function getJobCall(uint64 serviceId, uint64 callId) external view returns (Types.JobCall memory);
}
