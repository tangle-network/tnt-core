// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IAssetAdapter} from "./IAssetAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title RebasingAssetAdapter
/// @notice Adapter for rebasing tokens like stETH where balance changes automatically
/// @dev Uses internal share accounting to track proportional ownership as underlying balance changes.
///      Example: User deposits 100 stETH, gets 100 shares. Balance rebases to 110 stETH.
///      User's 100 shares are now worth 110 stETH.
contract RebasingAssetAdapter is IAssetAdapter, Ownable {
    using SafeERC20 for IERC20;
    using Math for uint256;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The underlying rebasing token
    address public immutable override asset;

    /// @notice Total internal shares outstanding
    uint256 public override totalShares;

    /// @notice Address authorized to call deposit/withdraw (MultiAssetDelegation)
    address public delegationManager;

    /// @notice Precision for share calculations (prevents rounding to zero)
    uint256 internal constant PRECISION = 1e18;

    /// @notice Initial shares per asset (used for first deposit)
    uint256 internal constant INITIAL_SHARES_PER_ASSET = 1e18;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlyDelegationManager();
    error DelegationManagerNotSet();
    error SlippageTooHigh();

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

    /// @notice Create a new RebasingAssetAdapter
    /// @param _asset The rebasing token address (e.g., stETH)
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
    /// @dev For rebasing tokens, we measure actual tokens received (not amount sent)
    ///      to handle any transfer fees or rebasing that occurs during transfer.
    function deposit(address from, uint256 assets) external override onlyDelegationManager returns (uint256 shares) {
        if (assets == 0) revert ZeroAmount();
        if (from == address(0)) revert ZeroAddress();

        // Snapshot balance before transfer
        uint256 balanceBefore = IERC20(asset).balanceOf(address(this));

        // Transfer tokens - use actual received amount for share calculation
        IERC20(asset).safeTransferFrom(from, address(this), assets);

        uint256 balanceAfter = IERC20(asset).balanceOf(address(this));
        uint256 actualReceived = balanceAfter - balanceBefore;

        if (actualReceived == 0) revert ZeroAmount();

        // Calculate shares based on current exchange rate
        if (totalShares == 0) {
            // First deposit: establish initial share price
            shares = actualReceived * INITIAL_SHARES_PER_ASSET;
        } else {
            // Subsequent deposits: shares proportional to current pool
            // shares = (actualReceived * totalShares) / balanceBefore
            shares = actualReceived.mulDiv(totalShares, balanceBefore, Math.Rounding.Floor);
        }

        if (shares == 0) revert ZeroShares();

        totalShares += shares;

        emit Deposit(from, actualReceived, shares);
    }

    /// @inheritdoc IAssetAdapter
    /// @dev Converts shares to current asset value based on pool ratio
    function withdraw(address to, uint256 shares) external override onlyDelegationManager returns (uint256 assets) {
        if (shares == 0) revert ZeroShares();
        if (to == address(0)) revert ZeroAddress();
        if (shares > totalShares) revert InsufficientAssets();

        // Calculate assets to withdraw: assets = (shares * totalAssets) / totalShares
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        assets = shares.mulDiv(currentBalance, totalShares, Math.Rounding.Floor);

        if (assets == 0) revert ZeroAmount();

        // Update state before transfer
        totalShares -= shares;

        // Transfer tokens
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
    /// @dev Returns current asset value of shares (changes as token rebases)
    function sharesToAssets(uint256 shares) public view override returns (uint256) {
        if (totalShares == 0) return 0;
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        return shares.mulDiv(currentBalance, totalShares, Math.Rounding.Floor);
    }

    /// @inheritdoc IAssetAdapter
    /// @dev Returns shares for given asset amount at current rate
    function assetsToShares(uint256 assets) public view override returns (uint256) {
        if (totalShares == 0) {
            return assets * INITIAL_SHARES_PER_ASSET;
        }
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        if (currentBalance == 0) return 0;
        return assets.mulDiv(totalShares, currentBalance, Math.Rounding.Floor);
    }

    /// @inheritdoc IAssetAdapter
    function previewDeposit(uint256 assets) external view override returns (uint256) {
        return assetsToShares(assets);
    }

    /// @inheritdoc IAssetAdapter
    function previewWithdraw(uint256 shares) external view override returns (uint256) {
        return sharesToAssets(shares);
    }

    /// @inheritdoc IAssetAdapter
    function supportsAsset(address token) external view override returns (bool) {
        return token == asset;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADDITIONAL VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get current exchange rate (assets per share, scaled by PRECISION)
    /// @dev Returns ~1e18 for 1:1 rate, normalizing for INITIAL_SHARES_PER_ASSET
    /// @return rate The exchange rate scaled by 1e18
    function exchangeRate() external view returns (uint256 rate) {
        if (totalShares == 0) return PRECISION;
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        // Normalize by INITIAL_SHARES_PER_ASSET so rate is ~1e18 when assets:shares is 1:1
        return currentBalance.mulDiv(PRECISION * INITIAL_SHARES_PER_ASSET, totalShares, Math.Rounding.Floor);
    }
}
