// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { IERC7540Deposit, IERC7540Redeem, IERC7540Operator } from "../interfaces/IERC7540.sol";
import { IMultiAssetDelegation } from "../interfaces/IMultiAssetDelegation.sol";
import { IAssetAdapter } from "./adapters/IAssetAdapter.sol";
import { Types } from "../libraries/Types.sol";

/// @notice Minimal view into the staking router's adapter registry.
/// @dev `getAssetAdapter` lives on `DepositManager` (inherited directly by the router),
///      not on `IMultiAssetDelegation`, so we surface it through a focused local interface
///      rather than widening the shared interface from here.
interface IAdapterLookup {
    function getAssetAdapter(address token) external view returns (address);
}

/// @title LiquidDelegationVault
/// @notice ERC7540 vault for liquid delegation to a specific operator with specific blueprints
/// @dev Wraps MultiAssetDelegation, making delegation positions liquid and transferable
///      Each vault is specific to one operator and one blueprint selection
contract LiquidDelegationVault is ERC20, IERC7540Deposit, IERC7540Redeem, IERC7540Operator, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using Math for uint256;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS & IMMUTABLES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Virtual shares/assets offset to prevent first-depositor inflation attack
    /// @dev Following OpenZeppelin ERC4626 pattern, consistent with DelegationManagerLib
    uint256 internal constant VIRTUAL_SHARES = 1e3;
    uint256 internal constant VIRTUAL_ASSETS = 1e3;

    /// @notice The underlying staking contract
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IMultiAssetDelegation public immutable staking;

    /// @notice The operator this vault delegates to
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable operator;

    /// @notice The underlying asset (WETH for native, or ERC20)
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IERC20 public immutable asset;

    /// @notice Whether this vault uses native ETH (wrapped as WETH)
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    bool public immutable isNative;

    /// @notice Blueprint IDs for Fixed mode (empty array = All mode)
    uint64[] private _blueprintIds;

    /// @notice Blueprint selection mode
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    Types.BlueprintSelectionMode public immutable selectionMode;

    // ═══════════════════════════════════════════════════════════════════════════
    // REQUEST TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Redeem request state
    struct RedeemRequestData {
        uint256 shares; // Shares to redeem
        uint256 unstakeShares; // Shares scheduled in staking bond-less request
        uint256 reservedAssets; // Asset value reserved out of totalAssets() while pending
        uint64 requestedRound; // Round when requested
        bool claimed; // Whether claimed
    }

    /// @notice Mapping: controller => requestId => RedeemRequestData
    mapping(address => mapping(uint256 => RedeemRequestData)) private _redeemRequests;

    /// @notice Next request ID per controller
    mapping(address => uint256) private _nextRequestId;

    /// @notice Operator approvals: controller => operator => approved
    mapping(address => mapping(address => bool)) private _operators;

    /// @notice Assets reserved for in-flight redemptions.
    /// @dev `scheduleDelegatorUnstake` only queues the bond-less request; it does NOT reduce the
    ///      vault's underlying delegation shares until `executeDelegatorUnstakeAndWithdraw` runs at
    ///      claim time. Without this accumulator, `totalAssets()` (priced off the still-un-reduced
    ///      delegation) stays inflated while `totalSupply()` has already dropped from the burn,
    ///      letting a pending redeemer inflate the asset-per-share rate and shortchange the next
    ///      depositor. We subtract reserved assets from `totalAssets()` so the rate is rate-neutral
    ///      across the request/claim lifecycle. Appended at the END of the storage region.
    uint256 private _pendingRedeemAssets;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error ZeroAssets();
    error ZeroShares();
    error NotController();
    error NotClaimable();
    error AlreadyClaimed();
    error InsufficientShares();
    error AsyncRequired();
    error RateUndefined();

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new liquid delegation vault
    /// @param _staking The staking contract
    /// @param _operator The operator to delegate to
    /// @param _asset The underlying asset (WETH for native)
    /// @param _blueprints Blueprint IDs (empty for All mode)
    /// @param _name Token name
    /// @param _symbol Token symbol
    constructor(
        IMultiAssetDelegation _staking,
        address _operator,
        IERC20 _asset,
        uint64[] memory _blueprints,
        string memory _name,
        string memory _symbol
    )
        ERC20(_name, _symbol)
    {
        staking = _staking;
        operator = _operator;
        asset = _asset;
        isNative = address(_asset) == address(0);

        if (_blueprints.length > 0) {
            selectionMode = Types.BlueprintSelectionMode.Fixed;
            _blueprintIds = _blueprints;
        } else {
            selectionMode = Types.BlueprintSelectionMode.All;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERC4626-LIKE VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Total assets managed by this vault
    /// @dev Returns the operator's delegated stake from this vault's perspective, net of assets
    ///      already reserved for in-flight redemptions. Reserved assets are still counted in the
    ///      underlying delegation (the bond-less request only queues, it does not reduce shares
    ///      until claim), so we exclude them here to keep the asset-per-share rate stable while a
    ///      redemption is pending. Floored at 0 to stay safe if slashing pushes the underlying
    ///      delegation below the reserved (pre-slash-priced) amount.
    ///
    ///      The floor case (reserved >= underlying) is DEGENERATE: a slash has pushed the
    ///      remaining backing below the still-pre-slash-priced reservation, so the per-share
    ///      rate is temporarily undefined. `_rateDefinedForMint` gates new mints in that window
    ///      (see deposit/mint) — without it, totalAssets()==0 with totalSupply()>0 collapses
    ///      convertToShares' denominator to the virtual offset and a dust deposit mints a
    ///      dominant share fraction, draining non-redeeming holders once the reservation
    ///      releases. The window self-heals as pending redeems are claimed and reservation
    ///      drops back below underlying.
    function totalAssets() public view returns (uint256) {
        uint256 underlying = staking.getDelegation(address(this), operator);
        // Idle asset backing held by the vault is real value for share holders. It is normally ~0
        // (deposits forward straight into staking), but a redeem that out-earns the exiting
        // redeemer's request-time entitlement RETAINS the reward surplus in the vault for remaining
        // holders (see `redeem`). The vault's whole accounting is denominated in staking
        // deposit-units (adapter shares for adapter-backed assets, raw tokens otherwise), so idle
        // RAW token balance is converted to deposit-units before being added — mixing token wei into
        // a share-denominated total would mis-price the rebasing/non-1:1 case.
        uint256 idle = _idleBackingInDepositUnits();
        uint256 underlyingPlusIdle = underlying + idle;
        uint256 reserved = _pendingRedeemAssets;
        if (reserved >= underlyingPlusIdle) {
            return 0;
        }
        return underlyingPlusIdle - reserved;
    }

    /// @notice The vault's idle asset balance expressed in staking deposit-units.
    /// @dev For adapter-backed assets, deposit-units are adapter shares, so raw idle token wei must
    ///      be converted via the adapter's `assetsToShares` to match the denomination of
    ///      `getDelegation`/`_pendingRedeemAssets`. For non-adapter assets it is 1:1.
    function _idleBackingInDepositUnits() internal view returns (uint256) {
        // Native vaults hold no ERC20 idle balance and `asset` is address(0); `balanceOf` on it
        // would revert, so short-circuit (native deposit/redeem are not yet implemented anyway).
        if (isNative) return 0;
        uint256 idleTokens = asset.balanceOf(address(this));
        if (idleTokens == 0) return 0;
        address adapter = IAdapterLookup(address(staking)).getAssetAdapter(address(asset));
        if (adapter == address(0)) return idleTokens;
        return IAssetAdapter(adapter).assetsToShares(idleTokens);
    }

    /// @notice Whether the asset-per-share rate is well-defined enough to safely MINT new shares.
    /// @dev INVARIANT: never mint against a collapsed rate. A mint is only safe when either the
    ///      vault is empty (totalSupply()==0, first-depositor case handled by the virtual offset)
    ///      or there is real backing for existing shares (totalAssets() > 0). When totalSupply()>0
    ///      and totalAssets()==0 the rate has collapsed onto the virtual offset and any mint
    ///      inflates the new depositor's share at the expense of existing holders.
    function _rateDefinedForMint() internal view returns (bool) {
        return totalSupply() == 0 || totalAssets() > 0;
    }

    /// @notice Convert assets to shares
    /// @dev Uses virtual offset to prevent first-depositor inflation attack
    /// @param assets Amount of assets
    /// @return shares Number of shares
    function convertToShares(uint256 assets) public view returns (uint256 shares) {
        // Virtual offset prevents inflation attack by ensuring well-defined exchange rate
        return assets.mulDiv(totalSupply() + VIRTUAL_SHARES, totalAssets() + VIRTUAL_ASSETS, Math.Rounding.Floor);
    }

    /// @notice Convert shares to assets
    /// @dev Uses virtual offset to prevent first-depositor inflation attack
    /// @param shares Number of shares
    /// @return assets Amount of assets
    function convertToAssets(uint256 shares) public view returns (uint256 assets) {
        // Virtual offset prevents inflation attack by ensuring well-defined exchange rate
        return shares.mulDiv(totalAssets() + VIRTUAL_ASSETS, totalSupply() + VIRTUAL_SHARES, Math.Rounding.Floor);
    }

    /// @notice Convert shares to the asset cost rounded UP (ceiling).
    /// @dev ERC-4626 requires `mint()` to charge the minter the asset cost rounded UP so a
    ///      minter can never receive shares worth more than they paid. `convertToAssets`
    ///      floors (correct for redemption previews), so `mint()` uses this ceiling variant.
    function _convertToAssetsRoundUp(uint256 shares) internal view returns (uint256 assets) {
        return shares.mulDiv(totalAssets() + VIRTUAL_ASSETS, totalSupply() + VIRTUAL_SHARES, Math.Rounding.Ceil);
    }

    /// @notice Get blueprint IDs for this vault
    function blueprintIds() external view returns (uint64[] memory) {
        return _blueprintIds;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SYNCHRONOUS DEPOSIT (ERC4626-style)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit assets and receive shares immediately
    /// @dev Deposits are synchronous - no request needed
    /// @param assets Amount of assets to deposit
    /// @param receiver Address to receive shares
    /// @return shares Number of shares minted
    function deposit(uint256 assets, address receiver) public nonReentrant returns (uint256 shares) {
        if (assets == 0) revert ZeroAssets();
        // Refuse to mint while the rate is collapsed (slash-during-pending-redeem); minting
        // here would hand the depositor an inflated share of existing holders' stake.
        if (!_rateDefinedForMint()) revert RateUndefined();

        shares = convertToShares(assets);
        if (shares == 0) revert ZeroShares();

        // Transfer assets from sender, push into staking, and delegate the exact
        // deposit-units the staking layer credited (adapter shares for adapter-backed
        // assets, raw assets otherwise).
        _depositAndDelegate(assets);

        // Mint liquid shares to receiver
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /// @notice Pull `assets` from the caller, deposit into staking, and delegate the credited units.
    /// @dev ROOT-CAUSE FIX for adapter-backed assets. The staking layer credits the *adapter share*
    ///      amount (`DepositManager._handleErc20Deposit`), which differs from the raw `assets` for
    ///      rebasing/non-1:1 adapters. Two bugs flow from delegating the raw amount:
    ///        1. when an adapter is registered, the adapter pulls tokens via
    ///           `safeTransferFrom(vault, adapter)`, so the vault must approve the ADAPTER, not the
    ///           router — otherwise every deposit reverts on the adapter's transferFrom; and
    ///        2. `delegateWithOptions` must be passed the credited deposit-units, not `assets`, or it
    ///           reverts with `InsufficientDeposit` (units < assets) or mis-accounts.
    ///      We read the credited delta from `getDeposit` around the call so the delegated amount is
    ///      exactly what was credited, regardless of adapter math or rebase-on-transfer.
    /// @return credited The deposit-unit amount credited by staking and delegated to the operator.
    function _depositAndDelegate(uint256 assets) internal returns (uint256 credited) {
        // Transfer assets from sender
        asset.safeTransferFrom(msg.sender, address(this), assets);

        // Approve the actual spender. When an adapter is registered for this asset, the adapter
        // (not the router) executes `safeTransferFrom(vault, adapter)`, so the allowance must be
        // granted to the adapter. Use forceApprove to handle tokens like USDT that require a reset.
        address adapter = IAdapterLookup(address(staking)).getAssetAdapter(address(asset));
        address spender = adapter != address(0) ? adapter : address(staking);
        asset.forceApprove(spender, assets);

        // NOTE: Native ETH handling via WETH is not yet implemented.
        // TODO: Add IWETH unwrap support when native ETH staking is enabled.
        //       This would require: IWETH(address(asset)).withdraw(assets);
        //       followed by: staking.deposit{value: assets}();
        // For now, all assets (including wrapped native) are deposited as ERC20.
        uint256 creditedBefore = staking.getDeposit(address(this), address(asset)).amount;
        staking.depositERC20(address(asset), assets);
        credited = staking.getDeposit(address(this), address(asset)).amount - creditedBefore;
        if (credited == 0) revert ZeroAssets();

        // Clear any residual allowance (defense-in-depth for adapters that do not pull the full
        // amount, e.g. fee-on-transfer paths) so a stale approval cannot be exploited later.
        if (asset.allowance(address(this), spender) != 0) {
            asset.forceApprove(spender, 0);
        }

        // Delegate the credited deposit-units (NOT the raw asset amount) to the operator.
        staking.delegateWithOptions(operator, address(asset), credited, selectionMode, _blueprintIds);
    }

    /// @notice Mint exact shares by depositing assets
    /// @param shares Number of shares to mint
    /// @param receiver Address to receive shares
    /// @return assets Amount of assets deposited
    function mint(uint256 shares, address receiver) public nonReentrant returns (uint256 assets) {
        if (shares == 0) revert ZeroShares();
        // Refuse to mint while the rate is collapsed (slash-during-pending-redeem); see deposit().
        if (!_rateDefinedForMint()) revert RateUndefined();

        // ERC-4626: mint() must round the asset cost UP so the minter pays at least fair value.
        // Flooring here (as `convertToAssets` does) lets a minter receive shares worth more than
        // they pay, diluting existing holders by the fractional remainder each call.
        assets = _convertToAssetsRoundUp(shares);
        if (assets == 0) revert ZeroAssets();

        // Use the shared deposit/delegate path (correct spender + credited-unit delegation).
        _depositAndDelegate(assets);

        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ASYNCHRONOUS REDEMPTION (ERC7540)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Request an asynchronous redemption
    /// @dev Burns shares immediately, schedules unstake in underlying contract
    /// @param shares Amount of shares to redeem
    /// @param controller Address that controls the request
    /// @param owner Address that owns the shares
    /// @return requestId Unique identifier for this request
    function requestRedeem(
        uint256 shares,
        address controller,
        address owner
    )
        external
        nonReentrant
        returns (uint256 requestId)
    {
        if (shares == 0) revert ZeroShares();
        // Reject the zero-address controller. Filing a request under controller=0
        // burns the redeemer's shares (no one can sign as address(0) to claim) so
        // we fail loudly here instead of silently locking the redemption forever.
        if (controller == address(0)) revert NotController();

        // Verify caller can act on behalf of owner.
        if (msg.sender != owner && !_operators[owner][msg.sender]) {
            revert NotController();
        }

        // When an authorized operator (msg.sender != owner) files the request,
        // controller must equal owner. ERC-7540 permits an approved operator to
        // file on the owner's behalf, but the request controller drives `redeem`
        // and routes assets to an arbitrary receiver — letting an operator pick
        // controller != owner would let them redirect the owner's funds. Owners
        // filing for themselves may pick any controller.
        if (msg.sender != owner && controller != owner) revert NotController();

        // Check owner has sufficient shares
        if (balanceOf(owner) < shares) revert InsufficientShares();

        // Calculate assets at current exchange rate (for scheduling)
        uint256 assets = convertToAssets(shares);

        // Mirror staking's unstake share calculation so we can execute the exact bond-less request later.
        uint256 unstakeShares = staking.previewDelegatorUnstakeShares(operator, address(asset), assets);

        uint64 requestRound = uint64(staking.currentRound());

        // Burn shares from owner
        _burn(owner, shares);

        // Schedule unstake in underlying staking contract
        staking.scheduleDelegatorUnstake(operator, address(asset), assets);

        // Reserve the redeemed asset value out of totalAssets() for the lifetime of the request.
        // `assets` was priced at the current (already-net) rate above, before the burn, so it is
        // exactly the value the redeemer is removing from the rate. We store it per-request so the
        // exact amount is released once at claim time, even if other requests reserve concurrently.
        _pendingRedeemAssets += assets;

        // Create request record
        requestId = _nextRequestId[controller]++;
        _redeemRequests[controller][requestId] = RedeemRequestData({
            shares: shares,
            unstakeShares: unstakeShares,
            reservedAssets: assets,
            requestedRound: requestRound,
            claimed: false
        });

        emit RedeemRequest(controller, owner, requestId, msg.sender, shares);
    }

    /// @notice Get pending redeem request amount
    function pendingRedeemRequest(uint256 requestId, address controller) external view returns (uint256 shares) {
        RedeemRequestData memory req = _redeemRequests[controller][requestId];

        if (req.claimed) return 0;

        uint64 currentRound = uint64(staking.currentRound());
        uint64 delay = uint64(staking.delegationBondLessDelay());
        uint64 withdrawDelay = uint64(staking.leaveDelegatorsDelay());
        if (withdrawDelay > delay) delay = withdrawDelay;

        // If not yet claimable, it's still pending
        if (currentRound < req.requestedRound + delay) {
            return req.shares;
        }
        return 0;
    }

    /// @notice Get claimable redeem request amount
    function claimableRedeemRequest(uint256 requestId, address controller) external view returns (uint256 shares) {
        RedeemRequestData memory req = _redeemRequests[controller][requestId];

        if (req.claimed) return 0;

        uint64 currentRound = uint64(staking.currentRound());
        uint64 delay = uint64(staking.delegationBondLessDelay());
        uint64 withdrawDelay = uint64(staking.leaveDelegatorsDelay());
        if (withdrawDelay > delay) delay = withdrawDelay;

        // If past delay, it's claimable
        if (currentRound >= req.requestedRound + delay) {
            return req.shares;
        }
        return 0;
    }

    /// @notice Claim redeemed assets after delay using a specific request id.
    /// @dev ERC-7540 callers must pass the requestId returned by `requestRedeem`.
    ///      Two requests with identical share counts are otherwise indistinguishable.
    function redeem(
        uint256 requestId,
        uint256 shares,
        address receiver,
        address controller
    )
        external
        nonReentrant
        returns (uint256 assets)
    {
        if (msg.sender != controller && !_operators[controller][msg.sender]) {
            revert NotController();
        }

        RedeemRequestData storage req = _redeemRequests[controller][requestId];

        if (req.claimed) revert AlreadyClaimed();
        if (req.shares == 0) revert NotClaimable();
        if (req.shares != shares) revert NotClaimable();

        uint64 currentRound = uint64(staking.currentRound());
        uint64 delay = uint64(staking.delegationBondLessDelay());
        uint64 withdrawDelay = uint64(staking.leaveDelegatorsDelay());
        if (withdrawDelay > delay) delay = withdrawDelay;

        if (currentRound < req.requestedRound + delay) {
            revert NotClaimable();
        }

        req.claimed = true;

        // Release the reservation exactly once. `req.claimed` is flipped above before any external
        // call and a second claim reverts with AlreadyClaimed, so this subtraction runs once per
        // request. Clamp to the live accumulator so a slash-during-pending (which can only ever
        // shrink the underlying delegation, never the bookkeeping) can never underflow the counter.
        uint256 entitlement = req.reservedAssets;
        uint256 reservedTotal = _pendingRedeemAssets;
        uint256 toRelease = entitlement > reservedTotal ? reservedTotal : entitlement;
        _pendingRedeemAssets = reservedTotal - toRelease;

        // Withdraw the matured bond-less request INTO THE VAULT (not directly to the receiver).
        // The staking layer prices `unstakeShares` at the CURRENT (post-reward) rate, so `returned`
        // (in deposit-units) can exceed the redeemer's request-time `entitlement` once rewards
        // accrue during unbonding. The exiting redeemer is entitled ONLY to their request-time
        // value; the reward surplus that accrued on the still-delegated pending position belongs to
        // the remaining holders. Paying out the full position (as the prior code did, by sending
        // directly to `receiver`) siphoned that surplus to the exiter and diluted everyone else.
        uint256 balanceBefore = asset.balanceOf(address(this));
        uint256 returned = staking.executeDelegatorUnstakeAndWithdraw(
            operator, address(asset), req.unstakeShares, req.requestedRound, address(this)
        );
        // Tokens actually received by the vault for this withdrawal (post-rebase for adapter assets).
        uint256 tokensReceived = asset.balanceOf(address(this)) - balanceBefore;

        // Pay the redeemer the PROPORTION of received tokens matching their request-time entitlement,
        // capping at 100% so they never take more than the position returned. `entitlement` and
        // `returned` are both deposit-units (same denomination), so the ratio is denomination-safe
        // and works for adapter-backed (rebasing) assets where `tokensReceived != returned`.
        //   - reward accrued  (returned > entitlement): redeemer gets their fixed entitlement worth,
        //     surplus tokens stay in the vault for remaining holders.
        //   - slash hit       (returned < entitlement): redeemer gets the full reduced position.
        // When NO shares remain after the burn (this was the last/only holder), there are no
        // remaining holders to retain surplus for, so the redeemer receives the full position —
        // this also avoids leaving rounding dust behind on a complete exit.
        if (returned == 0) {
            assets = 0;
        } else if (totalSupply() == 0 || entitlement >= returned) {
            assets = tokensReceived; // pay out everything received (last holder / slash / at-par)
        } else {
            assets = tokensReceived.mulDiv(entitlement, returned, Math.Rounding.Floor);
        }
        if (assets > 0) {
            asset.safeTransfer(receiver, assets);
        }
        // Any residual (reward surplus, or rounding dust) stays as idle balance and is counted by
        // `totalAssets()` (converted to deposit-units) for the benefit of remaining holders.

        emit Withdraw(msg.sender, receiver, controller, assets, shares);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SYNCHRONOUS WITHDRAW/REDEEM - DISABLED (must use async)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Synchronous withdraw is not supported
    /// @dev Use requestRedeem + redeem for async withdrawal
    function withdraw(uint256, address, address) external pure returns (uint256) {
        revert AsyncRequired();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ASYNC DEPOSIT (not required, deposits are instant)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Request deposit is not needed - deposits are synchronous
    function requestDeposit(uint256, address, address) external pure returns (uint256) {
        revert AsyncRequired(); // Use deposit() directly
    }

    function pendingDepositRequest(uint256, address) external pure returns (uint256) {
        return 0; // Deposits are instant
    }

    function claimableDepositRequest(uint256, address) external pure returns (uint256) {
        return 0; // Deposits are instant
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if operator is approved for controller
    function isOperator(address controller, address _operator) external view returns (bool) {
        return _operators[controller][_operator];
    }

    /// @notice Grant or revoke operator permissions
    function setOperator(address _operator, bool approved) external returns (bool) {
        _operators[msg.sender][_operator] = approved;
        emit OperatorSet(msg.sender, _operator, approved);
        return true;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERC20 OVERRIDES - Handle reward debt on transfer
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Override transfer to handle reward accounting
    /// @dev In production, you'd integrate with the reward debt system
    function _update(address from, address to, uint256 value) internal override {
        // For liquid shares, rewards are handled at vault level
        // Individual share transfers don't need reward debt updates
        // because the vault is the delegator, not individual holders
        super._update(from, to, value);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RECEIVE ETH
    // ═══════════════════════════════════════════════════════════════════════════

    receive() external payable { }
}
