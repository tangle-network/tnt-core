// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { Types } from "../src/libraries/Types.sol";
import { SchemaLib } from "../src/libraries/SchemaLib.sol";
import { ITangleFull } from "../src/interfaces/ITangle.sol";
import { BlueprintDefinitionHelper } from "../test/support/BlueprintDefinitionHelper.sol";

/// @title CreateTestBlueprintTLV2
/// @notice Deploy a blueprint with TLV v2 schemas that include field names
contract CreateTestBlueprintTLV2 is Script, BlueprintDefinitionHelper {
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    address constant TANGLE = 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9;

    function run() external {
        vm.startBroadcast(DEPLOYER_KEY);

        // Create blueprint with TLV v2 schemas
        Types.BlueprintDefinition memory def = _blueprintDefinition("http://localhost/test", address(0));
        def.config.membership = Types.MembershipModel.Dynamic;
        def.config.minOperators = 1;
        def.config.maxOperators = 0;
        def.metadata.name = "TLV v2 Test Blueprint";
        def.metadata.description = "Blueprint with named parameters for TLV v2 testing";

        // Add jobs with proper schemas that have field names
        Types.JobDefinition[] memory jobs = new Types.JobDefinition[](2);

        // Job 0: hello with "name" param (string)
        jobs[0].name = "hello";
        jobs[0].description = "Greets with a personalized message";
        jobs[0].paramsSchema = _stringSchema("name");
        jobs[0].resultSchema = _stringSchema("greeting");

        // Job 1: multiplyNumbers with "a" and "b" params
        jobs[1].name = "multiplyNumbers";
        jobs[1].description = "Multiplies two numbers";
        jobs[1].paramsSchema = _twoUint256Schema("a", "b");
        jobs[1].resultSchema = _uint256Schema("product");

        def.jobs = jobs;

        ITangleFull tangle = ITangleFull(payable(TANGLE));
        uint64 blueprintId = tangle.createBlueprint(def);
        console2.log("Blueprint created with ID:", blueprintId);

        vm.stopBroadcast();
    }

    function _stringSchema(string memory fieldName) internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.String;
        fields[0].arrayLength = 0;
        fields[0].children = new Types.BlueprintFieldType[](0);
        fields[0].name = fieldName;
        return SchemaLib.encodeSchema(fields);
    }

    function _uint256Schema(string memory fieldName) internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.Uint256;
        fields[0].arrayLength = 0;
        fields[0].children = new Types.BlueprintFieldType[](0);
        fields[0].name = fieldName;
        return SchemaLib.encodeSchema(fields);
    }

    function _twoUint256Schema(string memory name1, string memory name2) internal pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](2);
        fields[0].kind = Types.BlueprintFieldKind.Uint256;
        fields[0].arrayLength = 0;
        fields[0].children = new Types.BlueprintFieldType[](0);
        fields[0].name = name1;
        fields[1].kind = Types.BlueprintFieldKind.Uint256;
        fields[1].arrayLength = 0;
        fields[1].children = new Types.BlueprintFieldType[](0);
        fields[1].name = name2;
        return SchemaLib.encodeSchema(fields);
    }
}
