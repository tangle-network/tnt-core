// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IShieldedCredits
/// @notice Anonymous prepaid credit accounts for pay-per-use cloud services.
///
/// @dev Flow:
///   1. User does ONE shielded VAnchor withdrawal → funds a credit account (pseudonymous)
///   2. User signs EIP-712 spend authorizations with their ephemeral key (cheap, off-chain)
///   3. Operator serves the request, then claims payment using the signed authorization
///   4. User can top up or withdraw remaining credits at any time
///
///   This matches Vitalik's "ZK API Usage Credits" spec: deposit once, use many times,
///   service provider gets paid but never knows who you are.
interface IShieldedCredits {
    // ═══════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice View of a credit account's state
    struct CreditAccountView {
        address spendingKey;
        address token;
        uint256 balance;
        uint256 totalFunded;
        uint256 totalSpent;
        uint256 nonce;
    }

    /// @notice Spend authorization signed by the ephemeral key
    struct SpendAuth {
        bytes32 commitment;
        uint64 serviceId;
        uint8 jobIndex;
        uint256 amount;
        address operator; // Designated recipient — only this address can claim
        uint256 nonce;
        uint64 expiry;
        bytes signature;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════

    event CreditsFunded(bytes32 indexed commitment, address indexed token, uint256 amount, uint256 newBalance);
    event CreditsSpent(bytes32 indexed commitment, bytes32 indexed authHash, uint256 amount, uint256 remaining);
    event PaymentClaimed(bytes32 indexed authHash, address indexed operator, uint256 amount);
    event CreditsWithdrawn(bytes32 indexed commitment, address indexed recipient, uint256 amount);
    event CreditsReclaimed(bytes32 indexed authHash, bytes32 indexed commitment, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════

    error AccountNotFound(bytes32 commitment);
    error InsufficientCredits(uint256 available, uint256 requested);
    error InvalidSignature();
    error InvalidNonce(uint256 expected, uint256 got);
    error SpendExpired(uint64 expiry, uint256 currentTime);
    error SpendingKeyMismatch(address expected, address got);
    error AlreadyClaimed(bytes32 authHash);
    error NotDesignatedOperator(address expected, address got);
    error AuthNotFound(bytes32 authHash);
    error TokenMismatch(address expected, address got);
    error OperatorRequired();
    error NotExpiredYet(uint64 expiry, uint256 currentTime);

    // ═══════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Fund a credit account. Called by ShieldedGateway after VAnchor withdrawal.
    /// @param token The ERC20 token being deposited (wrapped pool token)
    /// @param amount The amount to fund
    /// @param commitment The credit account identifier: keccak256(spendingPubKey, salt)
    /// @param spendingKey The ephemeral ECDSA public key authorized to sign spends
    function fundCredits(address token, uint256 amount, bytes32 commitment, address spendingKey) external;

    /// @notice Authorize a spend and record it for later claim by an operator.
    /// @param auth The spend authorization with EIP-712 signature
    /// @return authHash The unique identifier for this spend authorization
    function authorizeSpend(SpendAuth calldata auth) external returns (bytes32 authHash);

    /// @notice Claim payment for a completed spend authorization.
    /// @param authHash The spend authorization hash
    /// @param recipient The address to receive payment (typically the operator)
    function claimPayment(bytes32 authHash, address recipient) external;

    /// @notice Withdraw unused credits back to an arbitrary address.
    /// @param commitment The credit account identifier
    /// @param recipient Where to send the tokens
    /// @param amount Amount to withdraw
    /// @param nonce Must match the account's current nonce
    /// @param signature EIP-712 signature from the spending key
    function withdrawCredits(
        bytes32 commitment,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    )
        external;

    /// @notice Reclaim funds from an expired spend authorization back to the credit account.
    /// @param authHash The spend authorization hash
    /// @param commitment The credit account identifier to return funds to
    function reclaimExpiredAuth(bytes32 authHash, bytes32 commitment) external;

    /// @notice View a credit account's state
    function getAccount(bytes32 commitment) external view returns (CreditAccountView memory);

    /// @notice View a pending spend authorization
    function getSpendAuth(bytes32 authHash)
        external
        view
        returns (uint256 amount, address token, address operator, uint64 expiry, bool claimed);
}
