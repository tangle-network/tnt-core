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
            serviceId: 42, jobIndex: 3, price: 1 ether, timestamp: 1_700_000_000, expiry: 1_700_003_600
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
            bytes32(0x2208c3cc800f0d0c2f7fccdf0d30b393a2949eb302b951a9e3468e60b7de9bd3),
            "struct hash mismatch"
        );
        assertEq(
            digest,
            bytes32(0x43852f97be3d1f638c99ae231f2790f2476effab2de03e5a6536762c94da2a7b),
            "EIP-712 digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 2: Zero price
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteDigest_Vector2_ZeroPrice() public pure {
        Types.JobQuoteDetails memory details =
            Types.JobQuoteDetails({ serviceId: 1, jobIndex: 0, price: 0, timestamp: 1_000_000, expiry: 1_003_600 });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        assertEq(
            digest,
            bytes32(0x2e5dfc598e6f1767b01024dd1dd7010623fbf5ed3c6f43f3da16f2fb07fc1bc3),
            "zero-price digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 3: Large price (near max u128)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteDigest_Vector3_LargePrice() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: 999, jobIndex: 7, price: type(uint128).max, timestamp: 1_700_000_000, expiry: 1_700_007_200
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        assertEq(
            digest,
            bytes32(0xa007fedc1503dbe6f87b5dca5c00bef6a306ab0d8e49681e6d8ea81e3ec6d56b),
            "large-price digest mismatch"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TEST VECTOR 4: Signature roundtrip
    // Uses private key 0x01 (address 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JobQuoteSignature_Vector4_Roundtrip() public pure {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            serviceId: 42, jobIndex: 3, price: 1 ether, timestamp: 1_700_000_000, expiry: 1_700_003_600
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Verify digest matches Vector 1
        assertEq(
            digest,
            bytes32(0x43852f97be3d1f638c99ae231f2790f2476effab2de03e5a6536762c94da2a7b),
            "digest must match Vector 1"
        );

        // Sign with private key 0x01
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);

        // Verify signature components (Rust test must produce the same)
        assertEq(v, 28, "v mismatch");
        assertEq(r, bytes32(0xe0eed464a6c3a0f8ffa634987ed23d4fabbe8a4547ecb5c456021f2d741333ad), "r mismatch");
        assertEq(s, bytes32(0x21252999cf52abde6e3a57ccfbea83e8e82b89b142995f2fd1ba7721b591f3c3), "s mismatch");

        // Recover the signer
        address recovered = ecrecover(digest, v, r, s);
        assertEq(recovered, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, "signer mismatch");
    }
}
