// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PaymentsCore } from "./PaymentsCore.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";

/// @title PaymentsEscrow
/// @notice Customer-facing escrow funding and post-termination withdrawal.
abstract contract PaymentsEscrow is PaymentsCore {
    using PaymentLib for PaymentLib.ServiceEscrow;

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
