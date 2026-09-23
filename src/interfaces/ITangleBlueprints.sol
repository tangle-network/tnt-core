// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleBlueprints
/// @notice Blueprint management interface
interface ITangleBlueprints {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintCreated(
        uint64 indexed blueprintId, address indexed owner, address manager, string metadataUri, bytes32 metadataHash
    );

    event BlueprintUpdated(uint64 indexed blueprintId, string metadataUri, bytes32 metadataHash);

    /// @dev Emitted when a two-step ownership transfer is proposed (pendingOwner = the proposed owner).
    event BlueprintTransferProposed(uint64 indexed blueprintId, address indexed from, address indexed pendingOwner);

    /// @dev Emitted when a pending two-step ownership transfer is cancelled by the current owner.
    event BlueprintTransferCancelled(uint64 indexed blueprintId, address indexed owner);

    event BlueprintTransferred(uint64 indexed blueprintId, address indexed from, address indexed to);

    event BlueprintDeactivated(uint64 indexed blueprintId);

    event BlueprintSourcesAcked(uint64 indexed blueprintId, address indexed operator, bytes32 sourcesHash);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a blueprint from an encoded definition that includes schemas and job metadata
    /// @param definition Fully populated blueprint definition struct
    /// @return blueprintId The new blueprint ID
    function createBlueprint(Types.BlueprintDefinition calldata definition) external returns (uint64 blueprintId);

    /// @notice Update blueprint metadata
    function updateBlueprint(uint64 blueprintId, string calldata metadataUri, bytes32 metadataHash) external;

    /// @notice Replace a blueprint's binary sources (owner only)
    function setBlueprintSources(uint64 blueprintId, Types.BlueprintSource[] calldata sources) external;

    /// @notice Propose a transfer of blueprint ownership (step 1 of 2)
    function transferBlueprint(uint64 blueprintId, address newOwner) external;

    /// @notice Accept a pending blueprint ownership transfer (step 2 of 2)
    function acceptBlueprintOwnership(uint64 blueprintId) external;

    /// @notice Cancel a pending blueprint ownership transfer
    function cancelBlueprintTransfer(uint64 blueprintId) external;

    /// @notice The pending owner of a blueprint (zero if none)
    function pendingBlueprintOwner(uint64 blueprintId) external view returns (address);

    /// @notice Acknowledge the blueprint's current cold-start sources digest (operator opt-in)
    function ackBlueprintSources(uint64 blueprintId, bytes32 sourcesHash) external;

    /// @notice The current cold-start sources digest for a blueprint
    function blueprintSourcesHash(uint64 blueprintId) external view returns (bytes32);

    /// @notice Whether `operator` has acked the blueprint's current cold-start sources
    function operatorAckedCurrentSources(uint64 blueprintId, address operator) external view returns (bool);

    /// @notice Deactivate a blueprint
    function deactivateBlueprint(uint64 blueprintId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get blueprint info
    function getBlueprint(uint64 blueprintId) external view returns (Types.Blueprint memory);

    /// @notice Get blueprint configuration
    function getBlueprintConfig(uint64 blueprintId) external view returns (Types.BlueprintConfig memory);

    /// @notice Get number of operators for a blueprint
    function blueprintOperatorCount(uint64 blueprintId) external view returns (uint256);

    /// @notice Get current blueprint count
    function blueprintCount() external view returns (uint64);

    /// @notice Get the original blueprint definition
    function getBlueprintDefinition(uint64 blueprintId)
        external
        view
        returns (Types.BlueprintDefinition memory definition);

    /// @notice keccak256 of the ABI-encoded definition captured at creation.
    /// @dev Verifies an event-sourced copy of the definition (the master manager's
    ///      BlueprintDefinitionRecorded event carries the full bytes).
    function blueprintDefinitionHash(uint64 blueprintId) external view returns (bytes32);

    /// @notice Get blueprint metadata and URI
    function blueprintMetadata(uint64 blueprintId)
        external
        view
        returns (Types.BlueprintMetadata memory metadata, string memory metadataUri, bytes32 metadataHash);

    /// @notice Get blueprint supported membership models
    function blueprintSupportedMemberships(uint64 blueprintId)
        external
        view
        returns (Types.MembershipModel[] memory memberships);

    /// @notice Get master blueprint revision
    function blueprintMasterRevision(uint64 blueprintId) external view returns (uint32);

    /// @notice Set event rate overrides for one or more job types in a blueprint
    /// @dev Rates are denominated in the SETTLEMENT ASSET's smallest unit, not a fixed
    ///      18-decimal scale. Each EventDriven service pins its settlement asset at
    ///      activation (`getServicePaymentAsset`); a blueprint whose services settle in a
    ///      6-decimal token (e.g. Tempo PathUSD) must set rates in 6-dec units. The rate is
    ///      per-blueprint but the decimals are per-service-asset, so a blueprint intended
    ///      for a single settlement token should document that token's decimals.
    function setJobEventRates(uint64 blueprintId, uint8[] calldata jobIndexes, uint256[] calldata rates) external;

    /// @notice Get the effective event rate for a specific job type
    /// @dev The returned rate is in the settlement asset's smallest unit — see
    ///      `setJobEventRates` and `getServicePaymentAsset`.
    function getJobEventRate(uint64 blueprintId, uint8 jobIndex) external view returns (uint256 rate);

    // ═══════════════════════════════════════════════════════════════════════════
    // RESOURCE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintResourceRequirementsSet(uint64 indexed blueprintId, uint256 count);

    /// @notice Set default resource requirements for a blueprint (owner only)
    function setBlueprintResourceRequirements(
        uint64 blueprintId,
        Types.ResourceCommitment[] calldata requirements
    )
        external;

    /// @notice Get default resource requirements for a blueprint
    function getBlueprintResourceRequirements(uint64 blueprintId)
        external
        view
        returns (Types.ResourceCommitment[] memory);
}
