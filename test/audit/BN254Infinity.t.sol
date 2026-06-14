// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { BN254 } from "../../src/libraries/BN254.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @notice Regression guard for the BN254 point-at-infinity universal-forgery.
///         verifyBls MUST reject degenerate (point-at-infinity) signature/pubkey inputs
///         up front with DegenerateBlsInput() rather than letting them reach the pairing
///         precompile, where e(O, ·) = e(·, O) = 1 collapses both sides of the BLS check
///         and "verifies" ANY message.
contract BN254InfinityTest is Test {
    function test_verifyBls_infinityPubkey_and_infinitySig_isRejected() public {
        // signature = G1 point at infinity (0,0), pubkey = G2 point at infinity (0,0,0,0)
        Types.BN254G1Point memory sig = Types.BN254G1Point(0, 0);
        Types.BN254G2Point memory pubkey = Types.BN254G2Point([uint256(0), 0], [uint256(0), 0]);

        bytes memory msg1 = abi.encode("arbitrary message A", uint256(1));
        bytes memory msg2 = abi.encode("totally different message B", address(this));

        // The all-zero (signature, pubkey) pair previously verified over ANY message —
        // a universal forgery. The fix rejects degenerate inputs before the pairing,
        // so verifyBls must revert for every message instead of returning true.
        vm.expectRevert(BN254.DegenerateBlsInput.selector);
        BN254.verifyBls(msg1, sig, pubkey);

        vm.expectRevert(BN254.DegenerateBlsInput.selector);
        BN254.verifyBls(msg2, sig, pubkey);
    }

    function test_verifyBls_realPubkey_zeroSig_isRejected() public {
        // A real (nonzero, on-curve) G2 generator as pubkey, with infinity signature.
        Types.BN254G2Point memory pubkey = Types.BN254G2Point(
            [
                11_559_732_032_986_387_107_991_004_021_392_285_783_925_812_861_821_192_530_917_403_151_452_391_805_634,
                10_857_046_999_023_057_135_944_570_762_232_829_481_370_756_359_578_518_086_990_519_993_285_655_852_781
            ],
            [
                4_082_367_875_863_433_681_332_203_403_145_435_568_316_851_327_593_401_208_105_741_076_214_120_093_531,
                8_495_653_923_123_431_417_604_973_247_489_272_438_418_190_587_263_600_148_770_280_649_306_958_101_930
            ]
        );
        Types.BN254G1Point memory sig = Types.BN254G1Point(0, 0);
        bytes memory m = abi.encode("msg");
        // An infinity (zero) signature against a real pubkey is a degenerate input:
        // e(O, gen) = 1 would let an attacker forge without holding the key. The fix
        // rejects the infinity signature up front rather than relying on the pairing
        // result, so verifyBls reverts instead of returning false.
        vm.expectRevert(BN254.DegenerateBlsInput.selector);
        BN254.verifyBls(m, sig, pubkey);
    }
}
