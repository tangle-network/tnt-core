// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IAssetAdapter } from "./IAssetAdapter.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

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

    /// @notice Pending delegation manager awaiting acceptance (2-step rotation).
    /// @dev Appended after `delegationManager` to keep prior storage layout stable.
    ///      A rotation is only ever live once the pending address claims it, so a
    ///      compromised owner key alone cannot silently repoint custody and drain
    ///      the pool — the proposal is observable on-chain before it can take effect.
    address public pendingDelegationManager;

    /// @notice Precision for share calculations (prevents rounding to zero)
    uint256 internal constant PRECISION = 1e18;

    /// @notice Virtual share/asset offset for first-depositor inflation defense.
    /// @dev INVARIANT: shares are TOKEN-DENOMINATED — deposited token-wei maps 1:1 to
    ///      shares while the pool is at its bootstrap ratio, and tracks the rebase
    ///      thereafter. The adapter's returned share count is consumed directly as the
    ///      delegation `amount` (DepositManager._handleErc20Deposit -> _depositAsset)
    ///      and is later passed to `oracle.toUSD(token, amount)` and the
    ///      token-denominated `depositCap`/`minDelegation` checks, all of which assume
    ///      raw token wei. The offset MUST therefore be SYMMETRIC (VIRTUAL_SHARES ==
    ///      VIRTUAL_ASSETS): the bootstrap ratio is VIRTUAL_SHARES/VIRTUAL_ASSETS, so
    ///      equal values give a 1:1 share/asset unit (an asymmetric 1e8/1 offset minted
    ///      ~1e8x-scaled shares and inflated rebasing-asset USD exposure ~1e8x).
    ///      Inflation defense is governed by the OFFSET MAGNITUDE, not the asymmetry:
    ///      with VIRTUAL_ASSETS=1e8 an attacker who seeds one wei must donate ≥1e8 raw
    ///      tokens to drift share price by a single unit, and even then recovers only
    ///      ~1e-8 of the donation — economically infeasible for any real 18-decimal
    ///      rebasing token.
    uint256 internal constant VIRTUAL_SHARES = 1e8;
    uint256 internal constant VIRTUAL_ASSETS = 1e8;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlyDelegationManager();
    error DelegationManagerNotSet();
    error SlippageTooHigh();
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
    /// @dev For rebasing tokens, we measure actual tokens received (not amount sent)
    ///      to handle any transfer fees or rebasing that occurs during transfer.
    /// @dev First-depositor inflation defense via a SYMMETRIC virtual asset/share
    ///      offset (VIRTUAL_SHARES == VIRTUAL_ASSETS == 1e8): a one-wei seed plus a
    ///      donation of D tokens cannot inflate share price enough to round a victim's
    ///      later deposit to zero shares (donating ≥1e8 raw tokens drifts price by only
    ///      one unit, and the griefer recovers ~1e-8 of the donation — infeasible).
    ///      The offset is symmetric so the bootstrap mint ratio is 1:1: shares are
    ///      token-denominated, which the cross-asset USD/exposure layer requires.
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

        // Virtual-offset share computation. Both totalShares and the asset-side
        // balance get a virtual addend, so the very first depositor cannot
        // unilaterally set the share price by donating just before depositing.
        // shares = actualReceived * (totalShares + VIRTUAL_SHARES) / (balanceBefore + VIRTUAL_ASSETS)
        shares =
            actualReceived.mulDiv(totalShares + VIRTUAL_SHARES, balanceBefore + VIRTUAL_ASSETS, Math.Rounding.Floor);

        if (shares == 0) revert ZeroShares();

        totalShares += shares;

        emit Deposit(from, actualReceived, shares);
    }

    /// @inheritdoc IAssetAdapter
    /// @dev Converts shares to current asset value based on pool ratio (with the
    ///      same virtual offset used at deposit time so round-trip math is symmetric).
    function withdraw(address to, uint256 shares) external override onlyDelegationManager returns (uint256 assets) {
        if (shares == 0) revert ZeroShares();
        if (to == address(0)) revert ZeroAddress();
        if (shares > totalShares) revert InsufficientAssets();

        // Calculate assets to withdraw with the same virtual offset:
        // assets = (shares * (balance + VIRTUAL_ASSETS)) / (totalShares + VIRTUAL_SHARES)
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        assets = shares.mulDiv(currentBalance + VIRTUAL_ASSETS, totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);

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
    /// @dev Returns current asset value of shares (changes as token rebases). Mirrors
    ///      the symmetric virtual-offset formula in `withdraw` so the round trip is
    ///      consistent (bootstrap: shares * VA / VS == shares, token-denominated 1:1).
    function sharesToAssets(uint256 shares) public view override returns (uint256) {
        if (shares == 0) return 0;
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        return shares.mulDiv(currentBalance + VIRTUAL_ASSETS, totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);
    }

    /// @inheritdoc IAssetAdapter
    /// @dev Returns shares for given asset amount at current rate. Uses the SAME
    ///      symmetric virtual-offset formula as `deposit` so `previewDeposit` agrees
    ///      with the shares actually minted (bootstrap: assets * VS / VA == assets,
    ///      i.e. token-denominated 1:1).
    function assetsToShares(uint256 assets) public view override returns (uint256) {
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        return assets.mulDiv(totalShares + VIRTUAL_SHARES, currentBalance + VIRTUAL_ASSETS, Math.Rounding.Floor);
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
    /// @dev Returns ~1e18 for a 1:1 rate. Shares are now token-denominated (1:1 on
    ///      bootstrap), so the rate is just (assets/shares) * PRECISION computed with
    ///      the same symmetric virtual offset used by deposit/withdraw.
    /// @return rate The exchange rate scaled by 1e18
    function exchangeRate() external view returns (uint256 rate) {
        if (totalShares == 0) return PRECISION;
        uint256 currentBalance = IERC20(asset).balanceOf(address(this));
        return (currentBalance + VIRTUAL_ASSETS).mulDiv(PRECISION, totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);
    }
}
