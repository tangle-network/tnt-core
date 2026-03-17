// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title IShieldedGateway
/// @notice Interface for the shielded payment gateway that bridges
///         protocol-solidity's VAnchor shielded pool with tnt-core services.
/// @dev This is the ONLY new contract surface. protocol-solidity and tnt-core
///      are imported unmodified from their audited codebases.
interface IShieldedGateway {
    // ═══════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Packed VAnchor proof data to avoid stack-too-deep
    struct VAnchorProof {
        bytes proof;
        bytes auxPublicInputs;
        bytes externalData; // abi.encode(CommonExtData)
        bytes publicInputs; // abi.encode(PublicInputs)
        bytes encryptions; // abi.encode(Encryptions)
    }

    /// @notice Service request parameters
    struct ServiceRequestParams {
        uint64 blueprintId;
        address[] operators;
        bytes config;
        address[] permittedCallers;
        uint64 ttl;
        Types.ConfidentialityPolicy confidentiality;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Emitted when a shielded spend funds a new service request
    event ShieldedServiceRequested(uint64 indexed requestId, address indexed pool, uint256 amount);

    /// @notice Emitted when a shielded spend tops up a service escrow
    event ShieldedServiceFunded(uint64 indexed serviceId, address indexed pool, uint256 amount);

    /// @notice Emitted when a shielded spend funds a credit account
    event ShieldedCreditsFunded(bytes32 indexed commitment, address indexed pool, uint256 amount);

    /// @notice Emitted when a new shielded pool is registered
    event PoolRegistered(address indexed token, address indexed pool);

    // ═══════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════

    error PoolNotRegistered(address token);
    error PoolAlreadyRegistered(address token);
    error InvalidSpendAmount();
    error InvalidRecipient();

    // ═══════════════════════════════════════════════════════════════════════
    // POOL MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Register a VAnchorTree pool for a given wrapped token
    /// @param wrappedToken The wrapped token address (the VAnchor's token)
    /// @param pool The VAnchorTree contract address
    function registerPool(address wrappedToken, address pool) external;

    /// @notice Get the pool address for a wrapped token
    function getPool(address wrappedToken) external view returns (address);

    // ═══════════════════════════════════════════════════════════════════════
    // SHIELDED OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Anonymously request a service by spending shielded UTXOs.
    ///         The gateway becomes the service owner, hiding the real requester.
    /// @param anchorProof The VAnchor proof data (proof, extData, nullifiers, commitments)
    /// @param params The tnt-core service request parameters
    /// @return requestId The tnt-core service request ID
    function shieldedRequestService(
        VAnchorProof calldata anchorProof,
        ServiceRequestParams calldata params
    )
        external
        payable
        returns (uint64 requestId);

    /// @notice Anonymously fund an existing service's escrow
    /// @param anchorProof The VAnchor proof data
    /// @param serviceId The service to fund
    function shieldedFundService(VAnchorProof calldata anchorProof, uint64 serviceId) external payable;

    // NOTE: Per-job payments use ShieldedCredits (fund once, sign per job).
    // shieldedSubmitJob was removed — VAnchor withdrawal per job is too expensive
    // and submitJob doesn't pull payment from the caller.

    /// @notice Anonymously fund a prepaid credit account for pay-per-use services.
    ///         ONE ZK proof here enables MANY cheap signature-based job payments later.
    /// @param anchorProof The VAnchor proof data
    /// @param commitment The credit account identifier: keccak256(spendingPubKey, salt)
    /// @param spendingKey The ephemeral ECDSA key authorized to sign spend authorizations
    function shieldedFundCredits(
        VAnchorProof calldata anchorProof,
        bytes32 commitment,
        address spendingKey
    )
        external
        payable;
}
