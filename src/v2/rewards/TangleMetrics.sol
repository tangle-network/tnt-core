// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { IMetricsRecorder } from "../interfaces/IMetricsRecorder.sol";

/// @title TangleMetrics
/// @notice Lightweight protocol activity recorder for reward distribution
/// @dev Records events and maintains minimal aggregates for RewardVaults
contract TangleMetrics is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    IMetricsRecorder
{
    // ═══════════════════════════════════════════════════════════════════════════
    // ROLES
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant RECORDER_ROLE = keccak256("RECORDER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS - Comprehensive protocol activity tracking
    // ═══════════════════════════════════════════════════════════════════════════

    // Staking
    event Staked(
        address indexed delegator,
        address indexed operator,
        address indexed asset,
        uint256 amount,
        uint256 timestamp
    );
    event Unstaked(
        address indexed delegator,
        address indexed operator,
        address indexed asset,
        uint256 amount,
        uint256 timestamp
    );

    // Operators
    event OperatorRegistered(
        address indexed operator,
        address indexed asset,
        uint256 amount,
        uint256 timestamp
    );
    event HeartbeatReceived(
        address indexed operator,
        uint64 indexed serviceId,
        uint64 timestamp,
        uint256 blockNumber
    );
    event JobCompleted(
        address indexed operator,
        uint64 indexed serviceId,
        uint64 jobCallId,
        bool success,
        uint256 timestamp
    );
    event OperatorSlashed(
        address indexed operator,
        uint64 indexed serviceId,
        uint256 amount,
        uint256 timestamp
    );

    // Services
    event ServiceCreated(
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        address indexed owner,
        uint256 operatorCount,
        uint256 timestamp
    );
    event ServiceTerminated(
        uint64 indexed serviceId,
        uint256 duration,
        uint256 timestamp
    );
    event JobCalled(
        uint64 indexed serviceId,
        address indexed caller,
        uint64 jobCallId,
        uint256 timestamp
    );

    // Payments
    event PaymentRecorded(
        address indexed payer,
        uint64 indexed serviceId,
        address indexed token,
        uint256 amount,
        uint256 timestamp
    );

    // Blueprints
    event BlueprintCreated(
        uint64 indexed blueprintId,
        address indexed developer,
        uint256 timestamp
    );
    event BlueprintRegistration(
        uint64 indexed blueprintId,
        address indexed operator,
        uint256 timestamp
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // AGGREGATE STORAGE - Minimal state for reward calculations
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Total staked per asset (for utilization calculations)
    mapping(address => uint256) public totalStakedByAsset;

    /// @notice Total staked by delegator per asset
    mapping(address => mapping(address => uint256)) public delegatorStakeByAsset;

    /// @notice Operator total stake received (across all assets, for weighting)
    mapping(address => uint256) public operatorTotalStake;

    /// @notice Operator job completion count
    mapping(address => uint256) public operatorJobsCompleted;

    /// @notice Operator successful job count
    mapping(address => uint256) public operatorJobsSuccessful;

    /// @notice Operator heartbeat count
    mapping(address => uint256) public operatorHeartbeats;

    /// @notice Operator last heartbeat timestamp
    mapping(address => uint256) public operatorLastHeartbeat;

    /// @notice Total fees paid by address
    mapping(address => uint256) public totalFeesPaid;

    /// @notice Total services created
    uint256 public totalServicesCreated;

    /// @notice Total jobs called
    uint256 public totalJobsCalled;

    /// @notice Total payments recorded
    uint256 public totalPaymentsRecorded;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT & DEVELOPER AGGREGATES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Blueprint developer mapping
    mapping(uint64 => address) public blueprintDeveloper;

    /// @notice Number of services created per blueprint
    mapping(uint64 => uint256) public blueprintServiceCount;

    /// @notice Number of jobs completed per blueprint
    mapping(uint64 => uint256) public blueprintJobCount;

    /// @notice Number of operators registered per blueprint
    mapping(uint64 => uint256) public blueprintOperatorCount;

    /// @notice Total fees earned by blueprint (across all services)
    mapping(uint64 => uint256) public blueprintTotalFees;

    /// @notice Number of blueprints created by developer
    mapping(address => uint256) public developerBlueprintCount;

    /// @notice Total services across all developer's blueprints
    mapping(address => uint256) public developerTotalServices;

    /// @notice Total jobs across all developer's blueprints
    mapping(address => uint256) public developerTotalJobs;

    /// @notice Total fees earned by developer (across all blueprints)
    mapping(address => uint256) public developerTotalFees;

    /// @notice Service to blueprint mapping (for lookups)
    mapping(uint64 => uint64) public serviceBlueprintId;

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the metrics contract
    /// @param admin Admin address
    function initialize(address admin) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
    }

    /// @notice Grant recorder role to protocol contracts
    /// @param recorder Address to grant role to (Tangle.sol, MultiAssetDelegation.sol)
    function grantRecorderRole(address recorder) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(RECORDER_ROLE, recorder);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKING & DELEGATION RECORDING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IMetricsRecorder
    function recordStake(
        address delegator,
        address operator,
        address asset,
        uint256 amount
    ) external onlyRole(RECORDER_ROLE) {
        totalStakedByAsset[asset] += amount;
        delegatorStakeByAsset[delegator][asset] += amount;
        operatorTotalStake[operator] += amount;

        emit Staked(delegator, operator, asset, amount, block.timestamp);
    }

    /// @inheritdoc IMetricsRecorder
    function recordUnstake(
        address delegator,
        address operator,
        address asset,
        uint256 amount
    ) external onlyRole(RECORDER_ROLE) {
        totalStakedByAsset[asset] -= amount;
        delegatorStakeByAsset[delegator][asset] -= amount;
        operatorTotalStake[operator] -= amount;

        emit Unstaked(delegator, operator, asset, amount, block.timestamp);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR RECORDING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IMetricsRecorder
    function recordOperatorRegistered(
        address operator,
        address asset,
        uint256 amount
    ) external onlyRole(RECORDER_ROLE) {
        totalStakedByAsset[asset] += amount;
        operatorTotalStake[operator] += amount;

        emit OperatorRegistered(operator, asset, amount, block.timestamp);
    }

    /// @inheritdoc IMetricsRecorder
    function recordHeartbeat(
        address operator,
        uint64 serviceId,
        uint64 timestamp
    ) external onlyRole(RECORDER_ROLE) {
        operatorHeartbeats[operator]++;
        operatorLastHeartbeat[operator] = timestamp;

        emit HeartbeatReceived(operator, serviceId, timestamp, block.number);
    }

    /// @inheritdoc IMetricsRecorder
    function recordJobCompletion(
        address operator,
        uint64 serviceId,
        uint64 jobCallId,
        bool success
    ) external onlyRole(RECORDER_ROLE) {
        operatorJobsCompleted[operator]++;
        if (success) {
            operatorJobsSuccessful[operator]++;
        }

        emit JobCompleted(operator, serviceId, jobCallId, success, block.timestamp);
    }

    /// @inheritdoc IMetricsRecorder
    function recordSlash(
        address operator,
        uint64 serviceId,
        uint256 amount
    ) external onlyRole(RECORDER_ROLE) {
        emit OperatorSlashed(operator, serviceId, amount, block.timestamp);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE RECORDING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IMetricsRecorder
    function recordServiceCreated(
        uint64 serviceId,
        uint64 blueprintId,
        address owner,
        uint256 operatorCount
    ) external onlyRole(RECORDER_ROLE) {
        totalServicesCreated++;

        // Track service to blueprint mapping
        serviceBlueprintId[serviceId] = blueprintId;

        // Update blueprint metrics
        blueprintServiceCount[blueprintId]++;

        // Update developer metrics
        address developer = blueprintDeveloper[blueprintId];
        if (developer != address(0)) {
            developerTotalServices[developer]++;
        }

        emit ServiceCreated(serviceId, blueprintId, owner, operatorCount, block.timestamp);
    }

    /// @inheritdoc IMetricsRecorder
    function recordServiceTerminated(
        uint64 serviceId,
        uint256 duration
    ) external onlyRole(RECORDER_ROLE) {
        emit ServiceTerminated(serviceId, duration, block.timestamp);
    }

    /// @inheritdoc IMetricsRecorder
    function recordJobCall(
        uint64 serviceId,
        address caller,
        uint64 jobCallId
    ) external onlyRole(RECORDER_ROLE) {
        totalJobsCalled++;

        // Update blueprint and developer job counts
        uint64 blueprintId = serviceBlueprintId[serviceId];
        if (blueprintId != 0) {
            blueprintJobCount[blueprintId]++;

            address developer = blueprintDeveloper[blueprintId];
            if (developer != address(0)) {
                developerTotalJobs[developer]++;
            }
        }

        emit JobCalled(serviceId, caller, jobCallId, block.timestamp);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT RECORDING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IMetricsRecorder
    function recordPayment(
        address payer,
        uint64 serviceId,
        address token,
        uint256 amount
    ) external onlyRole(RECORDER_ROLE) {
        totalFeesPaid[payer] += amount;
        totalPaymentsRecorded++;

        // Update blueprint and developer fee totals
        uint64 blueprintId = serviceBlueprintId[serviceId];
        if (blueprintId != 0) {
            blueprintTotalFees[blueprintId] += amount;

            address developer = blueprintDeveloper[blueprintId];
            if (developer != address(0)) {
                developerTotalFees[developer] += amount;
            }
        }

        emit PaymentRecorded(payer, serviceId, token, amount, block.timestamp);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT RECORDING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IMetricsRecorder
    function recordBlueprintCreated(
        uint64 blueprintId,
        address developer
    ) external onlyRole(RECORDER_ROLE) {
        // Store blueprint developer
        blueprintDeveloper[blueprintId] = developer;

        // Increment developer's blueprint count
        developerBlueprintCount[developer]++;

        emit BlueprintCreated(blueprintId, developer, block.timestamp);
    }

    /// @inheritdoc IMetricsRecorder
    function recordBlueprintRegistration(
        uint64 blueprintId,
        address operator
    ) external onlyRole(RECORDER_ROLE) {
        // Increment operator count for this blueprint
        blueprintOperatorCount[blueprintId]++;

        emit BlueprintRegistration(blueprintId, operator, block.timestamp);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get operator success rate (basis points)
    function getOperatorSuccessRate(address operator) external view returns (uint256) {
        uint256 completed = operatorJobsCompleted[operator];
        if (completed == 0) return 0;
        return (operatorJobsSuccessful[operator] * 10000) / completed;
    }

    /// @notice Check if operator heartbeat is recent
    /// @param operator The operator address
    /// @param maxAge Maximum age in seconds
    function isHeartbeatRecent(address operator, uint256 maxAge) external view returns (bool) {
        return block.timestamp - operatorLastHeartbeat[operator] <= maxAge;
    }

    /// @notice Get blueprint stats
    /// @param blueprintId The blueprint ID
    /// @return developer The developer address
    /// @return serviceCount Number of services created
    /// @return jobCount Number of jobs completed
    /// @return operatorCount Number of operators registered
    /// @return totalFees Total fees earned
    function getBlueprintStats(uint64 blueprintId) external view returns (
        address developer,
        uint256 serviceCount,
        uint256 jobCount,
        uint256 operatorCount,
        uint256 totalFees
    ) {
        return (
            blueprintDeveloper[blueprintId],
            blueprintServiceCount[blueprintId],
            blueprintJobCount[blueprintId],
            blueprintOperatorCount[blueprintId],
            blueprintTotalFees[blueprintId]
        );
    }

    /// @notice Get developer stats
    /// @param developer The developer address
    /// @return blueprintCount Number of blueprints created
    /// @return serviceCount Total services across all blueprints
    /// @return jobCount Total jobs across all blueprints
    /// @return totalFees Total fees earned across all blueprints
    function getDeveloperStats(address developer) external view returns (
        uint256 blueprintCount,
        uint256 serviceCount,
        uint256 jobCount,
        uint256 totalFees
    ) {
        return (
            developerBlueprintCount[developer],
            developerTotalServices[developer],
            developerTotalJobs[developer],
            developerTotalFees[developer]
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADES
    // ═══════════════════════════════════════════════════════════════════════════

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}
}
