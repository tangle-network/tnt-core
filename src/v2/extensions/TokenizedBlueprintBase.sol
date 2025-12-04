// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { BlueprintServiceManagerBase } from "../BlueprintServiceManagerBase.sol";

/// @title TokenizedBlueprintBase
/// @notice Extension for blueprints with community tokens and revenue sharing
/// @dev Combines:
///      - ERC20 token for blueprint community
///      - Synthetix-style staking rewards for revenue distribution
///      - Auto-directs developer revenue to this contract
///
/// Usage:
/// ```solidity
/// contract MyTokenizedBlueprint is TokenizedBlueprintBase {
///     constructor() TokenizedBlueprintBase("My Blueprint Token", "MBT") {}
///
///     // Override hooks to mint tokens for participation
///     function onJobResult(...) external override {
///         _mint(operator, REWARD_AMOUNT);
///     }
/// }
/// ```
///
/// Revenue Flow:
/// 1. queryDeveloperPaymentAddress() returns address(this)
/// 2. Revenue flows to this contract
/// 3. Revenue is distributed to staked token holders
/// 4. Users stake tokens via stake(), claim via claimReward()
abstract contract TokenizedBlueprintBase is BlueprintServiceManagerBase, ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, address indexed token, uint256 amount);
    event RewardAdded(address indexed token, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error ZeroAmount();
    error InsufficientStake();

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD TOKEN STATE (per reward token)
    // ═══════════════════════════════════════════════════════════════════════════

    struct RewardState {
        uint256 rewardPerTokenStored;      // Accumulated reward per staked token (scaled by 1e18)
        uint256 lastUpdateTime;            // Last time reward was updated
        uint256 rewardRate;                // Reward per second (for streaming mode)
        uint256 periodFinish;              // When current reward period ends (for streaming)
        uint256 pendingRewards;            // Undistributed rewards (for instant mode)
    }

    /// @notice Reward state per token (address(0) = native ETH)
    mapping(address => RewardState) public rewardStates;

    /// @notice User's paid reward per token snapshot
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;

    /// @notice User's pending rewards per token
    mapping(address => mapping(address => uint256)) public rewards;

    /// @notice List of reward tokens
    address[] public rewardTokens;
    mapping(address => bool) public isRewardToken;

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKING STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Total staked tokens
    uint256 public totalStaked;

    /// @notice User staked balances
    mapping(address => uint256) public stakedBalance;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Duration for streaming rewards (default 7 days)
    uint256 public rewardDuration = 7 days;

    /// @notice Whether to stream rewards over time or distribute instantly
    bool public streamingMode = false;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {
        // Native ETH is always a reward token
        _addRewardToken(address(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEVELOPER PAYMENT REDIRECT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Direct all developer revenue to this contract
    /// @dev Override from BlueprintServiceManagerBase
    function queryDeveloperPaymentAddress(uint64)
        external
        view
        virtual
        override
        returns (address payable)
    {
        return payable(address(this));
    }

    /// @notice Handle incoming native token payments
    /// @dev Called by receive() in base
    function _onPaymentReceived(address token, uint256 amount) internal virtual override {
        if (amount == 0) return;
        _notifyReward(token, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Stake blueprint tokens to earn revenue share
    /// @param amount Amount of tokens to stake
    function stake(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();

        _updateAllRewards(msg.sender);

        stakedBalance[msg.sender] += amount;
        totalStaked += amount;

        // Transfer tokens from user to this contract
        _transfer(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    /// @notice Withdraw staked tokens
    /// @param amount Amount to withdraw
    function withdraw(uint256 amount) external nonReentrant {
        if (amount == 0) revert ZeroAmount();
        if (stakedBalance[msg.sender] < amount) revert InsufficientStake();

        _updateAllRewards(msg.sender);

        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;

        // Transfer tokens back to user
        _transfer(address(this), msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Claim all pending rewards
    function claimReward() external nonReentrant {
        _updateAllRewards(msg.sender);

        for (uint256 i = 0; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            uint256 reward = rewards[msg.sender][token];

            if (reward > 0) {
                rewards[msg.sender][token] = 0;
                _transferReward(msg.sender, token, reward);
                emit RewardPaid(msg.sender, token, reward);
            }
        }
    }

    /// @notice Claim reward for specific token
    /// @param token The reward token address
    function claimReward(address token) external nonReentrant {
        _updateReward(token, msg.sender);

        uint256 reward = rewards[msg.sender][token];
        if (reward > 0) {
            rewards[msg.sender][token] = 0;
            _transferReward(msg.sender, token, reward);
            emit RewardPaid(msg.sender, token, reward);
        }
    }

    /// @notice Stake and claim in one transaction
    function stakeAndClaim(uint256 stakeAmount) external nonReentrant {
        _updateAllRewards(msg.sender);

        // Claim first
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            uint256 reward = rewards[msg.sender][token];
            if (reward > 0) {
                rewards[msg.sender][token] = 0;
                _transferReward(msg.sender, token, reward);
                emit RewardPaid(msg.sender, token, reward);
            }
        }

        // Then stake
        if (stakeAmount > 0) {
            stakedBalance[msg.sender] += stakeAmount;
            totalStaked += stakeAmount;
            _transfer(msg.sender, address(this), stakeAmount);
            emit Staked(msg.sender, stakeAmount);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD DISTRIBUTION (Synthetix Pattern)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Notify contract of new rewards
    /// @dev Called when revenue is received
    function _notifyReward(address token, uint256 amount) internal {
        if (!isRewardToken[token]) {
            _addRewardToken(token);
        }

        RewardState storage state = rewardStates[token];

        if (streamingMode) {
            // Streaming mode: distribute over rewardDuration
            _updateRewardPerToken(token);

            if (block.timestamp >= state.periodFinish) {
                state.rewardRate = amount / rewardDuration;
            } else {
                uint256 remaining = state.periodFinish - block.timestamp;
                uint256 leftover = remaining * state.rewardRate;
                state.rewardRate = (amount + leftover) / rewardDuration;
            }

            state.lastUpdateTime = block.timestamp;
            state.periodFinish = block.timestamp + rewardDuration;
        } else {
            // Instant mode: distribute immediately to current stakers
            if (totalStaked > 0) {
                state.rewardPerTokenStored += (amount * 1e18) / totalStaked;
            } else {
                state.pendingRewards += amount;
            }
        }

        emit RewardAdded(token, amount);
    }

    /// @notice Calculate current reward per token
    function rewardPerToken(address token) public view returns (uint256) {
        RewardState storage state = rewardStates[token];

        if (totalStaked == 0) {
            return state.rewardPerTokenStored;
        }

        if (streamingMode) {
            uint256 timeElapsed = _min(block.timestamp, state.periodFinish) - state.lastUpdateTime;
            return state.rewardPerTokenStored + (timeElapsed * state.rewardRate * 1e18) / totalStaked;
        }

        return state.rewardPerTokenStored;
    }

    /// @notice Calculate earned rewards for user
    function earned(address account, address token) public view returns (uint256) {
        return (stakedBalance[account] * (rewardPerToken(token) - userRewardPerTokenPaid[account][token])) / 1e18
            + rewards[account][token];
    }

    /// @notice Get all pending rewards for user
    function earnedAll(address account) external view returns (address[] memory tokens, uint256[] memory amounts) {
        tokens = rewardTokens;
        amounts = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            amounts[i] = earned(account, tokens[i]);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _updateRewardPerToken(address token) internal {
        RewardState storage state = rewardStates[token];
        state.rewardPerTokenStored = rewardPerToken(token);
        state.lastUpdateTime = _min(block.timestamp, state.periodFinish);
    }

    function _updateReward(address token, address account) internal {
        _updateRewardPerToken(token);

        if (account != address(0)) {
            rewards[account][token] = earned(account, token);
            userRewardPerTokenPaid[account][token] = rewardStates[token].rewardPerTokenStored;
        }

        // Distribute any pending rewards when first staker arrives
        RewardState storage state = rewardStates[token];
        if (state.pendingRewards > 0 && totalStaked > 0) {
            state.rewardPerTokenStored += (state.pendingRewards * 1e18) / totalStaked;
            state.pendingRewards = 0;
        }
    }

    function _updateAllRewards(address account) internal {
        for (uint256 i = 0; i < rewardTokens.length; i++) {
            _updateReward(rewardTokens[i], account);
        }
    }

    function _addRewardToken(address token) internal {
        if (!isRewardToken[token]) {
            isRewardToken[token] = true;
            rewardTokens.push(token);
        }
    }

    function _transferReward(address to, address token, uint256 amount) internal {
        if (token == address(0)) {
            (bool success,) = to.call{value: amount}("");
            require(success, "ETH transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION (Owner Only)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set reward streaming duration
    function _setRewardDuration(uint256 duration) internal {
        rewardDuration = duration;
    }

    /// @notice Enable/disable streaming mode
    function _setStreamingMode(bool enabled) internal {
        streamingMode = enabled;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get total revenue accumulated (native token)
    function totalRevenue() external view returns (uint256) {
        return address(this).balance + rewardStates[address(0)].rewardPerTokenStored * totalStaked / 1e18;
    }

    /// @notice Get list of reward tokens
    function getRewardTokens() external view returns (address[] memory) {
        return rewardTokens;
    }

    /// @notice Get staking APY estimate (based on recent rewards)
    /// @param token The reward token
    /// @return apy Annual percentage yield in basis points
    function estimateAPY(address token) external view returns (uint256 apy) {
        if (totalStaked == 0) return 0;

        RewardState storage state = rewardStates[token];
        if (streamingMode && state.rewardRate > 0) {
            // Annual reward / total staked * 10000 (for basis points)
            uint256 annualReward = state.rewardRate * 365 days;
            apy = (annualReward * 10000) / totalStaked;
        }
        // For instant mode, APY depends on revenue frequency
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERC20 HOOKS (for auto-updating rewards on transfer)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Override to update rewards on transfer
    function _update(address from, address to, uint256 value) internal virtual override {
        // Don't update rewards for staking/unstaking operations (handled separately)
        if (from != address(this) && to != address(this)) {
            if (from != address(0)) _updateAllRewards(from);
            if (to != address(0)) _updateAllRewards(to);
        }
        super._update(from, to, value);
    }
}
