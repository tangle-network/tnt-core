// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ICrossChainMessenger, ICrossChainReceiver} from "../interfaces/ICrossChainMessenger.sol";

/// @title LayerZeroCrossChainMessenger
/// @notice ICrossChainMessenger implementation for LayerZero V2
/// @dev Uses LayerZero's OApp architecture for cross-chain messaging
/// Supports any LayerZero-connected chain including Tempo, Ethereum, Arbitrum, etc.

/// @notice LayerZero V2 Endpoint interface
interface ILayerZeroEndpointV2 {
    struct MessagingParams {
        uint32 dstEid;           // Destination endpoint ID
        bytes32 receiver;         // Receiver address as bytes32
        bytes message;            // Message payload
        bytes options;            // Execution options
        bool payInLzToken;        // Pay in LZ token vs native
    }

    struct MessagingReceipt {
        bytes32 guid;             // Global unique identifier
        uint64 nonce;             // Message nonce
        MessagingFee fee;         // Fee paid
    }

    struct MessagingFee {
        uint256 nativeFee;        // Fee in native token
        uint256 lzTokenFee;       // Fee in LZ token
    }

    /// @notice Send message to another chain
    function send(
        MessagingParams calldata _params,
        address _refundAddress
    ) external payable returns (MessagingReceipt memory);

