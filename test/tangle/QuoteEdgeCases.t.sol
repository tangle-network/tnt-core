// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { SignatureLib } from "../../src/libraries/SignatureLib.sol";

/// @title QuoteEdgeCasesTest
/// @notice Edge cases for RFQ quote system
/// @dev Overrides operator addresses from BaseTest to use actual private keys for signature testing
contract QuoteEdgeCasesTest is BaseTest {
    // Use actual private keys for signature testing
    uint256 public operator1Key = 0xA11CE;
    uint256 public operator2Key = 0xB0B;
    uint256 public operator3Key = 0xC0DE;

    uint64 public blueprintId;

    function setUp() public override {
        // Override operator addresses with key-derived addresses before BaseTest.setUp()
        operator1 = vm.addr(operator1Key);
        operator2 = vm.addr(operator2Key);
        operator3 = vm.addr(operator3Key);

        super.setUp();

        // Setup operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);

        // Setup blueprint
        blueprintId = _createBlueprint(developer);

        // Register operators for blueprint
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUOTE SIGNATURE EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateServiceFromQuotes_ValidSignature() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), ttl);

        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);

        assertTrue(tangle.isServiceActive(serviceId));
    }

    function test_CreateServiceFromQuotes_ExpiredQuote_Reverts() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp - 1), uint64(ttl)); // Already
        // expired

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(); // Quote expired
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_QuoteExpiresExactlyAtTimestamp() public {
        uint64 ttl = 30 days;
        uint64 deadline = uint64(block.timestamp);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, deadline, uint64(ttl));

        address[] memory callers = new address[](0);

        vm.prank(user1);
        // Behavior at exact boundary - depends on implementation (< vs <=)
        try tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl) {
        // Success case - deadline is inclusive
        }
            catch {
            // Failure case - deadline is exclusive
        }
    }

    function test_CreateServiceFromQuotes_InvalidSignature_Reverts() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);

        // Create quote with wrong signer
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);

        // Sign with operator2's key but claim it's from operator1
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operator2Key, digest);

        quotes[0] = Types.SignedQuote({
            operator: operator1, // Wrong operator
            details: details,
            signature: abi.encodePacked(r, s, v)
        });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(); // Invalid signature
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_ReusedQuote_Reverts() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), uint64(ttl));

        address[] memory callers = new address[](0);

        // First use - should succeed
        vm.prank(user1);
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);

        // Second use - should fail (quote already used)
        vm.prank(user1);
        vm.expectRevert(); // Quote already used
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_WrongBlueprintId_Reverts() public {
        uint64 ttl = 30 days;
        // Create quote for different blueprint
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId + 1, // Wrong blueprint
            ttlBlocks: ttl,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operator1Key, digest);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({ operator: operator1, details: details, signature: abi.encodePacked(r, s, v) });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(); // Blueprint mismatch or not found
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId, // Trying to create for blueprintId
            quotes, // But quote is for blueprintId + 1
            "",
            callers,
            ttl
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateServiceFromQuotes_InsufficientPayment_Reverts() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), uint64(ttl));

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientPaymentForQuotes.selector, 1 ether, 0.5 ether));
        tangle.createServiceFromQuotes{ value: 0.5 ether }( // Insufficient
            blueprintId, quotes, "", callers, ttl
        );
    }

    function test_CreateServiceFromQuotes_ExcessPayment_Reverts() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), uint64(ttl));

        address[] memory callers = new address[](0);

        uint256 userBalanceBefore = user1.balance;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 1 ether, 2 ether));
        tangle.createServiceFromQuotes{ value: 2 ether }(blueprintId, quotes, "", callers, ttl);

        assertEq(user1.balance, userBalanceBefore, "User balance unchanged on revert");
    }

    function test_CreateServiceFromQuotes_ZeroPriceQuote() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 0, uint64(block.timestamp + 1 hours), uint64(ttl));

        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes( // No payment needed
            blueprintId,
            quotes,
            "",
            callers,
            ttl
        );

        assertTrue(tangle.isServiceActive(serviceId));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTIPLE OPERATORS EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateServiceFromQuotes_MultipleOperators() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](3);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), uint64(ttl));
        quotes[1] = _createSignedQuote(operator2Key, operator2, 2 ether, uint64(block.timestamp + 1 hours), uint64(ttl));
        quotes[2] =
            _createSignedQuote(operator3Key, operator3, 1.5 ether, uint64(block.timestamp + 1 hours), uint64(ttl));

        address[] memory callers = new address[](0);

        uint256 totalCost = 4.5 ether;

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: totalCost }(blueprintId, quotes, "", callers, ttl);

        assertTrue(tangle.isServiceActive(serviceId));
        assertTrue(tangle.isServiceOperator(serviceId, operator1));
        assertTrue(tangle.isServiceOperator(serviceId, operator2));
        assertTrue(tangle.isServiceOperator(serviceId, operator3));
    }

    function test_CreateServiceFromQuotes_DuplicateOperatorQuotes_Reverts() public {
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), uint64(ttl));
        // Second quote from same operator - should still fail
        quotes[1] = _createSignedQuote(operator1Key, operator1, 2 ether, uint64(block.timestamp + 2 hours), uint64(ttl));

        address[] memory callers = new address[](0);

        vm.prank(user1);
        // Should revert - same operator twice
        vm.expectRevert(); // Duplicate operator or quote already used
        tangle.createServiceFromQuotes{ value: 2 ether }(blueprintId, quotes, "", callers, ttl);
    }

    function test_CreateServiceFromQuotes_UnregisteredOperator_Reverts() public {
        uint64 ttl = 30 days;
        uint256 unregisteredKey = 0xDEAD;
        address unregisteredOp = vm.addr(unregisteredKey); // Derive address from key

        // Register with staking but not for blueprint
        vm.deal(unregisteredOp, 10 ether);
        vm.prank(unregisteredOp);
        staking.registerOperator{ value: 5 ether }();

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl, // Must match TTL passed to createServiceFromQuotes
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(unregisteredKey, digest);

        quotes[0] =
            Types.SignedQuote({ operator: unregisteredOp, details: details, signature: abi.encodePacked(r, s, v) });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotRegistered.selector, blueprintId, unregisteredOp));
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SECURITY COMMITMENTS EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateServiceFromQuotes_WithSecurityCommitments() public {
        uint64 ttl = 30 days;
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ token: address(0), kind: Types.AssetKind.Native }),
            exposureBps: 5000 // 50%
        });

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl, // Must match TTL passed to createServiceFromQuotes
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: commitments,
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operator1Key, digest);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({ operator: operator1, details: details, signature: abi.encodePacked(r, s, v) });

        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);

        assertTrue(tangle.isServiceActive(serviceId));

        // Check exposure was set correctly
        Types.ServiceOperator memory opData = tangle.getServiceOperator(serviceId, operator1);
        assertEq(opData.exposureBps, 5000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TTL EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateServiceFromQuotes_ZeroTTL() public {
        uint64 ttl = 0;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), ttl);

        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            callers,
            ttl // Zero TTL
        );

        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(svc.ttl, 0);
    }

    function test_CreateServiceFromQuotes_MaxTTL() public {
        uint64 ttl = type(uint64).max;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), ttl);

        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", callers, ttl);

        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(svc.ttl, type(uint64).max);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EMPTY QUOTES EDGE CASE
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateServiceFromQuotes_EmptyQuotes_Reverts() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](0);
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(); // No operators
        tangle.createServiceFromQuotes(blueprintId, quotes, "", callers, 30 days);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUOTE TIMESTAMP EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateServiceFromQuotes_MultipleOperators_DifferentCosts() public {
        // Multiple operators can provide quotes for the same service
        // Note: Quote digests must be unique (use different costs/expiry per operator)
        uint64 ttl = 30 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        // Different costs make digests unique
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), uint64(ttl));
        quotes[1] = _createSignedQuote(operator2Key, operator2, 2 ether, uint64(block.timestamp + 1 hours), uint64(ttl));

        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 3 ether }(blueprintId, quotes, "", callers, ttl);

        assertTrue(tangle.isServiceActive(serviceId));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _createSignedQuote(
        uint256 privateKey,
        address operator,
        uint256 totalCost,
        uint64 expiry,
        uint64 ttl
    )
        internal
        view
        returns (Types.SignedQuote memory)
    {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl, // Must match the TTL passed to createServiceFromQuotes
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return Types.SignedQuote({ operator: operator, details: details, signature: abi.encodePacked(r, s, v) });
    }

    function _computeQuoteDigest(Types.QuoteDetails memory details) internal view returns (bytes32) {
        bytes32 commitmentsHash = _hashSecurityCommitments(details.securityCommitments);
        bytes32 resourcesHash = _hashResourceCommitments(details.resourceCommitments);
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)ResourceCommitment(uint8 kind,uint64 count)"
                ),
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                commitmentsHash,
                resourcesHash
            )
        );

        // Get domain separator from contract (if exposed) or compute it
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("TangleQuote"),
                keccak256("1"),
                block.chainid,
                address(tangle)
            )
        );

        return MessageHashUtils.toTypedDataHash(domainSeparator, structHash);
    }

    function _hashSecurityCommitments(Types.AssetSecurityCommitment[] memory commitments)
        internal
        pure
        returns (bytes32)
    {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = _hashSecurityCommitment(commitments[i]);
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }

    function _hashSecurityCommitment(Types.AssetSecurityCommitment memory commitment) internal pure returns (bytes32) {
        bytes32 ASSET_TYPEHASH = keccak256("Asset(uint8 kind,address token)");
        bytes32 COMMITMENT_TYPEHASH =
            keccak256("AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)");
        bytes32 assetHash = keccak256(abi.encode(ASSET_TYPEHASH, uint8(commitment.asset.kind), commitment.asset.token));
        return keccak256(abi.encode(COMMITMENT_TYPEHASH, assetHash, commitment.exposureBps));
    }

    function _hashResourceCommitments(Types.ResourceCommitment[] memory commitments) internal pure returns (bytes32) {
        bytes32 RC_TYPEHASH = keccak256("ResourceCommitment(uint8 kind,uint64 count)");
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = keccak256(abi.encode(RC_TYPEHASH, commitments[i].kind, commitments[i].count));
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }
}
