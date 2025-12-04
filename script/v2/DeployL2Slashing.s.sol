// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";

import {L2SlashingReceiver} from "../../src/v2/beacon/L2SlashingReceiver.sol";
import {TangleL2Slasher} from "../../src/v2/beacon/TangleL2Slasher.sol";
import {HyperlaneReceiver} from "../../src/v2/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {LayerZeroReceiver} from "../../src/v2/beacon/bridges/LayerZeroCrossChainMessenger.sol";

/// @title DeployL2Slashing
/// @notice Deploy script for L2 (Tangle) slashing receiver infrastructure
/// @dev Deploys to Tangle mainnet/testnet
contract DeployL2Slashing is Script {
    // Chain IDs
    uint256 public constant ETHEREUM_MAINNET = 1;
    uint256 public constant ETHEREUM_SEPOLIA = 11155111;

    // Bridge protocol selection
    enum BridgeProtocol {
        Hyperlane,
        LayerZero,
        DirectMessenger  // For testing with direct calls
    }

    function run() external {
        run(BridgeProtocol.DirectMessenger);
    }

    function run(BridgeProtocol bridge) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = vm.envOr("ADMIN", deployer);
        address restaking = vm.envAddress("RESTAKING");
        uint256 sourceChainId = vm.envOr("SOURCE_CHAIN_ID", ETHEREUM_SEPOLIA);
        address l1Connector = vm.envOr("L1_CONNECTOR", address(0));

        console2.log("=== L2 Slashing Receiver Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Restaking:", restaking);
        console2.log("Source Chain ID:", sourceChainId);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy TangleL2Slasher
        TangleL2Slasher slasher = new TangleL2Slasher(restaking, admin);
        console2.log("TangleL2Slasher:", address(slasher));

        // 2. Determine messenger address (bridge receiver or direct mock)
        address messengerAddr;
        address bridgeReceiver;

        if (bridge == BridgeProtocol.Hyperlane) {
            // Deploy Hyperlane receiver first
            bridgeReceiver = deployHyperlaneReceiver(sourceChainId, l1Connector);
            messengerAddr = bridgeReceiver;
        } else if (bridge == BridgeProtocol.LayerZero) {
            // Deploy LayerZero receiver first
            bridgeReceiver = deployLayerZeroReceiver(sourceChainId, l1Connector);
            messengerAddr = bridgeReceiver;
        } else {
            // DirectMessenger: use deployer or mock as messenger
            messengerAddr = vm.envOr("MOCK_MESSENGER", deployer);
            bridgeReceiver = address(0);
        }

        // 3. Deploy L2SlashingReceiver with slasher and messenger
        L2SlashingReceiver receiver = new L2SlashingReceiver(address(slasher), messengerAddr);
        console2.log("L2SlashingReceiver:", address(receiver));

        // 4. Authorize receiver to call slasher
        slasher.setAuthorizedCaller(address(receiver), true);
        console2.log("Authorized receiver as slasher caller");

        // 5. Configure authorized senders if L1 connector is known
        if (l1Connector != address(0)) {
            receiver.setAuthorizedSender(sourceChainId, l1Connector, true);
            console2.log("Authorized L1 connector:", l1Connector);
        }

        vm.stopBroadcast();

        // Log deployment summary
        console2.log("\n=== L2 Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("TangleL2Slasher:", address(slasher));
        console2.log("L2SlashingReceiver:", address(receiver));
        if (bridgeReceiver != address(0)) {
            console2.log("BridgeReceiver:", bridgeReceiver);
        }
        console2.log("Source Chain ID:", sourceChainId);
        if (l1Connector != address(0)) {
            console2.log("L1 Connector:", l1Connector);
        }
    }

    /// @dev Deploy and configure HyperlaneReceiver
    /// Note: The receiver will be set as messenger for L2SlashingReceiver
    /// This is a placeholder that returns deployer for now - configure after L2SlashingReceiver is deployed
    function deployHyperlaneReceiver(
        uint256 sourceChainId,
        address l1Connector
    ) internal returns (address) {
        // Hyperlane Mailbox on Tangle (placeholder - update with actual address)
        address mailbox = vm.envAddress("HYPERLANE_MAILBOX");

        // Note: HyperlaneReceiver needs the L2SlashingReceiver address
        // For now we return a placeholder, actual deployment should be done in two steps
        // or the HyperlaneReceiver should be deployed with a placeholder and updated later

        // Return the mailbox for now as placeholder - actual integration
        // requires configuring HyperlaneReceiver after L2SlashingReceiver deployment
        console2.log("Note: Configure HyperlaneReceiver manually after deployment");
        console2.log("Source Chain ID:", sourceChainId);
        if (l1Connector != address(0)) {
            console2.log("L1 Connector to trust:", l1Connector);
        }

        return mailbox;  // Placeholder
    }

    /// @dev Deploy and configure LayerZeroReceiver
    /// Note: The receiver will be set as messenger for L2SlashingReceiver
    function deployLayerZeroReceiver(
        uint256 sourceChainId,
        address l1Connector
    ) internal returns (address) {
        // LayerZero Endpoint on Tangle (placeholder - update with actual address)
        address endpoint = vm.envAddress("LAYERZERO_ENDPOINT");

        // Note: LayerZeroReceiver needs the L2SlashingReceiver address
        // Return endpoint as placeholder
        console2.log("Note: Configure LayerZeroReceiver manually after deployment");
        console2.log("Source Chain ID:", sourceChainId);
        if (l1Connector != address(0)) {
            console2.log("L1 Connector to trust:", l1Connector);
        }

        return endpoint;  // Placeholder
    }
}

