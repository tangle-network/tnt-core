// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IBeaconOracle} from "./IBeaconOracle.sol";
import {BeaconChainProofs} from "./BeaconChainProofs.sol";
import {ValidatorTypes} from "./ValidatorTypes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title IValidatorPodManager
/// @notice Interface for the pod manager (forward declaration)
interface IValidatorPodManager {
    function recordBeaconChainETHBalanceUpdate(
        address podOwner,
        int256 sharesDelta
    ) external;
}

/// @title ValidatorPod
/// @notice Per-user contract that serves as withdrawal credential target for validators
/// @dev One pod per user, can have multiple validators pointing to it
contract ValidatorPod is ReentrancyGuard {
    using SafeERC20 for IERC20;
    using BeaconChainProofs for *;

    // ═══════════════════════════════════════════════════════════════════════════
    // IMMUTABLES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The owner of this pod (set at deployment, immutable)
    address public immutable podOwner;

    /// @notice The ValidatorPodManager that created this pod
    IValidatorPodManager public immutable podManager;

    /// @notice The beacon oracle for accessing beacon block roots
    IBeaconOracle public immutable beaconOracle;

    /// @notice Expected withdrawal credentials (computed from this contract's address)
    bytes32 public immutable podWithdrawalCredentials;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Whether the pod has completed initial restaking
    bool public hasRestaked;

    /// @notice Number of active validators in this pod
    uint256 public activeValidatorCount;

    /// @notice Validator info by pubkey hash
    mapping(bytes32 pubkeyHash => ValidatorTypes.ValidatorInfo) public validatorInfo;

    /// @notice Current checkpoint (if any)
    ValidatorTypes.Checkpoint public currentCheckpoint;

    /// @notice Timestamp when current checkpoint was started (0 if none active)
    uint64 public currentCheckpointTimestamp;

    /// @notice Track completed checkpoints for historical queries
    uint64 public lastCompletedCheckpointTimestamp;

    /// @notice ETH balance that has been withdrawn but not yet claimed
    uint256 public withdrawableRestakedExecutionLayerGwei;

    /// @notice H-1 FIX: Total restaked balance across all active validators (in gwei)
    /// @dev Maintained as running total for gas efficiency
    uint64 public totalRestakedBalanceGwei;

    /// @notice H-5 FIX: Maximum age for beacon roots (27 hours like EigenLayer)
    /// @dev EIP-4788 stores roots for 8191 slots (~27 hours)
    uint256 public constant MAX_BEACON_ROOT_AGE = 27 hours;

    /// @notice ELIP-004: Beacon chain slashing factor (WAD precision, 1e18 = 100%)
    /// @dev Monotonically decreasing. Tracks proportional balance decrease from beacon slashing.
    ///      When validators are slashed on beacon chain, this factor decreases proportionally.
    uint64 public beaconChainSlashingFactor;

    /// @notice Initial slashing factor value (1e18 = 100%, no slashing)
    uint64 public constant INITIAL_SLASHING_FACTOR = 1e18;

    /// @notice Authorized proof submitter (optional, for third-party proof submission)
    address public proofSubmitter;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ValidatorRestaked(bytes32 indexed pubkeyHash, uint40 validatorIndex);
    event ValidatorWithdrawn(bytes32 indexed pubkeyHash, uint64 amountGwei);
    event CheckpointCreated(uint64 indexed timestamp, bytes32 beaconBlockRoot);
    event CheckpointFinalized(uint64 indexed timestamp, int256 sharesDeltaGwei);
    event NonBeaconChainETHWithdrawn(address indexed recipient, uint256 amount);
    event BeaconChainSlashingFactorDecreased(uint64 oldFactor, uint64 newFactor);
    event ProofSubmitterUpdated(address oldSubmitter, address newSubmitter);
    event ValidatorBalanceUpdated(bytes32 indexed pubkeyHash, uint64 oldBalance, uint64 newBalance);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlyPodOwner();
    error OnlyPodManager();
    error InvalidWithdrawalCredentials();
    error ValidatorAlreadyRestaked();
    error ValidatorNotActive();
    error CheckpointAlreadyActive();
    error NoCheckpointActive();
    error NoActiveValidators();
    error InsufficientBalance();
    error ProofVerificationFailed();
    error ValidatorAlreadyProvenForCheckpoint();
    error StaleProof();
    error NotOwnerOrProofSubmitter();
    error ValidatorNotSlashed();
    error CurrentlyInCheckpoint();

    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════

    modifier onlyPodOwner() {
        if (msg.sender != podOwner) revert OnlyPodOwner();
        _;
    }

    modifier onlyPodManager() {
        if (msg.sender != address(podManager)) revert OnlyPodManager();
        _;
    }

    error TransferFailed();

    /// @notice Allows pod owner or designated proof submitter
    modifier onlyOwnerOrProofSubmitter() {
        if (msg.sender != podOwner && msg.sender != proofSubmitter) {
            revert NotOwnerOrProofSubmitter();
        }
        _;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new ValidatorPod
    /// @param _podOwner The owner of this pod
    /// @param _podManager The ValidatorPodManager contract
    /// @param _beaconOracle The beacon oracle for block roots
    constructor(
        address _podOwner,
        address _podManager,
        address _beaconOracle
    ) {
        podOwner = _podOwner;
        podManager = IValidatorPodManager(_podManager);
        beaconOracle = IBeaconOracle(_beaconOracle);
        podWithdrawalCredentials = ValidatorTypes.computeWithdrawalCredentials(address(this));

        // ELIP-004: Initialize slashing factor to 100% (no slashing)
        beaconChainSlashingFactor = INITIAL_SLASHING_FACTOR;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL CREDENTIAL VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Verify withdrawal credentials for one or more validators
    /// @param beaconTimestamp Timestamp of the beacon block to verify against
    /// @param stateRootProof Proof of state root in beacon block
    /// @param validatorIndices Indices of validators to verify
    /// @param validatorFieldsProofs Proofs for each validator's fields
    /// @param validatorFields The validator container fields for each validator
    function verifyWithdrawalCredentials(
        uint64 beaconTimestamp,
        ValidatorTypes.StateRootProof calldata stateRootProof,
        uint40[] calldata validatorIndices,
        bytes[] calldata validatorFieldsProofs,
        bytes32[][] calldata validatorFields
    ) external onlyPodOwner nonReentrant {
        // H-5 FIX: Check beacon root is not stale
        if (block.timestamp > beaconTimestamp + MAX_BEACON_ROOT_AGE) {
            revert StaleProof();
        }

        // Get the beacon block root for this timestamp
        bytes32 beaconBlockRoot = beaconOracle.getBeaconBlockRoot(beaconTimestamp);

        // Verify state root is in the beacon block
        if (!BeaconChainProofs.verifyStateRoot(beaconBlockRoot, stateRootProof)) {
            revert ProofVerificationFailed();
        }

        uint256 totalRestakedGwei = 0;

        for (uint256 i = 0; i < validatorIndices.length; i++) {
            totalRestakedGwei += _verifyAndProcessWithdrawalCredential(
                stateRootProof.beaconStateRoot,
                validatorIndices[i],
                ValidatorTypes.ValidatorFieldsProof({
                    validatorFields: validatorFields[i],
                    proof: validatorFieldsProofs[i]
                })
            );
        }

        // Mark pod as restaked after first successful verification
        if (!hasRestaked) {
            hasRestaked = true;
        }

        // Update shares in the pod manager
        if (totalRestakedGwei > 0) {
            podManager.recordBeaconChainETHBalanceUpdate(
                podOwner,
                int256(uint256(totalRestakedGwei)) * 1 gwei
            );
        }
    }

    /// @notice Internal function to verify and process a single validator
    function _verifyAndProcessWithdrawalCredential(
        bytes32 beaconStateRoot,
        uint40 validatorIndex,
        ValidatorTypes.ValidatorFieldsProof memory proof
    ) internal returns (uint64 restakedGwei) {
        // Verify the validator fields proof
        if (!BeaconChainProofs.verifyValidatorFields(beaconStateRoot, validatorIndex, proof)) {
            revert ProofVerificationFailed();
        }

        // Get pubkey hash for tracking
        bytes32 pubkeyHash = BeaconChainProofs.getPubkeyHash(proof.validatorFields);

        // Check validator hasn't already been restaked
        if (validatorInfo[pubkeyHash].status != ValidatorTypes.ValidatorStatus.INACTIVE) {
            revert ValidatorAlreadyRestaked();
        }

        // Verify withdrawal credentials point to this pod
        bytes32 credentials = BeaconChainProofs.getWithdrawalCredentials(proof.validatorFields);
        if (credentials != podWithdrawalCredentials) {
            revert InvalidWithdrawalCredentials();
        }

        // Get effective balance (capped at 32 ETH)
        uint64 effectiveBalance = BeaconChainProofs.getEffectiveBalanceGwei(proof.validatorFields);
        restakedGwei = effectiveBalance > ValidatorTypes.MAX_EFFECTIVE_BALANCE_GWEI
            ? ValidatorTypes.MAX_EFFECTIVE_BALANCE_GWEI
            : effectiveBalance;

        // Store validator info
        validatorInfo[pubkeyHash] = ValidatorTypes.ValidatorInfo({
            validatorIndex: validatorIndex,
            restakedBalanceGwei: restakedGwei,
            lastCheckpointedAt: uint64(block.timestamp),
            status: ValidatorTypes.ValidatorStatus.ACTIVE
        });

        activeValidatorCount++;

        // H-1 FIX: Track total restaked balance
        totalRestakedBalanceGwei += restakedGwei;

        emit ValidatorRestaked(pubkeyHash, validatorIndex);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CHECKPOINT FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Start a new checkpoint to update validator balances
    /// @param revertIfNoBalance If true, revert if pod has no ETH balance to snapshot
    function startCheckpoint(bool revertIfNoBalance) external onlyPodOwner {
        if (currentCheckpointTimestamp != 0) {
            revert CheckpointAlreadyActive();
        }

        if (activeValidatorCount == 0) {
            revert NoActiveValidators();
        }

        // Snapshot the pod's current ETH balance
        uint64 podBalanceGwei = uint64(address(this).balance / 1 gwei);

        if (revertIfNoBalance && podBalanceGwei == 0) {
            revert InsufficientBalance();
        }

        // Get the parent beacon block root (current block's parent)
        uint64 timestamp = uint64(block.timestamp);
        bytes32 beaconBlockRoot = beaconOracle.getBeaconBlockRoot(timestamp);

        // Initialize checkpoint
        currentCheckpoint = ValidatorTypes.Checkpoint({
            beaconBlockRoot: beaconBlockRoot,
            proofsRemaining: uint24(activeValidatorCount),
            podBalanceGwei: podBalanceGwei,
            balanceDeltasGwei: 0,
            priorBeaconBalanceGwei: _getTotalRestakedGwei()
        });

        currentCheckpointTimestamp = timestamp;

        emit CheckpointCreated(timestamp, beaconBlockRoot);
    }

    /// @notice Verify checkpoint proofs for validators
    /// @dev H-2 NOTE: Allowing anyone to call is intentional (like EigenLayer)
    ///      since proofs are cryptographically verified. This enables permissionless proof submission.
    /// @param stateRootProof Proof of state root in beacon block
    /// @param balanceContainerProof Proof of balance container in beacon state
    /// @param proofs Balance proofs for each validator
    function verifyCheckpointProofs(
        ValidatorTypes.StateRootProof calldata stateRootProof,
        ValidatorTypes.BalanceContainerProof calldata balanceContainerProof,
        ValidatorTypes.BalanceProof[] calldata proofs
    ) external nonReentrant {
        if (currentCheckpointTimestamp == 0) {
            revert NoCheckpointActive();
        }

        ValidatorTypes.Checkpoint memory checkpoint = currentCheckpoint;

        // C-3 FIX: Two-step verification - first verify state root against block root
        if (!BeaconChainProofs.verifyStateRoot(checkpoint.beaconBlockRoot, stateRootProof)) {
            revert ProofVerificationFailed();
        }

        // Then verify balance container against state root (not block root)
        if (!BeaconChainProofs.verifyBalanceContainer(stateRootProof.beaconStateRoot, balanceContainerProof)) {
            revert ProofVerificationFailed();
        }

        int128 balanceDelta = 0;

        for (uint256 i = 0; i < proofs.length; i++) {
            balanceDelta += _verifyAndProcessCheckpointProof(
                balanceContainerProof.balanceContainerRoot,
                proofs[i]
            );
        }

        // Update checkpoint state
        currentCheckpoint.balanceDeltasGwei += balanceDelta;
        currentCheckpoint.proofsRemaining -= uint24(proofs.length);

        // Finalize if all proofs submitted
        if (currentCheckpoint.proofsRemaining == 0) {
            _finalizeCheckpoint();
        }
    }

    /// @notice Internal function to verify and process a single balance proof
    function _verifyAndProcessCheckpointProof(
        bytes32 balanceContainerRoot,
        ValidatorTypes.BalanceProof calldata proof
    ) internal returns (int128 balanceDelta) {
        bytes32 pubkeyHash = proof.pubkeyHash;
        ValidatorTypes.ValidatorInfo storage info = validatorInfo[pubkeyHash];

        if (info.status != ValidatorTypes.ValidatorStatus.ACTIVE) {
            revert ValidatorNotActive();
        }

        // Prevent double-proving in same checkpoint
        if (info.lastCheckpointedAt >= currentCheckpointTimestamp) {
            revert ValidatorAlreadyProvenForCheckpoint();
        }

        // Verify the balance proof
        uint64 currentBalance = BeaconChainProofs.verifyValidatorBalance(
            balanceContainerRoot,
            uint40(info.validatorIndex),
            proof
        );

        // Calculate delta from previous balance
        uint64 previousBalance = info.restakedBalanceGwei;
        balanceDelta = int128(int64(currentBalance)) - int128(int64(previousBalance));

        // Update validator info
        info.restakedBalanceGwei = currentBalance;
        info.lastCheckpointedAt = currentCheckpointTimestamp;

        // H-1 FIX: Update total restaked balance tracking
        if (currentBalance > previousBalance) {
            totalRestakedBalanceGwei += (currentBalance - previousBalance);
        } else if (previousBalance > currentBalance) {
            totalRestakedBalanceGwei -= (previousBalance - currentBalance);
        }

        // Check if validator has exited (balance = 0)
        if (currentBalance == 0) {
            info.status = ValidatorTypes.ValidatorStatus.WITHDRAWN;
            activeValidatorCount--;
            emit ValidatorWithdrawn(pubkeyHash, previousBalance);
        }
    }

    /// @notice Finalize the current checkpoint
    /// @dev ELIP-004: Updates slashing factor if validators were slashed on beacon chain
    function _finalizeCheckpoint() internal {
        int256 totalDeltaWei = int256(currentCheckpoint.balanceDeltasGwei) * 1 gwei;

        // Add any ETH that arrived at the pod (partial withdrawals, tips, etc.)
        totalDeltaWei += int256(uint256(currentCheckpoint.podBalanceGwei)) * 1 gwei;

        // ELIP-004: Calculate new slashing factor if balance decreased due to beacon slashing
        // The slashing factor tracks the proportional decrease in validator balances
        uint64 currentBalance = totalRestakedBalanceGwei;
        uint64 priorBalance = currentCheckpoint.priorBeaconBalanceGwei;

        if (currentBalance < priorBalance && priorBalance > 0) {
            // Calculate new slashing factor: newFactor = oldFactor * currentBalance / priorBalance
            // Using uint256 for intermediate calculation to avoid overflow
            uint64 oldFactor = beaconChainSlashingFactor;
            uint64 newFactor = uint64(
                (uint256(oldFactor) * uint256(currentBalance)) / uint256(priorBalance)
            );

            // Slashing factor is monotonically decreasing
            if (newFactor < oldFactor) {
                beaconChainSlashingFactor = newFactor;
                emit BeaconChainSlashingFactorDecreased(oldFactor, newFactor);
            }
        }

        // Record the balance update with the pod manager
        podManager.recordBeaconChainETHBalanceUpdate(podOwner, totalDeltaWei);

        lastCompletedCheckpointTimestamp = currentCheckpointTimestamp;

        emit CheckpointFinalized(currentCheckpointTimestamp, totalDeltaWei);

        // Clear checkpoint state
        delete currentCheckpoint;
        currentCheckpointTimestamp = 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Withdraw ETH sent to this pod outside of beacon chain
    /// @param recipient Address to send ETH to
    /// @param amount Amount to withdraw
    /// @dev For recovering tips, MEV, or accidental transfers
    function withdrawNonBeaconChainETH(
        address recipient,
        uint256 amount
    ) external onlyPodOwner nonReentrant {
        if (amount > address(this).balance) {
            revert InsufficientBalance();
        }

        (bool success,) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit NonBeaconChainETHWithdrawn(recipient, amount);
    }

    /// @notice Recover ERC20 tokens accidentally sent to this pod
    /// @param token Token to recover
    /// @param recipient Address to send tokens to
    /// @param amount Amount to recover
    function recoverTokens(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyPodOwner {
        token.safeTransfer(recipient, amount);
    }

    /// @notice Withdraw ETH to staker (called by PodManager on withdrawal completion)
    /// @param recipient The staker to receive ETH
    /// @param amount Amount to withdraw in wei
    /// @dev Only callable by the PodManager contract
    function withdrawToStaker(address recipient, uint256 amount) external onlyPodManager nonReentrant {
        if (amount > address(this).balance) {
            revert InsufficientBalance();
        }

        (bool success,) = recipient.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit NonBeaconChainETHWithdrawn(recipient, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STALE BALANCE ENFORCEMENT (ELIP-004)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Allows anyone to prove a validator was slashed and force a checkpoint
    /// @dev Third-party enforcement mechanism per ELIP-004
    /// @param beaconTimestamp Timestamp of the beacon block containing the proof
    /// @param stateRootProof Proof of state root in beacon block
    /// @param validatorProof Proof of validator fields showing slashed status
    function verifyStaleBalance(
        uint64 beaconTimestamp,
        ValidatorTypes.StateRootProof calldata stateRootProof,
        ValidatorTypes.ValidatorFieldsProof memory validatorProof
    ) external nonReentrant {
        // Cannot call during active checkpoint
        if (currentCheckpointTimestamp != 0) {
            revert CurrentlyInCheckpoint();
        }

        // Check beacon root is not stale
        if (block.timestamp > beaconTimestamp + MAX_BEACON_ROOT_AGE) {
            revert StaleProof();
        }

        // Get the beacon block root for this timestamp
        bytes32 beaconBlockRoot = beaconOracle.getBeaconBlockRoot(beaconTimestamp);

        // Verify state root is in the beacon block
        if (!BeaconChainProofs.verifyStateRoot(beaconBlockRoot, stateRootProof)) {
            revert ProofVerificationFailed();
        }

        // Get pubkey hash and validator info
        bytes32 pubkeyHash = BeaconChainProofs.getPubkeyHash(validatorProof.validatorFields);
        ValidatorTypes.ValidatorInfo storage info = validatorInfo[pubkeyHash];

        // Validator must be active in this pod
        if (info.status != ValidatorTypes.ValidatorStatus.ACTIVE) {
            revert ValidatorNotActive();
        }

        // Verify the validator fields proof
        if (!BeaconChainProofs.verifyValidatorFields(
            stateRootProof.beaconStateRoot,
            uint40(info.validatorIndex),
            validatorProof
        )) {
            revert ProofVerificationFailed();
        }

        // Check if validator is slashed on beacon chain
        bool isSlashed = BeaconChainProofs.isValidatorSlashed(validatorProof.validatorFields);
        if (!isSlashed) {
            revert ValidatorNotSlashed();
        }

        // Force a checkpoint to be started to update the slashing factor
        // The caller can then submit balance proofs to complete the checkpoint
        _startCheckpointFromStaleBalance(beaconBlockRoot);
    }

    /// @notice Internal function to start checkpoint triggered by stale balance proof
    /// @param beaconBlockRoot The beacon block root from the stale balance proof
    function _startCheckpointFromStaleBalance(bytes32 beaconBlockRoot) internal {
        if (activeValidatorCount == 0) {
            revert NoActiveValidators();
        }

        uint64 podBalanceGwei = uint64(address(this).balance / 1 gwei);
        uint64 timestamp = uint64(block.timestamp);

        currentCheckpoint = ValidatorTypes.Checkpoint({
            beaconBlockRoot: beaconBlockRoot,
            proofsRemaining: uint24(activeValidatorCount),
            podBalanceGwei: podBalanceGwei,
            balanceDeltasGwei: 0,
            priorBeaconBalanceGwei: totalRestakedBalanceGwei
        });

        currentCheckpointTimestamp = timestamp;

        emit CheckpointCreated(timestamp, beaconBlockRoot);
    }

    /// @notice Set the proof submitter address
    /// @param newProofSubmitter Address authorized to submit proofs
    function setProofSubmitter(address newProofSubmitter) external onlyPodOwner {
        address oldSubmitter = proofSubmitter;
        proofSubmitter = newProofSubmitter;
        emit ProofSubmitterUpdated(oldSubmitter, newProofSubmitter);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get total restaked gwei across all active validators
    /// @dev H-1 FIX: Now returns the tracked running total instead of 0
    function _getTotalRestakedGwei() internal view returns (uint64) {
        return totalRestakedBalanceGwei;
    }

    /// @notice Get validator info by pubkey hash
    function getValidatorInfo(bytes32 pubkeyHash)
        external
        view
        returns (ValidatorTypes.ValidatorInfo memory)
    {
        return validatorInfo[pubkeyHash];
    }

    /// @notice Check if a checkpoint is currently active
    function checkpointActive() external view returns (bool) {
        return currentCheckpointTimestamp != 0;
    }

    /// @notice Get the current slashing factor (ELIP-004)
    /// @return factor The slashing factor in WAD precision (1e18 = 100%, no slashing)
    function getSlashingFactor() external view returns (uint64 factor) {
        return beaconChainSlashingFactor;
    }

    /// @notice Calculate the effective shares after applying slashing factor
    /// @param shares The raw shares amount
    /// @return effectiveShares The shares after applying slashing factor
    function applySlashingFactor(int256 shares) external view returns (int256 effectiveShares) {
        // Apply slashing factor: effectiveShares = shares * slashingFactor / 1e18
        return (shares * int256(uint256(beaconChainSlashingFactor))) / int256(uint256(INITIAL_SLASHING_FACTOR));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RECEIVE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Accept ETH transfers (for validator withdrawals, tips, etc.)
    receive() external payable {}
}
