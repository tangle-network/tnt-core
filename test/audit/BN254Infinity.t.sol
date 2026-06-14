// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { BN254 } from "../../src/libraries/BN254.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @notice Probe BN254.verifyBls behaviour on degenerate (point-at-infinity) inputs
///         and on a non-subgroup-membership check, to characterise the precompile.
contract BN254InfinityTest is Test {
    function test_verifyBls_infinityPubkey_and_infinitySig_verifiesAnyMessage() public {
        // signature = G1 point at infinity (0,0), pubkey = G2 point at infinity (0,0,0,0)
        Types.BN254G1Point memory sig = Types.BN254G1Point(0, 0);
        Types.BN254G2Point memory pubkey = Types.BN254G2Point([uint256(0), 0], [uint256(0), 0]);

        bytes memory msg1 = abi.encode("arbitrary message A", uint256(1));
        bytes memory msg2 = abi.encode("totally different message B", address(this));

        bool ok1 = BN254.verifyBls(msg1, sig, pubkey);
        bool ok2 = BN254.verifyBls(msg2, sig, pubkey);

        emit log_named_uint("verifyBls(msgA, O, O)", ok1 ? 1 : 0);
        emit log_named_uint("verifyBls(msgB, O, O)", ok2 ? 1 : 0);

        // If these are TRUE, the library treats an all-zero signature/pubkey pair as a
        // universally-valid BLS signature over ANY message.
        assertTrue(ok1, "infinity sig/pubkey should NOT verify but does");
        assertTrue(ok2, "infinity sig/pubkey should NOT verify but does");
    }

    function test_verifyBls_realPubkey_zeroSig_doesNotVerify() public {
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
        bool ok = BN254.verifyBls(m, sig, pubkey);
        emit log_named_uint("verifyBls(m, O, realGen)", ok ? 1 : 0);
        // With a real pubkey and O signature this should fail (e(O,gen)=1 != e(H(m),gen)).
        assertFalse(ok, "zero sig should not verify against real pubkey");
    }
}
