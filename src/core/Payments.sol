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
    event SubscriptionBilled(uint64 indexed serviceId, uint256 amount, uint64 period);
    event RewardsClaimed(address indexed account, address indexed token, uint256 amount);
    event TntPaymentDiscountApplied(uint64 indexed serviceId, address indexed recipient, address indexed token, uint256 amount);

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
        _recordPayment(msg.sender, serviceId, token, amount);
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
        uint256 serviceIdsLength = serviceIds.length;
        if (serviceIdsLength == 0) revert Errors.ZeroAmount();

        for (uint256 i = 0; i < serviceIdsLength;) {
            if (_tryBillSubscription(serviceIds[i])) {
                Types.BlueprintConfig storage bpConfig = _blueprintConfigs[_services[serviceIds[i]].blueprintId];
                totalBilled += bpConfig.subscriptionRate;
                billedCount++;
            }
            unchecked { ++i; }
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
            unchecked { ++i; }
        }

        billable = new uint64[](count);
        for (uint256 i = 0; i < count;) {
            billable[i] = temp[i];
            unchecked { ++i; }
        }
    }

    /// @notice Internal billing logic with TTL check
    /// @dev Uses effective exposure (delegation × exposureBps) for proportional payment distribution
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
        
        // Calculate effective exposures based on actual delegations
        (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure) = 
            _calculateEffectiveExposures(serviceId, operators);

        _distributePaymentWithEffectiveExposure(
            serviceId, 
            svc.blueprintId, 
            token, 
            rate, 
            operators, 
            effectiveExposures, 
            totalEffectiveExposure
        );

        emit SubscriptionBilled(serviceId, rate, interval);
    }

    /// @notice Try to bill a subscription, returns false on failure instead of reverting
    /// @dev Uses effective exposure (delegation × exposureBps) for proportional payment distribution
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
        
        // Calculate effective exposures based on actual delegations
        (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure) = 
            _calculateEffectiveExposures(serviceId, operators);

        _distributePaymentWithEffectiveExposure(
            serviceId, 
            svc.blueprintId, 
            token, 
            rate, 
            operators, 
            effectiveExposures, 
            totalEffectiveExposure
        );

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
            unchecked { ++i; }
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
            unchecked { ++i; }
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
        emit PaymentSplitUpdated(split.developerBps, split.protocolBps, split.operatorBps, split.stakerBps);
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

    function paymentSplit() external view returns (uint16, uint16, uint16, uint16) {
        return (_paymentSplit.developerBps, _paymentSplit.protocolBps, _paymentSplit.operatorBps, _paymentSplit.stakerBps);
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

    /// @notice Distribute payment to all stakeholders using effective exposures
    /// @dev Effective exposure = delegation × exposureBps, ensuring operators are paid
    ///      proportionally to actual security capital at risk
    /// @param serviceId The service ID
    /// @param blueprintId The blueprint ID
    /// @param token Payment token
    /// @param amount Total payment amount
    /// @param operators Array of operator addresses
    /// @param effectiveExposures Array of effective exposure values (delegation × exposureBps)
    /// @param totalEffectiveExposure Sum of all effective exposures
    function _distributePaymentWithEffectiveExposure(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] memory operators,
        uint256[] memory effectiveExposures,
        uint256 totalEffectiveExposure
    ) internal {
        if (amount == 0) return;

        // M-5 FIX: Validate payment amount is sufficient to prevent rounding to zero
        PaymentLib.validatePaymentAmount(amount, _paymentSplit, operators.length);

        Types.Blueprint storage bp = _blueprints[blueprintId];
        Types.Service storage svc = _services[serviceId];

        PaymentLib.PaymentAmounts memory amounts = PaymentLib.calculateSplit(amount, _paymentSplit);

        // Developer payment
        address developerAddr = bp.owner;
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).queryDeveloperPaymentAddress(serviceId) returns (address payable devAddr) {
                if (devAddr != address(0)) developerAddr = devAddr;
            } catch {}
        }
        PaymentLib.transferPayment(developerAddr, token, amounts.developerAmount);

        // TNT payment discount (funded from protocol share; sent to service owner)
        if (
            token != address(0) &&
            token == _tntToken &&
            _tntPaymentDiscountBps > 0 &&
            amounts.protocolAmount > 0 &&
            svc.owner != address(0)
        ) {
            uint256 desiredDiscount = (amount * _tntPaymentDiscountBps) / BPS_DENOMINATOR;
            uint256 discount = desiredDiscount > amounts.protocolAmount ? amounts.protocolAmount : desiredDiscount;
            if (discount > 0) {
                amounts.protocolAmount -= discount;
                PaymentLib.transferPayment(svc.owner, token, discount);
                emit TntPaymentDiscountApplied(serviceId, svc.owner, token, discount);
            }
        }

        // Protocol payment
        PaymentLib.transferPayment(_treasury, token, amounts.protocolAmount);

        // Operator and restaker payments - proportional to effective exposure
        if (totalEffectiveExposure > 0) {
            PaymentLib.OperatorPayment[] memory opPayments = PaymentLib.calculateOperatorPayments(
                amounts.operatorAmount,
                amounts.restakerAmount,
                operators,
                effectiveExposures,
                totalEffectiveExposure
            );

            uint256 opPaymentsLength = opPayments.length;
            for (uint256 i = 0; i < opPaymentsLength;) {
                PaymentLib.addPendingReward(
                    _pendingRewards,
                    opPayments[i].operator,
                    token,
                    opPayments[i].operatorShare
                );
                if (opPayments[i].operatorShare > 0) {
                    _pendingRewardTokens[opPayments[i].operator].add(token);
                }

                if (opPayments[i].restakerShare > 0) {
                    _forwardRestakerShare(
                        serviceId,
                        blueprintId,
                        opPayments[i].operator,
                        token,
                        opPayments[i].restakerShare
                    );
                }
                unchecked { ++i; }
            }
        }
    }

    /// @notice Legacy distribute payment function for backward compatibility
    /// @dev DEPRECATED: Use _distributePaymentWithEffectiveExposure for proper security-weighted payments
    function _distributePayment(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] memory operators,
        uint16[] memory exposures,
        uint256 totalExposure
    ) internal {
        // Convert to effective exposures for backward compatibility
        uint256[] memory effectiveExposures = new uint256[](operators.length);
        for (uint256 i = 0; i < operators.length; i++) {
            effectiveExposures[i] = exposures[i];
        }
        _distributePaymentWithEffectiveExposure(
            serviceId,
            blueprintId,
            token,
            amount,
            operators,
            effectiveExposures,
            totalExposure
        );
    }

    function _forwardRestakerShare(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address token,
        uint256 amount
    ) private {
        address distributor = _serviceFeeDistributor;
        if (distributor == address(0)) {
            PaymentLib.transferPayment(_treasury, token, amount);
            return;
        }

        if (token == address(0)) {
            IServiceFeeDistributor(distributor).distributeServiceFee{ value: amount }(
                serviceId,
                blueprintId,
                operator,
                token,
                amount
            );
        } else {
            PaymentLib.transferPayment(distributor, token, amount);
            IServiceFeeDistributor(distributor).distributeServiceFee(
                serviceId,
                blueprintId,
                operator,
                token,
                amount
            );
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
    ) internal view override returns (Types.AssetSecurityCommitment[] storage) {
        return _serviceSecurityCommitments[serviceId][operator];
    }
}
