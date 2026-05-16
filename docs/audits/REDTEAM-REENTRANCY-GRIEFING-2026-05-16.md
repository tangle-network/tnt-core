# Red-team audit: reentrancy + griefing — 2026-05-16

Scope: reentrancy posture on token-moving paths, cross-facet self-call
soundness, ERC20 transfer griefing, push-vs-pull patterns, slashing
spam, subscription billing livelock.

Method: read-only trace of every external entry point that moves value
or hits a BSM hook, plus the diamond router and OpenZeppelin
ReentrancyGuard storage layout to confirm shared-state semantics across
facets.

## Summary

| Severity | Count |
|----------|-------|
| Critical | 0 |
| High | 0 |
| Medium | 3 |
| Low | 2 |
| Informational | 1 |

No critical or high-severity issues. Reentrancy guards are correctly
placed and share a single ERC-7201 namespaced slot across every facet
in the diamond (`0x9b779b…5f00`), so the cross-facet self-call pattern
used by subscription billing, payment distribution, and `claimRewardsAll`
all run under the outer caller's guard. All operator and keeper
payments route through `_pendingRewards` (pull) — a malicious
contract-operator cannot brick a distribution by reverting on receive.

The three medium findings cluster around the same underlying gap:
**push transfers in `_distributeBill` to admin-/dev-controlled recipients
(developer, treasury, escrow withdrawer) are not isolated by
try/catch**, mirroring the gap that PR #136 closed for the rewards
sweep. They are griefing surfaces, not loss-of-funds bugs, but they let
a misconfigured manager / treasury / token brick a payment path until
the misconfiguration is corrected — which is sometimes outside the
griefed party's reach.

## Findings

### M-1: `_distributeBill` push transfers can be permanently griefed by a malicious BSM-resolved developer recipient

**Where**
- `src/core/PaymentsDistribution.sol:209` (`PaymentLib.transferPayment(developerAddr, ...)`)
- Recipient resolved by `_resolveDeveloperPaymentAddress` (`PaymentsDistribution.sol:364`),
  which calls `IBlueprintServiceManager.queryDeveloperPaymentAddress` over a
  gas-bounded staticcall.

**What**
The developer share is pushed via `PaymentLib.transferPayment`, which
reverts on transfer failure (`call{value:}` returns false, or
`safeTransfer` reverts). The recipient is whatever the manager hook
returns; on revert / zero / empty return it falls back to
`blueprint.owner`. The hook return value is not bounded, validated, or
isolated by try/catch.

A BSM whose upgrade authority is compromised (or whose original
developer turns adversarial) can return a contract that always reverts
on receive. Every non-subscription distribution for that blueprint —
job results, RFQ executions, quote-accept, service activation pay-once
— will revert at the developer-transfer line. Operators are blocked
from collecting per-job payment. For subscription services the only
escape is `terminateServiceForNonPayment` after the manager-resolved
grace window, after which the customer recovers escrow via
`withdrawRemainingEscrow` but operators are not paid for the
period(s) already due.

The dev share is funded from the customer's payment, so the BSM
attacker burns their own slice of revenue to grief; this caps the
incentive but does not eliminate it (the attack is free for the
manager owner if the original developer share is small relative to
the harm).

**Impact** MEDIUM. Liveness loss on every payment path through
`_distributeBill` for one blueprint. No funds lost (revert is atomic),
but a manager-upgrade scenario can persistently brick payment for the
operators on that blueprint.

**Reproducer (sketch)**
1. Deploy a blueprint with an upgradeable BSM.
2. Operate normally until the blueprint has services + escrow.
3. Upgrade the BSM to one whose `queryDeveloperPaymentAddress` returns
   `address(rejecter)` where `rejecter.receive()` always reverts.
4. Every subsequent `submitResult`, RFQ execute, quote-accept,
   activation, or subscription bill reverts at the developer-transfer
   step.

**Fix**
Wrap the developer push in try/catch the same way `_forwardStakerShare`
already isolates the staker pool. On failure, refund the
griefed share to the service escrow (subscription) or fold it into the
operator pool (one-shot), and emit a marker event. The
`_refundStakerShareToEscrow` helper is already the right shape — apply
the same pattern at line 209.

### M-2: `withdrawRemainingEscrow` has no admin / customer fallback when the escrow token is broken

**Where** `src/core/PaymentsEscrow.sol:46`

