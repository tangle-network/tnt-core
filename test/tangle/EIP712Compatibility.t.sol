// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { Types } from "../../src/libraries/Types.sol";
import { SignatureLib } from "../../src/libraries/SignatureLib.sol";

/// @title EIP712CompatibilityTest
/// @notice Deterministic test vectors for cross-repo EIP-712 verification.
///         Rust tests in blueprint-sdk MUST produce the same digests for the same inputs.
///
///         Domain: name="TangleQuote", version="1", chainId=31337,
///                 verifyingContract=0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF
///
///         If ANY assertion here changes, the corresponding Rust test in
///         blueprint-sdk/crates/pricing-engine/src/tests/eip712_compat.rs MUST be updated.
contract EIP712CompatibilityTest is Test {
    // ═══════════════════════════════════════════════════════════════════════════
    // DOMAIN CONFIGURATION (deterministic test values)
    // ═══════════════════════════════════════════════════════════════════════════

    uint256 constant CHAIN_ID = 31_337;
    address constant VERIFYING_CONTRACT = 0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF;

    function _testDomainSeparator() internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("TangleQuote"),
                keccak256("1"),
                CHAIN_ID,
                VERIFYING_CONTRACT
            )
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 1: Basic job quote
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteDigest_Vector1() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: 42, jobIndex: 3, price: 1 ether, timestamp: 1_700_000_000, expiry: 1_700_003_600, confidentiality: Types.ConfidentialityPolicy.Any
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 structHash = SignatureLib.hashJobQuote(details);
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // These values must match the Rust test in pricing-engine/tests/eip712_compat.rs
        assertEq(
            domainSep,
            bytes32(0x14a60a86c57fe72bdcbdc59af9a05606ca542a7ed2eeb732756b210d3306f149),
            "domain separator mismatch"
        );
        assertEq(
            structHash,
            bytes32(0xb5ad63b2aafeb693bc7fb591fb0cba712fff4cfafaccfb4bf97de29f069da660),
            "struct hash mismatch"
        );
        assertEq(
            digest,
            bytes32(0xe13955facb4fcba51dce076d019e9509fc5d3c028a269e17e5ea1b78ca41fd26),
            "EIP-712 digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 2: Zero price
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteDigest_Vector2_ZeroPrice() public pure {
        Types.JobQuoteDetails memory details =
            Types.JobQuoteDetails({ serviceId: 1, jobIndex: 0, price: 0, timestamp: 1_000_000, expiry: 1_003_600, confidentiality: Types.ConfidentialityPolicy.Any });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        assertEq(
            digest,
            bytes32(0x681b55c8c7602d2069ba2d5503cbec4f25e6067270e5e57bc310a0bb2f4ed7ff),
            "zero-price digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 3: Large price (near max u128)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteDigest_Vector3_LargePrice() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: 999, jobIndex: 7, price: type(uint128).max, timestamp: 1_700_000_000, expiry: 1_700_007_200, confidentiality: Types.ConfidentialityPolicy.Any
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        assertEq(
            digest,
            bytes32(0xbdb556510beb8c8e04fac3e8f2edcaa98ef9d8a6afe0048554919af68cc2e603),
            "large-price digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 4: Signature roundtrip
    // Uses private key 0x01 (address 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteSignature_Vector4_Roundtrip() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: 42, jobIndex: 3, price: 1 ether, timestamp: 1_700_000_000, expiry: 1_700_003_600, confidentiality: Types.ConfidentialityPolicy.Any
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Sign with private key 0x01
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);

        // Verify signature components (Rust test must produce the same)
        assertEq(v, 27, "v mismatch");
        assertEq(r, bytes32(0x960bdb5998cf170ed3046bd786fac54de0aee995b62a3f50d8ee0476d2fd5c1b), "r mismatch");
        assertEq(s, bytes32(0x6d80a9d5aadcc5f96338e9652a0c21f4f19592838006e3b5749e3346d29a5721), "s mismatch");

        // Recover the signer
        address recovered = ecrecover(digest, v, r, s);
        assertEq(recovered, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, "signer mismatch");
    }
}
