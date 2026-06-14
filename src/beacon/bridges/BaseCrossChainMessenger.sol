// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ICrossChainMessenger, ICrossChainReceiver } from "../interfaces/ICrossChainMessenger.sol";

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
    uint256 public constant BASE_SEPOLIA_CHAIN_ID = 84_532;

    /// @notice Owner for configuration
    address public owner;

    /// @notice Callers authorized to relay messages through this adapter.
    /// @dev SECURITY INVARIANT: `sendMessage` lends this adapter's authenticated L1
    ///      identity (`xDomainMessageSender` on L2) to whatever payload it forwards. The
    ///      L2 receiver authenticates the *adapter*, not the original caller, so any
    ///      address able to invoke `sendMessage` can forge an L1-authenticated message
    ///      (e.g. a beacon SLASH) against any operator. `sendMessage` MUST therefore be
    ///      restricted to the legitimate L1 origin (the L2SlashingConnector). The owner
    ///      is implicitly authorized so it can bootstrap/operate without a self-grant.
    mapping(address => bool) public authorizedSenders;

    /// @notice Minimum gas limit for L2 execution
    uint256 public minGasLimit = 100_000;

    /// @notice Gas buffer percentage (in basis points, 10000 = 100%)
    uint256 public gasBufferBps = 1000; // 10% buffer by default

    /// @notice Events for gas configuration changes
    event MinGasLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event GasBufferUpdated(uint256 oldBuffer, uint256 newBuffer);
    event AuthorizedSenderUpdated(address indexed sender, bool authorized);

    /// @notice Caller is not authorized to relay messages through this adapter.
    error UnauthorizedSender(address caller);

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

    /// @notice Authorize (or revoke) a caller permitted to relay through `sendMessage`.
    /// @dev The legitimate caller is the L2SlashingConnector. Owner-gated.
    function setAuthorizedSender(address sender, bool authorized) external onlyOwner {
        require(sender != address(0), "Zero address");
        authorizedSenders[sender] = authorized;
        emit AuthorizedSenderUpdated(sender, authorized);
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
        // INVARIANT: only the owner or an explicitly authorized sender (the
        // L2SlashingConnector) may borrow this adapter's authenticated L1 identity.
        // Without this gate any caller is a confused deputy that can forge an
        // L1-authenticated SLASH on L2.
        if (msg.sender != owner && !authorizedSenders[msg.sender]) {
            revert UnauthorizedSender(msg.sender);
        }

        require(destinationChainId == BASE_CHAIN_ID || destinationChainId == BASE_SEPOLIA_CHAIN_ID, "Unsupported chain");

        // Apply minimum gas limit and add safety buffer
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Base native messaging
        // effectiveGasLimit fits into uint32 because we enforce reasonable limits.
        // forge-lint: disable-next-line(unsafe-typecast)
        l1Messenger.sendMessage{ value: msg.value }(
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
    )
        external
        pure
        returns (uint256 fee)
    {
        // Base native messaging is free (paid by sequencer)
        return 0;
    }

    /// @inheritdoc ICrossChainMessenger
    function isChainSupported(uint256 chainId) external pure returns (bool) {
        return chainId == BASE_CHAIN_ID || chainId == BASE_SEPOLIA_CHAIN_ID;
    }

    /// @notice Set minimum gas limit for L2 execution
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

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}

/// @title BaseL2Receiver
/// @notice Adapter for receiving messages on Base L2
/// @dev Added message replay protection
///      C-3 : Converted to UUPS upgradeable. Deploy behind ERC1967Proxy
///      and call `initialize(...)`.
contract BaseL2Receiver is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @custom:storage-location erc7201:tangle.beacon.bridges.BaseL2Receiver
    struct BaseL2ReceiverStorage {
        IBaseCrossDomainMessenger l2Messenger;
        address l1Sender;
        ICrossChainReceiver receiver;
        uint256 sourceChainId;
        mapping(bytes32 => bool) processedMessages;
        uint256 messageNonce;
        uint256[50] __gap;
    }

    /// @notice ERC-7201 slot:
    ///         keccak256(abi.encode(uint256(keccak256("tangle.beacon.bridges.BaseL2Receiver")) - 1))
    ///         & ~bytes32(uint256(0xff))
    bytes32 private constant BASE_L2_RECEIVER_SLOT = 0x697acf8f37fcf1e990825dbccd8642ff6efc86e337b0fa3a87405b6fe90aa500;

    function _getStorage() private pure returns (BaseL2ReceiverStorage storage $) {
        bytes32 s = BASE_L2_RECEIVER_SLOT;
        assembly {
            $.slot := s
        }
    }

    /// @notice Event emitted when a message is processed
    event MessageProcessed(bytes32 indexed messageId, address indexed sender, uint256 nonce);

    /// @notice Error for replayed messages
    error MessageAlreadyProcessed(bytes32 messageId);
    error ZeroAddress();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _l2Messenger,
        address _l1Sender,
        address _receiver,
        uint256 _sourceChainId,
        address _owner
    )
        external
        initializer
    {
        if (_owner == address(0)) revert ZeroAddress();
        __UUPSUpgradeable_init();
        __Ownable_init(_owner);

        BaseL2ReceiverStorage storage $ = _getStorage();
        $.l2Messenger = IBaseCrossDomainMessenger(_l2Messenger);
        $.l1Sender = _l1Sender;
        $.receiver = ICrossChainReceiver(_receiver);
        $.sourceChainId = _sourceChainId;
    }

    function l2Messenger() external view returns (IBaseCrossDomainMessenger) {
        return _getStorage().l2Messenger;
    }

    function l1Sender() external view returns (address) {
        return _getStorage().l1Sender;
    }

    function receiver() external view returns (ICrossChainReceiver) {
        return _getStorage().receiver;
    }

    function sourceChainId() external view returns (uint256) {
        return _getStorage().sourceChainId;
    }

    function processedMessages(bytes32 messageId) external view returns (bool) {
        return _getStorage().processedMessages[messageId];
    }

    function messageNonce() external view returns (uint256) {
        return _getStorage().messageNonce;
    }

    /// @notice Relay message from L1
    /// @dev Added message ID validation to prevent replay attacks
    function relayMessage(bytes calldata payload) external {
        BaseL2ReceiverStorage storage $ = _getStorage();
        IBaseCrossDomainMessenger msgr = $.l2Messenger;
        address sender_ = $.l1Sender;

        require(msg.sender == address(msgr), "Only messenger");
        require(msgr.xDomainMessageSender() == sender_, "Invalid sender");

        // Deduplicate identical bridged payload deliveries from the same L1 sender.
        bytes32 messageId = keccak256(abi.encode(block.chainid, sender_, payload));

        // Check for replay attack
        if ($.processedMessages[messageId]) {
            revert MessageAlreadyProcessed(messageId);
        }

        // Mark message as processed before external call (CEI pattern)
        $.processedMessages[messageId] = true;
        uint256 currentNonce = $.messageNonce++;

        emit MessageProcessed(messageId, sender_, currentNonce);

        $.receiver.receiveMessage($.sourceChainId, sender_, payload);
    }

    /// @notice Check if a message ID has been processed
    function isMessageProcessed(bytes32 messageId) external view returns (bool) {
        return _getStorage().processedMessages[messageId];
    }

    /// @inheritdoc UUPSUpgradeable
    /// @dev Owner-gated. Production owner should be a multisig / timelock.
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }
}
