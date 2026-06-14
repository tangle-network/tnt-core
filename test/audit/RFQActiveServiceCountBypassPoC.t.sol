// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";

/// @title RFQActiveServiceCountBypassPoC
/// @notice Regression guard for finding sub-5-deep-audit-a0505ef9-d36 (now FIXED).
///
///         The RFQ/quote creation path createServiceFromQuotes -> _activateQuoteService
///         -> _processOperatorQuotes (QuotesCreate.sol) registers operators as live, paid
///         security providers (active=true, added to _serviceOperatorSet). Previously it
///         FAILED to increment _operatorActiveServiceCount[blueprintId][op], while the
///         standard request/approve activation path DID.
///
///         _operatorActiveServiceCount is the sole active-service guard on
///         unregisterOperator (Operators.sol) and on getOperatorTotalActiveServices
///         (the staking startLeaving() guard). When it stayed 0 on the RFQ path, an
///         operator backing a live RFQ service could unregister from the blueprint while
///         the service was still Active.
///
///         INVARIANT (post-fix): RFQ activation increments the active-service counter
///         exactly like the standard path, so the unregisterOperator guard correctly
///         reverts while the service is Active. This test reads the counter directly from
///         storage (slot 65, confirmed via `forge inspect`) to assert it is 1 on the RFQ
///         path, and exercises the real unregisterOperator guard to assert it reverts on
///         both the RFQ and standard paths. It will fail again if the RFQ path ever stops
///         tracking active services (i.e. the vuln is reintroduced).
contract RFQActiveServiceCountBypassPoC is BaseTest {
    // Operator whose private key we control so it can sign RFQ quotes.
    uint256 internal constant RFQ_OPERATOR_PK = 0xA11CE;
    address internal rfqOperator;

    // Storage slot of `_operatorActiveServiceCount` on the Tangle proxy (forge inspect).
    uint256 internal constant ACTIVE_SVC_COUNT_SLOT = 65;

    bytes32 private constant QUOTE_TYPEHASH = keccak256(
        "QuoteDetails(address requester,uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,uint8 confidentiality,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)ResourceCommitment(uint8 kind,uint64 count)"
    );

    function setUp() public override {
        super.setUp();
        rfqOperator = vm.addr(RFQ_OPERATOR_PK);
        vm.deal(rfqOperator, 100 ether);
        _registerOperator(rfqOperator); // stakes MIN_OPERATOR_STAKE, staking-Active
        vm.deal(user1, 100 ether);
    }

    /// @dev Reads _operatorActiveServiceCount[blueprintId][operator] from the proxy.
    ///      slot = keccak256(operator, keccak256(blueprintId, ACTIVE_SVC_COUNT_SLOT))
    function _readActiveServiceCount(uint64 blueprintId, address operator) internal view returns (uint256) {
        bytes32 inner = keccak256(abi.encode(uint256(blueprintId), ACTIVE_SVC_COUNT_SLOT));
        bytes32 slot = keccak256(abi.encode(operator, inner));
        return uint256(vm.load(address(tangle), slot));
    }

    /// @notice FIXED: RFQ activation increments the active-service counter, so the
    ///         unregisterOperator guard correctly blocks the operator while the service
    ///         is Active — identical to the standard request/approve path.
    function test_RFQ_path_increments_active_service_count_and_blocks_unregister() public {
        // --- SETUP: create an Active RFQ service backed by rfqOperator ---
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://rfq-bypass", address(0));
        _registerForBlueprint(rfqOperator, blueprintId);

        Types.SignedQuote[] memory quotes = _createSignedQuote(blueprintId, 1 ether, 120);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 120);

        // Service is genuinely live and the operator is a paid member of it.
        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(uint8(svc.status), uint8(Types.ServiceStatus.Active), "RFQ service must be Active");

        // --- INVARIANT: _processOperatorQuotes now increments the counter, mirroring
        //     the standard path. A reintroduced bug would leave this at 0 and fail here. ---
        uint256 cnt = _readActiveServiceCount(blueprintId, rfqOperator);
        emit log_named_uint("RFQ path: _operatorActiveServiceCount (while service Active)", cnt);
        assertEq(cnt, 1, "FIX: RFQ activation MUST increment the active-service counter");

        // --- GUARD BITES: unregisterOperator's active-service guard (Operators.sol)
        //     reads the counter from storage; with cnt==1 it correctly reverts. ---
        vm.prank(rfqOperator);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorHasActiveServices.selector, blueprintId, rfqOperator));
        tangle.unregisterOperator(blueprintId);

        // The security provider remains bound to its live service: still Active, with
        // the operator unable to walk away mid-service.
        svc = tangle.getService(serviceId);
        assertEq(
            uint8(svc.status),
            uint8(Types.ServiceStatus.Active),
            "Service remains Active and its operator stays bound"
        );

        emit log_string("GUARDED: RFQ operator is blocked from unregistering while service is Active");
    }

    /// @notice CONTROL: the standard request/approve path increments the counter, so
    ///         the identical unregisterOperator guard correctly blocks the operator.
    function test_standard_path_increments_count_and_blocks_unregister() public {
        _registerOperator(operator2);

        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://standard-path", address(0));
        _registerForBlueprint(operator2, blueprintId);

        // Standard path: request + approve -> _activateService increments the counter.
        uint64 requestId = _requestService(user1, blueprintId, operator2);
        _approveService(operator2, requestId);

        uint256 cnt = _readActiveServiceCount(blueprintId, operator2);
        emit log_named_uint("standard path: _operatorActiveServiceCount", cnt);
        assertEq(cnt, 1, "standard path MUST increment the active-service counter");

        // The guard now bites: unregisterOperator reverts.
        vm.prank(operator2);
        vm.expectRevert(abi.encodeWithSelector(Errors.OperatorHasActiveServices.selector, blueprintId, operator2));
        tangle.unregisterOperator(blueprintId);

        emit log_string("CONTROL: standard-path operator is correctly blocked from unregistering");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Quote signing helpers (mirrors test/tangle/QuotePaymentSplit.t.sol)
    // ─────────────────────────────────────────────────────────────────────────

    function _createSignedQuote(
        uint64 blueprintId,
        uint256 totalCost,
        uint64 ttl
    )
        internal
        view
        returns (Types.SignedQuote[] memory quotes)
    {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            requester: user1,
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            confidentiality: Types.ConfidentialityPolicy.Any,
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes memory signature = _signQuote(details, RFQ_OPERATOR_PK);
        quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({ details: details, signature: signature, operator: rfqOperator });
    }

    function _signQuote(Types.QuoteDetails memory details, uint256 pk) internal view returns (bytes memory) {
        bytes32 commitmentsHash = _hashSecurityCommitments(details.securityCommitments);
        bytes32 resourcesHash = _hashResourceCommitments(details.resourceCommitments);
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("TangleQuote")),
                keccak256(bytes("1")),
                block.chainid,
                address(tangle)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(
                QUOTE_TYPEHASH,
                details.requester,
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                details.confidentiality,
                commitmentsHash,
                resourcesHash
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
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
