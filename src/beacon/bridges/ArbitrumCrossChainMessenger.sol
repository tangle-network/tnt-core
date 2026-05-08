// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ICrossChainMessenger, ICrossChainReceiver } from "../interfaces/ICrossChainMessenger.sol";

/// @title ArbitrumCrossChainMessenger
/// @notice ICrossChainMessenger implementation for Arbitrum L1→L2 messaging
/// @dev Uses Arbitrum's native retryable ticket system

/// @notice Arbitrum Inbox interface for L1→L2 messaging
interface IArbitrumInbox {
    /// @notice Create retryable ticket for L1→L2 message
    /// @param to L2 destination address
    /// @param l2CallValue Call value for L2 execution
    /// @param maxSubmissionCost Max ETH for submission
    /// @param excessFeeRefundAddress Where to refund excess fees
    /// @param callValueRefundAddress Where to refund unused call value
    /// @param gasLimit L2 gas limit
    /// @param maxFeePerGas L2 max gas price
    /// @param data Calldata for L2 call
    /// @return ticketId Unique ticket identifier
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
        returns (uint256 ticketId);

    /// @notice Calculate submission cost
    function calculateRetryableSubmissionFee(uint256 dataLength, uint256 baseFee) external view returns (uint256);
}

/// @notice Arbitrum outbox for checking L2→L1 message status
interface IArbitrumOutbox {
    function l2ToL1Sender() external view returns (address);
}

