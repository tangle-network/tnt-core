// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";

/// @notice Regression guard: ValidatorPod.withdrawNonBeaconChainEth — the "tips recovery"
///         function that bypasses the withdrawal-queue delay and the delegation lock —
///         MUST NOT be able to reach beacon principal. Previously the owner could drain
///         ALL pod ETH (including exited beacon principal credited as beacon-pool shares
///         and delegated as slashable collateral) instantly, with no share burn and no
///         delegation check, escaping the slashing window and leaving delegations backed
///         by nothing. The fix reserves `totalAssetsOf(podOwner)` as an untouchable floor
///         and only lets the surplus above it be withdrawn here. This test asserts the
///         drain is now blocked and the principal/shares/delegation lock stay intact.
contract PoCNonBeaconDrainTest is BeaconTestBase {
    function test_withdrawNonBeaconChainEth_cannotDrainReservedBeaconPrincipal() public {
        // Staker restakes 32 ETH; the validator has exited so the 32 ETH principal
        // physically sits in the pod and has been credited as beacon-pool shares.
        ValidatorPod pod = _createPodWithShares(podOwner1, 32 ether);
        vm.deal(address(pod), 32 ether);

        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // Delegate the full principal as slashable collateral to the operator.
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);
        assertEq(podManager.operatorDelegatedStake(operator1), 32 ether, "32 ETH delegated/committed");

        // Attempt the instant drain via the "tips recovery" path. The entire 32 ETH is
        // reserved beacon principal (totalAssetsOf == 32 ETH, surplus == 0), so the pod
        // now rejects the withdrawal instead of bleeding restaked/delegated collateral.
        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPod.InsufficientBalance.selector);
        pod.withdrawNonBeaconChainEth(podOwner1, 32 ether);

        // Nothing left the pod: owner received zero, pod still custodies the full principal.
        assertEq(podOwner1.balance, balBefore, "owner received no principal - drain blocked");
        assertEq(address(pod).balance, 32 ether, "pod still custodies full beacon principal");

        // Beacon shares and the delegation lock remain consistent BECAUSE no collateral
        // was drained — they are backed by the ETH that is still in the pod, not phantom.
        assertEq(podManager.getSharesUint(podOwner1), 32 ether, "beacon shares intact and backed");
        assertEq(podManager.operatorDelegatedStake(operator1), 32 ether, "delegated stake still fully backed");
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 32 ether, "delegation lock backed by real ETH");
    }
}
