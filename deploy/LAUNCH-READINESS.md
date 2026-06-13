# Tangle mainnet launch readiness

Source-of-truth checklist for going live. Pairs with `deploy/RUNBOOK-launch.md` (the how)
and the audit artifact at `.evolve/critical-audit/2026-06-12T00:00:00Z/summary.md` (the what).
As of 2026-06-13: the security/hardening work (PR #167) is **merged to `main`**; the remaining
gates are operational + process, not code.

## TL;DR verdict
NOT yet launch-ready. Code is hardened + tested (`forge test` 1658/0). The blockers are:
(1) an **independent human audit**, (2) **real role addresses** in the mainnet config, (3) a
**full testnet deploy rehearsal**, (4) **CI confirmed green**. Beacon/L2/liquid-vaults are
code-complete but gated off and ship later.

## Launch gates (ordered)

### 🔴 1. Independent human audit — START NOW (longest lead, ~weeks)
No external audit exists (`audits/` is empty). The multi-agent AI review we ran is a useful
pre-screen, NOT a substitute for a professional human audit of a token + staked-fund protocol.
Engage Trail of Bits / Spearbit / Cantina / OZ on the merged `main`. This is the dominant gate.
- Hand them: the core (Tangle facets, MultiAssetDelegation, slashing, payments), the binary
  supply-chain surface (BlueprintsBinaryVersions / setBlueprintSources cold-start), governance.
- Beacon/L2/vault can be a second-phase scope (not in initial deploy).

### 🔴 2. Fill `deploy/config/base-mainnet.json` roles — deploy reverts without it
`roles.admin/treasury/timelock/multisig` are all `0x000…0`. `FullDeploy._requireProductionRoles`
**reverts on mainnet** until these are real, distinct Safe/timelock addresses (admin ≠ deployer,
timelock ≠ admin, etc.). Also fill the stake-asset adapter addresses + the `incentives.tntToken`.
The token sentinel `0x…0001` is replaced at runtime by FullDeploy.

### 🔴 3. Full testnet (base-sepolia) deploy rehearsal
Only piece-wise local-anvil dry-runs were done. Run the whole `deploy/deploy-all.sh` on
base-sepolia with production-shaped config, then smoke a real cycle: deploy → register operator →
delegate → request+approve service → submit job → bill → propose+execute slash → unstake. Confirm
the role-handoff assertions and `_assertGovernanceConfiguration` pass.

### 🟡 4. Confirm CI is green
Foundry CI was restored (`.github/workflows/foundry.yml`: `forge test` under `fast` + an
optimizer `size` job for EIP-170). It has not been observed passing on a live GH Actions run —
confirm both jobs go green on a PR before relying on it as a merge gate.

### 🟡 5. Token-launch workstream (separate owner)
Tokenomics already designed (inflation pool + weights + fee split, all implemented/tested).
Open items, outside this repo's code: confirm the existing economic-analysis doc matches the
as-built parameters (inflation weights `stakingBps/operatorsBps/customersBps/developersBps`,
`epochLength`, the 20/20/40/20 fee split, ~1%/yr inflation budget that must be PRE-FUNDED — the
pool never mints); distribution merkle (`migration` block); liquidity; governance bootstrap
(deploy TangleTimelock + TangleGovernor and pin into config, or wire into FullDeploy).

## Clarifications (so these aren't re-flagged)
- **Withdrawal delays are fine.** Two layers: (a) protocol staking delays default to 28 rounds
  (delegator unstake) / 56 rounds (operator leave) via `ProtocolConfig` — `guards.*Delay = 0` in
  config means "keep defaults", NOT "instant" (`_applyGuards` only overrides when non-zero);
  (b) per-service exit commitment is blueprint-controlled via the `getExitConfig` hook
  (`minCommitmentDuration`). Neither is a launch risk.

## Code-complete but gated OFF (enable post-launch, per subsystem)
All `deploy=false` in `base-mainnet.json`; flip on when their operational inputs are ready.

### Beacon restaking + L2 slashing (one cross-chain system)
- Bridge is **OP-Stack native** (Base canonical CrossDomainMessenger) — Hyperlane/LayerZero were
  deleted; Arbitrum native retained but unwired in the deploy script. No ISM/DVN to pin.
- **Beacon SSZ-proof fix**: validated against EigenLayer v1.12.0 + a real Deneb fixture. Residual:
  validate against a real **Pectra** beacon-state fixture (needs a live Electra endpoint + the MIT
  `Layr-Labs/eigenpod-proofs-generation` generator) before enabling restaking. Harness is in place
  (`BeaconChainProofsRealFixtureTest`).
- **Required post-deploy timelock actions** (no deploy key can do them — by design):
  1. `MultiAssetDelegation.addSlasher(TangleL2Slasher)` — else every beacon slash reverts.
  2. After 2-day `SENDER_ACTIVATION_DELAY`: `L2SlashingReceiver.activateOpStackL1Sender(...)`.
  3. `ConfigureL2SlashingConnector` (L1) wiring connector → L2 receiver.
  4. `L2SlashingConnector.registerPodOperator(...)` per onboarded pod.
  5. Stand up the off-chain slashing oracle that calls `propagateBeaconSlashing`.

### Liquid-staking vaults
- `DeployLiquidDelegation.s.sol` deploys the factory (turnkey); vaults are created on demand.
- Restrict prod vault creation to real ERC20 assets — the native-ETH vault path is not yet live.

## Open design decision (needs product call, not a bug)
- **Cold-start binary supply-chain (HIGH).** `setBlueprintSources` lets a blueprint owner repoint
  the operator-executed binary. On-chain mitigations shipped: two-step `transferBlueprint`, a
  per-operator source-ack primitive (`ackBlueprintSources` / `operatorAckedCurrentSources`).
  **Full closure requires the off-chain blueprint manager to consult `operatorAckedCurrentSources`
  before booting a repointed binary** — that's a change in the manager repo, not tnt-core.

## What's solid (high confidence)
Core staking/services/payments/blueprints: hardened + tested. Slash-evasion guard, wired BSM
dispute hooks, payments accounting invariants, EIP-712/replay defenses, storage-layout safety,
timelock ERC-7201 slot, facet EIP-170 sizes (under optimizer). See the audit artifact.
