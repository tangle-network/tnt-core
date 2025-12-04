// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Blueprints
/// @notice Blueprint creation and management
abstract contract Blueprints is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintCreated(uint64 indexed blueprintId, address indexed owner, address manager);
    event BlueprintUpdated(uint64 indexed blueprintId, string metadataUri);
    event BlueprintTransferred(uint64 indexed blueprintId, address indexed from, address indexed to);
    event BlueprintDeactivated(uint64 indexed blueprintId);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new blueprint
    /// @param metadataUri IPFS URI for blueprint metadata
    /// @param manager Optional service manager contract
    /// @return blueprintId The new blueprint ID
    function createBlueprint(
        string calldata metadataUri,
        address manager
    ) external whenNotPaused returns (uint64 blueprintId) {
        blueprintId = _blueprintCount++;

        _blueprints[blueprintId] = Types.Blueprint({
            owner: msg.sender,
            manager: manager,
            createdAt: uint64(block.timestamp),
            operatorCount: 0,
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            active: true
        });

        emit BlueprintCreated(blueprintId, msg.sender, manager);
        _recordBlueprintCreated(blueprintId, msg.sender);

        if (manager != address(0)) {
            _callManager(
                manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onBlueprintCreated,
                    (blueprintId, msg.sender, address(this))
                )
            );
        }
    }

    /// @notice Create blueprint with full configuration
    function createBlueprintWithConfig(
        string calldata metadataUri,
        address manager,
        Types.BlueprintConfig calldata config
    ) external whenNotPaused returns (uint64 blueprintId) {
        blueprintId = _blueprintCount++;

        _blueprints[blueprintId] = Types.Blueprint({
            owner: msg.sender,
            manager: manager,
            createdAt: uint64(block.timestamp),
            operatorCount: 0,
            membership: config.membership,
            pricing: config.pricing,
            active: true
        });

        _blueprintConfigs[blueprintId] = config;

        emit BlueprintCreated(blueprintId, msg.sender, manager);
        _recordBlueprintCreated(blueprintId, msg.sender);

        if (manager != address(0)) {
            _callManager(
                manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onBlueprintCreated,
                    (blueprintId, msg.sender, address(this))
                )
            );
        }
    }

    /// @notice Update blueprint metadata
    function updateBlueprint(uint64 blueprintId, string calldata metadataUri) external {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }
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
