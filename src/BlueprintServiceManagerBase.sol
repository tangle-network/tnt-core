// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

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
        OperatorPreferences calldata operator,
        bytes calldata registrationInputs
    )
        external
        payable
        override
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onUnregister(OperatorPreferences calldata operator) external override onlyFromRootChain { }

    /// @inheritdoc IBlueprintServiceManager
    function onUpdatePriceTargets(OperatorPreferences calldata operator) external payable override onlyFromRootChain { }

    /// @inheritdoc IBlueprintServiceManager
    function onRequest(
        uint64 requestId,
        address requester,
        OperatorPreferences[] calldata operators,
        bytes calldata requestInputs,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external
        payable
        override
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onApprove(
        OperatorPreferences calldata operator,
        uint64 requestId,
        uint8 restakingPercent
    )
        external
        payable
        override
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onReject(OperatorPreferences calldata operator, uint64 requestId) external override onlyFromRootChain { }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceInitialized(
        uint64 requestId,
        uint64 serviceId,
        address owner,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external
        override
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
        override
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        OperatorPreferences calldata operator,
        bytes calldata inputs,
        bytes calldata outputs
    )
        external
        payable
        override
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceTermination(uint64 serviceId, address owner) external override onlyFromRootChain { }

    /// @inheritdoc IBlueprintServiceManager
    function onUnappliedSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        external
        override
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
        override
        onlyFromRootChain
    { }

    /// @inheritdoc IBlueprintServiceManager
    function querySlashingOrigin(uint64) external view override returns (address slashingOrigin) {
        return address(this);
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryDisputeOrigin(uint64) external view override returns (address disputeOrigin) {
        return address(this);
    }
}
