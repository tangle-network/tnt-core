// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { L2SlashingReceiver, IL2Slasher } from "../../src/beacon/L2SlashingReceiver.sol";
import { BaseCrossChainMessenger } from "../../src/beacon/bridges/BaseCrossChainMessenger.sol";

/// @notice Mock IL2Slasher that RECORDS every slashOperator call so the test can assert
///         an attacker-chosen slash was applied with no beacon proof.
contract MockSlasher is IL2Slasher {
    address public lastOperator;
    uint16 public lastSlashBps;
    bytes public lastReason;
    uint256 public slashCount;

    function slashOperator(address operator, uint16 slashBps, bytes calldata reason) external override {
        lastOperator = operator;
        lastSlashBps = slashBps;
        lastReason = reason;
        slashCount++;
    }

    function canSlash(address) external pure override returns (bool) {
        return true;
    }

    function getSlashableStake(address) external pure override returns (uint256) {
        return 1000 ether;
    }
}

/// @notice Mock of the OP-stack `L2CrossDomainMessenger` singleton.
/// @dev Plays BOTH halves of the native bridge:
///      - L1 side: `sendMessage(target, message, gas)` is the function
///        `BaseCrossChainMessenger.sendMessage` forwards to. We simulate the native
///        bridge by immediately relaying it on "L2" with the authenticated L1 sender
///        (`xDomainMessageSender`) set to OUR caller — i.e. the adapter that relayed it.
///      - L2 side: exposes the settable `xDomainMessageSender()` the receiver reads to
///        authenticate the L1 origin, and a `relayCall` helper for a hand-forged delivery.
contract MockOpStackMessenger {
    address public xDomainMessageSender;

    /// @dev IBaseCrossDomainMessenger.sendMessage — invoked by the adapter on L1.
    ///      In production the native messenger queues this and replays it on L2 with
    ///      xDomainMessageSender == the L1 caller (the adapter). We do that inline.
    function sendMessage(address _target, bytes calldata _message, uint32) external payable {
        xDomainMessageSender = msg.sender; // the BaseCrossChainMessenger adapter relayed it
        (bool ok, bytes memory ret) = _target.call(_message);
        if (!ok) {
            assembly {
                revert(add(ret, 0x20), mload(ret))
            }
        }
        xDomainMessageSender = address(0);
    }

    /// @dev Directly drive an L2 delivery presenting `sender` as the authenticated L1 origin.
    function setXDomainMessageSender(address sender) external {
        xDomainMessageSender = sender;
    }

    function relayCall(address sender, address target, bytes calldata data) external {
        xDomainMessageSender = sender;
        (bool ok, bytes memory ret) = target.call(data);
        if (!ok) {
            assembly {
                revert(add(ret, 0x20), mload(ret))
            }
        }
    }
}

