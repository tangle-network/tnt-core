// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {
    ArbitrumCrossChainMessenger,
    ArbitrumL2Receiver,
    IArbitrumInbox
} from "../../../src/beacon/bridges/ArbitrumCrossChainMessenger.sol";
import {
    BaseCrossChainMessenger,
    BaseL2Receiver,
    IBaseCrossDomainMessenger
} from "../../../src/beacon/bridges/BaseCrossChainMessenger.sol";
import { ICrossChainReceiver } from "../../../src/beacon/interfaces/ICrossChainMessenger.sol";

/// @title Beacon cross-chain bridge audit regression tests (MED/LOW unit: beacon-bridges)
/// @notice Each test asserts a SECURE invariant introduced by the remediation in
///         BaseCrossChainMessenger.sol / ArbitrumCrossChainMessenger.sol. Reverting any
///         fix makes the matching test fail:
///           - MEDIUM (selector mismatch): the L1 messenger now encodes the L2 adapter's
///             `relayMessage(bytes)` selector, so the cross-chain call actually executes on
///             L2 instead of reverting. Proven end-to-end by replaying the captured calldata
///             against a real L2 adapter and confirming it reaches the final receiver.
///           - LOW (Arbitrum refund lock): refunds default to the L2 `target` (a recoverable,
///             operator-controlled contract) instead of `msg.sender` (whose L2 alias is a
///             dead, fund-locking address).
///           - LOW (uint32 gas truncation): the Base messenger reverts on an effective gas
///             limit > type(uint32).max instead of silently truncating it.

// ──────────────────────────────────────────────────────────────────────────────
// Mocks mirroring the real bridge topology
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Final receiver wired behind the L2 adapter. Records the last forwarded message.
contract MockCrossChainReceiver is ICrossChainReceiver {
    uint256 public lastSourceChainId;
    address public lastSender;
    bytes public lastPayload;
    uint256 public calls;

    function receiveMessage(uint256 sourceChainId, address sender, bytes calldata payload) external override {
        lastSourceChainId = sourceChainId;
        lastSender = sender;
        lastPayload = payload;
        calls += 1;
    }
}

/// @notice Captures the calldata + gas the L1 messenger forwards to the OP-stack messenger,
///         and lets the test replay that exact calldata against the real L2 adapter.
contract MockBaseMessenger is IBaseCrossDomainMessenger {
    address public override xDomainMessageSender;
    address public lastTarget;
    bytes public lastMessage;
    uint32 public lastGasLimit;

    function sendMessage(address target, bytes calldata message, uint32 minGasLimit) external payable override {
        lastTarget = target;
        lastMessage = message;
        lastGasLimit = minGasLimit;
    }

    function setXDomainMessageSender(address sender) external {
        xDomainMessageSender = sender;
    }
}

/// @notice Captures the retryable-ticket params the Arbitrum messenger submits.
contract MockArbitrumInbox is IArbitrumInbox {
    struct TicketParams {
        address to;
        uint256 l2CallValue;
        uint256 maxSubmissionCost;
        address excessFeeRefundAddress;
        address callValueRefundAddress;
        uint256 gasLimit;
        uint256 maxFeePerGas;
        bytes data;
    }

    TicketParams internal _lastTicket;
    uint256 public submissionFee;
    uint256 private ticketId;

    function getLastTicket() external view returns (TicketParams memory) {
        return _lastTicket;
    }

    function setSubmissionFee(uint256 fee) external {
        submissionFee = fee;
    }

    function createRetryableTicket(
        address to,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 gasLimit,
        uint256 maxFeePerGas,
        bytes calldata data
    )
        external
        payable
        override
        returns (uint256)
    {
        _lastTicket = TicketParams({
            to: to,
            l2CallValue: l2CallValue,
            maxSubmissionCost: maxSubmissionCost,
            excessFeeRefundAddress: excessFeeRefundAddress,
            callValueRefundAddress: callValueRefundAddress,
            gasLimit: gasLimit,
            maxFeePerGas: maxFeePerGas,
            data: data
        });
        ticketId += 1;
        return ticketId;
    }

    function calculateRetryableSubmissionFee(uint256, uint256) external view override returns (uint256) {
        return submissionFee;
    }
}

