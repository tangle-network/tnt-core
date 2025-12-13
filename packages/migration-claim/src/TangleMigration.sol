// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IZKVerifier} from "./IZKVerifier.sol";
import {TNTLockFactory} from "./lockups/TNTLockFactory.sol";

/// @title TangleMigration
/// @notice Distribution contract for Tangle network migration
/// @dev Substrate address holders must prove key ownership via ZK proof to claim
contract TangleMigration is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════

    // Merkle leaf format: (bytes32 pubkey, uint256 amount)
    // pubkey is the raw 32-byte SR25519 public key (decoded from SS58)

    // ═══════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice The token being distributed
    IERC20 public immutable token;

    /// @notice The ZK verifier contract
    IZKVerifier public zkVerifier;

    /// @notice Merkle root for the distribution
    bytes32 public merkleRoot;

    /// @notice Tracks claimed amounts per pubkey
    mapping(bytes32 => uint256) public claimed;

    /// @notice Total amount claimed so far
    uint256 public totalClaimed;

    /// @notice Whether claims are paused
    bool public paused;

    /// @notice Claim deadline (0 = no deadline)
    uint256 public claimDeadline;

    /// @notice Owner-only admin claim deadline (defaults to 60 days after deploy)
    uint256 public adminClaimDeadline;

    /// @notice Portion immediately unlocked (basis points, 10_000 = 100%)
    uint16 public unlockedBps = 10_000;

    /// @notice Timestamp when locked tokens become withdrawable
    uint64 public unlockTimestamp;

    /// @notice Factory that deploys per-beneficiary cliff locks
    TNTLockFactory public lockFactory;

    // ═══════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════

    event Claimed(
        bytes32 indexed pubkey,
        address indexed recipient,
        uint256 amount,
        uint256 unlockedAmount,
        uint256 lockedAmount,
        address lock
    );

    event MerkleRootUpdated(bytes32 oldRoot, bytes32 newRoot);
    event ZKVerifierUpdated(address oldVerifier, address newVerifier);
    event ClaimDeadlineUpdated(uint256 oldDeadline, uint256 newDeadline);
    event AdminClaimDeadlineUpdated(uint256 oldDeadline, uint256 newDeadline);
    event Paused(bool isPaused);
    event EmergencyWithdraw(address token, uint256 amount);
    event LockConfigUpdated(address lockFactory, uint64 unlockTimestamp, uint16 unlockedBps);
    event AdminClaimed(bytes32 indexed pubkey, address indexed recipient, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════

    error ClaimsPaused();
    error ClaimDeadlinePassed();
    error InvalidMerkleProof();
    error InvalidZKProof();
    error AlreadyClaimed();
    error ZeroAmount();
    error ZeroAddress();
    error NoZKVerifier();
    error InvalidBps();
    error LockConfigLocked();
    error AdminClaimWindowClosed();
    error InvalidAdminClaimDeadline();

    // ═══════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════

    /// @param _token The token to distribute
    /// @param _merkleRoot The merkle root of the distribution
    /// @param _zkVerifier The ZK verifier contract (can be zero initially)
    /// @param _owner The owner of the contract
    constructor(
        address _token,
        bytes32 _merkleRoot,
        address _zkVerifier,
        address _owner
    ) Ownable(_owner) {
        if (_token == address(0)) revert ZeroAddress();

        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        zkVerifier = IZKVerifier(_zkVerifier);

        adminClaimDeadline = block.timestamp + 60 days;

        // Defaults: 10% unlocked, 90% locked for 180 days.
        unlockedBps = 1000;
        // forge-lint: disable-next-line(unsafe-typecast)
        unlockTimestamp = uint64(block.timestamp + 180 days);
        lockFactory = new TNTLockFactory();
        emit LockConfigUpdated(address(lockFactory), unlockTimestamp, unlockedBps);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CLAIM FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Claim tokens for a Substrate pubkey using ZK proof
    /// @param pubkey The 32-byte SR25519 public key (decoded from SS58)
    /// @param amount The amount to claim (in wei)
    /// @param merkleProof The Merkle proof for the claim
    /// @param zkProof The ZK proof of Substrate key ownership
    /// @param recipient The EVM address to receive the tokens
    function claimWithZKProof(
        bytes32 pubkey,
        uint256 amount,
        bytes32[] calldata merkleProof,
        bytes calldata zkProof,
        address recipient
    ) external nonReentrant {
        _validateClaim();
        if (address(zkVerifier) == address(0)) revert NoZKVerifier();
        if (recipient == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (pubkey == bytes32(0)) revert ZeroAddress();

        // Check if already claimed
        if (claimed[pubkey] > 0) revert AlreadyClaimed();

        // Merkle leaf format: keccak256(bytes.concat(keccak256(abi.encode(pubkey, amount))))
        bytes32 leaf = keccak256(
            bytes.concat(
                keccak256(abi.encode(pubkey, amount))
            )
        );

        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert InvalidMerkleProof();
        }

        bytes32 expectedChallenge = keccak256(abi.encode(address(this), block.chainid, recipient, amount));

        // Verify ZK proof of key ownership
        // The ZK proof verifies: (pubkey, evmAddress, amount, expectedChallenge)
        bytes memory publicInputs = abi.encode(
            pubkey,
            recipient,
            amount,
            expectedChallenge
        );

        if (!zkVerifier.verifyProof(zkProof, publicInputs)) {
            revert InvalidZKProof();
        }

        // Mark as claimed and transfer
        claimed[pubkey] = amount;
        totalClaimed += amount;

        uint256 unlockedAmount = (amount * unlockedBps) / 10_000;
        uint256 lockedAmount = amount - unlockedAmount;

        if (unlockedAmount > 0) {
            token.safeTransfer(recipient, unlockedAmount);
        }

        address lock = address(0);
        if (lockedAmount > 0) {
            if (address(lockFactory) == address(0) || unlockTimestamp == 0) revert ZeroAddress();
            // Default delegation: keep voting power usable by the recipient while locked.
            lock = lockFactory.getOrCreateLock(address(token), recipient, unlockTimestamp, recipient);
            token.safeTransfer(lock, lockedAmount);
        }

        emit Claimed(pubkey, recipient, amount, unlockedAmount, lockedAmount, lock);
    }

    /// @notice Owner-only override to claim a Merkle allocation without a ZK proof.
    /// @dev Intended for short-term edge cases (e.g., lost keys) and time-bounded by `adminClaimDeadline`.
    function adminClaim(
        bytes32 pubkey,
        uint256 amount,
        bytes32[] calldata merkleProof,
        address recipient
    ) external onlyOwner nonReentrant {
        if (block.timestamp > adminClaimDeadline) revert AdminClaimWindowClosed();
        if (recipient == address(0)) revert ZeroAddress();
        if (amount == 0) revert ZeroAmount();
        if (pubkey == bytes32(0)) revert ZeroAddress();
        if (claimed[pubkey] > 0) revert AlreadyClaimed();

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(pubkey, amount))));
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert InvalidMerkleProof();
        }

        claimed[pubkey] = amount;
        totalClaimed += amount;

        uint256 unlockedAmount = (amount * unlockedBps) / 10_000;
        uint256 lockedAmount = amount - unlockedAmount;

        if (unlockedAmount > 0) {
            token.safeTransfer(recipient, unlockedAmount);
        }

        address lock = address(0);
        if (lockedAmount > 0) {
            if (address(lockFactory) == address(0) || unlockTimestamp == 0) revert ZeroAddress();
            lock = lockFactory.getOrCreateLock(address(token), recipient, unlockTimestamp, recipient);
            token.safeTransfer(lock, lockedAmount);
        }

        emit Claimed(pubkey, recipient, amount, unlockedAmount, lockedAmount, lock);
        emit AdminClaimed(pubkey, recipient, amount);
    }

    /// @notice Check if a pubkey has already claimed
    /// @param pubkey The 32-byte SR25519 public key
    /// @return The amount claimed (0 if not claimed)
    function getClaimedAmount(bytes32 pubkey) external view returns (uint256) {
        return claimed[pubkey];
    }

    /// @notice Verify a Merkle proof without claiming
    /// @param pubkey The 32-byte SR25519 public key
    /// @param amount The amount in the claim
    /// @param merkleProof The Merkle proof
    /// @return valid True if the proof is valid
    function verifyMerkleProof(
        bytes32 pubkey,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external view returns (bool valid) {
        bytes32 leaf = keccak256(
            bytes.concat(
                keccak256(abi.encode(pubkey, amount))
            )
        );
        return MerkleProof.verify(merkleProof, merkleRoot, leaf);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Update the Merkle root
    /// @param _merkleRoot The new Merkle root
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        emit MerkleRootUpdated(merkleRoot, _merkleRoot);
        merkleRoot = _merkleRoot;
    }

    /// @notice Update the ZK verifier
    /// @param _zkVerifier The new ZK verifier address
    function setZKVerifier(address _zkVerifier) external onlyOwner {
        emit ZKVerifierUpdated(address(zkVerifier), _zkVerifier);
        zkVerifier = IZKVerifier(_zkVerifier);
    }

    /// @notice Set the claim deadline
    /// @param _deadline Unix timestamp (0 to disable)
    function setClaimDeadline(uint256 _deadline) external onlyOwner {
        emit ClaimDeadlineUpdated(claimDeadline, _deadline);
        claimDeadline = _deadline;
    }

    /// @notice Reduce the admin claim deadline (cannot be extended).
    /// @dev Setting it to `block.timestamp` disables admin claims immediately.
    function reduceAdminClaimDeadline(uint256 _newDeadline) external onlyOwner {
        if (_newDeadline < block.timestamp) revert InvalidAdminClaimDeadline();
        if (_newDeadline > adminClaimDeadline) revert InvalidAdminClaimDeadline();
        emit AdminClaimDeadlineUpdated(adminClaimDeadline, _newDeadline);
        adminClaimDeadline = _newDeadline;
    }

    /// @notice Configure the lock split and cliff timestamp (only before the first claim).
    function setLockConfig(address _lockFactory, uint64 _unlockTimestamp, uint16 _unlockedBps) external onlyOwner {
        if (totalClaimed != 0) revert LockConfigLocked();
        if (_unlockedBps > 10_000) revert InvalidBps();
        if (_lockFactory == address(0)) revert ZeroAddress();
        lockFactory = TNTLockFactory(_lockFactory);
        unlockedBps = _unlockedBps;
        unlockTimestamp = _unlockTimestamp;
        emit LockConfigUpdated(_lockFactory, _unlockTimestamp, _unlockedBps);
    }

    /// @notice Pause or unpause claims
    /// @param _paused True to pause, false to unpause
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit Paused(_paused);
    }

    /// @notice Emergency withdraw tokens (only after deadline or if paused)
    /// @param _token Token to withdraw (use address(0) for native)
    /// @param _amount Amount to withdraw
    function emergencyWithdraw(address _token, uint256 _amount) external onlyOwner {
        if (_token == address(0)) {
            payable(owner()).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(owner(), _amount);
        }
        emit EmergencyWithdraw(_token, _amount);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════

    function _validateClaim() internal view {
        if (paused) revert ClaimsPaused();
        if (claimDeadline != 0 && block.timestamp > claimDeadline) {
            revert ClaimDeadlinePassed();
        }
    }
}
