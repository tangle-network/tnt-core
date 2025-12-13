// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/v2/restaking/OperatorStatusRegistry.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";
import { MasterBlueprintServiceManager } from "../../src/v2/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../src/v2/MBSMRegistry.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

error InvalidAddress(string field);
error ProxyVerificationFailed(string reason);
error AddressNotAllowlisted(string field, address provided, address expected);
error MissingEnv(string key);

abstract contract DeployScriptBase is Script {
    error MissingOperatorBondToken();

    function _requireEnvUint(string memory key) internal view returns (uint256 value) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            revert MissingEnv(key);
        }
    }

    function _envUintOrDefault(string memory key, uint256 defaultValue) internal view returns (uint256 value) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            return defaultValue;
        }
    }

    function _requireEnvAddress(string memory key) internal view returns (address value) {
        try vm.envAddress(key) returns (address raw) {
            return _requireNonZero(raw, key);
        } catch {
            revert MissingEnv(key);
        }
    }

    function _envAddressOrDefault(string memory key, address fallbackValue) internal view returns (address) {
        try vm.envAddress(key) returns (address raw) {
            return _requireNonZero(raw, key);
        } catch {
            return _requireNonZero(fallbackValue, key);
        }
    }

    function _envAddressIfSet(string memory key) internal view returns (address) {
        try vm.envAddress(key) returns (address raw) {
            return raw;
        } catch {
            return address(0);
        }
    }

    function _requireNonZero(address value, string memory field) internal pure returns (address) {
        if (value == address(0)) {
            revert InvalidAddress(field);
        }
        return value;
    }

    function _enforceAllowlist(string memory envKey, string memory field, address candidate) internal view {
        try vm.envAddress(envKey) returns (address allowed) {
            if (allowed != address(0) && candidate != allowed) {
                revert AddressNotAllowlisted(field, candidate, allowed);
            }
        } catch { }
    }

    /// @notice Verify UUPS proxy deployment was successful
    /// @param proxy The proxy address
    /// @param expectedAdmin The expected admin address
    /// @param label Human-readable label for error messages
    function _verifyProxy(address proxy, address expectedAdmin, string memory label) internal view {
        // 1. Check proxy address is valid
        if (proxy == address(0)) {
            revert ProxyVerificationFailed(string.concat(label, ": proxy is zero address"));
        }

        // 2. Check proxy has code (is a contract)
        if (proxy.code.length == 0) {
            revert ProxyVerificationFailed(string.concat(label, ": proxy has no code"));
        }

        // 3. Verify admin role is properly set
        bytes32 adminRole = AccessControlUpgradeable(proxy).DEFAULT_ADMIN_ROLE();
        if (!AccessControlUpgradeable(proxy).hasRole(adminRole, expectedAdmin)) {
            revert ProxyVerificationFailed(string.concat(label, ": admin role not set"));
        }

        console2.log(string.concat("[VERIFIED] ", label, " proxy at"), proxy);
    }
}

