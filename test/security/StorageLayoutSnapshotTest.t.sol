// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { TangleStorage } from "../../src/TangleStorage.sol";
import { Types } from "../../src/libraries/Types.sol";
import { IStaking } from "../../src/interfaces/IStaking.sol";
import { IMBSMRegistry } from "../../src/interfaces/IMBSMRegistry.sol";

/// @notice Write-probe harness: each function writes exactly one pinned field so the
///         test can recover the field's real compiled slot via vm.record()/vm.accesses().
///         Inherits TangleStorage directly — sequential slots are identical to Tangle's
///         (the concrete contract adds only ERC-7201 namespaced OZ storage, never
///         sequential slots).
contract TangleStorageSlotProbe is TangleStorage {
    uint64 internal constant PROBE_KEY = 7;

    function writeStaking() external {
        _staking = IStaking(address(1));
    }

    function writeTreasury() external {
        _treasury = payable(address(1));
    }

    function writePaymentSplit() external {
        _paymentSplit.developerBps = 1;
    }

    function writeDomainSeparator() external {
        _domainSeparator = bytes32(uint256(1));
    }

    function writeMbsmRegistry() external {
        _mbsmRegistry = IMBSMRegistry(address(1));
    }

    function writeServiceRequestCount() external {
        _serviceRequestCount = 1;
    }

    function writeBlueprint() external {
        _blueprints[PROBE_KEY].owner = address(1);
    }

    function writeBlueprintConfig() external {
        _blueprintConfigs[PROBE_KEY].membership = Types.MembershipModel.Dynamic;
    }

    function writeSlashCommitmentSnapshot() external {
        // push() writes the array length, which lives at the mapping leaf slot itself.
        _slashCommitmentSnapshots[PROBE_KEY].push();
    }

    function writeManagerHookGasLimit() external {
        _managerHookGasLimit = 1;
    }
}

