// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Types } from "./Types.sol";
import { Errors } from "./Errors.sol";

/// @title PaymentLib
/// @notice Library for payment collection, distribution, and escrow management
/// @dev Handles both native and ERC-20 tokens with proper accounting
library PaymentLib {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    uint16 internal constant BPS_DENOMINATOR = 10_000;

    /// @notice Minimum payment amount required to ensure all recipients receive non-zero amounts
    /// @dev This ensures that when split 4 ways (developer, protocol, operator, staker) at minimum
    ///      splits (e.g., 10% each), each party receives at least 1 wei.
    ///      Calculation: 10000 / min_bps_per_party = 10000 / 1000 = 10 (for 10% minimum split)
    ///      We use 100 as a conservative minimum to handle edge cases.
    uint256 internal constant MINIMUM_PAYMENT_AMOUNT = 100;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUNDING HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event PaymentCollected(address indexed payer, address indexed token, uint256 amount, uint64 indexed serviceId);

    event PaymentDistributed(
        uint64 indexed serviceId,
        address indexed token,
        uint256 developerAmount,
        uint256 protocolAmount,
        uint256 operatorAmount,
        uint256 stakerAmount
    );

    event EscrowDeposited(uint64 indexed serviceId, address indexed token, uint256 amount);
    event EscrowReleased(uint64 indexed serviceId, address indexed token, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculated payment amounts per recipient type
    struct PaymentAmounts {
        uint256 developerAmount;
        uint256 protocolAmount;
        uint256 operatorAmount;
        uint256 stakerAmount;
        uint256 keeperAmount;
    }

    /// @notice Per-operator payment allocation
    struct OperatorPayment {
        address operator;
        uint256 operatorShare; // Direct operator payment
        uint256 stakerShare; // Payment to delegators via staking
    }

    /// @notice Service escrow account (for subscriptions).
    /// @dev `subscriptionBaselineStake` is pinned at activation so the price the
    ///      customer agreed to is the price they pay; per-operator TWAP cursors
    ///      live separately in `TangleStorage._twapCursorByOp`.
    struct ServiceEscrow {
        address token;
        uint256 balance;
        uint256 totalDeposited;
        uint256 totalReleased;
        uint256 __reserved0; // Reserved slot; always zero.
        uint256 subscriptionBaselineStake;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TWAP BILL FORMULA (pure)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute the TWAP-fair bill amount for one subscription period.
    /// @dev Pure helper extracted from `Payments._computeTwapBillAmount` so the
    ///      core arithmetic (`rate * cumDelta / (baseline * interval)`) can be
    ///      fuzz-tested without spinning up a full staking environment. Returns
    ///      `nominalRate` on the pathological zero-baseline / zero-interval
    ///      case to match the on-chain fallback (no revert).
    /// @param nominalRate The blueprint's flat subscription rate (wei per period)
    /// @param cumDeltaPeriod Sum of per-operator cum stake-seconds attributed to this period
    /// @param baselineStake The per-period denominator pinned at lazy-init (wei)
    /// @param interval Subscription interval (seconds)
    function twapBillAmount(
        uint256 nominalRate,
        uint256 cumDeltaPeriod,
        uint256 baselineStake,
        uint256 interval
    )
        internal
        pure
        returns (uint256)
    {
        if (baselineStake == 0 || interval == 0) return nominalRate;
        // `nominalRate * cumDeltaPeriod` is bounded under realistic inputs but
        // checked-math would panic with 0x11 on the rare overflow paths instead
        // of surfacing the protocol error. Compute the product unchecked, then
        // detect overflow via the divide-back identity and revert with a typed
        // error so consumers can distinguish "misconfigured upstream state"
        // from generic arithmetic failures.
        unchecked {
            uint256 product = nominalRate * cumDeltaPeriod;
            if (cumDeltaPeriod != 0 && product / cumDeltaPeriod != nominalRate) {
                revert Errors.BillingArithmeticOverflow();
            }
            return product / (baselineStake * interval);
        }
    }

    /// @notice Scale a bill amount by a QoS adjustment expressed in basis points.
    /// @dev Clamped to [0, 10_000]. A manager's misbehaving hook cannot inflate
    ///      the bill beyond the nominal value, only discount it.
    function applyQosAdjustment(uint256 amount, uint16 qosBps) internal pure returns (uint256) {
        if (qosBps >= BPS_DENOMINATOR) return amount;
        return (amount * qosBps) / BPS_DENOMINATOR;
    }

    /// @notice Smallest bill amount that can be cleanly split N ways under the configured split.
    /// @dev Used by the subscription billing path to skip rather than revert when a
    ///      QoS-discounted (or per-op TWAP-discounted) bill rounds to less than 1 wei
    ///      per recipient. Returns `MINIMUM_PAYMENT_AMOUNT` floor or the dust threshold
    ///      implied by the split, whichever is greater. Reverting on dust would let a
    ///      manager hook brick a service by returning a small but non-zero `qosBps`.
    function minBillAmount(Types.PaymentSplit memory split, uint256 operatorCount) internal pure returns (uint256) {
        uint256 floor = MINIMUM_PAYMENT_AMOUNT;
        // Each non-zero share-recipient class needs at least 1 wei to round non-zero.
        if (split.developerBps > 0) {
            uint256 needed = (BPS_DENOMINATOR + split.developerBps - 1) / split.developerBps;
            if (needed > floor) floor = needed;
        }
        if (split.protocolBps > 0) {
            uint256 needed = (BPS_DENOMINATOR + split.protocolBps - 1) / split.protocolBps;
            if (needed > floor) floor = needed;
        }
        if (split.keeperBps > 0) {
            uint256 needed = (BPS_DENOMINATOR + split.keeperBps - 1) / split.keeperBps;
            if (needed > floor) floor = needed;
        }
        if (operatorCount > 0 && split.operatorBps > 0) {
            // Each operator must receive at least 1 wei after the operator-pool split.
            uint256 needed = (BPS_DENOMINATOR * operatorCount + split.operatorBps - 1) / split.operatorBps;
            if (needed > floor) floor = needed;
        }
        return floor;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate payment split amounts
    /// @dev Uses floor division for first N-1 recipients, then gives remainder
    ///      to final recipient (staker) to capture all dust from rounding.
    /// @param amount Total payment amount
    /// @param split Payment split configuration
    /// @return amounts Calculated amounts for each recipient type
    /// @notice Split an amount across (developer, protocol, operator pool, staker pool, keeper).
    /// @dev Floor-divides the first four shares and gives any rounding dust to the staker pool
    ///      so the sum is exactly `amount`. When the caller does not pay a keeper rebate
    ///      (`includeKeeper == false`), the keeper share is folded into the operator pool
    ///      and the keeper amount returns zero. This is the right default for distributions
    ///      that aren't triggered by a permissionless bill (one-shot pays, RFQ, per-job).
    function calculateSplit(
        uint256 amount,
        Types.PaymentSplit memory split,
        bool includeKeeper
    )
        internal
        pure
        returns (PaymentAmounts memory amounts)
    {
        amounts.developerAmount = (amount * split.developerBps) / BPS_DENOMINATOR;
        amounts.protocolAmount = (amount * split.protocolBps) / BPS_DENOMINATOR;
        uint256 operatorPiece = (amount * split.operatorBps) / BPS_DENOMINATOR;
        amounts.keeperAmount = includeKeeper ? (amount * split.keeperBps) / BPS_DENOMINATOR : 0;
        if (!includeKeeper) {
            // Roll the keeper allocation into the operator pool so total bps still sums to 10_000.
            operatorPiece += (amount * split.keeperBps) / BPS_DENOMINATOR;
        }
        amounts.operatorAmount = operatorPiece;
        // Staker absorbs all rounding dust so Σshares == amount exactly.
        amounts.stakerAmount = amount
            - amounts.developerAmount
            - amounts.protocolAmount
            - amounts.operatorAmount
            - amounts.keeperAmount;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT COLLECTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Collect payment from sender
    /// @dev Validates minimum payment to prevent dust-only payments
    /// @param token Payment token (address(0) for native)
    /// @param amount Amount to collect
    /// @param msgValue msg.value for native payments
    function collectPayment(address token, uint256 amount, uint256 msgValue) internal {
        if (amount == 0) {
            if (msgValue != 0) {
                revert Errors.InvalidMsgValue(0, msgValue);
            }
            return;
        }

        // Reject dust-only payments that would be too small to distribute meaningfully
        if (amount < MINIMUM_PAYMENT_AMOUNT) {
            revert Errors.PaymentTooSmall(amount, MINIMUM_PAYMENT_AMOUNT);
        }

        if (token == address(0)) {
            // Exact native payment required to prevent silent overpayment trapping.
            if (msgValue != amount) {
                revert Errors.InvalidMsgValue(amount, msgValue);
            }
        } else {
            // ERC20 payments must not carry native value.
            if (msgValue != 0) {
                revert Errors.InvalidMsgValue(0, msgValue);
            }
            // reject fee-on-transfer / rebasing tokens at ingress.
            // Without a balance-delta check, the escrow credits `amount` while the
            // contract only physically receives `amount - fee`. Eventual `safeTransfer`
            // to dev / treasury / operators reverts on insufficient balance, bricking
            // the escrow for that service. Computing the delta and rejecting on
            // mismatch is cheaper and clearer than book-keeping the actual received
            // amount, since downstream accounting assumes the credited value matches
            // the protocol's holdings 1:1.
            uint256 balanceBefore = IERC20(token).balanceOf(address(this));
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
            uint256 balanceAfter = IERC20(token).balanceOf(address(this));
            if (balanceAfter - balanceBefore != amount) {
                revert Errors.FeeOnTransferTokenRejected(token);
            }
        }
    }

    /// @notice Refund payment to recipient
    /// @param to Recipient address
    /// @param token Payment token (address(0) for native)
    /// @param amount Amount to refund
    function refundPayment(address to, address token, uint256 amount) internal {
        if (amount == 0 || to == address(0)) return;
        transferPayment(to, token, amount);
    }

    /// @notice Transfer payment to recipient
    /// @param to Recipient address
    /// @param token Payment token (address(0) for native)
    /// @param amount Amount to transfer
    function transferPayment(address to, address token, uint256 amount) internal {
        if (amount == 0 || to == address(0)) return;

        if (token == address(0)) {
            (bool success,) = payable(to).call{ value: amount }("");
            if (!success) revert Errors.PaymentFailed();
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ESCROW MANAGEMENT (for Subscriptions)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit funds into service escrow
    /// @param escrow The escrow storage to update
    /// @param token Payment token
    /// @param amount Amount to deposit
    /// @param msgValue msg.value for native payments
    function depositToEscrow(ServiceEscrow storage escrow, address token, uint256 amount, uint256 msgValue) internal {
        if (amount == 0) {
            collectPayment(token, amount, msgValue);
            return;
        }

        // Initialize token if first deposit
        if (escrow.totalDeposited == 0) {
            escrow.token = token;
        } else {
            // Ensure consistent token
            if (escrow.token != token) revert Errors.InvalidPaymentToken();
        }

        collectPayment(token, amount, msgValue);
        escrow.balance += amount;
        escrow.totalDeposited += amount;
    }

    /// @notice Release funds from escrow for distribution
    /// @param escrow The escrow storage to update
    /// @param amount Amount to release
    /// @return token The escrow token
    function releaseFromEscrow(ServiceEscrow storage escrow, uint256 amount) internal returns (address token) {
        if (escrow.balance < amount) {
            revert Errors.InsufficientEscrowBalance(amount, escrow.balance);
        }

        escrow.balance -= amount;
        escrow.totalReleased += amount;
        return escrow.token;
    }

    /// @notice Check if escrow has sufficient balance
    /// @param escrow The escrow to check
    /// @param amount Required amount
    /// @return True if sufficient
    function hasEscrowBalance(ServiceEscrow storage escrow, uint256 amount) internal view returns (bool) {
        return escrow.balance >= amount;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-TOKEN REWARD TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add to pending rewards for an account
    /// @param pendingRewards Storage mapping for pending rewards
    /// @param account The account to credit
    /// @param token The token type
    /// @param amount Amount to add
    function addPendingReward(
        mapping(address => mapping(address => uint256)) storage pendingRewards,
        address account,
        address token,
        uint256 amount
    )
        internal
    {
        if (amount == 0) return;
        pendingRewards[account][token] += amount;
    }

    /// @notice Claim pending rewards for an account
    /// @param pendingRewards Storage mapping for pending rewards
    /// @param account The account claiming
    /// @param token The token to claim
    /// @return amount The claimed amount
    function claimPendingReward(
        mapping(address => mapping(address => uint256)) storage pendingRewards,
        address account,
        address token
    )
        internal
        returns (uint256 amount)
    {
        amount = pendingRewards[account][token];
        if (amount == 0) return 0;

        pendingRewards[account][token] = 0;
        transferPayment(account, token, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Validate payment split sums to exactly 100%, including the keeper share.
    /// @dev The keeper share is rolled into the operator pool on distributions that don't
    ///      pay a keeper (one-shot pays, RFQ, per-job), so it counts toward the 10_000 bps
    ///      total regardless of whether any specific distribution emits to a keeper.
    function validateSplit(Types.PaymentSplit memory split) internal pure {
        uint256 total = uint256(split.developerBps)
            + uint256(split.protocolBps)
            + uint256(split.operatorBps)
            + uint256(split.stakerBps)
            + uint256(split.keeperBps);
        if (total != BPS_DENOMINATOR) {
            revert Errors.InvalidPaymentSplit();
        }
    }

    /// @notice Get the minimum payment constant
    /// @return The minimum payment amount
    function getMinimumPaymentAmount() internal pure returns (uint256) {
        return MINIMUM_PAYMENT_AMOUNT;
    }
}
