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

    /// @dev The Current Blueprint Id
    uint256 public currentBlueprintId;

    /// @dev The address of the owner of the blueprint
    address public blueprintOwner;

    /// @dev a mapping between service id and permitted payment assets.
    /// @dev serviceId => EnumerableSet of permitted payment assets.
    /// @notice This mapping is used to store the permitted payment assets for each service.
    mapping(uint64 => EnumerableSet.AddressSet) private _permittedPaymentAssets;

    /// @dev The supplied address is not a valid asset address, it does not start with 0xFFFFFFFF.
    error InvalidAssetId(address assetAddress);

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
    function onUpdatePriceTargets(ServiceOperators.OperatorPreferences calldata operator)
        external
        payable
        virtual
        onlyFromMaster
    { }

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
        uint8 slashPercent,
        uint256 totalPayout
    )
        external
        virtual
        onlyFromMaster
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
        ServiceOperators.Asset calldata asset
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
    function _permitAsset(
        uint64 serviceId,
        ServiceOperators.Asset calldata asset
    )
        internal
        virtual
        returns (bool added)
    {
        if (asset.kind == ServiceOperators.AssetKind.Erc20) {
            address assetAddress = address(uint160(uint256(asset.data)));
            bool _added = _permittedPaymentAssets[serviceId].add(assetAddress);
            return _added;
        } else if (asset.kind == ServiceOperators.AssetKind.Custom) {
            address assetAddress = _assetIdToAddress(asset.data);
            bool _added = _permittedPaymentAssets[serviceId].add(assetAddress);
            return _added;
        } else {
            return false;
        }
    }

    /**
     * @notice Revokes a previously permitted asset for a given service.
     * @dev Removes the asset from the set of permitted payment assets based on its kind.
     * @param serviceId The ID of the service for which the asset is being revoked.
     * @param asset The asset to be revoked, defined by its kind and data.
     */
    function _revokeAsset(
        uint64 serviceId,
        ServiceOperators.Asset calldata asset
    )
        internal
        virtual
        returns (bool removed)
    {
        if (asset.kind == ServiceOperators.AssetKind.Erc20) {
            address assetAddress = address(uint160(uint256(asset.data)));
            bool _removed = _permittedPaymentAssets[serviceId].remove(assetAddress);
            return _removed;
        } else if (asset.kind == ServiceOperators.AssetKind.Custom) {
            address assetAddress = _assetIdToAddress(asset.data);
            bool _removed = _permittedPaymentAssets[serviceId].remove(assetAddress);
            return _removed;
        } else {
            return false;
        }
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
    function _getPermittedAssets(uint64 serviceId) internal view virtual returns (ServiceOperators.Asset[] memory) {
        EnumerableSet.AddressSet storage permittedAssets = _permittedPaymentAssets[serviceId];
        ServiceOperators.Asset[] memory assets = new ServiceOperators.Asset[](permittedAssets.length());
        for (uint256 i = 0; i < permittedAssets.length(); i++) {
            address assetAddress = permittedAssets.at(i);
            if (assetAddress == address(0)) {
                continue;
            }
            ServiceOperators.AssetKind kind;
            bytes32 data;
            if (_checkAddressIsAssetIdCompatible(assetAddress)) {
                kind = ServiceOperators.AssetKind.Custom;
                data = _addressToAssetId(assetAddress);
            } else {
                kind = ServiceOperators.AssetKind.Erc20;
                data = bytes32(uint256(uint160(assetAddress)));
            }
            assets[i] = ServiceOperators.Asset(kind, data);
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
    function _isAssetPermitted(
        uint64 serviceId,
        ServiceOperators.Asset calldata asset
    )
        internal
        view
        virtual
        returns (bool)
    {
        // Native assets are always permitted.
        if (_isNativeAsset(asset)) {
            return true;
        } else if (asset.kind == ServiceOperators.AssetKind.Erc20) {
            address assetAddress = address(uint160(uint256(asset.data)));
            return _permittedPaymentAssets[serviceId].contains(assetAddress);
        } else if (asset.kind == ServiceOperators.AssetKind.Custom) {
            address assetAddress = _assetIdToAddress(asset.data);
            return _permittedPaymentAssets[serviceId].contains(assetAddress);
        } else {
            return false;
        }
    }

    /**
     * @notice Converts a given asset ID to its corresponding address representation.
     * @dev The conversion follows the pattern: 0xFFFFFFFF followed by the 16-byte asset ID.
     *
     * @param assetId The bytes32 asset ID to be converted.
     * @return The address representation of the asset ID.
     */
    function _assetIdToAddress(bytes32 assetId) internal pure returns (address) {
        // Construct the address by combining the prefix 0xFFFFFFFF00000000000000000000000000000000
        // with the lower 16 bytes of the assetId.
        // This ensures the address follows the designated asset address format.
        return address(uint160(uint256(0xFFFFFFFF << 128) | uint256(assetId)));
    }

    /**
     * @notice Converts an asset address back to its original asset ID.
     * @dev Validates that the address starts with the prefix 0xFFFFFFFF and extracts the 16-byte asset ID.
     *
     * @param assetAddress The address to be converted back to an asset ID.
     * @return The bytes32 representation of the original asset ID.
     */
    function _addressToAssetId(address assetAddress) internal pure returns (bytes32) {
        // Convert the address to a uint256 for bit manipulation.
        uint256 addr = uint256(uint160(assetAddress));

        // Ensure the upper 128 bits match the expected prefix 0xFFFFFFFF.
        if (!_checkAddressIsAssetIdCompatible(assetAddress)) {
            revert InvalidAssetId(assetAddress);
        }

        // Extract the lower 128 bits which represent the original asset ID.
        uint128 assetIdUint = uint128(addr);

        // Convert the uint128 asset ID back to bytes32 format.
        return bytes32(uint256(assetIdUint));
    }

    /**
     * @notice Checks if the given asset address is compatible by verifying it starts with the prefix 0xFFFFFFFF.
     * @dev This function converts the asset address to a uint256 and ensures the upper 128 bits match 0xFFFFFFFF.
     * @param assetAddress The address of the asset to check for compatibility.
     * @return bool Returns true if the asset address is compatible, false otherwise.
     */
    function _checkAddressIsAssetIdCompatible(address assetAddress) internal pure returns (bool) {
        // Convert the address to a uint256 for bit manipulation.
        uint256 addr = uint256(uint160(assetAddress));

        // Ensure the upper 128 bits match the expected prefix 0xFFFFFFFF.
        if ((addr >> 128) != 0xFFFFFFFF) {
            return false;
        }

        return true;
    }

    /**
     * @notice Determines if the provided asset is a native asset.
     * @dev This function checks the asset kind and verifies if the asset address or ID corresponds to a native asset.
     * @param asset The asset to be checked, defined by its kind and data.
     * @return bool Returns true if the asset is native, false otherwise.
     */
    function _isNativeAsset(ServiceOperators.Asset calldata asset) internal pure returns (bool) {
        if (asset.kind == ServiceOperators.AssetKind.Erc20) {
            address assetAddress = address(uint160(uint256(asset.data)));
            return (assetAddress == address(0));
        } else if (asset.kind == ServiceOperators.AssetKind.Custom) {
            uint256 assetId = uint256(asset.data);
            return (assetId == 0);
        } else {
            return false;
        }
    }
}
