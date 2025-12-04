// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { SlashingLib } from "../libraries/SlashingLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Slashing
/// @notice Slashing with dispute window support
/// @dev Uses basis points (0-10000) for precision instead of percentages (0-100)
abstract contract Slashing is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH PROPOSAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Propose a slash
    function proposeSlash(
        uint64 serviceId,
        address operator,
        uint256 amount,
        bytes32 evidence
    ) external returns (uint64 slashId) {
        Types.Service storage svc = _getService(serviceId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        bool authorized = msg.sender == svc.owner || msg.sender == bp.owner;
        if (!authorized && bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).querySlashingOrigin(serviceId) returns (address origin) {
                authorized = msg.sender == origin;
            } catch {}
        }
        if (!authorized) revert Errors.Unauthorized();

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][operator];
        if (!opData.active && opData.joinedAt == 0) {
            revert Errors.OperatorNotInService(serviceId, operator);
        }

        slashId = SlashingLib.proposeSlash(
            _slashState,
            _slashProposals,
            serviceId,
            operator,
            msg.sender,
            amount,
            opData.exposureBps,
            evidence,
            false
        );

        if (bp.manager != address(0)) {
            uint256 opStake = _restaking.getOperatorStake(operator);
            // Use basis points (0-10000) for precision instead of uint8 percentage (0-100)
            uint16 slashPercentBps = opStake > 0 ? uint16((amount * BPS_DENOMINATOR) / opStake) : 0;
            if (slashPercentBps > BPS_DENOMINATOR) slashPercentBps = BPS_DENOMINATOR;

            // Convert to uint8 for hook (legacy interface compatibility)
            // Note: The hook interface uses uint8 slashPercent (0-100), so we convert
            uint8 slashPercent = uint8(slashPercentBps / 100);
            if (slashPercent > 100) slashPercent = 100;

            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onUnappliedSlash, (serviceId, abi.encodePacked(operator), slashPercent))
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Dispute a pending slash
    function disputeSlash(uint64 slashId, string calldata reason) external {
        SlashingLib.SlashProposal storage proposal = _slashProposals[slashId];

        if (msg.sender != proposal.operator && !hasRole(SLASH_ADMIN_ROLE, msg.sender)) {
            revert Errors.NotSlashDisputer(slashId, msg.sender);
        }

        SlashingLib.disputeSlash(_slashProposals, slashId, msg.sender, reason);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXECUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Execute a pending slash after dispute window
    /// @dev Operators are expected to call this via their node software.
    ///      Uses blueprint-aware slashing to only affect delegators exposed to this blueprint.
    /// @param slashId The slash ID to execute
    /// @return actualSlashed Amount actually slashed (accounting reduction)
    function executeSlash(uint64 slashId) external nonReentrant returns (uint256 actualSlashed) {
        SlashingLib.SlashProposal storage proposal = _slashProposals[slashId];

        if (!SlashingLib.isExecutable(proposal)) {
            revert Errors.SlashNotExecutable(slashId);
        }

        Types.Service storage svc = _services[proposal.serviceId];

        // Use blueprint-aware slashing - only affects delegators exposed to this blueprint
        actualSlashed = _restaking.slashForBlueprint(
            proposal.operator,
            svc.blueprintId,
            proposal.serviceId,
            proposal.effectiveAmount,
            proposal.evidence
        );

        SlashingLib.markExecuted(_slashProposals, slashId, actualSlashed);

        // Record slash for metrics tracking (affects rewards distribution)
        _recordSlash(proposal.operator, proposal.serviceId, actualSlashed);

        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            uint256 opStake = _restaking.getOperatorStake(proposal.operator);
            // Use basis points for precision
            uint16 slashPercentBps = opStake > 0
                ? uint16((actualSlashed * BPS_DENOMINATOR) / (opStake + actualSlashed))
                : BPS_DENOMINATOR;
            if (slashPercentBps > BPS_DENOMINATOR) slashPercentBps = BPS_DENOMINATOR;

            // Convert to uint8 for hook (legacy interface compatibility)
            uint8 slashPercent = uint8(slashPercentBps / 100);
            if (slashPercent > 100) slashPercent = 100;

            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onSlash, (proposal.serviceId, abi.encodePacked(proposal.operator), slashPercent))
            );
        }
    }

    /// @notice Execute multiple pending slashes in batch
    /// @dev More gas-efficient for operators executing multiple slashes.
    ///      Uses blueprint-aware slashing to only affect delegators exposed to each blueprint.
    /// @param slashIds Array of slash IDs to execute
    /// @return totalSlashed Total amount slashed across all executions
    /// @return executedCount Number of slashes successfully executed
    function executeSlashBatch(uint64[] calldata slashIds) external nonReentrant returns (uint256 totalSlashed, uint256 executedCount) {
        for (uint256 i = 0; i < slashIds.length; i++) {
            SlashingLib.SlashProposal storage proposal = _slashProposals[slashIds[i]];

            // Skip non-executable slashes instead of reverting
            if (!SlashingLib.isExecutable(proposal)) continue;

            Types.Service storage svc = _services[proposal.serviceId];

            // Use blueprint-aware slashing
            uint256 actualSlashed = _restaking.slashForBlueprint(
                proposal.operator,
                svc.blueprintId,
                proposal.serviceId,
                proposal.effectiveAmount,
                proposal.evidence
            );

            SlashingLib.markExecuted(_slashProposals, slashIds[i], actualSlashed);

            // Record slash for metrics tracking (affects rewards distribution)
            _recordSlash(proposal.operator, proposal.serviceId, actualSlashed);

            totalSlashed += actualSlashed;
            executedCount++;

            // Call hook
            Types.Blueprint storage bp = _blueprints[svc.blueprintId];
            if (bp.manager != address(0)) {
                uint256 opStake = _restaking.getOperatorStake(proposal.operator);
                uint16 slashPercentBps = opStake > 0
                    ? uint16((actualSlashed * BPS_DENOMINATOR) / (opStake + actualSlashed))
                    : BPS_DENOMINATOR;
                uint8 slashPercent = uint8(slashPercentBps / 100);
                if (slashPercent > 100) slashPercent = 100;

                _tryCallManager(
                    bp.manager,
                    abi.encodeCall(IBlueprintServiceManager.onSlash, (proposal.serviceId, abi.encodePacked(proposal.operator), slashPercent))
                );
            }
        }
    }

    /// @notice Get executable slashes (past dispute window, not yet executed)
    /// @param fromId Start searching from this ID
    /// @param toId Search up to this ID (exclusive)
    /// @return ids Array of executable slash IDs
    function getExecutableSlashes(uint64 fromId, uint64 toId) external view returns (uint64[] memory ids) {
        // First pass: count matching
        uint64 count = 0;
        for (uint64 i = fromId; i < toId; i++) {
            if (SlashingLib.isExecutable(_slashProposals[i])) {
                count++;
            }
        }

        // Second pass: collect IDs
        ids = new uint64[](count);
        uint64 idx = 0;
        for (uint64 i = fromId; i < toId && idx < count; i++) {
            if (SlashingLib.isExecutable(_slashProposals[i])) {
                ids[idx++] = i;
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CANCELLATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Cancel a slash
    function cancelSlash(uint64 slashId, string calldata reason) external {
        if (!hasRole(SLASH_ADMIN_ROLE, msg.sender)) {
            revert Errors.NotSlashCanceller(slashId, msg.sender);
        }
        SlashingLib.cancelSlash(_slashProposals, slashId, msg.sender, reason);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update slashing config
    function setSlashConfig(
        uint64 disputeWindow,
        bool instantSlashEnabled,
        uint16 maxSlashBps
    ) external onlyRole(ADMIN_ROLE) {
        SlashingLib.updateConfig(_slashState, disputeWindow, instantSlashEnabled, maxSlashBps);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW
    // ═══════════════════════════════════════════════════════════════════════════

    function getSlashProposal(uint64 slashId) external view returns (SlashingLib.SlashProposal memory) {
        return _slashProposals[slashId];
    }
}
