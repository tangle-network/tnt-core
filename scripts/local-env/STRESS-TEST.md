# Local stress test harness

`stress-test.sh` is a single executable that brings up the full local Tangle
stack and walks 17 ordered economic checks against the merged-PR surface
(PRs #132, #133, #134, #136). It is intended as a fast, scriptable smoke test —
re-runnable locally and from CI — for the entire vertical slice.

A full green run takes **~45–85 seconds** on a warm-cache checkout (cold first
compile of `LocalTestnet.s.sol` adds another 4–6 minutes, one-time).

## Prereqs

Required on `PATH`:

- `anvil`, `cast`, `forge` (Foundry — recent enough to support
  `anvil_setStorageAt`, `anvil_setBalance`, `evm_increaseTime`)
- `curl`, `jq`, `nc`, `awk`, `python3`

Repository state:

- `forge soldeer update` must have populated `dependencies/`. The harness checks
  for `dependencies/forge-std-1.9.4` and exits early if missing.
- `forge build` must succeed for the implementation contracts and for
  `script/StressGriefingSeed.s.sol` (the helper that deploys the griefing
  ERC20 used in step 16).

Optional (only when the corresponding flag is passed):

- `docker` + Docker daemon — required for `--with-indexer` (Postgres + Hasura).
- `pnpm` — required for `--with-indexer` and `--with-dapp`.
- A clone of `/home/drew/code/dapp` for `--with-dapp`.
- A clone of `/home/drew/code/llm-inference-blueprint` with a `cargo build
  --release --bin llm-operator` target for `--with-operator`.

## How to run

```bash
# happy path — runs all 17 steps, indexer leg auto-skips (step 17 marked skip)
./scripts/local-env/stress-test.sh

# include the envio indexer + Hasura container; step 17 then asserts entities
./scripts/local-env/stress-test.sh --with-indexer

# also boot the dApp dev server (best-effort, never fails the harness)
./scripts/local-env/stress-test.sh --with-indexer --with-dapp

# also boot a blueprint operator binary
./scripts/local-env/stress-test.sh --with-operator

# skip the griefing-token step if the environment can't run anvil_setStorageAt
./scripts/local-env/stress-test.sh --skip-griefing

# skip step 17 explicitly even when the indexer is up
./scripts/local-env/stress-test.sh --with-indexer --skip-indexer-checks
```

Output format (one line per step + a single result line):

```
[OK]   step 06: operator2 registered             (0.05s)
[OK]   step 10: billSubscription #1              (0.32s, draw1=80909090909090909 wei)
[FAIL] step 13: proposeSlash + executeSlash      (0.30s — see /tmp/stress-13.log)
…
RESULT: 16 / 17 OK in 84s (failed: 13:proposeSlash + executeSlash).
```

Exit code: `0` ⇔ all green, `1` otherwise.

## What each step proves

| # | Step | Validates |
|---|---|---|
| 01 | prerequisites | local tools present, soldeer deps installed |
| 02 | idempotent cleanup | re-runs work — anvil killed, indexer docker volumes wiped, broadcast artifacts removed, state file deleted |
| 03 | anvil + contracts deployed | fresh anvil on port 8545; `script/LocalTestnet.s.sol:LocalTestnetSetup` runs in subscription mode (0.1 ETH per 60s blueprint); broadcast file written |
| 04 | resolve deployed addresses | the broadcast file at `broadcast/LocalTestnet.s.sol/31337/run-latest.json` parses to the Tangle proxy + staking proxy addresses every subsequent step depends on |
| 05 | optional services launched | the three best-effort side-processes (`--with-indexer` / `--with-dapp` / `--with-operator`) start without throwing |
| 06 | operator2 registered | `isOperatorRegistered(0, op2) == true` — confirms the blueprint registration path ran during setup (PR #132 setup baseline) |
| 07 | subscription service Active | `isServiceActive(0) == true` — subscription-priced service activation completed cleanly, including `subscriptionBaselineStake` pin (PR #132 subscription rearchitecture) |
| 08 | operator on service operator set | `isServiceOperator(0, op2) == true` — the `approveService` path emitted the right `ServiceOperator` record; ApprovalsViews split off cleanly (PR #133 facet split for EIP-170) |
| 09 | escrow funded > 0 | `getServiceEscrow(0).balance > 0` — `fundService` (invoked by `requestService{value: 1 ether}`) credited escrow |
| 10 | billSubscription #1 | first bill draws ≤ `subscriptionRate` from escrow; TWAP weighting across multi-asset operator delegations (TNT + native + USDC) executes without revert (PR #133 multi-asset bill weighting) |
| 11 | second staker grows pool | `MultiAssetDelegation.depositAndDelegate{value: 5 ether}` to op2 succeeds; `getOperatorDelegatedStake(op2)` strictly increases — proves the O(1) `_operatorDelegatedAggregate` update path (PR #134) |
| 12 | billSubscription #2 (post-stake) | second period draws again with the now-larger underlying pool — accounting stays consistent across delegations (PR #133 + #134 interplay) |
| 13 | proposeSlash + executeSlash | dispute window respected (`evm_increaseTime` by `7 days + 20s` to clear `DEFAULT_DISPUTE_WINDOW + TIMESTAMP_BUFFER`); `executeSlash` returns non-zero `actualSlashed` and emits `SlashExecuted` (PR #134 share-pool slashing) |
| 14 | operator stake reduced post-slash | `getOperatorDelegatedStake(op2)` post-slash < pre-slash baseline; share-pool slash dropped pool assets without per-delegator iteration (PR #134 win) |
| 15 | claimRewardsAll (native) | native rewards accrued in steps 10/12 are sweepable; `pendingRewards(op2, address(0))` returns 0 after the call |
| 16 | griefing token skipped | a deployed `RevertingTransferERC20` is seeded into op2's pending-reward bookkeeping via `anvil_setStorageAt` (`_pendingRewards[op2][grief] = 1e18` + `_pendingRewardTokens[op2].add(grief)`); `claimRewardsAll` iterates it but per-token try/catch isolates the revert and emits `RewardsClaimSkipped(op2, grief)`; the pending balance remains intact for retry (PR #136 win) |
| 17 | indexer entities present | when `--with-indexer` is set, envio indexer has ≥1 row each in `Operator`, `Service`, `ServiceOperator`, `SubscriptionBilling`, `PaymentDistribution`, `RewardClaim`, `RewardsClaimSkip` (PR #138), `SlashProposal`, `OperatorPoolSlash` (PR #138). Skipped if `--with-indexer` is not passed |

## Where logs land

- `/tmp/stress-NN.log` — stdout+stderr of step `NN`. Any non-zero exit leaves a
  log here for triage.
- `/tmp/stress-NN.log.summary` — single-line headline metric a passing step
  produces (e.g. `draw1=80909090909090909 wei` for step 10). The metric is
  inlined into the step's `[OK]` print and the file is consumed at print time.
- `/tmp/stress-11.stake-baseline` — pre-slash baseline written by step 11 so
  step 14 can compare post-slash stake. Cleaned up by `idempotent_cleanup`.
- `/tmp/stress-anvil.log`, `/tmp/stress-anvil.pid` — output and pid of the
  anvil instance the harness booted.
- `/tmp/stress-16-seed.log` — output of the `StressGriefingSeed` forge script
  that deploys the reverting ERC20 used in step 16.
- `/tmp/stress-dapp.log`, `/tmp/stress-operator.log` — outputs of the optional
  side processes (only created when their flags are passed).

## How to debug

1. **Step 01 fails with "Soldeer deps missing"** — run `forge soldeer update`
   in the repo root and retry.
2. **Step 03 fails** — inspect `/tmp/stress-anvil.log` (anvil itself) and
   `/tmp/stress-03.log` (the `LocalTestnet.s.sol` broadcast). Usually means a
   deployment script reverted or a port collision; the cleanup in step 02
   handles the latter on retry.
3. **Step 04 fails ("no broadcast file")** — `script/LocalTestnet.s.sol`
   produced no broadcast artifact. Re-run with the script's `-vvvv` (manual:
   `forge script script/LocalTestnet.s.sol:LocalTestnetSetup --rpc-url
   http://127.0.0.1:8545 --private-key … --broadcast --non-interactive -vvvv`)
   to see the on-chain trace.
4. **Step 13 fails with `SlashNotExecutable`** — the dispute window or the
   `TIMESTAMP_BUFFER` changed. Read the current window via `cast call
   $TANGLE_ADDR "getSlashConfig()"` and update the `bump_time` argument in
   `step_13_propose_and_execute_slash`.
5. **Step 16 reads `seeded == 0` or some weird number** — the storage slots
   changed. Re-run `forge inspect Tangle storage-layout | rg
   "_pendingRewards|_pendingRewardTokens"` and update the two slot constants
   (`2c` and `40`) inside `step_16_griefing_sweep`. Note: `vm.store` from a
   broadcast forge script does NOT propagate to anvil — only
   `anvil_setStorageAt` does — which is why the harness drives the seeding via
   `curl` rather than from `StressGriefingSeed.s.sol`.
6. **Step 17 fails for a single entity** — bring up an interactive run with
   `--with-indexer KEEP_RUNNING=true ./scripts/local-env/stress-test.sh` and
   inspect Hasura at <http://localhost:8080/console>. Usual cause: an event
   handler regressed when the contract changed selectors.

## Known issues / flakes

- **Indexer cold-start can take 60–120s.** The bring-up probe in
  `setup_indexer_optional` waits up to 240s. On slow disks or first-run
  `pnpm install`, raise to 360s if you see frequent timeouts.
- **`pnpm-workspace.yaml` in `indexer/`** — earlier QA runs may have left a
  stray `pnpm-workspace.yaml` file in `indexer/` with placeholder values that
  cause `pnpm` to choke. The harness's `idempotent_cleanup` does NOT remove
  this file (it's outside our scope to delete a tracked-by-someone file). If
  `--with-indexer` is flaky for you, `rm indexer/pnpm-workspace.yaml` and
  retry.
- **`getOperatorDelegatedStake` granularity** — step 14's pre/post inequality
  depends on the slashed share-pool dust being ≥1 wei. At 1500 bps on a
  10-ETH-equivalent pool the drop is 1.5 ETH ≈ 1.5e18 wei, well above any
  rounding floor. If you parameterize the slash bps lower than 100, the drop
  may round to zero and step 14 will fail spuriously.

## How to extend

Each step is an independent shell function — `step_NN_<name>` — invoked
through `run_step "NN" "<label>" step_NN_<name>`. To add an 18th step:

```bash
step_18_my_new_assertion() {
    state                                 # reload TANGLE_ADDR / STAKING_ADDR
    # ... cast call, assert, optionally write /tmp/stress-18.log.summary
}
# in main():
run_step 18 "my new assertion" step_18_my_new_assertion
TOTAL_STEPS=18                            # bump near the top of the script
```

Conventions:

- Read state via `state` (sources `/tmp/stress-state.env`). Add new keys
  there in `resolve_addresses` if you need a new address.
- Stay revert-on-error inside each step body — `set -e` is enforced.
- If a step measures a number worth surfacing in the OK line, write
  `${LOG_DIR}/stress-NN.log.summary` (one line). The runner consumes it and
  inlines the text into the `[OK]` print.
- If a step needs to persist data across steps, write a separate file like
  `${LOG_DIR}/stress-NN.<purpose>` (the `.summary` files are deleted after
  being consumed by `run_step`). Add the path glob to `idempotent_cleanup`.
- Group all indexer assertions into step 17 to keep the rest of the harness
  fast — every individual GraphQL call has multi-second latency on a
  cold-synced indexer.
