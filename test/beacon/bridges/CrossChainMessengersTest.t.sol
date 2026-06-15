// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, stdError } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

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

/// @notice Helpers to deploy the now-UUPS bridge receivers behind an
///         ERC1967 proxy with the test contract as the initial owner. C-3.
library BridgeReceiverDeploy {
    function deployArbitrumL2Receiver(
        address l1Sender,
        address receiver,
        uint256 sourceChainId
    )
        internal
        returns (ArbitrumL2Receiver)
    {
        ArbitrumL2Receiver impl = new ArbitrumL2Receiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(ArbitrumL2Receiver.initialize, (l1Sender, receiver, sourceChainId, address(this)))
        );
        return ArbitrumL2Receiver(address(proxy));
    }

    function deployBaseL2Receiver(
        address l2Messenger,
        address l1Sender,
        address receiver,
        uint256 sourceChainId
    )
        internal
        returns (BaseL2Receiver)
    {
        BaseL2Receiver impl = new BaseL2Receiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(BaseL2Receiver.initialize, (l2Messenger, l1Sender, receiver, sourceChainId, address(this)))
        );
        return BaseL2Receiver(address(proxy));
    }
}

contract MockCrossChainReceiver is ICrossChainReceiver {
    uint256 public lastSourceChainId;
    address public lastSender;
    bytes public lastPayload;

    function receiveMessage(uint256 sourceChainId, address sender, bytes calldata payload) external override {
        lastSourceChainId = sourceChainId;
        lastSender = sender;
        lastPayload = payload;
    }
}

uint256 constant SOURCE_CHAIN_ID = 11_155_111;

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
    uint256 public lastValue;
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
        lastValue = msg.value;
        ticketId += 1;
        return ticketId;
    }

    function calculateRetryableSubmissionFee(uint256, uint256) external view override returns (uint256) {
        return submissionFee;
    }
}

