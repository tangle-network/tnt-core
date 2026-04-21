// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../src/interfaces/IMultiAssetDelegation.sol";
import { IFacetSelectors } from "../../src/interfaces/IFacetSelectors.sol";
import { MultiAssetDelegation } from "../../src/staking/MultiAssetDelegation.sol";
import { StakingFacetBase } from "../../src/staking/StakingFacetBase.sol";
import { Types } from "../../src/libraries/Types.sol";
import { StakingOperatorsFacet } from "../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../src/facets/staking/StakingAdminFacet.sol";

contract MultiAssetDelegationInvariantExposed is StakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](3);
        selectorList[0] = this.rewardPoolTotals.selector;
        selectorList[1] = this.blueprintPoolTotals.selector;
        selectorList[2] = this.operatorStake.selector;
    }

    function rewardPoolTotals(address operator) external view returns (uint256) {
        bytes32 assetHash = keccak256(abi.encode(Types.AssetKind.Native, address(0)));
        return _rewardPools[operator][assetHash].totalAssets;
    }

    function blueprintPoolTotals(address operator, uint64 blueprintId) external view returns (uint256) {
        bytes32 assetHash = keccak256(abi.encode(Types.AssetKind.Native, address(0)));
        return _blueprintPools[operator][blueprintId][assetHash].totalAssets;
    }

    function operatorStake(address operator) external view returns (uint256) {
        return _operatorMetadata[operator].stake;
    }
}

contract SlashAccountingHandler is Test {
    IMultiAssetDelegation internal delegation;
    MultiAssetDelegationInvariantExposed internal exposed;

    address internal admin;
    address internal slasher;
    address internal operator;
    uint64 internal blueprintId;

    address[] internal allDelegators;
    address[] internal fixedDelegators;

    uint256 internal modeledTotal;
    uint256 internal cumulativeSlashed;
    uint256 internal cumulativeDelegated;

    constructor(
        IMultiAssetDelegation delegation_,
        MultiAssetDelegationInvariantExposed exposed_,
        address admin_,
        address slasher_,
        address operator_,
        uint64 blueprintId_
    ) {
        delegation = delegation_;
        exposed = exposed_;
        admin = admin_;
        slasher = slasher_;
        operator = operator_;
        blueprintId = blueprintId_;

        for (uint256 i = 0; i < 5; i++) {
            allDelegators.push(makeAddr(string(abi.encodePacked("allDelegator", vm.toString(i)))));
            fixedDelegators.push(makeAddr(string(abi.encodePacked("fixedDelegator", vm.toString(i)))));
        }

        modeledTotal = 90 ether;
    }

    function delegateAll(uint256 actorSeed, uint256 amountSeed) external {
        if (!delegation.isOperatorActive(operator)) return;

        address delegator = allDelegators[bound(actorSeed, 0, allDelegators.length - 1)];
        uint256 amount = bound(amountSeed, 0.1 ether, 25 ether);

        vm.deal(delegator, amount);
        vm.prank(delegator);
        delegation.depositAndDelegate{ value: amount }(operator);

        cumulativeDelegated += amount;
        modeledTotal += amount;
    }

    function delegateFixed(uint256 actorSeed, uint256 amountSeed) external {
        if (!delegation.isOperatorActive(operator)) return;

        address delegator = fixedDelegators[bound(actorSeed, 0, fixedDelegators.length - 1)];
        uint256 amount = bound(amountSeed, 0.1 ether, 25 ether);

        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = blueprintId;

        vm.deal(delegator, amount);
        vm.prank(delegator);
        delegation.depositAndDelegateWithOptions{ value: amount }(
            operator, address(0), amount, Types.BlueprintSelectionMode.Fixed, blueprints
        );

        cumulativeDelegated += amount;
        modeledTotal += amount;
    }

    function slash(uint256 rawBps) external {
        uint16 slashBps = uint16(bound(rawBps, 1, 10_000));

        vm.prank(slasher);
        uint256 actualSlashed =
            delegation.slashForBlueprint(operator, blueprintId, 99, slashBps, keccak256("invariant-evidence"));

        cumulativeSlashed += actualSlashed;
        modeledTotal -= actualSlashed;
    }

    function expectedTotal() external view returns (uint256) {
        return modeledTotal;
    }

    function totalSlashed() external view returns (uint256) {
        return cumulativeSlashed;
    }

    function totalDelegated() external view returns (uint256) {
        return cumulativeDelegated;
    }
}

contract SlashAccountingInvariantTest is StdInvariant, Test {
    IMultiAssetDelegation internal delegation;
    MultiAssetDelegationInvariantExposed internal exposed;
    SlashAccountingHandler internal handler;

    address internal admin = address(0xA11CE);
    address internal slasher = address(0xBEEF);
    address internal operator = address(0xDEAD);
    uint64 internal constant BLUEPRINT_ID = 42;

    function setUp() public {
        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(MultiAssetDelegation.initialize, (admin, 1 ether, 0.1 ether, 1000));
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        delegation = IMultiAssetDelegation(payable(address(proxy)));
        exposed = MultiAssetDelegationInvariantExposed(payable(address(proxy)));

        vm.startPrank(admin);
        _registerFacets(address(proxy));
        delegation.addSlasher(slasher);
        vm.stopPrank();

        vm.deal(operator, 100 ether);
        vm.prank(operator);
        delegation.registerOperator{ value: 20 ether }();
        vm.prank(operator);
        delegation.setDelegationMode(Types.DelegationMode.Open);

        address seedAllDelegator = address(0xAAA1);
        address seedFixedDelegator = address(0xBBB2);

        vm.deal(seedAllDelegator, 100 ether);
        vm.prank(seedAllDelegator);
        delegation.depositAndDelegate{ value: 30 ether }(operator);

        vm.deal(seedFixedDelegator, 100 ether);
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_ID;
        vm.prank(seedFixedDelegator);
        delegation.depositAndDelegateWithOptions{ value: 40 ether }(
            operator, address(0), 40 ether, Types.BlueprintSelectionMode.Fixed, blueprints
        );

        handler = new SlashAccountingHandler(delegation, exposed, admin, slasher, operator, BLUEPRINT_ID);
        targetContract(address(handler));
    }

    function invariant_slashAccountingConservesSlashableMass() public view {
        uint256 actualTotal =
            exposed.operatorStake(operator) + exposed.rewardPoolTotals(operator) + exposed.blueprintPoolTotals(operator, BLUEPRINT_ID);

        assertEq(actualTotal, handler.expectedTotal(), "slashable accounting drifted from modeled total");
    }

    function invariant_cumulativeSlashedNeverExceedsInitialPlusDeposits() public view {
        uint256 actualTotal =
            exposed.operatorStake(operator) + exposed.rewardPoolTotals(operator) + exposed.blueprintPoolTotals(operator, BLUEPRINT_ID);

        uint256 grossModeled = 90 ether + handler.totalDelegated();
        assertEq(actualTotal + handler.totalSlashed(), grossModeled, "slash conservation violated");
        assertLe(handler.totalSlashed(), grossModeled, "slashed amount exceeded modeled slashable mass");
    }

    function _registerFacets(address proxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(proxy));
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));
        router.registerFacet(address(new MultiAssetDelegationInvariantExposed()));
    }
}
