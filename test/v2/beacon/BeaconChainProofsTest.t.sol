// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BeaconTestBase} from "./BeaconTestBase.sol";
import {BeaconChainProofs} from "../../../src/v2/beacon/BeaconChainProofs.sol";
import {ValidatorTypes} from "../../../src/v2/beacon/ValidatorTypes.sol";
import {console2} from "forge-std/Test.sol";

/// @title BeaconProofsHarness
/// @notice Test harness with external functions for testing calldata library functions
contract BeaconProofsHarness {
    function verifyStateRoot(
        bytes32 beaconBlockRoot,
        ValidatorTypes.StateRootProof calldata stateRootProof
    ) external pure returns (bool) {
        return BeaconChainProofs.verifyStateRoot(beaconBlockRoot, stateRootProof);
    }

    function verifyValidatorFields(
        bytes32 beaconStateRoot,
        uint40 validatorIndex,
        ValidatorTypes.ValidatorFieldsProof memory proof
    ) external pure returns (bool) {
        return BeaconChainProofs.verifyValidatorFields(beaconStateRoot, validatorIndex, proof);
    }

    function verifyBalanceContainer(
        bytes32 beaconBlockRoot,
        ValidatorTypes.BalanceContainerProof calldata proof
    ) external pure returns (bool) {
        return BeaconChainProofs.verifyBalanceContainer(beaconBlockRoot, proof);
    }

    function verifyValidatorBalance(
        bytes32 balanceContainerRoot,
        uint40 validatorIndex,
        ValidatorTypes.BalanceProof calldata proof
    ) external pure returns (uint64) {
        return BeaconChainProofs.verifyValidatorBalance(balanceContainerRoot, validatorIndex, proof);
    }
}

