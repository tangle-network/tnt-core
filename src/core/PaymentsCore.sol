// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";

/// @title PaymentsCore
/// @notice Shared events and lightweight helpers for the payment subsystem.
/// @dev Holds the events emitted by both billing and distribution paths, the active-operator
///      enumeration helper used by billing, and the escrow deposit helper used by event-driven
///      flows. Distribution machinery (`_distributeBill` and downstream) lives in
///      `PaymentsDistribution` and is reached from billing via a diamond self-call so the
///      billing facet does not inline its bytecode.
abstract contract PaymentsCore is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

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
    /// @notice Emitted when a Subscription-pricing service has its per-operator TWAP cursors
    ///         and `subscriptionBaselineStake` seeded at activation. Indexers / off-chain
    ///         observers can subscribe here to track when the bill contract is locked in.
    event SubscriptionBaselineInitialized(uint64 indexed serviceId, uint256 baselineStake, uint256 operatorCount);

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

    /// @notice Deposit to escrow.
    function _depositToEscrow(uint64 serviceId, address token, uint256 amount) internal {
        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        escrow.token = token;
        escrow.balance += amount;
        escrow.totalDeposited += amount;
        emit EscrowFunded(serviceId, token, amount);
    }
}