**What**
`withdrawRemainingEscrow` zeros `escrow.balance` and bumps
`totalReleased`, then calls `PaymentLib.transferPayment` which reverts
on failure. If the escrow token becomes globally broken (e.g. a
centrally-administered token is paused, the customer is blocklisted,
or the token's `transfer` developers a bug post-deposit) the customer's
funded escrow is permanently stuck. There is no admin rescue path in
the payments subsystem (the staking module has `rescueTokens` but only
for non-registered assets — escrow tokens are not staking-registered).

Symmetric to `claimRewardsAll`'s griefing channel that PR #136 closed
for operator rewards.

**Impact** MEDIUM. Loss of access to funds (not loss of funds — the
balance remains in the contract). Recovery requires a UUPS upgrade to
add a force-rescue path.

**Reproducer (sketch)**
1. Customer funds a service with `BadToken` (centrally paused / can
   blocklist).
2. Service terminates normally.
3. Token issuer pauses transfers (or blocklists the service owner).
4. `withdrawRemainingEscrow` reverts forever.

**Fix**
Either:
- Add a per-service admin-rescue path (`onlyRole(ADMIN_ROLE)`) that
  forwards stuck escrow to the service owner via the same
  permissionless path, isolated by try/catch and with a marker event,
  OR
- Allow the service owner to designate an alternate recipient for the
  refund (parameterize `withdrawRemainingEscrow(uint64 serviceId,
  address payable to)` with owner-only auth on `to`), so a blocklisted
  owner can route to a fresh address.

### M-3: `getNonPaymentTerminationPolicy` is invoked without a gas cap, letting a malicious BSM grief the livelock-escape path

**Where** `src/core/ServicesLifecycle.sol:103`

**What**
`terminateServiceForNonPayment` is the documented livelock-escape for
subscription billing: when an operator-side issue or BSM griefing
freezes the schedule, anyone can terminate after a grace window
resolved by the BSM's `getNonPaymentTerminationPolicy` hook. The
resolver uses Solidity's `try/catch`, which does NOT impose a gas cap
— Solidity forwards 63/64 of the available gas, and the 1/64 reserved
gas may be insufficient to complete the post-call work
(`_terminateService` loops over operators, decrements counters,
deregisters from the heartbeat registry).

A BSM whose `getNonPaymentTerminationPolicy` body burns through all
forwarded gas turns the escape path into a gas-eating black hole.
Off-chain keepers can compensate by sending more gas, but it raises
the cost of the escape — and the protocol elsewhere bounds BSM hooks
to 500k gas via `MANAGER_HOOK_GAS_LIMIT` and a raw staticcall
(`_resolveBillAdjustmentBps` is the canonical pattern).

Same hygiene gap applies to:
- `querySlashingOrigin` at `Slashing.sol:59` (alternate authorization
  path for `proposeSlash`; bounded blast radius because service-owner
  / blueprint-owner are independent authorization paths).
- `getHeartbeatInterval` / `getHeartbeatThreshold` at `Base.sol:613`
  and `:622` (called during `_configureHeartbeat` from activation;
  failure modes degrade to defaults but a BSM gas burn can still
  delay activation).

**Impact** MEDIUM for `getNonPaymentTerminationPolicy` because it sits
on the only livelock escape; LOW for the heartbeat hooks; LOW for
`querySlashingOrigin` because two other authorization paths exist.

**Reproducer (sketch)**
1. BSM implements `getNonPaymentTerminationPolicy(serviceId)` with a
   `while (gasleft() > 1000) { sha256(...) }` body.
2. Service stops being billed, grace elapses.
3. Keeper calls `terminateServiceForNonPayment(serviceId)` with the
   usual gas budget.
4. The hook burns the budget; the catch block runs but the loop in
   `_terminateService` runs out of gas.

**Fix**
Replace the `try / catch` invocations of view hooks with the
gas-bounded raw-staticcall pattern already used by
`_resolveBillAdjustmentBps` and `_resolveDeveloperPaymentAddress`.
Capped to `MANAGER_HOOK_GAS_LIMIT` (500k), with revert / empty / wrong
returndata falling back to the default. This is mechanical: every
view-hook resolver should look like `manager.staticcall{ gas:
MANAGER_HOOK_GAS_LIMIT }(...)` and `abi.decode` the return data only
on the success path.

### L-1: `_settleDisputeBond` strands the dispute bond when the treasury push fails after a slash executes

**Where** `src/core/Slashing.sol:475` (`_settleDisputeBond`, in the
`refund == false` branch)

**What**
On `executeSlash` / `executeSlashBatch`, the disputer's bond is
forwarded to the treasury via `t.call{value: bond}("")`. On failure
the function restores `proposal.disputeBond` and `proposal.disputer`,
but by this point the proposal has already been `markExecuted`'d. No
admin re-settle path reads `proposal.disputeBond` for executed
proposals, so the bond is stuck on the proposal struct until a UUPS
upgrade or a manual rescue.

Realistic only if the treasury is misconfigured (contract without
payable fallback, or a multisig whose receiver logic reverts). The
`setTreasury` admin path lets ops correct the misconfiguration, but
already-executed proposals remain unsettled.

**Impact** LOW. Stuck native asset; recovery requires either an admin
re-settle path or a UUPS upgrade.

**Fix**
Add an admin-callable re-settle helper that re-runs `_settleDisputeBond`
for executed proposals whose `disputeBond > 0`. Alternatively, on push
failure during execute, fall through to a `_pendingDisputeBondRefunds`
pull credit for the treasury so the existing claim path drains it.

### L-2: `_operatorActiveSlashProposals` cap check ordering is inverted in `proposeSlash`

**Where** `src/core/Slashing.sol:93`

**What**
The pending-slash cap check (`_operatorActiveSlashProposals[operator]
>= maxPendingSlashesPerOperator`) runs AFTER
`SlashingLib.proposeSlash` has already allocated `slashId`, written
the proposal struct, and emitted `SlashProposed`. The revert at line
94 correctly rolls everything back, but the call burns gas unnecessarily
and emits a misleading event-then-revert pattern that off-chain
indexers may interpret as a successful propose followed by a separate
cap event.

**Impact** LOW. No state corruption — EVM revert rolls back all writes
and emits. Cosmetic ordering issue; minor wasted gas.

**Fix**
Move the cap check (and the `_operatorActiveSlashProposals[operator]
+= 1` increment that pairs with it) above the `SlashingLib.proposeSlash`
call so the cap fires before any other state mutation.

### I-1: `_claimRewardsTokenSafe` self-call is correctly NOT `nonReentrant`, confirmed by trace

**Where** `src/core/PaymentsRewards.sol:85`

**What** (clarification, not a finding)
`claimRewardsAll` holds the outer `nonReentrant` guard for the whole
sweep. Per-token execution self-calls
`this._claimRewardsTokenSafe(account, token)`, which goes external
(diamond proxy receives, dispatches to the rewards facet via
delegatecall). The inner function deliberately omits `nonReentrant`
because the OpenZeppelin guard's storage slot is the ERC-7201 namespaced
slot at `0x9b779b…5f00`, which is read/written under the proxy's
delegatecall context and therefore SHARED across facets. The outer
guard is `ENTERED` at the moment the self-call lands. If the inner
function were `nonReentrant` it would revert on every token. If a
token transfer inside the inner self-call attempted to re-enter
`claimRewardsAll`, the outer guard would block it (defense-in-depth).

This is correct and the audit confirms it. The same reasoning applies
to `distributePayment`, `distributeBillWithKeeper`, `depositToEscrow`,
and `initSubscriptionBaseline` — all self-call entry points
intentionally omit `nonReentrant` and gate on `msg.sender ==
address(this)` as the first check, before any state read.

## Clean checks

The following items were traced end-to-end and confirmed clean:

- **All token-moving external entry points hold `nonReentrant`.**
  Verified: `fundService`, `withdrawRemainingEscrow`,
  `billSubscription`, `billSubscriptionBatch`, `claimRewards()`,
  `claimRewards(address)`, `claimRewardsBatch`, `claimRewardsAll`,
  `proposeSlash`, `disputeSlash`, `executeSlash`, `executeSlashBatch`,
  `cancelSlash`, `claimDisputeBond`, `submitJob`, `submitResult`,
  `submitResults`, all aggregation / RFQ / quote / quote-extension /
  service-activation / join / exit entry points,
  `registerOperator` (both variants), `unregisterOperator`,
  `terminateService`, `terminateServiceForNonPayment`, `joinService`,
  `joinServiceWithCommitments`, `scheduleExit`, `executeExit`,
  `cancelExit`, `forceExit`, `leaveService`, `forceRemoveOperator`.

- **Cross-facet self-call reentrancy posture.** The OpenZeppelin
  `ReentrancyGuardUpgradeable` v5.1.0 stores its `_status` flag at the
  ERC-7201 slot
  `keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ReentrancyGuard"))
  - 1)) & ~bytes32(uint256(0xff))` — a fixed,
  inheritance-position-independent location. Every facet in the
  diamond inherits `Base → ReentrancyGuardUpgradeable`, and all
  delegatecalls from the diamond router operate on the proxy's
  storage, so the guard is genuinely shared. Self-calls from one facet
  to another go through `address(this).call(...)`, which lands at the
  proxy's fallback and delegatecalls into the target facet under the
  same storage context. Verified by reading the OZ implementation,
  `FacetRouterBase._delegateTo`, and confirming `Base.__Base_init`
  calls `__ReentrancyGuard_init()` exactly once at proxy
  initialization.

- **Self-call gates fire before any state read or external call.**
  `distributePayment`, `depositToEscrow`, `initSubscriptionBaseline`,
  `distributeBillWithKeeper`, `_claimRewardsTokenSafe`: each begins
  with `if (msg.sender != address(this)) revert Errors.Unauthorized();`
  as the very first statement.

- **Operator payments are pull, not push.** `_distributeBill` credits
  per-operator amounts to `_pendingRewards[operator][token]` via
  `PaymentLib.addPendingReward` and tracks the token via
  `_pendingRewardTokens[operator].add(token)`. Operators claim later
  via `claimRewards*`. A contract-operator that reverts on receive
  cannot force-fail the distribution. Confirmed by reading
  `PaymentsDistribution._payOperatorPoolByWeight:283-294`.

- **Keeper rebate is pull.** Same pattern at
  `PaymentsDistribution._distributeBill:229-233`.

- **CEI ordering in token-moving paths.**
  - `withdrawRemainingEscrow`: zeros `escrow.balance`, bumps
    `totalReleased`, THEN transfers (`PaymentsEscrow.sol:60-63`).
  - `claimPendingReward`: reads amount, zeros pending entry, THEN
    transfers (`PaymentLib.sol:351-364`).
  - `claimDisputeBond`: reads amount, zeros pending entry, THEN
    transfers; restores on transfer failure (`Slashing.sol:521-534`).
  - `_settleDisputeBond` (refund branch): zeros
    `proposal.disputeBond` and `proposal.disputer` BEFORE any
    interaction (`Slashing.sol:481-483`).
  - `executeSlash`: every state mutation
    (`markExecuted`, `decrementPendingSlash`,
    `_decrementOperatorPendingTracker`, `_recordSlash`) finalizes
    before `_settleDisputeBond` does the push.

- **`_forwardStakerShare` refund accounting is correct.** The function
  pushes ERC20 to the distributor BEFORE the staking-distributor call
  for ERC20 (so a revert leaves tokens at the distributor; the
  `StakerShareRefundedToEscrow` event marks it for off-chain
  resolution), and uses value-on-call for native (rolled back on
  revert, refunded to escrow). The escrow refund path
  (`_refundStakerShareToEscrow`) increments `escrow.balance += amount`
  and decrements `escrow.totalReleased` saturating at zero. The
  symmetry with `releaseFromEscrow` is exact when
  `escrow.totalReleased >= amount`; the saturation case can only
  happen when the staker share to refund exceeds the lifetime release
  count, which is structurally impossible (the release is in the
  same `_distributeBill` invocation that produced this refund branch,
  so `totalReleased` is at least `d.amount > stakerShare`). Verified
  at `PaymentsDistribution.sol:339-360`.

- **Manager hook gas bounding (correct sites).**
  `_resolveBillAdjustmentBps` (`PaymentsBilling.sol:381`),
  `_resolveDeveloperPaymentAddress` (`PaymentsDistribution.sol:374`),
  `_callManager` (`Base.sol:730`), `_tryCallManager` (`Base.sol:743`):
  all use `manager.staticcall{ gas: MANAGER_HOOK_GAS_LIMIT }(...)` or
  `manager.call{ gas: MANAGER_HOOK_GAS_LIMIT }(...)`. The
  `_isPaymentAssetAllowedByManager` helper does NOT bound gas but is
  read-only with a single boolean return and is invoked from
  `try/catch`; failure denies the token. Acceptable. The hooks that
  lack the bound are listed in M-3.

- **`fundService` ingress validation.** Re-checks (a) service active,
  (b) subscription pricing, (c) not TTL-expired, (d) manager still
  whitelists token. `depositToEscrow → collectPayment` rejects
  fee-on-transfer / rebasing tokens via the
  `balanceAfter - balanceBefore` check, rejects native value with
  ERC20 payments, and requires exact `msg.value` for native. CEI:
  collect THEN credit. Verified at `PaymentsEscrow.sol:19-43` and
  `PaymentLib.sol:211-249`.

- **Slashing spam cap.** `_operatorActiveSlashProposals` is bounded by
  `_slashState.config.maxPendingSlashesPerOperator` (default 32, never
  zero per `initializeConfig` and `updateConfig` validation). Past 32,
  `proposeSlash` reverts. Counter is decremented in `executeSlash`,
  `executeSlashBatch`, and `cancelSlash` paths via
  `_decrementOperatorPendingTracker`. Verified at
  `Slashing.sol:541-544` and `SlashingLib.sol:155-185`. Ordering is
  suboptimal (L-2) but correctness holds.

- **Subscription billing livelock paths considered.** The bill schedule
  advances `lastPaymentAt` by exactly one `interval` per processed
  period. The cursor advances unconditionally on:
  - Zero active operators (`PaymentsBilling.sol:116-120`,
    `SubscriptionBillSkippedNoOperators`).
  - Bill rounds to zero (`PaymentsBilling.sol:177-180`).
  - Skip-on-dust below `minBillAmount` (`PaymentsBilling.sol:171-175`).
  - Successful bill with manager QoS discount applied
    (`PaymentsBilling.sol:147-154`).
  The cursor does NOT advance on insufficient escrow
  (`PaymentsBilling.sol:159-162`), so an underfunded service stays
  stuck on the same period — recovery is either top-up
  (`fundService`) or `terminateServiceForNonPayment` after grace.
  Findings M-1 and M-3 are the only ways to permanently brick advance:
  a malicious developer recipient (M-1) makes the distribute step
  revert, which keeps the cursor un-committed; a malicious BSM
  termination-policy hook (M-3) makes the escape itself griefable.
  Both have mechanical fixes; neither corrupts state.

- **No path calls `distributePayment` with a forged operators array.**
  All eight call sites (`TangleJobsFacet` ×2, `TangleQuotesFacet`,
  `TangleJobsRFQFacet`, `TangleJobsAggregationFacet` ×2,
  `TangleQuotesExtensionFacet`, `TangleServicesFacet`) construct
  `operators` from `_serviceOperatorSet[serviceId].values()` or
  `_jobQuotedOperators[serviceId][callId].values()` or the
  request-resolved selection. No path lets a caller smuggle a
  fabricated address into the array.

- **`_claimRewardsTokenSafe` is registered on the rewards facet.**
  `TanglePaymentsRewardsFacet.selectors()` includes
  `this._claimRewardsTokenSafe.selector` at index 13. Without this
  registration the diamond fallback would revert with
  "unknown selector" and `claimRewardsAll` would tip every token into
  the catch block. Verified at
  `TanglePaymentsRewardsFacet.sol:27`.

## Method

1. Read `Base.sol` to confirm every protocol contract inherits
   `ReentrancyGuardUpgradeable` exactly once and `__ReentrancyGuard_init`
   is called at initialization.
2. Read the OpenZeppelin v5.1.0 `ReentrancyGuardUpgradeable.sol` source
   to confirm the guard's storage location is ERC-7201 namespaced (not
   inheritance-position dependent), and therefore shared across facets
   in the diamond.