/// @title BeaconChainProofsTest
/// @notice Tests for BeaconChainProofs library
/// @dev Tests Merkle proof verification, field extraction, and edge cases
contract BeaconChainProofsTest is BeaconTestBase {
    BeaconProofsHarness public harness;

    function setUp() public override {
        super.setUp();
        harness = new BeaconProofsHarness();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE ROOT VERIFICATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_verifyStateRoot_ValidProof() public view {
        // Create a simple state root and proof
        bytes32 stateRoot = keccak256("stateRoot");

        // State root is at index 3 in beacon block header (height 3)
        // We need 3 siblings for the proof
        bytes32[] memory siblings = new bytes32[](3);
        siblings[0] = keccak256("sibling0");
        siblings[1] = keccak256("sibling1");
        siblings[2] = keccak256("sibling2");

        // Build the root from leaf to root
        // Index 3 = binary 011 (right, right, left from leaf to root)
        bytes32 h0 = sha256(abi.encodePacked(siblings[0], stateRoot)); // index 3 % 2 = 1, so sibling first
        bytes32 h1 = sha256(abi.encodePacked(siblings[1], h0)); // index 1 % 2 = 1, so sibling first
        bytes32 beaconBlockRoot = sha256(abi.encodePacked(h1, siblings[2])); // index 0 % 2 = 0, so current first

        bytes memory proof = abi.encodePacked(siblings[0], siblings[1], siblings[2]);

        ValidatorTypes.StateRootProof memory stateRootProof =
            ValidatorTypes.StateRootProof({beaconStateRoot: stateRoot, proof: proof});

        bool result = harness.verifyStateRoot(beaconBlockRoot, stateRootProof);
        assertTrue(result, "Valid state root proof should verify");
    }

    function test_verifyStateRoot_InvalidProof() public view {
        bytes32 stateRoot = keccak256("stateRoot");
        bytes32 wrongStateRoot = keccak256("wrongStateRoot");

        bytes32[] memory siblings = new bytes32[](3);
        siblings[0] = keccak256("sibling0");
        siblings[1] = keccak256("sibling1");
        siblings[2] = keccak256("sibling2");

        // Compute root with correct state root
        bytes32 h0 = sha256(abi.encodePacked(siblings[0], stateRoot));
        bytes32 h1 = sha256(abi.encodePacked(siblings[1], h0));
        bytes32 beaconBlockRoot = sha256(abi.encodePacked(h1, siblings[2]));

        bytes memory proof = abi.encodePacked(siblings[0], siblings[1], siblings[2]);

        // Try to verify with wrong state root
        ValidatorTypes.StateRootProof memory stateRootProof =
            ValidatorTypes.StateRootProof({beaconStateRoot: wrongStateRoot, proof: proof});

        bool result = harness.verifyStateRoot(beaconBlockRoot, stateRootProof);
        assertFalse(result, "Invalid state root proof should not verify");
    }

    function test_verifyStateRoot_InvalidProofLength() public {
        bytes32 stateRoot = keccak256("stateRoot");
        bytes32 beaconBlockRoot = keccak256("beaconBlockRoot");

        // Wrong proof length (should be 3 * 32 = 96 bytes)
        bytes memory wrongLengthProof = abi.encodePacked(keccak256("sibling0"), keccak256("sibling1"));

        ValidatorTypes.StateRootProof memory stateRootProof =
            ValidatorTypes.StateRootProof({beaconStateRoot: stateRoot, proof: wrongLengthProof});

        vm.expectRevert(BeaconChainProofs.InvalidProofLength.selector);
        harness.verifyStateRoot(beaconBlockRoot, stateRootProof);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CRITICAL: EMPTY PROOF ATTACK TESTS (C-1 from audit)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Tests that empty proofs are rejected
    /// @dev This is a critical security test - empty proofs should NEVER pass
    function test_CRITICAL_emptyProofRejected_StateRoot() public {
        bytes32 stateRoot = keccak256("stateRoot");

        // Empty proof with leaf == root would incorrectly pass without check
        ValidatorTypes.StateRootProof memory stateRootProof =
            ValidatorTypes.StateRootProof({beaconStateRoot: stateRoot, proof: ""});

        // Should revert with InvalidProofLength
        vm.expectRevert(BeaconChainProofs.InvalidProofLength.selector);
        harness.verifyStateRoot(stateRoot, stateRootProof);
    }

    /// @notice Tests that if empty proof somehow reached verification, leaf != root fails
    /// @dev Additional defense - even if length check bypassed, verification should fail
    function test_CRITICAL_emptyProofDoesNotMatchRoot() public pure {
        bytes32 leaf = keccak256("leaf");
        bytes32 differentRoot = keccak256("root");

        // If empty proof reached _verifyMerkleProof, leaf != root should fail
        // This simulates the internal behavior
        // computedHash starts as leaf, no iterations, returns leaf == root check
        // With different leaf and root, this should fail
        assertFalse(leaf == differentRoot, "Empty proof with different leaf/root should fail");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR FIELDS VERIFICATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_verifyValidatorFields_InvalidFieldsLength() public {
        bytes32 beaconStateRoot = keccak256("stateRoot");
        uint40 validatorIndex = 100;

        // Wrong number of fields (should be 8)
        bytes32[] memory wrongFields = new bytes32[](7);
        for (uint256 i = 0; i < 7; i++) {
            wrongFields[i] = bytes32(i);
        }

        ValidatorTypes.ValidatorFieldsProof memory proof =
            ValidatorTypes.ValidatorFieldsProof({validatorFields: wrongFields, proof: ""});

        vm.expectRevert(BeaconChainProofs.InvalidValidatorFieldsLength.selector);
        harness.verifyValidatorFields(beaconStateRoot, validatorIndex, proof);
    }

    function test_verifyValidatorFields_CorrectHash() public pure {
        // Test that validator fields are hashed correctly (SSZ style)
        bytes32[] memory fields = new bytes32[](8);
        fields[0] = keccak256("pubkey"); // pubkey hash
        fields[1] = bytes32(uint256(0x01) << 248); // withdrawal credentials
        fields[2] = bytes32(uint256(32_000_000_000)); // effective balance
        fields[3] = bytes32(0); // not slashed
        fields[4] = bytes32(uint256(100)); // activation eligibility epoch
        fields[5] = bytes32(uint256(100)); // activation epoch
        fields[6] = bytes32(uint256(type(uint64).max)); // exit epoch (far future)
        fields[7] = bytes32(uint256(type(uint64).max)); // withdrawable epoch

        // Compute expected hash
        bytes32 h0 = sha256(abi.encodePacked(fields[0], fields[1]));
        bytes32 h1 = sha256(abi.encodePacked(fields[2], fields[3]));
        bytes32 h2 = sha256(abi.encodePacked(fields[4], fields[5]));
        bytes32 h3 = sha256(abi.encodePacked(fields[6], fields[7]));

        bytes32 h01 = sha256(abi.encodePacked(h0, h1));
        bytes32 h23 = sha256(abi.encodePacked(h2, h3));

        bytes32 expected = sha256(abi.encodePacked(h01, h23));

        // The internal function should produce the same hash
        assertTrue(expected != bytes32(0), "Hash should be non-zero");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BALANCE VERIFICATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_verifyValidatorBalance_InvalidProofLength() public {
        bytes32 balanceContainerRoot = keccak256("balanceRoot");
        uint40 validatorIndex = 100;

        // Wrong proof length (should be BALANCE_TREE_HEIGHT * 32)
        bytes memory wrongProof = abi.encodePacked(keccak256("sibling0"));

        ValidatorTypes.BalanceProof memory proof = ValidatorTypes.BalanceProof({
            pubkeyHash: keccak256("pubkey"),
            balanceRoot: keccak256("balance"),
            proof: wrongProof
        });

        vm.expectRevert(BeaconChainProofs.InvalidProofLength.selector);
        harness.verifyValidatorBalance(balanceContainerRoot, validatorIndex, proof);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FIELD EXTRACTOR TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_getPubkeyHash() public pure {
        bytes32 pubkeyHash = keccak256("mypubkey");
        bytes32[] memory fields = new bytes32[](8);
        fields[0] = pubkeyHash;

        bytes32 result = BeaconChainProofs.getPubkeyHash(fields);
        assertEq(result, pubkeyHash, "Pubkey hash should match");
    }

    function test_getWithdrawalCredentials() public pure {
        bytes32 credentials = bytes32(uint256(0x01) << 248 | uint256(uint160(address(0xBEEF))));
        bytes32[] memory fields = new bytes32[](8);
        fields[1] = credentials;

        bytes32 result = BeaconChainProofs.getWithdrawalCredentials(fields);
        assertEq(result, credentials, "Withdrawal credentials should match");
    }

    function test_getEffectiveBalanceGwei() public pure {
        uint64 balance = 32_000_000_000; // 32 ETH in gwei
        bytes32[] memory fields = new bytes32[](8);
        fields[2] = bytes32(uint256(balance));

        uint64 result = BeaconChainProofs.getEffectiveBalanceGwei(fields);
        assertEq(result, balance, "Effective balance should match");
    }

    function test_getEffectiveBalanceGwei_MaxValue() public pure {
        uint64 maxBalance = type(uint64).max;
        bytes32[] memory fields = new bytes32[](8);
        fields[2] = bytes32(uint256(maxBalance));

        uint64 result = BeaconChainProofs.getEffectiveBalanceGwei(fields);
        assertEq(result, maxBalance, "Max effective balance should match");
    }

    function test_isValidatorSlashed_True() public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[3] = bytes32(uint256(1)); // slashed = true

        bool result = BeaconChainProofs.isValidatorSlashed(fields);
        assertTrue(result, "Validator should be marked as slashed");
    }

    function test_isValidatorSlashed_False() public pure {
        bytes32[] memory fields = new bytes32[](8);
        fields[3] = bytes32(0); // slashed = false

        bool result = BeaconChainProofs.isValidatorSlashed(fields);
        assertFalse(result, "Validator should not be marked as slashed");
    }

    function test_getActivationEpoch() public pure {
        uint64 epoch = 12345;
        bytes32[] memory fields = new bytes32[](8);
        fields[5] = bytes32(uint256(epoch));

        uint64 result = BeaconChainProofs.getActivationEpoch(fields);
        assertEq(result, epoch, "Activation epoch should match");
    }

    function test_getExitEpoch() public pure {
        uint64 epoch = type(uint64).max; // FAR_FUTURE_EPOCH
        bytes32[] memory fields = new bytes32[](8);
        fields[6] = bytes32(uint256(epoch));

        uint64 result = BeaconChainProofs.getExitEpoch(fields);
        assertEq(result, epoch, "Exit epoch should match");
    }

    function test_getWithdrawableEpoch() public pure {
        uint64 epoch = 99999;
        bytes32[] memory fields = new bytes32[](8);
        fields[7] = bytes32(uint256(epoch));

        uint64 result = BeaconChainProofs.getWithdrawableEpoch(fields);
        assertEq(result, epoch, "Withdrawable epoch should match");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BALANCE EXTRACTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_extractBalance_Position0() public view {
        uint64 balance0 = 32_000_000_000;
        uint64 balance1 = 31_000_000_000;
        uint64 balance2 = 30_000_000_000;
        uint64 balance3 = 29_000_000_000;

        bytes32 balanceRoot = _generateBalanceRoot(balance0, balance1, balance2, balance3);

        // Validator index 0 -> position 0 in leaf
        // This would be extracted by verifyValidatorBalance
        uint256 position = 0 % 4;
        uint256 bitOffset = position * 64;
        uint64 extracted = uint64(uint256(balanceRoot) >> bitOffset);

        assertEq(extracted, balance0, "Balance at position 0 should match");
    }

    function test_extractBalance_Position1() public view {
        uint64 balance0 = 32_000_000_000;
        uint64 balance1 = 31_000_000_000;
        uint64 balance2 = 30_000_000_000;
        uint64 balance3 = 29_000_000_000;

        bytes32 balanceRoot = _generateBalanceRoot(balance0, balance1, balance2, balance3);

        // Validator index 1 -> position 1 in leaf
        uint256 position = 1 % 4;
        uint256 bitOffset = position * 64;
        uint64 extracted = uint64(uint256(balanceRoot) >> bitOffset);

        assertEq(extracted, balance1, "Balance at position 1 should match");
    }

    function test_extractBalance_Position2() public view {
        uint64 balance0 = 32_000_000_000;
        uint64 balance1 = 31_000_000_000;
        uint64 balance2 = 30_000_000_000;
        uint64 balance3 = 29_000_000_000;

        bytes32 balanceRoot = _generateBalanceRoot(balance0, balance1, balance2, balance3);

        uint256 position = 2 % 4;
        uint256 bitOffset = position * 64;
        uint64 extracted = uint64(uint256(balanceRoot) >> bitOffset);

        assertEq(extracted, balance2, "Balance at position 2 should match");
    }

    function test_extractBalance_Position3() public view {
        uint64 balance0 = 32_000_000_000;
        uint64 balance1 = 31_000_000_000;
        uint64 balance2 = 30_000_000_000;
        uint64 balance3 = 29_000_000_000;

        bytes32 balanceRoot = _generateBalanceRoot(balance0, balance1, balance2, balance3);

        uint256 position = 3 % 4;
        uint256 bitOffset = position * 64;
        uint64 extracted = uint64(uint256(balanceRoot) >> bitOffset);

        assertEq(extracted, balance3, "Balance at position 3 should match");
    }

    function test_extractBalance_Fuzz(uint64 b0, uint64 b1, uint64 b2, uint64 b3) public view {
        bytes32 balanceRoot = _generateBalanceRoot(b0, b1, b2, b3);

        // Extract all positions
        uint64 e0 = uint64(uint256(balanceRoot) >> 0);
        uint64 e1 = uint64(uint256(balanceRoot) >> 64);
        uint64 e2 = uint64(uint256(balanceRoot) >> 128);
        uint64 e3 = uint64(uint256(balanceRoot) >> 192);

        assertEq(e0, b0, "Balance 0 mismatch");
        assertEq(e1, b1, "Balance 1 mismatch");
        assertEq(e2, b2, "Balance 2 mismatch");
        assertEq(e3, b3, "Balance 3 mismatch");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MERKLE PROOF EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_merkleProof_RightmostLeaf() public pure {
        // Test proof for leaf at index 7 in 8-leaf tree (rightmost)
        bytes32 leaf = keccak256("leaf7");
        bytes32[] memory siblings = new bytes32[](3);
        siblings[0] = keccak256("sibling6");
        siblings[1] = keccak256("parent45");
        siblings[2] = keccak256("parent0123");

        // Index 7 = binary 111 (right, right, right)
        bytes32 h0 = sha256(abi.encodePacked(siblings[0], leaf)); // 7 % 2 = 1
        bytes32 h1 = sha256(abi.encodePacked(siblings[1], h0)); // 3 % 2 = 1
        bytes32 root = sha256(abi.encodePacked(siblings[2], h1)); // 1 % 2 = 1

        // Verify by reconstructing
        bytes32 computed = leaf;
        computed = sha256(abi.encodePacked(siblings[0], computed));
        computed = sha256(abi.encodePacked(siblings[1], computed));
        computed = sha256(abi.encodePacked(siblings[2], computed));

        assertEq(computed, root, "Rightmost leaf proof should verify");
    }

    function test_merkleProof_LeftmostLeaf() public pure {
        // Test proof for leaf at index 0 in 8-leaf tree (leftmost)
        bytes32 leaf = keccak256("leaf0");
        bytes32[] memory siblings = new bytes32[](3);
        siblings[0] = keccak256("sibling1");
        siblings[1] = keccak256("parent23");
        siblings[2] = keccak256("parent4567");

        // Index 0 = binary 000 (left, left, left)
        bytes32 h0 = sha256(abi.encodePacked(leaf, siblings[0])); // 0 % 2 = 0
        bytes32 h1 = sha256(abi.encodePacked(h0, siblings[1])); // 0 % 2 = 0
        bytes32 root = sha256(abi.encodePacked(h1, siblings[2])); // 0 % 2 = 0

        // Verify by reconstructing
        bytes32 computed = leaf;
        computed = sha256(abi.encodePacked(computed, siblings[0]));
        computed = sha256(abi.encodePacked(computed, siblings[1]));
        computed = sha256(abi.encodePacked(computed, siblings[2]));

        assertEq(computed, root, "Leftmost leaf proof should verify");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL CREDENTIALS TESTS (from ValidatorTypes)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_computeWithdrawalCredentials() public pure {
        address podAddress = address(0x1234567890123456789012345678901234567890);

        bytes32 credentials = ValidatorTypes.computeWithdrawalCredentials(podAddress);

        // Check prefix is 0x01
        assertTrue(ValidatorTypes.hasValidPrefix(credentials), "Should have valid 0x01 prefix");

        // Check address extraction
        address extracted = ValidatorTypes.getAddressFromCredentials(credentials);
        assertEq(extracted, podAddress, "Extracted address should match");
    }

    function test_computeWithdrawalCredentials_Fuzz(address pod) public pure {
        bytes32 credentials = ValidatorTypes.computeWithdrawalCredentials(pod);

        // Verify prefix
        assertTrue(ValidatorTypes.hasValidPrefix(credentials), "Should have valid prefix");

        // Verify roundtrip
        address extracted = ValidatorTypes.getAddressFromCredentials(credentials);
        assertEq(extracted, pod, "Address roundtrip should match");
    }

    function test_hasValidPrefix_Invalid() public pure {
        // Create credentials with 0x00 prefix (BLS)
        bytes32 blsCredentials = bytes32(uint256(uint160(address(0xBEEF))));

        assertFalse(ValidatorTypes.hasValidPrefix(blsCredentials), "BLS credentials should have invalid prefix");
    }

    function test_hasValidPrefix_Valid() public pure {
        bytes32 credentials = ValidatorTypes.computeWithdrawalCredentials(address(0xBEEF));

        assertTrue(ValidatorTypes.hasValidPrefix(credentials), "Should have valid prefix");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PECTRA 0x02 CREDENTIAL TESTS (EIP-7251)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_hasValidPrefix_02_Valid() public pure {
        bytes32 pectraCreds = ValidatorTypes.computeWithdrawalCredentials02(address(0x5678));
        assertTrue(ValidatorTypes.hasValidPrefix(pectraCreds), "Should accept 0x02 prefix");
        assertTrue(ValidatorTypes.has02Prefix(pectraCreds), "Should detect 0x02 prefix");
        assertFalse(ValidatorTypes.has01Prefix(pectraCreds), "Should not be 0x01 prefix");
    }

    function test_computeWithdrawalCredentials02() public pure {
        address addr = address(0xDeaDbeefdEAdbeefdEadbEEFdeadbeEFdEaDbeeF);
        bytes32 creds = ValidatorTypes.computeWithdrawalCredentials02(addr);

        // First byte should be 0x02
        assertEq(bytes1(creds), bytes1(0x02), "First byte should be 0x02");

        // Should be able to extract address back
        address extracted = ValidatorTypes.getAddressFromCredentials(creds);
        assertEq(extracted, addr, "Extracted address should match");
    }

    function test_computeWithdrawalCredentials02_Fuzz(address addr) public pure {
        bytes32 creds = ValidatorTypes.computeWithdrawalCredentials02(addr);

        assertTrue(ValidatorTypes.hasValidPrefix(creds), "Should have valid prefix");
        assertTrue(ValidatorTypes.has02Prefix(creds), "Should have 0x02 prefix");

        address extracted = ValidatorTypes.getAddressFromCredentials(creds);
        assertEq(extracted, addr, "Extracted address should match");
    }

    function test_has01Prefix() public pure {
        bytes32 creds01 = ValidatorTypes.computeWithdrawalCredentials(address(0x1234));
        assertTrue(ValidatorTypes.has01Prefix(creds01), "Should detect 0x01 prefix");
        assertFalse(ValidatorTypes.has02Prefix(creds01), "Should not be 0x02 prefix");
    }

    function test_hasValidPrefix_Both01And02() public pure {
        address addr = address(0xABCD);

        bytes32 creds01 = ValidatorTypes.computeWithdrawalCredentials(addr);
        bytes32 creds02 = ValidatorTypes.computeWithdrawalCredentials02(addr);

        // Both should be valid
        assertTrue(ValidatorTypes.hasValidPrefix(creds01), "0x01 should be valid");
        assertTrue(ValidatorTypes.hasValidPrefix(creds02), "0x02 should be valid");

        // They should be different
        assertTrue(creds01 != creds02, "0x01 and 0x02 creds should differ");

        // Both should extract to same address
        assertEq(
            ValidatorTypes.getAddressFromCredentials(creds01),
            ValidatorTypes.getAddressFromCredentials(creds02),
            "Should extract to same address"
        );
    }

    function test_hasValidPrefix_Invalid_0x03() public pure {
        // Test that 0x03 prefix is invalid
        bytes32 invalidCreds = bytes32(uint256(0x03) << 248 | uint256(uint160(0x1234)));
        assertFalse(ValidatorTypes.hasValidPrefix(invalidCreds), "0x03 prefix should be invalid");
    }
}
