// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/v2/restaking/OperatorStatusRegistry.sol";
import { MasterBlueprintServiceManager } from "../../src/v2/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../src/v2/MBSMRegistry.sol";

import { TangleBlueprintsFacet } from "../../src/v2/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../../src/v2/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { TangleOperatorsFacet } from "../../src/v2/facets/tangle/TangleOperatorsFacet.sol";
import { TangleServicesRequestsFacet } from "../../src/v2/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleServicesFacet } from "../../src/v2/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesLifecycleFacet } from "../../src/v2/facets/tangle/TangleServicesLifecycleFacet.sol";
import { TangleJobsFacet } from "../../src/v2/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsAggregationFacet } from "../../src/v2/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleQuotesFacet } from "../../src/v2/facets/tangle/TangleQuotesFacet.sol";
import { TangleQuotesExtensionFacet } from "../../src/v2/facets/tangle/TangleQuotesExtensionFacet.sol";
import { TanglePaymentsFacet } from "../../src/v2/facets/tangle/TanglePaymentsFacet.sol";
import { TangleSlashingFacet } from "../../src/v2/facets/tangle/TangleSlashingFacet.sol";
import { RestakingOperatorsFacet } from "../../src/v2/facets/restaking/RestakingOperatorsFacet.sol";
import { RestakingDepositsFacet } from "../../src/v2/facets/restaking/RestakingDepositsFacet.sol";
import { RestakingDelegationsFacet } from "../../src/v2/facets/restaking/RestakingDelegationsFacet.sol";
// RestakingRewardsFacet removed - no longer exists
import { RestakingSlashingFacet } from "../../src/v2/facets/restaking/RestakingSlashingFacet.sol";
import { RestakingAssetsFacet } from "../../src/v2/facets/restaking/RestakingAssetsFacet.sol";
import { RestakingViewsFacet } from "../../src/v2/facets/restaking/RestakingViewsFacet.sol";
import { RestakingAdminFacet } from "../../src/v2/facets/restaking/RestakingAdminFacet.sol";

/// @title DeployContractsOnly
/// @notice Deploys ONLY the core contracts without creating any blueprints, services, or operators
/// @dev Run with: forge script script/v2/DeployContractsOnly.s.sol:DeployContractsOnly --rpc-url http://localhost:8545 --broadcast -vvv
contract DeployContractsOnly is Script {
    // Anvil default deployer key
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    address deployer;
    address public tangleProxy;
    address public restakingProxy;
    address public statusRegistry;

    function run() external {
        deployer = vm.addr(DEPLOYER_KEY);

        console2.log("=== Deploying Core Contracts Only ===");
        console2.log("Deployer:", deployer);

        vm.startBroadcast(DEPLOYER_KEY);

        // 1. Deploy MultiAssetDelegation (Restaking)
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();
        bytes memory restakingInit = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (deployer, 1 ether, 0.1 ether, 1000) // minOpStake=1ETH, minDelegation=0.1ETH, commissionBps=10%
        );
        restakingProxy = address(new ERC1967Proxy(address(restakingImpl), restakingInit));
        console2.log("MultiAssetDelegation:", restakingProxy);

        // 2. Deploy Tangle
        Tangle tangleImpl = new Tangle();
        bytes memory tangleInit = abi.encodeCall(Tangle.initialize, (deployer, restakingProxy, payable(deployer)));
        tangleProxy = address(new ERC1967Proxy(address(tangleImpl), tangleInit));
        console2.log("Tangle:", tangleProxy);

        // 3. Register facets for Restaking
        _registerRestakingFacets(restakingProxy);

        // 4. Register facets for Tangle
        _registerTangleFacets(tangleProxy);

        // 5. Deploy OperatorStatusRegistry
        statusRegistry = address(new OperatorStatusRegistry(tangleProxy, deployer));
        console2.log("OperatorStatusRegistry:", statusRegistry);

        // 6. Configure cross-references
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));
        restaking.addSlasher(tangleProxy);

        Tangle tangle = Tangle(payable(tangleProxy));
        tangle.setOperatorStatusRegistry(statusRegistry);

        // 7. Deploy MBSM Registry
        MasterBlueprintServiceManager masterManager = new MasterBlueprintServiceManager(deployer, tangleProxy);
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy =
            new ERC1967Proxy(address(registryImpl), abi.encodeCall(MBSMRegistry.initialize, (deployer)));
        MBSMRegistry registry = MBSMRegistry(address(registryProxy));
        registry.grantRole(registry.MANAGER_ROLE(), tangleProxy);
        registry.addVersion(address(masterManager));
        tangle.setMBSMRegistry(address(registryProxy));
        console2.log("MBSMRegistry:", address(registryProxy));

        vm.stopBroadcast();

        console2.log("\n=== Deployment Complete ===");
        console2.log("Tangle:                  ", tangleProxy);
        console2.log("MultiAssetDelegation:    ", restakingProxy);
        console2.log("OperatorStatusRegistry:  ", statusRegistry);
        console2.log("\nNo blueprints, services, or operators created.");
        console2.log("Use CLI or cast to register operators and create blueprints.");
    }

    function _registerRestakingFacets(address proxy) internal {
        MultiAssetDelegation mad = MultiAssetDelegation(payable(proxy));
        mad.registerFacet(address(new RestakingOperatorsFacet()));
        mad.registerFacet(address(new RestakingDepositsFacet()));
        mad.registerFacet(address(new RestakingDelegationsFacet()));
        // RestakingRewardsFacet removed - no longer exists
        mad.registerFacet(address(new RestakingSlashingFacet()));
        mad.registerFacet(address(new RestakingAssetsFacet()));
        mad.registerFacet(address(new RestakingViewsFacet()));
        mad.registerFacet(address(new RestakingAdminFacet()));
    }

    function _registerTangleFacets(address proxy) internal {
        Tangle tangle = Tangle(payable(proxy));
        tangle.registerFacet(address(new TangleBlueprintsFacet()));
        tangle.registerFacet(address(new TangleBlueprintsManagementFacet()));
        tangle.registerFacet(address(new TangleOperatorsFacet()));
        tangle.registerFacet(address(new TangleServicesRequestsFacet()));
        tangle.registerFacet(address(new TangleServicesFacet()));
        tangle.registerFacet(address(new TangleServicesLifecycleFacet()));
        tangle.registerFacet(address(new TangleJobsFacet()));
        tangle.registerFacet(address(new TangleJobsAggregationFacet()));
        tangle.registerFacet(address(new TangleQuotesFacet()));
        tangle.registerFacet(address(new TangleQuotesExtensionFacet()));
        tangle.registerFacet(address(new TanglePaymentsFacet()));
        tangle.registerFacet(address(new TangleSlashingFacet()));
    }
}
