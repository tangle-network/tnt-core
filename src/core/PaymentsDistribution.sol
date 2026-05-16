// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { PaymentsCore } from "./PaymentsCore.sol";
import { PaymentsEffectiveExposure } from "./PaymentsEffectiveExposure.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";
import { IStaking } from "../interfaces/IStaking.sol";
import { ITanglePaymentsInternal } from "../interfaces/ITanglePaymentsInternal.sol";

/// @title PaymentsDistribution
/// @notice Sole owner of bill distribution: shared distribute path, exposure-weighted entry,
///         keeper-rebate entry, and the staker-share routing to the fee distributor.
/// @dev Lives on the dedicated distribution facet so the billing facet does not inline this
///      machinery. The subscription billing path reaches it via a self-call through the
///      diamond (`ITanglePaymentsInternal.distributeBillWithKeeper`).
abstract contract PaymentsDistribution is PaymentsCore, PaymentsEffectiveExposure {
    using EnumerableSet for EnumerableSet.AddressSet;

    /// @notice Emitted on every bill caller's keeper rebate.
    event KeeperRebateAccrued(uint64 indexed serviceId, address indexed keeper, address indexed token, uint256 amount);
    /// @notice Emitted when the staker pool's share could not be routed (no distributor configured,
    ///         or the distributor reverted). The amount is refunded to the service escrow so the
    ///         customer can recover it, rather than being silently captured by the treasury.
    event StakerShareRefundedToEscrow(
        uint64 indexed serviceId, address indexed operator, address indexed token, uint256 amount, bytes reason
    );
    /// @notice Emitted when a push transfer to a non-pull recipient (developer, TNT discount,
    ///         treasury) reverted on-receive. The diverted amount is folded into the operator
    ///         pool so distribution still completes and no funds are stranded in escrow.
    event PushTransferFailed(
        uint64 indexed serviceId, address indexed recipient, address indexed token, uint256 amount, bytes32 destination
    );
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
    event TntPaymentDiscountApplied(
        uint64 indexed serviceId, address indexed recipient, address indexed token, uint256 amount
    );

    bytes32 private constant PUSH_DEST_DEVELOPER = "developer";
    bytes32 private constant PUSH_DEST_TREASURY = "treasury";
    bytes32 private constant PUSH_DEST_TNT_DISCOUNT = "tnt-discount";

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
            ITanglePaymentsInternal.BillDistribution({
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

    /// @notice Initialize per-(operator, asset) TWAP cursors and pin the multi-asset baseline.
    /// @dev Walks each operator's `AssetSecurityCommitment[]` and seeds cursors for every
    ///      (op, asset) pair. Baseline is the exposure-weighted aggregate
    ///      `Σ_op Σ_asset (delegation × commitmentBps)`, USD-normalized when a price oracle
    ///      is configured. Pinned once at activation; subsequent bills measure against this
    ///      snapshot so an operator cannot inflate the customer's bill by ramping stake on
    ///      a single asset post-activation.
    function _initSubscriptionBaseline(uint64 serviceId, address[] calldata operators) internal {
        IStaking staking = _staking;
        address oracleAddr = _priceOracle;
        bool useOracle = oracleAddr != address(0);
        Types.Asset memory bondAsset = _bondAssetForBilling();

        uint256 baseline;
        uint256 n = operators.length;
        for (uint256 i = 0; i < n;) {
            address op = operators[i];
            Types.AssetSecurityCommitment[] storage commitments = _serviceSecurityCommitments[serviceId][op];
            uint256 m = commitments.length;
            if (m == 0) {
                bytes32 assetHash = keccak256(abi.encode(bondAsset.kind, bondAsset.token));
                (uint256 cumOp,, uint256 stakeOp) = staking.getCumStakeSeconds(op, bondAsset);
                _twapCursorByOpAsset[serviceId][op][assetHash] = cumOp == 0 ? 1 : cumOp;
                uint16 fallbackBps = _serviceOperators[serviceId][op].exposureBps;
                if (fallbackBps == 0) fallbackBps = uint16(BPS_DENOMINATOR);
                uint256 exposedAmount = (stakeOp * uint256(fallbackBps)) / BPS_DENOMINATOR;
                address token = bondAsset.kind == Types.AssetKind.Native ? address(0) : bondAsset.token;
                _snapshotBaselinePrice(serviceId, op, assetHash, oracleAddr, token);
                if (useOracle && exposedAmount > 0) {
                    baseline += _safeToUSD(oracleAddr, token, exposedAmount);
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
                    address token = c.asset.kind == Types.AssetKind.Native ? address(0) : c.asset.token;
                    _snapshotBaselinePrice(serviceId, op, assetHash, oracleAddr, token);
                    if (useOracle && exposedAmount > 0) {
                        baseline += _safeToUSD(oracleAddr, token, exposedAmount);
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

    /// @notice Record the activation-time USD-per-1e18-token snapshot for (serviceId, op, asset).
    /// @dev Skip if no oracle is configured. Skip if a snapshot already exists for this
    ///      triple (operators rejoining after a leave reuse their original activation
    ///      snapshot so a price ramp during the absence cannot game the rejoin). The
    ///      stored value is `_safeToUSDView(oracle, token, 1e18)` — see
    ///      `_baselinePriceByOpAsset` storage docs for the conversion formula at bill
    ///      time. A failed oracle query stores `1e18` (identity scale) so the bill path
    ///      degrades to raw token-second weighting for that (op, asset).
    function _snapshotBaselinePrice(
        uint64 serviceId,
        address op,
        bytes32 assetHash,
        address oracleAddr,
        address token
    )
        internal
    {
        if (oracleAddr == address(0)) return;
        if (_baselinePriceByOpAsset[serviceId][op][assetHash] != 0) return;
        uint256 priceUsd = _safeToUSDView(oracleAddr, token, 1 ether);
        // Identity (== 1 ether) means the oracle either reverted or is disabled for
        // this token. Treat as raw-weighting fallback by storing a sentinel that the
        // bill-time conversion (contribution * snapshot / 1 ether) recognizes as
        // identity. Storing 1 ether is exactly the identity scale.
        _baselinePriceByOpAsset[serviceId][op][assetHash] = priceUsd == 0 ? 1 ether : priceUsd;
    }

    /// @notice Calculate effective exposures with fallback to stored exposureBps
    /// @dev When operators have no security commitments, falls back to the exposureBps
    ///      stored on their ServiceOperator record for proportional distribution.
    function _calculateEffectiveExposuresWithFallback(
        uint64 serviceId,
        address[] memory operators
    )
        internal
        view
        returns (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure, bool hasSecurityCommitments)
    {
        (effectiveExposures, totalEffectiveExposure) = _calculateEffectiveExposures(serviceId, operators);

        hasSecurityCommitments = totalEffectiveExposure > 0;

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
    // SHARED DISTRIBUTION CORE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute a bill to (developer, protocol, operator pool, staker pool, keeper).
    /// @dev Single distribution path shared between subscription bills (keeper present, TWAP
    ///      weights) and non-subscription payments (no keeper, exposure-based weights). The
    ///      caller is responsible for computing weights — this function does not assume any
    ///      particular fairness model for the operator pool.
    function _distributeBill(ITanglePaymentsInternal.BillDistribution memory d) internal {
        if (d.amount == 0) return;
        if (d.operators.length == 0) revert Errors.NoOperators();

        bool includeKeeper = d.keeper != address(0);
        if (d.totalWeight == 0) revert Errors.InvalidState();
        PaymentLib.PaymentAmounts memory amounts = PaymentLib.calculateSplit(d.amount, _paymentSplit, includeKeeper);

        // Developer payment (manager can override the destination). Push is best-effort:
        // a malicious BSM that resolves a reverting recipient cannot brick distribution
        // for the rest of the pool — the un-sent amount folds into the operator pool.
        Types.Blueprint storage bp = _blueprints[d.blueprintId];
        Types.Service storage svc = _services[d.serviceId];
        address developerAddr = _resolveDeveloperPaymentAddress(bp.manager, bp.owner, d.serviceId);
        uint256 developerPaid = amounts.developerAmount;
        if (developerPaid > 0 && !PaymentLib.tryTransferPayment(developerAddr, d.token, developerPaid)) {
            emit PushTransferFailed(d.serviceId, developerAddr, d.token, developerPaid, PUSH_DEST_DEVELOPER);
            amounts.developerAmount = 0;
            amounts.operatorAmount += developerPaid;
        }

        // TNT payment discount: funded from the protocol share, paid to the service owner.
        if (
            d.token != address(0) && d.token == _tntToken && _tntPaymentDiscountBps > 0 && amounts.protocolAmount > 0
                && svc.owner != address(0)
        ) {
            uint256 desired = (d.amount * _tntPaymentDiscountBps) / BPS_DENOMINATOR;
            uint256 discount = desired > amounts.protocolAmount ? amounts.protocolAmount : desired;
            if (discount > 0) {
                amounts.protocolAmount -= discount;
                if (PaymentLib.tryTransferPayment(svc.owner, d.token, discount)) {
                    emit TntPaymentDiscountApplied(d.serviceId, svc.owner, d.token, discount);
                } else {
                    emit PushTransferFailed(d.serviceId, svc.owner, d.token, discount, PUSH_DEST_TNT_DISCOUNT);
                    amounts.operatorAmount += discount;
                }
            }
        }

        if (amounts.protocolAmount > 0 && !PaymentLib.tryTransferPayment(_treasury, d.token, amounts.protocolAmount)) {
            emit PushTransferFailed(d.serviceId, _treasury, d.token, amounts.protocolAmount, PUSH_DEST_TREASURY);
            amounts.operatorAmount += amounts.protocolAmount;
            amounts.protocolAmount = 0;
        }

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
        ITanglePaymentsInternal.BillDistribution memory d,
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

    /// @notice Route the staker pool's per-operator share through the fee distributor.
    /// @dev When the distributor is unset OR reverts, the share is refunded to the service
    ///      escrow rather than silently captured by the treasury.
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
            // and protocol to handle off-chain.
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
        if (escrow.token != token) {
            PaymentLib.transferPayment(_treasury, token, amount);
            return;
        }
        escrow.balance += amount;
        if (escrow.totalReleased >= amount) {
            escrow.totalReleased -= amount;
        } else {
            escrow.totalReleased = 0;
        }
        emit StakerShareRefundedToEscrow(serviceId, operator, token, amount, reason);
    }

    /// @notice Resolve the developer payment recipient via a gas-capped manager hook.
    /// @dev Bounded gas, raw staticcall, fall back to `blueprintOwner` on revert / empty / zero.
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
