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

    /// @dev EIP-712 TypeHash for QuoteDetails
    /// @dev Replay protection is handled by marking digests as used
    bytes32 internal constant QUOTE_TYPEHASH = keccak256(
        "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,AssetSecurityCommitment[] securityCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)"
    );

    /// @dev EIP-712 TypeHash for JobQuoteDetails (per-job RFQ)
    bytes32 internal constant JOB_QUOTE_TYPEHASH =
        keccak256("JobQuoteDetails(uint64 serviceId,uint8 jobIndex,uint256 price,uint64 timestamp,uint64 expiry)");

    /// @dev EIP-712 TypeHash for domain separator
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

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
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(
            abi.encode(
                QUOTE_TYPEHASH,
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                commitmentsHash
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
                details.serviceId,
                details.jobIndex,
                details.price,
                details.timestamp,
                details.expiry
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
    function verifyAndMarkJobQuoteUsed(
        mapping(bytes32 => bool) storage usedQuotes,
        bytes32 domainSeparator,
        Types.SignedJobQuote memory quote,
        uint64 maxQuoteAge
    )
        internal
    {
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

    /// @notice Verify multiple quotes and compute total cost
    function verifyQuoteBatch(
        mapping(bytes32 => bool) storage usedQuotes,
        bytes32 domainSeparator,
        Types.SignedQuote[] memory quotes,
        uint64 blueprintId,
        uint64 ttl
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

            // Verify signature and mark used
            verifyAndMarkQuoteUsed(usedQuotes, domainSeparator, quote);

            operators[i] = quote.operator;
            totalCost += quote.details.totalCost;
        }
    }
}
