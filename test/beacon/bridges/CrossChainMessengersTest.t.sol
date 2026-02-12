// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, stdError } from "forge-std/Test.sol";

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
import {
    HyperlaneCrossChainMessenger,
    HyperlaneReceiver,
    IHyperlaneMailbox,
    IInterchainGasPaymaster
} from "../../../src/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {
    LayerZeroCrossChainMessenger,
    LayerZeroReceiver,
    ILayerZeroEndpointV2,
    Origin
} from "../../../src/beacon/bridges/LayerZeroCrossChainMessenger.sol";
import { ICrossChainReceiver } from "../../../src/beacon/interfaces/ICrossChainMessenger.sol";

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

    contract MockHyperlaneMailbox is IHyperlaneMailbox {
        uint256 public quoteFee;
        uint32 public lastDestinationDomain;
        bytes32 public lastRecipient;
        bytes public lastMessageBody;
        uint256 public lastDispatchValue;
        bytes32 public nextMessageId = bytes32(uint256(1));

        function setQuoteFee(uint256 fee) external {
            quoteFee = fee;
        }

        function setNextMessageId(bytes32 newId) external {
            nextMessageId = newId;
        }

        function dispatch(
            uint32 destinationDomain,
            bytes32 recipientAddress,
            bytes calldata messageBody
        )
            external
            payable
            override
            returns (bytes32 messageId)
        {
            lastDestinationDomain = destinationDomain;
            lastRecipient = recipientAddress;
            lastMessageBody = messageBody;
            lastDispatchValue = msg.value;
            return nextMessageId;
        }

        function quoteDispatch(uint32, bytes32, bytes calldata) external view override returns (uint256 fee) {
            return quoteFee;
        }

        function localDomain() external pure override returns (uint32) {
            return 0;
        }
    }

    contract MockInterchainGasPaymaster is IInterchainGasPaymaster {
        uint256 public quoteFee;

        struct Payment {
            bytes32 messageId;
            uint32 destinationDomain;
            uint256 gasAmount;
            address refundAddress;
            uint256 value;
        }

        Payment public lastPayment;

        function getLastPayment() external view returns (Payment memory) {
            return lastPayment;
        }

        function setQuoteFee(uint256 fee) external {
            quoteFee = fee;
        }

        function payForGas(
            bytes32 messageId,
            uint32 destinationDomain,
            uint256 gasAmount,
            address refundAddress
        )
            external
            payable
            override
        {
            lastPayment = Payment({
                messageId: messageId,
                destinationDomain: destinationDomain,
                gasAmount: gasAmount,
                refundAddress: refundAddress,
                value: msg.value
            });
        }

        function quoteGasPayment(uint32, uint256) external view override returns (uint256) {
            return quoteFee;
        }
    }

    contract MockLayerZeroEndpoint is ILayerZeroEndpointV2 {
        MessagingParams internal _lastParams;
        address public lastRefundAddress;
        uint256 public lastValue;
        MessagingFee internal _quoteFee;
        bytes32 public nextGuid = bytes32(uint256(123));
        uint64 public nonce;

        function lastParams() external view returns (MessagingParams memory) {
            return _lastParams;
        }

        function storedQuoteFee() external view returns (MessagingFee memory) {
            return _quoteFee;
        }

        function setQuoteFee(uint256 nativeFee) external {
            _quoteFee = MessagingFee({ nativeFee: nativeFee, lzTokenFee: 0 });
        }

        function setNextGuid(bytes32 guid) external {
            nextGuid = guid;
        }

        function send(
            MessagingParams calldata params,
            address refundAddress
        )
            external
            payable
            override
            returns (MessagingReceipt memory receipt)
        {
            _lastParams = params;
            lastRefundAddress = refundAddress;
            lastValue = msg.value;
            nonce += 1;
            receipt = MessagingReceipt({
                guid: nextGuid, nonce: nonce, fee: MessagingFee({ nativeFee: msg.value, lzTokenFee: 0 })
            });
        }

        function quote(MessagingParams calldata, address) external view override returns (MessagingFee memory fee) {
            return _quoteFee;
        }

        function setDelegate(address) external override { }
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

            vm.prank(sender);
            bytes32 messageId = messenger.sendMessage{ value: 0.2 ether }(42_161, target, payload, 500_000);

            bytes memory expectedData =
                abi.encodeCall(ICrossChainReceiver.receiveMessage, (block.chainid, sender, payload));
            MockArbitrumInbox.TicketParams memory ticket = inbox.getLastTicket();
            assertEq(ticket.to, target, "target");
            assertEq(ticket.maxSubmissionCost, 0.01 ether, "submission");
            assertEq(ticket.excessFeeRefundAddress, sender, "fee refund");
            assertEq(ticket.callValueRefundAddress, sender, "call refund");
            // M-12 FIX: Gas limit includes 10% buffer, so 500_000 * 1.1 = 550_000
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
            // M-12 FIX: Gas limit includes 10% buffer, so 100_000 * 1.1 = 110_000
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
            ArbitrumL2Receiver l2Receiver = new ArbitrumL2Receiver(l1Sender, address(receiver));

            bytes memory data = abi.encode("hello");
            address aliased = l2Receiver.applyL1ToL2Alias(l1Sender);

            vm.prank(aliased);
            l2Receiver.relayMessage(data);

            assertEq(receiver.lastSourceChainId(), 1);
            assertEq(receiver.lastSender(), l1Sender);
            assertEq(receiver.lastPayload(), data);
        }

        function test_arbitrumL2Receiver_RevertWhenSenderIsNotAliased() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            address l1Sender = makeAddr("l1Sender");
            ArbitrumL2Receiver l2Receiver = new ArbitrumL2Receiver(l1Sender, address(receiver));

            vm.expectRevert("Invalid sender");
            l2Receiver.relayMessage("bad");
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
            vm.prank(sender);
            bytes32 messageId = messenger.sendMessage{ value: 0.5 ether }(8453, target, payload, 120_000);

            bytes memory expectedData =
                abi.encodeCall(ICrossChainReceiver.receiveMessage, (block.chainid, sender, payload));
            assertEq(baseMessenger.lastTarget(), target);
            assertEq(baseMessenger.lastMessage(), expectedData);
            // M-12 FIX: Gas limit includes 10% buffer, so 120_000 * 1.1 = 132_000
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
            BaseL2Receiver l2Receiver = new BaseL2Receiver(address(baseMessenger), address(this), address(receiver));
            bytes memory message = abi.encode("data");

            baseMessenger.setXDomainMessageSender(address(this));
            vm.prank(address(baseMessenger));
            l2Receiver.relayMessage(message);

            assertEq(receiver.lastSourceChainId(), 1);
            assertEq(receiver.lastSender(), address(this));
            assertEq(receiver.lastPayload(), message);
        }

        function test_relayMessage_RevertWhenMessengerMismatch() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            BaseL2Receiver l2Receiver = new BaseL2Receiver(address(baseMessenger), address(this), address(receiver));
            bytes memory message = abi.encode("data");

            vm.expectRevert("Only messenger");
            l2Receiver.relayMessage(message);
        }

        function test_relayMessage_RevertWhenSenderMismatch() public {
            MockCrossChainReceiver receiver = new MockCrossChainReceiver();
            BaseL2Receiver l2Receiver = new BaseL2Receiver(address(baseMessenger), address(this), address(receiver));
            bytes memory message = abi.encode("data");

            baseMessenger.setXDomainMessageSender(makeAddr("other"));
            vm.prank(address(baseMessenger));
            vm.expectRevert("Invalid sender");
            l2Receiver.relayMessage(message);
        }
    }

    contract HyperlaneCrossChainMessengerTest is Test {
        MockHyperlaneMailbox internal mailbox;
        MockInterchainGasPaymaster internal igp;
        HyperlaneCrossChainMessenger internal messenger;
        address internal sender = makeAddr("sender");
        address internal target = makeAddr("target");

        function setUp() public {
            mailbox = new MockHyperlaneMailbox();
            igp = new MockInterchainGasPaymaster();
            messenger = new HyperlaneCrossChainMessenger(address(mailbox), address(igp));
        }

        function test_sendMessage_PaysDispatchAndGas() public {
            mailbox.setQuoteFee(0.05 ether);
            igp.setQuoteFee(0.01 ether);
            bytes memory payload = abi.encode("hyperlane");

            vm.deal(sender, 1 ether);
            uint256 balanceBefore = sender.balance;
            vm.prank(sender);
            bytes32 messageId = messenger.sendMessage{ value: 0.2 ether }(42_161, target, payload, 150_000);

            bytes memory expectedBody = abi.encode(block.chainid, sender, payload);
            assertEq(mailbox.lastDestinationDomain(), 42_161);
            assertEq(mailbox.lastRecipient(), bytes32(uint256(uint160(target))));
            assertEq(mailbox.lastMessageBody(), expectedBody);
            assertEq(mailbox.lastDispatchValue(), 0.05 ether);

            MockInterchainGasPaymaster.Payment memory payment = igp.getLastPayment();
            assertEq(payment.messageId, messageId);
            assertEq(payment.destinationDomain, 42_161);
            // M-12 FIX: Gas limit includes 10% buffer, so 150_000 * 1.1 = 165_000
            assertEq(payment.gasAmount, 165_000);
            assertEq(payment.refundAddress, sender);
            assertEq(payment.value, 0.01 ether);
            assertEq(sender.balance, balanceBefore - 0.06 ether);
        }

        function test_sendMessage_RevertWhenDispatchUnderfunded() public {
            mailbox.setQuoteFee(0.05 ether);
            bytes memory payload = abi.encode("hyperlane");

            vm.deal(sender, 0.04 ether);
            vm.prank(sender);
            vm.expectRevert(
                abi.encodeWithSelector(
                    HyperlaneCrossChainMessenger.InsufficientMsgValue.selector, 0.05 ether, 0.04 ether
                )
            );
            messenger.sendMessage{ value: 0.04 ether }(42_161, target, payload, 0);
        }

        function test_sendMessage_RevertWhenGasPaymentUnderfunded() public {
            mailbox.setQuoteFee(0.02 ether);
            igp.setQuoteFee(0.01 ether);
            bytes memory payload = abi.encode("hyperlane");

            vm.deal(sender, 0.025 ether);
            vm.prank(sender);
            vm.expectRevert(
                abi.encodeWithSelector(
                    HyperlaneCrossChainMessenger.InsufficientMsgValue.selector, 0.03 ether, 0.025 ether
                )
            );
            messenger.sendMessage{ value: 0.025 ether }(42_161, target, payload, 100_000);
        }

        function test_sendMessage_RefundsExcessValue() public {
            mailbox.setQuoteFee(0.01 ether);
            igp.setQuoteFee(0.02 ether);
            bytes memory payload = abi.encode("hyperlane");

            vm.deal(sender, 0.05 ether);
            uint256 balanceBefore = sender.balance;

            vm.prank(sender);
            messenger.sendMessage{ value: 0.05 ether }(42_161, target, payload, 120_000);

            uint256 required = 0.03 ether;
            assertEq(sender.balance, balanceBefore - required);
            assertEq(mailbox.lastDispatchValue(), 0.01 ether);
            assertEq(igp.getLastPayment().value, 0.02 ether);
        }

        function test_sendMessage_DoesNotPayGasWhenInsufficientValue() public {
            mailbox.setQuoteFee(0.05 ether);
            igp.setQuoteFee(0.01 ether);
            bytes memory payload = abi.encode("hyperlane");

            messenger.setIgp(address(igp));
            vm.deal(sender, 0.05 ether);
            vm.prank(sender);
            vm.expectRevert(
                abi.encodeWithSelector(
                    HyperlaneCrossChainMessenger.InsufficientMsgValue.selector, 0.06 ether, 0.05 ether
                )
            );
            messenger.sendMessage{ value: 0.05 ether }(8453, target, payload, 200_000);
        }

        function test_sendMessage_RevertUnsupportedChain() public {
            vm.expectRevert("Unsupported chain");
            messenger.sendMessage(999, target, bytes(""), 0);
        }

        function test_estimateFee_UsesDispatchAndIgpQuotes() public {
            mailbox.setQuoteFee(0.01 ether);
            igp.setQuoteFee(0.005 ether);

            uint256 fee = messenger.estimateFee(42_161, bytes(""), 100_000);
            assertEq(fee, 0.015 ether);
        }

        function test_estimateFee_ReturnsZeroForUnknownChain() public {
            uint256 fee = messenger.estimateFee(999, bytes(""), 1);
            assertEq(fee, 0);
        }

        function test_setDomainMappingOnlyOwner() public {
            messenger.setDomainMapping(100, 1000);
            assertTrue(messenger.isChainSupported(100));

            vm.expectRevert("Only owner");
            vm.prank(makeAddr("intruder"));
            messenger.setDomainMapping(200, 2000);
        }

        function test_setIgpOnlyOwner() public {
            address newIgp = makeAddr("igp");
            messenger.setIgp(newIgp);
            assertEq(address(messenger.igp()), newIgp);

            vm.expectRevert("Only owner");
            vm.prank(makeAddr("intruder"));
            messenger.setIgp(address(0));
        }

        function test_sendMessage_RevertsWhenDispatchFeeNotFunded() public {
            mailbox.setQuoteFee(0.05 ether);

            vm.prank(sender);
            vm.expectRevert();
            messenger.sendMessage(42_161, target, bytes("insufficient"), 50_000);
        }

        function test_sendMessage_SucceedsWhenIgpUnset() public {
            mailbox.setQuoteFee(0.02 ether);
            messenger.setIgp(address(0));

            vm.deal(sender, 0.02 ether);
            vm.prank(sender);
            messenger.sendMessage{ value: 0.02 ether }(42_161, target, bytes("skip igp"), 60_000);

            MockInterchainGasPaymaster.Payment memory payment = igp.getLastPayment();
            assertEq(payment.value, 0, "IGP should not receive payment when unset");
        }

        function test_estimateFee_RevertsOnOverflowingGasQuote() public {
            mailbox.setQuoteFee(1);
            igp.setQuoteFee(type(uint256).max);

            vm.expectRevert(stdError.arithmeticError);
            messenger.estimateFee(42_161, bytes("overflow"), 1);
        }
    }

    contract LayerZeroCrossChainMessengerTest is Test {
        MockLayerZeroEndpoint internal endpoint;
        LayerZeroCrossChainMessenger internal messenger;
        address internal sender = makeAddr("sender");
        address internal target = makeAddr("target");

        function setUp() public {
            endpoint = new MockLayerZeroEndpoint();
            endpoint.setQuoteFee(0.02 ether);
            messenger = new LayerZeroCrossChainMessenger(address(endpoint));
        }

        function test_sendMessage_UsesEndpoint() public {
            bytes memory payload = abi.encode("lz");
            vm.deal(sender, 1 ether);

            vm.prank(sender);
            bytes32 guid = messenger.sendMessage{ value: 0.05 ether }(42_161, target, payload, 250_000);

            bytes memory expected = abi.encode(block.chainid, sender, payload);
            ILayerZeroEndpointV2.MessagingParams memory params = endpoint.lastParams();
            assertEq(params.dstEid, 30_110);
            assertEq(params.receiver, bytes32(uint256(uint160(target))));
            assertEq(params.message, expected);
            assertEq(params.options.length, 37); // TYPE_3 header + executor option
            assertEq(endpoint.lastRefundAddress(), sender);
            assertEq(endpoint.lastValue(), 0.05 ether);
            assertEq(guid, bytes32(uint256(123)));
        }

        function test_sendMessage_RevertUnsupportedChain() public {
            vm.expectRevert("Unsupported chain");
            messenger.sendMessage(555, target, bytes(""), 100);
        }

        function test_estimateFee_UsesEndpointQuote() public {
            uint256 fee = messenger.estimateFee(42_161, bytes(""), 1);
            assertEq(fee, endpoint.storedQuoteFee().nativeFee);
        }

        function test_onlyOwnerMayUpdateMappings() public {
            messenger.setChainMapping(9000, 9001);
            vm.expectRevert("Only owner");
            vm.prank(makeAddr("intruder"));
            messenger.setChainMapping(9001, 9002);
        }

        function test_onlyOwnerMaySetPeer() public {
            messenger.setPeer(30_110, address(this));
            assertEq(messenger.peers(30_110), bytes32(uint256(uint160(address(this)))));

            vm.expectRevert("Only owner");
            vm.prank(makeAddr("intruder"));
            messenger.setPeer(1, address(0));
        }
    }

    contract LayerZeroReceiverTest is Test {
        MockCrossChainReceiver internal receiver;
        LayerZeroReceiver internal lzReceiver;
        address internal endpoint = makeAddr("endpoint");
        address internal peer = makeAddr("peer");
        address internal originalSender = makeAddr("origin");

        function setUp() public {
            receiver = new MockCrossChainReceiver();
            lzReceiver = new LayerZeroReceiver(endpoint, address(receiver));
        }

        function test_lzReceive_ForwardsMessagesFromTrustedPeer() public {
            uint32 eid = 30_110;
            lzReceiver.setPeer(eid, bytes32(uint256(uint160(peer))));

            Origin memory origin = Origin({ srcEid: eid, sender: bytes32(uint256(uint160(peer))), nonce: 1 });
            bytes memory payload = abi.encode(uint256(42_161), originalSender, bytes("lz"));

            vm.prank(endpoint);
            lzReceiver.lzReceive(origin, bytes32(0), payload, address(0), bytes(""));

            assertEq(receiver.lastSourceChainId(), 42_161);
            assertEq(receiver.lastSender(), originalSender);
            assertEq(receiver.lastPayload(), bytes("lz"));
        }

        function test_lzReceive_RevertWhenEndpointMismatch() public {
            Origin memory origin = Origin({ srcEid: 30_110, sender: bytes32(uint256(1)), nonce: 0 });

            vm.expectRevert("Only endpoint");
            lzReceiver.lzReceive(origin, bytes32(0), bytes(""), address(0), bytes(""));
        }

        function test_lzReceive_RevertWhenPeerUntrusted() public {
            Origin memory origin = Origin({ srcEid: 30_110, sender: bytes32(uint256(1)), nonce: 0 });
            vm.prank(endpoint);
            vm.expectRevert("Untrusted peer");
            lzReceiver.lzReceive(origin, bytes32(0), bytes(""), address(0), bytes(""));
        }

        function test_setPeerRequiresOwner() public {
            vm.prank(makeAddr("intruder"));
            vm.expectRevert("Only owner");
            lzReceiver.setPeer(1, bytes32(uint256(1)));
        }

        function test_transferOwnership() public {
            address newOwner = makeAddr("newOwner");
            lzReceiver.transferOwnership(newOwner);

            vm.expectRevert("Only owner");
            lzReceiver.setPeer(1, bytes32(uint256(1)));

            vm.prank(newOwner);
            lzReceiver.setPeer(1, bytes32(uint256(1)));
        }
    }

    contract HyperlaneReceiverTest is Test {
        MockCrossChainReceiver internal receiver;
        HyperlaneReceiver internal hyperlaneReceiver;
        address internal mailbox = makeAddr("mailbox");
        address internal trustedSender = makeAddr("trustedSender");

        function setUp() public {
            receiver = new MockCrossChainReceiver();
            hyperlaneReceiver = new HyperlaneReceiver(mailbox, address(receiver));
        }

        function test_handle_ForwardsTrustedMessage() public {
            uint32 domain = 42_161;
            hyperlaneReceiver.setTrustedSender(domain, trustedSender, true);
            bytes memory payload = abi.encode(uint256(42_161), trustedSender, bytes("hl"));

            vm.prank(mailbox);
            hyperlaneReceiver.handle(domain, bytes32(uint256(uint160(trustedSender))), payload);

            assertEq(receiver.lastSourceChainId(), 42_161);
            assertEq(receiver.lastSender(), trustedSender);
            assertEq(receiver.lastPayload(), bytes("hl"));
        }

        function test_handle_RevertsWhenCallerNotMailbox() public {
            vm.expectRevert("Only mailbox");
            hyperlaneReceiver.handle(42_161, bytes32(uint256(1)), bytes("bad"));
        }

        function test_handle_RevertsWhenSenderNotTrusted() public {
            vm.prank(mailbox);
            vm.expectRevert("Untrusted sender");
            hyperlaneReceiver.handle(42_161, bytes32(uint256(1)), bytes("bad"));
        }

        function test_handle_RevertsWhenChainMismatch() public {
            uint32 domain = 8453;
            hyperlaneReceiver.setTrustedSender(domain, trustedSender, true);
            bytes memory payload = abi.encode(uint256(999), trustedSender, bytes("bad"));

            vm.prank(mailbox);
            vm.expectRevert("Chain mismatch");
            hyperlaneReceiver.handle(domain, bytes32(uint256(uint160(trustedSender))), payload);
        }

        function test_handle_RevertsAfterSenderRevoked() public {
            uint32 domain = 42_161;
            hyperlaneReceiver.setTrustedSender(domain, trustedSender, true);
            hyperlaneReceiver.setTrustedSender(domain, trustedSender, false);
            bytes memory payload = abi.encode(uint256(42_161), trustedSender, bytes("revoked"));

            vm.prank(mailbox);
            vm.expectRevert("Untrusted sender");
            hyperlaneReceiver.handle(domain, bytes32(uint256(uint160(trustedSender))), payload);
        }

        function test_handle_UsesUpdatedDomainMapping() public {
            uint32 domain = 9999;
            hyperlaneReceiver.setDomainMapping(domain, 5555);
            hyperlaneReceiver.setTrustedSender(domain, trustedSender, true);
            bytes memory payload = abi.encode(uint256(5555), trustedSender, bytes("ok"));

            vm.prank(mailbox);
            hyperlaneReceiver.handle(domain, bytes32(uint256(uint160(trustedSender))), payload);

            assertEq(receiver.lastSourceChainId(), 5555);
        }

        function test_setTrustedSender_OnlyOwner() public {
            vm.prank(makeAddr("intruder"));
            vm.expectRevert("Only owner");
            hyperlaneReceiver.setTrustedSender(1, trustedSender, true);
        }

        function test_setDomainMapping_OnlyOwner() public {
            vm.prank(makeAddr("intruder"));
            vm.expectRevert("Only owner");
            hyperlaneReceiver.setDomainMapping(777, 888);
        }

        function test_transferOwnership_AllowsNewOwnerToManageSenders() public {
            address newOwner = makeAddr("newOwner");
            hyperlaneReceiver.transferOwnership(newOwner);

            vm.expectRevert("Only owner");
            hyperlaneReceiver.setTrustedSender(1, trustedSender, true);

            vm.prank(newOwner);
            hyperlaneReceiver.setTrustedSender(1, trustedSender, true);
        }
    }
