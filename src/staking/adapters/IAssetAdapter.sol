// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IAssetAdapter
/// @notice Interface for asset adapters that handle deposits/withdrawals for different token types
/// @dev Adapters abstract away differences between standard ERC-20s, rebasing tokens, etc.
///      All accounting in MultiAssetDelegation uses "shares" from adapters, not raw token amounts.
interface IAssetAdapter {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event Deposit(address indexed from, uint256 assets, uint256 shares);
    event Withdraw(address indexed to, uint256 shares, uint256 assets);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error ZeroAmount();
    error ZeroAddress();
    error ZeroShares();
    error InsufficientAssets();
    error TransferFailed();

    // ═══════════════════════════════════════════════════════════════════════════
    // CORE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit assets into the adapter
    /// @param from Address to transfer assets from
    /// @param assets Amount of assets to deposit
    /// @return shares Amount of shares minted for this deposit
    /// @dev Must transfer tokens from `from` to adapter. Caller must have approval.
    function deposit(address from, uint256 assets) external returns (uint256 shares);

    /// @notice Withdraw assets from the adapter
    /// @param to Address to send assets to
    /// @param shares Amount of shares to redeem
    /// @return assets Amount of assets sent
    /// @dev Converts shares to current asset value and transfers to `to`
    function withdraw(address to, uint256 shares) external returns (uint256 assets);

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The underlying asset token this adapter handles
    function asset() external view returns (address);

    /// @notice Total assets currently held by this adapter
    /// @dev For rebasing tokens, this reflects current balance (which changes over time)
    function totalAssets() external view returns (uint256);

    /// @notice Total shares outstanding
    function totalShares() external view returns (uint256);

    /// @notice Convert shares to their current asset value
    /// @param shares Amount of shares
    /// @return assets Current asset value of shares
    function sharesToAssets(uint256 shares) external view returns (uint256 assets);

    /// @notice Convert assets to shares at current rate
    /// @param assets Amount of assets
    /// @return shares Share amount for given assets
    function assetsToShares(uint256 assets) external view returns (uint256 shares);

    /// @notice Preview how many shares a deposit would mint
    /// @param assets Amount of assets to deposit
    /// @return shares Shares that would be minted
    function previewDeposit(uint256 assets) external view returns (uint256 shares);

    /// @notice Preview how many assets a withdrawal would return
    /// @param shares Amount of shares to redeem
    /// @return assets Assets that would be returned
    function previewWithdraw(uint256 shares) external view returns (uint256 assets);

    /// @notice Check if this adapter supports a specific token
    /// @param token Token address to check
    /// @return True if this adapter handles the token
    function supportsAsset(address token) external view returns (bool);
}
