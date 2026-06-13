# Mainnet Parameters — Decision Record

Decided economic + security parameter set for the Base-mainnet launch of tnt-core, with rationale.
Produced from an adversarial multi-expert review (game theory / staking economics / tokenomics /
collateral risk / governance / marketplace) where every finding was red-teamed against the real code
bounds before being accepted. Companion to `deploy/LAUNCH-READINESS.md` (process gates) and
`deploy/config/base-mainnet.json` (the values).

## BLUF

The economics are **structurally sound but operationally unfinished**. Every adversarial "critical/high
exploit" (zero-bond operator, just-in-time reward capture, LST/EIGEN concentration, 100% same-block slash,
lock-array DoS) was either disproven or is inert because the risky assets ship disabled (`token=0x0`). The
load-bearing guards all hold: slash-evasion freeze, 7-day dispute window + admin cancel, no-mint pre-funded
inflation, MasterChef accumulator (prevents JIT capture), single-bond-asset model, virtual shares.

**Do not launch as-built.** The gaps are deploy-step omissions and a small set of pre-mainnet code fixes —
not a broken core. The deploy script currently leaves several parameters at insecure *defaults* because it
never calls the setters that would write the secure values.

## Hard blockers (must be true before mainnet)

1. **Roles filled** — `roles.{admin,treasury,timelock,multisig}` are all `0x0`; `FullDeploy` reverts on Base
   mainnet otherwise. `timelock` must be the `TangleTimelock` proxy → **deploy governance first** (see below).
2. **Lock-expiry unit bug — FIXED in this change.** `LockInfo.expiryBlock = block.number + lockDuration` added
   a *seconds* duration to a *block number* and compared against `block.number`. On Base (~2s blocks) every
   lock lasted ~2× its label and was chain-block-time dependent. Now timestamp-based (`expiryTimestamp`).
3. **`setSlashConfig` deploy step — WIRED in this change.** `FullDeploy` now reads the `slashing` config
   block and calls `setSlashConfig` during the bootstrap window (before role handoff). Without it mainnet
   shipped `maxSlashBps=100%`, `disputeBond=0`.
4. **`setPaymentSplit` deploy step — WIRED in this change.** `FullDeploy` reads the `payments` block and
   applies it (sum-to-10000 asserted). Without it `keeperBps=0` and the sole escrow-draw path
   (`billSubscription`, permissionless) had no keeper market → long-tail revenue leaks.
5. **Governance deploy + params pinned — ADDED in this change.** `FullDeploy` does not deploy the
   Governor/Timelock; new `script/DeployGovernance.s.sol` (wrapping the audited `GovernanceDeployer`) deploys
   token+Timelock+Governor from the `governance` config block, wires roles, and renounces the bootstrap admin,
   with a prod guard that rejects testnet values (20m/3h leak). Run it before `FullDeploy` and pin its
   Timelock/token into the config.
6. **Timelock delay 4 days** (was implied 2d). The timelock holds DEFAULT_ADMIN + UPGRADER over Tangle,
   MultiAssetDelegation, and the token; 4d > the protocol's own 7d exit delay floor for detection, well under
   the 30d clamp.
7. **Inflation budget + genesis headroom pinned.** `TangleToken.MAX_SUPPLY` == migration snapshot total; if
   genesis allocations sum to it, headroom is 0 → true fixed-supply, security budget = whatever treasury
   pre-funds. This is the single most important monetary number and is currently a TODO. Decide explicitly.
8. **Reward-multiplier schedule flattened to 1.0× — DONE in config.** The field is currently write-only/unread
   and the prior schedule was risk-*ascending* (more reward for riskier LSTs) — a latent landmine a future
   wiring PR would activate verbatim. Flattened + a setter clamp is on the punch-list.
9. **External human audit** of the payments / slashing / governance diffs.

## Decided config changes (applied to `deploy/config/base-mainnet.json`)

