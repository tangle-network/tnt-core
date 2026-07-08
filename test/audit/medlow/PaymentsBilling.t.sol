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
        assertApproxEqAbs(chargedAfterEnable, SUB_RATE, 1, "bill after oracle enable stays at nominal (no scale flip)");
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

    // ─────────────────────────────────────────────────────────────────────────
    // LOW FINDING: joiner on an already-USD-pinned subscription during an admin
    //              oracle-off window must NOT be billed at zero (fail-closed
    //              branch would strip their pay). Fix: `_finalizeJoin` seeds the
    //              identity sentinel (1 ether) for the joiner IFF the service is
    //              already USD-pinned, routing their leg through the identity
    //              branch instead of the zero branch.
    // ─────────────────────────────────────────────────────────────────────────

    uint16 internal constant JOIN_EXPOSURE = 5000; // 50%

    /// @dev Dynamic-membership subscription seeded with a single USD-snapshotted operator
    ///      (operator1) plus two registered-but-not-yet-joined operators (operator2,
    ///      operator3). Mirrors `_setUpSubscriptionWithOracle` but uses Dynamic membership
    ///      so operators can join mid-subscription, and registers all three operators on
    ///      the blueprint up front so the later `joinService` calls pass registration.
    function _setUpDynamicSubscription(address oracle) internal {
        if (oracle != address(0)) {
            vm.prank(admin);
            tangle.setPriceOracle(oracle);
        }

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 5,
            subscriptionRate: SUB_RATE,
            subscriptionInterval: SUB_INTERVAL,
            eventRate: 0
        });

        vm.prank(developer);
        blueprintId = _createBlueprintWithConfigAsSender("ipfs://sub-dynamic", address(0), config);

        // Register operator1 (activates the service) plus operator2/operator3 (join later).
        address[3] memory ops = [operator1, operator2, operator3];
        for (uint256 i = 0; i < ops.length; ++i) {
            vm.prank(ops[i]);
            staking.registerOperator{ value: BASE_OP_STAKE }();
            vm.prank(ops[i]);
            staking.setDelegationMode(Types.DelegationMode.Open);
            _directRegisterOperator(ops[i], blueprintId, "");
        }

        // Give the joiners some delegated stake so their post-join stake-seconds accrue a
        // non-zero raw delta by bill time (otherwise their weight would be zero regardless
        // of the snapshot, and the test could not distinguish "zeroed by fail-closed" from
        // "zeroed by no stake").
        vm.startPrank(delegator1);
        staking.deposit{ value: DELEGATOR_BASELINE }();
        staking.delegate(operator1, DELEGATOR_BASELINE);
        vm.stopPrank();
        vm.startPrank(delegator2);
        staking.deposit{ value: DELEGATOR_BASELINE * 2 }();
        staking.delegate(operator2, DELEGATOR_BASELINE);
        staking.delegate(operator3, DELEGATOR_BASELINE);
        vm.stopPrank();

        uint256 escrow = SUB_RATE * 24;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 10_000; // 100%
        address[] memory callers = new address[](0);
        vm.deal(address(tangle), 400 ether);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: escrow }(
            blueprintId, operators, exposures, "", callers, 0, address(0), escrow, Types.ConfidentialityPolicy.Any
        );

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        serviceId = tangle.serviceCount() - 1;
        assertTrue(tangle.isServiceActive(serviceId), "service active");
    }

    /// @notice An operator joining an ALREADY-USD-pinned subscription while the oracle is
    ///         OFF must still be billed (their leg routes through the identity branch, not
    ///         the fail-closed zero branch). This is the LOW-finding regression.
    /// @dev Setup: activate with operator1 while the oracle is ON, so the service is
    ///      USD-pinned (operator1 carries a non-zero activation snapshot). Then admin
    ///      disables the oracle. operator2 joins (index 1 of 3 — NOT the last-index
    ///      remainder recipient, so a zeroed weight is directly observable as a zero
    ///      reward share). After a bill, operator2's pending reward MUST be non-zero.
    ///      Pre-fix, `_snapshotJoinPrice` early-returned on the zero oracle, leaving
    ///      operator2 with no snapshot; the bill-time fail-closed branch then forced
    ///      operator2's contribution to 0 and stripped their entire share.
    function test_JoinDuringOracleOff_OnPinnedService_IsBilledAtIdentityScale() public {
        uint256 t0 = 4_000_000;
        vm.warp(t0);

        FlatUsdOracle oracle = new FlatUsdOracle(ORACLE_PRICE_USD);
        _setUpDynamicSubscription(address(oracle));

        // Service is USD-pinned: bill once with the oracle on to establish the nominal.
        vm.warp(t0 + SUB_INTERVAL);
        assertApproxEqAbs(_billOnceAndMeasure(), SUB_RATE, 1, "activation bill (oracle on) == nominal");

        // Admin disables the oracle mid-subscription.
        vm.prank(admin);
        tangle.setPriceOracle(address(0));
        assertEq(tangle.priceOracle(), address(0), "oracle disabled");

        // operator2 joins while the oracle is off. Because the service is already
        // USD-pinned, `_finalizeJoin` must seed operator2's identity sentinel.
        vm.prank(operator2);
        tangle.joinService(serviceId, JOIN_EXPOSURE);
        // operator3 joins last so operator2 is a non-last index (operator3 absorbs the
        // per-bill rounding remainder in `_payOperatorPoolByWeight`, which would otherwise
        // mask a zeroed weight on the last operator).
        vm.prank(operator3);
        tangle.joinService(serviceId, JOIN_EXPOSURE);

        // Bill a full period after the joins so operator2 accrues raw stake-seconds.
        uint256 op2Before = tangle.pendingRewards(operator2);
        vm.warp(block.timestamp + SUB_INTERVAL);
        tangle.billSubscription(serviceId);
        uint256 op2After = tangle.pendingRewards(operator2);

        assertGt(
            op2After - op2Before,
            0,
            "joiner on a USD-pinned service during oracle-off must be billed (identity scale), not zeroed"
        );
    }

    /// @notice Fail-closed lock-in: on a genuinely oracle-off, NON-USD service a leg with
    ///         no snapshot and no live oracle still contributes zero at bill time. This
    ///         asserts the intended #204 behavior so a future change cannot silently
    ///         reintroduce identity-scaling (which under-bills the customer). Here the
    ///         WHOLE service is raw-scale, so `_subscriptionPinnedInUsd` is false and the
    ///         joiner must NOT be seeded — the invariant (a non-USD service never gains a
    ///         snapshot from a join) is covered by the assertion below.
    /// @dev Enabling an oracle AFTER a join on a raw-scale service must not flip the bill
    ///      scale. If `_finalizeJoin` had wrongly seeded the joiner's snapshot, the
    ///      `_subscriptionPinnedInUsd` witness would flip to true and the subsequent
    ///      oracle-on bill would scale the numerator by ~2000x against a raw denominator —
    ///      corrupting the bill. A stable nominal bill proves the witness stayed false.
    function test_JoinOnNonUsdService_DoesNotSeedSnapshot_NorFlipScale() public {
        uint256 t0 = 5_000_000;
        vm.warp(t0);

        _setUpDynamicSubscription(address(0)); // raw-scale baseline, no oracle ever configured

        // Raw-scale first bill establishes the nominal.
        vm.warp(t0 + SUB_INTERVAL);
        assertApproxEqAbs(_billOnceAndMeasure(), SUB_RATE, 1, "raw-scale activation bill == nominal");

        // operator2 joins while there is NO oracle and the service is NOT USD-pinned. The
        // joiner must NOT receive a seeded snapshot (that would corrupt the pinned witness).
        vm.prank(operator2);
        tangle.joinService(serviceId, JOIN_EXPOSURE);
        vm.prank(operator3);
        tangle.joinService(serviceId, JOIN_EXPOSURE);

        // A bill while still raw-scale stays nominal (joiner participates at raw scale).
        vm.warp(block.timestamp + SUB_INTERVAL);
        assertApproxEqAbs(_billOnceAndMeasure(), SUB_RATE, 1, "raw-scale bill after non-USD join stays at nominal");

        // Now enable an oracle. If the join had corrupted the witness to USD, the numerator
        // would flip ~2000x against the raw denominator. It must stay raw → nominal.
        FlatUsdOracle oracle = new FlatUsdOracle(ORACLE_PRICE_USD);
        vm.prank(admin);
        tangle.setPriceOracle(address(oracle));

        vm.warp(block.timestamp + SUB_INTERVAL);
        assertApproxEqAbs(
            _billOnceAndMeasure(),
            SUB_RATE,
            1,
            "enabling an oracle after a non-USD join must not flip the bill scale (witness stayed raw)"
        );
    }

    /// @dev `_baselinePriceByOpAsset` is a private triple-nested mapping
    ///      (uint64 svc => address op => bytes32 assetHash => uint256), so its base slot is not
    ///      exposed and shifts whenever storage is reordered. Rather than hardcode it (brittle),
    ///      LOCATE it: scan candidate base slots and return the (svc,op,assetHash) entry that
    ///      currently holds op's non-zero activation snapshot. Robust to any storage reorder; if
    ///      the wrong slot were ever returned, wiping it would not zero the snapshot and the
    ///      caller's terminal `charged == 0` assertion would fail loudly.
    function _findBaselinePriceSlot(uint64 svcId, address op, bytes32 assetHash) internal view returns (bytes32) {
        for (uint256 base = 0; base < 512; base++) {
            bytes32 s1 = keccak256(abi.encode(uint256(svcId), base));
            bytes32 s2 = keccak256(abi.encode(op, s1));
            bytes32 slot = keccak256(abi.encode(assetHash, s2));
            if (uint256(vm.load(address(tangle), slot)) != 0) return slot;
        }
        revert("baseline price slot not found in [0,512) - storage layout changed");
    }

    /// @notice Direct fail-closed assertion: a USD-pinned subscription whose oracle is off
    ///         and whose leg has NO price snapshot contributes ZERO for that leg — the bill
    ///         collapses toward zero rather than silently scaling at 1x. Locks in the
    ///         intended #204 fail-closed behavior so a future change cannot revert it to
    ///         identity-scaling (which would under-bill the customer indefinitely).
    /// @dev The join-seed fix makes this state unreachable through any public path, so we
    ///      construct it directly: activate USD-pinned with the oracle on (operator1 gets a
    ///      snapshot), disable the oracle, then `vm.store`-zero operator1's snapshot. The
    ///      service stays USD-pinned only if some snapshot remains — so we keep the witness
    ///      alive by leaving the `subscriptionBaselineStake` (USD-scale denominator) intact
    ///      and confirm the now-snapshot-less leg drops to ~0. A guard assert first proves
    ///      the storage slot is correct (reads the known non-zero snapshot) so a slot drift
    ///      cannot produce a false green.
    function test_FailClosed_UsdPinnedLegWithoutSnapshot_ContributesZero() public {
        uint256 t0 = 6_000_000;
        vm.warp(t0);

        FlatUsdOracle oracle = new FlatUsdOracle(ORACLE_PRICE_USD);
        _setUpSubscriptionWithOracle(address(oracle)); // single-operator (operator1), USD-pinned

        // First bill (oracle on) establishes the USD-scale nominal.
        vm.warp(t0 + SUB_INTERVAL);
        assertApproxEqAbs(_billOnceAndMeasure(), SUB_RATE, 1, "activation bill (oracle on) == nominal");

        // operator1's bond-asset snapshot: bond asset is native here (no TNT set in tests).
        bytes32 assetHash = keccak256(abi.encode(Types.AssetKind.Native, address(0)));
        // Locate operator1's activation snapshot slot dynamically (survives storage reorders).
        bytes32 slot = _findBaselinePriceSlot(serviceId, operator1, assetHash);
        assertGt(uint256(vm.load(address(tangle), slot)), 0, "located slot holds operator1's non-zero snapshot");

        // Disable the oracle (service stays USD-pinned via the surviving denominator) and
        // wipe operator1's snapshot to reconstruct the fail-closed condition: USD-pinned,
        // no live oracle, no per-pair snapshot.
        vm.prank(admin);
        tangle.setPriceOracle(address(0));
        vm.store(address(tangle), slot, bytes32(uint256(0)));
        assertEq(uint256(vm.load(address(tangle), slot)), 0, "operator1 snapshot wiped");

        // The now-snapshot-less leg on a USD-pinned/oracle-off service must contribute zero,
        // collapsing the bill (the whole point of #204's fail-closed branch).
        vm.warp(block.timestamp + SUB_INTERVAL);
        uint256 charged = _billOnceAndMeasure();
        assertEq(charged, 0, "fail-closed: USD-pinned leg with no snapshot and no oracle contributes zero");
    }
}
