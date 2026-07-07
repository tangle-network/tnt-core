// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { TangleMetrics } from "../../src/rewards/TangleMetrics.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Vm } from "forge-std/Vm.sol";

contract BlueprintDefinitionStorageTest is BaseTest {
    event BlueprintSourcesRecorded(
        uint64 indexed blueprintId, bytes32 indexed sourcesHash, Types.BlueprintSource[] sources
    );

    /// @dev Decode the full blueprint definition from the BlueprintDefinitionRecorded
    ///      event payload — the canonical off-chain copy of the display data that is no
    ///      longer stored on-chain.
    function _decodeRecordedDefinition(Vm.Log[] memory logs)
        internal
        pure
        returns (Types.BlueprintDefinition memory def)
    {
        bytes32 topic = keccak256("BlueprintDefinitionRecorded(uint64,address,bytes)");
        for (uint256 i = 0; i < logs.length; ++i) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == topic) {
                bytes memory payload = abi.decode(logs[i].data, (bytes));
                return abi.decode(payload, (Types.BlueprintDefinition));
            }
        }
        revert("BlueprintDefinitionRecorded not emitted");
    }

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

    function _remoteNativeSource(
        string memory version,
        string memory triple,
        Types.BlueprintArchitecture arch,
        bytes32 sha
    )
        internal
        pure
        returns (Types.BlueprintSource memory source)
    {
        string memory base =
            string.concat("https://github.com/tangle-network/ai-trading-blueprint/releases/download/", version);
        string memory artifactUri = string.concat(
            "{\"dist_url\":\"",
            base,
            "/dist-manifest.json\",\"archive_url\":\"",
            base,
            "/trading-blueprint-",
            triple,
            ".tar.xz\",\"binaries\":[]}"
        );

        source.kind = Types.BlueprintSourceKind.Native;
        source.native = Types.NativeSource({
            fetcher: Types.BlueprintFetcherKind.Http, artifactUri: artifactUri, entrypoint: "trading-blueprint"
        });
        source.binaries = new Types.BlueprintBinary[](1);
        source.binaries[0] = Types.BlueprintBinary({
            arch: arch, os: Types.BlueprintOperatingSystem.Linux, name: "trading-blueprint", sha256: sha
        });
    }

    function _createOwned() internal returns (uint64 blueprintId) {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://set-sources", address(0));
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(def);
    }

    function test_BlueprintSourcesHash_ReflectsLiveSources() public {
        uint64 id = _createOwned();
        // Genesis: sources are anchored on-chain by hash only (the array itself is
        // not stored). The genesis set is one container source.
        Types.BlueprintSource[] memory genesis = new Types.BlueprintSource[](1);
        genesis[0] = _defaultBlueprintSource();
        bytes32 genesisHash = tangle.blueprintSourcesHash(id);
        assertEq(genesisHash, keccak256(abi.encode(genesis)), "genesis sources hash");

        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();
        vm.prank(developer);
        tangle.setBlueprintSources(id, next);

        // The on-chain anchor (what operators ack against) must now reflect the live
        // sources, not the stale genesis set — else setBlueprintSources is a no-op
        // for binary resolution. A hash match verifies the FULL array round-trips.
        assertEq(tangle.blueprintSourcesHash(id), keccak256(abi.encode(next)), "hash reflects new sources");
        assertTrue(tangle.blueprintSourcesHash(id) != genesisHash, "hash changed from genesis");

        // The definition view no longer reconstructs sources on-chain (empty array);
        // display data lives in the BlueprintSourcesRecorded event, not this view.
        Types.BlueprintDefinition memory d = tangle.getBlueprintDefinition(id);
        assertEq(d.sources.length, 0, "def sources not stored on-chain");
        // Non-source fields still come from the genesis blob (unchanged).
        assertEq(d.metadataUri, "ipfs://set-sources", "metadataUri preserved from blob");
    }

    function test_SetBlueprintSources_RepointsToMultiArch() public {
        uint64 id = _createOwned();
        // Genesis: one single-arch container source, anchored by hash only.
        Types.BlueprintSource[] memory genesis = new Types.BlueprintSource[](1);
        genesis[0] = _defaultBlueprintSource();
        assertEq(
            tangle.blueprintSourcesHash(id), keccak256(abi.encode(genesis)), "precondition: genesis sources hash"
        );

        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _multiArchNativeSource();
        bytes32 nextHash = keccak256(abi.encode(next));

        // The repoint re-fires the FULL source array (both arches, exact hashes)
        // alongside the anchor hash; matching topics + data proves the whole payload.
        vm.expectEmit(true, true, false, true, address(tangle));
        emit BlueprintSourcesRecorded(id, nextHash, next);
        vm.prank(developer);
        tangle.setBlueprintSources(id, next);

        // A hash match verifies the full content round-trips — any field difference
        // (kind, fetcher, artifactUri, per-arch binaries, names, sha256s) changes it.
        assertEq(tangle.blueprintSourcesHash(id), nextHash, "sources hash reflects multi-arch repoint");
    }

    function test_SetBlueprintSources_AllowsX86OnlyRemoteNativeSource() public {
        uint64 id = _createOwned();

        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](1);
        next[0] = _remoteNativeSource(
            "v0.1.28", "x86_64-unknown-linux-gnu", Types.BlueprintArchitecture.Amd64, bytes32(uint256(0xA11CE))
        );

        vm.prank(developer);
        tangle.setBlueprintSources(id, next);

        // Hash anchors the full x86-only remote-native set (kind, Http fetcher,
        // entrypoint, single Amd64 binary + sha256); a match round-trips all of it.
        assertEq(tangle.blueprintSourcesHash(id), keccak256(abi.encode(next)), "sources hash reflects x86-only set");

        // The on-chain definition view no longer reconstructs sources.
        Types.BlueprintDefinition memory definition = tangle.getBlueprintDefinition(id);
        assertEq(definition.sources.length, 0, "definition sources not stored on-chain");
    }

    function test_SetBlueprintSources_ReflectsPerArchRemoteNativeSourceArray() public {
        uint64 id = _createOwned();

        Types.BlueprintSource[] memory next = new Types.BlueprintSource[](2);
        next[0] = _remoteNativeSource(
            "v0.1.28", "x86_64-unknown-linux-gnu", Types.BlueprintArchitecture.Amd64, bytes32(uint256(0xA11CE))
        );
        next[1] = _remoteNativeSource(
            "v0.1.28", "aarch64-unknown-linux-gnu", Types.BlueprintArchitecture.Arm64, bytes32(uint256(0xB0B))
        );

        vm.prank(developer);
        tangle.setBlueprintSources(id, next);

        // Hash anchors the full two-source per-arch array (x86 + arm, each with its
        // own binary, arch, entrypoint, uri and sha256); a match round-trips it all.
        assertEq(tangle.blueprintSourcesHash(id), keccak256(abi.encode(next)), "sources hash reflects per-arch array");

        // The on-chain definition view no longer reconstructs sources.
        Types.BlueprintDefinition memory definition = tangle.getBlueprintDefinition(id);
        assertEq(definition.sources.length, 0, "definition sources not stored on-chain");
    }

    function test_SetBlueprintSources_ReplacesNotAppends_NoStaleEntries() public {
        uint64 id = _createOwned();

        // First set: two sources, the first with two binaries.
        Types.BlueprintSource[] memory big = new Types.BlueprintSource[](2);
        big[0] = _multiArchNativeSource(); // 2 binaries
        big[1] = _defaultBlueprintSource(); // 1 binary
        vm.prank(developer);
        tangle.setBlueprintSources(id, big);
        assertEq(tangle.blueprintSourcesHash(id), keccak256(abi.encode(big)), "after first set");

        // Re-set to a single source with a single binary; the anchor must be recomputed
        // over ONLY the new set, not left carrying the old second source/binary.
        Types.BlueprintSource[] memory small = new Types.BlueprintSource[](1);
        small[0] = _defaultBlueprintSource();
        vm.prank(developer);
        tangle.setBlueprintSources(id, small);

        // Hash equals keccak256(abi.encode(small)) exactly — any stale entry from the
        // prior set would change the encoding and break this equality. Replace, not append.
        assertEq(tangle.blueprintSourcesHash(id), keccak256(abi.encode(small)), "shrunk to one source, no stale entries");
        assertTrue(
            tangle.blueprintSourcesHash(id) != keccak256(abi.encode(big)), "anchor no longer reflects the old big set"
        );
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
        def.metadata.profilingData = "gpu:h100";

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

        vm.recordLogs();
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(def);

        (Types.BlueprintMetadata memory storedMetadata, string memory metadataUri, bytes32 metadataHash) =
            tangle.blueprintMetadata(blueprintId);
        assertEq(metadataUri, def.metadataUri, "metadata URI mismatch");
        assertEq(metadataHash, def.metadataHash, "metadata hash mismatch");
        // name + profilingData stay on-chain (operator manager reads them);
        // the other display fields are now empty on-chain and carried by the event.
        assertEq(storedMetadata.name, def.metadata.name, "name persisted on-chain");
        assertEq(storedMetadata.profilingData, def.metadata.profilingData, "profilingData persisted on-chain");
        assertEq(storedMetadata.description, "", "description dropped on-chain");
        assertEq(storedMetadata.author, "", "author dropped on-chain");
        assertEq(storedMetadata.category, "", "category dropped on-chain");
        assertEq(storedMetadata.codeRepository, "", "codeRepository dropped on-chain");
        assertEq(storedMetadata.license, "", "license dropped on-chain");

        // The full display metadata round-trips through the BlueprintDefinitionRecorded event.
        Types.BlueprintDefinition memory recorded = _decodeRecordedDefinition(vm.getRecordedLogs());
        assertEq(recorded.metadata.name, def.metadata.name, "event metadata name");
        assertEq(recorded.metadata.description, def.metadata.description, "event metadata description");
        assertEq(recorded.metadata.author, def.metadata.author, "event metadata author");
        assertEq(recorded.metadata.category, def.metadata.category, "event metadata category");
        assertEq(recorded.metadata.license, def.metadata.license, "event metadata license");

        // Sources are anchored on-chain by hash only; a match round-trips the full
        // two-source set (container + wasm, with wasm kind/artifactUri/entrypoint).
        assertEq(
            tangle.blueprintSourcesHash(blueprintId),
            keccak256(abi.encode(def.sources)),
            "sources hash mismatch"
        );

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

        // The MBSM no longer stores a record — it only emits. The definition digest
        // lives on Tangle core; the owner rides the BlueprintDefinitionRecorded event
        // as an indexed topic.
        vm.recordLogs();
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(def);

        assertEq(tangle.blueprintDefinitionHash(blueprintId), keccak256(encodedDefinition), "definition digest mismatch");

        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 topic = keccak256("BlueprintDefinitionRecorded(uint64,address,bytes)");
        bool found;
        for (uint256 i = 0; i < logs.length; ++i) {
            if (logs[i].topics.length > 2 && logs[i].topics[0] == topic) {
                assertEq(uint64(uint256(logs[i].topics[1])), blueprintId, "event blueprintId mismatch");
                assertEq(address(uint160(uint256(logs[i].topics[2]))), developer, "record owner mismatch");
                found = true;
            }
        }
        assertTrue(found, "BlueprintDefinitionRecorded not emitted");
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

    /// @notice Job COUNT, index ORDER, and schemas survive the
    ///         create -> getBlueprintDefinition round-trip; the display strings
    ///         (name/description/metadataUri) are now dropped on-chain and carried by the
    ///         BlueprintDefinitionRecorded event. The cargo-tangle CLI reads the display
    ///         strings from the event; schema-driven submission still reads on-chain.
    function test_JobsRoundTripExactlyThroughDefinitionView() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://job-roundtrip", address(0));
        def.jobs = new Types.JobDefinition[](2);
        def.jobs[0] = Types.JobDefinition({
            name: "sandbox_create",
            description: "Create a new AI sandbox",
            metadataUri: "ipfs://job-0-meta",
            paramsSchema: _boolSchema(),
            resultSchema: _boolUintSchema()
        });
        def.jobs[1] = Types.JobDefinition({
            name: "sandbox_delete",
            description: "",
            metadataUri: "",
            paramsSchema: _emptySchema(),
            resultSchema: _emptySchema()
        });

        vm.recordLogs();
        vm.prank(developer);
        uint64 id = tangle.createBlueprint(def);

        // On-chain: count + order + schemas exact; display strings emptied.
        Types.BlueprintDefinition memory got = tangle.getBlueprintDefinition(id);
        assertEq(got.jobs.length, 2, "job count");
        assertEq(got.jobs[0].paramsSchema, def.jobs[0].paramsSchema, "job0 paramsSchema");
        assertEq(got.jobs[0].resultSchema, def.jobs[0].resultSchema, "job0 resultSchema");
        assertEq(got.jobs[1].paramsSchema, def.jobs[1].paramsSchema, "job1 paramsSchema");
        assertEq(got.jobs[1].resultSchema, def.jobs[1].resultSchema, "job1 resultSchema");
        assertEq(got.jobs[0].name, "", "job0 name dropped on-chain");
        assertEq(got.jobs[0].description, "", "job0 description dropped on-chain");
        assertEq(got.jobs[0].metadataUri, "", "job0 metadataUri dropped on-chain");
        assertEq(got.jobs[1].name, "", "job1 name dropped on-chain");

        // The event carries the full display strings for every job, in order.
        Types.BlueprintDefinition memory recorded = _decodeRecordedDefinition(vm.getRecordedLogs());
        assertEq(recorded.jobs.length, 2, "event job count");
        assertEq(recorded.jobs[0].name, def.jobs[0].name, "event job0 name");
        assertEq(recorded.jobs[0].description, def.jobs[0].description, "event job0 description");
        assertEq(recorded.jobs[0].metadataUri, def.jobs[0].metadataUri, "event job0 metadataUri");
        assertEq(recorded.jobs[0].paramsSchema, def.jobs[0].paramsSchema, "event job0 paramsSchema");
        assertEq(recorded.jobs[1].name, def.jobs[1].name, "event job1 name");
    }

    /// @notice The on-chain 32-byte digest (held by Tangle core, not the MBSM) anchors
    ///         the creation-time encoding: it must match keccak256(abi.encode(def)) AND
    ///         the payload of the BlueprintDefinitionRecorded event — which abi-decodes
    ///         back to the original definition. This is the event-sourcing contract
    ///         that replaced storing the multi-KB blob on-chain.
    function test_DefinitionHashAnchorsEventSourcedCopy() public {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://hash-anchor", address(0));
        bytes32 expected = keccak256(abi.encode(def));

        vm.recordLogs();
        vm.prank(developer);
        uint64 id = tangle.createBlueprint(def);

        assertEq(tangle.blueprintDefinitionHash(id), expected, "on-chain digest");

        // The event payload is the canonical off-chain copy: hash-match + decode round-trip.
        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 topic = keccak256("BlueprintDefinitionRecorded(uint64,address,bytes)");
        bool found;
        for (uint256 i = 0; i < logs.length; ++i) {
            if (logs[i].topics.length > 0 && logs[i].topics[0] == topic) {
                bytes memory payload = abi.decode(logs[i].data, (bytes));
                assertEq(keccak256(payload), expected, "event payload digest");
                Types.BlueprintDefinition memory decoded = abi.decode(payload, (Types.BlueprintDefinition));
                assertEq(decoded.metadataUri, def.metadataUri, "decoded metadataUri");
                assertEq(decoded.jobs.length, def.jobs.length, "decoded job count");
                assertEq(decoded.metadata.name, def.metadata.name, "decoded metadata name");
                found = true;
            }
        }
        assertTrue(found, "BlueprintDefinitionRecorded not emitted");
    }

    /// @notice Wiring the metrics recorder requires BOTH the pointer and RECORDER_ROLE
    ///         (the FullDeploy script grants both). With the grant, createBlueprint
    ///         records developer attribution; without it, creation still succeeds and
    ///         metrics are silently skipped (the hook is best-effort by design).
    function test_MetricsRecordDeveloperAttributionWhenRoleGranted() public {
        TangleMetrics impl = new TangleMetrics();
        TangleMetrics metrics =
            TangleMetrics(address(new ERC1967Proxy(address(impl), abi.encodeCall(TangleMetrics.initialize, (admin)))));

        vm.startPrank(admin);
        tangle.setMetricsRecorder(address(metrics));
        metrics.grantRecorderRole(address(tangle));
        vm.stopPrank();

        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://metrics-wired", address(0));
        vm.prank(developer);
        uint64 id = tangle.createBlueprint(def);
        assertEq(metrics.blueprintDeveloper(id), developer, "developer attribution recorded");
        assertEq(metrics.developerBlueprintCount(developer), 1, "developer count");

        // Revoking the role degrades gracefully: creation succeeds, metrics skipped.
        bytes32 recorderRole = metrics.RECORDER_ROLE();
        vm.prank(admin);
        metrics.revokeRole(recorderRole, address(tangle));
        Types.BlueprintDefinition memory def2 = _blueprintDefinition("ipfs://metrics-unwired", address(0));
        vm.prank(developer);
        uint64 id2 = tangle.createBlueprint(def2);
        assertEq(metrics.blueprintDeveloper(id2), address(0), "no attribution without role");
    }
}
