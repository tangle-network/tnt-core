// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAssetAdapter} from "./IAssetAdapter.sol";
import {StandardAssetAdapter} from "./StandardAssetAdapter.sol";
import {RebasingAssetAdapter} from "./RebasingAssetAdapter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AssetAdapterFactory
/// @notice Factory for deploying and registering asset adapters
/// @dev Deploys adapters for different token types and registers them with MultiAssetDelegation
contract AssetAdapterFactory is Ownable {
    // ═══════════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════════

    enum AdapterType {
        Standard,  // Normal ERC-20 (wstETH, cbETH, rETH, WETH, etc.)
        Rebasing   // Rebasing tokens (stETH, etc.)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The MultiAssetDelegation contract
    address public delegationManager;

    /// @notice Mapping from token to its deployed adapter
    mapping(address token => address adapter) public tokenToAdapter;

    /// @notice Mapping from adapter to its token
    mapping(address adapter => address token) public adapterToToken;

    /// @notice All deployed adapters
    address[] public adapters;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event AdapterDeployed(
        address indexed token,
        address indexed adapter,
        AdapterType adapterType
    );

    event DelegationManagerSet(address indexed oldManager, address indexed newManager);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error ZeroAddress();
    error AdapterAlreadyExists(address token);
    error DelegationManagerNotSet();
    error AdapterNotFound(address token);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create factory
    /// @param _owner Owner address
    constructor(address _owner) Ownable(_owner) {}

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set the delegation manager address
    /// @param _delegationManager The MultiAssetDelegation contract
    function setDelegationManager(address _delegationManager) external onlyOwner {
        if (_delegationManager == address(0)) revert ZeroAddress();
        emit DelegationManagerSet(delegationManager, _delegationManager);
        delegationManager = _delegationManager;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPLOYMENT FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deploy a new adapter for a token
    /// @param token The ERC-20 token address
    /// @param adapterType The type of adapter to deploy
    /// @return adapter The deployed adapter address
    function deployAdapter(
        address token,
        AdapterType adapterType
    ) external onlyOwner returns (address adapter) {
        return _deployAdapterInternal(token, adapterType);
    }

    /// @notice Internal deploy function
    function _deployAdapterInternal(
        address token,
        AdapterType adapterType
    ) internal returns (address adapter) {
        if (token == address(0)) revert ZeroAddress();
        if (tokenToAdapter[token] != address(0)) revert AdapterAlreadyExists(token);
        if (delegationManager == address(0)) revert DelegationManagerNotSet();

        // Deploy the appropriate adapter type
        if (adapterType == AdapterType.Standard) {
            StandardAssetAdapter standardAdapter = new StandardAssetAdapter(token, address(this));
            standardAdapter.setDelegationManager(delegationManager);
            standardAdapter.transferOwnership(owner());
            adapter = address(standardAdapter);
        } else {
            RebasingAssetAdapter rebasingAdapter = new RebasingAssetAdapter(token, address(this));
            rebasingAdapter.setDelegationManager(delegationManager);
            rebasingAdapter.transferOwnership(owner());
            adapter = address(rebasingAdapter);
        }

        // Register the adapter
        tokenToAdapter[token] = adapter;
        adapterToToken[adapter] = token;
        adapters.push(adapter);

        emit AdapterDeployed(token, adapter, adapterType);
    }

    /// @notice Deploy a standard adapter (convenience function)
    /// @param token The ERC-20 token address
    /// @return adapter The deployed adapter address
    function deployStandardAdapter(address token) external onlyOwner returns (address adapter) {
        return _deployAdapterInternal(token, AdapterType.Standard);
    }

    /// @notice Deploy a rebasing adapter (convenience function)
    /// @param token The rebasing token address
    /// @return adapter The deployed adapter address
    function deployRebasingAdapter(address token) external onlyOwner returns (address adapter) {
        return _deployAdapterInternal(token, AdapterType.Rebasing);
    }

    /// @notice Register an externally deployed adapter
    /// @param token The token address
    /// @param adapter The adapter address
    /// @dev Use this to register adapters deployed outside the factory
    function registerAdapter(address token, address adapter) external onlyOwner {
        if (token == address(0)) revert ZeroAddress();
        if (adapter == address(0)) revert ZeroAddress();
        if (tokenToAdapter[token] != address(0)) revert AdapterAlreadyExists(token);

        // Verify adapter supports the token
        require(IAssetAdapter(adapter).supportsAsset(token), "Adapter doesn't support token");

        tokenToAdapter[token] = adapter;
        adapterToToken[adapter] = token;
        adapters.push(adapter);

        emit AdapterDeployed(token, adapter, AdapterType.Standard); // Type unknown for external
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get adapter for a token
    /// @param token The token address
    /// @return The adapter address (or zero if not found)
    function getAdapter(address token) external view returns (address) {
        return tokenToAdapter[token];
    }

    /// @notice Check if an adapter exists for a token
    /// @param token The token address
    /// @return True if adapter exists
    function hasAdapter(address token) external view returns (bool) {
        return tokenToAdapter[token] != address(0);
    }

    /// @notice Get total number of deployed adapters
    function adapterCount() external view returns (uint256) {
        return adapters.length;
    }

    /// @notice Get all deployed adapters
    function getAllAdapters() external view returns (address[] memory) {
        return adapters;
    }
}
