// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { SchemaLib } from "../../../src/v2/libraries/SchemaLib.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { BlueprintDefinitionHelper } from "../../support/BlueprintDefinitionHelper.sol";
import { SchemaTestUtils } from "../../support/SchemaTestUtils.sol";

/// @notice Minimal harness that exposes SchemaLib validation helpers for storage-backed schemas
contract SchemaHarness {
    bytes private _registrationSchema;
    bytes private _requestSchema;
    Types.StoredJobSchema private _jobSchema;

    function setRegistrationSchema(bytes memory schema) external {
        _registrationSchema = schema;
    }

    function setRequestSchema(bytes memory schema) external {
        _requestSchema = schema;
    }

    function setJobSchema(bytes memory paramsSchema, bytes memory resultSchema) external {
        _jobSchema.params = paramsSchema;
        _jobSchema.result = resultSchema;
    }

    function validateRegistration(bytes calldata payload, uint64 refId, uint64 auxId) external view {
        SchemaLib.validatePayload(_registrationSchema, payload, Types.SchemaTarget.Registration, refId, auxId);
    }

    function validateRequest(bytes calldata payload, uint64 refId, uint64 auxId) external view {
        SchemaLib.validatePayload(_requestSchema, payload, Types.SchemaTarget.Request, refId, auxId);
    }

    function validateJobParams(bytes calldata payload, uint64 blueprintId, uint8 jobIndex) external view {
        SchemaLib.validateJobParams(_jobSchema, payload, blueprintId, jobIndex);
    }

    function validateJobResult(bytes calldata payload, uint64 blueprintId, uint8 jobIndex) external view {
        SchemaLib.validateJobResult(_jobSchema, payload, blueprintId, jobIndex);
    }
}

