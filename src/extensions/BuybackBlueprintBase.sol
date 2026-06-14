// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { TokenizedBlueprintBase } from "./TokenizedBlueprintBase.sol";

/// @title ISwapRouter
/// @notice Minimal Uniswap V3 SwapRouter interface
interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);
}

/// @title IWETH
/// @notice Minimal WETH interface
interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function approve(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

/// @title BuybackBlueprintBase
/// @notice Extension that uses revenue to buy back the blueprint token from AMM
/// @dev Extends TokenizedBlueprintBase with automatic or manual buyback mechanics
///
/// Buyback Modes:
/// - AUTO: Every payment triggers a buyback (higher gas, consistent pressure)
/// - MANUAL: Accumulated ETH can be used for buyback by anyone (lower gas, batched)
/// - THRESHOLD: Auto-buyback when accumulated ETH exceeds threshold
///
/// Bought tokens can be:
/// - BURN: Permanently removed from supply (deflationary)
/// - DISTRIBUTE: Added to staking rewards pool
/// - TREASURY: Sent to a treasury address
abstract contract BuybackBlueprintBase is TokenizedBlueprintBase {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════════

    enum BuybackMode {
        MANUAL, // Buyback triggered manually
        AUTO, // Buyback on every payment
        THRESHOLD // Buyback when threshold reached
    }

    enum TokenDestination {
        BURN, // Burn bought tokens
        DISTRIBUTE, // Add to staking rewards
        TREASURY // Send to treasury
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event Buyback(uint256 ethSpent, uint256 tokensReceived, TokenDestination destination);
    event BuybackConfigUpdated(BuybackMode mode, TokenDestination destination, uint256 threshold);
    event BuybackPauseUpdated(bool paused);
    /// @notice Emitted when an automatic buyback cannot price the swap and the ETH is
    ///         deferred to the pending balance instead of being swapped unprotected.
    event BuybackDeferredNoQuote(uint256 ethAmount);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error BuybackFailed();
    error InsufficientBalance();
    error SlippageExceeded();
    error PoolNotSet();
    /// @notice Raised when a swap would execute with no effective minimum output
    ///         (i.e. zero slippage protection), which exposes the buyback to an MEV
    ///         sandwich. A buyback MUST have a non-zero `amountOutMinimum`.
    error NoSlippageProtection();

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Uniswap V3 SwapRouter address
    ISwapRouter public swapRouter;

    /// @notice WETH address (needed for ETH swaps on Uniswap)
    IWETH public weth;

    /// @notice Pool fee tier (500 = 0.05%, 3000 = 0.3%, 10000 = 1%)
    uint24 public poolFee = 3000;

    /// @notice Current buyback mode
    BuybackMode public buybackMode = BuybackMode.MANUAL;

    /// @notice What to do with bought tokens
    TokenDestination public tokenDestination = TokenDestination.DISTRIBUTE;

    /// @notice Threshold for THRESHOLD mode (in wei)
    uint256 public buybackThreshold = 1 ether;

    /// @notice Maximum slippage in basis points (default 5%)
    uint256 public maxSlippageBps = 500;

    /// @notice Treasury address for TREASURY destination
    address public buybackTreasury;

    /// @notice Whether buybacks are paused
    bool public buybackPaused;

    /// @notice Accumulated ETH for buyback (not yet spent)
    uint256 public pendingBuybackBalance;

    /// @notice Total ETH spent on buybacks
    uint256 public totalBuybackSpent;

    /// @notice Total tokens bought back
    uint256 public totalTokensBought;

    /// @notice Total tokens burned
    uint256 public totalTokensBurned;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(
        string memory name_,
        string memory symbol_,
        address _swapRouter,
        address _weth
    )
        TokenizedBlueprintBase(name_, symbol_)
    {
        swapRouter = ISwapRouter(_swapRouter);
        weth = IWETH(_weth);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT HANDLING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Handle incoming payments with buyback logic
    function _onPaymentReceived(address token, uint256 amount) internal virtual override {
        if (token != address(0)) {
            // ERC20 payments go to staking rewards
            super._onPaymentReceived(token, amount);
            return;
        }

        // Native ETH handling based on mode.
        //
        // Automatic paths (AUTO / THRESHOLD) are triggered by an external payment, so
        // there is no caller able to supply a slippage floor. They rely entirely on the
        // on-chain estimate from `_getExpectedOutput` (oracle/TWAP). If no estimate is
        // available the swap would have zero slippage protection, so we DEFER the ETH to
        // the pending balance (recoverable via the manual `executeBuyback*` path with an
        // explicit `minTokensOut`) instead of swapping it unprotected into an MEV sandwich.
        if (buybackMode == BuybackMode.AUTO) {
            _executeBuybackAuto(amount);
        } else if (buybackMode == BuybackMode.THRESHOLD) {
            // Accumulate and buyback when threshold reached
            pendingBuybackBalance += amount;
            if (pendingBuybackBalance >= buybackThreshold) {
                uint256 buybackAmount = pendingBuybackBalance;
                pendingBuybackBalance = 0;
                _executeBuybackAuto(buybackAmount);
            }
        } else {
            // MANUAL mode: just accumulate
            pendingBuybackBalance += amount;
        }
    }

    /// @notice Automatic (caller-less) buyback path. Defers to pending instead of
    ///         swapping when the swap cannot be given a non-zero minimum output.
    /// @dev Invariant: never swaps with zero slippage protection. When no on-chain
    ///      estimate is available, the ETH is held as pending and can be swept later
    ///      via `executeBuyback`/`executeBuybackAll` with an explicit `minTokensOut`.
    function _executeBuybackAuto(uint256 ethAmount) internal {
        if (ethAmount == 0) return;
        if (_minOutFor(ethAmount, 0) == 0) {
            // Unpriceable right now: do NOT swap unprotected. Hold for manual sweep.
            pendingBuybackBalance += ethAmount;
            emit BuybackDeferredNoQuote(ethAmount);
            return;
        }
        _executeBuyback(ethAmount, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BUYBACK EXECUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Execute buyback with accumulated ETH (for MANUAL mode)
    /// @param amount Amount of ETH to use for buyback
    /// @param minTokensOut Caller-supplied minimum tokens to receive. This is a hard
    ///        slippage floor: the swap reverts if it would return fewer tokens. Because
    ///        this trigger is permissionless, the caller MUST pass a sane bound (e.g.
    ///        computed off-chain against the current pool price) so an MEV bot cannot
    ///        sandwich the swap. The effective floor is `max(oracleMinOut, minTokensOut)`.
    function executeBuyback(uint256 amount, uint256 minTokensOut) external nonReentrant {
        if (amount > pendingBuybackBalance) revert InsufficientBalance();
        pendingBuybackBalance -= amount;
        _executeBuyback(amount, minTokensOut);
    }

    /// @notice Execute buyback with all accumulated ETH
    /// @param minTokensOut Caller-supplied minimum tokens to receive (see `executeBuyback`).
    function executeBuybackAll(uint256 minTokensOut) external nonReentrant {
        uint256 amount = pendingBuybackBalance;
        if (amount == 0) revert InsufficientBalance();
        pendingBuybackBalance = 0;
        _executeBuyback(amount, minTokensOut);
    }

    /// @notice Compute the effective minimum output for a swap.
    /// @dev Combines the on-chain oracle/TWAP estimate (discounted by `maxSlippageBps`)
    ///      with the caller-supplied floor and returns the larger of the two. Either
    ///      source alone is sufficient to bound slippage; both is strictly safer.
    function _minOutFor(uint256 ethAmount, uint256 callerMinOut) internal view returns (uint256) {
        uint256 expectedOut = _getExpectedOutput(ethAmount);
        uint256 oracleMinOut = (expectedOut * (10_000 - maxSlippageBps)) / 10_000;
        return callerMinOut > oracleMinOut ? callerMinOut : oracleMinOut;
    }

    /// @notice Internal buyback execution
    /// @dev Invariant: a buyback swap MUST carry a non-zero `amountOutMinimum`. A zero
    ///      minimum (the old behaviour when `_getExpectedOutput` returned 0) lets an MEV
    ///      bot sandwich the WETH->token swap and extract the entire buyback. The minimum
    ///      is the greater of the oracle-derived floor and the caller-supplied floor; if
    ///      both are zero the swap is rejected with `NoSlippageProtection`.
    function _executeBuyback(uint256 ethAmount, uint256 callerMinOut) internal {
        if (ethAmount == 0) return;
        if (address(swapRouter) == address(0)) revert PoolNotSet();
        if (buybackPaused) {
            pendingBuybackBalance += ethAmount;
            return;
        }

        // Resolve the slippage floor BEFORE moving funds. Fail closed: no protection -> no swap.
        uint256 minOut = _minOutFor(ethAmount, callerMinOut);
        if (minOut == 0) revert NoSlippageProtection();

        // Wrap ETH to WETH
        weth.deposit{ value: ethAmount }();
        weth.approve(address(swapRouter), ethAmount);

        // Execute swap: WETH -> Blueprint Token
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(weth),
            tokenOut: address(this),
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: ethAmount,
            amountOutMinimum: minOut,
            sqrtPriceLimitX96: 0
        });

        uint256 tokensReceived;
        try swapRouter.exactInputSingle(params) returns (uint256 amountOut) {
            tokensReceived = amountOut;
        } catch {
            // If swap fails, unwrap WETH and keep as pending
            weth.withdraw(ethAmount);
            pendingBuybackBalance += ethAmount;
            revert BuybackFailed();
        }

        // Update stats
        totalBuybackSpent += ethAmount;
        totalTokensBought += tokensReceived;

        // Handle bought tokens based on destination
        _handleBoughtTokens(tokensReceived);

        emit Buyback(ethAmount, tokensReceived, tokenDestination);
    }

    /// @notice Handle bought tokens based on configured destination
    function _handleBoughtTokens(uint256 amount) internal {
        if (tokenDestination == TokenDestination.BURN) {
            _burn(address(this), amount);
            totalTokensBurned += amount;
        } else if (tokenDestination == TokenDestination.DISTRIBUTE) {
            // Add to staking rewards
            _notifyReward(address(this), amount);
        } else if (tokenDestination == TokenDestination.TREASURY) {
            if (buybackTreasury != address(0)) {
                _transfer(address(this), buybackTreasury, amount);
            }
        }
    }

    /// @notice Get expected output for a given ETH input
    /// @dev Override this to use an oracle or TWAP for better estimates
    function _getExpectedOutput(uint256 ethAmount) internal view virtual returns (uint256) {
        ethAmount; // Default implementation ignores the amount; overrides can apply pricing logic.
        // Default: no minimum (override for production with oracle/TWAP)
        return 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure buyback parameters
    function _configureBuyback(BuybackMode mode, TokenDestination destination, uint256 threshold) internal {
        buybackMode = mode;
        tokenDestination = destination;
        buybackThreshold = threshold;
        emit BuybackConfigUpdated(mode, destination, threshold);
    }

    /// @notice Set swap router
    function _setSwapRouter(address router) internal {
        swapRouter = ISwapRouter(router);
    }

    /// @notice Pause or resume buybacks
    function setBuybackPaused(bool paused) external onlyBlueprintOwner {
        _setBuybackPaused(paused);
    }

    function _setBuybackPaused(bool paused) internal {
        if (buybackPaused == paused) return;
        buybackPaused = paused;
        emit BuybackPauseUpdated(paused);
    }

    /// @notice Set WETH address
    function _setWeth(address _weth) internal {
        weth = IWETH(_weth);
    }

    /// @notice Set pool fee tier
    function _setPoolFee(uint24 fee) internal {
        poolFee = fee;
    }

    /// @notice Set maximum slippage
    function _setMaxSlippage(uint256 bps) internal {
        require(bps <= 5000, "Slippage too high"); // Max 50%
        maxSlippageBps = bps;
    }

    /// @notice Set buyback treasury
    function _setBuybackTreasury(address treasury) internal {
        buybackTreasury = treasury;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get buyback statistics
    function buybackStats()
        external
        view
        returns (uint256 pending, uint256 totalSpent, uint256 totalBought, uint256 totalBurned)
    {
        return (pendingBuybackBalance, totalBuybackSpent, totalTokensBought, totalTokensBurned);
    }

    /// @notice Check if threshold buyback is ready
    function isBuybackReady() external view returns (bool) {
        return buybackMode == BuybackMode.THRESHOLD && pendingBuybackBalance >= buybackThreshold;
    }
}
