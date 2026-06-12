// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ICrossChainMessenger, ICrossChainReceiver } from "../interfaces/ICrossChainMessenger.sol";

/// @title LayerZeroCrossChainMessenger
/// @notice ICrossChainMessenger implementation for LayerZero V2
/// @dev Uses LayerZero's OApp architecture for cross-chain messaging
/// Supports any LayerZero-connected chain including Tempo, Ethereum, Arbitrum, etc.

/// @notice LayerZero V2 Endpoint interface
interface ILayerZeroEndpointV2 {
    struct MessagingParams {
        uint32 dstEid; // Destination endpoint ID
        bytes32 receiver; // Receiver address as bytes32
        bytes message; // Message payload
        bytes options; // Execution options
        bool payInLzToken; // Pay in LZ token vs native
    }

    struct MessagingReceipt {
        bytes32 guid; // Global unique identifier
        uint64 nonce; // Message nonce
        MessagingFee fee; // Fee paid
    }

    struct MessagingFee {
        uint256 nativeFee; // Fee in native token
        uint256 lzTokenFee; // Fee in LZ token
    }

    /// @notice Send message to another chain
    function send(
        MessagingParams calldata _params,
        address _refundAddress
    )
        external
        payable
        returns (MessagingReceipt memory);

    /// @notice Estimate fee for sending message
    function quote(MessagingParams calldata _params, address _sender) external view returns (MessagingFee memory);

    /// @notice Set delegate for this sender
    function setDelegate(address _delegate) external;
}

/// @notice LayerZero V2 Options library helpers
library OptionsBuilder {
    uint16 internal constant TYPE_3 = 3;

    /// @notice Create execution options with gas limit
    function newOptions() internal pure returns (bytes memory) {
        return abi.encodePacked(TYPE_3);
    }

    /// @notice Add executor gas limit
    function addExecutorLzReceiveOption(
        bytes memory _options,
        uint128 _gas,
        uint128 _value
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(_options, uint8(1), uint16(17), _gas, _value);
    }
}

