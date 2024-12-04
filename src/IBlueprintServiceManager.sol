// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Service Operators Library
/// @author Tangle Network Team
/// @dev Contains structs and enums related to service operators.
/// @notice Holds different structs and enums related to service operators.
library ServiceOperators {
    /// @dev Represents the preferences of an operator, including their ECDSA public key and price targets.
    struct OperatorPreferences {
        /// @notice The ECDSA public key of the operator.
        bytes ecdsaPublicKey;
        /// @notice The price targets associated with the operator.
        PriceTargets priceTargets;
    }

    /// @dev Defines the pricing targets for various resources such as CPU, memory, and different types of storage.
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

    /// @dev Represents different types of assets that can be used in the system
    enum AssetKind {
        /// @notice Custom Asset Id
        Custom,
        /// @notice Standard ERC20 token asset type
        Erc20
    }

    /// @dev Represents an asset with its type and associated data
    struct Asset {
        /// @notice The kind/type of the asset (Custom or ERC20)
        AssetKind kind;
        /// @notice The data associated with the asset, encoded as bytes32
        /// @dev The data is encoded as follows:
        /// - For Custom assets: The asset ID is stored as uint256
        /// - For ERC20 assets: The token address is stored as address
        bytes32 data;
    }

    /// @dev Represents parameters for a service request
    struct RequestParams {
        /// @notice Unique identifier for the request
        uint64 requestId;
        /// @notice Address of the requester
        address requester;
        /// @notice Array of operator preferences containing public keys and price targets
        OperatorPreferences[] operators;
        /// @notice Input parameters for the request encoded as bytes
        bytes requestInputs;
        /// @notice Array of addresses that are permitted to call the service
        address[] permittedCallers;
        /// @notice Time-to-live value indicating how long the service is valid
        uint64 ttl;
        /// @notice Asset to be used for payment
        Asset paymentAsset;
        /// @notice Amount of payment asset to be used
        uint256 amount;
    }
}

/// @title IBlueprintServiceManager
/// @dev Interface for the BlueprintServiceManager contract, which acts as a manager for the lifecycle of a Blueprint
/// Instance,
/// facilitating various stages such as registration, service requests, job execution, and job result handling.
interface IBlueprintServiceManager {
    /// @dev Hook to handle blueprint creation. Gets called by the root chain when a new blueprint is created.
    /// Could be a good place to store the master blueprint service manager address
    /// or any other blueprint related data.
    /// @param blueprintId The unique identifier for the blueprint.
    /// @param owner The address of the blueprint owner.
    /// @param mbsm The address of the master blueprint service manager.
    function onBlueprintCreated(uint64 blueprintId, address owner, address mbsm) external;

    /// @dev Hook for service operator registration. Called when a service operator
    /// attempts to register with the blueprint.
    /// @param operator The operator's details.
    /// @param registrationInputs Inputs required for registration in bytes format.
    function onRegister(
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata registrationInputs
    )
        external
        payable;

    /// @dev Hook for service operator unregistration. Called when a service operator
    /// attempts to unregister from the blueprint.
    /// @param operator The operator's details.
    function onUnregister(ServiceOperators.OperatorPreferences calldata operator) external;

    /// @dev Hook for updating operator's Price Targets. Called when an operator updates
    /// their price targets.
    /// @param operator The operator's details with the to be updated price targets.
    function onUpdatePriceTargets(ServiceOperators.OperatorPreferences calldata operator) external payable;

    /// @dev Hook for service instance requests. Called when a user requests a service
    /// instance from the blueprint but this does not mean the service is initiated yet.
    /// To get notified when the service is initiated, implement the `onServiceInitialized` hook.
    ///
    /// @param params The parameters for the service request.
    function onRequest(ServiceOperators.RequestParams calldata params) external payable;

    /// @dev Hook for service request approval. Called when a service request is approved by an operator.
    /// @param operator The operator's details.
    /// @param requestId The ID of the request.
    /// @param restakingPercent The percentage of the restaking amount (0-100).
    function onApprove(
        ServiceOperators.OperatorPreferences calldata operator,
        uint64 requestId,
        uint8 restakingPercent
    )
        external
        payable;

