// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PaymentsCore } from "./PaymentsCore.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";

/// @title PaymentsRefund
/// @notice Post-termination escrow refund path.
/// @dev Extracted from `PaymentsEscrow` so the customer-facing funding + billing
///      facet stays under the EIP-170 24576-byte runtime limit. Withdrawal is a
///      rare-path operation conceptually closer to the rewards/admin surface and
///      therefore lives on `TanglePaymentsRewardsFacet`.
abstract contract PaymentsRefund is PaymentsCore {
    /// @notice Withdraw remaining escrow balance after service termination.
    /// @dev Equivalent to `withdrawRemainingEscrowTo(serviceId, svc.owner)` — the
    ///      service owner remains the default recipient. Use the `To` variant
    ///      when the service owner has been blocklisted by the escrow token or
    ///      otherwise cannot receive on the owner address.
    function withdrawRemainingEscrow(uint64 serviceId) external nonReentrant {
        _withdrawRemainingEscrow(serviceId, payable(_getService(serviceId).owner));
    }

    /// @notice Withdraw remaining escrow balance to a service-owner-chosen address.
    /// @dev Caller must be the service owner. The recipient is arbitrary, so a
    ///      service owner blocklisted by the escrow token (or operating from a
    ///      smart-account that cannot receive directly) can still recover funds
    ///      by routing to a fresh address.
    function withdrawRemainingEscrowTo(uint64 serviceId, address payable to) external nonReentrant {
        if (to == address(0)) revert Errors.ZeroAddress();
        _withdrawRemainingEscrow(serviceId, to);
    }

    function _withdrawRemainingEscrow(uint64 serviceId, address payable to) private {
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

        PaymentLib.transferPayment(to, token, remaining);
        emit EscrowRefunded(serviceId, to, token, remaining);
    }
}
