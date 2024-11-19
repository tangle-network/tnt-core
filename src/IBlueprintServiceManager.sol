// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/**
 * @title IBlueprintServiceManager
 * @dev Interface for the BlueprintServiceManager contract, which acts as a manager for the lifecycle of a Blueprint Instance,
 * facilitating various stages such as registration, service requests, job execution, and job result handling.
 */
interface IBlueprintServiceManager {
    /**
     * @struct OperatorPreferences
     * @dev Represents the preferences of an operator, including their ECDSA public key and price targets.
     */
    struct OperatorPreferences {
        /// @notice The ECDSA public key of the operator.
        bytes ecdsaPublicKey;
        /// @notice The price targets associated with the operator.
        PriceTargets priceTargets;
    }

    /**
     * @struct PriceTargets
     * @dev Defines the pricing targets for various resources such as CPU, memory, and different types of storage.
     */
    struct PriceTargets {
        /// @notice The CPU price target.
        uint64 cpu;
        /// @notice The memory price target.
        uint64 mem;
        /// @notice The HDD storage price target.
        uint64 storage_hdd;
        /// @notice The SSD storage price target.
        uint64 storage_ssd;
        /// @notice The NVMe storage price target.
        uint64 storage_nvme;
    }

    /**
     * @dev Hook for service operator registration. Called when a service operator
     * attempts to register with the blueprint.
     * @param operator The operator's details.
     * @param registrationInputs Inputs required for registration in bytes format.
     */
    function onRegister(OperatorPreferences calldata operator, bytes calldata registrationInputs) external payable;

    /**
     * @dev Hook for service operator unregistration. Called when a service operator
     * attempts to unregister from the blueprint.
     * @param operator The operator's details.
     */
    function onUnregister(OperatorPreferences calldata operator) external;

    /**
     * @dev Hook for updating operator's Price Targets. Called when an operator updates
     * their price targets.
     * @param operator The operator's details with the to be updated price targets.
     */
    function onUpdatePriceTargets(OperatorPreferences calldata operator) external payable;

    /**
     * @dev Hook for service instance requests. Called when a user requests a service
     * instance from the blueprint but this does not mean the service is initiated yet.
     * To get notified when the service is initiated, implement the `onServiceInitialized` hook.
     *
     * @param requestId The ID of the request.
     * @param requester The address of the service requester.
     * @param operators The list of operators to be considered for the service.
     * @param requestInputs The inputs required for the service request in bytes format.
     * @param permittedCallers The list of permitted callers for the service.
     * @param ttl The time-to-live for the service.
     */
    function onRequest(
        uint64 requestId,
        address requester,
        OperatorPreferences[] calldata operators,
        bytes calldata requestInputs,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external
        payable;

    /**
     * @dev Hook for service request approval. Called when a service request is approved by an operator.
     * @param operator The operator's details.
     * @param requestId The ID of the request.
     * @param restakingPercent The percentage of the restaking amount (0-100).
     */
    function onApprove(OperatorPreferences calldata operator, uint64 requestId, uint8 restakingPercent) external payable;

    /**
     * @dev Hook for service request rejection. Called when a service request is rejected by an operator.
     * @param operator The operator's details.
     * @param requestId The ID of the request.
     */
    function onReject(OperatorPreferences calldata operator, uint64 requestId) external;

    /**
     * @dev Hook for service initialization. Called when a service is initialized.
     * This hook is called after the service is approved from all of the operators.
     *
     * @param requestId The ID of the request.
     * @param serviceId The ID of the service.
     * @param owner The owner of the service.
     * @param permittedCallers  The list of permitted callers for the service.
     * @param ttl The time-to-live for the service.
     */
    function onServiceInitialized(
        uint64 requestId,
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external;

    /**
     * @dev Hook for job calls on the service. Called when a job is called within
     * the service context.
     * @param serviceId The ID of the service where the job is called.
     * @param job The job identifier.
     * @param jobCallId A unique ID for the job call.
     * @param inputs Inputs required for the job execution in bytes format.
     */
    function onJobCall(uint64 serviceId, uint8 job, uint64 jobCallId, bytes calldata inputs) external payable;

    /**
     * @dev Hook for handling job result. Called when operators send the result
     * of a job execution.
     * @param serviceId The ID of the service related to the job.
     * @param job The job identifier.
     * @param jobCallId The unique ID for the job call.
     * @param operator The operator sending the result in bytes format.
     * @param inputs Inputs used for the job execution in bytes format.
     * @param outputs Outputs resulting from the job execution in bytes format.
     */
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        OperatorPreferences calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    )
        external
        payable;

    /**
     * @dev Hook for service termination. Called when a service is terminated.
     * @param serviceId The ID of the service to be terminated.
     * @param owner The owner of the service.
     */
    function onServiceTermination(uint64 serviceId, address owner) external;

    /**
     * @dev Hook for handling unapplied slashes. Called when a slash is queued and still not yet applied to an offender.
     * @param serviceId The ID of the service related to the slash.
     * @param offender The offender's details in bytes format.
     * @param slashPercent The percentage of the slash.
     * @param totalPayout The total payout amount in wei.
     */
    function onUnappliedSlash(uint64 serviceId, bytes calldata offender, uint8 slashPercent, uint256 totalPayout) external;

    /**
     * @dev Hook for handling applied slashes. Called when a slash is applied to an offender.
     * @param serviceId The ID of the service related to the slash.
     * @param offender The offender's details in bytes format.
     * @param slashPercent The percentage of the slash.
     * @param totalPayout The total payout amount in wei.
     */
    function onSlash(uint64 serviceId, bytes calldata offender, uint8 slashPercent, uint256 totalPayout) external;

    /**
     * @dev Query the slashing origin for a service. This mainly used by the runtime to determine the allowed account
     * that can slash a service. by default, the service manager is the only account that can slash a service. override this
     * function to allow other accounts to slash a service.
     * @param serviceId The ID of the service.
     * @return slashingOrigin The account that can slash the offender.
     */
    function querySlashingOrigin(uint64 serviceId) external view returns (address slashingOrigin);

    /**
     * @dev Query the dispute origin for a service. This mainly used by the runtime to determine the allowed account
     * that can dispute an unapplied slash and remove it. by default, the service manager is the only account that can dispute a
     * service. override this
     * function to allow other accounts to dispute a service.
     * @param serviceId The ID of the service.
     * @return disputeOrigin The account that can dispute the unapplied slash for that service
     */
    function queryDisputeOrigin(uint64 serviceId) external view returns (address disputeOrigin);
}
