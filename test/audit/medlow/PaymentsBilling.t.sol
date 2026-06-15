// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { PaymentLib } from "../../../src/libraries/PaymentLib.sol";
import { IPriceOracle } from "../../../src/oracles/interfaces/IPriceOracle.sol";

/// @dev Minimal price oracle that reports a flat USD price for every token.
///      `toUSD(token, amount) = amount * priceUsd / 1e18`, so a `priceUsd` far from
///      1e18 makes the USD scale and the raw token-second scale diverge by orders of
///      magnitude — exactly the condition that exposes a scale-mismatch bug in the
///      subscription bill formula `rate * cumDelta / (baseline * interval)`.
contract FlatUsdOracle is IPriceOracle {
    uint256 public priceUsd; // USD (18dp) per 1e18 units of any token

    constructor(uint256 priceUsd_) {
        priceUsd = priceUsd_;
    }

    function toUSD(address, uint256 amount) external view returns (uint256) {
        return (amount * priceUsd) / 1 ether;
    }

    function fromUSD(address, uint256 usdValue) external view returns (uint256) {
        return (usdValue * 1 ether) / priceUsd;
    }

    function getPrice(address) external view returns (uint256) {
        return priceUsd;
    }

    function getPriceData(address) external view returns (PriceData memory data) {
        data = PriceData({ price: priceUsd, updatedAt: block.timestamp, decimals: 18, isValid: true });
    }

    function isTokenSupported(address) external pure returns (bool) {
        return true;
    }

    function batchToUSD(address[] calldata, uint256[] calldata amounts) external view returns (uint256 total) {
        for (uint256 i = 0; i < amounts.length; ++i) {
            total += (amounts[i] * priceUsd) / 1 ether;
        }
    }

    function maxPriceAge() external pure returns (uint256) {
        return type(uint256).max;
    }

    function oracleName() external pure returns (string memory) {
        return "FlatUsdOracle";
    }
}