/// @title DeployV2
/// @notice Deploy script for Tangle v2 contracts
/// @dev Deploys with UUPS proxies for upgradeability
contract DeployV2 is DeployScriptBase {
    // Configuration
    uint256 public minOperatorStake = 1 ether;
    uint256 public minDelegation = 0.1 ether;
    uint16 public operatorCommissionBps = 1000; // 10%
    address public operatorBondToken;
    uint256 public operatorBondAmount = 100 ether;

    function run() external virtual {
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = _envAddressOrDefault("ADMIN", deployer);
        address treasury = _envAddressOrDefault("TREASURY", deployer);
        _enforceAllowlist("ADMIN_ALLOWLIST", "ADMIN", admin);
        _enforceAllowlist("TREASURY_ALLOWLIST", "TREASURY", treasury);

        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Treasury:", treasury);

        (
            address restakingProxy,
            address restakingImpl,
            address tangleProxy,
            address tangleImpl,
            address statusRegistry
        ) = _deployCore(deployerPrivateKey, deployer, admin, treasury, true);

        // Log summary
        console2.log("\n=== Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("Tangle:", tangleProxy);
        console2.log("MultiAssetDelegation:", restakingProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);
    }

    /// @notice Dry-run deployment for testing/CI without env or broadcast
    function dryRun(
        address deployer,
        address admin,
        address treasury
    )
        external
        returns (address restakingProxy, address tangleProxy, address statusRegistry)
    {
        address deployerAddr = deployer == address(0) ? msg.sender : deployer;
        admin = _requireNonZero(admin == address(0) ? deployerAddr : admin, "ADMIN");
        treasury = _requireNonZero(treasury == address(0) ? deployerAddr : treasury, "TREASURY");
        _enforceAllowlist("ADMIN_ALLOWLIST", "ADMIN", admin);
        _enforceAllowlist("TREASURY_ALLOWLIST", "TREASURY", treasury);
        (restakingProxy,, tangleProxy,, statusRegistry) = _deployCore(0, deployerAddr, admin, treasury, false);
    }

    function _deployCore(
        uint256 deployerPrivateKey,
        address deployer,
        address admin,
        address treasury,
        bool broadcast
    )
        internal
        returns (
            address restakingProxy,
            address restakingImpl,
            address tangleProxy,
            address tangleImpl,
            address statusRegistry
        )
    {
        if (broadcast) {
            vm.startBroadcast(deployerPrivateKey);
        } else if (deployer != address(0)) {
            vm.startPrank(deployer);
        }

        _ensureOperatorBondToken(admin);

        (restakingProxy, restakingImpl) = deployMultiAssetDelegation(admin);
        console2.log("MultiAssetDelegation implementation:", restakingImpl);
        console2.log("MultiAssetDelegation proxy:", restakingProxy);

        (tangleProxy, tangleImpl) = deployTangle(admin, restakingProxy, treasury);
        console2.log("Tangle implementation:", tangleImpl);
        console2.log("Tangle proxy:", tangleProxy);

        statusRegistry = deployOperatorStatusRegistry(tangleProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);

        // Verify proxy deployments
        _verifyProxy(restakingProxy, admin, "MultiAssetDelegation");
        _verifyProxy(tangleProxy, admin, "Tangle");

        MultiAssetDelegation(payable(restakingProxy)).addSlasher(tangleProxy);

        MasterBlueprintServiceManager masterManager = new MasterBlueprintServiceManager(admin, tangleProxy);
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy =
            new ERC1967Proxy(address(registryImpl), abi.encodeCall(MBSMRegistry.initialize, (admin)));
        MBSMRegistry mbsmRegistry = MBSMRegistry(address(registryProxy));
        mbsmRegistry.grantRole(mbsmRegistry.MANAGER_ROLE(), tangleProxy);
        mbsmRegistry.addVersion(address(masterManager));
        Tangle(payable(tangleProxy)).setMBSMRegistry(address(mbsmRegistry));

        console2.log("Granted SLASHER_ROLE to Tangle");
        Tangle(payable(tangleProxy)).setOperatorStatusRegistry(statusRegistry);
        console2.log("Set OperatorStatusRegistry on Tangle");

        _configureOperatorBonds(tangleProxy);

        if (broadcast) {
            vm.stopBroadcast();
        } else if (deployer != address(0)) {
            vm.stopPrank();
        }
    }

    function _configureOperatorBonds(address tangleProxy) internal {
        if (operatorBondToken == address(0)) {
            revert MissingOperatorBondToken();
        }
        Tangle tangle = Tangle(payable(tangleProxy));
        tangle.setOperatorBondAsset(operatorBondToken);
        tangle.setOperatorBlueprintBond(operatorBondAmount);
        console2.log("Configured operator bond asset:", operatorBondToken);
        console2.log("Configured operator bond amount:", operatorBondAmount);
    }

    function _ensureOperatorBondToken(address admin) internal {
        if (operatorBondToken != address(0)) {
            return;
        }

        string memory tokenField = "OPERATOR_BOND_TOKEN";
        address tokenFromEnv = _envAddressIfSet(tokenField);
        if (tokenFromEnv == address(0)) {
            tokenField = "TNT_TOKEN";
            tokenFromEnv = _envAddressIfSet(tokenField);
        }

        if (tokenFromEnv != address(0)) {
            operatorBondToken = _requireNonZero(tokenFromEnv, tokenField);
            operatorBondAmount = _envUintOrDefault("OPERATOR_BOND_AMOUNT", operatorBondAmount);
            console2.log("Using existing TNT token from env:", operatorBondToken);
            return;
        }

        operatorBondToken = _deployTNTToken(admin);
        operatorBondAmount = _envUintOrDefault("OPERATOR_BOND_AMOUNT", operatorBondAmount);
    }

    function _deployTNTToken(address admin) internal returns (address) {
        uint256 initialSupply = _envUintOrDefault("TNT_INITIAL_SUPPLY", 1_000_000 ether);
        TangleToken tokenImpl = new TangleToken();
        ERC1967Proxy tokenProxy =
            new ERC1967Proxy(address(tokenImpl), abi.encodeCall(TangleToken.initialize, (admin, initialSupply)));
        console2.log("Deployed TangleToken proxy:", address(tokenProxy));
        console2.log("Initial TNT supply minted to admin:", initialSupply);
        return address(tokenProxy);
    }

    function deployMultiAssetDelegation(address admin) internal returns (address proxy, address impl) {
        // Deploy implementation
        MultiAssetDelegation implementation = new MultiAssetDelegation();
        impl = address(implementation);

        // Deploy proxy
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize, (admin, minOperatorStake, minDelegation, operatorCommissionBps)
        );

        ERC1967Proxy proxyContract = new ERC1967Proxy(impl, initData);
        proxy = address(proxyContract);
    }

    function deployTangle(
        address admin,
        address restaking,
        address treasury
    )
        internal
        returns (address proxy, address impl)
    {
        // Deploy implementation
        Tangle implementation = new Tangle();
        impl = address(implementation);

        // Deploy proxy
        bytes memory initData = abi.encodeCall(Tangle.initialize, (admin, restaking, payable(treasury)));

        ERC1967Proxy proxyContract = new ERC1967Proxy(impl, initData);
        proxy = address(proxyContract);
    }

    function setBondConfig(address token, uint256 amount) public {
        operatorBondToken = token;
        operatorBondAmount = amount;
    }

    function deployOperatorStatusRegistry(address tangleCore) internal returns (address) {
        // OperatorStatusRegistry is not upgradeable - uses immutable tangleCore
        OperatorStatusRegistry registry = new OperatorStatusRegistry(tangleCore);
        return address(registry);
    }
}

