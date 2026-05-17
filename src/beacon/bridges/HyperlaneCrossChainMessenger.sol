// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ICrossChainMessenger, ICrossChainReceiver } from "../interfaces/ICrossChainMessenger.sol";

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
    )
        external
        payable
        returns (bytes32 messageId);

    /// @notice Quote fee for dispatching message
    function quoteDispatch(
        uint32 destinationDomain,
        bytes32 recipientAddress,
        bytes calldata messageBody
    )
        external
        view
        returns (uint256 fee);

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
    )
        external
        payable;

    /// @notice Quote gas payment
    function quoteGasPayment(uint32 destinationDomain, uint256 gasAmount) external view returns (uint256);
}

contract HyperlaneCrossChainMessenger is ICrossChainMessenger {
    /// @notice Hyperlane Mailbox
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IHyperlaneMailbox public immutable mailbox;

    /// @notice Interchain Gas Paymaster
    IInterchainGasPaymaster public igp;

    /// @notice Owner address
    address public owner;

    /// @notice Mapping from EVM chainId to Hyperlane domain ID
    mapping(uint256 => uint32) public chainIdToDomain;

    /// @notice Mapping from Hyperlane domain ID to EVM chainId
    mapping(uint32 => uint256) public domainToChainId;

    /// @notice Minimum gas limit for destination chain execution
    uint256 public minGasLimit = 100_000;

    /// @notice Gas buffer percentage (in basis points, 10000 = 100%)
    uint256 public gasBufferBps = 1000; // 10% buffer by default

    /// @notice Events
    event DomainMappingSet(uint256 indexed chainId, uint32 indexed domain);
    event IGPUpdated(address indexed oldIgp, address indexed newIgp);
    event MinGasLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event GasBufferUpdated(uint256 oldBuffer, uint256 newBuffer);
    error InsufficientMsgValue(uint256 required, uint256 provided);
    error RefundFailed();

    /// @dev SECURITY: For production, owner should be a timelock or multisig.
    /// Critical parameters (minGasLimit, gasBufferBps) affect cross-chain security.
    constructor(address _mailbox, address _igp) {
        mailbox = IHyperlaneMailbox(_mailbox);
        igp = IInterchainGasPaymaster(_igp);
        owner = msg.sender;

        // Initialize common chain domain mappings
        // Hyperlane uses domain IDs that match chain IDs for most EVM chains
        _setDomainMapping(1, 1); // Ethereum
        _setDomainMapping(42_161, 42_161); // Arbitrum One
        _setDomainMapping(8453, 8453); // Base
        _setDomainMapping(10, 10); // Optimism
        _setDomainMapping(137, 137); // Polygon
        _setDomainMapping(43_114, 43_114); // Avalanche
        _setDomainMapping(56, 56); // BSC
        // Testnets
        _setDomainMapping(11_155_111, 11_155_111); // Sepolia
        _setDomainMapping(17_000, 17_000); // Holesky
        _setDomainMapping(421_614, 421_614); // Arbitrum Sepolia
        _setDomainMapping(84_532, 84_532); // Base Sepolia
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Only owner");
    }

    /// @inheritdoc ICrossChainMessenger
    /// @dev Gas limit is now enforced to be at least minGasLimit and includes buffer
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
        uint32 destDomain = chainIdToDomain[destinationChainId];
        require(destDomain != 0, "Unsupported chain");

        // Apply minimum gas limit and add safety buffer
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode message with sender info for the receiver
        bytes memory messageBody = abi.encode(block.chainid, msg.sender, payload);

        // Quote dispatch fee
        uint256 dispatchFee = mailbox.quoteDispatch(destDomain, _addressToBytes32(target), messageBody);
        if (msg.value < dispatchFee) revert InsufficientMsgValue(dispatchFee, msg.value);

        // Dispatch message
        messageId = mailbox.dispatch{ value: dispatchFee }(destDomain, _addressToBytes32(target), messageBody);

        // Pay for destination gas if IGP is set and we have effective gas limit
        uint256 amountForGas;
        if (address(igp) != address(0) && effectiveGasLimit > 0) {
            uint256 gasQuote = igp.quoteGasPayment(destDomain, effectiveGasLimit);
            if (gasQuote > 0) {
                uint256 required = dispatchFee + gasQuote;
                if (msg.value < required) revert InsufficientMsgValue(required, msg.value);
                igp.payForGas{ value: gasQuote }(messageId, destDomain, effectiveGasLimit, msg.sender);
                amountForGas = gasQuote;
            }
        }

        uint256 refund = msg.value - dispatchFee - amountForGas;
        if (refund > 0) {
            (bool success,) = msg.sender.call{ value: refund }("");
            if (!success) revert RefundFailed();
        }
    }

    /// @inheritdoc ICrossChainMessenger
    /// @dev Fee estimation now includes gas buffer for accurate cost
    function estimateFee(
        uint256 destinationChainId,
        bytes calldata payload,
        uint256 gasLimit
    )
        external
        view
        returns (uint256 fee)
    {
        uint32 destDomain = chainIdToDomain[destinationChainId];
        if (destDomain == 0) return 0;

        // Apply minimum gas limit and buffer for accurate estimation
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode message
        bytes memory messageBody = abi.encode(block.chainid, address(0), payload);

        // Quote dispatch
        uint256 dispatchFee = mailbox.quoteDispatch(destDomain, bytes32(0), messageBody);

        // Quote gas payment (using effective gas limit)
        uint256 gasFee = 0;
        if (address(igp) != address(0) && effectiveGasLimit > 0) {
            gasFee = igp.quoteGasPayment(destDomain, effectiveGasLimit);
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
    function setIgp(address _igp) external onlyOwner {
        address old = address(igp);
        igp = IInterchainGasPaymaster(_igp);
        emit IGPUpdated(old, _igp);
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    /// @notice Set minimum gas limit for destination chain execution
    /// @param _minGasLimit New minimum gas limit
    function setMinGasLimit(uint256 _minGasLimit) external onlyOwner {
        uint256 oldLimit = minGasLimit;
        minGasLimit = _minGasLimit;
        emit MinGasLimitUpdated(oldLimit, _minGasLimit);
    }

    /// @notice Set gas buffer percentage
    /// @param _gasBufferBps New buffer in basis points (10000 = 100%)
    function setGasBuffer(uint256 _gasBufferBps) external onlyOwner {
        require(_gasBufferBps <= 10_000, "Buffer too high"); // Max 100% buffer
        uint256 oldBuffer = gasBufferBps;
        gasBufferBps = _gasBufferBps;
        emit GasBufferUpdated(oldBuffer, _gasBufferBps);
    }

    /// @notice Apply minimum gas limit and safety buffer
    /// @param gasLimit Requested gas limit
    /// @return Effective gas limit with buffer applied
    function _applyGasLimitWithBuffer(uint256 gasLimit) internal view returns (uint256) {
        // Enforce minimum gas limit
        uint256 effectiveLimit = gasLimit < minGasLimit ? minGasLimit : gasLimit;
        // Add safety buffer
        effectiveLimit = effectiveLimit + (effectiveLimit * gasBufferBps / 10_000);
        return effectiveLimit;
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
///      Added message replay protection
///      C-3 (Round 4): Converted to UUPS upgradeable. Deploy behind ERC1967Proxy
///      and call `initialize(...)`.
contract HyperlaneReceiver is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @custom:storage-location erc7201:tangle.beacon.bridges.HyperlaneReceiver
    struct HyperlaneReceiverStorage {
        address mailbox;
        ICrossChainReceiver receiver;
        // domain => sender => trusted
        mapping(uint32 => mapping(bytes32 => bool)) trustedSenders;
        // domain => evm chain id
        mapping(uint32 => uint256) domainToChainId;
        // replay protection
        mapping(bytes32 => bool) processedMessages;
        uint256[50] __gap;
    }

    /// @notice ERC-7201 slot:
    ///         keccak256(abi.encode(uint256(keccak256("tangle.beacon.bridges.HyperlaneReceiver")) - 1))
    ///         & ~bytes32(uint256(0xff))
    bytes32 private constant HYPERLANE_RECEIVER_SLOT =
        0x705d2cb8451e2eb6cc90102bf0b37cc1990532a8de11ebfaa53c217022f33f00;

    function _getStorage() private pure returns (HyperlaneReceiverStorage storage $) {
        bytes32 s = HYPERLANE_RECEIVER_SLOT;
        assembly {
            $.slot := s
        }
    }

    /// @notice Events
    event MessageHandled(uint32 indexed origin, bytes32 sender, uint256 sourceChainId);
    event TrustedSenderSet(uint32 domain, bytes32 sender, bool trusted);
    /// @notice Event emitted when a message is processed
    event MessageProcessed(bytes32 indexed messageId, uint32 indexed origin, bytes32 sender);

    /// @notice Error for replayed messages
    error MessageAlreadyProcessed(bytes32 messageId);
    error ZeroAddress();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the receiver behind a proxy.
    /// @dev Init order: ownership granted before any trusted-sender configuration so
    ///      `setTrustedSender`/`setDomainMapping` cannot be front-run by a stale
    ///      caller.
    function initialize(address _mailbox, address _receiver, address _owner) external initializer {
        if (_owner == address(0)) revert ZeroAddress();
        __UUPSUpgradeable_init();
        __Ownable_init(_owner);

        HyperlaneReceiverStorage storage $ = _getStorage();
        $.mailbox = _mailbox;
        $.receiver = ICrossChainReceiver(_receiver);

        // Initialize domain mappings
        $.domainToChainId[1] = 1; // Ethereum
        $.domainToChainId[42_161] = 42_161; // Arbitrum
        $.domainToChainId[8453] = 8453; // Base
        $.domainToChainId[11_155_111] = 11_155_111; // Sepolia
        $.domainToChainId[17_000] = 17_000; // Holesky
        $.domainToChainId[421_614] = 421_614; // Arbitrum Sepolia
        $.domainToChainId[84_532] = 84_532; // Base Sepolia
    }

    function mailbox() external view returns (address) {
        return _getStorage().mailbox;
    }

    function receiver() external view returns (ICrossChainReceiver) {
        return _getStorage().receiver;
    }

    function trustedSenders(uint32 domain, bytes32 sender) external view returns (bool) {
        return _getStorage().trustedSenders[domain][sender];
    }

    function domainToChainId(uint32 domain) external view returns (uint256) {
        return _getStorage().domainToChainId[domain];
    }

    function processedMessages(bytes32 messageId) external view returns (bool) {
        return _getStorage().processedMessages[messageId];
    }

    modifier onlyMailbox() {
        _onlyMailbox();
        _;
    }

    function _onlyMailbox() internal view {
        require(msg.sender == _getStorage().mailbox, "Only mailbox");
    }

    /// @notice Handle incoming Hyperlane message
    /// @param _origin Origin domain ID
    /// @param _sender Sender address as bytes32
    /// @param _message Message body
    /// @dev Added message ID validation to prevent replay attacks
    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable onlyMailbox {
        HyperlaneReceiverStorage storage $ = _getStorage();

        // Verify trusted sender
        require($.trustedSenders[_origin][_sender], "Untrusted sender");

        // Generate unique message ID from origin, sender, and message content
        bytes32 messageId = keccak256(abi.encode(_origin, _sender, keccak256(_message)));

        // Check for replay attack
        if ($.processedMessages[messageId]) {
            revert MessageAlreadyProcessed(messageId);
        }

        // Mark message as processed before external call (CEI pattern)
        $.processedMessages[messageId] = true;

        // Decode message
        (uint256 sourceChainId, address originalSender, bytes memory payload) =
            abi.decode(_message, (uint256, address, bytes));

        // Verify chain ID matches domain
        require($.domainToChainId[_origin] == sourceChainId, "Chain mismatch");

        emit MessageHandled(_origin, _sender, sourceChainId);
        emit MessageProcessed(messageId, _origin, _sender);

        // Forward to receiver
        $.receiver.receiveMessage(sourceChainId, originalSender, payload);
    }

    /// @notice Set trusted sender
    function setTrustedSender(uint32 domain, address sender, bool trusted) external onlyOwner {
        bytes32 senderBytes = bytes32(uint256(uint160(sender)));
        _getStorage().trustedSenders[domain][senderBytes] = trusted;
        emit TrustedSenderSet(domain, senderBytes, trusted);
    }

    /// @notice Set domain to chain ID mapping
    function setDomainMapping(uint32 domain, uint256 chainId) external onlyOwner {
        _getStorage().domainToChainId[domain] = chainId;
    }

    /// @notice Check if a message ID has been processed
    function isMessageProcessed(bytes32 messageId) external view returns (bool) {
        return _getStorage().processedMessages[messageId];
    }

    /// @inheritdoc UUPSUpgradeable
    /// @dev Owner-gated. Production owner should be a multisig / timelock.
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }
}
