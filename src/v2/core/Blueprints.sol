// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Blueprints
/// @notice Blueprint creation and management
abstract contract Blueprints is Base {
    uint256 private constant DEFAULT_JOB_SLOT_COUNT = 8;
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
        metadataUri; // Silence unused variable warning (metadata emitted via events)

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

        _initializeBlueprintSchemas(blueprintId, DEFAULT_JOB_SLOT_COUNT);

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

    /// @notice Create blueprint from encoded definition containing schemas and job metadata
    function createBlueprint(bytes calldata encodedDefinition) external whenNotPaused returns (uint64 blueprintId) {
        Types.BlueprintDefinition memory def = abi.decode(encodedDefinition, (Types.BlueprintDefinition));
        if (def.jobs.length == 0) {
            revert Errors.InvalidState();
        }

        blueprintId = _blueprintCount++;

        Types.MembershipModel membership = def.hasConfig ? def.config.membership : Types.MembershipModel.Fixed;
        Types.PricingModel pricing = def.hasConfig ? def.config.pricing : Types.PricingModel.PayOnce;

        _blueprints[blueprintId] = Types.Blueprint({
            owner: msg.sender,
            manager: def.manager,
            createdAt: uint64(block.timestamp),
            operatorCount: 0,
            membership: membership,
            pricing: pricing,
            active: true
        });

        if (def.hasConfig) {
            _blueprintConfigs[blueprintId] = def.config;
        }

        _storeBlueprintSchemas(blueprintId, def);

        emit BlueprintCreated(blueprintId, msg.sender, def.manager);
        _recordBlueprintCreated(blueprintId, msg.sender);

        if (def.manager != address(0)) {
            _callManager(
                def.manager,
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
        metadataUri; // Metadata stored off-chain; emitted via events in extensions.
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
        _initializeBlueprintSchemas(blueprintId, DEFAULT_JOB_SLOT_COUNT);

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

    function _initializeBlueprintSchemas(uint64 blueprintId, uint256 jobCount) private {
        delete _registrationSchemas[blueprintId];
        delete _requestSchemas[blueprintId];
        delete _blueprintJobSchemas[blueprintId];

        Types.StoredJobSchema[] storage schemas = _blueprintJobSchemas[blueprintId];
        for (uint256 i = 0; i < jobCount; ++i) {
            schemas.push();
        }
    }

    function _storeBlueprintSchemas(uint64 blueprintId, Types.BlueprintDefinition memory def) private {
        _registrationSchemas[blueprintId] = def.registrationSchema;
        _requestSchemas[blueprintId] = def.requestSchema;

        delete _blueprintJobSchemas[blueprintId];
        Types.StoredJobSchema[] storage schemas = _blueprintJobSchemas[blueprintId];
        for (uint256 i = 0; i < def.jobs.length; ++i) {
            schemas.push(
                Types.StoredJobSchema({
                    params: def.jobs[i].paramsSchema,
                    result: def.jobs[i].resultSchema
                })
            );
        }
    }
}
