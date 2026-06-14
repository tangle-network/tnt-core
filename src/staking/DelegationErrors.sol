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
    error OperatorBondTokenOnly(address requiredToken);
    error OperatorBondTokenLocked();

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InsufficientStake(uint256 required, uint256 provided);
    /// @dev Zero amount provided - kept parameterless for backward compatibility
    ///      Context is typically clear from the function that reverts
    error ZeroAmount();
    /// @dev Zero address provided - kept parameterless for backward compatibility
    ///      Context is typically clear from the function that reverts
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
    error DelegationDisabled(address operator);
    error DelegatorNotWhitelisted(address operator, address delegator);

    // ═══════════════════════════════════════════════════════════════════════════
    // TIMING ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error LeavingTooEarly(uint64 currentRound, uint64 requiredRound);
    error UnstakeTooEarly(uint64 currentRound, uint64 requiredRound);
    error WithdrawTooEarly(uint64 currentRound, uint64 requiredRound);
    error RoundAdvanceTooSoon(uint64 nextAllowedTime, uint64 currentTime);

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error NoRewardsToClaim();
    error TransferFailed();

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error NotSlasher(address caller);
    error InvalidSlashBps(uint256 slashBps);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidDelegationIndex(uint256 index);
    error NotFixedMode();
    error FixedModeRequiresBlueprints();
    error AllModeDisallowsBlueprints();
    error BlueprintAlreadySelected(uint64 blueprintId);
    error BlueprintNotSelected(uint64 blueprintId);
    error DuplicateBlueprint(uint64 blueprintId);
    error CannotRemoveLastBlueprint();
    error InvalidBlueprintShares();

    // ═══════════════════════════════════════════════════════════════════════════
    // LOCK VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidLockMultiplier(uint8 value);
    /// @dev Rejects deposits below the minimum lock amount so the lock-multiplier
    ///      reward path cannot be gamed by a stream of dust deposits.
    error BelowMinimumLockAmount(uint256 minimum, uint256 provided);

    // ═══════════════════════════════════════════════════════════════════════════
    // ADAPTER MIGRATION ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error AdapterMigrationInProgress(address token);
    error NoAdapterMigrationPending(address token);
    error AdapterMigrationAlreadyPending(address token);

    // ═══════════════════════════════════════════════════════════════════════════
    // COMMISSION CHANGE ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error NoCommissionChangePending();
    error CommissionChangeTooEarly(uint64 executeAfter, uint64 currentTime);
    error CommissionChangeAlreadyPending();

    // ═══════════════════════════════════════════════════════════════════════════
    // PENDING SLASH ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Blocks delegator withdrawals while the operator has un-finalized
    ///      slash proposals against them.
    error PendingSlashExists(address operator, uint64 pendingSlashCount);

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR EXIT ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Blocks operator exit while they have active service commitments.
    error OperatorHasActiveServices(address operator);

    /// @dev The active-services query to the Tangle core could not be evaluated (staticcall
    ///      reverted or returned malformed data). Exit is fail-closed: rather than skip the
    ///      guard, leaving is blocked until the query can be answered.
    error ActiveServiceCheckUnavailable(address operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // ACCESS CONTROL ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error Unauthorized();

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUTER ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error NotAContract(address account);
    error UnknownSelector(bytes4 selector);
    error SelectorAlreadyRegistered(bytes4 selector, address existingFacet);

    /// @notice Fee-on-transfer / rebasing token rejected on direct ERC20 deposit.
    /// @dev 1:1 share accounting assumes the contract
    ///      physically receives `amount`; non-1:1 tokens would inflate share supply
    ///      relative to actual holdings, eventually bricking withdrawals.
    error FeeOnTransferTokenRejected(address token);
}
