// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { BeaconRootRelayer } from "../../src/beacon/l1/BeaconRootRelayer.sol";
import { IL1CrossDomainMessenger } from "../../src/beacon/IBeaconOracle.sol";

contract MockL1CrossDomainMessenger is IL1CrossDomainMessenger {
    address public lastTarget;
    bytes public lastMessage;
    uint32 public lastGasLimit;
    uint256 public lastValue;
    uint256 public sendCount;

    function sendMessage(address target, bytes calldata message, uint32 minGasLimit) external payable override {
        lastTarget = target;
        lastMessage = message;
        lastGasLimit = minGasLimit;
        lastValue = msg.value;
        sendCount += 1;
    }
}

contract MockBeaconRoots {
    mapping(uint64 => bytes32) public roots;

    function setRoot(uint64 timestamp, bytes32 root) external {
        roots[timestamp] = root;
    }

    function clearRoot(uint64 timestamp) external {
        delete roots[timestamp];
    }

    fallback(bytes calldata data) external returns (bytes memory) {
        (uint64 timestamp) = abi.decode(data, (uint64));
        bytes32 root = roots[timestamp];
        if (root == bytes32(0)) revert("NO_ROOT");
        return abi.encode(root);
    }
}

contract BeaconRootRelayerTest is Test {
    address internal constant BEACON_PRECOMPILE = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    MockL1CrossDomainMessenger internal messenger;
    BeaconRootRelayer internal relayer;
    address internal l2Receiver = makeAddr("l2Receiver");
    MockBeaconRoots internal beaconRoots;

    function setUp() public {
        messenger = new MockL1CrossDomainMessenger();
        relayer = new BeaconRootRelayer(address(messenger), l2Receiver);

        // Deploy mock beacon roots contract at the precompile address
        beaconRoots = new MockBeaconRoots();
        vm.etch(BEACON_PRECOMPILE, address(beaconRoots).code);
    }

    function test_relayBeaconRoot_SendsMessageAndMarksTimestamp() public {
        uint64 timestamp = 123;
        bytes32 root = keccak256("root");

        MockBeaconRoots(BEACON_PRECOMPILE).setRoot(timestamp, root);

        vm.expectEmit();
        emit BeaconRootRelayer.BeaconRootRelayed(timestamp, root);
        relayer.relayBeaconRoot(timestamp);

        assertTrue(relayer.relayedTimestamps(timestamp));
        assertEq(messenger.lastTarget(), l2Receiver);
        assertEq(messenger.lastGasLimit(), relayer.DEFAULT_GAS_LIMIT());
        assertEq(messenger.lastMessage(), abi.encodeWithSignature("receiveBeaconRoot(uint64,bytes32)", timestamp, root));
    }

    function test_relayBeaconRoot_RevertWhenRootMissing() public {
        uint64 timestamp = 55;
        vm.expectRevert(abi.encodeWithSelector(BeaconRootRelayer.BeaconRootNotFound.selector, timestamp));
        relayer.relayBeaconRoot(timestamp);
    }

    function test_relayBeaconRoot_RevertWhenAlreadyRelayed() public {
        uint64 timestamp = 999;
        bytes32 root = keccak256("existing");
        MockBeaconRoots(BEACON_PRECOMPILE).setRoot(timestamp, root);

        relayer.relayBeaconRoot(timestamp);

        vm.expectRevert(abi.encodeWithSelector(BeaconRootRelayer.AlreadyRelayed.selector, timestamp));
        relayer.relayBeaconRoot(timestamp);
    }

    function test_relayBeaconRoots_SkipsDuplicates() public {
        uint64[] memory timestamps = new uint64[](3);
        timestamps[0] = 1;
        timestamps[1] = 2;
        timestamps[2] = 1;

        MockBeaconRoots(BEACON_PRECOMPILE).setRoot(1, keccak256("one"));
        MockBeaconRoots(BEACON_PRECOMPILE).setRoot(2, keccak256("two"));

        relayer.relayBeaconRoots(timestamps);
        assertEq(messenger.sendCount(), 2);
        assertTrue(relayer.relayedTimestamps(1));
        assertTrue(relayer.relayedTimestamps(2));
    }

    function test_hasBeaconRoot_ReflectsPrecompileSuccess() public {
        MockBeaconRoots(BEACON_PRECOMPILE).setRoot(7, keccak256("root"));
        assertTrue(relayer.hasBeaconRoot(7));

        MockBeaconRoots(BEACON_PRECOMPILE).clearRoot(7);
        assertFalse(relayer.hasBeaconRoot(7));
    }

    function test_getBeaconRoot_ReturnsRoot() public {
        uint64 timestamp = 77;
        bytes32 root = keccak256("data");
        MockBeaconRoots(BEACON_PRECOMPILE).setRoot(timestamp, root);

        bytes32 actual = relayer.getBeaconRoot(timestamp);
        assertEq(actual, root);
    }
}
