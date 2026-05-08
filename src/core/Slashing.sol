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
    )
        external
        nonReentrant
        returns (uint64 slashId)
    {
        // M-6 FIX: Validate slashBps does not exceed 100% (10000 bps)
        if (slashBps > BPS_DENOMINATOR) {
            revert Errors.SlashBpsExceedsMax(slashBps, BPS_DENOMINATOR);
        }
        // Reject zero evidence: the field is the off-chain identifier (e.g. an IPFS
        // CID hash) that monitors index by, and a 0x00…00 entry is indistinguishable
        // from "missing." Operators should always supply a real reference.
        if (evidence == bytes32(0)) {
            revert Errors.InvalidState();
        }

        Types.Service storage svc = _getService(serviceId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        bool authorized = msg.sender == svc.owner || msg.sender == bp.owner;
        if (!authorized && bp.manager != address(0)) {
            // Blueprint manager declares an additional slashing origin (e.g. a service-
            // specific oracle / committee). Operators audit the BSM and its upgradeability
            // before registering — that is the documented trust boundary.
            try IBlueprintServiceManager(bp.manager).querySlashingOrigin(serviceId) returns (address origin) {
                authorized = msg.sender == origin;
            } catch { }
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

        // Cap concurrent pending slashes per operator so a malicious proposer can't
        // grief by spamming. `maxPendingSlashesPerOperator` is validated non-zero in
        // both `initializeConfig` and `updateConfig`, so we trust it here.
        if (_operatorActiveSlashProposals[operator] >= _slashState.config.maxPendingSlashesPerOperator) {
            revert Errors.InvalidState();
        }
        _operatorActiveSlashProposals[operator] += 1;

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
                abi.encodeCall(
                    IBlueprintServiceManager.onUnappliedSlash, (serviceId, abi.encodePacked(operator), slashPercent)
                )
            );
        }
    }

    function _computeServiceCommitmentExposureBps(
        uint64 serviceId,
        address operator,
        uint64 blueprintId
    )
        internal
        view
        returns (uint16 exposureBps)
    {
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
                unchecked {
                    ++i;
                }
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
                unchecked {
                    ++i;
                }
                continue;
            }

            (uint256 allScore, uint256 fixedScore) =
                IServiceFeeDistributor(serviceFeeDistributor).getPoolScore(operator, blueprintId, asset);
            uint256 totalScore = allScore + fixedScore;
            if (totalScore == 0) {
                unchecked {
                    ++i;
                }
                continue;
            }

            uint256 weight = totalScore;
            if (useOracle) {
                address token = asset.kind == Types.AssetKind.Native ? address(0) : asset.token;
                weight = oracle.toUSD(token, totalScore);
            }
            if (weight == 0) {
                unchecked {
                    ++i;
                }
                continue;
            }

            weightedCommitted += Math.mulDiv(weight, committed, BPS_DENOMINATOR);
            totalWeight += weight;
            unchecked {
                ++i;
            }
        }

        if (totalWeight == 0) return BPS_DENOMINATOR;
        exposureBps = uint16(Math.mulDiv(weightedCommitted, BPS_DENOMINATOR, totalWeight));
        if (exposureBps > BPS_DENOMINATOR) exposureBps = BPS_DENOMINATOR;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Dispute a pending slash within the dispute window.
    /// @dev SLASH_ADMIN can dispute without a bond (it's the official escalation path).
    ///      The slashed operator must post `_slashState.config.disputeBond` in native
    ///      asset. Bond is forfeit to treasury if the dispute auto-fails or the slash
    ///      executes; refunded if SLASH_ADMIN cancels the slash.
    ///      A SLASH_ADMIN that is also the original proposer cannot self-dispute their
    ///      own slash: that path lets them freeze operator stake for the entire
    ///      `disputeResolutionDeadline` window for free, then capture the operator's
    ///      bond (when treasury == admin) on auto-execution. Admin escalation must
    ///      come from a different account.
    function disputeSlash(uint64 slashId, string calldata reason) external payable nonReentrant {
        SlashingLib.SlashProposal storage proposal = _slashProposals[slashId];

        bool isAdmin = hasRole(SLASH_ADMIN_ROLE, msg.sender);
        if (msg.sender != proposal.operator && !isAdmin) {
            revert Errors.NotSlashDisputer(slashId, msg.sender);
        }
        if (isAdmin && msg.sender == proposal.proposer) {
            revert Errors.Unauthorized();
        }

        uint256 requiredBond = isAdmin ? 0 : _slashState.config.disputeBond;
        if (msg.value != requiredBond) {
            revert Errors.InvalidMsgValue(requiredBond, msg.value);
        }

        SlashingLib.disputeSlash(_slashProposals, _slashState.config, slashId, msg.sender, reason, msg.value);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXECUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Execute a pending slash after dispute window.
    /// @dev Routes through `slashForService` when the operator made explicit commitments
    ///      to this service so we only slash assets they actually backed. Falls back to
    ///      blueprint-wide slashing when there are no commitments (legacy services).
    function executeSlash(uint64 slashId) external nonReentrant returns (uint256 actualSlashed) {
        SlashingLib.SlashProposal storage proposal = _slashProposals[slashId];

        if (!SlashingLib.isExecutable(proposal)) {
            revert Errors.SlashNotExecutable(slashId);
        }

        Types.Service storage svc = _services[proposal.serviceId];

        actualSlashed = _executeSlashOnStaking(proposal, svc.blueprintId);

        SlashingLib.markExecuted(_slashProposals, slashId, actualSlashed);
        _staking.decrementPendingSlash(proposal.operator);
        _decrementOperatorPendingTracker(proposal.operator);
        _recordSlash(proposal.operator, proposal.serviceId, actualSlashed);

        // Bond forfeit (interaction) AFTER all state is finalized.
        _settleDisputeBond(proposal, /*refund*/ false);

        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            uint16 slashPercentBps = proposal.effectiveSlashBps;
            if (slashPercentBps > BPS_DENOMINATOR) slashPercentBps = BPS_DENOMINATOR;

            // forge-lint: disable-next-line(unsafe-typecast)
            uint8 slashPercent = uint8(slashPercentBps / BPS_TO_PERCENT);
            if (slashPercent > MAX_PERCENT) slashPercent = MAX_PERCENT;

            _tryCallManager(
                bp.manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onSlash,
                    (proposal.serviceId, abi.encodePacked(proposal.operator), slashPercent)
                )
            );
        }
    }

    /// @notice Execute multiple pending slashes in batch
    /// @dev More gas-efficient for operators executing multiple slashes.
    ///      Uses blueprint-aware slashing to only affect delegators exposed to each blueprint.
    /// @param slashIds Array of slash IDs to execute
    /// @return totalSlashed Total amount slashed across all executions
    /// @return executedCount Number of slashes successfully executed
    function executeSlashBatch(uint64[] calldata slashIds)
        external
        nonReentrant
        returns (uint256 totalSlashed, uint256 executedCount)
    {
        for (uint256 i = 0; i < slashIds.length; i++) {
            SlashingLib.SlashProposal storage proposal = _slashProposals[slashIds[i]];

            // Skip non-executable slashes instead of reverting
            if (!SlashingLib.isExecutable(proposal)) continue;

            Types.Service storage svc = _services[proposal.serviceId];

            uint256 actualSlashed = _executeSlashOnStaking(proposal, svc.blueprintId);

            SlashingLib.markExecuted(_slashProposals, slashIds[i], actualSlashed);
            _staking.decrementPendingSlash(proposal.operator);
            _decrementOperatorPendingTracker(proposal.operator);
            _recordSlash(proposal.operator, proposal.serviceId, actualSlashed);

            // Bond forfeit (interaction) AFTER all state is finalized.
            _settleDisputeBond(proposal, /*refund*/ false);

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
                    abi.encodeCall(
                        IBlueprintServiceManager.onSlash,
                        (proposal.serviceId, abi.encodePacked(proposal.operator), slashPercent)
                    )
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
    /// @dev Only callable by SLASH_ADMIN_ROLE. Strict CEI: every state mutation
    ///      (status flip, pending-count decrements) finalizes BEFORE the bond ETH
    ///      transfer, so a malicious disputer contract cannot re-enter and observe
    ///      a half-cancelled state. `nonReentrant` is defense-in-depth on top.
    function cancelSlash(uint64 slashId, string calldata reason) external nonReentrant {
        if (!hasRole(SLASH_ADMIN_ROLE, msg.sender)) {
            revert Errors.NotSlashCanceller(slashId, msg.sender);
        }

        SlashingLib.SlashProposal storage proposal = _slashProposals[slashId];
        address operator = proposal.operator;

        SlashingLib.cancelSlash(_slashProposals, slashId, msg.sender, reason);
        _staking.decrementPendingSlash(operator);
        _decrementOperatorPendingTracker(operator);

        // Bond refund last (interaction).
        _settleDisputeBond(proposal, /*refund*/ true);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update slashing configuration.
    function setSlashConfig(
        uint64 disputeWindow,
        bool instantSlashEnabled,
        uint16 maxSlashBps,
        uint64 disputeResolutionDeadline,
        uint256 disputeBond,
        uint16 maxPendingSlashesPerOperator
    )
        external
        onlyRole(ADMIN_ROLE)
    {
        SlashingLib.updateConfig(
            _slashState,
            disputeWindow,
            instantSlashEnabled,
            maxSlashBps,
            disputeResolutionDeadline,
            disputeBond,
            maxPendingSlashesPerOperator
        );
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

    /// @notice Get current slashing configuration
    function getSlashConfig() external view returns (SlashingLib.SlashConfig memory) {
        return _slashState.config;
    }

    /// @dev Internal helper that picks the right slashing API based on whether the
    ///      operator made explicit per-asset commitments to the offending service.
    function _executeSlashOnStaking(
        SlashingLib.SlashProposal storage proposal,
        uint64 blueprintId
    ) internal returns (uint256 actualSlashed) {
        Types.AssetSecurityCommitment[] memory commitments = _loadServiceCommitments(proposal.serviceId, proposal.operator);

        if (commitments.length == 0) {
            return _staking.slashForBlueprint(
                proposal.operator, blueprintId, proposal.serviceId, proposal.effectiveSlashBps, proposal.evidence
            );
        }
        return _staking.slashForService(
            proposal.operator,
            blueprintId,
            proposal.serviceId,
            commitments,
            proposal.effectiveSlashBps,
            proposal.evidence
        );
    }

    function _loadServiceCommitments(
        uint64 serviceId,
        address operator
    ) internal view returns (Types.AssetSecurityCommitment[] memory copy) {
        Types.AssetSecurityCommitment[] storage stored = _serviceSecurityCommitments[serviceId][operator];
        uint256 len = stored.length;
        copy = new Types.AssetSecurityCommitment[](len);
        for (uint256 i = 0; i < len; i++) {
            copy[i] = stored[i];
        }
    }

    /// @dev Settle the dispute bond. On `refund == true` (cancelSlash) the bond is
    ///      credited to a per-disputer pull-pattern mapping that the disputer drains
    ///      via `claimDisputeBond()`. We do NOT push the bond directly back to the
    ///      disputer here because their fallback could re-enter staking — at this
    ///      point the protocol has already decremented `_operatorPendingSlashCount`
    ///      so an unstake call would slip past the slash-blocking gate and exit at
    ///      the pre-slash exchange rate (Round 2 economic F3).
    ///      On `refund == false` (executeSlash / auto-fail) the bond is forwarded to
    ///      the treasury via push, since the treasury is a protocol-controlled
    ///      address (typically multisig / governance) and a re-entry there cannot
    ///      bypass operator-side staking guards.
    function _settleDisputeBond(SlashingLib.SlashProposal storage proposal, bool refund) internal {
        uint256 bond = proposal.disputeBond;
        if (bond == 0) return;
        address disputer = proposal.disputer;

        // Clear before any external interaction (CEI).
        proposal.disputeBond = 0;
        proposal.disputer = address(0);

        if (refund && disputer != address(0)) {
            // Pull-pattern: credit and emit; disputer claims via claimDisputeBond().
            _pendingDisputeBondRefunds[disputer] += bond;
            emit DisputeBondCredited(disputer, bond);
            return;
        }

        address payable t = _treasury;
        if (t == address(0)) {
            // Treasury unset — restore the bond on the proposal so it can be settled
            // once a treasury is configured, rather than silently stranding ETH.
            proposal.disputeBond = bond;
            proposal.disputer = disputer;
            return;
        }
        (bool ok,) = t.call{ value: bond }("");
        if (!ok) {
            proposal.disputeBond = bond;
            proposal.disputer = disputer;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE BOND PULL CLAIM
    // ═══════════════════════════════════════════════════════════════════════════

    event DisputeBondCredited(address indexed disputer, uint256 amount);
    event DisputeBondClaimed(address indexed disputer, uint256 amount);

    /// @notice Disputer-initiated claim of any bond credited via `cancelSlash`.
    /// @dev `nonReentrant` and CEI-ordered; the recipient cannot re-enter the
    ///      staking module to slip past the pending-slash gate because that gate
    ///      was decremented in the original `cancelSlash` transaction, which has
    ///      long since been mined. By the time this claim runs, no slash is in
    ///      flight for the disputer's affected operator (or a fresh one has been
    ///      proposed and the operator's withdrawal path is blocked again on its
    ///      own merit).
    function claimDisputeBond() external nonReentrant {
        uint256 amount = _pendingDisputeBondRefunds[msg.sender];
        if (amount == 0) revert Errors.ZeroAmount();
        _pendingDisputeBondRefunds[msg.sender] = 0;
        (bool ok,) = msg.sender.call{ value: amount }("");
        if (!ok) {
            // Restore on transfer failure so the disputer can retry. Forge-style
            // checks-effects-interactions require us to re-credit AFTER the failed
            // call, never to leave the user without a recourse.
            _pendingDisputeBondRefunds[msg.sender] = amount;
            revert Errors.InvalidState();
        }
        emit DisputeBondClaimed(msg.sender, amount);
    }

    /// @notice Read pending dispute-bond refund balance for a disputer.
    function pendingDisputeBondRefund(address disputer) external view returns (uint256) {
        return _pendingDisputeBondRefunds[disputer];
    }

    function _decrementOperatorPendingTracker(address operator) internal {
        uint64 cur = _operatorActiveSlashProposals[operator];
        if (cur > 0) _operatorActiveSlashProposals[operator] = cur - 1;
    }
}