/// @title PoCBridgeForgery
/// @notice PoC for finding sub-1-deep-audit-b5af8d25-4e0:
///         `BaseCrossChainMessenger.sendMessage` is permissionless, so an arbitrary
///         attacker can forge a BEACON_SLASH that `L2SlashingReceiver` accepts in
///         `opStackMessengerMode`. The adapter is a confused-deputy / open relay: it
///         lends its trusted `xDomainMessageSender` identity to attacker payloads.
contract PoCBridgeForgery is Test {
    L2SlashingReceiver internal receiver;
    MockSlasher internal slasher;
    MockOpStackMessenger internal mockMessenger;
    BaseCrossChainMessenger internal adapter;

    address internal owner = address(this);
    address internal attacker = makeAddr("attacker");
    address internal victimOperator = makeAddr("victimOperator");
    address internal victimPod = makeAddr("victimPod");

    bytes4 internal constant SLASH_MESSAGE_TYPE = bytes4(keccak256("BEACON_SLASH"));

    // The adapter forwards `receiveMessage(block.chainid, msg.sender, payload)`, so the
    // source chain the receiver sees is the L1 chainid (the test's block.chainid).
    uint256 internal srcChainId;

    function setUp() public {
        srcChainId = block.chainid;

        slasher = new MockSlasher();
        mockMessenger = new MockOpStackMessenger();

        // The BaseCrossChainMessenger adapter is the real audited contract. Its L1
        // messenger is our mock. The adapter address is the value the receiver will see
        // as xDomainMessageSender on L2.
        adapter = new BaseCrossChainMessenger(address(mockMessenger));

        // Deploy receiver behind ERC1967Proxy; wire messenger via setMessenger (bootstrap).
        L2SlashingReceiver impl = new L2SlashingReceiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl), abi.encodeCall(L2SlashingReceiver.initialize, (address(slasher), address(0), owner))
        );
        receiver = L2SlashingReceiver(address(proxy));

        receiver.setMessenger(address(mockMessenger));
        receiver.setOpStackMessengerMode(true);

        // Register the trusted L1 counterpart = the adapter address (this is what the
        // legit flow authenticates to, because the connector reaches the native messenger
        // only THROUGH the adapter). Timelocked: schedule, warp, activate.
        receiver.setOpStackL1Sender(srcChainId, address(adapter), true);
        vm.warp(block.timestamp + receiver.SENDER_ACTIVATION_DELAY());
        receiver.activateOpStackL1Sender(srcChainId, address(adapter));

        assertEq(receiver.opStackL1Sender(srcChainId), address(adapter), "adapter registered as trusted L1 sender");
        assertTrue(receiver.opStackMessengerMode(), "opStack mode enabled");
    }

    /// @dev Build a forged BEACON_SLASH payload with every field attacker-chosen.
    function _forgedPayload(uint16 slashBps, uint256 nonce) internal view returns (bytes memory) {
        return abi.encodePacked(
            SLASH_MESSAGE_TYPE, abi.encode(victimOperator, slashBps, uint64(7777), nonce, victimPod)
        );
    }

    /// @notice END-TO-END: attacker calls the permissionless adapter.sendMessage; the
    ///         native messenger relays it under the adapter's trusted identity; the
    ///         receiver accepts the forged slash. No beacon proof anywhere.
    function test_AttackerForgesSlash_EndToEnd_ViaPermissionlessSendMessage() public {
        uint16 forgedBps = 9999;
        bytes memory payload = _forgedPayload(forgedBps, 1);

        assertEq(slasher.slashCount(), 0, "no slash yet");

        // FIX VERIFIED: sendMessage is now gated to owner/authorized relayers (the
        // L2SlashingConnector). An unauthorized attacker can no longer borrow the adapter's
        // authenticated L1 identity, so the forged slash reverts before any delivery.
        // (Cache BASE_CHAIN_ID() before the prank — calling it would otherwise consume the
        // prank and run sendMessage as the test contract, which IS the owner.)
        uint256 baseChainId = adapter.BASE_CHAIN_ID();
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(BaseCrossChainMessenger.UnauthorizedSender.selector, attacker));
        adapter.sendMessage(baseChainId, address(receiver), payload, 100_000);

        assertEq(slasher.slashCount(), 0, "no forged slash: adapter rejects unauthorized sender");
    }

    /// @notice The receiver authenticates the L1 origin via xDomainMessageSender == the
    ///         registered adapter. A delivery whose xDomainMessageSender is NOT the adapter
    ///         is rejected. On real OP-Stack the messenger reports the TRUE L1 caller, so
    ///         an `xDomainMessageSender == adapter` delivery can only originate from the
    ///         adapter itself — and the adapter now gates sendMessage to authorized relayers
    ///         (see the EndToEnd test). Faking xDomainMessageSender == adapter for a message
    ///         the adapter never relayed is not reachable on mainnet (it would require
    ///         compromising the OP CrossDomainMessenger, which is outside the trust model).
    function test_ForgedDelivery_FromNonAdapter_IsRejected() public {
        uint16 forgedBps = 5000;
        bytes memory payload = _forgedPayload(forgedBps, 42);

        // Attacker presents THEMSELF as the L1 sender (the only thing they can actually do
        // on real OP-Stack). The receiver's xDomainMessageSender == adapter check rejects it.
        vm.prank(attacker);
        vm.expectRevert();
        mockMessenger.relayCall(
            address(attacker),
            address(receiver),
            abi.encodeCall(L2SlashingReceiver.receiveMessage, (srcChainId, attacker, payload))
        );

        assertEq(slasher.slashCount(), 0, "no slash: receiver rejects non-adapter L1 origin");
    }
}
