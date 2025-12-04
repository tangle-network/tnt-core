// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/v2/restaking/OperatorStatusRegistry.sol";

/// @title DeployV2
/// @notice Deploy script for Tangle v2 contracts
/// @dev Deploys with UUPS proxies for upgradeability
contract DeployV2 is Script {
    // Configuration
    uint256 public minOperatorStake = 1 ether;
    uint256 public minDelegation = 0.1 ether;
    uint16 public operatorCommissionBps = 1000; // 10%

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = vm.envOr("ADMIN", deployer);
        address treasury = vm.envOr("TREASURY", deployer);

        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Treasury:", treasury);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy MultiAssetDelegation
        (address restakingProxy, address restakingImpl) = deployMultiAssetDelegation(admin);
        console2.log("MultiAssetDelegation implementation:", restakingImpl);
        console2.log("MultiAssetDelegation proxy:", restakingProxy);

        // Deploy Tangle
        (address tangleProxy, address tangleImpl) = deployTangle(admin, restakingProxy, treasury);
        console2.log("Tangle implementation:", tangleImpl);
        console2.log("Tangle proxy:", tangleProxy);

        // Deploy OperatorStatusRegistry (needs Tangle address)
        address statusRegistry = deployOperatorStatusRegistry(tangleProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);

        // Configure cross-references
        MultiAssetDelegation(payable(restakingProxy)).addSlasher(tangleProxy);
        console2.log("Granted SLASHER_ROLE to Tangle");

        Tangle(payable(tangleProxy)).setOperatorStatusRegistry(statusRegistry);
        console2.log("Set OperatorStatusRegistry on Tangle");

        vm.stopBroadcast();

        // Log summary
        console2.log("\n=== Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("Tangle:", tangleProxy);
        console2.log("MultiAssetDelegation:", restakingProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);
    }

    function deployMultiAssetDelegation(address admin) internal returns (address proxy, address impl) {
        // Deploy implementation
        MultiAssetDelegation implementation = new MultiAssetDelegation();
        impl = address(implementation);

        // Deploy proxy
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, minOperatorStake, minDelegation, operatorCommissionBps)
        );

        ERC1967Proxy proxyContract = new ERC1967Proxy(impl, initData);
        proxy = address(proxyContract);
    }

    function deployTangle(
        address admin,
        address restaking,
        address treasury
    ) internal returns (address proxy, address impl) {
        // Deploy implementation
        Tangle implementation = new Tangle();
        impl = address(implementation);

        // Deploy proxy
        bytes memory initData = abi.encodeCall(
            Tangle.initialize,
            (admin, restaking, payable(treasury))
        );

        ERC1967Proxy proxyContract = new ERC1967Proxy(impl, initData);
        proxy = address(proxyContract);
    }

    function deployOperatorStatusRegistry(address tangleCore) internal returns (address) {
        // OperatorStatusRegistry is not upgradeable - uses immutable tangleCore
        OperatorStatusRegistry registry = new OperatorStatusRegistry(tangleCore);
        return address(registry);
    }
}

/// @title UpgradeTangle
/// @notice Upgrade Tangle to new implementation
contract UpgradeTangle is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
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
contract UpgradeMultiAssetDelegation is Script {
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
