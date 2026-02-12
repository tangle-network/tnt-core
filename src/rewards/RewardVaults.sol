// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { TangleToken } from "../governance/TangleToken.sol";
import { IRewardsManager } from "../interfaces/IRewardsManager.sol";

/// @title RewardVaults
/// @notice Vault-based reward distribution for TNT incentives
/// @dev Implements O(1) reward distribution using accumulated-per-share accounting.
///
/// Key Concepts:
/// - One vault per staking asset (TNT, WETH, etc.)
/// - Rewards are paid in TNT (funded by InflationPool, NOT minted)
/// - Deposit cap limits how much stake can earn rewards
/// - Operators earn commission, rest goes to delegator pool
///
/// Funding Model:
/// - InflationPool transfers TNT to this contract each epoch
/// - This contract holds TNT and distributes it to claimants
/// - NO MINTING: This contract cannot mint tokens, only transfer what it holds
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

    uint256 public constant BPS_DENOMINATOR = 10_000;
    uint256 public constant PRECISION = 1e18;

    /// @notice Configurable lock durations for multiplier rewards (in seconds)
    uint256 public lockDurationOneMonth = 30 days;
    uint256 public lockDurationTwoMonths = 60 days;
    uint256 public lockDurationThreeMonths = 90 days;
    uint256 public lockDurationSixMonths = 180 days;

    // ═══════════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Lock duration multipliers
    enum LockDuration {
        None, // 1.0x (10000 bps)
        OneMonth, // 1.1x (11000 bps)
        TwoMonths, // 1.2x (12000 bps)
        ThreeMonths, // 1.3x (13000 bps)
        SixMonths // 1.6x (16000 bps)
    }

    /// @notice Vault configuration for a specific asset
    struct VaultConfig {
        uint256 depositCap; // Maximum deposits that earn rewards
        bool active; // Whether vault accepts deposits
    }

    /// @notice Current vault state
    struct VaultState {
        uint256 totalDeposits; // Current total deposits
        uint256 totalScore; // Total weighted score (deposits * lock multipliers)
        uint256 rewardsDistributed; // Total rewards distributed from this vault
    }

    /// @notice Operator reward pool for O(1) delegator distribution
    struct OperatorPool {
        uint256 accumulatedPerShare; // Accumulated rewards per share (scaled by PRECISION)
        uint256 totalStaked; // Total delegated to this operator
        uint256 pendingCommission; // Unclaimed operator commission
    }

    /// @notice Delegator position tracking
    struct DelegatorDebt {
        uint256 lastAccumulatedPerShare; // Snapshot when last claimed
        uint256 stakedAmount; // Current stake
        LockDuration lockDuration; // Lock duration for multiplier
        uint256 lockExpiry; // When lock expires (0 = no lock)
        uint256 boostedScore; // Weighted score minted for this delegator/operator pair
    }

    /// @notice Snapshot returned when rendering vaults in UI clients
    struct VaultSummary {
        address asset;
        uint256 depositCap;
        bool active;
        uint256 totalDeposits;
        uint256 totalScore;
        uint256 rewardsDistributed;
        uint256 depositCapRemaining;
        uint256 utilizationBps;
    }

    /// @notice Delegator position view model
    struct DelegatorPosition {
        address operator;
        uint256 stakedAmount;
        uint256 boostedScore;
        LockDuration lockDuration;
        uint256 lockExpiry;
        uint256 pendingRewards;
    }

    /// @notice Lightweight pending reward tuple for dashboards
    struct PendingRewardsView {
        address operator;
        uint256 amount;
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

    /// @notice Operators tracked per asset for epoch reward fan-out
    mapping(address => address[]) private assetOperators;
    mapping(address => mapping(address => bool)) private isAssetOperator;

    /// @notice Operators a delegator currently has stake with per asset
    mapping(address => mapping(address => address[])) private delegatorOperators;

    /// @notice Index of an operator inside a delegator's operator list (index + 1)
    mapping(address => mapping(address => mapping(address => uint256))) private delegatorOperatorIndex;

    /// @notice List of active vault assets
    address[] public vaultAssets;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event VaultCreated(address indexed asset, uint256 depositCap);
    event VaultConfigUpdated(address indexed asset, uint256 depositCap);
    event VaultDeactivated(address indexed asset);

    event StakeRecorded(
        address indexed asset, address indexed delegator, address indexed operator, uint256 amount, LockDuration lock
    );
    event UnstakeRecorded(address indexed asset, address indexed delegator, address indexed operator, uint256 amount);

    event RewardsDistributed(address indexed asset, address indexed operator, uint256 poolReward, uint256 commission);
    event DelegatorRewardsClaimed(
        address indexed asset, address indexed delegator, address indexed operator, uint256 amount
    );
    event OperatorCommissionClaimed(address indexed asset, address indexed operator, uint256 amount);

    event OperatorCommissionUpdated(uint16 newBps);
    event LockDurationsUpdated(uint256 oneMonth, uint256 twoMonths, uint256 threeMonths, uint256 sixMonths);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error VaultNotFound(address asset);
    error VaultAlreadyExists(address asset);
    error VaultNotActive(address asset);
    error InvalidDepositCap();
    error NoRewardsToClaim();
    error StillLocked(uint256 expiry);
    error DepositCapExceeded(address asset);
    error InsufficientStake();

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
    function initialize(address admin, address _tntToken, uint16 _operatorCommissionBps) external initializer {
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
    /// @param depositCap Maximum deposits that earn rewards
    function createVault(address asset, uint256 depositCap) external onlyRole(ADMIN_ROLE) {
        if (vaultConfigs[asset].depositCap != 0) revert VaultAlreadyExists(asset);
        if (depositCap == 0) revert InvalidDepositCap();

        vaultConfigs[asset] = VaultConfig({ depositCap: depositCap, active: true });

        vaultStates[asset] = VaultState({ totalDeposits: 0, totalScore: 0, rewardsDistributed: 0 });

        vaultAssets.push(asset);

        emit VaultCreated(asset, depositCap);
    }

    /// @notice Update vault configuration
    function updateVaultConfig(address asset, uint256 depositCap) external onlyRole(ADMIN_ROLE) {
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);
        if (depositCap == 0) revert InvalidDepositCap();

        vaultConfigs[asset].depositCap = depositCap;

        emit VaultConfigUpdated(asset, depositCap);
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

    /// @notice Update lock durations to better align with observed block times
    function setLockDurations(
        uint256 oneMonth,
        uint256 twoMonths,
        uint256 threeMonths,
        uint256 sixMonths
    )
        external
        onlyRole(ADMIN_ROLE)
    {
        require(oneMonth > 0, "oneMonth=0");
        require(twoMonths >= oneMonth, "twoMonths<one");
        require(threeMonths >= twoMonths, "threeMonths<two");
        require(sixMonths >= threeMonths, "sixMonths<three");

        lockDurationOneMonth = oneMonth;
        lockDurationTwoMonths = twoMonths;
        lockDurationThreeMonths = threeMonths;
        lockDurationSixMonths = sixMonths;

        emit LockDurationsUpdated(oneMonth, twoMonths, threeMonths, sixMonths);
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
    )
        external
        override
        onlyRole(REWARDS_MANAGER_ROLE)
    {
        // Skip if asset not in a vault
        VaultConfig storage config = vaultConfigs[asset];
        if (config.depositCap == 0) return;
        if (!config.active) revert VaultNotActive(asset);

        _trackOperator(asset, operator);

        // Update vault totals
        VaultState storage state = vaultStates[asset];
        uint256 score = lockMultiplierBps > 0 ? (amount * lockMultiplierBps) / BPS_DENOMINATOR : amount;
        if (state.totalDeposits + amount > config.depositCap) revert DepositCapExceeded(asset);
        state.totalDeposits += amount;
        state.totalScore += score;

        // Track delegator's first interaction for reward claiming
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        bool isNewDelegator = debt.stakedAmount == 0;
        if (isNewDelegator) {
            debt.lastAccumulatedPerShare = operatorPools[asset][operator].accumulatedPerShare;
        }
        debt.stakedAmount += amount;
        debt.boostedScore += score;
        debt.lockDuration = LockDuration.None;
        debt.lockExpiry = 0;

        if (isNewDelegator) {
            _trackDelegatorOperator(asset, delegator, operator);
        }

        // Update operator pool total (score-weighted)
        operatorPools[asset][operator].totalStaked += score;

        emit StakeRecorded(asset, delegator, operator, amount, LockDuration.None);
    }

    /// @inheritdoc IRewardsManager
    function recordUndelegate(
        address delegator,
        address operator,
        address asset,
        uint256 amount
    )
        external
        override
        onlyRole(REWARDS_MANAGER_ROLE)
    {
        // Skip if asset not in a vault
        if (vaultConfigs[asset].depositCap == 0) return;

        // Update vault totals
        VaultState storage state = vaultStates[asset];
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        if (debt.stakedAmount < amount) revert InsufficientStake();
        uint256 stakedBefore = debt.stakedAmount;
        uint256 score = debt.boostedScore == 0 ? amount : (debt.boostedScore * amount) / stakedBefore;
        state.totalDeposits -= amount;
        state.totalScore -= score;

        // Update delegator tracking
        debt.stakedAmount -= amount;
        if (debt.boostedScore >= score) {
            debt.boostedScore -= score;
        } else {
            debt.boostedScore = 0;
        }
        if (debt.stakedAmount == 0) {
            debt.lockDuration = LockDuration.None;
            debt.lockExpiry = 0;
            _untrackDelegatorOperator(asset, delegator, operator);
        }

        // Update operator pool total (score-weighted)
        OperatorPool storage pool = operatorPools[asset][operator];
        if (pool.totalStaked < score) revert InsufficientStake();
        pool.totalStaked -= score;

        emit UnstakeRecorded(asset, delegator, operator, amount);
    }

    /// @inheritdoc IRewardsManager
    function recordServiceReward(
        address operator,
        address asset,
        uint256 amount
    )
        external
        override
        onlyRole(REWARDS_MANAGER_ROLE)
    {
        // Skip if asset not in a vault or no amount
        if (vaultConfigs[asset].depositCap == 0 || amount == 0) return;

        _trackOperator(asset, operator);

        _distributeToOperatorPool(asset, operator, amount);
    }

    /// @inheritdoc IRewardsManager
    function getAssetDepositCapRemaining(address asset) external view override returns (uint256) {
        VaultConfig storage config = vaultConfigs[asset];
        if (config.depositCap == 0) return 0;

        VaultState storage state = vaultStates[asset];
        if (state.totalDeposits >= config.depositCap) return 0;

        return config.depositCap - state.totalDeposits;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EPOCH REWARDS (Called by InflationPool)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute epoch staking rewards across all operators in a vault
    /// @dev Called by InflationPool after transferring TNT to this contract
    /// @param asset The vault asset
    /// @param amount Total reward amount to distribute
    function distributeEpochReward(address asset, uint256 amount) external onlyRole(REWARDS_MANAGER_ROLE) {
        if (amount == 0) return;
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);

        VaultState storage state = vaultStates[asset];
        if (state.totalScore == 0) return;

        address[] storage operators = assetOperators[asset];
        uint256 totalStake = 0;
        for (uint256 i = 0; i < operators.length; i++) {
            uint256 stake = operatorPools[asset][operators[i]].totalStaked;
            if (stake == 0) continue;
            totalStake += stake;
        }
        if (totalStake == 0) return;

        uint256 amountRemaining = amount;
        uint256 stakeRemaining = totalStake;
        for (uint256 i = 0; i < operators.length && amountRemaining > 0; i++) {
            address operator = operators[i];
            uint256 operatorStake = operatorPools[asset][operator].totalStaked;
            if (operatorStake == 0) continue;

            uint256 share = (amountRemaining * operatorStake) / stakeRemaining;
            amountRemaining -= share;
            stakeRemaining -= operatorStake;
            if (share == 0) continue;

            _distributeToOperatorPool(asset, operator, share);
        }

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
    )
        external
        onlyRole(REWARDS_MANAGER_ROLE)
    {
        if (amount == 0) return;
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);

        _trackOperator(asset, operator);

        _distributeToOperatorPool(asset, operator, amount);
    }

    // Event for epoch rewards
    event EpochRewardDistributed(address indexed asset, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════════
    // Stake recording (compatibility for direct calls with LockDuration enum)
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
    )
        external
        onlyRole(REWARDS_MANAGER_ROLE)
    {
        VaultConfig storage config = vaultConfigs[asset];
        if (config.depositCap == 0) revert VaultNotFound(asset);
        if (!config.active) revert VaultNotActive(asset);

        _trackOperator(asset, operator);

        // Update vault state
        VaultState storage state = vaultStates[asset];
        uint256 score = _calculateScore(amount, lock);
        if (state.totalDeposits + amount > config.depositCap) revert DepositCapExceeded(asset);
        state.totalDeposits += amount;
        state.totalScore += score;

        // Update operator pool
        OperatorPool storage pool = operatorPools[asset][operator];
        pool.totalStaked += score;

        // Update delegator debt
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        bool isNewDelegator = debt.stakedAmount == 0;
        if (isNewDelegator) {
            debt.lastAccumulatedPerShare = pool.accumulatedPerShare;
        }
        debt.stakedAmount += amount;
        debt.lockDuration = lock;
        if (lock != LockDuration.None) {
            debt.lockExpiry = block.timestamp + _lockDurationSeconds(lock);
        } else {
            debt.lockExpiry = 0;
        }
        debt.boostedScore += score;

        if (isNewDelegator) {
            _trackDelegatorOperator(asset, delegator, operator);
        }

        emit StakeRecorded(asset, delegator, operator, amount, lock);
    }

    /// @notice Record an unstake
    function recordUnstake(
        address asset,
        address delegator,
        address operator,
        uint256 amount
    )
        external
        onlyRole(REWARDS_MANAGER_ROLE)
    {
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        if (debt.lockExpiry > block.timestamp) revert StillLocked(debt.lockExpiry);
        if (debt.stakedAmount < amount) revert InsufficientStake();

        // Update operator pool before unstaking

        // Update vault state
        VaultState storage state = vaultStates[asset];
        uint256 score = debt.boostedScore == 0
            ? _calculateScore(amount, debt.lockDuration)
            : (debt.boostedScore * amount) / debt.stakedAmount;
        state.totalDeposits -= amount;
        state.totalScore -= score;

        // Update operator pool
        OperatorPool storage pool = operatorPools[asset][operator];
        if (pool.totalStaked < score) revert InsufficientStake();
        pool.totalStaked -= score;

        // Update delegator debt
        debt.stakedAmount -= amount;
        if (debt.boostedScore >= score) {
            debt.boostedScore -= score;
        } else {
            debt.boostedScore = 0;
        }
        if (debt.stakedAmount == 0) {
            debt.lockDuration = LockDuration.None;
            debt.lockExpiry = 0;
            _untrackDelegatorOperator(asset, delegator, operator);
        }

        emit UnstakeRecorded(asset, delegator, operator, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim delegator rewards from an operator pool
    /// @param asset The vault asset
    /// @param operator The operator address
    function claimDelegatorRewards(address asset, address operator) external nonReentrant returns (uint256) {
        uint256 claimed = _claimDelegatorReward(msg.sender, asset, operator);
        if (claimed == 0) revert NoRewardsToClaim();
        return claimed;
    }

    /// @notice Claim delegator rewards from multiple operator pools
    /// @param asset The vault asset
    /// @param operators Operator list to claim from
    function claimDelegatorRewardsBatch(
        address asset,
        address[] calldata operators
    )
        external
        nonReentrant
        returns (uint256)
    {
        uint256 totalClaimed;
        for (uint256 i = 0; i < operators.length; i++) {
            totalClaimed += _claimDelegatorReward(msg.sender, asset, operators[i]);
        }
        if (totalClaimed == 0) revert NoRewardsToClaim();
        return totalClaimed;
    }

    /// @notice Claim rewards on behalf of a delegator (recipient receives funds directly)
    /// @param asset The vault asset
    /// @param operator The operator address
    /// @param delegator The account whose rewards are claimed
    function claimDelegatorRewardsFor(
        address asset,
        address operator,
        address delegator
    )
        external
        nonReentrant
        returns (uint256)
    {
        uint256 claimed = _claimDelegatorReward(delegator, asset, operator);
        if (claimed == 0) revert NoRewardsToClaim();
        return claimed;
    }

    /// @notice Claim operator commission
    /// @param asset The vault asset
    function claimOperatorCommission(address asset) external nonReentrant returns (uint256) {
        OperatorPool storage pool = operatorPools[asset][msg.sender];
        uint256 commission = pool.pendingCommission;
        if (commission == 0) revert NoRewardsToClaim();

        pool.pendingCommission = 0;

        // Transfer TNT from pool balance
        _transferRewards(msg.sender, commission);

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
    )
        external
        onlyRole(REWARDS_MANAGER_ROLE)
    {
        if (amount == 0) return;

        _trackOperator(asset, operator);

        _distributeToOperatorPool(asset, operator, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL: REWARD CALCULATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _trackOperator(address asset, address operator) internal {
        if (isAssetOperator[asset][operator]) return;
        isAssetOperator[asset][operator] = true;
        assetOperators[asset].push(operator);
    }

    function _trackDelegatorOperator(address asset, address delegator, address operator) internal {
        if (delegatorOperatorIndex[asset][delegator][operator] != 0) {
            return;
        }
        delegatorOperators[asset][delegator].push(operator);
        delegatorOperatorIndex[asset][delegator][operator] = delegatorOperators[asset][delegator].length;
    }

    function _untrackDelegatorOperator(address asset, address delegator, address operator) internal {
        uint256 indexPlusOne = delegatorOperatorIndex[asset][delegator][operator];
        if (indexPlusOne == 0) {
            return;
        }

        address[] storage operators = delegatorOperators[asset][delegator];
        uint256 index = indexPlusOne - 1;
        uint256 lastIndex = operators.length - 1;

        if (index != lastIndex) {
            address lastOperator = operators[lastIndex];
            operators[index] = lastOperator;
            delegatorOperatorIndex[asset][delegator][lastOperator] = index + 1;
        }

        operators.pop();
        delegatorOperatorIndex[asset][delegator][operator] = 0;
    }

    function _distributeToOperatorPool(address asset, address operator, uint256 amount) internal {
        if (amount == 0) return;

        OperatorPool storage pool = operatorPools[asset][operator];

        uint256 commission = (amount * operatorCommissionBps) / BPS_DENOMINATOR;
        uint256 poolReward = amount - commission;

        pool.pendingCommission += commission;

        if (pool.totalStaked > 0 && poolReward > 0) {
            pool.accumulatedPerShare += (poolReward * PRECISION) / pool.totalStaked;
        }

        vaultStates[asset].rewardsDistributed += amount;

        emit RewardsDistributed(asset, operator, poolReward, commission);
    }

    /// @notice Calculate delegator rewards owed
    function _calculateDelegatorRewards(
        OperatorPool storage pool,
        DelegatorDebt storage debt
    )
        internal
        view
        returns (uint256)
    {
        if (debt.stakedAmount == 0) return 0;

        uint256 accumulatedDiff = pool.accumulatedPerShare - debt.lastAccumulatedPerShare;
        return (debt.boostedScore * accumulatedDiff) / PRECISION;
    }

    /// @notice Shared implementation for delegator reward claims
    function _claimDelegatorReward(address delegator, address asset, address operator) internal returns (uint256) {
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);

        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        OperatorPool storage pool = operatorPools[asset][operator];

        uint256 owed = _calculateDelegatorRewards(pool, debt);
        if (owed == 0) {
            return 0;
        }

        debt.lastAccumulatedPerShare = pool.accumulatedPerShare;
        _transferRewards(delegator, owed);

        emit DelegatorRewardsClaimed(asset, delegator, operator, owed);
        return owed;
    }

    /// @notice Calculate weighted score for stake
    function _calculateScore(uint256 amount, LockDuration lock) internal pure returns (uint256) {
        uint256 multiplierBps = _lockMultiplierBps(lock);
        return (amount * multiplierBps) / BPS_DENOMINATOR;
    }

    /// @notice Get lock multiplier in basis points
    function _lockMultiplierBps(LockDuration lock) internal pure returns (uint256) {
        if (lock == LockDuration.None) return 10_000; // 1.0x
        if (lock == LockDuration.OneMonth) return 11_000; // 1.1x
        if (lock == LockDuration.TwoMonths) return 12_000; // 1.2x
        if (lock == LockDuration.ThreeMonths) return 13_000; // 1.3x
        if (lock == LockDuration.SixMonths) return 16_000; // 1.6x
        return 10_000;
    }

    /// @notice Get lock duration in seconds
    function _lockDurationSeconds(LockDuration lock) internal view returns (uint256) {
        if (lock == LockDuration.OneMonth) return lockDurationOneMonth;
        if (lock == LockDuration.TwoMonths) return lockDurationTwoMonths;
        if (lock == LockDuration.ThreeMonths) return lockDurationThreeMonths;
        if (lock == LockDuration.SixMonths) return lockDurationSixMonths;
        return 0;
    }

    /// @notice Transfer TNT rewards from pool balance
    /// @dev Requires this contract to hold sufficient TNT (funded by InflationPool)
    function _transferRewards(address to, uint256 amount) internal {
        // Transfer from this contract's balance (funded by InflationPool)
        require(tntToken.balanceOf(address(this)) >= amount, "Insufficient reward balance");
        require(tntToken.transfer(to, amount), "Reward transfer failed");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pending delegator rewards
    function pendingDelegatorRewards(
        address asset,
        address delegator,
        address operator
    )
        external
        view
        returns (uint256)
    {
        OperatorPool storage pool = operatorPools[asset][operator];
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        return _calculateDelegatorRewards(pool, debt);
    }

    /// @notice Get pending operator commission
    function pendingOperatorCommission(address asset, address operator) external view returns (uint256) {
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

    /// @notice Return vault summary for UI dashboards
    function getVaultSummary(address asset) public view returns (VaultSummary memory) {
        VaultConfig storage config = vaultConfigs[asset];
        if (config.depositCap == 0) revert VaultNotFound(asset);

        VaultState storage state = vaultStates[asset];
        uint256 depositCapRemaining =
            state.totalDeposits >= config.depositCap ? 0 : config.depositCap - state.totalDeposits;
        uint256 utilizationBps = (state.totalDeposits * BPS_DENOMINATOR) / config.depositCap;

        return VaultSummary({
            asset: asset,
            depositCap: config.depositCap,
            active: config.active,
            totalDeposits: state.totalDeposits,
            totalScore: state.totalScore,
            rewardsDistributed: state.rewardsDistributed,
            depositCapRemaining: depositCapRemaining,
            utilizationBps: utilizationBps
        });
    }

    /// @notice Return summaries for all vaults (expensive if many vaults)
    function getAllVaultSummaries() external view returns (VaultSummary[] memory summaries) {
        summaries = new VaultSummary[](vaultAssets.length);
        for (uint256 i = 0; i < vaultAssets.length; i++) {
            summaries[i] = getVaultSummary(vaultAssets[i]);
        }
    }

    /// @notice Return operators a delegator is currently staked with
    function getDelegatorOperators(address asset, address delegator) external view returns (address[] memory) {
        address[] storage operators = delegatorOperators[asset][delegator];
        address[] memory copy = new address[](operators.length);
        for (uint256 i = 0; i < operators.length; i++) {
            copy[i] = operators[i];
        }
        return copy;
    }

    /// @notice Inspect delegator positions including pending rewards for each operator
    function getDelegatorPositions(
        address asset,
        address delegator
    )
        external
        view
        returns (DelegatorPosition[] memory positions)
    {
        address[] storage operators = delegatorOperators[asset][delegator];
        positions = new DelegatorPosition[](operators.length);
        for (uint256 i = 0; i < operators.length; i++) {
            address operator = operators[i];
            DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
            OperatorPool storage pool = operatorPools[asset][operator];
            positions[i] = DelegatorPosition({
                operator: operator,
                stakedAmount: debt.stakedAmount,
                boostedScore: debt.boostedScore,
                lockDuration: debt.lockDuration,
                lockExpiry: debt.lockExpiry,
                pendingRewards: _calculateDelegatorRewards(pool, debt)
            });
        }
    }

    /// @notice Return pending rewards for all operators a delegator is staked to
    function pendingDelegatorRewardsAll(
        address asset,
        address delegator
    )
        external
        view
        returns (PendingRewardsView[] memory rewards, uint256 totalPending)
    {
        address[] storage operators = delegatorOperators[asset][delegator];
        rewards = new PendingRewardsView[](operators.length);

        for (uint256 i = 0; i < operators.length; i++) {
            address operator = operators[i];
            OperatorPool storage pool = operatorPools[asset][operator];
            DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
            uint256 pending = _calculateDelegatorRewards(pool, debt);

            rewards[i] = PendingRewardsView({ operator: operator, amount: pending });
            totalPending += pending;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADES
    // ═══════════════════════════════════════════════════════════════════════════

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) { }
}
