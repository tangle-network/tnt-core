// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { L2SlashingReceiver, IL2Slasher } from "../../src/beacon/L2SlashingReceiver.sol";
import {
    ArbitrumL2Receiver
} from "../../src/beacon/bridges/ArbitrumCrossChainMessenger.sol";
import {
    BaseL2Receiver,
    IBaseCrossDomainMessenger
} from "../../src/beacon/bridges/BaseCrossChainMessenger.sol";
import {
    HyperlaneReceiver
} from "../../src/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {
    LayerZeroReceiver
} from "../../src/beacon/bridges/LayerZeroCrossChainMessenger.sol";

/// @notice Round 4 audit C-3 — verifies that the L2 slashing receivers are
///         all UUPS upgradeable, ownership-gated, namespaced under ERC-7201,
///         and reject re-initialisation.
contract L2SlashingReceiverUUPSTest is Test {
    address internal admin = makeAddr("admin");
    address internal attacker = makeAddr("attacker");
    address internal slasher = makeAddr("slasher");
    address internal messenger = makeAddr("messenger");

    // ─── helpers ─────────────────────────────────────────────────────────────

    function _newL2Receiver(address _slasher, address _messenger, address _owner)
        internal
        returns (L2SlashingReceiver receiver, address impl)
    {
        L2SlashingReceiver implC = new L2SlashingReceiver();
        impl = address(implC);
        ERC1967Proxy proxy = new ERC1967Proxy(
            impl, abi.encodeCall(L2SlashingReceiver.initialize, (_slasher, _messenger, _owner))
        );
        receiver = L2SlashingReceiver(address(proxy));
    }

    function _newHyperlane(address _mailbox, address _receiver, address _owner)
        internal
        returns (HyperlaneReceiver h, address impl)
    {
        HyperlaneReceiver implC = new HyperlaneReceiver();
        impl = address(implC);
        ERC1967Proxy proxy = new ERC1967Proxy(
            impl, abi.encodeCall(HyperlaneReceiver.initialize, (_mailbox, _receiver, _owner))
        );
        h = HyperlaneReceiver(address(proxy));
    }

    function _newLayerZero(address _endpoint, address _receiver, address _owner)
        internal
        returns (LayerZeroReceiver lz, address impl)
    {
        LayerZeroReceiver implC = new LayerZeroReceiver();
        impl = address(implC);
        ERC1967Proxy proxy = new ERC1967Proxy(
            impl, abi.encodeCall(LayerZeroReceiver.initialize, (_endpoint, _receiver, _owner))
        );
        lz = LayerZeroReceiver(address(proxy));
    }

    function _newArbitrum(address _l1Sender, address _receiver, uint256 _src, address _owner)
        internal
        returns (ArbitrumL2Receiver a, address impl)
    {
        ArbitrumL2Receiver implC = new ArbitrumL2Receiver();
        impl = address(implC);
        ERC1967Proxy proxy = new ERC1967Proxy(
            impl, abi.encodeCall(ArbitrumL2Receiver.initialize, (_l1Sender, _receiver, _src, _owner))
        );
        a = ArbitrumL2Receiver(address(proxy));
    }

    function _newBase(
        address _l2Messenger,
        address _l1Sender,
        address _receiver,
        uint256 _src,
        address _owner
    ) internal returns (BaseL2Receiver b, address impl) {
        BaseL2Receiver implC = new BaseL2Receiver();
        impl = address(implC);
        ERC1967Proxy proxy = new ERC1967Proxy(
            impl,
            abi.encodeCall(
                BaseL2Receiver.initialize, (_l2Messenger, _l1Sender, _receiver, _src, _owner)
            )
        );
        b = BaseL2Receiver(address(proxy));
    }

    // ─── L2SlashingReceiver ──────────────────────────────────────────────────

    function test_L2Receiver_initIsOneShot() public {
        (L2SlashingReceiver receiver,) = _newL2Receiver(slasher, messenger, admin);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        receiver.initialize(slasher, messenger, admin);
    }

    function test_L2Receiver_implementationCannotBeInitialized() public {
        L2SlashingReceiver impl = new L2SlashingReceiver();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        impl.initialize(slasher, messenger, admin);
    }

    function test_L2Receiver_zeroOwnerReverts() public {
        L2SlashingReceiver impl = new L2SlashingReceiver();
        vm.expectRevert(L2SlashingReceiver.ZeroAddress.selector);
        new ERC1967Proxy(
            address(impl), abi.encodeCall(L2SlashingReceiver.initialize, (slasher, messenger, address(0)))
        );
    }

    function test_L2Receiver_upgradeByAdmin() public {
        (L2SlashingReceiver receiver,) = _newL2Receiver(slasher, messenger, admin);
        L2SlashingReceiver newImpl = new L2SlashingReceiver();
        vm.prank(admin);
        receiver.upgradeToAndCall(address(newImpl), "");
    }

    function test_L2Receiver_upgradeByNonAdminReverts() public {
        (L2SlashingReceiver receiver,) = _newL2Receiver(slasher, messenger, admin);
        L2SlashingReceiver newImpl = new L2SlashingReceiver();
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, attacker));
        receiver.upgradeToAndCall(address(newImpl), "");
    }

    function test_L2Receiver_statePersistsAcrossUpgrade() public {
        (L2SlashingReceiver receiver,) = _newL2Receiver(slasher, messenger, address(this));

        // Schedule + activate an authorised sender to populate namespaced storage.
        address sender_ = makeAddr("connector");
        receiver.setAuthorizedSender(1, sender_, true);
        vm.warp(block.timestamp + receiver.SENDER_ACTIVATION_DELAY() + 1);
        receiver.activateAuthorizedSender(1, sender_);
        assertTrue(receiver.authorizedSenders(1, sender_), "pre-upgrade: sender authorised");
        assertEq(receiver.messenger(), messenger, "pre-upgrade: messenger wired");
        assertEq(address(receiver.slasher()), slasher, "pre-upgrade: slasher wired");

        // Upgrade to a fresh implementation.
        L2SlashingReceiver newImpl = new L2SlashingReceiver();
        receiver.upgradeToAndCall(address(newImpl), "");

        // All namespaced state must be intact after the upgrade.
        assertTrue(receiver.authorizedSenders(1, sender_), "post-upgrade: sender survived");
        assertEq(receiver.messenger(), messenger, "post-upgrade: messenger survived");
        assertEq(address(receiver.slasher()), slasher, "post-upgrade: slasher survived");
        assertEq(receiver.owner(), address(this), "post-upgrade: owner survived");
    }

    /// @dev Storage layout sanity: writes to the struct land at the namespaced slot and
    ///      not at slot 0 (which would imply an upgrade-unsafe layout).
    function test_L2Receiver_storageLandsAtNamespacedSlot() public {
        (L2SlashingReceiver receiver,) = _newL2Receiver(slasher, messenger, address(this));

        // ERC-7201: keccak256(abi.encode(uint256(keccak256("tangle.beacon.L2SlashingReceiver")) - 1)) & ~0xff
        bytes32 nsSlot = 0x82055dbb59125fee25966888e9f62ec781a4d1c7ca467f7e3e2e55d698dfc400;

        // Field 0 is `slasher`, field 1 is `messenger`.
        bytes32 raw0 = vm.load(address(receiver), nsSlot);
        bytes32 raw1 = vm.load(address(receiver), bytes32(uint256(nsSlot) + 1));
        assertEq(address(uint160(uint256(raw0))), slasher, "slasher at namespaced slot+0");
        assertEq(address(uint160(uint256(raw1))), messenger, "messenger at namespaced slot+1");

        // Slot 0 must be untouched by these writes (only proxy implementation bookkeeping
        // and initializer flags live near the low slots). In particular the receiver
        // should not have a non-zero address packed into slot 0.
        bytes32 slot0 = vm.load(address(receiver), bytes32(0));
        assertEq(slot0, bytes32(0), "no state at non-namespaced slot 0");
    }

    // ─── ArbitrumL2Receiver ──────────────────────────────────────────────────

    function test_Arbitrum_initIsOneShot() public {
        (ArbitrumL2Receiver a,) = _newArbitrum(makeAddr("l1"), makeAddr("rcv"), 1, admin);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        a.initialize(makeAddr("l1"), makeAddr("rcv"), 1, admin);
    }

    function test_Arbitrum_implCannotBeInitialized() public {
        ArbitrumL2Receiver impl = new ArbitrumL2Receiver();
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        impl.initialize(makeAddr("l1"), makeAddr("rcv"), 1, admin);
    }

    function test_Arbitrum_upgradeAuth() public {
        (ArbitrumL2Receiver a,) = _newArbitrum(makeAddr("l1"), makeAddr("rcv"), 1, admin);
        ArbitrumL2Receiver impl2 = new ArbitrumL2Receiver();
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, attacker));
        a.upgradeToAndCall(address(impl2), "");
        vm.prank(admin);
        a.upgradeToAndCall(address(impl2), "");
    }

    // ─── BaseL2Receiver ──────────────────────────────────────────────────────

    function test_Base_initIsOneShot() public {
        (BaseL2Receiver b,) =
            _newBase(makeAddr("msgr"), makeAddr("l1"), makeAddr("rcv"), 1, admin);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        b.initialize(makeAddr("msgr"), makeAddr("l1"), makeAddr("rcv"), 1, admin);
    }

    function test_Base_upgradeAuth() public {
        (BaseL2Receiver b,) =
            _newBase(makeAddr("msgr"), makeAddr("l1"), makeAddr("rcv"), 1, admin);
        BaseL2Receiver impl2 = new BaseL2Receiver();
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, attacker));
        b.upgradeToAndCall(address(impl2), "");
        vm.prank(admin);
        b.upgradeToAndCall(address(impl2), "");
    }

    // ─── HyperlaneReceiver ───────────────────────────────────────────────────

    function test_Hyperlane_initIsOneShot() public {
        (HyperlaneReceiver h,) = _newHyperlane(makeAddr("mb"), makeAddr("rcv"), admin);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        h.initialize(makeAddr("mb"), makeAddr("rcv"), admin);
    }

    function test_Hyperlane_upgradeAuth() public {
        (HyperlaneReceiver h,) = _newHyperlane(makeAddr("mb"), makeAddr("rcv"), admin);
        HyperlaneReceiver impl2 = new HyperlaneReceiver();
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, attacker));
        h.upgradeToAndCall(address(impl2), "");
        vm.prank(admin);
        h.upgradeToAndCall(address(impl2), "");
    }

    function test_Hyperlane_statePersistsAcrossUpgrade() public {
        (HyperlaneReceiver h,) = _newHyperlane(makeAddr("mb"), makeAddr("rcv"), address(this));
        address trusted = makeAddr("trusted");
        h.setTrustedSender(42_161, trusted, true);
        assertTrue(h.trustedSenders(42_161, bytes32(uint256(uint160(trusted)))), "trusted set");

        HyperlaneReceiver impl2 = new HyperlaneReceiver();
        h.upgradeToAndCall(address(impl2), "");

        assertTrue(
            h.trustedSenders(42_161, bytes32(uint256(uint160(trusted)))), "trusted survived upgrade"
        );
    }

    // ─── LayerZeroReceiver ───────────────────────────────────────────────────

    function test_LayerZero_initIsOneShot() public {
        (LayerZeroReceiver lz,) = _newLayerZero(makeAddr("ep"), makeAddr("rcv"), admin);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        lz.initialize(makeAddr("ep"), makeAddr("rcv"), admin);
    }

    function test_LayerZero_upgradeAuth() public {
        (LayerZeroReceiver lz,) = _newLayerZero(makeAddr("ep"), makeAddr("rcv"), admin);
        LayerZeroReceiver impl2 = new LayerZeroReceiver();
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(OwnableUpgradeable.OwnableUnauthorizedAccount.selector, attacker));
        lz.upgradeToAndCall(address(impl2), "");
        vm.prank(admin);
        lz.upgradeToAndCall(address(impl2), "");
    }

    function test_LayerZero_statePersistsAcrossUpgrade() public {
        (LayerZeroReceiver lz,) = _newLayerZero(makeAddr("ep"), makeAddr("rcv"), address(this));
        bytes32 peer = bytes32(uint256(uint160(makeAddr("peer"))));
        lz.setPeer(30_110, peer);
        assertEq(lz.peers(30_110), peer);

        LayerZeroReceiver impl2 = new LayerZeroReceiver();
        lz.upgradeToAndCall(address(impl2), "");

        assertEq(lz.peers(30_110), peer, "peer survived upgrade");
    }
}
