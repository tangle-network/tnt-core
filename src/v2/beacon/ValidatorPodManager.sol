// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IBeaconOracle} from "./IBeaconOracle.sol";
import {ValidatorPod} from "./ValidatorPod.sol";
import {ValidatorTypes} from "./ValidatorTypes.sol";
import {IRestaking} from "../interfaces/IRestaking.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title ValidatorPodManager
/// @notice Factory and manager for ValidatorPods, implements IRestaking for Tangle integration
/// @dev Creates pods for users, tracks shares, handles delegation to operators
contract ValidatorPodManager is IRestaking, Ownable, ReentrancyGuard {
    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - CORE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Beacon oracle for accessing beacon roots
    IBeaconOracle public beaconOracle;

    /// @notice Minimum stake to be an operator (in wei)
    uint256 public minOperatorStakeAmount;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - PODS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Pod address by owner
    mapping(address owner => address pod) public ownerToPod;

    /// @notice Owner by pod address
    mapping(address pod => address owner) public podToOwner;

    /// @notice Number of pods created
    uint256 public podCount;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - SHARES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Shares by pod owner (can be negative if slashed below initial)
    /// @dev Represents restaked beacon chain ETH in wei
    mapping(address owner => int256) public podOwnerShares;

    /// @notice Total shares across all pod owners
    int256 public totalShares;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - OPERATORS & DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Registered operators
    mapping(address => bool) internal _operators;

    /// @notice Operator self-stake
    mapping(address operator => uint256) public operatorStake;

    /// @notice Delegation from pod owner to operator
    mapping(address delegator => mapping(address operator => uint256)) public delegations;

    /// @notice Total delegated to an operator
    mapping(address operator => uint256) public operatorDelegatedStake;

    /// @notice Authorized slashers
    mapping(address => bool) internal _slashers;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event PodCreated(address indexed owner, address indexed pod);
    event SharesUpdated(address indexed owner, int256 sharesDelta, int256 newShares);
    event OperatorRegistered(address indexed operator);
    event OperatorDeregistered(address indexed operator);
    event Delegated(address indexed delegator, address indexed operator, uint256 amount);
    event Undelegated(address indexed delegator, address indexed operator, uint256 amount);
    event SlasherUpdated(address indexed slasher, bool authorized);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error PodAlreadyExists();
    error NoPodExists();
    error OnlyPod();
    error NotOperator();
    error AlreadyOperator();
    error InsufficientShares();
    error InsufficientStake();
    error NotAuthorizedSlasher();
    error ZeroAddress();
    error ZeroAmount();

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the pod manager
    /// @param _beaconOracle Beacon oracle address
    /// @param _minOperatorStake Minimum stake to be an operator
    constructor(
        address _beaconOracle,
        uint256 _minOperatorStake
    ) Ownable(msg.sender) {
        if (_beaconOracle == address(0)) revert ZeroAddress();
        beaconOracle = IBeaconOracle(_beaconOracle);
        minOperatorStakeAmount = _minOperatorStake;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // POD MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new ValidatorPod for the caller
    /// @return pod The address of the new pod
    function createPod() external returns (address pod) {
        if (ownerToPod[msg.sender] != address(0)) {
            revert PodAlreadyExists();
        }

        pod = address(new ValidatorPod(msg.sender, address(this), address(beaconOracle)));

        ownerToPod[msg.sender] = pod;
        podToOwner[pod] = msg.sender;
        podCount++;

        emit PodCreated(msg.sender, pod);
    }

    /// @notice Get or create pod for the caller
    /// @return pod The pod address
    function getOrCreatePod() external returns (address pod) {
        pod = ownerToPod[msg.sender];
        if (pod == address(0)) {
            pod = address(new ValidatorPod(msg.sender, address(this), address(beaconOracle)));
            ownerToPod[msg.sender] = pod;
            podToOwner[pod] = msg.sender;
            podCount++;
            emit PodCreated(msg.sender, pod);
        }
    }

    /// @notice Get pod address for an owner (view only)
    /// @param owner The owner address
    /// @return The pod address (or zero if none)
    function getPod(address owner) external view returns (address) {
        return ownerToPod[owner];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE MANAGEMENT (called by pods)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record a balance update from a pod
    /// @param podOwner The pod owner
    /// @param sharesDelta Change in shares (can be negative)
    /// @dev Only callable by a valid pod
    function recordBeaconChainETHBalanceUpdate(
        address podOwner,
        int256 sharesDelta
    ) external {
        address pod = ownerToPod[podOwner];
        if (msg.sender != pod) revert OnlyPod();

        int256 currentShares = podOwnerShares[podOwner];
        int256 newShares = currentShares + sharesDelta;

        podOwnerShares[podOwner] = newShares;
        totalShares += sharesDelta;

        emit SharesUpdated(podOwner, sharesDelta, newShares);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register as an operator with self-stake
    function registerOperator() external payable {
        if (_operators[msg.sender]) revert AlreadyOperator();
        if (msg.value < minOperatorStakeAmount) revert InsufficientStake();

        _operators[msg.sender] = true;
        operatorStake[msg.sender] = msg.value;

        emit OperatorRegistered(msg.sender);
    }

    /// @notice Increase operator self-stake
    function increaseOperatorStake() external payable {
        if (!_operators[msg.sender]) revert NotOperator();
        operatorStake[msg.sender] += msg.value;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delegate beacon chain ETH shares to an operator
    /// @param operator The operator to delegate to
    /// @param amount Amount to delegate (in wei)
    function delegateTo(address operator, uint256 amount) external nonReentrant {
        if (!_operators[operator]) revert NotOperator();
        if (amount == 0) revert ZeroAmount();

        int256 availableShares = podOwnerShares[msg.sender];
        uint256 currentDelegated = _getTotalDelegatedBy(msg.sender);

        if (availableShares < 0 || uint256(availableShares) < currentDelegated + amount) {
            revert InsufficientShares();
        }

        delegations[msg.sender][operator] += amount;
        operatorDelegatedStake[operator] += amount;

        emit Delegated(msg.sender, operator, amount);
    }

    /// @notice Undelegate from an operator
    /// @param operator The operator to undelegate from
    /// @param amount Amount to undelegate
    function undelegateFrom(address operator, uint256 amount) external nonReentrant {
        if (delegations[msg.sender][operator] < amount) revert InsufficientShares();

        delegations[msg.sender][operator] -= amount;
        operatorDelegatedStake[operator] -= amount;

        emit Undelegated(msg.sender, operator, amount);
    }

    /// @notice Get total amount delegated by an address
    function _getTotalDelegatedBy(address delegator) internal view returns (uint256 total) {
        // Note: This would need iteration in production
        // For now, this is a simplified implementation
        return 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // IRESTAKING IMPLEMENTATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IRestaking
    function isOperator(address operator) external view override returns (bool) {
        return _operators[operator];
    }

    /// @inheritdoc IRestaking
    function isOperatorActive(address operator) external view override returns (bool) {
        return _operators[operator] && operatorStake[operator] >= minOperatorStakeAmount;
    }

    /// @inheritdoc IRestaking
    function getOperatorStake(address operator) external view override returns (uint256) {
        return operatorStake[operator] + operatorDelegatedStake[operator];
    }

    /// @inheritdoc IRestaking
    function getOperatorSelfStake(address operator) external view override returns (uint256) {
        return operatorStake[operator];
    }

    /// @inheritdoc IRestaking
    function getOperatorDelegatedStake(address operator) external view override returns (uint256) {
        return operatorDelegatedStake[operator];
    }

    /// @inheritdoc IRestaking
    function getDelegation(
        address delegator,
        address operator
    ) external view override returns (uint256) {
        return delegations[delegator][operator];
    }

    /// @inheritdoc IRestaking
    function getTotalDelegation(address delegator) external view override returns (uint256) {
        // Simplified - in production would need to track this
        int256 shares = podOwnerShares[delegator];
        return shares > 0 ? uint256(shares) : 0;
    }

    /// @inheritdoc IRestaking
    function minOperatorStake() external view override returns (uint256) {
        return minOperatorStakeAmount;
    }

    /// @inheritdoc IRestaking
    function meetsStakeRequirement(
        address operator,
        uint256 required
    ) external view override returns (bool) {
        return operatorStake[operator] + operatorDelegatedStake[operator] >= required;
    }

    /// @inheritdoc IRestaking
    function slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    ) external override returns (uint256 actualSlashed) {
        if (!_slashers[msg.sender]) revert NotAuthorizedSlasher();

        actualSlashed = _slash(operator, amount);

        emit OperatorSlashed(operator, serviceId, actualSlashed, evidence);
    }

    /// @inheritdoc IRestaking
    function slash(
        address operator,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    ) external override returns (uint256 actualSlashed) {
        if (!_slashers[msg.sender]) revert NotAuthorizedSlasher();

        actualSlashed = _slash(operator, amount);

        emit OperatorSlashed(operator, serviceId, actualSlashed, evidence);
    }

    /// @notice Internal slash implementation
    function _slash(address operator, uint256 amount) internal returns (uint256 actualSlashed) {
        uint256 totalStake = operatorStake[operator] + operatorDelegatedStake[operator];

        if (amount > totalStake) {
            amount = totalStake;
        }

        actualSlashed = amount;

        // Slash from self-stake first
        uint256 selfSlash = amount > operatorStake[operator] ? operatorStake[operator] : amount;
        operatorStake[operator] -= selfSlash;
        amount -= selfSlash;

        // Remaining from delegated stake
        if (amount > 0) {
            operatorDelegatedStake[operator] -= amount;
            // Note: In production, would need to proportionally reduce delegator shares
        }
    }

    /// @inheritdoc IRestaking
    function isSlasher(address account) external view override returns (bool) {
        return _slashers[account];
    }

    /// @inheritdoc IRestaking
    function notifyRewardForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount
    ) external override {
        // Reward distribution would be implemented here
        // For now, this is a no-op placeholder
    }

    /// @inheritdoc IRestaking
    function notifyReward(
        address operator,
        uint64 serviceId,
        uint256 amount
    ) external override {
        // Reward distribution would be implemented here
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add an authorized slasher
    /// @param slasher Address to authorize
    function addSlasher(address slasher) external onlyOwner {
        _slashers[slasher] = true;
        emit SlasherUpdated(slasher, true);
    }

    /// @notice Remove an authorized slasher
    /// @param slasher Address to remove
    function removeSlasher(address slasher) external onlyOwner {
        _slashers[slasher] = false;
        emit SlasherUpdated(slasher, false);
    }

    /// @notice Update minimum operator stake
    /// @param amount New minimum
    function setMinOperatorStake(uint256 amount) external onlyOwner {
        minOperatorStakeAmount = amount;
    }

    /// @notice Update beacon oracle
    /// @param _beaconOracle New oracle address
    function setBeaconOracle(address _beaconOracle) external onlyOwner {
        if (_beaconOracle == address(0)) revert ZeroAddress();
        beaconOracle = IBeaconOracle(_beaconOracle);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pod owner's shares
    /// @param owner The owner address
    /// @return Current shares (can be negative)
    function getShares(address owner) external view returns (int256) {
        return podOwnerShares[owner];
    }

    /// @notice Check if address has a pod
    /// @param owner Address to check
    /// @return True if pod exists
    function hasPod(address owner) external view returns (bool) {
        return ownerToPod[owner] != address(0);
    }
}
