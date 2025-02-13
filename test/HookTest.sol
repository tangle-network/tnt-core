// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "../src/BlueprintServiceManagerBase.sol";

contract HookTestBlueprintServiceManager is BlueprintServiceManagerBase {
    event OnBlueprintCreated();
    event OnRegister();
    event OnUnregister();
    event OnUpdatePriceTargets();
    event OnRequest();
    event OnApprove();
    event OnReject();
    event OnServiceInitialized();
    event OnJobCall();
    event OnJobResult();
    event OnServiceTermination();
    event OnUnappliedSlash();
    event OnSlash();

    function onBlueprintCreated(
        uint64 blueprintId,
        address owner,
        address mbsm
    ) external override onlyFromRootChain {
        currentBlueprintId = blueprintId;
        blueprintOwner = owner;
        masterBlueprintServiceManager = mbsm;
        emit OnBlueprintCreated();
    }

    function onRegister(
        ServiceOperators.OperatorPreferences calldata,
        bytes calldata
    ) external payable override onlyFromMaster {
        emit OnRegister();
    }

    function onUnregister(
        ServiceOperators.OperatorPreferences calldata
    ) external override onlyFromMaster {
        emit OnUnregister();
    }

    function onUpdatePriceTargets(
        ServiceOperators.OperatorPreferences calldata
    ) external payable override onlyFromMaster {
        emit OnUpdatePriceTargets();
    }

    function onRequest(
        ServiceOperators.RequestParams calldata
    ) external payable override onlyFromMaster {
        emit OnRequest();
    }

    function onApprove(
        ServiceOperators.OperatorPreferences calldata,
        uint64,
        uint8
    ) external payable override onlyFromMaster {
        emit OnApprove();
    }

    function onReject(
        ServiceOperators.OperatorPreferences calldata,
        uint64
    ) external override onlyFromMaster {
        emit OnReject();
    }

    function onServiceInitialized(
        uint64,
        uint64,
        address,
        address[] calldata,
        uint64
    ) external override onlyFromMaster {
        emit OnServiceInitialized();
    }

    function onJobCall(
        uint64,
        uint8,
        uint64,
        bytes calldata
    ) external payable override onlyFromMaster {
        emit OnJobCall();
    }

    function onJobResult(
        uint64,
        uint8,
        uint64,
        ServiceOperators.OperatorPreferences calldata,
        bytes calldata,
        bytes calldata
    ) external payable override onlyFromMaster {
        emit OnJobResult();
    }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceTermination(
        uint64,
        address
    ) external override onlyFromMaster {
        emit OnServiceTermination();
    }

    /// @inheritdoc IBlueprintServiceManager
    function onUnappliedSlash(
        uint64,
        bytes calldata,
        uint8
    ) external override onlyFromMaster {
        emit OnUnappliedSlash();
    }

    /// @inheritdoc IBlueprintServiceManager
    function onSlash(uint64, bytes calldata, uint8) external override {
        emit OnSlash();
    }
}
