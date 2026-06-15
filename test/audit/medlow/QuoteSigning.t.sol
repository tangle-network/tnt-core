// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { Tangle } from "../../../src/Tangle.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { Errors } from "../../../src/libraries/Errors.sol";
import { SignatureLib } from "../../../src/libraries/SignatureLib.sol";
import { ProtocolConfig } from "../../../src/config/ProtocolConfig.sol";
import { TangleJobsRFQFacet } from "../../../src/facets/tangle/TangleJobsRFQFacet.sol";

/// @title QuoteSigningTest
/// @notice Regression tests for the quote-signing audit unit. Each test asserts the SECURE
///         invariant introduced by the fix; reverting the corresponding production change makes
///         the test fail.
///
/// Findings covered (deduplicated to their root cause):
///  - EIP-712 non-canonical referenced-type ordering in QUOTE_TYPEHASH (3x medium + 3x low)
///  - Quote-path exposureBps never clamped to BPS_DENOMINATOR (2x medium)
///  - createServiceFromQuotes bypasses min/max operator quorum bounds (1x medium)
///  - QuoteDetails lacks create-vs-extend discriminator (2x medium + 2x low)
///  - RFQ job quote omits job inputs from signed digest (3x medium)
contract QuoteSigningTest is BaseTest {
    uint256 constant OPERATOR1_PK = 0x1;
    uint256 constant OPERATOR2_PK = 0x2;
    uint256 constant OPERATOR3_PK = 0x3;

    uint16 constant BPS = 10_000;

    uint64 internal blueprintId;
    uint64 internal quoteNonce;

    function setUp() public override {
        super.setUp();

        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);
        operator3 = vm.addr(OPERATOR3_PK);

        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(operator3, 100 ether);

        // The per-job RFQ facet is not in the default BaseTest wiring.
        vm.startPrank(admin);
        Tangle(payable(address(tangleProxy))).registerFacet(address(new TangleJobsRFQFacet()));
        vm.stopPrank();

        vm.prank(developer);
        blueprintId = _createBlueprintAsSender("ipfs://quote-signing", address(0));

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EIP-712 CANONICAL TYPE ORDERING (QUOTE_TYPEHASH)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The on-chain QUOTE_TYPEHASH must use EIP-712 canonical (alphabetical-by-name)
    ///         ordering of referenced struct types: Asset < AssetSecurityCommitment <
    ///         ResourceCommitment. A standards-compliant signer reproduces exactly this typehash.
    function test_QuoteTypehash_IsCanonicallyOrdered() public pure {
        bytes32 canonical = keccak256(
            "QuoteDetails(address requester,uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,uint8 confidentiality,uint8 operation,uint64 serviceId,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)Asset(uint8 kind,address token)AssetSecurityCommitment(Asset asset,uint16 exposureBps)ResourceCommitment(uint8 kind,uint64 count)"
        );
        assertEq(SignatureLib.QUOTE_TYPEHASH, canonical, "QUOTE_TYPEHASH must be canonically ordered");

        // The old, non-canonical ordering (AssetSecurityCommitment before Asset) must NOT match.
        bytes32 nonCanonical = keccak256(
            "QuoteDetails(address requester,uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,uint8 confidentiality,uint8 operation,uint64 serviceId,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)ResourceCommitment(uint8 kind,uint64 count)"
        );
        assertTrue(SignatureLib.QUOTE_TYPEHASH != nonCanonical, "must reject non-canonical type ordering");
    }

    /// @notice A quote signed off-chain with the canonical typehash and a non-empty security
    ///         commitment is accepted end-to-end (proves the on-chain hash matches the standard signer).
    function test_CanonicalSigner_QuoteAccepted() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quoteWithExposure(operator1, OPERATOR1_PK, 100, 1 ether, 2000);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);

        assertTrue(tangle.isServiceActive(serviceId));
        assertEq(tangle.getServiceOperator(serviceId, operator1).exposureBps, 2000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE BPS CLAMP
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice An operator-signed exposureBps above 100% (BPS_DENOMINATOR) must revert; the
    ///         unclamped value would otherwise be stored verbatim and over-collect on billing.
    function test_Exposure_AboveDenominator_Reverts() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quoteWithExposure(operator1, OPERATOR1_PK, 100, 1 ether, type(uint16).max); // 65535

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature("QuoteExposureExceedsMax(address,uint16,uint16)", operator1, type(uint16).max, BPS)
        );
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);
    }

    /// @notice exposureBps just over the bound (10001) also reverts.
    function test_Exposure_OneOverBound_Reverts() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quoteWithExposure(operator1, OPERATOR1_PK, 100, 1 ether, BPS + 1);

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature("QuoteExposureExceedsMax(address,uint16,uint16)", operator1, BPS + 1, BPS)
        );
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);
    }

    /// @notice exposureBps exactly at the bound (100%) is the maximum legal value and is stored verbatim.
    function test_Exposure_AtBound_Accepted() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quoteWithExposure(operator1, OPERATOR1_PK, 100, 1 ether, BPS);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);

        assertEq(tangle.getServiceOperator(serviceId, operator1).exposureBps, BPS);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR QUORUM BOUNDS (create-from-quotes)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The quote path must enforce the blueprint's minimum operator quorum, mirroring
    ///         the request/approve path. Too few operators reverts InsufficientOperators.
    function test_Bounds_BelowMinOperators_Reverts() public {
        uint64 bpId = _createBlueprintWithOperatorBounds(2, 0); // minOps = 2

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1); // only 1 operator
        quotes[0] = _quote(operator1, OPERATOR1_PK, bpId, 100, 1 ether);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientOperators.selector, uint32(2), uint32(1)));
        tangle.createServiceFromQuotes{ value: 1 ether }(bpId, quotes, "", new address[](0), 100);
    }

    /// @notice Too many operators (above the blueprint's max) reverts TooManyOperators.
    function test_Bounds_AboveMaxOperators_Reverts() public {
        uint64 bpId = _createBlueprintWithOperatorBounds(1, 1); // maxOps = 1

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2); // 2 operators > max 1
        quotes[0] = _quote(operator1, OPERATOR1_PK, bpId, 100, 1 ether);
        quotes[1] = _quote(operator2, OPERATOR2_PK, bpId, 100, 1 ether);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.TooManyOperators.selector, uint32(1), uint32(2)));
        tangle.createServiceFromQuotes{ value: 2 ether }(bpId, quotes, "", new address[](0), 100);
    }

    /// @notice An operator count within [min, max] is accepted.
    function test_Bounds_WithinRange_Accepted() public {
        uint64 bpId = _createBlueprintWithOperatorBounds(2, 3); // [2, 3]

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = _quote(operator1, OPERATOR1_PK, bpId, 100, 1 ether);
        quotes[1] = _quote(operator2, OPERATOR2_PK, bpId, 100, 1 ether);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 2 ether }(bpId, quotes, "", new address[](0), 100);
        assertTrue(tangle.isServiceActive(serviceId));
        assertEq(tangle.getService(serviceId).operatorCount, 2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CREATE vs EXTEND DISCRIMINATOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice A quote signed for the Extend flow cannot be redeemed via createServiceFromQuotes.
    ///         Without the operation/serviceId binding, a cheap extension quote would create a
    ///         full new service.
    function test_Discriminator_ExtendQuote_RejectedOnCreate() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        // Sign as Extend / serviceId = 7, but submit to the create path (expects Create / 0).
        quotes[0] =
            _quoteFull(operator1, OPERATOR1_PK, blueprintId, 100, 1 ether, Types.QuoteOperation.Extend, 7, BPS, false);

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "QuoteOperationMismatch(address,uint8,uint8,uint64,uint64)",
                operator1,
                uint8(Types.QuoteOperation.Create),
                uint8(Types.QuoteOperation.Extend),
                uint64(0),
                uint64(7)
            )
        );
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 100);
    }

    /// @notice A quote signed for the Create flow cannot be redeemed via extendServiceFromQuotes.
    function test_Discriminator_CreateQuote_RejectedOnExtend() public {
        // Stand up a live service via legitimate Create quotes.
        uint64 serviceId = _createServiceWithTtl(blueprintId, 30 days, 1 ether);

        // Now attempt to extend it with a Create-flavored quote.
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quoteFull(
            operator1, OPERATOR1_PK, blueprintId, 15 days, 0.5 ether, Types.QuoteOperation.Create, 0, BPS, false
        );

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "QuoteOperationMismatch(address,uint8,uint8,uint64,uint64)",
                operator1,
                uint8(Types.QuoteOperation.Extend),
                uint8(Types.QuoteOperation.Create),
                serviceId,
                uint64(0)
            )
        );
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, 15 days);
    }

    /// @notice An Extend quote signed for a different serviceId is rejected on the extend path.
    function test_Discriminator_ExtendQuote_WrongServiceId_Rejected() public {
        uint64 serviceId = _createServiceWithTtl(blueprintId, 30 days, 1 ether);
        uint64 wrongServiceId = serviceId + 99;

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quoteFull(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            15 days,
            0.5 ether,
            Types.QuoteOperation.Extend,
            wrongServiceId,
            BPS,
            false
        );

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "QuoteOperationMismatch(address,uint8,uint8,uint64,uint64)",
                operator1,
                uint8(Types.QuoteOperation.Extend),
                uint8(Types.QuoteOperation.Extend),
                serviceId,
                wrongServiceId
            )
        );
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, 15 days);
    }

    /// @notice A correctly-discriminated Extend quote (operation=Extend, matching serviceId) is accepted.
    function test_Discriminator_ExtendQuote_HappyPath() public {
        uint64 serviceId = _createServiceWithTtl(blueprintId, 30 days, 1 ether);
        Types.Service memory before = tangle.getService(serviceId);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quoteFull(
            operator1,
            OPERATOR1_PK,
            blueprintId,
            15 days,
            0.5 ether,
            Types.QuoteOperation.Extend,
            serviceId,
            BPS,
            false
        );

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 0.5 ether }(serviceId, quotes, 15 days);

        assertGt(tangle.getService(serviceId).ttl, before.ttl, "TTL should grow on a valid extend");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB QUOTE: PRICE BOUND TO INPUTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice submitJobFromQuote must reject a quote whose signed inputsHash does not match the
    ///         submitted inputs. Otherwise a cheap quote could be redeemed for arbitrary work.
    function test_JobQuote_InputsMismatch_Reverts() public {
        uint64 serviceId = _createServiceWithTtl(blueprintId, 30 days, 1 ether);

        bytes memory signedInputs = abi.encode(uint256(1)); // operator priced THIS
        bytes memory submittedInputs = abi.encode(uint256(999)); // caller submits THIS

        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _jobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether, signedInputs);

        bytes32 expectedHash = keccak256(submittedInputs);
        bytes32 quotedHash = keccak256(signedInputs);

        vm.prank(user1);
        vm.expectRevert(
            abi.encodeWithSignature(
                "JobQuoteInputsMismatch(address,bytes32,bytes32)", operator1, expectedHash, quotedHash
            )
        );
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, submittedInputs, quotes);
    }

    /// @notice A job quote whose inputsHash matches the submitted inputs is accepted.
    function test_JobQuote_MatchingInputs_Accepted() public {
        uint64 serviceId = _createServiceWithTtl(blueprintId, 30 days, 1 ether);

        bytes memory jobInputs = abi.encode(uint256(42));
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _jobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether, jobInputs);

        vm.prank(user1);
        uint64 callId = tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, jobInputs, quotes);

        Types.JobCall memory job = tangle.getJobCall(serviceId, callId);
        assertEq(job.payment, 1 ether);
        assertTrue(job.isRFQ);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS — blueprint setup
    // ═══════════════════════════════════════════════════════════════════════════

    function _createBlueprintWithOperatorBounds(uint32 minOps, uint32 maxOps) internal returns (uint64 bpId) {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: minOps,
            maxOperators: maxOps,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        bpId = _createBlueprintWithConfig(developer, "ipfs://bounded", address(0), config);
        _registerForBlueprint(operator1, bpId);
        _registerForBlueprint(operator2, bpId);
        _registerForBlueprint(operator3, bpId);
    }

    function _createServiceWithTtl(uint64 bpId, uint64 ttl, uint256 cost) internal returns (uint64 serviceId) {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = _quote(operator1, OPERATOR1_PK, bpId, ttl, cost);
        // Permit the operator-signing requester (user1) plus user1 again; default permits owner.
        vm.prank(user1);
        serviceId = tangle.createServiceFromQuotes{ value: cost }(bpId, quotes, "", new address[](0), ttl);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS — quote construction & EIP-712 signing
    // ═══════════════════════════════════════════════════════════════════════════

    function _quote(
        address operator,
        uint256 pk,
        uint64 bpId,
        uint64 ttl,
        uint256 cost
    )
        internal
        returns (Types.SignedQuote memory)
    {
        return _quoteFull(operator, pk, bpId, ttl, cost, Types.QuoteOperation.Create, 0, BPS, false);
    }

    function _quoteWithExposure(
        address operator,
        uint256 pk,
        uint64 ttl,
        uint256 cost,
        uint16 exposureBps
    )
        internal
        returns (Types.SignedQuote memory)
    {
        return _quoteFull(operator, pk, blueprintId, ttl, cost, Types.QuoteOperation.Create, 0, exposureBps, true);
    }

    function _quoteFull(
        address operator,
        uint256 pk,
        uint64 bpId,
        uint64 ttl,
        uint256 cost,
        Types.QuoteOperation operation,
        uint64 serviceId,
        uint16 exposureBps,
        bool withCommitment
    )
        internal
        returns (Types.SignedQuote memory)
    {
        uint64 baseTimestamp = uint64(block.timestamp) + quoteNonce;
        quoteNonce++;

        Types.AssetSecurityCommitment[] memory commitments;
        if (withCommitment) {
            commitments = new Types.AssetSecurityCommitment[](1);
            commitments[0] = Types.AssetSecurityCommitment({
                asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
                exposureBps: exposureBps
            });
        } else {
            commitments = new Types.AssetSecurityCommitment[](0);
        }

        Types.QuoteDetails memory details = Types.QuoteDetails({
            requester: user1,
            blueprintId: bpId,
            ttlBlocks: ttl,
            totalCost: cost,
            timestamp: baseTimestamp,
            expiry: baseTimestamp + 1 hours,
            confidentiality: Types.ConfidentialityPolicy.Any,
            operation: operation,
            serviceId: serviceId,
            securityCommitments: commitments,
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes memory signature = _signQuote(details, pk);
        return Types.SignedQuote({ details: details, signature: signature, operator: operator });
    }

    function _signQuote(Types.QuoteDetails memory details, uint256 pk) internal view returns (bytes memory) {
        bytes32 commitmentsHash = _hashSecurityCommitments(details.securityCommitments);
        bytes32 resourcesHash = _hashResourceCommitments(details.resourceCommitments);

        bytes32 structHash = keccak256(
            abi.encode(
                SignatureLib.QUOTE_TYPEHASH,
                details.requester,
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                details.confidentiality,
                details.operation,
                details.serviceId,
                commitmentsHash,
                resourcesHash
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function _jobQuote(
        address operator,
        uint256 pk,
        uint64 serviceId,
        uint8 jobIndex,
        uint256 price,
        bytes memory inputs
    )
        internal
        returns (Types.SignedJobQuote memory)
    {
        uint64 baseTimestamp = uint64(block.timestamp) + quoteNonce;
        quoteNonce++;

        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            requester: user1,
            serviceId: serviceId,
            jobIndex: jobIndex,
            price: price,
            timestamp: baseTimestamp,
            expiry: baseTimestamp + 1 hours,
            confidentiality: 0,
            inputsHash: keccak256(inputs)
        });

        bytes memory signature = _signJobQuote(details, pk);
        return Types.SignedJobQuote({ details: details, signature: signature, operator: operator });
    }

    function _signJobQuote(Types.JobQuoteDetails memory details, uint256 pk) internal view returns (bytes memory) {
        bytes32 structHash = keccak256(
            abi.encode(
                SignatureLib.JOB_QUOTE_TYPEHASH,
                details.requester,
                details.serviceId,
                details.jobIndex,
                details.price,
                details.timestamp,
                details.expiry,
                details.confidentiality,
                details.inputsHash
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", _domainSeparator(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function _domainSeparator() internal view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("TangleQuote"),
                keccak256("1"),
                block.chainid,
                address(tangle)
            )
        );
    }

    function _hashSecurityCommitments(Types.AssetSecurityCommitment[] memory commitments)
        internal
        pure
        returns (bytes32)
    {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            bytes32 assetHash = keccak256(
                abi.encode(
                    keccak256("Asset(uint8 kind,address token)"),
                    uint8(commitments[i].asset.kind),
                    commitments[i].asset.token
                )
            );
            hashes[i] = keccak256(
                abi.encode(
                    keccak256("AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)"),
                    assetHash,
                    commitments[i].exposureBps
                )
            );
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }

    function _hashResourceCommitments(Types.ResourceCommitment[] memory commitments) internal pure returns (bytes32) {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = keccak256(
                abi.encode(
                    keccak256("ResourceCommitment(uint8 kind,uint64 count)"), commitments[i].kind, commitments[i].count
                )
            );
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }
}
