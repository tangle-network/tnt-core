// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { EIP4788Oracle } from "../../../src/beacon/l1/EIP4788Oracle.sol";
import { BeaconRootRelayer } from "../../../src/beacon/l1/BeaconRootRelayer.sol";

// ─────────────────────────────────────────────────────────────────────────────
// Mocks for the EIP-4788 beacon roots precompile (0x000F3df6...Beac02)
// ─────────────────────────────────────────────────────────────────────────────

/// @notice Stand-in for the EIP-4788 precompile that returns a genuine 32-byte root (a "hit").
/// @dev The root is a compile-time constant baked into the runtime bytecode rather than
///      constructor-set storage, because `vm.etch` copies only runtime code (it does not run the
///      constructor), so storage-backed state would read as zero on the etched account.
contract MockBeaconRootsPresent {
    bytes32 internal constant ROOT = bytes32(uint256(0xBEEF));

    // EIP-4788 GET: input is a 32-byte timestamp, output is the 32-byte root.
    fallback(bytes calldata) external returns (bytes memory) {
        return abi.encode(ROOT);
    }
}

/// @notice Precompile stand-in that succeeds but returns EMPTY returndata. This is exactly what a
///         plain `staticcall` to an account with no code looks like (`success == true`, 0 bytes),
///         i.e. the "precompile absent" case that the pre-fix `has*` functions mis-reported as a hit.
contract MockBeaconRootsEmpty {
    fallback() external { }
}

// ─────────────────────────────────────────────────────────────────────────────
// EIP4788Oracle.hasBeaconBlockRoot — must mirror getBeaconBlockRoot (fail-closed)
// ─────────────────────────────────────────────────────────────────────────────

contract EIP4788OracleHasConsistencyTest is Test {
    EIP4788Oracle internal oracle;

    address internal constant BEACON_ROOTS_ADDRESS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;
    // Must equal MockBeaconRootsPresent.ROOT (baked into its runtime bytecode).
    bytes32 internal constant ROOT = bytes32(uint256(0xBEEF));

    uint64 internal ts;

    function setUp() public {
        oracle = new EIP4788Oracle();
        // A real slot-boundary timestamp keyed against the resolved genesis.
        ts = oracle.latestBeaconTimestamp();
    }

    /// SECURE INVARIANT: when the precompile is ABSENT (account has no code), a bare staticcall
    /// returns success=true with empty returndata. `hasBeaconBlockRoot` MUST return false to stay
    /// consistent with `getBeaconBlockRoot`, which reverts. Pre-fix it returned `success` (true),
    /// producing a false-positive "root exists". If the fix were reverted this assertion fails.
    function test_HasIsFalseWhenPrecompileAbsent() public {
        // No code at the precompile address: success=true, returndata length 0.
        assertEq(BEACON_ROOTS_ADDRESS.code.length, 0, "precompile must be empty for this case");

        assertFalse(oracle.hasBeaconBlockRoot(ts), "has must be false when precompile is absent");

        // get reverts -> the has/get contract is consistent.
        vm.expectRevert(abi.encodeWithSelector(EIP4788Oracle.BeaconRootNotFound.selector, ts));
        oracle.getBeaconBlockRoot(ts);
    }

    /// SECURE INVARIANT: a precompile that succeeds but returns empty (zero-length) returndata is
    /// NOT a hit. has must be false; get must revert. This is the explicit returndata-length guard.
    function test_HasIsFalseWhenReturndataEmpty() public {
        vm.etch(BEACON_ROOTS_ADDRESS, address(new MockBeaconRootsEmpty()).code);

        assertFalse(oracle.hasBeaconBlockRoot(ts), "has must be false on empty returndata");

        vm.expectRevert(abi.encodeWithSelector(EIP4788Oracle.BeaconRootNotFound.selector, ts));
        oracle.getBeaconBlockRoot(ts);
    }

    /// POSITIVE: a precompile returning a real 32-byte root is a hit — has==true and get==root.
    function test_HasAndGetAgreeWhenRootPresent() public {
        vm.etch(BEACON_ROOTS_ADDRESS, address(new MockBeaconRootsPresent()).code);

        assertTrue(oracle.hasBeaconBlockRoot(ts), "has must be true when a 32-byte root is returned");
        assertEq(oracle.getBeaconBlockRoot(ts), ROOT, "get must return the root");
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// BeaconRootRelayer.hasBeaconRoot — same root bug, must mirror _getBeaconRoot
// ─────────────────────────────────────────────────────────────────────────────

contract BeaconRootRelayerHasConsistencyTest is Test {
    BeaconRootRelayer internal relayer;

    address internal constant BEACON_ROOTS_ADDRESS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;
    // Must equal MockBeaconRootsPresent.ROOT (baked into its runtime bytecode).
    bytes32 internal constant ROOT = bytes32(uint256(0xBEEF));

    uint64 internal constant TS = 1_700_000_000;

    function setUp() public {
        // messenger + receiver are irrelevant for the view-path bug under test.
        relayer = new BeaconRootRelayer(address(0xDEAD), address(0xBEEF));
    }

    /// SECURE INVARIANT: precompile absent (no code) -> hasBeaconRoot must be false (mirrors
    /// _getBeaconRoot reverting). Pre-fix it returned `success` (true), a false positive.
    function test_HasIsFalseWhenPrecompileAbsent() public {
        assertEq(BEACON_ROOTS_ADDRESS.code.length, 0, "precompile must be empty for this case");

        assertFalse(relayer.hasBeaconRoot(TS), "has must be false when precompile is absent");

        vm.expectRevert(abi.encodeWithSelector(BeaconRootRelayer.BeaconRootNotFound.selector, TS));
        relayer.getBeaconRoot(TS);
    }

    /// SECURE INVARIANT: empty (zero-length) returndata is not a hit. has==false; get reverts.
    function test_HasIsFalseWhenReturndataEmpty() public {
        vm.etch(BEACON_ROOTS_ADDRESS, address(new MockBeaconRootsEmpty()).code);

        assertFalse(relayer.hasBeaconRoot(TS), "has must be false on empty returndata");

        vm.expectRevert(abi.encodeWithSelector(BeaconRootRelayer.BeaconRootNotFound.selector, TS));
        relayer.getBeaconRoot(TS);
    }

    /// POSITIVE: a 32-byte root is a hit — has==true and get==root.
    function test_HasAndGetAgreeWhenRootPresent() public {
        vm.etch(BEACON_ROOTS_ADDRESS, address(new MockBeaconRootsPresent()).code);

        assertTrue(relayer.hasBeaconRoot(TS), "has must be true when a 32-byte root is returned");
        assertEq(relayer.getBeaconRoot(TS), ROOT, "get must return the root");
    }
}
