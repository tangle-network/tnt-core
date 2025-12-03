// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ValidatorTypes} from "./ValidatorTypes.sol";

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
    // CONSTANTS - TREE HEIGHTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Height of beacon block header tree (state_root is at index 3)
    uint256 internal constant BEACON_BLOCK_HEADER_TREE_HEIGHT = 3;

    /// @notice Index of state root in beacon block header
    uint256 internal constant STATE_ROOT_INDEX = 3;

    /// @notice Height of beacon state tree (Deneb fork)
    uint256 internal constant BEACON_STATE_TREE_HEIGHT_DENEB = 5;

    /// @notice Height of beacon state tree (Pectra fork)
    uint256 internal constant BEACON_STATE_TREE_HEIGHT_PECTRA = 6;

    /// @notice Index of validators in beacon state (generalized index)
    uint256 internal constant VALIDATORS_INDEX = 11;

    /// @notice Index of balances in beacon state (generalized index)
    uint256 internal constant BALANCES_INDEX = 12;

    /// @notice Height of validator tree (supports up to 2^40 validators)
    uint256 internal constant VALIDATOR_TREE_HEIGHT = 40;

    /// @notice Height of balance tree (supports up to 2^38 balance entries)
    uint256 internal constant BALANCE_TREE_HEIGHT = 38;

    /// @notice Number of validators per balance leaf (4 validators packed per leaf)
    uint256 internal constant VALIDATORS_PER_BALANCE_LEAF = 4;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidProofLength();
    error InvalidValidatorFieldsLength();
    error ProofVerificationFailed();
    error InvalidWithdrawalCredentials();

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE ROOT VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify that a beacon state root is contained in a beacon block root
    /// @param beaconBlockRoot The beacon block root to verify against
    /// @param stateRootProof The proof containing state root and merkle proof
    /// @return True if verification succeeds
    function verifyStateRoot(
        bytes32 beaconBlockRoot,
        ValidatorTypes.StateRootProof calldata stateRootProof
    ) internal pure returns (bool) {
        // State root is at index 3 in the beacon block header
        // Proof length should be BEACON_BLOCK_HEADER_TREE_HEIGHT * 32 bytes
        if (stateRootProof.proof.length != BEACON_BLOCK_HEADER_TREE_HEIGHT * 32) {
            revert InvalidProofLength();
        }

        return _verifyMerkleProof(
            stateRootProof.proof,
            beaconBlockRoot,
            stateRootProof.beaconStateRoot,
            STATE_ROOT_INDEX
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR FIELDS VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify validator fields against the beacon state root
    /// @param beaconStateRoot The beacon state root
    /// @param validatorIndex The validator's index
    /// @param proof The validator fields and merkle proof
    /// @return True if verification succeeds
    function verifyValidatorFields(
        bytes32 beaconStateRoot,
        uint40 validatorIndex,
        ValidatorTypes.ValidatorFieldsProof memory proof
    ) internal pure returns (bool) {
        if (proof.validatorFields.length != VALIDATOR_FIELDS_LENGTH) {
            revert InvalidValidatorFieldsLength();
        }

        // Hash the validator fields to get the validator leaf
        bytes32 validatorLeaf = _hashValidatorFieldsMemory(proof.validatorFields);

        // Calculate the generalized index for this validator
        // validators is at index 11 in state, then we index into the validator list
        uint256 validatorGeneralizedIndex = (VALIDATORS_INDEX << VALIDATOR_TREE_HEIGHT) | uint256(validatorIndex);

        // Proof goes from validator leaf → validators root → state root
        uint256 expectedProofLength = (VALIDATOR_TREE_HEIGHT + BEACON_STATE_TREE_HEIGHT_DENEB) * 32;
        if (proof.proof.length != expectedProofLength) {
            revert InvalidProofLength();
        }

        return _verifyMerkleProofMemory(
            proof.proof,
            beaconStateRoot,
            validatorLeaf,
            validatorGeneralizedIndex
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BALANCE VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify balance container root against beacon block root
    /// @param beaconBlockRoot The beacon block root
    /// @param proof The balance container proof
    /// @return True if verification succeeds
    function verifyBalanceContainer(
        bytes32 beaconBlockRoot,
        ValidatorTypes.BalanceContainerProof calldata proof
    ) internal pure returns (bool) {
        // Balance container is at index 12 in the beacon state
        // Need to go through: block root → state root → balances root
        uint256 expectedProofLength = (BEACON_BLOCK_HEADER_TREE_HEIGHT + BEACON_STATE_TREE_HEIGHT_DENEB) * 32;
        if (proof.proof.length != expectedProofLength) {
            revert InvalidProofLength();
        }

        // Generalized index for balances in beacon state
        uint256 balancesGeneralizedIndex = BALANCES_INDEX;

        return _verifyMerkleProofFromGeneralizedIndex(
            proof.proof,
            beaconBlockRoot,
            proof.balanceContainerRoot,
            balancesGeneralizedIndex
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
    ) internal pure returns (uint64 balance) {
        // Each balance leaf contains 4 validator balances packed together
        uint256 balanceLeafIndex = validatorIndex / VALIDATORS_PER_BALANCE_LEAF;

        // Verify the balance leaf against balance container root
        if (proof.proof.length != BALANCE_TREE_HEIGHT * 32) {
            revert InvalidProofLength();
        }

        bool valid = _verifyMerkleProof(
            proof.proof,
            balanceContainerRoot,
            proof.balanceRoot,
            balanceLeafIndex
        );

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
        return uint64(uint256(validatorFields[VALIDATOR_EFFECTIVE_BALANCE_INDEX]));
    }

    /// @notice Check if validator is slashed
    function isValidatorSlashed(bytes32[] memory validatorFields) internal pure returns (bool) {
        return validatorFields[VALIDATOR_SLASHED_INDEX] != bytes32(0);
    }

    /// @notice Get activation epoch from validator fields
    function getActivationEpoch(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return uint64(uint256(validatorFields[VALIDATOR_ACTIVATION_EPOCH_INDEX]));
    }

    /// @notice Get exit epoch from validator fields
    function getExitEpoch(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return uint64(uint256(validatorFields[VALIDATOR_EXIT_EPOCH_INDEX]));
    }

    /// @notice Get withdrawable epoch from validator fields
    function getWithdrawableEpoch(bytes32[] memory validatorFields) internal pure returns (uint64) {
        return uint64(uint256(validatorFields[VALIDATOR_WITHDRAWABLE_EPOCH_INDEX]));
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
    function _extractBalanceFromLeaf(
        bytes32 balanceRoot,
        uint40 validatorIndex
    ) internal pure returns (uint64) {
        // Position within the leaf (0-3)
        uint256 position = validatorIndex % VALIDATORS_PER_BALANCE_LEAF;
        // Each balance is 8 bytes (64 bits), little-endian
        uint256 bitOffset = position * 64;
        return uint64(uint256(balanceRoot) >> bitOffset);
    }

    /// @notice Verify a Merkle proof using SHA256
    /// @param proof The concatenated sibling hashes
    /// @param root The expected root
    /// @param leaf The leaf being proven
    /// @param index The index of the leaf in the tree
    function _verifyMerkleProof(
        bytes calldata proof,
        bytes32 root,
        bytes32 leaf,
        uint256 index
    ) internal pure returns (bool) {
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
    function _verifyMerkleProofFromGeneralizedIndex(
        bytes calldata proof,
        bytes32 root,
        bytes32 leaf,
        uint256 generalizedIndex
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        uint256 index = generalizedIndex;

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

    /// @notice Verify a Merkle proof using generalized index (memory version)
    function _verifyMerkleProofMemory(
        bytes memory proof,
        bytes32 root,
        bytes32 leaf,
        uint256 generalizedIndex
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        uint256 index = generalizedIndex;

        for (uint256 i = 0; i < proof.length; i += 32) {
            bytes32 sibling;
            assembly {
                sibling := mload(add(add(proof, 32), i))
            }

            if (index % 2 == 0) {
                computedHash = sha256(abi.encodePacked(computedHash, sibling));
            } else {
                computedHash = sha256(abi.encodePacked(sibling, computedHash));
            }

            index = index / 2;
        }

        return computedHash == root;
    }
}
