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
    function registerFacet(address facet) external;
    function registerFacetSelectors(address facet, bytes4[] calldata selectors) external;
    function clearFacetSelectors(bytes4[] calldata selectors) external;
    function facetForSelector(bytes4 selector) external view returns (address);
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;
    function getServicePaymentAsset(uint64 serviceId) external view returns (address);
    function getBlueprintSettlementAsset(uint64 blueprintId) external view returns (address);
}

/// @title EventDrivenSettlementUpgrade
/// @notice Upgrades an EXISTING live Tangle facet-router deployment to tnt-core #209
///         (EventDriven per-job settlement in the blueprint's declared asset, native OR ERC20).
///
/// Mechanism (single broadcast, deployer must hold BOTH UPGRADER_ROLE — for the UUPS impl
/// swap AND the facet registry — plus be able to reach the router admin surface):
///   1. Deploy the new router implementation (`Tangle`) + the 7 changed facets.
///   2. UUPS `upgradeToAndCall(newImpl, "")` — brings in the new `TangleCoreApi.getServicePaymentAsset`
///      view and the appended storage (slots 90/91, gap 27->25, append-only: no migration).
///   3. For each changed facet: `clearFacetSelectors(newFacet.selectors())` then
///      `registerFacet(newFacet)`. Clearing first is REQUIRED because `_setFacetSelectors`
///      reverts (`SelectorAlreadyRegistered`) when a selector still points at the OLD facet.
///      Clearing a not-yet-mapped selector (the 2 new BlueprintsManagement selectors) is a
///      harmless delete-of-zero, so clearing the NEW selector set is always safe.
///
/// The register step re-maps EXACTLY the selectors each facet's `selectors()` returns and
/// touches nothing else — every other selector (staking, operators, slashing, quotes-extension,
/// payments, views, blueprints-create, binary-versions/attestations) keeps its current facet.
///
/// Usage (simulate):
///   PRIVATE_KEY=$KEY TANGLE_PROXY=0xff13.. \
///     forge script script/EventDrivenSettlementUpgrade.s.sol:EventDrivenSettlementUpgrade \
///     --rpc-url https://rpc.moderato.tempo.xyz --gas-estimate-multiplier 110
/// Add --broadcast --slow to execute.
contract EventDrivenSettlementUpgrade is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address payable proxy = payable(vm.envAddress("TANGLE_PROXY"));
        IRouterAdmin router = IRouterAdmin(proxy);

        console2.log("=== EventDriven ERC20 Settlement Upgrade (#209) ===");
        console2.log("Deployer:     ", deployer);
        console2.log("Tangle proxy: ", proxy);

        // Snapshot the CURRENT facet for one representative selector of every facet we touch,
        // so the rollback map is printed against real on-chain state (pre-upgrade).
        bytes4 SUBMIT_JOB = 0x3413e8ee; // submitJob(uint64,uint8,bytes)   -> TangleJobsFacet
        bytes4 BLUEPRINT_COUNT = 0xc602d4fa; // blueprintCount()          -> TangleBlueprintsManagementFacet
        console2.log("PRE  submitJob facet:      ", router.facetForSelector(SUBMIT_JOB));
        console2.log("PRE  blueprintCount facet: ", router.facetForSelector(BLUEPRINT_COUNT));

        vm.startBroadcast(deployerKey);

        // 1. Deploy new router impl + all 7 changed facets.
        Tangle newImpl = new Tangle();
        TangleJobsFacet jobs = new TangleJobsFacet();
        TangleJobsAggregationFacet jobsAgg = new TangleJobsAggregationFacet();
        TangleServicesFacet services = new TangleServicesFacet();
        TangleServicesRequestsFacet servicesReq = new TangleServicesRequestsFacet();
        TangleJobsRFQFacet jobsRfq = new TangleJobsRFQFacet();
        TangleQuotesFacet quotes = new TangleQuotesFacet();
        TangleBlueprintsManagementFacet bpMgmt = new TangleBlueprintsManagementFacet();

        console2.log("newImpl:      ", address(newImpl));
        console2.log("jobs:         ", address(jobs));
        console2.log("jobsAgg:      ", address(jobsAgg));
        console2.log("services:     ", address(services));
        console2.log("servicesReq:  ", address(servicesReq));
        console2.log("jobsRfq:      ", address(jobsRfq));
        console2.log("quotes:       ", address(quotes));
        console2.log("bpMgmt:       ", address(bpMgmt));

        // 2. UUPS implementation upgrade (adds getServicePaymentAsset view + storage tail).
        router.upgradeToAndCall(address(newImpl), "");

        // 3. Clear-then-register each changed facet's selectors.
        _repoint(router, address(jobs));
        _repoint(router, address(jobsAgg));
        _repoint(router, address(services));
        _repoint(router, address(servicesReq));
        _repoint(router, address(jobsRfq));
        _repoint(router, address(quotes));
        _repoint(router, address(bpMgmt));

        vm.stopBroadcast();

        // Post-upgrade assertions (run in the simulated/broadcast EVM).
        console2.log("POST submitJob facet:      ", router.facetForSelector(SUBMIT_JOB));
        console2.log("POST blueprintCount facet: ", router.facetForSelector(BLUEPRINT_COUNT));
        // New selectors now mapped:
        console2.log(
            "POST setBlueprintSettlementAsset facet:", router.facetForSelector(bytes4(0x730b595f))
        );
        console2.log(
            "POST getBlueprintSettlementAsset facet:", router.facetForSelector(bytes4(0xee09b0d8))
        );
        // New router view reachable (address(0) = native default for an existing service):
        console2.log("POST getServicePaymentAsset(0):", router.getServicePaymentAsset(0));

        require(router.facetForSelector(SUBMIT_JOB) == address(jobs), "submitJob not repointed");
        require(router.facetForSelector(BLUEPRINT_COUNT) == address(bpMgmt), "blueprintCount not repointed");
        require(router.facetForSelector(bytes4(0x730b595f)) == address(bpMgmt), "new selector not registered");
        console2.log("=== upgrade assertions passed ===");
    }

    /// @dev Clear then register the facet's own selector set. Clearing the NEW set first is
    ///      always safe: selectors still pointing at the old facet are cleared (avoiding the
    ///      SelectorAlreadyRegistered revert), and not-yet-mapped selectors clear to a no-op.
    function _repoint(IRouterAdmin router, address facet) internal {
        bytes4[] memory sels = IFacetSelectors(facet).selectors();
        router.clearFacetSelectors(sels);
        router.registerFacet(facet);
    }
}
