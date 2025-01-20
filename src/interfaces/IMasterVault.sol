// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IMasterVault {
    struct CrossChainAsset {
        uint32 originChainId;
        address originAsset;
        uint256 bridgeId;
        bool isRegistered;
    }

    error InvalidAsset(address asset);
}
