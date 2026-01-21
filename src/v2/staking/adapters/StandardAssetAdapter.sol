// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAssetAdapter} from "./IAssetAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title StandardAssetAdapter
/// @notice Adapter for standard ERC-20 tokens (non-rebasing)
/// @dev For tokens like WETH, USDC, wstETH, cbETH, rETH where balance doesn't change automatically.
///      Shares are 1:1 with assets - no conversion needed.
contract StandardAssetAdapter is IAssetAdapter, Ownable {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The underlying ERC-20 token
    address public immutable override asset;

    /// @notice Total shares outstanding (equals total assets for standard tokens)
    uint256 public override totalShares;

    /// @notice Address authorized to call deposit/withdraw (MultiAssetDelegation)
    address public delegationManager;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlyDelegationManager();
    error DelegationManagerNotSet();

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event DelegationManagerSet(address indexed oldManager, address indexed newManager);

    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════

    modifier onlyDelegationManager() {
        if (msg.sender != delegationManager) revert OnlyDelegationManager();
        _;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new StandardAssetAdapter
    /// @param _asset The ERC-20 token address
    /// @param _owner Owner address for admin functions
    constructor(address _asset, address _owner) Ownable(_owner) {
        if (_asset == address(0)) revert ZeroAddress();
        asset = _asset;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set the delegation manager address
    /// @param _delegationManager The MultiAssetDelegation contract address
    function setDelegationManager(address _delegationManager) external onlyOwner {
        if (_delegationManager == address(0)) revert ZeroAddress();
        emit DelegationManagerSet(delegationManager, _delegationManager);
        delegationManager = _delegationManager;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CORE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IAssetAdapter
    function deposit(address from, uint256 assets) external override onlyDelegationManager returns (uint256 shares) {
        if (assets == 0) revert ZeroAmount();
        if (from == address(0)) revert ZeroAddress();

        // For standard tokens, shares == assets (1:1)
        shares = assets;

        // Transfer tokens from user to this adapter
        IERC20(asset).safeTransferFrom(from, address(this), assets);

        // Track total shares
        totalShares += shares;

        emit Deposit(from, assets, shares);
    }

    /// @inheritdoc IAssetAdapter
    function withdraw(address to, uint256 shares) external override onlyDelegationManager returns (uint256 assets) {
        if (shares == 0) revert ZeroShares();
        if (to == address(0)) revert ZeroAddress();
        if (shares > totalShares) revert InsufficientAssets();

        // For standard tokens, assets == shares (1:1)
        assets = shares;

        // Update total shares
        totalShares -= shares;

        // Transfer tokens to recipient
        IERC20(asset).safeTransfer(to, assets);

        emit Withdraw(to, shares, assets);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IAssetAdapter
    function totalAssets() external view override returns (uint256) {
        return IERC20(asset).balanceOf(address(this));
    }

    /// @inheritdoc IAssetAdapter
    function sharesToAssets(uint256 shares) external pure override returns (uint256) {
        // 1:1 for standard tokens
        return shares;
    }

    /// @inheritdoc IAssetAdapter
    function assetsToShares(uint256 assets) external pure override returns (uint256) {
        // 1:1 for standard tokens
        return assets;
    }

    /// @inheritdoc IAssetAdapter
    function previewDeposit(uint256 assets) external pure override returns (uint256) {
        // 1:1 for standard tokens
        return assets;
    }

    /// @inheritdoc IAssetAdapter
    function previewWithdraw(uint256 shares) external pure override returns (uint256) {
        // 1:1 for standard tokens
        return shares;
    }

    /// @inheritdoc IAssetAdapter
    function supportsAsset(address token) external view override returns (bool) {
        return token == asset;
    }
}
