// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { BeaconRootReceiver } from "../../src/beacon/BeaconRootReceiver.sol";
import { IL2CrossDomainMessenger } from "../../src/beacon/IBeaconOracle.sol";

contract MockL2Messenger is IL2CrossDomainMessenger {
    address public currentSender;

    function xDomainMessageSender() external view override returns (address) {
        return currentSender;
    }

    function deliver(address receiver, address l1Sender, uint64 timestamp, bytes32 root) external {
        currentSender = l1Sender;
        BeaconRootReceiver(receiver).receiveBeaconRoot(timestamp, root);
    }
}

contract BeaconRootReceiverTest is Test {
    BeaconRootReceiver internal receiver;
    MockL2Messenger internal messenger;
    address internal relayer = makeAddr("relayer");
    address internal owner = makeAddr("owner");

    function setUp() public {
        messenger = new MockL2Messenger();
        vm.prank(owner);
        receiver = new BeaconRootReceiver(address(messenger), relayer);
    }

    function test_receiveBeaconRoot_Success() public {
        uint64 timestamp = 123;
        bytes32 root = keccak256("root");

        messenger.deliver(address(receiver), relayer, timestamp, root);

        assertEq(receiver.latestBeaconTimestamp(), timestamp);
        assertEq(receiver.getBeaconBlockRoot(timestamp), root);
        assertTrue(receiver.hasBeaconBlockRoot(timestamp));
    }

    function test_receiveBeaconRoot_RevertWhenNotMessenger() public {
        vm.expectRevert(BeaconRootReceiver.OnlyMessenger.selector);
        receiver.receiveBeaconRoot(1, bytes32("root"));
    }

    function test_receiveBeaconRoot_RevertWrongRelayer() public {
        uint64 timestamp = 1;
        bytes32 root = keccak256("alt");

        vm.expectRevert(BeaconRootReceiver.OnlyL1Relayer.selector);
        messenger.deliver(address(receiver), makeAddr("intruder"), timestamp, root);
    }

    function test_getBeaconBlockRoot_RevertWhenMissing() public {
        vm.expectRevert(abi.encodeWithSelector(BeaconRootReceiver.BeaconRootNotFound.selector, uint64(5)));
        receiver.getBeaconBlockRoot(5);
    }

    function test_setL1BeaconRootRelayer() public {
        address newRelayer = makeAddr("new");
        vm.prank(owner);
        receiver.setL1BeaconRootRelayer(newRelayer);

        uint64 timestamp = 9;
        bytes32 root = keccak256("new");

        messenger.deliver(address(receiver), newRelayer, timestamp, root);

        assertEq(receiver.getBeaconBlockRoot(timestamp), root);
    }

    function test_setL1BeaconRootRelayer_RevertZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(BeaconRootReceiver.ZeroAddress.selector);
        receiver.setL1BeaconRootRelayer(address(0));
    }
}
