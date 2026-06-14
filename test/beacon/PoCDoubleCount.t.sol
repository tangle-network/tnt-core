// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";
import { ValidatorPodManager } from "../../src/beacon/ValidatorPodManager.sol";

/// @notice Regression: queued beacon withdrawal and delegation can no longer
///         double-count the same restaked principal. A staker queues a full
///         withdrawal (allowed while undelegated), then attempts to delegate the
///         SAME principal. The fix gates `delegateTo` in share space —
///         freeShares = ownerShares - (queuedShares + delegatedShares) — so the
///         already-queued shares are NOT available to back a new delegation and
///         the call reverts with InsufficientShares(). The real withdrawal then
///         completes normally and NO phantom, zero-backed delegation persists.
///
///         INVARIANT GUARDED: beacon shares are mutually exclusive across the
///         {free, queued, delegated} buckets — _shares[d] >= queuedShares[d] +
///         delegatedShares[d] at all times, so the same principal can never
///         simultaneously be withdrawn AND back a live delegation.
contract PoCDoubleCountTest is BeaconTestBase {
    function test_queueThenDelegate_doubleCountBlocked_sharesMutuallyExclusive() public {
        // Staker restakes 32 ETH of beacon principal -> beacon-pool shares.
        ValidatorPod pod = _createPodWithShares(podOwner1, 32 ether);
        // The pod physically holds the 32 ETH of (already-withdrawn) beacon principal.
        vm.deal(address(pod), 32 ether);

        // An operator exists to delegate to.
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        uint256 shares = podManager.getSharesUint(podOwner1);
        assertEq(shares, 32 ether, "32 ETH shares minted");

        // Step 1: queue a withdrawal of ALL shares (delegation == 0, so allowed).
        vm.prank(podOwner1);
        bytes32 wRoot = podManager.queueWithdrawal(shares);

        // After queueing, every share is in the `queued` bucket: none are free.
        // freeShares = ownerShares - (queuedShares + delegatedShares) == 0.
        assertEq(podManager.queuedShares(podOwner1), 32 ether, "all 32 ETH shares queued");
        assertEq(podManager.delegatedShares(podOwner1), 0, "no shares delegated yet");

        // Step 2 (EXPLOIT, now BLOCKED): try to delegate the SAME 32 ETH. The fix
        // computes freeShares = ownerShares - (queuedShares + delegatedShares) = 0,
        // so freeAssets (0) < amount (32 ETH) and the call reverts. The queued shares
        // can no longer be double-spent into a phantom delegation.
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.InsufficientShares.selector);
        podManager.delegateTo(operator1, 32 ether);

        // The exploit reverted: no delegation was ever created, no shares moved into
        // the `delegated` bucket, and the queued bucket is untouched. Buckets remain
        // mutually exclusive: free(0) + queued(32) + delegated(0) == owner shares(32).
        assertEq(podManager.operatorDelegatedStake(operator1), 0, "operator has no delegated stake");
        assertEq(podManager.getDelegation(podOwner1, operator1), 0, "delegator has no delegation");
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 0, "deposit counter is zero");
        assertEq(podManager.delegatedShares(podOwner1), 0, "no shares double-counted into delegation");
        assertEq(podManager.queuedShares(podOwner1), 32 ether, "queued shares unchanged by failed delegation");
        // INVARIANT: ownerShares >= queuedShares + delegatedShares (mutual exclusivity).
        assertEq(
            podManager.getSharesUint(podOwner1),
            podManager.queuedShares(podOwner1) + podManager.delegatedShares(podOwner1),
            "all owner shares accounted for; queued and delegated buckets are disjoint and non-overlapping"
        );

        // Step 3: wait out the delay and complete the legitimate withdrawal. This is
        // the only claim on the principal, so it pays out cleanly with no phantom left.
        vm.roll(block.number + podManager.withdrawalDelayBlocks());

        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        podManager.completeWithdrawal(wRoot);
        uint256 received = podOwner1.balance - balBefore;

        // The staker got their full principal back, exactly once.
        assertEq(received, 32 ether, "staker withdrew full 32 ETH");
        assertEq(podManager.getSharesUint(podOwner1), 0, "beacon shares fully burned");
        assertEq(podManager.totalAssetsOf(podOwner1), 0, "beacon pool drained");
        assertEq(address(pod).balance, 0, "pod ETH fully removed");

        // No phantom delegation survives: the principal that left the pod is NOT
        // simultaneously backing any operator. Double-count is closed.
        assertEq(
            podManager.operatorDelegatedStake(operator1), 0, "no phantom delegated stake after withdrawal"
        );
        assertEq(podManager.getDelegation(podOwner1, operator1), 0, "no phantom delegation after withdrawal");
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 0, "deposit counter zero after full exit");
        assertEq(podManager.delegatedShares(podOwner1), 0, "no delegated shares after full exit");
    }
}
