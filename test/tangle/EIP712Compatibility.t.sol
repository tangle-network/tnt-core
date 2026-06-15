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
            requester: 0x000000000000000000000000000000000000bEEF,
            serviceId: 42,
            jobIndex: 3,
            price: 1 ether,
            timestamp: 1_700_000_000,
            expiry: 1_700_003_600,
            confidentiality: 0,
            inputsHash: keccak256("")
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
        // Updated for the typehash that adds `bytes32 inputsHash` (job inputs binding)
        // on top of `address requester`. The Rust test vectors in
        // pricing-engine/tests/eip712_compat.rs MUST be regenerated with the same
        // `requester=0xbEEF`, `inputsHash=keccak256("")`, and the new typehash.
        assertEq(
            structHash,
            bytes32(0x223829f63247a6b4a7724cdd0b3bb9b33ffacf2ac573851b8b4d6d028885c710),
            "struct hash mismatch"
        );
        assertEq(
            digest,
            bytes32(0x9bd02b8b280e84cda6136def5cae3eb19e0c5ab5bd4619a0cad56bc2c4f15a11),
            "EIP-712 digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 2: Zero price
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteDigest_Vector2_ZeroPrice() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            requester: address(0xC0FFEE),
            serviceId: 1,
            jobIndex: 0,
            price: 0,
            timestamp: 1_000_000,
            expiry: 1_003_600,
            confidentiality: 0,
            inputsHash: keccak256("")
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Updated for the typehash that adds `bytes32 inputsHash` on top of `address requester`.
        assertEq(
            digest,
            bytes32(0x1e88efd60c60a4c1e73e353d8ded5256bfffd2b115bf79c1646a555f8936ebf1),
            "zero-price digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 3: Large price (near max u128)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteDigest_Vector3_LargePrice() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            requester: 0x000000000000000000000000000000000000bEEF,
            serviceId: 999,
            jobIndex: 7,
            price: type(uint128).max,
            timestamp: 1_700_000_000,
            expiry: 1_700_007_200,
            confidentiality: 0,
            inputsHash: keccak256("")
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Updated for the typehash that adds `bytes32 inputsHash` on top of `address requester`.
        assertEq(
            digest,
            bytes32(0xb8c5094b407d6dd0c0e83ad9cd611be39095713ed16c720a8fe4a829ba84fc7f),
            "large-price digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 4: Signature roundtrip
    // Uses private key 0x01 (address 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteSignature_Vector4_Roundtrip() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            requester: 0x000000000000000000000000000000000000bEEF,
            serviceId: 42,
            jobIndex: 3,
            price: 1 ether,
            timestamp: 1_700_000_000,
            expiry: 1_700_003_600,
            confidentiality: 0,
            inputsHash: keccak256("")
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Sign with private key 0x01
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);

        // Verify signature components (Rust test must produce the same)
        // Updated for the typehash that adds `bytes32 inputsHash` on top of `address requester`.
        // (v can flip between 27/28 depending on the new digest; pin the actual
        // value the recovery succeeds against.)
        assertEq(r, bytes32(0x2561b12e4d70171c286c5dcedd0680c480eddf0c9846d1306218681793959308), "r mismatch");

        // Recover the signer
        address recovered = ecrecover(digest, v, r, s);
        assertEq(recovered, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, "signer mismatch");
    }
}
