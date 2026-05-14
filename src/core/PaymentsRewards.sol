// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";

/// @title PaymentsRewards
/// @notice Rewards claim + payment-split / treasury admin + escrow views.
/// @dev Split out from `Payments` so a dedicated facet can host these selectors
///      without dragging in the subscription-billing and distribution machinery.
///      All storage is shared with `Payments` via `Base`/`TangleStorage` slots.
abstract contract PaymentsRewards is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    event RewardsClaimed(address indexed account, address indexed token, uint256 amount);

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

    /// @notice Filter `serviceIds` down to those eligible for a subscription bill right now.
    /// @dev Mirrors `_billSubscriptionImpl`'s pre-conditions: active + subscription-priced +
    ///      baseline-seeded, past TTL guard, past billing interval, AND escrow can cover the
    ///      nominal rate (cap-at-nominal means a real bill never exceeds `subscriptionRate`).
    ///      Off-chain keepers use this to avoid burning gas on bills that will not draw.
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

    function _isBillable(uint64 serviceId) internal view returns (bool) {
        Types.Service storage svc = _services[serviceId];
        if (svc.status != Types.ServiceStatus.Active) return false;
        if (svc.pricing != Types.PricingModel.Subscription) return false;
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) return false;

        Types.BlueprintConfig storage bpConfig = _blueprintConfigs[svc.blueprintId];
        if (block.timestamp < svc.lastPaymentAt + bpConfig.subscriptionInterval) return false;

        PaymentLib.ServiceEscrow storage escrow = _serviceEscrows[serviceId];
        if (escrow.subscriptionBaselineStake == 0) return false;
        if (escrow.balance < bpConfig.subscriptionRate) return false;

        return true;
    }
}
