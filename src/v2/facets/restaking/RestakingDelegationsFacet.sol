// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingDelegationsFacet
/// @notice Facet for delegation lifecycle
contract RestakingDelegationsFacet is RestakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](9);
        selectorList[0] = this.depositAndDelegate.selector;
        selectorList[1] = this.depositAndDelegateWithOptions.selector;
        selectorList[2] = this.delegate.selector;
        selectorList[3] = this.delegateWithOptions.selector;
        selectorList[4] = this.scheduleDelegatorUnstake.selector;
        selectorList[5] = this.undelegate.selector;
        selectorList[6] = this.executeDelegatorUnstake.selector;
        selectorList[7] = this.addBlueprintToDelegation.selector;
        selectorList[8] = this.removeBlueprintFromDelegation.selector;
    }

    /// @notice Deposit and delegate native tokens in one transaction
    /// @param operator Operator to delegate to
    function depositAndDelegate(address operator) external payable whenNotPaused nonReentrant {
        _tryAdvanceRound();
        _depositNative();
        _delegateNative(operator, msg.value);
    }

    /// @notice Deposit and delegate with full options in one transaction
    /// @param operator Operator to delegate to
    /// @param token Token address (address(0) for native)
    /// @param amount Amount to deposit and delegate
    /// @param selectionMode Blueprint selection mode
    /// @param blueprintIds Blueprint IDs for Fixed mode
    function depositAndDelegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    )
        external
        payable
        whenNotPaused
        nonReentrant
    {
        _tryAdvanceRound();
        if (token == address(0)) {
            _depositNative();
        } else {
            _depositErc20(token, amount);
        }
        _delegateWithOptions(operator, token, amount, selectionMode, blueprintIds);
    }

    /// @notice Delegate to an operator (from existing deposit)
    function delegate(address operator, uint256 amount) external whenNotPaused nonReentrant {
        _tryAdvanceRound();
        _delegateNative(operator, amount);
    }

    /// @notice Delegate with full options (from existing deposit)
    function delegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    )
        external
        whenNotPaused
        nonReentrant
    {
        _tryAdvanceRound();
        _delegateWithOptions(operator, token, amount, selectionMode, blueprintIds);
    }

    /// @notice Schedule undelegation
    function scheduleDelegatorUnstake(address operator, address token, uint256 amount) external whenNotPaused {
        _scheduleDelegatorUnstake(operator, token, amount);
    }

    /// @notice Undelegate native tokens
    function undelegate(address operator, uint256 amount) external whenNotPaused nonReentrant {
        _undelegateNative(operator, amount);
    }

    /// @notice Execute pending unstakes
    function executeDelegatorUnstake() external nonReentrant {
        _tryAdvanceRound();
        _executeDelegatorUnstake();
    }

    /// @notice Add a blueprint to a Fixed mode delegation
    function addBlueprintToDelegation(uint256 delegationIndex, uint64 blueprintId) external whenNotPaused {
        _addBlueprintToDelegation(delegationIndex, blueprintId);
    }

    /// @notice Remove a blueprint from a Fixed mode delegation
    function removeBlueprintFromDelegation(uint256 delegationIndex, uint64 blueprintId) external whenNotPaused {
        _removeBlueprintFromDelegation(delegationIndex, blueprintId);
    }
}
