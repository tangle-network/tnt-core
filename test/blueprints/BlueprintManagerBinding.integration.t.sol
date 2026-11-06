// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";

contract BlueprintManagerBindingIntegrationTest is Test {
    function testUntrustedFirstCallerCannotReplaceRegistryAndPaymentOwner() public {
        BlueprintServiceManagerBase manager = new BlueprintServiceManagerBase();
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        (bool accepted,) = address(manager).call(abi.encodeCall(manager.onBlueprintCreated, (42, attacker, attacker)));
        assertFalse(accepted, "untrusted caller claimed the registry and developer payment address");
        assertEq(manager.tangleCore(), address(0));
        assertEq(manager.queryDeveloperPaymentAddress(42), address(0));
    }

    function testZeroCoreCannotBypassOneShotBinding() public {
        BlueprintServiceManagerBase manager = new BlueprintServiceManagerBase();
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        (bool accepted,) = address(manager).call(abi.encodeCall(manager.onBlueprintCreated, (42, attacker, address(0))));
        assertFalse(accepted, "zero core accepted an unauthenticated owner");
    }
}
