// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";

/// @notice PoC: service/blueprint slashing of an operator's DELEGATED stake is
///         non-punitive. _slash decrements only operatorStake (self) and the
///         operator delegation-pool accounting; it never touches the delegator's
///         beacon pool or the pod's ETH. The delegator therefore recovers 100% of
///         principal after a slash, so delegated stake provides no real collateral.
contract PoCSlashNoopTest is BeaconTestBase {
    function test_poc_serviceSlashDoesNotReduceDelegatorPrincipal() public {
        // Staker restakes 32 ETH; pod holds the 32 ETH of withdrawn principal.
        ValidatorPod pod = _createPodWithShares(podOwner1, 32 ether);
        vm.deal(address(pod), 32 ether);

        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // Delegate the full 32 ETH to the operator.
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);
        assertEq(podManager.operatorDelegatedStake(operator1), 32 ether, "32 ETH delegated");

        // The slasher applies a 50% service slash against the operator.
        vm.prank(slasher);
        podManager.slash(operator1, 1, 5000, bytes32("evidence"));

        // Delegation pool accounting drops (self-stake 1 ETH absorbed first, then pool).
        // Operator's delegated stake is now reduced...
        uint256 delegatedAfterSlash = podManager.operatorDelegatedStake(operator1);
        assertLt(delegatedAfterSlash, 32 ether, "delegation pool reduced by slash (accounting only)");

        // ...but the delegator can fully unwind and recover ALL principal.
        // Undelegate the live (post-slash) valuation, then withdraw the beacon pool.
        uint256 liveDelegation = podManager.getDelegation(podOwner1, operator1);
        vm.prank(podOwner1);
        bytes32 uRoot = podManager.queueUndelegation(operator1, liveDelegation);
        vm.roll(block.number + podManager.withdrawalDelayBlocks());
        vm.prank(podOwner1);
        podManager.completeUndelegation(uRoot);

        // Counter cleared -> beacon withdrawal unblocked.
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 0, "delegation counter cleared");

        uint256 shares = podManager.getSharesUint(podOwner1);
        vm.prank(podOwner1);
        bytes32 wRoot = podManager.queueWithdrawal(shares);
        vm.roll(block.number + podManager.withdrawalDelayBlocks());

        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        podManager.completeWithdrawal(wRoot);
        uint256 received = podOwner1.balance - balBefore;

        // Despite a 50% slash on the delegated stake, the delegator recovered 100%.
        assertEq(received, 32 ether, "delegator recovered FULL principal despite 50% slash");
    }
}
