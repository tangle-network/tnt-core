// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PaymentsCore } from "./PaymentsCore.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IStaking } from "../interfaces/IStaking.sol";
import { ITanglePaymentsInternal } from "../interfaces/ITanglePaymentsInternal.sol";

/// @title PaymentsBilling
/// @notice Subscription billing entry points, TWAP weighting, and baseline initialization.
/// @dev Inherits `PaymentsEffectiveExposure` so the staker-backed predicate
///      (`_calculateEffectiveExposures`) is available for weighting fallbacks.
abstract contract PaymentsBilling is PaymentsCore {
    /// @notice Bill a subscription service
    /// @dev Anyone can call this to trigger billing; no incentive for single billing
    function billSubscription(uint64 serviceId) external whenNotPaused nonReentrant {
        _billSubscriptionInternal(serviceId);
    }

    /// @notice Batch bill multiple subscription services.
    /// @dev Each service is billed independently in a try-bill mode that returns false
    ///      (rather than reverting) for any ineligible service. The caller earns the
    ///      keeper rebate on every successfully drawn bill — incentivising bots to
    ///      sweep the schedule. `totalBilled` reflects the actual amounts drawn (after
    ///      TWAP scaling + QoS adjustment), not the blueprint nominal rate.
    function billSubscriptionBatch(uint64[] calldata serviceIds)
        external
        whenNotPaused
        nonReentrant
        returns (uint256 totalBilled, uint256 billedCount)
    {
        uint256 serviceIdsLength = serviceIds.length;
        if (serviceIdsLength == 0) revert Errors.ZeroAmount();

        for (uint256 i = 0; i < serviceIdsLength;) {
            (bool billed, uint256 amount) = _tryBillSubscriptionMeasured(serviceIds[i]);
            if (billed) {
                totalBilled += amount;
                if (amount > 0) billedCount++;
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Permissionless subscription bill (reverts on failure).
    function _billSubscriptionInternal(uint64 serviceId) internal {
        (bool billed,) = _billSubscriptionImpl(serviceId, true, msg.sender);
        if (!billed) revert Errors.InvalidState(); // unreachable under revertOnFail=true
    }

    /// @notice Try-bill variant that also returns the actual drawn amount so callers
    ///         (notably `billSubscriptionBatch`) can report a true revenue figure.
    function _tryBillSubscriptionMeasured(uint64 serviceId) internal returns (bool, uint256) {
        return _billSubscriptionImpl(serviceId, false, msg.sender);
    }

    /// @notice Core subscription billing implementation, shared between strict and try-bill paths.
    /// @dev One call processes exactly one period of length `interval`, advancing `lastPaymentAt`
    ///      by `interval` (not to `block.timestamp`), so missed periods catch up over repeated calls.
    ///      Behavior:
    ///        1. Pre-checks: service active, subscription pricing, not TTL-expired, period due.
    ///        2. Active-operator snapshot. If empty: advance cursor without billing — escrow
    ///           untouched, customer keeps funds, schedule stays on rails.
    ///        3. Compute per-operator cum-stake-second deltas. Forward-project to `periodEnd`
    ///           on late bills so the next bill picks up cleanly from the period boundary.
    ///        4. Apply manager QoS adjustment (best-effort; clamped to [0, 10_000]).
    ///        5. Release `amount` from escrow.
    ///        6. Distribute by per-operator TWAP weight (cumDelta × exposureBps). Pay keeper
    ///           rebate to the caller from the operator pool's keeper slice.
    /// @param serviceId Service to bill
    /// @param revertOnFail When true, eligibility checks revert; when false, return false silently.
    /// @param keeper Caller of the public bill entry point — receives the keeper rebate.
    /// @return billed True if a bill was drawn (or the period was skipped due to zero operators).
    function _billSubscriptionImpl(
        uint64 serviceId,
        bool revertOnFail,
        address keeper
    )
        internal
        returns (bool billed, uint256 amountDrawn)
    {
        Types.Service storage svc = _services[serviceId];

        // Eligibility checks.
        if (svc.status != Types.ServiceStatus.Active) {
            if (revertOnFail) revert Errors.ServiceNotActive(serviceId);
            return (false, 0);
        }
        if (svc.pricing != Types.PricingModel.Subscription) {
            if (revertOnFail) revert Errors.InvalidState();
            return (false, 0);
        }
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) {
            if (revertOnFail) revert Errors.ServiceExpired(serviceId);
            return (false, 0);
        }

        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[svc.blueprintId];
        uint64 interval = bpConfig.subscriptionInterval;
        uint256 nominalRate = bpConfig.subscriptionRate;
        uint64 periodStart = svc.lastPaymentAt;
        uint64 periodEnd = periodStart + interval;

        if (block.timestamp < periodEnd) {
            if (revertOnFail) revert Errors.DeadlineExpired();
            return (false, 0);
        }

        address[] memory operators = _activeServiceOperators(serviceId);

        // Zero-operator path: advance the cursor and skip the bill so the schedule does
        // not livelock. The customer's escrow is untouched; if operators rejoin, the
        // next bill picks up from `periodEnd` and bills the standard rate.
        if (operators.length == 0) {
            svc.lastPaymentAt = periodEnd;
            emit SubscriptionBillSkippedNoOperators(serviceId, interval);
            return (true, 0);
        }

        // Same weights drive bill amount AND payout split. `_accrueOperatorWeights` is
        // a VIEW that computes projected cursors without writing them; cursors are
        // committed only on a successful bill or period skip, so a failed try-bill
        // does not advance state and cannot be used to consume periods for free.
        BillWeights memory w = _accrueOperatorWeights(serviceId, operators, periodEnd);

        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];

        // Baseline must have been pinned at activation; a zero here means a service was
        // activated via a non-canonical path that skipped baseline seeding. Reverting
        // loudly prevents a stake-ramp attacker from front-running baseline at first bill.
        if (escrow.subscriptionBaselineStake == 0) {
            revert Errors.SubscriptionBaselineNotInitialized(serviceId);
        }
        uint256 amount = PaymentLib.twapBillAmount(
            nominalRate, w.cumDeltaPeriod, escrow.subscriptionBaselineStake, uint256(interval)
        );

        // Bound the bill at the nominal rate: operators ramping stake cannot inflate
        // the customer's bill, but ramping-down still reduces it. Per-op weights stay
        // uncapped so ramping operators earn a larger slice of the same (capped) pool.
        // Cap also keeps `terminateServiceForNonPayment`'s `balance < rate` eligibility
        // consistent with the bill's `balance >= amount` requirement.
        if (amount > nominalRate) amount = nominalRate;

        // Manager QoS hook can discount (never inflate) the bill. Hook failures /
        // out-of-range returns fall back to the cap-resolved amount.
        uint16 qosBps = _resolveBillAdjustmentBps(svc.blueprintId, serviceId, periodStart, periodEnd);
        if (qosBps < BPS_DENOMINATOR) {
            uint256 adjusted = PaymentLib.applyQosAdjustment(amount, qosBps);
            emit SubscriptionBillAdjustedByManager(serviceId, amount, adjusted, qosBps);
            amount = adjusted;
        }

        // Insufficient escrow: do NOT commit cursors and do NOT advance `lastPaymentAt`.
        // The period stays due so `terminateServiceForNonPayment` remains the canonical
        // recovery path and a future top-up + retry processes the same window.
        if (amount > 0 && escrow.balance < amount) {
            if (revertOnFail) revert Errors.InsufficientEscrowBalance(amount, escrow.balance);
            return (false, 0);
        }

        // From here every exit path commits the cursors and advances `lastPaymentAt`.
        // Cursor SSTOREs land BEFORE any external transfer in `_distributeBill` so a
        // reverting transfer never leaves cursors stale.
        _commitOperatorCursors(serviceId, operators, w.projectedByOpAsset);
        svc.lastPaymentAt = periodEnd;

        // Skip-on-dust: a bill that rounds to less than 1 wei per recipient is treated
        // as a zero-cost processed period rather than reverting in `_distributeBill`.
        if (amount > 0 && amount < PaymentLib.minBillAmount(_paymentSplit, operators.length)) {
            emit SubscriptionBilled(serviceId, 0, interval);
            return (true, 0);
        }

        if (amount == 0) {
            emit SubscriptionBilled(serviceId, 0, interval);
            return (true, 0);
        }

        address token = PaymentLib.releaseFromEscrow(escrow, amount);
        ITanglePaymentsInternal(address(this))
            .distributeBillWithKeeper(
                ITanglePaymentsInternal.BillDistribution({
                    serviceId: serviceId,
                    blueprintId: svc.blueprintId,
                    token: token,
                    amount: amount,
                    operators: operators,
                    weights: w.weights,
                    totalWeight: w.totalWeight,
                    hasSecurityCommitments: w.hasSecurityCommitments,
                    keeper: keeper
                })
            );

        emit SubscriptionBilled(serviceId, amount, interval);
        return (true, amount);
    }

    /// @notice Persist the projected TWAP cursors after a bill has passed all guard checks.
    /// @dev Split out from `_accrueOperatorWeights` so a failed try-bill (insufficient escrow)
    ///      cannot advance cursors, which would let a service owner consume the period for
    ///      free on a subsequent retry by zeroing out cumDelta.
    function _commitOperatorCursors(
        uint64 serviceId,
        address[] memory operators,
        uint256[][] memory projectedByOpAsset
    )
        internal
    {
        Types.Asset memory bondAsset = _bondAssetForBilling();
        for (uint256 i = 0; i < operators.length;) {
            address op = operators[i];
            Types.AssetSecurityCommitment[] storage commitments = _serviceSecurityCommitments[serviceId][op];
            uint256[] memory projected = projectedByOpAsset[i];
            uint256 m = commitments.length;
            if (m == 0) {
                // Fallback path: single bond-asset cursor. `projected` was sized to 1 by
                // `_accrueOperatorWeights` to mirror this shape.
                bytes32 assetHash = keccak256(abi.encode(bondAsset.kind, bondAsset.token));
                _twapCursorByOpAsset[serviceId][op][assetHash] = projected[0];
            } else {
                for (uint256 j = 0; j < m;) {
                    bytes32 assetHash = keccak256(abi.encode(commitments[j].asset.kind, commitments[j].asset.token));
                    _twapCursorByOpAsset[serviceId][op][assetHash] = projected[j];
                    unchecked {
                        ++j;
                    }
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Per-bill state computed from per-(operator, asset) stake-seconds.
    /// @dev `projectedByOpAsset[i]` is a jagged inner array indexed by the operator's
    ///      `AssetSecurityCommitment[j]`. Cursors are committed only after the bill passes
    ///      the escrow-balance check so a failed try-bill cannot advance state.
    struct BillWeights {
        uint256 cumDeltaPeriod;
        uint256[] weights; // per-operator (exposure-weighted across assets)
        uint256[][] projectedByOpAsset; // per-(operator, asset_in_commitments)
        uint256 totalWeight;
        bool hasSecurityCommitments;
    }

    function _accrueOperatorWeights(
        uint64 serviceId,
        address[] memory operators,
        uint64 periodEnd
    )
        internal
        returns (BillWeights memory result)
    {
        IStaking staking = _staking;
        address oracleAddr = _priceOracle;
        Types.Asset memory bondAsset = _bondAssetForBilling();

        // Oracle mode is a property of the SERVICE pinned at activation, not of the
        // current `_priceOracle`. The baseline denominator (`subscriptionBaselineStake`)
        // was committed in either USD scale (oracle on at activation) or raw
        // token-second scale (oracle off). The bill numerator (`cumDeltaPeriod`) MUST
        // be computed in that same scale, otherwise the ratio collapses: e.g. a service
        // activated with the oracle on (USD denominator) and then `setPriceOracle(0)`
        // would, under a live `_priceOracle != 0` check, switch the numerator to raw
        // token-seconds — typically orders of magnitude smaller than the USD baseline —
        // driving every bill toward zero and under-drawing escrow indefinitely.
        //
        // We recover the activation-time mode from durable state: `_snapshotBaselinePrice`
        // / `_snapshotJoinPrice` write a non-zero `_baselinePriceByOpAsset` for every
        // seeded (op, asset) IFF an oracle was configured when the cursor was seeded, and
        // return early (leaving the zero sentinel) when it was not. So a non-zero snapshot
        // anywhere on the service's seeded operators is a permanent witness that the
        // baseline was pinned in USD scale, independent of the live oracle address.
        bool useOracle = _subscriptionPinnedInUsd(serviceId, operators, bondAsset);
        uint256 tailSeconds = block.timestamp > periodEnd ? block.timestamp - uint256(periodEnd) : 0;

        uint256 n = operators.length;
        result.weights = new uint256[](n);
        result.projectedByOpAsset = new uint256[][](n);

        for (uint256 i = 0; i < n;) {
            address op = operators[i];
            Types.AssetSecurityCommitment[] storage commitments = _serviceSecurityCommitments[serviceId][op];
            uint256 m = commitments.length;
            uint256 opWeight;
            uint256[] memory projected;
            if (m == 0) {
                // Fallback: no per-asset commitments → treat as a single implicit
                // commitment to the bond asset at the operator's overall
                // `ServiceOperator.exposureBps`. Mirrors `_initSubscriptionBaseline`.
                projected = new uint256[](1);
                bytes32 assetHash = keccak256(abi.encode(bondAsset.kind, bondAsset.token));
                (uint256 cumOp,, uint256 stakeOp) = staking.getCumStakeSeconds(op, bondAsset);
                uint256 projectedCum = _projectToPeriodEnd(cumOp, stakeOp, tailSeconds);
                uint256 cursor = _twapCursorByOpAsset[serviceId][op][assetHash];
                uint256 opDeltaRaw;
                if (cursor != 0 && projectedCum > cursor) {
                    opDeltaRaw = projectedCum - cursor;
                }
                projected[0] = projectedCum;

                uint16 fallbackBps = _serviceOperators[serviceId][op].exposureBps;
                if (fallbackBps == 0) fallbackBps = uint16(BPS_DENOMINATOR);
                uint256 contribution = (opDeltaRaw * uint256(fallbackBps)) / BPS_DENOMINATOR;
                if (useOracle && contribution > 0) {
                    uint256 snapshot = _baselinePriceByOpAsset[serviceId][op][assetHash];
                    if (snapshot != 0) {
                        // Activation-time price snapshot: pins this operator's
                        // weight contribution to the price captured when the
                        // (op, asset) cursor was first seeded. Immune to oracle
                        // drift post-activation.
                        contribution = (contribution * snapshot) / 1 ether;
                    } else if (oracleAddr != address(0)) {
                        // Cursor exists without a snapshot (legacy activation
                        // path or operator joined before this fix shipped) and
                        // the oracle is still live — convert at the live price.
                        // Still gas-capped and revert-isolated by _safeToUSD.
                        address token = bondAsset.kind == Types.AssetKind.Native ? address(0) : bondAsset.token;
                        contribution = _safeToUSD(oracleAddr, token, contribution);
                    }
                    // else: USD-pinned baseline but no per-pair snapshot AND the
                    // oracle has since been removed. Keep `contribution` at
                    // identity scale rather than collapsing to raw token-seconds,
                    // which would mismatch the USD-scale baseline denominator and
                    // under-bill the customer indefinitely.
                }
                opWeight = contribution;
                if (!result.hasSecurityCommitments && stakeOp > 0 && fallbackBps > 0) {
                    result.hasSecurityCommitments = true;
                }
            } else {
                projected = new uint256[](m);
                for (uint256 j = 0; j < m;) {
                    Types.AssetSecurityCommitment storage c = commitments[j];
                    bytes32 assetHash = keccak256(abi.encode(c.asset.kind, c.asset.token));
                    (uint256 cumOp,, uint256 stakeOp) = staking.getCumStakeSeconds(op, c.asset);
                    uint256 projectedCum = _projectToPeriodEnd(cumOp, stakeOp, tailSeconds);
                    uint256 cursor = _twapCursorByOpAsset[serviceId][op][assetHash];
                    uint256 opDeltaRaw;
                    if (cursor != 0 && projectedCum > cursor) {
                        opDeltaRaw = projectedCum - cursor;
                    }
                    projected[j] = projectedCum;

                    // Exposure-weighted contribution. With oracle: USD-normalized so
                    // heterogeneous assets aggregate by value. Without oracle: raw
                    // token-second amounts — comparable only when all committed assets
                    // share a unit, but proportional within that unit.
                    uint256 contribution = (opDeltaRaw * uint256(c.exposureBps)) / BPS_DENOMINATOR;
                    if (useOracle && contribution > 0) {
                        uint256 snapshot = _baselinePriceByOpAsset[serviceId][op][assetHash];
                        if (snapshot != 0) {
                            contribution = (contribution * snapshot) / 1 ether;
                        } else if (oracleAddr != address(0)) {
                            address token = c.asset.kind == Types.AssetKind.Native ? address(0) : c.asset.token;
                            contribution = _safeToUSD(oracleAddr, token, contribution);
                        }
                        // else: USD-pinned baseline, no per-pair snapshot, oracle
                        // removed — keep identity scale (see fallback path above).
                    }
                    opWeight += contribution;
                    if (!result.hasSecurityCommitments && stakeOp > 0 && c.exposureBps > 0) {
                        result.hasSecurityCommitments = true;
                    }
                    unchecked {
                        ++j;
                    }
                }
            }
            result.projectedByOpAsset[i] = projected;
            result.weights[i] = opWeight;
            result.totalWeight += opWeight;
            result.cumDeltaPeriod += opWeight;
            unchecked {
                ++i;
            }
        }

        // Fallback weighting: when cumDelta is zero across the board (e.g. genuine zero-stake
        // edge cases) OR every operator has zero exposureBps, distribute the operator pool
        // equally across active operators so the bill — if any — still reaches them.
        if (result.totalWeight == 0 && operators.length > 0) {
            for (uint256 i = 0; i < operators.length;) {
                result.weights[i] = 1;
                unchecked {
                    ++i;
                }
            }
            result.totalWeight = operators.length;
        }

        // `hasSecurityCommitments` was set during the per-(op, asset) loop above: true iff
        // any operator has non-zero current stake committed with non-zero `exposureBps` on
        // any asset. Controls whether the staker pool routes to the `ServiceFeeDistributor`
        // or folds into the operator pool.
    }

    /// @notice Recover a subscription's activation-time billing scale (USD vs raw).
    /// @dev The denominator (`subscriptionBaselineStake`) was pinned at activation in one
    ///      of two scales and can never change for the life of the service. We read that
    ///      decision from durable state rather than the mutable `_priceOracle`: a non-zero
    ///      `_baselinePriceByOpAsset` on any seeded (op, asset) is written ONLY when an
    ///      oracle was configured at seeding time (`_snapshotBaselinePrice` /
    ///      `_snapshotJoinPrice` early-return on a zero oracle), so its presence is a
    ///      permanent witness that the baseline was pinned in USD scale. Returning the
    ///      activation-time mode here keeps every bill's numerator in the same scale as
    ///      its denominator even after `setPriceOracle` is toggled mid-subscription.
    /// @return true iff this subscription's baseline was pinned in USD scale.
    function _subscriptionPinnedInUsd(
        uint64 serviceId,
        address[] memory operators,
        Types.Asset memory bondAsset
    )
        internal
        view
        returns (bool)
    {
        bytes32 bondAssetHash = keccak256(abi.encode(bondAsset.kind, bondAsset.token));
        uint256 n = operators.length;
        for (uint256 i = 0; i < n;) {
            address op = operators[i];
            Types.AssetSecurityCommitment[] storage commitments = _serviceSecurityCommitments[serviceId][op];
            uint256 m = commitments.length;
            if (m == 0) {
                if (_baselinePriceByOpAsset[serviceId][op][bondAssetHash] != 0) return true;
            } else {
                for (uint256 j = 0; j < m;) {
                    bytes32 assetHash = keccak256(abi.encode(commitments[j].asset.kind, commitments[j].asset.token));
                    if (_baselinePriceByOpAsset[serviceId][op][assetHash] != 0) return true;
                    unchecked {
                        ++j;
                    }
                }
            }
            unchecked {
                ++i;
            }
        }
        return false;
    }

    /// @notice Resolve the per-period bill adjustment from the blueprint's manager hook.
    /// @dev Best-effort with a hard gas cap (the manager hook gas budget). Any revert /
    ///      out-of-range return / zero manager yields a full-bill (10_000 bps) result.
    ///      Values above 10_000 are clamped — a misbehaving manager cannot inflate a
    ///      customer's bill, only discount it. The gas cap prevents a malicious
    ///      manager from looping out the keeper's gas budget to make permissionless
    ///      bill triggers unprofitable.
    function _resolveBillAdjustmentBps(
        uint64 blueprintId,
        uint64 serviceId,
        uint64 periodStart,
        uint64 periodEnd
    )
        internal
        view
        returns (uint16)
    {
        address manager = _blueprints[blueprintId].manager;
        if (manager == address(0)) return uint16(BPS_DENOMINATOR);
        (bool ok, bytes memory ret) = manager.staticcall{ gas: _hookGasLimit() }(
            abi.encodeWithSelector(
                IBlueprintServiceManager.computeBillAdjustmentBps.selector, serviceId, periodStart, periodEnd
            )
        );
        if (!ok || ret.length < 32) return uint16(BPS_DENOMINATOR);
        uint256 bps = abi.decode(ret, (uint256));
        if (bps >= BPS_DENOMINATOR) return uint16(BPS_DENOMINATOR);
        return uint16(bps);
    }

    /// @notice Forward-project an operator's cum stake-seconds to the period boundary.
    /// @dev `tailSeconds` is `block.timestamp - periodEnd` when the bill is late, or
    ///      zero when on-time. Exact when stake has been stable since `periodEnd`;
    ///      conservatively under-attributes when stake ramped down in the tail.
    function _projectToPeriodEnd(uint256 cumNow, uint256 stakeNow, uint256 tailSeconds)
        internal
        pure
        returns (uint256)
    {
        if (tailSeconds == 0) return cumNow;
        uint256 tail = stakeNow * tailSeconds;
        return cumNow > tail ? cumNow - tail : 0;
    }
}
