// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { TangleTimelock } from "../../src/governance/TangleTimelock.sol";
import {
    TimelockControllerUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";

/// @title TimelockSetMinDelayTest
/// @notice Regression test: `updateDelay` must (a) reject callers other than the timelock
///         itself and (b) actually persist the new delay (i.e. write to the OZ ERC-7201
///         namespaced `_minDelay` slot, not slot 0x33).
contract TimelockSetMinDelayTest is Test {
    TangleTimelock timelock;
    address admin = makeAddr("admin");

    function setUp() public {
        TangleTimelock impl = new TangleTimelock();
        address[] memory empty = new address[](0);
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(TangleTimelock.initialize, (1 days, empty, empty, admin))
        );
        timelock = TangleTimelock(payable(address(proxy)));
    }

    function test_UpdateDelay_RevertsWhenCallerNotTimelock() public {
        vm.prank(admin);
        vm.expectRevert(
            abi.encodeWithSelector(TimelockControllerUpgradeable.TimelockUnauthorizedCaller.selector, admin)
        );
        timelock.updateDelay(2 days);
    }

    function test_UpdateDelay_PersistsNewValue() public {
        assertEq(timelock.getMinDelay(), 1 days, "initial delay");

        // Calling from the timelock itself (the only caller `updateDelay` accepts) must
        // (1) succeed and (2) flow through `getMinDelay()`. If `_setMinDelay` writes to
        // the wrong slot, `getMinDelay()` will continue to return the old value.
        vm.prank(address(timelock));
        timelock.updateDelay(3 days);

        assertEq(timelock.getMinDelay(), 3 days, "delay must persist after updateDelay");
    }

    function test_UpdateDelay_BoundsEnforced() public {
        vm.prank(address(timelock));
        vm.expectRevert(abi.encodeWithSelector(TangleTimelock.DelayTooShort.selector, 1 hours, 1 days));
        timelock.updateDelay(1 hours);

        vm.prank(address(timelock));
        vm.expectRevert(abi.encodeWithSelector(TangleTimelock.DelayTooLong.selector, 60 days, 30 days));
        timelock.updateDelay(60 days);
    }
}
