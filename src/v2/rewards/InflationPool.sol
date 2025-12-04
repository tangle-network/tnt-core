// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { TangleMetrics } from "./TangleMetrics.sol";
import { RewardVaults } from "./RewardVaults.sol";

/// @title InflationPool
/// @notice Pre-funded reward distribution pool for TNT inflation
/// @dev Receives tokens from treasury/governance and distributes them over time.
///
/// Key Design Principles:
/// - NO MINTING: This contract cannot mint tokens. It can only distribute what it holds.
/// - PRE-FUNDED: Governance/treasury funds this pool with yearly inflation allocation.
/// - RISK ISOLATION: If this contract has a bug, attacker can only steal pool balance.
/// - REPLACEABLE: Governance can deploy new pool and move remaining funds if needed.
///
/// Architecture:
/// - Treasury funds pool with yearly TNT allocation (e.g., 1% of supply)
/// - Pool distributes across stakeholder categories with configurable weights
/// - Uses TangleMetrics for merit-based operator/customer scoring
/// - Epoch-based distribution that streams rewards over time
///
/// Migration Path:
/// - If bugs are found, deploy InflationPool v2
/// - Governance calls emergencyWithdraw() to move remaining funds to new pool
/// - Token holders are unaffected - their TNT is safe
contract InflationPool is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");
    bytes32 public constant FUNDER_ROLE = keccak256("FUNDER_ROLE");

    uint256 public constant BPS_DENOMINATOR = 10000;
    uint256 public constant PRECISION = 1e18;

    /// @notice Blocks per year (assuming ~12s blocks)
    uint256 public constant BLOCKS_PER_YEAR = 2_628_000;

    // ═══════════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribution weights for inflation allocation
    struct DistributionWeights {
        uint16 stakingBps;      // Stakers/delegators (e.g., 5000 = 50%)
        uint16 operatorsBps;    // Operator performance (e.g., 2500 = 25%)
        uint16 customersBps;    // Service usage (e.g., 1000 = 10%)
        uint16 developersBps;   // Blueprint developers (e.g., 1500 = 15%)
    }

    /// @notice Epoch tracking data
    struct EpochData {
        uint256 number;
        uint256 startBlock;
        uint256 endBlock;
        uint256 stakingDistributed;
        uint256 operatorsDistributed;
        uint256 customersDistributed;
        uint256 developersDistributed;
        bool distributed;
    }

    /// @notice Funding event data
    struct FundingRecord {
        uint256 amount;
        uint256 timestamp;
        uint256 blockNumber;
        address funder;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice TNT token (for transfers, NOT minting)
    IERC20 public tntToken;

    /// @notice Metrics contract for activity data
    TangleMetrics public metrics;

    /// @notice Reward vaults for staking distribution
    RewardVaults public vaults;

    /// @notice Distribution weights
    DistributionWeights public weights;

    /// @notice Blocks per epoch (e.g., 50400 = ~1 week)
    uint256 public epochLength;

    /// @notice Current epoch number
    uint256 public currentEpoch;

    /// @notice Block when current funding period started
    uint256 public fundingPeriodStartBlock;

    /// @notice Total distributed this funding period
    uint256 public distributedThisPeriod;

    /// @notice Budget for current funding period (set when funded)
    uint256 public periodBudget;

    /// @notice Epoch data history: epoch => data
    mapping(uint256 => EpochData) public epochs;

    /// @notice Pending rewards per account (for customers)
    mapping(address => uint256) public pendingCustomerRewards;

    /// @notice Pending rewards per operator (for operator performance)
    mapping(address => uint256) public pendingOperatorRewards;

    /// @notice Last epoch an operator was scored
    mapping(address => uint256) public operatorLastScoredEpoch;

    /// @notice Operators list for iteration
    address[] public trackedOperators;
    mapping(address => bool) public isTrackedOperator;

    /// @notice Customers list for iteration
    address[] public trackedCustomers;
    mapping(address => bool) public isTrackedCustomer;

    /// @notice Pending rewards per developer
    mapping(address => uint256) public pendingDeveloperRewards;

    /// @notice Developers list for iteration
    address[] public trackedDevelopers;
    mapping(address => bool) public isTrackedDeveloper;

    /// @notice Funding history
    FundingRecord[] public fundingHistory;

    /// @notice Total ever funded to this pool
    uint256 public totalFunded;

    /// @notice Total ever distributed from this pool
    uint256 public totalDistributed;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event PoolFunded(address indexed funder, uint256 amount, uint256 newBalance);
    event EpochDistributed(
        uint256 indexed epoch,
        uint256 stakingAmount,
        uint256 operatorsAmount,
        uint256 customersAmount,
        uint256 totalDistributed
    );
    event WeightsUpdated(uint16 stakingBps, uint16 operatorsBps, uint16 customersBps, uint16 developersBps);
    event EpochLengthUpdated(uint256 newLength);
    event OperatorRewardClaimed(address indexed operator, uint256 amount);
    event CustomerRewardClaimed(address indexed customer, uint256 amount);
    event DeveloperRewardClaimed(address indexed developer, uint256 amount);
    event EmergencyWithdraw(address indexed to, uint256 amount);
    event FundingPeriodReset(uint256 newPeriodStartBlock, uint256 previousPeriodDistributed);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidWeights();
    error EpochNotReady();
    error EpochAlreadyDistributed();
    error NoRewardsToClaim();
    error InsufficientPoolBalance();
    error InvalidEpochLength();
    error ZeroAmount();
    error ZeroAddress();

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the inflation pool
    /// @param admin Admin address
    /// @param _tntToken TNT token address
    /// @param _metrics Metrics contract address
    /// @param _vaults Reward vaults address
    /// @param _epochLength Blocks per epoch
    function initialize(
        address admin,
        address _tntToken,
        address _metrics,
        address _vaults,
        uint256 _epochLength
    ) external initializer {
        if (admin == address(0)) revert ZeroAddress();
        if (_tntToken == address(0)) revert ZeroAddress();

        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(DISTRIBUTOR_ROLE, admin);
        _grantRole(FUNDER_ROLE, admin);

        tntToken = IERC20(_tntToken);
        if (_metrics != address(0)) metrics = TangleMetrics(_metrics);
        if (_vaults != address(0)) vaults = RewardVaults(_vaults);

        epochLength = _epochLength;

        // Default weights: 50% staking, 25% operators, 10% customers, 15% developers
        weights = DistributionWeights({
            stakingBps: 5000,
            operatorsBps: 2500,
            customersBps: 1000,
            developersBps: 1500
        });

        // Initialize first epoch
        currentEpoch = 1;
        fundingPeriodStartBlock = block.number;

        epochs[1] = EpochData({
            number: 1,
            startBlock: block.number,
            endBlock: block.number + _epochLength,
            stakingDistributed: 0,
            operatorsDistributed: 0,
            customersDistributed: 0,
            developersDistributed: 0,
            distributed: false
        });
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNDING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fund the pool with TNT tokens
    /// @dev Called by governance/treasury to add inflation allocation
    /// @param amount Amount of TNT to add to the pool
    function fund(uint256 amount) external onlyRole(FUNDER_ROLE) {
        if (amount == 0) revert ZeroAmount();

        // Transfer tokens from funder to this pool
        tntToken.safeTransferFrom(msg.sender, address(this), amount);

        // Update period budget (additive - governance can top up)
        periodBudget += amount;
        totalFunded += amount;

        // Record funding
        fundingHistory.push(FundingRecord({
            amount: amount,
            timestamp: block.timestamp,
            blockNumber: block.number,
            funder: msg.sender
        }));

        emit PoolFunded(msg.sender, amount, poolBalance());
    }

    /// @notice Start a new funding period (resets distribution tracking)
    /// @dev Called when governance funds for a new year/period
    function resetFundingPeriod() external onlyRole(ADMIN_ROLE) {
        emit FundingPeriodReset(block.number, distributedThisPeriod);

        fundingPeriodStartBlock = block.number;
        distributedThisPeriod = 0;
        periodBudget = poolBalance(); // Remaining balance becomes new period budget
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EPOCH DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute rewards for current epoch
    /// @dev Can be called by anyone once epoch is complete
    function distributeEpoch() external nonReentrant {
        EpochData storage epoch = epochs[currentEpoch];

        if (block.number < epoch.endBlock) revert EpochNotReady();
        if (epoch.distributed) revert EpochAlreadyDistributed();

        // Check if we need to reset funding period (yearly)
        if (block.number >= fundingPeriodStartBlock + BLOCKS_PER_YEAR) {
            _resetFundingPeriod();
        }

        // Calculate epoch budget based on pool balance
        uint256 epochBudget = calculateEpochBudget();

        // Can only distribute what we have
        uint256 available = poolBalance();
        if (epochBudget > available) {
            epochBudget = available;
        }

        if (epochBudget == 0) {
            // No funds available, just advance epoch
            _advanceEpoch(0, 0, 0, 0);
            return;
        }

        // Calculate target distribution amounts
        uint256 stakingTarget = (epochBudget * weights.stakingBps) / BPS_DENOMINATOR;
        uint256 operatorsTarget = (epochBudget * weights.operatorsBps) / BPS_DENOMINATOR;
        uint256 customersTarget = (epochBudget * weights.customersBps) / BPS_DENOMINATOR;
        uint256 developersTarget = epochBudget - stakingTarget - operatorsTarget - customersTarget;

        // Distribute to each category
        uint256 stakingActual = _distributeStakingRewards(stakingTarget);
        uint256 operatorsActual = _distributeOperatorRewards(operatorsTarget);
        uint256 customersActual = _distributeCustomerRewards(customersTarget);
        uint256 developersActual = _distributeDeveloperRewards(developersTarget);

        // Handle undistributed amounts
        uint256 undistributed = (stakingTarget - stakingActual) +
                                (operatorsTarget - operatorsActual) +
                                (customersTarget - customersActual) +
                                (developersTarget - developersActual);

        if (undistributed > 0) {
            bool hasStaking = stakingActual > 0;
            bool hasOperators = operatorsActual > 0;
            bool hasCustomers = customersActual > 0;
            bool hasDevelopers = developersActual > 0;

            if (hasStaking || hasOperators || hasCustomers || hasDevelopers) {
                (uint256 stakingExtra, uint256 operatorsExtra, uint256 customersExtra, uint256 developersExtra) =
                    _redistributeUndistributed(undistributed, hasStaking, hasOperators, hasCustomers, hasDevelopers);
                stakingActual += stakingExtra;
                operatorsActual += operatorsExtra;
                customersActual += customersExtra;
                developersActual += developersExtra;
            }
        }

        // Track distributed amount
        uint256 totalEpochDistributed = stakingActual + operatorsActual + customersActual + developersActual;
        distributedThisPeriod += totalEpochDistributed;
        totalDistributed += totalEpochDistributed;

        // Advance to next epoch
        _advanceEpoch(stakingActual, operatorsActual, customersActual, developersActual);

        emit EpochDistributed(
            currentEpoch - 1,
            stakingActual,
            operatorsActual,
            customersActual,
            totalEpochDistributed
        );
    }

    /// @notice Advance to next epoch
    function _advanceEpoch(
        uint256 stakingDistributed,
        uint256 operatorsDistributed,
        uint256 customersDistributed,
        uint256 developersDistributed
    ) internal {
        epochs[currentEpoch].distributed = true;
        epochs[currentEpoch].stakingDistributed = stakingDistributed;
        epochs[currentEpoch].operatorsDistributed = operatorsDistributed;
        epochs[currentEpoch].customersDistributed = customersDistributed;
        epochs[currentEpoch].developersDistributed = developersDistributed;

        currentEpoch++;
        epochs[currentEpoch] = EpochData({
            number: currentEpoch,
            startBlock: block.number,
            endBlock: block.number + epochLength,
            stakingDistributed: 0,
            operatorsDistributed: 0,
            customersDistributed: 0,
            developersDistributed: 0,
            distributed: false
        });
    }

    /// @notice Reset funding period tracking
    function _resetFundingPeriod() internal {
        emit FundingPeriodReset(block.number, distributedThisPeriod);
        fundingPeriodStartBlock = block.number;
        distributedThisPeriod = 0;
        periodBudget = poolBalance();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKING REWARDS DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute staking rewards across vaults
    /// @param amount Total amount to distribute
    /// @return actualDistributed The actual amount transferred
    function _distributeStakingRewards(uint256 amount) internal returns (uint256 actualDistributed) {
        if (amount == 0 || address(vaults) == address(0)) return 0;

        address[] memory assets = vaults.getVaultAssets();
        if (assets.length == 0) return 0;

        // Calculate total deposits across all vaults
        uint256 totalDeposits = 0;
        uint256[] memory deposits = new uint256[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            (uint256 vaultDeposits,,,) = vaults.vaultStates(assets[i]);
            deposits[i] = vaultDeposits;
            totalDeposits += vaultDeposits;
        }

        if (totalDeposits == 0) return 0;

        // Distribute proportionally to vault utilization
        for (uint256 i = 0; i < assets.length; i++) {
            if (deposits[i] == 0) continue;

            uint256 vaultShare = (amount * deposits[i]) / totalDeposits;
            if (vaultShare == 0) continue;

            // Transfer to vaults (NOT mint!)
            tntToken.safeTransfer(address(vaults), vaultShare);
            actualDistributed += vaultShare;

            // Notify vaults of the reward
            _notifyVaultReward(assets[i], vaultShare);
        }
    }

    /// @notice Notify vault of epoch staking reward
    function _notifyVaultReward(address asset, uint256 amount) internal {
        try vaults.distributeEpochReward(asset, amount) {} catch {}
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REWARDS DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute operator performance rewards
    /// @param amount Total amount to distribute
    /// @return distributed Actual amount distributed
    function _distributeOperatorRewards(uint256 amount) internal returns (uint256 distributed) {
        if (amount == 0 || trackedOperators.length == 0 || address(metrics) == address(0)) return 0;

        // Calculate scores for all operators
        uint256 totalScore = 0;
        uint256[] memory scores = new uint256[](trackedOperators.length);

        for (uint256 i = 0; i < trackedOperators.length; i++) {
            scores[i] = _calculateOperatorScore(trackedOperators[i]);
            totalScore += scores[i];
        }

        if (totalScore == 0) return 0;

        // Distribute proportionally to scores
        for (uint256 i = 0; i < trackedOperators.length; i++) {
            if (scores[i] == 0) continue;

            uint256 reward = (amount * scores[i]) / totalScore;
            if (reward > 0) {
                pendingOperatorRewards[trackedOperators[i]] += reward;
                distributed += reward;
            }
        }

        // Note: Tokens stay in this contract until claimed
        // No transfer here - just accounting
    }

    /// @notice Calculate operator score based on metrics
    function _calculateOperatorScore(address operator) internal view returns (uint256 score) {
        uint256 jobs = metrics.operatorJobsCompleted(operator);
        uint256 successfulJobs = metrics.operatorJobsSuccessful(operator);
        uint256 stake = metrics.operatorTotalStake(operator);
        uint256 heartbeats = metrics.operatorHeartbeats(operator);

        uint256 successRate = jobs > 0 ? (successfulJobs * BPS_DENOMINATOR) / jobs : 0;
        uint256 stakeWeight = _sqrt(stake / 1e18) * 1e9;

        uint256 jobScore = (jobs * successRate * stakeWeight) / BPS_DENOMINATOR;
        uint256 heartbeatBonus = heartbeats * stakeWeight / 100;

        score = jobScore + heartbeatBonus;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CUSTOMER REWARDS DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute customer activity rewards
    /// @param amount Total amount to distribute
    /// @return distributed Actual amount distributed
    function _distributeCustomerRewards(uint256 amount) internal returns (uint256 distributed) {
        if (amount == 0 || trackedCustomers.length == 0 || address(metrics) == address(0)) return 0;

        // Calculate total fees paid
        uint256 totalFees = 0;
        uint256[] memory fees = new uint256[](trackedCustomers.length);

        for (uint256 i = 0; i < trackedCustomers.length; i++) {
            fees[i] = metrics.totalFeesPaid(trackedCustomers[i]);
            totalFees += fees[i];
        }

        if (totalFees == 0) return 0;

        // Distribute proportionally to fees paid
        for (uint256 i = 0; i < trackedCustomers.length; i++) {
            if (fees[i] == 0) continue;

            uint256 reward = (amount * fees[i]) / totalFees;
            if (reward > 0) {
                pendingCustomerRewards[trackedCustomers[i]] += reward;
                distributed += reward;
            }
        }

        // Note: Tokens stay in this contract until claimed
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEVELOPER REWARDS DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute developer rewards based on blueprint metrics
    /// @param amount Total amount to distribute
    /// @return distributed Actual amount distributed
    function _distributeDeveloperRewards(uint256 amount) internal returns (uint256 distributed) {
        if (amount == 0 || trackedDevelopers.length == 0 || address(metrics) == address(0)) return 0;

        // Calculate scores for all developers based on their blueprint activity
        uint256 totalScore = 0;
        uint256[] memory scores = new uint256[](trackedDevelopers.length);

        for (uint256 i = 0; i < trackedDevelopers.length; i++) {
            scores[i] = _calculateDeveloperScore(trackedDevelopers[i]);
            totalScore += scores[i];
        }

        if (totalScore == 0) return 0;

        // Distribute proportionally to scores
        for (uint256 i = 0; i < trackedDevelopers.length; i++) {
            if (scores[i] == 0) continue;

            uint256 reward = (amount * scores[i]) / totalScore;
            if (reward > 0) {
                pendingDeveloperRewards[trackedDevelopers[i]] += reward;
                distributed += reward;
            }
        }

        // Note: Tokens stay in this contract until claimed
    }

    /// @notice Calculate developer score based on blueprint metrics
    /// @dev Score = (totalServices × 1000) + (totalJobs × 100) + sqrt(totalFees)
    function _calculateDeveloperScore(address developer) internal view returns (uint256 score) {
        // Get developer stats from metrics
        uint256 blueprintCount = metrics.developerBlueprintCount(developer);
        uint256 serviceCount = metrics.developerTotalServices(developer);
        uint256 jobCount = metrics.developerTotalJobs(developer);
        uint256 totalFees = metrics.developerTotalFees(developer);

        // Blueprint creation weight (encourage more blueprints)
        uint256 blueprintScore = blueprintCount * 500;

        // Service creation weight (usage of blueprints)
        uint256 serviceScore = serviceCount * 1000;

        // Job execution weight (actual usage)
        uint256 jobScore = jobCount * 100;

        // Fee generation weight (economic value, sqrt to prevent whale dominance)
        uint256 feeScore = _sqrt(totalFees / 1e18) * 1e9;

        score = blueprintScore + serviceScore + jobScore + feeScore;
    }

    /// @notice Redistribute undistributed amounts
    function _redistributeUndistributed(
        uint256 amount,
        bool hasStaking,
        bool hasOperators,
        bool hasCustomers,
        bool hasDevelopers
    ) internal returns (uint256 stakingExtra, uint256 operatorsExtra, uint256 customersExtra, uint256 developersExtra) {
        uint256 activeCount = 0;
        if (hasStaking) activeCount++;
        if (hasOperators) activeCount++;
        if (hasCustomers) activeCount++;
        if (hasDevelopers) activeCount++;

        if (activeCount == 0) return (0, 0, 0, 0);

        uint256 sharePerCategory = amount / activeCount;
        uint256 remainder = amount - (sharePerCategory * activeCount);

        if (hasOperators) {
            operatorsExtra = _distributeOperatorRewards(sharePerCategory);
        }
        if (hasCustomers) {
            customersExtra = _distributeCustomerRewards(sharePerCategory);
        }
        if (hasDevelopers) {
            developersExtra = _distributeDeveloperRewards(sharePerCategory + remainder);
            remainder = 0;
        }
        if (hasStaking) {
            stakingExtra = _distributeStakingRewards(sharePerCategory + remainder);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim pending operator rewards
    function claimOperatorRewards() external nonReentrant returns (uint256 amount) {
        amount = pendingOperatorRewards[msg.sender];
        if (amount == 0) revert NoRewardsToClaim();

        pendingOperatorRewards[msg.sender] = 0;
        tntToken.safeTransfer(msg.sender, amount);

        emit OperatorRewardClaimed(msg.sender, amount);
    }

    /// @notice Claim pending customer rewards
    function claimCustomerRewards() external nonReentrant returns (uint256 amount) {
        amount = pendingCustomerRewards[msg.sender];
        if (amount == 0) revert NoRewardsToClaim();

        pendingCustomerRewards[msg.sender] = 0;
        tntToken.safeTransfer(msg.sender, amount);

        emit CustomerRewardClaimed(msg.sender, amount);
    }

    /// @notice Claim pending developer rewards
    function claimDeveloperRewards() external nonReentrant returns (uint256 amount) {
        amount = pendingDeveloperRewards[msg.sender];
        if (amount == 0) revert NoRewardsToClaim();

        pendingDeveloperRewards[msg.sender] = 0;
        tntToken.safeTransfer(msg.sender, amount);

        emit DeveloperRewardClaimed(msg.sender, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TRACKING REGISTRATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register an operator for reward tracking
    function registerOperator(address operator) external onlyRole(ADMIN_ROLE) {
        if (!isTrackedOperator[operator]) {
            trackedOperators.push(operator);
            isTrackedOperator[operator] = true;
        }
    }

    /// @notice Register a customer for reward tracking
    function registerCustomer(address customer) external onlyRole(ADMIN_ROLE) {
        if (!isTrackedCustomer[customer]) {
            trackedCustomers.push(customer);
            isTrackedCustomer[customer] = true;
        }
    }

    /// @notice Batch register operators
    function registerOperators(address[] calldata operators) external onlyRole(ADMIN_ROLE) {
        for (uint256 i = 0; i < operators.length; i++) {
            if (!isTrackedOperator[operators[i]]) {
                trackedOperators.push(operators[i]);
                isTrackedOperator[operators[i]] = true;
            }
        }
    }

    /// @notice Batch register customers
    function registerCustomers(address[] calldata customers) external onlyRole(ADMIN_ROLE) {
        for (uint256 i = 0; i < customers.length; i++) {
            if (!isTrackedCustomer[customers[i]]) {
                trackedCustomers.push(customers[i]);
                isTrackedCustomer[customers[i]] = true;
            }
        }
    }

    /// @notice Register a developer for reward tracking
    function registerDeveloper(address developer) external onlyRole(ADMIN_ROLE) {
        if (!isTrackedDeveloper[developer]) {
            trackedDevelopers.push(developer);
            isTrackedDeveloper[developer] = true;
        }
    }

    /// @notice Batch register developers
    function registerDevelopers(address[] calldata developers) external onlyRole(ADMIN_ROLE) {
        for (uint256 i = 0; i < developers.length; i++) {
            if (!isTrackedDeveloper[developers[i]]) {
                trackedDevelopers.push(developers[i]);
                isTrackedDeveloper[developers[i]] = true;
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update distribution weights
    function setWeights(
        uint16 stakingBps,
        uint16 operatorsBps,
        uint16 customersBps,
        uint16 developersBps
    ) external onlyRole(ADMIN_ROLE) {
        if (stakingBps + operatorsBps + customersBps + developersBps != BPS_DENOMINATOR) {
            revert InvalidWeights();
        }

        weights = DistributionWeights({
            stakingBps: stakingBps,
            operatorsBps: operatorsBps,
            customersBps: customersBps,
            developersBps: developersBps
        });

        emit WeightsUpdated(stakingBps, operatorsBps, customersBps, developersBps);
    }

    /// @notice Update epoch length
    function setEpochLength(uint256 newLength) external onlyRole(ADMIN_ROLE) {
        if (newLength < 100 || newLength > BLOCKS_PER_YEAR) revert InvalidEpochLength();
        epochLength = newLength;
        emit EpochLengthUpdated(newLength);
    }

    /// @notice Update external contract references
    function setContracts(
        address _tntToken,
        address _metrics,
        address _vaults
    ) external onlyRole(ADMIN_ROLE) {
        if (_tntToken != address(0)) tntToken = IERC20(_tntToken);
        if (_metrics != address(0)) metrics = TangleMetrics(_metrics);
        if (_vaults != address(0)) vaults = RewardVaults(_vaults);
    }

    /// @notice Emergency withdraw all tokens to a new pool
    /// @dev Used when migrating to a new pool version
    function emergencyWithdraw(address to) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (to == address(0)) revert ZeroAddress();
        uint256 balance = poolBalance();
        if (balance > 0) {
            tntToken.safeTransfer(to, balance);
            emit EmergencyWithdraw(to, balance);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get current pool balance
    function poolBalance() public view returns (uint256) {
        return tntToken.balanceOf(address(this));
    }

    /// @notice Calculate per-epoch budget based on remaining pool balance
    function calculateEpochBudget() public view returns (uint256) {
        uint256 balance = poolBalance();
        if (balance == 0) return 0;

        // Calculate remaining epochs in the funding period
        uint256 blocksElapsed = block.number > fundingPeriodStartBlock
            ? block.number - fundingPeriodStartBlock
            : 0;
        uint256 blocksRemaining = BLOCKS_PER_YEAR > blocksElapsed
            ? BLOCKS_PER_YEAR - blocksElapsed
            : epochLength;

        uint256 epochsRemaining = blocksRemaining / epochLength;
        if (epochsRemaining == 0) epochsRemaining = 1;

        // Distribute remaining balance over remaining epochs
        return balance / epochsRemaining;
    }

    /// @notice Get remaining period budget
    function remainingPeriodBudget() external view returns (uint256) {
        return periodBudget > distributedThisPeriod ? periodBudget - distributedThisPeriod : 0;
    }

    /// @notice Get blocks until next epoch distribution
    function blocksUntilNextEpoch() external view returns (uint256) {
        EpochData storage epoch = epochs[currentEpoch];
        if (block.number >= epoch.endBlock) return 0;
        return epoch.endBlock - block.number;
    }

    /// @notice Check if epoch is ready for distribution
    function isEpochReady() external view returns (bool) {
        return block.number >= epochs[currentEpoch].endBlock &&
               !epochs[currentEpoch].distributed;
    }

    /// @notice Get current distribution weights
    function getWeights() external view returns (
        uint16 stakingBps,
        uint16 operatorsBps,
        uint16 customersBps,
        uint16 developersBps
    ) {
        return (weights.stakingBps, weights.operatorsBps, weights.customersBps, weights.developersBps);
    }

    /// @notice Get tracked operator count
    function trackedOperatorCount() external view returns (uint256) {
        return trackedOperators.length;
    }

    /// @notice Get tracked customer count
    function trackedCustomerCount() external view returns (uint256) {
        return trackedCustomers.length;
    }

    /// @notice Get tracked developer count
    function trackedDeveloperCount() external view returns (uint256) {
        return trackedDevelopers.length;
    }

    /// @notice Get epoch data
    function getEpoch(uint256 epochNumber) external view returns (EpochData memory) {
        return epochs[epochNumber];
    }

    /// @notice Get funding history count
    function fundingHistoryCount() external view returns (uint256) {
        return fundingHistory.length;
    }

    /// @notice Get funding record at index
    function getFundingRecord(uint256 index) external view returns (FundingRecord memory) {
        return fundingHistory[index];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Integer square root (Babylonian method)
    function _sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADES
    // ═══════════════════════════════════════════════════════════════════════════

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}
}
