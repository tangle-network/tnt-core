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

    /// @notice Hard cap on the vault operator commission (20%).
    uint16 public constant MAX_COMMISSION_BPS = 2000;

    /// @notice Timelock on a commission INCREASE (7 days). Decreases apply immediately.
    uint64 public constant COMMISSION_TIMELOCK = 7 days;

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
        // Rewards accrued at the position's prior boostedScore that have been settled
        // (snapshotted out of the per-share rate) but not yet transferred. MasterChef
        // requires settling pending before mutating boostedScore; without an external
        // transfer (recordDelegate is called via swallowed try/catch) we bank the
        // settled amount here and pay it on claim. Appended last for upgrade safety:
        // existing positions read 0, the correct "no credit yet" default.
        uint256 accruedRewards;
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

    /// @notice Pending commission INCREASE awaiting the timelock (0 = none queued).
    uint16 internal _pendingCommissionBps;
    /// @notice Timestamp after which a queued commission increase may be executed (0 = none).
    uint64 internal _commissionExecuteAfter;

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
    event CommissionIncreaseQueued(uint16 newBps, uint64 executeAfter);
    event CommissionIncreaseCancelled(uint16 cancelledBps);
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
    /// @notice claimDelegatorRewardsFor restricts who may force-realize a position's rewards.
    error NotAuthorizedClaimer(address caller, address delegator);

    /// @notice Emitted when an expired lock's reward boost is lazily decayed back to base weight.
    event LockBoostDecayed(
        address indexed asset, address indexed delegator, address indexed operator, uint256 oldScore, uint256 newScore
    );
    /// @notice Emitted when a pool reward cannot be credited to delegators (no staked
    ///         score) and is parked in the operator's pending commission instead of dropped.
    event UnattributedRewardParked(address indexed asset, address indexed operator, uint256 amount);

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

        require(_operatorCommissionBps <= MAX_COMMISSION_BPS, "Commission exceeds cap");
        tntToken = TangleToken(_tntToken);
        operatorCommissionBps = _operatorCommissionBps;

        // Lock-duration defaults. These MUST be set here, not via inline field initializers:
        // this is a UUPS-proxied contract, so field initializers (which run only in the
        // constructor) never execute behind the proxy and would leave these at 0 — making
        // every lock-multiplier boost decay instantly (0-second lock). Admin can retune via
        // setLockDurations.
        lockDurationOneMonth = 30 days;
        lockDurationTwoMonths = 60 days;
        lockDurationThreeMonths = 90 days;
        lockDurationSixMonths = 180 days;
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

    /// @notice Change the operator commission rate (capped at MAX_COMMISSION_BPS = 20%).
    /// @dev A DECREASE (or no-op) only benefits delegators and applies immediately,
    ///      cancelling any queued increase. An INCREASE is queued behind
    ///      COMMISSION_TIMELOCK (7 days) so delegators get notice before a higher
    ///      commission binds; apply it with `executeCommissionIncrease`. This removes the
    ///      previous one-tx, uncapped-at-50% spike primitive.
    function setOperatorCommission(uint16 newBps) external onlyRole(ADMIN_ROLE) {
        require(newBps <= MAX_COMMISSION_BPS, "Commission exceeds cap");
        if (newBps <= operatorCommissionBps) {
            operatorCommissionBps = newBps;
            _pendingCommissionBps = 0;
            _commissionExecuteAfter = 0;
            emit OperatorCommissionUpdated(newBps);
            return;
        }
        _pendingCommissionBps = newBps;
        _commissionExecuteAfter = uint64(block.timestamp) + COMMISSION_TIMELOCK;
        emit CommissionIncreaseQueued(newBps, _commissionExecuteAfter);
    }

    /// @notice Execute a queued commission increase after its timelock elapses.
    function executeCommissionIncrease() external onlyRole(ADMIN_ROLE) {
        require(_commissionExecuteAfter != 0, "No pending increase");
        require(block.timestamp >= _commissionExecuteAfter, "Timelock not elapsed");
        uint16 newBps = _pendingCommissionBps;
        _pendingCommissionBps = 0;
        _commissionExecuteAfter = 0;
        operatorCommissionBps = newBps;
        emit OperatorCommissionUpdated(newBps);
    }

    /// @notice Cancel a queued commission increase.
    function cancelCommissionIncrease() external onlyRole(ADMIN_ROLE) {
        require(_commissionExecuteAfter != 0, "No pending increase");
        uint16 cancelled = _pendingCommissionBps;
        _pendingCommissionBps = 0;
        _commissionExecuteAfter = 0;
        emit CommissionIncreaseCancelled(cancelled);
    }

    /// @notice View a queued commission increase (0,0 if none).
    function getPendingCommissionIncrease() external view returns (uint16 pendingBps, uint64 executeAfter) {
        return (_pendingCommissionBps, _commissionExecuteAfter);
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
        OperatorPool storage pool = operatorPools[asset][operator];
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        bool isNewDelegator = debt.stakedAmount == 0;
        if (isNewDelegator) {
            debt.lastAccumulatedPerShare = pool.accumulatedPerShare;
        } else {
            // Top-up on an existing position. If its prior lock already expired, collapse
            // the stale boost to base weight first (this also settles pending) so the
            // expired boost cannot persist or compound onto the new stake. Otherwise just
            // harvest rewards accrued to the EXISTING boostedScore before it grows, so the
            // added stake cannot retroactively earn prior-epoch rewards.
            if (!_decayExpiredLock(asset, delegator, operator, pool, debt)) {
                _settle(pool, debt);
            }
        }
        debt.stakedAmount += amount;
        debt.boostedScore += score;

        // A lock-multiplier boost MUST carry a matching lock commitment. Map the boost
        // bps to a lock duration and stamp the longest applicable lockExpiry; never
        // shorten an existing, still-active lock (a top-up cannot unlock prior stake).
        LockDuration lock = _lockDurationFromBps(lockMultiplierBps);
        if (lock != LockDuration.None) {
            uint256 newExpiry = block.timestamp + _lockDurationSeconds(lock);
            if (newExpiry > debt.lockExpiry) {
                debt.lockExpiry = newExpiry;
                debt.lockDuration = lock;
            }
        } else if (isNewDelegator) {
            // Fresh unboosted position: no lock. Existing positions keep any prior lock.
            debt.lockDuration = LockDuration.None;
            debt.lockExpiry = 0;
        }

        if (isNewDelegator) {
            _trackDelegatorOperator(asset, delegator, operator);
        }

        // Update operator pool total (score-weighted)
        pool.totalStaked += score;

        emit StakeRecorded(asset, delegator, operator, amount, lock);
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
        OperatorPool storage pool = operatorPools[asset][operator];
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        if (debt.stakedAmount < amount) revert InsufficientStake();

        // If the lock already expired, collapse the boost to base weight first (also settles
        // pending). This keeps the removed proportion computed against the current (base)
        // weight and prevents a stale boost from lingering on the remaining stake. If no
        // decay applies, just harvest rewards accrued to the current boostedScore before it
        // shrinks, so the departing stake's already-earned rewards are banked (not forfeited
        // by the smaller post-unstake score).
        if (!_decayExpiredLock(asset, delegator, operator, pool, debt)) {
            _settle(pool, debt);
        }

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
        if (pool.totalStaked < score) revert InsufficientStake();
        pool.totalStaked -= score;

        // F8: prune the operator from the epoch-distribution fan-out list once its pool is
        // fully unwound, so the loop in `distributeEpochReward` cannot grow without bound.
        if (pool.totalStaked == 0) {
            _untrackOperator(asset, operator);
        }

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
        } else {
            // Top-up on an existing position. Collapse an already-expired lock boost to base
            // weight first (also settles pending) so a stale boost cannot persist; otherwise
            // harvest rewards accrued to the EXISTING boostedScore before it grows, so the
            // added stake cannot retroactively earn prior-epoch rewards.
            if (!_decayExpiredLock(asset, delegator, operator, pool, debt)) {
                _settle(pool, debt);
            }
        }
        debt.stakedAmount += amount;
        // A lock boost MUST carry a matching lock commitment, and a top-up must never
        // SHORTEN an existing active lock. Stamp the longest applicable expiry.
        if (lock != LockDuration.None) {
            uint256 newExpiry = block.timestamp + _lockDurationSeconds(lock);
            if (newExpiry > debt.lockExpiry) {
                debt.lockExpiry = newExpiry;
                debt.lockDuration = lock;
            }
        } else if (isNewDelegator) {
            debt.lockDuration = LockDuration.None;
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

        // Update operator pool
        OperatorPool storage pool = operatorPools[asset][operator];

        // Past the StillLocked guard the lock has necessarily expired, so collapse the boost
        // to base weight first (also settles pending). If no decay applies, just harvest
        // rewards accrued to the current boostedScore before it shrinks, so the departing
        // stake's already-earned rewards are banked (not forfeited by the smaller
        // post-unstake score).
        if (!_decayExpiredLock(asset, delegator, operator, pool, debt)) {
            _settle(pool, debt);
        }

        // Update vault state
        VaultState storage state = vaultStates[asset];
        uint256 score = debt.boostedScore == 0
            ? _calculateScore(amount, debt.lockDuration)
            : (debt.boostedScore * amount) / debt.stakedAmount;
        state.totalDeposits -= amount;
        state.totalScore -= score;

        // Update operator pool total (score-weighted)
        if (pool.totalStaked < score) revert InsufficientStake();
        pool.totalStaked -= score;

        // F8: prune the operator from the epoch-distribution fan-out list once its pool is
        // fully unwound, so the loop in `distributeEpochReward` cannot grow without bound.
        if (pool.totalStaked == 0) {
            _untrackOperator(asset, operator);
        }

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
        // Restrict who may force-realize a position's rewards. Funds always go to
        // `delegator` (no theft is possible), but an unrestricted force-claim lets any
        // address dictate the timing of another account's reward realization (resetting
        // their accrual snapshot, fixing a tax/cost-basis event, etc.). Only the position
        // owner or the protocol's rewards manager (the on-chain caller wiring) may trigger
        // it. Fail-closed: anyone else reverts.
        if (msg.sender != delegator && !hasRole(REWARDS_MANAGER_ROLE, msg.sender)) {
            revert NotAuthorizedClaimer(msg.sender, delegator);
        }
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
        assetOperatorIndex[asset][operator] = assetOperators[asset].length; // index + 1
    }

    /// @notice Remove an operator from `assetOperators[asset]` once its stake fully unwinds (F8).
    /// @dev Swap-and-pop, mirroring `_untrackDelegatorOperator`. The operator's accumulator state
    ///      in `operatorPools` is left intact, so a later re-stake re-tracks it safely and any
    ///      `pendingCommission` remains claimable independently of this membership list.
    function _untrackOperator(address asset, address operator) internal {
        uint256 indexPlusOne = assetOperatorIndex[asset][operator];
        if (indexPlusOne == 0) return;

        address[] storage operators = assetOperators[asset];
        uint256 index = indexPlusOne - 1;
        uint256 lastIndex = operators.length - 1;

        if (index != lastIndex) {
            address lastOperator = operators[lastIndex];
            operators[index] = lastOperator;
            assetOperatorIndex[asset][lastOperator] = index + 1;
        }

        operators.pop();
        assetOperatorIndex[asset][operator] = 0;
        isAssetOperator[asset][operator] = false;
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

        if (poolReward > 0) {
            if (pool.totalStaked > 0) {
                pool.accumulatedPerShare += (poolReward * PRECISION) / pool.totalStaked;
            } else {
                // No delegator score to credit: advancing accumulatedPerShare would divide
                // by zero and silently drop poolReward (delegators joining later cannot
                // recover it because the per-share rate never moved). Park it in the
                // operator's pending commission so the funds stay attributable and the
                // vault's accounted (rewardsDistributed) reward equals what was actually
                // assigned to a claimable bucket. Fail-closed: nothing is burned.
                pool.pendingCommission += poolReward;
                emit UnattributedRewardParked(asset, operator, poolReward);
            }
        }

        vaultStates[asset].rewardsDistributed += amount;

        emit RewardsDistributed(asset, operator, poolReward, commission);
    }

    /// @notice Calculate delegator rewards owed (banked credit + unsettled accrual)
    function _calculateDelegatorRewards(
        OperatorPool storage pool,
        DelegatorDebt storage debt
    )
        internal
        view
        returns (uint256)
    {
        uint256 accumulatedDiff = pool.accumulatedPerShare - debt.lastAccumulatedPerShare;
        // Use the decay-aware effective score: an expired lock accrues only at base weight,
        // so the unsettled portion (rewards minted since the last snapshot) is valued at the
        // weight a claim would settle at — never the stale boosted weight.
        return debt.accruedRewards + (_effectiveScore(debt) * accumulatedDiff) / PRECISION;
    }

    /// @notice Settle a position's pending rewards before its boostedScore changes.
    /// @dev INVARIANT: boostedScore must NEVER be mutated (top-up or partial unstake)
    ///      without first banking the rewards already accrued to the OLD boostedScore and
    ///      advancing lastAccumulatedPerShare to the current per-share rate. Otherwise the
    ///      new score retroactively earns (or forfeits) rewards from epochs it did not
    ///      participate in — the MasterChef "harvest before resize" rule. We bank into
    ///      accruedRewards (no external transfer) because the live caller wraps this in a
    ///      swallowed try/catch and a failed payout would silently skip settlement.
    function _settle(OperatorPool storage pool, DelegatorDebt storage debt) internal {
        uint256 accumulatedDiff = pool.accumulatedPerShare - debt.lastAccumulatedPerShare;
        if (accumulatedDiff != 0 && debt.boostedScore != 0) {
            debt.accruedRewards += (debt.boostedScore * accumulatedDiff) / PRECISION;
        }
        debt.lastAccumulatedPerShare = pool.accumulatedPerShare;
    }

    /// @notice Lazily decay an expired lock's reward boost back to the position's base
    ///         (unboosted) weight.
    /// @dev ROOT CAUSE FIX (lock boost was permanent): the lock multiplier is the *price*
    ///      of a time commitment. Once `lockExpiry` passes, the commitment is over, so the
    ///      boosted weight MUST collapse to the raw stake — otherwise a delegator who
    ///      locked once keeps siphoning a higher share of every future epoch forever while
    ///      bearing no remaining lock risk. We settle pending rewards FIRST (harvest-before-
    ///      resize invariant — see `_settle`) so the decay never retroactively claws back
    ///      rewards already earned during the lock; it only changes the weight applied to
    ///      FUTURE epochs. The base weight is `stakedAmount` (1.0x), matching how a
    ///      `LockDuration.None` position is scored. Returns true if a decay was applied.
    function _decayExpiredLock(
        address asset,
        address delegator,
        address operator,
        OperatorPool storage pool,
        DelegatorDebt storage debt
    )
        internal
        returns (bool)
    {
        if (debt.lockExpiry == 0 || block.timestamp < debt.lockExpiry) return false;
        // Base weight for an unboosted position is the raw stake. If the score is already
        // at (or below) base there is nothing to decay.
        if (debt.boostedScore <= debt.stakedAmount) {
            // Lock has expired with no remaining boost: clear the stale lock metadata so the
            // position reads as unlocked.
            debt.lockDuration = LockDuration.None;
            debt.lockExpiry = 0;
            return false;
        }

        // Harvest before resize so rewards accrued at the boosted weight stay banked.
        _settle(pool, debt);

        uint256 oldScore = debt.boostedScore;
        uint256 newScore = debt.stakedAmount;
        uint256 delta = oldScore - newScore;

        debt.boostedScore = newScore;
        debt.lockDuration = LockDuration.None;
        debt.lockExpiry = 0;

        // Keep the pool- and vault-level score aggregates in lockstep with the position.
        if (pool.totalStaked >= delta) {
            pool.totalStaked -= delta;
        } else {
            pool.totalStaked = 0;
        }
        VaultState storage state = vaultStates[asset];
        if (state.totalScore >= delta) {
            state.totalScore -= delta;
        } else {
            state.totalScore = 0;
        }

        emit LockBoostDecayed(asset, delegator, operator, oldScore, newScore);
        return true;
    }

    /// @notice Permissionlessly collapse a position's expired lock-multiplier boost back to base weight.
    /// @dev Mirrors `ServiceFeeDistributor.settleExpiredLock`. The lazy `_decayExpiredLock` otherwise
    ///      only runs on the locker's OWN claim/stake/unstake, so an idle locker keeps earning the
    ///      (up to 1.6x) boosted share of every epoch after `lockExpiry` — `_distributeToOperatorPool`
    ///      keeps advancing `accumulatedPerShare` against a `totalStaked` that still carries the stale
    ///      `boostedScore` — diluting honest delegators until the locker chooses to transact. This lets
    ///      any diluted co-delegator or keeper force the collapse. No-op (via `_decayExpiredLock`) when
    ///      the lock is absent, not yet expired, or already at base weight; idempotent.
    /// @return applied True if a boost was actually decayed; false on every no-op path, so a keeper
    ///         learns whether the poke did anything without having to re-read storage.
    function settleExpiredLock(
        address asset,
        address delegator,
        address operator
    )
        external
        nonReentrant
        returns (bool applied)
    {
        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        // Cheap short-circuit: for an absent or not-yet-expired lock there is nothing to decay and
        // `_decayExpiredLock` would return at its first guard anyway. Checking the debt slot (already
        // needed) first lets us skip the cold `operatorPools[asset][operator]` SLOAD on that common
        // no-op poke against a non-existent/active position.
        if (debt.lockExpiry == 0 || block.timestamp < debt.lockExpiry) return false;
        OperatorPool storage pool = operatorPools[asset][operator];
        return _decayExpiredLock(asset, delegator, operator, pool, debt);
    }

    /// @notice Effective (decay-aware) boosted score for views, without mutating storage.
    /// @dev Mirrors `_decayExpiredLock`: once the lock has expired the position earns only
    ///      its base weight (`stakedAmount`). View functions must report the same weight a
    ///      claim would settle at, so pending-reward dashboards do not over-promise a boost
    ///      the next claim will strip.
    function _effectiveScore(DelegatorDebt storage debt) internal view returns (uint256) {
        if (debt.lockExpiry != 0 && block.timestamp >= debt.lockExpiry && debt.boostedScore > debt.stakedAmount) {
            return debt.stakedAmount;
        }
        return debt.boostedScore;
    }

    /// @notice Shared implementation for delegator reward claims
    function _claimDelegatorReward(address delegator, address asset, address operator) internal returns (uint256) {
        if (vaultConfigs[asset].depositCap == 0) revert VaultNotFound(asset);

        DelegatorDebt storage debt = delegatorDebts[asset][delegator][operator];
        OperatorPool storage pool = operatorPools[asset][operator];

        // Lazily collapse an expired lock's boost to base weight before settling, so a
        // claim never pays out more than the position is currently entitled to and future
        // accrual happens at the unboosted weight.
        _decayExpiredLock(asset, delegator, operator, pool, debt);

        uint256 owed = _calculateDelegatorRewards(pool, debt);
        if (owed == 0) {
            return 0;
        }

        debt.lastAccumulatedPerShare = pool.accumulatedPerShare;
        debt.accruedRewards = 0;
        _transferRewards(delegator, owed);

        emit DelegatorRewardsClaimed(asset, delegator, operator, owed);
        return owed;
    }

    /// @notice Calculate weighted score for stake
    function _calculateScore(uint256 amount, LockDuration lock) internal pure returns (uint256) {
        uint256 multiplierBps = _lockMultiplierBps(lock);
        return (amount * multiplierBps) / BPS_DENOMINATOR;
    }

    /// @notice Map an inbound lock-multiplier (bps) to the lock duration that earns it.
    /// @dev Inverse of `_lockMultiplierBps`. The live recordDelegate path only forwards a
    ///      raw multiplier, so we recover the commitment tier it implies and snap any
    ///      in-between value DOWN to the nearest tier (you only get the lock you commit to).
    function _lockDurationFromBps(uint16 lockMultiplierBps) internal pure returns (LockDuration) {
        if (lockMultiplierBps >= 16_000) return LockDuration.SixMonths;
        if (lockMultiplierBps >= 13_000) return LockDuration.ThreeMonths;
        if (lockMultiplierBps >= 12_000) return LockDuration.TwoMonths;
        if (lockMultiplierBps >= 11_000) return LockDuration.OneMonth;
        return LockDuration.None;
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

    /// @notice Index (+1) of an operator inside `assetOperators[asset]` for O(1) removal (F8).
    /// @dev Appended at the end of storage (gap shrunk 50 -> 49) to stay upgrade-safe. Lets
    ///      `_untrackOperator` swap-and-pop an operator whose stake fully unwound, so the
    ///      epoch-distribution loop over `assetOperators` cannot grow unbounded with dead
    ///      entries and eventually exceed the block gas limit.
    mapping(address => mapping(address => uint256)) private assetOperatorIndex;

    /// @dev Reserved storage slots for future upgrades (Round 2 storage F-3). Shrunk 50 -> 49
    ///      when `assetOperatorIndex` was appended (F8).
    uint256[49] private __gap;
}
