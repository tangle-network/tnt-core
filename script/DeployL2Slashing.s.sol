// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";

import {L2SlashingReceiver} from "../src/beacon/L2SlashingReceiver.sol";
import {TangleL2Slasher} from "../src/beacon/TangleL2Slasher.sol";
import {HyperlaneReceiver} from "../src/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {LayerZeroReceiver} from "../src/beacon/bridges/LayerZeroCrossChainMessenger.sol";

error MissingEnv(string key);
error AddressNotAllowlisted(string key, address provided, address expected);
error BridgeContractNotFound(string name, address addr);

abstract contract EnvUtils is Script {
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

/// @title DeployL2Slashing
/// @notice Deploy script for L2 (Tangle) slashing receiver infrastructure
/// @dev Deploys to Tangle mainnet/testnet
contract DeployL2Slashing is EnvUtils {
    // Chain IDs - Ethereum
    uint256 public constant ETHEREUM_MAINNET = 1;
    uint256 public constant ETHEREUM_SEPOLIA = 11155111;
    uint256 public constant ETHEREUM_HOLESKY = 17000;
    // Chain IDs - Base
    uint256 public constant BASE_MAINNET = 8453;
    uint256 public constant BASE_SEPOLIA = 84532;

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
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = _envAddressOrDefault("ADMIN", deployer);
        address staking = _requireEnvAddress("STAKING");
        uint256 sourceChainId = vm.envOr("SOURCE_CHAIN_ID", ETHEREUM_SEPOLIA);
        address l1Connector = vm.envOr("L1_CONNECTOR", address(0));
        address messengerOverride = vm.envOr("MOCK_MESSENGER", deployer);
        if (messengerOverride == address(0)) revert MissingEnv("MOCK_MESSENGER");
        address l1Messenger = vm.envOr("L1_MESSENGER", address(0));

        _enforceAllowlist("ADMIN_ALLOWLIST", admin);
        _enforceAllowlist("STAKING_ALLOWLIST", staking);
        if (l1Connector != address(0)) {
            _enforceAllowlist("L1_CONNECTOR_ALLOWLIST", l1Connector);
        }
        if (bridge == BridgeProtocol.DirectMessenger) {
            _enforceAllowlist("MESSENGER_ALLOWLIST", messengerOverride);
        } else if (l1Messenger != address(0)) {
            _enforceAllowlist("L1_MESSENGER_ALLOWLIST", l1Messenger);
        }

        console2.log("=== L2 Slashing Receiver Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Staking:", staking);
        console2.log("Source Chain ID:", sourceChainId);
        if (bridge != BridgeProtocol.DirectMessenger) {
            console2.log("L1 Messenger:", l1Messenger);
        }

        (
            address slasher,
            address receiver,
            address bridgeReceiver
        ) = _deploy(
            bridge,
            deployerPrivateKey,
            deployer,
            admin,
            staking,
            sourceChainId,
            l1Connector,
            messengerOverride,
            l1Messenger,
            true
        );

        _writeManifest(
            _envStringOrEmpty("L2_SLASHING_MANIFEST"),
            bridge,
            admin,
            staking,
            sourceChainId,
            l1Connector,
            l1Messenger,
            slasher,
            receiver,
            bridgeReceiver
        );

        // Log deployment summary
        console2.log("\n=== L2 Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("TangleL2Slasher:", slasher);
        console2.log("L2SlashingReceiver:", receiver);
        if (bridgeReceiver != address(0)) {
            console2.log("BridgeReceiver:", bridgeReceiver);
        }
        console2.log("Source Chain ID:", sourceChainId);
        if (l1Connector != address(0)) {
            console2.log("L1 Connector:", l1Connector);
        }
    }

    /// @notice Dry-run deployment for testing/CI
    function dryRun(
        BridgeProtocol bridge,
        address deployer,
        address admin,
        address staking,
        uint256 sourceChainId,
        address l1Connector,
        address messengerOverride
    )
        external
        returns (address slasher, address receiver)
    {
        _enforceAllowlist("ADMIN_ALLOWLIST", admin);
        _enforceAllowlist("STAKING_ALLOWLIST", staking);
        if (l1Connector != address(0)) {
            _enforceAllowlist("L1_CONNECTOR_ALLOWLIST", l1Connector);
        }
        if (messengerOverride != address(0)) {
            _enforceAllowlist("MESSENGER_ALLOWLIST", messengerOverride);
        }
        address l1Messenger = vm.envOr("L1_MESSENGER", address(0));
        (slasher, receiver,) = _deploy(
            bridge,
            0,
            deployer == address(0) ? msg.sender : deployer,
            admin,
            staking,
            sourceChainId,
            l1Connector,
            messengerOverride,
            l1Messenger,
            false
        );
    }

    function _deploy(
        BridgeProtocol bridge,
        uint256 deployerPrivateKey,
        address deployer,
        address admin,
        address staking,
        uint256 sourceChainId,
        address l1Connector,
        address messengerOverride,
        address l1Messenger,
        bool broadcast
    )
        internal
        returns (address slasher, address receiver, address bridgeReceiver)
    {
        if (broadcast) {
            vm.startBroadcast(deployerPrivateKey);
        } else if (deployer != address(0)) {
            vm.startPrank(deployer);
        }

        TangleL2Slasher slasherContract = new TangleL2Slasher(staking, admin);
        slasher = address(slasherContract);
        console2.log("TangleL2Slasher:", slasher);

        address initialMessenger = messengerOverride != address(0) ? messengerOverride : deployer;
        L2SlashingReceiver receiverContract = new L2SlashingReceiver(slasher, initialMessenger);
        receiver = address(receiverContract);
        console2.log("L2SlashingReceiver:", receiver);

        slasherContract.setAuthorizedCaller(receiver, true);
        console2.log("Authorized receiver as slasher caller");

        if (bridge == BridgeProtocol.Hyperlane) {
            if (l1Messenger == address(0)) revert MissingEnv("L1_MESSENGER");
            bridgeReceiver = _deployAndConfigureHyperlaneReceiver(receiverContract, admin, sourceChainId, l1Messenger);
            receiverContract.setMessenger(bridgeReceiver);
        } else if (bridge == BridgeProtocol.LayerZero) {
            if (l1Messenger == address(0)) revert MissingEnv("L1_MESSENGER");
            bridgeReceiver = _deployAndConfigureLayerZeroReceiver(receiverContract, admin, sourceChainId, l1Messenger);
            receiverContract.setMessenger(bridgeReceiver);
        } else {
            bridgeReceiver = address(0);
            receiverContract.setMessenger(initialMessenger);
        }

        if (l1Connector != address(0)) {
            receiverContract.setAuthorizedSender(sourceChainId, l1Connector, true);
            console2.log("Authorized L1 connector:", l1Connector);
        }

        if (receiverContract.owner() != admin) {
            receiverContract.transferOwnership(admin);
            console2.log("Transferred L2SlashingReceiver ownership to admin");
        }

        if (broadcast) {
            vm.stopBroadcast();
        } else if (deployer != address(0)) {
            vm.stopPrank();
        }
    }

    function _deployAndConfigureHyperlaneReceiver(
        L2SlashingReceiver receiverContract,
        address admin,
        uint256 sourceChainId,
        address l1Messenger
    ) internal returns (address) {
        address mailbox = vm.envOr("HYPERLANE_MAILBOX", _defaultHyperlaneMailbox(block.chainid));
        if (mailbox == address(0)) revert MissingEnv("HYPERLANE_MAILBOX");

        // Verify bridge contract exists before deployment
        _verifyBridgeContract("Hyperlane Mailbox", mailbox);

        HyperlaneReceiver hyperlaneReceiver = new HyperlaneReceiver(mailbox, address(receiverContract));

        // HyperlaneReceiver expects the "sender" to be the origin contract that dispatched the message (the messenger).
        hyperlaneReceiver.setTrustedSender(uint32(sourceChainId), l1Messenger, true);
        if (hyperlaneReceiver.owner() != admin) {
            hyperlaneReceiver.transferOwnership(admin);
        }

        console2.log("HyperlaneReceiver:", address(hyperlaneReceiver));
        console2.log("Hyperlane mailbox:", mailbox);
        console2.log("Trusted L1 messenger:", l1Messenger);
        return address(hyperlaneReceiver);
    }

    function _deployAndConfigureLayerZeroReceiver(
        L2SlashingReceiver receiverContract,
        address admin,
        uint256 sourceChainId,
        address l1Messenger
    ) internal returns (address) {
        address endpoint = vm.envOr("LAYERZERO_ENDPOINT", _defaultLayerZeroEndpoint(block.chainid));
        if (endpoint == address(0)) revert MissingEnv("LAYERZERO_ENDPOINT");

        // Verify bridge contract exists before deployment
        _verifyBridgeContract("LayerZero Endpoint", endpoint);

        LayerZeroReceiver lzReceiver = new LayerZeroReceiver(endpoint, address(receiverContract));

        uint32 sourceEid = uint32(vm.envOr("LAYERZERO_SOURCE_EID", uint256(_defaultLayerZeroEid(sourceChainId))));
        if (sourceEid == 0) revert MissingEnv("LAYERZERO_SOURCE_EID");

        lzReceiver.setChainMapping(sourceEid, sourceChainId);
        lzReceiver.setPeer(sourceEid, bytes32(uint256(uint160(l1Messenger))));
        if (lzReceiver.owner() != admin) {
            lzReceiver.transferOwnership(admin);
        }

        console2.log("LayerZeroReceiver:", address(lzReceiver));
        console2.log("LayerZero endpoint:", endpoint);
        console2.log("Source EID:", sourceEid);
        console2.log("Trusted L1 messenger:", l1Messenger);
        return address(lzReceiver);
    }

    function _defaultHyperlaneMailbox(uint256 chainId) internal pure returns (address mailbox) {
        if (chainId == 1) {
            return 0xc005dc82818d67AF737725bD4bf75435d065D239;
        }
        if (chainId == 11155111) {
            return 0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766;
        }
        if (chainId == 17000) {
            return 0x5b6CFf85442B851A8e6eaBd2A4E4507B5135B3B0;
        }
        if (chainId == 8453) {
            return 0xeA87ae93Fa0019a82A727bfd3eBd1cFCa8f64f1D;
        }
        if (chainId == 84532) {
            return 0x6966b0E55883d49BFB24539356a2f8A673E02039;
        }
        return address(0);
    }

    function _defaultLayerZeroEndpoint(uint256 chainId) internal pure returns (address endpoint) {
        if (chainId == 1) {
            return 0x1a44076050125825900e736c501f859c50fE728c;
        }
        if (chainId == 11155111) {
            return 0x6EDCE65403992e310A62460808c4b910D972f10f;
        }
        if (chainId == 17000) {
            return 0x6EDCE65403992e310A62460808c4b910D972f10f;
        }
        if (chainId == 8453) {
            return 0x1a44076050125825900e736c501f859c50fE728c;
        }
        if (chainId == 84532) {
            return 0x6EDCE65403992e310A62460808c4b910D972f10f;
        }
        return address(0);
    }

    function _defaultLayerZeroEid(uint256 chainId) internal pure returns (uint32) {
        if (chainId == 1) return 30101;
        if (chainId == 42161) return 30110;
        if (chainId == 8453) return 30184;
        if (chainId == 11155111) return 40161;
        if (chainId == 421614) return 40231;
        if (chainId == 84532) return 40245;
        return 0;
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
        address staking,
        uint256 sourceChainId,
        address l1Connector,
        address l1Messenger,
        address slasher,
        address receiver,
        address messenger
    ) internal {
        if (bytes(path).length == 0) return;
        _ensureParentDir(path);

        string memory root = "l2Slashing";
        vm.serializeString(root, "kind", "l2-slashing");
        if (bridge == BridgeProtocol.Hyperlane) {
            vm.serializeString(root, "bridge", "hyperlane");
        } else if (bridge == BridgeProtocol.LayerZero) {
            vm.serializeString(root, "bridge", "layerzero");
        } else {
            vm.serializeString(root, "bridge", "direct");
        }
        vm.serializeUint(root, "chainId", block.chainid);
        vm.serializeAddress(root, "admin", admin);
        vm.serializeAddress(root, "staking", staking);
        vm.serializeUint(root, "sourceChainId", sourceChainId);
        vm.serializeAddress(root, "l1Connector", l1Connector);
        vm.serializeAddress(root, "l1Messenger", l1Messenger);
        vm.serializeAddress(root, "slasher", slasher);
        vm.serializeAddress(root, "receiver", receiver);
        string memory json = vm.serializeAddress(root, "messenger", messenger);
        vm.writeJson(json, path);

        console2.log("Wrote L2 slashing manifest:", path);
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
}

/// @title DeployL2SlashingTestnet
/// @notice Convenience script for testnet deployment
contract DeployL2SlashingTestnet is EnvUtils {
    function run() external {
        DeployL2Slashing deploy = new DeployL2Slashing();
        deploy.run(DeployL2Slashing.BridgeProtocol.DirectMessenger);
    }
}

/// @title DeployL2SlashingHyperlane
/// @notice Convenience script for Hyperlane receiver deployments.
contract DeployL2SlashingHyperlane is EnvUtils {
    function run() external {
        DeployL2Slashing deploy = new DeployL2Slashing();
        deploy.run(DeployL2Slashing.BridgeProtocol.Hyperlane);
    }
}

/// @title DeployL2SlashingLayerZero
/// @notice Convenience script for LayerZero receiver deployments.
contract DeployL2SlashingLayerZero is EnvUtils {
    function run() external {
        DeployL2Slashing deploy = new DeployL2Slashing();
        deploy.run(DeployL2Slashing.BridgeProtocol.LayerZero);
    }
}

/// @title ConfigureL2SlashingReceiver
/// @notice Configure an existing L2SlashingReceiver
contract ConfigureL2SlashingReceiver is EnvUtils {
    function run() external {
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address receiverAddr = _requireEnvAddress("RECEIVER");
        address messenger = _requireEnvAddress("MESSENGER");
        uint256 sourceChainId = _requireEnvUint("SOURCE_CHAIN_ID");
        address l1Connector = _requireEnvAddress("L1_CONNECTOR");

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
contract AuthorizeTangleL2Slasher is EnvUtils {
    function run() external {
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address slasherAddr = _requireEnvAddress("SLASHER");
        address caller = _requireEnvAddress("CALLER");

        TangleL2Slasher slasher = TangleL2Slasher(slasherAddr);

        vm.startBroadcast(deployerPrivateKey);

        slasher.setAuthorizedCaller(caller, true);

        vm.stopBroadcast();

        console2.log("Authorized caller:", caller);
    }
}

/// @title PauseTangleL2Slasher
/// @notice Emergency pause for slashing
contract PauseTangleL2Slasher is EnvUtils {
    function run() external {
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address slasherAddr = _requireEnvAddress("SLASHER");
        bool pause = vm.envBool("PAUSE");

        TangleL2Slasher slasher = TangleL2Slasher(slasherAddr);

        vm.startBroadcast(deployerPrivateKey);

        slasher.setPaused(pause);

        vm.stopBroadcast();

        console2.log("Slasher paused:", pause);
    }
}
