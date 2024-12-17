// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "src/BlueprintServiceManagerBase.sol";
import "src/IBlueprintServiceManager.sol";

contract MockBlueprintServiceManager is BlueprintServiceManagerBase {
    // Expose internal functions for testing
    function permitAsset(uint64 serviceId, ServiceOperators.Asset calldata asset) external returns (bool) {
        return _permitAsset(serviceId, asset);
    }

    function revokeAsset(uint64 serviceId, ServiceOperators.Asset calldata asset) external returns (bool) {
        return _revokeAsset(serviceId, asset);
    }

    function clearPermittedAssets(uint64 serviceId) external returns (bool) {
        return _clearPermittedAssets(serviceId);
    }

    function getPermittedAssetsAsAddresses(uint64 serviceId) external view returns (address[] memory) {
        return _getPermittedAssetsAsAddresses(serviceId);
    }

    function getPermittedAssets(uint64 serviceId) external view returns (ServiceOperators.Asset[] memory) {
        return _getPermittedAssets(serviceId);
    }

    function assetIdToAddress(bytes32 assetId) external pure returns (address) {
        return _assetIdToAddress(assetId);
    }

    function addressToAssetId(address assetAddress) external pure returns (bytes32) {
        return _addressToAssetId(assetAddress);
    }

    function isNativeAsset(ServiceOperators.Asset calldata asset) external pure returns (bool) {
        return _isNativeAsset(asset);
    }

    // Override required as BlueprintServiceManagerBase inherits RootChainEnabled
    function setMasterBlueprintServiceManager(address mbsm) external {
        masterBlueprintServiceManager = mbsm;
    }
}