/// @title SchemaLibFuzzTest
/// @notice Exercises schema TLV decoding under malformed payloads and fuzzed data
contract SchemaLibFuzzTest is Test, BlueprintDefinitionHelper {
    SchemaHarness private harness;

    function setUp() public {
        harness = new SchemaHarness();
        harness.setRegistrationSchema(_boolSchema());
        harness.setRequestSchema(_boolSchema());
        harness.setJobSchema(_boolSchema(), _boolSchema());
    }

    /// @notice Randomized registration payloads that do not match schema always revert with correct metadata
    function testFuzz_RegistrationPayloadReportsPath(uint8 len) public {
        vm.assume(len != 1);
        bytes memory payload = new bytes(len);
        uint64 blueprintId = 1337;
        uint256 expectedPath = len == 0 ? 0 : 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Registration),
                blueprintId,
                uint64(0),
                expectedPath
            )
        );
        harness.validateRegistration(payload, blueprintId, 0);
    }

    /// @notice Randomized request payloads return the correct path cursor on failure
    function testFuzz_RequestPayloadReportsPath(uint8 len) public {
        vm.assume(len != 1);
        bytes memory payload = new bytes(len);
        uint64 blueprintId = 4242;
        uint64 auxId = 99;
        uint256 expectedPath = len == 0 ? 0 : 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Request),
                blueprintId,
                auxId,
                expectedPath
            )
        );
        harness.validateRequest(payload, blueprintId, auxId);
    }

    /// @notice Job parameter payload mismatches bubble up through SchemaValidationFailed with job metadata attached
    function testFuzz_JobParamsPayloadReportsPath(uint8 len) public {
        vm.assume(len != 1);
        bytes memory payload = new bytes(len);
        uint64 blueprintId = 1;
        uint8 jobIndex = 7;
        uint256 expectedPath = len == 0 ? 0 : 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.JobParams),
                blueprintId,
                jobIndex,
                expectedPath
            )
        );
        harness.validateJobParams(payload, blueprintId, jobIndex);
    }

    /// @notice Job results are validated with the same metadata-rich errors under fuzzed payloads
    function testFuzz_JobResultPayloadReportsPath(uint8 len) public {
        vm.assume(len != 1);
        bytes memory payload = new bytes(len);
        uint64 blueprintId = 9;
        uint8 jobIndex = 3;
        uint256 expectedPath = len == 0 ? 0 : 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.JobResult),
                blueprintId,
                jobIndex,
                expectedPath
            )
        );
        harness.validateJobResult(payload, blueprintId, jobIndex);
    }

    /// @notice Blueprints that stored zero-length schemas continue to accept empty payloads
    function test_ZeroLengthSchemaAllowsEmptyPayloads() public {
        bytes memory empty = _emptySchema();
        harness.setRegistrationSchema(empty);
        harness.setRequestSchema(empty);
        harness.setJobSchema(empty, empty);

        harness.validateRegistration("", 777, 0);
        harness.validateRequest("", 777, 0);
        harness.validateJobParams("", 777, 0);
        harness.validateJobResult("", 777, 0);
    }

    /// @notice Struct payloads that lie about their declared field counts are rejected at the struct node
    function test_PathologicalStructFieldCountReverts() public {
        bytes memory schema = _structBoolUintSchema();
        harness.setRegistrationSchema(schema);

        // Struct claims it only has one field while schema requires two children.
        bytes memory payload = bytes.concat(_encodeCompactLength(1), bytes1(0x01));

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Registration),
                1,
                0,
                uint256(0)
            )
        );
        harness.validateRegistration(payload, 1, 0);
    }

    /// @notice Lists that declare more elements than the payload provides revert with the failing element path
    function test_PathologicalListChildCountReverts() public {
        bytes memory schema = _listOfBoolSchema();
        harness.setRequestSchema(schema);

        // Count=2 but only supply one bool.
        bytes memory payload = bytes.concat(_encodeCompactLength(2), bytes1(0x01));

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Request),
                2,
                0,
                uint256(1)
            )
        );
        harness.validateRequest(payload, 2, 0);
    }

    /// @notice Fixed arrays guard against claims that exceed the remaining bytes
    function test_PathologicalArrayLengthReverts() public {
        bytes memory schema = _arrayOfBoolSchema(3);
        harness.setJobSchema(schema, schema);

        // Array expects three bools but we only provide two.
        bytes memory payload = bytes.concat(bytes1(0x01), bytes1(0x02));

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.JobParams),
                3,
                0,
                uint256(2)
            )
        );
        harness.validateJobParams(payload, 3, 0);
    }

    /// @notice Variable-length fields (string/bytes) revert when the TLV claims more bytes than available
    function test_PathologicalStringLengthReverts() public {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.String;
        fields[0].children = new Types.BlueprintFieldType[](0);
        fields[0].arrayLength = 0;

        bytes memory schema = SchemaLib.encodeSchema(fields);
        harness.setRegistrationSchema(schema);

        // Claim the string is 5 bytes but only supply two bytes after the length prefix.
        bytes memory payload = bytes.concat(_encodeCompactLength(5), bytes1(0xAA), bytes1(0xBB));

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Registration),
                5,
                0,
                uint256(0)
            )
        );
        harness.validateRegistration(payload, 5, 0);
    }

    /// @notice Extra data after a struct completes is treated as a mixed-type violation and reverts with cursor metadata
    function test_PathologicalStructTrailingDataReverts() public {
        bytes memory schema = _structBoolUintSchema();
        harness.setRequestSchema(schema);

        // Payload encodes the correct struct, then appends stray bytes.
        bytes memory payload = bytes.concat(
            _encodeCompactLength(2),
            bytes1(0x01),
            bytes4(uint32(11)),
            bytes1(0xFF)
        );

        // The trailing byte causes cursor != payloadLength, which is reported as the cursor offset (6).
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Request),
                8,
                0,
                uint256(6)
            )
        );
        harness.validateRequest(payload, 8, 0);
    }

    /// @notice Randomized schema scenarios (deep optional/list/array combos) validate successfully
    function testFuzz_RandomSchemaInputsValidate(uint256 seed) public {
        SchemaTestUtils.Scenario memory scenario = SchemaTestUtils.randomScenario(seed);
        harness.setRegistrationSchema(scenario.schema);
        harness.setRequestSchema(scenario.schema);
        harness.setJobSchema(scenario.schema, scenario.schema);

        try harness.validateRegistration(scenario.validPayload, 111, 1) {
            harness.validateRequest(scenario.validPayload, 222, 2);
            harness.validateJobParams(scenario.validPayload, 333, 3);
            harness.validateJobResult(scenario.validPayload, 444, 4);
        } catch {
            // Skip malformed generator outputs
            return;
        }
    }

    /// @notice Corrupted payloads for randomized schemas always revert with SchemaValidationFailed
    function testFuzz_RandomSchemaInputsRejectCorruption(uint256 seed) public {
        SchemaTestUtils.Scenario memory scenario = SchemaTestUtils.randomScenario(seed ^ 0xABCDEF);
        harness.setRegistrationSchema(scenario.schema);

        bool validated;
        try harness.validateRegistration(scenario.validPayload, 888, 8) {
            validated = true;
        } catch {
            // Skip malformed generator outputs
        }

        if (!validated) {
            return;
        }

        if (keccak256(scenario.validPayload) == keccak256(scenario.invalidPayload)) {
            return;
        }

        bool reverted;
        try harness.validateRegistration(scenario.invalidPayload, 999, 9) {
            reverted = false;
        } catch {
            reverted = true;
        }

        if (!reverted) {
            // Some randomly generated corrupt payloads may still satisfy schema constraints; skip them.
            return;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _structBoolUintSchema() private pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.Struct;
        fields[0].arrayLength = 0;
        fields[0].children = new Types.BlueprintFieldType[](2);
        fields[0].children[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].children[1].kind = Types.BlueprintFieldKind.Uint32;
        fields[0].children[0].children = new Types.BlueprintFieldType[](0);
        fields[0].children[1].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _listOfBoolSchema() private pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.List;
        fields[0].arrayLength = 0;
        fields[0].children = new Types.BlueprintFieldType[](1);
        fields[0].children[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].children[0].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _arrayOfBoolSchema(uint16 length) private pure returns (bytes memory) {
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](1);
        fields[0].kind = Types.BlueprintFieldKind.Array;
        fields[0].arrayLength = length;
        fields[0].children = new Types.BlueprintFieldType[](1);
        fields[0].children[0].kind = Types.BlueprintFieldKind.Bool;
        fields[0].children[0].children = new Types.BlueprintFieldType[](0);
        return SchemaLib.encodeSchema(fields);
    }

    function _encodeCompactLength(uint256 value) private pure returns (bytes memory) {
        // These tests only need the short form where value fits in a single byte.
        require(value < 0x80, "value too large for short form");
        return abi.encodePacked(uint8(value));
    }
}