| Parameter | From | To | Why |
|---|---|---|---|
| `stakeAssets[*].rewardMultiplierBps` | 9000–13000 | **10000** (all) | Field is write-only; prior schedule risk-ascending — fail-closed flat until USD-normalized + re-audited |
| `core.minOperatorStake` + TNT entry | 2 TNT | **1000 TNT** | 2 TNT is a dust floor, not anti-sybil; 1000 TNT (~0.001% supply) prices out spam, no operator-set concentration |
| `incentives.weights.stakingBps` | 5000 | **5500** | Only ~50% of the ~1% budget reaches the security layer; raise the cheapest dilution-free lever |
| `incentives.weights.developersBps` | 1500 | **1000** | Donor for the staking bump (dev rewards are ADMIN-allowlist gated, not sybil-farmable); sum stays 10000 |
| `stakeAssets[EIGEN].depositCap` | 1M | **250k** | Right-size before any future enablement (entry stays `0x0`/disabled) |
| `stakeAssets[USDe].depositCap` | 15M | **5M** | Risk right-size (disabled) |
| `stakeAssets[stETH/wstETH].depositCap` | 30k each | **15k each** | Same Lido underlying — treat as one family budget (15k each = 30k aggregate) |
| **+ `governance` block** | (absent) | votingDelay 1d / votingPeriod 7d / proposalThreshold 200k TNT / quorum 6% / timelockDelay 4d | Pin launch governance; conservative-start |
| **+ `slashing` block** | (absent) | maxSlashBps 50% / disputeWindow 7d / disputeBond 0.02 ETH / resolutionDeadline 21d / maxPending 8 | Drives `setSlashConfig`; removes 100%-slash + free-dispute defaults |
| **+ `payments` block** | (absent) | 2000/1950/4000/2000/**50** (dev/protocol/operator/staker/keeper) | Drives `setPaymentSplit`; keeper market for permissionless billing |

**Kept as-is (verified fine):** `minDelegation` 0.2 TNT, `operatorCommissionBps` 10%,
`vaultOperatorCommissionBps` 15%, inflation `epochLength` 7d, `customersBps`/`operatorsBps`,
`defaultTntMinExposureBps` 10%, stablecoin caps, `MAX_OPERATORS_PER_SERVICE` 256, `MAX_ACTION_VALUE` 10000 ETH.

## Pre-audit code punch-list (not yet applied — for the audited diff)

Done in this change: **lock-expiry timestamp fix** (`Types.LockInfo`, `DepositManager`, `DelegationManagerLib`
+ test); **`FullDeploy` slash/payment wiring** + tests; **`DeployGovernance.s.sol`** + test + runbook;
**`TangleGovernor` NatSpec** (Blocks→Seconds). Remaining, prioritized for the same audited diff:

**P1 (rug/correctness primitives):**
- `RewardVaults.setOperatorCommission`: lower hard cap 5000→2000 bps and gate behind a 7d queue/execute/cancel
  timelock (reuse `COMMISSION_CHANGE_DELAY`) — today a single tx can spike vault commission with zero notice.
- `COMMISSION_CHANGE_DELAY` 7d → **14d for increases**; decreases immediate. 7d == the delegator exit delay =
  zero margin for a late-reacting delegator.
- `Slashing.sol`: move the `maxPendingSlashesPerOperator` cap check + increment **before** the
  `SlashingLib.proposeSlash` storage write (remove revert-to-undo dependency); default 32 → **8**.
- `StakingAssetsFacet`: `require(_minDelegation > 0)` on `enableAsset`/`enableAssetWithAdapter` (makes the
  anti-inflation floor an invariant, not a convention); `require(_rewardMultiplierBps <= MAX_REWARD_MULTIPLIER_BPS)`
  clamp (e.g. 20000) so a future wiring PR can't ship a wrong schedule.
- Service activation: strict `require(subscriptionInterval < svc.ttl)` for subscription-priced blueprints —
  a short-TTL/long-interval sub expires before its first bill is due and collects zero revenue.

**P2 (incentive shape):**
- Lock multiplier tiers → mildly convex `None 10000 / 1mo 11000 / 2mo 12500 / 3mo 14500 / 6mo 18000`. The
  current flat +0.1×/mo means 6mo is strictly dominated by rolling 3mo — paying for long-lock branding it
  won't get.

**P3 (cleanliness / dead code):**
- Delete dead zero-ref constants `DISPUTE_WINDOW_ROUNDS`, `ROUNDS_PER_EPOCH`, `REWARD_GRACE_PERIOD_ROUNDS`
  from `ProtocolConfig.sol` (verified 0 external references; `DISPUTE_WINDOW_ROUNDS` 3.5d even contradicts the
  live 7d `SlashConfig.disputeWindow`). Storage-layout-safe (library constants).
- `TangleGovernor.sol` NatSpec Blocks→Seconds is done; still document that `MAX_ACTION_VALUE` caps native
  value only (not ERC20/TNT outflows, which are governed by vote+timelock).
- Indexer `expiryBlock` field (`schema.graphql`, `staking.ts` — currently a hardcoded `0n` placeholder, not
  wired to the contract value) → rename to `expiryTimestamp` and re-run `npm run codegen`.

## Open decisions (only Drew / governance can ratify)

- **Role addresses:** the four Safes/timelock for `roles.*`.
- **SLASH_ADMIN_ROLE** held by a ≥3/5 multisig with a documented <7d dispute-adjudication SLA (fail-open
  auto-execute makes honest-dispute safety contingent on responsiveness).
- **CANCELLER_ROLE guardian Safe** on the timelock — as-built only the governor holds it. If a guardian is
  wired, `quorumPercent` can be 4 instead of 6.
- **Inflation budget size:** the actual Year-1 fund (recommended ~2.0M TNT / ~1.8% gross) + a declining
  multi-year schedule, funded from a named treasury reserve. Currently a recommendation in config, not executed.
- **Genesis allocation amounts** (substrate / evm / treasury / foundation) and the **headroom decision**:
  ~5% inflation envelope vs true fixed-supply. Pin one and assert it at deploy.
- **Governance init values** ratification (defaults proposed above).
- **Pre-committed weight migration** (staking→stakers, e.g. 3500/1500) once `ServiceFeeDistributor` + keeper +
  live services exist — `stakersBps=0` is correct at genesis but the rail should turn on after launch.
- **Gated-asset enablement:** stETH/wstETH/EIGEN/WBTC/tBTC/lBTC/USDe are `0x0` placeholders — each needs a real
  Base address + adapter (+ Lido-family aggregate cap) before enabling.
- **Operational:** run the protocol keeper bot from block 1 (billing + non-payment-termination sweep); and a
  pre-launch gas measurement of a worst-case 256-operator multi-asset `billSubscription` under via-IR (go/no-go
  on within-service billing pagination vs a stricter subscription-blueprint operator cap).

## Launch sequence

1. Apply P1–P3 code punch-list → external audit of the full diff.
2. Deploy `TangleTimelock` + `TangleGovernor` (`script/DeployGovernance.s.sol`) with the `governance` block;
   put the Timelock address in `roles.timelock`.
3. Fill all `roles.*`, the TNT token address, and the genesis/inflation numbers in `base-mainnet.json`.
4. Base-sepolia rehearsal via `deploy/deploy-all.sh` (deploy → delegate → service → bill → slash → unstake),
   confirming `setSlashConfig`/`setPaymentSplit` actually wrote the secure values.
5. Mainnet deploy; pre-fund the InflationPool per the ratified schedule; start the keeper bot.
