// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface ICrossChainAssetVault {
    struct CrossChainAsset {
        uint32 originChainId;
        address originAsset;
        uint256 bridgeId;
        bool isRegistered;
    }

    error InvalidAsset(address asset);

    event CrossChainAssetRegistered(address indexed syntheticAsset, uint32 chainId, uint256 originAsset, uint256 bridgeId);
    event CrossChainAssetDeposited(uint256 indexed asset, bytes32 indexed depositor, uint256 amount);

    event AdapterAuthorized(address indexed adapter);
    event AdapterUnauthorized(address indexed adapter);

    function authorizeAdapter(address adapter) external;
    function unauthorizeAdapter(address adapter) external;
}
