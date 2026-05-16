// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ValidatorTypes } from "./ValidatorTypes.sol";

/// @title BeaconChainProofs
/// @notice Library for verifying Merkle proofs against beacon chain state
/// @dev Adapted from EigenLayer's BeaconChainProofs.sol
///      Uses SHA256 for Merkle proof verification (beacon chain standard)
library BeaconChainProofs {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS - VALIDATOR FIELD INDICES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Index of pubkey in validator container
    uint256 internal constant VALIDATOR_PUBKEY_INDEX = 0;
    /// @notice Index of withdrawal credentials in validator container
    uint256 internal constant VALIDATOR_WITHDRAWAL_CREDENTIALS_INDEX = 1;
    /// @notice Index of effective balance in validator container
    uint256 internal constant VALIDATOR_EFFECTIVE_BALANCE_INDEX = 2;
    /// @notice Index of slashed flag in validator container
    uint256 internal constant VALIDATOR_SLASHED_INDEX = 3;
    /// @notice Index of activation eligibility epoch
    uint256 internal constant VALIDATOR_ACTIVATION_ELIGIBILITY_EPOCH_INDEX = 4;
    /// @notice Index of activation epoch
    uint256 internal constant VALIDATOR_ACTIVATION_EPOCH_INDEX = 5;
    /// @notice Index of exit epoch
    uint256 internal constant VALIDATOR_EXIT_EPOCH_INDEX = 6;
    /// @notice Index of withdrawable epoch
    uint256 internal constant VALIDATOR_WITHDRAWABLE_EPOCH_INDEX = 7;

    /// @notice Number of fields in a validator container
    uint256 internal constant VALIDATOR_FIELDS_LENGTH = 8;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS - TREE HEIGHTS AND INDICES (SSZ Spec)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Height of beacon block header tree (state_root is at index 3)
    uint256 internal constant BEACON_BLOCK_HEADER_TREE_HEIGHT = 3;

    /// @notice Index of state root in beacon block header (generalized index)
    uint256 internal constant STATE_ROOT_INDEX = 3;

    /// @notice Height of beacon state tree.
    /// @dev Electra/Pectra (live on Ethereum mainnet since May 2025) has 36-37 fields,
    ///      requiring height 6 (next power of two = 64). Pre-Pectra (Deneb) was 5.
    ///      Base mainnet launches against post-Pectra L1 only; we hardcode 6.
    uint256 internal constant BEACON_STATE_TREE_HEIGHT = 6;

    /// @notice Index of validators list in beacon state (field index 11)
    /// @dev In SSZ, generalized index = 2^depth + field_index = 32 + 11 = 43
    uint256 internal constant VALIDATOR_LIST_INDEX = 11;

    /// @notice Index of balances list in beacon state (field index 12)
    /// @dev Generalized index = 32 + 12 = 44
    uint256 internal constant BALANCE_LIST_INDEX = 12;

    /// @notice Height of validator tree (supports up to 2^40 validators)
    uint256 internal constant VALIDATOR_TREE_HEIGHT = 40;

    /// @notice Height of balance tree (supports up to 2^38 balance entries since 4 per leaf)
    uint256 internal constant BALANCE_TREE_HEIGHT = 38;

    /// @notice Number of validators per balance leaf (4 x 8-byte balances = 32 bytes)
    uint256 internal constant VALIDATORS_PER_BALANCE_LEAF = 4;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS - PROOF AGE LIMITS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Maximum age for beacon chain proofs (8192 slots = ~1 day)
    /// @dev EIP-4788 stores beacon block roots for 8191 slots (~27 hours).
    ///      We use 8192 slots (~1 day) as a conservative limit.
    ///      Proofs older than this should be rejected to prevent replay attacks.
    uint256 internal constant MAX_PROOF_AGE_SLOTS = 8192;

    /// @notice Seconds per slot on the beacon chain (12 seconds)
    uint256 internal constant SECONDS_PER_SLOT = 12;

    /// @notice Maximum proof age in seconds (~1 day = 8192 * 12 = 98304 seconds)
    uint256 internal constant MAX_PROOF_AGE = MAX_PROOF_AGE_SLOTS * SECONDS_PER_SLOT;

    /// @notice Generalized index for validator container root in beacon state.
    /// @dev (1 << BEACON_STATE_TREE_HEIGHT) | VALIDATOR_LIST_INDEX = (1 << 6) | 11 = 75.
    uint256 internal constant VALIDATOR_CONTAINER_GINDEX = 75;

    /// @notice Generalized index for balance container root in beacon state.
    /// @dev (1 << BEACON_STATE_TREE_HEIGHT) | BALANCE_LIST_INDEX = (1 << 6) | 12 = 76.
    uint256 internal constant BALANCE_CONTAINER_GINDEX = 76;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidProofLength();
    error InvalidValidatorFieldsLength();
    error ProofVerificationFailed();
    error InvalidWithdrawalCredentials();
    error EmptyProof();
    /// @notice Beacon block root is zero (invalid or genesis block)
    error InvalidBeaconBlockRoot();
    /// @notice State root is zero (invalid proof data)
    error InvalidStateRoot();
    /// @notice Proof timestamp is too old (exceeds MAX_PROOF_AGE)
    error ProofTooOld(uint64 proofTimestamp, uint64 currentTimestamp);

    // ═══════════════════════════════════════════════════════════════════════════
    // PROOF AGE VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Validate that a proof timestamp is not too old
    /// @param proofTimestamp The timestamp of the beacon block the proof is against
    /// @param currentTimestamp The current block timestamp
    /// @dev Reverts with ProofTooOld if the proof exceeds MAX_PROOF_AGE
    function validateProofAge(uint64 proofTimestamp, uint64 currentTimestamp) internal pure {
        if (currentTimestamp > proofTimestamp + MAX_PROOF_AGE) {
            revert ProofTooOld(proofTimestamp, currentTimestamp);
        }
    }

    /// @notice Check if a proof timestamp is within the valid age range
    /// @param proofTimestamp The timestamp of the beacon block the proof is against
    /// @param currentTimestamp The current block timestamp
    /// @return True if the proof is not too old
    function isProofAgeValid(uint64 proofTimestamp, uint64 currentTimestamp) internal pure returns (bool) {
        return currentTimestamp <= proofTimestamp + MAX_PROOF_AGE;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE ROOT VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify that a beacon state root is contained in a beacon block root
    /// @param beaconBlockRoot The beacon block root to verify against
    /// @param stateRootProof The proof containing state root and merkle proof
    /// @return True if verification succeeds
    /// @dev Added validation for zero beacon block root (genesis block edge case)
    ///      and zero state root to prevent invalid proof acceptance
    function verifyStateRoot(
        bytes32 beaconBlockRoot,
        ValidatorTypes.StateRootProof calldata stateRootProof
    )
        internal
        pure
        returns (bool)
    {
        // Reject zero beacon block root (could be genesis block or invalid root)
        // EIP-4788 returns 0 for timestamps before the fork or invalid timestamps
        if (beaconBlockRoot == bytes32(0)) {
            revert InvalidBeaconBlockRoot();
        }

        // Reject zero state root as it indicates invalid proof data
        if (stateRootProof.beaconStateRoot == bytes32(0)) {
            revert InvalidStateRoot();
        }

        // State root is at index 3 in the beacon block header
        // Proof length should be BEACON_BLOCK_HEADER_TREE_HEIGHT * 32 bytes
        if (stateRootProof.proof.length != BEACON_BLOCK_HEADER_TREE_HEIGHT * 32) {
            revert InvalidProofLength();
        }

        return
            _verifyMerkleProof(stateRootProof.proof, beaconBlockRoot, stateRootProof.beaconStateRoot, STATE_ROOT_INDEX);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR FIELDS VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify validator fields against the beacon state root
    /// @param beaconStateRoot The beacon state root (already verified against block root)
    /// @param validatorIndex The validator's index
    /// @param proof The validator fields and merkle proof
    /// @return True if verification succeeds
    function verifyValidatorFields(
        bytes32 beaconStateRoot,
        uint40 validatorIndex,
        ValidatorTypes.ValidatorFieldsProof memory proof
    )
        internal
        pure
        returns (bool)
    {
        if (proof.validatorFields.length != VALIDATOR_FIELDS_LENGTH) {
            revert InvalidValidatorFieldsLength();
        }

        // Hash the validator fields to get the validator leaf
        bytes32 validatorLeaf = _hashValidatorFieldsMemory(proof.validatorFields);

        // Calculate the generalized index for this validator
        // The validator is in a merkleized list at index VALIDATOR_CONTAINER_GINDEX in state
        // Within the list, we need to traverse VALIDATOR_TREE_HEIGHT levels to reach the validator
        // Generalized index = (VALIDATOR_CONTAINER_GINDEX << VALIDATOR_TREE_HEIGHT) | validatorIndex
        //
        // This creates a path: state root -> validators container -> specific validator
        uint256 validatorGIndex = (VALIDATOR_CONTAINER_GINDEX << VALIDATOR_TREE_HEIGHT) | uint256(validatorIndex);

        // Proof length: VALIDATOR_TREE_HEIGHT (within list) + BEACON_STATE_TREE_HEIGHT (to state root)
        uint256 expectedProofLength = (VALIDATOR_TREE_HEIGHT + BEACON_STATE_TREE_HEIGHT) * 32;
        if (proof.proof.length != expectedProofLength) {
            revert InvalidProofLength();
        }

        return _verifyMerkleProofFromGIndexMemory(proof.proof, beaconStateRoot, validatorLeaf, validatorGIndex);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BALANCE VERIFICATION (Two-step: block -> state -> balances)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify balance container root against beacon state root
    /// @param beaconStateRoot The beacon state root (must be verified separately against block root)
    /// @param proof The balance container proof
    /// @return True if verification succeeds
    /// @dev Now correctly verifies against state root, not block root
    function verifyBalanceContainer(
        bytes32 beaconStateRoot,
        ValidatorTypes.BalanceContainerProof calldata proof
    )
        internal
        pure
        returns (bool)
    {
        // Balance container is at generalized index 44 in the beacon state
        // Proof length: BEACON_STATE_TREE_HEIGHT levels to reach balances from state root
        uint256 expectedProofLength = BEACON_STATE_TREE_HEIGHT * 32;
        if (proof.proof.length != expectedProofLength) {
            revert InvalidProofLength();
        }

        return _verifyMerkleProofFromGIndex(
            proof.proof, beaconStateRoot, proof.balanceContainerRoot, BALANCE_CONTAINER_GINDEX
        );
    }

    /// @notice Verify a validator's balance within the balance container
    /// @param balanceContainerRoot The root of the balance container
    /// @param validatorIndex The validator's index
    /// @param proof The balance proof
    /// @return balance The validator's balance in gwei
    function verifyValidatorBalance(
        bytes32 balanceContainerRoot,
        uint40 validatorIndex,
        ValidatorTypes.BalanceProof calldata proof
    )
        internal
        pure
        returns (uint64 balance)
    {
        // Each balance leaf contains 4 validator balances packed together
        // Leaf index = validatorIndex / 4
        uint256 balanceLeafIndex = validatorIndex / VALIDATORS_PER_BALANCE_LEAF;

        // Verify the balance leaf against balance container root
        if (proof.proof.length != BALANCE_TREE_HEIGHT * 32) {
            revert InvalidProofLength();
        }

        bool valid = _verifyMerkleProof(proof.proof, balanceContainerRoot, proof.balanceRoot, balanceLeafIndex);

        if (!valid) {
            revert ProofVerificationFailed();
        }

        // Extract the specific validator's balance from the leaf
        // Each leaf contains 4 64-bit balances packed into 32 bytes
        balance = _extractBalanceFromLeaf(proof.balanceRoot, validatorIndex);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FIELD EXTRACTORS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pubkey hash from validator fields
    function getPubkeyHash(bytes32[] memory validatorFields) internal pure returns (bytes32) {
        return validatorFields[VALIDATOR_PUBKEY_INDEX];
    }

    /// @notice Get withdrawal credentials from validator fields
    function getWithdrawalCredentials(bytes32[] memory validatorFields) internal pure returns (bytes32) {
        return validatorFields[VALIDATOR_WITHDRAWAL_CREDENTIALS_INDEX];
    }

    /// @notice Get effective balance from validator fields (in gwei)
    function getEffectiveBalanceGwei(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return _fromLittleEndianUint64(validatorFields[VALIDATOR_EFFECTIVE_BALANCE_INDEX]);
    }

    /// @notice Check if validator is slashed
    function isValidatorSlashed(bytes32[] memory validatorFields) internal pure returns (bool) {
        return validatorFields[VALIDATOR_SLASHED_INDEX] != bytes32(0);
    }

    /// @notice Get activation epoch from validator fields
    function getActivationEpoch(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return _fromLittleEndianUint64(validatorFields[VALIDATOR_ACTIVATION_EPOCH_INDEX]);
    }

    /// @notice Get exit epoch from validator fields
    function getExitEpoch(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return _fromLittleEndianUint64(validatorFields[VALIDATOR_EXIT_EPOCH_INDEX]);
    }

    /// @notice Get withdrawable epoch from validator fields
    function getWithdrawableEpoch(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return _fromLittleEndianUint64(validatorFields[VALIDATOR_WITHDRAWABLE_EPOCH_INDEX]);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Hash validator fields to create the validator leaf (calldata version)
    function _hashValidatorFields(bytes32[] calldata fields) internal pure returns (bytes32) {
        // Hash pairs of fields, then hash those results, etc.
        // Validator has 8 fields, so we need 3 levels of hashing
        bytes32 h0 = sha256(abi.encodePacked(fields[0], fields[1]));
        bytes32 h1 = sha256(abi.encodePacked(fields[2], fields[3]));
        bytes32 h2 = sha256(abi.encodePacked(fields[4], fields[5]));
        bytes32 h3 = sha256(abi.encodePacked(fields[6], fields[7]));

        bytes32 h01 = sha256(abi.encodePacked(h0, h1));
        bytes32 h23 = sha256(abi.encodePacked(h2, h3));

        return sha256(abi.encodePacked(h01, h23));
    }

    /// @notice Hash validator fields to create the validator leaf (memory version)
    function _hashValidatorFieldsMemory(bytes32[] memory fields) internal pure returns (bytes32) {
        bytes32 h0 = sha256(abi.encodePacked(fields[0], fields[1]));
        bytes32 h1 = sha256(abi.encodePacked(fields[2], fields[3]));
        bytes32 h2 = sha256(abi.encodePacked(fields[4], fields[5]));
        bytes32 h3 = sha256(abi.encodePacked(fields[6], fields[7]));

        bytes32 h01 = sha256(abi.encodePacked(h0, h1));
        bytes32 h23 = sha256(abi.encodePacked(h2, h3));

        return sha256(abi.encodePacked(h01, h23));
    }

    /// @notice Extract a single validator's balance from a packed balance leaf
    /// @param balanceRoot The 32-byte leaf containing 4 packed balances
    /// @param validatorIndex The validator's global index
    /// @return The 64-bit balance in gwei
    /// @dev SSZ packs four uint64 balances into a single 32-byte chunk:
    ///      bytes[0..7]   = LE bytes of balance0
    ///      bytes[8..15]  = LE bytes of balance1
    ///      bytes[16..23] = LE bytes of balance2
    ///      bytes[24..31] = LE bytes of balance3
    ///      `bytes32` cast to `uint256` puts byte[0] in the most-significant
    ///      position, so we must shift the right 8-byte window down to the low
    ///      64 bits and then byte-swap from little-endian to the EVM's
    ///      big-endian uint64. The previous implementation read bytes[24..31]
    ///      for position 0 (wrong byte AND wrong endianness).
    function _extractBalanceFromLeaf(bytes32 balanceRoot, uint40 validatorIndex) internal pure returns (uint64) {
        // Position within the leaf (0-3)
        uint256 position = validatorIndex % VALIDATORS_PER_BALANCE_LEAF;
        // Shift target byte window into the low 64 bits.
        //   position 0 -> shift 192 (bytes[0..7])
        //   position 1 -> shift 128 (bytes[8..15])
        //   position 2 -> shift  64 (bytes[16..23])
        //   position 3 -> shift   0 (bytes[24..31])
        uint256 shift = 192 - position * 64;
        // forge-lint: disable-next-line(unsafe-typecast)
        uint64 leBytes = uint64(uint256(balanceRoot) >> shift);
        return _reverseUint64(leBytes);
    }

    /// @notice Decode a single SSZ-packed uint64 from the head of a 32-byte chunk.
    /// @dev SSZ encodes a standalone uint64 as 8 little-endian bytes followed by
    ///      24 zero bytes. Cast `bytes32 -> uint256` puts the LE bytes in the
    ///      top 64 bits, so we shift down and byte-swap.
    function _fromLittleEndianUint64(bytes32 chunk) internal pure returns (uint64) {
        // forge-lint: disable-next-line(unsafe-typecast)
        uint64 leBytes = uint64(uint256(chunk) >> 192);
        return _reverseUint64(leBytes);
    }

    /// @notice Byte-swap a uint64 (little-endian <-> big-endian).
    function _reverseUint64(uint64 n) internal pure returns (uint64) {
        return ((n & 0x00000000000000FF) << 56)
             | ((n & 0x000000000000FF00) << 40)
             | ((n & 0x0000000000FF0000) << 24)
             | ((n & 0x00000000FF000000) << 8)
             | ((n & 0x000000FF00000000) >> 8)
             | ((n & 0x0000FF0000000000) >> 24)
             | ((n & 0x00FF000000000000) >> 40)
             | ((n & 0xFF00000000000000) >> 56);
    }

    /// @notice Verify a Merkle proof using SHA256 with simple index
    /// @param proof The concatenated sibling hashes
    /// @param root The expected root
    /// @param leaf The leaf being proven
    /// @param index The index of the leaf in the tree
    function _verifyMerkleProof(
        bytes calldata proof,
        bytes32 root,
        bytes32 leaf,
        uint256 index
    )
        internal
        pure
        returns (bool)
    {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i += 32) {
            bytes32 sibling = bytes32(proof[i:i + 32]);

            if (index % 2 == 0) {
                computedHash = sha256(abi.encodePacked(computedHash, sibling));
            } else {
                computedHash = sha256(abi.encodePacked(sibling, computedHash));
            }

            index = index / 2;
        }

        return computedHash == root;
    }

    /// @notice Verify a Merkle proof using generalized index
    /// @dev Generalized index encodes the path from root to leaf
    ///      The lowest bit determines left/right at the first level,
    ///      second lowest at second level, etc.
    function _verifyMerkleProofFromGIndex(
        bytes calldata proof,
        bytes32 root,
        bytes32 leaf,
        uint256 gindex
    )
        internal
        pure
        returns (bool)
    {
        bytes32 computedHash = leaf;

        // Number of levels = log2(gindex) = position of highest bit
        // We process from leaf upward, using the bits of gindex to determine left/right
        for (uint256 i = 0; i < proof.length; i += 32) {
            bytes32 sibling = bytes32(proof[i:i + 32]);

            // If gindex is odd, we are on the right, so sibling is on left
            if (gindex % 2 == 1) {
                computedHash = sha256(abi.encodePacked(sibling, computedHash));
            } else {
                computedHash = sha256(abi.encodePacked(computedHash, sibling));
            }

            gindex = gindex / 2;
        }

        return computedHash == root;
    }

    /// @notice Verify a Merkle proof using generalized index (memory version)
    function _verifyMerkleProofFromGIndexMemory(
        bytes memory proof,
        bytes32 root,
        bytes32 leaf,
        uint256 gindex
    )
        internal
        pure
        returns (bool)
    {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i += 32) {
            bytes32 sibling;
            assembly {
                sibling := mload(add(add(proof, 32), i))
            }

            if (gindex % 2 == 1) {
                computedHash = sha256(abi.encodePacked(sibling, computedHash));
            } else {
                computedHash = sha256(abi.encodePacked(computedHash, sibling));
            }

            gindex = gindex / 2;
        }

        return computedHash == root;
    }
}
