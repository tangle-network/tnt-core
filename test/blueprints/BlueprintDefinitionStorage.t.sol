// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { MasterBlueprintServiceManager } from "../../src/MasterBlueprintServiceManager.sol";

contract BlueprintDefinitionStorageTest is BaseTest {
    event BlueprintSourcesUpdated(uint64 indexed blueprintId, uint256 sourceCount);

    /// @dev A real, fetchable, multi-arch (x86_64 + aarch64) native source — the
    ///      shape an owner repoints a blueprint to so manager cold-starts resolve
    ///      the operator's arch. Mirrors the live trading-blueprint fix.
    function _multiArchNativeSource() internal pure returns (Types.BlueprintSource memory source) {
        source.kind = Types.BlueprintSourceKind.Native;
        source.native = Types.NativeSource({
            fetcher: Types.BlueprintFetcherKind.Github,
            artifactUri: "https://github.com/tangle-network/ai-trading-blueprint/releases/download/v0.1.13",
            entrypoint: "trading-blueprint"
        });
        source.binaries = new Types.BlueprintBinary[](2);
        source.binaries[0] = Types.BlueprintBinary({
            arch: Types.BlueprintArchitecture.Amd64,
            os: Types.BlueprintOperatingSystem.Linux,
            name: "trading-blueprint-x86_64-unknown-linux-gnu",
            sha256: bytes32(uint256(0xA11CE))
        });
        source.binaries[1] = Types.BlueprintBinary({
            arch: Types.BlueprintArchitecture.Arm64,
            os: Types.BlueprintOperatingSystem.Linux,
            name: "trading-blueprint-aarch64-unknown-linux-gnu",
            sha256: bytes32(uint256(0xB0B))
        });
    }

    function _createOwned() internal returns (uint64 blueprintId) {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://set-sources", address(0));
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(def);
    }

    function test_GetBlueprintDefinition_ReflectsLiveSources() public {
        uint64 id = _createOwned();
        // Genesis: the definition's sources match the genesis (one container source).
        Types.BlueprintDefinition memory g = tangle.getBlueprintDefinition(id);
        assertEq(g.sources.length, 1, "genesis def sources");
        assertEq(uint256(g.sources[0].kind), uint256(Types.BlueprintSourceKind.Container), "genesis kind");

        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();
        vm.prank(developer);
        tangle.setBlueprintSources(id, next);

        // The definition view (what the manager reads) must now reflect the live
        // sources, not the stale genesis blob — else setBlueprintSources is a no-op
        // for binary resolution.
        Types.BlueprintDefinition memory d = tangle.getBlueprintDefinition(id);
        assertEq(d.sources.length, 1, "def reflects new source count");
        assertEq(uint256(d.sources[0].kind), uint256(Types.BlueprintSourceKind.Native), "def kind -> Native");
        assertEq(uint256(d.sources[0].native.fetcher), uint256(Types.BlueprintFetcherKind.Github), "def fetcher");
        assertEq(d.sources[0].binaries.length, 2, "def per-arch binaries");
        assertEq(d.sources[0].binaries[1].sha256, bytes32(uint256(0xB0B)), "def binary sha overlaid");
        // Non-source fields still come from the genesis blob (unchanged).
        assertEq(d.metadataUri, "ipfs://set-sources", "metadataUri preserved from blob");
    }

    function test_SetBlueprintSources_RepointsToMultiArch() public {
        uint64 id = _createOwned();
        // Genesis: one single-arch container source.
        assertEq(tangle.blueprintSources(id).length, 1, "precondition: one genesis source");

        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();

        vm.expectEmit(true, false, false, true, address(tangle));
        emit BlueprintSourcesUpdated(id, 1);
        vm.prank(developer);
        tangle.setBlueprintSources(id, next);

        Types.BlueprintSource[] memory stored = tangle.blueprintSources(id);
        assertEq(stored.length, 1, "source count");
        assertEq(uint256(stored[0].kind), uint256(Types.BlueprintSourceKind.Native), "kind -> Native");
        assertEq(uint256(stored[0].native.fetcher), uint256(Types.BlueprintFetcherKind.Github), "fetcher -> Github");
        assertEq(stored[0].native.artifactUri, next[0].native.artifactUri, "artifactUri");
        // Deep copy of nested binaries, both arches present with exact hashes.
        assertEq(stored[0].binaries.length, 2, "binary count");
        assertEq(uint256(stored[0].binaries[0].arch), uint256(Types.BlueprintArchitecture.Amd64), "binary0 arch");
        assertEq(uint256(stored[0].binaries[1].arch), uint256(Types.BlueprintArchitecture.Arm64), "binary1 arch");
        assertEq(uint256(stored[0].binaries[1].os), uint256(Types.BlueprintOperatingSystem.Linux), "binary1 os");
        assertEq(stored[0].binaries[1].name, next[0].binaries[1].name, "binary1 name");
        assertEq(stored[0].binaries[1].sha256, bytes32(uint256(0xB0B)), "binary1 sha256");
    }

    function test_SetBlueprintSources_ReplacesNotAppends_NoStaleEntries() public {
        uint64 id = _createOwned();

        // First set: two sources, the first with two binaries.
        Types.BlueprintSource[] memory big = new Types.BlueprintSource[](2);
        big[0] = _multiArchNativeSource(); // 2 binaries
        big[1] = _defaultBlueprintSource(); // 1 binary
        vm.prank(developer);
        tangle.setBlueprintSources(id, big);
        assertEq(tangle.blueprintSources(id).length, 2, "after first set");

        // Re-set to a single source with a single binary; delete must clear the
        // prior nested binaries array, not leave the old second binary dangling.
        Types.BlueprintSource[] memory small = new Types.BlueprintSource[](1);
        small[0] = _defaultBlueprintSource();
        vm.prank(developer);
        tangle.setBlueprintSources(id, small);

        Types.BlueprintSource[] memory stored = tangle.blueprintSources(id);
        assertEq(stored.length, 1, "shrunk to one source");
        assertEq(stored[0].binaries.length, 1, "shrunk to one binary (no stale entries)");
        assertEq(uint256(stored[0].kind), uint256(Types.BlueprintSourceKind.Container), "kind reset");
    }

    function test_SetBlueprintSources_RevertsForNonOwner() public {
        uint64 id = _createOwned();
        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, id, user1));
        tangle.setBlueprintSources(id, next);
    }

    function test_SetBlueprintSources_RevertsForUnknownBlueprint() public {
        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();
        uint64 missing = tangle.blueprintCount() + 7;

        vm.prank(developer);
        vm.expectRevert(abi.encodeWithSelector(Errors.BlueprintNotFound.selector, missing));
        tangle.setBlueprintSources(missing, next);
    }

    function test_SetBlueprintSources_RevertsOnEmptySources() public {
        uint64 id = _createOwned();
        Types.BlueprintSource[] memory empty = new Types.BlueprintSource[](0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintSourcesRequired.selector);
        tangle.setBlueprintSources(id, empty);
    }

    function test_SetBlueprintSources_RevertsOnSourceWithNoBinaries() public {
        uint64 id = _createOwned();
        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();
        next[0].binaries = new Types.BlueprintBinary[](0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintBinaryRequired.selector);
        tangle.setBlueprintSources(id, next);
    }

    function test_SetBlueprintSources_RevertsOnZeroBinaryHash() public {
        uint64 id = _createOwned();
        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();
        next[0].binaries[1].sha256 = bytes32(0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintBinaryHashRequired.selector);
        tangle.setBlueprintSources(id, next);
    }

    function test_MetadataSourcesAndMembershipsPersisted() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://custom-metadata", address(0));
        def.metadata.name = "Custom Blueprint";
        def.metadata.description = "Verifies metadata persistence";
        def.metadata.author = "Integration Team";
        def.metadata.category = "Test Suite";
        def.metadata.license = "Apache-2.0";

        def.sources = new Types.BlueprintSource[](2);
        def.sources[0] = _defaultBlueprintSource();
        def.sources[1].kind = Types.BlueprintSourceKind.Wasm;
        def.sources[1].wasm.runtime = Types.WasmRuntime.Wasmer;
        def.sources[1].wasm.fetcher = Types.BlueprintFetcherKind.Ipfs;
        def.sources[1].wasm.artifactUri = "ipfs://artifact";
        def.sources[1].wasm.entrypoint = "main";
        def.sources[1].binaries = new Types.BlueprintBinary[](1);
        def.sources[1].binaries[0] = Types.BlueprintBinary({
            arch: Types.BlueprintArchitecture.Wasm32,
            os: Types.BlueprintOperatingSystem.Unknown,
            name: "wasm",
            sha256: bytes32(uint256(0x5678))
        });

        def.supportedMemberships = new Types.MembershipModel[](1);
        def.supportedMemberships[0] = Types.MembershipModel.Dynamic;

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(def);

        (Types.BlueprintMetadata memory storedMetadata, string memory metadataUri, bytes32 metadataHash) =
            tangle.blueprintMetadata(blueprintId);
        assertEq(metadataUri, def.metadataUri, "metadata URI mismatch");
        assertEq(metadataHash, def.metadataHash, "metadata hash mismatch");
        assertEq(storedMetadata.name, def.metadata.name);
        assertEq(storedMetadata.description, def.metadata.description);
        assertEq(storedMetadata.author, def.metadata.author);
        assertEq(storedMetadata.license, def.metadata.license);

        Types.BlueprintSource[] memory storedSources = tangle.blueprintSources(blueprintId);
        assertEq(storedSources.length, def.sources.length, "source length mismatch");
        assertEq(uint256(storedSources[1].kind), uint256(def.sources[1].kind));
        assertEq(storedSources[1].wasm.artifactUri, def.sources[1].wasm.artifactUri);
        assertEq(storedSources[1].wasm.entrypoint, def.sources[1].wasm.entrypoint);

        Types.MembershipModel[] memory memberships = tangle.blueprintSupportedMemberships(blueprintId);
        assertEq(memberships.length, def.supportedMemberships.length, "membership length mismatch");
        assertEq(uint256(memberships[0]), uint256(def.supportedMemberships[0]));

        assertEq(
            tangle.blueprintMasterRevision(blueprintId),
            mbsmRegistry.getPinnedRevision(blueprintId),
            "master revision mismatch"
        );
    }

    function test_MasterManagerRecordsDefinition() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://mbsm-record", address(0));
        bytes memory encodedDefinition = abi.encode(def);

        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(def);

        MasterBlueprintServiceManager.BlueprintRecord memory record = masterManager.getBlueprintRecord(blueprintId);
        assertEq(record.owner, developer, "record owner mismatch");
        assertGt(record.recordedAt, 0, "record timestamp missing");
        assertEq(record.encodedDefinition, encodedDefinition, "definition payload mismatch");
    }

    function test_SetMBSMRegistryAccessAndZeroChecks() public {
        vm.expectRevert();
        vm.prank(developer);
        tangle.setMBSMRegistry(address(1));

        vm.prank(admin);
        vm.expectRevert(abi.encodeWithSelector(Errors.ZeroAddress.selector));
        tangle.setMBSMRegistry(address(0));
    }

    function test_CreateBlueprintFailsWithoutMetadata() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("", address(0));
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintMetadataRequired.selector);
        tangle.createBlueprint(def);
    }

    function test_CreateBlueprintFailsWithoutMetadataHash() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://missing-hash", address(0));
        def.metadataHash = bytes32(0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintMetadataHashRequired.selector);
        tangle.createBlueprint(def);
    }

    function test_CreateBlueprintFailsWithoutSources() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://no-sources", address(0));
        def.sources = new Types.BlueprintSource[](0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintSourcesRequired.selector);
        tangle.createBlueprint(def);
    }

    function test_CreateBlueprintFailsWithoutSupportedMemberships() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://no-memberships", address(0));
        def.supportedMemberships = new Types.MembershipModel[](0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintMembershipRequired.selector);
        tangle.createBlueprint(def);
    }

    function test_CreateBlueprintFailsWithoutBinaryDescriptors() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://missing-binaries", address(0));
        def.sources[0].binaries = new Types.BlueprintBinary[](0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintBinaryRequired.selector);
        tangle.createBlueprint(def);
    }

    function test_CreateBlueprintFailsWithZeroHash() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://zero-hash", address(0));
        def.sources[0].binaries[0].sha256 = bytes32(0);
        vm.prank(developer);
        vm.expectRevert(Errors.BlueprintBinaryHashRequired.selector);
        tangle.createBlueprint(def);
    }
}
