// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { MasterVault } from "../assets/MasterVault.sol";
import { ICrossChainDelegatorMessage } from "../interfaces/ICrossChainDelegatorMessage.sol";

contract MasterVaultTest is Test {
    MasterVault public masterVault;
    bytes32 constant OPERATOR = bytes32(uint256(1));

    function setUp() public {
        masterVault = new MasterVault();
    }

    function testSingleSlash() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 100;
        uint256 slashAmount = 1000;

        masterVault.slash(blueprintId, serviceId, OPERATOR, slashAmount);

        ICrossChainDelegatorMessage.Slash[] memory slashes = masterVault.getSlashes(OPERATOR);
        assertEq(slashes.length, 1, "Should have one slash record");
        assertEq(slashes[0].blueprintId, blueprintId, "Blueprint ID mismatch");
        assertEq(slashes[0].serviceId, serviceId, "Service ID mismatch");
        assertEq(slashes[0].slashAmount, slashAmount, "Slash amount mismatch");
    }

    function testMultipleSlashes() public {
        // First slash
        masterVault.slash(1, 100, OPERATOR, 1000);

        // Second slash
        masterVault.slash(2, 200, OPERATOR, 2000);

        // Third slash
        masterVault.slash(3, 300, OPERATOR, 3000);

        ICrossChainDelegatorMessage.Slash[] memory slashes = masterVault.getSlashes(OPERATOR);
        assertEq(slashes.length, 3, "Should have three slash records");

        // Verify first slash
        assertEq(slashes[0].blueprintId, 1);
        assertEq(slashes[0].serviceId, 100);
        assertEq(slashes[0].slashAmount, 1000);

        // Verify second slash
        assertEq(slashes[1].blueprintId, 2);
        assertEq(slashes[1].serviceId, 200);
        assertEq(slashes[1].slashAmount, 2000);

        // Verify third slash
        assertEq(slashes[2].blueprintId, 3);
        assertEq(slashes[2].serviceId, 300);
        assertEq(slashes[2].slashAmount, 3000);
    }

    function testDifferentOperatorSlashes() public {
        bytes32 operator1 = bytes32(uint256(1));
        bytes32 operator2 = bytes32(uint256(2));

        // Slash operator1
        masterVault.slash(1, 100, operator1, 1000);

        // Slash operator2
        masterVault.slash(2, 200, operator2, 2000);

        // Verify operator1 slashes
        ICrossChainDelegatorMessage.Slash[] memory slashes1 = masterVault.getSlashes(operator1);
        assertEq(slashes1.length, 1, "Operator1 should have one slash");
        assertEq(slashes1[0].blueprintId, 1);
        assertEq(slashes1[0].slashAmount, 1000);

        // Verify operator2 slashes
        ICrossChainDelegatorMessage.Slash[] memory slashes2 = masterVault.getSlashes(operator2);
        assertEq(slashes2.length, 1, "Operator2 should have one slash");
        assertEq(slashes2[0].blueprintId, 2);
        assertEq(slashes2[0].slashAmount, 2000);
    }
}
