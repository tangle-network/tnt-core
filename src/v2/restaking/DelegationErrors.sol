// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title DelegationErrors
/// @notice Consolidated error definitions for the delegation module
library DelegationErrors {
    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OperatorAlreadyRegistered(address operator);
    error OperatorNotRegistered(address operator);
    error OperatorNotActive(address operator);
    error OperatorNotLeaving(address operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InsufficientStake(uint256 required, uint256 provided);
    error ZeroAmount();
    error ZeroAddress();

    // ═══════════════════════════════════════════════════════════════════════════
    // ASSET ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error AssetNotEnabled(address asset);
    error BelowMinimumDeposit(uint256 minimum, uint256 provided);
    error DepositCapExceeded(uint256 cap, uint256 current, uint256 adding);

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InsufficientDeposit(uint256 available, uint256 requested);
    error DelegationNotFound(address delegator, address operator);
    error SelectionModeMismatch();
    error InsufficientDelegation(uint256 available, uint256 requested);
    error InsufficientAvailableBalance(uint256 available, uint256 requested);
    error AmountLocked(uint256 locked, uint256 requested);

    // ═══════════════════════════════════════════════════════════════════════════
    // TIMING ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error LeavingTooEarly(uint64 currentRound, uint64 requiredRound);
    error UnstakeTooEarly(uint64 currentRound, uint64 requiredRound);
    error WithdrawTooEarly(uint64 currentRound, uint64 requiredRound);

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error NoRewardsToClaim();
    error TransferFailed();

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error NotSlasher(address caller);
    error LegacySlashRequiresAllMode(address operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidDelegationIndex(uint256 index);
    error NotFixedMode();
    error FixedModeRequiresBlueprints();
    error AllModeDisallowsBlueprints();
    error BlueprintAlreadySelected(uint64 blueprintId);
    error BlueprintNotSelected(uint64 blueprintId);
    error CannotRemoveLastBlueprint();

    // ═══════════════════════════════════════════════════════════════════════════
    // LOCK VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidLockMultiplier(uint8 value);
}
