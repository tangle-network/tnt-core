// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";

/// @notice Regression guard: service/blueprint slashing of an operator's DELEGATED
///         stake MUST be punitive. The vulnerability was that `_slash` decremented only
///         operatorStake (self) and the operator delegation-pool accounting, never
///         flowing the loss into the delegator's beacon pool / pod ETH, so the delegator
///         could unwind and recover 100% of principal — making delegated stake worthless
///         collateral. The fix realizes the slash on `completeUndelegation`: the delegator
///         burns shares at the post-slash exchange rate and recovers only the slash-reduced
///         live valuation; the slashed value is retired from the pool, not returned. This
///         test asserts a 50% slash actually costs the delegator ~half their principal.
contract PoCSlashNoopTest is BeaconTestBase {
    function test_serviceSlashReducesDelegatorPrincipal() public {
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

        // ...and unwinding realizes that loss: undelegating at the post-slash live
        // valuation burns shares at the reduced exchange rate, so only the slash-reduced
        // value flows back into the beacon pool before the final withdrawal.
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

        // The 50% slash IS punitive: the delegator recovers the slash-reduced principal.
        //   totalStake = self 1 ETH + delegated 32 ETH = 33 ETH
        //   50% slash  = 16.5 ETH; self-stake absorbs 1 ETH, the delegation pool absorbs
        //                the remaining 15.5 ETH -> pool.totalAssets = 32 - 15.5 = 16.5 ETH
        // The delegator holds 100% of pool shares, so the realized live valuation — and the
        // ETH ultimately withdrawn from the beacon pool — is exactly 16.5 ETH. Anything at or
        // near 32 ETH means the slash was a no-op for delegated stake and the vuln is back.
        assertEq(received, 16.5 ether, "delegator recovered only the slash-reduced principal");
        assertLt(received, 32 ether, "delegator must NOT recover full principal after a slash");
    }
}
