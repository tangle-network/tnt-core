// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Errors } from "../../src/v2/libraries/Errors.sol";
import { Types } from "../../src/v2/libraries/Types.sol";

contract SchemaValidationTest is BaseTest {
    function test_OperatorRegistrationSchemaMismatch() public {
        uint64 blueprintId = _blueprintWithSchemas(_boolSchema(), _emptySchema(), _emptySchema());

        // Register on restaking (required prerequisite)
        vm.prank(operator1);
        restaking.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Missing payload should revert
        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Registration),
                blueprintId,
                uint64(0),
                uint256(0)
            )
        );
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator1, 0), "http://localhost:8545", bytes(""));

        // Correct payload succeeds
        bytes memory registrationPayload = _encodeBool(true);
        vm.prank(operator1);
        tangle.registerOperator(
            blueprintId, _operatorGossipKey(operator1, 0), "http://localhost:8545", registrationPayload
        );
    }

    function test_ServiceRequestSchemaMismatch() public {
        uint64 blueprintId = _blueprintWithSchemas(_emptySchema(), _boolUintSchema(), _emptySchema());
        _registerOperatorWithPayload(operator1, blueprintId, bytes(""));

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory permitted = new address[](0);

        // Payload missing the uint16 should revert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.Request),
                blueprintId,
                uint64(0),
                uint256(1)
            )
        );
        tangle.requestService(blueprintId, operators, _encodeBool(true), permitted, 0, address(0), 0);

        // Valid payload succeeds
        bytes memory validConfig = bytes.concat(_encodeBool(false), _encodeUint32(42));
        vm.prank(user1);
        tangle.requestService(blueprintId, operators, validConfig, permitted, 0, address(0), 0);
    }

    function test_JobParamsAndResultSchemaMismatch() public {
        bytes memory boolSchema = _boolSchema();
        uint64 blueprintId = _blueprintWithSchemas(_emptySchema(), _emptySchema(), boolSchema);
        _registerOperatorWithPayload(operator1, blueprintId, bytes(""));

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Invalid job inputs (missing bool) revert
        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.JobParams),
                blueprintId,
                uint64(0),
                uint256(0)
            )
        );
        tangle.submitJob(serviceId, 0, bytes(""));

        // Valid inputs succeed
        vm.prank(user1);
        uint64 callId = tangle.submitJob(serviceId, 0, _encodeBool(true));

        // Invalid result payload reverts
        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.SchemaValidationFailed.selector,
                uint8(Types.SchemaTarget.JobResult),
                blueprintId,
                uint64(0),
                uint256(0)
            )
        );
        tangle.submitResult(serviceId, callId, bytes(""));

        // Valid result payload succeeds
        vm.prank(operator1);
        tangle.submitResult(serviceId, callId, _encodeBool(false));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _blueprintWithSchemas(bytes memory registration, bytes memory request, bytes memory job)
        private
        returns (uint64)
    {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://schema-blueprint", address(0));
        def.registrationSchema = registration;
        def.requestSchema = request;
        for (uint256 i = 0; i < def.jobs.length; ++i) {
            def.jobs[i].paramsSchema = job;
            def.jobs[i].resultSchema = job;
        }

        vm.prank(developer);
        return tangle.createBlueprint(def);
    }

    function _registerOperatorWithPayload(address operator, uint64 blueprintId, bytes memory payload) private {
        vm.prank(operator);
        restaking.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator1, 0), "http://localhost:8545", payload);
    }

    function _encodeBool(bool value) private pure returns (bytes memory) {
        return abi.encodePacked(bytes1(value ? 0x01 : 0x00));
    }

    function _encodeUint16(uint16 value) private pure returns (bytes memory out) {
        out = new bytes(2);
        out[0] = bytes1(uint8(value >> 8));
        out[1] = bytes1(uint8(value));
    }

    function _encodeUint32(uint32 value) private pure returns (bytes memory out) {
        out = new bytes(4);
        out[0] = bytes1(uint8(value >> 24));
        out[1] = bytes1(uint8(value >> 16));
        out[2] = bytes1(uint8(value >> 8));
        out[3] = bytes1(uint8(value));
    }
}
