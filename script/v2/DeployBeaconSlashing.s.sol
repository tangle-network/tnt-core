// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";

import {ValidatorPodManager} from "../../src/v2/beacon/ValidatorPodManager.sol";
import {MockBeaconOracle} from "../../src/v2/beacon/BeaconRootReceiver.sol";
import {L2SlashingConnector} from "../../src/v2/beacon/L2SlashingConnector.sol";
import {HyperlaneCrossChainMessenger} from "../../src/v2/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {LayerZeroCrossChainMessenger} from "../../src/v2/beacon/bridges/LayerZeroCrossChainMessenger.sol";

error MissingEnv(string key);
error AddressNotAllowlisted(string key, address provided, address expected);

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
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = _envAddressOrDefault("ADMIN", deployer);
        address oracle = _envAddressOrDefault("SLASHING_ORACLE", deployer);
        uint256 tangleChainId = vm.envOr("TANGLE_CHAIN_ID", TANGLE_TESTNET);
        address l2Receiver = _requireEnvAddress("L2_RECEIVER");
        address beaconOracleOverride = vm.envOr("BEACON_ORACLE", address(0));

        _enforceAllowlist("ADMIN_ALLOWLIST", admin);
        _enforceAllowlist("SLASHING_ORACLE_ALLOWLIST", oracle);
        _enforceAllowlist("L2_RECEIVER_ALLOWLIST", l2Receiver);

        console2.log("=== L1 Beacon Slashing Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Oracle:", oracle);
        console2.log("Target Tangle Chain ID:", tangleChainId);

        (
            address beaconOracle,
            address podManager,
            address connector,
            address messenger
        ) = _deploy(
            bridge,
            deployerPrivateKey,
            deployer,
            admin,
            oracle,
            tangleChainId,
            l2Receiver,
            beaconOracleOverride,
            true
        );

        // Log deployment summary
        console2.log("\n=== L1 Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("ValidatorPodManager:", podManager);
        console2.log("L2SlashingConnector:", connector);
        console2.log("CrossChainMessenger:", messenger);
        console2.log("Target L2 Chain:", tangleChainId);
        console2.log("L2 Receiver:", l2Receiver);
    }

    /// @notice Dry-run deployment for testing/CI
    function dryRun(
        BridgeProtocol bridge,
        address deployer,
        address admin,
        address oracle,
        uint256 tangleChainId,
        address l2Receiver,
        address beaconOracle
    )
        external
        returns (address podManager, address connector, address messenger)
    {
        (, podManager, connector, messenger) = _deploy(
            bridge,
            0,
            deployer == address(0) ? msg.sender : deployer,
            admin,
            oracle,
            tangleChainId,
            l2Receiver,
            beaconOracle,
            false
        );
    }

    function _deploy(
        BridgeProtocol bridge,
        uint256 deployerPrivateKey,
        address deployer,
        address admin,
        address oracle,
        uint256 tangleChainId,
        address l2Receiver,
        address beaconOracleOverride,
        bool broadcast
    )
        internal
        returns (
            address beaconOracle,
            address podManager,
            address connector,
            address messenger
        )
    {
        if (broadcast) {
            vm.startBroadcast(deployerPrivateKey);
        } else if (deployer != address(0)) {
            vm.startPrank(deployer);
        }

        beaconOracle = beaconOracleOverride;
        if (beaconOracle == address(0)) {
            beaconOracle = address(new MockBeaconOracle());
            console2.log("MockBeaconOracle:", beaconOracle);
        } else {
            _enforceAllowlist("BEACON_ORACLE_ALLOWLIST", beaconOracle);
            console2.log("Using existing BeaconOracle:", beaconOracle);
        }

        ValidatorPodManager podManagerContract = new ValidatorPodManager(beaconOracle, minOperatorStake);
        podManager = address(podManagerContract);
        console2.log("ValidatorPodManager:", podManager);

        if (admin != deployer) {
            podManagerContract.transferOwnership(admin);
            console2.log("Transferred ownership to admin");
        }

        L2SlashingConnector connectorContract = new L2SlashingConnector(podManager, oracle);
        connector = address(connectorContract);
        console2.log("L2SlashingConnector:", connector);

        if (bridge == BridgeProtocol.Hyperlane) {
            messenger = deployHyperlaneMessenger();
        } else {
            messenger = deployLayerZeroMessenger();
        }

        connectorContract.setMessenger(messenger);
        connectorContract.setDefaultDestinationChain(tangleChainId);
        connectorContract.setChainConfig(tangleChainId, l2Receiver, 200_000, true);
        console2.log("Connector configured for chain:", tangleChainId);

        if (broadcast) {
            vm.stopBroadcast();
        } else if (deployer != address(0)) {
            vm.stopPrank();
        }
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

    function _requireEnvUint(string memory key) internal returns (uint256 value) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            revert MissingEnv(key);
        }
    }

    function _requireEnvAddress(string memory key) internal returns (address value) {
        try vm.envAddress(key) returns (address raw) {
            if (raw == address(0)) revert MissingEnv(key);
            return raw;
        } catch {
            revert MissingEnv(key);
        }
    }

    function _envAddressOrDefault(string memory key, address defaultValue) internal returns (address) {
        try vm.envAddress(key) returns (address raw) {
            if (raw == address(0)) revert MissingEnv(key);
            return raw;
        } catch {
            if (defaultValue == address(0)) revert MissingEnv(key);
            return defaultValue;
        }
    }

    function _enforceAllowlist(string memory key, address candidate) internal view {
        try vm.envAddress(key) returns (address allowed) {
            if (allowed != address(0) && candidate != allowed) {
                revert AddressNotAllowlisted(key, candidate, allowed);
            }
        } catch {}
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
