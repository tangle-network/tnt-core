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

    /// @notice Emitted when a job reaches its required result threshold
    /// @dev Derive resultCount from getJobCall(serviceId, callId).resultCount
    event JobCompleted(uint64 indexed serviceId, uint64 indexed callId);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a job to a service
    function submitJob(
        uint64 serviceId,
        uint8 jobIndex,
        bytes calldata inputs
    ) external payable returns (uint64 callId);

    /// @notice Submit a job result (as operator)
    function submitResult(uint64 serviceId, uint64 callId, bytes calldata result) external;

    /// @notice Submit multiple results in one transaction
    function submitResults(
        uint64 serviceId,
        uint64[] calldata callIds,
        bytes[] calldata results
    ) external;

    /// @notice Submit an aggregated BLS result for a job
    /// @dev Only valid for jobs where requiresAggregation returns true
    /// @param serviceId The service ID
    /// @param callId The job call ID
    /// @param output The aggregated output data
    /// @param signerBitmap Bitmap indicating which operators signed (bit i = operator i in service)
    /// @param aggregatedSignature The aggregated BLS signature [x, y]
    /// @param aggregatedPubkey The aggregated public key [x0, x1, y0, y1]
    function submitAggregatedResult(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        uint256 signerBitmap,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get job call info
    function getJobCall(uint64 serviceId, uint64 callId) external view returns (Types.JobCall memory);
}
