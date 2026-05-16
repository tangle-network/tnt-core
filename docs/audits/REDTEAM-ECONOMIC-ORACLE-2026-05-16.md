# Red-team audit — economic + oracle manipulation surfaces

- Date: 2026-05-16
- Scope: subscription billing (`PaymentsBilling`, `PaymentsDistribution`, `PaymentLib`), TWAP stake-second index in `DelegationStorage`, share-pool inflation defense in `ValidatorPodManager` / `LiquidDelegationVault` / `DelegationStorage`, slashing path (`Slashing`, `SlashingLib`, `SlashingManager`), `IPriceOracle` adapters (`ChainlinkOracle`, `UniswapV3Oracle`).
- Method: read-only static review + adversarial sequence tracing. No code changes.
- Severity counts: 0 CRITICAL, 1 HIGH, 3 MEDIUM, 2 LOW, 2 INFORMATIONAL.

## Summary

The cap-at-nominal guarantee on subscription bills holds — the customer's per-period draw cannot be inflated by oracle manipulation, stake ramps, or hostile manager hooks. Slashing is non-replayable and per-asset rounding is correct.

The remaining attack surface is **distributional**, not extractive against the customer: per-operator weights inside a (capped) bill are uncapped, so an operator who manipulates an oracle they control, or ramps stake just before `periodEnd`, can siphon the operator/staker share of the bill from honest operators. This is the strongest finding (HIGH). The other findings are oracle-griefing exposure and a documentation gap around the asymmetric virtual offsets in `DelegationStorage` vs `ValidatorPodManager` / `LiquidDelegationVault`.

## Findings

### H-1 — Oracle-manipulated weight inflation lets one operator capture a bill's operator pool

**Severity: HIGH** (recoverable loss — fund redistribution between operators, not from the customer).

**Location:** `src/core/PaymentsBilling.sol::_accrueOperatorWeights` lines 270–354; mirrored at `src/core/PaymentsDistribution.sol::_initSubscriptionBaseline` lines 105–159.

**Math trace.**
For each (operator, commitment), the weight contribution is:

```
contribution_j = (opDeltaRaw_j * c.exposureBps) / 10_000
if (useOracle && contribution_j > 0):
    contribution_j = oracle.toUSD(c.asset.token, contribution_j)
opWeight_i = Σ_j contribution_j
totalWeight = Σ_i opWeight_i
```

The bill amount `_billSubscriptionImpl` line 137 is bounded by the cap on line 145:

```
amount = PaymentLib.twapBillAmount(nominalRate, cumDeltaPeriod, baselineStake, interval)
if (amount > nominalRate) amount = nominalRate
```

Per-operator payout is `amount * weights[i] / totalWeight` (see `_payOperatorPoolByWeight` lines 270–281). `weights[i]` are uncapped USD-normalized at bill time; `baseline` is USD-normalized once at activation.

**Attack.** Operator A commits stake on an asset whose price oracle they can influence — e.g. low-cap ERC20 with a Uniswap V3 pool that has a 30-minute TWAP window (default `DEFAULT_TWAP_PERIOD` in `UniswapV3Oracle.sol` line 69). At activation, oracle price was P0; A's exposure contributed `X * P0` USD to baseline. Just before billing, A pushes the pool's tick over a sustained window to drive `oracle.toUSD(...)` to `X * (P0 * 100)`. At billing:

- `opWeight_A = (cumDelta_A * exposure_A_bps / 10_000) * P0 * 100`
- For honest operators on TNT, oracle returns `cumDelta_B * P_TNT` (unchanged)
- `weights[A] / totalWeight ≈ 1` if A's USD-priced contribution dominates

The bill cap fires (`amount = nominalRate`), so the customer is unharmed, but A captures the operator pool + (depending on `hasSecurityCommitments`) the staker pool — pulling rent from honest operators in the same service. Across N periods, A's expected take is `~nominalRate * (operatorBps + stakerBps) / 10_000` per period vs honest operators' near-zero share.

**Why baseline-pin doesn't block it.** The baseline pins the *denominator of bill amount* in USD at activation time. It does not pin the *split of the operator pool*. Weight inflation only affects the split denominator at bill time (`totalWeight`), not the protocol-level cap.

**Why UniswapV3 TWAP doesn't block it.** A 30-minute TWAP frustrates flash-loan manipulation but does not stop sustained manipulation, especially on low-liquidity pools. The oracle's own comment (`UniswapV3Oracle.sol` lines 42–56) acknowledges: "Attackers with sufficient capital can manipulate prices over the TWAP window." Subscription billing intervals are far longer (days/weeks), giving the attacker ample prep time.