contract BeaconBridgesAuditTest is Test {
    // OP-stack / Base
    MockBaseMessenger internal baseMessenger;
    BaseCrossChainMessenger internal baseAdapter;
    // Arbitrum
    MockArbitrumInbox internal inbox;
    ArbitrumCrossChainMessenger internal arbAdapter;

    // Shared
    MockCrossChainReceiver internal finalReceiver;
    address internal connector = makeAddr("l2SlashingConnector"); // the authorized L1 sender
    bytes internal slashPayload = abi.encode("SLASH", uint16(500), uint256(7));

    uint256 internal constant SOURCE_CHAIN_ID = 11_155_111;

    function setUp() public {
        finalReceiver = new MockCrossChainReceiver();

        baseMessenger = new MockBaseMessenger();
        baseAdapter = new BaseCrossChainMessenger(address(baseMessenger));
        baseAdapter.setAuthorizedSender(connector, true);

        inbox = new MockArbitrumInbox();
        arbAdapter = new ArbitrumCrossChainMessenger(address(inbox));
        arbAdapter.setAuthorizedSender(connector, true);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Helpers to deploy the real UUPS L2 adapters as the cross-chain `target`.
    // ──────────────────────────────────────────────────────────────────────────

    function _deployBaseL2Receiver(address l1Sender) internal returns (BaseL2Receiver) {
        BaseL2Receiver impl = new BaseL2Receiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(
                BaseL2Receiver.initialize,
                (address(baseMessenger), l1Sender, address(finalReceiver), SOURCE_CHAIN_ID, address(this))
            )
        );
        return BaseL2Receiver(address(proxy));
    }

    function _deployArbitrumL2Receiver(address l1Sender) internal returns (ArbitrumL2Receiver) {
        ArbitrumL2Receiver impl = new ArbitrumL2Receiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(
                ArbitrumL2Receiver.initialize,
                (l1Sender, address(finalReceiver), SOURCE_CHAIN_ID, address(this))
            )
        );
        return ArbitrumL2Receiver(address(proxy));
    }

    // ══════════════════════════════════════════════════════════════════════════
    // MEDIUM — L1/L2 adapter selector match: the L1-encoded calldata must EXECUTE
    // on the real L2 adapter (`relayMessage`), not revert. This is the core fix:
    // the slash path was dead because the L1 messenger encoded `receiveMessage`,
    // a selector the L2 adapter does not expose.
    // ══════════════════════════════════════════════════════════════════════════

    /// @notice Base path: replay the captured L1->L2 calldata against the real adapter and
    ///         prove it forwards to the final receiver. Reverting the selector fix makes the
    ///         replayed call revert (no matching function), failing this test.
    function test_base_l1Calldata_executesOnRealL2Adapter() public {
        // The L2 `target` is the paired adapter, authenticating `connector` as the L1 origin.
        BaseL2Receiver l2Adapter = _deployBaseL2Receiver(connector);

        // L1 side: the authorized connector sends a message targeting the L2 adapter.
        vm.prank(connector);
        baseAdapter.sendMessage(baseAdapter.BASE_CHAIN_ID(), address(l2Adapter), slashPayload, 150_000);

        bytes memory l1Calldata = baseMessenger.lastMessage();
        assertEq(baseMessenger.lastTarget(), address(l2Adapter), "target is the L2 adapter");

        // L2 side: the OP-stack messenger delivers `l1Calldata` to the adapter. The adapter
        // authenticates the L1 origin via xDomainMessageSender(), then dispatches.
        baseMessenger.setXDomainMessageSender(connector);
        vm.prank(address(baseMessenger));
        (bool ok,) = address(l2Adapter).call(l1Calldata);
        assertTrue(ok, "L1-encoded calldata must execute on the L2 adapter (selector must match relayMessage)");

        // The payload reached the final receiver with the adapter's authenticated identity.
        assertEq(finalReceiver.calls(), 1, "final receiver invoked exactly once");
        assertEq(finalReceiver.lastSourceChainId(), SOURCE_CHAIN_ID, "source chain forwarded");
        assertEq(finalReceiver.lastSender(), connector, "authenticated L1 sender forwarded");
        assertEq(finalReceiver.lastPayload(), slashPayload, "raw slash payload forwarded intact");
    }

    /// @notice Arbitrum path: same end-to-end proof through a retryable ticket. The L2 adapter
    ///         authenticates via the aliased sender; the captured ticket calldata must execute.
    function test_arbitrum_l1Calldata_executesOnRealL2Adapter() public {
        ArbitrumL2Receiver l2Adapter = _deployArbitrumL2Receiver(connector);
        inbox.setSubmissionFee(0);

        vm.prank(connector);
        arbAdapter.sendMessage(arbAdapter.ARBITRUM_ONE_CHAIN_ID(), address(l2Adapter), slashPayload, 150_000);

        MockArbitrumInbox.TicketParams memory ticket = inbox.getLastTicket();
        assertEq(ticket.to, address(l2Adapter), "ticket target is the L2 adapter");

        // L2 delivery is from the aliased L1 connector.
        address aliased = l2Adapter.applyL1ToL2Alias(connector);
        vm.prank(aliased);
        (bool ok,) = address(l2Adapter).call(ticket.data);
        assertTrue(ok, "retryable-ticket calldata must execute on the L2 adapter (selector must match relayMessage)");

        assertEq(finalReceiver.calls(), 1, "final receiver invoked exactly once");
        assertEq(finalReceiver.lastSourceChainId(), SOURCE_CHAIN_ID, "source chain forwarded");
        assertEq(finalReceiver.lastSender(), connector, "authenticated L1 sender forwarded");
        assertEq(finalReceiver.lastPayload(), slashPayload, "raw slash payload forwarded intact");
    }

    /// @notice Negative control: the OLD (buggy) `receiveMessage` encoding does NOT execute on
    ///         the L2 adapter. Documents exactly why the unfixed slash path was dead.
    function test_base_oldReceiveMessageEncoding_revertsOnL2Adapter() public {
        BaseL2Receiver l2Adapter = _deployBaseL2Receiver(connector);
        bytes memory buggyCalldata =
            abi.encodeCall(ICrossChainReceiver.receiveMessage, (block.chainid, connector, slashPayload));

        baseMessenger.setXDomainMessageSender(connector);
        vm.prank(address(baseMessenger));
        (bool ok,) = address(l2Adapter).call(buggyCalldata);
        assertFalse(ok, "the old receiveMessage selector must NOT be callable on the L2 adapter");
    }

    // ══════════════════════════════════════════════════════════════════════════
    // LOW — Arbitrum refund must NOT default to msg.sender (whose L2 alias locks ETH).
    // ══════════════════════════════════════════════════════════════════════════

    /// @notice With no explicit sweep address, both refund slots default to the L2 `target`
    ///         (a recoverable, operator-controlled contract) — never the L1 connector.
    function test_arbitrum_refundDefaultsToTarget_notMsgSender() public {
        ArbitrumL2Receiver l2Adapter = _deployArbitrumL2Receiver(connector);
        inbox.setSubmissionFee(0);
        assertEq(arbAdapter.l2RefundAddress(), address(0), "no sweep address configured");

        vm.prank(connector);
        arbAdapter.sendMessage(arbAdapter.ARBITRUM_ONE_CHAIN_ID(), address(l2Adapter), slashPayload, 150_000);

        MockArbitrumInbox.TicketParams memory ticket = inbox.getLastTicket();
        assertEq(ticket.excessFeeRefundAddress, address(l2Adapter), "excess-fee refund -> L2 target, not connector");
        assertEq(ticket.callValueRefundAddress, address(l2Adapter), "call-value refund -> L2 target, not connector");
        assertTrue(ticket.excessFeeRefundAddress != connector, "refund must not be the fund-locking L1 connector alias");
    }

    /// @notice An explicit sweep address still overrides the default.
    function test_arbitrum_refundUsesConfiguredSweepAddress() public {
        ArbitrumL2Receiver l2Adapter = _deployArbitrumL2Receiver(connector);
        inbox.setSubmissionFee(0);
        address sweep = makeAddr("l2Treasury");
        arbAdapter.setL2RefundAddress(sweep);

        vm.prank(connector);
        arbAdapter.sendMessage(arbAdapter.ARBITRUM_ONE_CHAIN_ID(), address(l2Adapter), slashPayload, 150_000);

        MockArbitrumInbox.TicketParams memory ticket = inbox.getLastTicket();
        assertEq(ticket.excessFeeRefundAddress, sweep, "configured sweep wins for excess fee");
        assertEq(ticket.callValueRefundAddress, sweep, "configured sweep wins for call value");
    }

    // ══════════════════════════════════════════════════════════════════════════
    // LOW — Base effective gas limit must not silently truncate past uint32.
    // ══════════════════════════════════════════════════════════════════════════

    /// @notice An effective gas limit above type(uint32).max reverts instead of wrapping.
    function test_base_gasLimitAboveUint32_reverts() public {
        // Disable the 10% buffer so the requested value IS the effective value, then request
        // exactly 2**32 (one above uint32 max). Without the guard this would truncate to 0.
        baseAdapter.setGasBuffer(0);
        uint256 overflowing = uint256(type(uint32).max) + 1;

        // Cache BASE_CHAIN_ID() BEFORE the prank: evaluating it as a call argument consumes the
        // prank, so sendMessage would run as the test contract, not the authorized connector.
        uint256 baseChainId = baseAdapter.BASE_CHAIN_ID();
        vm.prank(connector);
        vm.expectRevert(
            abi.encodeWithSelector(BaseCrossChainMessenger.GasLimitTooHigh.selector, overflowing)
        );
        baseAdapter.sendMessage(baseChainId, makeAddr("anyTarget"), slashPayload, overflowing);
    }

    /// @notice The maximum in-range effective gas limit is accepted and forwarded un-truncated.
    function test_base_gasLimitAtUint32Max_isAccepted() public {
        baseAdapter.setGasBuffer(0);
        uint256 maxLimit = uint256(type(uint32).max);

        vm.prank(connector);
        baseAdapter.sendMessage(baseAdapter.BASE_CHAIN_ID(), makeAddr("anyTarget"), slashPayload, maxLimit);

        assertEq(uint256(baseMessenger.lastGasLimit()), maxLimit, "exact uint32 max forwarded without truncation");
    }
}
