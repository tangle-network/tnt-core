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
            confidentiality: 0
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
        // Updated for the v0.13.0 typehash that adds `address requester`. The
        // Rust test vectors in pricing-engine/tests/eip712_compat.rs MUST be
        // regenerated with the same `requester=0xbEEF` and the new typehash.
        assertEq(
            structHash,
            bytes32(0x81efa1579f66bc16802d9c482eb23561fa1a86e1288cb65902b4619005a04a87),
            "struct hash mismatch"
        );
        assertEq(
            digest,
            bytes32(0xfd2339fda45c2e7e30f8d5dbcc062f82af12757ad80175cbdd6972627fb3c54c),
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
            confidentiality: 0
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Updated for the v0.13.0 typehash that adds `address requester`.
        assertEq(
            digest,
            bytes32(0xc21c630f71383acd4d8f5465a13264f9e376dfb323acfe97d5202bc9a5baa221),
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
            confidentiality: 0
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Updated for the v0.13.0 typehash that adds `address requester`.
        assertEq(
            digest,
            bytes32(0xebd98b504cfdbe392ddf9813148e2f7808bb6f7ef85c376315fe0446c2ffc9ee),
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
            confidentiality: 0
        });

        bytes32 domainSep = _testDomainSeparator();
        bytes32 digest = SignatureLib.computeJobQuoteDigest(domainSep, details);

        // Sign with private key 0x01
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, digest);

        // Verify signature components (Rust test must produce the same)
        // Updated for the v0.13.0 typehash that adds `address requester`.
        // (v can flip between 27/28 depending on the new digest; pin the actual
        // value the recovery succeeds against.)
        assertEq(r, bytes32(0x9d22c9909f6ebbcadc4ec85467c487e3d29afa8409f058371894af17f176db4c), "r mismatch");

        // Recover the signer
        address recovered = ecrecover(digest, v, r, s);
        assertEq(recovered, 0x7E5F4552091A69125d5DfCb7b8C2659029395Bdf, "signer mismatch");
    }
}
