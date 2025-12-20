// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingRewardsFacet
/// @notice Facet for reward distribution and claims
contract RestakingRewardsFacet is RestakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](5);
        selectorList[0] = this.notifyRewardForBlueprint.selector;
        selectorList[1] = this.notifyReward.selector;
        selectorList[2] = this.claimDelegatorRewards.selector;
        selectorList[3] = this.claimOperatorRewards.selector;
        selectorList[4] = this.claimOperatorRewardsTo.selector;
    }

    /// @notice Notify reward for an operator from a specific blueprint
    /// @dev Routes rewards to appropriate pools based on delegator blueprint exposure
    function notifyRewardForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount
    )
        external
    {
        serviceId; // silence unused warning
        _notifyRewardForBlueprint(operator, blueprintId, amount);
    }

    /// @notice Notify reward for an operator (legacy - all delegators get rewards)
    function notifyReward(address operator, uint64 serviceId, uint256 amount) external {
        serviceId; // silence unused warning
        _notifyReward(operator, amount);
    }

    /// @notice Claim delegator rewards
    function claimDelegatorRewards() external nonReentrant returns (uint256 totalRewards) {
        _tryAdvanceRound();
        totalRewards = _claimDelegatorRewards();
    }

    /// @notice Claim operator rewards
    function claimOperatorRewards() external nonReentrant {
        _claimOperatorRewards(payable(msg.sender));
    }

    /// @notice Claim operator rewards to a specific recipient (useful for contracts without receive hooks)
    function claimOperatorRewardsTo(address payable recipient) external nonReentrant {
        _claimOperatorRewards(recipient);
    }
}