contract MockBaseMessenger is IBaseCrossDomainMessenger {
    address public override xDomainMessageSender;
    address public lastTarget;
    bytes public lastMessage;
    uint32 public lastGasLimit;
    uint256 public lastValue;

    function sendMessage(address target, bytes calldata message, uint32 minGasLimit) external payable override {
        lastTarget = target;
        lastMessage = message;
        lastGasLimit = minGasLimit;
        lastValue = msg.value;
    }

    function setXDomainMessageSender(address sender) external {
        xDomainMessageSender = sender;
    }
}

    contract ArbitrumCrossChainMessengerTest is Test {
        MockArbitrumInbox internal inbox;
        ArbitrumCrossChainMessenger internal messenger;
        address internal target = makeAddr("target");
        address internal sender = makeAddr("sender");
        bytes internal payload = abi.encode("payload");

        function setUp() public {
            inbox = new MockArbitrumInbox();
            messenger = new ArbitrumCrossChainMessenger(address(inbox));
        }

        function test_sendMessage_CreatesRetryableTicket() public {
            inbox.setSubmissionFee(0.01 ether);
            vm.deal(sender, 1 ether);

            // sendMessage is restricted to authorized relayers (the connector). The test
            // contract is the adapter owner, so authorize `sender` for the legit flow.
            messenger.setAuthorizedSender(sender, true);
            vm.prank(sender);
            bytes32 messageId = messenger.sendMessage{ value: 0.2 ether }(42_161, target, payload, 500_000);

            // The L1 adapter now forwards ONLY the raw payload, encoded as the paired
            // L2 adapter's `relayMessage(bytes)` selector (the L2 adapter re-derives the
            // source chain + authenticated sender from its own storage). The old
            // `receiveMessage(chainId,sender,payload)` encoding would let the L2 trust an
            // L1-supplied `sender`, which is exactly the forgeable path that was closed.
            bytes memory expectedData = abi.encodeWithSignature("relayMessage(bytes)", payload);
            MockArbitrumInbox.TicketParams memory ticket = inbox.getLastTicket();
            assertEq(ticket.to, target, "target");
            assertEq(ticket.maxSubmissionCost, 0.01 ether, "submission");
            // With no explicit L2 sweep address configured, refunds default to the L2
            // `target` adapter — NEVER `sender` (the L1 connector's L2 alias is an address
            // nobody controls, so refunding there would permanently lock the ETH).
            assertEq(ticket.excessFeeRefundAddress, target, "fee refund");
            assertEq(ticket.callValueRefundAddress, target, "call refund");
            // Gas limit includes 10% buffer, so 500_000 * 1.1 = 550_000
            assertEq(ticket.gasLimit, 550_000, "gasLimit");
            assertEq(ticket.data, expectedData, "payload");
            assertEq(inbox.lastValue(), 0.2 ether, "msg.value");
            assertEq(messageId, bytes32(uint256(1)));
        }

        function test_sendMessage_RevertUnsupportedChain() public {
            vm.expectRevert("Unsupported chain");
            messenger.sendMessage(999, target, payload, 100);
        }

        function test_estimateFee_UsesSubmissionCostAndGasLimit() public {
            inbox.setSubmissionFee(0.01 ether);
            uint256 fee = messenger.estimateFee(42_161, payload, 100_000);
            // Gas limit includes 10% buffer, so 100_000 * 1.1 = 110_000
            assertEq(fee, 0.01 ether + 110_000 * messenger.l2MaxFeePerGas());
        }

        function test_onlyOwnerCanAdjustGasPrice() public {
            vm.expectRevert("Only owner");
            vm.prank(makeAddr("intruder"));
            messenger.setL2MaxFeePerGas(1 gwei);

            messenger.setL2MaxFeePerGas(2 gwei);
            assertEq(messenger.l2MaxFeePerGas(), 2 gwei);
        }

        function test_transferOwnership_AllowsNewOwnerToUpdateGasPrice() public {
            address newOwner = makeAddr("newOwner");
            messenger.transferOwnership(newOwner);

            vm.expectRevert("Only owner");
            messenger.setL2MaxFeePerGas(3 gwei);

            vm.prank(newOwner);
            messenger.setL2MaxFeePerGas(3 gwei);
            assertEq(messenger.l2MaxFeePerGas(), 3 gwei);
        }

        function test_arbitrumL2Receiver_RelaysFromAliasedSender() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            address l1Sender = makeAddr("l1Sender");
            ArbitrumL2Receiver l2Receiver =
                BridgeReceiverDeploy.deployArbitrumL2Receiver(l1Sender, address(receiver), SOURCE_CHAIN_ID);

            bytes memory data = abi.encode("hello");
            address aliased = l2Receiver.applyL1ToL2Alias(l1Sender);

            vm.prank(aliased);
            l2Receiver.relayMessage(data);

            assertEq(receiver.lastSourceChainId(), SOURCE_CHAIN_ID);
            assertEq(receiver.lastSender(), l1Sender);
            assertEq(receiver.lastPayload(), data);
        }

        function test_arbitrumL2Receiver_RevertWhenSenderIsNotAliased() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            address l1Sender = makeAddr("l1Sender");
            ArbitrumL2Receiver l2Receiver =
                BridgeReceiverDeploy.deployArbitrumL2Receiver(l1Sender, address(receiver), SOURCE_CHAIN_ID);

            vm.expectRevert("Invalid sender");
            l2Receiver.relayMessage("bad");
        }

        function test_arbitrumL2Receiver_RevertOnDuplicatePayload() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            address l1Sender = makeAddr("l1Sender");
            ArbitrumL2Receiver l2Receiver =
                BridgeReceiverDeploy.deployArbitrumL2Receiver(l1Sender, address(receiver), SOURCE_CHAIN_ID);

            bytes memory data = abi.encode("hello");
            address aliased = l2Receiver.applyL1ToL2Alias(l1Sender);

            vm.prank(aliased);
            l2Receiver.relayMessage(data);

            bytes32 messageId = keccak256(abi.encode(block.chainid, l1Sender, data));
            assertTrue(l2Receiver.isMessageProcessed(messageId));

            vm.prank(aliased);
            vm.expectRevert(abi.encodeWithSelector(ArbitrumL2Receiver.MessageAlreadyProcessed.selector, messageId));
            l2Receiver.relayMessage(data);
        }
    }

    contract BaseCrossChainMessengerTest is Test {
        MockBaseMessenger internal baseMessenger;
        BaseCrossChainMessenger internal messenger;
        address internal target = makeAddr("target");
        address internal sender = makeAddr("sender");
        bytes internal payload = abi.encode("payload");

        function setUp() public {
            baseMessenger = new MockBaseMessenger();
            messenger = new BaseCrossChainMessenger(address(baseMessenger));
        }

        function test_sendMessage_ForwardsToBaseMessenger() public {
            vm.deal(sender, 1 ether);
            // sendMessage is restricted to authorized relayers (the connector). The test
            // contract is the adapter owner, so authorize `sender` for the legit flow.
            messenger.setAuthorizedSender(sender, true);
            vm.prank(sender);
            bytes32 messageId = messenger.sendMessage{ value: 0.5 ether }(8453, target, payload, 120_000);

            // Adapter forwards only the raw payload under the L2 `relayMessage(bytes)`
            // selector; the L2 adapter authenticates the L1 origin itself rather than
            // trusting an L1-supplied sender (the closed forgeable-slash path).
            bytes memory expectedData = abi.encodeWithSignature("relayMessage(bytes)", payload);
            assertEq(baseMessenger.lastTarget(), target);
            assertEq(baseMessenger.lastMessage(), expectedData);
            // Gas limit includes 10% buffer, so 120_000 * 1.1 = 132_000
            assertEq(baseMessenger.lastGasLimit(), 132_000);
            assertEq(baseMessenger.lastValue(), 0.5 ether);
            assertTrue(messageId != bytes32(0));
        }

        function test_sendMessage_RevertUnsupportedChain() public {
            vm.expectRevert("Unsupported chain");
            messenger.sendMessage(1, target, payload, 100);
        }

        function test_relayMessage_ValidatesMessengerAndSender() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            BaseL2Receiver l2Receiver = BridgeReceiverDeploy.deployBaseL2Receiver(
                address(baseMessenger), address(this), address(receiver), SOURCE_CHAIN_ID
            );
            bytes memory message = abi.encode("data");

            baseMessenger.setXDomainMessageSender(address(this));
            vm.prank(address(baseMessenger));
            l2Receiver.relayMessage(message);

            assertEq(receiver.lastSourceChainId(), SOURCE_CHAIN_ID);
            assertEq(receiver.lastSender(), address(this));
            assertEq(receiver.lastPayload(), message);
        }

        function test_relayMessage_RevertWhenMessengerMismatch() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            BaseL2Receiver l2Receiver = BridgeReceiverDeploy.deployBaseL2Receiver(
                address(baseMessenger), address(this), address(receiver), SOURCE_CHAIN_ID
            );
            bytes memory message = abi.encode("data");

            vm.expectRevert("Only messenger");
            l2Receiver.relayMessage(message);
        }

        function test_relayMessage_RevertWhenSenderMismatch() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            BaseL2Receiver l2Receiver = BridgeReceiverDeploy.deployBaseL2Receiver(
                address(baseMessenger), address(this), address(receiver), SOURCE_CHAIN_ID
            );
            bytes memory message = abi.encode("data");

            baseMessenger.setXDomainMessageSender(makeAddr("other"));
            vm.prank(address(baseMessenger));
            vm.expectRevert("Invalid sender");
            l2Receiver.relayMessage(message);
        }

        function test_relayMessage_RevertOnDuplicatePayload() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            BaseL2Receiver l2Receiver = BridgeReceiverDeploy.deployBaseL2Receiver(
                address(baseMessenger), address(this), address(receiver), SOURCE_CHAIN_ID
            );
            bytes memory message = abi.encode("data");

            baseMessenger.setXDomainMessageSender(address(this));
            vm.prank(address(baseMessenger));
            l2Receiver.relayMessage(message);

            bytes32 messageId = keccak256(abi.encode(block.chainid, address(this), message));
            assertTrue(l2Receiver.isMessageProcessed(messageId));

            vm.prank(address(baseMessenger));
            vm.expectRevert(abi.encodeWithSelector(BaseL2Receiver.MessageAlreadyProcessed.selector, messageId));
            l2Receiver.relayMessage(message);
        }
    }
