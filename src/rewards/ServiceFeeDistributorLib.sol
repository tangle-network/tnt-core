// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Types } from "../libraries/Types.sol";
import { ITangleSecurityView } from "../interfaces/ITangleSecurityView.sol";
import { IPriceOracle } from "../oracles/interfaces/IPriceOracle.sol";
import { IStreamingPaymentManager } from "../interfaces/IStreamingPaymentManager.sol";

/// @title ServiceFeeDistributorLib
/// @notice Deployed (delegatecall-linked) library holding the heavy distribution/USD/score math for
/// {ServiceFeeDistributor}. Extracting these `public` functions moves their code out of the
/// distributor's runtime bytecode so the contract fits under chains that meter code-deposit gas
/// aggressively (e.g. Tempo's 30M-gas transaction cap).
/// @dev All functions take `Layout storage self` — the distributor's entire storage, declared in the
/// identical slot order it used before this refactor, so the on-chain storage layout is unchanged.
library ServiceFeeDistributorLib {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using SafeERC20 for IERC20;

    uint256 internal constant BPS_DENOMINATOR = 10_000;
    uint256 internal constant PRECISION = 1e18;

    /// @dev Shared with {ServiceFeeDistributor}; same name/args → identical 4-byte selector.
    error InvalidBlueprintAmounts();
    /// @dev Shared with {ServiceFeeDistributor}; same name/args → identical 4-byte selector.
    error EthTransferFailed();

    /// @notice The distributor's storage, one field per slot in the original declaration order.
    /// @dev Slot indices (0..31) MUST match the pre-refactor plain-variable layout. Do not reorder,
    ///      insert, or retype fields; append only, and shrink `__gap` to match.
    struct Layout {
        // slot 0
        address staking;
        // slot 1
        address tangle;
        // slot 2
        IPriceOracle priceOracle;
        // slot 3
        address inflationPool;
        // slot 4
        IStreamingPaymentManager streamingManager;
        // slot 5
        address tntToken;
        // slot 6
        uint256 tntScoreRate;
        // slot 7
        mapping(address => EnumerableSet.AddressSet) _operatorRewardTokens;
        // slot 8
        mapping(address => mapping(bytes32 => EnumerableSet.AddressSet)) _operatorAssetRewardTokens;
        // slot 9
        mapping(address => EnumerableSet.Bytes32Set) _operatorAssetHashes;
        // slot 10
        mapping(bytes32 => Types.Asset) _assetByHash;
        // slot 11
        mapping(bytes32 => bool) _assetKnown;
        // slot 12
        mapping(address => mapping(bytes32 => uint256)) totalAllScore;
        // slot 13
        mapping(address => mapping(uint64 => mapping(bytes32 => uint256))) totalFixedScore;
        // slot 14
        mapping(address => mapping(bytes32 => uint256)) _totalFixedScoreByAsset;
        // slot 15
        mapping(address => mapping(bytes32 => uint256)) _allSlashFactor;
        // slot 16
        mapping(address => mapping(uint64 => mapping(bytes32 => uint256))) _fixedSlashFactor;
        // slot 17
        mapping(address => mapping(bytes32 => mapping(address => uint256))) accAllPerScore;
        // slot 18
        mapping(address => mapping(uint64 => mapping(bytes32 => mapping(address => uint256)))) accFixedPerScore;
        // slot 19
        mapping(address => mapping(address => mapping(bytes32 => uint8))) _positionMode;
        // slot 20
        mapping(address => mapping(address => mapping(bytes32 => uint256))) _positionPrincipal;
        // slot 21
        mapping(address => mapping(address => mapping(bytes32 => uint256))) _positionScore;
        // slot 22
        mapping(address => mapping(address => mapping(bytes32 => mapping(uint64 => uint256)))) _positionFixedScore;
        // slot 23
        mapping(address => mapping(address => mapping(bytes32 => uint64[]))) _fixedBlueprints;
        // slot 24
        mapping(address => mapping(address => mapping(bytes32 => mapping(uint64 => uint256))))
            _fixedBlueprintIndexPlusOne;
        // slot 25
        mapping(address => mapping(address => mapping(bytes32 => mapping(address => uint256)))) _debtAll;
        // slot 26
        mapping(address => mapping(address => mapping(uint64 => mapping(bytes32 => mapping(address => uint256)))))
            _debtFixed;
        // slot 27
        mapping(address => mapping(address => uint256)) claimable;
        // slot 28
        mapping(address => EnumerableSet.AddressSet) _delegatorOperators;
        // slot 29
        mapping(address => mapping(address => EnumerableSet.Bytes32Set)) _delegatorAssets;
        // slot 30
        mapping(address => mapping(address => mapping(bytes32 => uint64))) _positionLockExpiry;
        // slot 31
        uint256[49] __gap;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PURE / VIEW MATH
    // ═══════════════════════════════════════════════════════════════════════════

    function assetHash(Types.Asset memory asset) public pure returns (bytes32) {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(abi.encode(asset.kind, asset.token));
    }

    function getAllSlashFactor(Layout storage self, address operator, bytes32 aHash) public view returns (uint256) {
        uint256 factor = self._allSlashFactor[operator][aHash];
        return factor == 0 ? PRECISION : factor;
    }

    function getFixedSlashFactor(
        Layout storage self,
        address operator,
        uint64 blueprintId,
        bytes32 aHash
    )
        public
        view
        returns (uint256)
    {
        uint256 factor = self._fixedSlashFactor[operator][blueprintId][aHash];
        return factor == 0 ? PRECISION : factor;
    }

    function applySlashFactor(uint256 score, uint256 factor) public pure returns (uint256) {
        if (score == 0) return 0;
        return (score * factor) / PRECISION;
    }

    /// @notice Convert asset amount to USD score value.
    /// @dev TNT gets a boosted score rate if tntScoreRate > 0, otherwise uses oracle.
    ///      For all other tokens, uses oracle price.
    function toUsd(Layout storage self, Types.Asset memory asset, uint256 amount) public view returns (uint256) {
        if (amount == 0) return 0;

        address token = asset.kind == Types.AssetKind.Native ? address(0) : asset.token;

        // TNT boost: if tntScoreRate is set, 1 TNT = tntScoreRate/1e18 USD score
        // This allows TNT to earn outsized fee share regardless of market price
        if (token != address(0) && token == self.tntToken && self.tntScoreRate > 0) {
            return (amount * self.tntScoreRate) / PRECISION;
        }

        // All other tokens use oracle price
        if (address(self.priceOracle) == address(0)) return amount;
        return self.priceOracle.toUSD(token, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // USD TOTALS
    // ═══════════════════════════════════════════════════════════════════════════

    function computeUsdTotalsForRequirements(
        Layout storage self,
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        Types.AssetSecurityRequirement[] memory reqs
    )
        public
        view
        returns (uint256 allUsdTotal, uint256 fixedUsdTotal)
    {
        for (uint256 i = 0; i < reqs.length; i++) {
            Types.Asset memory a = reqs[i].asset;
            bytes32 aHash = assetHash(a);

            uint16 commitmentBps =
                ITangleSecurityView(self.tangle).getServiceSecurityCommitmentBps(serviceId, operator, a.kind, a.token);
            if (commitmentBps == 0) continue;

            uint256 allScore = self.totalAllScore[operator][aHash];
            uint256 fixedScore = self.totalFixedScore[operator][blueprintId][aHash];

            uint256 allEffective = applySlashFactor(allScore, getAllSlashFactor(self, operator, aHash));
            uint256 fixedEffective =
                applySlashFactor(fixedScore, getFixedSlashFactor(self, operator, blueprintId, aHash));

            uint256 allExposed = (allEffective * commitmentBps) / BPS_DENOMINATOR;
            uint256 fixedExposed = (fixedEffective * commitmentBps) / BPS_DENOMINATOR;

            allUsdTotal += toUsd(self, a, allExposed);
            fixedUsdTotal += toUsd(self, a, fixedExposed);
        }
    }

    function computeUsdTotalsForOperatorAssets(
        Layout storage self,
        address operator,
        uint64 blueprintId,
        EnumerableSet.Bytes32Set storage set
    )
        public
        view
        returns (uint256 allUsdTotal, uint256 fixedUsdTotal)
    {
        uint256 assetCount = set.length();
        for (uint256 i = 0; i < assetCount; i++) {
            bytes32 aHash = set.at(i);
            Types.Asset memory asset = self._assetByHash[aHash];
            uint256 allScore = self.totalAllScore[operator][aHash];
            uint256 fixedScore = self.totalFixedScore[operator][blueprintId][aHash];
            allUsdTotal += toUsd(self, asset, applySlashFactor(allScore, getAllSlashFactor(self, operator, aHash)));
            fixedUsdTotal += toUsd(
                self, asset, applySlashFactor(fixedScore, getFixedSlashFactor(self, operator, blueprintId, aHash))
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Score-weighted split of `amount` across a service's security requirements.
    ///      `fixedMode` selects the Fixed-mode pools (per-blueprint) vs the All-mode pools.
    function distributeForRequirements(
        Layout storage self,
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount,
        uint256 usdTotal,
        Types.AssetSecurityRequirement[] memory reqs,
        bool fixedMode
    )
        public
    {
        uint256 remaining = amount;
        uint256 remainingUsd = usdTotal;

        for (uint256 i = 0; i < reqs.length && remaining > 0; i++) {
            Types.Asset memory a = reqs[i].asset;
            bytes32 aHash = assetHash(a);
            uint16 commitmentBps =
                ITangleSecurityView(self.tangle).getServiceSecurityCommitmentBps(serviceId, operator, a.kind, a.token);
            if (commitmentBps == 0) continue;

            uint256 score =
                fixedMode ? self.totalFixedScore[operator][blueprintId][aHash] : self.totalAllScore[operator][aHash];
            if (score == 0) continue;

            uint256 factor = fixedMode
                ? getFixedSlashFactor(self, operator, blueprintId, aHash)
                : getAllSlashFactor(self, operator, aHash);
            uint256 usd = toUsd(self, a, (applySlashFactor(score, factor) * commitmentBps) / BPS_DENOMINATOR);
            if (usd == 0) continue;

            uint256 share = (remaining * usd) / remainingUsd;
            remaining -= share;
            remainingUsd -= usd;
            if (share == 0) continue;

            if (fixedMode) {
                self.accFixedPerScore[operator][blueprintId][aHash][paymentToken] += (share * PRECISION) / score;
            } else {
                self.accAllPerScore[operator][aHash][paymentToken] += (share * PRECISION) / score;
            }
            self._operatorAssetRewardTokens[operator][aHash].add(paymentToken);
        }
    }

    /// @dev Score-weighted split of `amount` across an operator's registered assets when the
    ///      service declares no requirements. `fixedMode` selects Fixed vs All pools.
    function distributeForOperatorAssets(
        Layout storage self,
        address operator,
        uint64 blueprintId,
        address paymentToken,
        uint256 amount,
        uint256 usdTotal,
        EnumerableSet.Bytes32Set storage set,
        bool fixedMode
    )
        public
    {
        uint256 remaining = amount;
        uint256 remainingUsd = usdTotal;

        uint256 assetCount = set.length();
        for (uint256 i = 0; i < assetCount && remaining > 0; i++) {
            bytes32 aHash = set.at(i);
            uint256 denom =
                fixedMode ? self.totalFixedScore[operator][blueprintId][aHash] : self.totalAllScore[operator][aHash];
            if (denom == 0) continue;

            uint256 factor = fixedMode
                ? getFixedSlashFactor(self, operator, blueprintId, aHash)
                : getAllSlashFactor(self, operator, aHash);
            uint256 usd = toUsd(self, self._assetByHash[aHash], applySlashFactor(denom, factor));
            if (usd == 0) continue;

            uint256 share = (remaining * usd) / remainingUsd;
            remaining -= share;
            remainingUsd -= usd;
            if (share == 0) continue;

            if (fixedMode) {
                self.accFixedPerScore[operator][blueprintId][aHash][paymentToken] += (share * PRECISION) / denom;
            } else {
                self.accAllPerScore[operator][aHash][paymentToken] += (share * PRECISION) / denom;
            }
            self._operatorAssetRewardTokens[operator][aHash].add(paymentToken);
        }
    }

    function transferPayment(address payable to, address token, uint256 amount) public {
        if (amount == 0) return;
        if (token == address(0)) {
            (bool ok,) = to.call{ value: amount }("");
            if (!ok) revert EthTransferFailed();
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    /// @notice Immediate (non-streamed) score-weighted distribution of `amount` for a payment.
    /// @dev Consolidated entry point — moves the whole immediate-distribution flow (requirements vs
    ///      operator-asset fallback, USD split, treasury sweep of unbacked funds) out of the
    ///      distributor's bytecode. Delegatecall-linked, so `transferPayment`'s native leg still runs
    ///      in the distributor's context.
    function distributeImmediate(
        Layout storage self,
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    )
        public
    {
        Types.AssetSecurityRequirement[] memory reqs =
            ITangleSecurityView(self.tangle).getServiceSecurityRequirements(serviceId);
        if (reqs.length == 0) {
            EnumerableSet.Bytes32Set storage set = self._operatorAssetHashes[operator];
            uint256 assetCount = set.length();
            if (assetCount == 0) {
                transferPayment(ITangleSecurityView(self.tangle).treasury(), paymentToken, amount);
                return;
            }

            (uint256 allUsd0, uint256 fixedUsd0) = computeUsdTotalsForOperatorAssets(self, operator, blueprintId, set);

            uint256 totalUsd0 = allUsd0 + fixedUsd0;
            if (totalUsd0 == 0) {
                transferPayment(ITangleSecurityView(self.tangle).treasury(), paymentToken, amount);
                return;
            }

            uint256 allAmount0 = (amount * allUsd0) / totalUsd0;
            uint256 fixedAmount0 = amount - allAmount0;

            if (allAmount0 > 0 && allUsd0 > 0) {
                distributeForOperatorAssets(self, operator, 0, paymentToken, allAmount0, allUsd0, set, false);
            }
            if (fixedAmount0 > 0 && fixedUsd0 > 0) {
                distributeForOperatorAssets(
                    self, operator, blueprintId, paymentToken, fixedAmount0, fixedUsd0, set, true
                );
            }
            return;
        }

        (uint256 allUsdTotal, uint256 fixedUsdTotal) =
            computeUsdTotalsForRequirements(self, serviceId, blueprintId, operator, reqs);

        uint256 totalUsd = allUsdTotal + fixedUsdTotal;
        if (totalUsd == 0) {
            transferPayment(ITangleSecurityView(self.tangle).treasury(), paymentToken, amount);
            return;
        }

        uint256 allAmount = (amount * allUsdTotal) / totalUsd;
        uint256 fixedAmount = amount - allAmount;

        if (allAmount > 0 && allUsdTotal > 0) {
            distributeForRequirements(self, serviceId, 0, operator, paymentToken, allAmount, allUsdTotal, reqs, false);
        }

        if (fixedAmount > 0 && fixedUsdTotal > 0) {
            distributeForRequirements(
                self, serviceId, blueprintId, operator, paymentToken, fixedAmount, fixedUsdTotal, reqs, true
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SCORE BOOKKEEPING
    // ═══════════════════════════════════════════════════════════════════════════

    function applyFixedScoreDelta(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        uint256 scoreDelta,
        uint256 amount,
        bool isIncrease,
        uint64[] calldata blueprintIds,
        uint256[] calldata blueprintAmounts
    )
        public
    {
        if (blueprintIds.length == 0) return;
        if (blueprintIds.length != blueprintAmounts.length) {
            revert InvalidBlueprintAmounts();
        }
        if (scoreDelta == 0 || amount == 0) return;

        uint256 totalAmount = 0;
        uint256 amountsLen = blueprintAmounts.length;
        for (uint256 i = 0; i < amountsLen;) {
            totalAmount += blueprintAmounts[i];
            unchecked {
                ++i;
            }
        }
        if (totalAmount == 0) return;

        uint256 remainingScore = scoreDelta;
        uint256 idsLen = blueprintIds.length;
        // `_totalFixedScoreByAsset[operator][aHash]` is one slot mutated every iteration
        // (same read-modify-write in either branch); load once, mutate in memory, store once.
        // Each step observes exactly what the previous wrote, so the result is identical.
        uint256 byAssetAcc = self._totalFixedScoreByAsset[operator][aHash];
        for (uint256 i = 0; i < idsLen;) {
            uint64 bpId = blueprintIds[i];
            uint256 scoreForBlueprint =
                i == idsLen - 1 ? remainingScore : (scoreDelta * blueprintAmounts[i]) / totalAmount;
            remainingScore = remainingScore > scoreForBlueprint ? remainingScore - scoreForBlueprint : 0;

            if (isIncrease) {
                self._positionFixedScore[delegator][operator][aHash][bpId] += scoreForBlueprint;
                self.totalFixedScore[operator][bpId][aHash] += scoreForBlueprint;
                byAssetAcc += scoreForBlueprint;
            } else {
                uint256 currentScore = self._positionFixedScore[delegator][operator][aHash][bpId];
                uint256 dec = scoreForBlueprint > currentScore ? currentScore : scoreForBlueprint;
                self._positionFixedScore[delegator][operator][aHash][bpId] = currentScore - dec;

                uint256 curTotal = self.totalFixedScore[operator][bpId][aHash];
                self.totalFixedScore[operator][bpId][aHash] = dec > curTotal ? 0 : curTotal - dec;
                byAssetAcc = dec > byAssetAcc ? 0 : byAssetAcc - dec;
            }
            unchecked {
                ++i;
            }
        }
        self._totalFixedScoreByAsset[operator][aHash] = byAssetAcc;
    }

    function setFixedBlueprints(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        uint64[] calldata blueprintIds
    )
        public
    {
        // Clear existing set
        uint64[] storage existing = self._fixedBlueprints[delegator][operator][aHash];
        for (uint256 i = existing.length; i > 0; i--) {
            uint64 id = existing[i - 1];
            self._fixedBlueprintIndexPlusOne[delegator][operator][aHash][id] = 0;
            existing.pop();
        }

        for (uint256 i = 0; i < blueprintIds.length; i++) {
            uint64 id = blueprintIds[i];
            if (self._fixedBlueprintIndexPlusOne[delegator][operator][aHash][id] != 0) continue;
            existing.push(id);
            self._fixedBlueprintIndexPlusOne[delegator][operator][aHash][id] = existing.length;
        }
    }

    /// @notice F5: decay an expired lock-multiplier boost on a position back to base (principal).
    /// @dev Callers MUST drip operator streams before calling. No-op when there is no active lock
    ///      record, the lock has not expired, or there is no boost left to remove. Idempotent.
    function settleExpiredLock(Layout storage self, address delegator, address operator, bytes32 aHash) public {
        uint64 expiry = self._positionLockExpiry[delegator][operator][aHash];
        if (expiry == 0 || block.timestamp < expiry) return;

        uint8 mode = self._positionMode[delegator][operator][aHash];
        uint256 score = self._positionScore[delegator][operator][aHash];
        uint256 principal = self._positionPrincipal[delegator][operator][aHash];

        // Clear the marker regardless; the boost (if any) is being removed now.
        self._positionLockExpiry[delegator][operator][aHash] = 0;
        if (mode == 0 || score <= principal) return;

        // Settle accrued rewards at the boosted score before collapsing it.
        harvestAllTokens(self, delegator, operator, aHash, mode);

        uint256 boost = score - principal;
        if (mode == 1) {
            uint256 cur = self.totalAllScore[operator][aHash];
            self.totalAllScore[operator][aHash] = boost > cur ? 0 : cur - boost;
            self._positionScore[delegator][operator][aHash] = principal;
        } else {
            // Fixed mode: scale every per-blueprint score down by principal/score and reduce the
            // operator/blueprint totals by the removed amount.
            uint64[] storage bps = self._fixedBlueprints[delegator][operator][aHash];
            uint256 newAggregate = 0;
            uint256 cfa = self._totalFixedScoreByAsset[operator][aHash];
            uint256 bpsLen = bps.length;
            for (uint256 i = 0; i < bpsLen;) {
                uint64 bpId = bps[i];
                uint256 bScore = self._positionFixedScore[delegator][operator][aHash][bpId];
                if (bScore != 0) {
                    uint256 bNew = (bScore * principal) / score; // rounds down toward base
                    uint256 bDelta = bScore - bNew;
                    self._positionFixedScore[delegator][operator][aHash][bpId] = bNew;

                    uint256 cf = self.totalFixedScore[operator][bpId][aHash];
                    self.totalFixedScore[operator][bpId][aHash] = bDelta > cf ? 0 : cf - bDelta;
                    cfa = bDelta > cfa ? 0 : cfa - bDelta;
                    newAggregate += bNew;
                }
                unchecked {
                    ++i;
                }
            }
            self._totalFixedScoreByAsset[operator][aHash] = cfa;
            self._positionScore[delegator][operator][aHash] = newAggregate;
        }

        // Re-sync per-token debt to the collapsed score so future accrual is at base.
        syncDebtsToCurrentAcc(self, delegator, operator, aHash, mode);
    }

    /// @notice Fixed-mode blueprint rebalance: clear existing per-blueprint scores and redistribute
    ///         the position's score across `blueprintIds` weighted by `blueprintAmounts`.
    /// @dev Consolidated body of `onBlueprintsRebalanced` after the mode/expiry/harvest preamble.
    function rebalanceBlueprints(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        uint64[] calldata blueprintIds,
        uint256[] calldata blueprintAmounts
    )
        public
    {
        uint64[] storage existing = self._fixedBlueprints[delegator][operator][aHash];
        uint256 curTotalByAsset = self._totalFixedScoreByAsset[operator][aHash];
        uint256 existingLen = existing.length;
        for (uint256 i = 0; i < existingLen;) {
            uint64 bpId = existing[i];
            uint256 oldScore = self._positionFixedScore[delegator][operator][aHash][bpId];
            if (oldScore != 0) {
                uint256 cur = self.totalFixedScore[operator][bpId][aHash];
                self.totalFixedScore[operator][bpId][aHash] = oldScore > cur ? 0 : cur - oldScore;
                curTotalByAsset = oldScore > curTotalByAsset ? 0 : curTotalByAsset - oldScore;
                self._positionFixedScore[delegator][operator][aHash][bpId] = 0;
            }
            unchecked {
                ++i;
            }
        }
        self._totalFixedScoreByAsset[operator][aHash] = curTotalByAsset;

        uint256 totalAmount = 0;
        uint256 amountsLen = blueprintAmounts.length;
        for (uint256 i = 0; i < amountsLen;) {
            totalAmount += blueprintAmounts[i];
            unchecked {
                ++i;
            }
        }

        uint256 userScore = self._positionScore[delegator][operator][aHash];
        if (totalAmount > 0 && userScore > 0) {
            uint256 remainingScore = userScore;
            uint256 idsLen = blueprintIds.length;
            uint256 acc = self._totalFixedScoreByAsset[operator][aHash];
            for (uint256 i = 0; i < idsLen;) {
                uint64 bpId = blueprintIds[i];
                uint256 scoreForBlueprint =
                    i == idsLen - 1 ? remainingScore : (userScore * blueprintAmounts[i]) / totalAmount;
                remainingScore = remainingScore > scoreForBlueprint ? remainingScore - scoreForBlueprint : 0;

                self._positionFixedScore[delegator][operator][aHash][bpId] = scoreForBlueprint;
                self.totalFixedScore[operator][bpId][aHash] += scoreForBlueprint;
                acc += scoreForBlueprint;
                unchecked {
                    ++i;
                }
            }
            self._totalFixedScoreByAsset[operator][aHash] = acc;
        }

        setFixedBlueprints(self, delegator, operator, aHash, blueprintIds);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HARVEST / DEBT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Compute a position's pending reward for `token` without mutating debt.
    function pendingPosition(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        address token,
        uint8 mode
    )
        public
        view
        returns (uint256 pending)
    {
        if (mode == 1) {
            uint256 userScore = self._positionScore[delegator][operator][aHash];
            if (userScore == 0) return 0;
            uint256 accumulated = (userScore * self.accAllPerScore[operator][aHash][token]) / PRECISION;
            uint256 debt = self._debtAll[delegator][operator][aHash][token];
            if (accumulated > debt) pending = accumulated - debt;
            return pending;
        }

        uint64[] storage bps = self._fixedBlueprints[delegator][operator][aHash];
        for (uint256 i = 0; i < bps.length; i++) {
            uint64 bpId = bps[i];
            uint256 blueprintScore = self._positionFixedScore[delegator][operator][aHash][bpId];
            if (blueprintScore == 0) continue;
            uint256 accumulated = (blueprintScore * self.accFixedPerScore[operator][bpId][aHash][token]) / PRECISION;
            uint256 debt = self._debtFixed[delegator][operator][bpId][aHash][token];
            if (accumulated > debt) pending += accumulated - debt;
        }
    }

    /// @dev Advance a harvested position's reward debt to the current accumulator.
    function settlePositionDebt(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        address token,
        uint8 mode
    )
        public
    {
        if (mode == 1) {
            uint256 userScore = self._positionScore[delegator][operator][aHash];
            if (userScore == 0) return;
            self._debtAll[delegator][operator][aHash][token] =
                (userScore * self.accAllPerScore[operator][aHash][token]) / PRECISION;
            return;
        }

        uint64[] storage bps = self._fixedBlueprints[delegator][operator][aHash];
        for (uint256 i = 0; i < bps.length; i++) {
            uint64 bpId = bps[i];
            uint256 blueprintScore = self._positionFixedScore[delegator][operator][aHash][bpId];
            if (blueprintScore == 0) continue;
            self._debtFixed[delegator][operator][bpId][aHash][token] =
                (blueprintScore * self.accFixedPerScore[operator][bpId][aHash][token]) / PRECISION;
        }
    }

    function harvestToken(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        address token,
        uint8 mode
    )
        public
    {
        uint256 pending = pendingPosition(self, delegator, operator, aHash, token, mode);
        if (pending > 0) self.claimable[delegator][token] += pending;
        settlePositionDebt(self, delegator, operator, aHash, token, mode);
    }

    function harvestAllTokens(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        uint8 mode
    )
        public
    {
        // Use per-asset token set for efficiency - only iterates tokens actually distributed for this asset
        EnumerableSet.AddressSet storage set = self._operatorAssetRewardTokens[operator][aHash];
        uint256 length = set.length();
        for (uint256 i = 0; i < length; i++) {
            harvestToken(self, delegator, operator, aHash, set.at(i), mode);
        }
    }

    /// @dev Updates all reward debts to current accumulator state after a score change.
    function syncDebtsToCurrentAcc(
        Layout storage self,
        address delegator,
        address operator,
        bytes32 aHash,
        uint8 mode
    )
        public
    {
        EnumerableSet.AddressSet storage set = self._operatorAssetRewardTokens[operator][aHash];
        uint256 length = set.length();
        for (uint256 i = 0; i < length; i++) {
            settlePositionDebt(self, delegator, operator, aHash, set.at(i), mode);
        }
    }
}
