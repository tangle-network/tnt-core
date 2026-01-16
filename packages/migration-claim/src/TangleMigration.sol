// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IZKVerifier} from "./IZKVerifier.sol";
import {TNTVestingFactory} from "./lockups/TNTVestingFactory.sol";

/// @title TangleMigration
/// @notice Distribution contract for Tangle network migration with linear vesting
/// @dev Substrate address holders must prove key ownership via ZK proof to claim
///
/// Vesting Schedule (default 3 years total):
/// - 2% unlocked immediately at claim
/// - 12-month cliff (no vesting during this period)
/// - 98% vested linearly over 24 months after cliff
/// - Configurable: deploy new TNTVestingFactory with custom cliff/vesting durations
contract TangleMigration is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════

    uint64 public constant DEFAULT_CLIFF_DURATION = 365 days; // 12 months
    uint64 public constant DEFAULT_VESTING_DURATION = 730 days; // 24 months (total 36 months / 3 years)
    uint16 public constant DEFAULT_UNLOCKED_BPS = 200; // 2%

    // ═══════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice The token being distributed
    IERC20 public immutable token;

    /// @notice Treasury address for unclaimed token sweep (immutable for safety)
    address public immutable treasury;

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
    uint16 public unlockedBps;

    /// @notice Factory that deploys per-beneficiary vesting contracts
    TNTVestingFactory public vestingFactory;

    // ═══════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════

    event Claimed(
        bytes32 indexed pubkey,
        address indexed recipient,
        uint256 amount,
        uint256 unlockedAmount,
        uint256 vestedAmount,
        address vestingContract
    );

    event MerkleRootUpdated(bytes32 oldRoot, bytes32 newRoot);
    event ZKVerifierUpdated(address oldVerifier, address newVerifier);
    event ClaimDeadlineUpdated(uint256 oldDeadline, uint256 newDeadline);
    event AdminClaimDeadlineUpdated(uint256 oldDeadline, uint256 newDeadline);
    event Paused(bool isPaused);
    event EmergencyWithdraw(address token, uint256 amount);
    event VestingConfigUpdated(address vestingFactory, uint64 cliffDuration, uint64 vestingDuration, uint16 unlockedBps);
    event AdminClaimed(bytes32 indexed pubkey, address indexed recipient, uint256 amount);
    event UnclaimedSweptToTreasury(address indexed treasury, uint256 amount);

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
    error VestingConfigLocked();
    error AdminClaimWindowClosed();
    error InvalidAdminClaimDeadline();
    error EmergencyWithdrawNotAllowed();
    error ClaimDeadlineNotPassed();
    error NoClaimDeadlineSet();
    error MerkleRootLocked();
    error ZKVerifierLocked();
    error ETHTransferFailed();

    // ═══════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════

    /// @param _token The token to distribute
    /// @param _merkleRoot The merkle root of the distribution
    /// @param _zkVerifier The ZK verifier contract (can be zero initially)
    /// @param _owner The owner of the contract
    /// @param _treasury The treasury address for unclaimed token sweep (immutable)
    constructor(
        address _token,
        bytes32 _merkleRoot,
        address _zkVerifier,
        address _owner,
        address _treasury
    ) Ownable(_owner) {
        if (_token == address(0)) revert ZeroAddress();
        if (_treasury == address(0)) revert ZeroAddress();

        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        zkVerifier = IZKVerifier(_zkVerifier);
        treasury = _treasury;

        adminClaimDeadline = block.timestamp + 60 days;

        // Defaults: 2% unlocked, 98% vested over 18 months (6-month cliff + 12-month linear)
        unlockedBps = DEFAULT_UNLOCKED_BPS;
        vestingFactory = new TNTVestingFactory(DEFAULT_CLIFF_DURATION, DEFAULT_VESTING_DURATION);

        emit VestingConfigUpdated(
            address(vestingFactory),
            DEFAULT_CLIFF_DURATION,
            DEFAULT_VESTING_DURATION,
            DEFAULT_UNLOCKED_BPS
        );
    }

    // ═══════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Get the cliff duration from the vesting factory
    function cliffDuration() external view returns (uint64) {
        return vestingFactory.cliffDuration();
    }

    /// @notice Get the vesting duration from the vesting factory
    function vestingDuration() external view returns (uint64) {
        return vestingFactory.vestingDuration();
    }

    /// @notice Get the total vesting period (cliff + linear vesting)
    function totalVestingDuration() external view returns (uint64) {
        return vestingFactory.totalVestingDuration();
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
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(pubkey, amount))));

        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) {
            revert InvalidMerkleProof();
        }

        bytes32 expectedChallenge = keccak256(abi.encode(address(this), block.chainid, recipient, amount));

        // Verify ZK proof of key ownership
        bytes memory publicInputs = abi.encode(pubkey, recipient, amount, expectedChallenge);

        if (!zkVerifier.verifyProof(zkProof, publicInputs)) {
            revert InvalidZKProof();
        }

        _executeClaim(pubkey, amount, recipient);
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

        _executeClaim(pubkey, amount, recipient);
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
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(pubkey, amount))));
        return MerkleProof.verify(merkleProof, merkleRoot, leaf);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Update the Merkle root (only before first claim)
    /// @param _merkleRoot The new Merkle root
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        if (totalClaimed != 0) revert MerkleRootLocked();
        emit MerkleRootUpdated(merkleRoot, _merkleRoot);
        merkleRoot = _merkleRoot;
    }

    /// @notice Update the ZK verifier (only before first claim)
    /// @param _zkVerifier The new ZK verifier address
    function setZKVerifier(address _zkVerifier) external onlyOwner {
        if (totalClaimed != 0) revert ZKVerifierLocked();
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

    /// @notice Configure the vesting schedule (only before the first claim)
    /// @dev To change vesting duration, deploy a new factory with desired parameters.
    ///      Example: For 24-month schedule, use cliffDuration=180 days, vestingDuration=540 days
    /// @param _vestingFactory The vesting factory with configured cliff and vesting durations
    /// @param _unlockedBps Basis points unlocked immediately (e.g., 200 = 2%)
    function setVestingConfig(address _vestingFactory, uint16 _unlockedBps) external onlyOwner {
        if (totalClaimed != 0) revert VestingConfigLocked();
        if (_unlockedBps > 10_000) revert InvalidBps();
        if (_vestingFactory == address(0)) revert ZeroAddress();

        vestingFactory = TNTVestingFactory(_vestingFactory);
        unlockedBps = _unlockedBps;

        emit VestingConfigUpdated(
            _vestingFactory,
            vestingFactory.cliffDuration(),
            vestingFactory.vestingDuration(),
            _unlockedBps
        );
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
        bool deadlinePassed = claimDeadline != 0 && block.timestamp > claimDeadline;
        if (!paused && !deadlinePassed) revert EmergencyWithdrawNotAllowed();

        if (_token == address(0)) {
            (bool success,) = owner().call{value: _amount}("");
            if (!success) revert ETHTransferFailed();
        } else {
            IERC20(_token).safeTransfer(owner(), _amount);
        }
        emit EmergencyWithdraw(_token, _amount);
    }

    /// @notice Sweep all unclaimed tokens to treasury after claim deadline
    /// @dev Callable by anyone after claim deadline passes - tokens go to immutable treasury
    /// @return amount The amount of tokens swept to treasury
    function sweepUnclaimedToTreasury() external returns (uint256 amount) {
        if (claimDeadline == 0) revert NoClaimDeadlineSet();
        if (block.timestamp <= claimDeadline) revert ClaimDeadlineNotPassed();

        amount = token.balanceOf(address(this));
        if (amount > 0) {
            token.safeTransfer(treasury, amount);
            emit UnclaimedSweptToTreasury(treasury, amount);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function _validateClaim() internal view {
        if (paused) revert ClaimsPaused();
        if (claimDeadline != 0 && block.timestamp > claimDeadline) {
            revert ClaimDeadlinePassed();
        }
    }

    function _executeClaim(bytes32 pubkey, uint256 amount, address recipient) internal {
        // Mark as claimed
        claimed[pubkey] = amount;
        totalClaimed += amount;

        // Calculate unlocked vs vested amounts
        uint256 unlockedAmount = (amount * unlockedBps) / 10_000;
        uint256 vestedAmount = amount - unlockedAmount;

        // Transfer unlocked portion directly
        if (unlockedAmount > 0) {
            token.safeTransfer(recipient, unlockedAmount);
        }

        // Create vesting contract for locked portion
        address vestingContract = address(0);
        if (vestedAmount > 0) {
            // forge-lint: disable-next-line(unsafe-typecast)
            uint64 startTimestamp = uint64(block.timestamp);

            // Create vesting contract with recipient as beneficiary and delegatee
            vestingContract = vestingFactory.getOrCreateVesting(
                address(token),
                recipient,
                startTimestamp,
                recipient // delegatee - voting power goes to recipient
            );

            token.safeTransfer(vestingContract, vestedAmount);
        }

        emit Claimed(pubkey, recipient, amount, unlockedAmount, vestedAmount, vestingContract);
    }
}
