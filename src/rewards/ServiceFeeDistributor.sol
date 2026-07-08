// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Types } from "../libraries/Types.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";
import { ITangleSecurityView } from "../interfaces/ITangleSecurityView.sol";
import { IPriceOracle } from "../oracles/interfaces/IPriceOracle.sol";
import { IStreamingPaymentManager } from "../interfaces/IStreamingPaymentManager.sol";
import { ServiceFeeDistributorLib } from "./ServiceFeeDistributorLib.sol";

/// @title ServiceFeeDistributor
/// @notice Distributes service-fee staker shares in the payment token, weighted by USD value and per-asset
/// commitments. @dev O(1) per-operator/per-asset/per-token distribution using accumulated-per-score accounting.
/// @dev The heavy distribution/USD/score/harvest math lives in the deployed {ServiceFeeDistributorLib} (linked
/// via delegatecall) so this contract's runtime bytecode stays small enough for gas-metered code deposits. All
/// state lives in a single {ServiceFeeDistributorLib.Layout} at slot 0, in the exact slot order this contract
/// used before the extraction — the on-chain storage layout is unchanged.
contract ServiceFeeDistributor is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    IServiceFeeDistributor
{
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using ServiceFeeDistributorLib for ServiceFeeDistributorLib.Layout;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 public constant BPS_DENOMINATOR = 10_000;
    uint256 public constant PRECISION = 1e18;

    /// @dev All distributor storage, declared in {ServiceFeeDistributorLib.Layout} at slot 0. Field order there
    ///      matches the pre-refactor plain-variable layout slot-for-slot, so this is a layout-preserving change.
    ServiceFeeDistributorLib.Layout private _s;

    event StakingConfigured(address indexed staking);
    event TangleConfigured(address indexed tangle);
    event PriceOracleConfigured(address indexed oracle);
    event InflationPoolConfigured(address indexed pool);
    event StreamingManagerConfigured(address indexed streamingManager);
    event TntScoreRateConfigured(address indexed tntToken, uint256 scoreRate);

    event DelegationTracked(
        address indexed delegator,
        address indexed operator,
        address indexed asset,
        Types.BlueprintSelectionMode selectionMode,
        uint256 principal,
        uint256 score
    );

    event ServiceFeeDistributed(
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        address indexed operator,
        address paymentToken,
        uint256 amount
    );

    event Claimed(address indexed account, address indexed token, uint256 amount);

    error NotStaking();
    error NotTangle();
    error NotInflationPool();
    error InvalidModeChange();
    error InvalidBlueprintAmounts();
    error BadMsgValue();
    error UnexpectedMsgValue();
    error EthTransferFailed();

    // ═══════════════════════════════════════════════════════════════════════════
    // PUBLIC STATE GETTERS
    // ═══════════════════════════════════════════════════════════════════════════
    // These reproduce the auto-generated getters of the former `public` state variables so the ABI is unchanged.

    function staking() external view returns (address) {
        return _s.staking;
    }

    function tangle() external view returns (address) {
        return _s.tangle;
    }

    function priceOracle() external view returns (IPriceOracle) {
        return _s.priceOracle;
    }

    function inflationPool() external view returns (address) {
        return _s.inflationPool;
    }

    function streamingManager() external view returns (IStreamingPaymentManager) {
        return _s.streamingManager;
    }

    function tntToken() external view returns (address) {
        return _s.tntToken;
    }

    function tntScoreRate() external view returns (uint256) {
        return _s.tntScoreRate;
    }

    function totalAllScore(address operator, bytes32 assetHash) external view returns (uint256) {
        return _s.totalAllScore[operator][assetHash];
    }

    function totalFixedScore(address operator, uint64 blueprintId, bytes32 assetHash) external view returns (uint256) {
        return _s.totalFixedScore[operator][blueprintId][assetHash];
    }

    function accAllPerScore(address operator, bytes32 assetHash, address rewardToken) external view returns (uint256) {
        return _s.accAllPerScore[operator][assetHash][rewardToken];
    }

    function accFixedPerScore(
        address operator,
        uint64 blueprintId,
        bytes32 assetHash,
        address rewardToken
    )
        external
        view
        returns (uint256)
    {
        return _s.accFixedPerScore[operator][blueprintId][assetHash][rewardToken];
    }

    function claimable(address account, address token) external view returns (uint256) {
        return _s.claimable[account][token];
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address staking_, address tangle_, address oracle_) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        _s.staking = staking_;
        _s.tangle = tangle_;
        _s.priceOracle = IPriceOracle(oracle_);

        emit StakingConfigured(staking_);
        emit TangleConfigured(tangle_);
        emit PriceOracleConfigured(oracle_);
    }

    function setStaking(address staking_) external onlyRole(ADMIN_ROLE) {
        _s.staking = staking_;
        emit StakingConfigured(staking_);
    }

    function setTangle(address tangle_) external onlyRole(ADMIN_ROLE) {
        _s.tangle = tangle_;
        emit TangleConfigured(tangle_);
    }

    function setPriceOracle(address oracle_) external onlyRole(ADMIN_ROLE) {
        _s.priceOracle = IPriceOracle(oracle_);
        emit PriceOracleConfigured(oracle_);
    }

    function setInflationPool(address pool_) external onlyRole(ADMIN_ROLE) {
        _s.inflationPool = pool_;
        emit InflationPoolConfigured(pool_);
    }

    function setStreamingManager(address streamingManager_) external onlyRole(ADMIN_ROLE) {
        _s.streamingManager = IStreamingPaymentManager(streamingManager_);
        emit StreamingManagerConfigured(streamingManager_);
    }

    /// @notice Set TNT token and its score rate for fee distribution boost.
    /// @param tntToken_ The TNT token address (address(0) to disable).
    /// @param scoreRate_ Score rate in 18 decimals. 1e18 means 1 TNT = $1 score.
    ///        Set to 0 to use oracle price for TNT like other tokens.
    /// @dev Example: If TNT market price is $0.10 and scoreRate_ = 1e18,
    ///      then 1 TNT earns 10x the fee share compared to its market value.
    function setTntScoreRate(address tntToken_, uint256 scoreRate_) external onlyRole(ADMIN_ROLE) {
        _s.tntToken = tntToken_;
        _s.tntScoreRate = scoreRate_;
        emit TntScoreRateConfigured(tntToken_, scoreRate_);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HOOKS FROM STAKING
    // ═══════════════════════════════════════════════════════════════════════════

    function onDelegationChanged(
        address delegator,
        address operator,
        Types.Asset calldata asset,
        uint256 amount,
        bool isIncrease,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds,
        uint256[] calldata blueprintAmounts,
        uint16 lockMultiplierBps,
        uint64 lockExpiry
    )
        external
        override
    {
        if (msg.sender != _s.staking) revert NotStaking();

        // IMPORTANT: Drip all active streams for this operator BEFORE score changes
        // This ensures rewards are distributed with the scores that were active
        // during the streaming period, not the new scores after delegation change
        _dripOperatorStreams(operator);

        bytes32 assetHash = ServiceFeeDistributorLib.assetHash(asset);

        // F5: collapse any PRIOR expired lock boost to base before applying this change, so a
        // stale boost is never carried into the new score (and stops diluting others).
        _settleExpiredLock(delegator, operator, assetHash);
        if (!_s._assetKnown[assetHash]) {
            _s._assetKnown[assetHash] = true;
            _s._assetByHash[assetHash] = Types.Asset({ kind: asset.kind, token: asset.token });
        }
        _s._operatorAssetHashes[operator].add(assetHash);
        uint8 newMode = selectionMode == Types.BlueprintSelectionMode.All ? 1 : 2;
        uint8 existingMode = _s._positionMode[delegator][operator][assetHash];
        if (existingMode != 0 && existingMode != newMode) revert InvalidModeChange();

        // Harvest for all known payment tokens before mutating scores.
        _s.harvestAllTokens(delegator, operator, assetHash, existingMode == 0 ? newMode : existingMode);

        // Update principal/score.
        uint256 principalBefore = _s._positionPrincipal[delegator][operator][assetHash];
        uint256 scoreBefore = _s._positionScore[delegator][operator][assetHash];

        // F5: `lockMultiplierBps` boosts the score here, and `lockExpiry` (threaded from the
        // staking layer) records when that boost ends. `_settleExpiredLock` (called above and on
        // every reward path) collapses the boost back to base once the lock elapses, so it can no
        // longer dilute other delegators. Any prior expired boost was already settled at the top
        // of this function, so `scoreBefore` here is the live (base-or-still-locked) score.
        uint256 scoreDelta;
        uint256 principalAfter;
        uint256 scoreAfter;
        if (isIncrease) {
            scoreDelta = (amount * lockMultiplierBps) / BPS_DENOMINATOR;
            principalAfter = principalBefore + amount;
            scoreAfter = scoreBefore + scoreDelta;
            _s._positionPrincipal[delegator][operator][assetHash] = principalAfter;
            _s._positionScore[delegator][operator][assetHash] = scoreAfter;
        } else {
            // Decrease: preserve proportional score (handles prior lock multipliers).
            principalAfter = amount > principalBefore ? 0 : principalBefore - amount;
            if (principalBefore > 0) {
                scoreDelta = (scoreBefore * amount) / principalBefore;
            }
            scoreAfter = scoreDelta > scoreBefore ? 0 : scoreBefore - scoreDelta;
            _s._positionPrincipal[delegator][operator][assetHash] = principalAfter;
            _s._positionScore[delegator][operator][assetHash] = scoreAfter;
        }

        _s._positionMode[delegator][operator][assetHash] = newMode;

        // F5: record the lock expiry that backs this (possibly boosted) score so the boost can
        // be decayed to base once every lock elapses.
        _s._positionLockExpiry[delegator][operator][assetHash] = lockExpiry;

        // Track delegator position for claimAll iteration (only on first interaction)
        if (existingMode == 0) {
            _s._delegatorOperators[delegator].add(operator);
            _s._delegatorAssets[delegator][operator].add(assetHash);
        }

        // Sync Fixed blueprint set from staking payload (authoritative).
        if (newMode == 2) {
            _s.setFixedBlueprints(delegator, operator, assetHash, blueprintIds);
        }

        // Update totals.
        if (newMode == 1) {
            _s.totalAllScore[operator][assetHash] = isIncrease
                ? _s.totalAllScore[operator][assetHash] + scoreDelta
                : (scoreDelta > _s.totalAllScore[operator][assetHash]
                        ? 0
                        : _s.totalAllScore[operator][assetHash] - scoreDelta);
        } else {
            _s.applyFixedScoreDelta(
                delegator, operator, assetHash, scoreDelta, amount, isIncrease, blueprintIds, blueprintAmounts
            );
        }

        _pruneOperatorAssetIfEmpty(operator, assetHash);

        // Reset reward debt to prevent retroactive claims with the new score.
        _s.syncDebtsToCurrentAcc(delegator, operator, assetHash, newMode);

        if (principalAfter == 0 && scoreAfter == 0) {
            _pruneDelegatorPosition(delegator, operator, assetHash);
        }

        emit DelegationTracked(
            delegator,
            operator,
            asset.token,
            selectionMode,
            _s._positionPrincipal[delegator][operator][assetHash],
            _s._positionScore[delegator][operator][assetHash]
        );
    }

    function onAllModeSlashed(address operator, Types.Asset calldata asset, uint16 slashBps) external override {
        if (msg.sender != _s.staking) revert NotStaking();
        if (slashBps == 0) return;
        if (slashBps > BPS_DENOMINATOR) slashBps = uint16(BPS_DENOMINATOR);

        bytes32 assetHash = ServiceFeeDistributorLib.assetHash(asset);
        uint256 current = _s.getAllSlashFactor(operator, assetHash);
        _s._allSlashFactor[operator][assetHash] = (current * (BPS_DENOMINATOR - slashBps)) / BPS_DENOMINATOR;
    }

    function onFixedModeSlashed(
        address operator,
        uint64 blueprintId,
        Types.Asset calldata asset,
        uint16 slashBps
    )
        external
        override
    {
        if (msg.sender != _s.staking) revert NotStaking();
        if (slashBps == 0) return;
        if (slashBps > BPS_DENOMINATOR) slashBps = uint16(BPS_DENOMINATOR);

        bytes32 assetHash = ServiceFeeDistributorLib.assetHash(asset);
        uint256 current = _s.getFixedSlashFactor(operator, blueprintId, assetHash);
        _s._fixedSlashFactor[operator][blueprintId][assetHash] =
            (current * (BPS_DENOMINATOR - slashBps)) / BPS_DENOMINATOR;
    }

    function onBlueprintsRebalanced(
        address delegator,
        address operator,
        Types.Asset calldata asset,
        uint64[] calldata blueprintIds,
        uint256[] calldata blueprintAmounts
    )
        external
        override
    {
        if (msg.sender != _s.staking) revert NotStaking();

        // Drip before score changes
        _dripOperatorStreams(operator);

        bytes32 assetHash = ServiceFeeDistributorLib.assetHash(asset);
        if (_s._positionMode[delegator][operator][assetHash] != 2) {
            revert InvalidModeChange();
        }

        // F5: collapse any expired lock boost before rebalancing redistributes the score.
        _settleExpiredLock(delegator, operator, assetHash);

        if (blueprintIds.length != blueprintAmounts.length) {
            revert InvalidBlueprintAmounts();
        }

        _s.harvestAllTokens(delegator, operator, assetHash, 2);

        _s.rebalanceBlueprints(delegator, operator, assetHash, blueprintIds, blueprintAmounts);

        _s.syncDebtsToCurrentAcc(delegator, operator, assetHash, 2);

        _pruneOperatorAssetIfEmpty(operator, assetHash);
    }

    /// @notice Called when an operator is about to leave a service
    /// @dev Delegates to StreamingPaymentManager to drip before removal
    function onOperatorLeaving(uint64 serviceId, address operator) external override {
        if (msg.sender != _s.tangle) revert NotTangle();
        if (address(_s.streamingManager) != address(0)) {
            _s.streamingManager.onOperatorLeaving(serviceId, operator);
        }
    }

    /// @notice Called when a service is terminated early - refunds remaining streamed payments
    /// @dev Delegates to StreamingPaymentManager which handles refunds
    function onServiceTerminated(uint64 serviceId, address refundRecipient) external override {
        if (msg.sender != _s.tangle) revert NotTangle();
        if (address(_s.streamingManager) != address(0)) {
            _s.streamingManager.onServiceTerminated(serviceId, refundRecipient);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISTRIBUTION FROM TANGLE
    // ═══════════════════════════════════════════════════════════════════════════

    function distributeServiceFee(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    )
        external
        payable
        override
        nonReentrant
    {
        if (msg.sender != _s.tangle) revert NotTangle();
        if (amount == 0) return;

        // Pull-payment for the ERC20 leg (via the caller's approval) lets the caller
        // wrap this entry in try/catch and revoke the approval on revert without
        // stranding tokens at the distributor.
        _receivePayment(paymentToken, amount, true);

        _s._operatorRewardTokens[operator].add(paymentToken);

        // Check if service has TTL and streaming is enabled - if so, use streaming
        Types.Service memory svc = ITangleSecurityView(_s.tangle).getService(serviceId);
        if (svc.ttl > 0 && address(_s.streamingManager) != address(0)) {
            // Stream payment over service lifetime
            uint64 startTime = svc.createdAt;
            uint64 endTime = svc.createdAt + svc.ttl;

            // If we're past the start time, start from now
            if (block.timestamp > startTime) {
                startTime = uint64(block.timestamp);
            }

            // Only create stream if there's time remaining
            if (endTime > startTime) {
                // Transfer payment to streaming manager
                if (paymentToken != address(0)) {
                    IERC20(paymentToken).safeTransfer(address(_s.streamingManager), amount);
                }
                _s.streamingManager.createStream{ value: paymentToken == address(0) ? amount : 0 }(
                    serviceId, blueprintId, operator, paymentToken, amount, startTime, endTime
                );
                emit ServiceFeeDistributed(serviceId, blueprintId, operator, paymentToken, amount);
                return;
            }
            // If service is expired, fall through to immediate distribution
        }

        // Immediate distribution (no TTL or expired service)
        _distributeImmediate(serviceId, blueprintId, operator, paymentToken, amount);
        emit ServiceFeeDistributed(serviceId, blueprintId, operator, paymentToken, amount);
    }

    /// @notice Distribute inflation-funded staker rewards (no streaming).
    function distributeInflationReward(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    )
        external
        payable
        override
        nonReentrant
    {
        if (msg.sender != _s.inflationPool) revert NotInflationPool();
        if (amount == 0) return;

        _receivePayment(paymentToken, amount, false);

        _s._operatorRewardTokens[operator].add(paymentToken);
        _distributeImmediate(serviceId, blueprintId, operator, paymentToken, amount);
        emit ServiceFeeDistributed(serviceId, blueprintId, operator, paymentToken, amount);
    }

    /// @notice Distribute payment immediately (for services without TTL). Thin wrapper over the
    ///         deployed library's consolidated `distributeImmediate` (keeps the 3 call sites terse).
    function _distributeImmediate(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    )
        internal
    {
        _s.distributeImmediate(serviceId, blueprintId, operator, paymentToken, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    function claimFor(
        address token,
        address operator,
        Types.Asset calldata asset
    )
        external
        nonReentrant
        returns (uint256 amount)
    {
        bytes32 assetHash = ServiceFeeDistributorLib.assetHash(asset);
        uint8 mode = _s._positionMode[msg.sender][operator][assetHash];
        if (mode != 0) {
            // Drip any pending streaming payments to get up-to-date rewards
            _dripOperatorStreams(operator);
            // F5: decay an expired lock boost before harvesting so future accrual is at base.
            _settleExpiredLock(msg.sender, operator, assetHash);
            _s.harvestToken(msg.sender, operator, assetHash, token, mode);
        }

        amount = _payoutClaimable(msg.sender, token);
    }

    /// @dev Zero out and pay a claimant's accrued `claimable` balance for `token`. Shared
    ///      terminal-transfer step for the claim entrypoints (each carries `nonReentrant`).
    function _payoutClaimable(address account, address token) internal returns (uint256 amount) {
        amount = _s.claimable[account][token];
        if (amount == 0) return 0;
        _s.claimable[account][token] = 0;

        _transferPayment(payable(account), token, amount);
        emit Claimed(account, token, amount);
    }

    /// @notice Claim all pending rewards across all operators and assets for a specific payment token
    /// @param token The payment token to claim (address(0) for native)
    /// @return totalAmount Total amount claimed
    function claimAll(address token) external nonReentrant returns (uint256 totalAmount) {
        totalAmount = _claimAllForToken(msg.sender, token);
    }

    /// @notice Claim all pending rewards across all tokens
    /// @param tokens The payment tokens to claim (address(0) for native)
    /// @return amounts Total amounts claimed per token (same order as input)
    function claimAllBatch(address[] calldata tokens) external nonReentrant returns (uint256[] memory amounts) {
        amounts = new uint256[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            amounts[i] = _claimAllForToken(msg.sender, tokens[i]);
        }
    }

    /// @dev Slither flags this as `reentrancy-eth` because `_dripOperatorStreams`
    ///      makes an external call to `streamingManager` (which can transfer ETH)
    ///      and `_harvestToken` writes `claimable[...]` afterwards inside the loop.
    ///      The pattern is safe because every entry point that reaches this
    ///      function (`claimFor`, `claimAll`, `claimAllBatch`) carries the
    ///      contract's `nonReentrant` guard, blocking re-entry into any other
    ///      claim/harvest path. The terminal `claimable[account][token] = 0`
    ///      followed by `_transferPayment` is strict CEI for the top-level
    ///      transfer. Audit Round 2 Slither finding — verified non-exploitable.
    function _claimAllForToken(address account, address token) internal returns (uint256 totalAmount) {
        EnumerableSet.AddressSet storage operators = _s._delegatorOperators[account];
        uint256 opLen = operators.length();

        for (uint256 i = 0; i < opLen; i++) {
            address operator = operators.at(i);

            // Drip all streams for this operator to get up-to-date rewards
            _dripOperatorStreams(operator);

            EnumerableSet.Bytes32Set storage assets = _s._delegatorAssets[account][operator];
            uint256 assetLen = assets.length();

            for (uint256 j = 0; j < assetLen; j++) {
                bytes32 assetHash = assets.at(j);
                uint8 mode = _s._positionMode[account][operator][assetHash];
                if (mode == 0) continue;

                // F5: decay an expired lock boost before harvesting so future accrual is at base.
                _settleExpiredLock(account, operator, assetHash);
                _s.harvestToken(account, operator, assetHash, token, mode);
            }
        }

        totalAmount = _payoutClaimable(account, token);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function getPoolScore(
        address operator,
        uint64 blueprintId,
        Types.Asset calldata asset
    )
        external
        view
        override
        returns (uint256 allScore, uint256 fixedScore)
    {
        bytes32 assetHash = ServiceFeeDistributorLib.assetHash(asset);
        allScore = ServiceFeeDistributorLib.applySlashFactor(
            _s.totalAllScore[operator][assetHash], _s.getAllSlashFactor(operator, assetHash)
        );
        fixedScore = ServiceFeeDistributorLib.applySlashFactor(
            _s.totalFixedScore[operator][blueprintId][assetHash],
            _s.getFixedSlashFactor(operator, blueprintId, assetHash)
        );
    }

    function getOperatorServiceUsdExposure(
        uint64 serviceId,
        uint64 blueprintId,
        address operator
    )
        external
        view
        override
        returns (uint256 totalUsdExposure)
    {
        Types.AssetSecurityRequirement[] memory reqs =
            ITangleSecurityView(_s.tangle).getServiceSecurityRequirements(serviceId);
        if (reqs.length == 0) {
            EnumerableSet.Bytes32Set storage set = _s._operatorAssetHashes[operator];
            (uint256 allUsd, uint256 fixedUsd) = _s.computeUsdTotalsForOperatorAssets(operator, blueprintId, set);
            return allUsd + fixedUsd;
        }

        (uint256 allUsdTotal, uint256 fixedUsdTotal) =
            _s.computeUsdTotalsForRequirements(serviceId, blueprintId, operator, reqs);
        return allUsdTotal + fixedUsdTotal;
    }

    function operatorRewardTokens(address operator) external view returns (address[] memory) {
        return _s._operatorRewardTokens[operator].values();
    }

    /// @notice Get all operators a delegator has positions with
    function delegatorOperators(address delegator) external view returns (address[] memory) {
        return _s._delegatorOperators[delegator].values();
    }

    /// @notice Get all asset hashes a delegator has positions for with a specific operator
    function delegatorAssets(address delegator, address operator) external view returns (bytes32[] memory) {
        return _s._delegatorAssets[delegator][operator].values();
    }

    /// @notice Get a delegator's position details
    function getPosition(
        address delegator,
        address operator,
        bytes32 assetHash
    )
        external
        view
        returns (uint8 mode, uint256 principal, uint256 score)
    {
        mode = _s._positionMode[delegator][operator][assetHash];
        principal = _s._positionPrincipal[delegator][operator][assetHash];
        score = _s._positionScore[delegator][operator][assetHash];
    }

    /// @notice Preview pending rewards for a delegator across all positions for a token
    function pendingRewards(address delegator, address token) external view returns (uint256 pending) {
        pending = _s.claimable[delegator][token];

        EnumerableSet.AddressSet storage operators = _s._delegatorOperators[delegator];
        uint256 opLen = operators.length();

        for (uint256 i = 0; i < opLen; i++) {
            address operator = operators.at(i);
            EnumerableSet.Bytes32Set storage assets = _s._delegatorAssets[delegator][operator];
            uint256 assetLen = assets.length();

            for (uint256 j = 0; j < assetLen; j++) {
                bytes32 assetHash = assets.at(j);
                uint8 mode = _s._positionMode[delegator][operator][assetHash];
                if (mode == 0) continue;
                pending += _s.pendingPosition(delegator, operator, assetHash, token, mode);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice F5: decay an expired lock-multiplier boost on a position back to base (principal).
    /// @dev Lazy decay, mirroring `RewardVaults._decayExpiredLock`. The boost is only valid while a
    ///      lock is active; once `_positionLockExpiry` passes, the position must stop earning at the
    ///      boosted score (which otherwise dilutes everyone else forever). Already-accrued rewards
    ///      are harvested at the boosted score first (they were genuinely earned while the boost was
    ///      live, lazily), THEN the score is collapsed to principal and the per-token debt re-synced
    ///      so future accrual is at base. Callers MUST drip operator streams before calling.
    ///      No-op when there is no active lock record, the lock has not expired, or there is no
    ///      boost left to remove. Idempotent. Body lives in {ServiceFeeDistributorLib.settleExpiredLock}.
    function _settleExpiredLock(address delegator, address operator, bytes32 assetHash) internal {
        _s.settleExpiredLock(delegator, operator, assetHash);
    }

    /// @notice Permissionlessly decay a position's expired lock-multiplier boost (F5).
    /// @dev Lets anyone (e.g. a diluted co-delegator or a keeper) collapse a stale boost even if
    ///      the locker never interacts again, instead of relying on the locker's next claim/change.
    function settleExpiredLock(address delegator, address operator, Types.Asset calldata asset) external nonReentrant {
        _dripOperatorStreams(operator);
        _settleExpiredLock(delegator, operator, ServiceFeeDistributorLib.assetHash(asset));
    }

    function _pruneOperatorAssetIfEmpty(address operator, bytes32 assetHash) internal {
        if (_s.totalAllScore[operator][assetHash] != 0) return;
        if (_s._totalFixedScoreByAsset[operator][assetHash] != 0) return;
        _s._operatorAssetHashes[operator].remove(assetHash);
    }

    function _pruneDelegatorPosition(address delegator, address operator, bytes32 assetHash) internal {
        _s._positionMode[delegator][operator][assetHash] = 0;
        _s._positionPrincipal[delegator][operator][assetHash] = 0;
        _s._positionScore[delegator][operator][assetHash] = 0;
        _s._positionLockExpiry[delegator][operator][assetHash] = 0;

        uint64[] storage existing = _s._fixedBlueprints[delegator][operator][assetHash];
        for (uint256 i = existing.length; i > 0; i--) {
            uint64 id = existing[i - 1];
            _s._fixedBlueprintIndexPlusOne[delegator][operator][assetHash][id] = 0;
            _s._positionFixedScore[delegator][operator][assetHash][id] = 0;
            existing.pop();
        }

        _s._delegatorAssets[delegator][operator].remove(assetHash);
        if (_s._delegatorAssets[delegator][operator].length() == 0) {
            _s._delegatorOperators[delegator].remove(operator);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STREAMING PAYMENT DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Drip all active streams for an operator and distribute chunks
    /// @dev Called before score changes to ensure fair distribution with current scores
    function _dripOperatorStreams(address operator) internal {
        if (address(_s.streamingManager) == address(0)) return;

        (
            uint64[] memory serviceIds,
            uint64[] memory blueprintIds,
            address[] memory paymentTokens,
            uint256[] memory amounts
        ) = _s.streamingManager.dripOperatorStreams(operator);

        // Distribute each dripped chunk using current scores
        for (uint256 i = 0; i < serviceIds.length; i++) {
            if (amounts[i] > 0) {
                _distributeChunk(serviceIds[i], blueprintIds[i], operator, paymentTokens[i], amounts[i]);
            }
        }
    }

    /// @notice Distribute a chunk of payment using current scores
    /// @dev Internal helper for streaming distribution - uses same logic as immediate distribution
    function _distributeChunk(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    )
        internal
    {
        // Streaming chunks distribute with the exact same score-weighted split as an
        // immediate payment; the drip duration is not needed once the chunk amount is known.
        _distributeImmediate(serviceId, blueprintId, operator, paymentToken, amount);
    }

    /// @notice Public function to drip a specific stream and distribute to delegators
    /// @dev Drips the stream and distributes the chunk based on current scores
    function drip(uint64 serviceId, address operator) external nonReentrant {
        if (address(_s.streamingManager) == address(0)) return;

        (uint256 amount, uint64 blueprintId, address paymentToken) =
            _s.streamingManager.dripAndGetChunk(serviceId, operator);

        if (amount > 0) {
            _distributeChunk(serviceId, blueprintId, operator, paymentToken, amount);
        }
    }

    /// @notice Drip all active streams for an operator and distribute to delegators
    /// @dev Anyone can call to trigger distributions
    function dripAll(address operator) external nonReentrant {
        _dripOperatorStreams(operator);
    }

    /// @notice Get active stream IDs for an operator
    function getOperatorActiveStreams(address operator) external view returns (uint64[] memory) {
        if (address(_s.streamingManager) == address(0)) return new uint64[](0);
        return _s.streamingManager.getOperatorActiveStreams(operator);
    }

    /// @notice Calculate pending drip amount without executing
    function pendingDrip(uint64 serviceId, address operator) external view returns (uint256) {
        if (address(_s.streamingManager) == address(0)) return 0;
        return _s.streamingManager.pendingDrip(serviceId, operator);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Validate/collect an inbound payment: native value must equal `amount`;
    ///      an ERC20 leg forbids stray value and (when `pullErc20`) pulls via approval.
    function _receivePayment(address paymentToken, uint256 amount, bool pullErc20) internal {
        if (paymentToken == address(0)) {
            if (msg.value != amount) revert BadMsgValue();
        } else {
            if (msg.value != 0) revert UnexpectedMsgValue();
            if (pullErc20) IERC20(paymentToken).safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    function _transferPayment(address payable to, address token, uint256 amount) internal {
        ServiceFeeDistributorLib.transferPayment(to, token, amount);
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) { }

    /// @notice Receive ETH for native token distributions from StreamingPaymentManager
    receive() external payable { }
}