contract LayerZeroCrossChainMessenger is ICrossChainMessenger {
    using OptionsBuilder for bytes;

    /// @notice LayerZero V2 Endpoint
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ILayerZeroEndpointV2 public immutable endpoint;

    /// @notice Owner address
    address public owner;

    /// @notice Mapping from EVM chainId to LayerZero endpoint ID
    mapping(uint256 => uint32) public chainIdToEid;

    /// @notice Mapping from LayerZero endpoint ID to EVM chainId
    mapping(uint32 => uint256) public eidToChainId;

    /// @notice Trusted peers on each chain (eid => peer address as bytes32)
    mapping(uint32 => bytes32) public peers;

    /// @notice Minimum gas limit for destination chain execution
    uint256 public minGasLimit = 100_000;

    /// @notice Gas buffer percentage (in basis points, 10000 = 100%)
    uint256 public gasBufferBps = 1000; // 10% buffer by default

    /// @notice Events
    event PeerSet(uint32 indexed eid, bytes32 indexed peer);
    event ChainMappingSet(uint256 indexed chainId, uint32 indexed eid);
    event MinGasLimitUpdated(uint256 oldLimit, uint256 newLimit);
    event GasBufferUpdated(uint256 oldBuffer, uint256 newBuffer);

    /// @dev SECURITY: For production, owner should be a timelock or multisig.
    /// Critical parameters (minGasLimit, gasBufferBps) affect cross-chain security.
    constructor(address _endpoint) {
        endpoint = ILayerZeroEndpointV2(_endpoint);
        owner = msg.sender;

        // Initialize common chain mappings
        // Ethereum Mainnet
        chainIdToEid[1] = 30_101;
        eidToChainId[30_101] = 1;
        // Arbitrum One
        chainIdToEid[42_161] = 30_110;
        eidToChainId[30_110] = 42_161;
        // Base
        chainIdToEid[8453] = 30_184;
        eidToChainId[30_184] = 8453;
        // Sepolia
        chainIdToEid[11_155_111] = 40_161;
        eidToChainId[40_161] = 11_155_111;
        // Arbitrum Sepolia
        chainIdToEid[421_614] = 40_231;
        eidToChainId[40_231] = 421_614;
        // Base Sepolia
        chainIdToEid[84_532] = 40_245;
        eidToChainId[40_245] = 84_532;
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
        uint32 dstEid = chainIdToEid[destinationChainId];
        require(dstEid != 0, "Unsupported chain");

        // Apply minimum gas limit and add safety buffer
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode full message with sender info
        bytes memory message = abi.encode(block.chainid, msg.sender, payload);

        // Build execution options with effective gas limit
        bytes memory options = OptionsBuilder.newOptions().
            // forge-lint: disable-next-line(unsafe-typecast)
            addExecutorLzReceiveOption(uint128(effectiveGasLimit), 0);

        ILayerZeroEndpointV2.MessagingParams memory params = ILayerZeroEndpointV2.MessagingParams({
            dstEid: dstEid, receiver: _addressToBytes32(target), message: message, options: options, payInLzToken: false
        });

        ILayerZeroEndpointV2.MessagingReceipt memory receipt = endpoint.send{ value: msg.value }(
            params,
            msg.sender // Refund excess to sender
        );

        messageId = receipt.guid;
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
        uint32 dstEid = chainIdToEid[destinationChainId];
        if (dstEid == 0) return 0;

        // Apply minimum gas limit and buffer for accurate estimation
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode message
        bytes memory message = abi.encode(block.chainid, address(0), payload);

        // Build options with effective gas limit
        bytes memory options = OptionsBuilder.newOptions().
            // forge-lint: disable-next-line(unsafe-typecast)
            addExecutorLzReceiveOption(uint128(effectiveGasLimit), 0);

        ILayerZeroEndpointV2.MessagingParams memory params = ILayerZeroEndpointV2.MessagingParams({
            dstEid: dstEid, receiver: bytes32(0), message: message, options: options, payInLzToken: false
        });

        ILayerZeroEndpointV2.MessagingFee memory messagingFee = endpoint.quote(params, address(this));
        return messagingFee.nativeFee;
    }

    /// @inheritdoc ICrossChainMessenger
    function isChainSupported(uint256 chainId) external view returns (bool) {
        return chainIdToEid[chainId] != 0;
    }

    /// @notice Set trusted peer on destination chain
    function setPeer(uint32 eid, address peer) external onlyOwner {
        peers[eid] = _addressToBytes32(peer);
        emit PeerSet(eid, peers[eid]);
    }

    /// @notice Add chain ID to LayerZero EID mapping
    function setChainMapping(uint256 chainId, uint32 eid) external onlyOwner {
        chainIdToEid[chainId] = eid;
        eidToChainId[eid] = chainId;
        emit ChainMappingSet(chainId, eid);
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

    function _addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}

/// @title LayerZeroReceiver
/// @notice OApp-compatible receiver for LayerZero V2 messages
/// @dev Implements lzReceive to process incoming cross-chain messages
///      Added message replay protection using GUID
///      C-3 : Converted to UUPS upgradeable. Deploy behind ERC1967Proxy
///      and call `initialize(...)`.
contract LayerZeroReceiver is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    /// @notice Delay before a newly-proposed trusted peer becomes active.
    /// @dev Mirrors `L2SlashingReceiver.SENDER_ACTIVATION_DELAY`. The peer mapping is THE
    ///      trust anchor for inbound slash messages: whoever it points at can forge a
    ///      slash of any operator. Making peer changes instant would let a compromised
    ///      owner repoint the anchor and inject a forged slash before any monitor could
    ///      react, defeating the receiver's own 2-day delay. The propose → wait → activate
    ///      flow keeps the asymmetry from re-opening.
    ///
    ///      DEPLOY-TIME NOTE: the activation delay only protects the *peer identity*. The
    ///      LayerZero security stack that authenticates the message itself — the DVN set
    ///      and executor configured for this OApp, plus the `endpoint` it trusts — MUST be
    ///      pinned to a known-good configuration at deploy time. A permissive DVN/executor
    ///      configuration lets an attacker satisfy `lzReceive`'s endpoint + peer checks
    ///      with a forged origin, which no activation delay on this contract can prevent.
    uint256 public constant SENDER_ACTIVATION_DELAY = 2 days;

    /// @custom:storage-location erc7201:tangle.beacon.bridges.LayerZeroReceiver
    struct LayerZeroReceiverStorage {
        address endpoint;
        ICrossChainReceiver receiver;
        // eid => peer as bytes32
        mapping(uint32 => bytes32) peers;
        // eid => evm chain id
        mapping(uint32 => uint256) eidToChainId;
        // GUID => processed
        mapping(bytes32 => bool) processedMessages;
        // eid => pending peer as bytes32
        mapping(uint32 => bytes32) pendingPeers;
        // eid => activation timestamp for the pending peer
        mapping(uint32 => uint256) pendingPeersAt;
        // Gap reduced from 50 → 48 to account for `pendingPeers` and `pendingPeersAt`
        // appended above (append-only layout, existing slots preserved).
        uint256[48] __gap;
    }

    /// @notice ERC-7201 slot:
    ///         keccak256(abi.encode(uint256(keccak256("tangle.beacon.bridges.LayerZeroReceiver")) - 1))
    ///         & ~bytes32(uint256(0xff))
    bytes32 private constant LAYERZERO_RECEIVER_SLOT =
        0xc8d6dbf6ee97b652bc4d9630ab7dd428f73833407c880bfe0821be2f767b3a00;

    function _getStorage() private pure returns (LayerZeroReceiverStorage storage $) {
        bytes32 s = LAYERZERO_RECEIVER_SLOT;
        assembly {
            $.slot := s
        }
    }

    /// @notice Events
    event MessageReceived(uint32 indexed srcEid, bytes32 sender, uint256 sourceChainId, address originalSender);
    /// @notice Emitted when a peer becomes active.
    event PeerSet(uint32 indexed eid, bytes32 indexed peer);
    /// @notice Emitted when a peer change is proposed (timelocked).
    event PeerScheduled(uint32 indexed eid, bytes32 indexed peer, uint256 activationTime);
    /// @notice Event emitted when a message is processed
    event MessageProcessed(bytes32 indexed guid, uint32 indexed srcEid, bytes32 sender);

    /// @notice Error for replayed messages
    error MessageAlreadyProcessed(bytes32 guid);
    error ZeroAddress();
    /// @notice Raised when activating a peer that was never proposed.
    error PeerNotPending();
    /// @notice Raised when activating a peer before its delay elapses.
    error PeerActivationTooEarly(uint256 activationTime);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _endpoint, address _receiver, address _owner) external initializer {
        if (_owner == address(0)) revert ZeroAddress();
        __UUPSUpgradeable_init();
        __Ownable_init(_owner);

        LayerZeroReceiverStorage storage $ = _getStorage();
        $.endpoint = _endpoint;
        $.receiver = ICrossChainReceiver(_receiver);

        // Initialize common mappings
        $.eidToChainId[30_101] = 1; // Ethereum
        $.eidToChainId[30_110] = 42_161; // Arbitrum
        $.eidToChainId[30_184] = 8453; // Base
        $.eidToChainId[40_161] = 11_155_111; // Sepolia
        $.eidToChainId[40_231] = 421_614; // Arbitrum Sepolia
        $.eidToChainId[40_245] = 84_532; // Base Sepolia
    }

    function endpoint() external view returns (address) {
        return _getStorage().endpoint;
    }

    function receiver() external view returns (ICrossChainReceiver) {
        return _getStorage().receiver;
    }

    function peers(uint32 eid) external view returns (bytes32) {
        return _getStorage().peers[eid];
    }

    function eidToChainId(uint32 eid) external view returns (uint256) {
        return _getStorage().eidToChainId[eid];
    }

    function processedMessages(bytes32 guid) external view returns (bool) {
        return _getStorage().processedMessages[guid];
    }

    /// @notice LayerZero V2 receive function
    /// @dev Called by the endpoint when a message arrives
    ///      Added GUID validation to prevent replay attacks
    function lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address, // _executor
        bytes calldata // _extraData
    )
        external
        payable
    {
        LayerZeroReceiverStorage storage $ = _getStorage();
        require(msg.sender == $.endpoint, "Only endpoint");

        // Verify sender is trusted peer
        require($.peers[_origin.srcEid] == _origin.sender, "Untrusted peer");

        // Check for replay attack using LayerZero's unique GUID
        if ($.processedMessages[_guid]) {
            revert MessageAlreadyProcessed(_guid);
        }

        // Mark message as processed before external call (CEI pattern)
        $.processedMessages[_guid] = true;

        // Decode message
        (uint256 sourceChainId, address originalSender, bytes memory payload) =
            abi.decode(_message, (uint256, address, bytes));

        // Verify chain ID matches
        require($.eidToChainId[_origin.srcEid] == sourceChainId, "Chain mismatch");

        emit MessageReceived(_origin.srcEid, _origin.sender, sourceChainId, originalSender);
        emit MessageProcessed(_guid, _origin.srcEid, _origin.sender);

        // Forward to receiver
        $.receiver.receiveMessage(sourceChainId, originalSender, payload);
    }

    function pendingPeers(uint32 eid) external view returns (bytes32) {
        return _getStorage().pendingPeers[eid];
    }

    function pendingPeersAt(uint32 eid) external view returns (uint256) {
        return _getStorage().pendingPeersAt[eid];
    }

    /// @notice Propose a trusted peer (timelocked) or clear one (immediate).
    /// @dev Trust-anchor changes are asymmetric on purpose, mirroring
    ///      `L2SlashingReceiver.setAuthorizedSender`:
    ///        - non-zero `peer` → schedules activation after `SENDER_ACTIVATION_DELAY`;
    ///          the peer is NOT trusted until `activatePeer` is called past the delay.
    ///        - `peer == bytes32(0)` → clears the peer immediately (defensive
    ///          de-authorization is never delayed).
    ///      This closes the asymmetry where the receiver delayed new senders but a
    ///      compromised messenger owner could repoint the peer instantly.
    function setPeer(uint32 eid, bytes32 peer) external onlyOwner {
        LayerZeroReceiverStorage storage $ = _getStorage();
        if (peer == bytes32(0)) {
            $.peers[eid] = bytes32(0);
            $.pendingPeers[eid] = bytes32(0);
            $.pendingPeersAt[eid] = 0;
            emit PeerSet(eid, bytes32(0));
            return;
        }
        uint256 activationTime = block.timestamp + SENDER_ACTIVATION_DELAY;
        $.pendingPeers[eid] = peer;
        $.pendingPeersAt[eid] = activationTime;
        emit PeerScheduled(eid, peer, activationTime);
    }

    /// @notice Activate a previously-proposed peer once its delay has elapsed.
    function activatePeer(uint32 eid) external onlyOwner {
        LayerZeroReceiverStorage storage $ = _getStorage();
        bytes32 peer = $.pendingPeers[eid];
        if (peer == bytes32(0)) revert PeerNotPending();
        if (block.timestamp < $.pendingPeersAt[eid]) revert PeerActivationTooEarly($.pendingPeersAt[eid]);

        $.peers[eid] = peer;
        $.pendingPeers[eid] = bytes32(0);
        $.pendingPeersAt[eid] = 0;
        emit PeerSet(eid, peer);
    }

    /// @notice Set chain mapping
    function setChainMapping(uint32 eid, uint256 chainId) external onlyOwner {
        _getStorage().eidToChainId[eid] = chainId;
    }

    /// @notice Check if a message GUID has been processed
    function isMessageProcessed(bytes32 guid) external view returns (bool) {
        return _getStorage().processedMessages[guid];
    }

    /// @inheritdoc UUPSUpgradeable
    /// @dev Owner-gated. Production owner should be a multisig / timelock.
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }
}

/// @notice LayerZero Origin struct
struct Origin {
    uint32 srcEid; // Source endpoint ID
    bytes32 sender; // Sender address as bytes32
    uint64 nonce; // Message nonce
}
