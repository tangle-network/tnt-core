// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IBeaconOracle } from "../IBeaconOracle.sol";

/// @title EIP4788Oracle
/// @notice IBeaconOracle adapter for EIP-4788 beacon roots precompile
/// @dev Designed for Ethereum mainnet/testnets where EIP-4788 is available.
contract EIP4788Oracle is IBeaconOracle {
    /// @notice EIP-4788 beacon roots precompile address
    address public constant BEACON_ROOTS_ADDRESS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    /// @notice Seconds per beacon slot (consensus-layer constant)
    uint64 public constant SECONDS_PER_SLOT = 12;

    /// @notice Beacon chain genesis time (Unix seconds) used to anchor slot phase.
    /// @dev EIP-4788 keys the ring buffer by execution-block timestamps, which equal
    ///      `BEACON_GENESIS_TIME + SECONDS_PER_SLOT * slot`. Slot-boundary timestamps are
    ///      therefore congruent to `BEACON_GENESIS_TIME mod SECONDS_PER_SLOT`, NOT to 0.
    ///      The phase is chain-specific (mainnet == 11, Sepolia/Holesky/Hoodi == 0), so the
    ///      genesis is resolved from `block.chainid` at deploy time and fixed as immutable.
    uint64 public immutable BEACON_GENESIS_TIME;

    error BeaconRootNotFound(uint64 timestamp);
    error TimestampBeforeGenesis();

    // Beacon chain genesis times (Unix seconds) for chains where EIP-4788 is available.
    uint64 internal constant MAINNET_BEACON_GENESIS_TIME = 1_606_824_023; // chainid 1
    uint64 internal constant SEPOLIA_BEACON_GENESIS_TIME = 1_655_733_600; // chainid 11155111
    uint64 internal constant HOLESKY_BEACON_GENESIS_TIME = 1_695_902_400; // chainid 17000
    uint64 internal constant HOODI_BEACON_GENESIS_TIME = 1_742_213_400; // chainid 560048

    /// @dev Resolves the beacon genesis from `block.chainid`. The slot phase is chain-specific,
    ///      so the genesis cannot be a single hardcoded constant. Unknown chains (incl. local
    ///      forks/anvil) fall back to the mainnet genesis, which matches the production launch
    ///      target; known L1 testnets are pinned explicitly to their real phase.
    constructor() {
        uint256 cid = block.chainid;
        if (cid == 11_155_111) {
            BEACON_GENESIS_TIME = SEPOLIA_BEACON_GENESIS_TIME;
        } else if (cid == 17_000) {
            BEACON_GENESIS_TIME = HOLESKY_BEACON_GENESIS_TIME;
        } else if (cid == 560_048) {
            BEACON_GENESIS_TIME = HOODI_BEACON_GENESIS_TIME;
        } else {
            // chainid 1 (mainnet) and any unknown/local chain default to mainnet genesis.
            BEACON_GENESIS_TIME = MAINNET_BEACON_GENESIS_TIME;
        }
    }

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
    ///      INVARIANT: the returned value MUST be a key the EIP-4788 ring buffer can hold, i.e. a
    ///      genuine slot-boundary timestamp `BEACON_GENESIS_TIME + SECONDS_PER_SLOT * slot`.
    ///      Aligning to `block.timestamp - (block.timestamp % SECONDS_PER_SLOT)` is WRONG because
    ///      slot timestamps are congruent to `BEACON_GENESIS_TIME mod SECONDS_PER_SLOT` (== 11 on
    ///      mainnet), not 0 — that produced a key that never resolves. We instead floor to the slot
    ///      boundary relative to genesis. EIP-4788 stores the entry for the current block's
    ///      timestamp during that block's execution, so the most recent resolvable boundary is the
    ///      one at-or-before `block.timestamp`.
    function latestBeaconTimestamp() external view returns (uint64) {
        uint256 t = block.timestamp;
        uint256 genesis = BEACON_GENESIS_TIME;
        if (t < genesis) revert TimestampBeforeGenesis();
        // Floor to the slot boundary in the genesis phase: genesis + slot*SECONDS_PER_SLOT.
        t = genesis + ((t - genesis) / SECONDS_PER_SLOT) * SECONDS_PER_SLOT;
        // forge-lint: disable-next-line(unsafe-typecast)
        return uint64(t);
    }
}