/// @title PaymentsBillingMedLowTest
/// @notice Regression coverage for the MEDIUM audit finding:
///         "Oracle enable/disable mid-subscription corrupts TWAP bill scale ->
///          indefinite under-billing."
///
///         Root cause: `_accrueOperatorWeights` derived its USD-vs-raw billing scale
///         from the LIVE `_priceOracle` at every bill, while the bill denominator
///         (`subscriptionBaselineStake`) is pinned ONCE at activation. Toggling the
///         oracle mid-subscription flipped the numerator's scale out from under a
///         denominator that never changes, collapsing every subsequent bill toward
///         zero (oracle removed) or distorting it (oracle added).
///
///         Fix: the bill scale is recovered from durable per-(op,asset) activation-time
///         price snapshots (`_baselinePriceByOpAsset`), which are written iff an oracle
///         was configured when the service was activated and are never deleted. The
///         scale is therefore immutable for the life of the service regardless of
///         `setPriceOracle` calls. These tests assert the secure invariant: the bill
///         amount is stable across an oracle toggle.
contract PaymentsBillingMedLowTest is BaseTest {
    uint256 internal constant SUB_RATE = 1 ether;
    uint64 internal constant SUB_INTERVAL = 30 days;

    uint256 internal constant BASE_OP_STAKE = 5 ether;
    uint256 internal constant DELEGATOR_BASELINE = 10 ether;

    // Far from 1e18 so USD scale and raw token-second scale differ by ~2000x: a
    // scale flip would shrink (or grow) the bill by that factor, not by rounding.
    uint256 internal constant ORACLE_PRICE_USD = 2000 ether;

    uint64 internal blueprintId;
    uint64 internal serviceId;

    function _setUpSubscriptionWithOracle(address oracle) internal {
        if (oracle != address(0)) {
            vm.prank(admin);
            tangle.setPriceOracle(oracle);
        }

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
        blueprintId = _createBlueprintWithConfigAsSender("ipfs://sub-oracle", address(0), config);

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

        serviceId = tangle.serviceCount() - 1;
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
    // PRIMARY REGRESSION: oracle DISABLED mid-subscription must not collapse bills
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Activate with the oracle ON (USD-scale baseline), then `setPriceOracle(0)`
    ///         mid-subscription. The next bill MUST still charge the nominal rate.
    /// @dev Pre-fix, `_accrueOperatorWeights` recomputed `useOracle = _priceOracle != 0`
    ///      live, so after disabling the oracle the numerator dropped to raw token-seconds
    ///      while the denominator stayed USD-scaled — the bill collapsed to ~0 (the
    ///      ~2000x scale gap here). This test fails if the fix is reverted.
    function test_OracleDisabledMidSubscription_DoesNotCollapseBill() public {
        uint256 t0 = 1_000_000;
        vm.warp(t0);

        FlatUsdOracle oracle = new FlatUsdOracle(ORACLE_PRICE_USD);
        _setUpSubscriptionWithOracle(address(oracle));

        // Sanity: baseline was pinned in USD scale at activation.
        assertGt(_escrow().subscriptionBaselineStake, 0, "baseline pinned at activation");

        // First bill while the oracle is still configured — establishes the nominal.
        vm.warp(t0 + SUB_INTERVAL);
        uint256 chargedWithOracle = _billOnceAndMeasure();
        assertApproxEqAbs(chargedWithOracle, SUB_RATE, 1, "first bill (oracle on) == nominal");

        // Admin disables the oracle mid-subscription.
        vm.prank(admin);
        tangle.setPriceOracle(address(0));
        assertEq(tangle.priceOracle(), address(0), "oracle disabled");

        // Second bill, oracle now off. Scale must be recovered from the activation
        // snapshot, so the bill stays at nominal rather than collapsing.
        vm.warp(block.timestamp + SUB_INTERVAL);
        uint256 chargedAfterDisable = _billOnceAndMeasure();

        assertApproxEqAbs(
            chargedAfterDisable, SUB_RATE, 1, "bill after oracle disable stays at nominal (no scale collapse)"
        );
        // Hard guard against the collapse: a reverted fix bills ~SUB_RATE/2000, i.e.
        // < 1% of nominal. Assert the bill is at least half the nominal rate.
        assertGe(chargedAfterDisable, SUB_RATE / 2, "bill after oracle disable not collapsed toward zero");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // SYMMETRIC CASE: oracle ENABLED mid-subscription on a raw-scale baseline
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice Activate with NO oracle (raw token-second baseline), then enable an
    ///         oracle mid-subscription. The bill MUST stay at nominal — the numerator
    ///         must not flip to USD scale against a raw-scale denominator.
    /// @dev Pre-fix this flipped `useOracle` to true, multiplying the numerator by the
    ///      USD price (~2000x). The customer would be over-scaled; the nominal cap
    ///      hides the over-charge but the underlying scale mismatch is the same bug.
    ///      The fix keeps the service in raw scale (no activation snapshot was written),
    ///      so the bill is the clean nominal rate.
    function test_OracleEnabledMidSubscription_DoesNotFlipScale() public {
        uint256 t0 = 2_000_000;
        vm.warp(t0);

        _setUpSubscriptionWithOracle(address(0)); // raw-scale baseline

        // No activation-time price snapshot for the seeded operator/asset.
        assertGt(_escrow().subscriptionBaselineStake, 0, "raw baseline pinned at activation");

        vm.warp(t0 + SUB_INTERVAL);
        uint256 chargedRaw = _billOnceAndMeasure();
        assertApproxEqAbs(chargedRaw, SUB_RATE, 1, "first bill (no oracle) == nominal");

        // Admin enables an oracle mid-subscription.
        FlatUsdOracle oracle = new FlatUsdOracle(ORACLE_PRICE_USD);
        vm.prank(admin);
        tangle.setPriceOracle(address(oracle));

        vm.warp(block.timestamp + SUB_INTERVAL);
        uint256 chargedAfterEnable = _billOnceAndMeasure();

        // Scale stays raw (matching the raw baseline): clean nominal, no flip.
        assertApproxEqAbs(
            chargedAfterEnable, SUB_RATE, 1, "bill after oracle enable stays at nominal (no scale flip)"
        );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CONTROL: stable mode (oracle on the whole time) bills nominal across periods
    // ─────────────────────────────────────────────────────────────────────────

    /// @notice With the oracle configured for the entire lifetime (no toggle), bills
    ///         are stable at nominal — confirms the fix does not regress the happy path.
    function test_OracleStable_BillsNominalAcrossPeriods() public {
        uint256 t0 = 3_000_000;
        vm.warp(t0);

        FlatUsdOracle oracle = new FlatUsdOracle(ORACLE_PRICE_USD);
        _setUpSubscriptionWithOracle(address(oracle));

        vm.warp(t0 + SUB_INTERVAL);
        assertApproxEqAbs(_billOnceAndMeasure(), SUB_RATE, 1, "period 1 == nominal");

        vm.warp(block.timestamp + SUB_INTERVAL);
        assertApproxEqAbs(_billOnceAndMeasure(), SUB_RATE, 1, "period 2 == nominal");

        vm.warp(block.timestamp + SUB_INTERVAL);
        assertApproxEqAbs(_billOnceAndMeasure(), SUB_RATE, 1, "period 3 == nominal");
    }
}