3. Read `FacetRouterBase.sol` to confirm the diamond uses `delegatecall`
   for all facet dispatch, preserving the proxy's storage context.
4. Enumerate every external entry point under `src/core/` and
   `src/facets/tangle/` that moves tokens, calls a BSM hook, or is
   reachable from a path that does either. For each, verify
   `nonReentrant`, CEI ordering, and authorization gating.
5. Trace the self-call surfaces (`distributePayment`,
   `distributeBillWithKeeper`, `depositToEscrow`,
   `initSubscriptionBaseline`, `_claimRewardsTokenSafe`) end-to-end:
   confirm the `msg.sender == address(this)` gate is the first
   statement, confirm the outer caller holds `nonReentrant`, and
   confirm the inner does NOT (so the legitimate self-call is not
   blocked by the same-frame guard).
6. Enumerate every `manager.call` / `manager.staticcall` /
   `IBlueprintServiceManager(manager).<fn>` callsite. Confirm gas
   bounding (`MANAGER_HOOK_GAS_LIMIT`) or document the gap.
7. Trace the subscription billing flow: identify every cursor-advance
   site and every revert site, enumerate the adversarial state
   combinations that could pin `lastPaymentAt`, and confirm the
   permissionless escape `terminateServiceForNonPayment` cleanly
   exits.
8. Audit operator and keeper payment patterns: confirm pull via
   `_pendingRewards` is the only path used in `_distributeBill` and
   that no path push-transfers value to operator addresses.
