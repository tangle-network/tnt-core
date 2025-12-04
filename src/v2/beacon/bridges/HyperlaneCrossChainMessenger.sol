// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ICrossChainMessenger, ICrossChainReceiver} from "../interfaces/ICrossChainMessenger.sol";

/// @title HyperlaneCrossChainMessenger
/// @notice ICrossChainMessenger implementation for Hyperlane
/// @dev Uses Hyperlane's Mailbox for cross-chain messaging

/// @notice Hyperlane Mailbox interface
interface IHyperlaneMailbox {
    /// @notice Dispatch a message to another chain
    /// @param destinationDomain Destination chain domain ID
    /// @param recipientAddress Recipient address as bytes32
    /// @param messageBody Message payload
    /// @return messageId Unique message identifier
    function dispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external payable returns (bytes32 messageId);

    /// @notice Quote fee for dispatching message
    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    ) external view returns (uint256 fee);

    /// @notice Get the local domain
    function localDomain() external view returns (uint32);
}

/// @notice Hyperlane Interchain Gas Paymaster
interface IInterchainGasPaymaster {
    /// @notice Pay for gas on destination chain
    function payForGas(
        bytes32 messageId,
        uint32 destinationDomain,
        uint256 gasAmount,
        address refundAddress
    ) external payable;

    /// @notice Quote gas payment
    function quoteGasPayment(
        uint32 destinationDomain,
        uint256 gasAmount
    ) external view returns (uint256);
}

