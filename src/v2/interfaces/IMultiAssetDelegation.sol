// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";
import { SlashingManager } from "../restaking/SlashingManager.sol";

/// @title IMultiAssetDelegation
/// @notice Full interface for the multi-asset restaking contract
interface IMultiAssetDelegation {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event AssetEnabled(address indexed token, uint256 minOperatorStake, uint256 minDelegation);
    event AssetDisabled(address indexed token);
    event RoundAdvanced(uint64 indexed round);

    event OperatorRegistered(address indexed operator, uint256 stake);
    event OperatorStakeIncreased(address indexed operator, uint256 amount);
    event OperatorUnstakeScheduled(address indexed operator, uint256 amount, uint64 readyRound);
    event OperatorUnstakeExecuted(address indexed operator, uint256 amount);
    event OperatorLeavingScheduled(address indexed operator, uint64 readyRound);
    event OperatorLeft(address indexed operator);
    event OperatorBlueprintAdded(address indexed operator, uint64 indexed blueprintId);
    event OperatorBlueprintRemoved(address indexed operator, uint64 indexed blueprintId);

    event Deposited(address indexed delegator, address indexed token, uint256 amount, Types.LockMultiplier lock);
    event WithdrawScheduled(address indexed delegator, address indexed token, uint256 amount, uint64 readyRound);
    event Withdrawn(address indexed delegator, address indexed token, uint256 amount);
    event ExpiredLocksHarvested(address indexed delegator, address indexed token, uint256 count, uint256 totalAmount);

