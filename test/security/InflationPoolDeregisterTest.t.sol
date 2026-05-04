// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { InflationPool } from "../../src/rewards/InflationPool.sol";

/// @title InflationPoolDeregisterTest
/// @notice Regression: `deregisterOperator` removes an operator from `trackedOperators`,
///         clears its registration epoch, and lets the index shrink instead of growing
///         monotonically as inactive operators accumulate.
contract InflationPoolDeregisterTest is Test {
    InflationPool pool;
    address admin = makeAddr("admin");
    address tnt = address(0xDEAD);

    function setUp() public {
        InflationPool impl = new InflationPool();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(InflationPool.initialize, (admin, tnt, address(0), address(0), 7 days))
        );
        pool = InflationPool(payable(address(proxy)));
    }

    function _trackedCount() internal view returns (uint256 count) {
        // `trackedOperators` is `address[] public`; length is exposed indirectly.
        // Iterate by slot until we hit a revert or zero - simpler to just probe with try/catch.
        while (true) {
            try pool.trackedOperators(count) returns (address) {
                count++;
            } catch {
                return count;
            }
        }
    }

    function test_DeregisterOperator_RemovesFromTrackedList() public {
        address[] memory ops = new address[](3);
        ops[0] = makeAddr("op1");
        ops[1] = makeAddr("op2");
        ops[2] = makeAddr("op3");

        vm.prank(admin);
        pool.registerOperators(ops);

        assertEq(_trackedCount(), 3, "all three tracked");
        assertTrue(pool.isTrackedOperator(ops[1]));

        vm.prank(admin);
        pool.deregisterOperator(ops[1]);

        assertEq(_trackedCount(), 2, "shrinks after deregister");
        assertFalse(pool.isTrackedOperator(ops[1]));
        assertEq(pool.operatorRegistrationEpoch(ops[1]), 0, "registration epoch cleared");
    }

    function test_DeregisterOperator_NonAdminReverts() public {
        address attacker = makeAddr("attacker");
        vm.prank(admin);
        pool.registerOperator(makeAddr("op"));

        vm.prank(attacker);
        vm.expectRevert();
        pool.deregisterOperator(makeAddr("op"));
    }

    function test_DeregisterOperator_AllowsReregistration() public {
        address op = makeAddr("op");

        vm.startPrank(admin);
        pool.registerOperator(op);
        pool.deregisterOperator(op);
        pool.registerOperator(op);
        vm.stopPrank();

        assertTrue(pool.isTrackedOperator(op));
        assertEq(_trackedCount(), 1);
    }
}