/// @title UpgradeTangle
/// @notice Upgrade Tangle to new implementation
contract UpgradeTangle is DeployScriptBase {
    function run() external {
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address tangleProxy = vm.envAddress("TANGLE_PROXY");

        console2.log("Upgrading Tangle proxy:", tangleProxy);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        Tangle newImplementation = new Tangle();
        console2.log("New implementation:", address(newImplementation));

        // Upgrade (caller must have UPGRADER_ROLE)
        Tangle(payable(tangleProxy)).upgradeToAndCall(address(newImplementation), "");
        console2.log("Upgrade complete");

        vm.stopBroadcast();
    }
}

/// @title UpgradeMultiAssetDelegation
/// @notice Upgrade MultiAssetDelegation to new implementation
contract UpgradeMultiAssetDelegation is DeployScriptBase {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address restakingProxy = vm.envAddress("RESTAKING_PROXY");

        console2.log("Upgrading MultiAssetDelegation proxy:", restakingProxy);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        MultiAssetDelegation newImplementation = new MultiAssetDelegation();
        console2.log("New implementation:", address(newImplementation));

        // Upgrade
        MultiAssetDelegation(payable(restakingProxy)).upgradeToAndCall(address(newImplementation), "");
        console2.log("Upgrade complete");

        vm.stopBroadcast();
    }
}
