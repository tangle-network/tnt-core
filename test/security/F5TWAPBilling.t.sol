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

        // After lazy-init, escrow.subscriptionBaselineStake and lastBilledCumStake
        // are populated; subsequent bills are TWAP-correct against that baseline.
        PaymentLib.ServiceEscrow memory esc = _escrow();
        assertGt(esc.subscriptionBaselineStake, 0, "baseline seeded");
        assertGt(esc.lastBilledCumStake, 0, "cum cursor seeded");

        // Advance one more interval at constant stake → TWAP ratio == 1 → bill == nominal.
        vm.warp(block.timestamp + SUB_INTERVAL);
        uint256 charged2 = _billOnceAndMeasure();
        assertApproxEqAbs(charged2, SUB_RATE, 1, "post-init constant-stake bill == nominal");
    }
}
