// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../../../src/v2/libraries/Types.sol";
import { SchemaLib } from "../../../src/v2/libraries/SchemaLib.sol";

/// @title BlueprintDefinitionHelper
/// @notice Shared helper for constructing blueprint definitions in tests
abstract contract BlueprintDefinitionHelper {
    uint256 internal constant DEFAULT_JOB_COUNT = 8;

    /// @notice Build a blueprint definition with sane defaults
    function _blueprintDefinition(
        string memory metadataUri,
        address manager
    ) internal pure returns (Types.BlueprintDefinition memory def) {
        bytes memory emptySchema = _emptySchema();
        def.metadataUri = metadataUri;
        def.manager = manager;
        def.masterManagerRevision = 0;
        def.metadata = Types.BlueprintMetadata({
            name: "Test Blueprint",
            description: "Test blueprint definition",
            author: "Tangle",
            category: "Test",
            codeRepository: "https://github.com/webb-tools/tnt-core",
            logo: "",
            website: "https://tangle.network",
            license: "MIT",
            profilingData: ""
        });
        def.jobs = _buildJobDefinitions(DEFAULT_JOB_COUNT, emptySchema);
        def.registrationSchema = emptySchema;
        def.requestSchema = emptySchema;
        def.sources = new Types.BlueprintSource[](1);
        def.sources[0] = _defaultBlueprintSource();
        def.supportedMemberships = new Types.MembershipModel[](2);
        def.supportedMemberships[0] = Types.MembershipModel.Fixed;
        def.supportedMemberships[1] = Types.MembershipModel.Dynamic;
    }

    /// @notice Build a blueprint definition with explicit configuration
    function _blueprintDefinitionWithConfig(
        string memory metadataUri,
        address manager,
        Types.BlueprintConfig memory config
    ) internal pure returns (Types.BlueprintDefinition memory def) {
        def = _blueprintDefinition(metadataUri, manager);
        def.hasConfig = true;
        def.config = config;
    }

    function _blueprintDefinitionWithJobCount(
        string memory metadataUri,
        address manager,
        uint256 jobCount
    ) internal pure returns (Types.BlueprintDefinition memory def) {
        def = _blueprintDefinition(metadataUri, manager);
        if (jobCount == def.jobs.length) {
            return def;
        }
        bytes memory emptySchema = _emptySchema();
        def.jobs = _buildJobDefinitions(jobCount, emptySchema);
    }

    function _encodeBlueprintDefinition(Types.BlueprintDefinition memory def) internal pure returns (bytes memory) {
        return abi.encode(def);
    }

    function _boolSchema() internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].arrayLength = 0;
        fields[0].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _boolUintSchema() internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](2);
        for (uint256 i = 0; i < fields.length; ++i) {
            fields[i].arrayLength = 0;
            fields[i].children = new Types.BlueprintFieldType[](0);
        }
        fields[0].kind = Types.BlueprintFieldKind.Bool;
        fields[1].kind = Types.BlueprintFieldKind.Uint32;
        return SchemaLib.encodeSchema(fields);
    }

    function _requestStructBoolUint16Schema() internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.Struct;
        fields[0].children = new Types.BlueprintFieldType[](2);
        fields[0].children[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].children[0].children = new Types.BlueprintFieldType[](0);
        fields[0].children[1].kind = Types.BlueprintFieldKind.Uint16;
        fields[0].children[1].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _requestListOfBoolSchema() internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.List;
        fields[0].children = new Types.BlueprintFieldType[](1);
        fields[0].children[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].children[0].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _fixedJobBoolArraySchema(uint16 length) internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.Array;
        fields[0].arrayLength = length;
        fields[0].children = new Types.BlueprintFieldType[](1);
        fields[0].children[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].children[0].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _optionalBoolFieldSchema() internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.Optional;
        fields[0].children = new Types.BlueprintFieldType[](1);
        fields[0].children[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].children[0].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _emptySchema() internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _defaultBlueprintSource() internal pure returns (Types.BlueprintSource memory source) {
        source.kind = Types.BlueprintSourceKind.Container;
        source.container = Types.ImageRegistrySource({
            registry: "registry.tangle.local",
            image: "blueprint",
            tag: "latest"
        });
        source.wasm.runtime = Types.WasmRuntime.Wasmtime;
        source.wasm.fetcher = Types.BlueprintFetcherKind.None;
        source.native.fetcher = Types.BlueprintFetcherKind.None;
        source.testing = Types.TestingSource({
            cargoPackage: "",
            cargoBin: "",
            basePath: ""
        });
    }

    function _buildJobDefinitions(uint256 count, bytes memory schema)
        private
        pure
        returns (Types.JobDefinition[] memory jobs)
    {
        if (count == 0) {
            count = 1;
        }
        jobs = new Types.JobDefinition[](count);
        for (uint256 i = 0; i < count; ++i) {
            jobs[i] = Types.JobDefinition({
                name: "Test Job",
                description: "Default job for tests",
                metadataUri: "",
                paramsSchema: schema,
                resultSchema: schema
            });
        }
    }
}