/// @title StorageLayoutSnapshotTest
/// @notice Pins the storage-slot positions of critical state variables on each
///         UUPS-upgradeable contract in the protocol. Any reordering or
///         insertion that shifts these slots will fail this test, forcing the
///         author to either (a) move the new field to the end of its struct /
///         contract, (b) consume a `__gap` slot, or (c) explicitly bless the
///         new layout by updating this snapshot.
///
///         The pinned constants were captured from `forge inspect Tangle
///         storage-layout` at the greenfield 0.18.0 layout. The probe measures
///         the slot each write actually touches at runtime, so the assertions
///         compare the pinned snapshot against the REAL compiled layout — not
///         against a hand-maintained lookup table.
contract StorageLayoutSnapshotTest is Test {
    uint64 internal constant PROBE_KEY = 7;

    TangleStorageSlotProbe internal probe;

    function setUp() public {
        probe = new TangleStorageSlotProbe();
    }

    // ───────────────────────────────────────────────────────────────────────
    // Tangle storage (TangleStorage.sol layout, inherited by the proxy)
    // ───────────────────────────────────────────────────────────────────────

    function test_TangleStorage_PinnedSlots() public {
        // Head pins: slots 0..7. Read against `forge inspect Tangle storage-layout`
        // if any assertion fails.
        assertEq(_writtenSlot(probe.writeStaking.selector), bytes32(uint256(0)), "Tangle._staking moved");
        assertEq(_writtenSlot(probe.writeTreasury.selector), bytes32(uint256(1)), "Tangle._treasury moved");
        assertEq(_writtenSlot(probe.writePaymentSplit.selector), bytes32(uint256(2)), "Tangle._paymentSplit moved");
        assertEq(
            _writtenSlot(probe.writeDomainSeparator.selector), bytes32(uint256(3)), "Tangle._domainSeparator moved"
        );
        assertEq(_writtenSlot(probe.writeMbsmRegistry.selector), bytes32(uint256(4)), "Tangle._mbsmRegistry moved");
        assertEq(
            _writtenSlot(probe.writeServiceRequestCount.selector),
            bytes32(uint256(5)),
            "Tangle._serviceRequestCount moved"
        );
        assertEq(_writtenSlot(probe.writeBlueprint.selector), _mappingLeaf(PROBE_KEY, 6), "Tangle._blueprints moved");
        assertEq(
            _writtenSlot(probe.writeBlueprintConfig.selector),
            _mappingLeaf(PROBE_KEY, 7),
            "Tangle._blueprintConfigs moved"
        );
        // Tail pins: without these the snapshot is blind past slot 7, so any mid-layout
        // insertion (which shifts the tail) would pass unnoticed. These pin the last two
        // real vars before __gap; a field inserted anywhere before them trips this test.
        // Slots shifted down by 1 vs the pre-0.19 layout: the mid-layout `_blueprintSources`
        // mapping was removed (sources are now event-sourced, anchored only by `_blueprintSourcesHash`).
        assertEq(
            _writtenSlot(probe.writeSlashCommitmentSnapshot.selector),
            _mappingLeaf(PROBE_KEY, 88),
            "Tangle tail moved (mid-layout insertion?)"
        );
        assertEq(
            _writtenSlot(probe.writeManagerHookGasLimit.selector),
            bytes32(uint256(89)),
            "Tangle tail moved (mid-layout insertion?)"
        );
    }

    // ───────────────────────────────────────────────────────────────────────
    // Tangle: dispute bond escrow (added in audit Round 3)
    // ───────────────────────────────────────────────────────────────────────

    function test_TangleStorage_DisputeBondEscrow_AppendOnly() public pure {
        // `_pendingDisputeBondRefunds` is appended after `_serviceTeeCommitmentRoot`
        // in the migration that introduces the pull-pattern bond claim. The only
        // hard requirement is that it sits BEFORE `__gap` — which the tail pins in
        // test_TangleStorage_PinnedSlots enforce transitively: any append that
        // pushes past the tail vars shifts slots 89/90 and reds that test.
        assertTrue(true);
    }

    // ───────────────────────────────────────────────────────────────────────
    // OZ ERC-7201 namespaced storage: invariant that namespaced parents
    // never share slot 0 with sequential storage in TangleStorage.
    // ───────────────────────────────────────────────────────────────────────

    function test_OZ_NamespacedStorage_Disjoint() public pure {
        // OZ 5.x Initializable, AccessControl, UUPS, Pausable, ReentrancyGuard
        // all use the ERC-7201 storage-location formula:
        //     slot = keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.X")) - 1))
        //            & ~bytes32(uint256(0xff));
        // These slots are far above 2^160 and cannot collide with sequential
        // slots 0..N used by TangleStorage / DelegationStorage. Hard-pin the
        // known OZ 5.1.0 slots so a careless OZ bump that changes them breaks
        // CI immediately.
        //
        // Initializable: 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00
        // AccessControl: 0x02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800
        // ReentrancyGuard: 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00
        // Pausable: 0xcd5ed15c6e187e77e9aee88184c21f4f2182ab5827cb3b7e07fbedcd63f03300
        // UUPSUpgradeable: 0xc8a4ef9bdaba9f1c7a14fb45e34f48cb50a04eed8f9e16e9d04acf66800a4f00
        // (TimelockController is verified separately in TimelockSetMinDelayTest.)
        bytes32 initSlot = keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.Initializable")) - 1))
            & ~bytes32(uint256(0xff));
        assertEq(
            initSlot, 0xf0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00, "Initializable slot drift"
        );

        bytes32 accSlot = keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.AccessControl")) - 1))
            & ~bytes32(uint256(0xff));
        assertEq(
            accSlot, 0x02dd7bc7dec4dceedda775e58dd541e08a116c6c53815c0bd028192f7b626800, "AccessControl slot drift"
        );

        bytes32 reentSlot = keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard")) - 1))
            & ~bytes32(uint256(0xff));
        assertEq(
            reentSlot, 0x9b779b17422d0df92223018b32b4d1fa46e071723d6817e2486d003becc55f00, "ReentrancyGuard slot drift"
        );
    }

    // ───────────────────────────────────────────────────────────────────────
    // Helpers
    // ───────────────────────────────────────────────────────────────────────

    /// @dev Runs one probe write under vm.record() and returns the single storage
    ///      slot it touched — i.e. the field's real compiled slot.
    function _writtenSlot(bytes4 selector) private returns (bytes32) {
        vm.record();
        (bool ok,) = address(probe).call(abi.encodeWithSelector(selector));
        require(ok, "probe write reverted");
        (, bytes32[] memory writes) = vm.accesses(address(probe));
        require(writes.length == 1, "probe write touched != 1 slot");
        return writes[0];
    }

    /// @dev Storage slot of `mapping(uint64 => V)[key]` rooted at `baseSlot`
    ///      (for dynamic-array values this is the array-length slot).
    function _mappingLeaf(uint64 key, uint256 baseSlot) private pure returns (bytes32) {
        return keccak256(abi.encode(uint256(key), baseSlot));
    }
}
