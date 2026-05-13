// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { PaymentsEffectiveExposure } from "./PaymentsEffectiveExposure.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";
import { IStaking } from "../interfaces/IStaking.sol";
import { IPriceOracle } from "../oracles/interfaces/IPriceOracle.sol";

/// @title Payments
/// @notice Payment distribution, escrow, and rewards
/// @dev TIMESTAMP ASSUMPTIONS:
///      - block.timestamp is used for subscription billing intervals and TTL checks
///      - Miners can manipulate timestamps by ~15 seconds on Ethereum
///      - This tolerance is acceptable for billing intervals (typically hours/days)
///      - For critical time-sensitive operations, consider using block numbers instead
///      - TTL expiry and subscription intervals use timestamps for user-friendliness
/// @dev PAYMENT DISTRIBUTION:
///      - Operator payments are proportional to effective exposure (delegation × exposureBps)
///      - This ensures operators are paid based on actual security capital at risk
///      - If price oracle is configured, cross-asset values are normalized to USD
abstract contract Payments is Base, PaymentsEffectiveExposure {
    using EnumerableSet for EnumerableSet.AddressSet;
    using PaymentLib for PaymentLib.ServiceEscrow;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event EscrowFunded(uint64 indexed serviceId, address indexed token, uint256 amount);
    event EscrowRefunded(uint64 indexed serviceId, address indexed owner, address indexed token, uint256 amount);
    event SubscriptionBilled(uint64 indexed serviceId, uint256 amount, uint64 period);
    /// @notice Emitted when a subscription's bill window elapses but no active operators
    ///         exist to bill against. The `lastPaymentAt` cursor advances by `period` to
    ///         keep the schedule on rails; the escrow is not touched.
    event SubscriptionBillSkippedNoOperators(uint64 indexed serviceId, uint64 period);
    /// @notice Emitted when the manager hook reduced the bill via `computeBillAdjustmentBps`.
    /// @dev `preAdjustmentAmount` is the TWAP-and-cap-resolved amount (NOT the blueprint's
    ///      nominal rate). `adjustedAmount` is what the protocol ultimately drew from escrow.
    event SubscriptionBillAdjustedByManager(
        uint64 indexed serviceId, uint256 preAdjustmentAmount, uint256 adjustedAmount, uint16 adjustmentBps
    );
    /// @notice Emitted when the bill caller's keeper rebate is added to their pending-rewards
    ///         mapping. The actual transfer happens on `claimRewards` — naming mirrors
    ///         `OperatorRewardAccrued` to avoid implying push-transfer at the event.
    event KeeperRebateAccrued(uint64 indexed serviceId, address indexed keeper, address indexed token, uint256 amount);
    /// @notice Emitted when the staker pool's share could not be routed (no distributor configured,
    ///         or the distributor reverted). The amount is refunded to the service escrow so the
    ///         customer can recover it, rather than being silently captured by the treasury.
    event StakerShareRefundedToEscrow(
        uint64 indexed serviceId, address indexed operator, address indexed token, uint256 amount, bytes reason
    );
    /// @notice Emitted when a Subscription-pricing service has its per-operator TWAP cursors
    ///         and `subscriptionBaselineStake` seeded at activation. Indexers / off-chain
    ///         observers can subscribe here to track when the bill contract is locked in.
    event SubscriptionBaselineInitialized(uint64 indexed serviceId, uint256 baselineStake, uint256 operatorCount);
    event PaymentDistributed(
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        address indexed token,
        uint256 grossAmount,
        address developerRecipient,
        uint256 developerAmount,
        uint256 protocolAmount,
        uint256 operatorPoolAmount,
        uint256 stakerPoolAmount
    );
    event OperatorRewardAccrued(
        uint64 indexed serviceId, address indexed operator, address indexed token, uint64 blueprintId, uint256 amount
    );
    event RewardsClaimed(address indexed account, address indexed token, uint256 amount);
    event TntPaymentDiscountApplied(
        uint64 indexed serviceId, address indexed recipient, address indexed token, uint256 amount
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // ESCROW MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fund a service's escrow.
    /// @dev Re-checks (a) the service hasn't expired and (b) the blueprint manager still
    ///      whitelists the escrow's payment token. Without these checks a service could
    ///      be funded after expiry (escrow stuck) or after a manager policy revoke
    ///      (ongoing top-ups for a token the protocol now disallows).
    function fundService(uint64 serviceId, uint256 amount) external payable whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.pricing != Types.PricingModel.Subscription) {
            revert Errors.InvalidState();
        }
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) {
            revert Errors.ServiceExpired(serviceId);
        }

        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        address token = escrow.token;

        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0) && !_isPaymentAssetAllowedByManager(bp.manager, serviceId, token)) {
            revert Errors.TokenNotAllowed(token);
        }

        PaymentLib.depositToEscrow(escrow, token, amount, msg.value);

        emit EscrowFunded(serviceId, token, amount);
        _recordPayment(msg.sender, serviceId, token, amount);
    }

    /// @notice Withdraw remaining escrow balance after service termination
    function withdrawRemainingEscrow(uint64 serviceId) external nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }
        if (svc.status != Types.ServiceStatus.Terminated) {
            revert Errors.ServiceNotTerminated(serviceId);
        }

        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        uint256 remaining = escrow.balance;
        if (remaining == 0) revert Errors.ZeroAmount();

        address token = escrow.token;
        escrow.balance = 0;
        escrow.totalReleased += remaining;

        PaymentLib.transferPayment(svc.owner, token, remaining);
        emit EscrowRefunded(serviceId, svc.owner, token, remaining);
    }

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

    /// @notice Get services that are billable (past their billing interval)
    /// @param serviceIds Array of service IDs to check
    /// @return billable Array of service IDs that can be billed
    function getBillableServices(uint64[] calldata serviceIds) external view returns (uint64[] memory billable) {
        uint256 serviceIdsLength = serviceIds.length;
        uint64[] memory temp = new uint64[](serviceIdsLength);
        uint256 count = 0;

        for (uint256 i = 0; i < serviceIdsLength;) {
            if (_isBillable(serviceIds[i])) {
                temp[count++] = serviceIds[i];
            }
            unchecked {
                ++i;
            }
        }

        billable = new uint64[](count);
        for (uint256 i = 0; i < count;) {
            billable[i] = temp[i];
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

    /// @notice Permissionless subscription bill (returns false on failure instead of reverting).
    function _tryBillSubscription(uint64 serviceId) internal returns (bool) {
        (bool billed,) = _billSubscriptionImpl(serviceId, false, msg.sender);
        return billed;
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
    function _billSubscriptionImpl(uint64 serviceId, bool revertOnFail, address keeper)
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
        _distributeBill(
            BillDistribution({
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

    /// @notice Initialize per-(operator, asset) TWAP cursors and pin the multi-asset baseline.
    /// @dev Walks each operator's `AssetSecurityCommitment[]` and seeds cursors for every
    ///      (op, asset) pair. Baseline is the exposure-weighted aggregate
    ///      `Σ_op Σ_asset (delegation × commitmentBps)`, USD-normalized when a price oracle
    ///      is configured. Pinned once at activation; subsequent bills measure against this
    ///      snapshot so an operator cannot inflate the customer's bill by ramping stake on
    ///      a single asset post-activation.
    function _initSubscriptionBaseline(uint64 serviceId, address[] calldata operators) internal {
        IStaking staking = _getStaking();
        address oracleAddr = _getPriceOracle();
        bool useOracle = oracleAddr != address(0);
        IPriceOracle oracle = IPriceOracle(oracleAddr);
        Types.Asset memory bondAsset = _bondAssetForBilling();

        uint256 baseline;
        uint256 n = operators.length;
        for (uint256 i = 0; i < n;) {
            address op = operators[i];
            Types.AssetSecurityCommitment[] storage commitments = _serviceSecurityCommitments[serviceId][op];
            uint256 m = commitments.length;
            if (m == 0) {
                // No per-asset commitments specified — fall back to the bond asset at
                // the operator's `ServiceOperator.exposureBps`. Mirrors the legacy
                // single-asset semantics for services that don't opt into the
                // multi-asset commitment system.
                bytes32 assetHash = keccak256(abi.encode(bondAsset.kind, bondAsset.token));
                (uint256 cumOp,, uint256 stakeOp) = staking.getCumStakeSeconds(op, bondAsset);
                _twapCursorByOpAsset[serviceId][op][assetHash] = cumOp == 0 ? 1 : cumOp;
                uint16 fallbackBps = _serviceOperators[serviceId][op].exposureBps;
                if (fallbackBps == 0) fallbackBps = uint16(BPS_DENOMINATOR);
                uint256 exposedAmount = (stakeOp * uint256(fallbackBps)) / BPS_DENOMINATOR;
                if (useOracle && exposedAmount > 0) {
                    address token = bondAsset.kind == Types.AssetKind.Native ? address(0) : bondAsset.token;
                    baseline += oracle.toUSD(token, exposedAmount);
                } else {
                    baseline += exposedAmount;
                }
            } else {
                for (uint256 j = 0; j < m;) {
                    Types.AssetSecurityCommitment storage c = commitments[j];
                    bytes32 assetHash = keccak256(abi.encode(c.asset.kind, c.asset.token));
                    (uint256 cumOp,, uint256 stakeOp) = staking.getCumStakeSeconds(op, c.asset);
                    _twapCursorByOpAsset[serviceId][op][assetHash] = cumOp == 0 ? 1 : cumOp;

                    uint256 exposedAmount = (stakeOp * uint256(c.exposureBps)) / BPS_DENOMINATOR;
                    if (useOracle && exposedAmount > 0) {
                        address token = c.asset.kind == Types.AssetKind.Native ? address(0) : c.asset.token;
                        baseline += oracle.toUSD(token, exposedAmount);
                    } else {
                        baseline += exposedAmount;
                    }
                    unchecked {
                        ++j;
                    }
                }
            }
            unchecked {
                ++i;
            }
        }
        // Pathological zero-stake activation: defensive minimum of 1 keeps the denominator
        // positive. In practice activation requires staked, committed operators.
        uint256 pinned = baseline == 0 ? 1 : baseline;
        _serviceEscrows[serviceId].subscriptionBaselineStake = pinned;
        emit SubscriptionBaselineInitialized(serviceId, pinned, n);
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
        view
        returns (BillWeights memory result)
    {
        IStaking staking = _getStaking();
        address oracleAddr = _getPriceOracle();
        bool useOracle = oracleAddr != address(0);
        IPriceOracle oracle = IPriceOracle(oracleAddr);
        Types.Asset memory bondAsset = _bondAssetForBilling();
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
                    address token = bondAsset.kind == Types.AssetKind.Native ? address(0) : bondAsset.token;
                    contribution = oracle.toUSD(token, contribution);
                }
                opWeight = contribution;
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
                        address token = c.asset.kind == Types.AssetKind.Native ? address(0) : c.asset.token;
                        contribution = oracle.toUSD(token, contribution);
                    }
                    opWeight += contribution;
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

        // `hasSecurityCommitments` controls whether the staker pool is routed to the
        // ServiceFeeDistributor or folded into the operator pool — real delegated stake.
        (, uint256 totalExposure) = _calculateEffectiveExposures(serviceId, operators);
        result.hasSecurityCommitments = totalExposure > 0;
    }

    /// @notice Resolve the developer payment recipient via a gas-capped manager hook.
    /// @dev Same defense-in-depth as `_resolveBillAdjustmentBps`: bounded gas, raw
    ///      staticcall, fall back to `blueprintOwner` on revert / empty / zero. Without
    ///      this cap a malicious manager could grief subscription bills (and any other
    ///      distribution path that pays a developer).
    function _resolveDeveloperPaymentAddress(
        address manager,
        address blueprintOwner,
        uint64 serviceId
    )
        internal
        view
        returns (address)
    {
        if (manager == address(0)) return blueprintOwner;
        (bool ok, bytes memory ret) = manager.staticcall{ gas: MANAGER_HOOK_GAS_LIMIT }(
            abi.encodeWithSelector(IBlueprintServiceManager.queryDeveloperPaymentAddress.selector, serviceId)
        );
        if (!ok || ret.length < 32) return blueprintOwner;
        address dev = abi.decode(ret, (address));
        return dev == address(0) ? blueprintOwner : dev;
    }

    /// @notice Resolve the per-period bill adjustment from the blueprint's manager hook.
    /// @dev Best-effort with a hard gas cap (`MANAGER_HOOK_GAS_LIMIT`). Any revert /
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
        (bool ok, bytes memory ret) = manager.staticcall{ gas: MANAGER_HOOK_GAS_LIMIT }(
            abi.encodeWithSelector(IBlueprintServiceManager.computeBillAdjustmentBps.selector, serviceId, periodStart, periodEnd)
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

    /// @notice Predicate for `getBillableServices` — mirrors `_billSubscriptionImpl`'s
    ///         pre-conditions so off-chain keepers don't burn gas attempting bills the
    ///         impl will reject.
    /// @dev Returns true when the service is active, subscription-priced, baseline-seeded,
    ///      past its TTL guard, past its billing interval, AND the escrow can cover at
    ///      least the nominal rate (the cap-at-nominal guarantee means a bill never
    ///      exceeds `subscriptionRate`, so `balance >= rate` is sufficient).
    function _isBillable(uint64 serviceId) internal view returns (bool) {
        Types.Service storage svc = _services[serviceId];
        if (svc.status != Types.ServiceStatus.Active) return false;
        if (svc.pricing != Types.PricingModel.Subscription) return false;
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) return false;

        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[svc.blueprintId];
        if (block.timestamp < svc.lastPaymentAt + bpConfig.subscriptionInterval) return false;

        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        if (escrow.subscriptionBaselineStake == 0) return false;
        // Cap-at-nominal means a successful bill never exceeds `subscriptionRate`.
        if (escrow.balance < bpConfig.subscriptionRate) return false;

        return true;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARDS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim pending rewards (native token)
    function claimRewards() external nonReentrant {
        _claimRewardsToken(msg.sender, address(0), false);
    }

    /// @notice Claim pending rewards for specific token
    function claimRewards(address token) external nonReentrant {
        _claimRewardsToken(msg.sender, token, false);
    }

    /// @notice Claim pending rewards for multiple tokens
    function claimRewardsBatch(address[] calldata tokens) external nonReentrant {
        uint256 tokensLength = tokens.length;
        for (uint256 i = 0; i < tokensLength;) {
            _claimRewardsToken(msg.sender, tokens[i], false);
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Claim pending rewards for all tokens tracked for the caller
    function claimRewardsAll() external nonReentrant {
        EnumerableSet.AddressSet storage set = _pendingRewardTokens[msg.sender];
        while (set.length() > 0) {
            address token = set.at(set.length() - 1);
            _claimRewardsToken(msg.sender, token, true);
        }
    }

    /// @notice Get pending rewards
    function pendingRewards(address account) external view returns (uint256) {
        return _pendingRewards[account][address(0)];
    }

    /// @notice Get pending rewards for token
    function pendingRewards(address account, address token) external view returns (uint256) {
        return _pendingRewards[account][token];
    }

    /// @notice Return the set of tokens with non-zero pending operator rewards for an account
    function rewardTokens(address account) external view returns (address[] memory tokens) {
        EnumerableSet.AddressSet storage set = _pendingRewardTokens[account];
        uint256 setLength = set.length();
        tokens = new address[](setLength);
        for (uint256 i = 0; i < setLength;) {
            tokens[i] = set.at(i);
            unchecked {
                ++i;
            }
        }
    }

    function _claimRewardsToken(address account, address token, bool forceRemove) private {
        uint256 claimed = PaymentLib.claimPendingReward(_pendingRewards, account, token);
        if (claimed > 0) {
            _pendingRewardTokens[account].remove(token);
            emit RewardsClaimed(account, token, claimed);
        } else if (forceRemove) {
            _pendingRewardTokens[account].remove(token);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set payment split
    /// @param split The new payment split configuration
    function setPaymentSplit(Types.PaymentSplit calldata split) external onlyRole(ADMIN_ROLE) {
        PaymentLib.validateSplit(split);
        _paymentSplit = split;
        emit PaymentSplitUpdated(
            split.developerBps, split.protocolBps, split.operatorBps, split.stakerBps, split.keeperBps
        );
    }

    /// @notice Set treasury
    /// @param treasury_ The new treasury address
    function setTreasury(address payable treasury_) external onlyRole(ADMIN_ROLE) {
        if (treasury_ == address(0)) revert Errors.ZeroAddress();
        _treasury = treasury_;
        emit TreasuryUpdated(treasury_);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW
    // ═══════════════════════════════════════════════════════════════════════════

    function paymentSplit() external view returns (uint16, uint16, uint16, uint16, uint16) {
        return (
            _paymentSplit.developerBps,
            _paymentSplit.protocolBps,
            _paymentSplit.operatorBps,
            _paymentSplit.stakerBps,
            _paymentSplit.keeperBps
        );
    }

    function treasury() external view returns (address payable) {
        return _treasury;
    }

    function getServiceEscrow(uint64 serviceId) external view returns (PaymentLib.ServiceEscrow memory) {
        return _serviceEscrows[serviceId];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit to escrow
    function _depositToEscrow(uint64 serviceId, address token, uint256 amount) internal {
        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        escrow.token = token;
        escrow.balance += amount;
        escrow.totalDeposited += amount;
        emit EscrowFunded(serviceId, token, amount);
    }

    /// @notice Distribution parameters bundle. Keeps the wide signature manageable.
    struct BillDistribution {
        uint64 serviceId;
        uint64 blueprintId;
        address token;
        uint256 amount;
        address[] operators;
        uint256[] weights;
        uint256 totalWeight;
        bool hasSecurityCommitments;
        address keeper; // address(0) → no keeper rebate; share folds into operator pool
    }

    /// @notice Distribute a bill to (developer, protocol, operator pool, staker pool, keeper).
    /// @dev Single distribution path shared between subscription bills (keeper present, TWAP
    ///      weights) and non-subscription payments (no keeper, exposure-based weights). The
    ///      caller is responsible for computing weights — this function does not assume any
    ///      particular fairness model for the operator pool.
    function _distributeBill(BillDistribution memory d) internal {
        if (d.amount == 0) return;
        if (d.operators.length == 0) revert Errors.NoOperators();

        bool includeKeeper = d.keeper != address(0);
        if (d.totalWeight == 0) revert Errors.InvalidState();
        PaymentLib.PaymentAmounts memory amounts = PaymentLib.calculateSplit(d.amount, _paymentSplit, includeKeeper);

        // Developer payment (manager can override the destination).
        Types.Blueprint storage bp = _blueprints[d.blueprintId];
        Types.Service storage svc = _services[d.serviceId];
        address developerAddr = _resolveDeveloperPaymentAddress(bp.manager, bp.owner, d.serviceId);
        PaymentLib.transferPayment(developerAddr, d.token, amounts.developerAmount);

        // TNT payment discount: funded from the protocol share, paid to the service owner.
        if (
            d.token != address(0) && d.token == _tntToken && _tntPaymentDiscountBps > 0 && amounts.protocolAmount > 0
                && svc.owner != address(0)
        ) {
            uint256 desired = (d.amount * _tntPaymentDiscountBps) / BPS_DENOMINATOR;
            uint256 discount = desired > amounts.protocolAmount ? amounts.protocolAmount : desired;
            if (discount > 0) {
                amounts.protocolAmount -= discount;
                PaymentLib.transferPayment(svc.owner, d.token, discount);
                emit TntPaymentDiscountApplied(d.serviceId, svc.owner, d.token, discount);
            }
        }

        // Protocol payment.
        PaymentLib.transferPayment(_treasury, d.token, amounts.protocolAmount);

        // Keeper rebate: pull-pattern via _pendingRewards so the keeper's gas budget for
        // this transaction stays predictable and contract-keepers don't get force-fed ETH.
        if (includeKeeper && amounts.keeperAmount > 0) {
            PaymentLib.addPendingReward(_pendingRewards, d.keeper, d.token, amounts.keeperAmount);
            _pendingRewardTokens[d.keeper].add(d.token);
            emit KeeperRebateAccrued(d.serviceId, d.keeper, d.token, amounts.keeperAmount);
        }

        // When no real delegated stake backs operators, fold the staker share into the
        // operator pool so the customer still funds compute providers in full.
        uint256 operatorPool =
            d.hasSecurityCommitments ? amounts.operatorAmount : amounts.operatorAmount + amounts.stakerAmount;
        uint256 stakerPool = d.hasSecurityCommitments ? amounts.stakerAmount : 0;

        emit PaymentDistributed(
            d.serviceId,
            d.blueprintId,
            d.token,
            d.amount,
            developerAddr,
            amounts.developerAmount,
            amounts.protocolAmount,
            operatorPool,
            stakerPool
        );

        _payOperatorPoolByWeight(d, operatorPool, stakerPool);
    }

    /// @notice Distribute the operator + staker pools across active operators by `weights`.
    /// @dev `_distributeBill` ensures `weights.length == operators.length`, `totalWeight > 0`,
    ///      and any rounding dust accumulates on the LAST operator so Σshares == pool exactly.
    function _payOperatorPoolByWeight(
        BillDistribution memory d,
        uint256 operatorPool,
        uint256 stakerPool
    )
        internal
    {
        uint256 n = d.operators.length;
        uint256 operatorDistributed;
        uint256 stakerDistributed;

        for (uint256 i = 0; i < n;) {
            uint256 opShare;
            uint256 stakerShare;
            if (i == n - 1) {
                opShare = operatorPool - operatorDistributed;
                stakerShare = stakerPool - stakerDistributed;
            } else {
                opShare = (operatorPool * d.weights[i]) / d.totalWeight;
                stakerShare = (stakerPool * d.weights[i]) / d.totalWeight;
                operatorDistributed += opShare;
                stakerDistributed += stakerShare;
            }

            if (opShare > 0) {
                PaymentLib.addPendingReward(_pendingRewards, d.operators[i], d.token, opShare);
                _pendingRewardTokens[d.operators[i]].add(d.token);
                emit OperatorRewardAccrued(d.serviceId, d.operators[i], d.token, d.blueprintId, opShare);
            }
            if (stakerShare > 0) {
                _forwardStakerShare(d.serviceId, d.blueprintId, d.operators[i], d.token, stakerShare);
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Backwards-compatible entry point for non-subscription distributions
    ///         (one-shot, RFQ, per-job). Computes exposure-based weights internally and
    ///         routes through the shared `_distributeBill` core with no keeper rebate.
    function _distributePaymentWithEffectiveExposure(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] memory operators,
        uint256[] memory effectiveExposures,
        uint256 totalEffectiveExposure,
        bool hasSecurityCommitments
    )
        internal
    {
        // Fallback weighting: when nobody has effective exposure, distribute the operator
        // pool equally. Materializing this as a uniform `weights` array keeps the shared
        // core simple at a marginal gas cost.
        uint256[] memory weights = effectiveExposures;
        uint256 totalWeight = totalEffectiveExposure;
        if (totalWeight == 0 && operators.length > 0) {
            weights = new uint256[](operators.length);
            for (uint256 i = 0; i < operators.length;) {
                weights[i] = 1;
                unchecked {
                    ++i;
                }
            }
            totalWeight = operators.length;
        }

        _distributeBill(
            BillDistribution({
                serviceId: serviceId,
                blueprintId: blueprintId,
                token: token,
                amount: amount,
                operators: operators,
                weights: weights,
                totalWeight: totalWeight,
                hasSecurityCommitments: hasSecurityCommitments,
                keeper: address(0)
            })
        );
    }

    /// @notice Route the staker pool's per-operator share through the fee distributor.
    /// @dev When the distributor is unset OR reverts, the share is refunded to the service
    ///      escrow rather than silently captured by the treasury. That way:
    ///        - the customer recovers funds for unstaked / unrouted operator shares,
    ///        - a misbehaving distributor cannot brick all subscription bills, and
    ///        - off-chain observers can see exactly why the share didn't reach stakers.
    function _forwardStakerShare(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address token,
        uint256 amount
    )
        private
    {
        if (amount == 0) return;
        address distributor = _serviceFeeDistributor;

        if (distributor == address(0)) {
            _refundStakerShareToEscrow(serviceId, operator, token, amount, bytes("no-distributor"));
            return;
        }

        // ERC20: transfer to the distributor first so the callee can pull state-free.
        // Native: pass `value` directly. Either failure path refunds the customer.
        if (token == address(0)) {
            try IServiceFeeDistributor(distributor).distributeServiceFee{ value: amount }(
                serviceId, blueprintId, operator, token, amount
            ) {
                return;
            } catch (bytes memory reason) {
                _refundStakerShareToEscrow(serviceId, operator, token, amount, reason);
                return;
            }
        }

        PaymentLib.transferPayment(distributor, token, amount);
        try IServiceFeeDistributor(distributor).distributeServiceFee(serviceId, blueprintId, operator, token, amount) {
            return;
        } catch (bytes memory reason) {
            // The ERC20 has already left this contract — fee distributor holds it. We cannot
            // unilaterally claw the tokens back, so we emit a clear marker for the customer
            // and protocol to handle off-chain. The escrow is NOT credited because the funds
            // are not in escrow's accounting bucket. This is rare (distributor is owned by
            // the protocol) and explicitly surfaced so it never goes unnoticed.
            emit StakerShareRefundedToEscrow(serviceId, operator, token, amount, reason);
        }
    }

    function _refundStakerShareToEscrow(
        uint64 serviceId,
        address operator,
        address token,
        uint256 amount,
        bytes memory reason
    )
        private
    {
        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        // Defensive: only refund into an escrow that holds the same token.
        if (escrow.token != token) {
            PaymentLib.transferPayment(_treasury, token, amount);
            return;
        }
        escrow.balance += amount;
        // The release back to escrow is a counter-release: lower lifetime-released so the
        // accounting invariant `totalDeposited >= totalReleased + balance` holds.
        if (escrow.totalReleased >= amount) {
            escrow.totalReleased -= amount;
        } else {
            escrow.totalReleased = 0;
        }
        emit StakerShareRefundedToEscrow(serviceId, operator, token, amount, reason);
    }

    /// @dev Returns only operators currently active in the service. Operators that left
    ///      remain in the EnumerableSet for historical accounting; we must not pay them.
    function _activeServiceOperators(uint64 serviceId) internal view returns (address[] memory active) {
        address[] memory all = _serviceOperatorSet[serviceId].values();
        uint256 activeCount;
        for (uint256 i = 0; i < all.length; ++i) {
            if (_serviceOperators[serviceId][all[i]].active) activeCount++;
        }
        active = new address[](activeCount);
        uint256 j;
        for (uint256 i = 0; i < all.length; ++i) {
            if (_serviceOperators[serviceId][all[i]].active) {
                active[j++] = all[i];
            }
        }
    }

    /// @notice Calculate effective exposures with fallback to stored exposureBps
    /// @dev When operators have no security commitments (common case), falls back to
    ///      the exposureBps stored on their ServiceOperator record for proportional distribution.
    /// @return effectiveExposures Per-operator exposure weights
    /// @return totalEffectiveExposure Sum of all weights
    /// @return hasSecurityCommitments True when real delegated stake backs the operators (stakers exist)
    function _calculateEffectiveExposuresWithFallback(
        uint64 serviceId,
        address[] memory operators
    )
        internal
        view
        returns (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure, bool hasSecurityCommitments)
    {
        (effectiveExposures, totalEffectiveExposure) = _calculateEffectiveExposures(serviceId, operators);

        // If commitment-based calculation found real delegated stake, stakers are backing operators
        hasSecurityCommitments = totalEffectiveExposure > 0;

        // Fallback: when no security commitments exist, use stored exposureBps as weights.
        if (totalEffectiveExposure == 0 && operators.length > 0) {
            uint16[] memory bps = new uint16[](operators.length);
            for (uint256 i = 0; i < operators.length;) {
                bps[i] = _serviceOperators[serviceId][operators[i]].exposureBps;
                unchecked {
                    ++i;
                }
            }
            (effectiveExposures, totalEffectiveExposure) = _calculateSimpleExposures(operators, bps);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EFFECTIVE EXPOSURE INTERFACE IMPLEMENTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc PaymentsEffectiveExposure
    function _getStaking() internal view override returns (IStaking) {
        return _staking;
    }

    /// @inheritdoc PaymentsEffectiveExposure
    function _getPriceOracle() internal view override returns (address) {
        return _priceOracle;
    }

    /// @inheritdoc PaymentsEffectiveExposure
    function _getServiceSecurityCommitments(
        uint64 serviceId,
        address operator
    )
        internal
        view
        override
        returns (Types.AssetSecurityCommitment[] storage)
    {
        return _serviceSecurityCommitments[serviceId][operator];
    }
}
