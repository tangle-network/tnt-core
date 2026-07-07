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
        emit BlueprintDefinitionRecorded(blueprintId, owner, encodedDefinition);
    }

    /// @inheritdoc IMasterBlueprintServiceManager
    function onBinaryVersionPublished(
        uint64 blueprintId,
        Types.BinaryVersion calldata version,
        string calldata binaryUri
    )
        external
        override
        onlyRole(TANGLE_ROLE)
    {
        emit BinaryVersionRecorded(blueprintId, version.versionId, version.sha256Hash, binaryUri);
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
}
