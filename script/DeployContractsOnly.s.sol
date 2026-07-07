// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../src/Tangle.sol";
import { IMultiAssetDelegation } from "../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../src/staking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../src/staking/OperatorStatusRegistry.sol";
import { MasterBlueprintServiceManager } from "../src/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../src/MBSMRegistry.sol";

import { TangleBlueprintsFacet } from "../src/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { TangleBlueprintsBinaryVersionsFacet } from "../src/facets/tangle/TangleBlueprintsBinaryVersionsFacet.sol";
import {
    TangleBlueprintsBinaryAttestationsFacet
} from "../src/facets/tangle/TangleBlueprintsBinaryAttestationsFacet.sol";
import { BlueprintAuditors } from "../src/governance/BlueprintAuditors.sol";
import { TangleOperatorsFacet } from "../src/facets/tangle/TangleOperatorsFacet.sol";
import { TangleServicesRequestsFacet } from "../src/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleServicesFacet } from "../src/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesViewsFacet } from "../src/facets/tangle/TangleServicesViewsFacet.sol";
import { TangleServicesLifecycleFacet } from "../src/facets/tangle/TangleServicesLifecycleFacet.sol";
import { TangleJobsFacet } from "../src/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsAggregationFacet } from "../src/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleJobsRFQFacet } from "../src/facets/tangle/TangleJobsRFQFacet.sol";
import { TangleQuotesFacet } from "../src/facets/tangle/TangleQuotesFacet.sol";
import { TangleQuotesExtensionFacet } from "../src/facets/tangle/TangleQuotesExtensionFacet.sol";
import { TanglePaymentsFacet } from "../src/facets/tangle/TanglePaymentsFacet.sol";
import { TanglePaymentsRewardsFacet } from "../src/facets/tangle/TanglePaymentsRewardsFacet.sol";
import { TanglePaymentsDistributionFacet } from "../src/facets/tangle/TanglePaymentsDistributionFacet.sol";
import { TangleSlashingFacet } from "../src/facets/tangle/TangleSlashingFacet.sol";
import { StakingOperatorsFacet } from "../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingUnstakeWithdrawFacet } from "../src/facets/staking/StakingUnstakeWithdrawFacet.sol";
// StakingRewardsFacet removed - no longer exists
import { StakingSlashingFacet } from "../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../src/facets/staking/StakingAdminFacet.sol";

