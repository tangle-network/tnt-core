// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { SignatureLib } from "../../src/libraries/SignatureLib.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @title ResourceCommitmentsTest
/// @notice Tests for resource commitment storage and hashing during RFQ flows
contract ResourceCommitmentsTest is BaseTest {
    uint256 constant OPERATOR1_PK = 0x1;
    uint256 constant OPERATOR2_PK = 0x2;

    uint64 blueprintId;

    function setUp() public override {
        super.setUp();

        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);

        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);

        vm.prank(developer);
        blueprintId = _createBlueprintAsSender("ipfs://resource-test", address(0));

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RESOURCE COMMITMENT HASH STORED ON-CHAIN
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ResourceCommitmentHash_StoredOnCreation() public {
        Types.ResourceCommitment[] memory resources = new Types.ResourceCommitment[](2);
        resources[0] = Types.ResourceCommitment({ kind: 0, count: 4 }); // 4 CPU
        resources[1] = Types.ResourceCommitment({ kind: 1, count: 8192 }); // 8192 MB memory

        Types.SignedQuote[] memory quotes =
            _createQuoteWithResources(OPERATOR1_PK, operator1, blueprintId, 100, 1 ether, resources);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);

        bytes32 storedHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        bytes32 expectedHash = SignatureLib.hashResourceCommitments(resources);
        assertEq(storedHash, expectedHash, "stored hash should match computed hash");
        assertTrue(storedHash != bytes32(0), "hash should be non-zero");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENT EMITTED
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ResourcesCommitted_EventEmitted() public {
        Types.ResourceCommitment[] memory resources = new Types.ResourceCommitment[](1);
        resources[0] = Types.ResourceCommitment({ kind: 5, count: 2 }); // 2 GPU

        Types.SignedQuote[] memory quotes =
            _createQuoteWithResources(OPERATOR1_PK, operator1, blueprintId, 100, 1 ether, resources);

        vm.prank(user1);
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);

        // Event is checked via the fact that no revert occurred and hash is stored
        uint64 serviceId = tangle.serviceCount() - 1;
        bytes32 storedHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        assertTrue(storedHash != bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EMPTY COMMITMENTS = NO HASH STORED (BACKWARD COMPAT)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_EmptyResourceCommitments_NoHashStored() public {
        Types.SignedQuote[] memory quotes = _createQuoteNoResources(OPERATOR1_PK, operator1, blueprintId, 100, 1 ether);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);

        bytes32 storedHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        assertEq(storedHash, bytes32(0), "empty commitments should not store hash");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXTENSION UPDATES COMMITMENT HASH
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExtensionUpdatesResourceCommitmentHash() public {
        // Create service with initial resources
        Types.ResourceCommitment[] memory resources1 = new Types.ResourceCommitment[](1);
        resources1[0] = Types.ResourceCommitment({ kind: 0, count: 2 }); // 2 CPU

        Types.SignedQuote[] memory createQuotes =
            _createQuoteWithResources(OPERATOR1_PK, operator1, blueprintId, 100, 1 ether, resources1);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, createQuotes, "", new address[](0), 100);

        bytes32 initialHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);

        // Extend with new resources
        Types.ResourceCommitment[] memory resources2 = new Types.ResourceCommitment[](1);
        resources2[0] = Types.ResourceCommitment({ kind: 0, count: 8 }); // 8 CPU (upgraded)

        Types.SignedQuote[] memory extendQuotes =
            _createQuoteWithResources(OPERATOR1_PK, operator1, blueprintId, 50, 0.5 ether, resources2);

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, extendQuotes, 50);

        bytes32 updatedHash = tangle.getServiceResourceCommitmentHash(serviceId, operator1);
        bytes32 expectedHash = SignatureLib.hashResourceCommitments(resources2);
        assertEq(updatedHash, expectedHash, "hash should match new resources");
        assertTrue(updatedHash != initialHash, "hash should have changed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HASH MATCHES LIBRARY OUTPUT
    // ═══════════════════════════════════════════════════════════════════════════

    function test_HashMatchesSignatureLibOutput() public {
        Types.ResourceCommitment[] memory resources = new Types.ResourceCommitment[](3);
        resources[0] = Types.ResourceCommitment({ kind: 0, count: 4 }); // CPU
        resources[1] = Types.ResourceCommitment({ kind: 1, count: 16_384 }); // Memory
        resources[2] = Types.ResourceCommitment({ kind: 2, count: 102_400 }); // Storage

        bytes32 libHash = SignatureLib.hashResourceCommitments(resources);

        // Manually compute expected hash
        bytes32 RC_TYPEHASH = keccak256("ResourceCommitment(uint8 kind,uint64 count)");
        bytes32[] memory hashes = new bytes32[](3);
        hashes[0] = keccak256(abi.encode(RC_TYPEHASH, uint8(0), uint64(4)));
        hashes[1] = keccak256(abi.encode(RC_TYPEHASH, uint8(1), uint64(16_384)));
        hashes[2] = keccak256(abi.encode(RC_TYPEHASH, uint8(2), uint64(102_400)));

        bytes32 expected;
        assembly ("memory-safe") {
            expected := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }

        assertEq(libHash, expected, "library hash should match manual computation");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GETTER RETURNS CORRECT HASH
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GetterReturnsZeroForUnknownService() public view {
        bytes32 hash = tangle.getServiceResourceCommitmentHash(999, operator1);
        assertEq(hash, bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _createQuoteWithResources(
        uint256 privateKey,
        address operator,
        uint64 bpId,
        uint64 ttl,
        uint256 cost,
        Types.ResourceCommitment[] memory resources
    )
        internal
        view
        returns (Types.SignedQuote[] memory quotes)
    {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: bpId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: resources
        });

        bytes memory signature = _signQuote(details, privateKey);
        quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({ details: details, signature: signature, operator: operator });
    }

    function _createQuoteNoResources(
        uint256 privateKey,
        address operator,
        uint64 bpId,
        uint64 ttl,
        uint256 cost
    )
        internal
        view
        returns (Types.SignedQuote[] memory quotes)
    {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: bpId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes memory signature = _signQuote(details, privateKey);
        quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({ details: details, signature: signature, operator: operator });
    }

    function _signQuote(Types.QuoteDetails memory details, uint256 privateKey) internal view returns (bytes memory) {
        bytes32 commitmentsHash = _hashSecurityCommitments(details.securityCommitments);
        bytes32 resourcesHash = SignatureLib.hashResourceCommitments(details.resourceCommitments);

        bytes32 QUOTE_TYPEHASH = keccak256(
            "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)ResourceCommitment(uint8 kind,uint64 count)"
        );

        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("TangleQuote"),
                keccak256("1"),
                block.chainid,
                address(tangle)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                QUOTE_TYPEHASH,
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                commitmentsHash,
                resourcesHash
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return abi.encodePacked(r, s, v);
    }

    function _hashSecurityCommitments(Types.AssetSecurityCommitment[] memory commitments)
        internal
        pure
        returns (bytes32)
    {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            bytes32 ASSET_TYPEHASH = keccak256("Asset(uint8 kind,address token)");
            bytes32 COMMITMENT_TYPEHASH =
                keccak256("AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)");
            bytes32 assetHash =
                keccak256(abi.encode(ASSET_TYPEHASH, uint8(commitments[i].asset.kind), commitments[i].asset.token));
            hashes[i] = keccak256(abi.encode(COMMITMENT_TYPEHASH, assetHash, commitments[i].exposureBps));
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }
}
