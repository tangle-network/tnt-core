// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ValidatorTypes
/// @notice Type definitions for beacon chain validator restaking
library ValidatorTypes {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The amount of wei to credit per validator (32 ETH)
    uint256 constant REQUIRED_BALANCE_WEI = 32 ether;

    /// @notice Required balance in gwei (32 ETH)
    uint64 constant REQUIRED_BALANCE_GWEI = 32_000_000_000;

    /// @notice Maximum effective balance for a validator (32 ETH in gwei)
    uint64 constant MAX_EFFECTIVE_BALANCE_GWEI = 32_000_000_000;

    /// @notice Precision for share calculations
    uint256 constant PRECISION = 1e18;

    /// @notice Withdrawal credentials prefix for execution layer addresses (0x01)
    bytes1 constant WITHDRAWAL_CREDENTIALS_PREFIX_01 = 0x01;

    /// @notice Withdrawal credentials prefix for Pectra compounding validators (0x02)
    /// @dev Introduced in EIP-7251 (Pectra upgrade) for validators with >32 ETH effective balance
    bytes1 constant WITHDRAWAL_CREDENTIALS_PREFIX_02 = 0x02;

    /// @dev Legacy alias for 0x01 prefix
    bytes1 constant WITHDRAWAL_CREDENTIALS_PREFIX = WITHDRAWAL_CREDENTIALS_PREFIX_01;

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR STATUS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Status of a validator in the pod
    enum ValidatorStatus {
        INACTIVE,    // Not yet verified or unknown
        ACTIVE,      // Verified and restaked
        WITHDRAWN    // Fully exited from beacon chain
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR INFO
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Information about a validator restaked through a pod
    struct ValidatorInfo {
        /// @notice The validator's index in the beacon chain
        uint64 validatorIndex;
        /// @notice The validator's restaked balance in gwei
        uint64 restakedBalanceGwei;
        /// @notice Timestamp of the last checkpoint that included this validator
        uint64 lastCheckpointedAt;
        /// @notice Current status of the validator
        ValidatorStatus status;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CHECKPOINT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice A checkpoint tracks validator balance updates
    struct Checkpoint {
        /// @notice The beacon block root used for this checkpoint
        bytes32 beaconBlockRoot;
        /// @notice Number of proofs remaining to complete checkpoint
        uint24 proofsRemaining;
        /// @notice Pod's ETH balance at checkpoint start (in gwei)
        uint64 podBalanceGwei;
        /// @notice Running tally of balance changes (can be negative)
        int128 balanceDeltasGwei;
        /// @notice Previous total beacon balance before this checkpoint
        uint64 priorBeaconBalanceGwei;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PROOF STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Proof of beacon state root against beacon block root
    struct StateRootProof {
        /// @notice The beacon state root being proven
        bytes32 beaconStateRoot;
        /// @notice Merkle proof from state root to block root
        bytes proof;
    }

    /// @notice Proof of validator fields against beacon state root
    struct ValidatorFieldsProof {
        /// @notice The 8 validator container fields
        bytes32[] validatorFields;
        /// @notice Merkle proof against beacon state root
        bytes proof;
    }

    /// @notice Proof of balance container against beacon block root
    struct BalanceContainerProof {
        /// @notice Root of the balance container
        bytes32 balanceContainerRoot;
        /// @notice Merkle proof against beacon block root
        bytes proof;
    }

    /// @notice Proof of a single validator's balance
    struct BalanceProof {
        /// @notice Hash of the validator's pubkey
        bytes32 pubkeyHash;
        /// @notice Root containing this validator's balance
        bytes32 balanceRoot;
        /// @notice Merkle proof within balance container
        bytes proof;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL CREDENTIALS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute expected withdrawal credentials for an address
    /// @param addr The address that should receive withdrawals
    /// @return The 32-byte withdrawal credentials (0x01 prefix + 11 zero bytes + address)
    function computeWithdrawalCredentials(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr))) | bytes32(uint256(uint8(WITHDRAWAL_CREDENTIALS_PREFIX)) << 248);
    }

    /// @notice Extract address from withdrawal credentials
    /// @param withdrawalCredentials The 32-byte withdrawal credentials
    /// @return The address (last 20 bytes)
    function getAddressFromCredentials(bytes32 withdrawalCredentials) internal pure returns (address) {
        return address(uint160(uint256(withdrawalCredentials)));
    }

    /// @notice Check if withdrawal credentials have a valid prefix (0x01 or 0x02)
    /// @param withdrawalCredentials The credentials to check
    /// @return True if prefix is 0x01 or 0x02
    function hasValidPrefix(bytes32 withdrawalCredentials) internal pure returns (bool) {
        bytes1 prefix = bytes1(withdrawalCredentials);
        return prefix == WITHDRAWAL_CREDENTIALS_PREFIX_01 || prefix == WITHDRAWAL_CREDENTIALS_PREFIX_02;
    }

    /// @notice Check if withdrawal credentials have the legacy 0x01 prefix
    /// @param withdrawalCredentials The credentials to check
    /// @return True if prefix is 0x01
    function has01Prefix(bytes32 withdrawalCredentials) internal pure returns (bool) {
        return bytes1(withdrawalCredentials) == WITHDRAWAL_CREDENTIALS_PREFIX_01;
    }

    /// @notice Check if withdrawal credentials have the Pectra 0x02 prefix
    /// @param withdrawalCredentials The credentials to check
    /// @return True if prefix is 0x02
    function has02Prefix(bytes32 withdrawalCredentials) internal pure returns (bool) {
        return bytes1(withdrawalCredentials) == WITHDRAWAL_CREDENTIALS_PREFIX_02;
    }

    /// @notice Compute expected 0x02 withdrawal credentials for an address
    /// @dev Used for Pectra validators with compounding enabled
    /// @param addr The address that should receive withdrawals
    /// @return The 32-byte withdrawal credentials (0x02 prefix + 11 zero bytes + address)
    function computeWithdrawalCredentials02(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr))) | bytes32(uint256(uint8(WITHDRAWAL_CREDENTIALS_PREFIX_02)) << 248);
    }
}
