// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "src/Permissions.sol";
import "src/IBlueprintServiceManager.sol";

/**fo
 * @title BlueprintServiceManagerBase
 * @dev This contract acts as a manager for the lifecycle of a Blueprint Instance,
 * facilitating various stages such as registration, service requests, job execution,
 * and job result handling. It is designed to be used by the service blueprint designer
 * (gadget developer) and integrates with the RootChain for permissioned operations.
 * Each function serves as a hook for different lifecycle events, and reverting any
 * of these functions interrupts the process flow.
 */
contract BlueprintServiceManagerBase is IBlueprintServiceManager, RootChainEnabled {
    /**
     * @dev Hook for service operator registration. Called when a service operator
     * attempts to register with the blueprint.
     * @param operator The operator's details in bytes format.
     * @param registrationInputs Inputs required for registration in bytes format.
     */
    function onRegister(
        bytes calldata operator,
        bytes calldata registrationInputs
    )
        public
        payable
        virtual
        override
        onlyFromRootChain
    { }

    /**
     * @dev Hook for service instance requests. Called when a user requests a service
     * instance from the blueprint.
     * @param serviceId The ID of the requested service.
     * @param operators The operators involved in the service in bytes array format.
     * @param requestInputs Inputs required for the service request in bytes format.
     */
    function onRequest(
        uint64 serviceId,
        bytes[] calldata operators,
        bytes calldata requestInputs
    )
        public
        payable
        virtual
        override
        onlyFromRootChain
    { }

    /**
     * @dev Hook for job calls on the service. Called when a job is called within
     * the service context.
     * @param serviceId The ID of the service where the job is called.
     * @param job The job identifier.
     * @param jobCallId A unique ID for the job call.
     * @param inputs Inputs required for the job execution in bytes format.
     */
    function onJobCall(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata inputs
    )
        public
        payable
        virtual
        override
        onlyFromRootChain
    { }

    /**
     * @dev Hook for handling job result. Called when operators send the result
     * of a job execution.
     * @param serviceId The ID of the service related to the job.
     * @param job The job identifier.
     * @param jobCallId The unique ID for the job call.
     * @param participant The participant (operator) sending the result in bytes format.
     * @param inputs Inputs used for the job execution in bytes format.
     * @param outputs Outputs resulting from the job execution in bytes format.
     */
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata participant,
        bytes calldata inputs,
        bytes calldata outputs
    )
        public
        payable
        virtual
        override
        onlyFromRootChain
    { }

    /**
     * @dev Hook for handling unapplied slashes. Called when a slash is queued and still not yet applied to an offender.
     * @param serviceId The ID of the service related to the slash.
     * @param offender The offender's details in bytes format.
     * @param slashPercent The percentage of the slash.
     * @param totalPayout The total payout amount in wei.
     */
    function onUnappliedSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        public
        virtual
        override
        onlyFromRootChain
    { }

    /**
     * @dev Hook for handling applied slashes. Called when a slash is applied to an offender.
     * @param serviceId The ID of the service related to the slash.
     * @param offender The offender's details in bytes format.
     * @param slashPercent The percentage of the slash.
     * @param totalPayout The total payout amount in wei.
     */
    function onSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        public
        virtual
        override
        onlyFromRootChain
    { }

    /**
     * @dev Query the slashing origin for a service. This mainly used by the runtime to determine the allowed account
     * that can slash a service. by default, the service manager is the only account that can slash a service. override this
     * function to allow other accounts to slash a service.
     * @param serviceId The ID of the service.
     * @return slashingOrigin The list of accounts that can slash the service.
     */
    function querySlashingOrigin(uint64 serviceId) public view virtual override returns (address slashingOrigin) {
        return address(this);
    }

    /**
     * @dev Query the dispute origin for a service. This mainly used by the runtime to determine the allowed account
     * that can dispute an unapplied slash and remove it. by default, the service manager is the only account that can dispute a
     * service. override this
     * function to allow other accounts to dispute a service.
     * @param serviceId The ID of the service.
     * @return disputeOrigin The account that can dispute the unapplied slash for that service
     */
    function queryDisputeOrigin(uint64 serviceId) public view virtual override returns (address disputeOrigin) {
        return address(this);
    }
}
