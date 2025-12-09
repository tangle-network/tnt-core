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
        uint64 indexed blueprintId,
        address indexed owner,
        address manager,
        string metadataUri
    );

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
}
