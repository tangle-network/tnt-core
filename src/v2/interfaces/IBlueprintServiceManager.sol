// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IBlueprintServiceManager
/// @notice Full interface for blueprint-specific service managers
/// @dev Blueprint developers implement this to customize all aspects of their blueprint.
///      This is the primary integration point for blueprint developers - implement the hooks
///      you need and leave others as default (via BlueprintServiceManagerBase).
///
/// The lifecycle flow:
/// 1. Blueprint created → onBlueprintCreated
/// 2. Operators register → onRegister
/// 3. Service requested → onRequest
/// 4. Operators approve → onApprove
/// 5. Service activated → onServiceInitialized
/// 6. Jobs submitted → onJobCall
/// 7. Results submitted → onJobResult
/// 8. Service terminated → onServiceTermination
interface IBlueprintServiceManager {
    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when blueprint is created
    /// @dev Store the blueprintId and tangleCore address for future reference
    /// @param blueprintId The new blueprint ID
    /// @param owner The blueprint owner
    /// @param tangleCore The address of the Tangle core contract
    function onBlueprintCreated(uint64 blueprintId, address owner, address tangleCore) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when an operator registers to this blueprint
    /// @dev Validate operator requirements here (stake, reputation, etc.)
    /// @param operator The operator's address
    /// @param registrationInputs Custom registration data (blueprint-specific encoding)
    function onRegister(address operator, bytes calldata registrationInputs) external payable;

    /// @notice Called when an operator unregisters from this blueprint
    /// @param operator The operator's address
    function onUnregister(address operator) external;

    /// @notice Called when an operator updates their preferences (RPC address, etc.)
    /// @param operator The operator's address
    /// @param newPreferences Updated preferences data
    function onUpdatePreferences(address operator, bytes calldata newPreferences) external payable;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE CONFIGURATION QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the heartbeat interval for a service
    /// @dev Operators must submit heartbeats within this interval
    /// @param serviceId The service ID
    /// @return useDefault True to use protocol default, false to use custom value
    /// @return interval Heartbeat interval in blocks (0 = disabled)
    function getHeartbeatInterval(uint64 serviceId) external view returns (bool useDefault, uint64 interval);

    /// @notice Get the heartbeat threshold for a service
    /// @dev Percentage of operators that must respond within interval
    /// @param serviceId The service ID
    /// @return useDefault True to use protocol default
    /// @return threshold Threshold percentage (0-100)
    function getHeartbeatThreshold(uint64 serviceId) external view returns (bool useDefault, uint8 threshold);

    /// @notice Get the slashing window for a service
    /// @dev Time window for disputes before slash is finalized
    /// @param serviceId The service ID
    /// @return useDefault True to use protocol default
    /// @return window Slashing window in blocks
    function getSlashingWindow(uint64 serviceId) external view returns (bool useDefault, uint64 window);

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when a service is requested
    /// @dev Validate service configuration, operator selection, payment amount
    /// @param requestId The request ID
    /// @param requester Who is requesting the service
    /// @param operators Requested operators
    /// @param requestInputs Service configuration (blueprint-specific encoding)
    /// @param ttl Time-to-live for the service
    /// @param paymentAsset Payment token address (address(0) for native)
    /// @param paymentAmount Payment amount
    function onRequest(
        uint64 requestId,
        address requester,
        address[] calldata operators,
        bytes calldata requestInputs,
        uint64 ttl,
        address paymentAsset,
        uint256 paymentAmount
    ) external payable;

    /// @notice Called when an operator approves a service request
    /// @param operator The approving operator
    /// @param requestId The request ID
    /// @param restakingPercent Percentage of stake committed to this service (0-100)
    function onApprove(address operator, uint64 requestId, uint8 restakingPercent) external payable;

    /// @notice Called when an operator rejects a service request
    /// @param operator The rejecting operator
    /// @param requestId The request ID
    function onReject(address operator, uint64 requestId) external;

    /// @notice Called when service becomes active (all operators approved)
    /// @param blueprintId The blueprint ID
    /// @param requestId The original request ID
    /// @param serviceId The new service ID
    /// @param owner The service owner
    /// @param permittedCallers Addresses allowed to submit jobs
    /// @param ttl Service time-to-live
    function onServiceInitialized(
        uint64 blueprintId,
        uint64 requestId,
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers,
        uint64 ttl
    ) external;

