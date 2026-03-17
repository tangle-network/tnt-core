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

        // Deploy bridge first (need address for handler)
        // Use CREATE2-style: deploy bridge, then handler pointing to bridge
        bridge = new LayerZeroAnchorBridge(address(lzEndpoint), address(0));

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

    function test_transferOwnership() public {
        address newOwner = makeAddr("newOwner");
        bridge.transferOwnership(newOwner);
        assertEq(bridge.owner(), newOwner);
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
