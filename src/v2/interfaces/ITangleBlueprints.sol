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

    /// @notice Create a new blueprint with a service manager
    /// @param metadataUri IPFS or URL to blueprint metadata
    /// @param manager IBlueprintServiceManager implementation
    /// @return blueprintId The new blueprint ID
    function createBlueprint(string calldata metadataUri, address manager) external returns (uint64 blueprintId);

    /// @notice Create a blueprint from an encoded definition that includes schemas and job metadata
    /// @param encodedDefinition ABI-encoded Types.BlueprintDefinition struct
    /// @return blueprintId The new blueprint ID
    function createBlueprint(bytes calldata encodedDefinition) external returns (uint64 blueprintId);

    /// @notice Create a blueprint with full configuration
    /// @param metadataUri IPFS or URL to blueprint metadata
    /// @param manager IBlueprintServiceManager implementation
    /// @param config Blueprint configuration
    /// @return blueprintId The new blueprint ID
    function createBlueprintWithConfig(
        string calldata metadataUri,
        address manager,
        Types.BlueprintConfig calldata config
    ) external returns (uint64 blueprintId);

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
}
