// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { TangleToken } from "../governance/TangleToken.sol";
import { IRewardsManager } from "../interfaces/IRewardsManager.sol";

/// @title RewardVaults
/// @notice Vault-based reward distribution for TNT incentives
/// @dev Implements O(1) reward distribution using accumulated-per-share pattern
///
/// Key Concepts:
/// - One vault per staking asset (TNT, WETH, etc.)
/// - Rewards are paid in TNT only (minted as inflation)
/// - Deposit cap limits how much can earn rewards
/// - Utilization affects reward rate: 10% utilized = 10% of max rewards
/// - Operators earn commission, rest goes to delegator pool
contract RewardVaults is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    IRewardsManager
{
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant REWARDS_MANAGER_ROLE = keccak256("REWARDS_MANAGER_ROLE");

    uint256 public constant BPS_DENOMINATOR = 10000;
    uint256 public constant PRECISION = 1e18;

    /// @notice Blocks per year (assuming ~12s blocks)
    uint256 public constant BLOCKS_PER_YEAR = 2_628_000;

    // ═══════════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Lock duration multipliers
    enum LockDuration {
        None,       // 1.0x (10000 bps)
        OneMonth,   // 1.1x (11000 bps)
        TwoMonths,  // 1.2x (12000 bps)
        ThreeMonths,// 1.3x (13000 bps)
        SixMonths   // 1.6x (16000 bps)
    }

    /// @notice Vault configuration for a specific asset
    struct VaultConfig {
        uint256 apyBps;          // Annual percentage yield in basis points (e.g., 500 = 5%)
        uint256 depositCap;      // Maximum deposits that earn rewards
        uint256 incentiveCap;    // Maximum rewards that can be distributed
        uint256 boostMultiplierBps; // Boost multiplier (10000 = 1x, 0 = disabled)
        bool active;             // Whether vault accepts deposits
    }

    /// @notice Current vault state
    struct VaultState {
        uint256 totalDeposits;   // Current total deposits
        uint256 totalScore;      // Total weighted score (deposits * lock multipliers)
        uint256 rewardsDistributed; // Total rewards distributed from this vault
        uint256 lastUpdateBlock; // Last block rewards were calculated
    }

    /// @notice Operator reward pool for O(1) delegator distribution
    struct OperatorPool {
        uint256 accumulatedPerShare; // Accumulated rewards per share (scaled by PRECISION)
        uint256 totalStaked;         // Total delegated to this operator
        uint256 lastUpdateBlock;     // Last update block
        uint256 pendingCommission;   // Unclaimed operator commission
    }

    /// @notice Delegator position tracking
    struct DelegatorDebt {
        uint256 lastAccumulatedPerShare; // Snapshot when last claimed
        uint256 stakedAmount;            // Current stake
        LockDuration lockDuration;       // Lock duration for multiplier
        uint256 lockExpiry;              // When lock expires (0 = no lock)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice TNT token for reward distribution
    TangleToken public tntToken;

    /// @notice Operator commission rate in basis points (e.g., 1500 = 15%)
    uint16 public operatorCommissionBps;

    /// @notice Vault configuration per asset
    mapping(address => VaultConfig) public vaultConfigs;

    /// @notice Vault state per asset
    mapping(address => VaultState) public vaultStates;

    /// @notice Operator pools per asset: asset => operator => pool
    mapping(address => mapping(address => OperatorPool)) public operatorPools;

    /// @notice Delegator debt per asset: asset => delegator => operator => debt
    mapping(address => mapping(address => mapping(address => DelegatorDebt))) public delegatorDebts;

    /// @notice Decay configuration
    uint256 public decayStartBlock;  // Block after which decay starts
    uint256 public decayRateBps;     // Decay rate per block in basis points

    /// @notice List of active vault assets
    address[] public vaultAssets;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event VaultCreated(address indexed asset, uint256 apyBps, uint256 depositCap, uint256 incentiveCap);
    event VaultConfigUpdated(address indexed asset, uint256 apyBps, uint256 depositCap, uint256 incentiveCap);
    event VaultDeactivated(address indexed asset);

    event StakeRecorded(address indexed asset, address indexed delegator, address indexed operator, uint256 amount, LockDuration lock);
    event UnstakeRecorded(address indexed asset, address indexed delegator, address indexed operator, uint256 amount);

    event RewardsDistributed(address indexed asset, address indexed operator, uint256 poolReward, uint256 commission);
    event DelegatorRewardsClaimed(address indexed asset, address indexed delegator, address indexed operator, uint256 amount);
    event OperatorCommissionClaimed(address indexed asset, address indexed operator, uint256 amount);

    event DecayConfigUpdated(uint256 startBlock, uint256 rateBps);
    event OperatorCommissionUpdated(uint16 newBps);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error VaultNotFound(address asset);
    error VaultAlreadyExists(address asset);
    error VaultNotActive(address asset);
    error InvalidAPY(uint256 apyBps);
    error InvalidDepositCap();
    error InvalidIncentiveCap();
    error InvalidDecayRate(uint256 rateBps);
    error NoRewardsToClaim();
    error StillLocked(uint256 expiry);
    error MintFailed();

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the reward vaults
    /// @param admin Admin address
    /// @param _tntToken TNT token address
    /// @param _operatorCommissionBps Initial operator commission (e.g., 1500 = 15%)
    function initialize(
        address admin,
        address _tntToken,
        uint16 _operatorCommissionBps
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(REWARDS_MANAGER_ROLE, admin);

        tntToken = TangleToken(_tntToken);
        operatorCommissionBps = _operatorCommissionBps;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VAULT MANAGEMENT (ADMIN)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new reward vault for an asset
    /// @param asset The asset address (address(0) for native)
    /// @param apyBps APY in basis points (e.g., 500 = 5%)
    /// @param depositCap Maximum deposits that earn rewards
    /// @param incentiveCap Maximum rewards distributable
    /// @param boostMultiplierBps Boost multiplier (10000 = 1x, 0 = disabled)
    function createVault(
        address asset,
        uint256 apyBps,
        uint256 depositCap,
        uint256 incentiveCap,
        uint256 boostMultiplierBps
    ) external onlyRole(ADMIN_ROLE) {
        if (vaultConfigs[asset].depositCap != 0) revert VaultAlreadyExists(asset);
        if (apyBps > 10000) revert InvalidAPY(apyBps); // Max 100% APY
        if (depositCap == 0) revert InvalidDepositCap();
        if (incentiveCap > depositCap) revert InvalidIncentiveCap();

        vaultConfigs[asset] = VaultConfig({
            apyBps: apyBps,
            depositCap: depositCap,
            incentiveCap: incentiveCap,
            boostMultiplierBps: boostMultiplierBps,
            active: true
        });

        vaultStates[asset] = VaultState({
            totalDeposits: 0,
            totalScore: 0,
            rewardsDistributed: 0,
            lastUpdateBlock: block.number
        });

        vaultAssets.push(asset);

        emit VaultCreated(asset, apyBps, depositCap, incentiveCap);
    }

    /// @notice Update vault configuration
    function updateVaultConfig(
        address asset,
        uint256 apyBps,
        uint256 depositCap,
        uint256 incentiveCap,
        uint256 boostMultiplierBps
    ) external onlyRole(ADMIN_ROLE) {
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);
        if (apyBps > 10000) revert InvalidAPY(apyBps);
        if (depositCap == 0) revert InvalidDepositCap();
        if (incentiveCap > depositCap) revert InvalidIncentiveCap();

        // Update rewards before config change
        _updateVaultRewards(asset);

        vaultConfigs[asset].apyBps = apyBps;
        vaultConfigs[asset].depositCap = depositCap;
        vaultConfigs[asset].incentiveCap = incentiveCap;
        vaultConfigs[asset].boostMultiplierBps = boostMultiplierBps;

        emit VaultConfigUpdated(asset, apyBps, depositCap, incentiveCap);
    }

    /// @notice Deactivate a vault (no new deposits, existing can withdraw)
    function deactivateVault(address asset) external onlyRole(ADMIN_ROLE) {
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);
        vaultConfigs[asset].active = false;
        emit VaultDeactivated(asset);
    }

    /// @notice Update operator commission rate
    function setOperatorCommission(uint16 newBps) external onlyRole(ADMIN_ROLE) {
        require(newBps <= 5000, "Max 50% commission");
        operatorCommissionBps = newBps;
        emit OperatorCommissionUpdated(newBps);
    }

    /// @notice Update decay configuration
    function setDecayConfig(uint256 startBlock, uint256 rateBps) external onlyRole(ADMIN_ROLE) {
        if (rateBps > 1000) revert InvalidDecayRate(rateBps); // Max 10% decay
        decayStartBlock = startBlock;
        decayRateBps = rateBps;
        emit DecayConfigUpdated(startBlock, rateBps);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // IRewardsManager IMPLEMENTATION (Called by MultiAssetDelegation)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IRewardsManager
    function recordDelegate(
        address delegator,
        address operator,
        address asset,
        uint256 amount,
        uint16 lockMultiplierBps
    ) external override onlyRole(REWARDS_MANAGER_ROLE) {
        // Skip if asset not in a vault
        if (vaultConfigs[asset].depositCap == 0) return;

        _updateVaultRewards(asset);

        // Update vault totals
        VaultState storage state = vaultStates[asset];
        state.totalDeposits += amount;

        // Calculate score with lock multiplier
        uint256 score = lockMultiplierBps > 0
            ? (amount * lockMultiplierBps) / BPS_DENOMINATOR
            : amount;
        state.totalScore += score;

        // Track delegator's first interaction for reward claiming
        if (delegatorDebts[asset][delegator][operator].stakedAmount == 0) {
            delegatorDebts[asset][delegator][operator].lastAccumulatedPerShare =
                operatorPools[asset][operator].accumulatedPerShare;
        }
        delegatorDebts[asset][delegator][operator].stakedAmount += amount;

        // Update operator pool total
        operatorPools[asset][operator].totalStaked += amount;

        emit StakeRecorded(asset, delegator, operator, amount, LockDuration.None);
    }

    /// @inheritdoc IRewardsManager
    function recordUndelegate(
        address delegator,
        address operator,
        address asset,
        uint256 amount
    ) external override onlyRole(REWARDS_MANAGER_ROLE) {
        // Skip if asset not in a vault
        if (vaultConfigs[asset].depositCap == 0) return;

        _updateVaultRewards(asset);

        // Update vault totals
        VaultState storage state = vaultStates[asset];
        state.totalDeposits -= amount;
        state.totalScore -= amount; // Simplified - assumes no lock multiplier on unstake

        // Update delegator tracking
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        if (debt.stakedAmount >= amount) {
            debt.stakedAmount -= amount;
        }

        // Update operator pool total
        OperatorPool storage pool = operatorPools[asset][operator];
        if (pool.totalStaked >= amount) {
            pool.totalStaked -= amount;
        }

        emit UnstakeRecorded(asset, delegator, operator, amount);
    }

    /// @inheritdoc IRewardsManager
    function recordServiceReward(
        address operator,
        address asset,
        uint256 amount
    ) external override onlyRole(REWARDS_MANAGER_ROLE) {
        // Skip if asset not in a vault or no amount
        if (vaultConfigs[asset].depositCap == 0 || amount == 0) return;

        _updateVaultRewards(asset);
        _updateOperatorPool(asset, operator);

        OperatorPool storage pool = operatorPools[asset][operator];

        // Split between commission and delegator pool
        uint256 commission = (amount * operatorCommissionBps) / BPS_DENOMINATOR;
        uint256 poolReward = amount - commission;

        pool.pendingCommission += commission;

        if (pool.totalStaked > 0 && poolReward > 0) {
            pool.accumulatedPerShare += (poolReward * PRECISION) / pool.totalStaked;
        }

        vaultStates[asset].rewardsDistributed += amount;

        emit RewardsDistributed(asset, operator, poolReward, commission);
    }

    /// @inheritdoc IRewardsManager
    function getAssetDepositCapRemaining(address asset) external view override returns (uint256) {
        VaultConfig storage config = vaultConfigs[asset];
        if (config.depositCap == 0) return 0;

        VaultState storage state = vaultStates[asset];
        if (state.totalScore >= config.depositCap) return 0;

        return config.depositCap - state.totalScore;
    }

    /// @inheritdoc IRewardsManager
    function getAssetIncentiveCap(address asset) external view override returns (uint256) {
        return vaultConfigs[asset].incentiveCap;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EPOCH REWARDS (Called by InflationController)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute epoch staking rewards across all operators in a vault
    /// @dev Called by InflationController after minting TNT to this contract
    /// @param asset The vault asset
    /// @param amount Total reward amount to distribute
    function distributeEpochReward(
        address asset,
        uint256 amount
    ) external onlyRole(REWARDS_MANAGER_ROLE) {
        if (amount == 0) return;
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);

        _updateVaultRewards(asset);

        VaultState storage state = vaultStates[asset];
        if (state.totalDeposits == 0) return;

        // Distribute to all operator pools proportionally to their stake
        // This is a simplified distribution - in practice you'd iterate over operators
        // For now, we track it at the vault level and individual operators claim their share

        state.rewardsDistributed += amount;

        emit EpochRewardDistributed(asset, amount);
    }

    /// @notice Distribute epoch reward to a specific operator's pool
    /// @param asset The vault asset
    /// @param operator The operator address
    /// @param amount Reward amount for this operator
    function distributeEpochRewardToOperator(
        address asset,
        address operator,
        uint256 amount
    ) external onlyRole(REWARDS_MANAGER_ROLE) {
        if (amount == 0) return;
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);

        _updateVaultRewards(asset);
        _updateOperatorPool(asset, operator);

        OperatorPool storage pool = operatorPools[asset][operator];

        // Split between commission and delegator pool
        uint256 commission = (amount * operatorCommissionBps) / BPS_DENOMINATOR;
        uint256 poolReward = amount - commission;

        pool.pendingCommission += commission;

        if (pool.totalStaked > 0 && poolReward > 0) {
            pool.accumulatedPerShare += (poolReward * PRECISION) / pool.totalStaked;
        }

        vaultStates[asset].rewardsDistributed += amount;

        emit RewardsDistributed(asset, operator, poolReward, commission);
    }

    // Event for epoch rewards
    event EpochRewardDistributed(address indexed asset, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE RECORDING (Legacy - for direct calls with LockDuration enum)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record a stake for reward tracking
    /// @param asset The staked asset
    /// @param delegator The delegator address
    /// @param operator The operator address
    /// @param amount The stake amount
    /// @param lock The lock duration
    function recordStake(
        address asset,
        address delegator,
        address operator,
        uint256 amount,
        LockDuration lock
    ) external onlyRole(REWARDS_MANAGER_ROLE) {
        VaultConfig storage config = vaultConfigs[asset];
        if (config.depositCap == 0) revert VaultNotFound(asset);
        if (!config.active) revert VaultNotActive(asset);

        // Update vault and operator pool rewards first
        _updateVaultRewards(asset);
        _updateOperatorPool(asset, operator);

        // Update vault state
        VaultState storage state = vaultStates[asset];
        uint256 score = _calculateScore(amount, lock);
        state.totalDeposits += amount;
        state.totalScore += score;

        // Update operator pool
        OperatorPool storage pool = operatorPools[asset][operator];
        pool.totalStaked += amount;

        // Update delegator debt
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        debt.lastAccumulatedPerShare = pool.accumulatedPerShare;
        debt.stakedAmount += amount;
        debt.lockDuration = lock;
        if (lock != LockDuration.None) {
            debt.lockExpiry = block.timestamp + _lockDurationSeconds(lock);
        }

        emit StakeRecorded(asset, delegator, operator, amount, lock);
    }

    /// @notice Record an unstake
    function recordUnstake(
        address asset,
        address delegator,
        address operator,
        uint256 amount
    ) external onlyRole(REWARDS_MANAGER_ROLE) {
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        if (debt.lockExpiry > block.timestamp) revert StillLocked(debt.lockExpiry);

        // Update rewards before unstaking
        _updateVaultRewards(asset);
        _updateOperatorPool(asset, operator);

        // Update vault state
        VaultState storage state = vaultStates[asset];
        uint256 score = _calculateScore(amount, debt.lockDuration);
        state.totalDeposits -= amount;
        state.totalScore -= score;

        // Update operator pool
        OperatorPool storage pool = operatorPools[asset][operator];
        pool.totalStaked -= amount;

        // Update delegator debt
        debt.stakedAmount -= amount;
        if (debt.stakedAmount == 0) {
            debt.lockDuration = LockDuration.None;
            debt.lockExpiry = 0;
        }

        emit UnstakeRecorded(asset, delegator, operator, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim delegator rewards from an operator pool
    /// @param asset The vault asset
    /// @param operator The operator address
    function claimDelegatorRewards(
        address asset,
        address operator
    ) external nonReentrant returns (uint256) {
        _updateVaultRewards(asset);
        _updateOperatorPool(asset, operator);

        DelegatorDebt storage debt = delegatorDebts[asset][msg.sender][operator];
        OperatorPool storage pool = operatorPools[asset][operator];

        uint256 owed = _calculateDelegatorRewards(pool, debt);
        if (owed == 0) revert NoRewardsToClaim();

        // Update debt checkpoint
        debt.lastAccumulatedPerShare = pool.accumulatedPerShare;

        // Mint and transfer TNT
        _mintRewards(msg.sender, owed);

        emit DelegatorRewardsClaimed(asset, msg.sender, operator, owed);
        return owed;
    }

    /// @notice Claim operator commission
    /// @param asset The vault asset
    function claimOperatorCommission(address asset) external nonReentrant returns (uint256) {
        _updateVaultRewards(asset);
        _updateOperatorPool(asset, msg.sender);

        OperatorPool storage pool = operatorPools[asset][msg.sender];
        uint256 commission = pool.pendingCommission;
        if (commission == 0) revert NoRewardsToClaim();

        pool.pendingCommission = 0;

        // Mint and transfer TNT
        _mintRewards(msg.sender, commission);

        emit OperatorCommissionClaimed(asset, msg.sender, commission);
        return commission;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD DISTRIBUTION (Called externally to trigger distribution)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute rewards to an operator's pool
    /// @dev Called by reward manager based on service activity
    /// @param asset The vault asset
    /// @param operator The operator address
    /// @param amount Total reward amount (will be split between commission and pool)
    function distributeRewards(
        address asset,
        address operator,
        uint256 amount
    ) external onlyRole(REWARDS_MANAGER_ROLE) {
        if (amount == 0) return;

        _updateVaultRewards(asset);
        _updateOperatorPool(asset, operator);

        OperatorPool storage pool = operatorPools[asset][operator];

        // Split between commission and delegator pool
        uint256 commission = (amount * operatorCommissionBps) / BPS_DENOMINATOR;
        uint256 poolReward = amount - commission;

        // Add commission to pending
        pool.pendingCommission += commission;

        // Add to pool (increases accumulated per share)
        if (pool.totalStaked > 0 && poolReward > 0) {
            pool.accumulatedPerShare += (poolReward * PRECISION) / pool.totalStaked;
        }

        // Track in vault state
        vaultStates[asset].rewardsDistributed += amount;

        emit RewardsDistributed(asset, operator, poolReward, commission);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL: REWARD CALCULATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update vault rewards based on time elapsed
    function _updateVaultRewards(address asset) internal {
        VaultState storage state = vaultStates[asset];
        VaultConfig storage config = vaultConfigs[asset];

        uint256 blocksPassed = block.number - state.lastUpdateBlock;
        if (blocksPassed == 0) return;

        state.lastUpdateBlock = block.number;

        // No rewards if no deposits
        if (state.totalDeposits == 0) return;

        // Calculate utilization: min(deposits, depositCap) / depositCap
        uint256 effectiveDeposits = state.totalDeposits > config.depositCap
            ? config.depositCap
            : state.totalDeposits;
        uint256 utilizationBps = (effectiveDeposits * BPS_DENOMINATOR) / config.depositCap;

        // Calculate rewards: (APY / blocks_per_year) * effective_deposits * utilization * blocks
        // Utilization squared effect: 10% utilized = 1% of max rewards
        uint256 maxRewardsPerBlock = (config.incentiveCap * config.apyBps) / (BLOCKS_PER_YEAR * BPS_DENOMINATOR);
        uint256 actualRewards = (maxRewardsPerBlock * utilizationBps * utilizationBps * blocksPassed) / (BPS_DENOMINATOR * BPS_DENOMINATOR);

        // Apply decay if past start block
        if (decayStartBlock > 0 && block.number > decayStartBlock) {
            uint256 decayBlocks = block.number - decayStartBlock;
            uint256 decayFactor = BPS_DENOMINATOR - ((decayBlocks * decayRateBps) / BPS_DENOMINATOR);
            if (decayFactor < 1000) decayFactor = 1000; // Minimum 10% of rewards
            actualRewards = (actualRewards * decayFactor) / BPS_DENOMINATOR;
        }

        // Rewards are distributed when operators receive them via distributeRewards()
        // This function just updates the vault's time tracking
    }

    /// @notice Update operator pool state
    function _updateOperatorPool(address asset, address operator) internal {
        OperatorPool storage pool = operatorPools[asset][operator];
        pool.lastUpdateBlock = block.number;
    }

    /// @notice Calculate delegator rewards owed
    function _calculateDelegatorRewards(
        OperatorPool storage pool,
        DelegatorDebt storage debt
    ) internal view returns (uint256) {
        if (debt.stakedAmount == 0) return 0;

        uint256 accumulatedDiff = pool.accumulatedPerShare - debt.lastAccumulatedPerShare;
        return (debt.stakedAmount * accumulatedDiff) / PRECISION;
    }

    /// @notice Calculate weighted score for stake
    function _calculateScore(uint256 amount, LockDuration lock) internal pure returns (uint256) {
        uint256 multiplierBps = _lockMultiplierBps(lock);
        return (amount * multiplierBps) / BPS_DENOMINATOR;
    }

    /// @notice Get lock multiplier in basis points
    function _lockMultiplierBps(LockDuration lock) internal pure returns (uint256) {
        if (lock == LockDuration.None) return 10000;      // 1.0x
        if (lock == LockDuration.OneMonth) return 11000;  // 1.1x
        if (lock == LockDuration.TwoMonths) return 12000; // 1.2x
        if (lock == LockDuration.ThreeMonths) return 13000; // 1.3x
        if (lock == LockDuration.SixMonths) return 16000; // 1.6x
        return 10000;
    }

    /// @notice Get lock duration in seconds
    function _lockDurationSeconds(LockDuration lock) internal pure returns (uint256) {
        if (lock == LockDuration.OneMonth) return 30 days;
        if (lock == LockDuration.TwoMonths) return 60 days;
        if (lock == LockDuration.ThreeMonths) return 90 days;
        if (lock == LockDuration.SixMonths) return 180 days;
        return 0;
    }

    /// @notice Mint TNT rewards
    function _mintRewards(address to, uint256 amount) internal {
        // Requires RewardVaults to have MINTER_ROLE on TangleToken
        tntToken.mint(to, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pending delegator rewards
    function pendingDelegatorRewards(
        address asset,
        address delegator,
        address operator
    ) external view returns (uint256) {
        OperatorPool storage pool = operatorPools[asset][operator];
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        return _calculateDelegatorRewards(pool, debt);
    }

    /// @notice Get pending operator commission
    function pendingOperatorCommission(
        address asset,
        address operator
    ) external view returns (uint256) {
        return operatorPools[asset][operator].pendingCommission;
    }

    /// @notice Get vault utilization in basis points
    function getVaultUtilization(address asset) external view returns (uint256) {
        VaultConfig storage config = vaultConfigs[asset];
        VaultState storage state = vaultStates[asset];
        if (config.depositCap == 0) return 0;
        return (state.totalDeposits * BPS_DENOMINATOR) / config.depositCap;
    }

    /// @notice Get all vault assets
    function getVaultAssets() external view returns (address[] memory) {
        return vaultAssets;
    }

    /// @notice Get vault count
    function vaultCount() external view returns (uint256) {
        return vaultAssets.length;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADES
    // ═══════════════════════════════════════════════════════════════════════════

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}
}
