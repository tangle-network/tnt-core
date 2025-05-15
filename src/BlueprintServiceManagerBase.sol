// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "src/Permissions.sol";
import "src/IBlueprintServiceManager.sol";

/// @title BlueprintServiceManagerBase
/// @author Tangle Network Team
/// @dev This contract acts as a manager for the lifecycle of a Blueprint Instance,
/// facilitating various stages such as registration, service requests, job execution,
/// and job result handling. It is designed to be used by the service blueprint designer
/// (gadget developer) and integrates with the RootChain for permissioned operations.
/// Each function serves as a hook for different lifecycle events, and reverting any
/// of these functions interrupts the process flow.
contract BlueprintServiceManagerBase is IBlueprintServiceManager, RootChainEnabled {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Assets for Assets.Asset;
    using Assets for address;
    using Assets for bytes32;

    /// @dev The Current Blueprint Id
    uint256 public currentBlueprintId;

    /// @dev The address of the owner of the blueprint
    address public blueprintOwner;
    
    /// @dev Whether heartbeats are enabled for this blueprint
    bool public heartbeatsEnabled = true;
    
    /// @dev Heartbeat interval in blocks (e.g., 100 blocks)
    uint64 public heartbeatInterval = 100;
    
    /// @dev Heartbeat threshold percentage (e.g., 80%)
    uint8 public heartbeatThreshold = 80;
    
    /// @dev Slashing window in blocks (e.g., 1000 blocks)
    uint64 public slashingWindow = 1000;
    
    /// @dev Whether the heartbeatsEnabled value has been explicitly set
    bool private _heartbeatsEnabledSet;
    
    /// @dev Whether the heartbeatInterval value has been explicitly set
    bool private _heartbeatIntervalSet;
    
    /// @dev Whether the heartbeatThreshold value has been explicitly set
    bool private _heartbeatThresholdSet;
    
    /// @dev Whether the slashingWindow value has been explicitly set
    bool private _slashingWindowSet;

    /// @dev a mapping between service id and permitted payment assets.
    /// @dev serviceId => EnumerableSet of permitted payment assets.
    /// @notice This mapping is used to store the permitted payment assets for each service.
    mapping(uint64 => EnumerableSet.AddressSet) private _permittedPaymentAssets;

    /// @inheritdoc IBlueprintServiceManager
    function onBlueprintCreated(uint64 blueprintId, address owner, address mbsm) external virtual onlyFromRootChain {
        currentBlueprintId = blueprintId;
        blueprintOwner = owner;
        masterBlueprintServiceManager = mbsm;
    }

    /// @inheritdoc IBlueprintServiceManager
    function onRegister(
        ServiceOperators.OperatorPreferences calldata operator,
        bytes calldata registrationInputs
    )
        external
        payable
        virtual
        onlyFromMaster
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onUnregister(ServiceOperators.OperatorPreferences calldata operator) external virtual onlyFromMaster { }

    /// @inheritdoc IBlueprintServiceManager
    function onUpdateRpcAddress(ServiceOperators.OperatorPreferences calldata operator)
        external
        payable
        virtual
        onlyFromMaster
    { }
    
    /// @inheritdoc IBlueprintServiceManager
    function areHeartbeatsEnabled() external view virtual returns (bool) {
        return heartbeatsEnabled;
    }
    
    /// @inheritdoc IBlueprintServiceManager
    function getHeartbeatInterval() external view virtual returns (uint64) {
        if (!heartbeatsEnabled) {
            return 0; // Return 0 if heartbeats are disabled
        }
        return heartbeatInterval;
    }
    
    /// @inheritdoc IBlueprintServiceManager
    function getHeartbeatThreshold() external view virtual returns (uint8) {
        if (!heartbeatsEnabled) {
            return 0; // Return 0 if heartbeats are disabled
        }
        return heartbeatThreshold;
    }
    
    /// @inheritdoc IBlueprintServiceManager
    function getSlashingWindow() external view virtual returns (uint64) {
        if (!heartbeatsEnabled) {
            return 0; // Return 0 if heartbeats are disabled
        }
        return slashingWindow;
    }
    
    /// @inheritdoc IBlueprintServiceManager
    function setHeartbeatsEnabled(bool enabled) external virtual onlyFromMaster {
        heartbeatsEnabled = enabled;
        _heartbeatsEnabledSet = true;
    }
    
    /// @inheritdoc IBlueprintServiceManager
    function setHeartbeatInterval(uint64 interval) external virtual onlyFromMaster {
        heartbeatInterval = interval;
        _heartbeatIntervalSet = true;
    }
    
    /// @inheritdoc IBlueprintServiceManager
    function setHeartbeatThreshold(uint8 threshold) external virtual onlyFromMaster {
        require(threshold <= 100, "Threshold must be between 0 and 100");
        heartbeatThreshold = threshold;
        _heartbeatThresholdSet = true;
    }
    
    /// @inheritdoc IBlueprintServiceManager
    function setSlashingWindow(uint64 window) external virtual onlyFromMaster {
        slashingWindow = window;
        _slashingWindowSet = true;
    }

    /// @inheritdoc IBlueprintServiceManager
    function onRequest(ServiceOperators.RequestParams calldata params) external payable virtual onlyFromMaster { }

    /// @inheritdoc IBlueprintServiceManager
    function onApprove(
        ServiceOperators.OperatorPreferences calldata operator,
        uint64 requestId,
        uint8 restakingPercent
    )
        external
        payable
        virtual
        onlyFromMaster
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onReject(
        ServiceOperators.OperatorPreferences calldata operator,
        uint64 requestId
    )
        external
        virtual
        onlyFromMaster
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
        onlyFromMaster
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
        onlyFromMaster
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
        onlyFromMaster
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceTermination(uint64 serviceId, address owner) external virtual onlyFromMaster { }

    /// @inheritdoc IBlueprintServiceManager
    function onUnappliedSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent
    )
        external
        virtual
        onlyFromMaster
    { }

    /// @inheritdoc IBlueprintServiceManager
    function onSlash(
        uint64 serviceId,
        bytes calldata offender,
        uint8 slashPercent
    )
        external
        virtual
        onlyFromMaster
    { }

    /// @inheritdoc IBlueprintServiceManager
    function canJoin(
        uint64 serviceId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        external
        view
        virtual
        onlyFromMaster
        returns (bool allowed)
    {
        return false;
    }

    /// @inheritdoc IBlueprintServiceManager
    function onOperatorJoined(
        uint64 serviceId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        external
        virtual
        onlyFromMaster
    { }

    /// @inheritdoc IBlueprintServiceManager
    function canLeave(
        uint64 serviceId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        external
        view
        virtual
        onlyFromMaster
        returns (bool allowed)
    {
        return false;
    }

    /// @inheritdoc IBlueprintServiceManager
    function onOperatorLeft(
        uint64 serviceId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        external
        virtual
        onlyFromMaster
    { }

    /// @inheritdoc IBlueprintServiceManager
    function querySlashingOrigin(uint64) external view virtual returns (address slashingOrigin) {
        return address(this);
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryDisputeOrigin(uint64) external view virtual returns (address disputeOrigin) {
        return address(this);
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryDeveloperPaymentAddress(uint64)
        external
        view
        virtual
        returns (address payable developerPaymentAddress)
    {
        return payable(blueprintOwner);
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryIsPaymentAssetAllowed(
        uint64 serviceId,
        Assets.Asset calldata asset
    )
        external
        view
        virtual
        returns (bool isAllowed)
    {
        return _isAssetPermitted(serviceId, asset);
    }

    /**
     * @notice Permits a specific asset for a given service.
     * @dev Adds the asset to the set of permitted payment assets based on its kind.
     * @param serviceId The ID of the service for which the asset is being permitted.
     * @param asset The asset to be permitted, defined by its kind and data.
     */
    function _permitAsset(uint64 serviceId, Assets.Asset calldata asset) internal virtual returns (bool added) {
        address assetAddress = asset.toAddress();
        bool _added = _permittedPaymentAssets[serviceId].add(assetAddress);
        return _added;
    }

    /**
     * @notice Revokes a previously permitted asset for a given service.
     * @dev Removes the asset from the set of permitted payment assets based on its kind.
     * @param serviceId The ID of the service for which the asset is being revoked.
     * @param asset The asset to be revoked, defined by its kind and data.
     */
    function _revokeAsset(uint64 serviceId, Assets.Asset calldata asset) internal virtual returns (bool removed) {
        address assetAddress = asset.toAddress();
        bool _removed = _permittedPaymentAssets[serviceId].remove(assetAddress);
        return _removed;
    }

    /**
     * @notice Clears all permitted assets for a given service.
     * @dev Iterates through the set of permitted assets and removes each one.
     * @param serviceId The ID of the service for which permitted assets are being cleared.
     */
    function _clearPermittedAssets(uint64 serviceId) internal virtual returns (bool cleared) {
        EnumerableSet.AddressSet storage permittedAssets = _permittedPaymentAssets[serviceId];
        uint256 length = permittedAssets.length();
        while (length > 0) {
            address assetAddress = permittedAssets.at(0);
            permittedAssets.remove(assetAddress);
            length = permittedAssets.length();
        }

        // The set should be empty after clearing all permitted assets.
        return permittedAssets.length() == 0;
    }

    /**
     * @notice Retrieves all permitted assets for a given service as an array of addresses.
     * @dev Converts the EnumerableSet of permitted assets to a dynamic array of addresses.
     * @param serviceId The ID of the service for which permitted assets are being retrieved.
     * @return assets An array of addresses representing the permitted assets.
     */
    function _getPermittedAssetsAsAddresses(uint64 serviceId) internal view virtual returns (address[] memory) {
        EnumerableSet.AddressSet storage permittedAssets = _permittedPaymentAssets[serviceId];
        address[] memory assets = new address[](permittedAssets.length());
        for (uint256 i = 0; i < permittedAssets.length(); i++) {
            assets[i] = permittedAssets.at(i);
        }
        return assets;
    }

    /**
     * @notice Retrieves all permitted assets for a given service as an array of Asset structs.
     * @dev Converts the EnumerableSet of permitted assets to a dynamic array of ServiceOperators.Asset.
     * @param serviceId The ID of the service for which permitted assets are being retrieved.
     * @return assets An array of ServiceOperators.Asset structs representing the permitted assets.
     */
    function _getPermittedAssets(uint64 serviceId) internal view virtual returns (Assets.Asset[] memory) {
        EnumerableSet.AddressSet storage permittedAssets = _permittedPaymentAssets[serviceId];
        Assets.Asset[] memory assets = new Assets.Asset[](permittedAssets.length());
        for (uint256 i = 0; i < permittedAssets.length(); i++) {
            address assetAddress = permittedAssets.at(i);
            if (assetAddress == address(0)) {
                continue;
            }
            assets[i] = assetAddress.toAsset();
        }
        return assets;
    }

    /**
     * @notice Checks if a specific asset is permitted for a given service.
     * @dev Determines if the asset is contained within the set of permitted payment assets based on its kind.
     * @param serviceId The ID of the service to check.
     * @param asset The asset to check, defined by its kind and data.
     * @return isAllowed Boolean indicating whether the asset is permitted.
     */
    function _isAssetPermitted(uint64 serviceId, Assets.Asset calldata asset) internal view virtual returns (bool) {
        // Native assets are always permitted.
        if (asset.isNative()) {
            return true;
        } else {
            address assetAddress = asset.toAddress();
            return _permittedPaymentAssets[serviceId].contains(assetAddress);
        }
    }
}
