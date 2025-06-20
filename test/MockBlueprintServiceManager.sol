// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "src/BlueprintServiceManagerBase.sol";
import "src/IBlueprintServiceManager.sol";

contract MockBlueprintServiceManager is BlueprintServiceManagerBase {
    // Expose internal functions for testing
    function exposePermitAsset(uint64 serviceId, Assets.Asset calldata asset) external returns (bool) {
        return _permitAsset(serviceId, asset);
    }

    function exposeRevokeAsset(uint64 serviceId, Assets.Asset calldata asset) external returns (bool) {
        return _revokeAsset(serviceId, asset);
    }

    function exposeClearPermittedAssets(uint64 serviceId) external returns (bool) {
        return _clearPermittedAssets(serviceId);
    }

    function exposeGetPermittedAssetsAsAddresses(uint64 serviceId) external view returns (address[] memory) {
        return _getPermittedAssetsAsAddresses(serviceId);
    }

    function exposeGetPermittedAssets(uint64 serviceId) external view returns (Assets.Asset[] memory) {
        return _getPermittedAssets(serviceId);
    }

    function exposeIsAssetPermitted(uint64 serviceId, Assets.Asset calldata asset) external view returns (bool) {
        return _isAssetPermitted(serviceId, asset);
    }

    function setMasterBlueprintServiceManager(address mbsm) external {
        masterBlueprintServiceManager = mbsm;
    }

    function setBlueprintOwner(address owner) external {
        blueprintOwner = owner;
    }

    function setCurrentBlueprintId(uint64 id) external {
        currentBlueprintId = id;
    }
    
    function exposeTestUnsupportedAssetKind(uint256 invalidKind) external pure {
        Assets.Asset memory invalidAsset = Assets.Asset({
            kind: Assets.Kind(invalidKind),
            data: bytes32(0)
        });
        
        // This should revert with UnsupportedAssetKind
        Assets.toAddress(invalidAsset);
    }
    
    function canJoin(
        uint64 serviceId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        external
        view
        virtual
        override
        onlyFromMaster
        returns (bool allowed)
    {
        return true;
    }

    function canLeave(
        uint64 serviceId,
        ServiceOperators.OperatorPreferences calldata operator
    )
        external
        view
        virtual
        override
        onlyFromMaster
        returns (bool allowed)
    {
        return true;
    }
}
