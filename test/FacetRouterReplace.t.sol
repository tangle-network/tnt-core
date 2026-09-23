// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { ERC1967Utils } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

import { BaseTest } from "./BaseTest.sol";
import { Tangle } from "../src/Tangle.sol";
import { FacetRouterBase } from "../src/facets/FacetRouterBase.sol";
import { IFacetSelectors } from "../src/interfaces/IFacetSelectors.sol";
import { TangleJobsFacet } from "../src/facets/tangle/TangleJobsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { Errors } from "../src/libraries/Errors.sol";

/// @notice `replaceFacets` is the atomic facet-swap path: one call re-points every selector of
///         each facet, and inside `upgradeToAndCall` it lands in the same transaction as the
///         implementation swap. These tests pin that contract: routes move in one call, the
///         router keeps serving through the new facet, the registry gate (UPGRADER_ROLE) holds,
///         and the combined UUPS + facet upgrade is a single transaction.
contract FacetRouterReplaceTest is BaseTest {
    Tangle internal router;

    bytes32 internal constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    function setUp() public override {
        super.setUp();
        router = Tangle(payable(address(tangleProxy)));
    }

    function test_replaceFacets_repointsEverySelectorOfEachFacet() public {
        TangleJobsFacet newJobs = new TangleJobsFacet();
        TangleBlueprintsManagementFacet newBp = new TangleBlueprintsManagementFacet();
        address oldJobs = router.facetForSelector(newJobs.selectors()[0]);
        address oldBp = router.facetForSelector(newBp.selectors()[0]);
        assertTrue(oldJobs != address(0) && oldJobs != address(newJobs), "precondition: jobs routed elsewhere");
        assertTrue(oldBp != address(0) && oldBp != address(newBp), "precondition: bpMgmt routed elsewhere");

        address[] memory facets = new address[](2);
        facets[0] = address(newJobs);
        facets[1] = address(newBp);
        vm.prank(admin);
        router.replaceFacets(facets);

        _assertRouted(address(newJobs));
        _assertRouted(address(newBp));
        // The router still serves the replaced surface, now through the new facet.
        assertEq(tangle.blueprintCount(), 0, "blueprintCount must route through the new facet");
        _createBlueprint(user1);
        assertEq(tangle.blueprintCount(), 1, "state written through the replaced facet");
    }

    function test_replaceFacets_emitsClearedThenSetForAReplacedSelector() public {
        TangleJobsFacet newJobs = new TangleJobsFacet();
        bytes4 first = newJobs.selectors()[0];
        address[] memory facets = new address[](1);
        facets[0] = address(newJobs);

        vm.expectEmit(true, false, false, true, address(router));
        emit FacetRouterBase.FacetSelectorCleared(first);
        vm.expectEmit(true, true, false, true, address(router));
        emit FacetRouterBase.FacetSelectorSet(first, address(newJobs));
        vm.prank(admin);
        router.replaceFacets(facets);
    }

    function test_replaceFacets_isIdempotent() public {
        TangleJobsFacet newJobs = new TangleJobsFacet();
        address[] memory facets = new address[](1);
        facets[0] = address(newJobs);
        vm.startPrank(admin);
        router.replaceFacets(facets);
        router.replaceFacets(facets);
        vm.stopPrank();
        _assertRouted(address(newJobs));
    }

    function test_replaceFacets_rejectsCallerWithoutUpgraderRole() public {
        address[] memory facets = new address[](1);
        facets[0] = address(new TangleJobsFacet());
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, user1, UPGRADER_ROLE)
        );
        vm.prank(user1);
        router.replaceFacets(facets);
    }

    function test_replaceFacets_rejectsZeroAddressAndNonContract() public {
        address[] memory facets = new address[](1);

        facets[0] = address(0);
        vm.expectRevert(Errors.ZeroAddress.selector);
        vm.prank(admin);
        router.replaceFacets(facets);

        facets[0] = user1;
        vm.expectRevert(abi.encodeWithSelector(Errors.NotAContract.selector, user1));
        vm.prank(admin);
        router.replaceFacets(facets);
    }

    /// @notice The upgrade path the deploy scripts use: implementation swap and facet re-point
    ///         in ONE transaction, so no entry point is ever unrouted between them.
    function test_upgradeToAndCall_replaceFacets_isOneTransaction() public {
        Tangle newImpl = new Tangle();
        TangleJobsFacet newJobs = new TangleJobsFacet();
        TangleBlueprintsManagementFacet newBp = new TangleBlueprintsManagementFacet();
        address[] memory facets = new address[](2);
        facets[0] = address(newJobs);
        facets[1] = address(newBp);

        address oldImpl = _implementation();
        assertTrue(oldImpl != address(newImpl), "precondition: fresh implementation");

        vm.prank(admin);
        router.upgradeToAndCall(address(newImpl), abi.encodeCall(router.replaceFacets, (facets)));

        assertEq(_implementation(), address(newImpl), "implementation swapped");
        _assertRouted(address(newJobs));
        _assertRouted(address(newBp));
        assertEq(tangle.blueprintCount(), 0, "router serves through the new facet after the combined upgrade");
    }

    function test_upgradeToAndCall_replaceFacets_revertsAtomicallyOnBadFacet() public {
        Tangle newImpl = new Tangle();
        address[] memory facets = new address[](2);
        facets[0] = address(new TangleJobsFacet());
        facets[1] = user1; // not a contract: the whole upgrade must revert, including the impl swap

        address oldImpl = _implementation();
        address oldJobs = router.facetForSelector(IFacetSelectors(facets[0]).selectors()[0]);

        vm.expectRevert(abi.encodeWithSelector(Errors.NotAContract.selector, user1));
        vm.prank(admin);
        router.upgradeToAndCall(address(newImpl), abi.encodeCall(router.replaceFacets, (facets)));

        assertEq(_implementation(), oldImpl, "implementation untouched");
        assertEq(
            router.facetForSelector(IFacetSelectors(facets[0]).selectors()[0]), oldJobs, "jobs routes untouched"
        );
    }

    function _assertRouted(address facet) internal view {
        bytes4[] memory sels = IFacetSelectors(facet).selectors();
        for (uint256 i = 0; i < sels.length; i++) {
            assertEq(router.facetForSelector(sels[i]), facet, "selector not routed to the new facet");
        }
    }

    function _implementation() internal view returns (address) {
        return address(uint160(uint256(vm.load(address(tangleProxy), ERC1967Utils.IMPLEMENTATION_SLOT))));
    }
}
