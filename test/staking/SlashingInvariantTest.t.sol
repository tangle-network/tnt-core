// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
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

contract MultiAssetDelegationExposed is StakingFacetBase, IFacetSelectors {
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

contract SlashForBlueprintFuzzTest is Test {
    IMultiAssetDelegation internal delegation;
    MultiAssetDelegationExposed internal exposed;
    address internal admin = address(0xA11CE);
    address internal slasher = address(0xBEEF);
    address internal operator = address(0xDEAD);
    address internal delegatorAll = address(0xAAA1);
    address internal delegatorFixed = address(0xBBB2);
    uint64 internal constant BLUEPRINT_ID = 42;

    function setUp() public {
        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(MultiAssetDelegation.initialize, (admin, 1 ether, 0.1 ether, 1000));
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        delegation = IMultiAssetDelegation(payable(address(proxy)));
        exposed = MultiAssetDelegationExposed(payable(address(proxy)));

        vm.startPrank(admin);
        _registerFacets(address(proxy));
        vm.stopPrank();

        vm.startPrank(admin);
        delegation.addSlasher(slasher);
        vm.stopPrank();

        vm.deal(operator, 100 ether);
        vm.prank(operator);
        delegation.registerOperator{ value: 20 ether }();
        vm.prank(operator);
        delegation.setDelegationMode(Types.DelegationMode.Open);

        vm.deal(delegatorAll, 100 ether);
        vm.prank(delegatorAll);
        delegation.depositAndDelegate{ value: 30 ether }(operator);

        vm.deal(delegatorFixed, 100 ether);
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_ID;
        vm.prank(delegatorFixed);
        delegation.depositAndDelegateWithOptions{ value: 40 ether }(
            operator, address(0), 40 ether, Types.BlueprintSelectionMode.Fixed, blueprints
        );
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
        router.registerFacet(address(new MultiAssetDelegationExposed()));
    }

    function testFuzz_slashAccounting(uint16 rawBps) public {
        uint256 operatorStakeBefore = exposed.operatorStake(operator);
        uint256 allAssetsBefore = exposed.rewardPoolTotals(operator);
        uint256 blueprintAssetsBefore = exposed.blueprintPoolTotals(operator, BLUEPRINT_ID);
        uint256 maxSlash = operatorStakeBefore + allAssetsBefore + blueprintAssetsBefore;
        vm.assume(maxSlash > 0);

        uint16 slashBps = uint16(bound(uint256(rawBps), 1, 10_000));

        vm.prank(slasher);
        uint256 actualSlashed =
            delegation.slashForBlueprint(operator, BLUEPRINT_ID, 99, slashBps, keccak256("evidence"));

        uint256 operatorStakeAfter = exposed.operatorStake(operator);
        uint256 allAssetsAfter = exposed.rewardPoolTotals(operator);
        uint256 blueprintAssetsAfter = exposed.blueprintPoolTotals(operator, BLUEPRINT_ID);

        uint256 deltaSelf = operatorStakeBefore - operatorStakeAfter;
        uint256 deltaAll = allAssetsBefore - allAssetsAfter;
        uint256 deltaFixed = blueprintAssetsBefore - blueprintAssetsAfter;

        assertEq(actualSlashed, deltaSelf + deltaAll + deltaFixed, "slash accounting mismatch");
    }
}
