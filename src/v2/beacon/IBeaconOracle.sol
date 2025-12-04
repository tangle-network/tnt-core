// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IBeaconOracle
/// @notice Interface for accessing beacon chain block roots
/// @dev Can be implemented by:
///      - EIP4788Oracle (mainnet, direct access)
///      - BeaconRootReceiver (L2, via canonical bridge)
///      - MockBeaconOracle (testing)
interface IBeaconOracle {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when a beacon root is stored
    event BeaconRootReceived(uint64 indexed timestamp, bytes32 root);

    // ═══════════════════════════════════════════════════════════════════════════
    // QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the beacon block root for a given timestamp
    /// @param timestamp The timestamp to query (must be a slot boundary)
    /// @return The beacon block root for that timestamp
    /// @dev Reverts if no root exists for the timestamp
    function getBeaconBlockRoot(uint64 timestamp) external view returns (bytes32);

    /// @notice Check if a beacon root exists for a timestamp
    /// @param timestamp The timestamp to check
    /// @return True if a root exists
    function hasBeaconBlockRoot(uint64 timestamp) external view returns (bool);

    /// @notice Get the most recent beacon root timestamp
    /// @return The timestamp of the most recently stored root
    function latestBeaconTimestamp() external view returns (uint64);
}

/// @title IL1CrossDomainMessenger
/// @notice OP Stack L1 messenger interface for sending messages to L2
interface IL1CrossDomainMessenger {
    /// @notice Send a message to L2
    /// @param target Address on L2 to call
    /// @param message Calldata to send
    /// @param minGasLimit Minimum gas limit for L2 execution
    function sendMessage(address target, bytes calldata message, uint32 minGasLimit) external payable;
}

/// @title IL2CrossDomainMessenger
/// @notice OP Stack L2 messenger interface for receiving messages from L1
interface IL2CrossDomainMessenger {
    /// @notice Get the sender of the current cross-domain message
    /// @return Address of the L1 sender
    function xDomainMessageSender() external view returns (address);
}
