// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "src/Permissions.sol";
import "src/IBlueprintServiceManager.sol";

/**
 * @title BlueprintServiceManagerBase
 * @author Tangle Network Team
 * @dev This contract acts as a manager for the lifecycle of a Blueprint Instance,
 * facilitating various stages such as registration, service requests, job execution,
 * and job result handling. It is designed to be used by the service blueprint designer
 * (gadget developer) and integrates with the RootChain for permissioned operations.
 * Each function serves as a hook for different lifecycle events, and reverting any
 * of these functions interrupts the process flow.
 */
contract BlueprintServiceManagerBase is IBlueprintServiceManager, RootChainEnabled {
    /// @inheritdoc IBlueprintServiceManager
    function onRegister(
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata registrationInputs
    )
        external
        payable
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onUnregister(ServiceOperators.OperatorPreferences calldata operator) external virtual onlyFromRootChain { }

    /// @inheritdoc IBlueprintServiceManager
    function onUpdatePriceTargets(ServiceOperators.OperatorPreferences calldata operator)
        external
        payable
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onRequest(
        uint64 requestId,
        address requester,
        ServiceOperators.OperatorPreferences[] calldata operators,
        bytes calldata requestInputs,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external
        payable
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onApprove(
        ServiceOperators.OperatorPreferences calldata operator,
        uint64 requestId,
        uint8 restakingPercent
    )
        external
        payable
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onReject(
        ServiceOperators.OperatorPreferences calldata operator,
        uint64 requestId
    )
        external
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceInitialized(
        uint64 requestId,
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onJobCall(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata inputs
    )
        external
        payable
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    )
        external
        payable
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceTermination(uint64 serviceId, address owner) external virtual onlyFromRootChain { }

    /// @inheritdoc IBlueprintServiceManager
    function onUnappliedSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        external
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        external
        virtual
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function querySlashingOrigin(uint64) external view virtual returns (address slashingOrigin) {
        return address(this);
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryDisputeOrigin(uint64) external view virtual returns (address disputeOrigin) {
        return address(this);
    }
}
