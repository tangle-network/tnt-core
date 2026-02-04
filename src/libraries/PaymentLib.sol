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
    /// @dev This ensures that when split 4 ways (developer, protocol, operator, restaker) at minimum
    ///      splits (e.g., 10% each), each party receives at least 1 wei.
    ///      Calculation: 10000 / min_bps_per_party = 10000 / 1000 = 10 (for 10% minimum split)
    ///      We use 100 as a conservative minimum to handle edge cases.
    uint256 internal constant MINIMUM_PAYMENT_AMOUNT = 100;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUNDING HELPERS (M-5 FIX)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice M-5 FIX: Round up division to capture dust for final recipient
    /// @dev Uses ceiling division: (a + b - 1) / b
    /// @param numerator The numerator
    /// @param denominator The denominator (must be > 0)
    /// @return result The ceiling of numerator / denominator
    function divUp(uint256 numerator, uint256 denominator) internal pure returns (uint256 result) {
        // Note: denominator > 0 is assumed (validated by caller)
        result = (numerator + denominator - 1) / denominator;
    }

    /// @notice M-5 FIX: Calculate basis points share with rounding up
    /// @dev Used for final recipient to capture dust
    /// @param amount Total amount to split
    /// @param bps Basis points (out of 10000)
    /// @return share The rounded-up share
    function bpsShareRoundUp(uint256 amount, uint16 bps) internal pure returns (uint256 share) {
        share = divUp(amount * bps, BPS_DENOMINATOR);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event PaymentCollected(
        address indexed payer,
        address indexed token,
        uint256 amount,
        uint64 indexed serviceId
    );

    event PaymentDistributed(
        uint64 indexed serviceId,
        address indexed token,
        uint256 developerAmount,
        uint256 protocolAmount,
        uint256 operatorAmount,
        uint256 restakerAmount
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
        uint256 restakerAmount;
    }

    /// @notice Per-operator payment allocation
    struct OperatorPayment {
        address operator;
        uint256 operatorShare;   // Direct operator payment
        uint256 restakerShare;   // Payment to delegators via restaking
    }

    /// @notice Service escrow account (for subscriptions)
    struct ServiceEscrow {
        address token;          // Payment token (address(0) = native)
        uint256 balance;        // Current escrow balance
        uint256 totalDeposited; // Lifetime deposits
        uint256 totalReleased;  // Lifetime releases
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate payment split amounts
    /// @dev M-5 FIX: Uses floor division for first N-1 recipients, then gives remainder
    ///      to final recipient (restaker) to capture all dust from rounding.
    /// @param amount Total payment amount
    /// @param split Payment split configuration
    /// @return amounts Calculated amounts for each recipient type
    function calculateSplit(
        uint256 amount,
        Types.PaymentSplit memory split
    ) internal pure returns (PaymentAmounts memory amounts) {
        // M-5 FIX: Floor division for first three recipients
        amounts.developerAmount = (amount * split.developerBps) / BPS_DENOMINATOR;
        amounts.protocolAmount = (amount * split.protocolBps) / BPS_DENOMINATOR;
        amounts.operatorAmount = (amount * split.operatorBps) / BPS_DENOMINATOR;
        // M-5 FIX: Final recipient (restaker) gets remainder to capture all rounding dust
        // This ensures no dust is lost: sum of all amounts == original amount
        amounts.restakerAmount = amount - amounts.developerAmount - amounts.protocolAmount - amounts.operatorAmount;
    }

    /// @notice Calculate weighted operator payments based on effective exposure
    /// @dev M-5 FIX: Uses floor division for first N-1 operators, then gives remainder
    ///      to final operator to capture all dust from rounding.
    ///      Effective exposure = delegation × exposureBps for each asset, summed across assets.
    ///      This ensures operators are paid proportionally to actual security provided.
    /// @param totalOperatorAmount Total amount for all operators
    /// @param totalRestakerAmount Total amount for all restakers
    /// @param operators Array of operator addresses
    /// @param effectiveExposures Array of effective exposure values (parallel to operators)
    ///        These should be pre-calculated as: Σ(delegation[asset] × exposureBps[asset])
    /// @param totalEffectiveExposure Sum of all effective exposures
    /// @return payments Array of per-operator payment allocations
    function calculateOperatorPayments(
        uint256 totalOperatorAmount,
        uint256 totalRestakerAmount,
        address[] memory operators,
        uint256[] memory effectiveExposures,
        uint256 totalEffectiveExposure
    ) internal pure returns (OperatorPayment[] memory payments) {
        if (totalEffectiveExposure == 0) {
            return new OperatorPayment[](0);
        }

        payments = new OperatorPayment[](operators.length);

        uint256 operatorDistributed = 0;
        uint256 restakerDistributed = 0;

        for (uint256 i = 0; i < operators.length; i++) {
            uint256 effectiveExposure = effectiveExposures[i];

            // M-5 FIX: Last operator gets remainder to capture all rounding dust
            if (i == operators.length - 1) {
                payments[i] = OperatorPayment({
                    operator: operators[i],
                    operatorShare: totalOperatorAmount - operatorDistributed,
                    restakerShare: totalRestakerAmount - restakerDistributed
                });
            } else {
                uint256 opShare = (totalOperatorAmount * effectiveExposure) / totalEffectiveExposure;
                uint256 restakeShare = (totalRestakerAmount * effectiveExposure) / totalEffectiveExposure;

                payments[i] = OperatorPayment({
                    operator: operators[i],
                    operatorShare: opShare,
                    restakerShare: restakeShare
                });

                operatorDistributed += opShare;
                restakerDistributed += restakeShare;
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT COLLECTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Collect payment from sender
    /// @dev M-5 FIX: Validates minimum payment to prevent dust-only payments
    /// @param token Payment token (address(0) for native)
    /// @param amount Amount to collect
    /// @param msgValue msg.value for native payments
    function collectPayment(
        address token,
        uint256 amount,
        uint256 msgValue
    ) internal {
        if (amount == 0) return;

        // M-5 FIX: Reject dust-only payments that would be too small to distribute meaningfully
        if (amount < MINIMUM_PAYMENT_AMOUNT) {
            revert Errors.PaymentTooSmall(amount, MINIMUM_PAYMENT_AMOUNT);
        }

        if (token == address(0)) {
            if (msgValue < amount) {
                revert Errors.InsufficientPayment(amount, msgValue);
            }
        } else {
            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
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
            (bool success,) = payable(to).call{value: amount}("");
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
    function depositToEscrow(
        ServiceEscrow storage escrow,
        address token,
        uint256 amount,
        uint256 msgValue
    ) internal {
        if (amount == 0) return;

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
    function releaseFromEscrow(
        ServiceEscrow storage escrow,
        uint256 amount
    ) internal returns (address token) {
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
    function hasEscrowBalance(
        ServiceEscrow storage escrow,
        uint256 amount
    ) internal view returns (bool) {
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
    ) internal {
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
    ) internal returns (uint256 amount) {
        amount = pendingRewards[account][token];
        if (amount == 0) return 0;

        pendingRewards[account][token] = 0;
        transferPayment(account, token, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Validate payment split sums to 100%
    /// @param split The split to validate
    function validateSplit(Types.PaymentSplit memory split) internal pure {
        uint256 total = uint256(split.developerBps) +
                       uint256(split.protocolBps) +
                       uint256(split.operatorBps) +
                       uint256(split.stakerBps);
        if (total != BPS_DENOMINATOR) {
            revert Errors.InvalidPaymentSplit();
        }
    }

    /// @notice Validate payment amount is sufficient for distribution
    /// @dev Reverts if amount would result in zero payments to any recipient
    /// @param amount The payment amount to validate
    /// @param split The payment split configuration
    /// @param operatorCount Number of operators to distribute to
    function validatePaymentAmount(
        uint256 amount,
        Types.PaymentSplit memory split,
        uint256 operatorCount
    ) internal pure {
        if (amount == 0) return; // Zero payments are allowed (no-op)

        // Check minimum amount to ensure non-zero payments
        if (amount < MINIMUM_PAYMENT_AMOUNT) {
            revert Errors.PaymentTooSmall(amount, MINIMUM_PAYMENT_AMOUNT);
        }

        // Ensure each non-zero split recipient gets at least 1 wei
        if (split.developerBps > 0 && (amount * split.developerBps) / BPS_DENOMINATOR == 0) {
            revert Errors.PaymentTooSmall(amount, (BPS_DENOMINATOR + split.developerBps - 1) / split.developerBps);
        }
        if (split.protocolBps > 0 && (amount * split.protocolBps) / BPS_DENOMINATOR == 0) {
            revert Errors.PaymentTooSmall(amount, (BPS_DENOMINATOR + split.protocolBps - 1) / split.protocolBps);
        }

        // For operators, ensure each operator gets at least 1 wei if there are operators
        if (operatorCount > 0 && split.operatorBps > 0) {
            uint256 operatorAmount = (amount * split.operatorBps) / BPS_DENOMINATOR;
            if (operatorAmount / operatorCount == 0) {
                // Calculate minimum: need operatorCount wei in operator pool
                uint256 minForOperators = (operatorCount * BPS_DENOMINATOR + split.operatorBps - 1) / split.operatorBps;
                revert Errors.PaymentTooSmall(amount, minForOperators);
            }
        }
    }

    /// @notice Get the minimum payment constant
    /// @return The minimum payment amount
    function getMinimumPaymentAmount() internal pure returns (uint256) {
        return MINIMUM_PAYMENT_AMOUNT;
    }
}
