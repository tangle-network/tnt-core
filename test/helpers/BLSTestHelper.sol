// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BN254 } from "../../src/libraries/BN254.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @title BLSTestHelper
/// @notice Helper contract for generating valid BLS test data
/// @dev Uses precomputed G2 points for test private keys
///
/// BN254 BLS scheme:
/// - Private key `sk` is a scalar in F_r
/// - Public key `pk = sk * G2` (G2 point)
/// - Signature `sig = sk * H(message)` (G1 point)
/// - Verify: e(sig, G2) = e(H(message), pk)
///
/// Test keys (precomputed using sage math):
/// - sk=1: pk = G2 generator
/// - sk=2: pk = 2*G2 (precomputed below)
/// - sk=3: pk = 3*G2 (precomputed below)
library BLSTestHelper {
    // ═══════════════════════════════════════════════════════════════════════════
    // G2 GENERATOR (pk for sk=1)
    // ═══════════════════════════════════════════════════════════════════════════

    // G2 generator coordinates (same as BN254.sol)
    uint256 constant G2_X0 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant G2_X1 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant G2_Y0 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant G2_Y1 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    // ═══════════════════════════════════════════════════════════════════════════
    // PRECOMPUTED G2 POINTS (2*G2, 3*G2)
    // These were computed using SageMath for BN254 curve
    // ═══════════════════════════════════════════════════════════════════════════

    // 2 * G2 (public key for sk=2)
    uint256 constant G2_2X_X0 = 18029695676650738226693292988307914797657423701064905010927197838374790804409;
    uint256 constant G2_2X_X1 = 14583779054894525174450323658765874724019480979794335525732096752006891875705;
    uint256 constant G2_2X_Y0 = 2140229616977736810657479771656733941598412651537078903776637920509952744750;
    uint256 constant G2_2X_Y1 = 11474861747383700316476719153975578001603231366361248090558603872215261634898;

    // 3 * G2 (public key for sk=3)
    uint256 constant G2_3X_X0 = 2725019753478801796453339367788033689375851816420509565303521482350756874229;
    uint256 constant G2_3X_X1 = 7273165102799931111715871471550377909735733521218303035754523677688038059653;
    uint256 constant G2_3X_Y0 = 957874124722006818841961785324909313781880061366718538693995380805373202866;
    uint256 constant G2_3X_Y1 = 2512659008974376214222774206987427162027254181373325676825515531566330959255;

    // 6 * G2 (aggregate pubkey for sk=1+2+3)
    uint256 constant G2_6X_X0 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant G2_6X_X1 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant G2_6X_Y0 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant G2_6X_Y1 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;

    // ═══════════════════════════════════════════════════════════════════════════
    // PUBLIC KEY GETTERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get G2 public key for test private key index
    /// @param keyIndex 1, 2, or 3
    function getTestPubkey(uint256 keyIndex) internal pure returns (Types.BN254G2Point memory) {
        if (keyIndex == 1) {
            return Types.BN254G2Point([G2_X0, G2_X1], [G2_Y0, G2_Y1]);
        } else if (keyIndex == 2) {
            return Types.BN254G2Point([G2_2X_X0, G2_2X_X1], [G2_2X_Y0, G2_2X_Y1]);
        } else if (keyIndex == 3) {
            return Types.BN254G2Point([G2_3X_X0, G2_3X_X1], [G2_3X_Y0, G2_3X_Y1]);
        }
        revert("Invalid key index");
    }

    /// @notice Get aggregated pubkey for operators 1+2+3 (sk=6)
    function getAggregatedPubkey123() internal pure returns (Types.BN254G2Point memory) {
        return Types.BN254G2Point([G2_6X_X0, G2_6X_X1], [G2_6X_Y0, G2_6X_Y1]);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SIGNATURE GENERATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Sign a message with test private key
    /// @dev sig = sk * H(message)
    /// @param message The message to sign
    /// @param privateKey The private key (1, 2, or 3 for tests)
    function sign(
        bytes memory message,
        uint256 privateKey
    ) internal view returns (Types.BN254G1Point memory) {
        // Hash message to G1 point
        Types.BN254G1Point memory msgPoint = BN254.hashToG1(message);
        // Multiply by private key
        return BN254.scalarMulG1(msgPoint, privateKey);
    }

    /// @notice Create aggregated signature for multiple signers
    /// @param message The message all signers signed
    /// @param privateKeys Array of private keys
    function aggregateSignatures(
        bytes memory message,
        uint256[] memory privateKeys
    ) internal view returns (Types.BN254G1Point memory aggSig) {
        require(privateKeys.length > 0, "No private keys");

        // First signature
        aggSig = sign(message, privateKeys[0]);

        // Add remaining signatures
        for (uint256 i = 1; i < privateKeys.length; i++) {
            Types.BN254G1Point memory sig = sign(message, privateKeys[i]);
            aggSig = BN254.addG1(aggSig, sig);
        }
    }

    /// @notice Build the message that operators sign for job results
    /// @dev Message format matches Jobs.sol: abi.encodePacked(serviceId, callId, keccak256(output))
    function buildJobResultMessage(
        uint64 serviceId,
        uint64 callId,
        bytes memory output
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(serviceId, callId, keccak256(output));
    }

    /// @notice Create valid BLS data for a single signer (sk=1)
    /// @return sig The signature
    /// @return pubkey The public key (G2 generator)
    function createSingleSignerData(
        uint64 serviceId,
        uint64 callId,
        bytes memory output
    ) internal view returns (
        Types.BN254G1Point memory sig,
        Types.BN254G2Point memory pubkey
    ) {
        bytes memory message = buildJobResultMessage(serviceId, callId, output);
        sig = sign(message, 1);
        pubkey = getTestPubkey(1);
    }

    /// @notice Create valid BLS data for all 3 test signers
    function createThreeSignerData(
        uint64 serviceId,
        uint64 callId,
        bytes memory output
    ) internal view returns (
        Types.BN254G1Point memory aggSig,
        Types.BN254G2Point memory aggPubkey
    ) {
        bytes memory message = buildJobResultMessage(serviceId, callId, output);

        uint256[] memory privateKeys = new uint256[](3);
        privateKeys[0] = 1;
        privateKeys[1] = 2;
        privateKeys[2] = 3;

        aggSig = aggregateSignatures(message, privateKeys);
        aggPubkey = getAggregatedPubkey123();
    }

    /// @notice Convert G1 point to uint256[2] array for contract calls
    function g1ToArray(Types.BN254G1Point memory p) internal pure returns (uint256[2] memory) {
        return [p.x, p.y];
    }

    /// @notice Convert G2 point to uint256[4] array for contract calls
    function g2ToArray(Types.BN254G2Point memory p) internal pure returns (uint256[4] memory) {
        return [p.x[0], p.x[1], p.y[0], p.y[1]];
    }
}
