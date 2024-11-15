// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IMasterVault {
    struct CrossChainAsset {
        uint32 originChainId;
        address originAsset;
        uint256 bridgeId;
        bool isRegistered;
    }

    error InvalidAsset(address asset);

    event AdapterAuthorized(address indexed adapter);
    event AdapterUnauthorized(address indexed adapter);

    function authorizeAdapter(address adapter) external;
    function unauthorizeAdapter(address adapter) external;
}
