// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Types } from "../libraries/Types.sol";
import { DelegationErrors } from "./DelegationErrors.sol";

/// @title DelegationStorage
/// @notice Centralized storage layout for the multi-asset delegation system
/// @dev All manager contracts inherit from this to share storage
abstract contract DelegationStorage {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    uint256 public constant PRECISION = 1e18;
    uint256 public constant BPS_DENOMINATOR = 10_000;

    // C-1 FIX: Virtual shares/assets offset to prevent first depositor inflation attack.
    // Following OpenZeppelin ERC4626 pattern. The offset makes it economically infeasible
    // for an attacker to inflate the exchange rate via donation attacks.
    // With these values, attacker would need to donate VIRTUAL_SHARES tokens to gain
    // any meaningful inflation, making the attack unprofitable.
    uint256 public constant VIRTUAL_SHARES = 1e8;
    uint256 public constant VIRTUAL_ASSETS = 1;

    // Lock durations in seconds
    uint64 public constant LOCK_ONE_MONTH = 30 days;
    uint64 public constant LOCK_TWO_MONTHS = 60 days;
    uint64 public constant LOCK_THREE_MONTHS = 90 days;
    uint64 public constant LOCK_SIX_MONTHS = 180 days;

    // Lock multipliers in BPS (10000 = 1x)
    uint16 public constant MULTIPLIER_NONE = 10_000;
    uint16 public constant MULTIPLIER_ONE_MONTH = 11_000;
    uint16 public constant MULTIPLIER_TWO_MONTHS = 12_000;
    uint16 public constant MULTIPLIER_THREE_MONTHS = 13_000;
    uint16 public constant MULTIPLIER_SIX_MONTHS = 16_000;

    // M-9 FIX: Minimum lock amount to prevent lock multiplier bypass via small deposits
    // Set to 0.01 ETH (1e16 wei) equivalent to prevent dust attacks while remaining accessible
    uint256 public constant MIN_LOCK_AMOUNT = 1e16;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROLES
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SLASHER_ROLE = keccak256("SLASHER_ROLE");
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("ASSET_MANAGER_ROLE");
    bytes32 public constant TANGLE_ROLE = keccak256("TANGLE_ROLE");

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUND MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Current round number
    uint64 public currentRound;

    /// @notice Seconds per round (used for time-based rate limiting)
    uint64 public roundDuration;

    /// @notice Timestamp when the last round was advanced
    uint64 public lastRoundAdvance;

    // ═══════════════════════════════════════════════════════════════════════════
    // DELAYS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delay for unstaking delegations (in rounds)
    uint64 public delegationBondLessDelay;

    /// @notice Delay for delegator withdrawals (in rounds)
    uint64 public leaveDelegatorsDelay;

    /// @notice Delay for operator exit (in rounds)
    uint64 public leaveOperatorsDelay;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR COMMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator commission rate in basis points
    uint16 public operatorCommissionBps;

    // M-10 FIX: Commission change timelock to protect existing delegations
    /// @notice Timelock delay for commission changes (7 days)
    uint64 public constant COMMISSION_CHANGE_DELAY = 7 days;

    /// @notice Pending commission change value (0 means no pending change)
    uint16 internal _pendingCommissionBps;

    /// @notice Timestamp when pending commission change can be executed
    uint64 internal _commissionChangeExecuteAfter;

    // ═══════════════════════════════════════════════════════════════════════════
    // ASSET CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Asset configurations: keccak256(asset) => config
    mapping(bytes32 => Types.AssetConfig) internal _assetConfigs;

    /// @notice Set of enabled ERC20 tokens
    EnumerableSet.AddressSet internal _enabledErc20s;

    /// @notice Whether native asset is enabled
    bool public nativeEnabled;

    // ═══════════════════════════════════════════════════════════════════════════
    // ASSET ADAPTERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Asset adapter registry: token address => adapter address
    /// @dev If adapter is set, deposits/withdrawals go through adapter for share accounting
    mapping(address => address) internal _assetAdapters;

    /// @notice Whether to require adapters for all ERC20 deposits
    /// @dev When true, deposits revert if no adapter is registered
    bool public requireAdapters;

    /// @notice M-8 FIX: Tracks whether an adapter migration is in progress for a token
    /// @dev When true, new deposits/withdrawals for this token are paused
    mapping(address => bool) internal _adapterMigrationInProgress;

    /// @notice M-8 FIX: Pending adapter address during migration
    mapping(address => address) internal _pendingAdapter;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR STORAGE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set of all registered operators
    EnumerableSet.AddressSet internal _operators;

    /// @notice Operator metadata: operator => metadata
    mapping(address => Types.OperatorMetadata) internal _operatorMetadata;

    /// @notice Operator unstake requests: operator => request
    mapping(address => Types.OperatorBondLessRequest) internal _operatorBondLessRequests;

    /// @notice Operator blueprint registrations: operator => blueprint IDs
    mapping(address => EnumerableSet.UintSet) internal _operatorBlueprints;

    /// @notice Delegators per operator: operator => delegator addresses
    /// @dev Maintained for efficient iteration during slashing
    mapping(address => EnumerableSet.AddressSet) internal _operatorDelegators;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUND SNAPSHOTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator snapshots at round: round => operator => snapshot
    mapping(uint64 => mapping(address => Types.OperatorSnapshot)) internal _atStake;

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH FACTOR (RESERVED)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Reserved slot for prior slash-factor tracking (unused with share-based pools).
    mapping(address => mapping(bytes32 => uint256)) internal _operatorSlashFactor;

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATOR DEPOSITS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delegator deposits: delegator => assetHash => Deposit
    mapping(address => mapping(bytes32 => Types.Deposit)) internal _deposits;

    /// @notice Deposit locks: delegator => assetHash => LockInfo[]
    mapping(address => mapping(bytes32 => Types.LockInfo[])) internal _depositLocks;

    /// @notice Withdraw requests: delegator => WithdrawRequest[]
    mapping(address => Types.WithdrawRequest[]) internal _withdrawRequests;

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delegations: delegator => BondInfoDelegator[]
    mapping(address => Types.BondInfoDelegator[]) internal _delegations;

    /// @notice Blueprint selection for Fixed mode: delegator => delegationIndex => blueprintIds
    mapping(address => mapping(uint256 => uint64[])) internal _delegationBlueprints;

    /// @notice Unstake requests: delegator => BondLessRequest[]
    mapping(address => Types.BondLessRequest[]) internal _unstakeRequests;

    /// @notice Blueprint selection for unstake: delegator => unstakeIndex => blueprintIds
    mapping(address => mapping(uint256 => uint64[])) internal _unstakeBlueprints;

    /// @notice Delegator status
    mapping(address => Types.DelegatorStatus) internal _delegatorStatus;

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARDS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Per-operator reward pools: operator => assetHash => pool
    /// @dev This is the "All mode" pool - delegators with All mode get rewards/slashes from ALL blueprints
    mapping(address => mapping(bytes32 => Types.OperatorRewardPool)) internal _rewardPools;

    /// @notice M-7 FIX: Accumulated dust from rounding in reward distributions
    /// @dev token address => accumulated dust amount (address(0) for native token)
    mapping(address => uint256) internal _accumulatedDust;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT EXPOSURE TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Per-blueprint reward pools for Fixed mode delegators
    /// @dev operator => blueprintId => assetHash => pool
    /// Fixed mode delegators only get rewards/slashes from their selected blueprints
    mapping(address => mapping(uint64 => mapping(bytes32 => Types.OperatorRewardPool))) internal _blueprintPools;

    /// @notice Track which delegations use "All" mode (exposed to all blueprints)
    /// @dev delegator => operator => delegationIndex => isAllMode
    /// If true, delegation is in _rewardPools; if false, in _blueprintPools
    mapping(address => mapping(address => mapping(uint256 => bool))) internal _delegationIsAllMode;

    /// @notice Track shares per blueprint for Fixed mode delegations
    /// @dev delegator => operator => assetHash => blueprintId => shares
    mapping(address => mapping(address => mapping(bytes32 => mapping(uint64 => uint256)))) internal
        _delegatorBlueprintShares;

    // ═══════════════════════════════════════════════════════════════════════════
    // EXTERNAL INTEGRATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice External rewards manager for TNT incentives (IRewardsManager)
    /// @dev If set, delegation changes are reported for reward tracking
    address internal _rewardsManager;

    /// @notice External distributor for service-fee payouts (multi-token, per-asset commitments)
    /// @dev If set, delegation and blueprint-selection changes are reported for fee accrual.
    address internal _serviceFeeDistributor;

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute hash for an asset
    function _assetHash(Types.Asset memory asset) internal pure returns (bytes32) {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(abi.encode(asset.kind, asset.token));
    }

    /// @notice Get lock duration for a multiplier
    function _getLockDuration(Types.LockMultiplier multiplier) internal pure returns (uint64) {
        if (multiplier == Types.LockMultiplier.OneMonth) return LOCK_ONE_MONTH;
        if (multiplier == Types.LockMultiplier.TwoMonths) return LOCK_TWO_MONTHS;
        if (multiplier == Types.LockMultiplier.ThreeMonths) return LOCK_THREE_MONTHS;
        if (multiplier == Types.LockMultiplier.SixMonths) return LOCK_SIX_MONTHS;
        return 0;
    }

    /// @notice Get multiplier BPS for a lock type
    function _getLockMultiplierBps(Types.LockMultiplier multiplier) internal pure returns (uint16) {
        if (multiplier == Types.LockMultiplier.OneMonth) return MULTIPLIER_ONE_MONTH;
        if (multiplier == Types.LockMultiplier.TwoMonths) return MULTIPLIER_TWO_MONTHS;
        if (multiplier == Types.LockMultiplier.ThreeMonths) return MULTIPLIER_THREE_MONTHS;
        if (multiplier == Types.LockMultiplier.SixMonths) return MULTIPLIER_SIX_MONTHS;
        return MULTIPLIER_NONE;
    }

    function _validateLockMultiplier(Types.LockMultiplier multiplier) internal pure {
        if (
            multiplier == Types.LockMultiplier.None || multiplier == Types.LockMultiplier.OneMonth
                || multiplier == Types.LockMultiplier.TwoMonths || multiplier == Types.LockMultiplier.ThreeMonths
                || multiplier == Types.LockMultiplier.SixMonths
        ) {
            return;
        }

        revert DelegationErrors.InvalidLockMultiplier(uint8(multiplier));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RESERVED SLASH FACTOR HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Reserved getter for the historical slash factor (unused with share-based pools)
    /// @dev Returns PRECISION (1e18) if unset
    function getOperatorSlashFactor(address operator, bytes32 assetHash) public view returns (uint256) {
        uint256 factor = _operatorSlashFactor[operator][assetHash];
        return factor == 0 ? PRECISION : factor;
    }

    /// @notice Reserved helper kept for storage compatibility (unused)
    function _applyLazySlash(
        uint256 originalAmount,
        uint256 snapshotFactor,
        uint256 currentFactor
    )
        internal
        pure
        returns (uint256 effectiveAmount)
    {
        if (snapshotFactor == 0 || currentFactor >= snapshotFactor) {
            return originalAmount; // No slash occurred since request
        }
        // Proportional reduction: amount * (currentFactor / snapshotFactor)
        return (originalAmount * currentFactor) / snapshotFactor;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // F5: TWAP STAKE-SECONDS ACCRUAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator's total delegated stake for a specific asset (sum across
    ///         All-mode pool and every Fixed-mode blueprint pool the operator owns).
    /// @dev Reads the incrementally-maintained `_operatorDelegatedAggregate` so cost
    ///      is a single SLOAD rather than O(blueprints). Every callsite that mutates
    ///      `_rewardPools[op][h].totalAssets` or `_blueprintPools[op][bp][h].totalAssets`
    ///      MUST keep the aggregate in sync via `_increaseDelegatedStake` /
    ///      `_decreaseDelegatedStake`; otherwise the invariant
    ///      `aggregate == rewardPool.totalAssets + Σ blueprintPool.totalAssets` breaks.
    function _getOperatorDelegatedStakeForAsset(
        address operator,
        bytes32 assetHash
    )
        internal
        view
        returns (uint256)
    {
        return _operatorDelegatedAggregate[operator][assetHash];
    }

    /// @notice Apply a positive delta to the operator's delegated-stake aggregate.
    function _increaseDelegatedStake(address operator, bytes32 assetHash, uint256 amount) internal {
        if (amount == 0) return;
        _operatorDelegatedAggregate[operator][assetHash] += amount;
    }

    /// @notice Apply a negative delta to the operator's delegated-stake aggregate.
    /// @dev Saturating subtraction guards against rounding edges in share-pool conversions
    ///      where the per-pool `totalAssets -= amount` already saturates to zero. Without a
    ///      floor here, the aggregate could underflow while the pool stayed at zero.
    function _decreaseDelegatedStake(address operator, bytes32 assetHash, uint256 amount) internal {
        if (amount == 0) return;
        uint256 current = _operatorDelegatedAggregate[operator][assetHash];
        _operatorDelegatedAggregate[operator][assetHash] = current > amount ? current - amount : 0;
    }

    /// @notice Operator's total stake for an asset (self-stake when bond + delegated).
    /// @dev Single source of truth so the TWAP accrual hook always agrees with the
    ///      value used for billing, slashing, and view facets. For non-bond assets
    ///      self-stake contributes zero.
    function _getOperatorStakeForAssetHash(
        address operator,
        bytes32 assetHash
    )
        internal
        view
        returns (uint256)
    {
        uint256 delegated = _getOperatorDelegatedStakeForAsset(operator, assetHash);
        bytes32 bondHash = _operatorBondToken == address(0)
            ? _assetHash(Types.Asset(Types.AssetKind.Native, address(0)))
            : _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));
        if (assetHash == bondHash) {
            // forge-lint: disable-next-line(unsafe-typecast)
            return delegated + _operatorMetadata[operator].stake;
        }
        return delegated;
    }

    /// @notice Fold elapsed time × current stake into the cumulative counter.
    /// @dev Caller passes the operator's CURRENT stake for the asset (i.e. the value
    ///      that has been in effect since `_cumStakeSecondsLastUpdate`). Must be
    ///      called BEFORE the underlying stake actually changes, otherwise the
    ///      pre-change interval would be priced at the new (post-change) stake.
    ///      First accrual seeds `lastUpdate` without area contribution, so any
    ///      pre-existing pool starts TWAP cleanly at upgrade time without
    ///      back-paying for unobservable history.
    function _accrueStakeSecondsRaw(address operator, bytes32 assetHash, uint256 currentStake) internal {
        uint64 last = _cumStakeSecondsLastUpdate[operator][assetHash];
        uint64 nowTs = uint64(block.timestamp);
        if (last == 0) {
            _cumStakeSecondsLastUpdate[operator][assetHash] = nowTs;
            return;
        }
        if (nowTs <= last) return; // same-block or clock skew: no-op
        unchecked {
            // safe: (nowTs - last) ≤ 2^64; currentStake ≤ 2^256; product fits
            // because product ≤ 2^256 by construction of realistic stakes.
            _cumStakeSeconds[operator][assetHash] += currentStake * (nowTs - last);
        }
        _cumStakeSecondsLastUpdate[operator][assetHash] = nowTs;
    }

    /// @notice Fold pre-change stake-seconds into the cumulative index.
    /// @dev MUST be invoked BEFORE every state change that mutates the operator's
    ///      total stake for the given asset. Reads the current stake (the value
    ///      that was in effect over [lastUpdate, now]) and pushes the area into
    ///      `_cumStakeSeconds`. Idempotent within a single block.
    function _accrueOperatorStakeSeconds(address operator, bytes32 assetHash) internal {
        uint256 currentStake = _getOperatorStakeForAssetHash(operator, assetHash);
        _accrueStakeSecondsRaw(operator, assetHash, currentStake);
    }

    /// @notice Lazy-realize cumulative stake-seconds at the current block.
    /// @dev Does not write storage. Returns the snapshotted counter the caller would
    ///      see if accrual ran right now, plus the stored `lastUpdate` and live
    ///      stake for caller-side bookkeeping (e.g. lazy-initializing a
    ///      subscription's last-billed cursor).
    function _getCumStakeSecondsView(
        address operator,
        bytes32 assetHash
    )
        internal
        view
        returns (uint256 cum, uint64 lastUpdate, uint256 currentStake)
    {
        cum = _cumStakeSeconds[operator][assetHash];
        lastUpdate = _cumStakeSecondsLastUpdate[operator][assetHash];
        currentStake = _getOperatorStakeForAssetHash(operator, assetHash);
        if (lastUpdate != 0 && block.timestamp > lastUpdate) {
            unchecked {
                cum += currentStake * (uint64(block.timestamp) - lastUpdate);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUTER SELECTOR REGISTRY
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Function selector => facet address
    mapping(bytes4 => address) internal _facetForSelector;

    /// @notice ERC20 token used for operator bond requirements (TNT)
    address internal _operatorBondToken;

    // ═══════════════════════════════════════════════════════════════════════════
    // M-9 FIX: PENDING SLASH TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Count of pending slashes per operator (used to block withdrawals during pending slashes)
    /// @dev Incremented when slash is proposed, decremented when executed or cancelled
    mapping(address => uint64) internal _operatorPendingSlashCount;

    // ═══════════════════════════════════════════════════════════════════════════
    // M-10 FIX: TANGLE CORE REFERENCE FOR ACTIVE SERVICE CHECKS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Reference to Tangle core contract for querying active services
    /// @dev Used to check if operator has active service commitments before exit
    address internal _tangleCore;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR DELEGATION CONFIG
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator delegation mode: operator => DelegationMode
    /// @dev Default is Disabled (self-stake only)
    mapping(address => Types.DelegationMode) internal _operatorDelegationMode;

    /// @notice Whitelist of approved delegators: operator => delegator => approved
    mapping(address => mapping(address => bool)) internal _operatorDelegationWhitelist;

    // ═══════════════════════════════════════════════════════════════════════════
    // F5: TWAP-FAIR STAKE INDEX (cumulative stake-seconds per operator+asset)
    // ═══════════════════════════════════════════════════════════════════════════
    // Compound-v2 / Aave-v3 style index: every stake-changing path calls
    // `_accrueOperatorStakeSeconds(op, assetHash)` BEFORE mutating the underlying
    // amount, which folds `prevStake × (now − lastUpdate)` into the running counter.
    // Subscription billing then prices a period by `cum_now − cum_lastBilled`,
    // making TWAP-fair pricing O(1) per change with no looping. Counter is
    // monotonic and never decreases (slashes still attribute time-weight up to the
    // slash instant). uint256 stake-seconds cannot overflow at realistic scales
    // (e.g. 1e30 wei × 100 years ≈ 3.15e39 < 2^256).

    /// @notice Cumulative stake-seconds: operator => assetHash => Σ stake(t)·dt
    mapping(address => mapping(bytes32 => uint256)) internal _cumStakeSeconds;

    /// @notice Timestamp of the last accrual into _cumStakeSeconds for this pair.
    /// @dev 0 sentinel means "never accrued"; the first accrual seeds lastUpdate
    ///      without contributing area, so pre-existing pools begin TWAP at upgrade.
    mapping(address => mapping(bytes32 => uint64)) internal _cumStakeSecondsLastUpdate;

    /// @notice O(1) running total of an operator's delegated stake per asset.
    /// @dev Invariant: equals `_rewardPools[op][h].totalAssets +
    ///      Σ_bp _blueprintPools[op][bp][h].totalAssets` after every state-modifying call.
    ///      Maintained incrementally by `_increaseDelegatedStake` / `_decreaseDelegatedStake`
    ///      at every pool mutation site (delegate, undelegate, slash). Lets the TWAP
    ///      accrual hook and billing read total delegated stake in a single SLOAD instead
    ///      of iterating the operator's blueprint set.
    mapping(address operator => mapping(bytes32 assetHash => uint256)) internal _operatorDelegatedAggregate;

    /// @notice Reserved storage gap for future upgrades
    /// @dev Standard gap size is 50 slots. When adding new storage, decrease this gap accordingly.
    uint256[43] private __gap;
}
