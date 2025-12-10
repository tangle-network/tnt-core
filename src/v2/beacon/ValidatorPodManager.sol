// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IBeaconOracle } from "./IBeaconOracle.sol";
import { ValidatorPod } from "./ValidatorPod.sol";
import { IRestaking } from "../interfaces/IRestaking.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

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

    /// @notice H-3 FIX: Total amount delegated by a delegator
    mapping(address delegator => uint256) public delegatorTotalDelegated;

    /// @notice H-4 FIX: Track delegators per operator for proportional slashing
    mapping(address operator => address[]) internal _operatorDelegators;

    /// @notice H-4 FIX: Track if delegator is in operator's delegator list
    mapping(address operator => mapping(address delegator => bool)) internal _isDelegator;

    /// @notice Authorized slashers
    mapping(address => bool) internal _slashers;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - WITHDRAWAL QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Withdrawal request structure
    struct Withdrawal {
        address staker;
        uint256 shares;
        uint32 startBlock;
        bool completed;
    }

    /// @notice Withdrawal delay in blocks (default ~7 days on L2 at 2s blocks)
    uint32 public withdrawalDelayBlocks;

    /// @notice Default withdrawal delay (~7 days at 2s blocks = 302,400 blocks)
    uint32 public constant DEFAULT_WITHDRAWAL_DELAY = 302_400;

    /// @notice Maximum withdrawal delay (~30 days)
    uint32 public constant MAX_WITHDRAWAL_DELAY = 1_296_000;

    /// @notice Pending withdrawals by withdrawal root
    mapping(bytes32 => Withdrawal) public pendingWithdrawals;

    /// @notice Nonce for unique withdrawal roots per staker
    mapping(address => uint256) public withdrawalNonce;

    /// @notice Total shares currently queued for withdrawal per staker
    mapping(address => uint256) public queuedShares;

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
    event DelegatorSlashed(address indexed delegator, address indexed operator, uint256 amount);
    event WithdrawalQueued(bytes32 indexed withdrawalRoot, address indexed staker, uint256 shares);
    event WithdrawalCompleted(bytes32 indexed withdrawalRoot, address indexed staker, uint256 shares);
    event WithdrawalDelaySet(uint32 oldDelay, uint32 newDelay);

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
    error WithdrawalNotFound();
    error WithdrawalNotReady();
    error WithdrawalAlreadyCompleted();
    error ExceedsMaxDelay();
    error HasPendingDelegations();
    error StakeTransferFailed();

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
        withdrawalDelayBlocks = DEFAULT_WITHDRAWAL_DELAY;
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
    function recordBeaconChainEthBalanceUpdate(
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

    /// @notice Deregister as an operator and withdraw self-stake
    /// @dev Cannot deregister if delegators still have stake with this operator
    function deregisterOperator() external nonReentrant {
        if (!_operators[msg.sender]) revert NotOperator();

        // Safety: cannot deregister if delegators have stake with this operator
        if (operatorDelegatedStake[msg.sender] > 0) {
            revert HasPendingDelegations();
        }

        uint256 stake = operatorStake[msg.sender];

        // Clear operator state
        _operators[msg.sender] = false;
        operatorStake[msg.sender] = 0;

        emit OperatorDeregistered(msg.sender);

        // Return self-stake
        if (stake > 0) {
            (bool sent,) = payable(msg.sender).call{value: stake}("");
            if (!sent) revert StakeTransferFailed();
        }
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
        uint256 currentDelegated = delegatorTotalDelegated[msg.sender]; // H-3 FIX

        // availableShares fits in uint256 because negative case handled.
        // forge-lint: disable-next-line(unsafe-typecast)
        if (availableShares < 0 || uint256(availableShares) < currentDelegated + amount) {
            revert InsufficientShares();
        }

        // H-4 FIX: Track delegator in operator's list for proportional slashing
        if (!_isDelegator[operator][msg.sender]) {
            _operatorDelegators[operator].push(msg.sender);
            _isDelegator[operator][msg.sender] = true;
        }

        delegations[msg.sender][operator] += amount;
        operatorDelegatedStake[operator] += amount;
        delegatorTotalDelegated[msg.sender] += amount; // H-3 FIX

        emit Delegated(msg.sender, operator, amount);
    }

    /// @notice Undelegate from an operator
    /// @param operator The operator to undelegate from
    /// @param amount Amount to undelegate
    function undelegateFrom(address operator, uint256 amount) external nonReentrant {
        if (delegations[msg.sender][operator] < amount) revert InsufficientShares();

        delegations[msg.sender][operator] -= amount;
        operatorDelegatedStake[operator] -= amount;
        delegatorTotalDelegated[msg.sender] -= amount; // H-3 FIX

        emit Undelegated(msg.sender, operator, amount);
    }

    /// @notice Get total amount delegated by an address
    /// @dev H-3 FIX: Now returns the tracked total instead of 0
    function _getTotalDelegatedBy(address delegator) internal view returns (uint256) {
        return delegatorTotalDelegated[delegator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Queue a withdrawal of beacon chain ETH shares
    /// @param shares Amount of shares to withdraw (in wei)
    /// @return withdrawalRoot Unique identifier for this withdrawal
    /// @dev Must have no pending delegations to withdraw
    function queueWithdrawal(uint256 shares) external nonReentrant returns (bytes32 withdrawalRoot) {
        if (shares == 0) revert ZeroAmount();

        // Check staker has sufficient available shares
        int256 currentShares = podOwnerShares[msg.sender];
        uint256 delegated = delegatorTotalDelegated[msg.sender];
        uint256 queued = queuedShares[msg.sender];

        // Must undelegate before withdrawing
        if (delegated > 0) revert HasPendingDelegations();

        // Available = total shares - already queued
        // forge-lint: disable-next-line(unsafe-typecast)
        if (currentShares < 0 || uint256(currentShares) < queued + shares) {
            revert InsufficientShares();
        }

        // Generate unique withdrawal root
        uint256 nonce = withdrawalNonce[msg.sender]++;
        withdrawalRoot = keccak256(abi.encodePacked(msg.sender, shares, block.number, nonce));

        // Store pending withdrawal
        pendingWithdrawals[withdrawalRoot] = Withdrawal({
            staker: msg.sender,
            shares: shares,
            startBlock: uint32(block.number),
            completed: false
        });

        // Track queued shares
        queuedShares[msg.sender] += shares;

        emit WithdrawalQueued(withdrawalRoot, msg.sender, shares);
    }

    /// @notice Complete a pending withdrawal after delay period
    /// @param withdrawalRoot The withdrawal identifier
    /// @dev Transfers ETH from the pod to the staker
    function completeWithdrawal(bytes32 withdrawalRoot) external nonReentrant {
        Withdrawal storage withdrawal = pendingWithdrawals[withdrawalRoot];

        // Verify withdrawal exists and belongs to caller
        if (withdrawal.staker != msg.sender) revert WithdrawalNotFound();
        if (withdrawal.completed) revert WithdrawalAlreadyCompleted();

        // Check delay has passed
        if (block.number < withdrawal.startBlock + withdrawalDelayBlocks) {
            revert WithdrawalNotReady();
        }

        // Mark as completed
        withdrawal.completed = true;

        // Reduce shares and queued amount
        uint256 shares = withdrawal.shares;
        // forge-lint: disable-next-line(unsafe-typecast)
        podOwnerShares[msg.sender] -= int256(shares);
        // forge-lint: disable-next-line(unsafe-typecast)
        totalShares -= int256(shares);
        queuedShares[msg.sender] -= shares;

        // Transfer ETH from pod to staker
        address pod = ownerToPod[msg.sender];
        if (pod != address(0)) {
            // Request pod to send ETH to staker
            ValidatorPod(payable(pod)).withdrawToStaker(msg.sender, shares);
        }

        emit WithdrawalCompleted(withdrawalRoot, msg.sender, shares);
    }

    /// @notice Get withdrawal info
    /// @param withdrawalRoot The withdrawal identifier
    /// @return staker The staker address
    /// @return shares Amount of shares
    /// @return startBlock Block when queued
    /// @return completed Whether completed
    /// @return canComplete Whether can be completed now
    function getWithdrawalInfo(bytes32 withdrawalRoot)
        external
        view
        returns (
            address staker,
            uint256 shares,
            uint32 startBlock,
            bool completed,
            bool canComplete
        )
    {
        Withdrawal storage w = pendingWithdrawals[withdrawalRoot];
        staker = w.staker;
        shares = w.shares;
        startBlock = w.startBlock;
        completed = w.completed;
        canComplete = !completed && block.number >= startBlock + withdrawalDelayBlocks;
    }

    /// @notice Calculate available shares for withdrawal
    /// @param staker The staker address
    /// @return available Shares available to queue for withdrawal
    function getAvailableToWithdraw(address staker) external view returns (uint256 available) {
        int256 shares = podOwnerShares[staker];
        if (shares <= 0) return 0;

        uint256 delegated = delegatorTotalDelegated[staker];
        uint256 queued = queuedShares[staker];
        uint256 used = delegated + queued;

        if (uint256(shares) > used) {
            // forge-lint: disable-next-line(unsafe-typecast)
            available = uint256(shares) - used;
        }
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
        // forge-lint: disable-next-line(unsafe-typecast)
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
        uint64 /*blueprintId*/,
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
    /// @dev H-4 FIX: Now proportionally slashes delegators
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

        // H-4 FIX: Proportionally slash delegators
        if (amount > 0) {
            uint256 delegatedBefore = operatorDelegatedStake[operator];
            if (delegatedBefore > 0) {
                // Iterate through all delegators and reduce proportionally
                address[] storage delegators = _operatorDelegators[operator];
                for (uint256 i = 0; i < delegators.length; i++) {
                    address delegator = delegators[i];
                    uint256 delegatorStake = delegations[delegator][operator];

                    if (delegatorStake > 0) {
                        // Calculate proportional slash: (delegatorStake / delegatedBefore) * amount
                        uint256 delegatorSlash = (delegatorStake * amount) / delegatedBefore;

                        if (delegatorSlash > delegatorStake) {
                            delegatorSlash = delegatorStake;
                        }

                        delegations[delegator][operator] -= delegatorSlash;
                        delegatorTotalDelegated[delegator] -= delegatorSlash;

                        emit DelegatorSlashed(delegator, operator, delegatorSlash);
                    }
                }
            }
            operatorDelegatedStake[operator] -= amount;
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

    /// @notice Set the withdrawal delay
    /// @param newDelay New delay in blocks
    function setWithdrawalDelay(uint32 newDelay) external onlyOwner {
        if (newDelay > MAX_WITHDRAWAL_DELAY) revert ExceedsMaxDelay();
        uint32 oldDelay = withdrawalDelayBlocks;
        withdrawalDelayBlocks = newDelay;
        emit WithdrawalDelaySet(oldDelay, newDelay);
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
