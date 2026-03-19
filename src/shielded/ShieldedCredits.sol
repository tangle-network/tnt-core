// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { IShieldedCredits } from "./IShieldedCredits.sol";

/// @title ShieldedCredits
/// @author Tangle Network
/// @notice Anonymous prepaid credit accounts for pay-per-use services.
///
/// @dev Implements Vitalik's "ZK API Usage Credits" pattern:
///      - ONE on-chain ZK proof to fund credits (via ShieldedGateway + VAnchor)
///      - MANY cheap off-chain signatures to authorize spending per job
///      - Operators claim payment after serving requests
///
/// @dev AUDIT SURFACE: ~200 lines of new logic. Key security properties:
///      - Spending key is immutable after first funding (prevents re-keying attacks)
///      - Strict nonce ordering prevents replay and double-spend
///      - EIP-712 typed signatures prevent cross-domain replay
///      - Balance checks are pre-deduction (no underflow)
///      - Claims are idempotent (double-claim reverts, not double-pays)
///      - No commitment-to-identity linkage stored
contract ShieldedCredits is IShieldedCredits, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════
    // EIP-712
    // ═══════════════════════════════════════════════════════════════════════

    bytes32 public constant SPEND_TYPEHASH = keccak256(
        "SpendAuthorization(bytes32 commitment,uint64 serviceId,uint8 jobIndex,uint256 amount,address operator,uint256 nonce,uint64 expiry)"
    );

    bytes32 public constant WITHDRAW_TYPEHASH =
        keccak256("WithdrawCredits(bytes32 commitment,address recipient,uint256 amount,uint256 nonce)");

    bytes32 public immutable DOMAIN_SEPARATOR;

    // ═══════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════

    struct CreditAccount {
        address spendingKey;
        address token;
        uint256 balance;
        uint256 totalFunded;
        uint256 totalSpent;
        uint256 nonce;
    }

    /// @notice commitment => CreditAccount
    mapping(bytes32 => CreditAccount) internal _accounts;

    struct PendingSpend {
        uint256 amount;
        address token;
        address operator;
        uint64 expiry;
        bool claimed;
    }

    /// @notice authHash => pending spend data
    mapping(bytes32 => PendingSpend) internal _pendingSpends;

    // ═══════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════

    constructor() {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("ShieldedCredits"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FUNDING
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedCredits
    function fundCredits(address token, uint256 amount, bytes32 commitment, address spendingKey) external nonReentrant {
        if (amount == 0) revert InsufficientCredits(0, 0);
        if (spendingKey == address(0)) revert InvalidSignature();

        CreditAccount storage acct = _accounts[commitment];

        if (acct.spendingKey == address(0)) {
            // New account
            acct.spendingKey = spendingKey;
            acct.token = token;
        } else {
            // Top-up: spending key must match
            if (acct.spendingKey != spendingKey) {
                revert SpendingKeyMismatch(acct.spendingKey, spendingKey);
            }
            if (acct.token != token) {
                revert TokenMismatch(acct.token, token);
            }
        }

        // Pull tokens from caller (ShieldedGateway or direct funder)
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        acct.balance += amount;
        acct.totalFunded += amount;

        emit CreditsFunded(commitment, token, amount, acct.balance);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SPENDING
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedCredits
    function authorizeSpend(SpendAuth calldata auth) external nonReentrant returns (bytes32 authHash) {
        if (auth.operator == address(0)) revert OperatorRequired();

        CreditAccount storage acct = _accounts[auth.commitment];
        if (acct.spendingKey == address(0)) revert AccountNotFound(auth.commitment);
        if (block.timestamp > auth.expiry) revert SpendExpired(auth.expiry, block.timestamp);
        if (auth.nonce != acct.nonce) revert InvalidNonce(acct.nonce, auth.nonce);
        if (auth.amount > acct.balance) revert InsufficientCredits(acct.balance, auth.amount);

        // Verify EIP-712 signature
        bytes32 structHash = keccak256(
            abi.encode(
                SPEND_TYPEHASH,
                auth.commitment,
                auth.serviceId,
                auth.jobIndex,
                auth.amount,
                auth.operator,
                auth.nonce,
                auth.expiry
            )
        );
        bytes32 digest = MessageHashUtils.toTypedDataHash(DOMAIN_SEPARATOR, structHash);
        address signer = ECDSA.recover(digest, auth.signature);
        if (signer != acct.spendingKey) revert InvalidSignature();

        // Deduct balance and increment nonce
        acct.balance -= auth.amount;
        acct.totalSpent += auth.amount;
        acct.nonce++;

        // Store the authorization for later claim
        authHash = keccak256(abi.encode(auth.commitment, auth.serviceId, auth.jobIndex, auth.nonce));
        _pendingSpends[authHash] = PendingSpend({
            amount: auth.amount, token: acct.token, operator: auth.operator, expiry: auth.expiry, claimed: false
        });

        emit CreditsSpent(auth.commitment, authHash, auth.amount, acct.balance);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CLAIMING
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedCredits
    function claimPayment(bytes32 authHash, address recipient) external nonReentrant {
        PendingSpend storage spend = _pendingSpends[authHash];
        if (spend.amount == 0) revert AuthNotFound(authHash);
        if (spend.claimed) revert AlreadyClaimed(authHash);
        if (block.timestamp > spend.expiry) revert SpendExpired(spend.expiry, block.timestamp);

        // Only the designated operator can claim.
        //
        // NOTE: We intentionally do NOT verify on-chain job completion via tnt-core here.
        // ShieldedCredits operates independently of tnt-core's job lifecycle because:
        //   1. Operators may serve requests off-chain (e.g. private inference) without
        //      submitting results on-chain, which is the primary use case for anonymous credits.
        //   2. The user explicitly authorized this payment by signing a SpendAuth that names
        //      the operator — the EIP-712 signature is the user's attestation that the operator
        //      is trusted to deliver. The operator address gate prevents anyone else from claiming.
        //   3. Coupling to tnt-core would require storing a contract reference and would break
        //      composability — ShieldedCredits can be used with any service backend.
        //   4. The serviceId and jobIndex in the SpendAuth are commitments for off-chain
        //      correlation and auditability, not on-chain enforcement.
        if (msg.sender != spend.operator) revert NotDesignatedOperator(spend.operator, msg.sender);

        spend.claimed = true;

        IERC20(spend.token).safeTransfer(recipient, spend.amount);

        emit PaymentClaimed(authHash, recipient, spend.amount);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // WITHDRAWAL
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedCredits
    function withdrawCredits(
        bytes32 commitment,
        address recipient,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    )
        external
        nonReentrant
    {
        CreditAccount storage acct = _accounts[commitment];
        if (acct.spendingKey == address(0)) revert AccountNotFound(commitment);
        if (nonce != acct.nonce) revert InvalidNonce(acct.nonce, nonce);
        if (amount > acct.balance) revert InsufficientCredits(acct.balance, amount);

        // Verify EIP-712 signature
        bytes32 structHash = keccak256(abi.encode(WITHDRAW_TYPEHASH, commitment, recipient, amount, nonce));
        bytes32 digest = MessageHashUtils.toTypedDataHash(DOMAIN_SEPARATOR, structHash);
        address signer = ECDSA.recover(digest, signature);
        if (signer != acct.spendingKey) revert InvalidSignature();

        acct.balance -= amount;
        acct.nonce++;

        IERC20(acct.token).safeTransfer(recipient, amount);

        emit CreditsWithdrawn(commitment, recipient, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // RECLAIM
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedCredits
    function reclaimExpiredAuth(bytes32 authHash, bytes32 commitment) external nonReentrant {
        PendingSpend storage spend = _pendingSpends[authHash];
        if (spend.amount == 0) revert AuthNotFound(authHash);
        if (spend.claimed) revert AlreadyClaimed(authHash);
        if (block.timestamp <= spend.expiry) revert NotExpiredYet(spend.expiry, block.timestamp);

        uint256 amount = spend.amount;
        spend.claimed = true;

        _accounts[commitment].balance += amount;
        _accounts[commitment].totalSpent -= amount;

        emit CreditsReclaimed(authHash, commitment, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedCredits
    function getAccount(bytes32 commitment) external view returns (CreditAccountView memory) {
        CreditAccount storage acct = _accounts[commitment];
        return CreditAccountView({
            spendingKey: acct.spendingKey,
            token: acct.token,
            balance: acct.balance,
            totalFunded: acct.totalFunded,
            totalSpent: acct.totalSpent,
            nonce: acct.nonce
        });
    }

    /// @inheritdoc IShieldedCredits
    function getSpendAuth(bytes32 authHash)
        external
        view
        returns (uint256 amount, address token, address operator, uint64 expiry, bool claimed)
    {
        PendingSpend storage spend = _pendingSpends[authHash];
        return (spend.amount, spend.token, spend.operator, spend.expiry, spend.claimed);
    }
}
