// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IBeaconOracle } from "./IBeaconOracle.sol";
import { ValidatorPod } from "./ValidatorPod.sol";
import { IStaking } from "../interfaces/IStaking.sol";
import { Types } from "../libraries/Types.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title ValidatorPodManager
/// @notice Factory and manager for ValidatorPods, implements IStaking for Tangle integration.
/// @dev G-02 (Round 4): Refactored to use O(1) share-pool accounting consistent with the rest of
///      the staking surface (`MultiAssetDelegation`, `LiquidDelegationVault`, `RewardsManager`).
///
///      Per-pod accounting model:
///        Each pod owner has an isolated share-pool tracked by `BeaconPool { totalAssets, totalShares }`
///        and a per-owner `shares[owner]` balance. Beacon chain rebases (rewards / slashes) move
///        `totalAssets` only -- share balances are unaffected. Deposits (validator credential proofs)
///        mint shares against the pool at the current exchange rate. Withdrawals burn shares and
///        transfer the asset-equivalent ETH out of the pod.
///
///      Slashing semantics divergence from a Lido-style global pool:
///        We deliberately keep the slash isolated to the affected pod (existing semantics).
///        With one shareholder per pod, "totalAssets -= slashed; shares unchanged" reduces the
///        owner's claimable assets without spreading the loss across other pod owners. This matches
///        the per-pod-isolation invariant the existing contract maintained, while still using
///        share-pool math (virtual offset, mulDiv) so behavior is bit-exact with the rest of Tangle.
///
///      Virtual offsets (`VIRTUAL_SHARES = VIRTUAL_ASSETS = 1e3`) defend against first-depositor
///      inflation attacks; they match `LiquidDelegationVault` exactly.
contract ValidatorPodManager is IStaking, Ownable, ReentrancyGuard {
    using Math for uint256;

    uint256 public constant BPS_DENOMINATOR = 10_000;

    /// @notice G-02: Virtual shares/assets offset to prevent first-depositor inflation attack.
    /// @dev Following OpenZeppelin ERC4626 pattern, consistent with `LiquidDelegationVault`.
    uint256 internal constant VIRTUAL_SHARES = 1e3;
    uint256 internal constant VIRTUAL_ASSETS = 1e3;

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
    // STATE - SHARES (G-02: SHARE-POOL ACCOUNTING)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Per-pod share-pool state. One pool per pod owner.
    struct BeaconPool {
        uint256 totalAssets; // Beacon-chain ETH (in wei) attributable to this pod
        uint256 totalShares; // Outstanding shares for this pod
    }

    /// @notice Pool state by pod owner
    mapping(address owner => BeaconPool) internal _pools;

    /// @notice Per-owner share balance
    mapping(address owner => uint256) internal _shares;

    /// @notice Aggregate shares across all pools (informational, not used for accounting)
    uint256 internal _aggregateShares;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - OPERATORS & DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Registered operators
    mapping(address => bool) internal _operators;

    /// @notice Operator self-stake
    mapping(address operator => uint256) public operatorStake;

    /// @notice Delegation from pod owner to operator (in asset units)
    mapping(address delegator => mapping(address operator => uint256)) public delegations;

    /// @notice Total delegated to an operator (in asset units)
    mapping(address operator => uint256) public operatorDelegatedStake;

    /// @notice H-3 FIX: Total amount delegated by a delegator (in asset units)
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
    /// @dev `shares` is denominated in pool shares (G-02). `assets` is the asset value
    ///      locked in at queue time (snapshot of `convertToAssets(shares)`), to ensure
    ///      the staker receives no more than they had at request time even if the pool
    ///      rebases up before completion. The actual transferred amount is the minimum
    ///      of the snapshot and the live value at completion (so beacon slashes between
    ///      queue and complete still take effect).
    struct Withdrawal {
        address staker;
        uint256 shares;
        uint256 assets;
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
    // STATE - UNDELEGATION QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Undelegation request structure
    /// @dev Similar to EigenLayer's queued withdrawal model - undelegation is not instant
    struct Undelegation {
        address delegator;
        address operator;
        uint256 amount;
        uint32 startBlock;
        bool completed;
    }

    /// @notice Pending undelegations by undelegation root
    mapping(bytes32 => Undelegation) public pendingUndelegations;

    /// @notice Nonce for unique undelegation roots per delegator
    mapping(address => uint256) public undelegationNonce;

    /// @notice Total amount currently queued for undelegation per delegator per operator
    mapping(address => mapping(address => uint256)) public queuedUndelegations;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event PodCreated(address indexed owner, address indexed pod);

    /// @notice G-02: Emitted when shares are minted/burned for an owner.
    event SharesUpdated(
        address indexed owner, int256 sharesDelta, uint256 newShares, uint256 totalAssets, uint256 totalSharesPool
    );

    /// @notice G-02: Emitted when the pool's totalAssets is updated by a beacon chain rebase
    ///         (rewards/slash). Shares are unchanged; only the share price moves.
    event BeaconRebase(
        address indexed owner, int256 assetsDelta, uint256 newTotalAssets, uint256 totalSharesPool
    );

    event OperatorRegistered(address indexed operator);
    event OperatorDeregistered(address indexed operator);
    event Delegated(address indexed delegator, address indexed operator, uint256 amount);
    event Undelegated(address indexed delegator, address indexed operator, uint256 amount);
    event UndelegationQueued(
        bytes32 indexed undelegationRoot, address indexed delegator, address indexed operator, uint256 amount
    );
    event UndelegationCompleted(
        bytes32 indexed undelegationRoot, address indexed delegator, address indexed operator, uint256 amount
    );
    event SlasherUpdated(address indexed slasher, bool authorized);
    event DelegatorSlashed(address indexed delegator, address indexed operator, uint256 amount);
    event WithdrawalQueued(
        bytes32 indexed withdrawalRoot, address indexed staker, uint256 shares, uint256 assets
    );
    event WithdrawalCompleted(
        bytes32 indexed withdrawalRoot, address indexed staker, uint256 shares, uint256 assets
    );
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
    error ZeroShares();
    error WithdrawalNotFound();
    error WithdrawalNotReady();
    error WithdrawalAlreadyCompleted();
    error ExceedsMaxDelay();
    error HasPendingDelegations();
    error StakeTransferFailed();
    error UndelegationNotFound();
    error UndelegationNotReady();
    error UndelegationAlreadyCompleted();
    error InvalidDelta();

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the pod manager
    /// @param _beaconOracle Beacon oracle address
    /// @param _minOperatorStake Minimum stake to be an operator
    constructor(address _beaconOracle, uint256 _minOperatorStake) Ownable(msg.sender) {
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
    // SHARE-POOL CONVERSION HELPERS (G-02)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Convert assets to shares for a specific pool, rounding shares DOWN.
    /// @dev Matches OpenZeppelin ERC4626 deposit semantics: depositor cannot mint
    ///      more shares than the asset contribution warrants.
    function _convertToShares(BeaconPool storage pool, uint256 assets) internal view returns (uint256) {
        return assets.mulDiv(pool.totalShares + VIRTUAL_SHARES, pool.totalAssets + VIRTUAL_ASSETS, Math.Rounding.Floor);
    }

    /// @notice Convert shares to assets for a specific pool, rounding assets DOWN.
    /// @dev Matches OpenZeppelin ERC4626 redeem semantics: redeemer cannot withdraw
    ///      more assets than the shares warrant.
    function _convertToAssets(BeaconPool storage pool, uint256 shares) internal view returns (uint256) {
        return shares.mulDiv(pool.totalAssets + VIRTUAL_ASSETS, pool.totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);
    }

    /// @notice Public view: convert assets to shares for `owner`'s pool.
    function convertToShares(address owner, uint256 assets) external view returns (uint256) {
        return _convertToShares(_pools[owner], assets);
    }

    /// @notice Public view: convert shares to assets for `owner`'s pool.
    function convertToAssets(address owner, uint256 shares) external view returns (uint256) {
        return _convertToAssets(_pools[owner], shares);
    }

    /// @notice Public view: total assets in `owner`'s pool (live beacon-chain ETH).
    function totalAssetsOf(address owner) external view returns (uint256) {
        return _pools[owner].totalAssets;
    }

    /// @notice Public view: total shares outstanding in `owner`'s pool.
    function totalSharesOf(address owner) external view returns (uint256) {
        return _pools[owner].totalShares;
    }

    /// @notice Public view: aggregate shares across all pools (informational).
    function totalShares() external view returns (uint256) {
        return _aggregateShares;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE MANAGEMENT (called by pods)  -- G-02 SHARE-POOL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record a beacon-chain principal deposit (validator credential proof).
    /// @dev Mints pool shares for `podOwner` against the current pool exchange rate.
    ///      Called by `ValidatorPod.verifyWithdrawalCredentials` when new principal
    ///      becomes attributable to this pod. Only callable by the owner's pod.
    /// @param podOwner The pod owner
    /// @param assets Principal added to the pod (in wei, must be > 0)
    /// @return mintedShares Number of shares minted to `podOwner`
    function recordBeaconChainDeposit(address podOwner, uint256 assets)
        external
        returns (uint256 mintedShares)
    {
        address pod = ownerToPod[podOwner];
        if (msg.sender != pod) revert OnlyPod();
        if (assets == 0) revert ZeroAmount();

        BeaconPool storage pool = _pools[podOwner];

        mintedShares = _convertToShares(pool, assets);
        if (mintedShares == 0) revert ZeroShares();

        pool.totalAssets += assets;
        pool.totalShares += mintedShares;
        _shares[podOwner] += mintedShares;
        _aggregateShares += mintedShares;

        // assets fits in int256 because uint256 -> int256 cast guarded by reasonable bounds
        // forge-lint: disable-next-line(unsafe-typecast)
        emit SharesUpdated(podOwner, int256(mintedShares), _shares[podOwner], pool.totalAssets, pool.totalShares);
    }

    /// @notice Record a beacon-chain rebase (rewards or slash).
    /// @dev Updates `totalAssets` only -- shares are unchanged, share price moves.
    ///      Called by `ValidatorPod._finalizeCheckpoint`. Only callable by the owner's pod.
    ///      A negative `assetsDelta` representing more than the current pool balance
    ///      saturates `totalAssets` to zero (full slash) instead of reverting.
    /// @param podOwner The pod owner
    /// @param assetsDelta Signed change in beacon-chain assets (can be negative)
    function recordBeaconChainRebase(address podOwner, int256 assetsDelta) external {
        address pod = ownerToPod[podOwner];
        if (msg.sender != pod) revert OnlyPod();

        BeaconPool storage pool = _pools[podOwner];
        uint256 newTotal;
        if (assetsDelta >= 0) {
            // forge-lint: disable-next-line(unsafe-typecast)
            newTotal = pool.totalAssets + uint256(assetsDelta);
        } else {
            // forge-lint: disable-next-line(unsafe-typecast)
            uint256 absDelta = uint256(-assetsDelta);
            newTotal = absDelta >= pool.totalAssets ? 0 : pool.totalAssets - absDelta;
        }
        pool.totalAssets = newTotal;

        emit BeaconRebase(podOwner, assetsDelta, newTotal, pool.totalShares);
    }

    /// @notice Backward-compatible balance update entry point.
    /// @dev Translates the legacy `(owner, int256 delta)` signature into share-pool ops:
    ///      - If `delta > 0` AND the owner has no shares yet: treat as a fresh deposit.
    ///      - If `delta > 0` AND the owner already has shares: caller must use the explicit
    ///        `recordBeaconChainDeposit` / `recordBeaconChainRebase` methods. We default to
    ///        `recordBeaconChainDeposit` here for back-compat with the original semantics
    ///        ("positive delta == principal added"); rebases up should not have used this
    ///        legacy path historically.
    ///      - If `delta < 0`: treat as a rebase down (slash).
    ///      Prefer the explicit methods in new code.
    function recordBeaconChainEthBalanceUpdate(address podOwner, int256 sharesDelta) external {
        address pod = ownerToPod[podOwner];
        if (msg.sender != pod) revert OnlyPod();

        if (sharesDelta == 0) revert InvalidDelta();

        BeaconPool storage pool = _pools[podOwner];

        if (sharesDelta > 0) {
            // Treat positive delta as principal deposit (mints shares).
            // forge-lint: disable-next-line(unsafe-typecast)
            uint256 assets = uint256(sharesDelta);
            uint256 mintedShares = _convertToShares(pool, assets);
            if (mintedShares == 0) revert ZeroShares();

            pool.totalAssets += assets;
            pool.totalShares += mintedShares;
            _shares[podOwner] += mintedShares;
            _aggregateShares += mintedShares;

            // forge-lint: disable-next-line(unsafe-typecast)
            emit SharesUpdated(
                podOwner, int256(mintedShares), _shares[podOwner], pool.totalAssets, pool.totalShares
            );
        } else {
            // Negative delta: rebase down (beacon chain slash).
            // forge-lint: disable-next-line(unsafe-typecast)
            uint256 absDelta = uint256(-sharesDelta);
            uint256 newTotal = absDelta >= pool.totalAssets ? 0 : pool.totalAssets - absDelta;
            pool.totalAssets = newTotal;
            emit BeaconRebase(podOwner, sharesDelta, newTotal, pool.totalShares);
        }
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
            (bool sent,) = payable(msg.sender).call{ value: stake }("");
            if (!sent) revert StakeTransferFailed();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delegate beacon chain ETH to an operator (in asset units).
    /// @dev G-02: availability is checked against `convertToAssets(shares[owner])` rather
    ///      than the legacy raw `podOwnerShares[owner]`. The delegation amount is denominated
    ///      in assets so an upstream rebase up before undelegation does not reduce headroom.
    /// @param operator The operator to delegate to
    /// @param amount Amount to delegate (in wei)
    function delegateTo(address operator, uint256 amount) external nonReentrant {
        if (!_operators[operator]) revert NotOperator();
        if (amount == 0) revert ZeroAmount();

        uint256 availableAssets = _convertToAssets(_pools[msg.sender], _shares[msg.sender]);
        uint256 currentDelegated = delegatorTotalDelegated[msg.sender];

        if (availableAssets < currentDelegated + amount) {
            revert InsufficientShares();
        }

        // H-4 FIX: Track delegator in operator's list for proportional slashing
        if (!_isDelegator[operator][msg.sender]) {
            _operatorDelegators[operator].push(msg.sender);
            _isDelegator[operator][msg.sender] = true;
        }

        delegations[msg.sender][operator] += amount;
        operatorDelegatedStake[operator] += amount;
        delegatorTotalDelegated[msg.sender] += amount;

        emit Delegated(msg.sender, operator, amount);
    }

    /// @notice Queue an undelegation from an operator
    /// @dev SECURITY: Undelegation is queued with delay to match EigenLayer model.
    ///      This prevents delegators from instantly rugging operators who are in services.
    ///      During the delay period, if the operator misbehaves, the stake can still be slashed.
    /// @param operator The operator to undelegate from
    /// @param amount Amount to undelegate
    /// @return undelegationRoot Unique identifier for this undelegation
    function queueUndelegation(
        address operator,
        uint256 amount
    )
        external
        nonReentrant
        returns (bytes32 undelegationRoot)
    {
        if (amount == 0) revert ZeroAmount();

        // Check delegator has sufficient delegation (accounting for already queued undelegations)
        uint256 currentDelegation = delegations[msg.sender][operator];
        uint256 alreadyQueued = queuedUndelegations[msg.sender][operator];

        if (currentDelegation < alreadyQueued + amount) revert InsufficientShares();

        // Generate unique undelegation root
        uint256 nonce = undelegationNonce[msg.sender]++;
        undelegationRoot = keccak256(abi.encodePacked(msg.sender, operator, amount, block.number, nonce));

        // Store pending undelegation
        pendingUndelegations[undelegationRoot] = Undelegation({
            delegator: msg.sender,
            operator: operator,
            amount: amount,
            startBlock: uint32(block.number),
            completed: false
        });

        // Track queued undelegations
        queuedUndelegations[msg.sender][operator] += amount;

        emit UndelegationQueued(undelegationRoot, msg.sender, operator, amount);
    }

    /// @notice Complete a pending undelegation after delay period
    /// @param undelegationRoot The undelegation identifier
    function completeUndelegation(bytes32 undelegationRoot) external nonReentrant {
        Undelegation storage undelegation = pendingUndelegations[undelegationRoot];

        // Verify undelegation exists and belongs to caller
        if (undelegation.delegator != msg.sender) revert UndelegationNotFound();
        if (undelegation.completed) revert UndelegationAlreadyCompleted();

        // Check delay has passed (uses same delay as withdrawals)
        if (block.number < undelegation.startBlock + withdrawalDelayBlocks) {
            revert UndelegationNotReady();
        }

        // Mark as completed
        undelegation.completed = true;

        // Get values before updating state
        address operator = undelegation.operator;
        uint256 amount = undelegation.amount;

        // Update queued tracking
        queuedUndelegations[msg.sender][operator] -= amount;

        // Actually perform the undelegation
        delegations[msg.sender][operator] -= amount;
        operatorDelegatedStake[operator] -= amount;
        delegatorTotalDelegated[msg.sender] -= amount;

        // Clean up delegator tracking if fully undelegated
        if (delegations[msg.sender][operator] == 0) {
            _removeDelegator(operator, msg.sender);
        }

        emit UndelegationCompleted(undelegationRoot, msg.sender, operator, amount);
    }

    /// @notice Get undelegation info
    /// @param undelegationRoot The undelegation identifier
    /// @return delegator The delegator address
    /// @return operator The operator address
    /// @return amount The undelegation amount
    /// @return startBlock When the undelegation was queued
    /// @return completableBlock When the undelegation can be completed
    /// @return completed Whether already completed
    function getUndelegationInfo(bytes32 undelegationRoot)
        external
        view
        returns (
            address delegator,
            address operator,
            uint256 amount,
            uint32 startBlock,
            uint32 completableBlock,
            bool completed
        )
    {
        Undelegation storage u = pendingUndelegations[undelegationRoot];
        return (u.delegator, u.operator, u.amount, u.startBlock, u.startBlock + withdrawalDelayBlocks, u.completed);
    }

    /// @notice Get effective delegation (current minus queued undelegations)
    /// @param delegator The delegator address
    /// @param operator The operator address
    /// @return Effective delegation amount
    function getEffectiveDelegation(address delegator, address operator) external view returns (uint256) {
        uint256 current = delegations[delegator][operator];
        uint256 queued = queuedUndelegations[delegator][operator];
        return current > queued ? current - queued : 0;
    }

    /// @notice Internal function to remove a delegator from operator's delegator list
    function _removeDelegator(address operator, address delegator) internal {
        if (_isDelegator[operator][delegator]) {
            _isDelegator[operator][delegator] = false;
            // Remove from array (swap and pop)
            address[] storage delegators = _operatorDelegators[operator];
            uint256 delegatorsLength = delegators.length;
            for (uint256 i = 0; i < delegatorsLength;) {
                if (delegators[i] == delegator) {
                    delegators[i] = delegators[delegatorsLength - 1];
                    delegators.pop();
                    break;
                }
                unchecked {
                    ++i;
                }
            }
        }
    }

    /// @notice Get total amount delegated by an address
    /// @dev H-3 FIX: Now returns the tracked total instead of 0
    function _getTotalDelegatedBy(address delegator) internal view returns (uint256) {
        return delegatorTotalDelegated[delegator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL QUEUE  (G-02: SHARE-DENOMINATED)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Queue a withdrawal denominated in pool shares.
    /// @dev G-02: This is the canonical share-pool withdrawal API. The asset value
    ///      transferred at completion is the live `convertToAssets(shares)`, capped at
    ///      the queue-time snapshot to prevent the staker capturing post-queue rebases up.
    /// @param shares Amount of shares to redeem
    /// @return withdrawalRoot Unique identifier for this withdrawal
    function queueWithdrawal(uint256 shares) external nonReentrant returns (bytes32 withdrawalRoot) {
        if (shares == 0) revert ZeroAmount();

        BeaconPool storage pool = _pools[msg.sender];

        // Must undelegate before withdrawing
        if (delegatorTotalDelegated[msg.sender] > 0) revert HasPendingDelegations();

        uint256 ownerShares = _shares[msg.sender];
        uint256 alreadyQueued = queuedShares[msg.sender];
        if (ownerShares < alreadyQueued + shares) revert InsufficientShares();

        // Snapshot the asset equivalent at queue time. Even if the pool rebases up before
        // completion, the staker only receives this snapshot (rebase-up profit is socialized
        // back to the pool). Rebase-down (slash) takes effect via the live convertToAssets.
        uint256 assetSnapshot = _convertToAssets(pool, shares);

        // Generate unique withdrawal root
        uint256 nonce = withdrawalNonce[msg.sender]++;
        withdrawalRoot = keccak256(abi.encodePacked(msg.sender, shares, assetSnapshot, block.number, nonce));

        // Store pending withdrawal
        pendingWithdrawals[withdrawalRoot] = Withdrawal({
            staker: msg.sender, shares: shares, assets: assetSnapshot, startBlock: uint32(block.number), completed: false
        });

        // Track queued shares
        queuedShares[msg.sender] += shares;

        emit WithdrawalQueued(withdrawalRoot, msg.sender, shares, assetSnapshot);
    }

    /// @notice Complete a pending withdrawal after delay period.
    /// @dev G-02: Burns the queued shares against the pool, transfers ETH = min(snapshot, live).
    ///      Reduces both `pool.totalAssets` and `pool.totalShares` accordingly.
    /// @param withdrawalRoot The withdrawal identifier
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

        uint256 sharesToBurn = withdrawal.shares;
        uint256 snapshotAssets = withdrawal.assets;

        BeaconPool storage pool = _pools[msg.sender];

        // Live valuation at completion. If pool slashed in the interim, this will be
        // smaller than the snapshot -- staker absorbs the slash. If pool gained, the
        // snapshot caps payout (rebase-up profit stays with remaining shareholders, if any).
        uint256 liveAssets = _convertToAssets(pool, sharesToBurn);
        uint256 payout = liveAssets < snapshotAssets ? liveAssets : snapshotAssets;

        // Burn shares against the pool. We never burn more than outstanding.
        uint256 burnableShares = sharesToBurn > pool.totalShares ? pool.totalShares : sharesToBurn;
        pool.totalShares -= burnableShares;
        // payout will not exceed pool.totalAssets because liveAssets <= totalAssets always.
        pool.totalAssets = payout >= pool.totalAssets ? 0 : pool.totalAssets - payout;

        _shares[msg.sender] -= sharesToBurn;
        _aggregateShares -= burnableShares;
        queuedShares[msg.sender] -= sharesToBurn;

        // Transfer ETH from pod to staker
        address pod = ownerToPod[msg.sender];
        if (pod != address(0) && payout > 0) {
            ValidatorPod(payable(pod)).withdrawToStaker(msg.sender, payout);
        }

        emit WithdrawalCompleted(withdrawalRoot, msg.sender, sharesToBurn, payout);
    }

    /// @notice Get withdrawal info
    /// @param withdrawalRoot The withdrawal identifier
    /// @return staker The staker address
    /// @return shares Amount of shares queued
    /// @return assets Snapshot of asset value at queue time
    /// @return startBlock Block when queued
    /// @return completed Whether completed
    /// @return canComplete Whether can be completed now
    function getWithdrawalInfo(bytes32 withdrawalRoot)
        external
        view
        returns (
            address staker,
            uint256 shares,
            uint256 assets,
            uint32 startBlock,
            bool completed,
            bool canComplete
        )
    {
        Withdrawal storage w = pendingWithdrawals[withdrawalRoot];
        staker = w.staker;
        shares = w.shares;
        assets = w.assets;
        startBlock = w.startBlock;
        completed = w.completed;
        canComplete = !completed && block.number >= startBlock + withdrawalDelayBlocks;
    }

    /// @notice Calculate available shares for withdrawal
    /// @param staker The staker address
    /// @return available Shares available to queue for withdrawal
    function getAvailableToWithdraw(address staker) external view returns (uint256 available) {
        // G-02: "Available to withdraw" is now expressed in shares. Delegation reduces the
        // assets the staker can claim, so we subtract the share-equivalent of the delegated
        // assets from their share balance.
        uint256 ownerShares = _shares[staker];
        if (ownerShares == 0) return 0;

        uint256 queued = queuedShares[staker];
        uint256 delegatedAssets = delegatorTotalDelegated[staker];
        uint256 delegatedShares = delegatedAssets == 0 ? 0 : _convertToShares(_pools[staker], delegatedAssets);

        uint256 used = queued + delegatedShares;
        if (ownerShares > used) {
            available = ownerShares - used;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // IRESTAKING IMPLEMENTATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IStaking
    function isOperator(address operator) external view override returns (bool) {
        return _operators[operator];
    }

    /// @inheritdoc IStaking
    function isOperatorActive(address operator) external view override returns (bool) {
        return _operators[operator] && operatorStake[operator] >= minOperatorStakeAmount;
    }

    /// @inheritdoc IStaking
    function getOperatorStake(address operator) external view override returns (uint256) {
        return operatorStake[operator] + operatorDelegatedStake[operator];
    }

    /// @inheritdoc IStaking
    function getOperatorSelfStake(address operator) external view override returns (uint256) {
        return operatorStake[operator];
    }

    /// @inheritdoc IStaking
    function getOperatorDelegatedStake(address operator) external view override returns (uint256) {
        return operatorDelegatedStake[operator];
    }

    /// @inheritdoc IStaking
    function getOperatorDelegatedStakeForAsset(
        address operator,
        Types.Asset calldata asset
    )
        external
        view
        override
        returns (uint256)
    {
        if (asset.kind != Types.AssetKind.Native) return 0;
        return operatorDelegatedStake[operator];
    }

    /// @inheritdoc IStaking
    function getOperatorStakeForAsset(
        address operator,
        Types.Asset calldata asset
    )
        external
        view
        override
        returns (uint256)
    {
        if (asset.kind != Types.AssetKind.Native) return 0;
        return operatorStake[operator] + operatorDelegatedStake[operator];
    }

    /// @inheritdoc IStaking
    function getDelegation(address delegator, address operator) external view override returns (uint256) {
        return delegations[delegator][operator];
    }

    /// @inheritdoc IStaking
    function getTotalDelegation(address delegator) external view override returns (uint256) {
        // G-02: return the asset-equivalent of the delegator's pod shares.
        return _convertToAssets(_pools[delegator], _shares[delegator]);
    }

    /// @inheritdoc IStaking
    function minOperatorStake() external view override returns (uint256) {
        return minOperatorStakeAmount;
    }

    /// @inheritdoc IStaking
    function meetsStakeRequirement(address operator, uint256 required) external view override returns (bool) {
        return operatorStake[operator] + operatorDelegatedStake[operator] >= required;
    }

    /// @inheritdoc IStaking
    function slashForBlueprint(
        address operator,
        uint64,
        /*blueprintId*/
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    )
        external
        override
        returns (uint256 actualSlashed)
    {
        if (!_slashers[msg.sender]) revert NotAuthorizedSlasher();

        actualSlashed = _slash(operator, slashBps);

        emit OperatorSlashed(operator, serviceId, slashBps, evidence);
    }

    /// @inheritdoc IStaking
    function slashForService(
        address operator,
        uint64,
        /*blueprintId*/
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata,
        /*commitments*/
        uint16 slashBps,
        bytes32 evidence
    )
        external
        override
        returns (uint256 actualSlashed)
    {
        if (!_slashers[msg.sender]) revert NotAuthorizedSlasher();

        actualSlashed = _slash(operator, slashBps);

        emit OperatorSlashed(operator, serviceId, slashBps, evidence);
    }

    /// @inheritdoc IStaking
    function slash(
        address operator,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    )
        external
        override
        returns (uint256 actualSlashed)
    {
        if (!_slashers[msg.sender]) revert NotAuthorizedSlasher();

        actualSlashed = _slash(operator, slashBps);

        emit OperatorSlashed(operator, serviceId, slashBps, evidence);
    }

    /// @notice Internal slash implementation
    /// @dev H-4 FIX: Proportionally slashes delegators. Slashing only operates on the
    ///      operator's self-stake and delegated asset claims, not the underlying pool
    ///      shares -- beacon-chain-induced slashes flow through `recordBeaconChainRebase`.
    function _slash(address operator, uint16 slashBps) internal returns (uint256 actualSlashed) {
        uint256 totalStake = operatorStake[operator] + operatorDelegatedStake[operator];

        if (slashBps > BPS_DENOMINATOR) {
            slashBps = uint16(BPS_DENOMINATOR);
        }
        uint256 amount = (totalStake * slashBps) / BPS_DENOMINATOR;

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
                uint256 delegatorsLength = delegators.length;
                for (uint256 i = 0; i < delegatorsLength;) {
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
                    unchecked {
                        ++i;
                    }
                }
            }
            operatorDelegatedStake[operator] -= amount;
        }
    }

    /// @inheritdoc IStaking
    function isSlasher(address account) external view override returns (bool) {
        return _slashers[account];
    }

    /// @inheritdoc IStaking
    /// @dev No-op for ValidatorPodManager - blueprint tracking not needed
    function addBlueprintForOperator(address, uint64) external override {
        // No-op: ValidatorPodManager doesn't track blueprint-specific pools
    }

    /// @inheritdoc IStaking
    /// @dev No-op for ValidatorPodManager - blueprint tracking not needed
    function removeBlueprintForOperator(address, uint64) external override {
        // No-op: ValidatorPodManager doesn't track blueprint-specific pools
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // M-9 FIX: PENDING SLASH TRACKING (NO-OP for ValidatorPodManager)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IStaking
    /// @dev No-op for ValidatorPodManager - pending slash tracking handled differently
    function incrementPendingSlash(address) external override {
        // No-op: ValidatorPodManager uses different withdrawal model
    }

    /// @inheritdoc IStaking
    /// @dev No-op for ValidatorPodManager - pending slash tracking handled differently
    function decrementPendingSlash(address) external override {
        // No-op: ValidatorPodManager uses different withdrawal model
    }

    /// @inheritdoc IStaking
    /// @dev Returns 0 for ValidatorPodManager - pending slash tracking handled differently
    function getPendingSlashCount(address) external pure override returns (uint64) {
        return 0; // ValidatorPodManager doesn't track pending slashes this way
    }

    /// @inheritdoc IStaking
    /// @dev F5 stub: ValidatorPodManager does not host the staking-pool index used by
    ///      `Payments.billSubscription`. Returning zeros makes any subscription that
    ///      points its bill aggregation at this staking adapter degrade to flat-rate
    ///      billing (cumDelta = 0 → bill = 0; lazy-init then seeds baseline at 1 and
    ///      subsequent bills also accrue 0). Beacon-only subscriptions are not a
    ///      supported deployment shape today, so emitting a zero stake-seconds index
    ///      here is intentional and deliberate.
    function getCumStakeSeconds(
        address operator,
        Types.Asset calldata asset
    )
        external
        view
        override
        returns (uint256, uint64, uint256)
    {
        return (0, 0, this.getOperatorStakeForAsset(operator, asset));
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
    // VIEW FUNCTIONS  (G-02: SHARE-POOL)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pod owner's pool share balance.
    /// @param owner The owner address
    /// @return Current pool shares (uint256, share-pool semantics).
    function getShares(address owner) external view returns (uint256) {
        return _shares[owner];
    }

    /// @notice Get pod owner's asset-equivalent restaked balance.
    /// @dev Live valuation: `convertToAssets(shares[owner])`. Reflects rebases.
    /// @param owner The owner address
    /// @return Asset balance in wei
    function getRestakedAssets(address owner) external view returns (uint256) {
        return _convertToAssets(_pools[owner], _shares[owner]);
    }

    /// @notice Check if address has a pod
    /// @param owner Address to check
    /// @return True if pod exists
    function hasPod(address owner) external view returns (bool) {
        return ownerToPod[owner] != address(0);
    }
}
