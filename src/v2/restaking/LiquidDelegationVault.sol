// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

import { IERC7540Deposit, IERC7540Redeem, IERC7540Operator } from "../interfaces/IERC7540.sol";
import { IMultiAssetDelegation } from "../interfaces/IMultiAssetDelegation.sol";
import { Types } from "../libraries/Types.sol";

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

    /// @notice The underlying restaking contract
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IMultiAssetDelegation public immutable restaking;

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
        uint256 unstakeShares; // Shares scheduled in restaking bond-less request
        uint64 requestedRound; // Round when requested
        bool claimed; // Whether claimed
    }

    /// @notice Mapping: controller => requestId => RedeemRequestData
    mapping(address => mapping(uint256 => RedeemRequestData)) private _redeemRequests;

    /// @notice Next request ID per controller
    mapping(address => uint256) private _nextRequestId;

    /// @notice Operator approvals: controller => operator => approved
    mapping(address => mapping(address => bool)) private _operators;

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

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new liquid delegation vault
    /// @param _restaking The restaking contract
    /// @param _operator The operator to delegate to
    /// @param _asset The underlying asset (WETH for native)
    /// @param _blueprints Blueprint IDs (empty for All mode)
    /// @param _name Token name
    /// @param _symbol Token symbol
    constructor(
        IMultiAssetDelegation _restaking,
        address _operator,
        IERC20 _asset,
        uint64[] memory _blueprints,
        string memory _name,
        string memory _symbol
    )
        ERC20(_name, _symbol)
    {
        restaking = _restaking;
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
    /// @dev Returns the operator's delegated stake from this vault's perspective
    function totalAssets() public view returns (uint256) {
        // Get our delegation to this operator
        return restaking.getDelegation(address(this), operator);
    }

    /// @notice Convert assets to shares
    /// @param assets Amount of assets
    /// @return shares Number of shares
    function convertToShares(uint256 assets) public view returns (uint256 shares) {
        uint256 supply = totalSupply();
        uint256 total = totalAssets();

        if (supply == 0 || total == 0) {
            return assets; // 1:1 for first deposit
        }
        return assets.mulDiv(supply, total, Math.Rounding.Floor);
    }

    /// @notice Convert shares to assets
    /// @param shares Number of shares
    /// @return assets Amount of assets
    function convertToAssets(uint256 shares) public view returns (uint256 assets) {
        uint256 supply = totalSupply();

        if (supply == 0) {
            return shares; // 1:1 for empty vault
        }
        return shares.mulDiv(totalAssets(), supply, Math.Rounding.Floor);
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

        shares = convertToShares(assets);
        if (shares == 0) revert ZeroShares();

        // Transfer assets from sender
        asset.safeTransferFrom(msg.sender, address(this), assets);

        // Approve and deposit into restaking
        // Use forceApprove to handle tokens like USDT that require resetting to 0 first
        asset.forceApprove(address(restaking), assets);

        // NOTE: Native ETH handling via WETH is not yet implemented.
        // TODO: Add IWETH unwrap support when native ETH restaking is enabled.
        //       This would require: IWETH(address(asset)).withdraw(assets);
        //       followed by: restaking.deposit{value: assets}();
        // For now, all assets (including wrapped native) are deposited as ERC20.
        restaking.depositERC20(address(asset), assets);

        // Delegate to operator with blueprint selection
        restaking.delegateWithOptions(operator, address(asset), assets, selectionMode, _blueprintIds);

        // Mint liquid shares to receiver
        _mint(receiver, shares);

        emit Deposit(msg.sender, receiver, assets, shares);
    }

    /// @notice Mint exact shares by depositing assets
    /// @param shares Number of shares to mint
    /// @param receiver Address to receive shares
    /// @return assets Amount of assets deposited
    function mint(uint256 shares, address receiver) public nonReentrant returns (uint256 assets) {
        if (shares == 0) revert ZeroShares();

        assets = convertToAssets(shares);
        if (assets == 0) revert ZeroAssets();

        // Use deposit logic
        asset.safeTransferFrom(msg.sender, address(this), assets);
        // Use forceApprove to handle tokens like USDT that require resetting to 0 first
        asset.forceApprove(address(restaking), assets);

        restaking.depositERC20(address(asset), assets);
        restaking.delegateWithOptions(operator, address(asset), assets, selectionMode, _blueprintIds);

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

        // Verify caller can act on behalf of owner
        if (msg.sender != owner && !_operators[owner][msg.sender]) {
            revert NotController();
        }

        // Check owner has sufficient shares
        if (balanceOf(owner) < shares) revert InsufficientShares();

        // Calculate assets at current exchange rate (for scheduling)
        uint256 assets = convertToAssets(shares);

        // Mirror restaking's unstake share calculation so we can execute the exact bond-less request later.
        uint256 unstakeShares = restaking.previewDelegatorUnstakeShares(operator, address(asset), assets);

        uint64 requestRound = uint64(restaking.currentRound());

        // Burn shares from owner
        _burn(owner, shares);

        // Schedule unstake in underlying restaking contract
        restaking.scheduleDelegatorUnstake(operator, address(asset), assets);

        // Create request record
        requestId = _nextRequestId[controller]++;
        _redeemRequests[controller][requestId] = RedeemRequestData({
            shares: shares,
            unstakeShares: unstakeShares,
            requestedRound: requestRound,
            claimed: false
        });

        emit RedeemRequest(controller, owner, requestId, msg.sender, shares);
    }

    /// @notice Get pending redeem request amount
    function pendingRedeemRequest(uint256 requestId, address controller) external view returns (uint256 shares) {
        RedeemRequestData memory req = _redeemRequests[controller][requestId];

        if (req.claimed) return 0;

        uint64 currentRound = uint64(restaking.currentRound());
        uint64 delay = uint64(restaking.delegationBondLessDelay());
        uint64 withdrawDelay = uint64(restaking.leaveDelegatorsDelay());
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

        uint64 currentRound = uint64(restaking.currentRound());
        uint64 delay = uint64(restaking.delegationBondLessDelay());
        uint64 withdrawDelay = uint64(restaking.leaveDelegatorsDelay());
        if (withdrawDelay > delay) delay = withdrawDelay;

        // If past delay, it's claimable
        if (currentRound >= req.requestedRound + delay) {
            return req.shares;
        }
        return 0;
    }

    /// @notice Claim redeemed assets after delay
    /// @param shares Amount of shares being redeemed (must match request)
    /// @param receiver Address to receive assets
    /// @param controller Controller of the request
    /// @return assets Amount of assets received
    function redeem(
        uint256 shares,
        address receiver,
        address controller
    )
        external
        nonReentrant
        returns (uint256 assets)
    {
        // Verify caller is controller or approved operator
        if (msg.sender != controller && !_operators[controller][msg.sender]) {
            revert NotController();
        }

        // Find matching claimable request
        // Note: In a production implementation, you'd pass requestId as parameter
        // For simplicity, we find the first claimable request matching shares
        uint256 requestId = _findClaimableRequest(controller, shares);
        RedeemRequestData storage req = _redeemRequests[controller][requestId];

        if (req.claimed) revert AlreadyClaimed();

        uint64 currentRound = uint64(restaking.currentRound());
        uint64 delay = uint64(restaking.delegationBondLessDelay());
        uint64 withdrawDelay = uint64(restaking.leaveDelegatorsDelay());
        if (withdrawDelay > delay) delay = withdrawDelay;

        if (currentRound < req.requestedRound + delay) {
            revert NotClaimable();
        }

        // Mark as claimed
        req.claimed = true;

        // Execute the exact bond-less request and withdraw the resulting assets directly to the receiver.
        assets = restaking.executeDelegatorUnstakeAndWithdraw(
            operator,
            address(asset),
            req.unstakeShares,
            req.requestedRound,
            receiver
        );

        emit Withdraw(msg.sender, receiver, controller, assets, shares);
    }

    /// @notice Find a claimable request matching shares
    function _findClaimableRequest(address controller, uint256 shares) internal view returns (uint256 requestId) {
        uint256 nextId = _nextRequestId[controller];
        uint64 currentRound = uint64(restaking.currentRound());
        uint64 delay = uint64(restaking.delegationBondLessDelay());
        uint64 withdrawDelay = uint64(restaking.leaveDelegatorsDelay());
        if (withdrawDelay > delay) delay = withdrawDelay;

        for (uint256 i = 0; i < nextId; i++) {
            RedeemRequestData memory req = _redeemRequests[controller][i];
            if (!req.claimed && req.shares == shares && currentRound >= req.requestedRound + delay) {
                return i;
            }
        }
        revert NotClaimable();
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
