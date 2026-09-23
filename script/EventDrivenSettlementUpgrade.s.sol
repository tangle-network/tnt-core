// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";

import { Tangle } from "../src/Tangle.sol";
import { TangleJobsFacet } from "../src/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsAggregationFacet } from "../src/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleServicesFacet } from "../src/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesRequestsFacet } from "../src/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleJobsRFQFacet } from "../src/facets/tangle/TangleJobsRFQFacet.sol";
import { TangleQuotesFacet } from "../src/facets/tangle/TangleQuotesFacet.sol";
import { TangleBlueprintsManagementFacet } from "../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { IFacetSelectors } from "../src/interfaces/IFacetSelectors.sol";

interface IRouterAdmin {
    function replaceFacets(address[] calldata facets) external;
    function facetForSelector(bytes4 selector) external view returns (address);
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;
    function getServicePaymentAsset(uint64 serviceId) external view returns (address);
    function getBlueprintSettlementAsset(uint64 blueprintId) external view returns (address);
}

/// @title EventDrivenSettlementUpgrade
/// @notice Upgrades a live Tangle facet-router deployment to tnt-core #209 (EventDriven per-job
///         settlement in the blueprint's declared asset, native OR ERC20).
///
/// Mechanism (deployer must hold UPGRADER_ROLE, which gates both the UUPS swap and the facet
/// registry):
///   1. Deploy the new router implementation (`Tangle`) and the 7 changed facets. These are
///      plain deployments; the live router is untouched until step 3.
///   2. Print the rollback map from real pre-upgrade chain state: the current implementation
///      and, for every selector each new facet will claim, the facet that serves it today.
///   3. ONE transaction: `upgradeToAndCall(newImpl, replaceFacets(facets))`. The UUPS swap
///      installs the new implementation and, in the same call, delegatecalls its
///      `replaceFacets` so every changed selector is re-pointed. There is no window in which
///      an entry point is unrouted, and an interrupted broadcast cannot leave one dead: either
///      the whole upgrade landed or none of it did.
///
/// `replaceFacets` re-maps EXACTLY the selectors each facet's `selectors()` returns and touches
/// nothing else — every other selector (staking, operators, slashing, quotes-extension, payments,
/// views, blueprints-create, binary-versions/attestations) keeps its current facet.
///
/// Rollback (needs the printed map): the new implementation must stay installed long enough to
/// run `replaceFacets(oldFacets)` — the previous implementation has no `replaceFacets` — then
/// `clearFacetSelectors` for selectors that only exist on the new facets, then
/// `upgradeToAndCall(oldImpl, "")`.
///
/// Usage (simulate):
///   PRIVATE_KEY=$KEY TANGLE_PROXY=0xff13.. \
///     forge script script/EventDrivenSettlementUpgrade.s.sol:EventDrivenSettlementUpgrade \
///     --rpc-url https://rpc.moderato.tempo.xyz --gas-estimate-multiplier 110
/// Add --broadcast --slow to execute.
contract EventDrivenSettlementUpgrade is Script {
    /// @dev ERC-1967 implementation slot: bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1).
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address payable proxy = payable(vm.envAddress("TANGLE_PROXY"));
        IRouterAdmin router = IRouterAdmin(proxy);

        console2.log("=== EventDriven ERC20 Settlement Upgrade (#209) ===");
        console2.log("Deployer:     ", deployer);
        console2.log("Tangle proxy: ", proxy);

        vm.startBroadcast(deployerKey);

        // 1. Deploy the new router implementation and the 7 changed facets.
        Tangle newImpl = new Tangle();
        string[7] memory names;
        names[0] = "jobs";
        names[1] = "jobsAgg";
        names[2] = "services";
        names[3] = "servicesReq";
        names[4] = "jobsRfq";
        names[5] = "quotes";
        names[6] = "bpMgmt";
        address[] memory facets = new address[](7);
        facets[0] = address(new TangleJobsFacet());
        facets[1] = address(new TangleJobsAggregationFacet());
        facets[2] = address(new TangleServicesFacet());
        facets[3] = address(new TangleServicesRequestsFacet());
        facets[4] = address(new TangleJobsRFQFacet());
        facets[5] = address(new TangleQuotesFacet());
        facets[6] = address(new TangleBlueprintsManagementFacet());

        console2.log("newImpl:      ", address(newImpl));
        for (uint256 i = 0; i < facets.length; i++) {
            console2.log(names[i], facets[i]);
        }

        // 2. Rollback map from pre-upgrade chain state: the implementation being replaced and,
        //    per new facet, the facet that currently serves each selector it will claim
        //    (address(0) = a selector that is new in this release).
        address oldImpl = address(uint160(uint256(vm.load(proxy, IMPLEMENTATION_SLOT))));
        console2.log("PRE implementation:", oldImpl);
        for (uint256 i = 0; i < facets.length; i++) {
            bytes4[] memory sels = IFacetSelectors(facets[i]).selectors();
            console2.log("PRE facet map for", names[i]);
            for (uint256 j = 0; j < sels.length; j++) {
                console2.log("  selector", vm.toString(abi.encodePacked(sels[j])), "->", router.facetForSelector(sels[j]));
            }
        }

        // 3. Implementation swap and facet re-point in ONE transaction.
        router.upgradeToAndCall(address(newImpl), abi.encodeCall(IRouterAdmin.replaceFacets, (facets)));

        vm.stopBroadcast();

        // Post-upgrade assertions (run in the simulated/broadcast EVM).
        address postImpl = address(uint160(uint256(vm.load(proxy, IMPLEMENTATION_SLOT))));
        console2.log("POST implementation:", postImpl);
        require(postImpl == address(newImpl), "implementation not swapped");
        for (uint256 i = 0; i < facets.length; i++) {
            bytes4[] memory sels = IFacetSelectors(facets[i]).selectors();
            for (uint256 j = 0; j < sels.length; j++) {
                require(router.facetForSelector(sels[j]) == facets[i], "selector not repointed");
            }
        }
        // New selectors of this release are routed to the new BlueprintsManagement facet.
        bytes4 setAsset = bytes4(keccak256("setBlueprintSettlementAsset(uint64,address)"));
        bytes4 getAsset = bytes4(keccak256("getBlueprintSettlementAsset(uint64)"));
        require(router.facetForSelector(setAsset) == facets[6], "setBlueprintSettlementAsset not routed");
        require(router.facetForSelector(getAsset) == facets[6], "getBlueprintSettlementAsset not routed");
        // New router view reachable (address(0) = native default for an existing service).
        console2.log("POST getServicePaymentAsset(0):", router.getServicePaymentAsset(0));
        console2.log("=== upgrade assertions passed ===");
    }
}
