// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title BlueprintsManage
/// @notice Blueprint reads and ownership management
abstract contract BlueprintsManage is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintUpdated(uint64 indexed blueprintId, string metadataUri);
    event BlueprintTransferred(uint64 indexed blueprintId, address indexed from, address indexed to);
    event BlueprintDeactivated(uint64 indexed blueprintId);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Retrieve the original blueprint definition
    function getBlueprintDefinition(uint64 blueprintId)
        external
        view
        returns (Types.BlueprintDefinition memory definition)
    {
        bytes storage blob = _blueprintDefinitionBlobs[blueprintId];
        if (blob.length == 0) revert Errors.BlueprintNotFound(blueprintId);
        definition = abi.decode(blob, (Types.BlueprintDefinition));
    }

    /// @notice Update blueprint metadata
    function updateBlueprint(uint64 blueprintId, string calldata metadataUri) external {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }
        _blueprintMetadataUri[blueprintId] = metadataUri;
        emit BlueprintUpdated(blueprintId, metadataUri);
    }

    /// @notice Transfer blueprint ownership
    function transferBlueprint(uint64 blueprintId, address newOwner) external {
        if (newOwner == address(0)) revert Errors.ZeroAddress();

        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        address oldOwner = bp.owner;
        bp.owner = newOwner;
        emit BlueprintTransferred(blueprintId, oldOwner, newOwner);
    }

    /// @notice Deactivate a blueprint
    function deactivateBlueprint(uint64 blueprintId) external {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        bp.active = false;
        emit BlueprintDeactivated(blueprintId);
    }
}
