// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../../src/interfaces/IMultiAssetDelegation.sol";
import { IStaking } from "../../../src/interfaces/IStaking.sol";
import { MultiAssetDelegation } from "../../../src/staking/MultiAssetDelegation.sol";
import { DelegationManagerLib } from "../../../src/staking/DelegationManagerLib.sol";
import { DelegationErrors } from "../../../src/staking/DelegationErrors.sol";
import { Types } from "../../../src/libraries/Types.sol";

import { StakingOperatorsFacet } from "../../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingUnstakeWithdrawFacet } from "../../../src/facets/staking/StakingUnstakeWithdrawFacet.sol";
import { StakingSlashingFacet } from "../../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../../src/facets/staking/StakingAdminFacet.sol";

/// @title DelegationLib audit regression tests (MED/LOW unit: delegation-lib)
/// @notice Each test asserts a SECURE invariant introduced by the remediation; reverting the fix
///         in DelegationManagerLib.sol / StakingDelegationsFacet.sol makes the matching test fail.
contract DelegationLibAuditTest is Test {
    IMultiAssetDelegation internal delegation;

    address internal admin = makeAddr("admin");
    address internal operator = makeAddr("operator");
    address internal delegator = makeAddr("delegator");
    address internal receiver = makeAddr("receiver");

    uint256 internal constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 internal constant MIN_DELEGATION = 0.1 ether;
    uint16 internal constant OPERATOR_COMMISSION_BPS = 1000;
    uint256 internal constant ROUND_DURATION = 21_600; // 6h

    uint64 internal constant BOND_LESS_DELAY = 5;
    uint64 internal constant LEAVE_DELEGATORS_DELAY = 5;

    uint64 internal constant REGISTERED_BLUEPRINT = 7;

    function setUp() public {
        MultiAssetDelegation impl = new MultiAssetDelegation();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(
                MultiAssetDelegation.initialize, (admin, MIN_OPERATOR_STAKE, MIN_DELEGATION, OPERATOR_COMMISSION_BPS)
            )
        );
        delegation = IMultiAssetDelegation(payable(address(proxy)));

        MultiAssetDelegation router = MultiAssetDelegation(payable(address(proxy)));
        vm.startPrank(admin);
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingUnstakeWithdrawFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));

        // Roles used by the tests.
        delegation.addSlasher(admin);
        delegation.setTangle(admin);
        // Shorten the two unbonding delays so the additive-delay test stays cheap to advance.
        delegation.setDelays(BOND_LESS_DELAY, LEAVE_DELEGATORS_DELAY, 56);
        vm.stopPrank();

        vm.deal(operator, 100 ether);
        vm.deal(delegator, 100 ether);

        // Register operator, open delegation, and register it for one blueprint.
        vm.prank(operator);
        delegation.registerOperator{ value: 10 ether }();
        vm.prank(operator);
        delegation.setDelegationMode(Types.DelegationMode.Open);
        vm.prank(admin);
        delegation.addBlueprintForOperator(operator, REGISTERED_BLUEPRINT);
    }

    function _advanceRounds(uint256 rounds) internal {
        uint256 startTime = block.timestamp;
        for (uint256 i = 0; i < rounds; i++) {
            vm.warp(startTime + (i + 1) * ROUND_DURATION);
            delegation.advanceRound();
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Finding (MED): Fixed-mode delegation must reject unregistered blueprints,
    // otherwise the stake lands in a slash-immune pool.
    // ─────────────────────────────────────────────────────────────────────────

    function test_fixedDelegation_revertsForUnregisteredBlueprint() public {
        uint64[] memory bps = new uint64[](1);
        bps[0] = 9999; // operator is NOT registered for this blueprint

        vm.prank(delegator);
        delegation.deposit{ value: 5 ether }();

        vm.prank(delegator);
        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationManagerLib.BlueprintNotRegisteredForOperator.selector, operator, uint64(9999)
            )
        );
        delegation.delegateWithOptions(operator, address(0), 1 ether, Types.BlueprintSelectionMode.Fixed, bps);
    }

    function test_fixedDelegation_succeedsForRegisteredBlueprint() public {
        uint64[] memory bps = new uint64[](1);
        bps[0] = REGISTERED_BLUEPRINT;

        vm.prank(delegator);
        delegation.deposit{ value: 5 ether }();
        vm.prank(delegator);
        delegation.delegateWithOptions(operator, address(0), 1 ether, Types.BlueprintSelectionMode.Fixed, bps);

        assertEq(delegation.getDelegation(delegator, operator), 1 ether, "registered-blueprint delegation must work");
    }

    function test_addBlueprintToDelegation_revertsForUnregisteredBlueprint() public {
        // Start with a valid Fixed delegation on the registered blueprint.
        uint64[] memory bps = new uint64[](1);
        bps[0] = REGISTERED_BLUEPRINT;
        vm.prank(delegator);
        delegation.deposit{ value: 5 ether }();
        vm.prank(delegator);
        delegation.delegateWithOptions(operator, address(0), 2 ether, Types.BlueprintSelectionMode.Fixed, bps);

        // Adding an unregistered blueprint must fail closed.
        vm.prank(delegator);
        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationManagerLib.BlueprintNotRegisteredForOperator.selector, operator, uint64(4242)
            )
        );
        delegation.addBlueprintToDelegation(0, 4242);

        // Adding another registered blueprint still works.
        vm.prank(admin);
        delegation.addBlueprintForOperator(operator, 8);
        vm.prank(delegator);
        delegation.addBlueprintToDelegation(0, 8);
        assertEq(delegation.getDelegationBlueprints(delegator, 0).length, 2, "second registered blueprint must add");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Finding (LOW): slash must not strand deposit principal. After a slash + full
    // undelegate, delegatedAmount residual, dep.amount and currentDeposits must be
    // reconciled down by the realized slash loss.
    // ─────────────────────────────────────────────────────────────────────────

    function test_slash_doesNotStrandPrincipal_twoStepPath() public {
        // Deposit 10, delegate 10 (All mode).
        vm.prank(delegator);
        delegation.depositAndDelegate{ value: 10 ether }(operator);

        Types.AssetConfig memory cfgBefore = delegation.getAssetConfig(address(0));
        assertEq(cfgBefore.currentDeposits, 10 ether, "currentDeposits should track full deposit");

        // 20% slash of the All-mode pool (slash happens BEFORE undelegation — the exact finding).
        vm.prank(admin);
        uint256 slashed = delegation.slash(operator, 1, 2000, bytes32("ev"));
        assertGt(slashed, 0, "slash must reduce the pool");

        // Schedule + execute FULL undelegation at the post-slash value (~8 ether).
        uint256 postSlashValue = delegation.getDelegation(delegator, operator);
        assertApproxEqAbs(postSlashValue, 8 ether, 1e6, "delegation value reflects the slash");
        vm.prank(delegator);
        delegation.scheduleDelegatorUnstake(operator, address(0), postSlashValue);
        _advanceRounds(BOND_LESS_DELAY + 1);
        vm.prank(delegator);
        delegation.executeDelegatorUnstake();

        // Position fully closed.
        assertEq(delegation.getDelegation(delegator, operator), 0, "delegation must be fully removed");

        Types.Deposit memory dep = delegation.getDeposit(delegator, address(0));
        // SECURE INVARIANT: no residual delegated cost-basis after full exit.
        assertEq(dep.delegatedAmount, 0, "residual delegatedAmount must be reconciled to zero");

        // dep.amount and currentDeposits must reflect the destroyed principal (~2 ether lost).
        Types.AssetConfig memory cfgAfter = delegation.getAssetConfig(address(0));
        assertApproxEqAbs(dep.amount, 8 ether, 1e6, "dep.amount must drop by the slash loss");
        assertApproxEqAbs(cfgAfter.currentDeposits, 8 ether, 1e6, "currentDeposits must drop by the slash loss");

        // The withdrawable balance must equal the realized post-slash value (no phantom headroom).
        assertEq(dep.amount, dep.amount - dep.delegatedAmount, "available == amount when nothing delegated");

        // And the delegator can actually withdraw the full remaining balance.
        vm.prank(delegator);
        delegation.scheduleWithdraw(address(0), dep.amount);
        _advanceRounds(LEAVE_DELEGATORS_DELAY + 1);
        uint256 balBefore = delegator.balance;
        vm.prank(delegator);
        delegation.executeWithdraw();
        assertApproxEqAbs(delegator.balance - balBefore, 8 ether, 1e6, "must withdraw full post-slash principal");

        Types.Deposit memory depFinal = delegation.getDeposit(delegator, address(0));
        assertEq(depFinal.amount, 0, "no stranded principal must remain");
        Types.AssetConfig memory cfgFinal = delegation.getAssetConfig(address(0));
        assertEq(cfgFinal.currentDeposits, 0, "currentDeposits must drain to zero (no inflated cap headroom)");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Finding (LOW): executeDelegatorUnstakeAndWithdraw must impose the FULL
    // additive unbonding period (bondLessDelay + leaveDelegatorsDelay), not half.
    // ─────────────────────────────────────────────────────────────────────────

    function test_executeAndWithdraw_requiresAdditiveUnbonding() public {
        vm.prank(delegator);
        delegation.depositAndDelegate{ value: 10 ether }(operator);

        vm.prank(delegator);
        delegation.scheduleDelegatorUnstake(operator, address(0), 4 ether);

        Types.BondLessRequest[] memory reqs = delegation.getPendingUnstakes(delegator);
        assertEq(reqs.length, 1, "one pending request");
        uint64 requestedRound = reqs[0].requestedRound;
        uint256 shares = reqs[0].shares;

        // Advance past ONLY the bond-less delay. The combined path must STILL reject because the
        // withdraw delay stacks on top (this is the half-unbonding bug being fixed).
        _advanceRounds(BOND_LESS_DELAY + 1);

        uint64 expectedReadyRound = requestedRound + BOND_LESS_DELAY + LEAVE_DELEGATORS_DELAY;
        // Cache currentRound BEFORE the prank: evaluating delegation.currentRound() as the
        // expectRevert argument consumes the prank, so the call would run as the test contract
        // (DelegationNotFound) instead of the delegator (WithdrawTooEarly).
        uint64 curRound = delegation.currentRound();
        vm.prank(delegator);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.WithdrawTooEarly.selector, curRound, expectedReadyRound)
        );
        delegation.executeDelegatorUnstakeAndWithdraw(operator, address(0), shares, requestedRound, receiver);

        // Advance the remaining (additive) delay; now it must succeed.
        _advanceRounds(LEAVE_DELEGATORS_DELAY);
        uint256 recvBefore = receiver.balance;
        vm.prank(delegator);
        uint256 amount = delegation.executeDelegatorUnstakeAndWithdraw(operator, address(0), shares, requestedRound, receiver);
        assertGt(amount, 0, "redeem must pay out after the full additive delay");
        assertEq(receiver.balance - recvBefore, amount, "receiver gets the redeemed assets");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Finding (MED): a pending slash must block every delegation-exit path so a
    // matured unstake cannot exit at the pre-slash exchange rate.
    // ─────────────────────────────────────────────────────────────────────────

    function test_pendingSlash_blocksScheduleAndCombinedRedeem() public {
        IStaking staking = IStaking(address(delegation));

        vm.prank(delegator);
        delegation.depositAndDelegate{ value: 10 ether }(operator);

        // A matured, standing unstake request.
        vm.prank(delegator);
        delegation.scheduleDelegatorUnstake(operator, address(0), 5 ether);
        Types.BondLessRequest[] memory reqs = delegation.getPendingUnstakes(delegator);
        uint64 requestedRound = reqs[0].requestedRound;
        uint256 shares = reqs[0].shares;
        _advanceRounds(BOND_LESS_DELAY + LEAVE_DELEGATORS_DELAY + 1);

        // A slash is now proposed against the operator (pending-slash counter goes positive).
        vm.prank(admin);
        staking.incrementPendingSlash(operator);
        assertEq(staking.getPendingSlashCount(operator), 1, "pending slash registered");

        // Scheduling a NEW unstake must be blocked.
        vm.prank(delegator);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.PendingSlashExists.selector, operator, uint64(1))
        );
        delegation.scheduleDelegatorUnstake(operator, address(0), 1 ether);

        // The single-step redeem of the already-matured request must also be blocked, so it cannot
        // drain at the pre-slash rate while the slash is in flight.
        vm.prank(delegator);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.PendingSlashExists.selector, operator, uint64(1))
        );
        delegation.executeDelegatorUnstakeAndWithdraw(operator, address(0), shares, requestedRound, receiver);

        // The two-step execute SKIPS the request while the slash is pending (no payout, request
        // remains for after resolution).
        vm.prank(delegator);
        delegation.executeDelegatorUnstake();
        assertEq(delegation.getPendingUnstakes(delegator).length, 1, "matured request must not execute under pending slash");
    }

    function test_executeAndWithdraw_slashLossReconciled() public {
        vm.prank(delegator);
        delegation.depositAndDelegate{ value: 10 ether }(operator);

        vm.prank(delegator);
        delegation.scheduleDelegatorUnstake(operator, address(0), 10 ether);

        Types.BondLessRequest[] memory reqs = delegation.getPendingUnstakes(delegator);
        uint64 requestedRound = reqs[0].requestedRound;
        uint256 shares = reqs[0].shares;

        // Slash 20% after scheduling but before redeem.
        vm.prank(admin);
        delegation.slash(operator, 1, 2000, bytes32("ev"));

        // Wait out the full additive unbonding window.
        _advanceRounds(BOND_LESS_DELAY + LEAVE_DELEGATORS_DELAY + 1);

        vm.prank(delegator);
        delegation.executeDelegatorUnstakeAndWithdraw(operator, address(0), shares, requestedRound, receiver);

        // No stranded principal: position closed, deposit accounting fully reconciled.
        Types.Deposit memory dep = delegation.getDeposit(delegator, address(0));
        assertEq(dep.delegatedAmount, 0, "no residual delegatedAmount after slashed redeem");
        assertEq(dep.amount, 0, "no stranded dep.amount after slashed redeem");
        Types.AssetConfig memory cfg = delegation.getAssetConfig(address(0));
        assertEq(cfg.currentDeposits, 0, "currentDeposits must not stay inflated after slashed redeem");
    }
}
