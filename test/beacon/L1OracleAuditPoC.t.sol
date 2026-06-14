// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { EIP4788Oracle } from "../../src/beacon/l1/EIP4788Oracle.sol";

/// Mimics the real EIP-4788 precompile: returns root iff the queried timestamp
/// exactly matches a stored slot timestamp, otherwise REVERTS (as on mainnet).
contract MockBeaconRoots4788 {
    mapping(uint64 => bytes32) public roots;
    function setRoot(uint64 t, bytes32 r) external { roots[t] = r; }
    fallback(bytes calldata data) external returns (bytes memory) {
        uint64 t = abi.decode(data, (uint64));
        bytes32 r = roots[t];
        if (r == bytes32(0)) revert("NO_ROOT");
        return abi.encode(r);
    }
}

contract L1OracleAuditPoC is Test {
    address constant PRECOMPILE = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;
    // Ethereum mainnet beacon genesis time
    uint64 constant MAINNET_BEACON_GENESIS = 1_606_824_023;

    EIP4788Oracle oracle;
    MockBeaconRoots4788 mock;

    function setUp() public {
        oracle = new EIP4788Oracle();
        mock = new MockBeaconRoots4788();
        vm.etch(PRECOMPILE, address(mock).code);
    }

    /// Real beacon/execution slot timestamps are congruent to 11 (mod 12) on mainnet,
    /// but latestBeaconTimestamp() aligns to 0 (mod 12) -> the returned value can NEVER
    /// be a valid key in the EIP-4788 ring buffer.
    function test_latestBeaconTimestamp_isNeverAValidKey() public {
        // pick a realistic "now": some slot far after genesis
        uint64 slot = 9_000_000;
        uint64 realSlotTs = MAINNET_BEACON_GENESIS + 12 * slot;     // a genuine stored key
        assertEq(realSlotTs % 12, 11, "mainnet slot ts are 11 mod 12");

        vm.warp(uint256(realSlotTs) + 3); // partway into the next slot, like a real block
        uint64 latest = oracle.latestBeaconTimestamp();

        assertEq(latest % 12, 0, "oracle aligns to 0 mod 12");
        assertTrue(latest != realSlotTs, "latest does not equal the true slot ts");

        // Store the authentic root under the authentic key
        bytes32 root = keccak256("authentic-root");
        MockBeaconRoots4788(PRECOMPILE).setRoot(realSlotTs, root);

        // A correct value (realSlotTs) resolves fine...
        assertEq(oracle.getBeaconBlockRoot(realSlotTs), root);

        // ...but the value latestBeaconTimestamp() hands an integrator REVERTS 100% of the time.
        vm.expectRevert();
        oracle.getBeaconBlockRoot(latest);
    }
}
