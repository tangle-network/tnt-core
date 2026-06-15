// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { StakingFacetBase } from "../../staking/StakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title StakingSlashingFacet
/// @notice Facet for slashing and round management
contract StakingSlashingFacet is StakingFacetBase, IFacetSelectors {
    event RoundAdvanced(uint64 indexed round);
    event OperatorSnapshotted(uint64 indexed round, address indexed operator);

    /// @notice Snapshot for (round, operator) already exists and cannot be overwritten.
    /// @dev Snapshots feed historical slashing math; allowing a re-snapshot mid-round would
    ///      let a privileged caller retroactively change the stake basis a slash is computed
    ///      against. Snapshots are therefore write-once per round.
    error SnapshotAlreadyTaken(uint64 round, address operator);

    // ─────────────────────────────────────────────────────────────────────────
    // ERC-7201 facet-local storage
    //
    // DelegationStorage is the shared sequential layout for every staking facet and
    // must not be touched. The write-once snapshot guard needs new state, so it lives
    // in a namespaced (ERC-7201) slot derived from a unique string — this slot is
    // collision-free against the sequential layout by construction and requires no
    // storage migration on upgrade.
    // ─────────────────────────────────────────────────────────────────────────

    /// @custom:storage-location erc7201:tangle.staking.StakingSlashingFacet
    struct SlashingFacetStorage {
        // round => operator => snapshot already taken this round
        mapping(uint64 => mapping(address => bool)) snapshotTaken;
    }

    /// @notice ERC-7201 slot:
    ///         keccak256(abi.encode(uint256(keccak256("tangle.staking.StakingSlashingFacet")) - 1))
    ///         & ~bytes32(uint256(0xff))
    bytes32 private constant SLASHING_FACET_STORAGE_SLOT =
        0x1a01f77f53227e89a61746b347de7a926d541cbf27bb593f17507e031e657e00;

    function _slashingFacetStorage() private pure returns (SlashingFacetStorage storage $) {
        bytes32 slot = SLASHING_FACET_STORAGE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](8);
        selectorList[0] = this.slashForBlueprint.selector;
        selectorList[1] = this.slashForService.selector;
        selectorList[2] = this.slash.selector;
        selectorList[3] = this.advanceRound.selector;
        selectorList[4] = this.snapshotOperator.selector;
        // Pending slash tracking functions
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
    /// @dev Permissionless crank by design: round advancement gates time-based unbonding /
    ///      withdrawal delays for ALL participants, so it must NOT depend on a privileged
    ///      caller being online (that would freeze every withdrawal protocol-wide). Racing is
    ///      already prevented because _advanceRound enforces roundDuration rate limiting (a
    ///      round cannot be advanced before its duration elapses). The integrity-sensitive
    ///      operation — the per-operator stake snapshot historical slashing is computed
    ///      against — is the one that is gated and write-once (see snapshotOperator).
    function advanceRound() external {
        _advanceRound();
        emit RoundAdvanced(currentRound);
    }

    /// @notice Take snapshot of operator state for the current round
    /// @dev Restricted to SLASHER_ROLE and write-once per (round, operator): the snapshot is the
    ///      stake basis historical slashing is computed against, so it must not be permissionless
    ///      nor re-writable within a round.
    function snapshotOperator(address operator) external onlyRole(SLASHER_ROLE) {
        SlashingFacetStorage storage $ = _slashingFacetStorage();
        uint64 round = currentRound;
        if ($.snapshotTaken[round][operator]) {
            revert SnapshotAlreadyTaken(round, operator);
        }
        $.snapshotTaken[round][operator] = true;
        _snapshotOperator(operator);
        emit OperatorSnapshotted(round, operator);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PENDING SLASH TRACKING
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
