// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { StakingFacetBase } from "../../staking/StakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title StakingSlashingFacet
/// @notice Facet for slashing and round management
contract StakingSlashingFacet is StakingFacetBase, IFacetSelectors {
    event RoundAdvanced(uint64 indexed round);

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](8);
        selectorList[0] = this.slashForBlueprint.selector;
        selectorList[1] = this.slashForService.selector;
        selectorList[2] = this.slash.selector;
        selectorList[3] = this.advanceRound.selector;
        selectorList[4] = this.snapshotOperator.selector;
        // M-9 FIX: Pending slash tracking functions
        selectorList[5] = this.incrementPendingSlash.selector;
        selectorList[6] = this.decrementPendingSlash.selector;
        selectorList[7] = this.getPendingSlashCount.selector;
    }

    /// @notice Slash operator for a specific blueprint
    /// @dev Only affects delegators exposed to this blueprint (All mode + Fixed mode who selected it)
    function slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    )
        external
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slashForBlueprint(operator, blueprintId, serviceId, slashBps, evidence);
    }

    /// @notice Slash operator for a specific service with per-asset commitments
    /// @dev Only slashes assets the operator committed to this service, proportionally
    function slashForService(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint16 slashBps,
        bytes32 evidence
    )
        external
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slashForService(operator, blueprintId, serviceId, commitments, slashBps, evidence);
    }

    /// @notice Slash operator and delegators proportionally for consensus/native violations
    function slash(
        address operator,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    )
        external
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slash(operator, serviceId, slashBps, evidence);
    }

    /// @notice Advance to next round
    function advanceRound() external {
        _advanceRound();
        emit RoundAdvanced(currentRound);
    }

    /// @notice Take snapshot of operator state
    function snapshotOperator(address operator) external {
        _snapshotOperator(operator);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // M-9 FIX: PENDING SLASH TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Increment pending slash count for an operator
    /// @dev Called by Tangle when a slash is proposed
    /// @param operator The operator with a new pending slash
    function incrementPendingSlash(address operator) external onlyRole(SLASHER_ROLE) {
        _incrementPendingSlash(operator);
    }

    /// @notice Decrement pending slash count for an operator
    /// @dev Called by Tangle when a slash is executed or cancelled
    /// @param operator The operator whose pending slash was resolved
    function decrementPendingSlash(address operator) external onlyRole(SLASHER_ROLE) {
        _decrementPendingSlash(operator);
    }

    /// @notice Get pending slash count for an operator
    /// @param operator The operator to query
    /// @return count Number of pending slashes
    function getPendingSlashCount(address operator) external view override returns (uint64) {
        return _operatorPendingSlashCount[operator];
    }
}
