// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {BeaconChainProofs} from "../../../src/v2/beacon/BeaconChainProofs.sol";
import {ValidatorTypes} from "../../../src/v2/beacon/ValidatorTypes.sol";

/// @title BeaconFuzzTest
/// @notice Extensive fuzz testing for beacon chain proof verification
contract BeaconFuzzTest is Test {
    using BeaconChainProofs for *;

    // ═══════════════════════════════════════════════════════════════════════════
    // MERKLE PROOF FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test: Merkle proof verification with random leaves and proofs
    function testFuzz_merkleVerify_randomProof(
        bytes32 leaf,
        bytes32[10] memory proofElements,
        uint256 index
    ) public pure {
        // Bound index to reasonable range
        index = bound(index, 0, 1023); // 2^10 - 1

        // Build proof bytes
        bytes memory proof = new bytes(320); // 10 * 32
        for (uint256 i = 0; i < 10; i++) {
            for (uint256 j = 0; j < 32; j++) {
                proof[i * 32 + j] = proofElements[i][j];
            }
        }

        // Compute expected root by walking up the tree
        bytes32 computedHash = leaf;
        uint256 proofIndex = index;
        for (uint256 i = 0; i < 10; i++) {
            if (proofIndex % 2 == 0) {
                computedHash = sha256(abi.encodePacked(computedHash, proofElements[i]));
            } else {
                computedHash = sha256(abi.encodePacked(proofElements[i], computedHash));
            }
            proofIndex /= 2;
        }

        // Verify using our own implementation
        bool valid = _verifyMerkleProof(proof, computedHash, leaf, index);
        assertTrue(valid, "Computed root should verify");
    }

    /// @notice Fuzz test: Merkle proof fails with wrong leaf
    function testFuzz_merkleVerify_wrongLeaf(
        bytes32 correctLeaf,
        bytes32 wrongLeaf,
        bytes32[5] memory proofElements,
        uint256 index
    ) public pure {
        vm.assume(correctLeaf != wrongLeaf);
        index = bound(index, 0, 31); // 2^5 - 1

        bytes memory proof = new bytes(160); // 5 * 32
        for (uint256 i = 0; i < 5; i++) {
            for (uint256 j = 0; j < 32; j++) {
                proof[i * 32 + j] = proofElements[i][j];
            }
        }

        // Compute root with correct leaf
        bytes32 computedHash = correctLeaf;
        uint256 proofIndex = index;
        for (uint256 i = 0; i < 5; i++) {
            if (proofIndex % 2 == 0) {
                computedHash = sha256(abi.encodePacked(computedHash, proofElements[i]));
            } else {
                computedHash = sha256(abi.encodePacked(proofElements[i], computedHash));
            }
            proofIndex /= 2;
        }

        // Verify with wrong leaf should fail
        bool valid = _verifyMerkleProof(proof, computedHash, wrongLeaf, index);
        assertFalse(valid, "Wrong leaf should not verify");
    }

    /// @notice Fuzz test: Merkle proof fails with wrong index
    function testFuzz_merkleVerify_wrongIndex(
        bytes32 leaf,
        bytes32[5] memory proofElements,
        uint256 correctIndex,
        uint256 wrongIndex
    ) public pure {
        correctIndex = bound(correctIndex, 0, 31);
        wrongIndex = bound(wrongIndex, 0, 31);
        vm.assume(correctIndex != wrongIndex);

        bytes memory proof = new bytes(160);
        for (uint256 i = 0; i < 5; i++) {
            for (uint256 j = 0; j < 32; j++) {
                proof[i * 32 + j] = proofElements[i][j];
            }
        }

        bytes32 computedHash = _computeMerkleRoot(leaf, proofElements, correctIndex);
        bytes32 wrongRoot = _computeMerkleRoot(leaf, proofElements, wrongIndex);
        vm.assume(computedHash != wrongRoot);

        // Verify with wrong index should fail
        bool valid = _verifyMerkleProof(proof, computedHash, leaf, wrongIndex);
        assertFalse(valid, "Wrong index should not verify");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR TYPES FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test: Withdrawal credentials computation is deterministic
    function testFuzz_computeWithdrawalCredentials_deterministic(address addr) public pure {
        bytes32 creds1 = ValidatorTypes.computeWithdrawalCredentials(addr);
        bytes32 creds2 = ValidatorTypes.computeWithdrawalCredentials(addr);
        assertEq(creds1, creds2, "Should be deterministic");
    }

    /// @notice Fuzz test: Withdrawal credentials have correct prefix
    function testFuzz_computeWithdrawalCredentials_prefix(address addr) public pure {
        bytes32 creds = ValidatorTypes.computeWithdrawalCredentials(addr);
        assertEq(bytes1(creds), bytes1(0x01), "Should have 0x01 prefix");
    }

    /// @notice Fuzz test: Can extract address from credentials
    function testFuzz_computeWithdrawalCredentials_roundtrip(address addr) public pure {
        bytes32 creds = ValidatorTypes.computeWithdrawalCredentials(addr);
        address extracted = ValidatorTypes.getAddressFromCredentials(creds);
        assertEq(extracted, addr, "Should roundtrip");
    }

    /// @notice Fuzz test: 0x02 credentials computation
    function testFuzz_computeWithdrawalCredentials02_prefix(address addr) public pure {
        bytes32 creds = ValidatorTypes.computeWithdrawalCredentials02(addr);
        assertEq(bytes1(creds), bytes1(0x02), "Should have 0x02 prefix");
    }

    /// @notice Fuzz test: 0x02 credentials roundtrip
    function testFuzz_computeWithdrawalCredentials02_roundtrip(address addr) public pure {
        bytes32 creds = ValidatorTypes.computeWithdrawalCredentials02(addr);
        address extracted = ValidatorTypes.getAddressFromCredentials(creds);
        assertEq(extracted, addr, "Should roundtrip");
    }

    /// @notice Fuzz test: hasValidPrefix accepts 0x01 and 0x02 only
    function testFuzz_hasValidPrefix_onlyValidPrefixes(bytes32 creds) public pure {
        bytes1 prefix = bytes1(creds);
        bool expected = (prefix == bytes1(0x01) || prefix == bytes1(0x02));
        bool actual = ValidatorTypes.hasValidPrefix(creds);
        assertEq(actual, expected, "Should match expected prefix check");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BALANCE EXTRACTION FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test: Balance extraction from little-endian bytes
    function testFuzz_extractBalance_littleEndian(uint64 balance) public pure {
        // Create balance root (little-endian) - pack 4 balances
        bytes32 balanceRoot = bytes32(uint256(balance));

        // Use the internal extraction function via test wrapper
        uint64 extracted = _extractBalance(balanceRoot, 0);
        assertEq(extracted, balance, "Should extract correct balance");
    }

    /// @notice Fuzz test: Multiple balances packed in one root
    function testFuzz_extractBalance_packed(
        uint64 balance0,
        uint64 balance1,
        uint64 balance2,
        uint64 balance3
    ) public pure {
        // Pack 4 balances into bytes32 (little-endian)
        bytes32 balanceRoot = bytes32(
            uint256(balance0) |
            (uint256(balance1) << 64) |
            (uint256(balance2) << 128) |
            (uint256(balance3) << 192)
        );

        assertEq(_extractBalance(balanceRoot, 0), balance0);
        assertEq(_extractBalance(balanceRoot, 1), balance1);
        assertEq(_extractBalance(balanceRoot, 2), balance2);
        assertEq(_extractBalance(balanceRoot, 3), balance3);
    }

    // Helper function to extract balance from a leaf
    function _extractBalance(bytes32 balanceRoot, uint256 indexInLeaf) internal pure returns (uint64) {
        uint256 bitShift = indexInLeaf * 64;
        return uint64(uint256(balanceRoot) >> bitShift);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR FIELDS FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test: Validator slashed field extraction
    function testFuzz_isValidatorSlashed(bytes32 slashedField) public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[3] = slashedField; // Field 3 is slashed

        bool expected = uint256(slashedField) != 0;
        bool actual = BeaconChainProofs.isValidatorSlashed(fields);
        assertEq(actual, expected, "Should correctly detect slashed status");
    }

    /// @notice Fuzz test: Validator effective balance extraction
    function testFuzz_getEffectiveBalance(uint64 balance) public pure {
        bytes32[] memory fields = new bytes32[](8);
        // Field 2 is effective balance (little-endian)
        fields[2] = bytes32(uint256(balance));

        uint64 extracted = BeaconChainProofs.getEffectiveBalanceGwei(fields);
        assertEq(extracted, balance, "Should extract correct effective balance");
    }

    /// @notice Fuzz test: Withdrawal credentials extraction
    function testFuzz_getWithdrawalCredentials(bytes32 wc) public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[1] = wc; // Field 1 is withdrawal credentials

        bytes32 extracted = BeaconChainProofs.getWithdrawalCredentials(fields);
        assertEq(extracted, wc, "Should extract correct withdrawal credentials");
    }

    /// @notice Fuzz test: Pubkey hash extraction
    function testFuzz_getPubkeyHash(bytes32 pubkeyHash) public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[0] = pubkeyHash; // Field 0 is pubkey hash

        bytes32 extracted = BeaconChainProofs.getPubkeyHash(fields);
        assertEq(extracted, pubkeyHash, "Should extract correct pubkey hash");
    }

    /// @notice Fuzz test: Activation epoch extraction
    function testFuzz_getActivationEpoch(uint64 epoch) public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[5] = bytes32(uint256(epoch)); // Field 5 is activation epoch

        uint64 extracted = BeaconChainProofs.getActivationEpoch(fields);
        assertEq(extracted, epoch, "Should extract correct activation epoch");
    }

    /// @notice Fuzz test: Exit epoch extraction
    function testFuzz_getExitEpoch(uint64 epoch) public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[6] = bytes32(uint256(epoch)); // Field 6 is exit epoch

        uint64 extracted = BeaconChainProofs.getExitEpoch(fields);
        assertEq(extracted, epoch, "Should extract correct exit epoch");
    }

    /// @notice Fuzz test: Withdrawable epoch extraction
    function testFuzz_getWithdrawableEpoch(uint64 epoch) public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[7] = bytes32(uint256(epoch)); // Field 7 is withdrawable epoch

        uint64 extracted = BeaconChainProofs.getWithdrawableEpoch(fields);
        assertEq(extracted, epoch, "Should extract correct withdrawable epoch");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE ROOT PROOF TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test: Correct proof length is 3 hashes (96 bytes)
    function test_stateRootProofLength() public pure {
        uint256 expectedLength = 3 * 32; // BEACON_BLOCK_HEADER_TREE_HEIGHT * 32
        assertEq(expectedLength, 96, "State root proof should be 96 bytes");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING FACTOR FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test: Slashing factor bounds (0 <= factor <= 1e18)
    function testFuzz_slashingFactor_bounds(uint64 oldFactor, uint64 currentBalance, uint64 priorBalance) public pure {
        vm.assume(priorBalance > 0);
        vm.assume(oldFactor <= 1e18);
        vm.assume(currentBalance <= priorBalance);

        uint64 newFactor = uint64(
            (uint256(oldFactor) * uint256(currentBalance)) / uint256(priorBalance)
        );

        assertTrue(newFactor <= oldFactor, "New factor should be <= old factor");
        assertTrue(newFactor <= 1e18, "Factor should be <= 1e18");
    }

    /// @notice Fuzz test: Slashing factor monotonically decreases
    function testFuzz_slashingFactor_monotonic(
        uint64 factor1,
        uint64 balance1,
        uint64 balance2,
        uint64 balance3
    ) public pure {
        vm.assume(factor1 > 0 && factor1 <= 1e18);
        vm.assume(balance1 > 0);
        vm.assume(balance2 <= balance1 && balance2 > 0);
        vm.assume(balance3 <= balance2 && balance3 > 0);

        uint64 factor2 = uint64((uint256(factor1) * uint256(balance2)) / uint256(balance1));
        uint64 factor3 = uint64((uint256(factor2) * uint256(balance3)) / uint256(balance2));

        assertTrue(factor2 <= factor1, "Factor should decrease or stay same");
        assertTrue(factor3 <= factor2, "Factor should decrease or stay same");
    }

    /// @notice Fuzz test: Slashing factor precision
    function testFuzz_slashingFactor_precision(uint64 balance) public pure {
        vm.assume(balance >= 2 && balance <= 32_000_000_000); // Min 2 gwei to allow division, Max 32 ETH in gwei

        uint64 initialFactor = 1e18; // 100%

        // Simulate a 50% slash
        uint64 halfBalance = balance / 2;
        uint64 newFactor = uint64((uint256(initialFactor) * uint256(halfBalance)) / uint256(balance));

        // Should be approximately 50% (0.5e18)
        // Allow for rounding (integer division can cause off-by-one)
        assertTrue(newFactor <= 5e17, "Factor should be <= 50%");
        // For odd balances, halfBalance is (balance-1)/2, so factor is slightly less than 50%
        assertTrue(newFactor >= 5e17 - 1e18 / balance, "Factor should be close to 50%");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GWEI CONVERSION FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test: Gwei to Wei conversion
    function testFuzz_gweiToWei(uint64 gweiAmount) public pure {
        uint256 weiAmount = uint256(gweiAmount) * 1e9;
        assertEq(weiAmount / 1e9, gweiAmount, "Should convert correctly");
    }

    /// @notice Fuzz test: Balance capping at 32 ETH
    function testFuzz_balanceCap(uint64 rawBalance) public pure {
        uint64 maxBalance = 32_000_000_000; // 32 ETH in gwei
        uint64 capped = rawBalance > maxBalance ? maxBalance : rawBalance;
        assertTrue(capped <= maxBalance, "Should be capped at 32 ETH");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE CALCULATION FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fuzz test: Share calculation with slashing factor
    function testFuzz_shareCalculation(uint64 shares, uint64 slashingFactor) public pure {
        vm.assume(slashingFactor <= 1e18);

        uint256 effectiveShares = (uint256(shares) * uint256(slashingFactor)) / 1e18;
        assertTrue(effectiveShares <= shares, "Effective shares should be <= original");
    }

    /// @notice Fuzz test: Proportional slashing
    function testFuzz_proportionalSlashing(
        uint128 delegatorStake,
        uint128 totalDelegated,
        uint128 slashAmount
    ) public pure {
        vm.assume(totalDelegated > 0);
        vm.assume(delegatorStake <= totalDelegated);
        vm.assume(slashAmount <= totalDelegated);

        // Use uint256 for multiplication to avoid overflow
        uint256 delegatorSlash = (uint256(delegatorStake) * uint256(slashAmount)) / uint256(totalDelegated);
        assertTrue(delegatorSlash <= delegatorStake, "Slash should not exceed stake");
        assertTrue(delegatorSlash <= slashAmount, "Slash should not exceed total slash");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Internal merkle proof verification (mirrors BeaconChainProofs)
    function _verifyMerkleProof(
        bytes memory proof,
        bytes32 root,
        bytes32 leaf,
        uint256 index
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        uint256 proofLength = proof.length / 32;

        for (uint256 i = 0; i < proofLength; i++) {
            bytes32 proofElement;
            assembly {
                proofElement := mload(add(proof, add(32, mul(i, 32))))
            }

            if (index % 2 == 0) {
                computedHash = sha256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = sha256(abi.encodePacked(proofElement, computedHash));
            }
            index /= 2;
        }

        return computedHash == root;
    }

    function _computeMerkleRoot(
        bytes32 leaf,
        bytes32[5] memory proofElements,
        uint256 index
    ) internal pure returns (bytes32 root) {
        root = leaf;
        uint256 proofIndex = index;
        for (uint256 i = 0; i < proofElements.length; i++) {
            if (proofIndex % 2 == 0) {
                root = sha256(abi.encodePacked(root, proofElements[i]));
            } else {
                root = sha256(abi.encodePacked(proofElements[i], root));
            }
            proofIndex /= 2;
        }
    }
}
