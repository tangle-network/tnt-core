// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IL1CrossDomainMessenger} from "../IBeaconOracle.sol";

/// @title BeaconRootRelayer
/// @notice L1 contract that reads beacon roots via EIP-4788 and relays them to L2
/// @dev Deployed on Ethereum mainnet, sends messages through OP Stack canonical bridge
contract BeaconRootRelayer {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice EIP-4788 beacon roots precompile address
    address public constant BEACON_ROOTS_ADDRESS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    /// @notice Default gas limit for L2 message execution
    uint32 public constant DEFAULT_GAS_LIMIT = 100_000;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice OP Stack L1 Cross Domain Messenger
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IL1CrossDomainMessenger public immutable messenger;

    /// @notice Target contract on L2 to receive beacon roots
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable l2BeaconRootReceiver;

    /// @notice Tracks which timestamps have been relayed (to prevent duplicates)
    mapping(uint64 => bool) public relayedTimestamps;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when a beacon root is relayed to L2
    event BeaconRootRelayed(uint64 indexed timestamp, bytes32 root);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error BeaconRootNotFound(uint64 timestamp);
    error AlreadyRelayed(uint64 timestamp);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the relayer
    /// @param _messenger L1CrossDomainMessenger address
    /// @param _l2BeaconRootReceiver BeaconRootReceiver address on L2
    constructor(address _messenger, address _l2BeaconRootReceiver) {
        messenger = IL1CrossDomainMessenger(_messenger);
        l2BeaconRootReceiver = _l2BeaconRootReceiver;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RELAY FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Relay a beacon root for a specific timestamp to L2
    /// @param timestamp The beacon chain timestamp (must be a slot boundary)
    /// @dev Anyone can call this - it's permissionless
    function relayBeaconRoot(uint64 timestamp) external {
        if (relayedTimestamps[timestamp]) {
            revert AlreadyRelayed(timestamp);
        }

        bytes32 root = _getBeaconRoot(timestamp);

        relayedTimestamps[timestamp] = true;

        // Encode the call to receiveBeaconRoot on L2
        bytes memory message = abi.encodeWithSignature(
            "receiveBeaconRoot(uint64,bytes32)",
            timestamp,
            root
        );

        // Send through the canonical bridge
        messenger.sendMessage(l2BeaconRootReceiver, message, DEFAULT_GAS_LIMIT);

        emit BeaconRootRelayed(timestamp, root);
    }

    /// @notice Relay multiple beacon roots in a single transaction
    /// @param timestamps Array of timestamps to relay
    function relayBeaconRoots(uint64[] calldata timestamps) external {
        for (uint256 i = 0; i < timestamps.length; i++) {
            uint64 timestamp = timestamps[i];

            if (relayedTimestamps[timestamp]) {
                continue; // Skip already relayed, don't revert
            }

            bytes32 root = _getBeaconRoot(timestamp);

            relayedTimestamps[timestamp] = true;

            bytes memory message = abi.encodeWithSignature(
                "receiveBeaconRoot(uint64,bytes32)",
                timestamp,
                root
            );

            messenger.sendMessage(l2BeaconRootReceiver, message, DEFAULT_GAS_LIMIT);

            emit BeaconRootRelayed(timestamp, root);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if a beacon root exists for a timestamp
    /// @param timestamp The timestamp to check
    /// @return True if a root exists
    function hasBeaconRoot(uint64 timestamp) external view returns (bool) {
        (bool success,) = BEACON_ROOTS_ADDRESS.staticcall(abi.encode(timestamp));
        return success;
    }

    /// @notice Get a beacon root for a timestamp (view only, doesn't relay)
    /// @param timestamp The timestamp to query
    /// @return The beacon block root
    function getBeaconRoot(uint64 timestamp) external view returns (bytes32) {
        return _getBeaconRoot(timestamp);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Read beacon root from EIP-4788 precompile
    function _getBeaconRoot(uint64 timestamp) internal view returns (bytes32) {
        (bool success, bytes memory data) = BEACON_ROOTS_ADDRESS.staticcall(abi.encode(timestamp));

        if (!success || data.length != 32) {
            revert BeaconRootNotFound(timestamp);
        }

        return abi.decode(data, (bytes32));
    }
}