contract ArbitrumCrossChainMessenger is ICrossChainMessenger {
    /// @notice Arbitrum L1 Inbox
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IArbitrumInbox public immutable inbox;

    /// @notice Arbitrum One chain ID
    uint256 public constant ARBITRUM_ONE_CHAIN_ID = 42_161;
    uint256 public constant ARBITRUM_SEPOLIA_CHAIN_ID = 421_614;

    /// @notice Default L2 gas price (can be overridden)
    uint256 public l2MaxFeePerGas = 0.1 gwei;

    /// @notice M-12 FIX: Minimum gas limit for L2 execution (prevents insufficient gas)
    uint256 public minGasLimit = 100_000;

    /// @notice M-12 FIX: Gas buffer percentage (in basis points, 10000 = 100%)
    /// @dev Adds safety margin to requested gas limit
    uint256 public gasBufferBps = 1000; // 10% buffer by default

    /// @notice L2 alias of an L1 address that should receive excess-fee refunds.
    /// @dev Round 2 cross-chain auditor H-1: when `excessFeeRefundAddress` is set
    ///      to `msg.sender` (the L1 connector), Arbitrum mints the refund at the
    ///      L2 alias of that L1 contract — which has no receive logic, so the
    ///      ETH is permanently locked. Callers who care about recovering excess
    ///      gas / submission fees can configure a sweep address (their own L2
    ///      treasury, a sweep contract, etc.). Owner-controlled with a default
    ///      of `address(0)` which means "fall back to msg.sender" for backwards
    ///      compatibility with deploy scripts that haven't migrated yet.
    address public l2RefundAddress;

    /// @notice Owner for configuration
    address public owner;

    /// @notice M-12 FIX: Events for gas configuration changes
    event MinGasLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event GasBufferUpdated(uint256 oldBuffer, uint256 newBuffer);
    event L2RefundAddressUpdated(address indexed oldAddress, address indexed newAddress);

    /// @dev SECURITY: For production, owner should be a timelock or multisig.
    /// Critical parameters (minGasLimit, gasBufferBps) affect cross-chain security.
    constructor(address _inbox) {
        inbox = IArbitrumInbox(_inbox);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Only owner");
    }

    /// @inheritdoc ICrossChainMessenger
    /// @dev M-12 FIX: Gas limit is now enforced to be at least minGasLimit and includes buffer
    function sendMessage(
        uint256 destinationChainId,
        address target,
        bytes calldata payload,
        uint256 gasLimit
    )
        external
        payable
        returns (bytes32 messageId)
    {
        require(
            destinationChainId == ARBITRUM_ONE_CHAIN_ID || destinationChainId == ARBITRUM_SEPOLIA_CHAIN_ID,
            "Unsupported chain"
        );

        // M-12 FIX: Apply minimum gas limit and add safety buffer
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode the cross-chain call
        bytes memory l2Calldata =
            abi.encodeCall(ICrossChainReceiver.receiveMessage, (block.chainid, msg.sender, payload));

        // Calculate submission cost
        uint256 submissionCost = inbox.calculateRetryableSubmissionFee(l2Calldata.length, block.basefee);

        // Round 2 cross-chain auditor H-1: route excess-fee + call-value refunds to a
        // sweep address if configured. Falls back to `msg.sender` (the L1 connector)
        // only when no sweep address is set, which results in funds locked at the L2
        // alias of the L1 contract — fine for one-shot deployments, lossy for any
        // ongoing relay traffic.
        address refundTo = l2RefundAddress != address(0) ? l2RefundAddress : msg.sender;

        // Create retryable ticket
        uint256 ticketId = inbox.createRetryableTicket{ value: msg.value }(
            target, // L2 destination
            0, // L2 call value
            submissionCost, // Max submission cost
            refundTo, // Excess fee refund (audit H-1)
            refundTo, // Call value refund (audit H-1)
            effectiveGasLimit, // L2 gas limit (with buffer)
            l2MaxFeePerGas, // L2 max gas price
            l2Calldata // L2 calldata
        );

        // Convert ticket ID to bytes32
        messageId = bytes32(ticketId);
    }

    /// @inheritdoc ICrossChainMessenger
    /// @dev M-12 FIX: Fee estimation now includes gas buffer for accurate cost
    function estimateFee(
        uint256, // destinationChainId
        bytes calldata payload,
        uint256 gasLimit
    )
        external
        view
        returns (uint256 fee)
    {
        // M-12 FIX: Apply minimum gas limit and buffer for accurate estimation
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode call to estimate size
        bytes memory l2Calldata =
            abi.encodeCall(ICrossChainReceiver.receiveMessage, (block.chainid, address(0), payload));

        // Submission cost
        uint256 submissionCost = inbox.calculateRetryableSubmissionFee(l2Calldata.length, block.basefee);

        // L2 execution cost (using effective gas limit with buffer)
        uint256 l2ExecutionCost = effectiveGasLimit * l2MaxFeePerGas;

        return submissionCost + l2ExecutionCost;
    }

    /// @inheritdoc ICrossChainMessenger
    function isChainSupported(uint256 chainId) external pure returns (bool) {
        return chainId == ARBITRUM_ONE_CHAIN_ID || chainId == ARBITRUM_SEPOLIA_CHAIN_ID;
    }

    /// @notice Update L2 gas price estimate
    function setL2MaxFeePerGas(uint256 _l2MaxFeePerGas) external onlyOwner {
        l2MaxFeePerGas = _l2MaxFeePerGas;
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
        require(_gasBufferBps <= 10_000, "Buffer too high"); // Max 100% buffer
        uint256 oldBuffer = gasBufferBps;
        gasBufferBps = _gasBufferBps;
        emit GasBufferUpdated(oldBuffer, _gasBufferBps);
    }

    /// @notice Set the L2 sweep address that will receive excess-fee and call-value
    ///         refunds from `createRetryableTicket`. Round 2 cross-chain H-1.
    /// @dev Set to a contract you control on L2 (a treasury sweep, or the
    ///      `L2SlashingReceiver` itself if you want refunds to compound into the
    ///      bridge balance). Set to `address(0)` to fall back to the legacy
    ///      `msg.sender` behavior, which leaks refunds to the L2 alias of the L1
    ///      connector (typically irrecoverable).
    function setL2RefundAddress(address newAddress) external onlyOwner {
        address old = l2RefundAddress;
        l2RefundAddress = newAddress;
        emit L2RefundAddressUpdated(old, newAddress);
    }

    /// @notice M-12 FIX: Apply minimum gas limit and safety buffer
    /// @param gasLimit Requested gas limit
    /// @return Effective gas limit with buffer applied
    function _applyGasLimitWithBuffer(uint256 gasLimit) internal view returns (uint256) {
        // Enforce minimum gas limit
        uint256 effectiveLimit = gasLimit < minGasLimit ? minGasLimit : gasLimit;
        // Add safety buffer
        effectiveLimit = effectiveLimit + (effectiveLimit * gasBufferBps / 10_000);
        return effectiveLimit;
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}

/// @title ArbitrumL2Receiver
/// @notice Adapter for receiving messages on Arbitrum L2 from L1
/// @dev Validates sender is the aliased L1 contract
///      M-12 FIX: Added message replay protection
contract ArbitrumL2Receiver {
    /// @notice Address offset for L1→L2 aliasing
    uint160 internal constant OFFSET = uint160(0x1111000000000000000000000000000000001111);

    /// @notice Expected L1 sender (before aliasing)
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable l1Sender;

    /// @notice The actual receiver contract
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ICrossChainReceiver public immutable receiver;
    uint256 public immutable sourceChainId;

    /// @notice M-12 FIX: Track processed message IDs to prevent replay attacks
    mapping(bytes32 => bool) public processedMessages;

    /// @notice M-12 FIX: Nonce for generating unique message IDs
    uint256 public messageNonce;

    /// @notice M-12 FIX: Event emitted when a message is processed
    event MessageProcessed(bytes32 indexed messageId, address indexed sender, uint256 nonce);

    /// @notice M-12 FIX: Error for replayed messages
    error MessageAlreadyProcessed(bytes32 messageId);

    constructor(address _l1Sender, address _receiver, uint256 _sourceChainId) {
        l1Sender = _l1Sender;
        receiver = ICrossChainReceiver(_receiver);
        sourceChainId = _sourceChainId;
    }

    /// @notice Compute L1 aliased address
    function applyL1ToL2Alias(address l1Address) public pure returns (address l2Address) {
        unchecked {
            l2Address = address(uint160(l1Address) + OFFSET);
        }
    }

    /// @notice Relay message from L1 (called via retryable ticket)
    /// @dev M-12 FIX: Added message ID validation to prevent replay attacks
    function relayMessage(bytes calldata payload) external {
        // Verify msg.sender is the aliased L1 sender
        require(msg.sender == applyL1ToL2Alias(l1Sender), "Invalid sender");

        // Deduplicate identical bridged payload deliveries from the same L1 sender.
        bytes32 messageId = keccak256(abi.encode(block.chainid, l1Sender, payload));

        // M-12 FIX: Check for replay attack
        if (processedMessages[messageId]) {
            revert MessageAlreadyProcessed(messageId);
        }

        // M-12 FIX: Mark message as processed before external call (CEI pattern)
        processedMessages[messageId] = true;
        uint256 currentNonce = messageNonce++;

        emit MessageProcessed(messageId, l1Sender, currentNonce);

        receiver.receiveMessage(sourceChainId, l1Sender, payload);
    }

    /// @notice M-12 FIX: Check if a message ID has been processed
    /// @param messageId The message ID to check
    /// @return True if the message has been processed
    function isMessageProcessed(bytes32 messageId) external view returns (bool) {
        return processedMessages[messageId];
    }
}
