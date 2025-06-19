// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "src/SlashAlert.sol";

// Mock implementation of ISlashAlert for testing
contract MockSlashAlert is ISlashAlert {
    uint64 public lastBlueprintId;
    uint64 public lastServiceId;
    bytes32 public lastOperator;
    uint256 public lastSlashAmount;
    bool public wasCalled;

    function onSlash(
        uint64 blueprintId,
        uint64 serviceId,
        bytes32 operator,
        uint256 slashAmount
    ) external override {
        lastBlueprintId = blueprintId;
        lastServiceId = serviceId;
        lastOperator = operator;
        lastSlashAmount = slashAmount;
        wasCalled = true;
    }
}

contract SlashAlertTest is Test {
    MockSlashAlert slashAlert;

    function setUp() public {
        slashAlert = new MockSlashAlert();
    }

    function testOnSlashInterface() public {
        uint64 blueprintId = 123;
        uint64 serviceId = 456;
        bytes32 operator = bytes32(uint256(0xABCDEF));
        uint256 slashAmount = 1000 ether;

        slashAlert.onSlash(blueprintId, serviceId, operator, slashAmount);

        assertTrue(slashAlert.wasCalled(), "onSlash was not called");
        assertEq(slashAlert.lastBlueprintId(), blueprintId, "Blueprint ID mismatch");
        assertEq(slashAlert.lastServiceId(), serviceId, "Service ID mismatch");
        assertEq(slashAlert.lastOperator(), operator, "Operator mismatch");
        assertEq(slashAlert.lastSlashAmount(), slashAmount, "Slash amount mismatch");
    }

    function testOnSlashDifferentValues() public {
        uint64 blueprintId = 789;
        uint64 serviceId = 101112;
        bytes32 operator = bytes32(uint256(0x123456));
        uint256 slashAmount = 500 ether;

        slashAlert.onSlash(blueprintId, serviceId, operator, slashAmount);

        assertTrue(slashAlert.wasCalled(), "onSlash was not called");
        assertEq(slashAlert.lastBlueprintId(), blueprintId, "Blueprint ID mismatch");
        assertEq(slashAlert.lastServiceId(), serviceId, "Service ID mismatch");
        assertEq(slashAlert.lastOperator(), operator, "Operator mismatch");
        assertEq(slashAlert.lastSlashAmount(), slashAmount, "Slash amount mismatch");
    }
}
