// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";
import { IMultiAssetDelegation } from "../../src/interfaces/IMultiAssetDelegation.sol";
import { MockServiceFeeDistributor } from "../mocks/MockServiceFeeDistributor.sol";

interface ITanglePaymentsLike {
    function fundService(uint64 serviceId, uint256 amount) external payable;
    function billSubscription(uint64 serviceId) external;
    function claimRewards() external;
    function terminateService(uint64 serviceId) external;
    function withdrawRemainingEscrow(uint64 serviceId) external;
    function pendingRewards(address account) external view returns (uint256);
    function getServiceEscrow(uint64 serviceId) external view returns (PaymentLib.ServiceEscrow memory);
}

contract SubscriptionEscrowHandler is Test {
    uint256 internal constant MAX_TOP_UP = 2 ether;
    uint256 internal constant MAX_STAKE_RAMP = 10 ether;

    ITanglePaymentsLike internal tangle;
    IMultiAssetDelegation internal staking;
    address internal serviceOwner;
    address internal operator;
    address internal stakeRamper;

    uint64 public immutable serviceId;
    uint256 public immutable nominalRate;
    uint256 public immutable baselinePinnedAtSetup;

    uint256 public totalFunded;
    uint256 public totalClaimedByOperator;
    uint256 public totalRefundedToOwner;

    /// @notice Highest single-bill release amount observed across the entire sequence.
    /// @dev Driven by tracking `totalReleased` deltas in `bill()`. Used by the
    ///      `invariant_billAmountNeverExceedsNominalRate` check.
    uint256 public maxSingleBillRelease;
    uint256 public successfulBillCount;
    uint256 public observedBaselineStake; // last-seen subscriptionBaselineStake

    constructor(
        ITanglePaymentsLike tangle_,
        IMultiAssetDelegation staking_,
        uint64 serviceId_,
        address serviceOwner_,
        address operator_,
        address stakeRamper_,
        uint256 nominalRate_,
        uint256 baselinePinnedAtSetup_
    ) {
        tangle = tangle_;
        staking = staking_;
        serviceId = serviceId_;
        serviceOwner = serviceOwner_;
        operator = operator_;
        stakeRamper = stakeRamper_;
        nominalRate = nominalRate_;
        baselinePinnedAtSetup = baselinePinnedAtSetup_;
        observedBaselineStake = baselinePinnedAtSetup_;
    }

    function topUp(uint256 amount) external {
        amount = bound(amount, 1 wei, MAX_TOP_UP);
        vm.deal(serviceOwner, serviceOwner.balance + amount);
        vm.prank(serviceOwner);
        try tangle.fundService{ value: amount }(serviceId, amount) {
            totalFunded += amount;
        } catch { }
    }

    function warpForward(uint256 step) external {
        step = bound(step, 1 days, 45 days);
        vm.warp(block.timestamp + step);
    }

    function bill() external {
        PaymentLib.ServiceEscrow memory before = tangle.getServiceEscrow(serviceId);
        uint256 releasedBefore = before.totalReleased;
        try tangle.billSubscription(serviceId) {
            PaymentLib.ServiceEscrow memory afterEscrow = tangle.getServiceEscrow(serviceId);
            uint256 drawn = afterEscrow.totalReleased - releasedBefore;
            if (drawn > maxSingleBillRelease) maxSingleBillRelease = drawn;
            if (drawn > 0) successfulBillCount++;
            observedBaselineStake = afterEscrow.subscriptionBaselineStake;
        } catch { }
    }

    function claimOperator() external {
        uint256 beforeBalance = operator.balance;
        vm.prank(operator);
        try tangle.claimRewards() {
            totalClaimedByOperator += operator.balance - beforeBalance;
        } catch { }
    }

    function terminate() external {
        vm.prank(serviceOwner);
        try tangle.terminateService(serviceId) { } catch { }
    }

    function refundRemaining() external {
        uint256 beforeBalance = serviceOwner.balance;
        vm.prank(serviceOwner);
        try tangle.withdrawRemainingEscrow(serviceId) {
            totalRefundedToOwner += serviceOwner.balance - beforeBalance;
        } catch { }
    }

    /// @notice Adversarial stake ramp: a delegator unrelated to the customer deposits more
    ///         native into the operator pool, inflating raw cum-stake-seconds for the
    ///         current bill window. The bill amount MUST stay capped at `nominalRate`.
    function rampStakeUp(uint256 amount) external {
        amount = bound(amount, 0.1 ether, MAX_STAKE_RAMP);
        vm.deal(stakeRamper, stakeRamper.balance + amount);
        vm.prank(stakeRamper);
        try staking.depositAndDelegate{ value: amount }(operator) { } catch { }
    }

    /// @notice Adversarial stake unwind: opposite direction. Schedules an unstake of
    ///         the ramper's delegation so cum-stake-seconds drift down again.
    function rampStakeDown(uint256 amount) external {
        uint256 current = staking.getDelegation(stakeRamper, operator);
        if (current == 0) return;
        amount = bound(amount, 1, current);
        vm.prank(stakeRamper);
        try staking.scheduleDelegatorUnstake(operator, address(0), amount) { } catch { }
    }
}

