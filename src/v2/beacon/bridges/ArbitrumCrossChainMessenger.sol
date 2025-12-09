// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ICrossChainMessenger, ICrossChainReceiver} from "../interfaces/ICrossChainMessenger.sol";

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
    ) external payable returns (uint256 ticketId);

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
    uint256 public constant ARBITRUM_ONE_CHAIN_ID = 42161;
    uint256 public constant ARBITRUM_SEPOLIA_CHAIN_ID = 421614;

    /// @notice Default L2 gas price (can be overridden)
    uint256 public l2MaxFeePerGas = 0.1 gwei;

    /// @notice Owner for configuration
    address public owner;

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
    function sendMessage(
        uint256 destinationChainId,
        address target,
        bytes calldata payload,
        uint256 gasLimit
    ) external payable returns (bytes32 messageId) {
        require(
            destinationChainId == ARBITRUM_ONE_CHAIN_ID || destinationChainId == ARBITRUM_SEPOLIA_CHAIN_ID,
            "Unsupported chain"
        );

        // Encode the cross-chain call
        bytes memory l2Calldata = abi.encodeCall(
            ICrossChainReceiver.receiveMessage,
            (block.chainid, msg.sender, payload)
        );

        // Calculate submission cost
        uint256 submissionCost = inbox.calculateRetryableSubmissionFee(l2Calldata.length, block.basefee);

        // Create retryable ticket
        uint256 ticketId = inbox.createRetryableTicket{value: msg.value}(
            target,                  // L2 destination
            0,                       // L2 call value
            submissionCost,          // Max submission cost
            msg.sender,              // Excess fee refund
            msg.sender,              // Call value refund
            gasLimit,                // L2 gas limit
            l2MaxFeePerGas,          // L2 max gas price
            l2Calldata               // L2 calldata
        );

        // Convert ticket ID to bytes32
        messageId = bytes32(ticketId);
    }

    /// @inheritdoc ICrossChainMessenger
    function estimateFee(
        uint256, // destinationChainId
        bytes calldata payload,
        uint256 gasLimit
    ) external view returns (uint256 fee) {
        // Encode call to estimate size
        bytes memory l2Calldata = abi.encodeCall(
            ICrossChainReceiver.receiveMessage,
            (block.chainid, address(0), payload)
        );

        // Submission cost
        uint256 submissionCost = inbox.calculateRetryableSubmissionFee(l2Calldata.length, block.basefee);

        // L2 execution cost
        uint256 l2ExecutionCost = gasLimit * l2MaxFeePerGas;

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

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}

/// @title ArbitrumL2Receiver
/// @notice Adapter for receiving messages on Arbitrum L2 from L1
/// @dev Validates sender is the aliased L1 contract
contract ArbitrumL2Receiver {
    /// @notice Address offset for L1→L2 aliasing
    uint160 internal constant OFFSET = uint160(0x1111000000000000000000000000000000001111);

    /// @notice Expected L1 sender (before aliasing)
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable l1Sender;

    /// @notice The actual receiver contract
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ICrossChainReceiver public immutable receiver;

    constructor(address _l1Sender, address _receiver) {
        l1Sender = _l1Sender;
        receiver = ICrossChainReceiver(_receiver);
    }

    /// @notice Compute L1 aliased address
    function applyL1ToL2Alias(address l1Address) public pure returns (address l2Address) {
        unchecked {
            l2Address = address(uint160(l1Address) + OFFSET);
        }
    }

    /// @notice Relay message from L1 (called via retryable ticket)
    function relayMessage(bytes calldata payload) external {
        // Verify msg.sender is the aliased L1 sender
        require(msg.sender == applyL1ToL2Alias(l1Sender), "Invalid sender");

        // Forward to receiver (chainId 1 = Ethereum mainnet)
        receiver.receiveMessage(1, l1Sender, payload);
    }
}