    /// @notice Estimate fee for sending message
    function quote(
        MessagingParams calldata _params,
        address _sender
    ) external view returns (MessagingFee memory);

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
    ) internal pure returns (bytes memory) {
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

    /// @notice M-12 FIX: Minimum gas limit for destination chain execution
    uint256 public minGasLimit = 100_000;

    /// @notice M-12 FIX: Gas buffer percentage (in basis points, 10000 = 100%)
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
        chainIdToEid[1] = 30101;
        eidToChainId[30101] = 1;
        // Arbitrum One
        chainIdToEid[42161] = 30110;
        eidToChainId[30110] = 42161;
        // Base
        chainIdToEid[8453] = 30184;
        eidToChainId[30184] = 8453;
        // Sepolia
        chainIdToEid[11155111] = 40161;
        eidToChainId[40161] = 11155111;
        // Arbitrum Sepolia
        chainIdToEid[421614] = 40231;
        eidToChainId[40231] = 421614;
        // Base Sepolia
        chainIdToEid[84532] = 40245;
        eidToChainId[40245] = 84532;
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
    ) external payable returns (bytes32 messageId) {
        uint32 dstEid = chainIdToEid[destinationChainId];
        require(dstEid != 0, "Unsupported chain");

        // M-12 FIX: Apply minimum gas limit and add safety buffer
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode full message with sender info
        bytes memory message = abi.encode(block.chainid, msg.sender, payload);

        // Build execution options with effective gas limit
        bytes memory options = OptionsBuilder.newOptions()
            // forge-lint: disable-next-line(unsafe-typecast)
            .addExecutorLzReceiveOption(uint128(effectiveGasLimit), 0);

        ILayerZeroEndpointV2.MessagingParams memory params = ILayerZeroEndpointV2.MessagingParams({
            dstEid: dstEid,
            receiver: _addressToBytes32(target),
            message: message,
            options: options,
            payInLzToken: false
        });

        ILayerZeroEndpointV2.MessagingReceipt memory receipt = endpoint.send{value: msg.value}(
            params,
            msg.sender // Refund excess to sender
        );

        messageId = receipt.guid;
    }

    /// @inheritdoc ICrossChainMessenger
    /// @dev M-12 FIX: Fee estimation now includes gas buffer for accurate cost
    function estimateFee(
        uint256 destinationChainId,
        bytes calldata payload,
        uint256 gasLimit
    ) external view returns (uint256 fee) {
        uint32 dstEid = chainIdToEid[destinationChainId];
        if (dstEid == 0) return 0;

        // M-12 FIX: Apply minimum gas limit and buffer for accurate estimation
        uint256 effectiveGasLimit = _applyGasLimitWithBuffer(gasLimit);

        // Encode message
        bytes memory message = abi.encode(block.chainid, address(0), payload);

        // Build options with effective gas limit
        bytes memory options = OptionsBuilder.newOptions()
            // forge-lint: disable-next-line(unsafe-typecast)
            .addExecutorLzReceiveOption(uint128(effectiveGasLimit), 0);

        ILayerZeroEndpointV2.MessagingParams memory params = ILayerZeroEndpointV2.MessagingParams({
            dstEid: dstEid,
            receiver: bytes32(0),
            message: message,
            options: options,
            payInLzToken: false
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

    /// @notice M-12 FIX: Set minimum gas limit for destination chain execution
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

    function _addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}

/// @title LayerZeroReceiver
/// @notice OApp-compatible receiver for LayerZero V2 messages
/// @dev Implements lzReceive to process incoming cross-chain messages
///      M-12 FIX: Added message replay protection using GUID
contract LayerZeroReceiver {
    /// @notice LayerZero V2 Endpoint
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable endpoint;

    /// @notice The actual message receiver
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ICrossChainReceiver public immutable receiver;

    /// @notice Trusted peers (eid => peer as bytes32)
    mapping(uint32 => bytes32) public peers;

    /// @notice Mapping from LayerZero EID to chain ID
    mapping(uint32 => uint256) public eidToChainId;

    /// @notice Owner
    address public owner;

    /// @notice M-12 FIX: Track processed message GUIDs to prevent replay attacks
    /// @dev LayerZero provides unique GUIDs for each message
    mapping(bytes32 => bool) public processedMessages;

    /// @notice Events
    event MessageReceived(uint32 indexed srcEid, bytes32 sender, uint256 sourceChainId, address originalSender);
    /// @notice M-12 FIX: Event emitted when a message is processed
    event MessageProcessed(bytes32 indexed guid, uint32 indexed srcEid, bytes32 sender);

    /// @notice M-12 FIX: Error for replayed messages
    error MessageAlreadyProcessed(bytes32 guid);

    constructor(address _endpoint, address _receiver) {
        endpoint = _endpoint;
        receiver = ICrossChainReceiver(_receiver);
        owner = msg.sender;

        // Initialize common mappings
        eidToChainId[30101] = 1;        // Ethereum
        eidToChainId[30110] = 42161;    // Arbitrum
        eidToChainId[30184] = 8453;     // Base
        eidToChainId[40161] = 11155111; // Sepolia
        eidToChainId[40231] = 421614;   // Arbitrum Sepolia
        eidToChainId[40245] = 84532;    // Base Sepolia
    }

    modifier onlyOwner() {
        _receiverOnlyOwner();
        _;
    }

    function _receiverOnlyOwner() internal view {
        require(msg.sender == owner, "Only owner");
    }

    /// @notice LayerZero V2 receive function
    /// @dev Called by the endpoint when a message arrives
    ///      M-12 FIX: Added GUID validation to prevent replay attacks
    function lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address, // _executor
        bytes calldata // _extraData
    ) external payable {
        require(msg.sender == endpoint, "Only endpoint");

        // Verify sender is trusted peer
        require(peers[_origin.srcEid] == _origin.sender, "Untrusted peer");

        // M-12 FIX: Check for replay attack using LayerZero's unique GUID
        if (processedMessages[_guid]) {
            revert MessageAlreadyProcessed(_guid);
        }

        // M-12 FIX: Mark message as processed before external call (CEI pattern)
        processedMessages[_guid] = true;

        // Decode message
        (uint256 sourceChainId, address originalSender, bytes memory payload) =
            abi.decode(_message, (uint256, address, bytes));

        // Verify chain ID matches
        require(eidToChainId[_origin.srcEid] == sourceChainId, "Chain mismatch");

        emit MessageReceived(_origin.srcEid, _origin.sender, sourceChainId, originalSender);
        emit MessageProcessed(_guid, _origin.srcEid, _origin.sender);

        // Forward to receiver
        receiver.receiveMessage(sourceChainId, originalSender, payload);
    }

    /// @notice Set trusted peer
    function setPeer(uint32 eid, bytes32 peer) external onlyOwner {
        peers[eid] = peer;
    }

    /// @notice Set chain mapping
    function setChainMapping(uint32 eid, uint256 chainId) external onlyOwner {
        eidToChainId[eid] = chainId;
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    /// @notice M-12 FIX: Check if a message GUID has been processed
    /// @param guid The LayerZero message GUID to check
    /// @return True if the message has been processed
    function isMessageProcessed(bytes32 guid) external view returns (bool) {
        return processedMessages[guid];
    }
}

/// @notice LayerZero Origin struct
struct Origin {
    uint32 srcEid;      // Source endpoint ID
    bytes32 sender;     // Sender address as bytes32
    uint64 nonce;       // Message nonce
}
