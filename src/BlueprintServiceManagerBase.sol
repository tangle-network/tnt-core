// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./Permissions.sol";
import "./interfaces/IBlueprintServiceManager.sol";

/// @title BlueprintServiceManagerBase
/// @dev This contract acts as a manager for the lifecycle of a Blueprint Instance,
/// facilitating various stages such as registration, service requests, job execution,
/// and job result handling. It is designed to be used by the service blueprint designer
/// (gadget developer) and integrates with the RootChain for permissioned operations.
/// Each function serves as a hook for different lifecycle events, and reverting any
/// of these functions interrupts the process flow.
contract BlueprintServiceManagerBase is IBlueprintServiceManager, RootChainEnabledOwnable {
    /// @inheritdoc IBlueprintServiceManager
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

    /// @inheritdoc IBlueprintServiceManager
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

    /// @inheritdoc IBlueprintServiceManager
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

    /// @inheritdoc IBlueprintServiceManager
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

    /// @inheritdoc IBlueprintServiceManager
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

    /// @inheritdoc IBlueprintServiceManager
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

    /// @inheritdoc IBlueprintServiceManager
    function querySlashingOrigin(uint64 serviceId) public view virtual override returns (address slashingOrigin) {
        return address(this);
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryDisputeOrigin(uint64 serviceId) public view virtual override returns (address disputeOrigin) {
        return address(this);
    }
}
