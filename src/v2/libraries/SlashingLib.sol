// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Errors } from "./Errors.sol";

/// @title SlashingLib
/// @notice Library for slashing logic with dispute window support
/// @dev Implements a queue-based slash proposal system with configurable dispute period
library SlashingLib {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    uint16 internal constant BPS_DENOMINATOR = 10_000;

    /// @dev Default dispute window in seconds (7 days)
    uint64 internal constant DEFAULT_DISPUTE_WINDOW = 7 days;

    /// @dev Minimum dispute window (1 hour)
    uint64 internal constant MIN_DISPUTE_WINDOW = 1 hours;

    /// @dev Maximum dispute window (30 days)
    uint64 internal constant MAX_DISPUTE_WINDOW = 30 days;

    // ═══════════════════════════════════════════════════════════════════════════
    // ENUMS
    // ═══════════════════════════════════════════════════════════════════════════

    enum SlashStatus {
        Pending,    // Waiting for dispute window to pass
        Disputed,   // Under dispute review
        Executed,   // Slash was executed
        Cancelled   // Slash was cancelled (dispute successful or admin override)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Pending slash proposal
    struct SlashProposal {
        uint64 serviceId;           // Service where violation occurred
        address operator;           // Operator to be slashed
        address proposer;           // Who proposed the slash
        uint256 amount;             // Original slash amount
        uint256 effectiveAmount;    // Amount after exposure scaling
        bytes32 evidence;           // Evidence hash (IPFS or other)
        uint64 proposedAt;          // When slash was proposed
        uint64 executeAfter;        // When slash can be executed
        SlashStatus status;         // Current status
        string disputeReason;       // Reason if disputed
    }

    /// @notice Slashing configuration
    struct SlashConfig {
        uint64 disputeWindow;       // Time before slash can be executed
        bool instantSlashEnabled;   // Allow immediate slashing (for emergencies)
        uint16 maxSlashBps;         // Maximum slash as % of stake (default 10000 = 100%)
    }

    /// @notice Slashing state storage
    struct SlashState {
        uint64 nextSlashId;         // Auto-incrementing slash ID
        SlashConfig config;         // Slashing configuration
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event SlashProposed(
        uint64 indexed slashId,
        uint64 indexed serviceId,
        address indexed operator,
        address proposer,
        uint256 amount,
        uint256 effectiveAmount,
        bytes32 evidence,
        uint64 executeAfter
    );

    event SlashDisputed(
        uint64 indexed slashId,
        address indexed disputer,
        string reason
    );

    event SlashExecuted(
        uint64 indexed slashId,
        uint64 indexed serviceId,
        address indexed operator,
        uint256 actualSlashed
    );

    event SlashCancelled(
        uint64 indexed slashId,
        address indexed canceller,
        string reason
    );

    event SlashConfigUpdated(
        uint64 disputeWindow,
        bool instantSlashEnabled,
        uint16 maxSlashBps
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize slashing configuration
    /// @param state The slash state storage
    function initializeConfig(SlashState storage state) internal {
        state.config = SlashConfig({
            disputeWindow: DEFAULT_DISPUTE_WINDOW,
            instantSlashEnabled: false,
            maxSlashBps: BPS_DENOMINATOR // 100%
        });
    }

    /// @notice Update slashing configuration
    /// @param state The slash state storage
    /// @param disputeWindow New dispute window
    /// @param instantSlashEnabled Whether instant slashing is allowed
    /// @param maxSlashBps Maximum slash percentage
    function updateConfig(
        SlashState storage state,
        uint64 disputeWindow,
        bool instantSlashEnabled,
        uint16 maxSlashBps
    ) internal {
        if (disputeWindow < MIN_DISPUTE_WINDOW || disputeWindow > MAX_DISPUTE_WINDOW) {
            revert Errors.InvalidSlashConfig();
        }
        if (maxSlashBps == 0 || maxSlashBps > BPS_DENOMINATOR) {
            revert Errors.InvalidSlashConfig();
        }

        state.config = SlashConfig({
            disputeWindow: disputeWindow,
            instantSlashEnabled: instantSlashEnabled,
            maxSlashBps: maxSlashBps
        });

        emit SlashConfigUpdated(disputeWindow, instantSlashEnabled, maxSlashBps);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate effective slash amount based on operator exposure
    /// @param amount Base slash amount
    /// @param exposureBps Operator's exposure in basis points
    /// @return Effective slash amount
    function calculateEffectiveSlash(
        uint256 amount,
        uint16 exposureBps
    ) internal pure returns (uint256) {
        return (amount * exposureBps) / BPS_DENOMINATOR;
    }

    /// @notice Cap slash amount to maximum allowed
    /// @param amount Proposed slash amount
    /// @param operatorStake Operator's total stake
    /// @param maxSlashBps Maximum slash percentage
    /// @return Capped slash amount
    function capSlashAmount(
        uint256 amount,
        uint256 operatorStake,
        uint16 maxSlashBps
    ) internal pure returns (uint256) {
        uint256 maxSlash = (operatorStake * maxSlashBps) / BPS_DENOMINATOR;
        return amount > maxSlash ? maxSlash : amount;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH PROPOSAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new slash proposal
    /// @param state The slash state storage
    /// @param proposals Storage mapping for proposals
    /// @param serviceId Service where violation occurred
    /// @param operator Operator to slash
    /// @param proposer Who is proposing the slash
    /// @param amount Base slash amount
    /// @param exposureBps Operator's exposure
    /// @param evidence Evidence hash
    /// @param instant If true, skip dispute window (requires instantSlashEnabled)
    /// @return slashId The new slash proposal ID
    function proposeSlash(
        SlashState storage state,
        mapping(uint64 => SlashProposal) storage proposals,
        uint64 serviceId,
        address operator,
        address proposer,
        uint256 amount,
        uint16 exposureBps,
        bytes32 evidence,
        bool instant
    ) internal returns (uint64 slashId) {
        if (amount == 0) revert Errors.InvalidSlashAmount();
        if (operator == address(0)) revert Errors.ZeroAddress();

        // Calculate effective amount based on exposure
        uint256 effectiveAmount = calculateEffectiveSlash(amount, exposureBps);
        if (effectiveAmount == 0) revert Errors.InvalidSlashAmount();

        // Determine execution time
        uint64 executeAfter;
        if (instant) {
            if (!state.config.instantSlashEnabled) {
                revert Errors.InstantSlashNotEnabled();
            }
            executeAfter = uint64(block.timestamp);
        } else {
            executeAfter = uint64(block.timestamp) + state.config.disputeWindow;
        }

        // Create proposal
        slashId = state.nextSlashId++;
        proposals[slashId] = SlashProposal({
            serviceId: serviceId,
            operator: operator,
            proposer: proposer,
            amount: amount,
            effectiveAmount: effectiveAmount,
            evidence: evidence,
            proposedAt: uint64(block.timestamp),
            executeAfter: executeAfter,
            status: SlashStatus.Pending,
            disputeReason: ""
        });

        emit SlashProposed(
            slashId,
            serviceId,
            operator,
            proposer,
            amount,
            effectiveAmount,
            evidence,
            executeAfter
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Dispute a pending slash proposal
    /// @param proposals Storage mapping for proposals
    /// @param slashId The slash ID to dispute
    /// @param disputer Who is disputing
    /// @param reason Reason for dispute
    function disputeSlash(
        mapping(uint64 => SlashProposal) storage proposals,
        uint64 slashId,
        address disputer,
        string memory reason
    ) internal {
        SlashProposal storage proposal = proposals[slashId];

        if (proposal.operator == address(0)) {
            revert Errors.SlashNotFound(slashId);
        }

        if (proposal.status != SlashStatus.Pending) {
            revert Errors.SlashNotPending(slashId);
        }

        if (block.timestamp >= proposal.executeAfter) {
            revert Errors.DisputeWindowPassed(slashId);
        }

        proposal.status = SlashStatus.Disputed;
        proposal.disputeReason = reason;

        emit SlashDisputed(slashId, disputer, reason);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXECUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if a slash is ready to execute
    /// @dev Only Pending slashes can be executed - Disputed slashes are blocked
    /// @param proposal The slash proposal
    /// @return True if ready
    function isExecutable(SlashProposal storage proposal) internal view returns (bool) {
        // Disputed slashes cannot be executed - they require admin resolution
        if (proposal.status == SlashStatus.Disputed) {
            return false;
        }
        return proposal.status == SlashStatus.Pending &&
               block.timestamp >= proposal.executeAfter;
    }

    /// @notice Mark a slash as executed
    /// @param proposals Storage mapping for proposals
    /// @param slashId The slash ID
    /// @param actualSlashed Actual amount that was slashed
    /// @return proposal The executed proposal
    function markExecuted(
        mapping(uint64 => SlashProposal) storage proposals,
        uint64 slashId,
        uint256 actualSlashed
    ) internal returns (SlashProposal storage proposal) {
        proposal = proposals[slashId];

        if (proposal.operator == address(0)) {
            revert Errors.SlashNotFound(slashId);
        }

        if (!isExecutable(proposal)) {
            revert Errors.SlashNotExecutable(slashId);
        }

        proposal.status = SlashStatus.Executed;

        emit SlashExecuted(
            slashId,
            proposal.serviceId,
            proposal.operator,
            actualSlashed
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CANCELLATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Cancel a slash proposal
    /// @param proposals Storage mapping for proposals
    /// @param slashId The slash ID to cancel
    /// @param canceller Who is cancelling
    /// @param reason Reason for cancellation
    function cancelSlash(
        mapping(uint64 => SlashProposal) storage proposals,
        uint64 slashId,
        address canceller,
        string memory reason
    ) internal {
        SlashProposal storage proposal = proposals[slashId];

        if (proposal.operator == address(0)) {
            revert Errors.SlashNotFound(slashId);
        }

        if (proposal.status == SlashStatus.Executed) {
            revert Errors.SlashAlreadyExecuted(slashId);
        }

        if (proposal.status == SlashStatus.Cancelled) {
            revert Errors.SlashAlreadyCancelled(slashId);
        }

        proposal.status = SlashStatus.Cancelled;

        emit SlashCancelled(slashId, canceller, reason);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pending slash proposals for an operator
    /// @param proposals Storage mapping for proposals
    /// @param operator The operator address
    /// @param fromId Start searching from this ID
    /// @param toId Search up to this ID (exclusive)
    /// @return ids Array of pending slash IDs
    function getPendingSlashes(
        mapping(uint64 => SlashProposal) storage proposals,
        address operator,
        uint64 fromId,
        uint64 toId
    ) internal view returns (uint64[] memory ids) {
        // First pass: count matching
        uint64 count = 0;
        for (uint64 i = fromId; i < toId; i++) {
            if (proposals[i].operator == operator &&
                proposals[i].status == SlashStatus.Pending) {
                count++;
            }
        }

        // Second pass: collect IDs
        ids = new uint64[](count);
        uint64 idx = 0;
        for (uint64 i = fromId; i < toId && idx < count; i++) {
            if (proposals[i].operator == operator &&
                proposals[i].status == SlashStatus.Pending) {
                ids[idx++] = i;
            }
        }
    }

    /// @notice Calculate total pending slash amount for an operator
    /// @param proposals Storage mapping for proposals
    /// @param operator The operator address
    /// @param fromId Start from this ID
    /// @param toId Search up to this ID
    /// @return total Total pending slash amount
    function getTotalPendingSlash(
        mapping(uint64 => SlashProposal) storage proposals,
        address operator,
        uint64 fromId,
        uint64 toId
    ) internal view returns (uint256 total) {
        for (uint64 i = fromId; i < toId; i++) {
            if (proposals[i].operator == operator &&
                proposals[i].status == SlashStatus.Pending) {
                total += proposals[i].effectiveAmount;
            }
        }
    }
}
