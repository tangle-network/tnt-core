// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../src/BlueprintServiceManagerBase.sol";

/**
 * @title IncredibleSquaringBlueprint
 * @dev This contract is an example of a service blueprint that provides a single
 * service to square a number. It demonstrates the lifecycle hooks that can be
 * implemented in a service blueprint.
 */
contract IncredibleSquaringBlueprint is BlueprintServiceManagerBase {
    /**
     * @dev A mapping of all service operators registered with the blueprint.
     * The key is the operator's address and the value is the operator's details.
     */
    mapping(address => ServiceOperators.OperatorPreferences) public operators;

    /**
     * @dev A mapping of all service instances requested from the blueprint.
     * The key is the service ID and the value is the service operator's address.
     */
    mapping(uint64 => address[]) public serviceInstances;

    /**
     * @dev Hook for service operator registration. Called when a service operator
     * attempts to register with the blueprint.
     * @param operator The operator's details.
     * @param registrationInputs Inputs required for registration.
     */
    function onRegister(
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata registrationInputs
    )
        public
        payable
        override
        onlyFromMaster
    {
        // compute the operator's address from the operator's public key
        address operatorAddress = ServiceOperators.asOperatorAddress(operator.ecdsaPublicKey);
        // store the operator's details
        operators[operatorAddress] = operator;
    }

    /**
     * @dev Hook for service instance requests. Called when a user requests a service
     * instance from the blueprint.
     * @param params The parameters for the service request.
     */
    function onRequest(ServiceOperators.RequestParams calldata params) public payable override onlyFromMaster {
        // store the service instance request
        for (uint256 i = 0; i < params.operators.length; i++) {
            address operatorAddress = ServiceOperators.asOperatorAddress(params.operators[i].ecdsaPublicKey);
            serviceInstances[params.requestId].push(operatorAddress);
        }
    }

    /**
     * @dev Hook for job calls on the service. Called when a job is called within
     * the service context.
     */
    function onJobCall(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata inputs
    )
        public
        payable
        override
        onlyFromMaster
    {
        // Implement job call logic here
    }

    /**
     * @dev Hook for handling job result. Called when operators send the result
     * of a job execution.
     */
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    )
        public
        payable
        override
        onlyFromMaster
    {
        // Do something with the job result
    }

    /**
     * @dev Verifies the result of a job call.
     */
    function verifyResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    )
        public
        view
        returns (bool)
    {
        // check if job is zero.
        require(job == 0, "Job not found");

        // Check if the operator is a registered operator
        address operatorAddress = ServiceOperators.asOperatorAddress(operator.ecdsaPublicKey);
        require(operators[operatorAddress].ecdsaPublicKey.length > 0, "Operator not registered");

        // Check if operator is part of the service instance
        require(isOperatorInServiceInstance(serviceId, operatorAddress), "Operator not part of service instance");

        // Decode the inputs and outputs
        uint256 input = abi.decode(inputs, (uint256));
        uint256 output = abi.decode(outputs, (uint256));

        // Check if the output is the square of the input
        return output == input * input;
    }

    function isOperatorInServiceInstance(uint64 serviceId, address operatorAddress) public view returns (bool) {
        for (uint256 i = 0; i < serviceInstances[serviceId].length; i++) {
            if (serviceInstances[serviceId][i] == operatorAddress) {
                return true;
            }
        }
        return false;
    }
}
