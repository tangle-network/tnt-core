// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ITangleSlashing
/// @notice Slashing interface for Tangle protocol
interface ITangleSlashing {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event SlashProposed(
        uint64 indexed serviceId,
        address indexed operator,
        uint256 amount,
        bytes32 evidence
    );

    event SlashExecuted(uint64 indexed serviceId, address indexed operator, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Propose a slash against an operator
    /// @param serviceId The service where violation occurred
    /// @param operator The operator to slash
    /// @param amount Amount to slash
    /// @param evidence Evidence hash
    /// @return slashId The ID of the created slash proposal
    function proposeSlash(
        uint64 serviceId,
        address operator,
        uint256 amount,
        bytes32 evidence
    ) external returns (uint64 slashId);
}