    /// @dev Hook for service request rejection. Called when a service request is rejected by an operator.
    /// @param operator The operator's details.
    /// @param requestId The ID of the request.
    function onReject(ServiceOperators.OperatorPreferences calldata operator, uint64 requestId) external;

    /// @dev Hook for service initialization. Called when a service is initialized.
    /// This hook is called after the service is approved from all of the operators.
    ///
    /// @param requestId The ID of the request.
    /// @param serviceId The ID of the service.
    /// @param owner The owner of the service.
    /// @param permittedCallers  The list of permitted callers for the service.
    /// @param ttl The time-to-live for the service.
    function onServiceInitialized(
        uint64 requestId,
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external;

    /// @dev Hook for job calls on the service. Called when a job is called within
    /// the service context.
    /// @param serviceId The ID of the service where the job is called.
    /// @param job The job identifier.
    /// @param jobCallId A unique ID for the job call.
    /// @param inputs Inputs required for the job execution in bytes format.
    function onJobCall(uint64 serviceId, uint8 job, uint64 jobCallId, bytes calldata inputs) external payable;

    /// @dev Hook for handling job result. Called when operators send the result
    /// of a job execution.
    /// @param serviceId The ID of the service related to the job.
    /// @param job The job identifier.
    /// @param jobCallId The unique ID for the job call.
    /// @param operator The operator sending the result in bytes format.
    /// @param inputs Inputs used for the job execution in bytes format.
    /// @param outputs Outputs resulting from the job execution in bytes format.
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    )
        external
        payable;

    /// @dev Hook for service termination. Called when a service is terminated.
    /// @param serviceId The ID of the service to be terminated.
    /// @param owner The owner of the service.
    function onServiceTermination(uint64 serviceId, address owner) external;

    /// @dev Hook for handling unapplied slashes. Called when a slash is queued and still not yet applied to an
    /// offender.
    /// @param serviceId The ID of the service related to the slash.
    /// @param offender The offender's details in bytes format.
    /// @param slashPercent The percentage of the slash.
    /// @param totalPayout The total payout amount in wei.
    function onUnappliedSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        external;

    /// @dev Hook for handling applied slashes. Called when a slash is applied to an offender.
    /// @param serviceId The ID of the service related to the slash.
    /// @param offender The offender's details in bytes format.
    /// @param slashPercent The percentage of the slash.
    /// @param totalPayout The total payout amount in wei.
    function onSlash(uint64 serviceId, bytes calldata offender, uint8 slashPercent, uint256 totalPayout) external;

    /// @dev Query the slashing origin for a service. This mainly used by the runtime to determine the allowed account
    /// that can slash a service. by default, the service manager is the only account that can slash a service. override
    /// this
    /// function to allow other accounts to slash a service.
    /// @param serviceId The ID of the service.
    /// @return slashingOrigin The account that can slash the offender.
    function querySlashingOrigin(uint64 serviceId) external view returns (address slashingOrigin);

    /// @dev Query the dispute origin for a service. This mainly used by the runtime to determine the allowed account
    /// that can dispute an unapplied slash and remove it. by default, the service manager is the only account that can
    /// dispute a
    /// service. override this
    /// function to allow other accounts to dispute a service.
    /// @param serviceId The ID of the service.
    /// @return disputeOrigin The account that can dispute the unapplied slash for that service
    function queryDisputeOrigin(uint64 serviceId) external view returns (address disputeOrigin);

    /// @dev Query the developer payment address for a service. This mainly used by the runtime or the Master Blueprint
    /// Service
    /// Manager
    /// to determine the developer payment address for a service.
    /// @notice This function should be implemented by the Blueprint Service Manager contract.
    /// @param serviceId The ID of the service.
    /// @return developerPaymentAddress The address of the developer payment address for that service
    function queryDeveloperPaymentAddress(uint64 serviceId) external view returns (address developerPaymentAddress);
}