    event Delegated(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 amount,
        uint256 shares,
        Types.BlueprintSelectionMode selectionMode
    );
    event DelegatorUnstakeScheduled(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 shares,
        uint256 estimatedAmount,
        uint64 readyRound
    );
    event DelegatorUnstakeExecuted(
        address indexed delegator,
        address indexed operator,
        address indexed token,
        uint256 shares,
        uint256 amount
    );
    event BlueprintAddedToDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);
    event BlueprintRemovedFromDelegation(address indexed delegator, uint256 indexed delegationIndex, uint64 blueprintId);

    event Slashed(
        address indexed operator,
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        bytes32 assetHash,
        uint16 slashBps,
        uint256 operatorSlashed,
        uint256 delegatorsSlashed,
        uint256 exchangeRateAfter
    );
    event SlashedForService(
        address indexed operator,
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        uint256 totalSlashed,
        uint256 commitmentCount
    );
    event SlashRecorded(
        address indexed operator,
        uint64 indexed slashId,
        bytes32 assetHash,
        uint16 slashBps,
        uint256 totalSlashed,
        uint256 exchangeRateBefore,
        uint256 exchangeRateAfter
    );

    event AdapterRegistered(address indexed token, address indexed adapter);
    event AdapterRemoved(address indexed token);
    event RequireAdaptersUpdated(bool required);

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function registerOperator() external payable;
    function registerOperatorWithAsset(address token, uint256 amount) external;
    function increaseStake() external payable;
    function increaseStakeWithAsset(address token, uint256 amount) external;
    function scheduleOperatorUnstake(uint256 amount) external;
    function executeOperatorUnstake() external;
    function addBlueprint(uint64 blueprintId) external;
    function removeBlueprint(uint64 blueprintId) external;
    function startLeaving() external;
    function completeLeaving() external;

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPOSIT FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function deposit() external payable;
    function depositWithLock(Types.LockMultiplier lockMultiplier) external payable;
    function depositERC20(address token, uint256 amount) external;
    function depositERC20WithLock(address token, uint256 amount, Types.LockMultiplier lockMultiplier) external;
    function scheduleWithdraw(address token, uint256 amount) external;
    function executeWithdraw() external;

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function depositAndDelegate(address operator) external payable;
    function depositAndDelegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    ) external payable;
    function delegate(address operator, uint256 amount) external;
    function delegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    ) external;
    function scheduleDelegatorUnstake(address operator, address token, uint256 amount) external;
    function undelegate(address operator, uint256 amount) external;
    function executeDelegatorUnstake() external;
    /// @notice Execute a specific matured unstake request and withdraw the resulting assets to `receiver`.
    /// @dev Convenience helper for integrations (e.g. ERC7540 liquid delegation vaults) to avoid a separate
    ///      scheduleWithdraw/executeWithdraw flow after bond-less delay has already elapsed.
    /// @param operator Operator to unstake from
    /// @param token Token address (address(0) for native)
    /// @param shares Shares to unstake (as stored in the underlying bond-less request)
    /// @param requestedRound Round in which the unstake was scheduled
    /// @param receiver Recipient of the withdrawn assets
    /// @return amount Actual amount returned (after exchange-rate adjustments)
    function executeDelegatorUnstakeAndWithdraw(
        address operator,
        address token,
        uint256 shares,
        uint64 requestedRound,
        address receiver
    ) external returns (uint256 amount);
    function addBlueprintToDelegation(uint256 delegationIndex, uint64 blueprintId) external;
    function removeBlueprintFromDelegation(uint256 delegationIndex, uint64 blueprintId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    function slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);
    function slashForService(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);
    function slash(
        address operator,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);
    function advanceRound() external;
    function snapshotOperator(address operator) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // ASSET MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    function enableAsset(
        address token,
        uint256 minOperatorStake,
        uint256 minDelegation,
        uint256 depositCap,
        uint16 rewardMultiplierBps
    ) external;
    function disableAsset(address token) external;
    function getAssetConfig(address token) external view returns (Types.AssetConfig memory);
    function registerAdapter(address token, address adapter) external;
    function removeAdapter(address token) external;
    function setRequireAdapters(bool required) external;
    function enableAssetWithAdapter(
        address token,
        address adapter,
        uint256 minOperatorStake,
        uint256 minDelegation,
        uint256 depositCap,
        uint16 rewardMultiplierBps
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function isOperator(address operator) external view returns (bool);
    function isOperatorActive(address operator) external view returns (bool);
    function getOperatorStake(address operator) external view returns (uint256);
    function getOperatorSelfStake(address operator) external view returns (uint256);
    function getOperatorDelegatedStake(address operator) external view returns (uint256);
    function getOperatorDelegatedStakeForAsset(address operator, Types.Asset calldata asset) external view returns (uint256);
    function getOperatorStakeForAsset(address operator, Types.Asset calldata asset) external view returns (uint256);
    function getDelegation(address delegator, address operator) external view returns (uint256);
    function getTotalDelegation(address delegator) external view returns (uint256 total);
    function minOperatorStake() external view returns (uint256);
    function operatorBondToken() external view returns (address);
    function meetsStakeRequirement(address operator, uint256 required) external view returns (bool);
    function isSlasher(address account) external view returns (bool);
    function getOperatorMetadata(address operator) external view returns (Types.OperatorMetadata memory);
    function getOperatorBlueprints(address operator) external view returns (uint256[] memory);
    function operatorCount() external view returns (uint256);
    function operatorAt(uint256 index) external view returns (address);
    function getDeposit(address delegator, address token) external view returns (Types.Deposit memory);
    function getPendingWithdrawals(address delegator) external view returns (Types.WithdrawRequest[] memory);
    function getLocks(address delegator, address token) external view returns (Types.LockInfo[] memory);
    function getDelegations(address delegator) external view returns (Types.BondInfoDelegator[] memory);
    function getDelegationBlueprints(address delegator, uint256 idx) external view returns (uint64[] memory);
    function getPendingUnstakes(address delegator) external view returns (Types.BondLessRequest[] memory);
    function previewDelegatorUnstakeShares(address operator, address token, uint256 amount) external view returns (uint256);
    /// @notice Get the operator's reward pool for the bond asset
    function getOperatorRewardPool(address operator) external view returns (Types.OperatorRewardPool memory);
    function getOperatorDelegators(address operator) external view returns (address[] memory);
    function getOperatorDelegatorCount(address operator) external view returns (uint256);
    function rewardsManager() external view returns (address);
    function serviceFeeDistributor() external view returns (address);
    function getSlashImpact(address operator, uint64 slashIndex, address delegator) external view returns (uint256);
    function getSlashCount(address operator) external view returns (uint64);
    function getSlashRecord(address operator, uint64 slashIndex)
        external
        view
        returns (SlashingManager.SlashRecord memory);
    function getSlashCountForService(uint64 serviceId, address operator) external view returns (uint64);
    function getSlashCountForBlueprint(uint64 blueprintId, address operator) external view returns (uint64);
    function currentRound() external view returns (uint64);
    function roundDuration() external view returns (uint64);
    function delegationBondLessDelay() external view returns (uint64);
    function leaveDelegatorsDelay() external view returns (uint64);
    function leaveOperatorsDelay() external view returns (uint64);
    function operatorCommissionBps() external view returns (uint16);

    function LOCK_ONE_MONTH() external view returns (uint64);
    function LOCK_TWO_MONTHS() external view returns (uint64);
    function LOCK_THREE_MONTHS() external view returns (uint64);
    function LOCK_SIX_MONTHS() external view returns (uint64);

    function MULTIPLIER_NONE() external view returns (uint16);
    function MULTIPLIER_ONE_MONTH() external view returns (uint16);
    function MULTIPLIER_TWO_MONTHS() external view returns (uint16);
    function MULTIPLIER_THREE_MONTHS() external view returns (uint16);
    function MULTIPLIER_SIX_MONTHS() external view returns (uint16);

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function addSlasher(address slasher) external;
    function removeSlasher(address slasher) external;
    function setOperatorCommission(uint16 bps) external;
    function setOperatorBondToken(address token) external;
    function setDelays(uint64 delegationBondLessDelay, uint64 leaveDelegatorsDelay, uint64 leaveOperatorsDelay) external;
    function setRewardsManager(address manager) external;
    function setServiceFeeDistributor(address distributor) external;
    function pause() external;
    function unpause() external;
    function rescueTokens(address token, address to, uint256 amount) external;
}
