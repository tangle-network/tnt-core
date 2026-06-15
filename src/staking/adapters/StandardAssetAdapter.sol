// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IAssetAdapter } from "./IAssetAdapter.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

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

    /// @notice Pending delegation manager awaiting acceptance (2-step rotation).
    /// @dev Appended after `delegationManager` to keep prior storage layout stable.
    ///      A rotation is only ever live once the pending address claims it, so a
    ///      compromised owner key alone cannot silently repoint custody and drain
    ///      the pool — the proposal is observable on-chain before it can take effect.
    address public pendingDelegationManager;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlyDelegationManager();
    error DelegationManagerNotSet();
    /// @notice Bootstrap setter blocked because a manager is already wired; rotate
    ///         via the 2-step propose/accept flow instead.
    error DelegationManagerAlreadySet();
    /// @notice acceptDelegationManager called by an address that is not the pending one.
    error NotPendingDelegationManager();

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event DelegationManagerSet(address indexed oldManager, address indexed newManager);
    event DelegationManagerProposed(address indexed currentManager, address indexed pendingManager);

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

    /// @notice One-time bootstrap of the delegation manager at deploy/wiring time.
    /// @dev Only valid while no manager is set (custody pool is empty). Once wired,
    ///      the manager is the address that can withdraw the entire custodied pool,
    ///      so repointing it requires the 2-step propose/accept rotation below — a
    ///      plain owner setter would let a single compromised owner key drain
    ///      everything in one transaction.
    /// @param _delegationManager The MultiAssetDelegation contract address
    function setDelegationManager(address _delegationManager) external onlyOwner {
        if (_delegationManager == address(0)) revert ZeroAddress();
        if (delegationManager != address(0)) revert DelegationManagerAlreadySet();
        emit DelegationManagerSet(address(0), _delegationManager);
        delegationManager = _delegationManager;
    }

    /// @notice Step 1 of manager rotation: propose a new delegation manager.
    /// @dev Owner-gated, but the change is NOT live until the proposed address
    ///      calls `acceptDelegationManager`. The proposal emits an event so
    ///      delegators/guardians can react before custody can move.
    /// @param _delegationManager The proposed MultiAssetDelegation contract address
    function proposeDelegationManager(address _delegationManager) external onlyOwner {
        if (_delegationManager == address(0)) revert ZeroAddress();
        pendingDelegationManager = _delegationManager;
        emit DelegationManagerProposed(delegationManager, _delegationManager);
    }

    /// @notice Step 2 of manager rotation: the pending manager claims the role.
    /// @dev Must be called by the pending address itself. This proves the new
    ///      manager is a live, controllable contract/address (not a fat-fingered
    ///      or attacker-supplied dead address) before it gains pool custody.
    function acceptDelegationManager() external {
        address pending = pendingDelegationManager;
        if (msg.sender != pending) revert NotPendingDelegationManager();
        emit DelegationManagerSet(delegationManager, pending);
        delegationManager = pending;
        pendingDelegationManager = address(0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CORE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IAssetAdapter
    /// @dev INVARIANT: shares minted == tokens ACTUALLY received into custody, so
    ///      `totalShares` can never exceed the adapter's real balance. Crediting the
    ///      requested `assets` for a fee-on-transfer token (where balanceAfter -
    ///      balanceBefore < assets) over-credits shares and bricks the last withdrawer
    ///      once the pool is drained below the outstanding share total. We measure the
    ///      balance delta and mint against that (1:1, since this is a non-rebasing token).
    function deposit(address from, uint256 assets) external override onlyDelegationManager returns (uint256 shares) {
        if (assets == 0) revert ZeroAmount();
        if (from == address(0)) revert ZeroAddress();

        // Measure actual tokens received to stay solvent under fee-on-transfer tokens.
        uint256 balanceBefore = IERC20(asset).balanceOf(address(this));
        IERC20(asset).safeTransferFrom(from, address(this), assets);
        uint256 received = IERC20(asset).balanceOf(address(this)) - balanceBefore;

        if (received == 0) revert ZeroAmount();

        // Standard (non-rebasing) token: shares == tokens received (1:1).
        shares = received;

        // Track total shares
        totalShares += shares;

        emit Deposit(from, received, shares);
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