**Why Chainlink isn't safe either.** The adapter accepts any feed an admin configures. A misconfigured low-quality feed (custom chain, illiquid token) reproduces the attack — Chainlink only protects you when the feed itself is robust.

**Reproduction sketch (test outline, not committed).**

```solidity
// Activate service with commitments on TNT (P=1) and EVIL (P=1, attacker-controlled pool)
//   baseline_USD = stakeTNT_op1 * P_TNT + stakeEVIL_attacker * P_EVIL = 100 + 100 = 200
// Wait one billing interval. Attacker manipulates EVIL pool tick so oracle returns 100x.
// billSubscription:
//   cumDelta_op1   = stakeTNT_op1 * interval
//   cumDelta_attacker = stakeEVIL_attacker * interval, oracle.toUSD inflates 100x
//   weights[attacker] / totalWeight ≈ 100/(100+1) ≈ 0.99
// Expected: attacker receives ~99% of (operatorBps + stakerBps) * nominalRate / 10_000.
// assertGt(rewardsTransferredTo(attacker), 0.95 * nominalRate * 0.5);
```

**Mitigation options (informational, not required by this audit):**
1. Cap per-operator weight contribution to `baseline / activeOperatorCount * K` (some bounded multiple).
2. USD-normalize weights against the activation-time price (snapshot per-asset USD rate into `_serviceSecurityCommitments` at activation, reuse at bill).
3. Require oracle adapters to attest to a minimum-liquidity / minimum-TWAP-window precondition before a service binds them.
4. Reject services whose committed assets aren't backed by a Chainlink feed with an explicit minimum-volume guard.

The cleanest fix is (2): the baseline already snapshots the USD-aggregate; snapshotting the per-(op,asset) USD price too lets `_accrueOperatorWeights` use the activation rate, neutralizing oracle drift entirely.

### M-1 — Oracle revert during billing bricks all subscription bills for the configured assets

**Severity: MEDIUM** (griefing — denial of billing, no fund loss).

**Location:** `src/core/PaymentsBilling.sol` lines 296, 323; `src/core/PaymentsDistribution.sol` lines 127, 141.

`oracle.toUSD(token, contribution)` is called inside `_accrueOperatorWeights` and `_initSubscriptionBaseline` without try/catch. Failure modes that surface here:

- `ChainlinkOracle._getPriceData` reverts on `SequencerDown`, `StalePrice_Sequencer`, `StaleRound`, `InvalidPrice`, `StalePrice`, `TokenNotSupported`. (Note: the staleness check is timestamp-based with `block.timestamp - updatedAt > maxAge`. A sequencer outage right after a downward feed update will both stale the price and block any new updates.)
- `UniswapV3Oracle._getPriceData` reverts on `TokenNotSupported`, `PriceNotAvailable` (no quote feed), `InvalidPrice`, `StalePrice` of the quote feed, and propagates `observe()` reverts when the pool's `observationCardinality` is insufficient or the requested `secondsAgo` predates the oldest observation.

Any such revert bubbles up through `billSubscription` and stops the keeper from drawing periods. The TTL clock keeps running. `terminateServiceForNonPayment` requires `balance < rate`, which can't be checked because the bill can't be computed — operators can't recover their dues.

