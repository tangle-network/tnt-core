// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "./Types.sol";

/// @title BN254
/// @notice BN254 (alt_bn128) curve operations for BLS signature verification
/// @dev Uses EVM precompiles at addresses 0x06, 0x07, and 0x08 for efficient operations
library BN254 {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The prime field modulus for BN254
    uint256 internal constant P_MOD =
        21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /// @notice The group order for BN254
    uint256 internal constant R_MOD =
        21888242871839275222246405745257275088548364400416034343698204186575808495617;

    /// @notice G1 generator x coordinate
    uint256 internal constant G1_X = 1;

    /// @notice G1 generator y coordinate
    uint256 internal constant G1_Y = 2;

    /// @notice G2 generator x coordinates (x = x0 * i + x1)
    uint256 internal constant G2_X0 =
        11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 internal constant G2_X1 =
        10857046999023057135944570762232829481370756359578518086990519993285655852781;

    /// @notice G2 generator y coordinates (y = y0 * i + y1)
    uint256 internal constant G2_Y0 =
        4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 internal constant G2_Y1 =
        8495653923123431417604973247489272438418190587263600148770280649306958101930;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidG1Point();
    error InvalidG2Point();
    error PairingFailed();
    error HashToPointFailed();

    // ═══════════════════════════════════════════════════════════════════════════
    // POINT VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if a G1 point is valid (on the curve)
    /// @param p The G1 point to validate
    /// @return True if valid
    function isValidG1(Types.BN254G1Point memory p) internal pure returns (bool) {
        if (p.x == 0 && p.y == 0) {
            return true; // Point at infinity is valid
        }
        if (p.x >= P_MOD || p.y >= P_MOD) {
            return false;
        }
        // Check y^2 = x^3 + 3 (mod p)
        uint256 lhs = mulmod(p.y, p.y, P_MOD);
        uint256 rhs = addmod(mulmod(mulmod(p.x, p.x, P_MOD), p.x, P_MOD), 3, P_MOD);
        return lhs == rhs;
    }

    /// @notice Check if a G2 point is valid
    /// @dev Full validation would require extension field arithmetic, so we just check bounds
    /// @param p The G2 point to validate
    /// @return True if bounds are valid
    function isValidG2(Types.BN254G2Point memory p) internal pure returns (bool) {
        return p.x[0] < P_MOD && p.x[1] < P_MOD && p.y[0] < P_MOD && p.y[1] < P_MOD;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // G1 OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add two G1 points using precompile 0x06
    /// @param p1 First point
    /// @param p2 Second point
    /// @return r The sum p1 + p2
    function addG1(
        Types.BN254G1Point memory p1,
        Types.BN254G1Point memory p2
    ) internal view returns (Types.BN254G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.x;
        input[1] = p1.y;
        input[2] = p2.x;
        input[3] = p2.y;

        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0x80, r, 0x40)
        }
        if (!success) revert InvalidG1Point();
    }

    /// @notice Scalar multiplication on G1 using precompile 0x07
    /// @param p The point to multiply
    /// @param s The scalar
    /// @return r The product s * p
    function scalarMulG1(
        Types.BN254G1Point memory p,
        uint256 s
    ) internal view returns (Types.BN254G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.x;
        input[1] = p.y;
        input[2] = s;

        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x60, r, 0x40)
        }
        if (!success) revert InvalidG1Point();
    }

    /// @notice Negate a G1 point (reflect over x-axis)
    /// @param p The point to negate
    /// @return The negated point
    function negateG1(Types.BN254G1Point memory p) internal pure returns (Types.BN254G1Point memory) {
        if (p.x == 0 && p.y == 0) {
            return p; // Point at infinity
        }
        return Types.BN254G1Point(p.x, P_MOD - (p.y % P_MOD));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAIRING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check a pairing equation using precompile 0x08
    /// @dev Verifies e(p1[0], p2[0]) * e(p1[1], p2[1]) * ... = 1
    /// @param p1 Array of G1 points
    /// @param p2 Array of G2 points
    /// @return True if the pairing equation holds
    function pairing(
        Types.BN254G1Point[] memory p1,
        Types.BN254G2Point[] memory p2
    ) internal view returns (bool) {
        require(p1.length == p2.length, "BN254: pairing length mismatch");
        uint256 elements = p1.length;
        uint256 inputSize = elements * 6;
        uint256[] memory input = new uint256[](inputSize);

        for (uint256 i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].x;
            input[i * 6 + 1] = p1[i].y;
            // G2 point encoding per EIP-197:
            // x = x[0] * i + x[1], y = y[0] * i + y[1]
            // Point (a0 + i*a1, b0 + i*b1) is encoded as [a1, a0, b1, b0]
            // So x[0]=a1 (imag), x[1]=a0 (real), encode as [x[0], x[1], y[0], y[1]]
            input[i * 6 + 2] = p2[i].x[0];
            input[i * 6 + 3] = p2[i].x[1];
            input[i * 6 + 4] = p2[i].y[0];
            input[i * 6 + 5] = p2[i].y[1];
        }

        uint256[1] memory result;
        bool success;
        assembly {
            success := staticcall(
                sub(gas(), 2000),
                8,
                add(input, 0x20),
                mul(inputSize, 0x20),
                result,
                0x20
            )
        }
        if (!success) revert PairingFailed();
        return result[0] == 1;
    }

    /// @notice Verify a single pairing e(a, b) == e(c, d)
    /// @dev Uses the fact that e(a,b) * e(-c,d) = 1 iff e(a,b) = e(c,d)
    function pairingCheck(
        Types.BN254G1Point memory a,
        Types.BN254G2Point memory b,
        Types.BN254G1Point memory c,
        Types.BN254G2Point memory d
    ) internal view returns (bool) {
        Types.BN254G1Point[] memory p1 = new Types.BN254G1Point[](2);
        Types.BN254G2Point[] memory p2 = new Types.BN254G2Point[](2);
        p1[0] = a;
        p1[1] = negateG1(c);
        p2[0] = b;
        p2[1] = d;
        return pairing(p1, p2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLS SIGNATURE VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Hash a message to a G1 point using try-and-increment
    /// @dev This is a simple hash-to-curve, not a constant-time one
    /// @param message The message to hash
    /// @return The G1 point
    function hashToG1(bytes memory message) internal pure returns (Types.BN254G1Point memory) {
        uint256 h = uint256(keccak256(message)) % P_MOD;
        uint256 x = h;

        // Try-and-increment: find smallest x such that x^3 + 3 is a quadratic residue
        for (uint256 i = 0; i < 256; i++) {
            uint256 y2 = addmod(mulmod(mulmod(x, x, P_MOD), x, P_MOD), 3, P_MOD);
            uint256 y = sqrtMod(y2);
            if (mulmod(y, y, P_MOD) == y2) {
                return Types.BN254G1Point(x, y);
            }
            x = addmod(x, 1, P_MOD);
        }
        revert HashToPointFailed();
    }

    /// @notice Verify a BLS signature
    /// @dev Checks e(signature, G2) = e(H(message), pubkey)
    /// @param message The signed message
    /// @param signature The BLS signature (G1 point)
    /// @param pubkey The public key (G2 point)
    /// @return True if signature is valid
    function verifyBls(
        bytes memory message,
        Types.BN254G1Point memory signature,
        Types.BN254G2Point memory pubkey
    ) internal view returns (bool) {
        Types.BN254G1Point memory msgPoint = hashToG1(message);
        Types.BN254G2Point memory g2 = Types.BN254G2Point([G2_X0, G2_X1], [G2_Y0, G2_Y1]);
        return pairingCheck(signature, g2, msgPoint, pubkey);
    }

    /// @notice Verify an aggregated BLS signature
    /// @dev For aggregated signatures, we verify e(aggSig, G2) = e(H(msg), aggPubkey)
    /// @param message The signed message (must be same for all signers)
    /// @param aggregatedSignature The aggregated BLS signature
    /// @param aggregatedPubkey The aggregated public key
    /// @return True if signature is valid
    function verifyAggregatedBls(
        bytes memory message,
        Types.BN254G1Point memory aggregatedSignature,
        Types.BN254G2Point memory aggregatedPubkey
    ) internal view returns (bool) {
        return verifyBls(message, aggregatedSignature, aggregatedPubkey);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MATH HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute modular square root using Tonelli-Shanks
    /// @dev Only works for p ≡ 3 (mod 4), which is true for BN254
    /// @param a The value to sqrt
    /// @return The square root (or garbage if not a QR)
    function sqrtMod(uint256 a) internal pure returns (uint256) {
        // For p ≡ 3 (mod 4): sqrt(a) = a^((p+1)/4)
        // P_MOD = 21888242871839275222246405745257275088696311157297823662689037894645226208583
        // (P_MOD + 1) / 4 = 5472060717959818805561601436314318772174077789324455915672259473661306552146
        // = 0x0c19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52
        return expMod(a, 0x0c19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52, P_MOD);
    }

    /// @notice Modular exponentiation
    /// @param base The base
    /// @param exponent The exponent
    /// @param modulus The modulus
    /// @return The result
    function expMod(uint256 base, uint256 exponent, uint256 modulus) internal pure returns (uint256) {
        uint256 result = 1;
        base = base % modulus;
        while (exponent > 0) {
            if (exponent % 2 == 1) {
                result = mulmod(result, base, modulus);
            }
            exponent = exponent >> 1;
            base = mulmod(base, base, modulus);
        }
        return result;
    }
}
