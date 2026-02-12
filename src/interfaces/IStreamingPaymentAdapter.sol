// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IStreamingPaymentAdapter
/// @notice Common interface for streaming payment adapters (Superfluid, Sablier, etc.)
/// @dev Adapters implement this interface to provide streaming payment capabilities
///      to Tangle services without tight coupling to specific protocols.
interface IStreamingPaymentAdapter {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when a stream is created for a service
    event StreamCreated(
        uint64 indexed serviceId,
        uint256 indexed streamId,
        address indexed payer,
        address token,
        uint256 ratePerSecond,
        uint256 totalAmount
    );

    /// @notice Emitted when a stream is updated
    event StreamUpdated(uint64 indexed serviceId, uint256 indexed streamId, uint256 newRatePerSecond);

    /// @notice Emitted when a stream is cancelled
    event StreamCancelled(uint64 indexed serviceId, uint256 indexed streamId, uint256 refundedAmount);

    /// @notice Emitted when funds are withdrawn from a stream
    event StreamWithdrawn(uint64 indexed serviceId, uint256 indexed streamId, uint256 amount, address recipient);

    /// @notice Emitted when a stream is settled and distributed
    event StreamSettled(uint64 indexed serviceId, uint256 indexed streamId, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // STREAM MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a streaming payment for a service
    /// @param serviceId The Tangle service ID
    /// @param token The ERC-20 token to stream (address(0) for native)
    /// @param totalAmount Total amount to stream
    /// @param durationSeconds Stream duration in seconds
    /// @param cliffSeconds Optional cliff period (0 for no cliff)
    /// @return streamId The created stream ID
    function createStream(
        uint64 serviceId,
        address token,
        uint256 totalAmount,
        uint64 durationSeconds,
        uint64 cliffSeconds
    )
        external
        payable
        returns (uint256 streamId);

    /// @notice Update the rate of an existing stream
    /// @param streamId The stream ID to update
    /// @param newRatePerSecond New streaming rate
    function updateStreamRate(uint256 streamId, uint256 newRatePerSecond) external;

    /// @notice Cancel a stream and refund remaining balance
    /// @param streamId The stream ID to cancel
    /// @return refundedAmount Amount refunded to the payer
    function cancelStream(uint256 streamId) external returns (uint256 refundedAmount);

    /// @notice Withdraw available funds from a stream
    /// @param streamId The stream ID
    /// @return withdrawnAmount Amount withdrawn
    function withdrawFromStream(uint256 streamId) external returns (uint256 withdrawnAmount);

    /// @notice Settle a stream's accumulated funds and distribute to operators
    /// @dev This triggers distribution through Tangle's payment system
    /// @param streamId The stream ID to settle
    function settleAndDistribute(uint256 streamId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the current withdrawable amount for a stream
    /// @param streamId The stream ID
    /// @return amount Amount available to withdraw
    function getWithdrawableAmount(uint256 streamId) external view returns (uint256 amount);

    /// @notice Get the current streaming rate
    /// @param streamId The stream ID
    /// @return ratePerSecond Tokens per second being streamed
    function getStreamRate(uint256 streamId) external view returns (uint256 ratePerSecond);

    /// @notice Get full stream information
    /// @param streamId The stream ID
    /// @return serviceId Associated Tangle service
    /// @return payer Address funding the stream
    /// @return token Token being streamed
    /// @return totalAmount Total stream amount
    /// @return withdrawnAmount Amount already withdrawn
    /// @return startTime Stream start timestamp
    /// @return endTime Stream end timestamp
    /// @return cliffTime Cliff timestamp (0 if no cliff)
    /// @return active Whether stream is active
    function getStreamInfo(uint256 streamId)
        external
        view
        returns (
            uint64 serviceId,
            address payer,
            address token,
            uint256 totalAmount,
            uint256 withdrawnAmount,
            uint256 startTime,
            uint256 endTime,
            uint256 cliffTime,
            bool active
        );

    /// @notice Get the service ID associated with a stream
    /// @param streamId The stream ID
    /// @return serviceId The Tangle service ID
    function getStreamServiceId(uint256 streamId) external view returns (uint64 serviceId);

    /// @notice Get all active streams for a service
    /// @param serviceId The Tangle service ID
    /// @return streamIds Array of active stream IDs
    function getServiceStreams(uint64 serviceId) external view returns (uint256[] memory streamIds);

    /// @notice Calculate real-time accrued amount (not yet settled)
    /// @param streamId The stream ID
    /// @return accruedAmount Amount accrued since last settlement
    function getAccruedAmount(uint256 streamId) external view returns (uint256 accruedAmount);

    // ═══════════════════════════════════════════════════════════════════════════
    // PROTOCOL INFO
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the name of the underlying protocol
    /// @return name Protocol name (e.g., "Superfluid", "Sablier")
    function protocolName() external view returns (string memory name);

    /// @notice Check if a token is supported for streaming
    /// @param token The token address
    /// @return supported True if token can be streamed
    function isTokenSupported(address token) external view returns (bool supported);
}

/// @title ISuperfluidAdapter
/// @notice Extended interface for Superfluid-specific features
interface ISuperfluidAdapter is IStreamingPaymentAdapter {
    /// @notice Get the net flow rate for an account (incoming - outgoing)
    /// @param account The account address
    /// @param token The super token
    /// @return netFlowRate Net flow rate (can be negative)
    function getNetFlowRate(address account, address token) external view returns (int96 netFlowRate);

    /// @notice Get the real-time balance of an account
    /// @param account The account address
    /// @param token The super token
    /// @return availableBalance Current available balance
    /// @return deposit Required deposit/buffer
    function getRealtimeBalance(
        address account,
        address token
    )
        external
        view
        returns (int256 availableBalance, uint256 deposit);

    /// @notice Check if an account is solvent (positive balance)
    /// @param account The account address
    /// @param token The super token
    /// @return solvent True if account has positive balance
    function isSolvent(address account, address token) external view returns (bool solvent);

    /// @notice Get the required buffer/deposit for a flow rate
    /// @param token The super token
    /// @param flowRate Flow rate in wei/second
    /// @return bufferAmount Required buffer deposit
    function getRequiredBuffer(address token, int96 flowRate) external view returns (uint256 bufferAmount);

    /// @notice Wrap underlying tokens to super tokens
    /// @param token The underlying token
    /// @param amount Amount to wrap
    function wrapTokens(address token, uint256 amount) external;

    /// @notice Unwrap super tokens to underlying
    /// @param token The super token
    /// @param amount Amount to unwrap
    function unwrapTokens(address token, uint256 amount) external;
}

/// @title ISablierAdapter
/// @notice Extended interface for Sablier-specific features
interface ISablierAdapter is IStreamingPaymentAdapter {
    /// @notice Stream type for Sablier
    enum StreamType {
        Linear, // Linear vesting over time
        Dynamic, // Custom curve with segments
        Tranched // Fixed payment tranches
    }

    /// @notice Segment for dynamic streams
    struct Segment {
        uint128 amount;
        uint64 exponent; // Curve exponent (scaled by 1e18)
        uint40 timestamp;
    }

    /// @notice Create a linear stream (constant rate)
    /// @param serviceId The Tangle service ID
    /// @param token The ERC-20 token
    /// @param totalAmount Total amount to stream
    /// @param durationSeconds Total duration
    /// @param cliffSeconds Cliff period
    /// @return streamId The created stream ID
    function createLinearStream(
        uint64 serviceId,
        address token,
        uint128 totalAmount,
        uint40 durationSeconds,
        uint40 cliffSeconds
    )
        external
        returns (uint256 streamId);

    /// @notice Create a dynamic stream with custom curve
    /// @param serviceId The Tangle service ID
    /// @param token The ERC-20 token
    /// @param totalAmount Total amount to stream
    /// @param segments Array of segments defining the curve
    /// @return streamId The created stream ID
    function createDynamicStream(
        uint64 serviceId,
        address token,
        uint128 totalAmount,
        Segment[] calldata segments
    )
        external
        returns (uint256 streamId);

    /// @notice Check if a stream is cancelable
    /// @param streamId The stream ID
    /// @return cancelable True if stream can be cancelled
    function isCancelable(uint256 streamId) external view returns (bool cancelable);

    /// @notice Check if a stream was cancelled
    /// @param streamId The stream ID
    /// @return cancelled True if stream was cancelled
    function wasCancelled(uint256 streamId) external view returns (bool cancelled);

    /// @notice Get the NFT token ID for a stream (Sablier streams are NFTs)
    /// @param streamId The stream ID
    /// @return tokenId The ERC-721 token ID
    // forge-lint: disable-next-line(mixed-case-function)
    function getStreamNFT(uint256 streamId) external view returns (uint256 tokenId);

    /// @notice Transfer stream ownership (NFT transfer)
    /// @param streamId The stream ID
    /// @param newRecipient New recipient address
    function transferStream(uint256 streamId, address newRecipient) external;
}

/// @title IPaymentAdapterRegistry
/// @notice Registry for managing multiple payment adapters
interface IPaymentAdapterRegistry {
    /// @notice Register a new payment adapter
    /// @param name Adapter name
    /// @param adapter Adapter address
    function registerAdapter(string calldata name, address adapter) external;

    /// @notice Remove a payment adapter
    /// @param name Adapter name to remove
    function removeAdapter(string calldata name) external;

    /// @notice Get an adapter by name
    /// @param name Adapter name
    /// @return adapter Adapter address
    function getAdapter(string calldata name) external view returns (address adapter);

    /// @notice Get the default adapter
    /// @return adapter Default adapter address
    function getDefaultAdapter() external view returns (address adapter);

    /// @notice Set the default adapter
    /// @param name Name of adapter to set as default
    function setDefaultAdapter(string calldata name) external;

    /// @notice Check if an adapter is registered
    /// @param name Adapter name
    /// @return registered True if adapter exists
    function isRegistered(string calldata name) external view returns (bool registered);

    /// @notice Get all registered adapter names
    /// @return names Array of adapter names
    function getRegisteredAdapters() external view returns (string[] memory names);
}
