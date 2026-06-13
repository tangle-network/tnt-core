// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";

import { ValidatorPodManager } from "../src/beacon/ValidatorPodManager.sol";
import { MockBeaconOracle } from "../src/beacon/BeaconRootReceiver.sol";
import { EIP4788Oracle } from "../src/beacon/l1/EIP4788Oracle.sol";
import { L2SlashingConnector } from "../src/beacon/L2SlashingConnector.sol";
import { BaseCrossChainMessenger } from "../src/beacon/bridges/BaseCrossChainMessenger.sol";

error MissingEnv(string key);
error AddressNotAllowlisted(string key, address provided, address expected);
error BridgeContractNotFound(string name, address addr);
error BridgeContractInvalid(string name, address addr);

/// @title DeployBeaconSlashingL1
/// @notice Deploy script for L1 beacon chain staking and slashing infrastructure
/// @dev Deploys to Ethereum mainnet/testnet
contract DeployBeaconSlashingL1 is Script {
    // Configuration
    uint256 public minOperatorStake = 32 ether; // Standard beacon chain validator stake

    // Chain IDs
    uint256 public constant TANGLE_MAINNET = 5845;
    uint256 public constant TANGLE_TESTNET = 3799;

    // Bridge protocol selection
    enum BridgeProtocol {
        OpStack // OP-Stack canonical CrossDomainMessenger (Base/Optimism) — native, no third-party trust
    }

    function run() external {
        run(BridgeProtocol.OpStack);
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

        // Fail closed on production chains: ADMIN/SLASHING_ORACLE must be explicit, distinct,
        // non-deployer addresses (these own the pod manager / connector and authorize beacon
        // slashes), and the forgeable MockBeaconOracle must never reach mainnet.
        _requireProductionBeaconConfig(deployer, admin, oracle, useMockBeaconOracle);

        console2.log("=== L1 Beacon Slashing Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Oracle:", oracle);
        console2.log("Target Tangle Chain ID:", tangleChainId);
        if (skipChainConfig) {
            console2.log("Skipping L2 chain config (set later via ConfigureL2SlashingConnector)");
        }

        (address beaconOracle, address podManager, address connector, address messenger) = _deploy(
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

        _writeManifest(
            _envStringOrEmpty("BEACON_SLASHING_MANIFEST"),
            bridge,
            admin,
            oracle,
            tangleChainId,
            l2Receiver,
            beaconOracle,
            podManager,
            connector,
            messenger
        );

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
        returns (address beaconOracle, address podManager, address connector, address messenger)
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

        messenger = deployOpStackMessenger();

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

    /// @notice Deploy the OP-Stack canonical-bridge adapter (Base/Optimism). This wraps the
    ///         target chain's L1CrossDomainMessenger (deployed on L1, one per OP chain), so the
    ///         slash message inherits Base/Ethereum security with NO third-party ISM/DVN to pin.
    /// @dev Run on L1 (Ethereum). `L1_CROSS_DOMAIN_MESSENGER` overrides; defaults are Base's
    ///      canonical L1 messenger proxy on Ethereum mainnet / Sepolia. For Optimism or other OP
    ///      chains, pass the override.
    function deployOpStackMessenger() internal returns (address) {
        address l1Messenger = vm.envOr("L1_CROSS_DOMAIN_MESSENGER", address(0));
        if (l1Messenger == address(0) && block.chainid == 1) {
            // Base mainnet's L1CrossDomainMessenger proxy on Ethereum.
            l1Messenger = 0x866E82a600A1414e583f7F13623F1aC5d58b0Afa;
        } else if (l1Messenger == address(0) && block.chainid == 11_155_111) {
            // Base Sepolia's L1CrossDomainMessenger proxy on Sepolia.
            l1Messenger = 0xC34855F4De64F1840e5686e64278da901e261f20;
        }
        if (l1Messenger == address(0)) {
            revert(
                "Unsupported chain for OP-Stack (set L1_CROSS_DOMAIN_MESSENGER to the target OP chain's L1 messenger)"
            );
        }

        _verifyBridgeContract("L1CrossDomainMessenger", l1Messenger);

        BaseCrossChainMessenger messenger = new BaseCrossChainMessenger(l1Messenger);
        console2.log("BaseCrossChainMessenger (OP-Stack):", address(messenger));
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
    )
        internal
    {
        if (bytes(path).length == 0) return;
        _ensureParentDir(path);

        string memory root = "beaconSlashing";
        vm.serializeString(root, "kind", "beacon-slashing-l1");
        vm.serializeString(root, "bridge", "opstack");
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
        } catch { }
    }

    /// @notice True on L1/L2 mainnets where beacon slashing would be live. Bypass on
    ///         local/anvil with TANGLE_DEPLOY_LOCAL=1.
    function _isProductionChain() internal view returns (bool) {
        if (vm.envOr("TANGLE_DEPLOY_LOCAL", uint256(0)) != 0) return false;
        uint256 id = block.chainid;
        // Ethereum, Base, Tangle, Arbitrum, Optimism mainnets.
        return id == 1 || id == 8453 || id == 5845 || id == 42_161 || id == 10;
    }

    /// @notice Refuse to deploy beacon slashing infra to a production chain with hot-key admin
    ///         or a forgeable mock oracle.
    function _requireProductionBeaconConfig(
        address deployer,
        address admin,
        address oracle,
        bool useMockBeaconOracle
    )
        internal
        view
    {
        if (!_isProductionChain()) return;
        require(!useMockBeaconOracle, "config: USE_MOCK_BEACON_ORACLE forbidden on production");
        require(admin != deployer, "config: ADMIN must be a multisig/timelock, not the deployer");
        require(oracle != deployer, "config: SLASHING_ORACLE must be set, not the deployer");
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
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.OpStack);
    }
}

/// @title DeployBeaconSlashingL1Holesky
/// @notice Convenience script for Holesky testnet deployment
/// @dev Run with: forge script script/DeployBeaconSlashing.s.sol:DeployBeaconSlashingL1Holesky --rpc-url $HOLESKY_RPC
/// --broadcast
contract DeployBeaconSlashingL1Holesky is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.OpStack);
    }
}

/// @title DeployBeaconSlashingBase
/// @notice Convenience script for Base mainnet deployment
/// @dev Run with: forge script script/DeployBeaconSlashing.s.sol:DeployBeaconSlashingBase --rpc-url $BASE_RPC
/// --broadcast
contract DeployBeaconSlashingBase is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.OpStack);
    }
}

/// @title DeployBeaconSlashingBaseSepolia
/// @notice Convenience script for Base Sepolia testnet deployment
/// @dev Run with: forge script script/DeployBeaconSlashing.s.sol:DeployBeaconSlashingBaseSepolia --rpc-url
/// $BASE_SEPOLIA_RPC --broadcast
contract DeployBeaconSlashingBaseSepolia is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.OpStack);
    }
}

/// @title DeployBeaconSlashingOpStack
/// @notice OP-Stack (Base/Optimism) native L1 leg — recommended for Base. Deploys the
///         BaseCrossChainMessenger wrapping the target OP chain's canonical L1CrossDomainMessenger;
///         no third-party bridge, no ISM/DVN to pin. Run on L1 (Ethereum); set
///         L1_CROSS_DOMAIN_MESSENGER to the target OP chain's L1 messenger (defaults to Base's).
contract DeployBeaconSlashingOpStack is Script {
    function run() external {
        DeployBeaconSlashingL1 deploy = new DeployBeaconSlashingL1();
        deploy.run(DeployBeaconSlashingL1.BridgeProtocol.OpStack);
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
