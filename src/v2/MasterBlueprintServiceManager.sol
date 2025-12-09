// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

import { IMasterBlueprintServiceManager } from "./interfaces/IMasterBlueprintServiceManager.sol";

/// @title MasterBlueprintServiceManager
/// @notice Protocol-wide sink for blueprint definitions emitted by Tangle
/// @dev Records every blueprint definition and allows governance to curate/inspect them.
contract MasterBlueprintServiceManager is IMasterBlueprintServiceManager, AccessControl {
    bytes32 public constant TANGLE_ROLE = keccak256("TANGLE_ROLE");

    struct BlueprintRecord {
        address owner;
        uint64 recordedAt;
        bytes encodedDefinition;
    }

    /// @notice blueprintId => record
    mapping(uint64 => BlueprintRecord) private _records;

    event BlueprintDefinitionRecorded(uint64 indexed blueprintId, address indexed owner, bytes encodedDefinition);

    constructor(address admin, address initialTangle) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        if (initialTangle != address(0)) {
            _grantRole(TANGLE_ROLE, initialTangle);
        }
    }

    /// @notice Allow or disallow a Tangle instance to push blueprint definitions
    function setTangle(address tangle, bool allowed) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (allowed) {
            _grantRole(TANGLE_ROLE, tangle);
        } else {
            _revokeRole(TANGLE_ROLE, tangle);
        }
    }

    /// @inheritdoc IMasterBlueprintServiceManager
    function onBlueprintCreated(
        uint64 blueprintId,
        address owner,
        bytes calldata encodedDefinition
    ) external override onlyRole(TANGLE_ROLE) {
        _records[blueprintId] = BlueprintRecord({
            owner: owner,
            recordedAt: uint64(block.timestamp),
            encodedDefinition: encodedDefinition
        });
        emit BlueprintDefinitionRecorded(blueprintId, owner, encodedDefinition);
    }

    /// @notice Fetch stored blueprint metadata
    function getBlueprintRecord(uint64 blueprintId) external view returns (BlueprintRecord memory) {
        return _records[blueprintId];
    }
}
