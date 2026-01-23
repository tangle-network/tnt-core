// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { StakingFacetBase } from "../../staking/StakingFacetBase.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";
import { Types } from "../../libraries/Types.sol";

/// @title StakingOperatorsFacet
/// @notice Facet for operator lifecycle management
contract StakingOperatorsFacet is StakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](14);
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
        selectorList[10] = this.setDelegationMode.selector;
        selectorList[11] = this.setDelegationWhitelist.selector;
        selectorList[12] = this.getDelegationMode.selector;
        selectorList[13] = this.isWhitelisted.selector;
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

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION CONFIG
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set delegation mode for your operator
    /// @dev Changes take effect immediately for NEW delegations only.
    ///      Existing delegations remain valid regardless of mode change.
    ///      Default is Disabled (self-stake only) - lowest securities risk.
    ///      - Disabled: Only operator can self-stake
    ///      - Whitelist: Only approved addresses can delegate
    ///      - Open: Anyone can delegate (highest securities risk)
    /// @param mode Delegation mode: Disabled (0), Whitelist (1), or Open (2)
    function setDelegationMode(Types.DelegationMode mode) external {
        _setDelegationMode(mode);
    }

    /// @notice Update delegation whitelist (batch)
    /// @dev Whitelist only applies when delegation mode is set to Whitelist.
    ///      Can be called regardless of current mode to pre-configure.
    /// @param delegators Array of delegator addresses to update
    /// @param approved True to approve for delegation, false to revoke
    function setDelegationWhitelist(address[] calldata delegators, bool approved) external {
        _setDelegationWhitelist(delegators, approved);
    }

    /// @notice Get operator's delegation mode
    /// @param operator The operator address to query
    /// @return The current delegation mode (Disabled=0, Whitelist=1, Open=2)
    function getDelegationMode(address operator) external view returns (Types.DelegationMode) {
        return _getDelegationMode(operator);
    }

    /// @notice Check if delegator is whitelisted for operator
    /// @param operator The operator address
    /// @param delegator The delegator address to check
    /// @return True if delegator is on operator's whitelist
    function isWhitelisted(address operator, address delegator) external view returns (bool) {
        return _isWhitelisted(operator, delegator);
    }
}
