// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { SlashingLib } from "../libraries/SlashingLib.sol";

/// @title ITangleSlashing
/// @notice Slashing interface for Tangle protocol
interface ITangleSlashing {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event SlashProposed(uint64 indexed serviceId, address indexed operator, uint16 slashBps, bytes32 evidence);

    event SlashExecuted(uint64 indexed serviceId, address indexed operator, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Propose a slash against an operator
    /// @param serviceId The service where violation occurred
    /// @param operator The operator to slash
    /// @param slashBps Slash percentage in basis points
    /// @param evidence Evidence hash
    /// @return slashId The ID of the created slash proposal
    function proposeSlash(
        uint64 serviceId,
        address operator,
        uint16 slashBps,
        bytes32 evidence
    )
        external
        returns (uint64 slashId);

    /// @notice Dispute a slash proposal
    /// @dev `payable` because the implementation requires `msg.value == config.disputeBond`
    ///      when the bond is non-zero (and zero otherwise). Typed callers must use a payable
    ///      reference so `disputeSlash{value: bond}(...)` compiles.
    function disputeSlash(uint64 slashId, string calldata reason) external payable;

    /// @notice Execute a slash proposal
    function executeSlash(uint64 slashId) external returns (uint256 actualSlashed);

    /// @notice Execute a batch of slashes
    function executeSlashBatch(uint64[] calldata slashIds)
        external
        returns (uint256 totalSlashed, uint256 executedCount);

    /// @notice Get list of executable slash IDs in a range
    function getExecutableSlashes(uint64 fromId, uint64 toId) external view returns (uint64[] memory ids);

    /// @notice Cancel a slash proposal
    function cancelSlash(uint64 slashId, string calldata reason) external;

    /// @notice Update slashing configuration
    /// @param disputeResolutionDeadline How long SLASH_ADMIN has to resolve a dispute
    /// @param disputeBond Native asset bond required to dispute (0 = disabled)
    /// @param maxPendingSlashesPerOperator Cap on concurrent pending slashes per operator
    function setSlashConfig(
        uint64 disputeWindow,
        bool instantSlashEnabled,
        uint16 maxSlashBps,
        uint64 disputeResolutionDeadline,
        uint256 disputeBond,
        uint16 maxPendingSlashesPerOperator
    ) external;

    /// @notice Get slash proposal details
    function getSlashProposal(uint64 slashId) external view returns (SlashingLib.SlashProposal memory);

    /// @notice Get current slashing configuration
    function getSlashConfig() external view returns (SlashingLib.SlashConfig memory);
}
