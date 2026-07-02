// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @dev A blueprint service manager whose creation hook does substantial storage
///      bookkeeping. Burns ~1.2M gas in `onBlueprintCreated` — comfortably over the
///      old 500k hook budget and under the 2M one.
contract StorageHeavySetupBSM {
    mapping(uint256 => uint256) private _setupState;
    bool public initialized;

    function onBlueprintCreated(uint64, address, address) external {
        for (uint256 i = 1; i <= 54; ++i) {
            _setupState[i] = i; // 54 fresh SSTOREs ≈ 1.2M gas
        }
        initialized = true;
    }
}

/// @dev Burns effectively unbounded gas — must be stopped by the hook budget so a
///      hostile manager cannot consume the whole transaction.
contract GasExhaustingBSM {
    mapping(uint256 => uint256) private _sink;

    function onBlueprintCreated(uint64, address, address) external {
        for (uint256 i = 1; i != 0; ++i) {
            _sink[i] = i;
        }
    }
}

contract ManagerHookGasBudgetTest is BaseTest {
    /// @notice The manager hook budget (MANAGER_HOOK_GAS_LIMIT = 2M) clears a real
    ///         setup hook that does a few dozen SSTOREs (~1.2M gas). Under the tight 500k
    ///         DEFAULT budget it OOGs and creation reverts; raising the per-deployment budget
    ///         (as high-SSTORE-metering chains like Tempo do) lets it clear. Pins both sides
    ///         of the configurable budget.
    function test_DefaultBudgetBoundsHeavySetupHook() public {
        StorageHeavySetupBSM bsm = new StorageHeavySetupBSM();
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://heavy-hook-default", address(bsm));

        // Default budget is 500k (no override set).
        assertEq(tangle.managerHookGasLimit(), 500_000, "default budget");
        vm.prank(developer);
        vm.expectRevert();
        tangle.createBlueprint(def);
        assertFalse(bsm.initialized(), "heavy hook OOGs under the 500k default");
    }

    function test_RaisedBudgetClearsStorageHeavySetupHook() public {
        StorageHeavySetupBSM bsm = new StorageHeavySetupBSM();
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://heavy-hook-raised", address(bsm));

        vm.prank(admin);
        tangle.setManagerHookGasLimit(2_000_000);
        assertEq(tangle.managerHookGasLimit(), 2_000_000, "raised budget");

        vm.prank(developer);
        uint64 id = tangle.createBlueprint(def);
        assertTrue(bsm.initialized(), "setup hook ran to completion under the raised budget");
        assertEq(tangle.getBlueprint(id).manager, address(bsm), "manager wired");
    }

    /// @notice The budget is still a hard ceiling: a manager that tries to burn the
    ///         whole transaction is cut off at the hook budget and — because createBlueprint treats
    ///         its own manager's failure as fatal — creation reverts instead of the
    ///         caller silently paying for unbounded hostile work.
    function test_CreateBlueprintCapsGasExhaustingHook() public {
        GasExhaustingBSM bsm = new GasExhaustingBSM();
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://hostile-hook", address(bsm));

        uint256 gasBefore = gasleft();
        vm.prank(developer);
        vm.expectRevert();
        tangle.createBlueprint(def);
        // The hook's damage is bounded by the budget (500k default, plus protocol
        // overhead), not by the transaction gas limit.
        assertLt(gasBefore - gasleft(), 6_000_000, "hostile hook gas is bounded");
    }
}
