// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IBeaconOracle } from "../IBeaconOracle.sol";

/// @title EIP4788Oracle
/// @notice IBeaconOracle adapter for EIP-4788 beacon roots precompile
/// @dev Designed for Ethereum mainnet/testnets where EIP-4788 is available.
contract EIP4788Oracle is IBeaconOracle {
    /// @notice EIP-4788 beacon roots precompile address
    address public constant BEACON_ROOTS_ADDRESS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    error BeaconRootNotFound(uint64 timestamp);

    /// @inheritdoc IBeaconOracle
    function getBeaconBlockRoot(uint64 timestamp) external view returns (bytes32) {
        (bool success, bytes memory data) = BEACON_ROOTS_ADDRESS.staticcall(abi.encode(timestamp));
        if (!success || data.length != 32) revert BeaconRootNotFound(timestamp);
        return abi.decode(data, (bytes32));
    }

    /// @inheritdoc IBeaconOracle
    function hasBeaconBlockRoot(uint64 timestamp) external view returns (bool) {
        (bool success,) = BEACON_ROOTS_ADDRESS.staticcall(abi.encode(timestamp));
        return success;
    }

    /// @inheritdoc IBeaconOracle
    /// @dev EIP-4788 does not expose "latest"; this returns a best-effort slot-aligned timestamp.
    function latestBeaconTimestamp() external view returns (uint64) {
        uint256 t = block.timestamp;
        // Beacon slots are 12 seconds; EIP-4788 uses slot-boundary timestamps.
        t = t - (t % 12);
        // forge-lint: disable-next-line(unsafe-typecast)
        return uint64(t);
    }
}

