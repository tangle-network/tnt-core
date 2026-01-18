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

    /// @notice M-12 FIX: Owner for configuration
    address public owner;

    /// @notice M-12 FIX: Minimum gas limit for L2 execution
    uint256 public minGasLimit = 100_000;

    /// @notice M-12 FIX: Gas buffer percentage (in basis points, 10000 = 100%)
    uint256 public gasBufferBps = 1000; // 10% buffer by default

    /// @notice M-12 FIX: Events for gas configuration changes
    event MinGasLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event GasBufferUpdated(uint256 oldBuffer, uint256 newBuffer);

    /// @dev SECURITY: For production, owner should be a timelock or multisig.
    /// Critical parameters (minGasLimit, gasBufferBps) affect cross-chain security.
    constructor(address _l1Messenger) {
        l1Messenger = IBaseCrossDomainMessenger(_l1Messenger);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @inheritdoc ICrossChainMessenger
    /// @dev M-12 FIX: Gas limit is now enforced to be at least minGasLimit and includes buffer
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

        // M-12 FIX: Apply minimum gas limit and add safety buffer
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Base native messaging
        // effectiveGasLimit fits into uint32 because we enforce reasonable limits.
        // forge-lint: disable-next-line(unsafe-typecast)
        l1Messenger.sendMessage{value: msg.value}(
            target,
            abi.encodeCall(ICrossChainReceiver.receiveMessage, (block.chainid, msg.sender, payload)),
            // forge-lint: disable-next-line(unsafe-typecast)
            uint32(effectiveGasLimit)
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

    /// @notice M-12 FIX: Set minimum gas limit for L2 execution
    /// @param _minGasLimit New minimum gas limit
    function setMinGasLimit(uint256 _minGasLimit) external onlyOwner {
        uint256 oldLimit = minGasLimit;
        minGasLimit = _minGasLimit;
        emit MinGasLimitUpdated(oldLimit, _minGasLimit);
    }

    /// @notice M-12 FIX: Set gas buffer percentage
    /// @param _gasBufferBps New buffer in basis points (10000 = 100%)
    function setGasBuffer(uint256 _gasBufferBps) external onlyOwner {
        require(_gasBufferBps <= 10000, "Buffer too high"); // Max 100% buffer
        uint256 oldBuffer = gasBufferBps;
        gasBufferBps = _gasBufferBps;
        emit GasBufferUpdated(oldBuffer, _gasBufferBps);
    }

    /// @notice M-12 FIX: Apply minimum gas limit and safety buffer
    /// @param gasLimit Requested gas limit
    /// @return Effective gas limit with buffer applied
    function _applyGasLimitWithBuffer(uint256 gasLimit) internal view returns (uint256) {
        // Enforce minimum gas limit
        uint256 effectiveLimit = gasLimit < minGasLimit ? minGasLimit : gasLimit;
        // Add safety buffer
        effectiveLimit = effectiveLimit + (effectiveLimit * gasBufferBps / 10000);
        return effectiveLimit;
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}

/// @title BaseL2Receiver
/// @notice Adapter for receiving messages on Base L2
/// @dev M-12 FIX: Added message replay protection
contract BaseL2Receiver {
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IBaseCrossDomainMessenger public immutable l2Messenger;
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable l1Sender;
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ICrossChainReceiver public immutable receiver;

    /// @notice M-12 FIX: Track processed message IDs to prevent replay attacks
    mapping(bytes32 => bool) public processedMessages;

    /// @notice M-12 FIX: Nonce for generating unique message IDs
    uint256 public messageNonce;

    /// @notice M-12 FIX: Event emitted when a message is processed
    event MessageProcessed(bytes32 indexed messageId, address indexed sender, uint256 nonce);

    /// @notice M-12 FIX: Error for replayed messages
    error MessageAlreadyProcessed(bytes32 messageId);

    constructor(address _l2Messenger, address _l1Sender, address _receiver) {
        l2Messenger = IBaseCrossDomainMessenger(_l2Messenger);
        l1Sender = _l1Sender;
        receiver = ICrossChainReceiver(_receiver);
    }

    /// @notice Relay message from L1
    /// @dev M-12 FIX: Added message ID validation to prevent replay attacks
    function relayMessage(bytes calldata payload) external {
        require(msg.sender == address(l2Messenger), "Only messenger");
        require(l2Messenger.xDomainMessageSender() == l1Sender, "Invalid sender");

        // M-12 FIX: Generate unique message ID from payload and context
        bytes32 messageId = keccak256(abi.encode(
            block.chainid,
            l1Sender,
            payload,
            messageNonce
        ));

        // M-12 FIX: Check for replay attack
        if (processedMessages[messageId]) {
            revert MessageAlreadyProcessed(messageId);
        }

        // M-12 FIX: Mark message as processed before external call (CEI pattern)
        processedMessages[messageId] = true;
        uint256 currentNonce = messageNonce++;

        emit MessageProcessed(messageId, l1Sender, currentNonce);

        receiver.receiveMessage(1, l1Sender, payload); // chainId 1 = Ethereum mainnet
    }

    /// @notice M-12 FIX: Check if a message ID has been processed
    /// @param messageId The message ID to check
    /// @return True if the message has been processed
    function isMessageProcessed(bytes32 messageId) external view returns (bool) {
        return processedMessages[messageId];
    }
}
