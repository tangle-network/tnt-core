// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleBlueprints
/// @notice Blueprint management interface
interface ITangleBlueprints {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintCreated(uint64 indexed blueprintId, address indexed owner, address manager, string metadataUri);

    event BlueprintUpdated(uint64 indexed blueprintId, string metadataUri);

    event BlueprintTransferred(uint64 indexed blueprintId, address indexed from, address indexed to);

    event BlueprintDeactivated(uint64 indexed blueprintId);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a blueprint from an encoded definition that includes schemas and job metadata
    /// @param definition Fully populated blueprint definition struct
    /// @return blueprintId The new blueprint ID
    function createBlueprint(Types.BlueprintDefinition calldata definition) external returns (uint64 blueprintId);

    /// @notice Update blueprint metadata
    function updateBlueprint(uint64 blueprintId, string calldata metadataUri) external;

    /// @notice Transfer blueprint ownership
    function transferBlueprint(uint64 blueprintId, address newOwner) external;

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

    /// @notice Get blueprint metadata and URI
    function blueprintMetadata(uint64 blueprintId)
        external
        view
        returns (Types.BlueprintMetadata memory metadata, string memory metadataUri);

    /// @notice Get blueprint sources
    function blueprintSources(uint64 blueprintId) external view returns (Types.BlueprintSource[] memory sources);

    /// @notice Get blueprint supported membership models
    function blueprintSupportedMemberships(uint64 blueprintId)
        external
        view
        returns (Types.MembershipModel[] memory memberships);

    /// @notice Get master blueprint revision
    function blueprintMasterRevision(uint64 blueprintId) external view returns (uint32);

    /// @notice Set event rate overrides for one or more job types in a blueprint
    function setJobEventRates(uint64 blueprintId, uint8[] calldata jobIndexes, uint256[] calldata rates) external;

    /// @notice Get the effective event rate for a specific job type
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
