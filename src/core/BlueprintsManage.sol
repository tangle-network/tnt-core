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
    event JobEventRateSet(uint64 indexed blueprintId, uint8 indexed jobIndex, uint256 rate);

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

    // ═══════════════════════════════════════════════════════════════════════════
    // PER-JOB PRICING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set event rate overrides for one or more job types in a blueprint
    /// @param blueprintId The blueprint ID
    /// @param jobIndexes Array of job indexes
    /// @param rates Array of per-job event rates (0 to clear override and use blueprint default)
    function setJobEventRates(uint64 blueprintId, uint8[] calldata jobIndexes, uint256[] calldata rates) external {
        if (jobIndexes.length != rates.length) revert Errors.LengthMismatch();

        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        uint256 schemaCount = _blueprintJobSchemas[blueprintId].length;
        for (uint256 i = 0; i < jobIndexes.length; i++) {
            if (jobIndexes[i] >= schemaCount) {
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
}
