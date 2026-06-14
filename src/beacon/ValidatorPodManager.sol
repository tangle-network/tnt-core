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
/// @dev Two independent share-pools live in this contract:
///
///        1. Per-pod beacon pool (`BeaconPool`, indexed by pod owner).
///           Tracks beacon-chain principal credited to a pod. Deposits mint shares;
///           rebases (rewards/slashes signalled by checkpoints) move `totalAssets` only.
///
///        2. Per-operator delegation pool (`DelegationPool`, indexed by operator).
///           Tracks delegated assets a delegator has committed to a specific operator.
///           `delegateTo` mints shares at the current exchange rate; slashing decrements
///           `totalAssets` only -- every delegator's effective claim drops proportionally
///           in a single SSTORE regardless of how many delegators the operator has.
///
///      Virtual offsets (`VIRTUAL_SHARES = VIRTUAL_ASSETS = 1e3`) defend against
///      first-depositor inflation attacks on both pools.
///
///      External ABI: `delegations(d,o)` and `operatorDelegatedStake(o)` return
///      asset-denominated values derived from the per-operator share pool. Post-slash,
///      those values reflect the slashed amount automatically via share-to-asset
///      conversion.
contract ValidatorPodManager is IStaking, Ownable, ReentrancyGuard {
    using Math for uint256;

    uint256 public constant BPS_DENOMINATOR = 10_000;

    /// @notice Virtual shares/assets offset to prevent first-depositor inflation attack.
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
    // STATE - BEACON SHARE POOL (per pod)
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

    /// @notice Total amount delegated by a delegator (in asset units, deposit-accounted).
    /// @dev Deposit/withdraw counter used for headroom checks; NOT slash-adjusted. It
    ///      overstates committed delegation after slashes, which is conservative — it
    ///      can only block new delegations, never permit over-delegation. Live
    ///      per-(delegator, operator) asset value is available via `getDelegation`.
    /// @dev INVARIANT: `delegatorTotalDelegated[d] == Σ_o _delegatorOperatorDelegated[d][o]`.
    ///      Maintained by decrementing both counters by the same delta on every
    ///      undelegation completion so the aggregate can always reach 0 once every
    ///      per-operator commitment is fully unwound — even after slashing reduced the
    ///      live valuation below the deposited principal (the bug this split fixes:
    ///      previously a single asset-denominated counter could never be paid down to 0
    ///      after a slash, permanently bricking `queueWithdrawal`).
    mapping(address delegator => uint256) public delegatorTotalDelegated;

    /// @notice Authorized slashers
    mapping(address => bool) internal _slashers;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - WITHDRAWAL QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Withdrawal request structure
    /// @dev `shares` is denominated in pool shares. `assets` is the asset value
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

    /// @notice Beacon-pool shares locked as collateral behind a delegator's live delegations.
    /// @dev INVARIANT (no-double-spend of restaked principal): for every owner,
    ///        `_shares[owner] >= queuedShares[owner] + delegatedShares[owner]`.
    ///      A beacon share is in at most one of {free, queued-for-withdrawal, delegated}.
    ///      `delegateTo` locks shares here; `completeUndelegation` releases the shares the
    ///      delegator still has economic claim to and BURNS the rest (the slashed portion),
    ///      so a slash permanently destroys the corresponding beacon principal instead of
    ///      letting the delegator withdraw it. `queueWithdrawal` may only draw on free shares.
    mapping(address owner => uint256) public delegatedShares;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE - UNDELEGATION QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Undelegation request structure
    /// @dev Modeled on EigenLayer's queued withdrawal pattern - undelegation is not instant.
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
    // STATE - DELEGATION SHARE POOL (per operator) -- appended; no relayout
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Per-operator delegation share-pool. `totalAssets` is the slashable asset
    ///         balance delegated to this operator; `totalShares` is the outstanding
    ///         delegator claim balance. Slash decrements `totalAssets` only in O(1),
    ///         leaving share balances untouched so every delegator's effective amount
    ///         drops proportionally.
    struct DelegationPool {
        uint256 totalAssets;
        uint256 totalShares;
    }

    /// @notice Delegation pool state by operator.
    mapping(address operator => DelegationPool) internal _operatorDelegationPools;

    /// @notice Per-(delegator, operator) delegation share balance.
    mapping(address delegator => mapping(address operator => uint256)) internal _delegationShares;

    /// @notice Per-(delegator, operator) deposit-accounted committed amount (asset units).
    /// @dev Partition of `delegatorTotalDelegated[d]` by operator. NOT slash-adjusted.
    ///      Used so that when a delegator fully unwinds an operator (their pool shares
    ///      hit 0), the *entire* deposited commitment for that operator can be cleared
    ///      from both this entry and the aggregate counter, regardless of how much value
    ///      was lost to slashing. This is what lets `delegatorTotalDelegated` reach 0 and
    ///      unblocks `queueWithdrawal` after a slash.
    mapping(address delegator => mapping(address operator => uint256)) internal _delegatorOperatorDelegated;

    /// @notice Per-(delegator, operator) beacon-pool shares escrowed behind this delegation.
    /// @dev Partition of `delegatedShares[delegator]` by operator. Locked on `delegateTo`,
    ///      and on `completeUndelegation` the delegator gets back only the share-fraction
    ///      they still have economic claim to after slashing; the remainder is burned from
    ///      their beacon pool so slashed principal can never be withdrawn (closes the
    ///      "service slash is non-punitive" finding).
    mapping(address delegator => mapping(address operator => uint256)) internal _delegatorOperatorEscrowShares;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event PodCreated(address indexed owner, address indexed pod);

    /// @notice Emitted when beacon-pool shares are minted/burned for an owner.
    event SharesUpdated(
        address indexed owner, int256 sharesDelta, uint256 newShares, uint256 totalAssets, uint256 totalSharesPool
    );

    /// @notice Emitted when the beacon pool's totalAssets is updated by a beacon chain
    ///         rebase (rewards/slash). Shares are unchanged; only the share price moves.
    event BeaconRebase(address indexed owner, int256 assetsDelta, uint256 newTotalAssets, uint256 totalSharesPool);

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

    /// @notice Emitted when an operator's delegation pool is slashed. Indexers should
    ///         use this together with cached per-delegator share balances to recompute
    ///         effective per-delegator stake; no per-delegator event is emitted because
    ///         the slash is O(1) on-chain (totalAssets decrement only).
    event OperatorPoolSlashed(
        address indexed operator, uint256 slashedAssets, uint256 newTotalAssets, uint256 totalShares
    );

    event WithdrawalQueued(bytes32 indexed withdrawalRoot, address indexed staker, uint256 shares, uint256 assets);
    event WithdrawalCompleted(bytes32 indexed withdrawalRoot, address indexed staker, uint256 shares, uint256 assets);
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
    function getPod(address owner) external view returns (address) {
        return ownerToPod[owner];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BEACON SHARE-POOL CONVERSION HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Convert assets to shares for a beacon pool, rounding shares DOWN.
    function _convertToShares(BeaconPool storage pool, uint256 assets) internal view returns (uint256) {
        return assets.mulDiv(pool.totalShares + VIRTUAL_SHARES, pool.totalAssets + VIRTUAL_ASSETS, Math.Rounding.Floor);
    }

    /// @notice Convert shares to assets for a beacon pool, rounding assets DOWN.
    function _convertToAssets(BeaconPool storage pool, uint256 shares) internal view returns (uint256) {
        return shares.mulDiv(pool.totalAssets + VIRTUAL_ASSETS, pool.totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);
    }

    /// @notice Public view: convert assets to shares for `owner`'s beacon pool.
    function convertToShares(address owner, uint256 assets) external view returns (uint256) {
        return _convertToShares(_pools[owner], assets);
    }

    /// @notice Public view: convert shares to assets for `owner`'s beacon pool.
    function convertToAssets(address owner, uint256 shares) external view returns (uint256) {
        return _convertToAssets(_pools[owner], shares);
    }

    /// @notice Public view: total assets in `owner`'s beacon pool (live beacon-chain ETH).
    function totalAssetsOf(address owner) external view returns (uint256) {
        return _pools[owner].totalAssets;
    }

    /// @notice Public view: total shares outstanding in `owner`'s beacon pool.
    function totalSharesOf(address owner) external view returns (uint256) {
        return _pools[owner].totalShares;
    }

    /// @notice Public view: aggregate beacon-pool shares (informational).
    function totalShares() external view returns (uint256) {
        return _aggregateShares;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION SHARE-POOL CONVERSION HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Convert assets to shares for an operator delegation pool, rounding DOWN.
    function _convertDelegationToShares(DelegationPool storage pool, uint256 assets) internal view returns (uint256) {
        return assets.mulDiv(pool.totalShares + VIRTUAL_SHARES, pool.totalAssets + VIRTUAL_ASSETS, Math.Rounding.Floor);
    }

    /// @notice Convert shares to assets for an operator delegation pool, rounding DOWN.
    function _convertDelegationToAssets(DelegationPool storage pool, uint256 shares) internal view returns (uint256) {
        return shares.mulDiv(pool.totalAssets + VIRTUAL_ASSETS, pool.totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);
    }

    /// @notice Public view: per-(delegator, operator) live asset value.
    /// @dev Preserves the original `delegations(d, o)` selector. Returns the asset
    ///      equivalent of the delegator's current operator-pool shares, which
    ///      automatically reflects any slashing.
    function delegations(address delegator, address operator) external view returns (uint256) {
        return _convertDelegationToAssets(_operatorDelegationPools[operator], _delegationShares[delegator][operator]);
    }

    /// @notice Public view: total assets currently delegated to an operator.
    /// @dev Preserves the original `operatorDelegatedStake(o)` selector and semantics
    ///      (assets, not shares). Drops to reflect slashing in O(1).
    function operatorDelegatedStake(address operator) external view returns (uint256) {
        return _operatorDelegationPools[operator].totalAssets;
    }

    /// @notice Public view: per-(delegator, operator) share balance.
    function getDelegationShares(address delegator, address operator) external view returns (uint256) {
        return _delegationShares[delegator][operator];
    }

    /// @notice Public view: operator delegation pool totals.
    function getOperatorDelegationPool(address operator)
        external
        view
        returns (uint256 poolAssets, uint256 poolShares)
    {
        DelegationPool storage p = _operatorDelegationPools[operator];
        return (p.totalAssets, p.totalShares);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BEACON SHARE MANAGEMENT (called by pods)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record a beacon-chain principal deposit (validator credential proof).
    /// @dev Mints pool shares for `podOwner` against the current pool exchange rate.
    ///      Called by `ValidatorPod.verifyWithdrawalCredentials` when new principal
    ///      becomes attributable to this pod. Only callable by the owner's pod.
    /// @param podOwner The pod owner
    /// @param assets Principal added to the pod (in wei, must be > 0)
    /// @return mintedShares Number of shares minted to `podOwner`
    function recordBeaconChainDeposit(address podOwner, uint256 assets) external returns (uint256 mintedShares) {
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

        // forge-lint: disable-next-line(unsafe-typecast)
        emit SharesUpdated(podOwner, int256(mintedShares), _shares[podOwner], pool.totalAssets, pool.totalShares);
    }

    /// @notice Record a beacon-chain rebase (rewards or slash).
    /// @dev Updates `totalAssets` only; shares are unchanged so the share price moves.
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

    /// @notice Deregister as an operator and withdraw self-stake.
    /// @dev Cannot deregister while the operator's delegation pool holds assets.
    function deregisterOperator() external nonReentrant {
        if (!_operators[msg.sender]) revert NotOperator();

        if (_operatorDelegationPools[msg.sender].totalAssets > 0) {
            revert HasPendingDelegations();
        }

        uint256 stake = operatorStake[msg.sender];

        _operators[msg.sender] = false;
        operatorStake[msg.sender] = 0;

        emit OperatorDeregistered(msg.sender);

        if (stake > 0) {
            (bool sent,) = payable(msg.sender).call{ value: stake }("");
            if (!sent) revert StakeTransferFailed();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delegate beacon-pool assets to an operator.
    /// @dev Mints operator-pool shares for the delegator at the current pool rate.
    ///      `availableAssets` is computed off the delegator's live beacon-pool share
    ///      valuation; `delegatorTotalDelegated` is a conservative deposit counter
    ///      (not slash-adjusted) used to bound new commitments.
    /// @param operator The operator to delegate to
    /// @param amount Amount to delegate (in wei)
    function delegateTo(address operator, uint256 amount) external nonReentrant {
        if (!_operators[operator]) revert NotOperator();
        if (amount == 0) revert ZeroAmount();

        // Only beacon shares that are neither already queued for withdrawal nor already
        // locked behind another delegation may back a new delegation. Enforcing this in
        // share space (the canonical custody unit) — instead of trusting the conservative
        // asset counter alone — closes the double-count where shares queued for withdrawal
        // were delegated again, then withdrawn for real, leaving a phantom delegation.
        // INVARIANT: _shares[d] >= queuedShares[d] + delegatedShares[d] after this call.
        BeaconPool storage beaconPool = _pools[msg.sender];
        uint256 ownerShares = _shares[msg.sender];
        uint256 lockedShares = queuedShares[msg.sender] + delegatedShares[msg.sender];
        uint256 freeShares = ownerShares > lockedShares ? ownerShares - lockedShares : 0;
        uint256 freeAssets = _convertToAssets(beaconPool, freeShares);
        if (freeAssets < amount) {
            revert InsufficientShares();
        }

        // Lock the beacon shares that collateralize this delegation, at the current pool rate.
        // Over-delegation is already prevented by the `freeAssets < amount` gate above; this
        // escrow is what `completeUndelegation` later releases (surviving) and burns (slashed).
        // Floor a non-zero delegation to at least one share and clamp to the free shares so
        // the no-double-spend INVARIANT (_shares >= queued + delegated) can never be violated.
        uint256 escrowShares = _convertToShares(beaconPool, amount);
        if (escrowShares == 0) escrowShares = 1;
        if (escrowShares > freeShares) escrowShares = freeShares;

        DelegationPool storage pool = _operatorDelegationPools[operator];
        uint256 mintedShares = _convertDelegationToShares(pool, amount);
        if (mintedShares == 0) revert ZeroShares();

        pool.totalAssets += amount;
        pool.totalShares += mintedShares;
        _delegationShares[msg.sender][operator] += mintedShares;

        // Lock the collateralizing beacon shares.
        delegatedShares[msg.sender] += escrowShares;
        _delegatorOperatorEscrowShares[msg.sender][operator] += escrowShares;

        // Maintain the aggregate counter and its per-operator partition in lockstep so
        // the INVARIANT (aggregate == Σ per-operator) holds.
        delegatorTotalDelegated[msg.sender] += amount;
        _delegatorOperatorDelegated[msg.sender][operator] += amount;

        emit Delegated(msg.sender, operator, amount);
    }

    /// @notice Queue an undelegation from an operator.
    /// @dev Asset-denominated input. The amount is locked in (not share-snapshotted) so
    ///      slashes that occur between queueing and completion proportionally reduce
    ///      the realized payout via `_convertDelegationToShares` at completion time.
    /// @param operator The operator to undelegate from
    /// @param amount Amount to undelegate (in wei)
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

        uint256 currentDelegation =
            _convertDelegationToAssets(_operatorDelegationPools[operator], _delegationShares[msg.sender][operator]);
        uint256 alreadyQueued = queuedUndelegations[msg.sender][operator];

        if (currentDelegation < alreadyQueued + amount) revert InsufficientShares();

        uint256 nonce = undelegationNonce[msg.sender]++;
        undelegationRoot = keccak256(abi.encodePacked(msg.sender, operator, amount, block.number, nonce));

        pendingUndelegations[undelegationRoot] = Undelegation({
            delegator: msg.sender,
            operator: operator,
            amount: amount,
            startBlock: uint32(block.number),
            completed: false
        });

        queuedUndelegations[msg.sender][operator] += amount;

        emit UndelegationQueued(undelegationRoot, msg.sender, operator, amount);
    }

    /// @notice Complete a pending undelegation after delay period.
    /// @dev Burns operator-pool shares matching the requested asset amount at the
    ///      current exchange rate (so slashes during the delay are realized by the
    ///      delegator). If the live valuation is below the requested asset amount,
    ///      burns all of the delegator's remaining shares for this operator and
    ///      transfers what is available.
    function completeUndelegation(bytes32 undelegationRoot) external nonReentrant {
        Undelegation storage undelegation = pendingUndelegations[undelegationRoot];

        if (undelegation.delegator != msg.sender) revert UndelegationNotFound();
        if (undelegation.completed) revert UndelegationAlreadyCompleted();

        if (block.number < undelegation.startBlock + withdrawalDelayBlocks) {
            revert UndelegationNotReady();
        }

        undelegation.completed = true;

        address operator = undelegation.operator;
        uint256 amount = undelegation.amount;

        queuedUndelegations[msg.sender][operator] -= amount;

        DelegationPool storage pool = _operatorDelegationPools[operator];
        uint256 ownerShares = _delegationShares[msg.sender][operator];
        uint256 liveAssets = _convertDelegationToAssets(pool, ownerShares);

        uint256 realizedAssets;
        uint256 sharesBurned;
        if (liveAssets <= amount) {
            // Slashed below the requested amount: realize whatever is left and zero out.
            realizedAssets = liveAssets;
            sharesBurned = ownerShares;
        } else {
            realizedAssets = amount;
            sharesBurned = _convertDelegationToShares(pool, amount);
            if (sharesBurned > ownerShares) sharesBurned = ownerShares;
        }

        uint256 remainingShares = ownerShares - sharesBurned;
        _delegationShares[msg.sender][operator] = remainingShares;
        pool.totalShares -= sharesBurned;
        // Share→asset conversion can round a hair above the pool's tracked assets
        // (e.g. live valuation 16.5e18+dust vs totalAssets 16.5e18 when this delegator
        // holds all shares post-slash). Clamp so the decrement — and the realized payout —
        // never exceed the pool, which would underflow and re-brick the very withdrawal
        // this path exists to unblock.
        if (realizedAssets > pool.totalAssets) realizedAssets = pool.totalAssets;
        pool.totalAssets -= realizedAssets;

        // Pay down the deposit-accounted counters. The counter is asset-denominated
        // against the *deposited* principal, not the slashed live valuation, so we must
        // NOT decrement by `realizedAssets` (which can be below the deposited amount
        // after a slash) — doing so would leave a permanent residue that can never reach
        // 0 and would brick `queueWithdrawal` forever.
        //
        // When this fully unwinds the delegator's position with this operator
        // (remainingShares == 0), clear the ENTIRE per-operator deposited commitment from
        // both counters — that residue is exactly the value lost to slashing and is no
        // longer recoverable, so it must not keep blocking withdrawals.
        //
        // On a partial undelegation (remainingShares > 0), decrement by the requested
        // `amount`. Since `queueUndelegation` bounds `amount` by the live valuation,
        // `amount <= depositedForOperator`, so this can never underflow the per-operator
        // entry; we clamp defensively regardless. This preserves the
        // INVARIANT (aggregate == Σ per-operator) on every path.
        uint256 depositedForOperator = _delegatorOperatorDelegated[msg.sender][operator];
        uint256 counterDelta;
        if (remainingShares == 0) {
            counterDelta = depositedForOperator;
        } else {
            counterDelta = amount <= depositedForOperator ? amount : depositedForOperator;
        }

        _delegatorOperatorDelegated[msg.sender][operator] = depositedForOperator - counterDelta;

        uint256 counter = delegatorTotalDelegated[msg.sender];
        delegatorTotalDelegated[msg.sender] = counter >= counterDelta ? counter - counterDelta : 0;

        // Reconcile the escrowed beacon shares behind this delegation. The portion of the
        // escrow covered by this unwind is proportional to the delegation-pool shares burned.
        // Of that covered escrow, the delegator only KEEPS the slash-adjusted fraction
        // (realized value / deposited value); the slashed remainder is BURNED from their
        // beacon pool so the principal lost to slashing can never be withdrawn. This is what
        // makes a service slash punitive: without it the delegator releases their full escrow
        // and withdraws 100% of beacon principal regardless of the slash.
        // INVARIANT after release+burn: a delegator's withdrawable beacon principal reflects
        // every slash that hit the operators they delegated to.
        uint256 escrowForOperator = _delegatorOperatorEscrowShares[msg.sender][operator];
        if (escrowForOperator > 0) {
            uint256 escrowCovered;
            if (remainingShares == 0) {
                // Full unwind of this operator: reconcile the entire escrow.
                escrowCovered = escrowForOperator;
            } else {
                // Partial unwind: cover escrow proportional to delegation shares burned.
                escrowCovered = escrowForOperator.mulDiv(sharesBurned, ownerShares, Math.Rounding.Floor);
                if (escrowCovered > escrowForOperator) escrowCovered = escrowForOperator;
            }

            // Surviving (releasable) escrow = covered * realized / depositedCovered.
            // depositedCovered is the deposit-accounted value of the portion being unwound.
            uint256 depositedCovered = counterDelta;
            uint256 escrowToRelease;
            if (depositedCovered == 0 || realizedAssets >= depositedCovered) {
                // No value lost on the covered portion: release all covered escrow.
                escrowToRelease = escrowCovered;
            } else {
                escrowToRelease = escrowCovered.mulDiv(realizedAssets, depositedCovered, Math.Rounding.Floor);
            }
            uint256 escrowToBurn = escrowCovered - escrowToRelease;

            // Unlock the covered escrow from the delegation locks.
            _delegatorOperatorEscrowShares[msg.sender][operator] = escrowForOperator - escrowCovered;
            uint256 locked = delegatedShares[msg.sender];
            delegatedShares[msg.sender] = locked >= escrowCovered ? locked - escrowCovered : 0;

            // Burn the slashed portion out of the delegator's beacon pool: destroy the
            // shares and the principal they represent so they are never withdrawable.
            if (escrowToBurn > 0) {
                BeaconPool storage bp = _pools[msg.sender];
                uint256 burnShares = escrowToBurn > _shares[msg.sender] ? _shares[msg.sender] : escrowToBurn;
                if (burnShares > bp.totalShares) burnShares = bp.totalShares;
                uint256 burnAssets = _convertToAssets(bp, burnShares);
                _shares[msg.sender] -= burnShares;
                _aggregateShares -= burnShares;
                bp.totalShares -= burnShares;
                bp.totalAssets = burnAssets >= bp.totalAssets ? 0 : bp.totalAssets - burnAssets;
                // forge-lint: disable-next-line(unsafe-typecast)
                emit BeaconRebase(msg.sender, -int256(burnAssets), bp.totalAssets, bp.totalShares);
            }
        }

        emit UndelegationCompleted(undelegationRoot, msg.sender, operator, realizedAssets);
    }

    /// @notice Get undelegation info.
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

    /// @notice Get effective delegation (current asset value minus queued undelegations).
    function getEffectiveDelegation(address delegator, address operator) external view returns (uint256) {
        uint256 current =
            _convertDelegationToAssets(_operatorDelegationPools[operator], _delegationShares[delegator][operator]);
        uint256 queued = queuedUndelegations[delegator][operator];
        return current > queued ? current - queued : 0;
    }

    /// @notice Get total amount delegated by an address (deposit-accounted counter).
    function _getTotalDelegatedBy(address delegator) internal view returns (uint256) {
        return delegatorTotalDelegated[delegator];
    }

    /// @notice Per-(delegator, operator) deposit-accounted committed amount (asset units).
    /// @dev Partition of `delegatorTotalDelegated`; NOT slash-adjusted. Use `getDelegation`
    ///      for the live, slash-adjusted asset value.
    function delegatorOperatorDelegated(address delegator, address operator) external view returns (uint256) {
        return _delegatorOperatorDelegated[delegator][operator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL QUEUE (beacon share-denominated)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Queue a withdrawal denominated in beacon-pool shares.
    /// @dev The asset value transferred at completion is the live `convertToAssets(shares)`,
    ///      capped at the queue-time snapshot to prevent the staker capturing post-queue
    ///      rebases up.
    function queueWithdrawal(uint256 shares) external nonReentrant returns (bytes32 withdrawalRoot) {
        if (shares == 0) revert ZeroAmount();

        BeaconPool storage pool = _pools[msg.sender];

        if (delegatorTotalDelegated[msg.sender] > 0) revert HasPendingDelegations();

        uint256 ownerShares = _shares[msg.sender];
        uint256 alreadyQueued = queuedShares[msg.sender];
        if (ownerShares < alreadyQueued + shares) revert InsufficientShares();

        uint256 assetSnapshot = _convertToAssets(pool, shares);

        uint256 nonce = withdrawalNonce[msg.sender]++;
        withdrawalRoot = keccak256(abi.encodePacked(msg.sender, shares, assetSnapshot, block.number, nonce));

        pendingWithdrawals[withdrawalRoot] = Withdrawal({
            staker: msg.sender,
            shares: shares,
            assets: assetSnapshot,
            startBlock: uint32(block.number),
            completed: false
        });

        queuedShares[msg.sender] += shares;

        emit WithdrawalQueued(withdrawalRoot, msg.sender, shares, assetSnapshot);
    }

    /// @notice Complete a pending withdrawal after delay period.
    /// @dev Burns the queued shares against the pool, transfers ETH = min(snapshot, live).
    function completeWithdrawal(bytes32 withdrawalRoot) external nonReentrant {
        Withdrawal storage withdrawal = pendingWithdrawals[withdrawalRoot];

        if (withdrawal.staker != msg.sender) revert WithdrawalNotFound();
        if (withdrawal.completed) revert WithdrawalAlreadyCompleted();

        if (block.number < withdrawal.startBlock + withdrawalDelayBlocks) {
            revert WithdrawalNotReady();
        }

        withdrawal.completed = true;

        uint256 sharesToBurn = withdrawal.shares;
        uint256 snapshotAssets = withdrawal.assets;

        BeaconPool storage pool = _pools[msg.sender];

        uint256 liveAssets = _convertToAssets(pool, sharesToBurn);
        uint256 payout = liveAssets < snapshotAssets ? liveAssets : snapshotAssets;

        uint256 burnableShares = sharesToBurn > pool.totalShares ? pool.totalShares : sharesToBurn;
        pool.totalShares -= burnableShares;
        pool.totalAssets = payout >= pool.totalAssets ? 0 : pool.totalAssets - payout;

        _shares[msg.sender] -= sharesToBurn;
        _aggregateShares -= burnableShares;
        queuedShares[msg.sender] -= sharesToBurn;

        address pod = ownerToPod[msg.sender];
        if (pod != address(0) && payout > 0) {
            ValidatorPod(payable(pod)).withdrawToStaker(msg.sender, payout);
        }

        emit WithdrawalCompleted(withdrawalRoot, msg.sender, sharesToBurn, payout);
    }

    /// @notice Get withdrawal info.
    function getWithdrawalInfo(bytes32 withdrawalRoot)
        external
        view
        returns (address staker, uint256 shares, uint256 assets, uint32 startBlock, bool completed, bool canComplete)
    {
        Withdrawal storage w = pendingWithdrawals[withdrawalRoot];
        staker = w.staker;
        shares = w.shares;
        assets = w.assets;
        startBlock = w.startBlock;
        completed = w.completed;
        canComplete = !completed && block.number >= startBlock + withdrawalDelayBlocks;
    }

    /// @notice Calculate available (free) beacon-pool shares for withdrawal.
    /// @dev Mirrors the no-double-spend INVARIANT enforced in `delegateTo`/`queueWithdrawal`:
    ///      free = ownerShares - queuedShares - delegatedShares. Uses the exact escrowed
    ///      delegated-share count (not an asset-counter conversion) so the view matches the
    ///      shares actually locked behind live delegations.
    function getAvailableToWithdraw(address staker) external view returns (uint256 available) {
        uint256 ownerShares = _shares[staker];
        if (ownerShares == 0) return 0;

        uint256 used = queuedShares[staker] + delegatedShares[staker];
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
        return operatorStake[operator] + _operatorDelegationPools[operator].totalAssets;
    }

    /// @inheritdoc IStaking
    function getOperatorSelfStake(address operator) external view override returns (uint256) {
        return operatorStake[operator];
    }

    /// @inheritdoc IStaking
    function getOperatorDelegatedStake(address operator) external view override returns (uint256) {
        return _operatorDelegationPools[operator].totalAssets;
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
        return _operatorDelegationPools[operator].totalAssets;
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
        return operatorStake[operator] + _operatorDelegationPools[operator].totalAssets;
    }

    /// @inheritdoc IStaking
    function getDelegation(address delegator, address operator) external view override returns (uint256) {
        return _convertDelegationToAssets(_operatorDelegationPools[operator], _delegationShares[delegator][operator]);
    }

    /// @inheritdoc IStaking
    function getTotalDelegation(address delegator) external view override returns (uint256) {
        // Asset-equivalent of the delegator's pod shares (live valuation).
        return _convertToAssets(_pools[delegator], _shares[delegator]);
    }

    /// @inheritdoc IStaking
    function minOperatorStake() external view override returns (uint256) {
        return minOperatorStakeAmount;
    }

    /// @inheritdoc IStaking
    function meetsStakeRequirement(address operator, uint256 required) external view override returns (bool) {
        return operatorStake[operator] + _operatorDelegationPools[operator].totalAssets >= required;
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

    /// @notice Internal slash. O(1): one SLOAD/SSTORE for self-stake, one for the
    ///         delegation pool's `totalAssets`. Per-delegator effective stake drops
    ///         proportionally via the unchanged share balances.
    /// @dev Off-chain consumers can derive per-delegator slash impact from the
    ///      `OperatorPoolSlashed` event plus cached share balances.
    function _slash(address operator, uint16 slashBps) internal returns (uint256 actualSlashed) {
        if (slashBps > BPS_DENOMINATOR) {
            slashBps = uint16(BPS_DENOMINATOR);
        }

        DelegationPool storage pool = _operatorDelegationPools[operator];
        uint256 selfBefore = operatorStake[operator];
        uint256 delegatedBefore = pool.totalAssets;
        uint256 totalStake = selfBefore + delegatedBefore;

        uint256 amount = (totalStake * slashBps) / BPS_DENOMINATOR;
        actualSlashed = amount;

        // Self-stake first.
        uint256 selfSlash = amount > selfBefore ? selfBefore : amount;
        if (selfSlash > 0) {
            operatorStake[operator] = selfBefore - selfSlash;
            amount -= selfSlash;
        }

        // Delegation pool: decrement totalAssets only; shares are untouched so every
        // delegator's effective claim drops proportionally in a single SSTORE.
        if (amount > 0 && delegatedBefore > 0) {
            uint256 poolSlash = amount > delegatedBefore ? delegatedBefore : amount;
            uint256 newTotal = delegatedBefore - poolSlash;
            pool.totalAssets = newTotal;
            emit OperatorPoolSlashed(operator, poolSlash, newTotal, pool.totalShares);
        }
    }

    /// @inheritdoc IStaking
    function isSlasher(address account) external view override returns (bool) {
        return _slashers[account];
    }

    /// @inheritdoc IStaking
    function addBlueprintForOperator(address, uint64) external override {
        // No-op: ValidatorPodManager doesn't track blueprint-specific pools.
    }

    /// @inheritdoc IStaking
    function removeBlueprintForOperator(address, uint64) external override {
        // No-op: ValidatorPodManager doesn't track blueprint-specific pools.
    }

    /// @inheritdoc IStaking
    function incrementPendingSlash(address) external override {
        // No-op: ValidatorPodManager uses a different withdrawal model.
    }

    /// @inheritdoc IStaking
    function decrementPendingSlash(address) external override {
        // No-op: ValidatorPodManager uses a different withdrawal model.
    }

    /// @inheritdoc IStaking
    function getPendingSlashCount(address) external pure override returns (uint64) {
        return 0;
    }

    /// @inheritdoc IStaking
    /// @dev Subscription billing does not source its stake-seconds index from this
    ///      adapter today; returning zeros makes any subscription wired to this
    ///      staking adapter degrade to flat-rate billing (cumDelta = 0 → bill = 0).
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

    function addSlasher(address slasher) external onlyOwner {
        _slashers[slasher] = true;
        emit SlasherUpdated(slasher, true);
    }

    function removeSlasher(address slasher) external onlyOwner {
        _slashers[slasher] = false;
        emit SlasherUpdated(slasher, false);
    }

    function setMinOperatorStake(uint256 amount) external onlyOwner {
        minOperatorStakeAmount = amount;
    }

    function setBeaconOracle(address _beaconOracle) external onlyOwner {
        if (_beaconOracle == address(0)) revert ZeroAddress();
        beaconOracle = IBeaconOracle(_beaconOracle);
    }

    function setWithdrawalDelay(uint32 newDelay) external onlyOwner {
        if (newDelay > MAX_WITHDRAWAL_DELAY) revert ExceedsMaxDelay();
        uint32 oldDelay = withdrawalDelayBlocks;
        withdrawalDelayBlocks = newDelay;
        emit WithdrawalDelaySet(oldDelay, newDelay);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS (beacon pool)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get pod owner's beacon-pool share balance as a signed integer.
    /// @dev Storage is unsigned; the cast is lossless for any practical balance
    ///      (bounded by Ether supply ≪ 2^128 wei). Callers preferring unsigned
    ///      should use `getSharesUint`.
    function getShares(address owner) external view returns (int256) {
        uint256 raw = _shares[owner];
        if (raw > uint256(type(int256).max)) raw = uint256(type(int256).max);
        // forge-lint: disable-next-line(unsafe-typecast)
        return int256(raw);
    }

    /// @notice Get pod owner's beacon-pool share balance as an unsigned integer.
    function getSharesUint(address owner) external view returns (uint256) {
        return _shares[owner];
    }

    /// @notice Get pod owner's asset-equivalent restaked balance (live valuation).
    function getRestakedAssets(address owner) external view returns (uint256) {
        return _convertToAssets(_pools[owner], _shares[owner]);
    }

    /// @notice Check if address has a pod.
    function hasPod(address owner) external view returns (bool) {
        return ownerToPod[owner] != address(0);
    }
}
