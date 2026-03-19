// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { LayerZeroAnchorBridge } from "../../src/shielded/LayerZeroAnchorBridge.sol";
import { ILayerZeroEndpointV2, Origin } from "../../src/beacon/bridges/LayerZeroCrossChainMessenger.sol";
import { IExecutor } from "protocol-solidity/interfaces/IExecutor.sol";

/// @title MockLZEndpoint
/// @notice Minimal mock of LayerZero V2 endpoint for testing send/receive flows.
contract MockLZEndpoint {
    uint64 public nonce;

    // Last send params (for assertions)
    uint32 public lastDstEid;
    bytes32 public lastReceiver;
    bytes public lastMessage;
    bytes public lastOptions;

    function send(
        ILayerZeroEndpointV2.MessagingParams calldata _params,
        address // _refundAddress
    )
        external
        payable
        returns (ILayerZeroEndpointV2.MessagingReceipt memory receipt)
    {
        nonce++;
        lastDstEid = _params.dstEid;
        lastReceiver = _params.receiver;
        lastMessage = _params.message;
        lastOptions = _params.options;

        receipt.guid = keccak256(abi.encodePacked(nonce, _params.dstEid, _params.receiver));
        receipt.nonce = nonce;
        receipt.fee = ILayerZeroEndpointV2.MessagingFee({ nativeFee: msg.value, lzTokenFee: 0 });
    }

    function quote(
        ILayerZeroEndpointV2.MessagingParams calldata,
        address
    )
        external
        pure
        returns (ILayerZeroEndpointV2.MessagingFee memory fee)
    {
        fee.nativeFee = 0.01 ether;
        fee.lzTokenFee = 0;
    }

    function setDelegate(address) external { }

    /// @notice Simulate delivering a message to a receiver (call lzReceive)
    function deliver(address receiver, Origin calldata origin, bytes32 guid, bytes calldata message) external {
        LayerZeroAnchorBridge(receiver).lzReceive(origin, guid, message, address(this), "");
    }
}

/// @title MockAnchorHandler
/// @notice Mimics AnchorHandler's onlyBridge + executeProposal pattern.
contract MockAnchorHandler {
    address public _bridgeAddress;

    bytes32 public lastResourceId;
    bytes public lastData;
    uint256 public executionCount;

    // Parsed updateEdge fields
    bytes4 public lastFuncSig;
    uint32 public lastLeafIndex;
    bytes32 public lastMerkleRoot;
    bytes32 public lastTargetResourceId;

    constructor(address bridge) {
        _bridgeAddress = bridge;
    }

    modifier onlyBridge() {
        require(msg.sender == _bridgeAddress, "HandlerHelpers: sender must be bridge contract");
        _;
    }

    function executeProposal(bytes32 resourceID, bytes calldata data) external onlyBridge {
        lastResourceId = resourceID;
        lastData = data;
        executionCount++;

        // Parse the data like AnchorHandler does
        lastFuncSig = bytes4(data[32:36]);
        if (lastFuncSig == bytes4(keccak256("updateEdge(uint256,uint32,bytes32)"))) {
            lastLeafIndex = uint32(bytes4(data[36:40]));
            lastMerkleRoot = bytes32(data[40:72]);
            lastTargetResourceId = bytes32(data[72:104]);
        }
    }

    function setResource(bytes32, address) external onlyBridge { }

    function migrateBridge(address newBridge) external onlyBridge {
        _bridgeAddress = newBridge;
    }
}

