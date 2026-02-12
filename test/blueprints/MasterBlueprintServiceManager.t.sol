// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { MasterBlueprintServiceManager } from "../../src/MasterBlueprintServiceManager.sol";

contract MasterBlueprintServiceManagerTest is Test {
    MasterBlueprintServiceManager internal mbsm;
    address internal admin = makeAddr("admin");
    address internal tangle = makeAddr("tangle");
    uint64 internal constant BLUEPRINT_ID = 77;

    function setUp() public {
        mbsm = new MasterBlueprintServiceManager(admin, tangle);
    }

    function test_Constructor_GrantsRoles() public {
        assertTrue(mbsm.hasRole(mbsm.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(mbsm.hasRole(mbsm.TANGLE_ROLE(), tangle));
    }

    function test_SetTangle_TogglesRole() public {
        address newTangle = makeAddr("newTangle");

        vm.prank(admin);
        mbsm.setTangle(newTangle, true);
        assertTrue(mbsm.hasRole(mbsm.TANGLE_ROLE(), newTangle));

        vm.prank(admin);
        mbsm.setTangle(newTangle, false);
        assertFalse(mbsm.hasRole(mbsm.TANGLE_ROLE(), newTangle));
    }

    function test_OnBlueprintCreated_RecordsDefinition() public {
        bytes memory encodedDefinition = abi.encode("ipfs://definition");
        uint64 nowTs = 1_234_567;
        vm.warp(nowTs);

        vm.prank(tangle);
        mbsm.onBlueprintCreated(BLUEPRINT_ID, address(0xBEEF), encodedDefinition);

        MasterBlueprintServiceManager.BlueprintRecord memory record = mbsm.getBlueprintRecord(BLUEPRINT_ID);

        assertEq(record.owner, address(0xBEEF));
        assertEq(record.recordedAt, nowTs);
        assertEq(record.encodedDefinition, encodedDefinition);
    }

    function test_OnBlueprintCreated_RevertsWithoutRole() public {
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", address(this), mbsm.TANGLE_ROLE()
            )
        );
        mbsm.onBlueprintCreated(BLUEPRINT_ID, address(1), "data");
    }
}
