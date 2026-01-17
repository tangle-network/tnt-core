// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingOperatorsFacet
/// @notice Facet for operator lifecycle management
contract RestakingOperatorsFacet is RestakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](10);
        selectorList[0] = this.registerOperator.selector;
        selectorList[1] = this.registerOperatorWithAsset.selector;
        selectorList[2] = this.increaseStake.selector;
        selectorList[3] = this.increaseStakeWithAsset.selector;
        selectorList[4] = this.scheduleOperatorUnstake.selector;
        selectorList[5] = this.executeOperatorUnstake.selector;
        selectorList[6] = this.addBlueprintForOperator.selector;
        selectorList[7] = this.removeBlueprintForOperator.selector;
        selectorList[8] = this.startLeaving.selector;
        selectorList[9] = this.completeLeaving.selector;
    }

    /// @notice Register as an operator with native stake
    function registerOperator() external payable whenNotPaused nonReentrant {
        _registerOperatorNative();
    }

    /// @notice Register as operator with ERC20 stake
    function registerOperatorWithAsset(address token, uint256 amount) external whenNotPaused nonReentrant {
        _registerOperatorWithAsset(token, amount);
    }

    /// @notice Increase operator stake with native token
    function increaseStake() external payable whenNotPaused nonReentrant {
        _increaseStakeNative();
    }

    /// @notice Increase operator stake with ERC20 bond token
    function increaseStakeWithAsset(address token, uint256 amount) external whenNotPaused nonReentrant {
        _increaseStakeWithAsset(token, amount);
    }

    /// @notice Schedule operator self-stake reduction
    /// @param amount Amount to unstake
    function scheduleOperatorUnstake(uint256 amount) external whenNotPaused {
        _scheduleOperatorUnstake(amount);
    }

    /// @notice Execute pending operator unstake
    function executeOperatorUnstake() external nonReentrant {
        _executeOperatorUnstake();
    }

    /// @notice Add blueprint support for an operator (called by Tangle on registration)
    /// @param operator The operator address
    /// @param blueprintId The blueprint to add
    function addBlueprintForOperator(address operator, uint64 blueprintId) external onlyRole(TANGLE_ROLE) {
        _addBlueprintForOperator(operator, blueprintId);
    }

    /// @notice Remove blueprint support for an operator (called by Tangle on unregistration)
    /// @param operator The operator address
    /// @param blueprintId The blueprint to remove
    function removeBlueprintForOperator(address operator, uint64 blueprintId) external onlyRole(TANGLE_ROLE) {
        _removeBlueprintForOperator(operator, blueprintId);
    }

    /// @notice Schedule leaving as operator
    function startLeaving() external {
        _startLeaving();
    }

    /// @notice Complete leaving and withdraw all stake
    function completeLeaving() external nonReentrant {
        _completeLeaving();
    }
}
