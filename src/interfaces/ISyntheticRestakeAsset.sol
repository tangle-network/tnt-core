// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @title ISyntheticRestakeAsset
/// @notice Interface for SyntheticRestakeAsset contract
interface ISyntheticRestakeAsset {
    /// @notice Origin chain information
    function originChainId() external view returns (uint32);

    /// @notice Original asset address on origin chain
    function originAsset() external view returns (uint256);

    /// @notice Bridge used for cross-chain transfer
    function bridgeId() external view returns (uint256);

    /// @notice Vault that manages this synthetic asset
    function vault() external view returns (address);
}