/// @title LayerZeroAnchorBridgeTest
contract LayerZeroAnchorBridgeTest is Test {
    LayerZeroAnchorBridge public bridge;
    MockLZEndpoint public lzEndpoint;
    MockAnchorHandler public handler;

    address public owner = address(this);
    address public relayer = makeAddr("relayer");

    uint256 public constant DEST_CHAIN_ID = 42_161; // Arbitrum
    uint32 public constant DEST_EID = 30_110;
    uint256 public constant SRC_CHAIN_ID = 1; // Ethereum
    uint32 public constant SRC_EID = 30_101;

    bytes32 public constant TEST_RESOURCE_ID = bytes32(uint256(0xabcdef));
    bytes32 public constant TEST_MERKLE_ROOT = bytes32(uint256(0x1234));
    uint32 public constant TEST_LEAF_INDEX = 42;

    function setUp() public {
        lzEndpoint = new MockLZEndpoint();

        // Pre-compute bridge address to set up circular dependency
        // Deploy a temporary handler first, then bridge, then real handler, then update
        address tempHandler = address(new MockAnchorHandler(address(1)));

        bridge = new LayerZeroAnchorBridge(address(lzEndpoint), tempHandler);

        // Deploy handler with bridge as the authorized bridge address
        handler = new MockAnchorHandler(address(bridge));

        // Set handler on bridge
        bridge.setHandler(address(handler));

        // Configure chain mappings and peers
        bridge.setChainMapping(DEST_CHAIN_ID, DEST_EID);
        bridge.setChainMapping(SRC_CHAIN_ID, SRC_EID);

        // Set peer (self-referential for testing)
        bytes32 peerAddr = bytes32(uint256(uint160(address(bridge))));
        bridge.setPeer(DEST_EID, peerAddr);
        bridge.setPeer(SRC_EID, peerAddr);
    }

    // -- Send tests --

    function test_relayMerkleRoot() public {
        bridge.relayMerkleRoot{ value: 0.1 ether }(DEST_CHAIN_ID, TEST_MERKLE_ROOT, TEST_LEAF_INDEX, TEST_RESOURCE_ID);

        assertEq(lzEndpoint.lastDstEid(), DEST_EID);
        assertEq(lzEndpoint.lastReceiver(), bytes32(uint256(uint160(address(bridge)))));
        assertTrue(lzEndpoint.lastMessage().length > 0);
    }

    function test_relayMerkleRoot_revertsUnsupportedChain() public {
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.UnsupportedChain.selector, uint256(999)));
        bridge.relayMerkleRoot{ value: 0.1 ether }(999, TEST_MERKLE_ROOT, TEST_LEAF_INDEX, TEST_RESOURCE_ID);
    }

    function test_estimateRelayFee() public view {
        uint256 fee = bridge.estimateRelayFee(DEST_CHAIN_ID, TEST_MERKLE_ROOT, TEST_LEAF_INDEX, TEST_RESOURCE_ID);
        assertEq(fee, 0.01 ether);
    }

    function test_estimateRelayFee_unsupportedChainReturnsZero() public view {
        uint256 fee = bridge.estimateRelayFee(999, TEST_MERKLE_ROOT, TEST_LEAF_INDEX, TEST_RESOURCE_ID);
        assertEq(fee, 0);
    }

    // -- Receive tests --

    function test_lzReceive_executesProposal() public {
        // Build the payload as the bridge would encode it
        bytes memory payload = _buildUpdateEdgePayload(TEST_RESOURCE_ID, TEST_MERKLE_ROOT, TEST_LEAF_INDEX);

        Origin memory origin = Origin({ srcEid: SRC_EID, sender: bytes32(uint256(uint160(address(bridge)))), nonce: 1 });

        bytes32 guid = keccak256("test-guid-1");

        // Deliver via the mock endpoint (so msg.sender == lzEndpoint)
        lzEndpoint.deliver(address(bridge), origin, guid, payload);

        // Verify handler received the proposal
        assertEq(handler.executionCount(), 1);
        assertEq(handler.lastResourceId(), TEST_RESOURCE_ID);
        assertEq(handler.lastFuncSig(), bytes4(keccak256("updateEdge(uint256,uint32,bytes32)")));
        assertEq(handler.lastLeafIndex(), TEST_LEAF_INDEX);
        assertEq(handler.lastMerkleRoot(), TEST_MERKLE_ROOT);
    }

    function test_lzReceive_replayProtection() public {
        bytes memory payload = _buildUpdateEdgePayload(TEST_RESOURCE_ID, TEST_MERKLE_ROOT, TEST_LEAF_INDEX);
        Origin memory origin = Origin({ srcEid: SRC_EID, sender: bytes32(uint256(uint160(address(bridge)))), nonce: 1 });
        bytes32 guid = keccak256("test-guid-replay");

        // First delivery succeeds
        lzEndpoint.deliver(address(bridge), origin, guid, payload);
        assertTrue(bridge.isMessageProcessed(guid));

        // Second delivery with same GUID reverts
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.MessageAlreadyProcessed.selector, guid));
        lzEndpoint.deliver(address(bridge), origin, guid, payload);
    }

    function test_lzReceive_rejectsUntrustedPeer() public {
        bytes memory payload = _buildUpdateEdgePayload(TEST_RESOURCE_ID, TEST_MERKLE_ROOT, TEST_LEAF_INDEX);
        bytes32 fakeSender = bytes32(uint256(0xdead));
        Origin memory origin = Origin({ srcEid: SRC_EID, sender: fakeSender, nonce: 1 });
        bytes32 guid = keccak256("test-guid-untrusted");

        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.UntrustedPeer.selector, SRC_EID, fakeSender));
        lzEndpoint.deliver(address(bridge), origin, guid, payload);
    }

    function test_lzReceive_rejectsNonEndpoint() public {
        bytes memory payload = _buildUpdateEdgePayload(TEST_RESOURCE_ID, TEST_MERKLE_ROOT, TEST_LEAF_INDEX);
        Origin memory origin = Origin({ srcEid: SRC_EID, sender: bytes32(uint256(uint160(address(bridge)))), nonce: 1 });
        bytes32 guid = keccak256("test-guid-nonendpoint");

        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.OnlyEndpoint.selector));
        bridge.lzReceive(origin, guid, payload, address(0), "");
    }

    // -- Roundtrip test --

    function test_sendThenReceive_roundtrip() public {
        // Send
        bridge.relayMerkleRoot{ value: 0.1 ether }(DEST_CHAIN_ID, TEST_MERKLE_ROOT, TEST_LEAF_INDEX, TEST_RESOURCE_ID);

        // The message that was sent to the endpoint
        bytes memory sentMessage = lzEndpoint.lastMessage();

        // Simulate receiving this message on the destination (same chain in test)
        Origin memory origin =
            Origin({ srcEid: DEST_EID, sender: bytes32(uint256(uint160(address(bridge)))), nonce: 1 });
        bytes32 guid = keccak256("roundtrip-guid");

        lzEndpoint.deliver(address(bridge), origin, guid, sentMessage);

        // The handler should have parsed the updateEdge correctly
        assertEq(handler.executionCount(), 1);
        assertEq(handler.lastMerkleRoot(), TEST_MERKLE_ROOT);
        assertEq(handler.lastLeafIndex(), TEST_LEAF_INDEX);
    }

    // -- Admin tests --

    function test_setPeer() public {
        bytes32 newPeer = bytes32(uint256(0xcafe));
        bridge.setPeer(DEST_EID, newPeer);
        assertEq(bridge.peers(DEST_EID), newPeer);
    }

    function test_setChainMapping() public {
        bridge.setChainMapping(137, 30_109);
        assertEq(bridge.chainToEid(137), 30_109);
        assertEq(bridge.eidToChain(30_109), 137);
    }

    function test_setHandler() public {
        address newHandler = makeAddr("newHandler");
        bridge.setHandler(newHandler);
        assertEq(bridge.handler(), newHandler);
    }

    function test_setHandler_revertsZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.ZeroAddress.selector));
        bridge.setHandler(address(0));
    }

    function test_transferOwnership_setsPending() public {
        address newOwner = makeAddr("newOwner");
        bridge.transferOwnership(newOwner);
        // Two-step: owner should NOT change yet
        assertEq(bridge.owner(), owner);
        assertEq(bridge.pendingOwner(), newOwner);
    }

    function test_transferOwnership_revertsZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.ZeroAddress.selector));
        bridge.transferOwnership(address(0));
    }

    function test_onlyOwner_reverts() public {
        vm.prank(makeAddr("nobody"));
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.OnlyOwner.selector));
        bridge.setPeer(DEST_EID, bytes32(0));
    }

    function test_setDstGasLimit() public {
        bridge.setDstGasLimit(500_000);
        assertEq(bridge.dstGasLimit(), 500_000);
    }

    // -- addEdge tests --

    function test_addEdge() public {
        uint256 newChainId = 10; // Optimism
        uint32 newEid = 30_111;
        bytes32 peer = bytes32(uint256(0xcafe));
        bytes32 merkleRoot = bytes32(uint256(0xbeef));
        uint32 leafIndex = 7;
        bytes32 resourceId = bytes32(uint256(0xfeed));

        bridge.addEdge(newChainId, newEid, peer, merkleRoot, leafIndex, resourceId);

        // Verify chain mapping
        assertEq(bridge.chainToEid(newChainId), newEid);
        assertEq(bridge.eidToChain(newEid), newChainId);

        // Verify peer set
        assertEq(bridge.peers(newEid), peer);

        // Verify handler received executeProposal
        assertEq(handler.lastResourceId(), resourceId);
        assertEq(handler.lastMerkleRoot(), merkleRoot);
        assertEq(handler.lastLeafIndex(), leafIndex);
    }

    function test_addEdge_zeroPeer() public {
        uint256 newChainId = 10;
        uint32 newEid = 30_111;
        bytes32 merkleRoot = bytes32(uint256(0xbeef));
        uint32 leafIndex = 7;
        bytes32 resourceId = bytes32(uint256(0xfeed));

        bridge.addEdge(newChainId, newEid, bytes32(0), merkleRoot, leafIndex, resourceId);

        // Chain mapping should be set
        assertEq(bridge.chainToEid(newChainId), newEid);
        assertEq(bridge.eidToChain(newEid), newChainId);

        // Peer should NOT be set (manual-only mode)
        assertEq(bridge.peers(newEid), bytes32(0));

        // Handler still received the proposal
        assertEq(handler.lastResourceId(), resourceId);
    }

    function test_addEdge_onlyOwner() public {
        vm.prank(makeAddr("nobody"));
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.OnlyOwner.selector));
        bridge.addEdge(10, 30_111, bytes32(uint256(0xcafe)), bytes32(uint256(0xbeef)), 7, bytes32(uint256(0xfeed)));
    }

    function test_addEdge_multipleChainsSequential() public {
        uint256[3] memory chainIds = [uint256(10), uint256(137), uint256(8453)];
        uint32[3] memory eids = [uint32(30_111), uint32(30_109), uint32(30_184)];
        bytes32[3] memory peersArr = [bytes32(uint256(0xaa)), bytes32(uint256(0xbb)), bytes32(uint256(0xcc))];

        for (uint256 i = 0; i < 3; i++) {
            bridge.addEdge(
                chainIds[i], eids[i], peersArr[i], bytes32(uint256(i + 1)), uint32(i), bytes32(uint256(0xf0 + i))
            );
        }

        for (uint256 i = 0; i < 3; i++) {
            assertEq(bridge.chainToEid(chainIds[i]), eids[i]);
            assertEq(bridge.eidToChain(eids[i]), chainIds[i]);
            assertEq(bridge.peers(eids[i]), peersArr[i]);
        }

        // Handler should have been called 3 times
        assertEq(handler.executionCount(), 3);
    }

    // -- directUpdateEdge tests --

    function test_directUpdateEdge() public {
        bytes32 merkleRoot = bytes32(uint256(0x9999));
        uint32 leafIndex = 55;
        bytes32 resourceId = bytes32(uint256(0xaaaa));

        bridge.directUpdateEdge(merkleRoot, leafIndex, resourceId);

        assertEq(handler.lastResourceId(), resourceId);
        assertEq(handler.lastMerkleRoot(), merkleRoot);
        assertEq(handler.lastLeafIndex(), leafIndex);
        assertEq(handler.executionCount(), 1);
    }

    function test_directUpdateEdge_onlyOwner() public {
        vm.prank(makeAddr("nobody"));
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.OnlyOwner.selector));
        bridge.directUpdateEdge(bytes32(uint256(1)), 1, bytes32(uint256(1)));
    }

    // -- Two-step ownership transfer tests --

    function test_twoStepOwnership_transferAndAccept() public {
        address newOwner = makeAddr("newOwner");

        bridge.transferOwnership(newOwner);

        // Owner should NOT have changed yet
        assertEq(bridge.owner(), owner);
        assertEq(bridge.pendingOwner(), newOwner);

        // Accept ownership
        vm.prank(newOwner);
        bridge.acceptOwnership();

        assertEq(bridge.owner(), newOwner);
        assertEq(bridge.pendingOwner(), address(0));
    }

    function test_twoStepOwnership_acceptRevertsNonPending() public {
        address newOwner = makeAddr("newOwner");
        bridge.transferOwnership(newOwner);

        // Random address cannot accept
        vm.prank(makeAddr("random"));
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.NotPendingOwner.selector));
        bridge.acceptOwnership();
    }

    function test_twoStepOwnership_oldOwnerRetainsUntilAccepted() public {
        address newOwner = makeAddr("newOwner");
        bridge.transferOwnership(newOwner);

        // Old owner can still do admin operations
        bridge.setDstGasLimit(300_000);
        assertEq(bridge.dstGasLimit(), 300_000);

        // New owner cannot do admin operations until they accept
        vm.prank(newOwner);
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.OnlyOwner.selector));
        bridge.setDstGasLimit(400_000);
    }

    function test_twoStepOwnership_canOverridePending() public {
        address newOwner1 = makeAddr("newOwner1");
        address newOwner2 = makeAddr("newOwner2");

        bridge.transferOwnership(newOwner1);
        assertEq(bridge.pendingOwner(), newOwner1);

        // Override with a different pending owner
        bridge.transferOwnership(newOwner2);
        assertEq(bridge.pendingOwner(), newOwner2);

        // newOwner1 can no longer accept
        vm.prank(newOwner1);
        vm.expectRevert(abi.encodeWithSelector(LayerZeroAnchorBridge.NotPendingOwner.selector));
        bridge.acceptOwnership();

        // newOwner2 can accept
        vm.prank(newOwner2);
        bridge.acceptOwnership();
        assertEq(bridge.owner(), newOwner2);
    }

    // -- Helpers --

    function _buildUpdateEdgePayload(
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
