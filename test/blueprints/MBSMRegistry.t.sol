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

    /// @dev `addVersion` rejects EOAs; tests use placeholder addresses with stub bytecode.
    /// @dev Skip the precompile range (1..0xa) — `vm.etch` refuses to overwrite them.
    function _stubMBSM(address addr) internal {
        require(uint160(addr) > 0x10, "MBSMRegistry test: pick address above precompile range");
        vm.etch(addr, hex"60006000fd"); // any non-empty bytecode
    }

    function _executeEmergencyDeprecation(uint32 revision) internal {
        vm.prank(admin);
        registry.queueEmergencyDeprecation(revision);
        vm.warp(block.timestamp + registry.EMERGENCY_DEPRECATION_DELAY());
        vm.prank(admin);
        registry.executeEmergencyDeprecation(revision);
    }

    function test_Initialize_SetsRoles() public {
        assertTrue(registry.hasRole(registry.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(registry.hasRole(registry.MANAGER_ROLE(), admin));
        assertTrue(registry.hasRole(registry.UPGRADER_ROLE(), admin));
    }

    function test_AddVersionAndGetters() public {
        _stubMBSM(address(0x1234));
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

        // EOA / non-contract address must be rejected so MBSM hooks can never silently no-op.
        // Use an arbitrary high address that has no bytecode and no precompile.
        address eoa = address(0xCAFE_AAAA);
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.NotAContract.selector, eoa));
        registry.addVersion(eoa);

        address dup = address(0xCAFE_BBBB);
        _stubMBSM(dup);
        vm.prank(admin);
        registry.addVersion(dup);

        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.VersionAlreadyRegistered.selector, dup));
        registry.addVersion(dup);
    }

    function test_AddVersion_MaxLimitEnforced() public {
        uint256 max = registry.MAX_VERSIONS();
        for (uint256 i = 0; i < max; i++) {
            // Skip the precompile range (1..0xa) by offsetting from 0x100.
            address mbsm = address(uint160(0x100 + i));
            _stubMBSM(mbsm);
            vm.prank(admin);
            registry.addVersion(mbsm);
        }

        _stubMBSM(address(0xBEEF));
        vm.prank(admin);
        vm.expectRevert(MBSMRegistry.MaxVersionsExceeded.selector);
        registry.addVersion(address(0xBEEF));
    }

    function test_EmergencyDeprecation_RequiresDelayAndBricksTargetedRevision() public {
        _stubMBSM(address(0xAAA));
        _stubMBSM(address(0xBBB));
        vm.startPrank(admin);
        registry.addVersion(address(0xAAA));
        registry.addVersion(address(0xBBB));
        vm.stopPrank();

        assertTrue(registry.isValidRevision(2));

        vm.prank(admin);
        registry.queueEmergencyDeprecation(2);

        // Cannot execute before the delay elapses
        vm.prank(admin);
        vm.expectRevert();
        registry.executeEmergencyDeprecation(2);

        vm.warp(block.timestamp + registry.EMERGENCY_DEPRECATION_DELAY());
        vm.prank(admin);
        registry.executeEmergencyDeprecation(2);

        assertFalse(registry.isValidRevision(2));
        assertEq(registry.getRevision(address(0xBBB)), 0);

        // Queueing an unknown revision still reverts
        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.InvalidRevision.selector, 5));
        registry.queueEmergencyDeprecation(5);
    }

    function test_PinAndUnpinBlueprint() public {
        _stubMBSM(address(0x111));
        _stubMBSM(address(0x222));
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
        _stubMBSM(address(0x456));
        vm.prank(admin);
        registry.addVersion(address(0x456));

        vm.expectRevert(abi.encodeWithSelector(MBSMRegistry.InvalidRevision.selector, 0));
        registry.getMBSMByRevision(0);
    }

    function test_GetAllVersions_ReturnsFullHistory() public {
        _stubMBSM(address(0x111));
        _stubMBSM(address(0x222));
        _stubMBSM(address(0x333));
        vm.startPrank(admin);
        registry.addVersion(address(0x111));
        registry.addVersion(address(0x222));
        registry.addVersion(address(0x333));
        vm.stopPrank();

        _executeEmergencyDeprecation(2);

        address[] memory versions = registry.getAllVersions();
        assertEq(versions.length, 3);
        assertEq(versions[0], address(0x111));
        assertEq(versions[1], address(0));
        assertEq(versions[2], address(0x333));
    }
}
