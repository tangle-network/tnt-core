// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title BlueprintsManage
/// @notice Blueprint reads and ownership management
abstract contract BlueprintsManage is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintUpdated(uint64 indexed blueprintId, string metadataUri, bytes32 metadataHash);
    event BlueprintTransferProposed(uint64 indexed blueprintId, address indexed from, address indexed pendingOwner);
    event BlueprintTransferCancelled(uint64 indexed blueprintId, address indexed owner);
    event BlueprintTransferred(uint64 indexed blueprintId, address indexed from, address indexed to);
    event BlueprintDeactivated(uint64 indexed blueprintId);
    event JobEventRateSet(uint64 indexed blueprintId, uint8 indexed jobIndex, uint256 rate);
    event BlueprintResourceRequirementsSet(uint64 indexed blueprintId, uint256 count);
    event BlueprintSourcesUpdated(uint64 indexed blueprintId, uint256 sourceCount);
    event BlueprintSourcesAcked(uint64 indexed blueprintId, address indexed operator, bytes32 sourcesHash);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get current blueprint count
    function blueprintCount() external view returns (uint64) {
        return _blueprintCount;
    }

    /// @notice Get blueprint metadata and URI
    function blueprintMetadata(uint64 blueprintId)
        external
        view
        returns (Types.BlueprintMetadata memory metadata, string memory metadataUri, bytes32 metadataHash)
    {
        metadata = _blueprintMetadata[blueprintId];
        metadataUri = _blueprintMetadataUri[blueprintId];
        metadataHash = _blueprintMetadataHash[blueprintId];
    }

    /// @notice Get blueprint sources
    function blueprintSources(uint64 blueprintId) external view returns (Types.BlueprintSource[] memory sources) {
        Types.BlueprintSource[] storage stored = _blueprintSources[blueprintId];
        sources = new Types.BlueprintSource[](stored.length);
        for (uint256 i = 0; i < stored.length; ++i) {
            sources[i] = stored[i];
        }
    }

    /// @notice Get blueprint supported membership models
    function blueprintSupportedMemberships(uint64 blueprintId)
        external
        view
        returns (Types.MembershipModel[] memory memberships)
    {
        Types.MembershipModel[] storage stored = _blueprintSupportedMemberships[blueprintId];
        memberships = new Types.MembershipModel[](stored.length);
        for (uint256 i = 0; i < stored.length; ++i) {
            memberships[i] = stored[i];
        }
    }

    /// @notice Get master blueprint revision
    function blueprintMasterRevision(uint64 blueprintId) external view returns (uint32) {
        return _blueprintMasterRevisions[blueprintId];
    }

    /// @notice keccak256 of the ABI-encoded definition captured at creation.
    /// @dev Verifies an event-sourced copy (the master manager's
    ///      BlueprintDefinitionRecorded event carries the full bytes). Zero for
    ///      blueprints created before the definition-hash migration.
    function blueprintDefinitionHash(uint64 blueprintId) external view returns (bytes32) {
        return _blueprintDefinitionHash[blueprintId];
    }

    /// @notice Retrieve the blueprint definition, reconstructed from the decomposed
    /// on-chain fields (no monolithic blob is stored — `blueprintDefinitionHash`
    /// anchors the creation-time encoding; the full bytes live in the master
    /// manager's BlueprintDefinitionRecorded event). Jobs round-trip exactly.
    /// `hasConfig` reads true with the creation-time normalized config, and
    /// sources reflect the current (post-genesis) set — the view the blueprint
    /// manager reads to resolve operator binaries.
    function getBlueprintDefinition(uint64 blueprintId)
        external
        view
        returns (Types.BlueprintDefinition memory definition)
    {
        if (_blueprints[blueprintId].createdAt == 0) revert Errors.BlueprintNotFound(blueprintId);
        definition.metadataUri = _blueprintMetadataUri[blueprintId];
        definition.metadataHash = _blueprintMetadataHash[blueprintId];
        definition.manager = _blueprints[blueprintId].manager;
        definition.masterManagerRevision = _blueprintMasterRevisions[blueprintId];
        definition.hasConfig = true;
        definition.config = _blueprintConfigs[blueprintId];
        definition.metadata = _blueprintMetadata[blueprintId];

        definition.jobs = _blueprintJobs[blueprintId];

        definition.registrationSchema = _registrationSchemas[blueprintId];
        definition.requestSchema = _requestSchemas[blueprintId];
        definition.sources = _blueprintSources[blueprintId];
        definition.supportedMemberships = _blueprintSupportedMemberships[blueprintId];
    }

    /// @notice Update blueprint metadata
    function updateBlueprint(
        uint64 blueprintId,
        string calldata metadataUri,
        bytes32 metadataHash
    )
        external
        nonReentrant
    {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }
        if (_blueprintMetadataLocked[blueprintId]) revert Errors.BlueprintMetadataLocked(blueprintId);
        if (bytes(metadataUri).length == 0) revert Errors.BlueprintMetadataRequired();
        if (metadataHash == bytes32(0)) revert Errors.BlueprintMetadataHashRequired();
        _blueprintMetadataUri[blueprintId] = metadataUri;
        _blueprintMetadataHash[blueprintId] = metadataHash;
        emit BlueprintUpdated(blueprintId, metadataUri, metadataHash);
    }

    /// @notice Replace a blueprint's binary sources (owner-only).
    /// @dev createBlueprint writes sources once at genesis; this lets the owner
    ///      repoint the blueprint at real, fetchable, multi-arch artifacts after
    ///      creation — correcting a placeholder source, or rolling the source
    ///      forward each release so operators cold-starting through the manager
    ///      fetch the right per-arch binary. The manager resolves the initial
    ///      binary from these sources (not from published BinaryVersions, which
    ///      only drive in-place upgrades), so a wrong/placeholder source here
    ///      means no operator can boot the blueprint. Same validation as
    ///      createBlueprint: >=1 source, each with >=1 binary, every binary
    ///      carrying a non-zero sha256. Sources are not lockable; ownership is
    ///      the gate. The active/published BinaryVersion set is unaffected.
    function setBlueprintSources(
        uint64 blueprintId,
        Types.BlueprintSource[] calldata sources
    )
        external
        whenNotPaused
        nonReentrant
    {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }
        _validateBlueprintSources(sources);
        _writeBlueprintSources(blueprintId, sources);
        emit BlueprintSourcesUpdated(blueprintId, sources.length);
    }

    /// @notice Propose a transfer of blueprint ownership (step 1 of 2).
    /// @dev Two-step (propose/accept) so a leaked owner key cannot instantly hand the
    ///      blueprint's binary-distribution authority to an attacker — the proposed
    ///      owner must call `acceptBlueprintOwnership`, and the current owner can
    ///      revoke a pending proposal until then via `cancelBlueprintTransfer`.
    function transferBlueprint(uint64 blueprintId, address newOwner) external whenNotPaused nonReentrant {
        if (newOwner == address(0)) revert Errors.ZeroAddress();

        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        _pendingBlueprintOwner[blueprintId] = newOwner;
        emit BlueprintTransferProposed(blueprintId, bp.owner, newOwner);
    }

    /// @notice Accept a pending blueprint ownership transfer (step 2 of 2).
    /// @dev Only the address named by the current owner in `transferBlueprint` can
    ///      accept; this is what actually moves `bp.owner`.
    function acceptBlueprintOwnership(uint64 blueprintId) external whenNotPaused nonReentrant {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        address pending = _pendingBlueprintOwner[blueprintId];
        if (pending == address(0) || msg.sender != pending) {
            revert Errors.NotPendingBlueprintOwner(blueprintId, msg.sender);
        }

        address oldOwner = bp.owner;
        bp.owner = pending;
        delete _pendingBlueprintOwner[blueprintId];
        emit BlueprintTransferred(blueprintId, oldOwner, pending);
    }

    /// @notice Cancel a pending blueprint ownership transfer.
    function cancelBlueprintTransfer(uint64 blueprintId) external whenNotPaused nonReentrant {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }
        delete _pendingBlueprintOwner[blueprintId];
        emit BlueprintTransferCancelled(blueprintId, bp.owner);
    }

    /// @notice Get the pending owner of a blueprint (zero if none).
    function pendingBlueprintOwner(uint64 blueprintId) external view returns (address) {
        return _pendingBlueprintOwner[blueprintId];
    }

    /// @notice Acknowledge the blueprint's current cold-start source set (operator opt-in).
    /// @dev The off-chain manager gates cold-start / re-provision boot on this ack so a
    ///      blueprint owner cannot silently repoint the executable an operator runs:
    ///      `setBlueprintSources` changes `_blueprintSourcesHash`, which invalidates any
    ///      prior ack. The operator passes the exact digest it intends to run; the call
    ///      reverts if it no longer matches the live sources (front-run / stale ack).
    /// @param blueprintId Target blueprint.
    /// @param sourcesHash The digest the operator is acking; must equal the live hash.
    function ackBlueprintSources(uint64 blueprintId, bytes32 sourcesHash) external whenNotPaused nonReentrant {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner == address(0)) revert Errors.BlueprintNotFound(blueprintId);
        // Only operators registered for the blueprint can ack — acks are meaningful
        // only for accounts that actually boot the binary.
        if (!_blueprintOperators[blueprintId].contains(msg.sender)) {
            revert Errors.OperatorNotRegistered(blueprintId, msg.sender);
        }
        bytes32 live = _blueprintSourcesHash[blueprintId];
        if (live == bytes32(0) || sourcesHash != live) {
            revert Errors.StaleSourcesAck(blueprintId, sourcesHash, live);
        }
        _operatorAckedSourcesHash[blueprintId][msg.sender] = sourcesHash;
        emit BlueprintSourcesAcked(blueprintId, msg.sender, sourcesHash);
    }

    /// @notice The current cold-start sources digest for a blueprint.
    function blueprintSourcesHash(uint64 blueprintId) external view returns (bytes32) {
        return _blueprintSourcesHash[blueprintId];
    }

    /// @notice Whether `operator` has acked the blueprint's CURRENT cold-start sources.
    /// @dev Off-chain managers should treat `false` as "do not boot the new binary for
    ///      this operator until it re-acks", which is what makes a malicious repoint safe.
    function operatorAckedCurrentSources(uint64 blueprintId, address operator) external view returns (bool) {
        bytes32 live = _blueprintSourcesHash[blueprintId];
        return live != bytes32(0) && _operatorAckedSourcesHash[blueprintId][operator] == live;
    }

    /// @notice Deactivate a blueprint
    function deactivateBlueprint(uint64 blueprintId) external whenNotPaused nonReentrant {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        bp.active = false;
        emit BlueprintDeactivated(blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PER-JOB PRICING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set event rate overrides for one or more job types in a blueprint
    /// @param blueprintId The blueprint ID
    /// @param jobIndexes Array of job indexes
    /// @param rates Array of per-job event rates (0 to clear override and use blueprint default)
    function setJobEventRates(
        uint64 blueprintId,
        uint8[] calldata jobIndexes,
        uint256[] calldata rates
    )
        external
        nonReentrant
    {
        if (jobIndexes.length != rates.length) revert Errors.LengthMismatch();

        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        uint256 jobCount = _blueprintJobs[blueprintId].length;
        for (uint256 i = 0; i < jobIndexes.length; i++) {
            if (jobIndexes[i] >= jobCount) {
                revert Errors.InvalidJobIndex(jobIndexes[i]);
            }
            _jobEventRates[blueprintId][jobIndexes[i]] = rates[i];
            emit JobEventRateSet(blueprintId, jobIndexes[i], rates[i]);
        }
    }

    /// @notice Get the effective event rate for a specific job type
    /// @param blueprintId The blueprint ID
    /// @param jobIndex The job index
    /// @return rate The per-job rate if set, otherwise the blueprint's default eventRate
    function getJobEventRate(uint64 blueprintId, uint8 jobIndex) external view returns (uint256 rate) {
        rate = _jobEventRates[blueprintId][jobIndex];
        if (rate == 0) {
            rate = _blueprintConfigs[blueprintId].eventRate;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT RESOURCE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set default resource requirements for a blueprint
    /// @param blueprintId The blueprint ID
    /// @param requirements Array of resource commitments (no duplicate kinds, all count > 0)
    function setBlueprintResourceRequirements(
        uint64 blueprintId,
        Types.ResourceCommitment[] calldata requirements
    )
        external
        nonReentrant
    {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        // Validate: no duplicate kinds, all counts > 0
        delete _blueprintResourceRequirements[blueprintId];
        for (uint256 i = 0; i < requirements.length; i++) {
            if (requirements[i].count == 0) revert Errors.ZeroAmount();
            // Check for duplicate kinds
            for (uint256 j = 0; j < i; j++) {
                if (requirements[j].kind == requirements[i].kind) {
                    revert Errors.InvalidState();
                }
            }
            _blueprintResourceRequirements[blueprintId].push(requirements[i]);
        }

        emit BlueprintResourceRequirementsSet(blueprintId, requirements.length);
    }

    /// @notice Get default resource requirements for a blueprint
    /// @param blueprintId The blueprint ID
    /// @return The array of resource commitments
    function getBlueprintResourceRequirements(uint64 blueprintId)
        external
        view
        returns (Types.ResourceCommitment[] memory)
    {
        return _blueprintResourceRequirements[blueprintId];
    }
}
