// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { RootChainEnabled } from "../src/Permissions.sol";

// Mock contract to test RootChainEnabled
contract MockPermissions is RootChainEnabled {
    bool public rootChainFunctionCalled;
    bool public masterFunctionCalled;

    constructor(address _mbsm) {
        masterBlueprintServiceManager = _mbsm;
    }

    function callRootChainFunction() external onlyFromRootChain {
        rootChainFunctionCalled = true;
    }

    function callMasterFunction() external onlyFromMaster {
        masterFunctionCalled = true;
    }
}

/// @title Permissions Test Contract
/// @notice Tests the functionality of the RootChainEnabled contract
contract PermissionsTest is Test {
    MockPermissions permissions;
    address constant ROOT_CHAIN = 0x09dF6A941ee03B1e632904E382e10862fA9cc0e3;
    address constant REWARDS_PALLET = address(0x7e87d5);
    address constant TEST_MBSM = address(0x3333);

    function setUp() public {
        permissions = new MockPermissions(TEST_MBSM);
    }

    function testRootChainAccessControl() public {
        // Should revert when not called from ROOT_CHAIN
        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyRootChainAllowed.selector, 
                address(this), 
                ROOT_CHAIN
            )
        );
        permissions.callRootChainFunction();

        // Should succeed when called from ROOT_CHAIN
        vm.startPrank(ROOT_CHAIN);
        permissions.callRootChainFunction();
        vm.stopPrank();
        assertTrue(permissions.rootChainFunctionCalled(), "Function should have been called");
    }

    function testMasterAccessControl() public {
        // Should revert when not called from masterBlueprintServiceManager
        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector, 
                address(this), 
                TEST_MBSM
            )
        );
        permissions.callMasterFunction();

        // Should succeed when called from masterBlueprintServiceManager
        vm.startPrank(TEST_MBSM);
        permissions.callMasterFunction();
        vm.stopPrank();
        assertTrue(permissions.masterFunctionCalled(), "Function should have been called");
    }

    function testRootChainAddress() public {
        assertEq(permissions.rootChain(), ROOT_CHAIN, "ROOT_CHAIN address does not match");
        assertEq(permissions.ROOT_CHAIN(), ROOT_CHAIN, "ROOT_CHAIN constant does not match");
    }

    function testRewardsPalletAddress() public {
        assertEq(permissions.rewardsPallet(), REWARDS_PALLET, "REWARDS_PALLET address does not match");
        assertEq(permissions.REWARDS_PALLET(), REWARDS_PALLET, "REWARDS_PALLET constant does not match");
    }

    function testMasterBlueprintServiceManagerAddress() public {
        assertEq(permissions.masterBlueprintServiceManagerAddress(), TEST_MBSM, "masterBlueprintServiceManager address does not match");
        assertEq(permissions.masterBlueprintServiceManager(), TEST_MBSM, "masterBlueprintServiceManager variable does not match");
    }
}
