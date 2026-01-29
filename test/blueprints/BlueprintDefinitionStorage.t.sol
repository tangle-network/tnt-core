// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { MasterBlueprintServiceManager } from "../../src/MasterBlueprintServiceManager.sol";

contract BlueprintDefinitionStorageTest is BaseTest {
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

		bytes memory encodedDefinition = abi.encode(def);
		vm.prank(developer);
		uint64 blueprintId = tangle.createBlueprint(def);

		(Types.BlueprintMetadata memory storedMetadata, string memory metadataUri) =
			tangle.blueprintMetadata(blueprintId);
		assertEq(metadataUri, def.metadataUri, "metadata URI mismatch");
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

		MasterBlueprintServiceManager.BlueprintRecord memory record =
			masterManager.getBlueprintRecord(blueprintId);
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
		bytes memory encoded = abi.encode(def);
		vm.prank(developer);
		vm.expectRevert(Errors.BlueprintMetadataRequired.selector);
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
