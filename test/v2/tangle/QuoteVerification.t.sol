// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { SignatureLib } from "../../../src/v2/libraries/SignatureLib.sol";

/// @title QuoteVerificationTest
/// @notice Comprehensive tests for the RFQ signature verification system
contract QuoteVerificationTest is BaseTest {
    uint256 constant OPERATOR1_PK = 0x1;
    uint256 constant OPERATOR2_PK = 0x2;
    uint256 constant OPERATOR3_PK = 0x3;

    uint64 blueprintId;

    function setUp() public override {
        super.setUp();

        // Override operator addresses with deterministic keys
        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);
        operator3 = vm.addr(OPERATOR3_PK);

        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(operator3, 100 ether);

        // Setup blueprint
        vm.prank(developer);
        blueprintId = tangle.createBlueprint("ipfs://rfq-test", address(0));

        // Register operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SINGLE OPERATOR QUOTES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateFromQuote_SingleOperator() public {
        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            100, // ttl
            1 ether // cost
        );

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );

        assertTrue(tangle.isServiceActive(serviceId));
        assertTrue(tangle.isServiceOperator(serviceId, operator1));
        assertEq(tangle.getService(serviceId).owner, user1);
    }

    function test_CreateFromQuote_RevertInvalidSignature() public {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: 100,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        // Sign with wrong key
        bytes memory wrongSignature = _signQuote(details, OPERATOR2_PK);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: wrongSignature,
            operator: operator1 // Wrong operator for this signature
        });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidQuoteSignature.selector, operator1));
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    function test_CreateFromQuote_RevertExpiredQuote() public {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: 100,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp - 1), // Already expired
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes memory signature = _signQuote(details, OPERATOR1_PK);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: signature,
            operator: operator1
        });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteExpired.selector, operator1, details.expiry));
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    function test_CreateFromQuote_RevertBlueprintMismatch() public {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: 999, // Wrong blueprint
            ttlBlocks: 100,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes memory signature = _signQuote(details, OPERATOR1_PK);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: signature,
            operator: operator1
        });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteBlueprintMismatch.selector, operator1, blueprintId, 999));
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    function test_CreateFromQuote_RevertTTLMismatch() public {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: 50, // Different TTL
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes memory signature = _signQuote(details, OPERATOR1_PK);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: signature,
            operator: operator1
        });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteTTLMismatch.selector, operator1, 100, 50));
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTIPLE OPERATOR QUOTES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateFromQuote_MultipleOperators() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](3);
        quotes[0] = _createQuote(operator1, OPERATOR1_PK, blueprintId, 100, 1 ether);
        quotes[1] = _createQuote(operator2, OPERATOR2_PK, blueprintId, 100, 2 ether);
        quotes[2] = _createQuote(operator3, OPERATOR3_PK, blueprintId, 100, 1.5 ether);

        uint256 totalCost = 4.5 ether;

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: totalCost }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );

        assertTrue(tangle.isServiceActive(serviceId));
        assertTrue(tangle.isServiceOperator(serviceId, operator1));
        assertTrue(tangle.isServiceOperator(serviceId, operator2));
        assertTrue(tangle.isServiceOperator(serviceId, operator3));
        assertEq(tangle.getService(serviceId).operatorCount, 3);
    }

    function test_CreateFromQuote_RevertDuplicateOperator() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = _createQuote(operator1, OPERATOR1_PK, blueprintId, 100, 1 ether);
        quotes[1] = _createQuote(operator1, OPERATOR1_PK, blueprintId, 100, 1 ether); // Same operator

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.DuplicateOperatorQuote.selector, operator1));
        tangle.createServiceFromQuotes{ value: 2 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    function test_CreateFromQuote_RevertNoQuotes() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](0);

        vm.prank(user1);
        vm.expectRevert(Errors.NoQuotes.selector);
        tangle.createServiceFromQuotes(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT HANDLING
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateFromQuote_RevertInsufficientPayment() public {
        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            100,
            2 ether // Costs 2 ETH
        );

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientPaymentForQuotes.selector, 2 ether, 1 ether));
        tangle.createServiceFromQuotes{ value: 1 ether }( // Only sending 1 ETH
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    function test_CreateFromQuote_RefundsExcessPayment() public {
        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            100,
            1 ether
        );

        uint256 userBalanceBefore = user1.balance;

        vm.prank(user1);
        tangle.createServiceFromQuotes{ value: 5 ether }( // Overpaying
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );

        // Should have been refunded 4 ETH
        assertEq(user1.balance, userBalanceBefore - 1 ether);
    }

    function test_CreateFromQuote_ZeroCost() public {
        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            100,
            0 // Free!
        );

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );

        assertTrue(tangle.isServiceActive(serviceId));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REPLAY PROTECTION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateFromQuote_RevertReplayAttack() public {
        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            100,
            1 ether
        );

        // First use succeeds
        vm.prank(user1);
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );

        // Replay attack fails
        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSelector(Errors.QuoteAlreadyUsed.selector, operator1));
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateFromQuote_RevertOperatorNotRegistered() public {
        address unregisteredOp = makeAddr("unregistered");
        uint256 unregisteredPk = 0x999;

        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: 100,
            totalCost: 1 ether,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes memory signature = _signQuoteWithKey(details, unregisteredPk);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({
            details: details,
            signature: signature,
            operator: vm.addr(unregisteredPk)
        });

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorNotRegistered.selector, blueprintId, vm.addr(unregisteredPk)));
        tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PERMITTED CALLERS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CreateFromQuote_WithPermittedCallers() public {
        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            100,
            1 ether
        );

        address[] memory callers = new address[](2);
        callers[0] = makeAddr("caller1");
        callers[1] = makeAddr("caller2");

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            "",
            callers,
            100
        );

        assertTrue(tangle.isPermittedCaller(serviceId, user1)); // Owner always permitted
        assertTrue(tangle.isPermittedCaller(serviceId, callers[0]));
        assertTrue(tangle.isPermittedCaller(serviceId, callers[1]));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _createSingleQuote(
        address operator,
        uint256 privateKey,
        uint64 bpId,
        uint64 ttl,
        uint256 cost
    ) internal view returns (Types.SignedQuote[] memory) {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _createQuote(operator, privateKey, bpId, ttl, cost);
        return quotes;
    }

    function _createQuote(
        address operator,
        uint256 privateKey,
        uint64 bpId,
        uint64 ttl,
        uint256 cost
    ) internal view returns (Types.SignedQuote memory) {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: bpId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes memory signature = _signQuote(details, privateKey);

        return Types.SignedQuote({
            details: details,
            signature: signature,
            operator: operator
        });
    }

    function _signQuote(
        Types.QuoteDetails memory details,
        uint256 privateKey
    ) internal view returns (bytes memory) {
        return _signQuoteWithKey(details, privateKey);
    }

    function _signQuoteWithKey(
        Types.QuoteDetails memory details,
        uint256 privateKey
    ) internal view returns (bytes memory) {
        bytes32 QUOTE_TYPEHASH = keccak256(
            "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry)"
        );

        bytes32 domainSeparator = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256("TangleQuote"),
            keccak256("1"),
            block.chainid,
            address(tangle)
        ));

        bytes32 structHash = keccak256(abi.encode(
            QUOTE_TYPEHASH,
            details.blueprintId,
            details.ttlBlocks,
            details.totalCost,
            details.timestamp,
            details.expiry
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator,
            structHash
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return abi.encodePacked(r, s, v);
    }
}
