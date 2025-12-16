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
    uint256 public constant BPS_DENOMINATOR = 10000;

    // Lock durations in blocks (assuming ~12s blocks)
    uint64 public constant LOCK_ONE_MONTH = 216000;
    uint64 public constant LOCK_TWO_MONTHS = 432000;
    uint64 public constant LOCK_THREE_MONTHS = 648000;
    uint64 public constant LOCK_SIX_MONTHS = 1296000;

    // Lock multipliers in BPS (10000 = 1x)
    uint16 public constant MULTIPLIER_NONE = 10000;
    uint16 public constant MULTIPLIER_ONE_MONTH = 11000;
    uint16 public constant MULTIPLIER_TWO_MONTHS = 12000;
    uint16 public constant MULTIPLIER_THREE_MONTHS = 13000;
    uint16 public constant MULTIPLIER_SIX_MONTHS = 16000;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROLES
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SLASHER_ROLE = keccak256("SLASHER_ROLE");
    bytes32 public constant ASSET_MANAGER_ROLE = keccak256("ASSET_MANAGER_ROLE");

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUND MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Current round number
    uint64 public currentRound;

    /// @notice Blocks per round
    uint64 public roundDuration;

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

    /// @notice Per-operator reward pools: operator => pool
    /// @dev This is the "All mode" pool - delegators with All mode get rewards/slashes from ALL blueprints
    mapping(address => Types.OperatorRewardPool) internal _rewardPools;

    /// @notice Delegator reward tracking: delegator => operator => debt
    mapping(address => mapping(address => Types.DelegatorRewardDebt)) internal _rewardDebts;

    /// @notice Pending operator rewards from commission
    mapping(address => uint256) internal _operatorPendingRewards;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT EXPOSURE TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Per-blueprint reward pools for Fixed mode delegators
    /// @dev operator => blueprintId => pool
    /// Fixed mode delegators only get rewards/slashes from their selected blueprints
    mapping(address => mapping(uint64 => Types.OperatorRewardPool)) internal _blueprintPools;

    /// @notice Per-blueprint reward debt for Fixed mode delegators
    /// @dev delegator => operator => blueprintId => debt
    mapping(address => mapping(address => mapping(uint64 => Types.DelegatorRewardDebt))) internal _blueprintRewardDebts;

    /// @notice Track which delegations use "All" mode (exposed to all blueprints)
    /// @dev delegator => operator => delegationIndex => isAllMode
    /// If true, delegation is in _rewardPools; if false, in _blueprintPools
    mapping(address => mapping(address => mapping(uint256 => bool))) internal _delegationIsAllMode;

    /// @notice Track shares per blueprint for Fixed mode delegations
    /// @dev delegator => operator => blueprintId => shares
    mapping(address => mapping(address => mapping(uint64 => uint256))) internal _delegatorBlueprintShares;

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
            multiplier == Types.LockMultiplier.None ||
            multiplier == Types.LockMultiplier.OneMonth ||
            multiplier == Types.LockMultiplier.TwoMonths ||
            multiplier == Types.LockMultiplier.ThreeMonths ||
            multiplier == Types.LockMultiplier.SixMonths
        ) {
            return;
        }

        revert DelegationErrors.InvalidLockMultiplier(uint8(multiplier));
    }

    /// @notice Reserved storage gap for future upgrades
    uint256[48] private _gap;
}
