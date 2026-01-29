// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../../src/libraries/Types.sol";
import { SchemaLib } from "../../src/libraries/SchemaLib.sol";

/// @title SchemaTestUtils
/// @notice Generates complex schema/payload pairs for fuzzing SchemaLib
library SchemaTestUtils {
    struct Scenario {
        bytes schema;
        bytes validPayload;
        bytes invalidPayload;
    }

    uint8 private constant MAX_DEPTH = 3;

    /// @notice Produce a pseudo-random schema scenario with both valid and invalid payloads
    function randomScenario(uint256 seed) internal pure returns (Scenario memory scenario) {
        seed = _nextSeed(seed);
        uint8 fieldCount = uint8((seed & 0x03) + 1);
        Types.BlueprintFieldType[] memory fields = new Types.BlueprintFieldType[](fieldCount);
        bytes memory valid;
        bytes memory corrupt;
        bool corruptSet;
        uint256 next = seed;

        for (uint8 i = 0; i < fieldCount; ++i) {
            Types.BlueprintFieldType memory field;
            (field, next) = _buildFieldDefinition(next, 0);
            fields[i] = field;

            bytes memory goodBytes;
            bytes memory badBytes;
            (goodBytes, badBytes, next) = _encodeValue(field, next);
            valid = bytes.concat(valid, goodBytes);

            if (!corruptSet && badBytes.length > 0) {
                corrupt = bytes.concat(corrupt, badBytes);
                corruptSet = true;
            } else {
                corrupt = bytes.concat(corrupt, goodBytes);
            }
        }

        if (!corruptSet) {
            corrupt = _appendExtraneousByte(valid);
        }

        scenario.schema = SchemaLib.encodeSchema(fields);
        scenario.validPayload = valid;
        scenario.invalidPayload = _ensureDifference(valid, corrupt);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FIELD GENERATION
    // ═══════════════════════════════════════════════════════════════════════════

    function _buildFieldDefinition(uint256 seed, uint8 depth)
        private
        pure
        returns (Types.BlueprintFieldType memory field, uint256 nextSeed)
    {
        nextSeed = _nextSeed(seed);
        // forge-lint: disable-next-line(unsafe-typecast)
        uint8 variant = uint8(seed & 0x0F);
        if (depth >= MAX_DEPTH) {
            variant %= 6;
        }

        if (variant == 0) {
            field = _scalarField(Types.BlueprintFieldKind.Bool);
        } else if (variant == 1) {
            field = _scalarField(Types.BlueprintFieldKind.Uint64);
        } else if (variant == 2) {
            field = _scalarField(Types.BlueprintFieldKind.String);
        } else if (variant == 3) {
            field = _scalarField(Types.BlueprintFieldKind.Bytes);
        } else if (variant == 4) {
            field.kind = Types.BlueprintFieldKind.FixedBytes;
            field.arrayLength = uint16((nextSeed & 0x1F) + 1);
            field.children = new Types.BlueprintFieldType[](0);
            field.name = "";
            nextSeed = _nextSeed(nextSeed);
        } else if (variant == 5) {
            field = _scalarField(Types.BlueprintFieldKind.Address);
        } else if (variant == 6) {
            Types.BlueprintFieldType memory child;
            (child, nextSeed) = _buildFieldDefinition(nextSeed, depth + 1);
            field.kind = Types.BlueprintFieldKind.Optional;
            field.children = new Types.BlueprintFieldType[](1);
            field.children[0] = child;
            field.name = "";
        } else if (variant == 7) {
            Types.BlueprintFieldType memory child;
            (child, nextSeed) = _buildFieldDefinition(nextSeed, depth + 1);
            field.kind = Types.BlueprintFieldKind.List;
            field.children = new Types.BlueprintFieldType[](1);
            field.children[0] = child;
            field.name = "";
        } else if (variant == 8) {
            uint8 childCount = uint8((nextSeed & 0x03) + 2);
            field.kind = Types.BlueprintFieldKind.Struct;
            field.children = new Types.BlueprintFieldType[](childCount);
            field.name = "";
            nextSeed = _nextSeed(nextSeed);
            for (uint8 i = 0; i < childCount; ++i) {
                Types.BlueprintFieldType memory child;
                (child, nextSeed) = _buildFieldDefinition(nextSeed, depth + 1);
                field.children[i] = child;
            }
        } else if (variant == 9) {
            Types.BlueprintFieldType memory child;
            (child, nextSeed) = _buildFieldDefinition(nextSeed, depth + 1);
            field.kind = Types.BlueprintFieldKind.Array;
            field.arrayLength = uint16((nextSeed & 0x03) + 1);
            field.children = new Types.BlueprintFieldType[](1);
            field.children[0] = child;
            field.name = "";
            nextSeed = _nextSeed(nextSeed);
        } else if (variant == 10) {
            field = _scalarField(Types.BlueprintFieldKind.Bytes32);
        } else if (variant == 11) {
            field = _scalarField(Types.BlueprintFieldKind.Uint16);
        } else if (variant == 12) {
            field = _scalarField(Types.BlueprintFieldKind.Uint256);
        } else {
            field = _scalarField(Types.BlueprintFieldKind.Bytes);
        }

        return (field, nextSeed);
    }

    function _encodeValue(Types.BlueprintFieldType memory field, uint256 seed)
        private
        pure
        returns (bytes memory good, bytes memory bad, uint256 nextSeed)
    {
        nextSeed = _nextSeed(seed);
        Types.BlueprintFieldKind kind = field.kind;

        if (kind == Types.BlueprintFieldKind.Bool) {
            bool flag = (seed & 0x01) == 1;
            good = abi.encodePacked(bytes1(flag ? 0x01 : 0x00));
            bad = bytes("");
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Uint16) {
            good = _encodeUint(seed, 2);
            bad = _slice(good, 0, good.length > 0 ? good.length - 1 : 0);
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Uint64) {
            good = _encodeUint(seed, 8);
            bad = _slice(good, 0, good.length - 1);
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Uint256) {
            good = _encodeUint(seed, 32);
            bad = _slice(good, 0, good.length - 2);
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Address) {
            address addr = address(uint160(uint256(keccak256(abi.encode(seed)))));
            good = abi.encodePacked(addr);
            bad = bytes("");
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Bytes32) {
            bytes32 data = keccak256(abi.encode(seed));
            good = abi.encodePacked(data);
            bad = _slice(good, 0, good.length - 1);
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.FixedBytes) {
            uint16 len = field.arrayLength > 0 ? field.arrayLength : 1;
            good = _randomBytes(len, seed);
            bad = _slice(good, 0, len > 0 ? len - 1 : 0);
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.String || kind == Types.BlueprintFieldKind.Bytes) {
            uint8 len = uint8((seed & 0x1F) + 1);
            bytes memory body = _randomBytes(len, seed);
            good = bytes.concat(_encodeCompactLength(len), body);
            bad = bytes.concat(_encodeCompactLength(len + 1), body);
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Optional) {
            Types.BlueprintFieldType memory child = field.children[0];
            bool include = (seed & 0x01) == 1;
            if (!include) {
                good = _encodeCompactLength(0);
                bad = bytes.concat(_encodeCompactLength(1));
                return (good, bad, nextSeed);
            }

            bytes memory childGood;
            bytes memory childBad;
            (childGood, childBad, nextSeed) = _encodeValue(child, nextSeed);
            good = bytes.concat(_encodeCompactLength(childGood.length), childGood);
            bytes memory corruptedChild = childBad.length > 0 ? childBad : _slice(childGood, 0, childGood.length - 1);
            bad = bytes.concat(_encodeCompactLength(childGood.length + 1), corruptedChild);
            return (good, bad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.List) {
            Types.BlueprintFieldType memory child = field.children[0];
            uint8 count = uint8((seed & 0x03) + 1);
            bytes memory listGood = _encodeCompactLength(count);
            bytes memory listBad = _encodeCompactLength(count);
            bool placed;
            uint256 curSeed = nextSeed;
            for (uint8 i = 0; i < count; ++i) {
                bytes memory childGood;
                bytes memory childBad;
                (childGood, childBad, curSeed) = _encodeValue(child, curSeed);
                listGood = bytes.concat(listGood, childGood);
                if (!placed && childBad.length > 0) {
                    listBad = bytes.concat(listBad, childBad);
                    placed = true;
                } else {
                    listBad = bytes.concat(listBad, childGood);
                }
            }
            if (!placed) {
                listBad = _appendExtraneousByte(listGood);
            }
            nextSeed = curSeed;
            return (listGood, listBad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Array) {
            Types.BlueprintFieldType memory child = field.children[0];
            uint16 len = field.arrayLength > 0 ? field.arrayLength : 1;
            bytes memory arrGood;
            bytes memory arrBad;
            bool placed;
            uint256 curSeed = nextSeed;
            for (uint16 i = 0; i < len; ++i) {
                bytes memory childGood;
                bytes memory childBad;
                (childGood, childBad, curSeed) = _encodeValue(child, curSeed);
                arrGood = bytes.concat(arrGood, childGood);
                if (!placed && childBad.length > 0) {
                    arrBad = bytes.concat(arrBad, childBad);
                    placed = true;
                } else {
                    arrBad = bytes.concat(arrBad, childGood);
                }
            }
            if (!placed) {
                arrBad = _slice(arrGood, 0, arrGood.length - 1);
            }
            nextSeed = curSeed;
            return (arrGood, arrBad, nextSeed);
        }

        if (kind == Types.BlueprintFieldKind.Struct) {
            bytes memory structGood;
            bytes memory structBad;
            bool placed;
            uint256 curSeed = nextSeed;
            for (uint256 i = 0; i < field.children.length; ++i) {
                Types.BlueprintFieldType memory child = field.children[i];
                bytes memory childGood;
                bytes memory childBad;
                (childGood, childBad, curSeed) = _encodeValue(child, curSeed);
                structGood = bytes.concat(structGood, childGood);
                if (!placed && childBad.length > 0) {
                    structBad = bytes.concat(structBad, childBad);
                    placed = true;
                } else {
                    structBad = bytes.concat(structBad, childGood);
                }
            }
            if (!placed) {
                structBad = _slice(structGood, 0, structGood.length - 1);
            }
            nextSeed = curSeed;
            return (structGood, structBad, nextSeed);
        }

        bytes memory fallbackData = _randomBytes(4, seed);
        good = bytes.concat(_encodeCompactLength(fallbackData.length), fallbackData);
        bad = bytes.concat(_encodeCompactLength(fallbackData.length + 1), fallbackData);
        return (good, bad, nextSeed);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _scalarField(Types.BlueprintFieldKind kind) private pure returns (Types.BlueprintFieldType memory field) {
        field.kind = kind;
        field.arrayLength = 0;
        field.children = new Types.BlueprintFieldType[](0);
        field.name = "";
    }

    function _randomBytes(uint256 length, uint256 seed) private pure returns (bytes memory data) {
        data = new bytes(length);
        uint256 cur = seed;
        for (uint256 i = 0; i < length; ++i) {
            cur = uint256(keccak256(abi.encode(cur, i)));
            // forge-lint: disable-next-line(unsafe-typecast)
            data[i] = bytes1(uint8(cur));
        }
    }

    function _encodeCompactLength(uint256 value) private pure returns (bytes memory out) {
        if (value < 0x80) {
            // forge-lint: disable-next-line(unsafe-typecast)
            out = abi.encodePacked(uint8(value));
        } else if (value < 0x4000) {
            uint8 hi = uint8(0x80 | (value >> 8));
            // forge-lint: disable-next-line(unsafe-typecast)
            uint8 lo = uint8(value);
            out = abi.encodePacked(hi, lo);
        } else {
            revert("length too large");
        }
    }

    function _encodeUint(uint256 value, uint8 size) private pure returns (bytes memory out) {
        out = new bytes(size);
        for (uint8 i = 0; i < size; ++i) {
            // forge-lint: disable-next-line(unsafe-typecast)
            out[size - 1 - i] = bytes1(uint8(value & 0xFF));
            value >>= 8;
        }
    }

    function _slice(bytes memory data, uint256 start, uint256 end) private pure returns (bytes memory sliceData) {
        if (end <= start) {
            return bytes("");
        }
        sliceData = new bytes(end - start);
        for (uint256 i = 0; i < end - start; ++i) {
            sliceData[i] = data[start + i];
        }
    }

    function _ensureDifference(bytes memory valid, bytes memory candidate) private pure returns (bytes memory) {
        if (candidate.length == 0) {
            return _appendExtraneousByte(valid);
        }
        if (candidate.length != valid.length) {
            return candidate;
        }
        bool identical = true;
        for (uint256 i = 0; i < candidate.length; ++i) {
            if (candidate[i] != valid[i]) {
                identical = false;
                break;
            }
        }
        if (identical) {
            return _appendExtraneousByte(valid);
        }
        return candidate;
    }

    function _appendExtraneousByte(bytes memory source) private pure returns (bytes memory) {
        return bytes.concat(source, bytes1(0xFF));
    }

    function _nextSeed(uint256 seed) private pure returns (uint256) {
        if (seed == 0) {
            seed = 0xA5A5A5A5;
        }
        return uint256(keccak256(abi.encode(seed, 0xBEEF)));
    }
}
