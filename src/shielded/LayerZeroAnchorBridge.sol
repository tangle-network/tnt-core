// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ILayerZeroAnchorBridge } from "./ILayerZeroAnchorBridge.sol";
import { ILayerZeroEndpointV2, OptionsBuilder, Origin } from "../beacon/bridges/LayerZeroCrossChainMessenger.sol";
import { IExecutor } from "protocol-solidity/interfaces/IExecutor.sol";

/// @title LayerZeroAnchorBridge
/// @notice Replaces SignatureBridge for the VAnchor system using LayerZero V2.
/// @dev This contract acts as the "bridge" that AnchorHandler expects. On receive,
///      it calls `handler.executeProposal()` with properly encoded updateEdge data.
///      AnchorHandler checks `msg.sender == _bridgeAddress`, so this contract must be
///      set as the bridge address in AnchorHandler's constructor.
contract LayerZeroAnchorBridge is ILayerZeroAnchorBridge {
    using OptionsBuilder for bytes;

    // -- Immutables --

    /// @notice LayerZero V2 Endpoint
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ILayerZeroEndpointV2 public immutable lzEndpoint;

    // -- State --

    /// @notice Owner / admin
    address public owner;

    /// @notice AnchorHandler that executes proposals
    address public handler;

    /// @notice EVM chain ID -> LayerZero endpoint ID
    mapping(uint256 => uint32) public chainToEid;

    /// @notice LayerZero endpoint ID -> EVM chain ID
    mapping(uint32 => uint256) public eidToChain;

    /// @notice Trusted peer bridges on other chains (eid -> peer address as bytes32)
    mapping(uint32 => bytes32) public peers;

    /// @notice Processed message GUIDs for replay protection
    mapping(bytes32 => bool) public processedMessages;

    /// @notice Gas limit for lzReceive execution on destination
    uint128 public dstGasLimit = 200_000;

    /// @notice Pending owner for two-step ownership transfer
    address public pendingOwner;

    // -- Errors --

    error OnlyOwner();
    error OnlyEndpoint();
    error UntrustedPeer(uint32 srcEid, bytes32 sender);
    error UnsupportedChain(uint256 chainId);
    error MessageAlreadyProcessed(bytes32 guid);
    error ZeroAddress();
    error NotPendingOwner();

    // -- Events --

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    // -- Constructor --

    /// @param _lzEndpoint LayerZero V2 endpoint address
    /// @param _handler AnchorHandler address (this contract must be the bridge in AnchorHandler)
    constructor(address _lzEndpoint, address _handler) {
        require(_lzEndpoint != address(0), "LZ endpoint zero");
        require(_handler != address(0), "handler zero");
        lzEndpoint = ILayerZeroEndpointV2(_lzEndpoint);
        handler = _handler;
        owner = msg.sender;
    }

    // -- Modifiers --

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    // -- Send --

    /// @inheritdoc ILayerZeroAnchorBridge
    function relayMerkleRoot(
        uint256 destChainId,
        bytes32 merkleRoot,
        uint32 leafIndex,
        bytes32 targetResourceId
    )
        external
        payable
        onlyOwner
    {
        uint32 dstEid = chainToEid[destChainId];
        if (dstEid == 0) revert UnsupportedChain(destChainId);

        bytes memory payload = _encodeUpdateEdge(targetResourceId, merkleRoot, leafIndex);
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(dstGasLimit, 0);

        ILayerZeroEndpointV2.MessagingParams memory params = ILayerZeroEndpointV2.MessagingParams({
            dstEid: dstEid, receiver: peers[dstEid], message: payload, options: options, payInLzToken: false
        });

        ILayerZeroEndpointV2.MessagingReceipt memory receipt = lzEndpoint.send{ value: msg.value }(params, msg.sender);

        emit MerkleRootRelayed(destChainId, merkleRoot, leafIndex, targetResourceId, receipt.guid);
    }

    /// @inheritdoc ILayerZeroAnchorBridge
    function estimateRelayFee(
        uint256 destChainId,
        bytes32 merkleRoot,
        uint32 leafIndex,
        bytes32 targetResourceId
    )
        external
        view
        returns (uint256 fee)
    {
        uint32 dstEid = chainToEid[destChainId];
        if (dstEid == 0) return 0;

        bytes memory payload = _encodeUpdateEdge(targetResourceId, merkleRoot, leafIndex);
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(dstGasLimit, 0);

        ILayerZeroEndpointV2.MessagingParams memory params = ILayerZeroEndpointV2.MessagingParams({
            dstEid: dstEid, receiver: peers[dstEid], message: payload, options: options, payInLzToken: false
        });

        ILayerZeroEndpointV2.MessagingFee memory msgFee = lzEndpoint.quote(params, address(this));
        return msgFee.nativeFee;
    }

    // -- Receive --

    /// @notice LayerZero V2 receive entrypoint. Called by the LZ endpoint when a
    ///         cross-chain message arrives. Decodes the updateEdge proposal data and
    ///         forwards it to AnchorHandler.executeProposal().
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
        if (msg.sender != address(lzEndpoint)) revert OnlyEndpoint();
        if (peers[_origin.srcEid] != _origin.sender) revert UntrustedPeer(_origin.srcEid, _origin.sender);
        if (processedMessages[_guid]) revert MessageAlreadyProcessed(_guid);

        // Mark processed before external call (CEI)
        processedMessages[_guid] = true;

        // The message IS the executeProposal data (resourceId + functionSig + args)
        // Forward directly to handler
        bytes32 resourceId = bytes32(_message[0:32]);
        IExecutor(handler).executeProposal(resourceId, _message);

        emit MerkleRootReceived(
            _origin.srcEid,
            bytes32(_message[36 + 4:36 + 36]), // merkleRoot from args
            uint32(bytes4(_message[36:40])), // nonce/leafIndex from args
            resourceId
        );
    }

    // -- Admin --

    /// @inheritdoc ILayerZeroAnchorBridge
    function setPeer(uint32 eid, bytes32 peer) external onlyOwner {
        peers[eid] = peer;
        emit PeerSet(eid, peer);
    }

    /// @inheritdoc ILayerZeroAnchorBridge
    function setChainMapping(uint256 chainId, uint32 eid) external onlyOwner {
        chainToEid[chainId] = eid;
        eidToChain[eid] = chainId;
        emit ChainMappingSet(chainId, eid);
    }

    /// @inheritdoc ILayerZeroAnchorBridge
    function setHandler(address _handler) external onlyOwner {
        if (_handler == address(0)) revert ZeroAddress();
        address old = handler;
        handler = _handler;
        emit HandlerUpdated(old, _handler);
    }

    /// @notice Add a new cross-chain edge in one call.
    ///         Configures chain mapping + peer + pushes the initial merkle root
    ///         to the local VAnchor — everything needed for a new chain connection.
    /// @param chainId         EVM chain ID of the new chain
    /// @param eid             LayerZero endpoint ID of the new chain
    /// @param peer            Address of the LayerZeroAnchorBridge on the new chain (bytes32)
    /// @param merkleRoot      Current merkle root of the remote VAnchor
    /// @param leafIndex       Current leaf index of the remote VAnchor
    /// @param srcResourceID   Resource ID of the remote VAnchor
    function addEdge(
        uint256 chainId,
        uint32 eid,
        bytes32 peer,
        bytes32 merkleRoot,
        uint32 leafIndex,
        bytes32 srcResourceID
    )
        external
        onlyOwner
    {
        // 1. Set chain mapping (EVM chain ID ↔ LZ endpoint ID)
        chainToEid[chainId] = eid;
        eidToChain[eid] = chainId;
        emit ChainMappingSet(chainId, eid);

        // 2. Set trusted peer (if non-zero — zero means manual-only, no LZ relay)
        if (peer != bytes32(0)) {
            peers[eid] = peer;
            emit PeerSet(eid, peer);
        }

        // 3. Push initial merkle root to the local VAnchor
        bytes memory data = _encodeUpdateEdge(srcResourceID, merkleRoot, leafIndex);
        IExecutor(handler).executeProposal(srcResourceID, data);

        emit DirectEdgeUpdate(merkleRoot, leafIndex, srcResourceID);
    }

    /// @notice Push a merkle root directly to the local VAnchor without LayerZero.
    ///         For manual root updates by the multisig on chains without full LZ relay.
    function directUpdateEdge(bytes32 merkleRoot, uint32 leafIndex, bytes32 srcResourceID) external onlyOwner {
        bytes memory data = _encodeUpdateEdge(srcResourceID, merkleRoot, leafIndex);
        IExecutor(handler).executeProposal(srcResourceID, data);
        emit DirectEdgeUpdate(merkleRoot, leafIndex, srcResourceID);
    }

    /// @notice Set gas limit for destination chain execution
    function setDstGasLimit(uint128 _gasLimit) external onlyOwner {
        dstGasLimit = _gasLimit;
    }

    /// @notice Start two-step ownership transfer
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner, newOwner);
    }

    /// @notice Accept ownership (must be called by the pending owner)
    function acceptOwnership() external {
        if (msg.sender != pendingOwner) revert NotPendingOwner();
        address oldOwner = owner;
        owner = pendingOwner;
        pendingOwner = address(0);
        emit OwnershipTransferStarted(oldOwner, msg.sender);
    }

    /// @notice Check if a message GUID has been processed
    function isMessageProcessed(bytes32 guid) external view returns (bool) {
        return processedMessages[guid];
    }

    // -- Internal --

    /// @dev Encode the data blob that AnchorHandler.executeProposal expects for updateEdge.
    ///      Format: resourceId (32) | functionSig (4) | nonce/leafIndex (4) | merkleRoot (32) | target/resourceId (32)
    function _encodeUpdateEdge(
        bytes32 resourceId,
        bytes32 merkleRoot,
        uint32 leafIndex
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes4 funcSig = bytes4(keccak256("updateEdge(uint256,uint32,bytes32)"));
        return abi.encodePacked(resourceId, funcSig, leafIndex, merkleRoot, resourceId);
    }
}
