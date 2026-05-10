// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";

/// @title F5TWAPBillingTest
/// @notice Round 4 audit fix F5: subscription billing must price the period by
///         the time-weighted average stake, not the stake at the bill instant.
///         These tests cover the four behavioral guarantees called out in the
///         audit + the lazy-init path for pre-upgrade subscriptions.
contract F5TWAPBillingTest is BaseTest {
    uint256 internal constant SUB_RATE = 1 ether;
    uint64 internal constant SUB_INTERVAL = 30 days;

    uint256 internal constant BASE_OP_STAKE = 5 ether;
    uint256 internal constant DELEGATOR_BASELINE = 10 ether;

    uint64 internal blueprintId;
    uint64 internal serviceId;
    address internal slasher = makeAddr("f5_slasher");

    function setUp() public override {
        super.setUp();
        // Authorize a dedicated slasher EOA so the slash test can call staking.slash
        // directly instead of going through Tangle's full proposal/execute flow.
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
        blueprintId = _createBlueprintWithConfigAsSender("ipfs://f5-subscription", address(0), config);

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

        uint256 escrow = SUB_RATE * 12; // plenty for any TWAP scaling
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
        assertTrue(tangle.isServiceActive(serviceId), "service active");
    }

    function _escrow() internal view returns (PaymentLib.ServiceEscrow memory) {
        return tangle.getServiceEscrow(serviceId);
    }

    /// @dev Compute the bill amount the protocol charged in the most recent call by
    ///      taking `totalReleased(after) − totalReleased(before)`.
    function _billOnceAndMeasure() internal returns (uint256 charged) {
        uint256 releasedBefore = _escrow().totalReleased;
        tangle.billSubscription(serviceId);
        charged = _escrow().totalReleased - releasedBefore;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Tests
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Regression: constant stake throughout the period bills exactly subscriptionRate.
    function test_F5_ConstantStake_BillsNominalRate() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // Bill #1 (lazy-init period): bills nominal rate.
        vm.warp(t0 + SUB_INTERVAL);
        uint256 charged1 = _billOnceAndMeasure();
        assertEq(charged1, SUB_RATE, "first bill is nominal (lazy-init)");

        // Bill #2: stake is constant — TWAP ratio == 1, bill stays nominal.
        vm.warp(t0 + 2 * SUB_INTERVAL);
        uint256 charged2 = _billOnceAndMeasure();
        assertApproxEqAbs(charged2, SUB_RATE, 1, "constant-stake TWAP equals nominal");
    }

    /// @notice Doubling stake mid-period bills ~1.5× nominal.
    /// @dev Operator (delegator2) doubles total stake half-way through the second
    ///      window — TWAP avg over the window is 1.5× the start stake.
    function test_F5_DoubledMidPeriod_BillsOneAndAHalf() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // Lazy-init bill at the start of period 1 → period 2.
        vm.warp(t0 + SUB_INTERVAL);
        _billOnceAndMeasure();

        // Halfway through window [t0 + 1*INT, t0 + 2*INT], double the operator's stake
        // by adding an equal-sized delegation. Pre-double aggregate = BASE + DELEGATOR;
        // post-double = 2 × pre-double.
        vm.warp(t0 + SUB_INTERVAL + SUB_INTERVAL / 2);
        uint256 doubleAmount = BASE_OP_STAKE + DELEGATOR_BASELINE;
        vm.deal(delegator2, doubleAmount + 1 ether);
        vm.startPrank(delegator2);
        staking.deposit{ value: doubleAmount }();
        staking.delegate(operator1, doubleAmount);
        vm.stopPrank();

        // End of period 2: avg-stake = 1.5 × baseline → bill ≈ 1.5 × SUB_RATE.
        vm.warp(t0 + 2 * SUB_INTERVAL);
        uint256 charged = _billOnceAndMeasure();

        // 1.5x with small slack for integer division and the lazy-init seeding moment.
        uint256 lower = (SUB_RATE * 145) / 100;
        uint256 upper = (SUB_RATE * 155) / 100;
        assertGt(charged, lower, "TWAP doubled-stake bill below 1.45x");
        assertLt(charged, upper, "TWAP doubled-stake bill above 1.55x");
    }

    /// @notice Halving stake mid-period bills ~0.75× nominal.
    /// @dev Uses a 50% slash as the stake-reduction primitive (functionally equivalent to
    ///      undelegate-and-execute for our purposes: it deterministically cuts aggregate
    ///      stake to ~50% at a single timestamp). Distinct from the slash-correctness test
    ///      below in that the *baseline stake* here is at parity with no extra delegators.
    function test_F5_HalvedMidPeriod_BillsThreeQuarters() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // Lazy-init bill at the end of period 1.
        vm.warp(t0 + SUB_INTERVAL);
        _billOnceAndMeasure();

        // Halfway through period 2, halve aggregate stake via a 50% slash. The TWAP
        // average over the window is 0.5 × (1.0 + 0.5) = 0.75 × the baseline.
        vm.warp(t0 + SUB_INTERVAL + SUB_INTERVAL / 2);
        vm.prank(slasher);
        staking.slash(operator1, serviceId, 5000, bytes32(uint256(0xdeed)));

        // End of period 2.
        vm.warp(t0 + 2 * SUB_INTERVAL);
        uint256 charged = _billOnceAndMeasure();

        // ~0.75× nominal. Slack covers rounding from the share-pool exchange-rate
        // arithmetic.
        uint256 lower = (SUB_RATE * 70) / 100;
        uint256 upper = (SUB_RATE * 80) / 100;
        assertGt(charged, lower, "TWAP halved-stake bill below 0.7x");
        assertLt(charged, upper, "TWAP halved-stake bill above 0.8x");
    }

    /// @notice Slashing reduces stake from the slash instant; subsequent billing weights
    ///         only the remaining stake going forward.
    function test_F5_MidPeriodSlash_BillsByPostSlashStake() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // Lazy-init at end of period 1.
        vm.warp(t0 + SUB_INTERVAL);
        _billOnceAndMeasure();

        // Halfway through period 2: slash the operator 50%. Total stake drops to ~50%
        // for the remaining half of the window → avg = 0.75× of pre-slash.
        vm.warp(t0 + SUB_INTERVAL + SUB_INTERVAL / 2);
        vm.prank(slasher);
        staking.slash(operator1, serviceId, 5000, bytes32(uint256(0xb1ade)));

        vm.warp(t0 + 2 * SUB_INTERVAL);
        uint256 charged = _billOnceAndMeasure();

        // ~0.75× nominal: the integral over [start, slash] at 1× plus [slash, end] at 0.5×
        // divided by baseline×interval = 0.75.
        uint256 lower = (SUB_RATE * 70) / 100;
        uint256 upper = (SUB_RATE * 80) / 100;
        assertGt(charged, lower, "post-slash TWAP bill below 0.7x");
        assertLt(charged, upper, "post-slash TWAP bill above 0.8x");
    }

    /// @notice First post-upgrade bill lazy-initializes the cursor and bills the
    ///         standard nominal rate (does not retro-bill any pre-upgrade history).
    function test_F5_LazyInit_FirstPostUpgradeBill_NominalAndForwardOnly() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpSubscription();

        // Simulate "pre-upgrade lifetime" by warping a long way past createdAt
        // BEFORE the first bill. The lazy-init must not retro-charge for that
        // unobservable history — it should bill exactly SUB_RATE for the first
        // window and seed cursors at the live aggregate.
        vm.warp(t0 + SUB_INTERVAL * 5); // 5 intervals of pretend-history

        // First-ever bill: lazy-init path. Seeds cursor and bills nominal.
        uint256 charged1 = _billOnceAndMeasure();
        assertEq(charged1, SUB_RATE, "first post-upgrade bill is nominal");

        // After lazy-init, escrow.subscriptionBaselineStake is populated;
        // per-operator cursors live in `TangleStorage._twapCursorByOp` and are
        // exercised by the constant-stake check below. The struct-level reserved
        // slot is always zero (aggregate cursor was retired in the F5 followup).
        PaymentLib.ServiceEscrow memory esc = _escrow();
        assertGt(esc.subscriptionBaselineStake, 0, "baseline seeded");

        // Advance one more interval at constant stake → TWAP ratio == 1 → bill == nominal.
        vm.warp(block.timestamp + SUB_INTERVAL);
        uint256 charged2 = _billOnceAndMeasure();
        assertApproxEqAbs(charged2, SUB_RATE, 1, "post-init constant-stake bill == nominal");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // OPERATOR-SET CHANGE: mid-life join must not retroactively bill for the
    // joiner's pre-join cum activity. Without the F5 per-operator cursor +
    // join hook in `ServicesLifecycle._finalizeJoin`, a fresh joiner's full
    // historical cum would land in cumDelta and produce a massive over-bill
    // on the following period.
    // ─────────────────────────────────────────────────────────────────────────

    function test_F5_MidPeriodJoiner_NoRetroactiveBill() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);

        // Dynamic-membership service so operator2 can `joinService` mid-life.
        _setUpDynamicSubscription();

        // Bill once (lazy-init) and bill again at constant single-operator stake
        // to confirm baseline is settled before the second operator joins.
        vm.warp(t0 + SUB_INTERVAL);
        uint256 charged1 = _billOnceAndMeasure();
        assertEq(charged1, SUB_RATE, "first bill (lazy-init) is nominal");

        // Register operator2 with substantial stake well BEFORE they join. The
        // staking-side cum-stake counter will accrue for operator2 over the
        // pre-join interval; without the join hook this would leak into the
        // first post-join bill.
        vm.prank(operator2);
        staking.registerOperator{ value: BASE_OP_STAKE * 4 }();
        vm.prank(operator2);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator2, blueprintId, "");

        vm.warp(block.timestamp + SUB_INTERVAL / 2);

        // Joiner enters the service mid-period. The join hook re-seeds
        // `_twapCursorByOp[serviceId][operator2]` at this instant; pre-join
        // cum activity is forgotten by the billing layer.
        vm.prank(operator2);
        tangle.joinService(serviceId, 5000);

        vm.warp(block.timestamp + SUB_INTERVAL);

        // Now bill the next full period. The cumDelta_op for operator2
        // should be (currentStake_op2 × interval), exactly the period's
        // worth — not the much larger value that includes pre-join time.
        // Combined with operator1's interval-worth of stake-seconds, the
        // ratio is `(stake1 + stake2_post_join) / baseline_stake1_only`.
        uint256 charged2 = _billOnceAndMeasure();

        // Sanity floor: the bill MUST charge at least nominal (operator1
        // alone produced nominal at constant stake) and MUST NOT exceed
        // ~5× nominal (the realistic upper bound given op2's stake is 4×
        // op1's). A retroactive bill would explode well past this cap.
        assertGt(charged2, SUB_RATE - 1, "bill must include op1's continuing stake");
        assertLt(charged2, SUB_RATE * 6, "no retroactive bill for op2's pre-join cum");
    }

    function test_F5_OperatorExit_BillUsesRemainingSet() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);
        _setUpDynamicSubscription();

        // Bring operator2 in alongside operator1 so we can test exit semantics
        // without bottoming out below `minOperators` (= 1).
        vm.prank(operator2);
        staking.registerOperator{ value: BASE_OP_STAKE }();
        vm.prank(operator2);
        staking.setDelegationMode(Types.DelegationMode.Open);
        _directRegisterOperator(operator2, blueprintId, "");
        vm.prank(operator2);
        tangle.joinService(serviceId, 5000);

        vm.warp(t0 + SUB_INTERVAL);
        _billOnceAndMeasure(); // lazy-init across BOTH operators

        // Operator2 schedules + executes an exit. The blueprint's exit queue
        // duration (default) gates immediate `leaveService`, so we go through
        // the queue path and advance time past it.
        vm.prank(operator2);
        tangle.scheduleExit(serviceId);
        vm.warp(block.timestamp + 30 days); // > default exitQueueDuration
        vm.prank(operator2);
        tangle.executeExit(serviceId);

        // Bill the next full period after op2's exit.
        vm.warp(block.timestamp + SUB_INTERVAL);
        uint256 charged = _billOnceAndMeasure();

        // operator1 alone produced the lazy-init baseline. After op2 exits,
        // operator1 still contributes one full period of stake-seconds —
        // ratio = stake1 * interval / (stake1+stake2) * interval = stake1 / (stake1+stake2).
        // With equal stakes this is ~0.5x nominal; we assert the bill is
        // strictly less than nominal (proving op2 didn't drag the bill back
        // up) and strictly positive (proving op1 still contributes).
        assertLt(charged, SUB_RATE, "bill drops after op2 exit");
        assertGt(charged, 0, "remaining operator still contributes");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // FUZZ: pure billing math (PaymentLib.twapBillAmount)
    // CLAUDE.md requires fuzz tests for financial logic. The TWAP formula is
    // extracted as a pure function so we can fuzz over the full input space
    // (rate, cumDelta, baseline, interval) without spinning up the staking
    // layer per run.
    // ─────────────────────────────────────────────────────────────────────────

    function testFuzz_F5_BillProportionalToCumDelta(
        uint96 rate,
        uint96 baseline,
        uint32 interval,
        uint64 cumDelta
    )
        public
        pure
    {
        // Reject degenerate inputs the on-chain path also short-circuits on.
        vm.assume(rate > 0);
        vm.assume(baseline > 0);
        vm.assume(interval > 0);

        uint256 amount = PaymentLib.twapBillAmount(rate, cumDelta, baseline, interval);

        // Invariant 1: bill scales linearly with cumDelta (mod floor).
        if (cumDelta == 0) {
            assertEq(amount, 0, "zero stake-time -> zero bill");
        } else {
            // Double cumDelta should roughly double the bill (mod floor).
            uint256 doubled = PaymentLib.twapBillAmount(rate, uint256(cumDelta) * 2, baseline, interval);
            // doubled >= amount * 2 - 1 (floor division can shave 1 wei)
            assertGe(doubled + 1, amount * 2, "monotonicity under cumDelta doubling");
        }
    }

    function testFuzz_F5_BillCanonicalAtFullStakeTime(uint96 rate, uint96 baseline, uint32 interval) public pure {
        vm.assume(rate > 0);
        vm.assume(baseline > 0);
        vm.assume(interval > 0);
        // cumDelta = baseline * interval => time-weighted ratio is 1 => bill == nominal
        uint256 cumDelta = uint256(baseline) * uint256(interval);
        uint256 amount = PaymentLib.twapBillAmount(rate, cumDelta, baseline, interval);
        assertApproxEqAbs(amount, rate, 1, "full-stake-time period -> bill == nominal (mod floor)");
    }

    function testFuzz_F5_NoOverflowOnRealisticInputs(uint128 rate, uint128 baseline, uint32 interval) public pure {
        vm.assume(rate > 0);
        vm.assume(baseline > 0);
        vm.assume(interval > 0);
        // cumDelta at baseline-equivalent ratio. Should never revert at uint128 inputs.
        uint256 cumDelta = uint256(baseline) * uint256(interval);
        PaymentLib.twapBillAmount(rate, cumDelta, baseline, interval);
    }

    function testFuzz_F5_PathologicalDenomReturnsNominal(uint96 rate, uint64 cumDelta) public pure {
        // baseline == 0 OR interval == 0 falls back to nominal (matches on-chain branch).
        assertEq(PaymentLib.twapBillAmount(rate, cumDelta, 0, 1 days), rate, "zero baseline -> nominal");
        assertEq(PaymentLib.twapBillAmount(rate, cumDelta, 1 ether, 0), rate, "zero interval -> nominal");
    }
}
