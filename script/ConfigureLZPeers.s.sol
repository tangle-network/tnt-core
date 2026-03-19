// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";

/// @notice Minimal interface for LayerZeroAnchorBridge admin functions
interface ILZBridge {
    function setPeer(uint32 eid, bytes32 peer) external;
    function setChainMapping(uint256 chainId, uint32 eid) external;
    function setDstGasLimit(uint128 gasLimit) external;
    function peers(uint32 eid) external view returns (bytes32);
    function chainToEid(uint256 chainId) external view returns (uint32);
}

/// @title ConfigureLZPeers
/// @notice Configure LayerZero cross-chain peers for an 8-chain VAnchor bridge.
///
/// Registers chain mappings (EVM chain ID ↔ LZ endpoint ID) and trusted peers
/// (the LayerZeroAnchorBridge contract address on each remote chain).
///
/// @dev All 8 chains use the same LZ V2 EndpointV2 address:
///      Mainnet: 0x1a44076050125825900e736c501f859c50fE728c
///      Testnet: 0x6EDCE65403992e310A62460808c4b910D972f10f
///
/// Usage:
///   BRIDGE=0x... \
///   PEER_ETHEREUM=0x... PEER_ARBITRUM=0x... PEER_BASE=0x... \
///   PEER_OPTIMISM=0x... PEER_POLYGON=0x... PEER_BSC=0x... \
///   PEER_AVALANCHE=0x... PEER_SCROLL=0x... \
///   forge script script/ConfigureLZPeers.s.sol:ConfigureLZPeers \
///     --rpc-url $RPC_URL --broadcast
contract ConfigureLZPeers is Script {
    // ─── Top 8 EVM chains by activity ──────────────────────────────────
    // Ranked by TVL + LayerZero message volume

    // Chain IDs
    uint256 constant ETHEREUM = 1;
    uint256 constant ARBITRUM = 42161;
    uint256 constant BASE = 8453;
    uint256 constant OPTIMISM = 10;
    uint256 constant POLYGON = 137;
    uint256 constant BSC = 56;
    uint256 constant AVALANCHE = 43114;
    uint256 constant HYPERLIQUID = 999;

    // LayerZero V2 Endpoint IDs (mainnet)
    uint32 constant EID_ETHEREUM = 30101;
    uint32 constant EID_ARBITRUM = 30110;
    uint32 constant EID_BASE = 30184;
    uint32 constant EID_OPTIMISM = 30111;
    uint32 constant EID_POLYGON = 30109;
    uint32 constant EID_BSC = 30102;
    uint32 constant EID_AVALANCHE = 30106;
    uint32 constant EID_HYPERLIQUID = 30367;

    function run() external {
        address bridgeAddr = vm.envAddress("BRIDGE");
        ILZBridge bridge = ILZBridge(bridgeAddr);

        console2.log("Configuring LZ peers for bridge:", bridgeAddr);
        console2.log("Chain ID:", block.chainid);

        vm.startBroadcast();

        // Register all chain mappings
        _setMapping(bridge, ETHEREUM, EID_ETHEREUM);
        _setMapping(bridge, ARBITRUM, EID_ARBITRUM);
        _setMapping(bridge, BASE, EID_BASE);
        _setMapping(bridge, OPTIMISM, EID_OPTIMISM);
        _setMapping(bridge, POLYGON, EID_POLYGON);
        _setMapping(bridge, BSC, EID_BSC);
        _setMapping(bridge, AVALANCHE, EID_AVALANCHE);
        _setMapping(bridge, HYPERLIQUID, EID_HYPERLIQUID);

        // Register peers from env vars (skip if not set)
        _setPeerFromEnv(bridge, EID_ETHEREUM, "PEER_ETHEREUM");
        _setPeerFromEnv(bridge, EID_ARBITRUM, "PEER_ARBITRUM");
        _setPeerFromEnv(bridge, EID_BASE, "PEER_BASE");
        _setPeerFromEnv(bridge, EID_OPTIMISM, "PEER_OPTIMISM");
        _setPeerFromEnv(bridge, EID_POLYGON, "PEER_POLYGON");
        _setPeerFromEnv(bridge, EID_BSC, "PEER_BSC");
        _setPeerFromEnv(bridge, EID_AVALANCHE, "PEER_AVALANCHE");
        _setPeerFromEnv(bridge, EID_HYPERLIQUID, "PEER_HYPERLIQUID");

        // Set gas limit (200k default, increase if needed for complex handlers)
        bridge.setDstGasLimit(200_000);

        vm.stopBroadcast();

        console2.log("\nDone. Verify with:");
        console2.log("  cast call", bridgeAddr, '"chainToEid(uint256)(uint32)" 1');
    }

    function _setMapping(ILZBridge bridge, uint256 chainId, uint32 eid) internal {
        if (bridge.chainToEid(chainId) == eid) {
            console2.log("  Chain", chainId, "already mapped to eid", eid);
            return;
        }
        bridge.setChainMapping(chainId, eid);
        console2.log("  Mapped chain", chainId, "-> eid", eid);
    }

    function _setPeerFromEnv(ILZBridge bridge, uint32 eid, string memory envKey) internal {
        address peer = vm.envOr(envKey, address(0));
        if (peer == address(0)) {
            console2.log("  Skipping peer for eid (env not set):", eid);
            return;
        }
        bytes32 peerBytes = bytes32(uint256(uint160(peer)));
        if (bridge.peers(eid) == peerBytes) {
            console2.log("  Peer for eid", eid, "already set to", peer);
            return;
        }
        bridge.setPeer(eid, peerBytes);
        console2.log("  Set peer for eid", eid, "->", peer);
    }
}
