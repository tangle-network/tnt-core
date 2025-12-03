// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Payments
/// @notice Payment distribution, escrow, and rewards
abstract contract Payments is Base {
    using EnumerableSet for EnumerableSet.AddressSet;
    using PaymentLib for PaymentLib.ServiceEscrow;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event EscrowFunded(uint64 indexed serviceId, address indexed token, uint256 amount);
    event SubscriptionBilled(uint64 indexed serviceId, uint256 amount, uint64 period);
    event RewardsClaimed(address indexed account, address indexed token, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // ESCROW MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fund a service's escrow
    function fundService(
        uint64 serviceId,
        uint256 amount
    ) external payable nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.pricing != Types.PricingModel.Subscription) {
            revert Errors.InvalidState();
        }

        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        address token = escrow.token;

        PaymentLib.depositToEscrow(escrow, token, amount, msg.value);

        // Refund excess ETH for native token payments
        if (token == address(0) && msg.value > amount) {
            PaymentLib.transferPayment(msg.sender, address(0), msg.value - amount);
        }

        emit EscrowFunded(serviceId, token, amount);
    }

    /// @notice Bill a subscription service
    /// @dev Anyone can call this to trigger billing; no incentive for single billing
    function billSubscription(uint64 serviceId) external nonReentrant {
        _billSubscriptionInternal(serviceId);
    }

    /// @notice Batch bill multiple subscription services
    /// @dev Recipients (operators, developers, restakers) are naturally incentivized to call this
    /// @param serviceIds Array of service IDs to bill
    /// @return totalBilled Total amount billed across all services
    /// @return billedCount Number of services successfully billed
    function billSubscriptionBatch(uint64[] calldata serviceIds) external nonReentrant returns (uint256 totalBilled, uint256 billedCount) {
        if (serviceIds.length == 0) revert Errors.ZeroAmount();

        for (uint256 i = 0; i < serviceIds.length; i++) {
            if (_tryBillSubscription(serviceIds[i])) {
                Types.BlueprintConfig storage bpConfig = _blueprintConfigs[_services[serviceIds[i]].blueprintId];
                totalBilled += bpConfig.subscriptionRate;
                billedCount++;
            }
        }
    }

    /// @notice Get services that are billable (past their billing interval)
    /// @param serviceIds Array of service IDs to check
    /// @return billable Array of service IDs that can be billed
    function getBillableServices(uint64[] calldata serviceIds) external view returns (uint64[] memory billable) {
        uint64[] memory temp = new uint64[](serviceIds.length);
        uint256 count = 0;

        for (uint256 i = 0; i < serviceIds.length; i++) {
            if (_isBillable(serviceIds[i])) {
                temp[count++] = serviceIds[i];
            }
        }

        billable = new uint64[](count);
        for (uint256 i = 0; i < count; i++) {
            billable[i] = temp[i];
        }
    }

    /// @notice Internal billing logic with TTL check
    function _billSubscriptionInternal(uint64 serviceId) internal {
        Types.Service storage svc = _getService(serviceId);
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.pricing != Types.PricingModel.Subscription) {
            revert Errors.InvalidState();
        }

        // TTL check - cannot bill expired services
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) {
            revert Errors.ServiceExpired(serviceId);
        }

        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[svc.blueprintId];
        uint64 interval = bpConfig.subscriptionInterval;
        uint256 rate = bpConfig.subscriptionRate;

        if (block.timestamp < svc.lastPaymentAt + interval) {
            revert Errors.DeadlineExpired();
        }

        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        if (escrow.balance < rate) {
            revert Errors.InsufficientEscrowBalance(rate, escrow.balance);
        }

        address token = PaymentLib.releaseFromEscrow(escrow, rate);
        svc.lastPaymentAt = uint64(block.timestamp);

        address[] memory operators = _serviceOperatorSet[serviceId].values();
        uint16[] memory exposures = new uint16[](operators.length);
        uint256 totalExposure = 0;

        for (uint256 i = 0; i < operators.length; i++) {
            exposures[i] = _serviceOperators[serviceId][operators[i]].exposureBps;
            totalExposure += exposures[i];
        }

        _distributePayment(serviceId, svc.blueprintId, token, rate, operators, exposures, totalExposure);

        emit SubscriptionBilled(serviceId, rate, interval);
    }

    /// @notice Try to bill a subscription, returns false on failure instead of reverting
    function _tryBillSubscription(uint64 serviceId) internal returns (bool) {
        if (!_isBillable(serviceId)) return false;

        Types.Service storage svc = _services[serviceId];
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[svc.blueprintId];
        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];

        uint256 rate = bpConfig.subscriptionRate;
        if (escrow.balance < rate) return false;

        address token = PaymentLib.releaseFromEscrow(escrow, rate);
        svc.lastPaymentAt = uint64(block.timestamp);

        address[] memory operators = _serviceOperatorSet[serviceId].values();
        uint16[] memory exposures = new uint16[](operators.length);
        uint256 totalExposure = 0;

        for (uint256 i = 0; i < operators.length; i++) {
            exposures[i] = _serviceOperators[serviceId][operators[i]].exposureBps;
            totalExposure += exposures[i];
        }

        _distributePayment(serviceId, svc.blueprintId, token, rate, operators, exposures, totalExposure);

        emit SubscriptionBilled(serviceId, rate, bpConfig.subscriptionInterval);
        return true;
    }

    /// @notice Check if a service is billable
    function _isBillable(uint64 serviceId) internal view returns (bool) {
        Types.Service storage svc = _services[serviceId];

        // Must be active subscription
        if (svc.status != Types.ServiceStatus.Active) return false;
        if (svc.pricing != Types.PricingModel.Subscription) return false;

        // Must not be expired (TTL check)
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) return false;

        // Must be past billing interval
        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[svc.blueprintId];
        if (block.timestamp < svc.lastPaymentAt + bpConfig.subscriptionInterval) return false;

        return true;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARDS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim pending rewards (native token)
    function claimRewards() external nonReentrant {
        uint256 claimed = PaymentLib.claimPendingReward(_pendingRewards, msg.sender, address(0));
        if (claimed > 0) {
            emit RewardsClaimed(msg.sender, address(0), claimed);
        }
    }

    /// @notice Claim pending rewards for specific token
    function claimRewards(address token) external nonReentrant {
        uint256 claimed = PaymentLib.claimPendingReward(_pendingRewards, msg.sender, token);
        if (claimed > 0) {
            emit RewardsClaimed(msg.sender, token, claimed);
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

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set payment split
    function setPaymentSplit(Types.PaymentSplit calldata split) external onlyRole(ADMIN_ROLE) {
        PaymentLib.validateSplit(split);
        _paymentSplit = split;
    }

    /// @notice Set treasury
    function setTreasury(address payable treasury_) external onlyRole(ADMIN_ROLE) {
        if (treasury_ == address(0)) revert Errors.ZeroAddress();
        _treasury = treasury_;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW
    // ═══════════════════════════════════════════════════════════════════════════

    function paymentSplit() external view returns (uint16, uint16, uint16, uint16) {
        return (_paymentSplit.developerBps, _paymentSplit.protocolBps, _paymentSplit.operatorBps, _paymentSplit.restakerBps);
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

    /// @notice Distribute payment to all stakeholders
    function _distributePayment(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] memory operators,
        uint16[] memory exposures,
        uint256 totalExposure
    ) internal {
        if (amount == 0) return;

        Types.Blueprint storage bp = _blueprints[blueprintId];

        PaymentLib.PaymentAmounts memory amounts = PaymentLib.calculateSplit(amount, _paymentSplit);

        // Developer payment
        address developerAddr = bp.owner;
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).queryDeveloperPaymentAddress(serviceId) returns (address payable devAddr) {
                if (devAddr != address(0)) developerAddr = devAddr;
            } catch {}
        }
        PaymentLib.transferPayment(developerAddr, token, amounts.developerAmount);

        // Protocol payment
        PaymentLib.transferPayment(_treasury, token, amounts.protocolAmount);

        // Operator and restaker payments
        if (totalExposure > 0) {
            PaymentLib.OperatorPayment[] memory opPayments = PaymentLib.calculateOperatorPayments(
                amounts.operatorAmount,
                amounts.restakerAmount,
                operators,
                exposures,
                totalExposure
            );

            for (uint256 i = 0; i < opPayments.length; i++) {
                PaymentLib.addPendingReward(
                    _pendingRewards,
                    opPayments[i].operator,
                    token,
                    opPayments[i].operatorShare
                );

                if (opPayments[i].restakerShare > 0) {
                    PaymentLib.transferPayment(address(_restaking), token, opPayments[i].restakerShare);
                    _restaking.notifyReward(
                        opPayments[i].operator,
                        serviceId,
                        opPayments[i].restakerShare
                    );
                }
            }
        }
    }
}
