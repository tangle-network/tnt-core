// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Errors
/// @notice Custom errors for Tangle Protocol v2
/// @dev Custom errors are more gas efficient than require strings
library Errors {
    // ═══════════════════════════════════════════════════════════════════════════
    // GENERAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Zero address provided where non-zero required
    error ZeroAddress();

    /// @notice Zero amount provided where non-zero required
    error ZeroAmount();

    /// @notice Caller not authorized for this action
    error Unauthorized();

    /// @notice Operation would result in invalid state
    error InvalidState();

    /// @notice Array length mismatch
    error LengthMismatch();

    /// @notice Deadline has passed
    error DeadlineExpired();

    // ═══════════════════════════════════════════════════════════════════════════
    // SCHEMA
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Schema exceeds supported depth or node limits
    error SchemaTooLarge();

    /// @notice Schema validation failed at encoded path
    error SchemaValidationFailed(uint8 target, uint64 refId, uint64 auxId, uint256 path);

    /// @notice Schema field kind is not supported
    error UnsupportedFieldKind(uint8 kind);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Blueprint does not exist
    error BlueprintNotFound(uint64 blueprintId);

    /// @notice Blueprint is not active
    error BlueprintNotActive(uint64 blueprintId);

    /// @notice Caller is not blueprint owner
    error NotBlueprintOwner(uint64 blueprintId, address caller);

    /// @notice Blueprint definition missing required metadata
    error BlueprintMetadataRequired();

    /// @notice Blueprint definition missing supported membership models
    error BlueprintMembershipRequired();

    /// @notice Blueprint definition missing implementation sources
    error BlueprintSourcesRequired();

    /// @notice MBSM registry not configured
    error MBSMRegistryNotSet();

    /// @notice Unable to resolve a master blueprint service manager revision
    error MasterManagerUnavailable();

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator not registered for this blueprint
    error OperatorNotRegistered(uint64 blueprintId, address operator);

    /// @notice Operator already registered for this blueprint
    error OperatorAlreadyRegistered(uint64 blueprintId, address operator);

    /// @notice Operator is not active
    error OperatorNotActive(address operator);

    /// @notice Operator does not meet minimum stake requirement
    error InsufficientStake(address operator, uint256 required, uint256 actual);

    /// @notice Operator exceeded blueprint registration limit
    error MaxBlueprintsPerOperatorExceeded(address operator, uint32 maxAllowed);

    /// @notice Operator provided invalid gossip key
    error InvalidOperatorKey();

    /// @notice Gossip key already registered for blueprint
    error DuplicateOperatorKey(uint64 blueprintId, bytes32 keyHash);

    /// @notice Incorrect bond amount supplied during registration
    error OperatorBondMismatch(uint64 blueprintId, uint256 required, uint256 sent);

    /// @notice Failed to refund operator bond on unregister
    error OperatorBondRefundFailed(address operator, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Service request not found
    error ServiceRequestNotFound(uint64 requestId);

    /// @notice Service request already processed
    error ServiceRequestAlreadyProcessed(uint64 requestId);

    /// @notice Service not found
    error ServiceNotFound(uint64 serviceId);

    /// @notice Service is not active
    error ServiceNotActive(uint64 serviceId);

    /// @notice Service has expired
    error ServiceExpired(uint64 serviceId);

    /// @notice Caller is not service owner
    error NotServiceOwner(uint64 serviceId, address caller);

    /// @notice Caller is not a permitted caller for this service
    error NotPermittedCaller(uint64 serviceId, address caller);

    /// @notice Operator is not part of this service
    error OperatorNotInService(uint64 serviceId, address operator);

    /// @notice Operator already approved this request
    error AlreadyApproved(uint64 requestId, address operator);

    /// @notice Insufficient operators for service (below blueprint minimum)
    error InsufficientOperators(uint32 required, uint32 provided);

    /// @notice Too many operators for service (exceeds blueprint maximum)
    error TooManyOperators(uint32 maximum, uint32 provided);

    /// @notice No operators specified
    error NoOperators();

    /// @notice Invalid TTL value
    error InvalidTTL(uint64 ttl);

    /// @notice No security requirements provided
    error NoSecurityRequirements();

    /// @notice Invalid security requirement (min > max, zero exposure, etc.)
    error InvalidSecurityRequirement();

    /// @notice Security commitments don't match requirements
    error SecurityCommitmentMismatch();

    /// @notice Commitment exposure below minimum requirement
    error CommitmentBelowMinimum(address asset, uint16 committed, uint16 minimum);

    /// @notice Commitment exposure above maximum requirement
    error CommitmentAboveMaximum(address asset, uint16 committed, uint16 maximum);

    /// @notice Missing commitment for required asset
    error MissingAssetCommitment(address asset);

    /// @notice Operator lacks sufficient stake for commitment
    error InsufficientStakeForCommitment(address operator, address asset);

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Job call not found
    error JobCallNotFound(uint64 serviceId, uint64 callId);

    /// @notice Job already completed
    error JobAlreadyCompleted(uint64 serviceId, uint64 callId);

    /// @notice Invalid job index
    error InvalidJobIndex(uint8 jobIndex);

    /// @notice Operator already submitted result for this job
    error ResultAlreadySubmitted(uint64 serviceId, uint64 callId, address operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Insufficient payment sent
    error InsufficientPayment(uint256 required, uint256 sent);

    /// @notice Payment transfer failed
    error PaymentFailed();

    /// @notice Payment token not allowed
    error TokenNotAllowed(address token);

    /// @notice Invalid payment token for escrow
    error InvalidPaymentToken();

    // ═══════════════════════════════════════════════════════════════════════════
    // RESTAKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Restaking module not set
    error RestakingNotSet();

    /// @notice Slash amount exceeds stake
    error SlashExceedsStake(address operator, uint256 slashAmount, uint256 stake);

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE MANAGER
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Service manager call reverted
    error ManagerReverted(address manager, bytes reason);

    /// @notice Service manager rejected operation
    error ManagerRejected(address manager);

    // ═══════════════════════════════════════════════════════════════════════════
    // HOOK (DEPRECATED - use Manager errors)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Hook call reverted
    error HookReverted(address hook, bytes reason);

    /// @notice Hook returned false (rejected operation)
    error HookRejected(address hook);

    // ═══════════════════════════════════════════════════════════════════════════
    // RFQ (Request For Quote)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Quote has expired
    error QuoteExpired(address operator, uint64 expiry);

    /// @notice Quote signature invalid
    error InvalidQuoteSignature(address operator);

    /// @notice Quote blueprint mismatch
    error QuoteBlueprintMismatch(address operator, uint64 expectedBlueprint, uint64 quotedBlueprint);

    /// @notice Quote TTL mismatch
error QuoteTTLMismatch(address operator, uint64 expectedTtl, uint64 quotedTtl);

    /// @notice No quotes provided
    error NoQuotes();

    /// @notice Duplicate operator in quotes
    error DuplicateOperatorQuote(address operator);

    /// @notice Total quote cost exceeds payment
    error InsufficientPaymentForQuotes(uint256 totalCost, uint256 payment);

    /// @notice Quote already used (replay protection)
    error QuoteAlreadyUsed(address operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // ESCROW
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Insufficient escrow balance
    error InsufficientEscrowBalance(uint256 required, uint256 available);

    /// @notice Invalid payment split (doesn't sum to 100%)
    error InvalidPaymentSplit();

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slash proposal not found
    error SlashNotFound(uint64 slashId);

    /// @notice Slash not in pending status
    error SlashNotPending(uint64 slashId);

    /// @notice Slash not executable (wrong status or time)
    error SlashNotExecutable(uint64 slashId);

    /// @notice Slash already executed
    error SlashAlreadyExecuted(uint64 slashId);

    /// @notice Slash already cancelled
    error SlashAlreadyCancelled(uint64 slashId);

    /// @notice Dispute window has passed
    error DisputeWindowPassed(uint64 slashId);

    /// @notice Invalid slash amount (zero)
    error InvalidSlashAmount();

    /// @notice Invalid slash configuration
    error InvalidSlashConfig();

    /// @notice Instant slash not enabled
    error InstantSlashNotEnabled();

    /// @notice Caller not authorized to dispute slash
    error NotSlashDisputer(uint64 slashId, address caller);

    /// @notice Caller not authorized to cancel slash
    error NotSlashCanceller(uint64 slashId, address caller);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLS AGGREGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Job requires aggregated result, use submitAggregatedResult
    error AggregationRequired(uint64 serviceId, uint8 jobIndex);

    /// @notice Aggregated result not allowed for this job
    error AggregationNotRequired(uint64 serviceId, uint8 jobIndex);

    /// @notice Invalid BLS signature
    error InvalidBLSSignature();

    /// @notice Aggregation threshold not met
    error AggregationThresholdNotMet(uint64 serviceId, uint64 callId, uint256 achieved, uint256 required);

    /// @notice Operator not found in signer bitmap
    error InvalidSignerBitmap(uint256 bitmap);

    /// @notice Signer is not an active operator for this service
    error InvalidSigner(uint64 serviceId, address signer);

    /// @notice Duplicate signer in bitmap
    error DuplicateSigner();

    /// @notice Invalid G1 point in signature
    error InvalidG1Point();

    /// @notice Invalid G2 point in public key
    error InvalidG2Point();

    // ═══════════════════════════════════════════════════════════════════════════
    // EXIT QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator has not been in service long enough to exit
    error ExitTooEarly(uint64 serviceId, address operator, uint64 minCommitmentEnd, uint64 currentTime);

    /// @notice Exit not yet scheduled
    error ExitNotScheduled(uint64 serviceId, address operator);

    /// @notice Exit already scheduled
    error ExitAlreadyScheduled(uint64 serviceId, address operator);

    /// @notice Exit not yet executable (still in queue)
    error ExitNotExecutable(uint64 serviceId, address operator, uint64 executeAfter, uint64 currentTime);

    /// @notice Force exit not allowed for this service
    error ForceExitNotAllowed(uint64 serviceId);
}
