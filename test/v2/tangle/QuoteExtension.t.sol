// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";

/// @title QuoteExtensionTest
/// @notice Tests for service TTL extension via quotes
contract QuoteExtensionTest is BaseTest {
    // Use actual private keys for signature testing
    uint256 public operator1Key = 0xA11CE;
    uint256 public operator2Key = 0xB0B;

    uint64 public blueprintId;
    uint64 public serviceId;

    uint64 constant INITIAL_TTL = 30 days;

    function setUp() public override {
        // Override operator addresses with key-derived addresses
        operator1 = vm.addr(operator1Key);
        operator2 = vm.addr(operator2Key);

        super.setUp();

        // Setup operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);

        // Setup blueprint
        blueprintId = _createBlueprint(developer);

        // Register operators for blueprint
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);

        // Create initial service using quotes
        serviceId = _createInitialService();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BASIC EXTENSION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExtendService_ValidQuotes() public {
        uint64 additionalTtl = 15 days;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        // Use different costs to make quotes unique
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);
        quotes[1] = _createExtensionQuote(operator2Key, operator2, 0.6 ether, additionalTtl);

        Types.Service memory svcBefore = tangle.getService(serviceId);
        uint64 oldTtl = svcBefore.ttl;

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 1.1 ether }(serviceId, quotes, additionalTtl);

        Types.Service memory svcAfter = tangle.getService(serviceId);

        // TTL should have increased
        assertGt(svcAfter.ttl, oldTtl, "TTL should increase");
    }

    function test_ExtendService_OnlyOwner() public {
        uint64 additionalTtl = 15 days;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);

        vm.prank(user2); // Not owner
        vm.expectRevert(Errors.Unauthorized.selector);
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);
    }

    function test_ExtendService_InsufficientPayment() public {
        uint64 additionalTtl = 15 days;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 1 ether, additionalTtl);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientPaymentForQuotes.selector, 1 ether, 0.5 ether));
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);
    }

    function test_ExtendService_ExcessPaymentRefunded() public {
        uint64 additionalTtl = 15 days;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 1 ether, additionalTtl);

        uint256 balBefore = user1.balance;

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 2 ether }(serviceId, quotes, additionalTtl);

        // User should get 1 ether back
        assertEq(user1.balance, balBefore - 1 ether, "Excess should be refunded");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExtendService_RequiresCurrentOperators() public {
        uint64 additionalTtl = 15 days;

        // Setup operator3 but NOT as part of the service
        uint256 operator3Key = 0xC0DE;
        address op3 = vm.addr(operator3Key);
        vm.deal(op3, 10 ether);
        _registerOperator(op3, 5 ether);
        _registerForBlueprint(op3, blueprintId);

        // Try to extend with operator3 (not in service)
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuoteForOperator(operator3Key, op3, 0.5 ether, additionalTtl);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotInService.selector, serviceId, op3));
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);
    }

    function test_ExtendService_SubsetOfOperators() public {
        // Extension only needs quotes from current operators, not all of them
        uint64 additionalTtl = 15 days;

        // Only get quote from operator1 (operator2 is also in service but not extending)
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);

        Types.Service memory svcBefore = tangle.getService(serviceId);

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);

        Types.Service memory svcAfter = tangle.getService(serviceId);
        assertGt(svcAfter.ttl, svcBefore.ttl, "Should extend with subset of operators");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE STATE VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExtendService_RevertsForZeroTTLService() public {
        // Create a service without TTL
        uint64 noTtlServiceId = _createServiceWithoutTTL();

        uint64 additionalTtl = 15 days;
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);

        vm.prank(user1);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(noTtlServiceId, quotes, additionalTtl);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUOTE SIGNATURE VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExtendService_ExpiredQuote_Reverts() public {
        uint64 additionalTtl = 15 days;

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: additionalTtl,
            totalCost: 0.5 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp - 1), // Expired
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(operator1Key, digest);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            operator: operator1,
            details: details,
            signature: abi.encodePacked(r, s, v)
        });

        vm.prank(user1);
        vm.expectRevert(); // Quote expired
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);
    }

    function test_ExtendService_DuplicateQuotes_Reverts() public {
        uint64 additionalTtl = 15 days;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        // Same operator twice
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);
        quotes[1] = _createSignedQuoteWithDifferentExpiry(operator1Key, operator1, 0.5 ether, additionalTtl);

        vm.prank(user1);
        vm.expectRevert(); // Duplicate operator
        tangle.extendServiceFromQuotes{ value: 1 ether }(serviceId, quotes, additionalTtl);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TTL CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExtendService_TTLCalculation_BeforeExpiry() public {
        uint64 additionalTtl = 15 days;

        Types.Service memory svcBefore = tangle.getService(serviceId);
        uint64 currentEnd = svcBefore.createdAt + svcBefore.ttl;

        // Extend before current TTL expires
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);

        Types.Service memory svcAfter = tangle.getService(serviceId);
        uint64 newEnd = svcAfter.createdAt + svcAfter.ttl;

        // New end should be current end + additionalTtl
        assertEq(newEnd, currentEnd + additionalTtl, "Should extend from current end time");
    }

    function test_ExtendService_TTLCalculation_AfterExpiry() public {
        // Warp past the service expiry
        Types.Service memory svc = tangle.getService(serviceId);
        vm.warp(svc.createdAt + svc.ttl + 1 days);

        uint64 additionalTtl = 15 days;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);

        Types.Service memory svcAfter = tangle.getService(serviceId);
        uint64 newEnd = svcAfter.createdAt + svcAfter.ttl;

        // Extension should start from now since we're past expiry
        assertGe(newEnd, block.timestamp + additionalTtl - 1, "Should extend from current time if expired");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENT EMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExtendService_EmitsEvent() public {
        uint64 additionalTtl = 15 days;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createExtensionQuote(operator1Key, operator1, 0.5 ether, additionalTtl);

        Types.Service memory svcBefore = tangle.getService(serviceId);

        vm.prank(user1);
        vm.expectEmit(true, false, false, false);
        emit ServiceExtended(serviceId, svcBefore.ttl, 0, 0.5 ether); // oldTtl, newTtl (any), payment

        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, additionalTtl);
    }

    event ServiceExtended(uint64 indexed serviceId, uint64 oldTtl, uint64 newTtl, uint256 payment);

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _createInitialService() internal returns (uint64) {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        // Use different costs to make quote hashes unique
        quotes[0] = _createSignedQuote(operator1Key, operator1, 1 ether, uint64(block.timestamp + 1 hours), INITIAL_TTL);
        quotes[1] = _createSignedQuote(operator2Key, operator2, 1.1 ether, uint64(block.timestamp + 1 hours), INITIAL_TTL);

        address[] memory callers = new address[](0);

        vm.prank(user1);
        return tangle.createServiceFromQuotes{ value: 2.1 ether }(
            blueprintId,
            quotes,
            "",
            callers,
            INITIAL_TTL
        );
    }

    function _createServiceWithoutTTL() internal returns (uint64) {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createSignedQuote(operator1Key, operator1, 0, uint64(block.timestamp + 1 hours), 0);

        address[] memory callers = new address[](0);

        vm.prank(user1);
        return tangle.createServiceFromQuotes(
            blueprintId,
            quotes,
            "",
            callers,
            0
        );
    }

    function _createExtensionQuote(
        uint256 privateKey,
        address operator,
        uint256 totalCost,
        uint64 additionalTtl
    ) internal view returns (Types.SignedQuote memory) {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: additionalTtl,
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return Types.SignedQuote({
            operator: operator,
            details: details,
            signature: abi.encodePacked(r, s, v)
        });
    }

    function _createSignedQuoteForOperator(
        uint256 privateKey,
        address operator,
        uint256 totalCost,
        uint64 ttl
    ) internal view returns (Types.SignedQuote memory) {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return Types.SignedQuote({
            operator: operator,
            details: details,
            signature: abi.encodePacked(r, s, v)
        });
    }

    function _createSignedQuoteWithDifferentExpiry(
        uint256 privateKey,
        address operator,
        uint256 totalCost,
        uint64 ttl
    ) internal view returns (Types.SignedQuote memory) {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 2 hours), // Different expiry
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return Types.SignedQuote({
            operator: operator,
            details: details,
            signature: abi.encodePacked(r, s, v)
        });
    }

    function _createSignedQuote(
        uint256 privateKey,
        address operator,
        uint256 totalCost,
        uint64 expiry,
        uint64 ttl
    ) internal view returns (Types.SignedQuote memory) {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: expiry,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes32 digest = _computeQuoteDigest(details);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return Types.SignedQuote({
            operator: operator,
            details: details,
            signature: abi.encodePacked(r, s, v)
        });
    }

    function _computeQuoteDigest(Types.QuoteDetails memory details) internal view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(
            keccak256("QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry)"),
            details.blueprintId,
            details.ttlBlocks,
            details.totalCost,
            details.timestamp,
            details.expiry
        ));

        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("TangleQuote"),
            keccak256("1"),
            block.chainid,
            address(tangle)
        ));

        return MessageHashUtils.toTypedDataHash(domainSeparator, structHash);
    }
}
