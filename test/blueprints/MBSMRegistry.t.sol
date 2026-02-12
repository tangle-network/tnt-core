// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { MBSMRegistry } from "../../src/MBSMRegistry.sol";
import { Errors } from "../../src/libraries/Errors.sol";

contract MBSMRegistryTest is Test {
    MBSMRegistry internal registry;
    address internal admin = makeAddr("admin");

    function setUp() public {
        MBSMRegistry implementation = new MBSMRegistry();
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), abi.encodeCall(MBSMRegistry.initialize, (admin)));
        registry = MBSMRegistry(address(proxy));
    }

    function test_Initialize_SetsRoles() public {
        assertTrue(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(registry.hasRole(registry.MANAGER_ROLE(), admin));
        assertTrue(registry.hasRole(registry.UPGRADER_ROLE(), admin));
    }

    function test_AddVersionAndGetters() public {
        vm.prank(admin);
        uint32 revision = registry.addVersion(address(0x1234));
        assertEq(revision, 1);
        assertEq(registry.getLatestRevision(), 1);
        assertEq(registry.versionCount(), 1);
        assertEq(registry.getLatestMBSM(), address(0x1234));
        assertEq(registry.getRevision(address(0x1234)), 1);
    }

    function test_AddVersion_RevertsOnInvalidInput() public {
        vm.prank(admin);
        vm.expectRevert(Errors.ZeroAddress.selector);
        registry.addVersion(address(0));

        vm.prank(admin);
        registry.addVersion(address(0x1));

        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.VersionAlreadyRegistered.selector, address(0x1)));
        registry.addVersion(address(0x1));
    }

    function test_AddVersion_MaxLimitEnforced() public {
        uint256 max = registry.MAX_VERSIONS();
        for (uint256 i = 0; i < max; i++) {
            vm.prank(admin);
            registry.addVersion(address(uint160(i + 1)));
        }

        vm.prank(admin);
        vm.expectRevert(MBSMRegistry.MaxVersionsExceeded.selector);
        registry.addVersion(address(0xBEEF));
    }

    function test_DeprecateVersion_AndValidityChecks() public {
        vm.startPrank(admin);
        registry.addVersion(address(0xAAA));
        registry.addVersion(address(0xBBB));
        vm.stopPrank();

        assertTrue(registry.isValidRevision(2));

        vm.prank(admin);
        registry.deprecateVersion(2);

        assertFalse(registry.isValidRevision(2));
        assertEq(registry.getRevision(address(0xBBB)), 0);

        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.InvalidRevision.selector, 5));
        registry.deprecateVersion(5);
    }

    function test_PinAndUnpinBlueprint() public {
        vm.startPrank(admin);
        registry.addVersion(address(0x111));
        registry.addVersion(address(0x222));
        registry.pinBlueprint(7, 1);
        vm.stopPrank();

        assertEq(registry.getMBSM(7), address(0x111));
        assertEq(registry.getPinnedRevision(7), 1);

        vm.prank(admin);
        registry.unpinBlueprint(7);

        assertEq(registry.getPinnedRevision(7), 0);
        assertEq(registry.getMBSM(7), address(0x222));
    }

    function test_GetMBSM_DefaultsToLatestWhenNoVersions() public {
        assertEq(registry.getLatestMBSM(), address(0));
        assertEq(registry.getMBSM(1), address(0));
    }

    function test_GetMBSMByRevision_RevertsOnInvalid() public {
        vm.prank(admin);
        registry.addVersion(address(0x456));

        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.InvalidRevision.selector, 0));
        registry.getMBSMByRevision(0);
    }

    function test_GetAllVersions_ReturnsFullHistory() public {
        vm.startPrank(admin);
        registry.addVersion(address(0x111));
        registry.addVersion(address(0x222));
        registry.addVersion(address(0x333));
        registry.deprecateVersion(2);
        vm.stopPrank();

        address[] memory versions = registry.getAllVersions();
        assertEq(versions.length, 3);
        assertEq(versions[0], address(0x111));
        assertEq(versions[1], address(0));
        assertEq(versions[2], address(0x333));
    }
}
