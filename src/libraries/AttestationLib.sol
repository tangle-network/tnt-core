// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title AttestationLib
/// @notice Pure helpers for TEE attestation nonces and BLS proof-of-possession messages.
/// @dev Lives in a library so the same compute can be shared between the approvals path
///      (where it is consumed during validation) and the views facet (where it is exposed
///      as a public read) without forcing the approvals contract to inherit the views
///      facet's bytecode.
library AttestationLib {
    /// @notice Canonical TEE attestation nonce for `requestId` on `verifyingContract` on `chainId`.
    /// @dev Operators MUST set `TeeAttestationCommitment.nonceBinding` to this exact value.
    ///      Cross-request attestation replay is structurally impossible: an attestation
    ///      document binding to nonce N_A cannot satisfy a commitment requiring nonce N_B.
    function teeNonce(uint64 requestId, address verifyingContract, uint256 chainId) internal pure returns (bytes32) {
        return keccak256(abi.encode("tangle.tee.nonce", requestId, verifyingContract, chainId));
    }

    /// @notice Domain-separated message every operator must sign with their BLS secret key
    ///         to register a public key. Bound to chainId + verifying contract + operator
    ///         address so a PoP from one chain or operator cannot be replayed.
    function blsPopMessage(
        address operator,
        uint256[4] memory blsPubkey,
        address verifyingContract,
        uint256 chainId
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encode("TANGLE_BLS_POP_v1", chainId, verifyingContract, operator, blsPubkey);
    }
}
