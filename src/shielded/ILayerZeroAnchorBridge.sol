// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ILayerZeroAnchorBridge
/// @notice Interface for the LayerZero V2-based anchor bridge that replaces SignatureBridge
///         for cross-chain merkle root relay in the VAnchor system.
interface ILayerZeroAnchorBridge {
    /// @notice Emitted when a merkle root update is sent to a destination chain
    event MerkleRootRelayed(
        uint256 indexed destChainId, bytes32 merkleRoot, uint32 leafIndex, bytes32 resourceId, bytes32 messageId
    );

    /// @notice Emitted when a merkle root update is received from a source chain
    event MerkleRootReceived(uint32 indexed srcEid, bytes32 merkleRoot, uint32 leafIndex, bytes32 resourceId);

    /// @notice Emitted when a peer is set for a destination endpoint
    event PeerSet(uint32 indexed eid, bytes32 peer);

    /// @notice Emitted when a chain mapping is configured
    event ChainMappingSet(uint256 indexed chainId, uint32 indexed eid);

    /// @notice Emitted when the handler address is updated
    event HandlerUpdated(address indexed oldHandler, address indexed newHandler);

    /// @notice Emitted when a direct edge update is submitted by the multisig owner
    event DirectEdgeUpdate(bytes32 merkleRoot, uint32 leafIndex, bytes32 srcResourceID);

    /// @notice Add a new cross-chain edge in one call: chain mapping + peer + initial root push.
    function addEdge(
        uint256 chainId,
        uint32 eid,
        bytes32 peer,
        bytes32 merkleRoot,
        uint32 leafIndex,
        bytes32 srcResourceID
    )
        external;

    /// @notice Push a merkle root directly without LayerZero (manual multisig updates).
    function directUpdateEdge(bytes32 merkleRoot, uint32 leafIndex, bytes32 srcResourceID) external;

    /// @notice Relay a merkle root update to another chain via LayerZero
    /// @param destChainId EVM chain ID of the destination
    /// @param merkleRoot The new merkle root to relay
    /// @param leafIndex The latest leaf index
    /// @param targetResourceId The resource ID on the destination chain
    function relayMerkleRoot(
        uint256 destChainId,
        bytes32 merkleRoot,
        uint32 leafIndex,
        bytes32 targetResourceId
    )
        external
        payable;

    /// @notice Estimate the LayerZero fee for relaying a merkle root update
    /// @param destChainId EVM chain ID of the destination
    /// @param merkleRoot The merkle root to relay
    /// @param leafIndex The latest leaf index
    /// @param targetResourceId The resource ID on the destination chain
    /// @return fee The estimated native fee
    function estimateRelayFee(
        uint256 destChainId,
        bytes32 merkleRoot,
        uint32 leafIndex,
        bytes32 targetResourceId
    )
        external
        view
        returns (uint256 fee);

    /// @notice Set trusted peer bridge on another chain
    /// @param eid LayerZero endpoint ID of the peer
    /// @param peer Address of the peer bridge (as bytes32)
    function setPeer(uint32 eid, bytes32 peer) external;

    /// @notice Set EVM chain ID to LayerZero endpoint ID mapping
    /// @param chainId EVM chain ID
    /// @param eid LayerZero endpoint ID
    function setChainMapping(uint256 chainId, uint32 eid) external;

    /// @notice Set the AnchorHandler address
    /// @param handler The AnchorHandler contract address
    function setHandler(address handler) external;
}
