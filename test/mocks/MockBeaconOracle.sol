// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IBeaconOracle } from "../../src/beacon/IBeaconOracle.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title MockBeaconOracle
/// @notice Mock oracle for testing - allows direct root injection
/// @dev Use in tests and local development only. Kept out of `src/` so it is never
///      compiled into production artifacts.
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