contract SubscriptionEscrowInvariantTest is StdInvariant, BaseTest {
    MockServiceFeeDistributor internal distributor;
    SubscriptionEscrowHandler internal handler;

    uint64 internal serviceId;
    uint256 internal subscriptionRate;
    uint256 internal pinnedBaseline;

    /// @dev Adversarial delegator that ramps stake up/down on operator1 during the run.
    address internal stakeRamper = makeAddr("stakeRamper");

    uint256 internal initialDeveloperBalance;
    uint256 internal initialTreasuryBalance;
    uint256 internal initialDistributorBalance;

    function setUp() public override {
        super.setUp();

        distributor = new MockServiceFeeDistributor();
        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        staking.setServiceFeeDistributor(address(distributor));
        vm.stopPrank();

        subscriptionRate = 0.1 ether;
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: subscriptionRate,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 bp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription-invariant", address(0), config));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, bp);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        uint256 initialDeposit = 1 ether;
        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: initialDeposit }(
            bp, operators, "", callers, 365 days, address(0), initialDeposit, Types.ConfidentialityPolicy.Any
        );
        _approveService(operator1, requestId);
        serviceId = 0;

        // Snapshot the baseline pinned at activation. The invariant
        // `invariant_baselinePinnedAtActivation` requires this to remain immutable.
        PaymentLib.ServiceEscrow memory escrowAtActivation = tangle.getServiceEscrow(serviceId);
        pinnedBaseline = escrowAtActivation.subscriptionBaselineStake;

        initialDeveloperBalance = developer.balance;
        initialTreasuryBalance = treasury.balance;
        initialDistributorBalance = address(distributor).balance;

        handler = new SubscriptionEscrowHandler(
            ITanglePaymentsLike(address(tangle)),
            staking,
            serviceId,
            user1,
            operator1,
            stakeRamper,
            subscriptionRate,
            pinnedBaseline
        );
        vm.deal(address(handler), 100 ether);
        targetContract(address(handler));
    }

    function invariant_subscriptionEscrowConservesNativeValue() external view {
        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        uint256 pendingOperator = tangle.pendingRewards(operator1);
        // Keeper rebate accrues to the bill caller (the handler contract) via the
        // pending-rewards mapping. Track it so the conservation invariant holds.
        uint256 pendingKeeper = tangle.pendingRewards(address(handler));

        uint256 developerOut = developer.balance - initialDeveloperBalance;
        uint256 treasuryOut = treasury.balance - initialTreasuryBalance;
        uint256 stakerOut = address(distributor).balance - initialDistributorBalance;

        uint256 lhs = 1 ether + handler.totalFunded();
        uint256 rhs = escrow.balance + pendingOperator + pendingKeeper + handler.totalClaimedByOperator()
            + handler.totalRefundedToOwner() + developerOut + treasuryOut + stakerOut;

        assertEq(lhs, rhs, "subscription native value not conserved");
        assertEq(
            address(tangle).balance, escrow.balance + pendingOperator + pendingKeeper, "tangle balance mismatch"
        );
    }

    /// @notice A single bill draw can never exceed the blueprint's nominal subscription rate.
    /// @dev Catches: a regression of the cap-at-nominal clamp in
    ///      `PaymentsBilling._billSubscriptionImpl` (the `if (amount > nominalRate) amount = nominalRate;`
    ///      branch). Without that branch, an adversarial stake ramp pushes the TWAP
    ///      ratio above 1 and the customer is overcharged. The handler drives delegate
    ///      / undelegate / warp / bill sequences with an unrelated `stakeRamper`
    ///      adding native to the operator pool.
    function invariant_billAmountNeverExceedsNominalRate() external view {
        assertLe(
            handler.maxSingleBillRelease(),
            subscriptionRate,
            "single-bill draw exceeded nominal subscription rate"
        );
    }

    /// @notice The subscription baseline is captured ONCE at activation and never changes.
    /// @dev Catches: a regression that re-pins `subscriptionBaselineStake` on a later
    ///      bill / topUp / re-init path. The baseline pins the per-period denominator
    ///      so post-activation stake ramps cannot inflate the bill. The escrow view
    ///      must always show the same baseline as the one captured in `setUp`.
    function invariant_baselinePinnedAtActivation() external view {
        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        assertEq(
            escrow.subscriptionBaselineStake,
            pinnedBaseline,
            "subscriptionBaselineStake mutated after activation"
        );
        // Also verify the handler's observation (last-seen value at each successful
        // bill) never drifted from the activation baseline — defends against a
        // sequence-dependent re-pinning that the static read above would miss.
        assertEq(
            handler.observedBaselineStake(),
            pinnedBaseline,
            "baseline observed during billing diverged from activation snapshot"
        );
    }
}
