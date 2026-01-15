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

/// @title ServiceFeeDistributor
/// @notice Distributes service-fee restaker shares in the payment token, weighted by USD value and per-asset commitments.
/// @dev O(1) per-operator/per-asset/per-token distribution using accumulated-per-score accounting.
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

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256 public constant BPS_DENOMINATOR = 10000;
    uint256 public constant PRECISION = 1e18;

    /// @notice Authoritative restaking contract that emits delegation-change hooks.
    address public restaking;

    /// @notice Tangle contract (source of service requirements + per-asset operator commitments + treasury).
    address public tangle;

    /// @notice Price oracle used for USD weighting (address(0) disables USD weighting and uses raw amounts).
    IPriceOracle public priceOracle;

    /// @notice InflationPool authorized to distribute inflation-funded restaker rewards.
    address public inflationPool;

    /// @notice StreamingPaymentManager for handling streamed payments
    IStreamingPaymentManager public streamingManager;

    /// @notice TNT token address for score boost
    address public tntToken;

    /// @notice TNT score rate: how much "USD score" 1 TNT is worth (18 decimals).
    /// @dev If tntScoreRate = 1e18, then 1 TNT = $1 score regardless of actual market price.
    /// If tntScoreRate = 0, TNT uses oracle price like other tokens.
    uint256 public tntScoreRate;

    // operator => rewardToken set (payment tokens ever distributed for this operator)
    // Note: This is a superset used for view functions. The more precise set is _operatorAssetRewardTokens
    mapping(address => EnumerableSet.AddressSet) private _operatorRewardTokens;

    // operator => assetHash => rewardToken set (tokens distributed for this specific operator-asset pair)
    // This is the primary set used for iteration - much smaller than _operatorRewardTokens
    mapping(address => mapping(bytes32 => EnumerableSet.AddressSet)) private _operatorAssetRewardTokens;

    // operator => asset set (staking assets ever seen for this operator)
    mapping(address => EnumerableSet.Bytes32Set) private _operatorAssetHashes;

    // assetHash => canonical asset metadata for USD pricing
    mapping(bytes32 => Types.Asset) private _assetByHash;
    mapping(bytes32 => bool) private _assetKnown;

    // Totals (score units are amount * lockMultiplierBps / 10_000).
    mapping(address => mapping(bytes32 => uint256)) public totalAllScore; // operator => assetHash => totalScore
    mapping(address => mapping(uint64 => mapping(bytes32 => uint256))) public totalFixedScore; // operator => blueprintId => assetHash => totalScore
    mapping(address => mapping(bytes32 => uint256)) private _totalFixedScoreByAsset; // operator => assetHash => totalFixedScore

    // Slash factors (PRECISION = no slash). Applied only for USD weighting across assets.
    mapping(address => mapping(bytes32 => uint256)) private _allSlashFactor; // operator => assetHash => factor
    mapping(address => mapping(uint64 => mapping(bytes32 => uint256))) private _fixedSlashFactor; // operator => blueprintId => assetHash => factor

    // Accumulators.
    mapping(address => mapping(bytes32 => mapping(address => uint256))) public accAllPerScore; // operator => assetHash => rewardToken => acc
    mapping(address => mapping(uint64 => mapping(bytes32 => mapping(address => uint256)))) public accFixedPerScore; // operator => blueprintId => assetHash => rewardToken => acc

    // Position mode: 0 = none, 1 = All, 2 = Fixed
    mapping(address => mapping(address => mapping(bytes32 => uint8))) private _positionMode;
    // Principal and score for the position (delegator => operator => assetHash)
    mapping(address => mapping(address => mapping(bytes32 => uint256))) private _positionPrincipal;
    mapping(address => mapping(address => mapping(bytes32 => uint256))) private _positionScore;
    mapping(address => mapping(address => mapping(bytes32 => mapping(uint64 => uint256)))) private _positionFixedScore;

    // Fixed-mode blueprint selection (delegator => operator => assetHash => blueprints)
    mapping(address => mapping(address => mapping(bytes32 => uint64[]))) private _fixedBlueprints;
    mapping(address => mapping(address => mapping(bytes32 => mapping(uint64 => uint256)))) private _fixedBlueprintIndexPlusOne;

    // Reward debt (per token) to prevent retroactive claims.
    // debt = score * accumulator at time of last sync. pending = score * acc - debt
    mapping(address => mapping(address => mapping(bytes32 => mapping(address => uint256)))) private _debtAll;
    // delegator => operator => assetHash => token => debt
    mapping(address => mapping(address => mapping(uint64 => mapping(bytes32 => mapping(address => uint256))))) private _debtFixed;
    // delegator => operator => blueprintId => assetHash => token => debt

    // Claimable balances (per payment token).
    mapping(address => mapping(address => uint256)) public claimable; // account => token => amount

    // Delegator position tracking for claimAll iteration
    mapping(address => EnumerableSet.AddressSet) private _delegatorOperators; // delegator => operators
    mapping(address => mapping(address => EnumerableSet.Bytes32Set)) private _delegatorAssets; // delegator => operator => assetHashes

    event RestakingConfigured(address indexed restaking);
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

    error NotRestaking();
    error NotTangle();
    error NotInflationPool();
    error InvalidModeChange();
    error InvalidBlueprintAmounts();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address restaking_,
        address tangle_,
        address oracle_
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        restaking = restaking_;
        tangle = tangle_;
        priceOracle = IPriceOracle(oracle_);

        emit RestakingConfigured(restaking_);
        emit TangleConfigured(tangle_);
        emit PriceOracleConfigured(oracle_);
    }

    function setRestaking(address restaking_) external onlyRole(ADMIN_ROLE) {
        restaking = restaking_;
        emit RestakingConfigured(restaking_);
    }

    function setTangle(address tangle_) external onlyRole(ADMIN_ROLE) {
        tangle = tangle_;
        emit TangleConfigured(tangle_);
    }

    function setPriceOracle(address oracle_) external onlyRole(ADMIN_ROLE) {
        priceOracle = IPriceOracle(oracle_);
        emit PriceOracleConfigured(oracle_);
    }

    function setInflationPool(address pool_) external onlyRole(ADMIN_ROLE) {
        inflationPool = pool_;
        emit InflationPoolConfigured(pool_);
    }

    function setStreamingManager(address streamingManager_) external onlyRole(ADMIN_ROLE) {
        streamingManager = IStreamingPaymentManager(streamingManager_);
        emit StreamingManagerConfigured(streamingManager_);
    }

    /// @notice Set TNT token and its score rate for fee distribution boost.
    /// @param tntToken_ The TNT token address (address(0) to disable).
    /// @param scoreRate_ Score rate in 18 decimals. 1e18 means 1 TNT = $1 score.
    ///        Set to 0 to use oracle price for TNT like other tokens.
    /// @dev Example: If TNT market price is $0.10 and scoreRate_ = 1e18,
    ///      then 1 TNT earns 10x the fee share compared to its market value.
    function setTntScoreRate(address tntToken_, uint256 scoreRate_) external onlyRole(ADMIN_ROLE) {
        tntToken = tntToken_;
        tntScoreRate = scoreRate_;
        emit TntScoreRateConfigured(tntToken_, scoreRate_);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HOOKS FROM RESTAKING
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
        uint16 lockMultiplierBps
    ) external override {
        if (msg.sender != restaking) revert NotRestaking();

        // IMPORTANT: Drip all active streams for this operator BEFORE score changes
        // This ensures rewards are distributed with the scores that were active
        // during the streaming period, not the new scores after delegation change
        _dripOperatorStreams(operator);

        bytes32 assetHash = _assetHash(asset);
        if (!_assetKnown[assetHash]) {
            _assetKnown[assetHash] = true;
            _assetByHash[assetHash] = Types.Asset({ kind: asset.kind, token: asset.token });
        }
        _operatorAssetHashes[operator].add(assetHash);
        uint8 newMode = selectionMode == Types.BlueprintSelectionMode.All ? 1 : 2;
        uint8 existingMode = _positionMode[delegator][operator][assetHash];
        if (existingMode != 0 && existingMode != newMode) revert InvalidModeChange();

        // Harvest for all known payment tokens before mutating scores.
        _harvestAllTokens(delegator, operator, assetHash, existingMode == 0 ? newMode : existingMode);

        // Update principal/score.
        uint256 principalBefore = _positionPrincipal[delegator][operator][assetHash];
        uint256 scoreBefore = _positionScore[delegator][operator][assetHash];

        uint256 scoreDelta;
        uint256 principalAfter;
        uint256 scoreAfter;
        if (isIncrease) {
            scoreDelta = (amount * lockMultiplierBps) / BPS_DENOMINATOR;
            principalAfter = principalBefore + amount;
            scoreAfter = scoreBefore + scoreDelta;
            _positionPrincipal[delegator][operator][assetHash] = principalAfter;
            _positionScore[delegator][operator][assetHash] = scoreAfter;
        } else {
            // Decrease: preserve proportional score (handles prior lock multipliers).
            principalAfter = amount > principalBefore ? 0 : principalBefore - amount;
            if (principalBefore > 0) {
                scoreDelta = (scoreBefore * amount) / principalBefore;
            }
            scoreAfter = scoreDelta > scoreBefore ? 0 : scoreBefore - scoreDelta;
            _positionPrincipal[delegator][operator][assetHash] = principalAfter;
            _positionScore[delegator][operator][assetHash] = scoreAfter;
        }

        _positionMode[delegator][operator][assetHash] = newMode;

        // Track delegator position for claimAll iteration (only on first interaction)
        if (existingMode == 0) {
            _delegatorOperators[delegator].add(operator);
            _delegatorAssets[delegator][operator].add(assetHash);
        }

        // Sync Fixed blueprint set from restaking payload (authoritative).
        if (newMode == 2) {
            _setFixedBlueprints(delegator, operator, assetHash, blueprintIds);
        }

        // Update totals.
        if (newMode == 1) {
            totalAllScore[operator][assetHash] = isIncrease
                ? totalAllScore[operator][assetHash] + scoreDelta
                : (scoreDelta > totalAllScore[operator][assetHash] ? 0 : totalAllScore[operator][assetHash] - scoreDelta);
        } else {
            _applyFixedScoreDelta(
                delegator,
                operator,
                assetHash,
                scoreDelta,
                amount,
                isIncrease,
                blueprintIds,
                blueprintAmounts
            );
        }

        _pruneOperatorAssetIfEmpty(operator, assetHash);

        // Reset reward debt to prevent retroactive claims with the new score.
        _syncDebtsToCurrentAcc(delegator, operator, assetHash, newMode);

        if (principalAfter == 0 && scoreAfter == 0) {
            _pruneDelegatorPosition(delegator, operator, assetHash);
        }

        emit DelegationTracked(
            delegator,
            operator,
            asset.token,
            selectionMode,
            _positionPrincipal[delegator][operator][assetHash],
            _positionScore[delegator][operator][assetHash]
        );
    }

    function onAllModeSlashed(
        address operator,
        Types.Asset calldata asset,
        uint16 slashBps
    ) external override {
        if (msg.sender != restaking) revert NotRestaking();
        if (slashBps == 0) return;
        if (slashBps > BPS_DENOMINATOR) slashBps = uint16(BPS_DENOMINATOR);

        bytes32 assetHash = _assetHash(asset);
        uint256 current = _getAllSlashFactor(operator, assetHash);
        _allSlashFactor[operator][assetHash] = (current * (BPS_DENOMINATOR - slashBps)) / BPS_DENOMINATOR;
    }

    function onFixedModeSlashed(
        address operator,
        uint64 blueprintId,
        Types.Asset calldata asset,
        uint16 slashBps
    ) external override {
        if (msg.sender != restaking) revert NotRestaking();
        if (slashBps == 0) return;
        if (slashBps > BPS_DENOMINATOR) slashBps = uint16(BPS_DENOMINATOR);

        bytes32 assetHash = _assetHash(asset);
        uint256 current = _getFixedSlashFactor(operator, blueprintId, assetHash);
        _fixedSlashFactor[operator][blueprintId][assetHash] = (current * (BPS_DENOMINATOR - slashBps)) / BPS_DENOMINATOR;
    }

    function onBlueprintsRebalanced(
        address delegator,
        address operator,
        Types.Asset calldata asset,
        uint64[] calldata blueprintIds,
        uint256[] calldata blueprintAmounts
    ) external override {
        if (msg.sender != restaking) revert NotRestaking();

        // Drip before score changes
        _dripOperatorStreams(operator);

        bytes32 assetHash = _assetHash(asset);
        if (_positionMode[delegator][operator][assetHash] != 2) {
            revert InvalidModeChange();
        }

        if (blueprintIds.length != blueprintAmounts.length) {
            revert InvalidBlueprintAmounts();
        }

        _harvestAllTokens(delegator, operator, assetHash, 2);

        uint64[] storage existing = _fixedBlueprints[delegator][operator][assetHash];
        for (uint256 i = 0; i < existing.length; i++) {
            uint64 bpId = existing[i];
            uint256 oldScore = _positionFixedScore[delegator][operator][assetHash][bpId];
            if (oldScore == 0) continue;
            uint256 cur = totalFixedScore[operator][bpId][assetHash];
            totalFixedScore[operator][bpId][assetHash] = oldScore > cur ? 0 : cur - oldScore;
            uint256 curTotalByAsset = _totalFixedScoreByAsset[operator][assetHash];
            _totalFixedScoreByAsset[operator][assetHash] =
                oldScore > curTotalByAsset ? 0 : curTotalByAsset - oldScore;
            _positionFixedScore[delegator][operator][assetHash][bpId] = 0;
        }

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < blueprintAmounts.length; i++) {
            totalAmount += blueprintAmounts[i];
        }

        uint256 userScore = _positionScore[delegator][operator][assetHash];
        if (totalAmount > 0 && userScore > 0) {
            uint256 remainingScore = userScore;
            for (uint256 i = 0; i < blueprintIds.length; i++) {
                uint64 bpId = blueprintIds[i];
                uint256 scoreForBlueprint = i == blueprintIds.length - 1
                    ? remainingScore
                    : (userScore * blueprintAmounts[i]) / totalAmount;
                remainingScore = remainingScore > scoreForBlueprint ? remainingScore - scoreForBlueprint : 0;

                _positionFixedScore[delegator][operator][assetHash][bpId] = scoreForBlueprint;
                totalFixedScore[operator][bpId][assetHash] += scoreForBlueprint;
                _totalFixedScoreByAsset[operator][assetHash] += scoreForBlueprint;
            }
        }

        _setFixedBlueprints(delegator, operator, assetHash, blueprintIds);

        _syncDebtsToCurrentAcc(delegator, operator, assetHash, 2);

        _pruneOperatorAssetIfEmpty(operator, assetHash);
    }

    /// @notice Called when an operator is about to leave a service
    /// @dev Delegates to StreamingPaymentManager to drip before removal
    function onOperatorLeaving(uint64 serviceId, address operator) external override {
        if (msg.sender != tangle) revert NotTangle();
        if (address(streamingManager) != address(0)) {
            streamingManager.onOperatorLeaving(serviceId, operator);
        }
    }

    /// @notice Called when a service is terminated early - refunds remaining streamed payments
    /// @dev Delegates to StreamingPaymentManager which handles refunds
    function onServiceTerminated(uint64 serviceId, address refundRecipient) external override {
        if (msg.sender != tangle) revert NotTangle();
        if (address(streamingManager) != address(0)) {
            streamingManager.onServiceTerminated(serviceId, refundRecipient);
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
    ) external payable override nonReentrant {
        if (msg.sender != tangle) revert NotTangle();
        if (amount == 0) return;

        if (paymentToken == address(0)) {
            require(msg.value == amount, "bad msg.value");
        } else {
            require(msg.value == 0, "unexpected msg.value");
        }

        _operatorRewardTokens[operator].add(paymentToken);

        // Check if service has TTL and streaming is enabled - if so, use streaming
        Types.Service memory svc = ITangleSecurityView(tangle).getService(serviceId);
        if (svc.ttl > 0 && address(streamingManager) != address(0)) {
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
                    IERC20(paymentToken).safeTransfer(address(streamingManager), amount);
                }
                streamingManager.createStream{ value: paymentToken == address(0) ? amount : 0 }(
                    serviceId,
                    blueprintId,
                    operator,
                    paymentToken,
                    amount,
                    startTime,
                    endTime
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

    /// @notice Distribute inflation-funded restaker rewards (no streaming).
    function distributeInflationReward(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    ) external payable override nonReentrant {
        if (msg.sender != inflationPool) revert NotInflationPool();
        if (amount == 0) return;

        if (paymentToken == address(0)) {
            require(msg.value == amount, "bad msg.value");
        } else {
            require(msg.value == 0, "unexpected msg.value");
        }

        _operatorRewardTokens[operator].add(paymentToken);
        _distributeImmediate(serviceId, blueprintId, operator, paymentToken, amount);
        emit ServiceFeeDistributed(serviceId, blueprintId, operator, paymentToken, amount);
    }

    /// @notice Distribute payment immediately (for services without TTL)
    function _distributeImmediate(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    ) internal {
        Types.AssetSecurityRequirement[] memory reqs =
            ITangleSecurityView(tangle).getServiceSecurityRequirements(serviceId);
        if (reqs.length == 0) {
            _distributeWithoutRequirements(serviceId, blueprintId, operator, paymentToken, amount);
            return;
        }

        (uint256 allUsdTotal, uint256 fixedUsdTotal) =
            _computeUsdTotalsForRequirements(serviceId, blueprintId, operator, reqs);

        uint256 totalUsd = allUsdTotal + fixedUsdTotal;
        if (totalUsd == 0) {
            _transferPayment(ITangleSecurityView(tangle).treasury(), paymentToken, amount);
            return;
        }

        uint256 allAmount = (amount * allUsdTotal) / totalUsd;
        uint256 fixedAmount = amount - allAmount;

        if (allAmount > 0 && allUsdTotal > 0) {
            _distributeAllForRequirements(serviceId, operator, paymentToken, allAmount, allUsdTotal, reqs);
        }

        if (fixedAmount > 0 && fixedUsdTotal > 0) {
            _distributeFixedForRequirements(serviceId, blueprintId, operator, paymentToken, fixedAmount, fixedUsdTotal, reqs);
        }
    }

    function _distributeWithoutRequirements(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    ) internal {
        serviceId; // silence unused warning (reserved for future policy gating)

        EnumerableSet.Bytes32Set storage set = _operatorAssetHashes[operator];
        uint256 assetCount = set.length();
        if (assetCount == 0) {
            _transferPayment(ITangleSecurityView(tangle).treasury(), paymentToken, amount);
            return;
        }

        (uint256 allUsdTotal, uint256 fixedUsdTotal) =
            _computeUsdTotalsForOperatorAssets(operator, blueprintId, set);

        uint256 totalUsd = allUsdTotal + fixedUsdTotal;
        if (totalUsd == 0) {
            _transferPayment(ITangleSecurityView(tangle).treasury(), paymentToken, amount);
            return;
        }

        uint256 allAmount = (amount * allUsdTotal) / totalUsd;
        uint256 fixedAmount = amount - allAmount;

        if (allAmount > 0 && allUsdTotal > 0) {
            _distributeAllForOperatorAssets(operator, paymentToken, allAmount, allUsdTotal, set);
        }

        if (fixedAmount > 0 && fixedUsdTotal > 0) {
            _distributeFixedForOperatorAssets(operator, blueprintId, paymentToken, fixedAmount, fixedUsdTotal, set);
        }
    }

    function _computeUsdTotalsForRequirements(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        Types.AssetSecurityRequirement[] memory reqs
    ) internal view returns (uint256 allUsdTotal, uint256 fixedUsdTotal) {
        for (uint256 i = 0; i < reqs.length; i++) {
            Types.Asset memory a = reqs[i].asset;
            bytes32 assetHash = _assetHash(a);

            uint16 commitmentBps = ITangleSecurityView(tangle).getServiceSecurityCommitmentBps(
                serviceId,
                operator,
                a.kind,
                a.token
            );
            if (commitmentBps == 0) continue;

            uint256 allScore = totalAllScore[operator][assetHash];
            uint256 fixedScore = totalFixedScore[operator][blueprintId][assetHash];

            uint256 allEffective = _applySlashFactor(allScore, _getAllSlashFactor(operator, assetHash));
            uint256 fixedEffective = _applySlashFactor(fixedScore, _getFixedSlashFactor(operator, blueprintId, assetHash));

            uint256 allExposed = (allEffective * commitmentBps) / BPS_DENOMINATOR;
            uint256 fixedExposed = (fixedEffective * commitmentBps) / BPS_DENOMINATOR;

            allUsdTotal += _toUsd(a, allExposed);
            fixedUsdTotal += _toUsd(a, fixedExposed);
        }
    }

    function _distributeAllForRequirements(
        uint64 serviceId,
        address operator,
        address paymentToken,
        uint256 amount,
        uint256 usdTotal,
        Types.AssetSecurityRequirement[] memory reqs
    ) internal {
        uint256 remaining = amount;
        uint256 remainingUsd = usdTotal;

        for (uint256 i = 0; i < reqs.length && remaining > 0; i++) {
            Types.Asset memory a = reqs[i].asset;
            bytes32 assetHash = _assetHash(a);
            uint16 commitmentBps = ITangleSecurityView(tangle).getServiceSecurityCommitmentBps(
                serviceId,
                operator,
                a.kind,
                a.token
            );
            if (commitmentBps == 0) continue;

            uint256 allScore = totalAllScore[operator][assetHash];
            if (allScore == 0) continue;

            uint256 allEffective = _applySlashFactor(allScore, _getAllSlashFactor(operator, assetHash));
            uint256 allUsd = _toUsd(a, (allEffective * commitmentBps) / BPS_DENOMINATOR);
            if (allUsd == 0) continue;

            uint256 share = (remaining * allUsd) / remainingUsd;
            remaining -= share;
            remainingUsd -= allUsd;
            if (share == 0) continue;

            accAllPerScore[operator][assetHash][paymentToken] += (share * PRECISION) / allScore;
            _operatorAssetRewardTokens[operator][assetHash].add(paymentToken);
        }
    }

    function _distributeFixedForRequirements(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount,
        uint256 usdTotal,
        Types.AssetSecurityRequirement[] memory reqs
    ) internal {
        uint256 remaining = amount;
        uint256 remainingUsd = usdTotal;

        for (uint256 i = 0; i < reqs.length && remaining > 0; i++) {
            Types.Asset memory a = reqs[i].asset;
            bytes32 assetHash = _assetHash(a);
            uint16 commitmentBps = ITangleSecurityView(tangle).getServiceSecurityCommitmentBps(
                serviceId,
                operator,
                a.kind,
                a.token
            );
            if (commitmentBps == 0) continue;

            uint256 fixedScore = totalFixedScore[operator][blueprintId][assetHash];
            if (fixedScore == 0) continue;

            uint256 fixedEffective = _applySlashFactor(fixedScore, _getFixedSlashFactor(operator, blueprintId, assetHash));
            uint256 fixedUsd = _toUsd(a, (fixedEffective * commitmentBps) / BPS_DENOMINATOR);
            if (fixedUsd == 0) continue;

            uint256 share = (remaining * fixedUsd) / remainingUsd;
            remaining -= share;
            remainingUsd -= fixedUsd;
            if (share == 0) continue;

            accFixedPerScore[operator][blueprintId][assetHash][paymentToken] += (share * PRECISION) / fixedScore;
            _operatorAssetRewardTokens[operator][assetHash].add(paymentToken);
        }
    }

    function _computeUsdTotalsForOperatorAssets(
        address operator,
        uint64 blueprintId,
        EnumerableSet.Bytes32Set storage set
    ) internal view returns (uint256 allUsdTotal, uint256 fixedUsdTotal) {
        uint256 assetCount = set.length();
        for (uint256 i = 0; i < assetCount; i++) {
            bytes32 assetHash = set.at(i);
            Types.Asset memory asset = _assetByHash[assetHash];
            uint256 allScore = totalAllScore[operator][assetHash];
            uint256 fixedScore = totalFixedScore[operator][blueprintId][assetHash];
            allUsdTotal += _toUsd(asset, _applySlashFactor(allScore, _getAllSlashFactor(operator, assetHash)));
            fixedUsdTotal +=
                _toUsd(asset, _applySlashFactor(fixedScore, _getFixedSlashFactor(operator, blueprintId, assetHash)));
        }
    }

    function _distributeAllForOperatorAssets(
        address operator,
        address paymentToken,
        uint256 amount,
        uint256 usdTotal,
        EnumerableSet.Bytes32Set storage set
    ) internal {
        uint256 remaining = amount;
        uint256 remainingUsd = usdTotal;

        uint256 assetCount = set.length();
        for (uint256 i = 0; i < assetCount && remaining > 0; i++) {
            bytes32 assetHash = set.at(i);
            uint256 denom = totalAllScore[operator][assetHash];
            if (denom == 0) continue;

            uint256 usd = _toUsd(
                _assetByHash[assetHash],
                _applySlashFactor(denom, _getAllSlashFactor(operator, assetHash))
            );
            if (usd == 0) continue;

            uint256 share = (remaining * usd) / remainingUsd;
            remaining -= share;
            remainingUsd -= usd;
            if (share == 0) continue;

            accAllPerScore[operator][assetHash][paymentToken] += (share * PRECISION) / denom;
            _operatorAssetRewardTokens[operator][assetHash].add(paymentToken);
        }
    }

    function _distributeFixedForOperatorAssets(
        address operator,
        uint64 blueprintId,
        address paymentToken,
        uint256 amount,
        uint256 usdTotal,
        EnumerableSet.Bytes32Set storage set
    ) internal {
        uint256 remaining = amount;
        uint256 remainingUsd = usdTotal;

        uint256 assetCount = set.length();
        for (uint256 i = 0; i < assetCount && remaining > 0; i++) {
            bytes32 assetHash = set.at(i);
            uint256 denom = totalFixedScore[operator][blueprintId][assetHash];
            if (denom == 0) continue;

            uint256 usd = _toUsd(
                _assetByHash[assetHash],
                _applySlashFactor(denom, _getFixedSlashFactor(operator, blueprintId, assetHash))
            );
            if (usd == 0) continue;

            uint256 share = (remaining * usd) / remainingUsd;
            remaining -= share;
            remainingUsd -= usd;
            if (share == 0) continue;

            accFixedPerScore[operator][blueprintId][assetHash][paymentToken] += (share * PRECISION) / denom;
            _operatorAssetRewardTokens[operator][assetHash].add(paymentToken);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    function claimFor(
        address token,
        address operator,
        Types.Asset calldata asset
    ) external nonReentrant returns (uint256 amount) {
        bytes32 assetHash = _assetHash(asset);
        uint8 mode = _positionMode[msg.sender][operator][assetHash];
        if (mode != 0) {
            // Drip any pending streaming payments to get up-to-date rewards
            _dripOperatorStreams(operator);
            _harvestToken(msg.sender, operator, assetHash, token, mode);
        }

        amount = claimable[msg.sender][token];
        if (amount == 0) return 0;
        claimable[msg.sender][token] = 0;

        _transferPayment(payable(msg.sender), token, amount);
        emit Claimed(msg.sender, token, amount);
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

    function _claimAllForToken(address account, address token) internal returns (uint256 totalAmount) {
        EnumerableSet.AddressSet storage operators = _delegatorOperators[account];
        uint256 opLen = operators.length();

        for (uint256 i = 0; i < opLen; i++) {
            address operator = operators.at(i);

            // Drip all streams for this operator to get up-to-date rewards
            _dripOperatorStreams(operator);

            EnumerableSet.Bytes32Set storage assets = _delegatorAssets[account][operator];
            uint256 assetLen = assets.length();

            for (uint256 j = 0; j < assetLen; j++) {
                bytes32 assetHash = assets.at(j);
                uint8 mode = _positionMode[account][operator][assetHash];
                if (mode == 0) continue;

                _harvestToken(account, operator, assetHash, token, mode);
            }
        }

        totalAmount = claimable[account][token];
        if (totalAmount == 0) return 0;
        claimable[account][token] = 0;

        _transferPayment(payable(account), token, totalAmount);
        emit Claimed(account, token, totalAmount);
    }

    function _harvestToken(
        address delegator,
        address operator,
        bytes32 assetHash,
        address token,
        uint8 mode
    ) internal {
        uint256 userScore = _positionScore[delegator][operator][assetHash];

        if (mode == 1) {
            if (userScore == 0) return;
            uint256 acc = accAllPerScore[operator][assetHash][token];
            uint256 accumulated = (userScore * acc) / PRECISION;
            uint256 debt = _debtAll[delegator][operator][assetHash][token];
            if (accumulated > debt) {
                claimable[delegator][token] += (accumulated - debt);
            }
            _debtAll[delegator][operator][assetHash][token] = accumulated;
            return;
        }

        // Fixed mode - iterate over blueprints
        uint64[] storage bps = _fixedBlueprints[delegator][operator][assetHash];
        for (uint256 i = 0; i < bps.length; i++) {
            uint64 bpId = bps[i];
            uint256 blueprintScore = _positionFixedScore[delegator][operator][assetHash][bpId];
            if (blueprintScore == 0) continue;
            uint256 acc = accFixedPerScore[operator][bpId][assetHash][token];
            uint256 accumulated = (blueprintScore * acc) / PRECISION;
            uint256 debt = _debtFixed[delegator][operator][bpId][assetHash][token];
            if (accumulated > debt) {
                claimable[delegator][token] += (accumulated - debt);
            }
            _debtFixed[delegator][operator][bpId][assetHash][token] = accumulated;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function getPoolScore(
        address operator,
        uint64 blueprintId,
        Types.Asset calldata asset
    ) external view override returns (uint256 allScore, uint256 fixedScore) {
        bytes32 assetHash = _assetHash(asset);
        allScore = _applySlashFactor(totalAllScore[operator][assetHash], _getAllSlashFactor(operator, assetHash));
        fixedScore = _applySlashFactor(
            totalFixedScore[operator][blueprintId][assetHash],
            _getFixedSlashFactor(operator, blueprintId, assetHash)
        );
    }

    function getOperatorServiceUsdExposure(
        uint64 serviceId,
        uint64 blueprintId,
        address operator
    ) external view override returns (uint256 totalUsdExposure) {
        Types.AssetSecurityRequirement[] memory reqs =
            ITangleSecurityView(tangle).getServiceSecurityRequirements(serviceId);
        if (reqs.length == 0) {
            EnumerableSet.Bytes32Set storage set = _operatorAssetHashes[operator];
            (uint256 allUsd, uint256 fixedUsd) = _computeUsdTotalsForOperatorAssets(operator, blueprintId, set);
            return allUsd + fixedUsd;
        }

        (uint256 allUsdTotal, uint256 fixedUsdTotal) =
            _computeUsdTotalsForRequirements(serviceId, blueprintId, operator, reqs);
        return allUsdTotal + fixedUsdTotal;
    }

    function operatorRewardTokens(address operator) external view returns (address[] memory tokens) {
        EnumerableSet.AddressSet storage set = _operatorRewardTokens[operator];
        tokens = new address[](set.length());
        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i] = set.at(i);
        }
    }

    /// @notice Get all operators a delegator has positions with
    function delegatorOperators(address delegator) external view returns (address[] memory operators) {
        EnumerableSet.AddressSet storage set = _delegatorOperators[delegator];
        operators = new address[](set.length());
        for (uint256 i = 0; i < operators.length; i++) {
            operators[i] = set.at(i);
        }
    }

    /// @notice Get all asset hashes a delegator has positions for with a specific operator
    function delegatorAssets(address delegator, address operator) external view returns (bytes32[] memory assetHashes) {
        EnumerableSet.Bytes32Set storage set = _delegatorAssets[delegator][operator];
        assetHashes = new bytes32[](set.length());
        for (uint256 i = 0; i < assetHashes.length; i++) {
            assetHashes[i] = set.at(i);
        }
    }

    /// @notice Get a delegator's position details
    function getPosition(
        address delegator,
        address operator,
        bytes32 assetHash
    ) external view returns (uint8 mode, uint256 principal, uint256 score) {
        mode = _positionMode[delegator][operator][assetHash];
        principal = _positionPrincipal[delegator][operator][assetHash];
        score = _positionScore[delegator][operator][assetHash];
    }

    /// @notice Preview pending rewards for a delegator across all positions for a token
    function pendingRewards(address delegator, address token) external view returns (uint256 pending) {
        pending = claimable[delegator][token];

        EnumerableSet.AddressSet storage operators = _delegatorOperators[delegator];
        uint256 opLen = operators.length();

        for (uint256 i = 0; i < opLen; i++) {
            address operator = operators.at(i);
            EnumerableSet.Bytes32Set storage assets = _delegatorAssets[delegator][operator];
            uint256 assetLen = assets.length();

            for (uint256 j = 0; j < assetLen; j++) {
                bytes32 assetHash = assets.at(j);
                uint8 mode = _positionMode[delegator][operator][assetHash];
                if (mode == 0) continue;

                if (mode == 1) {
                    uint256 userScore = _positionScore[delegator][operator][assetHash];
                    if (userScore == 0) continue;
                    uint256 acc = accAllPerScore[operator][assetHash][token];
                    uint256 accumulated = (userScore * acc) / PRECISION;
                    uint256 debt = _debtAll[delegator][operator][assetHash][token];
                    if (accumulated > debt) {
                        pending += (accumulated - debt);
                    }
                } else {
                    uint64[] storage bps = _fixedBlueprints[delegator][operator][assetHash];
                    for (uint256 k = 0; k < bps.length; k++) {
                        uint64 bpId = bps[k];
                        uint256 blueprintScore = _positionFixedScore[delegator][operator][assetHash][bpId];
                        if (blueprintScore == 0) continue;
                        uint256 acc = accFixedPerScore[operator][bpId][assetHash][token];
                        uint256 accumulated = (blueprintScore * acc) / PRECISION;
                        uint256 debt = _debtFixed[delegator][operator][bpId][assetHash][token];
                        if (accumulated > debt) {
                            pending += (accumulated - debt);
                        }
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════════

    function _harvestAllTokens(address delegator, address operator, bytes32 assetHash, uint8 mode) internal {
        // Use per-asset token set for efficiency - only iterates tokens actually distributed for this asset
        EnumerableSet.AddressSet storage set = _operatorAssetRewardTokens[operator][assetHash];
        uint256 length = set.length();
        for (uint256 i = 0; i < length; i++) {
            _harvestToken(delegator, operator, assetHash, set.at(i), mode);
        }
    }

    function _pruneOperatorAssetIfEmpty(address operator, bytes32 assetHash) internal {
        if (totalAllScore[operator][assetHash] != 0) return;
        if (_totalFixedScoreByAsset[operator][assetHash] != 0) return;
        _operatorAssetHashes[operator].remove(assetHash);
    }

    function _pruneDelegatorPosition(address delegator, address operator, bytes32 assetHash) internal {
        _positionMode[delegator][operator][assetHash] = 0;
        _positionPrincipal[delegator][operator][assetHash] = 0;
        _positionScore[delegator][operator][assetHash] = 0;

        uint64[] storage existing = _fixedBlueprints[delegator][operator][assetHash];
        for (uint256 i = existing.length; i > 0; i--) {
            uint64 id = existing[i - 1];
            _fixedBlueprintIndexPlusOne[delegator][operator][assetHash][id] = 0;
            _positionFixedScore[delegator][operator][assetHash][id] = 0;
            existing.pop();
        }

        _delegatorAssets[delegator][operator].remove(assetHash);
        if (_delegatorAssets[delegator][operator].length() == 0) {
            _delegatorOperators[delegator].remove(operator);
        }
    }

    function _applyFixedScoreDelta(
        address delegator,
        address operator,
        bytes32 assetHash,
        uint256 scoreDelta,
        uint256 amount,
        bool isIncrease,
        uint64[] calldata blueprintIds,
        uint256[] calldata blueprintAmounts
    ) internal {
        if (blueprintIds.length == 0) return;
        if (blueprintIds.length != blueprintAmounts.length) {
            revert InvalidBlueprintAmounts();
        }
        if (scoreDelta == 0 || amount == 0) return;

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < blueprintAmounts.length; i++) {
            totalAmount += blueprintAmounts[i];
        }
        if (totalAmount == 0) return;

        uint256 remainingScore = scoreDelta;
        for (uint256 i = 0; i < blueprintIds.length; i++) {
            uint64 bpId = blueprintIds[i];
            uint256 scoreForBlueprint = i == blueprintIds.length - 1
                ? remainingScore
                : (scoreDelta * blueprintAmounts[i]) / totalAmount;
            remainingScore = remainingScore > scoreForBlueprint ? remainingScore - scoreForBlueprint : 0;

            if (isIncrease) {
                _positionFixedScore[delegator][operator][assetHash][bpId] += scoreForBlueprint;
                totalFixedScore[operator][bpId][assetHash] += scoreForBlueprint;
                _totalFixedScoreByAsset[operator][assetHash] += scoreForBlueprint;
            } else {
                uint256 currentScore = _positionFixedScore[delegator][operator][assetHash][bpId];
                uint256 dec = scoreForBlueprint > currentScore ? currentScore : scoreForBlueprint;
                _positionFixedScore[delegator][operator][assetHash][bpId] = currentScore - dec;

                uint256 curTotal = totalFixedScore[operator][bpId][assetHash];
                totalFixedScore[operator][bpId][assetHash] = dec > curTotal ? 0 : curTotal - dec;
                uint256 curTotalByAsset = _totalFixedScoreByAsset[operator][assetHash];
                _totalFixedScoreByAsset[operator][assetHash] =
                    dec > curTotalByAsset ? 0 : curTotalByAsset - dec;
            }
        }
    }

    /// @dev Updates all reward debts to current accumulator state after a score change.
    /// This is necessary for correct accounting - prevents retroactive claims with new score.
    /// @notice O(N) where N = number of reward tokens for this specific operator-asset pair.
    /// Much more efficient than iterating all operator tokens.
    function _syncDebtsToCurrentAcc(address delegator, address operator, bytes32 assetHash, uint8 mode) internal {
        uint256 userScore = _positionScore[delegator][operator][assetHash];
        // Use per-asset token set for efficiency
        EnumerableSet.AddressSet storage set = _operatorAssetRewardTokens[operator][assetHash];
        uint256 length = set.length();

        if (mode == 1) {
            for (uint256 i = 0; i < length; i++) {
                address token = set.at(i);
                uint256 acc = accAllPerScore[operator][assetHash][token];
                _debtAll[delegator][operator][assetHash][token] = (userScore * acc) / PRECISION;
            }
            return;
        }

        // Fixed mode
        uint64[] storage bps = _fixedBlueprints[delegator][operator][assetHash];
        for (uint256 j = 0; j < bps.length; j++) {
            uint64 bpId = bps[j];
            uint256 blueprintScore = _positionFixedScore[delegator][operator][assetHash][bpId];
            if (blueprintScore == 0) continue;
            for (uint256 i = 0; i < length; i++) {
                address token = set.at(i);
                uint256 acc = accFixedPerScore[operator][bpId][assetHash][token];
                _debtFixed[delegator][operator][bpId][assetHash][token] = (blueprintScore * acc) / PRECISION;
            }
        }
    }

    function _setFixedBlueprints(address delegator, address operator, bytes32 assetHash, uint64[] calldata blueprintIds) internal {
        // Clear existing set
        uint64[] storage existing = _fixedBlueprints[delegator][operator][assetHash];
        for (uint256 i = existing.length; i > 0; i--) {
            uint64 id = existing[i - 1];
            _fixedBlueprintIndexPlusOne[delegator][operator][assetHash][id] = 0;
            existing.pop();
        }

        for (uint256 i = 0; i < blueprintIds.length; i++) {
            uint64 id = blueprintIds[i];
            if (_fixedBlueprintIndexPlusOne[delegator][operator][assetHash][id] != 0) continue;
            existing.push(id);
            _fixedBlueprintIndexPlusOne[delegator][operator][assetHash][id] = existing.length;
        }
    }

    function _addFixedBlueprint(address delegator, address operator, bytes32 assetHash, uint64 blueprintId) internal {
        if (_fixedBlueprintIndexPlusOne[delegator][operator][assetHash][blueprintId] != 0) return;
        uint64[] storage arr = _fixedBlueprints[delegator][operator][assetHash];
        arr.push(blueprintId);
        _fixedBlueprintIndexPlusOne[delegator][operator][assetHash][blueprintId] = arr.length;
    }

    function _removeFixedBlueprint(address delegator, address operator, bytes32 assetHash, uint64 blueprintId) internal {
        uint256 indexPlusOne = _fixedBlueprintIndexPlusOne[delegator][operator][assetHash][blueprintId];
        if (indexPlusOne == 0) return;

        uint64[] storage arr = _fixedBlueprints[delegator][operator][assetHash];
        uint256 index = indexPlusOne - 1;
        uint256 lastIndex = arr.length - 1;
        if (index != lastIndex) {
            uint64 lastId = arr[lastIndex];
            arr[index] = lastId;
            _fixedBlueprintIndexPlusOne[delegator][operator][assetHash][lastId] = index + 1;
        }
        arr.pop();
        _fixedBlueprintIndexPlusOne[delegator][operator][assetHash][blueprintId] = 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STREAMING PAYMENT DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Drip all active streams for an operator and distribute chunks
    /// @dev Called before score changes to ensure fair distribution with current scores
    function _dripOperatorStreams(address operator) internal {
        if (address(streamingManager) == address(0)) return;

        (
            uint64[] memory serviceIds,
            uint64[] memory blueprintIds,
            address[] memory paymentTokens,
            uint256[] memory amounts,
            uint256[] memory durations
        ) = streamingManager.dripOperatorStreams(operator);

        // Distribute each dripped chunk using current scores
        for (uint256 i = 0; i < serviceIds.length; i++) {
            if (amounts[i] > 0) {
                _distributeChunk(
                    serviceIds[i],
                    blueprintIds[i],
                    operator,
                    paymentTokens[i],
                    amounts[i],
                    durations[i]
                );
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
        uint256 amount,
        uint256 /* durationSeconds */
    ) internal {
        Types.AssetSecurityRequirement[] memory reqs =
            ITangleSecurityView(tangle).getServiceSecurityRequirements(serviceId);

        if (reqs.length == 0) {
            // No security requirements - distribute across all operator assets
            _distributeWithoutRequirements(serviceId, blueprintId, operator, paymentToken, amount);
        } else {
            // Compute USD totals for All vs Fixed mode delegators
            (uint256 allUsdTotal, uint256 fixedUsdTotal) =
                _computeUsdTotalsForRequirements(serviceId, blueprintId, operator, reqs);

            uint256 totalUsd = allUsdTotal + fixedUsdTotal;
            if (totalUsd == 0) {
                // No eligible delegators - send to treasury
                _transferPayment(ITangleSecurityView(tangle).treasury(), paymentToken, amount);
                return;
            }

            uint256 allAmount = (amount * allUsdTotal) / totalUsd;
            uint256 fixedAmount = amount - allAmount;

            if (allAmount > 0 && allUsdTotal > 0) {
                _distributeAllForRequirements(serviceId, operator, paymentToken, allAmount, allUsdTotal, reqs);
            }

            if (fixedAmount > 0 && fixedUsdTotal > 0) {
                _distributeFixedForRequirements(serviceId, blueprintId, operator, paymentToken, fixedAmount, fixedUsdTotal, reqs);
            }
        }
    }

    /// @notice Public function to drip a specific stream and distribute to delegators
    /// @dev Drips the stream and distributes the chunk based on current scores
    function drip(uint64 serviceId, address operator) external nonReentrant {
        if (address(streamingManager) == address(0)) return;

        (
            uint256 amount,
            uint256 durationSeconds,
            uint64 blueprintId,
            address paymentToken
        ) = streamingManager.dripAndGetChunk(serviceId, operator);

        if (amount > 0) {
            _distributeChunk(serviceId, blueprintId, operator, paymentToken, amount, durationSeconds);
        }
    }

    /// @notice Drip all active streams for an operator and distribute to delegators
    /// @dev Anyone can call to trigger distributions
    function dripAll(address operator) external nonReentrant {
        _dripOperatorStreams(operator);
    }

    /// @notice Get active stream IDs for an operator
    function getOperatorActiveStreams(address operator) external view returns (uint64[] memory) {
        if (address(streamingManager) == address(0)) return new uint64[](0);
        return streamingManager.getOperatorActiveStreams(operator);
    }

    /// @notice Calculate pending drip amount without executing
    function pendingDrip(uint64 serviceId, address operator) external view returns (uint256) {
        if (address(streamingManager) == address(0)) return 0;
        return streamingManager.pendingDrip(serviceId, operator);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _assetHash(Types.Asset memory asset) internal pure returns (bytes32) {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(abi.encode(asset.kind, asset.token));
    }

    function _getAllSlashFactor(address operator, bytes32 assetHash) internal view returns (uint256) {
        uint256 factor = _allSlashFactor[operator][assetHash];
        return factor == 0 ? PRECISION : factor;
    }

    function _getFixedSlashFactor(
        address operator,
        uint64 blueprintId,
        bytes32 assetHash
    ) internal view returns (uint256) {
        uint256 factor = _fixedSlashFactor[operator][blueprintId][assetHash];
        return factor == 0 ? PRECISION : factor;
    }

    function _applySlashFactor(uint256 score, uint256 factor) internal pure returns (uint256) {
        if (score == 0) return 0;
        return (score * factor) / PRECISION;
    }

    /// @notice Convert asset amount to USD score value.
    /// @dev TNT gets a boosted score rate if tntScoreRate > 0, otherwise uses oracle.
    ///      For all other tokens, uses oracle price.
    function _toUsd(Types.Asset memory asset, uint256 amount) internal view returns (uint256) {
        if (amount == 0) return 0;

        address token = asset.kind == Types.AssetKind.Native ? address(0) : asset.token;

        // TNT boost: if tntScoreRate is set, 1 TNT = tntScoreRate/1e18 USD score
        // This allows TNT to earn outsized fee share regardless of market price
        if (token != address(0) && token == tntToken && tntScoreRate > 0) {
            return (amount * tntScoreRate) / PRECISION;
        }

        // All other tokens use oracle price
        if (address(priceOracle) == address(0)) return amount;
        return priceOracle.toUSD(token, amount);
    }

    function _transferPayment(address payable to, address token, uint256 amount) internal {
        if (amount == 0) return;
        if (token == address(0)) {
            (bool ok,) = to.call{ value: amount }("");
            require(ok, "eth transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}

    /// @notice Receive ETH for native token distributions from StreamingPaymentManager
    receive() external payable {}
}
