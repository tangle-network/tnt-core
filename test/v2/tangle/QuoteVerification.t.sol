// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { SignatureLib } from "../../../src/v2/libraries/SignatureLib.sol";
import { BlueprintServiceManagerBase } from "../../../src/v2/BlueprintServiceManagerBase.sol";

/// @title QuoteVerificationTest
/// @notice Comprehensive tests for the RFQ signature verification system
contract MockQuoteManager is BlueprintServiceManagerBase {
    bool public paymentAllowed = true;
    bool public requestCalled;
    bool public initCalled;
    address[] private _requestOperators;
    address[] private _initializedCallers;
    bytes public lastRequestConfig;
    uint64 public lastRequestTTL;
    uint256 public lastRequestCost;

    function setPaymentAllowed(bool allowed) external {
        paymentAllowed = allowed;
    }

    function queryIsPaymentAssetAllowed(uint64, address) external view override returns (bool) {
        return paymentAllowed;
    }

    function onRequest(
        uint64,
        address,
        address[] calldata operators,
        bytes calldata config,
        uint64 ttl,
        address,
        uint256 cost
    ) external payable override onlyFromTangle {
        requestCalled = true;
        lastRequestConfig = config;
        lastRequestTTL = ttl;
        lastRequestCost = cost;
        delete _requestOperators;
        for (uint256 i = 0; i < operators.length; i++) {
            _requestOperators.push(operators[i]);
        }
    }

    function onServiceInitialized(
        uint64,
        uint64,
        uint64,
        address,
        address[] calldata permittedCallers,
        uint64
    ) external override onlyFromTangle {
        initCalled = true;
        delete _initializedCallers;
        for (uint256 i = 0; i < permittedCallers.length; i++) {
            _initializedCallers.push(permittedCallers[i]);
        }
    }

    function getRequestOperators() external view returns (address[] memory) {
        return _requestOperators;
    }

    function getInitializedCallers() external view returns (address[] memory) {
        return _initializedCallers;
    }
}