contract HyperlaneCrossChainMessenger is ICrossChainMessenger {
    /// @notice Hyperlane Mailbox
    IHyperlaneMailbox public immutable mailbox;

    /// @notice Interchain Gas Paymaster
    IInterchainGasPaymaster public igp;

    /// @notice Owner address
    address public owner;

    /// @notice Mapping from EVM chainId to Hyperlane domain ID
    mapping(uint256 => uint32) public chainIdToDomain;

    /// @notice Mapping from Hyperlane domain ID to EVM chainId
    mapping(uint32 => uint256) public domainToChainId;

    /// @notice Events
    event DomainMappingSet(uint256 chainId, uint32 domain);
    event IGPUpdated(address oldIGP, address newIGP);

    constructor(address _mailbox, address _igp) {
        mailbox = IHyperlaneMailbox(_mailbox);
        igp = IInterchainGasPaymaster(_igp);
        owner = msg.sender;

        // Initialize common chain domain mappings
        // Hyperlane uses domain IDs that match chain IDs for most EVM chains
        _setDomainMapping(1, 1);           // Ethereum
        _setDomainMapping(42161, 42161);   // Arbitrum One
        _setDomainMapping(8453, 8453);     // Base
        _setDomainMapping(10, 10);         // Optimism
        _setDomainMapping(137, 137);       // Polygon
        _setDomainMapping(43114, 43114);   // Avalanche
        _setDomainMapping(56, 56);         // BSC
        // Testnets
        _setDomainMapping(11155111, 11155111); // Sepolia
        _setDomainMapping(421614, 421614);     // Arbitrum Sepolia
        _setDomainMapping(84532, 84532);       // Base Sepolia
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @inheritdoc ICrossChainMessenger
    function sendMessage(
        uint256 destinationChainId,
        address target,
        bytes calldata payload,
        uint256 gasLimit
    ) external payable returns (bytes32 messageId) {
        uint32 destDomain = chainIdToDomain[destinationChainId];
        require(destDomain != 0, "Unsupported chain");

        // Encode message with sender info for the receiver
        bytes memory messageBody = abi.encode(block.chainid, msg.sender, payload);

        // Quote dispatch fee
        uint256 dispatchFee = mailbox.quoteDispatch(
            destDomain,
            _addressToBytes32(target),
            messageBody
        );

        // Dispatch message
        messageId = mailbox.dispatch{value: dispatchFee}(
            destDomain,
            _addressToBytes32(target),
            messageBody
        );

        // Pay for destination gas if IGP is set and we have remaining value
        if (address(igp) != address(0) && msg.value > dispatchFee && gasLimit > 0) {
            uint256 gasPayment = msg.value - dispatchFee;
            igp.payForGas{value: gasPayment}(
                messageId,
                destDomain,
                gasLimit,
                msg.sender
            );
        }
    }

    /// @inheritdoc ICrossChainMessenger
    function estimateFee(
        uint256 destinationChainId,
        bytes calldata payload,
        uint256 gasLimit
    ) external view returns (uint256 fee) {
        uint32 destDomain = chainIdToDomain[destinationChainId];
        if (destDomain == 0) return 0;

        // Encode message
        bytes memory messageBody = abi.encode(block.chainid, address(0), payload);

        // Quote dispatch
        uint256 dispatchFee = mailbox.quoteDispatch(
            destDomain,
            bytes32(0),
            messageBody
        );

        // Quote gas payment
        uint256 gasFee = 0;
        if (address(igp) != address(0) && gasLimit > 0) {
            gasFee = igp.quoteGasPayment(destDomain, gasLimit);
        }

        return dispatchFee + gasFee;
    }

    /// @inheritdoc ICrossChainMessenger
    function isChainSupported(uint256 chainId) external view returns (bool) {
        return chainIdToDomain[chainId] != 0;
    }

    /// @notice Set domain mapping
    function setDomainMapping(uint256 chainId, uint32 domain) external onlyOwner {
        _setDomainMapping(chainId, domain);
    }

    /// @notice Update IGP address
    function setIGP(address _igp) external onlyOwner {
        address old = address(igp);
        igp = IInterchainGasPaymaster(_igp);
        emit IGPUpdated(old, _igp);
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    function _setDomainMapping(uint256 chainId, uint32 domain) internal {
        chainIdToDomain[chainId] = domain;
        domainToChainId[domain] = chainId;
        emit DomainMappingSet(chainId, domain);
    }

    function _addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}

/// @title HyperlaneReceiver
/// @notice Hyperlane MessageRecipient for receiving cross-chain messages
/// @dev Implements handle() to process incoming messages
contract HyperlaneReceiver {
    /// @notice Hyperlane Mailbox
    address public immutable mailbox;

    /// @notice The actual message receiver
    ICrossChainReceiver public immutable receiver;

    /// @notice Owner
    address public owner;

    /// @notice Trusted senders per origin domain (domain => sender => trusted)
    mapping(uint32 => mapping(bytes32 => bool)) public trustedSenders;

    /// @notice Mapping from Hyperlane domain to EVM chain ID
    mapping(uint32 => uint256) public domainToChainId;

    /// @notice Events
    event MessageHandled(uint32 indexed origin, bytes32 sender, uint256 sourceChainId);
    event TrustedSenderSet(uint32 domain, bytes32 sender, bool trusted);

    constructor(address _mailbox, address _receiver) {
        mailbox = _mailbox;
        receiver = ICrossChainReceiver(_receiver);
        owner = msg.sender;

        // Initialize domain mappings
        domainToChainId[1] = 1;             // Ethereum
        domainToChainId[42161] = 42161;     // Arbitrum
        domainToChainId[8453] = 8453;       // Base
        domainToChainId[11155111] = 11155111; // Sepolia
        domainToChainId[421614] = 421614;   // Arbitrum Sepolia
        domainToChainId[84532] = 84532;     // Base Sepolia
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier onlyMailbox() {
        require(msg.sender == mailbox, "Only mailbox");
        _;
    }

    /// @notice Handle incoming Hyperlane message
    /// @param _origin Origin domain ID
    /// @param _sender Sender address as bytes32
    /// @param _message Message body
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable onlyMailbox {
        // Verify trusted sender
        require(trustedSenders[_origin][_sender], "Untrusted sender");

        // Decode message
        (uint256 sourceChainId, address originalSender, bytes memory payload) =
            abi.decode(_message, (uint256, address, bytes));

        // Verify chain ID matches domain
        require(domainToChainId[_origin] == sourceChainId, "Chain mismatch");

        emit MessageHandled(_origin, _sender, sourceChainId);

        // Forward to receiver
        receiver.receiveMessage(sourceChainId, originalSender, payload);
    }

    /// @notice Set trusted sender
    function setTrustedSender(uint32 domain, address sender, bool trusted) external onlyOwner {
        bytes32 senderBytes = bytes32(uint256(uint160(sender)));
        trustedSenders[domain][senderBytes] = trusted;
        emit TrustedSenderSet(domain, senderBytes, trusted);
    }

    /// @notice Set domain to chain ID mapping
    function setDomainMapping(uint32 domain, uint256 chainId) external onlyOwner {
        domainToChainId[domain] = chainId;
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}
