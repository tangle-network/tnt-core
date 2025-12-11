// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { ProtocolConfig } from "../config/ProtocolConfig.sol";
import { SlashingManager } from "./SlashingManager.sol";
import { DepositManager } from "./DepositManager.sol";
import { IRestaking } from "../interfaces/IRestaking.sol";
import { Types } from "../libraries/Types.sol";
import { IAssetAdapter } from "./adapters/IAssetAdapter.sol";

/// @title MultiAssetDelegation
/// @notice Modular multi-asset delegation system with proportional slashing
/// @dev Facade contract that inherits from all manager modules
contract MultiAssetDelegation is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    SlashingManager,
    DepositManager,
    IRestaking
{
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event AssetEnabled(address indexed token, uint256 minOperatorStake, uint256 minDelegation);
    event AssetDisabled(address indexed token);
    event RoundAdvanced(uint64 indexed round);

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZER
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the contract
    /// @param admin Admin address
    /// @param nativeMinOperatorStake Minimum stake for operators
    /// @param nativeMinDelegation Minimum delegation amount
    /// @param _operatorCommissionBps Operator commission in basis points
    function initialize(
        address admin,
        uint256 nativeMinOperatorStake,
        uint256 nativeMinDelegation,
        uint16 _operatorCommissionBps
    )
        external
        initializer
    {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(ASSET_MANAGER_ROLE, admin);

        // Configure native asset
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        _assetConfigs[nativeHash] = Types.AssetConfig({
            enabled: true,
            minOperatorStake: nativeMinOperatorStake,
            minDelegation: nativeMinDelegation,
            depositCap: 0,
            currentDeposits: 0,
            // forge-lint: disable-next-line(unsafe-typecast)
            rewardMultiplierBps: uint16(BPS_DENOMINATOR)
        });
        nativeEnabled = true;

        operatorCommissionBps = _operatorCommissionBps;
        currentRound = 1;
        roundDuration = ProtocolConfig.ROUND_DURATION_BLOCKS;

        delegationBondLessDelay = ProtocolConfig.DELEGATOR_DELAY_ROUNDS;
        leaveDelegatorsDelay = ProtocolConfig.DELEGATOR_DELAY_ROUNDS;
        leaveOperatorsDelay = ProtocolConfig.OPERATOR_DELAY_ROUNDS;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR FUNCTIONS (PUBLIC)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register as an operator with native stake
    function registerOperator() external payable whenNotPaused nonReentrant {
        _registerOperatorNative();
    }

    /// @notice Register as operator with ERC20 stake
    function registerOperatorWithAsset(address token, uint256 amount) external whenNotPaused nonReentrant {
        _registerOperatorWithAsset(token, amount);
    }

    /// @notice Increase operator stake with native token
    function increaseStake() external payable whenNotPaused nonReentrant {
        _increaseStakeNative();
    }

    /// @notice Schedule operator self-stake reduction
    /// @param amount Amount to unstake
    function scheduleOperatorUnstake(uint256 amount) external whenNotPaused {
        _scheduleOperatorUnstake(amount);
    }

    /// @notice Execute pending operator unstake
    function executeOperatorUnstake() external nonReentrant {
        _executeOperatorUnstake();
    }

    /// @notice Add blueprint support
    function addBlueprint(uint64 blueprintId) external {
        _addBlueprint(blueprintId);
    }

    /// @notice Remove blueprint support
    function removeBlueprint(uint64 blueprintId) external {
        _removeBlueprint(blueprintId);
    }

    /// @notice Schedule leaving as operator
    function startLeaving() external {
        _startLeaving();
    }

    /// @notice Complete leaving and withdraw all stake
    function completeLeaving() external nonReentrant {
        _completeLeaving();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPOSIT FUNCTIONS (PUBLIC)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit native token
    function deposit() external payable whenNotPaused nonReentrant {
        _depositNative();
    }

    /// @notice Deposit native token with lock
    function depositWithLock(Types.LockMultiplier lockMultiplier) external payable whenNotPaused nonReentrant {
        _depositNativeWithLock(lockMultiplier);
    }

    /// @notice Deposit ERC20 token
    function depositERC20(address token, uint256 amount) external whenNotPaused nonReentrant {
        _depositErc20(token, amount);
    }

    /// @notice Deposit ERC20 with lock
    function depositERC20WithLock(
        address token,
        uint256 amount,
        Types.LockMultiplier lockMultiplier
    )
        external
        whenNotPaused
        nonReentrant
    {
        _depositErc20WithLock(token, amount, lockMultiplier);
    }

    /// @notice Schedule withdrawal
    function scheduleWithdraw(address token, uint256 amount) external whenNotPaused {
        _scheduleWithdraw(token, amount);
    }

    /// @notice Execute pending withdrawals
    function executeWithdraw() external nonReentrant {
        _executeWithdraw();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION FUNCTIONS (PUBLIC)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deposit and delegate native tokens in one transaction
    /// @param operator Operator to delegate to
    function depositAndDelegate(address operator) external payable whenNotPaused nonReentrant {
        _depositNative();
        _delegateNative(operator, msg.value);
    }

    /// @notice Deposit and delegate with full options in one transaction
    /// @param operator Operator to delegate to
    /// @param token Token address (address(0) for native)
    /// @param amount Amount to deposit and delegate
    /// @param selectionMode Blueprint selection mode
    /// @param blueprintIds Blueprint IDs for Fixed mode
    function depositAndDelegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    )
        external
        payable
        whenNotPaused
        nonReentrant
    {
        if (token == address(0)) {
            _depositNative();
        } else {
            _depositErc20(token, amount);
        }
        _delegateWithOptions(operator, token, amount, selectionMode, blueprintIds);
    }

    /// @notice Delegate to an operator (from existing deposit)
    function delegate(address operator, uint256 amount) external whenNotPaused nonReentrant {
        _delegateNative(operator, amount);
    }

    /// @notice Delegate with full options (from existing deposit)
    function delegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    )
        external
        whenNotPaused
        nonReentrant
    {
        _delegateWithOptions(operator, token, amount, selectionMode, blueprintIds);
    }

    /// @notice Schedule undelegation
    function scheduleDelegatorUnstake(address operator, address token, uint256 amount) external whenNotPaused {
        _scheduleDelegatorUnstake(operator, token, amount);
    }

    /// @notice Undelegate native tokens
    function undelegate(address operator, uint256 amount) external whenNotPaused nonReentrant {
        _undelegateNative(operator, amount);
    }

    /// @notice Execute pending unstakes
    function executeDelegatorUnstake() external nonReentrant {
        _executeDelegatorUnstake();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT FOR DELEGATORS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add a blueprint to a Fixed mode delegation
    /// @dev Only works for Fixed mode delegations. Liquid vault depositors cannot call this
    ///      because they are not the delegator (the vault contract is the delegator).
    /// @param delegationIndex The index of the delegation in your delegations array
    /// @param blueprintId The blueprint ID to add exposure to
    function addBlueprintToDelegation(uint256 delegationIndex, uint64 blueprintId) external whenNotPaused {
        _addBlueprintToDelegation(delegationIndex, blueprintId);
    }

    /// @notice Remove a blueprint from a Fixed mode delegation
    /// @dev Only works for Fixed mode delegations. Cannot remove the last blueprint.
    ///      Liquid vault depositors cannot call this because they are not the delegator.
    /// @param delegationIndex The index of the delegation in your delegations array
    /// @param blueprintId The blueprint ID to remove exposure from
    function removeBlueprintFromDelegation(uint256 delegationIndex, uint64 blueprintId) external whenNotPaused {
        _removeBlueprintFromDelegation(delegationIndex, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD FUNCTIONS (PUBLIC)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Notify reward for an operator from a specific blueprint
    /// @dev Routes rewards to appropriate pools based on delegator blueprint exposure
    function notifyRewardForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount
    )
        external
        override
    {
        serviceId; // silence unused warning
        _notifyRewardForBlueprint(operator, blueprintId, amount);
    }

    /// @notice Notify reward for an operator (legacy - all delegators get rewards)
    function notifyReward(address operator, uint64 serviceId, uint256 amount) external override {
        serviceId; // silence unused warning
        _notifyReward(operator, amount);
    }

    /// @notice Claim delegator rewards
    function claimDelegatorRewards() external nonReentrant returns (uint256 totalRewards) {
        totalRewards = _claimDelegatorRewards();
    }

    /// @notice Claim operator rewards
    function claimOperatorRewards() external nonReentrant {
        _claimOperatorRewards(payable(msg.sender));
    }

    /// @notice Claim operator rewards to a specific recipient (useful for contracts without receive hooks)
    function claimOperatorRewardsTo(address payable recipient) external nonReentrant {
        _claimOperatorRewards(recipient);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING (IRestaking)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slash operator for a specific blueprint
    /// @dev Only affects delegators exposed to this blueprint (All mode + Fixed mode who selected it)
    function slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    )
        external
        override
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slashForBlueprint(operator, blueprintId, serviceId, amount, evidence);
    }

    /// @notice Slash operator and delegators proportionally (legacy - slashes all)
    function slash(
        address operator,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    )
        external
        override
        onlyRole(SLASHER_ROLE)
        returns (uint256 actualSlashed)
    {
        return _slash(operator, serviceId, amount, evidence);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUND MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Advance to next round
    function advanceRound() external {
        _advanceRound();
        emit RoundAdvanced(currentRound);
    }

    /// @notice Take snapshot of operator state
    function snapshotOperator(address operator) external {
        _snapshotOperator(operator);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ASSET MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Enable an ERC20 token for staking
    function enableAsset(
        address token,
        uint256 _minOperatorStake,
        uint256 _minDelegation,
        uint256 _depositCap,
        uint16 _rewardMultiplierBps
    )
        external
        onlyRole(ASSET_MANAGER_ROLE)
    {
        require(token != address(0), "Use native");
        bytes32 assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));

        _assetConfigs[assetHash] = Types.AssetConfig({
            enabled: true,
            minOperatorStake: _minOperatorStake,
            minDelegation: _minDelegation,
            depositCap: _depositCap,
            currentDeposits: 0,
            rewardMultiplierBps: _rewardMultiplierBps
        });
        _enabledErc20s.add(token);

        emit AssetEnabled(token, _minOperatorStake, _minDelegation);
    }

    /// @notice Disable an asset
    function disableAsset(address token) external onlyRole(ASSET_MANAGER_ROLE) {
        bytes32 assetHash;
        if (token == address(0)) {
            assetHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
            nativeEnabled = false;
        } else {
            assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));
            _enabledErc20s.remove(token);
        }
        _assetConfigs[assetHash].enabled = false;
        emit AssetDisabled(token);
    }

    /// @notice Get asset configuration
    function getAssetConfig(address token) external view returns (Types.AssetConfig memory) {
        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        return _assetConfigs[_assetHash(asset)];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADAPTER MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    event AdapterRegistered(address indexed token, address indexed adapter);
    event AdapterRemoved(address indexed token);
    event RequireAdaptersUpdated(bool required);

    /// @notice Register an adapter for a token
    /// @param token The token address
    /// @param adapter The adapter address
    /// @dev Adapter must support the token (checked via supportsAsset)
    function registerAdapter(address token, address adapter) external onlyRole(ASSET_MANAGER_ROLE) {
        require(token != address(0), "Cannot set adapter for native");
        require(adapter != address(0), "Invalid adapter");

        // Verify adapter supports the token
        require(
            IAssetAdapter(adapter).supportsAsset(token),
            "Adapter doesn't support token"
        );

        _assetAdapters[token] = adapter;
        emit AdapterRegistered(token, adapter);
    }

    /// @notice Remove adapter for a token (falls back to direct transfers)
    /// @param token The token address
    function removeAdapter(address token) external onlyRole(ASSET_MANAGER_ROLE) {
        require(_assetAdapters[token] != address(0), "No adapter registered");
        delete _assetAdapters[token];
        emit AdapterRemoved(token);
    }

    /// @notice Set whether adapters are required for ERC20 deposits
    /// @param required If true, deposits revert when no adapter is registered
    function setRequireAdapters(bool required) external onlyRole(ASSET_MANAGER_ROLE) {
        requireAdapters = required;
        emit RequireAdaptersUpdated(required);
    }

    /// @notice Enable asset with adapter in one call
    /// @param token Token address
    /// @param adapter Adapter address
    /// @param _minOperatorStake Minimum stake for operators
    /// @param _minDelegation Minimum delegation amount
    /// @param _depositCap Maximum total deposits (0 = unlimited)
    /// @param _rewardMultiplierBps Reward multiplier in basis points
    function enableAssetWithAdapter(
        address token,
        address adapter,
        uint256 _minOperatorStake,
        uint256 _minDelegation,
        uint256 _depositCap,
        uint16 _rewardMultiplierBps
    ) external onlyRole(ASSET_MANAGER_ROLE) {
        require(token != address(0), "Use native");
        require(adapter != address(0), "Invalid adapter");
        require(
            IAssetAdapter(adapter).supportsAsset(token),
            "Adapter doesn't support token"
        );

        // Register adapter
        _assetAdapters[token] = adapter;
        emit AdapterRegistered(token, adapter);

        // Enable asset
        bytes32 assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));
        _assetConfigs[assetHash] = Types.AssetConfig({
            enabled: true,
            minOperatorStake: _minOperatorStake,
            minDelegation: _minDelegation,
            depositCap: _depositCap,
            currentDeposits: 0,
            rewardMultiplierBps: _rewardMultiplierBps
        });
        _enabledErc20s.add(token);

        emit AssetEnabled(token, _minOperatorStake, _minDelegation);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // IRESTAKING VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IRestaking
    function isOperator(address operator) external view override returns (bool) {
        return _isOperator(operator);
    }

    /// @inheritdoc IRestaking
    function isOperatorActive(address operator) external view override returns (bool) {
        return _isOperatorActive(operator);
    }

    /// @inheritdoc IRestaking
    function getOperatorStake(address operator) external view override returns (uint256) {
        return _getOperatorSelfStake(operator) + _rewardPools[operator].totalAssets;
    }

    /// @inheritdoc IRestaking
    function getOperatorSelfStake(address operator) external view override returns (uint256) {
        return _getOperatorSelfStake(operator);
    }

    /// @inheritdoc IRestaking
    function getOperatorDelegatedStake(address operator) external view override returns (uint256) {
        return _rewardPools[operator].totalAssets;
    }

    /// @inheritdoc IRestaking
    function getDelegation(address delegator, address operator) external view override returns (uint256) {
        return _getDelegationToOperator(delegator, operator);
    }

    /// @inheritdoc IRestaking
    function getTotalDelegation(address delegator) external view override returns (uint256 total) {
        for (uint256 i = 0; i < _delegations[delegator].length; i++) {
            Types.BondInfoDelegator storage d = _delegations[delegator][i];
            // Convert shares to underlying amount at current exchange rate
            total += _sharesToAmount(d.operator, d.shares);
        }
    }

    /// @inheritdoc IRestaking
    function minOperatorStake() external view override returns (uint256) {
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        return _assetConfigs[nativeHash].minOperatorStake;
    }

    /// @inheritdoc IRestaking
    function meetsStakeRequirement(address operator, uint256 required) external view override returns (bool) {
        return _getOperatorSelfStake(operator) >= required;
    }

    /// @inheritdoc IRestaking
    function isSlasher(address account) external view override returns (bool) {
        return hasRole(SLASHER_ROLE, account);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADDITIONAL VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get operator metadata
    function getOperatorMetadata(address operator) external view returns (Types.OperatorMetadata memory) {
        return _getOperatorMetadata(operator);
    }

    /// @notice Get operator blueprints
    function getOperatorBlueprints(address operator) external view returns (uint256[] memory) {
        return _getOperatorBlueprints(operator);
    }

    /// @notice Get total operator count
    function operatorCount() external view returns (uint256) {
        return _operatorCount();
    }

    /// @notice Get operator at index
    function operatorAt(uint256 index) external view returns (address) {
        return _operatorAt(index);
    }

    /// @notice Get deposit for a delegator and token
    function getDeposit(address delegator, address token) external view returns (Types.Deposit memory) {
        return _getDeposit(delegator, token);
    }

    /// @notice Get pending withdrawals
    function getPendingWithdrawals(address delegator) external view returns (Types.WithdrawRequest[] memory) {
        return _getPendingWithdrawals(delegator);
    }

    /// @notice Get locks for a delegator
    function getLocks(address delegator, address token) external view returns (Types.LockInfo[] memory) {
        return _getLocks(delegator, token);
    }

    /// @notice Get all delegations for a delegator
    function getDelegations(address delegator) external view returns (Types.BondInfoDelegator[] memory) {
        return _getDelegations(delegator);
    }

    /// @notice Get delegation blueprints
    function getDelegationBlueprints(address delegator, uint256 idx) external view returns (uint64[] memory) {
        return _getDelegationBlueprints(delegator, idx);
    }

    /// @notice Get pending unstakes
    function getPendingUnstakes(address delegator) external view returns (Types.BondLessRequest[] memory) {
        return _getPendingUnstakes(delegator);
    }

    /// @notice Get operator reward pool
    function getOperatorRewardPool(address operator) external view returns (Types.OperatorRewardPool memory) {
        return _getOperatorRewardPool(operator);
    }

    /// @notice Get pending delegator rewards
    function getPendingDelegatorRewards(address delegator) external view returns (uint256) {
        return _getPendingDelegatorRewards(delegator);
    }

    /// @notice Get pending operator rewards
    function getPendingOperatorRewards(address operator) external view returns (uint256) {
        return _getPendingOperatorRewards(operator);
    }

    /// @notice Get all delegators for an operator
    /// @param operator The operator address
    /// @return delegators Array of delegator addresses
    function getOperatorDelegators(address operator) external view returns (address[] memory) {
        return _getOperatorDelegators(operator);
    }

    /// @notice Get the number of delegators for an operator
    function getOperatorDelegatorCount(address operator) external view returns (uint256) {
        return _getOperatorDelegatorCount(operator);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add a slasher
    function addSlasher(address slasher) external onlyRole(ADMIN_ROLE) {
        _grantRole(SLASHER_ROLE, slasher);
    }

    /// @notice Remove a slasher
    function removeSlasher(address slasher) external onlyRole(ADMIN_ROLE) {
        _revokeRole(SLASHER_ROLE, slasher);
    }

    /// @notice Set operator commission rate
    function setOperatorCommission(uint16 bps) external onlyRole(ADMIN_ROLE) {
        require(bps <= BPS_DENOMINATOR, "Invalid BPS");
        operatorCommissionBps = bps;
    }

    /// @notice Set delay parameters
    function setDelays(
        uint64 _delegationBondLessDelay,
        uint64 _leaveDelegatorsDelay,
        uint64 _leaveOperatorsDelay
    )
        external
        onlyRole(ADMIN_ROLE)
    {
        delegationBondLessDelay = _delegationBondLessDelay;
        leaveDelegatorsDelay = _leaveDelegatorsDelay;
        leaveOperatorsDelay = _leaveOperatorsDelay;
    }

    /// @notice Set external rewards manager for TNT incentives
    /// @param manager Address of IRewardsManager (RewardVaults), or address(0) to disable
    function setRewardsManager(address manager) external onlyRole(ADMIN_ROLE) {
        _rewardsManager = manager;
    }

    /// @notice Get the rewards manager address
    function rewardsManager() external view returns (address) {
        return _rewardsManager;
    }

    /// @notice Pause the contract
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /// @notice Unpause the contract
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /// @notice Authorize upgrade
    function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) { }

    /// @notice Receive native tokens
    receive() external payable { }
}
