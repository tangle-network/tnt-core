// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MockRewardVaults {
    address public lastAsset;
    address public lastOperator;
    uint256 public lastAmount;

    mapping(address => uint256) public distributedToOperator;
    uint256 public totalDistributed;

    mapping(address => mapping(address => uint256)) public totalStakedByAssetAndOperator;

    function distributeServiceFeeRewards(address asset, address operator, uint256 amount) external {
        lastAsset = asset;
        lastOperator = operator;
        lastAmount = amount;
        distributedToOperator[operator] += amount;
        totalDistributed += amount;
    }

    function operatorPools(address asset, address operator)
        external
        view
        returns (uint256 accumulatedPerShare, uint256 totalStaked, uint256 lastUpdateBlock, uint256 pendingCommission)
    {
        accumulatedPerShare = 0;
        totalStaked = totalStakedByAssetAndOperator[asset][operator];
        lastUpdateBlock = 0;
        pendingCommission = 0;
    }

    function setTotalStaked(address asset, address operator, uint256 totalStaked) external {
        totalStakedByAssetAndOperator[asset][operator] = totalStaked;
    }
}