contract QuoteVerificationTest is BaseTest {
    uint256 constant OPERATOR1_PK = 0x1;
    uint256 constant OPERATOR2_PK = 0x2;
    uint256 constant OPERATOR3_PK = 0x3;

    uint64 blueprintId;
    uint64 internal quoteNonce;

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
        blueprintId = _createBlueprintAsSender("ipfs://rfq-test", address(0));

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

    function test_CreateFromQuote_AddsPermittedCallers() public {
        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            100,
            1 ether
        );
        address[] memory extraCallers = new address[](2);
        extraCallers[0] = user2;
        extraCallers[1] = operator2;

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 1 ether }(
            blueprintId,
            quotes,
            bytes("perm"),
            extraCallers,
            100
        );

        assertTrue(tangle.isPermittedCaller(serviceId, user1));
        assertTrue(tangle.isPermittedCaller(serviceId, user2));
        assertTrue(tangle.isPermittedCaller(serviceId, operator2));
        assertFalse(tangle.isPermittedCaller(serviceId, developer));
    }

    function test_CreateFromQuote_UsesCommitmentExposure() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = _createQuoteWithExposure(operator1, OPERATOR1_PK, blueprintId, 100, 1 ether, 2000);
        quotes[1] = _createQuoteWithExposure(operator2, OPERATOR2_PK, blueprintId, 100, 2 ether, 8000);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 3 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            100
        );

        Types.ServiceOperator memory op1Data = tangle.getServiceOperator(serviceId, operator1);
        Types.ServiceOperator memory op2Data = tangle.getServiceOperator(serviceId, operator2);
        assertEq(op1Data.exposureBps, 2000);
        assertEq(op2Data.exposureBps, 8000);
    }

    function testFuzz_CreateFromQuote_ExposurePropagation(uint16 exposureA, uint16 exposureB) public {
        exposureA = uint16(bound(exposureA, 0, 10_000));
        exposureB = uint16(bound(exposureB, 0, 10_000));
        if (exposureA == 0 && exposureB == 0) {
            exposureA = 1;
        }

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = _createQuoteWithExposure(operator1, OPERATOR1_PK, blueprintId, 150, 1 ether, exposureA);
        quotes[1] = _createQuoteWithExposure(operator2, OPERATOR2_PK, blueprintId, 150, 1 ether, exposureB);

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 2 ether }(
            blueprintId,
            quotes,
            "",
            new address[](0),
            150
        );

        Types.ServiceOperator memory op1Data = tangle.getServiceOperator(serviceId, operator1);
        Types.ServiceOperator memory op2Data = tangle.getServiceOperator(serviceId, operator2);
        assertEq(op1Data.exposureBps, exposureA);
        assertEq(op2Data.exposureBps, exposureB);
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

    function test_CreateFromQuote_ManagerHooksCaptureData() public {
        MockQuoteManager manager = new MockQuoteManager();
        vm.prank(developer);
        uint64 managedBlueprintId = _createBlueprintAsSender("ipfs://managed-rfq", address(manager));
        _registerForBlueprint(operator1, managedBlueprintId);

        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            managedBlueprintId,
            200,
            2 ether
        );
        address[] memory permitted = new address[](1);
        permitted[0] = user2;
        bytes memory config = bytes("managed-config");

        vm.prank(user1);
        uint64 serviceId = tangle.createServiceFromQuotes{ value: 2 ether }(
            managedBlueprintId,
            quotes,
            config,
            permitted,
            200
        );

        assertTrue(manager.requestCalled());
        assertTrue(manager.initCalled());
        address[] memory reqOps = manager.getRequestOperators();
        assertEq(reqOps.length, 1);
        assertEq(reqOps[0], operator1);
        assertEq(manager.lastRequestTTL(), 200);
        assertEq(manager.lastRequestCost(), 2 ether);
        assertEq(manager.lastRequestConfig(), config);

        address[] memory initCallers = manager.getInitializedCallers();
        assertEq(initCallers.length, 2);
        assertEq(initCallers[0], user1);
        assertEq(initCallers[1], user2);
        assertTrue(tangle.isServiceActive(serviceId));
    }

    function test_CreateFromQuote_ManagerDisallowsPaymentAsset() public {
        MockQuoteManager manager = new MockQuoteManager();
        manager.setPaymentAllowed(false);
        vm.prank(developer);
        uint64 managedBlueprintId = _createBlueprintAsSender("ipfs://managed-rfq-deny", address(manager));
        _registerForBlueprint(operator1, managedBlueprintId);

        Types.SignedQuote[] memory quotes = _createSingleQuote(
            operator1,
            OPERATOR1_PK,
            managedBlueprintId,
            100,
            1 ether
        );

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.TokenNotAllowed.selector, address(0)));
        tangle.createServiceFromQuotes{ value: 1 ether }(
            managedBlueprintId,
            quotes,
            "",
            new address[](0),
            100
        );
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
    ) internal returns (Types.SignedQuote[] memory) {
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
    ) internal returns (Types.SignedQuote memory) {
        uint64 baseTimestamp = uint64(block.timestamp) + quoteNonce;
        quoteNonce++;
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: bpId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: baseTimestamp,
            expiry: baseTimestamp + 1 hours,
            securityCommitments: new Types.AssetSecurityCommitment[](0)
        });

        bytes memory signature = _signQuote(details, privateKey);

        return Types.SignedQuote({
            details: details,
            signature: signature,
            operator: operator
        });
    }

    function _createQuoteWithExposure(
        address operator,
        uint256 privateKey,
        uint64 bpId,
        uint64 ttl,
        uint256 cost,
        uint16 exposureBps
    ) internal returns (Types.SignedQuote memory) {
        uint64 baseTimestamp = uint64(block.timestamp) + quoteNonce;
        quoteNonce++;
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: bpId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: baseTimestamp,
            expiry: baseTimestamp + 1 hours,
            securityCommitments: new Types.AssetSecurityCommitment[](1)
        });
        details.securityCommitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: exposureBps
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
            "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,AssetSecurityCommitment[] securityCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)"
        );
        bytes32 commitmentsHash = _hashSecurityCommitments(details.securityCommitments);

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
            details.expiry,
            commitmentsHash
        ));

        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            domainSeparator,
            structHash
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return abi.encodePacked(r, s, v);
    }

    function _hashSecurityCommitments(
        Types.AssetSecurityCommitment[] memory commitments
    ) internal pure returns (bytes32) {
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

    function _hashSecurityCommitment(
        Types.AssetSecurityCommitment memory commitment
    ) internal pure returns (bytes32) {
        bytes32 ASSET_TYPEHASH = keccak256("Asset(uint8 kind,address token)");
        bytes32 COMMITMENT_TYPEHASH = keccak256(
            "AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)"
        );
        bytes32 assetHash = keccak256(
            abi.encode(ASSET_TYPEHASH, uint8(commitment.asset.kind), commitment.asset.token)
        );
        return keccak256(abi.encode(COMMITMENT_TYPEHASH, assetHash, commitment.exposureBps));
    }
}
