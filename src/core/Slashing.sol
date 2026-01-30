// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { SlashingLib } from "../libraries/SlashingLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";
import { IPriceOracle } from "../oracles/interfaces/IPriceOracle.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Slashing
/// @notice Slashing with dispute window support
/// @dev Uses basis points (0-10000) for precision instead of percentages (0-100)
abstract contract Slashing is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH PROPOSAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Propose a slash against an operator
    /// @dev Trust model: Service owners, blueprint owners, and slashing origins can propose.
    /// Operators should verify service/blueprint ownership before joining.
    /// Dispute window provides protection against malicious proposals.
    /// @param serviceId The service ID the operator is being slashed for
    /// @param operator The operator address to slash
    /// @param slashBps The slash amount in basis points (0-10000)
    /// @param evidence Evidence hash (e.g., IPFS CID) supporting the slash reason
    /// @return slashId The newly created slash proposal ID
    function proposeSlash(
        uint64 serviceId,
        address operator,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint64 slashId) {
        // M-6 FIX: Validate slashBps does not exceed 100% (10000 bps)
        if (slashBps > BPS_DENOMINATOR) {
            revert Errors.SlashBpsExceedsMax(slashBps, BPS_DENOMINATOR);
        }

        Types.Service storage svc = _getService(serviceId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        bool authorized = msg.sender == svc.owner || msg.sender == bp.owner;
        if (!authorized && bp.manager != address(0)) {
            // The slashing origin returned by blueprint manager is trusted.
            // Operators should audit blueprint manager code before registering.
            try IBlueprintServiceManager(bp.manager).querySlashingOrigin(serviceId) returns (address origin) {
                authorized = msg.sender == origin;
            } catch {}
        }
        if (!authorized) revert Errors.Unauthorized();

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][operator];
        if (!opData.active && opData.joinedAt == 0) {
            revert Errors.OperatorNotInService(serviceId, operator);
        }

        uint16 effectiveExposureBps = opData.exposureBps;
        if (_serviceSecurityRequirements[serviceId].length > 0) {
            uint16 commitmentBps = _computeServiceCommitmentExposureBps(serviceId, operator, svc.blueprintId);
            effectiveExposureBps = uint16((uint256(effectiveExposureBps) * commitmentBps) / BPS_DENOMINATOR);
        }

        uint16 cappedSlashBps = SlashingLib.capSlashBps(slashBps, _slashState.config.maxSlashBps);

        slashId = SlashingLib.proposeSlash(
            _slashState,
            _slashProposals,
            serviceId,
            operator,
            msg.sender,
            cappedSlashBps,
            effectiveExposureBps,
            evidence,
            false
        );

        // M-9 FIX: Increment pending slash count to block delegator withdrawals
        _staking.incrementPendingSlash(operator);

        if (bp.manager != address(0)) {
            uint16 slashPercentBps = cappedSlashBps;
            if (slashPercentBps > BPS_DENOMINATOR) slashPercentBps = BPS_DENOMINATOR;

            // Convert to uint8 for hook (hook uses 0-100 percent, so we convert from bps)
            // forge-lint: disable-next-line(unsafe-typecast)
            uint8 slashPercent = uint8(slashPercentBps / BPS_TO_PERCENT);
            if (slashPercent > MAX_PERCENT) slashPercent = MAX_PERCENT;

            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onUnappliedSlash, (serviceId, abi.encodePacked(operator), slashPercent))
            );
        }
    }

    function _computeServiceCommitmentExposureBps(
        uint64 serviceId,
        address operator,
        uint64 blueprintId
    ) internal view returns (uint16 exposureBps) {
        Types.AssetSecurityRequirement[] storage reqs = _serviceSecurityRequirements[serviceId];
        uint256 reqsLength = reqs.length;
        if (reqsLength == 0) return BPS_DENOMINATOR;

        // L-12 FIX: Cache storage reads
        address serviceFeeDistributor = _serviceFeeDistributor;

        if (serviceFeeDistributor == address(0)) {
            uint256 sum;
            uint256 count;
            for (uint256 i = 0; i < reqsLength;) {
                Types.Asset memory asset = reqs[i].asset;
                // forge-lint: disable-next-line(asm-keccak256)
                bytes32 assetHash = keccak256(abi.encode(asset.kind, asset.token));
                uint16 committed = _serviceSecurityCommitmentBps[serviceId][operator][assetHash];
                sum += committed;
                count++;
                unchecked { ++i; }
            }
            if (count == 0) return BPS_DENOMINATOR;
            exposureBps = uint16(sum / count);
            if (exposureBps > BPS_DENOMINATOR) exposureBps = BPS_DENOMINATOR;
            return exposureBps;
        }

        // L-12 FIX: Cache storage reads
        address priceOracleAddr = _priceOracle;
        IPriceOracle oracle = IPriceOracle(priceOracleAddr);
        bool useOracle = priceOracleAddr != address(0);

        uint256 weightedCommitted; // scaled down by BPS_DENOMINATOR to avoid overflow
        uint256 totalWeight;
        for (uint256 i = 0; i < reqsLength;) {
            Types.Asset memory asset = reqs[i].asset;
            // forge-lint: disable-next-line(asm-keccak256)
            bytes32 assetHash = keccak256(abi.encode(asset.kind, asset.token));
            uint16 committed = _serviceSecurityCommitmentBps[serviceId][operator][assetHash];
            if (committed == 0) {
                unchecked { ++i; }
                continue;
            }

            (uint256 allScore, uint256 fixedScore) =
                IServiceFeeDistributor(serviceFeeDistributor).getPoolScore(operator, blueprintId, asset);
            uint256 totalScore = allScore + fixedScore;
            if (totalScore == 0) {
                unchecked { ++i; }
                continue;
            }

            uint256 weight = totalScore;
            if (useOracle) {
                address token = asset.kind == Types.AssetKind.Native ? address(0) : asset.token;
                weight = oracle.toUSD(token, totalScore);
            }
            if (weight == 0) {
                unchecked { ++i; }
                continue;
            }

            weightedCommitted += Math.mulDiv(weight, committed, BPS_DENOMINATOR);
            totalWeight += weight;
            unchecked { ++i; }
        }

        if (totalWeight == 0) return BPS_DENOMINATOR;
        exposureBps = uint16(Math.mulDiv(weightedCommitted, BPS_DENOMINATOR, totalWeight));
        if (exposureBps > BPS_DENOMINATOR) exposureBps = BPS_DENOMINATOR;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Dispute a pending slash within the dispute window
    /// @param slashId The slash proposal ID to dispute
    /// @param reason A human-readable reason for the dispute
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
        actualSlashed = _staking.slashForBlueprint(
            proposal.operator,
            svc.blueprintId,
            proposal.serviceId,
            proposal.effectiveSlashBps,
            proposal.evidence
        );

        SlashingLib.markExecuted(_slashProposals, slashId, actualSlashed);

        // M-9 FIX: Decrement pending slash count to allow delegator withdrawals
        _staking.decrementPendingSlash(proposal.operator);

        // Record slash for metrics tracking (affects rewards distribution)
        _recordSlash(proposal.operator, proposal.serviceId, actualSlashed);

        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            uint16 slashPercentBps = proposal.effectiveSlashBps;
            if (slashPercentBps > BPS_DENOMINATOR) slashPercentBps = BPS_DENOMINATOR;

            // Convert to uint8 for hook (hook uses 0-100 percent, so we convert from bps)
            // forge-lint: disable-next-line(unsafe-typecast)
            uint8 slashPercent = uint8(slashPercentBps / BPS_TO_PERCENT);
            if (slashPercent > MAX_PERCENT) slashPercent = MAX_PERCENT;

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
            uint256 actualSlashed = _staking.slashForBlueprint(
                proposal.operator,
                svc.blueprintId,
                proposal.serviceId,
                proposal.effectiveSlashBps,
                proposal.evidence
            );

            SlashingLib.markExecuted(_slashProposals, slashIds[i], actualSlashed);

            // M-9 FIX: Decrement pending slash count to allow delegator withdrawals
            _staking.decrementPendingSlash(proposal.operator);

            // Record slash for metrics tracking (affects rewards distribution)
            _recordSlash(proposal.operator, proposal.serviceId, actualSlashed);

            totalSlashed += actualSlashed;
            executedCount++;

            // Call hook
            Types.Blueprint storage bp = _blueprints[svc.blueprintId];
            if (bp.manager != address(0)) {
                uint16 slashPercentBps = proposal.effectiveSlashBps;
                // forge-lint: disable-next-line(unsafe-typecast)
                uint8 slashPercent = uint8(slashPercentBps / BPS_TO_PERCENT);
                if (slashPercent > MAX_PERCENT) slashPercent = MAX_PERCENT;

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

    /// @notice Cancel a pending slash proposal
    /// @dev Only callable by SLASH_ADMIN_ROLE
    /// @param slashId The slash proposal ID to cancel
    /// @param reason A human-readable reason for the cancellation
    function cancelSlash(uint64 slashId, string calldata reason) external {
        if (!hasRole(SLASH_ADMIN_ROLE, msg.sender)) {
            revert Errors.NotSlashCanceller(slashId, msg.sender);
        }

        // M-9 FIX: Get operator before cancelling (proposal may be cleared)
        address operator = _slashProposals[slashId].operator;

        SlashingLib.cancelSlash(_slashProposals, slashId, msg.sender, reason);

        // M-9 FIX: Decrement pending slash count to allow delegator withdrawals
        _staking.decrementPendingSlash(operator);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update slashing configuration
    /// @param disputeWindow The dispute window duration in seconds
    /// @param instantSlashEnabled Whether instant slashing (bypassing dispute) is enabled
    /// @param maxSlashBps Maximum slash amount in basis points (0-10000)
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

    /// @notice Get details of a slash proposal
    /// @param slashId The slash proposal ID to query
    /// @return The slash proposal struct with all details
    function getSlashProposal(uint64 slashId) external view returns (SlashingLib.SlashProposal memory) {
        return _slashProposals[slashId];
    }
}
