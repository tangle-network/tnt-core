// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { IAssetAdapter } from "../../restaking/adapters/IAssetAdapter.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingAssetsFacet
/// @notice Facet for asset and adapter management
contract RestakingAssetsFacet is RestakingFacetBase, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;
    event AssetEnabled(address indexed token, uint256 minOperatorStake, uint256 minDelegation);
    event AssetDisabled(address indexed token);
    event AdapterRegistered(address indexed token, address indexed adapter);
    event AdapterRemoved(address indexed token);
    event RequireAdaptersUpdated(bool required);

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](7);
        selectorList[0] = this.enableAsset.selector;
        selectorList[1] = this.disableAsset.selector;
        selectorList[2] = this.getAssetConfig.selector;
        selectorList[3] = this.registerAdapter.selector;
        selectorList[4] = this.removeAdapter.selector;
        selectorList[5] = this.setRequireAdapters.selector;
        selectorList[6] = this.enableAssetWithAdapter.selector;
    }

    /// @notice Enable an ERC20 token for staking
    function enableAsset(
        address token,
        uint256 _minOperatorStake,
        uint256 _minDelegation,
        uint256 _depositCap,
        uint16 _rewardMultiplierBps
    )
        external
        onlyRole(ASSET_MANAGER_ROLE)
    {
        require(token != address(0), "Use native");
        bytes32 assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));

        _assetConfigs[assetHash] = Types.AssetConfig({
            enabled: true,
            minOperatorStake: _minOperatorStake,
            minDelegation: _minDelegation,
            depositCap: _depositCap,
            currentDeposits: 0,
            rewardMultiplierBps: _rewardMultiplierBps
        });
        _enabledErc20s.add(token);

        emit AssetEnabled(token, _minOperatorStake, _minDelegation);
    }

    /// @notice Disable an asset
    function disableAsset(address token) external onlyRole(ASSET_MANAGER_ROLE) {
        bytes32 assetHash;
        if (token == address(0)) {
            assetHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
            nativeEnabled = false;
        } else {
            assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));
            _enabledErc20s.remove(token);
        }
        _assetConfigs[assetHash].enabled = false;
        emit AssetDisabled(token);
    }

    /// @notice Get asset configuration
    function getAssetConfig(address token) external view returns (Types.AssetConfig memory) {
        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        return _assetConfigs[_assetHash(asset)];
    }

    /// @notice Register an adapter for a token
    /// @param token The token address
    /// @param adapter The adapter address
    /// @dev Adapter must support the token (checked via supportsAsset)
    function registerAdapter(address token, address adapter) external onlyRole(ASSET_MANAGER_ROLE) {
        require(token != address(0), "Cannot set adapter for native");
        require(adapter != address(0), "Invalid adapter");

        // Verify adapter supports the token
        require(
            IAssetAdapter(adapter).supportsAsset(token),
            "Adapter doesn't support token"
        );

        _assetAdapters[token] = adapter;
        emit AdapterRegistered(token, adapter);
    }

    /// @notice Remove adapter for a token (falls back to direct transfers)
    /// @param token The token address
    function removeAdapter(address token) external onlyRole(ASSET_MANAGER_ROLE) {
        require(_assetAdapters[token] != address(0), "No adapter registered");
        delete _assetAdapters[token];
        emit AdapterRemoved(token);
    }

    /// @notice Set whether adapters are required for ERC20 deposits
    /// @param required If true, deposits revert when no adapter is registered
    function setRequireAdapters(bool required) external onlyRole(ASSET_MANAGER_ROLE) {
        requireAdapters = required;
        emit RequireAdaptersUpdated(required);
    }

    /// @notice Enable asset with adapter in one call
    /// @param token Token address
    /// @param adapter Adapter address
    /// @param _minOperatorStake Minimum stake for operators
    /// @param _minDelegation Minimum delegation amount
    /// @param _depositCap Maximum total deposits (0 = unlimited)
    /// @param _rewardMultiplierBps Reward multiplier in basis points
    function enableAssetWithAdapter(
        address token,
        address adapter,
        uint256 _minOperatorStake,
        uint256 _minDelegation,
        uint256 _depositCap,
        uint16 _rewardMultiplierBps
    ) external onlyRole(ASSET_MANAGER_ROLE) {
        require(token != address(0), "Use native");
        require(adapter != address(0), "Invalid adapter");
        require(
            IAssetAdapter(adapter).supportsAsset(token),
            "Adapter doesn't support token"
        );

        // Register adapter
        _assetAdapters[token] = adapter;
        emit AdapterRegistered(token, adapter);

        // Enable asset
        bytes32 assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));
        _assetConfigs[assetHash] = Types.AssetConfig({
            enabled: true,
            minOperatorStake: _minOperatorStake,
            minDelegation: _minDelegation,
            depositCap: _depositCap,
            currentDeposits: 0,
            rewardMultiplierBps: _rewardMultiplierBps
        });
        _enabledErc20s.add(token);

        emit AssetEnabled(token, _minOperatorStake, _minDelegation);
    }
}
