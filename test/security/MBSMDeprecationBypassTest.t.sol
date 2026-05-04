// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { MBSMRegistry } from "../../src/MBSMRegistry.sol";
import { MasterBlueprintServiceManager } from "../../src/MasterBlueprintServiceManager.sol";

/// @title MBSMDeprecationBypassTest
/// @notice Regression test: emergency MBSM deprecation must require a 24h queue + execute path,
///         and direct synchronous deprecation must not exist.
contract MBSMDeprecationBypassTest is Test {
    MBSMRegistry registry;
    address admin = makeAddr("admin");

    function setUp() public {
        MBSMRegistry impl = new MBSMRegistry();
        ERC1967Proxy proxy =
            new ERC1967Proxy(address(impl), abi.encodeCall(MBSMRegistry.initialize, (admin)));
        registry = MBSMRegistry(address(proxy));
    }

    function test_EmergencyDeprecation_BlockedWithoutDelay() public {
        MasterBlueprintServiceManager mbsm = new MasterBlueprintServiceManager(admin, address(0xdead));

        vm.startPrank(admin);
        uint32 rev = registry.addVersion(address(mbsm));
        registry.pinBlueprint(42, rev);
        vm.stopPrank();

        assertEq(registry.getMBSM(42), address(mbsm));

        vm.prank(admin);
        registry.queueEmergencyDeprecation(rev);

        // Pinned blueprint still resolves during the queued window
        assertEq(registry.getMBSM(42), address(mbsm));

        vm.prank(admin);
        vm.expectRevert();
        registry.executeEmergencyDeprecation(rev);

        vm.warp(block.timestamp + registry.EMERGENCY_DEPRECATION_DELAY());
        vm.prank(admin);
        registry.executeEmergencyDeprecation(rev);

        assertEq(registry.getMBSM(42), address(0));
    }

    function test_SafePath_RespectsGracePeriod() public {
        MasterBlueprintServiceManager mbsm = new MasterBlueprintServiceManager(admin, address(0xdead));

        vm.startPrank(admin);
        uint32 rev = registry.addVersion(address(mbsm));
        registry.pinBlueprint(7, rev);
        registry.initiateDeprecation(rev);
        vm.stopPrank();

        assertEq(registry.getMBSM(7), address(mbsm));

        vm.warp(block.timestamp + 7 days + 1);
        vm.prank(admin);
        registry.completeDeprecation(rev);

        assertEq(registry.getMBSM(7), address(0));
    }

    function test_CancelEmergencyDeprecation() public {
        MasterBlueprintServiceManager mbsm = new MasterBlueprintServiceManager(admin, address(0xdead));

        vm.startPrank(admin);
        uint32 rev = registry.addVersion(address(mbsm));
        registry.queueEmergencyDeprecation(rev);
        registry.cancelEmergencyDeprecation(rev);
        vm.stopPrank();

        vm.warp(block.timestamp + registry.EMERGENCY_DEPRECATION_DELAY() + 1);
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.NoEmergencyDeprecationQueued.selector, rev));
        registry.executeEmergencyDeprecation(rev);
    }
}
