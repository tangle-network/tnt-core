// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Types } from "./Types.sol";
import { Errors } from "./Errors.sol";

/// @title SignatureLib
/// @notice Library for EIP-712 signature verification with replay protection
/// @dev Handles quote signatures for RFQ system
library SignatureLib {
    using ECDSA for bytes32;

    // ═══════════════════════════════════════════════════════════════════════════
    // TYPE HASHES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev EIP-712 TypeHash for Asset
    bytes32 internal constant ASSET_TYPEHASH = keccak256("Asset(uint8 kind,address token)");

    /// @dev EIP-712 TypeHash for AssetSecurityCommitment
    /// @dev Includes nested Asset definition for EIP-712 type string completeness
    bytes32 internal constant ASSET_SECURITY_COMMITMENT_TYPEHASH =
        keccak256("AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)");

    /// @dev EIP-712 TypeHash for ResourceCommitment
    bytes32 internal constant RESOURCE_COMMITMENT_TYPEHASH = keccak256("ResourceCommitment(uint8 kind,uint64 count)");

    /// @dev EIP-712 TypeHash for QuoteDetails
    /// @dev Replay protection is handled by marking digests as used.
    /// @dev `requester` is part of the typed data so the operator's signature commits
    ///      to who is allowed to redeem the quote. Without it, a third party can copy
    ///      the signature, flip `details.requester`, and pass the binding check in
    ///      `verifyQuoteBatch` while the original signature still recovers correctly.
    /// @dev `operation` + `serviceId` bind the quote to a single flow (create vs extend)
    ///      so a quote signed for one cannot be redeemed against the other through the
    ///      shared `_usedQuotes` map.
    /// @dev Referenced struct types are appended in EIP-712 canonical (alphabetical-by-name)
    ///      order — Asset, AssetSecurityCommitment, ResourceCommitment — so that standards
    ///      compliant signers compute the same `hashStruct`.
    bytes32 internal constant QUOTE_TYPEHASH = keccak256(
        "QuoteDetails(address requester,uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,uint8 confidentiality,uint8 operation,uint64 serviceId,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)Asset(uint8 kind,address token)AssetSecurityCommitment(Asset asset,uint16 exposureBps)ResourceCommitment(uint8 kind,uint64 count)"
    );

    /// @dev EIP-712 TypeHash for JobQuoteDetails (per-job RFQ).
    /// @dev Includes `requester` so the operator's signature binds the consumer of
    ///      the quote, mirroring the QuoteDetails fix.
    /// @dev Includes `inputsHash` (= keccak256(inputs)) so the operator's price is bound to
    ///      the exact job inputs; otherwise the caller could substitute arbitrary inputs and
    ///      redeem a cheap quote for expensive work.
    bytes32 internal constant JOB_QUOTE_TYPEHASH = keccak256(
        "JobQuoteDetails(address requester,uint64 serviceId,uint8 jobIndex,uint256 price,uint64 timestamp,uint64 expiry,uint8 confidentiality,bytes32 inputsHash)"
    );

    /// @dev EIP-712 TypeHash for domain separator
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice A quote's signed operation/serviceId did not match the flow consuming it.
    /// @dev Declared locally (not in the shared Errors library) per the quote-signing fix scope.
    error QuoteOperationMismatch(
        address operator, uint8 expectedOperation, uint8 quotedOperation, uint64 expectedServiceId, uint64 quotedServiceId
    );

    /// @notice A job quote's signed `inputsHash` did not match the submitted job inputs.
    error JobQuoteInputsMismatch(address operator, bytes32 expectedInputsHash, bytes32 quotedInputsHash);

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event QuoteUsed(address indexed operator, bytes32 indexed quoteHash);

    // ═══════════════════════════════════════════════════════════════════════════
    // DOMAIN SEPARATOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute the EIP-712 domain separator
    function computeDomainSeparator(
        string memory name,
        string memory version,
        address verifyingContract
    )
        internal
        view
        returns (bytes32)
    {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(
            abi.encode(
                DOMAIN_TYPEHASH, keccak256(bytes(name)), keccak256(bytes(version)), block.chainid, verifyingContract
            )
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUOTE VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute the hash of quote details for signing
    function hashQuote(Types.QuoteDetails memory details) internal pure returns (bytes32) {
        bytes32 commitmentsHash = hashSecurityCommitments(details.securityCommitments);
        bytes32 resourcesHash = hashResourceCommitments(details.resourceCommitments);
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(
            abi.encode(
                QUOTE_TYPEHASH,
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
    }

    function hashSecurityCommitments(Types.AssetSecurityCommitment[] memory commitments)
        internal
        pure
        returns (bytes32)
    {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = hashSecurityCommitment(commitments[i]);
        }
        bytes32 out;
        // Hash the concatenation of the element hashes (standard EIP-712 array hashing pattern).
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }

    function hashSecurityCommitment(Types.AssetSecurityCommitment memory commitment) internal pure returns (bytes32) {
        bytes32 assetHash = keccak256(abi.encode(ASSET_TYPEHASH, commitment.asset.kind, commitment.asset.token));
        return keccak256(abi.encode(ASSET_SECURITY_COMMITMENT_TYPEHASH, assetHash, commitment.exposureBps));
    }

    function hashResourceCommitments(Types.ResourceCommitment[] memory commitments) internal pure returns (bytes32) {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = hashResourceCommitment(commitments[i]);
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }

    function hashResourceCommitment(Types.ResourceCommitment memory commitment) internal pure returns (bytes32) {
        return keccak256(abi.encode(RESOURCE_COMMITMENT_TYPEHASH, commitment.kind, commitment.count));
    }

    /// @notice Compute the full EIP-712 digest for a quote
    function computeQuoteDigest(
        bytes32 domainSeparator,
        Types.QuoteDetails memory details
    )
        internal
        pure
        returns (bytes32)
    {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, hashQuote(details)));
    }

    /// @notice Verify quote and check it hasn't been used
    function verifyAndMarkQuoteUsed(
        mapping(bytes32 => bool) storage usedQuotes,
        bytes32 domainSeparator,
        Types.SignedQuote memory quote
    )
        internal
    {
        bytes32 digest = computeQuoteDigest(domainSeparator, quote.details);

        // Check not already used
        if (usedQuotes[digest]) {
            revert Errors.QuoteAlreadyUsed(quote.operator);
        }

        // Verify signature
        address recovered = digest.recover(quote.signature);
        if (recovered != quote.operator) {
            revert Errors.InvalidQuoteSignature(quote.operator);
        }

        // Mark as used
        usedQuotes[digest] = true;
        emit QuoteUsed(quote.operator, digest);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB QUOTE VERIFICATION (per-job RFQ)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute the hash of job quote details for signing
    function hashJobQuote(Types.JobQuoteDetails memory details) internal pure returns (bytes32) {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(
            abi.encode(
                JOB_QUOTE_TYPEHASH,
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
    }

    /// @notice Compute the full EIP-712 digest for a job quote
    function computeJobQuoteDigest(
        bytes32 domainSeparator,
        Types.JobQuoteDetails memory details
    )
        internal
        pure
        returns (bytes32)
    {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, hashJobQuote(details)));
    }

    /// @notice Verify job quote signature and mark as used (replay protection)
    /// @param expectedRequester The address consuming the quote (typically `msg.sender`).
    ///        Bound here so a third party that observed the gossiped quote cannot
    ///        front-run the intended caller and burn the single-use digest. A wildcard
    ///        `requester == address(0)` on the signed details is rejected outright.
    /// @param expectedInputsHash `keccak256(inputs)` of the job actually being submitted. The
    ///        operator's price is bound to these exact inputs; a mismatch means the caller tried
    ///        to redeem the quote for work the operator never priced.
    function verifyAndMarkJobQuoteUsed(
        mapping(bytes32 => bool) storage usedQuotes,
        bytes32 domainSeparator,
        Types.SignedJobQuote memory quote,
        uint64 maxQuoteAge,
        address expectedRequester,
        bytes32 expectedInputsHash
    )
        internal
    {
        // Bind the quote to the caller. Wildcard requesters are rejected because a
        // publicly-posted wildcard quote is a free coupon for whoever lands their tx
        // first — the operator's signature must commit to a specific consumer.
        if (quote.details.requester == address(0) || quote.details.requester != expectedRequester) {
            revert Errors.JobQuoteRequesterMismatch(quote.operator, quote.details.requester, expectedRequester);
        }

        // Bind the operator's price to the exact job inputs they quoted. Without this the
        // caller could pass arbitrary `inputs` to `submitJobFromQuote` and redeem a cheap
        // quote for expensive work the operator never agreed to.
        if (quote.details.inputsHash != expectedInputsHash) {
            revert JobQuoteInputsMismatch(quote.operator, expectedInputsHash, quote.details.inputsHash);
        }

        // Check expiry
        if (block.timestamp > quote.details.expiry) {
            revert Errors.QuoteExpired(quote.operator, quote.details.expiry);
        }

        // Check timestamp freshness
        if (maxQuoteAge > 0 && block.timestamp > quote.details.timestamp + maxQuoteAge) {
            revert Errors.QuoteTimestampTooOld(quote.operator, quote.details.timestamp, maxQuoteAge);
        }

        bytes32 digest = computeJobQuoteDigest(domainSeparator, quote.details);

        // Check not already used
        if (usedQuotes[digest]) {
            revert Errors.QuoteAlreadyUsed(quote.operator);
        }

        // Verify signature
        address recovered = digest.recover(quote.signature);
        if (recovered != quote.operator) {
            revert Errors.InvalidQuoteSignature(quote.operator);
        }

        // Mark as used
        usedQuotes[digest] = true;
        emit QuoteUsed(quote.operator, digest);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BATCH VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify multiple quotes and compute total cost.
    /// @param expectedRequester The address each quote must be bound to (typically `msg.sender`).
    /// @param maxQuoteAge Maximum allowed age (in seconds) of `details.timestamp`. `0` disables
    ///        the check; non-zero values enforce that the operator-signed timestamp is no older
    ///        than `maxQuoteAge` at redemption. Without this an operator-signed `expiry` set to
    ///        `type(uint64).max` would let a customer redeem a stale price long after the
    ///        market moved.
    /// @dev Wildcard `requester == address(0)` is rejected. Operators that sign a wildcard
    ///      quote and post it publicly are vulnerable to a front-runner consuming the
    ///      single-use digest before the intended caller's tx lands. Wildcard support has
    ///      no good production use case; if a workflow needs "any of N callers may consume
    ///      this," the operator should issue per-caller quotes or have the caller batch
    ///      them as a permittedCaller list at request time.
    /// @param expectedOperation The flow consuming the batch (`Create` or `Extend`). Each quote's
    ///        signed `operation` must match, so a quote signed for one flow cannot be replayed
    ///        against the other through the shared `usedQuotes` map.
    /// @param expectedServiceId The target service for extend quotes (`0` for create). Bound into
    ///        the check so an extend quote signed for service A cannot be redeemed against service B.
    function verifyQuoteBatch(
        mapping(bytes32 => bool) storage usedQuotes,
        bytes32 domainSeparator,
        Types.SignedQuote[] memory quotes,
        uint64 blueprintId,
        uint64 ttl,
        address expectedRequester,
        uint64 maxQuoteAge,
        Types.QuoteOperation expectedOperation,
        uint64 expectedServiceId
    )
        internal
        returns (uint256 totalCost, address[] memory operators)
    {
        if (quotes.length == 0) {
            revert Errors.NoQuotes();
        }

        operators = new address[](quotes.length);
        totalCost = 0;

        for (uint256 i = 0; i < quotes.length; i++) {
            Types.SignedQuote memory quote = quotes[i];

            // Check for duplicate operators
            for (uint256 j = 0; j < i; j++) {
                if (operators[j] == quote.operator) {
                    revert Errors.DuplicateOperatorQuote(quote.operator);
                }
            }

            // Bind the quote to the flow it was signed for. A create quote (full new
            // commitment) and an extend quote (low marginal cost) share `QUOTE_TYPEHASH`
            // and the `usedQuotes` map; without this check a cheap extend quote could be
            // redeemed as a service creation (or vice versa) whenever blueprintId/ttl/
            // requester coincide.
            if (quote.details.operation != expectedOperation || quote.details.serviceId != expectedServiceId) {
                revert QuoteOperationMismatch(
                    quote.operator,
                    uint8(expectedOperation),
                    uint8(quote.details.operation),
                    expectedServiceId,
                    quote.details.serviceId
                );
            }

            // Validate quote parameters match request
            if (quote.details.blueprintId != blueprintId) {
                revert Errors.QuoteBlueprintMismatch(quote.operator, blueprintId, quote.details.blueprintId);
            }

            if (quote.details.ttlBlocks != ttl) {
                revert Errors.QuoteTTLMismatch(quote.operator, ttl, quote.details.ttlBlocks);
            }

            // Check expiry
            if (block.timestamp > quote.details.expiry) {
                revert Errors.QuoteExpired(quote.operator, quote.details.expiry);
            }

            // Check timestamp freshness so an operator-signed long-tail `expiry` cannot
            // be used to redeem a stale-priced quote weeks later.
            if (maxQuoteAge > 0 && block.timestamp > quote.details.timestamp + maxQuoteAge) {
                revert Errors.QuoteTimestampStale(quote.operator, quote.details.timestamp, maxQuoteAge);
            }

            // Bind quote to the intended requester so a third party cannot front-run
            // `createServiceFromQuotes` with the operator's signature. Wildcard
            // `requester == address(0)` is rejected outright — see the docstring.
            if (quote.details.requester == address(0) || quote.details.requester != expectedRequester) {
                revert Errors.InvalidQuoteSignature(quote.operator);
            }

            // Verify signature and mark used
            verifyAndMarkQuoteUsed(usedQuotes, domainSeparator, quote);

            operators[i] = quote.operator;
            totalCost += quote.details.totalCost;
        }
    }
}
