// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { DelegationErrors } from "../../restaking/DelegationErrors.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingViewsFacet
/// @notice Facet for restaking view functions
contract RestakingViewsFacet is RestakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](29);
        selectorList[0] = this.isOperator.selector;
        selectorList[1] = this.isOperatorActive.selector;
        selectorList[2] = this.getOperatorStake.selector;
        selectorList[3] = this.getOperatorSelfStake.selector;
        selectorList[4] = this.getOperatorDelegatedStake.selector;
        selectorList[5] = this.getOperatorDelegatedStakeForAsset.selector;
        selectorList[6] = this.getOperatorStakeForAsset.selector;
        selectorList[7] = this.getDelegation.selector;
        selectorList[8] = this.getTotalDelegation.selector;
        selectorList[9] = this.minOperatorStake.selector;
        selectorList[10] = this.meetsStakeRequirement.selector;
        selectorList[11] = this.isSlasher.selector;
        selectorList[12] = this.getOperatorMetadata.selector;
        selectorList[13] = this.getOperatorBlueprints.selector;
        selectorList[14] = this.operatorCount.selector;
        selectorList[15] = this.operatorAt.selector;
        selectorList[16] = this.getDeposit.selector;
        selectorList[17] = this.getPendingWithdrawals.selector;
        selectorList[18] = this.getLocks.selector;
        selectorList[19] = this.getDelegations.selector;
        selectorList[20] = this.getDelegationBlueprints.selector;
        selectorList[21] = this.getPendingUnstakes.selector;
        selectorList[22] = this.getOperatorRewardPool.selector;
        selectorList[23] = this.getOperatorDelegators.selector;
        selectorList[24] = this.getOperatorDelegatorCount.selector;
        selectorList[25] = this.rewardsManager.selector;
        selectorList[26] = this.serviceFeeDistributor.selector;
        selectorList[27] = this.operatorBondToken.selector;
        selectorList[28] = this.previewDelegatorUnstakeShares.selector;
    }

    function isOperator(address operator) external view returns (bool) {
        return _isOperator(operator);
    }

    function isOperatorActive(address operator) external view returns (bool) {
        return _isOperatorActive(operator);
    }

    function getOperatorStake(address operator) external view returns (uint256) {
        return _getOperatorTotalStake(operator);
    }

    function getOperatorSelfStake(address operator) external view returns (uint256) {
        return _getOperatorSelfStake(operator);
    }

    function getOperatorDelegatedStake(address operator) external view returns (uint256) {
        return _getOperatorDelegatedStake(operator);
    }

    function getOperatorDelegatedStakeForAsset(
        address operator,
        Types.Asset calldata asset
    ) external view returns (uint256) {
        bytes32 assetHash = _assetHash(asset);
        return _getOperatorDelegatedStakeForAsset(operator, assetHash);
    }

    function getOperatorStakeForAsset(
        address operator,
        Types.Asset calldata asset
    ) external view returns (uint256) {
        bytes32 assetHash = _assetHash(asset);
        uint256 delegated = _getOperatorDelegatedStakeForAsset(operator, assetHash);
        if (asset.kind == Types.AssetKind.Native && _operatorBondToken == address(0)) {
            return delegated + _getOperatorSelfStake(operator);
        }
        if (asset.kind == Types.AssetKind.ERC20 && asset.token == _operatorBondToken) {
            return delegated + _getOperatorSelfStake(operator);
        }
        return delegated;
    }

    function previewDelegatorUnstakeShares(
        address operator,
        address token,
        uint256 amount
    ) external view returns (uint256 shares) {
        if (amount == 0) revert DelegationErrors.ZeroAmount();
        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        bytes32 assetHash = _assetHash(asset);
        (shares,) = _previewDelegatorUnstakeShares(msg.sender, operator, assetHash, amount);
    }

    function getDelegation(address delegator, address operator) external view returns (uint256) {
        return _getDelegationToOperator(delegator, operator);
    }

    function getTotalDelegation(address delegator) external view returns (uint256 total) {
        return _getTotalDelegation(delegator);
    }

    function minOperatorStake() external view returns (uint256) {
        if (_operatorBondToken == address(0)) {
            bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
            return _assetConfigs[nativeHash].minOperatorStake;
        }
        bytes32 bondHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));
        return _assetConfigs[bondHash].minOperatorStake;
    }

    function meetsStakeRequirement(address operator, uint256 required) external view returns (bool) {
        return _getOperatorTotalStake(operator) >= required;
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

    /// @notice Get the operator bond token (TNT)
    function operatorBondToken() external view returns (address) {
        return _operatorBondToken;
    }
}