/// @title DeployContractsOnly
/// @notice Deploys ONLY the core contracts without creating any blueprints, services, or operators
/// @dev Run with: forge script script/DeployContractsOnly.s.sol:DeployContractsOnly --rpc-url http://localhost:8545
/// --broadcast -vvv
contract DeployContractsOnly is Script {
    // Anvil default deployer key
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    address deployer;
    address public tangleProxy;
    address public stakingProxy;
    address public statusRegistry;
    address public blueprintAuditors;

    function run() external {
        // This script is for local Anvil only. It hardcodes a well-known dev
        // key, grants every role to the deployer, and performs NO role handoff
        // to a timelock or multisig. Using it on a real chain would leave
        // `BlueprintAuditors.GOVERNANCE_ROLE` (and so the sole `_authorizeUpgrade`
        // authority) on the script's broadcast EOA. Production deploys MUST go
        // through `FullDeploy.s.sol`, which performs the role handoff via
        // `_applyRoleHandoff`.
        require(block.chainid == 31_337, "DeployContractsOnly: local Anvil only; use FullDeploy for production");

        deployer = vm.addr(DEPLOYER_KEY);

        console2.log("=== Deploying Core Contracts Only ===");
        console2.log("Deployer:", deployer);

        vm.startBroadcast(DEPLOYER_KEY);

        // 1. Deploy MultiAssetDelegation (Staking)
        MultiAssetDelegation stakingImpl = new MultiAssetDelegation();
        bytes memory stakingInit = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (deployer, 1 ether, 0.1 ether, 1000) // minOpStake=1ETH, minDelegation=0.1ETH, commissionBps=10%
        );
        stakingProxy = address(new ERC1967Proxy(address(stakingImpl), stakingInit));
        console2.log("MultiAssetDelegation:", stakingProxy);

        // 2. Deploy Tangle
        Tangle tangleImpl = new Tangle();
        bytes memory tangleInit = abi.encodeCall(Tangle.initialize, (deployer, stakingProxy, payable(deployer)));
        tangleProxy = address(new ERC1967Proxy(address(tangleImpl), tangleInit));
        console2.log("Tangle:", tangleProxy);

        // 3. Register facets for Staking
        _registerStakingFacets(stakingProxy);

        // 4. Register facets for Tangle
        _registerTangleFacets(tangleProxy);

        // 5. Deploy OperatorStatusRegistry
        statusRegistry = address(new OperatorStatusRegistry(tangleProxy, deployer));
        console2.log("OperatorStatusRegistry:", statusRegistry);

        // 6. Configure cross-references
        IMultiAssetDelegation staking = IMultiAssetDelegation(payable(stakingProxy));
        staking.addSlasher(tangleProxy);
        staking.setTangle(tangleProxy);

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

        // 8. Deploy BlueprintAuditors registry. Governance-curated weight map used
        //    by off-chain aggregators scoring the permissionless attestations
        //    written via `BlueprintsBinaryAttestations`. The deployer holds
        //    `FIRST_PARTY_ADMIN_ROLE` so a security-council multisig can be
        //    granted/handed-off post-deploy via the standard role flows. In
        //    production, `governor` must be the TangleTimelock proxy address;
        //    we pass `deployer` here as a placeholder for local Anvil runs and
        //    leave production handoff to the FullDeploy / role-handoff scripts.
        BlueprintAuditors auditorsImpl = new BlueprintAuditors();
        ERC1967Proxy auditorsProxy = new ERC1967Proxy(
            address(auditorsImpl), abi.encodeCall(BlueprintAuditors.initialize, (deployer, deployer, deployer))
        );
        blueprintAuditors = address(auditorsProxy);
        console2.log("BlueprintAuditors:", blueprintAuditors);

        vm.stopBroadcast();

        console2.log("\n=== Deployment Complete ===");
        console2.log("Tangle:                  ", tangleProxy);
        console2.log("MultiAssetDelegation:    ", stakingProxy);
        console2.log("OperatorStatusRegistry:  ", statusRegistry);
        console2.log("BlueprintAuditors:       ", blueprintAuditors);
        console2.log("\nNo blueprints, services, or operators created.");
        console2.log("Use CLI or cast to register operators and create blueprints.");
    }

    function _registerStakingFacets(address proxy) internal {
        MultiAssetDelegation mad = MultiAssetDelegation(payable(proxy));
        mad.registerFacet(address(new StakingOperatorsFacet()));
        mad.registerFacet(address(new StakingDepositsFacet()));
        mad.registerFacet(address(new StakingDelegationsFacet()));
        mad.registerFacet(address(new StakingUnstakeWithdrawFacet()));
        // StakingRewardsFacet removed - no longer exists
        mad.registerFacet(address(new StakingSlashingFacet()));
        mad.registerFacet(address(new StakingAssetsFacet()));
        mad.registerFacet(address(new StakingViewsFacet()));
        mad.registerFacet(address(new StakingAdminFacet()));
    }

    function _registerTangleFacets(address proxy) internal {
        Tangle tangle = Tangle(payable(proxy));
        tangle.registerFacet(address(new TangleBlueprintsFacet()));
        tangle.registerFacet(address(new TangleBlueprintsManagementFacet()));
        tangle.registerFacet(address(new TangleBlueprintsBinaryVersionsFacet()));
        tangle.registerFacet(address(new TangleBlueprintsBinaryAttestationsFacet()));
        tangle.registerFacet(address(new TangleOperatorsFacet()));
        tangle.registerFacet(address(new TangleServicesRequestsFacet()));
        tangle.registerFacet(address(new TangleServicesFacet()));
        tangle.registerFacet(address(new TangleServicesViewsFacet()));
        tangle.registerFacet(address(new TangleServicesLifecycleFacet()));
        tangle.registerFacet(address(new TangleJobsFacet()));
        tangle.registerFacet(address(new TangleJobsAggregationFacet()));
        tangle.registerFacet(address(new TangleJobsRFQFacet()));
        tangle.registerFacet(address(new TangleQuotesFacet()));
        tangle.registerFacet(address(new TangleQuotesExtensionFacet()));
        tangle.registerFacet(address(new TanglePaymentsFacet()));
        tangle.registerFacet(address(new TanglePaymentsRewardsFacet()));
        tangle.registerFacet(address(new TanglePaymentsDistributionFacet()));
        tangle.registerFacet(address(new TangleSlashingFacet()));
    }
}
