// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "./Types.sol";
import { Errors } from "./Errors.sol";

/// @title SchemaLib
/// @notice Helpers for encoding and validating blueprint schemas using TLV payloads
library SchemaLib {
    uint256 private constant NODE_HEADER_SIZE = 5;

    // M-14 FIX: Add depth and size limits to prevent DoS via deeply nested or overly large schemas
    uint256 private constant MAX_SCHEMA_DEPTH = 32;
    uint256 private constant MAX_ARRAY_LENGTH = 65535;
    uint256 private constant MAX_LIST_LENGTH = 10000;
    uint256 private constant MAX_STRUCT_FIELDS = 256;

    struct ValidationContext {
        Types.SchemaTarget target;
        uint64 refId;
        uint64 auxId;
        uint256 depth; // M-14 FIX: Track recursion depth
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SCHEMA ENCODING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Encode a schema tree into canonical bytes
    function encodeSchema(Types.BlueprintFieldType[] memory source) internal pure returns (bytes memory) {
        if (source.length == 0) {
            return bytes("");
        }
        if (source.length > type(uint16).max) {
            revert Errors.SchemaTooLarge();
        }

        uint256 totalNodes = _countNodes(source);
        bytes memory out = new bytes(2 + totalNodes * NODE_HEADER_SIZE);
        _writeUint16(out, 0, uint16(source.length));

        uint256 cursor = 2;
        for (uint256 i = 0; i < source.length; ++i) {
            cursor = _writeField(out, cursor, source[i]);
        }
        return out;
    }

    function _countNodes(Types.BlueprintFieldType[] memory source) private pure returns (uint256 count) {
        for (uint256 i = 0; i < source.length; ++i) {
            count += 1 + _countNodes(source[i].children);
        }
    }

    function _writeField(
        bytes memory out,
        uint256 cursor,
        Types.BlueprintFieldType memory field
    ) private pure returns (uint256) {
        if (field.children.length > type(uint16).max) {
            revert Errors.SchemaTooLarge();
        }

        _writeHeader(out, cursor, field);
        cursor += NODE_HEADER_SIZE;
        for (uint256 i = 0; i < field.children.length; ++i) {
            cursor = _writeField(out, cursor, field.children[i]);
        }
        return cursor;
    }

    function _writeHeader(bytes memory out, uint256 offset, Types.BlueprintFieldType memory field) private pure {
        uint8 kind = uint8(field.kind);
        uint16 childCount = uint16(field.children.length);

        assembly ("memory-safe") {
            let ptr := add(add(out, 0x20), offset)
            mstore8(ptr, kind)
        }

        _writeUint16(out, offset + 1, field.arrayLength);
        _writeUint16(out, offset + 3, childCount);
    }

    function _writeUint16(bytes memory out, uint256 offset, uint16 value) private pure {
        assembly ("memory-safe") {
            let ptr := add(add(out, 0x20), offset)
            mstore8(ptr, shr(8, value))
            mstore8(add(ptr, 1), and(value, 0xff))
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Validate payload against schema (registration/request params)
    function validatePayload(
        bytes storage schemaStorage,
        bytes memory payload,
        Types.SchemaTarget target,
        uint64 refId,
        uint64 auxId
    ) internal view {
        _validate(schemaStorage, payload, target, refId, auxId);
    }

    /// @notice Validate job inputs against stored schema
    function validateJobParams(
        Types.StoredJobSchema storage schema,
        bytes memory payload,
        uint64 blueprintId,
        uint8 jobIndex
    ) internal view {
        _validate(schema.params, payload, Types.SchemaTarget.JobParams, blueprintId, jobIndex);
    }

    /// @notice Validate job results against stored schema
    function validateJobResult(
        Types.StoredJobSchema storage schema,
        bytes memory payload,
        uint64 blueprintId,
        uint8 jobIndex
    ) internal view {
        _validate(schema.result, payload, Types.SchemaTarget.JobResult, blueprintId, jobIndex);
    }

    function _validate(
        bytes storage schemaStorage,
        bytes memory payload,
        Types.SchemaTarget target,
        uint64 refId,
        uint64 auxId
    ) private view {
        if (schemaStorage.length == 0) {
            return;
        }
        bytes memory schema = schemaStorage;
        _validateEncoded(schema, payload, target, refId, auxId);
    }

    function _validateEncoded(
        bytes memory schema,
        bytes memory payload,
        Types.SchemaTarget target,
        uint64 refId,
        uint64 auxId
    ) private pure {
        if (schema.length < 2) {
            revert Errors.SchemaValidationFailed(uint8(target), refId, auxId, 0);
        }

        // M-14 FIX: Initialize depth tracking in context
        ValidationContext memory ctx = ValidationContext({ target: target, refId: refId, auxId: auxId, depth: 0 });

        uint16 fieldCount = _readUint16(schema, 0);
        uint256 schemaCursor = 2;
        uint256 cursor = 0;
        uint256 payloadLength = payload.length;

        for (uint16 i = 0; i < fieldCount; ++i) {
            uint256 path = _encodePath(0, i);
            uint256 nodeEnd = _skipNode(schema, schemaCursor, ctx, path);
            cursor = _validateField(
                schema,
                schemaCursor,
                payload,
                cursor,
                payloadLength,
                ctx,
                path
            );
            schemaCursor = nodeEnd;
        }

        if (cursor != payloadLength) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, cursor);
        }
    }

    function _validateField(
        bytes memory schema,
        uint256 start,
        bytes memory data,
        uint256 cursor,
        uint256 limit,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256) {
        // M-14 FIX: Check recursion depth to prevent stack overflow attacks
        if (ctx.depth >= MAX_SCHEMA_DEPTH) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        (
            Types.BlueprintFieldKind kind,
            uint16 arrayLength,
            uint16 childCount,
            uint256 childCursor
        ) = _readHeader(schema, start, ctx, path);

        if (kind == Types.BlueprintFieldKind.Void) {
            return cursor;
        }

        if (kind == Types.BlueprintFieldKind.Bool) {
            return _consume(data, cursor, 1, limit, ctx, path);
        }

        if (
            kind == Types.BlueprintFieldKind.Uint8 ||
            kind == Types.BlueprintFieldKind.Int8
        ) {
            return _consume(data, cursor, 1, limit, ctx, path);
        }

        if (
            kind == Types.BlueprintFieldKind.Uint16 ||
            kind == Types.BlueprintFieldKind.Int16
        ) {
            return _consume(data, cursor, 2, limit, ctx, path);
        }

        if (
            kind == Types.BlueprintFieldKind.Uint32 ||
            kind == Types.BlueprintFieldKind.Int32
        ) {
            return _consume(data, cursor, 4, limit, ctx, path);
        }

        if (
            kind == Types.BlueprintFieldKind.Uint64 ||
            kind == Types.BlueprintFieldKind.Int64
        ) {
            return _consume(data, cursor, 8, limit, ctx, path);
        }

        if (
            kind == Types.BlueprintFieldKind.Uint128 ||
            kind == Types.BlueprintFieldKind.Int128
        ) {
            return _consume(data, cursor, 16, limit, ctx, path);
        }

        if (
            kind == Types.BlueprintFieldKind.Uint256 ||
            kind == Types.BlueprintFieldKind.Int256
        ) {
            return _consume(data, cursor, 32, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.Address) {
            return _consume(data, cursor, 20, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.Bytes32) {
            return _consume(data, cursor, 32, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.FixedBytes) {
            if (arrayLength == 0 || arrayLength > 32) {
                revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
            }
            return _consume(data, cursor, arrayLength, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.String || kind == Types.BlueprintFieldKind.Bytes) {
            (uint256 len, uint256 next) = _readCompactLength(data, cursor, limit, ctx, path);
            return _consume(data, next, len, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.Optional) {
            return _validateOptional(schema, childCursor, childCount, data, cursor, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.Array) {
            return _validateArray(schema, childCursor, childCount, arrayLength, data, cursor, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.List) {
            return _validateList(schema, childCursor, childCount, data, cursor, limit, ctx, path);
        }

        if (kind == Types.BlueprintFieldKind.Struct) {
            return _validateStruct(schema, childCursor, childCount, data, cursor, limit, ctx, path);
        }

        revert Errors.UnsupportedFieldKind(uint8(kind));
    }

    function _validateOptional(
        bytes memory schema,
        uint256 childCursor,
        uint16 childCount,
        bytes memory data,
        uint256 cursor,
        uint256 limit,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256) {
        if (childCount != 1) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        (uint256 len, uint256 next) = _readCompactLength(data, cursor, limit, ctx, path);
        if (len == 0) return next;

        uint256 endCursor = next + len;
        if (endCursor > limit) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        // M-14 FIX: Increment depth for nested validation
        ctx.depth++;
        uint256 consumed = _validateField(
            schema,
            childCursor,
            data,
            next,
            endCursor,
            ctx,
            _encodePath(path, 0)
        );
        ctx.depth--;

        if (consumed != endCursor) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }
        return consumed;
    }

    function _validateArray(
        bytes memory schema,
        uint256 childCursor,
        uint16 childCount,
        uint16 arrayLength,
        bytes memory data,
        uint256 cursor,
        uint256 limit,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256 current) {
        if (childCount != 1) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        // M-14 FIX: Validate array length bounds
        if (arrayLength > MAX_ARRAY_LENGTH) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        // M-14 FIX: Increment depth for nested validation
        ctx.depth++;
        current = cursor;
        for (uint16 i = 0; i < arrayLength; ++i) {
            current = _validateField(schema, childCursor, data, current, limit, ctx, _encodePath(path, i));
        }
        ctx.depth--;
    }

    function _validateList(
        bytes memory schema,
        uint256 childCursor,
        uint16 childCount,
        bytes memory data,
        uint256 cursor,
        uint256 limit,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256 current) {
        if (childCount != 1) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        (uint256 count, uint256 next) = _readCompactLength(data, cursor, limit, ctx, path);

        // M-14 FIX: Validate list length to prevent DoS
        if (count > MAX_LIST_LENGTH) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        // M-14 FIX: Increment depth for nested validation
        ctx.depth++;
        current = next;
        for (uint256 i = 0; i < count; ++i) {
            current = _validateField(
                schema,
                childCursor,
                data,
                current,
                limit,
                ctx,
                // forge-lint: disable-next-line(unsafe-typecast)
                _encodePath(path, uint16(i))
            );
        }
        ctx.depth--;
    }

    function _validateStruct(
        bytes memory schema,
        uint256 childCursor,
        uint16 childCount,
        bytes memory data,
        uint256 cursor,
        uint256 limit,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256 current) {
        (uint256 fieldCount, uint256 next) = _readCompactLength(data, cursor, limit, ctx, path);
        if (fieldCount != childCount) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        // M-14 FIX: Validate struct field count to prevent DoS
        if (childCount > MAX_STRUCT_FIELDS) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        // M-14 FIX: Increment depth for nested validation
        ctx.depth++;
        current = next;
        uint256 childStart = childCursor;
        for (uint16 i = 0; i < childCount; ++i) {
            uint256 childEnd = _skipNode(schema, childStart, ctx, _encodePath(path, i));
            current = _validateField(schema, childStart, data, current, limit, ctx, _encodePath(path, i));
            childStart = childEnd;
        }
        ctx.depth--;

        if (childStart != _nodeEnd(schema, childCursor, childCount, ctx, path)) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }
    }

    function _skipNode(
        bytes memory schema,
        uint256 cursor,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256) {
        (, , uint16 childCount, uint256 next) = _readHeader(schema, cursor, ctx, path);
        return _nodeEnd(schema, next, childCount, ctx, path);
    }

    function _nodeEnd(
        bytes memory schema,
        uint256 cursor,
        uint16 childCount,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256 next) {
        next = cursor;
        for (uint16 i = 0; i < childCount; ++i) {
            next = _skipNode(schema, next, ctx, _encodePath(path, i));
        }
    }

    function _readHeader(
        bytes memory schema,
        uint256 cursor,
        ValidationContext memory ctx,
        uint256 path
    )
        private
        pure
        returns (
            Types.BlueprintFieldKind kind,
            uint16 arrayLength,
            uint16 childCount,
            uint256 next
        )
    {
        if (cursor + NODE_HEADER_SIZE > schema.length) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }
        kind = Types.BlueprintFieldKind(uint8(schema[cursor]));
        arrayLength = _readUint16(schema, cursor + 1);
        childCount = _readUint16(schema, cursor + 3);
        next = cursor + NODE_HEADER_SIZE;
    }

    function _readUint16(bytes memory data, uint256 offset) private pure returns (uint16) {
        return (uint16(uint8(data[offset])) << 8) | uint16(uint8(data[offset + 1]));
    }

    function _consume(
        bytes memory data,
        uint256 cursor,
        uint256 size,
        uint256 limit,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256) {
        uint256 end = cursor + size;
        if (end > limit || end > data.length) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }
        return end;
    }

    function _readCompactLength(
        bytes memory data,
        uint256 cursor,
        uint256 limit,
        ValidationContext memory ctx,
        uint256 path
    ) private pure returns (uint256 value, uint256 next) {
        if (cursor >= data.length || cursor >= limit) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        uint8 first = uint8(data[cursor]);
        cursor += 1;

        if (first & 0x80 == 0) {
            value = first;
            next = cursor;
            return (value, next);
        }

        if (first & 0xC0 == 0x80) {
            if (cursor >= data.length || cursor >= limit) {
                revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
            }
            uint8 second = uint8(data[cursor]);
            cursor += 1;
            value = ((uint256(first) & 0x3F) << 8) | uint256(second);
            next = cursor;
            return (value, next);
        }

        uint8 lenLen = first & 0x3F;
        if (lenLen == 0 || lenLen > 32) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }
        if (cursor + lenLen > data.length || cursor + lenLen > limit) {
            revert Errors.SchemaValidationFailed(uint8(ctx.target), ctx.refId, ctx.auxId, path);
        }

        uint256 result = 0;
        for (uint8 i = 0; i < lenLen; ++i) {
            result = (result << 8) | uint8(data[cursor]);
            cursor += 1;
        }

        value = result;
        next = cursor;
        return (value, next);
    }

    function _encodePath(uint256 path, uint16 index) private pure returns (uint256) {
        return (path << 16) | index;
    }
}
