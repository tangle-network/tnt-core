// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

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
    mapping(address => bytes) public operators;

    /**
     * @dev A mapping of all service instances requested from the blueprint.
     * The key is the service ID and the value is the service operator's address.
     */
    mapping(uint64 => address[]) public serviceInstances;

    /**
     * @dev Hook for service operator registration. Called when a service operator
     * attempts to register with the blueprint.
     * @param operator The operator's details.
     * @param _registrationInputs Inputs required for registration.
     */
    function onRegister(
        bytes calldata operator,
        bytes calldata _registrationInputs
    ) public payable override onlyFromRootChain {
        // compute the operator's address from the operator's public key
        address operatorAddress = operatorAddressFromPublicKey(operator);
        // store the operator's details
        operators[operatorAddress] = operator;
    }

    /**
     * @dev Hook for service instance requests. Called when a user requests a service
     * instance from the blueprint.
     * @param serviceId The ID of the requested service.
     * @param operators The operators involved in the service.
     * @param _requestInputs Inputs required for the service request.
     */
    function onRequest(
        uint64 serviceId,
        bytes[] calldata operators,
        bytes calldata _requestInputs
    ) public payable override onlyFromRootChain {
        // store the service instance request
        for (uint i = 0; i < operators.length; i++) {
            address operatorAddress = operatorAddressFromPublicKey(
                operators[i]
            );
            serviceInstances[serviceId].push(operatorAddress);
        }
    }

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
    ) public payable override onlyFromRootChain {
        // Implement job call logic here
    }

    /**
     * @dev Hook for handling job result. Called when operators send the result
     * of a job execution.
     * @param serviceId The ID of the service related to the job.
     * @param job The job identifier.
     * @param jobCallId The unique ID for the job call.
     * @param operator The operator (operator) sending the result in bytes format.
     * @param inputs Inputs used for the job execution in bytes format.
     * @param outputs Outputs resulting from the job execution in bytes format.
     */
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    ) public payable virtual override onlyFromRootChain {
        // Do something with the job result
    }

    /**
     * @dev Verifies the result of a job call. This function is used to validate the
     * outputs of a job execution against the expected results.
     * @param serviceId The ID of the service related to the job.
     * @param job The job identifier.
     * @param jobCallId The unique ID for the job call.
     * @param operator The operator (operator) whose result is being verified.
     * @param inputs Inputs used for the job execution.
     * @param outputs Outputs resulting from the job execution.
     * @return bool Returns true if the job call result is verified successfully,
     * otherwise false.
     */
    function verifyResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    ) public view returns (bool) {
        // Someone requested to verify the result of a job call.
        // We need to check if the output is the square of the input.

        // check if job is zero.
        require(job == 0, "Job not found");
        // Check if the operator is a registered operator, so we can slash
        // their stake if they are cheating.
        address operatorAddress = operatorAddressFromPublicKey(operator);
        require(
            operators[operatorAddress].length > 0,
            "Operator not registered"
        );
        // Check if operator is part of the service instance
        require(
            isOperatorInServiceInstance(serviceId, operatorAddress),
            "Operator not part of service instance"
        );
        // Decode the inputs and outputs
        uint256 input = abi.decode(inputs, (uint256));
        uint256 output = abi.decode(outputs, (uint256));
        // Check if the output is the square of the input
        bool isValid = output == input * input;
        if (!isValid) {
            // Slash the operator's stake if the result is invalid
            // Using ServicesPrecompile to slash the operator's stake
            // slashPercent = 10; // 10% slash
            // ServicesPrecompile.slash(serviceId, operator, slashPercent);
        }

        return isValid;
    }

    function isOperatorInServiceInstance(
        uint64 serviceId,
        address operatorAddress
    ) public view returns (bool) {
        for (uint i = 0; i < serviceInstances[serviceId].length; i++) {
            if (serviceInstances[serviceId][i] == operatorAddress) {
                return true;
            }
        }
        return false;
    }

    function operatorAddressFromPublicKey(
        bytes calldata publicKey
    ) public pure returns (address) {
        return address(uint160(uint256(keccak256(publicKey))));
    }
}