    /// @notice Called when service is terminated
    /// @param serviceId The service ID
    /// @param owner The service owner
    function onServiceTermination(uint64 serviceId, address owner) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if an operator can join a dynamic service
    /// @dev Called before operator joins - return false to reject
    /// @param serviceId The service ID
    /// @param operator The operator wanting to join
    /// @return allowed True if operator can join
    function canJoin(uint64 serviceId, address operator) external view returns (bool allowed);

    /// @notice Called after an operator successfully joins a service
    /// @param serviceId The service ID
    /// @param operator The operator that joined
    /// @param exposureBps The operator's stake exposure in basis points
    function onOperatorJoined(uint64 serviceId, address operator, uint16 exposureBps) external;

    /// @notice Check if an operator can leave a dynamic service
    /// @dev Called before operator leaves - return false to reject
    /// @param serviceId The service ID
    /// @param operator The operator wanting to leave
    /// @return allowed True if operator can leave
    function canLeave(uint64 serviceId, address operator) external view returns (bool allowed);

    /// @notice Called after an operator successfully leaves a service
    /// @param serviceId The service ID
    /// @param operator The operator that left
    function onOperatorLeft(uint64 serviceId, address operator) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when a job is submitted
    /// @dev Validate job inputs, check caller permissions, etc.
    /// @param serviceId The service ID
    /// @param job The job index in the blueprint
    /// @param jobCallId Unique ID for this job call
    /// @param inputs Job inputs (blueprint-specific encoding)
    function onJobCall(uint64 serviceId, uint8 job, uint64 jobCallId, bytes calldata inputs) external payable;

    /// @notice Called when an operator submits a job result
    /// @dev Validate result format, check operator eligibility, aggregate results
    /// @param serviceId The service ID
    /// @param job The job index
    /// @param jobCallId The job call ID
    /// @param operator The operator submitting
    /// @param inputs Original job inputs
    /// @param outputs Result outputs (blueprint-specific encoding)
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        address operator,
        bytes calldata inputs,
        bytes calldata outputs
    ) external payable;

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when a slash is queued but not yet applied
    /// @dev This is the dispute window - gather evidence, notify parties
    /// @param serviceId The service ID
    /// @param offender The operator being slashed (encoded as bytes for flexibility)
    /// @param slashPercent Percentage of stake to slash
    function onUnappliedSlash(uint64 serviceId, bytes calldata offender, uint8 slashPercent) external;

    /// @notice Called when a slash is finalized and applied
    /// @param serviceId The service ID
    /// @param offender The slashed operator
    /// @param slashPercent Percentage slashed
    function onSlash(uint64 serviceId, bytes calldata offender, uint8 slashPercent) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // AUTHORIZATION QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Query the account authorized to propose slashes for a service
    /// @dev Override to allow custom slashing authorities (dispute contracts, etc.)
    /// @param serviceId The service ID
    /// @return slashingOrigin Address that can slash (default: this contract)
    function querySlashingOrigin(uint64 serviceId) external view returns (address slashingOrigin);

    /// @notice Query the account authorized to dispute slashes
    /// @dev Override to allow custom dispute resolution
    /// @param serviceId The service ID
    /// @return disputeOrigin Address that can dispute (default: this contract)
    function queryDisputeOrigin(uint64 serviceId) external view returns (address disputeOrigin);

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the developer payment address for a service
    /// @dev Override to route payments to different addresses per service
    /// @param serviceId The service ID
    /// @return developerPaymentAddress Address to receive developer share
    function queryDeveloperPaymentAddress(uint64 serviceId)
        external
        view
        returns (address payable developerPaymentAddress);

    /// @notice Check if a payment asset is allowed for this blueprint
    /// @param serviceId The service ID
    /// @param asset The payment asset address (address(0) for native)
    /// @return isAllowed True if the asset can be used for payment
    function queryIsPaymentAssetAllowed(uint64 serviceId, address asset) external view returns (bool isAllowed);

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the number of results required to complete a job
    /// @dev Override for consensus requirements (e.g., 2/3 majority)
    /// @param serviceId The service ID
    /// @param jobIndex The job index
    /// @return required Number of results needed (0 = service operator count)
    function getRequiredResultCount(uint64 serviceId, uint8 jobIndex) external view returns (uint32 required);

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the minimum stake required for operators to register for this blueprint
    /// @dev Called during operator registration to validate stake requirements
    /// @return useDefault True to use protocol default from restaking module
    /// @return minStake Custom minimum stake amount (only used if useDefault=false)
    function getMinOperatorStake() external view returns (bool useDefault, uint256 minStake);
}
