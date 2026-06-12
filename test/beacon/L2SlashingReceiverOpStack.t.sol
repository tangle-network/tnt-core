// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { L2SlashingReceiver, IL2Slasher } from "../../src/beacon/L2SlashingReceiver.sol";

/// @notice Minimal slasher that records the last slash and always reports slashable.
contract RecordingSlasher is IL2Slasher {
    address public lastOperator;
    uint16 public lastSlashBps;
    uint256 public slashCount;

    function slashOperator(address operator, uint16 slashBps, bytes calldata) external override {
        lastOperator = operator;
        lastSlashBps = slashBps;
        slashCount++;
    }

    function canSlash(address) external pure override returns (bool) {
        return true;
    }

    function getSlashableStake(address) external pure override returns (uint256) {
        return 100 ether;
    }
}

/// @notice Mock of the OP-stack `L2CrossDomainMessenger` singleton.
/// @dev Relays an arbitrary call to a target while exposing a settable
///      `xDomainMessageSender()`. This is exactly the shared-singleton surface an
///      attacker abuses: ANY L1 actor can drive `relayCall`, and the receiver must
///      authenticate the L1 origin via `xDomainMessageSender()` — NOT via the calldata
///      `sender` it forwards.
contract MockOpStackCrossDomainMessenger {
    address private _xDomainMessageSender;

    function setXDomainMessageSender(address sender) external {
        _xDomainMessageSender = sender;
    }

    function xDomainMessageSender() external view returns (address) {
        return _xDomainMessageSender;
    }

    /// @notice Relay a call to `target` while presenting `sender` as the xDomain sender.
    function relayCall(address sender, address target, bytes calldata data) external returns (bytes memory) {
        _xDomainMessageSender = sender;
        (bool ok, bytes memory ret) = target.call(data);
        if (!ok) {
            assembly {
                revert(add(ret, 0x20), mload(ret))
            }
        }
        return ret;
    }
}

