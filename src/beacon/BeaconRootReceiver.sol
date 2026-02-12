// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IBeaconOracle, IL2CrossDomainMessenger } from "./IBeaconOracle.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title BeaconRootReceiver
/// @notice L2 contract that receives beacon roots from L1 via the canonical bridge
/// @dev Implements IBeaconOracle for use by ValidatorPodManager
contract BeaconRootReceiver is IBeaconOracle, Ownable {
    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice OP Stack L2 Cross Domain Messenger
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IL2CrossDomainMessenger public immutable messenger;

    /// @notice Authorized L1 relayer address
    address public l1BeaconRootRelayer;

    /// @notice Stored beacon roots by timestamp
    mapping(uint64 => bytes32) public beaconRoots;

    /// @notice Timestamp of the most recently received root
    uint64 public override latestBeaconTimestamp;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlyMessenger();
    error OnlyL1Relayer();
    error BeaconRootNotFound(uint64 timestamp);
    error ZeroAddress();

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the receiver
    /// @param _messenger L2CrossDomainMessenger address
    /// @param _l1BeaconRootRelayer BeaconRootRelayer address on L1
    constructor(address _messenger, address _l1BeaconRootRelayer) Ownable(msg.sender) {
        if (_messenger == address(0)) revert ZeroAddress();
        messenger = IL2CrossDomainMessenger(_messenger);
        l1BeaconRootRelayer = _l1BeaconRootRelayer;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RECEIVE FROM L1
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Receive a beacon root from L1 (called via canonical bridge)
    /// @param timestamp The beacon chain timestamp
    /// @param root The beacon block root
    /// @dev Only callable through the L2 messenger from the authorized L1 relayer
    function receiveBeaconRoot(uint64 timestamp, bytes32 root) external {
        // Verify the call came through the canonical bridge
        if (msg.sender != address(messenger)) {
            revert OnlyMessenger();
        }

        // Verify the L1 sender is the authorized relayer
        if (messenger.xDomainMessageSender() != l1BeaconRootRelayer) {
            revert OnlyL1Relayer();
        }

        // Store the root
        beaconRoots[timestamp] = root;

        // Update latest if this is newer
        if (timestamp > latestBeaconTimestamp) {
            latestBeaconTimestamp = timestamp;
        }

        emit BeaconRootReceived(timestamp, root);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // IBeaconOracle IMPLEMENTATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBeaconOracle
    function getBeaconBlockRoot(uint64 timestamp) external view override returns (bytes32) {
        bytes32 root = beaconRoots[timestamp];
        if (root == bytes32(0)) {
            revert BeaconRootNotFound(timestamp);
        }
        return root;
    }

    /// @inheritdoc IBeaconOracle
    function hasBeaconBlockRoot(uint64 timestamp) external view override returns (bool) {
        return beaconRoots[timestamp] != bytes32(0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update the L1 relayer address
    /// @param _l1BeaconRootRelayer New relayer address
    /// @dev Only callable by owner, for upgrades/migrations
    function setL1BeaconRootRelayer(address _l1BeaconRootRelayer) external onlyOwner {
        if (_l1BeaconRootRelayer == address(0)) revert ZeroAddress();
        l1BeaconRootRelayer = _l1BeaconRootRelayer;
    }
}

    /// @title MockBeaconOracle
    /// @notice Mock oracle for testing - allows direct root injection
    /// @dev Use in tests and local development only
    contract MockBeaconOracle is IBeaconOracle, Ownable {
        mapping(uint64 => bytes32) public beaconRoots;
        uint64 public override latestBeaconTimestamp;

        error BeaconRootNotFound(uint64 timestamp);

        constructor() Ownable(msg.sender) { }

        /// @notice Set a beacon root for testing
        function setBeaconBlockRoot(uint64 timestamp, bytes32 root) external onlyOwner {
            beaconRoots[timestamp] = root;
            if (timestamp > latestBeaconTimestamp) {
                latestBeaconTimestamp = timestamp;
            }
            emit BeaconRootReceived(timestamp, root);
        }

        /// @notice Set multiple beacon roots for testing
        function setBeaconBlockRoots(uint64[] calldata timestamps, bytes32[] calldata roots) external onlyOwner {
            require(timestamps.length == roots.length, "Length mismatch");
            for (uint256 i = 0; i < timestamps.length; i++) {
                beaconRoots[timestamps[i]] = roots[i];
                if (timestamps[i] > latestBeaconTimestamp) {
                    latestBeaconTimestamp = timestamps[i];
                }
                emit BeaconRootReceived(timestamps[i], roots[i]);
            }
        }

        function getBeaconBlockRoot(uint64 timestamp) external view override returns (bytes32) {
            bytes32 root = beaconRoots[timestamp];
            if (root == bytes32(0)) {
                revert BeaconRootNotFound(timestamp);
            }
            return root;
        }

        function hasBeaconBlockRoot(uint64 timestamp) external view override returns (bool) {
            return beaconRoots[timestamp] != bytes32(0);
        }
    }
