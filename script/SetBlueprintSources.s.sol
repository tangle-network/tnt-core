// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { Types } from "../src/libraries/Types.sol";

/// Minimal interface — the deployed router exposes setBlueprintSources (added by
/// the live facet upgrade), but this branch's ITangle interface predates it.
interface ITangleSetSources {
    function setBlueprintSources(uint64 blueprintId, Types.BlueprintSource[] calldata sources) external;
}

/// Manual replay of the publish workflow's cold-start source update
/// (.github/workflows/publish-blueprint-binary.yml, "Update blueprint
/// cold-start sources"). Prefer the workflow; this script sends the same
/// setBlueprintSources transaction locally when Actions is unavailable. It
/// fails closed: every identifying input is required (no blueprint default)
/// and only the architectures with an explicit non-zero sha are published.
///
/// env: TANGLE_CONTRACT, BLUEPRINT_OWNER_PRIVATE_KEY, BLUEPRINT_ID,
///      BLUEPRINT_REPO (owner/repo, e.g. tangle-network/ai-trading-blueprint),
///      BINARY_NAME (released binary = entrypoint, e.g. trading-blueprint),
///      VERSION (release tag), X86_SHA and/or ARM_SHA (0x-prefixed
///      extracted-binary sha256 from the release's
///      <binary>-<triple>.bin.sha256 asset).
contract SetBlueprintSources is Script {
    function artifactUri(
        string memory repo,
        string memory version,
        string memory binaryName,
        string memory triple
    )
        internal
        pure
        returns (string memory)
    {
        string memory base = string.concat("https://github.com/", repo, "/releases/download/", version, "/");
        return string.concat(
            '{"dist_url":"',
            base,
            'dist-manifest.json",',
            '"archive_url":"',
            base,
            binaryName,
            "-",
            triple,
            '.tar.xz",',
            '"binaries":[]}'
        );
    }

    function source(
        string memory repo,
        string memory version,
        string memory binaryName,
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
            fetcher: Types.BlueprintFetcherKind.Http,
            artifactUri: artifactUri(repo, version, binaryName, triple),
            entrypoint: binaryName
        });
        src.binaries = new Types.BlueprintBinary[](1);
        src.binaries[0] = Types.BlueprintBinary({
            arch: arch, os: Types.BlueprintOperatingSystem.Linux, name: binaryName, sha256: sha
        });
    }

    function run() external {
        address tangle = vm.envAddress("TANGLE_CONTRACT");
        uint256 pk = vm.envUint("BLUEPRINT_OWNER_PRIVATE_KEY");
        uint256 rawId = vm.envUint("BLUEPRINT_ID");
        require(rawId <= type(uint64).max, "set sources: BLUEPRINT_ID out of range");
        uint64 blueprintId = uint64(rawId);
        string memory repo = vm.envString("BLUEPRINT_REPO");
        string memory binaryName = vm.envString("BINARY_NAME");
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
            sources[i++] = source(
                repo, version, binaryName, "x86_64-unknown-linux-gnu", Types.BlueprintArchitecture.Amd64, x86Sha
            );
        }
        if (armSha != bytes32(0)) {
            sources[i++] = source(
                repo, version, binaryName, "aarch64-unknown-linux-gnu", Types.BlueprintArchitecture.Arm64, armSha
            );
        }

        vm.startBroadcast(pk);
        ITangleSetSources(tangle).setBlueprintSources(blueprintId, sources);
        vm.stopBroadcast();

        console2.log("setBlueprintSources(%s) -> %s source(s)", blueprintId, sourceCount);
        console2.log("repo: %s @ %s, binary: %s", repo, version, binaryName);
    }
}
