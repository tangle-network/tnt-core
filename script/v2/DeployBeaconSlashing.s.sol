// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";

import {ValidatorPodManager} from "../../src/v2/beacon/ValidatorPodManager.sol";
import {MockBeaconOracle} from "../../src/v2/beacon/BeaconRootReceiver.sol";
import {L2SlashingConnector} from "../../src/v2/beacon/L2SlashingConnector.sol";
import {HyperlaneCrossChainMessenger} from "../../src/v2/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {LayerZeroCrossChainMessenger} from "../../src/v2/beacon/bridges/LayerZeroCrossChainMessenger.sol";

/// @title DeployBeaconSlashingL1
/// @notice Deploy script for L1 beacon chain restaking and slashing infrastructure
/// @dev Deploys to Ethereum mainnet/testnet
contract DeployBeaconSlashingL1 is Script {
    // Configuration
    uint256 public minOperatorStake = 32 ether;  // Standard beacon chain validator stake

    // Chain IDs
    uint256 public constant TANGLE_MAINNET = 5845;
    uint256 public constant TANGLE_TESTNET = 3799;

    // Bridge protocol selection
    enum BridgeProtocol {
        Hyperlane,
        LayerZero
    }

    function run() external {
        run(BridgeProtocol.Hyperlane);
    }

    function run(BridgeProtocol bridge) public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = vm.envOr("ADMIN", deployer);
        address oracle = vm.envOr("SLASHING_ORACLE", deployer);
        uint256 tangleChainId = vm.envOr("TANGLE_CHAIN_ID", TANGLE_TESTNET);
        address l2Receiver = vm.envAddress("L2_RECEIVER");

        console2.log("=== L1 Beacon Slashing Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Oracle:", oracle);
        console2.log("Target Tangle Chain ID:", tangleChainId);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy beacon oracle (or use existing)
        address beaconOracle = vm.envOr("BEACON_ORACLE", address(0));
        if (beaconOracle == address(0)) {
            // Deploy mock for testnet, production uses 4788 precompile receiver
            beaconOracle = address(new MockBeaconOracle());
            console2.log("MockBeaconOracle:", beaconOracle);
        } else {
            console2.log("Using existing BeaconOracle:", beaconOracle);
        }

        // 2. Deploy ValidatorPodManager
        ValidatorPodManager podManager = new ValidatorPodManager(
            beaconOracle,
            minOperatorStake
        );
        console2.log("ValidatorPodManager:", address(podManager));

        // Transfer ownership if admin is different from deployer
        if (admin != deployer) {
            podManager.transferOwnership(admin);
            console2.log("Transferred ownership to admin");
        }

        // 3. Deploy L2SlashingConnector
        L2SlashingConnector connector = new L2SlashingConnector(
            address(podManager),
            oracle
        );
        console2.log("L2SlashingConnector:", address(connector));

        // 4. Deploy cross-chain messenger based on selected protocol
        address messenger;
        if (bridge == BridgeProtocol.Hyperlane) {
            messenger = deployHyperlaneMessenger();
        } else {
            messenger = deployLayerZeroMessenger();
        }

        // 5. Configure connector
        connector.setMessenger(messenger);
        connector.setDefaultDestinationChain(tangleChainId);
        connector.setChainConfig(
            tangleChainId,
            l2Receiver,
            200_000,  // Gas limit for L2 execution
            true      // Enabled
        );
        console2.log("Connector configured for chain:", tangleChainId);

        vm.stopBroadcast();

        // Log deployment summary
        console2.log("\n=== L1 Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("ValidatorPodManager:", address(podManager));
        console2.log("L2SlashingConnector:", address(connector));
        console2.log("CrossChainMessenger:", messenger);
        console2.log("Target L2 Chain:", tangleChainId);
        console2.log("L2 Receiver:", l2Receiver);
    }

    function deployHyperlaneMessenger() internal returns (address) {
        // Hyperlane Mailbox addresses by chain
        address mailbox;
        address igp;

        if (block.chainid == 1) {
            // Ethereum mainnet
            mailbox = 0xc005dc82818d67AF737725bD4bf75435d065D239;
            igp = 0x6cA0B6D22da47f091B7613223cD4BB03a2d77918;
        } else if (block.chainid == 11155111) {
            // Sepolia testnet
            mailbox = 0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766;
            igp = 0x6f2756380FD49228ae25Aa7F2817993cB74Ecc56;
        } else {
            revert("Unsupported chain for Hyperlane");
        }

        HyperlaneCrossChainMessenger messenger = new HyperlaneCrossChainMessenger(
            mailbox,
            igp
        );
        console2.log("HyperlaneCrossChainMessenger:", address(messenger));
        return address(messenger);
    }

    function deployLayerZeroMessenger() internal returns (address) {
        // LayerZero V2 Endpoint addresses by chain
        address endpoint;

        if (block.chainid == 1) {
            // Ethereum mainnet
            endpoint = 0x1a44076050125825900e736c501f859c50fE728c;
        } else if (block.chainid == 11155111) {
            // Sepolia testnet
            endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        } else {
            revert("Unsupported chain for LayerZero");
        }

        LayerZeroCrossChainMessenger messenger = new LayerZeroCrossChainMessenger(endpoint);
        console2.log("LayerZeroCrossChainMessenger:", address(messenger));
        return address(messenger);
    }
}

/// @title DeployBeaconSlashingL1Testnet
/// @notice Convenience script for testnet deployment with mock setup
contract DeployBeaconSlashingL1Testnet is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.Hyperlane);
    }
}

/// @title ConfigureL2SlashingConnector
/// @notice Configure an existing L2SlashingConnector
contract ConfigureL2SlashingConnector is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address connectorAddr = vm.envAddress("CONNECTOR");
        address messengerAddr = vm.envAddress("MESSENGER");
        uint256 tangleChainId = vm.envUint("TANGLE_CHAIN_ID");
        address l2Receiver = vm.envAddress("L2_RECEIVER");

        L2SlashingConnector connector = L2SlashingConnector(payable(connectorAddr));

        vm.startBroadcast(deployerPrivateKey);

        connector.setMessenger(messengerAddr);
        connector.setDefaultDestinationChain(tangleChainId);
        connector.setChainConfig(tangleChainId, l2Receiver, 200_000, true);

        vm.stopBroadcast();

        console2.log("Connector configured");
    }
}
