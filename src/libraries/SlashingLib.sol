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

    /// @dev Buffer for timestamp manipulation protection (15 seconds)
    /// Miners can manipulate block.timestamp within ~15 seconds, so we add this
    /// buffer to prevent dispute window bypass attacks
    uint64 internal constant TIMESTAMP_BUFFER = 15;

    // ═══════════════════════════════════════════════════════════════════════════
    // ENUMS
    // ═══════════════════════════════════════════════════════════════════════════

    enum SlashStatus {
        Pending, // Waiting for dispute window to pass
        Disputed, // Under dispute review
        Executed, // Slash was executed
        Cancelled // Slash was cancelled (dispute successful or admin override)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Pending slash proposal
    struct SlashProposal {
        uint64 serviceId; // Service where violation occurred
        address operator; // Operator to be slashed
        address proposer; // Who proposed the slash
        uint16 slashBps; // Original slash percentage (bps)
        uint16 effectiveSlashBps; // Slash percentage after exposure scaling
        bytes32 evidence; // Evidence hash (IPFS or other)
        uint64 proposedAt; // When slash was proposed
        uint64 executeAfter; // When slash can be executed
        SlashStatus status; // Current status
        string disputeReason; // Reason if disputed
        // Address that posted the dispute bond. address(0) when undisputed.
        address disputer;
        // Native-asset bond locked when the slash was disputed. Refunded on cancel,
        // forfeit to treasury when the dispute auto-fails or the slash executes.
        uint256 disputeBond;
        // Timestamp the dispute was raised (0 when undisputed).
        uint64 disputedAt;
        // Snapshot of `config.disputeResolutionDeadline` at the moment the dispute was
        // raised. Stored on the proposal so that admin shrinking the live config later
        // cannot retroactively shorten an already-disputed slash's review window.
        uint64 disputeDeadline;
    }

    /// @notice Slashing configuration
    struct SlashConfig {
        uint64 disputeWindow; // Time before slash can be executed
        bool instantSlashEnabled; // Allow immediate slashing (for emergencies)
        uint16 maxSlashBps; // Maximum slash as % of stake (default 10000 = 100%)
        // Once a slash is disputed, SLASH_ADMIN has this long to resolve it (cancel
        // or convert back to pending). After the deadline, the dispute auto-fails and
        // the slash becomes executable. Prevents permanent delegator lockup.
        uint64 disputeResolutionDeadline;
        // Native-asset bond required to dispute a slash. Forfeit to treasury if the
        // dispute is rejected (slash executes); refunded if the slash is cancelled.
        // Defeats free-DoS where an operator self-disputes to lock their own delegators.
        uint256 disputeBond;
        // Maximum number of pending slashes a single operator can carry simultaneously.
        // Defends against spam-griefing the pending-slash counter.
        uint16 maxPendingSlashesPerOperator;
    }

    /// @notice Slashing state storage
    struct SlashState {
        uint64 nextSlashId; // Auto-incrementing slash ID
        SlashConfig config; // Slashing configuration
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event SlashProposed(
        uint64 indexed slashId,
        uint64 indexed serviceId,
        address indexed operator,
        address proposer,
        uint16 slashBps,
        uint16 effectiveSlashBps,
        bytes32 evidence,
        uint64 executeAfter
    );

    event SlashDisputed(uint64 indexed slashId, address indexed disputer, string reason);

    event SlashExecuted(
        uint64 indexed slashId, uint64 indexed serviceId, address indexed operator, uint256 actualSlashed
    );

    event SlashCancelled(uint64 indexed slashId, address indexed canceller, string reason);

    event SlashConfigUpdated(
        uint64 disputeWindow,
        bool instantSlashEnabled,
        uint16 maxSlashBps,
        uint64 disputeResolutionDeadline,
        uint256 disputeBond,
        uint16 maxPendingSlashesPerOperator
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
            maxSlashBps: BPS_DENOMINATOR, // 100%
            disputeResolutionDeadline: 14 days,
            disputeBond: 0, // Defaults to disabled; admin enables via setSlashConfig.
            // One pending slash already freezes the operator + its delegators, so a small
            // cap suffices; lower default bounds admin cleanup cost on a griefing attempt.
            maxPendingSlashesPerOperator: 8
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
        uint16 maxSlashBps,
        uint64 disputeResolutionDeadline,
        uint256 disputeBond,
        uint16 maxPendingSlashesPerOperator
    )
        internal
    {
        if (disputeWindow < MIN_DISPUTE_WINDOW || disputeWindow > MAX_DISPUTE_WINDOW) {
            revert Errors.InvalidSlashConfig();
        }
        if (maxSlashBps == 0 || maxSlashBps > BPS_DENOMINATOR) {
            revert Errors.InvalidSlashConfig();
        }
        if (disputeResolutionDeadline < 1 days || disputeResolutionDeadline > 60 days) {
            revert Errors.InvalidSlashConfig();
        }
        if (maxPendingSlashesPerOperator == 0) revert Errors.InvalidSlashConfig();

        state.config = SlashConfig({
            disputeWindow: disputeWindow,
            instantSlashEnabled: instantSlashEnabled,
            maxSlashBps: maxSlashBps,
            disputeResolutionDeadline: disputeResolutionDeadline,
            disputeBond: disputeBond,
            maxPendingSlashesPerOperator: maxPendingSlashesPerOperator
        });

        emit SlashConfigUpdated(
            disputeWindow,
            instantSlashEnabled,
            maxSlashBps,
            disputeResolutionDeadline,
            disputeBond,
            maxPendingSlashesPerOperator
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate effective slash bps based on operator exposure
    /// @param slashBps Base slash percentage
    /// @param exposureBps Operator's exposure in basis points
    /// @return Effective slash percentage
    function calculateEffectiveSlashBps(uint16 slashBps, uint16 exposureBps) internal pure returns (uint16) {
        return uint16((uint256(slashBps) * exposureBps) / BPS_DENOMINATOR);
    }

    /// @notice Cap slash percentage to maximum allowed
    /// @param slashBps Proposed slash percentage
    /// @param maxSlashBps Maximum slash percentage
    /// @return Capped slash percentage
    function capSlashBps(uint16 slashBps, uint16 maxSlashBps) internal pure returns (uint16) {
        return slashBps > maxSlashBps ? maxSlashBps : slashBps;
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
    /// @param slashBps Base slash percentage
    /// @param exposureBps Operator's exposure
    /// @param evidence Evidence hash
    /// @param instant If true, skip dispute window (requires instantSlashEnabled)
    /// @return slashId The new slash proposal ID
    /// @param disputeWindow Effective dispute window (seconds) for this proposal. The caller
    ///        resolves this — protocol default or a per-service override from the blueprint's
    ///        `getSlashingWindow` hook — and is responsible for clamping it to
    ///        `[MIN_DISPUTE_WINDOW, MAX_DISPUTE_WINDOW]`. Ignored for instant slashes.
    function proposeSlash(
        SlashState storage state,
        mapping(uint64 => SlashProposal) storage proposals,
        uint64 serviceId,
        address operator,
        address proposer,
        uint16 slashBps,
        uint16 exposureBps,
        bytes32 evidence,
        bool instant,
        uint64 disputeWindow
    )
        internal
        returns (uint64 slashId)
    {
        if (slashBps == 0) revert Errors.InvalidSlashAmount();
        if (operator == address(0)) revert Errors.ZeroAddress();

        // Calculate effective bps based on exposure
        uint16 effectiveSlashBps = calculateEffectiveSlashBps(slashBps, exposureBps);
        if (effectiveSlashBps == 0) revert Errors.InvalidSlashAmount();

        // Determine execution time
        uint64 executeAfter;
        if (instant) {
            if (!state.config.instantSlashEnabled) {
                revert Errors.InstantSlashNotEnabled();
            }
            executeAfter = uint64(block.timestamp);
        } else {
            // Defense-in-depth: clamp again here so the library never produces a proposal
            // outside protocol bounds even if a caller forgets to clamp.
            if (disputeWindow < MIN_DISPUTE_WINDOW) disputeWindow = MIN_DISPUTE_WINDOW;
            if (disputeWindow > MAX_DISPUTE_WINDOW) disputeWindow = MAX_DISPUTE_WINDOW;
            executeAfter = uint64(block.timestamp) + disputeWindow;
        }

        // Create proposal
        slashId = state.nextSlashId++;
        proposals[slashId] = SlashProposal({
            serviceId: serviceId,
            operator: operator,
            proposer: proposer,
            slashBps: slashBps,
            effectiveSlashBps: effectiveSlashBps,
            evidence: evidence,
            proposedAt: uint64(block.timestamp),
            executeAfter: executeAfter,
            status: SlashStatus.Pending,
            disputeReason: "",
            disputer: address(0),
            disputeBond: 0,
            disputedAt: 0,
            disputeDeadline: 0
        });

        emit SlashProposed(slashId, serviceId, operator, proposer, slashBps, effectiveSlashBps, evidence, executeAfter);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Dispute a pending slash proposal.
    /// @dev Snapshots `config.disputeResolutionDeadline` onto the proposal so a later
    ///      admin-driven shrink of the live config cannot retroactively shorten an
    ///      already-disputed slash's review window.
    function disputeSlash(
        mapping(uint64 => SlashProposal) storage proposals,
        SlashConfig storage config,
        uint64 slashId,
        address disputer,
        string memory reason,
        uint256 bondPosted
    )
        internal
    {
        SlashProposal storage proposal = proposals[slashId];

        if (proposal.operator == address(0)) {
            revert Errors.SlashNotFound(slashId);
        }

        if (proposal.status != SlashStatus.Pending) {
            revert Errors.SlashNotPending(slashId);
        }

        // Dispute window extends through `executeAfter + TIMESTAMP_BUFFER`. Without
        // the buffer, a sequencer or proposer with timestamp influence can land an
        // operator's dispute tx at exactly `executeAfter` (where it reverts) and
        // then 15 seconds later anyone can call `executeSlash`. The buffer here
        // mirrors `isExecutable` so the operator's window is symmetric with the
        // execute side and there is no dead zone.
        if (block.timestamp >= uint256(proposal.executeAfter) + TIMESTAMP_BUFFER) {
            revert Errors.DisputeWindowPassed(slashId);
        }

        proposal.status = SlashStatus.Disputed;
        proposal.disputeReason = reason;
        proposal.disputer = disputer;
        proposal.disputeBond = bondPosted;
        proposal.disputedAt = uint64(block.timestamp);
        proposal.disputeDeadline = uint64(block.timestamp) + config.disputeResolutionDeadline;

        emit SlashDisputed(slashId, disputer, reason);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXECUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if a slash is ready to execute.
    /// @dev A `Pending` slash becomes executable after the dispute window plus a
    ///      timestamp-manipulation buffer. A `Disputed` slash auto-fails once
    ///      `proposal.disputeDeadline` (snapshotted from config at dispute time) has
    ///      elapsed. The deadline is read from the proposal — not live config — so
    ///      admin cannot retroactively shorten the operator's review window.
    ///      The same `TIMESTAMP_BUFFER` is applied to both branches: a sequencer /
    ///      proposer with timestamp influence cannot sandwich either deadline tick.
    function isExecutable(SlashProposal storage proposal) internal view returns (bool) {
        if (proposal.status == SlashStatus.Pending) {
            return block.timestamp >= proposal.executeAfter + TIMESTAMP_BUFFER;
        }
        if (proposal.status == SlashStatus.Disputed) {
            return block.timestamp >= uint256(proposal.disputeDeadline) + TIMESTAMP_BUFFER;
        }
        return false;
    }

    /// @notice Mark a slash as executed.
    function markExecuted(
        mapping(uint64 => SlashProposal) storage proposals,
        uint64 slashId,
        uint256 actualSlashed
    )
        internal
        returns (SlashProposal storage proposal)
    {
        proposal = proposals[slashId];

        if (proposal.operator == address(0)) {
            revert Errors.SlashNotFound(slashId);
        }

        if (!isExecutable(proposal)) {
            revert Errors.SlashNotExecutable(slashId);
        }

        proposal.status = SlashStatus.Executed;

        emit SlashExecuted(slashId, proposal.serviceId, proposal.operator, actualSlashed);
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
    )
        internal
    {
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
    )
        internal
        view
        returns (uint64[] memory ids)
    {
        // First pass: count matching
        uint64 count = 0;
        for (uint64 i = fromId; i < toId; i++) {
            if (proposals[i].operator == operator && proposals[i].status == SlashStatus.Pending) {
                count++;
            }
        }

        // Second pass: collect IDs
        ids = new uint64[](count);
        uint64 idx = 0;
        for (uint64 i = fromId; i < toId && idx < count; i++) {
            if (proposals[i].operator == operator && proposals[i].status == SlashStatus.Pending) {
                ids[idx++] = i;
            }
        }
    }
}
