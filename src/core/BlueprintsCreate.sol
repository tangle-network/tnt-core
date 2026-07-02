// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IMasterBlueprintServiceManager } from "../interfaces/IMasterBlueprintServiceManager.sol";

/// @title BlueprintsCreate
/// @notice Blueprint creation flow
abstract contract BlueprintsCreate is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintCreated(
        uint64 indexed blueprintId, address indexed owner, address manager, string metadataUri, bytes32 metadataHash
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT CREATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create blueprint from encoded definition containing schemas and job metadata
    function createBlueprint(Types.BlueprintDefinition calldata def)
        external
        whenNotPaused
        nonReentrant
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
        _storeBlueprintMetadata(blueprintId, def.metadataUri, def.metadataHash, def.metadata);
        _storeBlueprintSources(blueprintId, def.sources);
        _storeSupportedMemberships(blueprintId, def.supportedMemberships);
        _blueprintMasterRevisions[blueprintId] = resolvedRevision;
        bytes memory encodedDefinition = abi.encode(def);
        // Store only the digest; the full definition is emitted (via the master
        // manager's BlueprintDefinitionRecorded event) rather than SSTORE'd — the
        // blob was redundant with the decomposed fields and the event, and cost
        // ~one storage slot per 32 bytes of a multi-KB definition.
        _blueprintDefinitionHash[blueprintId] = keccak256(encodedDefinition);

        emit BlueprintCreated(blueprintId, msg.sender, def.manager, def.metadataUri, def.metadataHash);
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

    function _storeBlueprintSchemas(uint64 blueprintId, Types.BlueprintDefinition calldata def) private {
        _registrationSchemas[blueprintId] = def.registrationSchema;
        _requestSchemas[blueprintId] = def.requestSchema;

        delete _blueprintJobs[blueprintId];
        Types.JobDefinition[] storage jobs = _blueprintJobs[blueprintId];
        for (uint256 i = 0; i < def.jobs.length; ++i) {
            // Job COUNT and index ORDER are load-bearing (job index keys submissions),
            // so every job is pushed. Only the schemas are stored on-chain; the
            // display strings (name/description/metadataUri) live in the
            // BlueprintDefinitionRecorded event, not on-chain.
            jobs.push(
                Types.JobDefinition({
                    name: "",
                    description: "",
                    metadataUri: "",
                    paramsSchema: def.jobs[i].paramsSchema,
                    resultSchema: def.jobs[i].resultSchema
                })
            );
        }
    }

    function _storeBlueprintMetadata(
        uint64 blueprintId,
        string calldata metadataUri,
        bytes32 metadataHash,
        Types.BlueprintMetadata calldata metadata
    )
        private
    {
        _blueprintMetadataUri[blueprintId] = metadataUri;
        _blueprintMetadataHash[blueprintId] = metadataHash;
        // Only name + profilingData are read on-chain by the operator manager
        // (data-dir label + GPU/confidentiality profile), so those stay. The other
        // display fields live in the BlueprintDefinitionRecorded event, not on-chain.
        _blueprintMetadata[blueprintId] = Types.BlueprintMetadata({
            name: metadata.name,
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: "",
            profilingData: metadata.profilingData
        });
    }

    function _storeBlueprintSources(uint64 blueprintId, Types.BlueprintSource[] calldata sources) private {
        _writeBlueprintSources(blueprintId, sources);
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
        if (def.metadataHash == bytes32(0)) revert Errors.BlueprintMetadataHashRequired();
        if (def.jobs.length == 0) revert Errors.InvalidState();
        if (def.supportedMemberships.length == 0) revert Errors.BlueprintMembershipRequired();
        if (
            def.hasConfig && def.config.pricing == Types.PricingModel.Subscription
                && (def.config.subscriptionRate == 0 || def.config.subscriptionInterval == 0)
        ) {
            revert Errors.InvalidState();
        }
        _validateBlueprintSources(def.sources);
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