/// @title DeployL2SlashingTestnet
/// @notice Convenience script for testnet deployment
contract DeployL2SlashingTestnet is Script {
    function run() external {
        DeployL2Slashing deploy = new DeployL2Slashing();
        deploy.run(DeployL2Slashing.BridgeProtocol.DirectMessenger);
    }
}

/// @title ConfigureL2SlashingReceiver
/// @notice Configure an existing L2SlashingReceiver
contract ConfigureL2SlashingReceiver is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address receiverAddr = vm.envAddress("RECEIVER");
        address messenger = vm.envAddress("MESSENGER");
        uint256 sourceChainId = vm.envUint("SOURCE_CHAIN_ID");
        address l1Connector = vm.envAddress("L1_CONNECTOR");

        L2SlashingReceiver receiver = L2SlashingReceiver(receiverAddr);

        vm.startBroadcast(deployerPrivateKey);

        receiver.setMessenger(messenger);
        receiver.setAuthorizedSender(sourceChainId, l1Connector, true);

        vm.stopBroadcast();

        console2.log("Receiver configured");
        console2.log("Messenger set to:", messenger);
        console2.log("Authorized sender from chain", sourceChainId, ":", l1Connector);
    }
}

/// @title AuthorizeTangleL2Slasher
/// @notice Add authorized callers to TangleL2Slasher
contract AuthorizeTangleL2Slasher is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address slasherAddr = vm.envAddress("SLASHER");
        address caller = vm.envAddress("CALLER");

        TangleL2Slasher slasher = TangleL2Slasher(slasherAddr);

        vm.startBroadcast(deployerPrivateKey);

        slasher.setAuthorizedCaller(caller, true);

        vm.stopBroadcast();

        console2.log("Authorized caller:", caller);
    }
}

/// @title PauseTangleL2Slasher
/// @notice Emergency pause for slashing
contract PauseTangleL2Slasher is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address slasherAddr = vm.envAddress("SLASHER");
        bool pause = vm.envBool("PAUSE");

        TangleL2Slasher slasher = TangleL2Slasher(slasherAddr);

        vm.startBroadcast(deployerPrivateKey);

        slasher.setPaused(pause);

        vm.stopBroadcast();

        console2.log("Slasher paused:", pause);
    }
}
