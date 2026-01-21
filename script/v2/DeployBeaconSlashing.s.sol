// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";

import {ValidatorPodManager} from "../../src/v2/beacon/ValidatorPodManager.sol";
import {MockBeaconOracle} from "../../src/v2/beacon/BeaconRootReceiver.sol";
import {EIP4788Oracle} from "../../src/v2/beacon/l1/EIP4788Oracle.sol";
import {L2SlashingConnector} from "../../src/v2/beacon/L2SlashingConnector.sol";
import {HyperlaneCrossChainMessenger} from "../../src/v2/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {LayerZeroCrossChainMessenger} from "../../src/v2/beacon/bridges/LayerZeroCrossChainMessenger.sol";

error MissingEnv(string key);
error AddressNotAllowlisted(string key, address provided, address expected);
error BridgeContractNotFound(string name, address addr);
error BridgeContractInvalid(string name, address addr);

/// @title DeployBeaconSlashingL1
/// @notice Deploy script for L1 beacon chain staking and slashing infrastructure
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
        bool skipChainConfig = vm.envOr("SKIP_CHAIN_CONFIG", false);
        address l2Receiver = vm.envOr("L2_RECEIVER", address(0));
        if (!skipChainConfig && l2Receiver == address(0)) {
            revert MissingEnv("L2_RECEIVER");
        }
        address beaconOracleOverride = vm.envOr("BEACON_ORACLE", address(0));
        bool useMockBeaconOracle = vm.envOr("USE_MOCK_BEACON_ORACLE", false);

        _enforceAllowlist("ADMIN_ALLOWLIST", admin);
        _enforceAllowlist("SLASHING_ORACLE_ALLOWLIST", oracle);
        if (l2Receiver != address(0)) {
            _enforceAllowlist("L2_RECEIVER_ALLOWLIST", l2Receiver);
        }

        console2.log("=== L1 Beacon Slashing Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Oracle:", oracle);
        console2.log("Target Tangle Chain ID:", tangleChainId);
        if (skipChainConfig) {
            console2.log("Skipping L2 chain config (set later via ConfigureL2SlashingConnector)");
        }

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
            useMockBeaconOracle,
            true
        );

        _writeManifest(_envStringOrEmpty("BEACON_SLASHING_MANIFEST"), bridge, admin, oracle, tangleChainId, l2Receiver, beaconOracle, podManager, connector, messenger);

        // Log deployment summary
        console2.log("\n=== L1 Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("ValidatorPodManager:", podManager);
        console2.log("L2SlashingConnector:", connector);
        console2.log("CrossChainMessenger:", messenger);
        console2.log("Target L2 Chain:", tangleChainId);
        if (l2Receiver != address(0)) {
            console2.log("L2 Receiver:", l2Receiver);
        }
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
            true,
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
        bool useMockBeaconOracle,
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
            if (useMockBeaconOracle) {
                beaconOracle = address(new MockBeaconOracle());
                console2.log("MockBeaconOracle:", beaconOracle);
            } else {
                beaconOracle = address(new EIP4788Oracle());
                console2.log("EIP4788Oracle:", beaconOracle);
            }
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
        if (l2Receiver != address(0)) {
            connectorContract.setDefaultDestinationChain(tangleChainId);
            connectorContract.setChainConfig(tangleChainId, l2Receiver, 200_000, true);
            console2.log("Connector configured for chain:", tangleChainId);
        } else {
            console2.log("Connector messenger set (chain config deferred)");
        }

        if (broadcast) {
            vm.stopBroadcast();
        } else if (deployer != address(0)) {
            vm.stopPrank();
        }
    }

    function deployHyperlaneMessenger() internal returns (address) {
        // Hyperlane Mailbox addresses by chain
        // See: https://docs.hyperlane.xyz/docs/reference/addresses/deployments/mailbox
        // See: https://github.com/hyperlane-xyz/hyperlane-registry/tree/main/chains
        // NOTE: L2 slashing deploy scripts also use `HYPERLANE_MAILBOX`; to avoid env collisions, L1 uses L1_* vars.
        address mailbox = vm.envOr("L1_HYPERLANE_MAILBOX", address(0));
        address igp = vm.envOr("L1_HYPERLANE_IGP", address(0));
        if (mailbox != address(0) || igp != address(0)) {
            if (mailbox == address(0)) revert MissingEnv("L1_HYPERLANE_MAILBOX");
            if (igp == address(0)) revert MissingEnv("L1_HYPERLANE_IGP");
        }

        if (mailbox == address(0) && igp == address(0) && block.chainid == 1) {
            // Ethereum mainnet
            mailbox = 0xc005dc82818d67AF737725bD4bf75435d065D239;
            igp = 0x6cA0B6D22da47f091B7613223cD4BB03a2d77918;
        } else if (mailbox == address(0) && igp == address(0) && block.chainid == 11155111) {
            // Sepolia testnet
            mailbox = 0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766;
            igp = 0x6f2756380FD49228ae25Aa7F2817993cB74Ecc56;
        } else if (mailbox == address(0) && igp == address(0) && block.chainid == 17000) {
            // Holesky testnet
            mailbox = 0x5b6CFf85442B851A8e6eaBd2A4E4507B5135B3B0;
            igp = 0x6f2756380FD49228ae25Aa7F2817993cB74Ecc56; // Same as Sepolia - verify before mainnet
        } else if (mailbox == address(0) && igp == address(0) && block.chainid == 8453) {
            // Base mainnet
            mailbox = 0xeA87ae93Fa0019a82A727bfd3eBd1cFCa8f64f1D;
            igp = 0xc3F23848Ed2e04C0c6d41bd7804fa8f89F940B94;
        } else if (mailbox == address(0) && igp == address(0) && block.chainid == 84532) {
            // Base Sepolia testnet
            mailbox = 0x6966b0E55883d49BFB24539356a2f8A673E02039;
            igp = 0x28B02B97a850872C4D33C3E024fab6499ad96564;
        }

        if (mailbox == address(0) || igp == address(0)) {
            revert("Unsupported chain for Hyperlane (set L1_HYPERLANE_MAILBOX and L1_HYPERLANE_IGP to override)");
        }

        // Verify bridge contracts exist before deployment
        _verifyBridgeContract("Hyperlane Mailbox", mailbox);
        _verifyBridgeContract("Hyperlane IGP", igp);

        HyperlaneCrossChainMessenger messenger = new HyperlaneCrossChainMessenger(
            mailbox,
            igp
        );
        console2.log("HyperlaneCrossChainMessenger:", address(messenger));
        return address(messenger);
    }

    function deployLayerZeroMessenger() internal returns (address) {
        // LayerZero V2 Endpoint addresses by chain
        // See: https://docs.layerzero.network/v2/deployments/deployed-contracts
        // NOTE: L2 slashing deploy scripts use `LAYERZERO_ENDPOINT`; to avoid env collisions, L1 uses L1_* vars.
        address endpoint = vm.envOr("L1_LAYERZERO_ENDPOINT", address(0));

        if (endpoint == address(0) && block.chainid == 1) {
            // Ethereum mainnet
            endpoint = 0x1a44076050125825900e736c501f859c50fE728c;
        } else if (endpoint == address(0) && block.chainid == 11155111) {
            // Sepolia testnet
            endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        } else if (endpoint == address(0) && block.chainid == 17000) {
            // Holesky testnet
            endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        } else if (endpoint == address(0) && block.chainid == 8453) {
            // Base mainnet
            endpoint = 0x1a44076050125825900e736c501f859c50fE728c;
        } else if (endpoint == address(0) && block.chainid == 84532) {
            // Base Sepolia testnet
            endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        }

        if (endpoint == address(0)) {
            revert("Unsupported chain for LayerZero (set L1_LAYERZERO_ENDPOINT to override)");
        }

        // Verify bridge contract exists before deployment
        _verifyBridgeContract("LayerZero Endpoint", endpoint);

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

    function _envStringOrEmpty(string memory key) internal view returns (string memory value) {
        try vm.envString(key) returns (string memory raw) {
            return raw;
        } catch {
            return "";
        }
    }

    function _writeManifest(
        string memory path,
        BridgeProtocol bridge,
        address admin,
        address oracle,
        uint256 destinationChainId,
        address l2Receiver,
        address beaconOracle,
        address podManager,
        address connector,
        address messenger
    ) internal {
        if (bytes(path).length == 0) return;
        _ensureParentDir(path);

        string memory root = "beaconSlashing";
        vm.serializeString(root, "kind", "beacon-slashing-l1");
        vm.serializeString(root, "bridge", bridge == BridgeProtocol.Hyperlane ? "hyperlane" : "layerzero");
        vm.serializeUint(root, "chainId", block.chainid);
        vm.serializeAddress(root, "admin", admin);
        vm.serializeAddress(root, "oracle", oracle);
        vm.serializeUint(root, "destinationChainId", destinationChainId);
        vm.serializeAddress(root, "l2Receiver", l2Receiver);
        vm.serializeAddress(root, "beaconOracle", beaconOracle);
        vm.serializeAddress(root, "podManager", podManager);
        vm.serializeAddress(root, "connector", connector);
        string memory json = vm.serializeAddress(root, "messenger", messenger);
        vm.writeJson(json, path);

        console2.log("Wrote beacon slashing manifest:", path);
    }

    function _ensureParentDir(string memory filePath) internal {
        string memory dir = _parentDir(filePath);
        if (bytes(dir).length == 0) return;
        vm.createDir(dir, true);
    }

    function _parentDir(string memory filePath) internal pure returns (string memory dir) {
        bytes memory pathBytes = bytes(filePath);
        if (pathBytes.length == 0) return "";

        for (uint256 i = pathBytes.length; i > 0; i--) {
            if (pathBytes[i - 1] == "/") {
                if (i <= 1) return "";
                bytes memory dirBytes = new bytes(i - 1);
                for (uint256 j = 0; j < i - 1; j++) {
                    dirBytes[j] = pathBytes[j];
                }
                return string(dirBytes);
            }
        }
        return "";
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

    /// @notice Verify bridge contract exists and has code
    function _verifyBridgeContract(string memory name, address addr) internal view {
        if (addr == address(0)) revert BridgeContractNotFound(name, addr);
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(addr)
        }
        if (codeSize == 0) revert BridgeContractNotFound(name, addr);
    }
}

