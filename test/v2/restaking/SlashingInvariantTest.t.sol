// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {MultiAssetDelegation} from "../../../src/v2/restaking/MultiAssetDelegation.sol";
import {Types} from "../../../src/v2/libraries/Types.sol";

contract MultiAssetDelegationExposed is MultiAssetDelegation {
    function rewardPoolTotals(address operator) external view returns (uint256) {
        return _rewardPools[operator].totalAssets;
    }

    function blueprintPoolTotals(address operator, uint64 blueprintId) external view returns (uint256) {
        return _blueprintPools[operator][blueprintId].totalAssets;
    }

    function operatorStake(address operator) external view returns (uint256) {
        return _operatorMetadata[operator].stake;
    }
}

contract SlashForBlueprintFuzzTest is Test {
    MultiAssetDelegationExposed internal delegation;
    address internal admin = address(0xA11CE);
    address internal slasher = address(0xBEEF);
    address internal operator = address(0xDEAD);
    address internal delegatorAll = address(0xAAA1);
    address internal delegatorFixed = address(0xBBB2);
    uint64 internal constant BLUEPRINT_ID = 42;

    function setUp() public {
        MultiAssetDelegationExposed impl = new MultiAssetDelegationExposed();
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, 1 ether, 0.1 ether, 1000)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        delegation = MultiAssetDelegationExposed(payable(address(proxy)));

        vm.startPrank(admin);
        delegation.addSlasher(slasher);
        vm.stopPrank();

        vm.deal(operator, 100 ether);
        vm.prank(operator);
        delegation.registerOperator{value: 20 ether}();

        vm.deal(delegatorAll, 100 ether);
        vm.prank(delegatorAll);
        delegation.depositAndDelegate{value: 30 ether}(operator);

        vm.deal(delegatorFixed, 100 ether);
        uint64[] memory blueprints = new uint64[](1);
        blueprints[0] = BLUEPRINT_ID;
        vm.prank(delegatorFixed);
        delegation.depositAndDelegateWithOptions{value: 40 ether}(
            operator,
            address(0),
            40 ether,
            Types.BlueprintSelectionMode.Fixed,
            blueprints
        );
    }

    function testFuzz_slashAccounting(uint128 rawAmount) public {
        uint256 operatorStakeBefore = delegation.operatorStake(operator);
        uint256 allAssetsBefore = delegation.rewardPoolTotals(operator);
        uint256 blueprintAssetsBefore = delegation.blueprintPoolTotals(operator, BLUEPRINT_ID);
        uint256 maxSlash = operatorStakeBefore + allAssetsBefore + blueprintAssetsBefore;
        vm.assume(maxSlash > 0);

        uint256 amount = bound(uint256(rawAmount), 1, maxSlash);

        vm.prank(slasher);
        uint256 actualSlashed = delegation.slashForBlueprint(
            operator,
            BLUEPRINT_ID,
            99,
            amount,
            keccak256("evidence")
        );

        uint256 operatorStakeAfter = delegation.operatorStake(operator);
        uint256 allAssetsAfter = delegation.rewardPoolTotals(operator);
        uint256 blueprintAssetsAfter = delegation.blueprintPoolTotals(operator, BLUEPRINT_ID);

        uint256 deltaSelf = operatorStakeBefore - operatorStakeAfter;
        uint256 deltaAll = allAssetsBefore - allAssetsAfter;
        uint256 deltaFixed = blueprintAssetsBefore - blueprintAssetsAfter;

        assertEq(actualSlashed, deltaSelf + deltaAll + deltaFixed, "slash accounting mismatch");
    }
}
