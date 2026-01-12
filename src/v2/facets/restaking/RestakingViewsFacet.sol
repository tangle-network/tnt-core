// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingViewsFacet
/// @notice Facet for restaking view functions
contract RestakingViewsFacet is RestakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](25);
        selectorList[0] = this.isOperator.selector;
        selectorList[1] = this.isOperatorActive.selector;
        selectorList[2] = this.getOperatorStake.selector;
        selectorList[3] = this.getOperatorSelfStake.selector;
        selectorList[4] = this.getOperatorDelegatedStake.selector;
        selectorList[5] = this.getDelegation.selector;
        selectorList[6] = this.getTotalDelegation.selector;
        selectorList[7] = this.minOperatorStake.selector;
        selectorList[8] = this.meetsStakeRequirement.selector;
        selectorList[9] = this.isSlasher.selector;
        selectorList[10] = this.getOperatorMetadata.selector;
        selectorList[11] = this.getOperatorBlueprints.selector;
        selectorList[12] = this.operatorCount.selector;
        selectorList[13] = this.operatorAt.selector;
        selectorList[14] = this.getDeposit.selector;
        selectorList[15] = this.getPendingWithdrawals.selector;
        selectorList[16] = this.getLocks.selector;
        selectorList[17] = this.getDelegations.selector;
        selectorList[18] = this.getDelegationBlueprints.selector;
        selectorList[19] = this.getPendingUnstakes.selector;
        selectorList[20] = this.getOperatorRewardPool.selector;
        selectorList[21] = this.getOperatorDelegators.selector;
        selectorList[22] = this.getOperatorDelegatorCount.selector;
        selectorList[23] = this.rewardsManager.selector;
        selectorList[24] = this.serviceFeeDistributor.selector;
    }

    function isOperator(address operator) external view returns (bool) {
        return _isOperator(operator);
    }

    function isOperatorActive(address operator) external view returns (bool) {
        return _isOperatorActive(operator);
    }

    function getOperatorStake(address operator) external view returns (uint256) {
        return _getOperatorSelfStake(operator) + _rewardPools[operator].totalAssets;
    }

    function getOperatorSelfStake(address operator) external view returns (uint256) {
        return _getOperatorSelfStake(operator);
    }

    function getOperatorDelegatedStake(address operator) external view returns (uint256) {
        return _rewardPools[operator].totalAssets;
    }

    function getDelegation(address delegator, address operator) external view returns (uint256) {
        return _getDelegationToOperator(delegator, operator);
    }

    function getTotalDelegation(address delegator) external view returns (uint256 total) {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            // Convert shares to underlying amount at current exchange rate
            total += _sharesToAmount(d.operator, d.shares);
        }
    }

    function minOperatorStake() external view returns (uint256) {
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        return _assetConfigs[nativeHash].minOperatorStake;
    }

    function meetsStakeRequirement(address operator, uint256 required) external view returns (bool) {
        return _getOperatorSelfStake(operator) >= required;
    }

    function isSlasher(address account) external view returns (bool) {
        return hasRole(SLASHER_ROLE, account);
    }

    /// @notice Get operator metadata
    function getOperatorMetadata(address operator) external view returns (Types.OperatorMetadata memory) {
        return _getOperatorMetadata(operator);
    }

    /// @notice Get operator blueprints
    function getOperatorBlueprints(address operator) external view returns (uint256[] memory) {
        return _getOperatorBlueprints(operator);
    }

    /// @notice Get total operator count
    function operatorCount() external view returns (uint256) {
        return _operatorCount();
    }

    /// @notice Get operator at index
    function operatorAt(uint256 index) external view returns (address) {
        return _operatorAt(index);
    }

    /// @notice Get deposit for a delegator and token
    function getDeposit(address delegator, address token) external view returns (Types.Deposit memory) {
        return _getDeposit(delegator, token);
    }

    /// @notice Get pending withdrawals
    function getPendingWithdrawals(address delegator) external view returns (Types.WithdrawRequest[] memory) {
        return _getPendingWithdrawals(delegator);
    }

    /// @notice Get locks for a delegator
    function getLocks(address delegator, address token) external view returns (Types.LockInfo[] memory) {
        return _getLocks(delegator, token);
    }

    /// @notice Get all delegations for a delegator
    function getDelegations(address delegator) external view returns (Types.BondInfoDelegator[] memory) {
        return _getDelegations(delegator);
    }

    /// @notice Get delegation blueprints
    function getDelegationBlueprints(address delegator, uint256 idx) external view returns (uint64[] memory) {
        return _getDelegationBlueprints(delegator, idx);
    }

    /// @notice Get pending unstakes
    function getPendingUnstakes(address delegator) external view returns (Types.BondLessRequest[] memory) {
        return _getPendingUnstakes(delegator);
    }

    /// @notice Get operator reward pool
    function getOperatorRewardPool(address operator) external view returns (Types.OperatorRewardPool memory) {
        return _getOperatorRewardPool(operator);
    }

    /// @notice Get all delegators for an operator
    /// @param operator The operator address
    /// @return delegators Array of delegator addresses
    function getOperatorDelegators(address operator) external view returns (address[] memory) {
        return _getOperatorDelegators(operator);
    }

    /// @notice Get the number of delegators for an operator
    function getOperatorDelegatorCount(address operator) external view returns (uint256) {
        return _getOperatorDelegatorCount(operator);
    }

    /// @notice Get the rewards manager address
    function rewardsManager() external view returns (address) {
        return _rewardsManager;
    }

    /// @notice Get the service-fee distributor address
    function serviceFeeDistributor() external view returns (address) {
        return _serviceFeeDistributor;
    }
}
