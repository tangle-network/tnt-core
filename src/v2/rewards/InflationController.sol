// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { TangleToken } from "../governance/TangleToken.sol";
import { TangleMetrics } from "./TangleMetrics.sol";
import { RewardVaults } from "./RewardVaults.sol";

/// @title InflationController
/// @notice Controls TNT inflation with configurable distribution weights
/// @dev Epoch-based distribution that targets a fixed yearly inflation rate
///
/// Architecture:
/// - Tracks global inflation budget (e.g., 1% of supply/year)
/// - Distributes budget across stakeholder categories with configurable weights
/// - Pulls activity data from TangleMetrics for merit-based distribution
/// - Mints TNT within budget via MINTER_ROLE on TangleToken
contract InflationController is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    uint256 public constant BPS_DENOMINATOR = 10000;
    uint256 public constant PRECISION = 1e18;

    /// @notice Blocks per year (assuming ~12s blocks)
    uint256 public constant BLOCKS_PER_YEAR = 2_628_000;

    /// @notice Maximum TNT supply (must match TangleToken.MAX_SUPPLY)
    uint256 public constant MAX_SUPPLY = 100_000_000 * 1e18;

    // ═══════════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribution weights for inflation allocation
    struct DistributionWeights {
        uint16 stakingBps;      // Stakers/delegators (e.g., 6000 = 60%)
        uint16 operatorsBps;    // Operator performance (e.g., 2500 = 25%)
        uint16 customersBps;    // Service usage (e.g., 1500 = 15%)
    }

    /// @notice Epoch tracking data
    struct EpochData {
        uint256 number;
        uint256 startBlock;
        uint256 endBlock;
        uint256 stakingDistributed;
        uint256 operatorsDistributed;
        uint256 customersDistributed;
        bool distributed;
    }

    /// @notice Operator score for merit-based distribution
    struct OperatorScore {
        uint256 weightedJobs;       // jobs * stake
        uint256 heartbeatScore;     // recent heartbeats
        uint256 successRate;        // job success rate (bps)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice TNT token for minting rewards
    TangleToken public tntToken;

    /// @notice Metrics contract for activity data
    TangleMetrics public metrics;

    /// @notice Reward vaults for staking distribution
    RewardVaults public vaults;

    /// @notice Yearly inflation rate in basis points (e.g., 100 = 1%)
    uint16 public inflationBps;

    /// @notice Distribution weights
    DistributionWeights public weights;

    /// @notice Blocks per epoch (e.g., 50400 = ~1 week)
    uint256 public epochLength;

    /// @notice Current epoch number
    uint256 public currentEpoch;

    /// @notice Block when current year started (for yearly budget tracking)
    uint256 public yearStartBlock;

    /// @notice Total minted this year
    uint256 public mintedThisYear;

    /// @notice Yearly budget fixed at year start (prevents budget drift as supply grows)
    uint256 public yearlyBudgetFixed;

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

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event EpochDistributed(
        uint256 indexed epoch,
        uint256 stakingAmount,
        uint256 operatorsAmount,
        uint256 customersAmount,
        uint256 totalMinted
    );
    event WeightsUpdated(uint16 stakingBps, uint16 operatorsBps, uint16 customersBps);
    event InflationRateUpdated(uint16 newBps);
    event EpochLengthUpdated(uint256 newLength);
    event OperatorRewardClaimed(address indexed operator, uint256 amount);
    event CustomerRewardClaimed(address indexed customer, uint256 amount);
    event YearReset(uint256 newYearStartBlock, uint256 previousYearMinted);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error InvalidWeights();
    error EpochNotReady();
    error EpochAlreadyDistributed();
    error NoRewardsToClaim();
    error YearlyBudgetExceeded();
    error InvalidInflationRate();
    error InvalidEpochLength();

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the inflation controller
    /// @param admin Admin address
    /// @param _tntToken TNT token address
    /// @param _metrics Metrics contract address
    /// @param _vaults Reward vaults address
    /// @param _inflationBps Yearly inflation in bps (e.g., 100 = 1%)
    /// @param _epochLength Blocks per epoch
    function initialize(
        address admin,
        address _tntToken,
        address _metrics,
        address _vaults,
        uint16 _inflationBps,
        uint256 _epochLength
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(DISTRIBUTOR_ROLE, admin);

        tntToken = TangleToken(_tntToken);
        metrics = TangleMetrics(_metrics);
        vaults = RewardVaults(_vaults);

        inflationBps = _inflationBps;
        epochLength = _epochLength;

        // Default weights: 60% staking, 25% operators, 15% customers
        weights = DistributionWeights({
            stakingBps: 6000,
            operatorsBps: 2500,
            customersBps: 1500
        });

        // Initialize first epoch
        currentEpoch = 1;
        yearStartBlock = block.number;
        // Fix yearly budget at initialization
        yearlyBudgetFixed = (TangleToken(_tntToken).totalSupply() * _inflationBps) / BPS_DENOMINATOR;

        epochs[1] = EpochData({
            number: 1,
            startBlock: block.number,
            endBlock: block.number + _epochLength,
            stakingDistributed: 0,
            operatorsDistributed: 0,
            customersDistributed: 0,
            distributed: false
        });
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

        // Check if we need to reset year
        if (block.number >= yearStartBlock + BLOCKS_PER_YEAR) {
            _resetYear();
        }

        // Calculate epoch budget
        uint256 epochBudget = calculateEpochBudget();

        // Check yearly budget (use fixed budget to prevent drift)
        if (mintedThisYear + epochBudget > yearlyBudgetFixed) {
            epochBudget = yearlyBudgetFixed > mintedThisYear ? yearlyBudgetFixed - mintedThisYear : 0;
        }

        // Check MAX_SUPPLY - ensure we don't try to mint beyond the cap
        uint256 currentSupply = tntToken.totalSupply();
        uint256 remainingMintable = MAX_SUPPLY > currentSupply ? MAX_SUPPLY - currentSupply : 0;
        if (epochBudget > remainingMintable) {
            epochBudget = remainingMintable;
        }

        if (epochBudget == 0) {
            // Budget exhausted, just advance epoch
            _advanceEpoch(0, 0, 0);
            return;
        }

        // Calculate target distribution amounts
        uint256 stakingTarget = (epochBudget * weights.stakingBps) / BPS_DENOMINATOR;
        uint256 operatorsTarget = (epochBudget * weights.operatorsBps) / BPS_DENOMINATOR;
        uint256 customersTarget = epochBudget - stakingTarget - operatorsTarget;

        // First pass: distribute and check what can actually be received
        uint256 stakingActual = _distributeStakingRewards(stakingTarget);
        uint256 operatorsActual = _distributeOperatorRewards(operatorsTarget);
        uint256 customersActual = _distributeCustomerRewards(customersTarget);

        // Calculate undistributed amounts
        uint256 undistributed = (stakingTarget - stakingActual) +
                                (operatorsTarget - operatorsActual) +
                                (customersTarget - customersActual);

        // Redistribute undistributed portions to categories that can receive
        // Only check for active operators/customers if first pass returned 0
        if (undistributed > 0) {
            bool hasStaking = stakingActual > 0;
            bool hasOperators = operatorsActual > 0;
            bool hasCustomers = customersActual > 0;

            // Cap redistribution to not exceed epoch budget
            if (undistributed > epochBudget - stakingActual - operatorsActual - customersActual) {
                undistributed = epochBudget - stakingActual - operatorsActual - customersActual;
            }

            if (undistributed > 0) {
                (uint256 stakingExtra, uint256 operatorsExtra, uint256 customersExtra) = _redistributeUndistributed(
                    undistributed,
                    hasStaking,
                    hasOperators,
                    hasCustomers
                );
                stakingActual += stakingExtra;
                operatorsActual += operatorsExtra;
                customersActual += customersExtra;
            }
        }

        // Track ACTUAL minted amount (not planned)
        uint256 totalActualMinted = stakingActual + operatorsActual + customersActual;
        mintedThisYear += totalActualMinted;

        // Advance to next epoch with ACTUAL amounts
        _advanceEpoch(stakingActual, operatorsActual, customersActual);

        emit EpochDistributed(
            currentEpoch - 1,
            stakingActual,
            operatorsActual,
            customersActual,
            totalActualMinted
        );
    }

    /// @notice Check if there are active operators with non-zero scores
    function _hasActiveOperators() internal view returns (bool) {
        for (uint256 i = 0; i < trackedOperators.length; i++) {
            if (_calculateOperatorScore(trackedOperators[i]) > 0) return true;
        }
        return false;
    }

    /// @notice Check if there are active customers with fees paid
    function _hasActiveCustomers() internal view returns (bool) {
        for (uint256 i = 0; i < trackedCustomers.length; i++) {
            if (metrics.totalFeesPaid(trackedCustomers[i]) > 0) return true;
        }
        return false;
    }

    /// @notice Redistribute undistributed portions to active categories
    function _redistributeUndistributed(
        uint256 amount,
        bool hasStaking,
        bool hasOperators,
        bool hasCustomers
    ) internal returns (uint256 stakingExtra, uint256 operatorsExtra, uint256 customersExtra) {
        // Count active categories
        uint256 activeCount = 0;
        if (hasStaking) activeCount++;
        if (hasOperators) activeCount++;
        if (hasCustomers) activeCount++;

        if (activeCount == 0) return (0, 0, 0); // No one to redistribute to

        // Calculate share per active category
        uint256 sharePerCategory = amount / activeCount;
        uint256 remainder = amount - (sharePerCategory * activeCount);

        // Distribute to active categories
        if (hasOperators) {
            operatorsExtra = _distributeOperatorRewards(sharePerCategory);
        }
        if (hasCustomers) {
            // Give remainder to customers to avoid dust
            customersExtra = _distributeCustomerRewards(sharePerCategory + remainder);
            remainder = 0;
        }
        if (hasStaking) {
            stakingExtra = _distributeStakingRewards(sharePerCategory + remainder);
        }
    }

    /// @notice Advance to next epoch
    function _advanceEpoch(
        uint256 stakingDistributed,
        uint256 operatorsDistributed,
        uint256 customersDistributed
    ) internal {
        // Mark current epoch as distributed
        epochs[currentEpoch].distributed = true;
        epochs[currentEpoch].stakingDistributed = stakingDistributed;
        epochs[currentEpoch].operatorsDistributed = operatorsDistributed;
        epochs[currentEpoch].customersDistributed = customersDistributed;

        // Create next epoch
        currentEpoch++;
        epochs[currentEpoch] = EpochData({
            number: currentEpoch,
            startBlock: block.number,
            endBlock: block.number + epochLength,
            stakingDistributed: 0,
            operatorsDistributed: 0,
            customersDistributed: 0,
            distributed: false
        });
    }

    /// @notice Reset year tracking
    function _resetYear() internal {
        emit YearReset(block.number, mintedThisYear);
        yearStartBlock = block.number;
        mintedThisYear = 0;
        // Recalculate fixed yearly budget based on NEW supply
        yearlyBudgetFixed = (tntToken.totalSupply() * inflationBps) / BPS_DENOMINATOR;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKING REWARDS DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute staking rewards across vaults
    /// @param amount Total amount to distribute
    /// @return actualDistributed The actual amount minted and distributed
    function _distributeStakingRewards(uint256 amount) internal returns (uint256 actualDistributed) {
        if (amount == 0) return 0;

        // Get all vault assets
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

            // Mint and send to vaults for distribution
            tntToken.mint(address(vaults), vaultShare);
            actualDistributed += vaultShare;

            // Notify vaults of the reward
            _notifyVaultReward(assets[i], vaultShare);
        }
    }

    /// @notice Notify vault of epoch staking reward
    function _notifyVaultReward(address asset, uint256 amount) internal {
        // Call the vault's epoch reward distribution
        try vaults.distributeEpochReward(asset, amount) {} catch {}
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REWARDS DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute operator performance rewards
    /// @param amount Total amount to distribute
    /// @return distributed Actual amount distributed
    function _distributeOperatorRewards(uint256 amount) internal returns (uint256 distributed) {
        if (amount == 0 || trackedOperators.length == 0) return 0;

        // Calculate scores for all operators
        uint256 totalScore = 0;
        uint256[] memory scores = new uint256[](trackedOperators.length);

        for (uint256 i = 0; i < trackedOperators.length; i++) {
            address op = trackedOperators[i];
            scores[i] = _calculateOperatorScore(op);
            totalScore += scores[i];
        }

        if (totalScore == 0) return 0;

        // Distribute proportionally to scores - track ACTUAL distributed amount
        uint256 actualDistributed = 0;
        for (uint256 i = 0; i < trackedOperators.length; i++) {
            if (scores[i] == 0) continue;

            uint256 reward = (amount * scores[i]) / totalScore;
            if (reward > 0) {
                pendingOperatorRewards[trackedOperators[i]] += reward;
                actualDistributed += reward;
            }
        }

        // Only mint what was actually distributed (avoids dust accumulation)
        if (actualDistributed > 0) {
            tntToken.mint(address(this), actualDistributed);
        }
        return actualDistributed;
    }

    /// @notice Calculate operator score based on metrics
    /// @param operator Operator address
    /// @return score Weighted score
    function _calculateOperatorScore(address operator) internal view returns (uint256 score) {
        // Get metrics from TangleMetrics
        uint256 jobs = metrics.operatorJobsCompleted(operator);
        uint256 successfulJobs = metrics.operatorJobsSuccessful(operator);
        uint256 stake = metrics.operatorTotalStake(operator);
        uint256 heartbeats = metrics.operatorHeartbeats(operator);

        // Score = (jobs * successRate * stake) + heartbeatBonus
        // This weights by stake to prevent abuse
        uint256 successRate = jobs > 0 ? (successfulJobs * BPS_DENOMINATOR) / jobs : 0;

        // Weighted jobs = jobs * successRate/10000 * sqrt(stake)
        // Using simplified sqrt approximation
        uint256 stakeWeight = _sqrt(stake / 1e18) * 1e9; // Normalize

        uint256 jobScore = (jobs * successRate * stakeWeight) / BPS_DENOMINATOR;
        uint256 heartbeatBonus = heartbeats * stakeWeight / 100; // Small bonus for liveness

        score = jobScore + heartbeatBonus;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CUSTOMER REWARDS DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Distribute customer activity rewards
    /// @param amount Total amount to distribute
    /// @return distributed Actual amount distributed
    function _distributeCustomerRewards(uint256 amount) internal returns (uint256 distributed) {
        if (amount == 0 || trackedCustomers.length == 0) return 0;

        // Calculate total fees paid
        uint256 totalFees = 0;
        uint256[] memory fees = new uint256[](trackedCustomers.length);

        for (uint256 i = 0; i < trackedCustomers.length; i++) {
            fees[i] = metrics.totalFeesPaid(trackedCustomers[i]);
            totalFees += fees[i];
        }

        if (totalFees == 0) return 0;

        // Distribute proportionally to fees paid - track ACTUAL distributed amount
        uint256 actualDistributed = 0;
        for (uint256 i = 0; i < trackedCustomers.length; i++) {
            if (fees[i] == 0) continue;

            uint256 reward = (amount * fees[i]) / totalFees;
            if (reward > 0) {
                pendingCustomerRewards[trackedCustomers[i]] += reward;
                actualDistributed += reward;
            }
        }

        // Only mint what was actually distributed (avoids dust accumulation)
        if (actualDistributed > 0) {
            tntToken.mint(address(this), actualDistributed);
        }
        return actualDistributed;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Claim pending operator rewards
    function claimOperatorRewards() external nonReentrant returns (uint256 amount) {
        amount = pendingOperatorRewards[msg.sender];
        if (amount == 0) revert NoRewardsToClaim();

        pendingOperatorRewards[msg.sender] = 0;
        tntToken.transfer(msg.sender, amount);

        emit OperatorRewardClaimed(msg.sender, amount);
    }

    /// @notice Claim pending customer rewards
    function claimCustomerRewards() external nonReentrant returns (uint256 amount) {
        amount = pendingCustomerRewards[msg.sender];
        if (amount == 0) revert NoRewardsToClaim();

        pendingCustomerRewards[msg.sender] = 0;
        tntToken.transfer(msg.sender, amount);

        emit CustomerRewardClaimed(msg.sender, amount);
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

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update distribution weights
    /// @param stakingBps Staking weight (bps)
    /// @param operatorsBps Operators weight (bps)
    /// @param customersBps Customers weight (bps)
    function setWeights(
        uint16 stakingBps,
        uint16 operatorsBps,
        uint16 customersBps
    ) external onlyRole(ADMIN_ROLE) {
        if (stakingBps + operatorsBps + customersBps != BPS_DENOMINATOR) {
            revert InvalidWeights();
        }

        weights = DistributionWeights({
            stakingBps: stakingBps,
            operatorsBps: operatorsBps,
            customersBps: customersBps
        });

        emit WeightsUpdated(stakingBps, operatorsBps, customersBps);
    }

    /// @notice Update inflation rate
    /// @param newBps New inflation rate in basis points
    function setInflationRate(uint16 newBps) external onlyRole(ADMIN_ROLE) {
        if (newBps > 1000) revert InvalidInflationRate(); // Max 10%
        inflationBps = newBps;
        emit InflationRateUpdated(newBps);
    }

    /// @notice Update epoch length
    /// @param newLength New epoch length in blocks
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
        if (_tntToken != address(0)) tntToken = TangleToken(_tntToken);
        if (_metrics != address(0)) metrics = TangleMetrics(_metrics);
        if (_vaults != address(0)) vaults = RewardVaults(_vaults);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate yearly inflation budget based on current supply
    function calculateYearlyBudget() public view returns (uint256) {
        uint256 totalSupply = tntToken.totalSupply();
        return (totalSupply * inflationBps) / BPS_DENOMINATOR;
    }

    /// @notice Calculate per-epoch budget
    function calculateEpochBudget() public view returns (uint256) {
        uint256 yearlyBudget = calculateYearlyBudget();
        uint256 epochsPerYear = BLOCKS_PER_YEAR / epochLength;
        return yearlyBudget / epochsPerYear;
    }

    /// @notice Get remaining yearly budget
    function remainingYearlyBudget() external view returns (uint256) {
        return yearlyBudgetFixed > mintedThisYear ? yearlyBudgetFixed - mintedThisYear : 0;
    }

    /// @notice Get the fixed yearly budget for this year
    function getYearlyBudgetFixed() external view returns (uint256) {
        return yearlyBudgetFixed;
    }

    /// @notice Get remaining mintable supply (constrained by MAX_SUPPLY)
    function remainingMintableSupply() external view returns (uint256) {
        uint256 currentSupply = tntToken.totalSupply();
        return MAX_SUPPLY > currentSupply ? MAX_SUPPLY - currentSupply : 0;
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
        uint16 customersBps
    ) {
        return (weights.stakingBps, weights.operatorsBps, weights.customersBps);
    }

    /// @notice Get tracked operator count
    function trackedOperatorCount() external view returns (uint256) {
        return trackedOperators.length;
    }

    /// @notice Get tracked customer count
    function trackedCustomerCount() external view returns (uint256) {
        return trackedCustomers.length;
    }

    /// @notice Get epoch data
    function getEpoch(uint256 epochNumber) external view returns (EpochData memory) {
        return epochs[epochNumber];
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
