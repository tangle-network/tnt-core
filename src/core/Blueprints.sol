// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IMasterBlueprintServiceManager } from "../interfaces/IMasterBlueprintServiceManager.sol";

/// @title Blueprints
/// @notice Blueprint creation and management
abstract contract Blueprints is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintCreated(uint64 indexed blueprintId, address indexed owner, address manager, string metadataUri);
    event BlueprintUpdated(uint64 indexed blueprintId, string metadataUri);
    event BlueprintTransferred(uint64 indexed blueprintId, address indexed from, address indexed to);
    event BlueprintDeactivated(uint64 indexed blueprintId);
    /// @notice Emitted when blueprint metadata is locked (M-2 fix)
    event BlueprintMetadataLocked(uint64 indexed blueprintId);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create blueprint from encoded definition containing schemas and job metadata
    /// @param def The blueprint definition containing metadata, schemas, sources, and configuration
    /// @return blueprintId The newly created blueprint's ID
    function createBlueprint(Types.BlueprintDefinition calldata def)
        external
        whenNotPaused
        returns (uint64 blueprintId)
    {
        if (address(_mbsmRegistry) == address(0)) revert Errors.MBSMRegistryNotSet();
        _validateBlueprintDefinition(def);

        (address masterManager, uint32 resolvedRevision) = _resolveMasterManager(def.masterManagerRevision);
        blueprintId = _blueprintCount++;

        Types.BlueprintConfig memory config = _normalizeBlueprintConfig(def);

        _blueprints[blueprintId] = Types.Blueprint({
            owner: msg.sender,
            manager: def.manager,
            createdAt: uint64(block.timestamp),
            operatorCount: 0,
            membership: config.membership,
            pricing: config.pricing,
            active: true
        });

        _blueprintConfigs[blueprintId] = config;
        _storeBlueprintSchemas(blueprintId, def);
        _storeBlueprintMetadata(blueprintId, def.metadataUri, def.metadata);
        _storeBlueprintSources(blueprintId, def.sources);
        _storeSupportedMemberships(blueprintId, def.supportedMemberships);
        _blueprintMasterRevisions[blueprintId] = resolvedRevision;
        bytes memory encodedDefinition = abi.encode(def);
        _blueprintDefinitionBlobs[blueprintId] = encodedDefinition;

        emit BlueprintCreated(blueprintId, msg.sender, def.manager, def.metadataUri);
        _recordBlueprintCreated(blueprintId, msg.sender);

        if (def.manager != address(0)) {
            _callManager(
                def.manager,
                abi.encodeCall(IBlueprintServiceManager.onBlueprintCreated, (blueprintId, msg.sender, address(this)))
            );
        }
        _notifyMasterBlueprintManager(masterManager, blueprintId, msg.sender, encodedDefinition);
        _mbsmRegistry.pinBlueprint(blueprintId, resolvedRevision);
    }

    /// @notice Retrieve the original blueprint definition
    /// @param blueprintId The blueprint ID to query
    /// @return definition The complete blueprint definition
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
    /// @dev Reverts if metadata is locked (operators have registered) (M-2 fix)
    /// @param blueprintId The blueprint ID to update
    /// @param metadataUri The new metadata URI (IPFS/HTTPS pointer)
    function updateBlueprint(uint64 blueprintId, string calldata metadataUri) external {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }
        // M-2 fix: Check if metadata is locked
        if (_blueprintMetadataLocked[blueprintId]) {
            revert Errors.BlueprintMetadataLocked(blueprintId);
        }
        _blueprintMetadataUri[blueprintId] = metadataUri;
        emit BlueprintUpdated(blueprintId, metadataUri);
    }

    /// @notice Check if blueprint metadata is locked
    /// @param blueprintId The blueprint ID to check
    /// @return True if metadata cannot be updated, false otherwise
    function isBlueprintMetadataLocked(uint64 blueprintId) external view returns (bool) {
        return _blueprintMetadataLocked[blueprintId];
    }

    /// @notice Transfer blueprint ownership
    /// @param blueprintId The blueprint ID to transfer
    /// @param newOwner The address of the new owner (cannot be zero)
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

    /// @notice Deactivate a blueprint, preventing new services from being created
    /// @param blueprintId The blueprint ID to deactivate
    function deactivateBlueprint(uint64 blueprintId) external {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) {
            revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        }

        bp.active = false;
        emit BlueprintDeactivated(blueprintId);
    }

    function _storeBlueprintSchemas(uint64 blueprintId, Types.BlueprintDefinition calldata def) private {
        _registrationSchemas[blueprintId] = def.registrationSchema;
        _requestSchemas[blueprintId] = def.requestSchema;

        delete _blueprintJobSchemas[blueprintId];
        Types.StoredJobSchema[] storage schemas = _blueprintJobSchemas[blueprintId];
        for (uint256 i = 0; i < def.jobs.length; ++i) {
            schemas.push(Types.StoredJobSchema({ params: def.jobs[i].paramsSchema, result: def.jobs[i].resultSchema }));
        }
    }

    function _storeBlueprintMetadata(
        uint64 blueprintId,
        string calldata metadataUri,
        Types.BlueprintMetadata calldata metadata
    )
        private
    {
        _blueprintMetadataUri[blueprintId] = metadataUri;
        _blueprintMetadata[blueprintId] = metadata;
    }

    function _storeBlueprintSources(uint64 blueprintId, Types.BlueprintSource[] calldata sources) private {
        delete _blueprintSources[blueprintId];
        Types.BlueprintSource[] storage stored = _blueprintSources[blueprintId];
        for (uint256 i = 0; i < sources.length; ++i) {
            Types.BlueprintSource storage dst = stored.push();
            Types.BlueprintSource calldata src = sources[i];
            dst.kind = src.kind;
            dst.container = src.container;
            dst.wasm = src.wasm;
            dst.native = src.native;
            dst.testing = src.testing;

            for (uint256 j = 0; j < src.binaries.length; ++j) {
                dst.binaries.push(src.binaries[j]);
            }
        }
    }

    function _storeSupportedMemberships(uint64 blueprintId, Types.MembershipModel[] calldata memberships) private {
        delete _blueprintSupportedMemberships[blueprintId];
        Types.MembershipModel[] storage stored = _blueprintSupportedMemberships[blueprintId];
        for (uint256 i = 0; i < memberships.length; ++i) {
            stored.push(memberships[i]);
        }
    }

    function _validateBlueprintDefinition(Types.BlueprintDefinition calldata def) private pure {
        if (bytes(def.metadataUri).length == 0) revert Errors.BlueprintMetadataRequired();
        if (def.jobs.length == 0) revert Errors.InvalidState();
        if (def.sources.length == 0) revert Errors.BlueprintSourcesRequired();
        if (def.supportedMemberships.length == 0) revert Errors.BlueprintMembershipRequired();
        for (uint256 i = 0; i < def.sources.length; ++i) {
            Types.BlueprintSource calldata source = def.sources[i];
            if (source.binaries.length == 0) revert Errors.BlueprintBinaryRequired();
            for (uint256 j = 0; j < source.binaries.length; ++j) {
                if (source.binaries[j].sha256 == bytes32(0)) {
                    revert Errors.BlueprintBinaryHashRequired();
                }
            }
        }
    }

    function _normalizeBlueprintConfig(Types.BlueprintDefinition calldata def)
        private
        pure
        returns (Types.BlueprintConfig memory config)
    {
        config = def.config;
        if (!def.hasConfig) {
            config.membership = Types.MembershipModel.Fixed;
            config.pricing = Types.PricingModel.PayOnce;
        }
    }

    function _resolveMasterManager(uint32 requestedRevision)
        private
        view
        returns (address masterManager, uint32 resolvedRevision)
    {
        if (requestedRevision == 0) {
            masterManager = _mbsmRegistry.getLatestMBSM();
            resolvedRevision = _mbsmRegistry.getLatestRevision();
        } else {
            masterManager = _mbsmRegistry.getMBSMByRevision(requestedRevision);
            resolvedRevision = requestedRevision;
        }
        if (masterManager == address(0) || resolvedRevision == 0) {
            revert Errors.MasterManagerUnavailable();
        }
    }

    function _notifyMasterBlueprintManager(
        address masterManager,
        uint64 blueprintId,
        address owner,
        bytes memory encodedDefinition
    )
        private
    {
        IMasterBlueprintServiceManager(masterManager).onBlueprintCreated(blueprintId, owner, encodedDefinition);
    }
}
