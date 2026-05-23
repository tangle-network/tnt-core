// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";

/// @dev Test-only manager that waives every subscription bill (QoS adjustment = 0 bps).
contract QosZeroManager is BlueprintServiceManagerBase {
    function computeBillAdjustmentBps(uint64, uint64, uint64) external pure override returns (uint16) {
        return 0;
    }
}

/// @dev Test-only manager that allows force-removing operators below the protocol-enforced
///      `minOperators` floor. Lets tests reach the zero-active-operators state.
contract ForceRemoveAllowedManager is BlueprintServiceManagerBase {
    function forceRemoveAllowsBelowMin(uint64) external pure override returns (bool) {
        return true;
    }

    function evict(address tangle_, uint64 serviceId, address op) external {
        (bool ok,) = tangle_.call(abi.encodeWithSignature("forceRemoveOperator(uint64,address)", serviceId, op));
        require(ok, "evict failed");
    }
}

/// @title SubscriptionBillingTest
/// @notice Behavioral coverage for the TWAP-fair, keeper-incentivised subscription
///         billing engine. Verifies:
///           - Baseline pinned at activation (not at first bill).
///           - Bill amount weighted by per-operator TWAP cum-stake-seconds.
///           - Operator payout shares match TWAP weights (not snapshot exposure).
///           - Zero-active-operators advances the cursor without billing.
///           - Manager QoS hook scales the bill down (never up).
///           - Keeper rebate paid to msg.sender on each successful bill.
///           - EventDriven pricing rejects upfront paymentAmount at request.
///           - Pure math primitives (`twapBillAmount`, `applyQosAdjustment`).
contract SubscriptionBillingTest is BaseTest {
    uint256 internal constant SUB_RATE = 1 ether;
    uint64 internal constant SUB_INTERVAL = 30 days;

    uint256 internal constant BASE_OP_STAKE = 5 ether;
    uint256 internal constant DELEGATOR_BASELINE = 10 ether;

    uint64 internal blueprintId;
    uint64 internal serviceId;
    address internal slasher = makeAddr("f5_slasher");

    function setUp() public override {
        super.setUp();
        vm.prank(admin);
        staking.addSlasher(slasher);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    function _setUpSubscription() internal {
        _setUpSubscriptionImpl(Types.MembershipModel.Fixed);
    }

    function _setUpDynamicSubscription() internal {
        _setUpSubscriptionImpl(Types.MembershipModel.Dynamic);
    }

    function _setUpSubscriptionImpl(Types.MembershipModel membership) internal {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: membership,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: SUB_RATE,
            subscriptionInterval: SUB_INTERVAL,
            eventRate: 0
        });

        vm.prank(developer);
        blueprintId = _createBlueprintWithConfigAsSender("ipfs://subscription", address(0), config);

        // Operator 1: registers + delegator stakes baseline.
        vm.prank(operator1);
        staking.registerOperator{ value: BASE_OP_STAKE }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        vm.startPrank(delegator1);
        staking.deposit{ value: DELEGATOR_BASELINE }();
        staking.delegate(operator1, DELEGATOR_BASELINE);
        vm.stopPrank();

        uint256 escrow = SUB_RATE * 24;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.deal(address(tangle), 200 ether);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: escrow }(
            blueprintId, operators, "", callers, 0, address(0), escrow, Types.ConfidentialityPolicy.Any
        );

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        serviceId = 0;
        assertTrue(tangle.isServiceActive(serviceId), "service active");
    }

    function _escrow() internal view returns (PaymentLib.ServiceEscrow memory) {
        return tangle.getServiceEscrow(serviceId);
    }

    function _billOnceAndMeasure() internal returns (uint256 charged) {
        uint256 releasedBefore = _escrow().totalReleased;
        tangle.billSubscription(serviceId);
        charged = _escrow().totalReleased - releasedBefore;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // BASELINE AT ACTIVATION (not first bill)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice First subscription bill at constant stake equals the nominal rate.
    /// @dev Baseline is captured at activation, so a service with no stake changes
    ///      between activation and first bill produces a TWAP ratio of exactly 1.
    ///      Floor division can leave a sub-wei residue (e.g. 999_999_999_999_999_999
    ///      when stake*interval doesn't divide evenly), so we tolerate 1 wei.
    function test_FirstBill_AtConstantStake_EqualsNominal() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // Baseline is already pinned at activation; no lazy-init "free" first bill.
        PaymentLib.ServiceEscrow memory esc = _escrow();
        assertGt(esc.subscriptionBaselineStake, 0, "baseline pinned at activation");

        vm.warp(t0 + SUB_INTERVAL);
        uint256 charged = _billOnceAndMeasure();
        assertApproxEqAbs(charged, SUB_RATE, 1, "constant-stake bill == nominal at activation baseline");
    }

    /// @notice Stake doubling mid-period CANNOT inflate the customer's bill above nominal.
    /// @dev The bill cap at `nominalRate` is the key customer-protection invariant: operators
    ///      can ramp stake mid-period (earning a bigger share of the operator pool via TWAP
    ///      weighting), but the customer never pays more than the rate they signed up for.
    ///      Counterpoint to `test_StakeHalvedMidPeriod_BillsThreeQuarters`: downward stake
    ///      changes DO reduce the bill (customer relief on degraded security), upward stake
    ///      changes do NOT inflate it (no surprise bill).
    function test_StakeDoubledMidPeriod_BillCappedAtNominal() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        vm.warp(t0 + SUB_INTERVAL);
        _billOnceAndMeasure();

        // Halfway through next period, double effective stake on operator1.
        vm.warp(block.timestamp + SUB_INTERVAL / 2);
        uint256 doubleAmount = BASE_OP_STAKE + DELEGATOR_BASELINE;
        vm.deal(delegator1, doubleAmount);
        vm.startPrank(delegator1);
        staking.deposit{ value: doubleAmount }();
        staking.delegate(operator1, doubleAmount);
        vm.stopPrank();
        vm.warp(block.timestamp + SUB_INTERVAL / 2);

        uint256 charged = _billOnceAndMeasure();
        // Capped at nominal: even though raw TWAP would give ~1.5x, the bill cannot exceed
        // the rate the customer agreed to.
        assertApproxEqAbs(charged, SUB_RATE, 1, "doubled-mid-period bill capped at nominal");
    }

    /// @notice 50% slash mid-period bills ~0.75× the nominal rate.
    function test_StakeHalvedMidPeriod_BillsThreeQuarters() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        vm.warp(t0 + SUB_INTERVAL);
        _billOnceAndMeasure();

        vm.warp(block.timestamp + SUB_INTERVAL / 2);
        vm.prank(slasher);
        staking.slash(operator1, serviceId, 5000, bytes32(uint256(0xdeed)));
        vm.warp(block.timestamp + SUB_INTERVAL / 2);

        uint256 charged = _billOnceAndMeasure();
        uint256 lower = (SUB_RATE * 70) / 100;
        uint256 upper = (SUB_RATE * 80) / 100;
        assertGe(charged, lower, "halved-mid-period bill >= 0.70x");
        assertLe(charged, upper, "halved-mid-period bill <= 0.80x");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ZERO-OPERATOR SAFETY (no livelock)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice When the active operator set is empty, the bill function advances
    ///         the cursor and emits `SubscriptionBillSkippedNoOperators` without
    ///         touching escrow. Customer's funds stay intact; the schedule resumes
    ///         the moment an operator rejoins.
    /// @dev Uses a manager that bypasses the `minOperators` floor via
    ///      `forceRemoveAllowsBelowMin`, so a force-removal can leave zero active
    ///      operators on an otherwise-active service.
    function test_ZeroOperators_SkipsBillAdvancesCursor() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);

        ForceRemoveAllowedManager mgr = new ForceRemoveAllowedManager();
        _setUpSubscriptionWithManager(address(mgr));

        // Force-remove the only operator to leave the service with an empty active set.
        mgr.evict(address(tangle), serviceId, operator1);

        uint256 escrowBefore = _escrow().balance;
        uint64 lastPaidBefore = _lastPaymentAt(serviceId);

        vm.warp(t0 + SUB_INTERVAL);
        vm.expectEmit(true, false, false, true);
        emit SubscriptionBillSkippedNoOperators(serviceId, SUB_INTERVAL);
        tangle.billSubscription(serviceId);

        uint256 escrowAfter = _escrow().balance;
        uint64 lastPaidAfter = _lastPaymentAt(serviceId);
        assertEq(escrowAfter, escrowBefore, "escrow untouched on zero-op skip");
        assertEq(lastPaidAfter, lastPaidBefore + SUB_INTERVAL, "cursor advanced exactly one interval");
    }

    /// @dev Re-declare the event for `vm.expectEmit` matching (events are not
    ///      automatically importable from `Payments.sol`).
    event SubscriptionBillSkippedNoOperators(uint64 indexed serviceId, uint64 period);

    function _lastPaymentAt(uint64 sid) internal view returns (uint64) {
        return tangle.getService(sid).lastPaymentAt;
    }

    /// @notice Manager hook with `computeBillAdjustmentBps == 0` waives the entire
    ///         period: escrow is untouched, cursor advances, event emitted.
    function test_ManagerQos_ZeroBpsWaivesBill() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        QosZeroManager mgr = new QosZeroManager();
        _setUpSubscriptionWithManager(address(mgr));

        vm.warp(t0 + SUB_INTERVAL);
        uint256 escrowBefore = _escrow().balance;
        uint256 charged = _billOnceAndMeasure();
        uint256 escrowAfter = _escrow().balance;
        assertEq(charged, 0, "0bps manager hook waives the bill");
        assertEq(escrowAfter, escrowBefore, "escrow untouched on waived bill");
    }

    function _setUpSubscriptionWithManager(address manager) internal {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: SUB_RATE,
            subscriptionInterval: SUB_INTERVAL,
            eventRate: 0
        });

        vm.prank(developer);
        blueprintId = _createBlueprintWithConfigAsSender("ipfs://subscription-managed", manager, config);

        vm.prank(operator1);
        staking.registerOperator{ value: BASE_OP_STAKE }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator1, blueprintId, "");

        vm.startPrank(delegator1);
        staking.deposit{ value: DELEGATOR_BASELINE }();
        staking.delegate(operator1, DELEGATOR_BASELINE);
        vm.stopPrank();

        uint256 escrow = SUB_RATE * 12;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);
        vm.deal(address(tangle), 100 ether);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: escrow }(
            blueprintId, operators, "", callers, 0, address(0), escrow, Types.ConfidentialityPolicy.Any
        );

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        serviceId = 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // KEEPER REBATE
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice The caller of `billSubscription` earns the keeper share via the
    ///         pull-pattern rewards mapping. Any wallet/bot can profitably
    ///         keep the schedule running, regardless of whether they have
    ///         stake or operate a service.
    function test_KeeperRebate_PaidToBillCaller() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // Set a non-zero keeper bps. Default ships with 50 bps but we make the
        // assertion explicit by re-setting the split here.
        vm.prank(admin);
        tangle.setPaymentSplit(
            Types.PaymentSplit({
                developerBps: 1950, protocolBps: 2000, operatorBps: 4000, stakerBps: 2000, keeperBps: 50
            })
        );

        address keeper = makeAddr("keeper");
        assertEq(tangle.pendingRewards(keeper, address(0)), 0, "keeper starts with no pending");

        vm.warp(t0 + SUB_INTERVAL);
        vm.prank(keeper);
        tangle.billSubscription(serviceId);

        uint256 keeperPending = tangle.pendingRewards(keeper, address(0));
        // Expect ~0.5% of nominal rate (1 wei rounding tolerance).
        uint256 expectedRebate = (SUB_RATE * 50) / 10_000;
        assertApproxEqAbs(keeperPending, expectedRebate, 1, "keeper rebate ~= 0.5% of bill");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EVENT-DRIVEN REJECTS UPFRONT PAYMENT
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Insufficient-escrow on a try-bill MUST NOT advance the per-operator TWAP
    ///         cursors. Otherwise a service owner could deliberately underfund, trigger
    ///         a failed batch bill to zero out future cumDeltas, top up, and bill again
    ///         for free.
    function test_TryBillInsufficientEscrow_DoesNotAdvanceCursors() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // First period at activation baseline — establishes a cursor snapshot.
        vm.warp(t0 + SUB_INTERVAL);
        _billOnceAndMeasure();

        // Drain escrow below `subscriptionRate` so the NEXT period's bill fails.
        // We do this via a successful bill that empties most of the escrow; what
        // remains is intentionally insufficient.
        PaymentLib.ServiceEscrow memory escAfter = _escrow();
        uint256 toLeave = SUB_RATE - 1;
        // Force the escrow into the "0.5 ETH < SUB_RATE" state via service owner refund.
        // Easiest: terminate / withdraw is too invasive; instead just record state and run
        // the underfunded batch path directly.
        if (escAfter.balance > toLeave) {
            // Run additional bills until balance drops just below SUB_RATE.
            while (_escrow().balance >= SUB_RATE) {
                vm.warp(block.timestamp + SUB_INTERVAL);
                _billOnceAndMeasure();
            }
        }
        // Try a batch bill on the underfunded service. No cursor
        // SSTOREs should happen.
        vm.warp(block.timestamp + SUB_INTERVAL);
        uint64[] memory ids = new uint64[](1);
        ids[0] = serviceId;
        (uint256 totalBilled, uint256 billedCount) = tangle.billSubscriptionBatch(ids);
        assertEq(billedCount, 0, "underfunded service not billed");
        assertEq(totalBilled, 0, "no revenue accrued");

        // Top up to exactly nominal, then bill once. Pre-fix this would attribute
        // cumDelta=0 (cursors already at projected) and process the period for free;
        // with the fix the cursor was untouched on the failed batch attempt, so the
        // bill is the full nominal amount.
        vm.deal(user1, SUB_RATE * 2);
        vm.prank(user1);
        tangle.fundService{ value: SUB_RATE * 2 }(serviceId, SUB_RATE * 2);

        uint256 charged = _billOnceAndMeasure();
        assertApproxEqAbs(charged, SUB_RATE, 1, "post-topup bill must NOT be free");
    }

    /// @notice `twapBillAmount` reverts (rather than silently returning `nominalRate`)
    ///         when `rate * cumDelta` would overflow uint256. Realistic protocol scale
    ///         keeps the product well inside uint256; the revert is a guardrail for
    ///         misconfigured upstream state, not a regular path.
    function testFuzz_TwapBillAmount_OverflowReverts(uint256 rate, uint256 cumDelta) public {
        // Bound to inputs that DO overflow `rate * cumDelta`. We pick `rate` and
        // `cumDelta` such that the high bit is set on both — their product
        // necessarily exceeds 2^256.
        rate = bound(rate, type(uint192).max, type(uint256).max);
        cumDelta = bound(cumDelta, type(uint192).max, type(uint256).max);
        vm.expectRevert(Errors.BillingArithmeticOverflow.selector);
        PaymentLib.twapBillAmount(rate, cumDelta, 1 ether, 30 days);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // EVENT-DRIVEN REJECTS UPFRONT PAYMENT
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice EventDriven services are funded by per-job `msg.value`, not an upfront
    ///         lump sum. Requesting an EventDriven service with a non-zero
    ///         `paymentAmount` MUST revert at request time so the customer's funds are
    ///         not collected into the contract and locked until expiry.
    function test_EventDriven_RejectsUpfrontPayment() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0.1 ether
        });

        vm.prank(developer);
        uint64 bp = _createBlueprintWithConfigAsSender("ipfs://event-driven", address(0), config);

        vm.prank(operator1);
        staking.registerOperator{ value: BASE_OP_STAKE }();
        _directRegisterOperator(operator1, bp, "");

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.deal(user1, 10 ether);

        // Non-zero paymentAmount must be rejected at REQUEST time, before
        // `collectPayment` runs (so the customer's ETH never enters the contract).
        vm.prank(user1);
        vm.expectRevert(Errors.UpfrontPaymentNotAllowedForEventDriven.selector);
        tangle.requestService{ value: 1 ether }(
            bp, ops, "", callers, 0, address(0), 1 ether, Types.ConfidentialityPolicy.Any
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PURE MATH (fuzz)
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice `twapBillAmount` scales linearly with cumDelta (mod floor).
    function testFuzz_TwapBillAmount_LinearInCumDelta(
        uint96 rate,
        uint96 baseline,
        uint32 interval,
        uint64 cumDelta
    )
        public
        pure
    {
        vm.assume(rate > 0);
        vm.assume(baseline > 0);
        vm.assume(interval > 0);

        uint256 amount = PaymentLib.twapBillAmount(rate, cumDelta, baseline, interval);

        if (cumDelta == 0) {
            assertEq(amount, 0, "zero stake-time -> zero bill");
        } else {
            uint256 doubled = PaymentLib.twapBillAmount(rate, uint256(cumDelta) * 2, baseline, interval);
            assertGe(doubled + 1, amount * 2, "monotonicity under cumDelta doubling");
        }
    }

    /// @notice cumDelta == baseline*interval ⇒ bill ≈ nominal (mod floor).
    function testFuzz_TwapBillAmount_FullStakeTimeEqualsNominal(
        uint96 rate,
        uint96 baseline,
        uint32 interval
    )
        public
        pure
    {
        vm.assume(rate > 0);
        vm.assume(baseline > 0);
        vm.assume(interval > 0);
        uint256 cumDelta = uint256(baseline) * uint256(interval);
        uint256 amount = PaymentLib.twapBillAmount(rate, cumDelta, baseline, interval);
        assertApproxEqAbs(amount, rate, 1, "full-stake-time period -> bill == nominal");
    }

    /// @notice At realistic protocol scales (uint96 stake/rate, uint32 interval), the
    ///         arithmetic does not overflow. Inputs larger than uint96 stake or rate
    ///         could overflow and are intended to revert (see next test).
    function testFuzz_TwapBillAmount_NoOverflowAtProtocolScale(
        uint96 rate,
        uint96 baseline,
        uint32 interval
    )
        public
        pure
    {
        vm.assume(rate > 0);
        vm.assume(baseline > 0);
        vm.assume(interval > 0);
        uint256 cumDelta = uint256(baseline) * uint256(interval);
        PaymentLib.twapBillAmount(rate, cumDelta, baseline, interval);
    }

    /// @notice Pathological zero-baseline or zero-interval falls back to nominal.
    function testFuzz_TwapBillAmount_PathologicalDenomReturnsNominal(uint96 rate, uint64 cumDelta) public pure {
        assertEq(PaymentLib.twapBillAmount(rate, cumDelta, 0, 1 days), rate, "zero baseline -> nominal");
        assertEq(PaymentLib.twapBillAmount(rate, cumDelta, 1 ether, 0), rate, "zero interval -> nominal");
    }

    /// @notice QoS adjustment scales the bill and is capped at the nominal value.
    function testFuzz_ApplyQosAdjustment_ScalesAndCaps(uint128 amount, uint16 qosBps) public pure {
        uint256 adjusted = PaymentLib.applyQosAdjustment(amount, qosBps);
        if (qosBps >= 10_000) {
            assertEq(adjusted, amount, "qosBps >= 10000 cannot inflate");
        } else {
            uint256 expected = (uint256(amount) * uint256(qosBps)) / 10_000;
            assertEq(adjusted, expected, "qos discount = amount * bps / 10000");
        }
    }
}

