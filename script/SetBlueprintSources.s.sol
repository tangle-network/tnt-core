// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";

interface ITangleSetBlueprintSources {
    enum BlueprintSourceKind {
        Container,
        Wasm,
        Native
    }

    enum BlueprintFetcherKind {
        None,
        Ipfs,
        Http,
        Github
    }

    enum WasmRuntime {
        Unknown,
        Wasmtime,
        Wasmer
    }

    struct ImageRegistrySource {
        string registry;
        string image;
        string tag;
    }

    struct WasmSource {
        WasmRuntime runtime;
        BlueprintFetcherKind fetcher;
        string artifactUri;
        string entrypoint;
    }

    struct NativeSource {
        BlueprintFetcherKind fetcher;
        string artifactUri;
        string entrypoint;
    }

    struct TestingSource {
        string cargoPackage;
        string cargoBin;
        string basePath;
    }

    enum BlueprintArchitecture {
        Wasm32,
        Wasm64,
        Wasi32,
        Wasi64,
        Amd32,
        Amd64,
        Arm32,
        Arm64,
        RiscV32,
        RiscV64
    }

    enum BlueprintOperatingSystem {
        Unknown,
        Linux,
        Windows,
        MacOS,
        BSD
    }

    struct BlueprintBinary {
        BlueprintArchitecture arch;
        BlueprintOperatingSystem os;
        string name;
        bytes32 sha256;
    }

    struct BlueprintSource {
        BlueprintSourceKind kind;
        ImageRegistrySource container;
        WasmSource wasm;
        NativeSource native;
        TestingSource testing;
        BlueprintBinary[] binaries;
    }

    function setBlueprintSources(uint64 blueprintId, BlueprintSource[] calldata sources) external;
}

contract SetBlueprintSources is Script {
    string constant ENTRYPOINT = "trading-blueprint";

    function artifactUri(string memory repo, string memory version, string memory binaryName, string memory triple)
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
        ITangleSetBlueprintSources.BlueprintArchitecture arch,
        bytes32 sha
    )
        internal
        pure
        returns (ITangleSetBlueprintSources.BlueprintSource memory src)
    {
        src.kind = ITangleSetBlueprintSources.BlueprintSourceKind.Native;
        src.native = ITangleSetBlueprintSources.NativeSource({
            fetcher: ITangleSetBlueprintSources.BlueprintFetcherKind.Http,
            artifactUri: artifactUri(repo, version, binaryName, triple),
            entrypoint: ENTRYPOINT
        });
        src.binaries = new ITangleSetBlueprintSources.BlueprintBinary[](1);
        src.binaries[0] = ITangleSetBlueprintSources.BlueprintBinary({
            arch: arch,
            os: ITangleSetBlueprintSources.BlueprintOperatingSystem.Linux,
            name: ENTRYPOINT,
            sha256: sha
        });
    }

    function run() external {
        address tangle = vm.envAddress("TANGLE_CONTRACT");
        uint64 blueprintId = uint64(vm.envUint("BLUEPRINT_ID"));
        uint256 ownerKey = vm.envUint("BLUEPRINT_OWNER_PRIVATE_KEY");
        string memory repo = vm.envString("BLUEPRINT_REPO");
        string memory version = vm.envString("BLUEPRINT_VERSION");
        string memory binaryName = vm.envString("BINARY_NAME");
        bytes32 x86Sha = vm.envBytes32("X86_SHA");
        bytes32 armSha = vm.envBytes32("ARM_SHA");

        ITangleSetBlueprintSources.BlueprintSource[] memory sources = new ITangleSetBlueprintSources.BlueprintSource[](2);
        sources[0] =
            source(
                repo,
                version,
                binaryName,
                "x86_64-unknown-linux-gnu",
                ITangleSetBlueprintSources.BlueprintArchitecture.Amd64,
                x86Sha
            );
        sources[1] =
            source(
                repo,
                version,
                binaryName,
                "aarch64-unknown-linux-gnu",
                ITangleSetBlueprintSources.BlueprintArchitecture.Arm64,
                armSha
            );

        vm.startBroadcast(ownerKey);
        ITangleSetBlueprintSources(tangle).setBlueprintSources(blueprintId, sources);
        vm.stopBroadcast();

        console2.log("setBlueprintSources(%s) -> %s/%s", blueprintId, repo, version);
    }
}