/// @title DeployBeaconSlashingL1Testnet
/// @notice Convenience script for testnet deployment with mock setup (Sepolia)
contract DeployBeaconSlashingL1Testnet is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.Hyperlane);
    }
}

/// @title DeployBeaconSlashingL1Holesky
/// @notice Convenience script for Holesky testnet deployment
/// @dev Run with: forge script script/v2/DeployBeaconSlashing.s.sol:DeployBeaconSlashingL1Holesky --rpc-url $HOLESKY_RPC --broadcast
contract DeployBeaconSlashingL1Holesky is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.Hyperlane);
    }
}

/// @title DeployBeaconSlashingL1HoleskyLayerZero
/// @notice Convenience script for Holesky testnet deployment using LayerZero.
contract DeployBeaconSlashingL1HoleskyLayerZero is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.LayerZero);
    }
}

/// @title DeployBeaconSlashingBase
/// @notice Convenience script for Base mainnet deployment
/// @dev Run with: forge script script/v2/DeployBeaconSlashing.s.sol:DeployBeaconSlashingBase --rpc-url $BASE_RPC --broadcast
contract DeployBeaconSlashingBase is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.Hyperlane);
    }
}

/// @title DeployBeaconSlashingBaseSepolia
/// @notice Convenience script for Base Sepolia testnet deployment
/// @dev Run with: forge script script/v2/DeployBeaconSlashing.s.sol:DeployBeaconSlashingBaseSepolia --rpc-url $BASE_SEPOLIA_RPC --broadcast
contract DeployBeaconSlashingBaseSepolia is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.Hyperlane);
    }
}

/// @title DeployBeaconSlashingL1LayerZero
/// @notice Generic convenience script for LayerZero deployments on any supported L1 chain.
contract DeployBeaconSlashingL1LayerZero is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.LayerZero);
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
