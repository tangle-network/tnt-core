// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { Types } from "../src/libraries/Types.sol";

/// Minimal interface — the deployed router exposes setBlueprintSources (added by
/// the live facet upgrade), but this branch's ITangle interface predates it.
interface ITangleSetSources {
    function setBlueprintSources(uint64 blueprintId, Types.BlueprintSource[] calldata sources) external;
}

/// Emergency/manual version of the publish workflow's cold-start source update.
/// Prefer `.github/workflows/publish-blueprint-binary.yml`; this script is for
/// replaying the exact setBlueprintSources transaction locally when Actions is
/// unavailable. It fails closed: VERSION is required and only the architectures
/// with an explicit non-zero sha are published.
///
/// env: TANGLE_CONTRACT, BLUEPRINT_OWNER_PRIVATE_KEY, VERSION,
///      X86_SHA and/or ARM_SHA (0x-prefixed extracted-binary sha256 from the
///      release's .bin.sha256 asset), optional BLUEPRINT_ID (default 13).
contract SetTradingSourcesV016 is Script {
    uint64 constant DEFAULT_BLUEPRINT_ID = 13;
    string constant ENTRYPOINT = "trading-blueprint";

    function artifactUri(string memory version, string memory triple) internal pure returns (string memory) {
        string memory base =
            string.concat("https://github.com/tangle-network/ai-trading-blueprint/releases/download/", version, "/");
        return string.concat(
            '{"dist_url":"',
            base,
            'dist-manifest.json",',
            '"archive_url":"',
            base,
            "trading-blueprint-",
            triple,
            '.tar.xz",',
            '"binaries":[]}'
        );
    }

    function source(
        string memory version,
        string memory triple,
        Types.BlueprintArchitecture arch,
        bytes32 sha
    )
        internal
        pure
        returns (Types.BlueprintSource memory src)
    {
        src.kind = Types.BlueprintSourceKind.Native;
        src.native = Types.NativeSource({
            fetcher: Types.BlueprintFetcherKind.Http, artifactUri: artifactUri(version, triple), entrypoint: ENTRYPOINT
        });
        src.binaries = new Types.BlueprintBinary[](1);
        src.binaries[0] = Types.BlueprintBinary({
            arch: arch, os: Types.BlueprintOperatingSystem.Linux, name: ENTRYPOINT, sha256: sha
        });
    }

    function run() external {
        address tangle = vm.envAddress("TANGLE_CONTRACT");
        uint256 pk = vm.envUint("BLUEPRINT_OWNER_PRIVATE_KEY");
        uint64 blueprintId = uint64(vm.envOr("BLUEPRINT_ID", uint256(DEFAULT_BLUEPRINT_ID)));
        string memory version = vm.envString("VERSION");
        bytes32 x86Sha = vm.envOr("X86_SHA", bytes32(0));
        bytes32 armSha = vm.envOr("ARM_SHA", bytes32(0));

        uint256 sourceCount;
        if (x86Sha != bytes32(0)) sourceCount++;
        if (armSha != bytes32(0)) sourceCount++;
        require(sourceCount != 0, "set sources: X86_SHA or ARM_SHA required");

        Types.BlueprintSource[] memory sources = new Types.BlueprintSource[](sourceCount);
        uint256 i;
        if (x86Sha != bytes32(0)) {
            sources[i++] = source(version, "x86_64-unknown-linux-gnu", Types.BlueprintArchitecture.Amd64, x86Sha);
        }
        if (armSha != bytes32(0)) {
            sources[i++] = source(version, "aarch64-unknown-linux-gnu", Types.BlueprintArchitecture.Arm64, armSha);
        }

        vm.startBroadcast(pk);
        ITangleSetSources(tangle).setBlueprintSources(blueprintId, sources);
        vm.stopBroadcast();

        console2.log("setBlueprintSources(%s) -> %s source(s)", blueprintId, sourceCount);
        console2.log("version: %s", version);
    }
}
