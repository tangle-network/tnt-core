// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

import { IMasterBlueprintServiceManager } from "./interfaces/IMasterBlueprintServiceManager.sol";
import { Types } from "./libraries/Types.sol";

/// @title MasterBlueprintServiceManager
/// @notice Protocol-wide sink for blueprint definitions and binary-lifecycle events
///         emitted by Tangle.
/// @dev Records every blueprint definition and the authoritative cross-blueprint
///      events for binary version publishes and operator acknowledgements. The
///      per-blueprint BSM hook is dispatched separately by Tangle so it runs
///      under Tangle's identity and respects the BSM's `onlyFromTangle` check;
///      the master manager itself only emits indexer events.
contract MasterBlueprintServiceManager is IMasterBlueprintServiceManager, AccessControl {
    bytes32 public constant TANGLE_ROLE = keccak256("TANGLE_ROLE");

    struct BlueprintRecord {
        address owner;
        uint64 recordedAt;
        // Digest of the ABI-encoded definition. The full bytes are emitted in
        // BlueprintDefinitionRecorded (the authoritative indexer event) rather
        // than SSTORE'd; this contract only ever emits — never reads the blob.
        bytes32 definitionHash;
    }

    /// @notice blueprintId => record
    mapping(uint64 => BlueprintRecord) private _records;


    /// @notice Authoritative indexer event for a new binary version.
    event BinaryVersionRecorded(
        uint64 indexed blueprintId, uint64 indexed versionId, bytes32 sha256Hash, string binaryUri
    );

    /// @notice Authoritative indexer event for an operator binary acknowledgement.
    event OperatorBinaryAckRecorded(uint64 indexed serviceId, uint64 indexed versionId, address indexed operator);

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
    )
        external
        override
        onlyRole(TANGLE_ROLE)
    {
        _records[blueprintId] = BlueprintRecord({
            owner: owner, recordedAt: uint64(block.timestamp), definitionHash: keccak256(encodedDefinition)
        });
        emit BlueprintDefinitionRecorded(blueprintId, owner, encodedDefinition);
    }

    /// @inheritdoc IMasterBlueprintServiceManager
    function onBinaryVersionPublished(
        uint64 blueprintId,
        Types.BinaryVersion calldata version
    )
        external
        override
        onlyRole(TANGLE_ROLE)
    {
        emit BinaryVersionRecorded(blueprintId, version.versionId, version.sha256Hash, version.binaryUri);
    }

    /// @inheritdoc IMasterBlueprintServiceManager
    function onOperatorBinaryAcked(
        uint64 serviceId,
        uint64 versionId,
        address operator
    )
        external
        override
        onlyRole(TANGLE_ROLE)
    {
        emit OperatorBinaryAckRecorded(serviceId, versionId, operator);
    }

    /// @notice Fetch stored blueprint metadata
    function getBlueprintRecord(uint64 blueprintId) external view returns (BlueprintRecord memory) {
        return _records[blueprintId];
    }
}
