// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingSlashingFacet
/// @notice Facet for slashing and round management
contract RestakingSlashingFacet is RestakingFacetBase, IFacetSelectors {
    event RoundAdvanced(uint64 indexed round);

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](5);
        selectorList[0] = this.slashForBlueprint.selector;
        selectorList[1] = this.slashForService.selector;
        selectorList[2] = this.slash.selector;
        selectorList[3] = this.advanceRound.selector;
        selectorList[4] = this.snapshotOperator.selector;
    }

    /// @notice Slash operator for a specific blueprint
    /// @dev Only affects delegators exposed to this blueprint (All mode + Fixed mode who selected it)
    function slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    )
        external
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slashForBlueprint(operator, blueprintId, serviceId, amount, evidence);
    }

    /// @notice Slash operator for a specific service with per-asset commitments
    /// @dev Only slashes assets the operator committed to this service, proportionally
    function slashForService(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256 amount,
        bytes32 evidence
    )
        external
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slashForService(operator, blueprintId, serviceId, commitments, amount, evidence);
    }

    /// @notice Slash operator and delegators proportionally (legacy - slashes all)
    function slash(
        address operator,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    )
        external
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slash(operator, serviceId, amount, evidence);
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
}