/// @title L2SlashingReceiverOpStackTest
/// @notice Cross-chain MEDIUM (forgeable-slash): on OP-stack chains the receiver must
///         authenticate the L1 origin via `xDomainMessageSender()`, NOT the
///         attacker-supplied calldata `sender`.
contract L2SlashingReceiverOpStackTest is Test {
    L2SlashingReceiver internal receiver;
    RecordingSlasher internal slasher;
    MockOpStackCrossDomainMessenger internal opMessenger;

    address internal owner = address(this);
    address internal operator = makeAddr("operator");
    address internal realConnector = makeAddr("realConnector"); // trusted L1 counterpart
    address internal attacker = makeAddr("attacker");

    uint256 internal constant L1_CHAIN_ID = 1;
    bytes4 internal constant SLASH_MESSAGE_TYPE = bytes4(keccak256("BEACON_SLASH"));

    function setUp() public {
        slasher = new RecordingSlasher();
        opMessenger = new MockOpStackCrossDomainMessenger();

        L2SlashingReceiver impl = new L2SlashingReceiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl), abi.encodeCall(L2SlashingReceiver.initialize, (address(slasher), address(opMessenger), owner))
        );
        receiver = L2SlashingReceiver(address(proxy));

        // Enable OP-stack direct-delivery mode and register the trusted L1 counterpart
        // (timelocked, mirroring the authorized-sender flow).
        receiver.setOpStackMessengerMode(true);
        receiver.setOpStackL1Sender(L1_CHAIN_ID, realConnector, true);
        vm.warp(block.timestamp + receiver.SENDER_ACTIVATION_DELAY() + 1);
        receiver.activateOpStackL1Sender(L1_CHAIN_ID, realConnector);
    }

    function _slashPayload(uint256 nonce) internal returns (bytes memory) {
        return abi.encodePacked(
            SLASH_MESSAGE_TYPE, abi.encode(operator, uint16(1000), uint64(0.9e18), nonce, makeAddr("pod"))
        );
    }

    /// @dev The forgery: a non-counterpart L1 sender drives the singleton, but sets the
    ///      calldata `sender` to the REAL connector. Under the old code `onlyMessenger`
    ///      (singleton) + `authorizedSenders[L1][realConnector]` both passed. The fix
    ///      authenticates via `xDomainMessageSender()`, which is the attacker, so it reverts.
    function test_opStack_forgedSenderReverts() public {
        bytes memory payload = _slashPayload(0);

        // xDomainMessageSender is the attacker; calldata `sender` is spoofed to realConnector.
        vm.expectRevert(
            abi.encodeWithSelector(L2SlashingReceiver.UnauthorizedOpStackSender.selector, L1_CHAIN_ID, attacker)
        );
        opMessenger.relayCall(
            attacker,
            address(receiver),
            abi.encodeCall(L2SlashingReceiver.receiveMessage, (L1_CHAIN_ID, realConnector, payload))
        );

        assertEq(slasher.slashCount(), 0, "no slash should have applied");
    }

    /// @dev Even if the attacker is honest about the calldata `sender` being themselves,
    ///      it still reverts — calldata `sender` is irrelevant in OP-stack mode.
    function test_opStack_forgedSender_ignoresCalldataSender() public {
        bytes memory payload = _slashPayload(1);

        vm.expectRevert(
            abi.encodeWithSelector(L2SlashingReceiver.UnauthorizedOpStackSender.selector, L1_CHAIN_ID, attacker)
        );
        opMessenger.relayCall(
            attacker,
            address(receiver),
            abi.encodeCall(L2SlashingReceiver.receiveMessage, (L1_CHAIN_ID, attacker, payload))
        );
    }

    /// @dev Happy path: xDomainMessageSender == trusted counterpart → slash applies, even
    ///      when the calldata `sender` is garbage (it is ignored in OP-stack mode).
    function test_opStack_authenticatedSenderSucceeds() public {
        bytes memory payload = _slashPayload(2);

        opMessenger.relayCall(
            realConnector,
            address(receiver),
            // calldata `sender` deliberately set to a bogus value to prove it is ignored.
            abi.encodeCall(L2SlashingReceiver.receiveMessage, (L1_CHAIN_ID, makeAddr("ignored"), payload))
        );

        assertEq(slasher.slashCount(), 1, "slash applied");
        assertEq(slasher.lastOperator(), operator);
        assertEq(slasher.lastSlashBps(), 1000);
        // Nonce is namespaced under the AUTHENTICATED sender, not the calldata sender.
        assertTrue(receiver.isNonceProcessed(L1_CHAIN_ID, realConnector, 2));
    }

    /// @dev OP-stack mode but no trusted counterpart configured for the source chain →
    ///      the message cannot be authenticated, so it reverts (fail-closed).
    function test_opStack_unconfiguredSourceChainReverts() public {
        uint256 otherChain = 10;
        bytes memory payload = _slashPayload(3);

        vm.expectRevert(
            abi.encodeWithSelector(L2SlashingReceiver.OpStackSenderNotConfigured.selector, otherChain)
        );
        opMessenger.relayCall(
            realConnector,
            address(receiver),
            abi.encodeCall(L2SlashingReceiver.receiveMessage, (otherChain, realConnector, payload))
        );
    }

    /// @dev The OP-stack trust anchor is timelocked: scheduling does not take effect
    ///      immediately, and a non-owner cannot schedule it.
    function test_opStackL1Sender_isTimelocked_andOwnerGated() public {
        address newCounterpart = makeAddr("newCounterpart");

        // Schedule — not yet active.
        receiver.setOpStackL1Sender(L1_CHAIN_ID, newCounterpart, true);
        assertEq(receiver.opStackL1Sender(L1_CHAIN_ID), realConnector, "anchor unchanged until activation");

        // Activating before the delay reverts.
        uint256 activationTime = receiver.pendingAuthorizedSenders(L1_CHAIN_ID, newCounterpart);
        vm.expectRevert(
            abi.encodeWithSelector(L2SlashingReceiver.SenderActivationTooEarly.selector, activationTime)
        );
        receiver.activateOpStackL1Sender(L1_CHAIN_ID, newCounterpart);

        // After the delay, activation repoints the anchor.
        vm.warp(block.timestamp + receiver.SENDER_ACTIVATION_DELAY() + 1);
        receiver.activateOpStackL1Sender(L1_CHAIN_ID, newCounterpart);
        assertEq(receiver.opStackL1Sender(L1_CHAIN_ID), newCounterpart);

        // Non-owner cannot schedule the trust anchor.
        vm.prank(attacker);
        vm.expectRevert();
        receiver.setOpStackL1Sender(L1_CHAIN_ID, attacker, true);
    }
}
