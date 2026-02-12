// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IStreamingPaymentManager
/// @notice Interface for streaming payment management
interface IStreamingPaymentManager {
    /// @notice Create a streaming payment for a service
    function createStream(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount,
        uint64 startTime,
        uint64 endTime
    )
        external
        payable;

    /// @notice Drip a specific stream and return chunk info
    function dripAndGetChunk(
        uint64 serviceId,
        address operator
    )
        external
        returns (uint256 amount, uint256 durationSeconds, uint64 blueprintId, address paymentToken);

    /// @notice Drip all active streams for an operator
    function dripOperatorStreams(address operator)
        external
        returns (
            uint64[] memory serviceIds,
            uint64[] memory blueprintIds,
            address[] memory paymentTokens,
            uint256[] memory amounts,
            uint256[] memory durations
        );

    /// @notice Called when service is terminated
    function onServiceTerminated(uint64 serviceId, address refundRecipient) external;

    /// @notice Called when operator is leaving
    function onOperatorLeaving(uint64 serviceId, address operator) external;

    /// @notice Get active stream IDs for an operator
    function getOperatorActiveStreams(address operator) external view returns (uint64[] memory);

    /// @notice Get streaming payment details
    function getStreamingPayment(
        uint64 serviceId,
        address operator
    )
        external
        view
        returns (
            uint64 _serviceId,
            uint64 blueprintId,
            address _operator,
            address paymentToken,
            uint256 totalAmount,
            uint256 distributed,
            uint64 startTime,
            uint64 endTime,
            uint64 lastDripTime
        );

    /// @notice Calculate pending drip amount
    function pendingDrip(uint64 serviceId, address operator) external view returns (uint256);
}
