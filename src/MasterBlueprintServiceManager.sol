// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "src/Permissions.sol";
import "src/IBlueprintServiceManager.sol";

/// @title Master Blueprint Service Manager
/// @author Tangle
/// @dev This contract acts as an interceptor between the root chain and blueprint service manager contracts.
contract MasterBlueprintServiceManager is RootChainEnabled, AccessControl, Pausable {
    using EnumerableMap for EnumerableMap.UintToAddressMap;
    using Assets for Assets.Asset;
    using Assets for address;
    using Assets for bytes32;
    using SafeERC20 for IERC20;

    /// @title Blueprint Structs
    /// @dev Defines the Blueprint and related data structures for the service.
    /// @notice Use this struct to define the blueprint of a service.
    struct Blueprint {
        /// @dev The metadata information about the service.
        ServiceMetadata metadata;
        /// @dev The address of the blueprint service manager.
        address manager;
        /// @dev The Master Blueprint Service Manager revision.
        uint32 mbsmRevision;
    }

    /// @dev Contains metadata information about the service.
    /// @notice Provides descriptive details about the service.
    struct ServiceMetadata {
        string name;
        string description; // Empty string represents None
        string author; // Empty string represents None
        string category; // Empty string represents None
        string codeRepository; // Empty string represents None
        string logo; // Empty string represents None
        string website; // Empty string represents None
        string license; // Empty string represents None
    }

    // ============ Events ============

    /// @dev Emitted when a new blueprint is created.
    /// @notice A new blueprint is created.
    /// @param owner The owner of the blueprint.
    /// @param blueprintId The unique identifier for the blueprint.
    /// @param blueprint The blueprint data.
    event BlueprintCreated(address indexed owner, uint64 indexed blueprintId, Blueprint blueprint);

    /// @dev Emitted when a service operator registers with a blueprint.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param operator The operator's preferences.
    event OperatorRegistered(uint64 indexed blueprintId, ServiceOperators.OperatorPreferences operator);

    /// @dev Emitted when a service operator unregisters from a blueprint.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param operator The operator's preferences.
    event OperatorUnregistered(uint64 indexed blueprintId, ServiceOperators.OperatorPreferences operator);

    /// @dev Emitted when an operator updates their price targets.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param operator The operator's updated preferences.
    event PriceTargetsUpdated(uint64 indexed blueprintId, ServiceOperators.OperatorPreferences operator);

    /// @dev Emitted when a service instance is requested from a blueprint.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param requestId The ID of the request.
    /// @param requester The address of the service requester.
    /// @param ttl The time-to-live for the service.
    /// @param asset The asset used for payment for the service.
    /// @param amount The amount of the payment asset.
    event ServiceRequested(
        uint64 indexed blueprintId,
        uint64 indexed requestId,
        address indexed requester,
        uint64 ttl,
        Assets.Asset asset,
        uint256 amount
    );

    /// @dev Emitted when a service request is approved by an operator.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param requestId The ID of the request.
    /// @param operator The operator's preferences.
    /// @param restakingPercent The percentage of the restaking amount.
    event RequestApproved(
        uint64 indexed blueprintId,
        uint64 indexed requestId,
        ServiceOperators.OperatorPreferences operator,
        uint8 restakingPercent
    );

    /// @dev Emitted when a service request is rejected by an operator.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param requestId The ID of the request.
    /// @param operator The operator's preferences.
    event RequestRejected(
        uint64 indexed blueprintId, uint64 indexed requestId, ServiceOperators.OperatorPreferences operator
    );

    /// @dev Emitted when a service is initialized.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param requestId The ID of the request.
    /// @param serviceId The ID of the service.
    /// @param owner The owner of the service.
    /// @param ttl The time-to-live for the service.
    event ServiceInitialized(
        uint64 indexed blueprintId, uint64 indexed requestId, uint64 indexed serviceId, address owner, uint64 ttl
    );

    /// @dev Emitted when a job is called within the service context.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param serviceId The ID of the service.
    /// @param job The job identifier.
    /// @param jobCallId The unique ID for the job call.
    event JobCalled(uint64 indexed blueprintId, uint64 indexed serviceId, uint8 job, uint64 jobCallId);

    /// @dev Emitted when a job result is received from an operator.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param serviceId The ID of the service.
    /// @param job The job identifier.
    /// @param jobCallId The unique ID for the job call.
    /// @param operator The operator's preferences.
    event JobResultReceived(
        uint64 indexed blueprintId,
        uint64 indexed serviceId,
        uint8 job,
        uint64 jobCallId,
        ServiceOperators.OperatorPreferences operator
    );

    /// @dev Emitted when a service is terminated.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param serviceId The ID of the service.
    /// @param owner The owner of the service.
    event ServiceTerminated(uint64 indexed blueprintId, uint64 indexed serviceId, address owner);

    /// @dev Emitted when a slash is queued but not yet applied.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param serviceId The ID of the service.
    /// @param offender The offender's details.
    /// @param slashPercent The percentage of the slash.
    /// @param totalPayout The total payout amount.
    event UnappliedSlash(
        uint64 indexed blueprintId, uint64 indexed serviceId, bytes offender, uint8 slashPercent, uint256 totalPayout
    );

    /// @dev Emitted when a slash is applied to an offender.
    /// @param blueprintId The unique identifier of the blueprint.
    /// @param serviceId The ID of the service.
    /// @param offender The offender's details.
    /// @param slashPercent The percentage of the slash.
    /// @param totalPayout The total payout amount.
    event Slashed(
        uint64 indexed blueprintId, uint64 indexed serviceId, bytes offender, uint8 slashPercent, uint256 totalPayout
    );

    // ============ Storage ============

    /// @dev Mapping that store the blueprint service manager contracts.
    /// @notice Contains the blueprints created by the runtime.
    ///
    /// blueprintId => Blueprint Service Manager address
    EnumerableMap.UintToAddressMap private blueprints;

    /// @dev Mapping to store the blueprint owners.
    /// @notice Contains the owner of the blueprints.
    ///
    /// blueprintId => owner
    EnumerableMap.UintToAddressMap private blueprintOwners;

    /// @dev Mapping that stores the Service requests for a blueprint.
    /// @notice Contains the service requests for a blueprint.
    ///
    /// requestId => request
    mapping(uint64 => ServiceOperators.RequestParams) private serviceRequests;

    // ======== Functions =========

    /// @dev Hook to handle blueprint creation. Gets called by the root chain when a new blueprint is created.
    /// @param blueprintId The unique identifier for the blueprint.
    /// @param owner The address of the blueprint owner.
    /// @param blueprint The blueprint data.
    function onBlueprintCreated(
        uint64 blueprintId,
        address owner,
        Blueprint calldata blueprint
    )
        public
        payable
        onlyFromRootChain
        whenNotPaused
    {
        blueprints.set(blueprintId, blueprint.manager);
        blueprintOwners.set(blueprintId, owner);
        emit BlueprintCreated(owner, blueprintId, blueprint);
    }

    /// @dev Called by the runtime when a service operator attempts to register with the blueprint.
    /// @param blueprintId The blueprint unique identifier.
    /// @param operator The Service Operator.
    /// @param registrationInputs The registration inputs in bytes format.
    function onRegister(
        uint64 blueprintId,
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata registrationInputs
    )
        public
        payable
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onRegister(operator, registrationInputs);
        emit OperatorRegistered(blueprintId, operator);
    }

    /// @dev Called when a service operator attempts to unregister from the blueprint.
    /// @param blueprintId The blueprint unique identifier.
    /// @param operator The operator's details.
    function onUnregister(
        uint64 blueprintId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        public
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onUnregister(operator);
        emit OperatorUnregistered(blueprintId, operator);
    }

    /// @dev Called when an operator updates their price targets.
    /// @param blueprintId The blueprint unique identifier.
    /// @param operator The operator's details with the updated price targets.
    function onUpdatePriceTargets(
        uint64 blueprintId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        public
        payable
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onUpdatePriceTargets(operator);
        emit PriceTargetsUpdated(blueprintId, operator);
    }

    /// @dev Called when a user requests a service instance from the blueprint.
    /// @param blueprintId The blueprint unique identifier.
    /// @param params The request parameters.
    function onRequest(
        uint64 blueprintId,
        ServiceOperators.RequestParams calldata params
    )
        public
        payable
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onRequest(params);
        serviceRequests[params.requestId] = params;
        emit ServiceRequested(
            blueprintId, params.requestId, params.requester, params.ttl, params.paymentAsset, params.amount
        );
    }

    /// @dev Called when a service request is approved by an operator.
    /// @param blueprintId The blueprint unique identifier.
    /// @param operator The operator's details.
    /// @param requestId The ID of the request.
    /// @param restakingPercent The percentage of the restaking amount.
    function onApprove(
        uint64 blueprintId,
        ServiceOperators.OperatorPreferences calldata operator,
        uint64 requestId,
        uint8 restakingPercent
    )
        public
        payable
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onApprove(operator, requestId, restakingPercent);
        emit RequestApproved(blueprintId, requestId, operator, restakingPercent);
    }

    /// @dev Called when a service request is rejected by an operator.
    /// @param blueprintId The blueprint unique identifier.
    /// @param operator The operator's details.
    /// @param requestId The ID of the request.
    function onReject(
        uint64 blueprintId,
        ServiceOperators.OperatorPreferences calldata operator,
        uint64 requestId
    )
        public
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onReject(operator, requestId);
        delete serviceRequests[requestId];
        emit RequestRejected(blueprintId, requestId, operator);
    }

    /// @dev Called when a service is initialized.
    /// @param blueprintId The blueprint unique identifier.
    /// @param requestId The ID of the request.
    /// @param serviceId The ID of the service.
    /// @param owner The owner of the service.
    /// @param permittedCallers The list of permitted callers.
    /// @param ttl The time-to-live for the service.
    function onServiceInitialized(
        uint64 blueprintId,
        uint64 requestId,
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        public
        onlyFromRootChain
        whenNotPaused
    {
        IBlueprintServiceManager manager = IBlueprintServiceManager(blueprints.get(blueprintId));
        ServiceOperators.RequestParams memory request = serviceRequests[requestId];
        _splitFunds(manager, serviceId, request);
        manager.onServiceInitialized(requestId, serviceId, owner, permittedCallers, ttl);
        emit ServiceInitialized(blueprintId, requestId, serviceId, owner, ttl);
    }

    /// @dev Called when a job is called within the service context.
    /// @param blueprintId The blueprint unique identifier.
    /// @param serviceId The ID of the service.
    /// @param job The job identifier.
    /// @param jobCallId The unique ID for the job call.
    /// @param inputs The inputs required for the job execution.
    function onJobCall(
        uint64 blueprintId,
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata inputs
    )
        public
        payable
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onJobCall(serviceId, job, jobCallId, inputs);
        emit JobCalled(blueprintId, serviceId, job, jobCallId);
    }

    /// @dev Called when operators send the result of a job execution.
    /// @param blueprintId The blueprint unique identifier.
    /// @param serviceId The ID of the service.
    /// @param job The job identifier.
    /// @param jobCallId The unique ID for the job call.
    /// @param operator The operator sending the result.
    /// @param inputs The inputs used for the job execution.
    /// @param outputs The outputs from the job execution.
    function onJobResult(
        uint64 blueprintId,
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    )
        public
        payable
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onJobResult(serviceId, job, jobCallId, operator, inputs, outputs);
        emit JobResultReceived(blueprintId, serviceId, job, jobCallId, operator);
    }

    /// @dev Called when a service is terminated.
    /// @param blueprintId The blueprint unique identifier.
    /// @param serviceId The ID of the service.
    /// @param owner The owner of the service.
    function onServiceTermination(
        uint64 blueprintId,
        uint64 serviceId,
        address owner
    )
        public
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onServiceTermination(serviceId, owner);
        emit ServiceTerminated(blueprintId, serviceId, owner);
    }

    /// @dev Called when a slash is queued but not yet applied.
    /// @param blueprintId The blueprint unique identifier.
    /// @param serviceId The ID of the service.
    /// @param offender The offender's details.
    /// @param slashPercent The percentage of the slash.
    /// @param totalPayout The total payout amount.
    function onUnappliedSlash(
        uint64 blueprintId,
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        public
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onUnappliedSlash(serviceId, offender, slashPercent, totalPayout);
        emit UnappliedSlash(blueprintId, serviceId, offender, slashPercent, totalPayout);
    }

    /// @dev Called when a slash is applied to an offender.
    /// @param blueprintId The blueprint unique identifier.
    /// @param serviceId The ID of the service.
    /// @param offender The offender's details.
    /// @param slashPercent The percentage of the slash.
    /// @param totalPayout The total payout amount.
    function onSlash(
        uint64 blueprintId,
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        public
        onlyFromRootChain
        whenNotPaused
    {
        address manager = blueprints.get(blueprintId);
        IBlueprintServiceManager(manager).onSlash(serviceId, offender, slashPercent, totalPayout);
        emit Slashed(blueprintId, serviceId, offender, slashPercent, totalPayout);
    }

    /// @dev Query the slashing origin for a service.
    /// @param blueprintId The blueprint unique identifier.
    /// @param serviceId The ID of the service.
    /// @return slashingOrigin The account that can slash the offender.
    function querySlashingOrigin(uint64 blueprintId, uint64 serviceId) public view returns (address slashingOrigin) {
        address manager = blueprints.get(blueprintId);
        return IBlueprintServiceManager(manager).querySlashingOrigin(serviceId);
    }

    /// @dev Query the dispute origin for a service.
    /// @param blueprintId The blueprint unique identifier.
    /// @param serviceId The ID of the service.
    /// @return disputeOrigin The account that can dispute the unapplied slash.
    function queryDisputeOrigin(uint64 blueprintId, uint64 serviceId) public view returns (address disputeOrigin) {
        address manager = blueprints.get(blueprintId);
        return IBlueprintServiceManager(manager).queryDisputeOrigin(serviceId);
    }

    function _splitFunds(
        IBlueprintServiceManager manager,
        uint64 serviceId,
        ServiceOperators.RequestParams memory request
    )
        internal
    {
        // TODO: make the following logic dynamic and configurable.
        // Here is an example:
        // - Developers: 50%
        // - Protocol: 20%
        // - Operators/Restakers: 30% (Operators 10%, Restakers 20%)
        uint256 totalAmount = request.amount;
        uint256 developerAmount = (totalAmount * 50) / 100;
        uint256 protocolAmount = (totalAmount * 20) / 100;
        uint256 operatorAmount = (totalAmount * 10) / 100;
        uint256 restakerAmount = (totalAmount * 20) / 100;
        uint256 toRewardsPallet = operatorAmount + restakerAmount;

        address payable developer = manager.queryDeveloperPaymentAddress(serviceId);
        // TODO: add real addresses
        address payable protocol = payable(address(0x0));
        address payable rewardsPallet = payable(address(0x1));

        if (request.paymentAsset.isNative()) {
            // Native asset
            developer.transfer(developerAmount);
            protocol.transfer(protocolAmount);
            // rewardsPallet.transfer(operatorAmount + restakerAmount);
            // TODO: call the rewards pallet precompile here.
        } else {
            // ERC20
            address token = request.paymentAsset.toAddress();
            IERC20(token).safeTransfer(developer, developerAmount);
            IERC20(token).safeTransfer(protocol, protocolAmount);
            IERC20(token).safeTransfer(rewardsPallet, toRewardsPallet);
            // TODO: call the rewards pallet precompile here.
        }
    }
}