This is intentional fail-closed behavior for the baseline at activation (you don't want to mis-price a long-running contract). But on the hot path, the same fail-closed semantics turn an oracle outage into a service-wide payment freeze with no graceful degradation.

Observed mitigations already present:
- `_resolveBillAdjustmentBps` uses a gas-capped staticcall with fail-closed fallback (`uint16(BPS_DENOMINATOR)`).
- `_isBillable` (in `PaymentsRewards.sol`) lets keepers off-chain filter; it doesn't call the oracle, but a real bill will revert.

The fix shape would be: in `_accrueOperatorWeights`, fall back to raw token-second weighting (skip USD normalization) when `oracle.toUSD` reverts, and emit an event flagging the affected service. Bills then continue in degraded-fairness mode rather than freezing entirely. Worth pricing the tradeoff: degraded-fairness gives an oracle-dependent service a "free pass" during outages, which is itself partially exploitable.

### M-2 — `DelegationStorage` virtual offset (`Vs=1e8, Va=1`) gives the first depositor 10^8 shares per wei

**Severity: MEDIUM** (no fund loss given the absence of donation surfaces — see below — but the constant choice is unusual and worth documenting).

**Location:** `src/staking/DelegationStorage.sol` lines 27–28; consumed in `src/staking/DelegationManagerLib.sol::_amountToShares` line 74 and `_sharesToAmount` line 96.

The standard OpenZeppelin ERC4626 inflation defense uses asymmetric `Vs = 10**decimalsOffset, Va = 1`. With `Vs = 1e8`, the first delegator of 1 wei mints `1 * (0 + 1e8) / (0 + 1) = 1e8` shares. With `Vs = 1e3, Va = 1e3` (used by `ValidatorPodManager` line 40 and `LiquidDelegationVault` line 28), the first depositor of 1 wei mints 1 share.

The standard inflation attack requires the attacker to *donate* to `totalAssets` after the initial deposit, so subsequent deposits round to zero shares. I traced every writer of `_rewardPools[op][h].totalAssets` and `_blueprintPools[op][bp][h].totalAssets` (`grep -rn "totalAssets\\s*+=" src/staking/`):

- `RewardsManager.sol` line 131: `pool.totalAssets += amount;` — paired with `pool.totalShares += shares` (same function)
- `RewardsManager.sol` line 181: same, in `_updateFixedModePools` — paired with `pool.totalShares += sharesForBlueprint`
- `DelegationManagerLib.sol` line 336: same, in `_setBlueprintShares` — paired with adjacent `pool.totalShares` mutation

Every `totalAssets` increment is paired with a matching `totalShares` mint. There is no `receive()` / `fallback()` / standalone rewards-into-pool donation path, and bill distribution goes to `_pendingRewards`, not to `_rewardPools.totalAssets`. So the donation step of the inflation attack is closed.

The high `Vs` is therefore harmless under the current architecture but:
1. Creates large share-count outputs that are surprising (1 wei → 1e8 shares).
2. Diverges from the convention used in the sibling share-pools (`VPM`, `LDV` use 1e3/1e3).
3. Is fragile to future changes: if any future code path were to write to `_rewardPools[*].totalAssets` without minting matching shares (e.g. a rewards-folder, a slash-refund, an admin top-up), the asymmetry resurfaces immediately as a real inflation vector.

Suggested follow-up: align `DelegationStorage` to `Vs = 10**N, Va = 1` per OZ's recommendation with `N` ≥ the decimal mismatch you want to absorb (OZ defaults to `N = 6` in ERC4626 for 18-decimal assets), and document the choice in a comment that references the donation-surface invariant.

### M-3 — Stake-ramp at `periodEnd - ε` lets an operator capture an outsized slice of the same-period bill

**Severity: MEDIUM** (distributional, not extractive against the customer).

**Location:** `src/staking/DelegationStorage.sol::_accrueStakeSecondsRaw` lines 378–392; `src/core/PaymentsBilling.sol::_projectToPeriodEnd` lines 394–402.

**Math trace.**
Suppose operator A holds a small stake `s_A` since the period start. At `t = periodEnd - 1`, A delegates an additional `S >> s_A`. The accrual at delegation time folds `[lastUpdate, periodEnd - 1]` at `s_A` (the pre-ramp stake), then mutates the underlying stake to `s_A + S`.

At `t > periodEnd` the bill is called. `getCumStakeSeconds(A)` returns
```
cum_now = cum_lastUpdate_at_periodEnd-1
        + (t - (periodEnd - 1)) * (s_A + S)
```
`_projectToPeriodEnd` subtracts `(s_A + S) * (t - periodEnd)`. Result:
```
cum_atPeriodEnd ≈ cum_lastUpdate
                + ((periodEnd-1) - lastUpdate) * s_A  (pre-ramp area)
                + 1 * (s_A + S)                       (the 1-second ramp window)
```
So A's contribution to `cumDelta_period` includes a full `S × 1 s` block.

If `S` is large enough, A's `weights[A]` dominates `totalWeight` even with one second of stake. Bill amount is still cap-bounded; but A captures ~all of `operatorPool + stakerPool`.

**Capital cost.** A must lock `S` for the unstake delay (`delegationBondLessDelay` rounds in `OperatorManager.sol` line 173). For one bill, capital cost = `S * rate_alt * delay`. Profit = `(operatorBps + stakerBps) * nominalRate / 10000`. Profitability requires `nominalRate * 0.5 > S * rate_alt * delay` — only practical against high-rate, low-liquidity services or when the attacker is already a multi-period participant amortizing the lock.

**Why this is not CRITICAL.**
- The cap bounds total harm to `(operatorBps + stakerBps) * nominalRate * billsPerLockPeriod`.
- The attacker pays in real, slashable capital — under-collateralizing them isn't free.
- The semantics ("more time-weighted stake → more share") are the design intent.

**Why it's still worth flagging.**
The intent of TWAP-fair weighting is to reward stable, real backing — not to reward last-second deposits that ride a single second of cum-stake-seconds into a dominating weight. Two fixes would tighten this without breaking TWAP:
1. Cap `opDeltaRaw_i / cumDeltaPeriod` at a multiple of the operator's baseline-time share at activation.
2. Use a longer accrual window (multi-period EMA) for billing weights rather than within-period instantaneous projection.

### L-1 — Uniswap V3 oracle accepts arbitrary admin-configured pools without minimum-liquidity / cardinality guards

**Severity: LOW** (informational — pricing trust is delegated to the admin).

**Location:** `src/oracles/UniswapV3Oracle.sol::configurePool` lines 208–235.

The contract's own comment (lines 42–56) acknowledges the requirement: "verify it has sufficient liquidity. Recommended minimum: $1M TVL." None of this is enforced on-chain. `configurePool` checks that the pool exists and the token is in it, then trusts the admin. The pool's `observationCardinalityNext` is not asserted to be ≥ `twapPeriod / 12`. A pool with cardinality 1 will revert on `observe(secondsAgos=[twapPeriod, 0])` and brick price queries (which feeds back into M-1's denial path).

Suggested follow-up: enforce a minimum `observationCardinality` and a minimum `liquidity` at config time, or at least surface a non-reverting view that callers can check before relying on the feed.

### L-2 — `_resolveBillAdjustmentBps` `staticcall` lacks return-data length sanity beyond `< 32`

**Severity: LOW** (informational).

**Location:** `src/core/PaymentsBilling.sol::_resolveBillAdjustmentBps` lines 369–388.

`abi.decode(ret, (uint256))` on a return blob ≥ 32 bytes will succeed for any malformed payload, and the result is then clamped at 10_000. The clamp closes the only attack vector (manager-side inflation of the bill), so this is purely an observation: malformed returns are silently accepted as "the manager wants no discount." Fine. Worth keeping in mind that any future use of manager-returned `bytes` over 32 bytes (e.g. for multi-field returns) would need explicit length checks.

### I-1 — Slash idempotence is sound; recording the slashed amount is non-replayable

**Severity: INFORMATIONAL** (clean check).

**Location:** `src/libraries/SlashingLib.sol` lines 338–370; `src/core/Slashing.sol` lines 249–285, 293–336.

`markExecuted` re-checks `isExecutable(proposal)` (lines 363–365), which returns `false` once `proposal.status == SlashStatus.Executed`. The status flip happens *before* `emit SlashExecuted` and well before the external transfer in `_settleDisputeBond`. Reentrancy via the manager `onSlash` hook is blocked at the higher level by `nonReentrant` on `executeSlash` and `executeSlashBatch`. A replay attempt against the same `slashId` reverts with `SlashNotExecutable`. Confirmed.

### I-2 — Cum-stake-seconds overflow is unreachable at realistic scales

**Severity: INFORMATIONAL** (clean check).

**Location:** `src/staking/DelegationStorage.sol::_accrueStakeSecondsRaw` lines 378–392; comment at lines 471–474.

Worst-case bound: a 1B-token operator with 18-decimal precision (`stake = 1e27` wei) accruing for 1000 years (`~3.15e10` seconds) yields `stake * dt ≈ 3.15e37`. Even multiplied by `exposureBps ≤ 1e4` and oracle conversion at `1e18` USD-precision (USD value ~1e9 dollars / 1e30 stake-seconds-USD), the product fits in `uint256` (`< 2^256 ≈ 1.16e77`). The downstream `twapBillAmount` adds an explicit overflow check on `nominalRate * cumDeltaPeriod` (lines 114–118 of `PaymentLib.sol`) for safety. No realistic overflow path.

## Clean checks (with evidence)

1. **Cap-at-nominal protects the customer.** `_billSubscriptionImpl` line 145: `if (amount > nominalRate) amount = nominalRate;` runs after `twapBillAmount` and before QoS adjustment. QoS can only discount (`applyQosAdjustment` floors at `qosBps < 10_000`). Manager hook return values above `10_000` are clamped. The customer's per-period draw is bounded by `nominalRate` regardless of oracle, weight, or hook behavior.
2. **Baseline pin enforces single-snapshot pricing.** `_initSubscriptionBaseline` is called exactly once at activation (line 30 of `TanglePaymentsDistributionFacet.sol`). `_billSubscriptionImpl` line 133 reverts if `subscriptionBaselineStake == 0`, blocking a stake-ramp attacker from gaming first-bill state by activating via a non-canonical path. The pin is stored in `escrow.subscriptionBaselineStake` and never overwritten.
3. **Share-pool rounding always favors the protocol.** All four conversion functions in `ValidatorPodManager` (lines 326, 331, 365, 370) and both in `LiquidDelegationVault` (lines 147, 156) use `Math.Rounding.Floor`. `DelegationManagerLib._amountToShares` / `_sharesToAmount` use raw `*`/`/` which floor in Solidity 0.8. Verified across deposit and withdraw paths; no path uses ceiling rounding that would give the depositor extra shares or extra assets.
4. **No donation surface into `_rewardPools` or `_blueprintPools`.** Every `pool.totalAssets +=` writer pairs with `pool.totalShares +=` (RewardsManager 117–139, 143–190; DelegationManagerLib 327–342). No `receive()` / `fallback()` / standalone admin top-up. `_pendingRewards` is the bill destination, not the pool. The classic ERC4626 inflation attack requires a donation surface; absent here.
5. **No donation surface into `ValidatorPodManager` pools.** `BeaconPool.totalAssets` only moves via `recordBeaconChainDeposit` (pod-only, mints shares) and `recordBeaconChainRebase` (pod-only, requires real beacon-chain proof through `ValidatorPod._finalizeCheckpoint`). `DelegationPool.totalAssets` only moves via `delegateTo` (mints shares), `completeUndelegation` (burns shares), and `_slash` (decrement only). No bare donation.
6. **Slash re-execution is blocked.** See I-1.
7. **VPM `getCumStakeSeconds` returns zeros.** `src/beacon/ValidatorPodManager.sol` lines 969–979: returns `(0, 0, getOperatorStakeForAsset(...))`. A subscription wired to VPM as its `_staking` adapter degrades to `cumDelta = 0` → bill = 0 (zero-stake-seconds path). Bills emit but draw nothing, which is the intended degraded behavior — VPM isn't designed to be the billing adapter today.
8. **TWAP cum-stake-seconds overflow.** See I-2.
9. **`twapBillAmount` overflow detection.** `PaymentLib.sol` lines 114–118: explicit divide-back identity check, reverts with typed `BillingArithmeticOverflow`. Won't panic the EVM on a 0x11.
10. **Front-running of `billSubscription` only redirects the keeper rebate to the caller, never inflates it.** The keeper rebate is `amount * keeperBps / 10_000` of the (capped) bill. A keeper cannot manipulate `amount` upward because of the cap. The "keeper sandwich" (deposit→bill→undelegate) requires the keeper to be an operator who can ramp; this collapses into M-3.

## Method

1. Read every file in `src/core/`, `src/oracles/`, `src/staking/`, `src/beacon/` touching billing, weighting, distribution, slashing, or share-pool conversion.
2. Traced every state writer of `_rewardPools[*].totalAssets`, `_blueprintPools[*].totalAssets`, `_operatorDelegationPools[*].totalAssets`, `_pools[*].totalAssets` to confirm the donation surface is closed.
3. Walked `_accrueOperatorWeights` symbolically with three adversary models: oracle-manipulator (H-1), stake-ramper (M-3), front-running keeper (clean check 10).
4. Walked `_initSubscriptionBaseline` to confirm cap-at-nominal denominator is pinned (clean check 2).
5. Walked `markExecuted` / `isExecutable` / `executeSlash` to confirm idempotence (I-1).
6. Bounded cum-stake-seconds growth at adversarial scales (I-2).
7. Compared virtual-offset constants across `DelegationStorage` (`1e8 / 1`), `VPM` (`1e3 / 1e3`), `LDV` (`1e3 / 1e3`) and verified no donation surface (M-2).

## Top 3

1. **H-1** — Oracle-manipulated weight inflation lets one operator capture the operator/staker pool share of a (capped) bill. Customer is safe; honest operators are not. Fix shape: snapshot per-(op,asset) USD price at activation and reuse at bill, neutralizing oracle drift inside the operator-share split.
2. **M-1** — Oracle revert during billing bricks the period. No fund loss, but a misadministered or stalled feed denies billing service-wide.
3. **M-3** — Stake-ramp at `periodEnd - ε` lets an operator dominate within-period TWAP weight despite only one second of high stake. Rate-limited by the unstake-delay capital cost.
