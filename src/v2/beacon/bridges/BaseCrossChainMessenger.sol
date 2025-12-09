// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ICrossChainMessenger, ICrossChainReceiver} from "../interfaces/ICrossChainMessenger.sol";

/// @title BaseCrossChainMessenger
/// @notice ICrossChainMessenger implementation for Base L1→L2 messaging
/// @dev Uses Base's native CrossDomainMessenger
interface IBaseCrossDomainMessenger {
    function sendMessage(address _target, bytes calldata _message, uint32 _minGasLimit) external payable;
    function xDomainMessageSender() external view returns (address);
}

contract BaseCrossChainMessenger is ICrossChainMessenger {
    /// @notice Base L1 CrossDomainMessenger
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IBaseCrossDomainMessenger public immutable l1Messenger;

    /// @notice Base L2 chain ID
    uint256 public constant BASE_CHAIN_ID = 8453;
    uint256 public constant BASE_SEPOLIA_CHAIN_ID = 84532;

    constructor(address _l1Messenger) {
        l1Messenger = IBaseCrossDomainMessenger(_l1Messenger);
    }

    /// @inheritdoc ICrossChainMessenger
    function sendMessage(
        uint256 destinationChainId,
        address target,
        bytes calldata payload,
        uint256 gasLimit
    ) external payable returns (bytes32 messageId) {
        require(
            destinationChainId == BASE_CHAIN_ID || destinationChainId == BASE_SEPOLIA_CHAIN_ID,
            "Unsupported chain"
        );

        // Base native messaging
        // gasLimit fits into uint32 because bridge enforces < 2^32.
        // forge-lint: disable-next-line(unsafe-typecast)
        l1Messenger.sendMessage{value: msg.value}(
            target,
            abi.encodeCall(ICrossChainReceiver.receiveMessage, (block.chainid, msg.sender, payload)),
            // forge-lint: disable-next-line(unsafe-typecast)
            uint32(gasLimit)
        );

        // Generate message ID from params
        messageId = keccak256(abi.encode(block.chainid, target, payload, block.number));
    }

    /// @inheritdoc ICrossChainMessenger
    function estimateFee(
        uint256, // destinationChainId
        bytes calldata, // payload
        uint256 // gasLimit
    ) external pure returns (uint256 fee) {
        // Base native messaging is free (paid by sequencer)
        return 0;
    }

    /// @inheritdoc ICrossChainMessenger
    function isChainSupported(uint256 chainId) external pure returns (bool) {
        return chainId == BASE_CHAIN_ID || chainId == BASE_SEPOLIA_CHAIN_ID;
    }
}

/// @title BaseL2Receiver
/// @notice Adapter for receiving messages on Base L2
contract BaseL2Receiver {
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IBaseCrossDomainMessenger public immutable l2Messenger;
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable l1Sender;
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ICrossChainReceiver public immutable receiver;

    constructor(address _l2Messenger, address _l1Sender, address _receiver) {
        l2Messenger = IBaseCrossDomainMessenger(_l2Messenger);
        l1Sender = _l1Sender;
        receiver = ICrossChainReceiver(_receiver);
    }

    /// @notice Relay message from L1
    function relayMessage(bytes calldata payload) external {
        require(msg.sender == address(l2Messenger), "Only messenger");
        require(l2Messenger.xDomainMessageSender() == l1Sender, "Invalid sender");

        receiver.receiveMessage(1, l1Sender, payload); // chainId 1 = Ethereum mainnet
    }
}
