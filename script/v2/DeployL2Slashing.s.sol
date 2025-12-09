// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";

import {L2SlashingReceiver} from "../../src/v2/beacon/L2SlashingReceiver.sol";
import {TangleL2Slasher} from "../../src/v2/beacon/TangleL2Slasher.sol";

error MissingEnv(string key);
error AddressNotAllowlisted(string key, address provided, address expected);

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
}

/// @title DeployL2Slashing
/// @notice Deploy script for L2 (Tangle) slashing receiver infrastructure
/// @dev Deploys to Tangle mainnet/testnet
contract DeployL2Slashing is EnvUtils {
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
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = _envAddressOrDefault("ADMIN", deployer);
        address restaking = _requireEnvAddress("RESTAKING");
        uint256 sourceChainId = vm.envOr("SOURCE_CHAIN_ID", ETHEREUM_SEPOLIA);
        address l1Connector = vm.envOr("L1_CONNECTOR", address(0));
        address messengerOverride = vm.envOr("MOCK_MESSENGER", deployer);
        if (messengerOverride == address(0)) revert MissingEnv("MOCK_MESSENGER");

        _enforceAllowlist("ADMIN_ALLOWLIST", admin);
        _enforceAllowlist("RESTAKING_ALLOWLIST", restaking);
        if (l1Connector != address(0)) {
            _enforceAllowlist("L1_CONNECTOR_ALLOWLIST", l1Connector);
        }
        _enforceAllowlist("MESSENGER_ALLOWLIST", messengerOverride);

        console2.log("=== L2 Slashing Receiver Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Restaking:", restaking);
        console2.log("Source Chain ID:", sourceChainId);

        (
            address slasher,
            address receiver,
            address bridgeReceiver
        ) = _deploy(
            bridge,
            deployerPrivateKey,
            deployer,
            admin,
            restaking,
            sourceChainId,
            l1Connector,
            messengerOverride,
            true
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
        address restaking,
        uint256 sourceChainId,
        address l1Connector,
        address messengerOverride
    )
        external
        returns (address slasher, address receiver)
    {
        _enforceAllowlist("ADMIN_ALLOWLIST", admin);
        _enforceAllowlist("RESTAKING_ALLOWLIST", restaking);
        if (l1Connector != address(0)) {
            _enforceAllowlist("L1_CONNECTOR_ALLOWLIST", l1Connector);
        }
        if (messengerOverride != address(0)) {
            _enforceAllowlist("MESSENGER_ALLOWLIST", messengerOverride);
        }
        (slasher, receiver,) = _deploy(
            bridge,
            0,
            deployer == address(0) ? msg.sender : deployer,
            admin,
            restaking,
            sourceChainId,
            l1Connector,
            messengerOverride,
            false
        );
    }

    function _deploy(
        BridgeProtocol bridge,
        uint256 deployerPrivateKey,
        address deployer,
        address admin,
        address restaking,
        uint256 sourceChainId,
        address l1Connector,
        address messengerOverride,
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

        TangleL2Slasher slasherContract = new TangleL2Slasher(restaking, admin);
        slasher = address(slasherContract);
        console2.log("TangleL2Slasher:", slasher);

        address messengerAddr;
        if (bridge == BridgeProtocol.Hyperlane) {
            bridgeReceiver = deployHyperlaneReceiver(sourceChainId, l1Connector);
            messengerAddr = bridgeReceiver;
        } else if (bridge == BridgeProtocol.LayerZero) {
            bridgeReceiver = deployLayerZeroReceiver(sourceChainId, l1Connector);
            messengerAddr = bridgeReceiver;
        } else {
            messengerAddr = messengerOverride != address(0) ? messengerOverride : deployer;
            bridgeReceiver = address(0);
        }

        L2SlashingReceiver receiverContract = new L2SlashingReceiver(slasher, messengerAddr);
        receiver = address(receiverContract);
        console2.log("L2SlashingReceiver:", receiver);

        slasherContract.setAuthorizedCaller(receiver, true);
        console2.log("Authorized receiver as slasher caller");

        if (l1Connector != address(0)) {
            receiverContract.setAuthorizedSender(sourceChainId, l1Connector, true);
            console2.log("Authorized L1 connector:", l1Connector);
        }

        if (broadcast) {
            vm.stopBroadcast();
        } else if (deployer != address(0)) {
            vm.stopPrank();
        }
    }

    /// @dev Deploy and configure HyperlaneReceiver
    /// Note: The receiver will be set as messenger for L2SlashingReceiver
    /// This is a placeholder that returns deployer for now - configure after L2SlashingReceiver is deployed
    function deployHyperlaneReceiver(
        uint256 sourceChainId,
        address l1Connector
    ) internal view returns (address) {
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
    ) internal view returns (address) {
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
contract DeployL2SlashingTestnet is EnvUtils {
    function run() external {
        DeployL2Slashing deploy = new DeployL2Slashing();
        deploy.run(DeployL2Slashing.BridgeProtocol.DirectMessenger);
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
