// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { L2SlashingReceiver } from "../src/beacon/L2SlashingReceiver.sol";
import { TangleL2Slasher } from "../src/beacon/TangleL2Slasher.sol";

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
        } catch { }
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
    uint256 public constant ETHEREUM_SEPOLIA = 11_155_111;
    uint256 public constant ETHEREUM_HOLESKY = 17_000;
    // Chain IDs - Base
    uint256 public constant BASE_MAINNET = 8453;
    uint256 public constant BASE_SEPOLIA = 84_532;

    // Bridge protocol selection
    enum BridgeProtocol {
        DirectMessenger, // For testing with direct calls
        OpStack // OP-Stack canonical CrossDomainMessenger (Base/Optimism) — native, no third-party trust
    }

    /// @notice OP-Stack L2CrossDomainMessenger predeploy (same address on all OP chains).
    address internal constant OP_L2_CROSS_DOMAIN_MESSENGER = 0x4200000000000000000000000000000000000007;

    /// @notice True on mainnets where slashing would be live. Bypass on local with TANGLE_DEPLOY_LOCAL=1.
    function _isProductionChain() internal view returns (bool) {
        if (vm.envOr("TANGLE_DEPLOY_LOCAL", uint256(0)) != 0) return false;
        uint256 id = block.chainid;
        return id == ETHEREUM_MAINNET || id == BASE_MAINNET || id == 5845 || id == 42_161 || id == 10;
    }

    /// @notice Refuse to deploy L2 slashing to a production chain with hot-key admin or the
    ///         deployer-controlled DirectMessenger mock bridge.
    function _requireProductionL2Config(address deployer, address admin, BridgeProtocol bridge) internal view {
        if (!_isProductionChain()) return;
        require(bridge != BridgeProtocol.DirectMessenger, "config: DirectMessenger forbidden on production");
        require(admin != deployer, "config: ADMIN must be a multisig/timelock, not the deployer");
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

        // Fail closed on production chains: ADMIN must be an explicit non-deployer
        // timelock/multisig (it owns the receiver/slasher and activates trust anchors), and
        // the DirectMessenger mock path (deployer-controlled slashing) must never reach mainnet.
        _requireProductionL2Config(deployer, admin, bridge);

        console2.log("=== L2 Slashing Receiver Deployment ===");
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Staking:", staking);
        console2.log("Source Chain ID:", sourceChainId);
        if (bridge != BridgeProtocol.DirectMessenger) {
            console2.log("L1 Messenger:", l1Messenger);
        }

        (address slasher, address receiver, address bridgeReceiver) = _deploy(
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

        // Own the slasher as the deployer during setup so `setAuthorizedCaller` below succeeds,
        // then hand off to `admin` at the bottom (mirrors the receiver). Constructing it owned by
        // `admin` directly would revert `setAuthorizedCaller` whenever admin != deployer (i.e.
        // always in production), since that call runs in the deployer's broadcast context.
        TangleL2Slasher slasherContract = new TangleL2Slasher(staking, deployer);
        slasher = address(slasherContract);
        console2.log("TangleL2Slasher:", slasher);

        // Pass `address(0)` as the initializer's initial messenger so the
        // first `setMessenger` call below takes the bootstrap path (immediate
        // write). Subsequent swaps go through the 2-day timelock; without the
        // bootstrap exemption the deploy flow would deadlock for two days.
        address initialMessenger = address(0);
        // Deployer placeholder retained for None-bridge path below.
        address fallbackMessenger = messengerOverride != address(0) ? messengerOverride : deployer;
        // C-3 (Round 4): deploy L2SlashingReceiver behind ERC1967 proxy. The
        // deployer is wired in as the initial owner so post-deploy configuration
        // (`setMessenger`, `setAuthorizedSender`) succeeds; ownership is then
        // transferred to `admin` at the bottom of this function.
        L2SlashingReceiver receiverImpl = new L2SlashingReceiver();
        ERC1967Proxy receiverProxy = new ERC1967Proxy(
            address(receiverImpl), abi.encodeCall(L2SlashingReceiver.initialize, (slasher, initialMessenger, deployer))
        );
        L2SlashingReceiver receiverContract = L2SlashingReceiver(address(receiverProxy));
        receiver = address(receiverContract);
        console2.log("L2SlashingReceiver impl:", address(receiverImpl));
        console2.log("L2SlashingReceiver proxy:", receiver);

        slasherContract.setAuthorizedCaller(receiver, true);
        console2.log("Authorized receiver as slasher caller");

        if (bridge == BridgeProtocol.OpStack) {
            // OP-Stack native path: NO bridge adapter. The receiver talks directly to the OP
            // L2CrossDomainMessenger predeploy and authenticates the L1 origin via
            // xDomainMessageSender(). The trusted L1 sender is the L1 BaseCrossChainMessenger
            // adapter (the contract that calls L1CrossDomainMessenger.sendMessage), passed as
            // L1_MESSENGER — NOT the connector. No ISM/DVN to pin; trust is Base/Ethereum itself.
            if (l1Messenger == address(0)) revert MissingEnv("L1_MESSENGER");
            bridgeReceiver = address(0);
            address l2Messenger = vm.envOr("L2_CROSS_DOMAIN_MESSENGER", OP_L2_CROSS_DOMAIN_MESSENGER);
            receiverContract.setMessenger(l2Messenger); // bootstrap (immediate)
            receiverContract.setOpStackMessengerMode(true);
            // Timelocked: schedules the trusted L1 sender; admin must activateOpStackL1Sender
            // after SENDER_ACTIVATION_DELAY before slashing relays.
            receiverContract.setOpStackL1Sender(sourceChainId, l1Messenger, true);
            console2.log("OP-Stack mode: L2 messenger set; opStack L1 sender SCHEDULED (activate after delay):");
            console2.log("  l2Messenger:", l2Messenger);
            console2.log("  l1Sender (BaseCrossChainMessenger):", l1Messenger);
        } else {
            bridgeReceiver = address(0);
            receiverContract.setMessenger(fallbackMessenger);
        }

        // authorizedSenders is the adapter-path auth; in OP-Stack mode the receiver uses
        // opStackL1Sender instead, so skip it there (harmless but meaningless otherwise).
        if (l1Connector != address(0) && bridge != BridgeProtocol.OpStack) {
            receiverContract.setAuthorizedSender(sourceChainId, l1Connector, true);
            console2.log("Authorized L1 connector:", l1Connector);
        }

        if (receiverContract.owner() != admin) {
            receiverContract.transferOwnership(admin);
            console2.log("Transferred L2SlashingReceiver ownership to admin");
        }
        if (slasherContract.owner() != admin) {
            slasherContract.transferOwnership(admin);
            console2.log("Transferred TangleL2Slasher ownership to admin");
        }

        if (broadcast) {
            vm.stopBroadcast();
        } else if (deployer != address(0)) {
            vm.stopPrank();
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
        address staking,
        uint256 sourceChainId,
        address l1Connector,
        address l1Messenger,
        address slasher,
        address receiver,
        address messenger
    )
        internal
    {
        if (bytes(path).length == 0) return;
        _ensureParentDir(path);

        string memory root = "l2Slashing";
        vm.serializeString(root, "kind", "l2-slashing");
        if (bridge == BridgeProtocol.OpStack) {
            vm.serializeString(root, "bridge", "opstack");
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

/// @title DeployL2SlashingOpStack
/// @notice OP-Stack (Base/Optimism) native receiver deployment — recommended for Base. Uses the
///         canonical L2CrossDomainMessenger; no third-party bridge, no ISM/DVN to pin.
contract DeployL2SlashingOpStack is EnvUtils {
    function run() external {
        DeployL2Slashing deploy = new DeployL2Slashing();
        deploy.run(DeployL2Slashing.BridgeProtocol.OpStack);
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
