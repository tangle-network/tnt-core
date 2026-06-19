// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";

/// @title PoCNonBeaconDrainAfterSlash
/// @notice Regression guard for the "service slash is non-punitive" drain.
///
///         Before the fix, after a service (L2) slash was realized in
///         `completeUndelegation`, the beacon-pool `totalAssets` floor used by
///         `ValidatorPod.withdrawNonBeaconChainEth` dropped below the physical ETH
///         still held by the pod. The owner could then drain the "burned" principal as
///         fake non-beacon surplus, and later withdraw the surviving shares normally —
///         recovering the ENTIRE 32 ETH principal despite a 50% slash.
///
///         Fix: `completeUndelegation` now reports the burned (slashed) principal to the
///         pod via `recordSlashedPrincipalRetained`, and `withdrawNonBeaconChainEth`
///         floors withdrawals at `totalAssetsOf + slashedPrincipalRetainedWei`. The
///         stranded slashed ETH is therefore permanently un-extractable, and the slash
///         is punitive: the owner recovers only the surviving (non-slashed) principal.
contract PoCNonBeaconDrainAfterSlash is BeaconTestBase {
    function test_slashedPrincipalCannotBeDrainedAsNonBeaconEth() public {
        // ── 1. Owner restakes 32 ETH; the full principal physically sits in the
        //       pod and is credited as beacon-pool shares. ────────────────────
        ValidatorPod pod = _createPodWithShares(podOwner1, 32 ether);
        vm.deal(address(pod), 32 ether);
        assertEq(podManager.totalAssetsOf(podOwner1), 32 ether, "floor==32 pre-slash");
        assertEq(address(pod).balance, 32 ether, "32 ETH in pod");

        // ── 2. Register operator and delegate the full principal. ─────────────
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);

        // ── 3. Slash the operator 50% at the service (L2) layer. ──────────────
        uint256 poolBefore = podManager.operatorDelegatedStake(operator1);
        vm.prank(slasher);
        podManager.slash(operator1, 1, 5000, bytes32(uint256(1)));
        uint256 poolAfter = podManager.operatorDelegatedStake(operator1);
        assertLt(poolAfter, poolBefore, "delegation pool reduced by slash");

        // Shorten the undelegation/withdrawal delay so the test is tractable.
        vm.prank(admin);
        podManager.setWithdrawalDelay(10);

        // ── 4. Queue + complete undelegation. This realizes the slash: the
        //       delegator's beacon-pool shares are partially BURNED, lowering
        //       totalAssetsOf, and the burned principal is reported to the pod. ─
        uint256 live = podManager.getDelegation(podOwner1, operator1); // post-slash live value
        vm.prank(podOwner1);
        bytes32 root = podManager.queueUndelegation(operator1, live);

        vm.roll(100);

        vm.prank(podOwner1);
        podManager.completeUndelegation(root);

        // The floor dropped (escrow burn), but the physical 32 ETH is still in the pod.
        uint256 floor = podManager.totalAssetsOf(podOwner1);
        assertLt(floor, 32 ether, "floor reduced by escrow burn");
        assertEq(address(pod).balance, 32 ether, "physical ETH still in pod");

        uint256 burnedPrincipal = pod.slashedPrincipalRetainedWei();
        assertGt(burnedPrincipal, 0, "pod recorded the burned slashed principal");

        // The fake surplus the old exploit targeted is now fully reserved by the pod's
        // slashed-principal floor, so there is no withdrawable non-beacon ETH at all.
        uint256 fakeSurplus = 32 ether - floor;
        assertEq(fakeSurplus, burnedPrincipal, "fake surplus exactly equals the burned principal");

        // ── 5. EXPLOIT ATTEMPT: draining the burned principal must now revert. ─
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPod.InsufficientBalance.selector);
        pod.withdrawNonBeaconChainEth(podOwner1, fakeSurplus);

        // Even 1 wei of "surplus" is unavailable — the floor covers the whole balance.
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPod.InsufficientBalance.selector);
        pod.withdrawNonBeaconChainEth(podOwner1, 1);

        // ── 6. Owner withdraws ONLY the surviving (non-slashed) shares normally. ─
        uint256 survivorShares = podManager.getSharesUint(podOwner1);
        vm.prank(podOwner1);
        bytes32 wRoot = podManager.queueWithdrawal(survivorShares);

        vm.roll(1000);

        vm.prank(podOwner1);
        podManager.completeWithdrawal(wRoot);

        // ── NET RESULT: the 50% slash is punitive. The owner recovers only the
        //    surviving ~16.5 ETH (operator self-stake absorbed the first 1 ETH of the
        //    16.5 ETH slash, so 15.5 ETH of pod principal was burned). The slashed
        //    principal stays stranded in the pod and is never extractable.
        assertLt(podOwner1.balance, 132 ether, "owner did NOT recover the full principal");
        assertEq(podOwner1.balance, 116.5 ether, "owner recovered only surviving principal (100 + 16.5)");
        assertEq(address(pod).balance, 15.5 ether, "slashed principal stranded in pod, not drained");
    }
}
