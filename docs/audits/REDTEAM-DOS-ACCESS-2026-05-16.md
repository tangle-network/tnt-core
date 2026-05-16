# Red-team audit: DoS surfaces + access control

Scope: `src/core/`, `src/staking/`, `src/beacon/`, `src/facets/`, `src/libraries/`.
Method: static read of the branch `chore/audit-dos-access-2026-05-16` (forked from `chore/audit-economic-oracle-2026-05-16`), no source modifications.
Posture: adversarial, looking for paths that (a) brick state for honest users or (b) escalate privilege beyond the documented trust boundary.

## Summary

| Severity      | Count |
|---------------|-------|
| CRITICAL      | 0     |
| HIGH          | 2     |
| MEDIUM        | 4     |
| LOW           | 4     |
| INFORMATIONAL | 3     |

The two HIGH items are both real DoS surfaces that touch the permissionless billing path. Neither lets an attacker steal funds, but both can force a service into an unbillable / unrecoverable state via gas exhaustion. Everything else is hardening / hygiene.

The reviewed code is generally well-bounded: `MAX_OPERATORS_PER_SERVICE` is enforced as a hard ceiling on every per-operator loop, manager hooks that route value (`_callManager`, `_tryCallManager`, the two `staticcall` paths in `PaymentsBilling`/`PaymentsDistribution`) all carry an explicit `MANAGER_HOOK_GAS_LIMIT` cap, and the EIP-712 + BLS PoP + TEE nonce constructions are all bound to `(chainId, verifyingContract, …)`. The gaps are concentrated in two places: per-asset commitment arrays whose length is operator/customer-supplied with no cap, and a handful of `try IBlueprintServiceManager(...)` callsites that do not carry an explicit gas stipend.

## Findings

### H-1 (HIGH) — Unbounded security-commitment arrays brick subscription billing

Files: `src/core/ServicesRequests.sol:351-358`, `src/facets/tangle/TangleServicesFacet.sol:73-91`, `src/core/PaymentsBilling.sol:204-360`, `src/core/PaymentsDistribution.sol:105-159`, `src/core/Slashing.sol:128-205`.

`requestServiceWithSecurity` accepts `Types.AssetSecurityRequirement[] calldata securityRequirements` with only `requirements.length == 0` rejected (`ServicesRequests.sol:352`). There is no upper bound.

At activation, `_persistServiceSecurity` (TangleServicesFacet.sol:73) copies the requirements into `_serviceSecurityRequirements[serviceId]` and, for every approving operator, copies their commitment array into `_serviceSecurityCommitments[serviceId][operator]`. Both arrays grow O(R) where R is the customer-chosen requirement count.

Every subscription bill then walks every (operator × asset) pair:

- `PaymentsBilling._accrueOperatorWeights` (line 270) — outer loop over operators, inner loop over the operator's commitments (line 304). `oracle.toUSD` may be invoked per asset.
- `PaymentsBilling._commitOperatorCursors` (line 213) — symmetric inner loop per operator (line 224).
- `PaymentsDistribution._initSubscriptionBaseline` (line 114) — same nested shape (line 132), runs once at activation.
- `Slashing._computeServiceCommitmentExposureBps` (line 138 / 162) — full asset walk on every slash proposal.

Operators per service are bounded by `MAX_OPERATORS_PER_SERVICE = 64`, but R is not bounded. A customer who lists, say, R = 1000 ERC-20 requirements pays ~32 KB of calldata once at request time (request cost is high but finite) and from that point forward every `billSubscription` and every `proposeSlash` for that service iterates 64 × 1000 = 64 000 commitments. Each inner iteration does a `keccak256`, a storage read (`_serviceSecurityCommitmentBps`), an `_staking.getCumStakeSeconds` external call, and — when an oracle is configured — an `oracle.toUSD` external call.

This blows past the block gas limit on a single mainnet block well before R = 1000 is reached. Once it does, the subscription bill cannot be drawn, the escrow cannot be released to operators, and `terminateServiceForNonPayment` cannot fire either (it requires `billSubscription` machinery via the manager-policy resolver). Customer funds are not stolen — they're stranded in escrow until the customer terminates manually — but operators silently stop being paid.

The cost surface is paid by:
- The keeper calling `billSubscription` (the rebate is denominated in basis points of the bill; a runaway commitment count makes the rebate go negative net of gas).
- The slash proposer in `proposeSlash`.
- The last-approving operator in `approveService` → `_activateService`.

Recommendation: add `MAX_SECURITY_REQUIREMENTS_PER_REQUEST` (mirroring the existing `MAX_TEE_COMMITMENTS_PER_OPERATOR = 8` in `ServiceValidationLib.sol:10`) and enforce it in `_validateSecurityRequirements`. A practical cap is 16 — more than enough for any heterogeneous-asset blueprint, low enough that the worst-case bill stays within a single block.

### H-2 (HIGH) — Permissionless bill / aggregation paths forward 63/64 gas to `try IBlueprintServiceManager(...)`

Files: `src/core/JobsAggregation.sol:65,69,125`, `src/core/JobsSubmission.sol:240,337`, `src/core/ServicesLifecycle.sol:103,404,448,475,643,651`, `src/core/Operators.sol:137`, `src/core/Slashing.sol:59`, `src/core/Base.sol:613,622`.

`_callManager` and `_tryCallManager` in `Base.sol` (lines 730 / 743) both enforce `gas: MANAGER_HOOK_GAS_LIMIT` (500 000), and the two `staticcall` sites in `PaymentsBilling._resolveBillAdjustmentBps` (line 381) and `PaymentsDistribution._resolveDeveloperPaymentAddress` (line 374) do the same. Confirmed.

However, every `try IBlueprintServiceManager(bp.manager).foo() … catch { }` callsite does NOT add an explicit gas stipend. Solidity's `try/catch` for an external call without `{ gas: … }` follows ordinary EVM `CALL` semantics: it forwards 63/64 of remaining gas. A malicious BSM can consume that entire stipend in an OOG loop and then revert; the surrounding `catch { }` swallows the revert but the gas is already gone.

The most exploitable callsite is `Slashing.proposeSlash → querySlashingOrigin` (line 59) and the `requiresAggregation` hooks in `JobsAggregation.submitAggregatedResult` (line 65) and `JobsSubmission._maybeRequireAggregation` (line 240). All three are reachable from permissionless or semi-permissionless paths (anyone with a valid signature for the latter two) and all three sit BEFORE the bulk of the function's state writes. A malicious manager that wants to brick aggregated-result submission for its own blueprint can simply make `requiresAggregation` burn all forwarded gas before the protocol can record a successful job result.

Most other instances are less severe because they're only hit by parties that already trust the blueprint (the operator registering, the operator joining, the operator leaving, the service owner force-removing). For those, the BSM is part of the documented trust boundary and the worst-case is "the BSM author can brick their own service" — annoying but the customer/operator chose this BSM.

Recommendation: route every `try IBlueprintServiceManager(...) … catch` through a helper that mirrors `_tryCallManager`'s pattern — `manager.staticcall{ gas: MANAGER_HOOK_GAS_LIMIT }(abi.encodeCall(…))` followed by `abi.decode` on success. The two existing call sites in `PaymentsBilling` and `PaymentsDistribution` already use this pattern and can be lifted to a shared internal helper.

### M-1 (MEDIUM) — Cosmetic role separation: `DEFAULT_ADMIN_ROLE` granted to a single key

Files: `src/core/Base.sol:174-178`, `src/staking/MultiAssetDelegation.sol:53-55`.

`__Base_init` grants `DEFAULT_ADMIN_ROLE` to `admin` and then separately grants `ADMIN_ROLE`, `PAUSER_ROLE`, `UPGRADER_ROLE`, and `SLASH_ADMIN_ROLE` to the same address. OpenZeppelin AccessControl uses `DEFAULT_ADMIN_ROLE` as the default role admin for every other role (no `_setRoleAdmin` overrides exist in the codebase, verified via `grep -rn "_setRoleAdmin\|getRoleAdmin" src/`). Consequently, whoever holds `DEFAULT_ADMIN_ROLE` can `grantRole(UPGRADER_ROLE, self)` and unilaterally upgrade the proxy. The advertised role separation — admin / pauser / upgrader / slash-admin as distinct privilege levels — is cosmetic until the role admins are explicitly siloed.

The deployment runbook states that `DEFAULT_ADMIN_ROLE` should be handed off to a timelock post-deploy (Base.sol:159-161 has the H-5 note). That is necessary but not sufficient: the timelock will still be able to grant itself any role at any time. To actually enforce defense-in-depth, the contract must call `_setRoleAdmin(UPGRADER_ROLE, GOVERNANCE_ROLE)` (and equivalents) during init so the admin path and the upgrade path are different principals.

Same issue exists in `MultiAssetDelegation.__init` for the staking adapter (admin = ADMIN_ROLE = ASSET_MANAGER_ROLE all collapsed to a single key).

Recommendation: in `__Base_init`, add `_setRoleAdmin(UPGRADER_ROLE, UPGRADER_ROLE)` (or a dedicated `GOVERNANCE_ROLE`) so admin cannot grant the upgrade key, and similarly for `SLASH_ADMIN_ROLE`. Mirror in `MultiAssetDelegation`.

### M-2 (MEDIUM) — `ValidatorPodManager` slasher registry gated only by single-owner `onlyOwner`

Files: `src/beacon/ValidatorPodManager.sol:275,985-993,999,1004`.

`ValidatorPodManager` is `Ownable` (not `Ownable2Step`, not role-based) and `_slashers` is a bare `mapping(address => bool)` mutated by `addSlasher` / `removeSlasher` (lines 985 / 990). Owner is set in the constructor (`Ownable(msg.sender)` at line 275). `setBeaconOracle` (line 999) and `setWithdrawalDelay` (line 1004) are similarly `onlyOwner` with no timelock.

If the deployer EOA is compromised before ownership is transferred (or if `transferOwnership` is never called), an attacker can:

- Add themselves as a slasher and slash any operator pool.
- Re-point the beacon oracle to an attacker-controlled feed and forge rebase deltas.
- Set `withdrawalDelay` to `type(uint32).max` to brick withdrawals.

The core `Tangle` contract uses `AccessControl` with explicit role separation; `ValidatorPodManager` skipped this. The trust model for the beacon module is therefore weaker than the trust model for the rest of the protocol.

Recommendation: migrate to `AccessControl` with at least `ADMIN_ROLE` + `SLASHER_ROLE` + `ORACLE_ADMIN_ROLE`, mirroring the staking adapter. At minimum, switch to `Ownable2Step` to defend against fat-fingered ownership transfers. Consider a timelock on `addSlasher` and `setBeaconOracle`.

### M-3 (MEDIUM) — Stale-state risk: `_operatorActiveSlashProposals` only decrements on explicit `execute*` / `cancel*` calls

File: `src/core/Slashing.sol:90-99,541-544`, `src/libraries/SlashingLib.sol:338-346`.

`proposeSlash` is callable by `svc.owner`, `bp.owner`, or the BSM-declared `slashingOrigin`. The cap `_operatorActiveSlashProposals[operator] >= maxPendingSlashesPerOperator` (Slashing.sol:93) bounds in-flight slash proposals against a single operator. The counter is incremented at proposal time and decremented inside `_decrementOperatorPendingTracker` from `executeSlash`, `executeSlashBatch`, and `cancelSlash`.

The auto-fail path for a disputed proposal is handled implicitly: once `block.timestamp >= proposal.disputeDeadline + TIMESTAMP_BUFFER`, `SlashingLib.isExecutable` returns `true` for the `Disputed` status (line 342-344). So a disputed proposal whose deadline has elapsed becomes executable via `executeSlash` — which then decrements the counter correctly. There is no state-leak when the path is exercised.

The remaining concern is operational, not exploitable: a disputed proposal whose deadline has elapsed but for which nobody ever calls `executeSlash` keeps the local counter bumped indefinitely. Because the counter is per-operator, an attacker who can spam `disputeBond`-backed disputes on `maxPendingSlashesPerOperator` proposals AND find a victim who never gets around to `executeSlash`-ing them can lock out legitimate slash proposals on that operator. The economic cost is `maxPendingSlashesPerOperator × disputeBond` posted by the attacker (refunded on `cancelSlash`, forfeit on `executeSlash`), so the attack is not free.

Recommendation: extend the invariant fuzz suite (`test/fuzz/InvariantFuzz.t.sol`) to assert that `_operatorActiveSlashProposals[op]` equals the count of non-finalized proposals targeting `op` across all proposal IDs after every action. Optional: expose a permissionless `sweepStaleDisputedSlashes(uint64[] slashIds)` helper that just calls `executeSlash` on each (already permissionless, but a batched variant lowers the friction).

### M-4 (MEDIUM) — `addPermittedCaller` / `removePermittedCaller` / `updateOperatorPreferences` / `preRegister` lack `whenNotPaused`

Files: `src/core/ServicesLifecycle.sol:159,168`, `src/core/Operators.sol:49,243`.

The pause policy across the protocol is consistent for funds-flow paths: every entry that pulls value (`fundService`, `requestService*`, `joinService*`, `billSubscription*`, `submitJob`, `submitResult*`, `createBlueprint`, `extendService*`, `acceptQuote*`) carries `whenNotPaused`. State-removing paths (`terminate*`, `leave*`, `exit*`, `withdrawRemainingEscrow`, `claimRewards*`, `claimDisputeBond`) are intentionally pause-bypass so customers can recover funds during an emergency.

The four functions above don't fit either pattern:
- `preRegister` (Operators.sol:49) only emits an event; it has no economic side effect, so paused or unpaused makes no difference. Worth pausing for consistency.
- `addPermittedCaller` / `removePermittedCaller` (ServicesLifecycle.sol:159/168) mutate the permitted-caller set for an active service. During pause, the service is still active but no jobs can be submitted (`submitJob` is paused), so adding/removing callers is moot. Worth pausing for consistency.
- `updateOperatorPreferences` (Operators.sol:243) is more concerning: it lacks BOTH `whenNotPaused` AND `nonReentrant`, then calls `_tryCallManager` at line 288. The reentrancy surface is narrow (the function only writes operator-prefs storage) but the inconsistency with `registerOperator` / `unregisterOperator` (both of which carry `nonReentrant`) is suspicious. A malicious BSM hook could re-enter `updateOperatorPreferences` on a different blueprint, but the cross-blueprint state is independent, so no concrete exploit emerges. Defense-in-depth says add `nonReentrant`.

Recommendation: add `whenNotPaused` to all four. Add `nonReentrant` to `updateOperatorPreferences`.

### L-1 (LOW) — `O(N²)` operator-duplicate check in `_validateRequestOperators` runs before the size cap

File: `src/core/ServicesRequests.sol:266-287`, `_validateOperatorBounds` at line 294-308.

`_requestServiceInternal` calls `_validateRequestOperators` (which does an `O(operators.length²)` duplicate scan at line 282) BEFORE calling `_computeRequestBounds` → `_validateOperatorBounds` (line 202). With `operators.length` user-supplied, the duplicate scan runs to completion even when the array exceeds `MAX_OPERATORS_PER_SERVICE`.

The early `OperatorNotRegistered` revert on line 268 caps this in practice (the first non-registered operator short-circuits), but a caller who fills the array entirely with registered operators avoids that escape hatch. Self-DoS at worst — the caller pays the gas — but trivial to fix by moving `_validateOperatorBounds` (or just a `if (operators.length > MAX_OPERATORS_PER_SERVICE) revert` guard) to the top of `_requestServiceInternal`.

### L-2 (LOW) — `_isRequestOperator` is O(N) on every approval / rejection

File: `src/core/ServicesApprovals.sol:194-200`.

`_requireApprovingOperator` (line 186) and `rejectService` (line 166) both call `_isRequestOperator`, which linearly scans `_requestOperators[requestId]`. Bounded by `MAX_OPERATORS_PER_SERVICE = 64`, so capped at 64 SLOADs per call. Not exploitable; flagged because a hash set / bitmap would cut approval-side gas roughly in half. Pure perf, not security.

### L-3 (LOW) — `_pendingRewardTokens[account]` set has no eviction on zero balance

File: `src/core/PaymentsDistribution.sol:231,285`, `src/core/PaymentsRewards.sol:113-121`.

`_pendingRewardTokens[account].add(token)` is called every time a reward is accrued in a new token. The set is cleaned up in `_claimRewardsToken` only when `claimed > 0`. If `addPendingReward` is called for `amount == 0` (it isn't today — both call sites guard `opShare > 0`/`stakerShare > 0`), the set could grow without ever shrinking.

Bigger concern: there is no scenario today where an attacker can inject arbitrary `token` values into the set — `token` always comes from the customer-chosen escrow token or `address(0)` (native). So set growth is bounded by the set of tokens the operator chose to receive payment in. Indexable concern only — `rewardTokens(account)` view becomes expensive for long-lived operators, but the on-chain `claimRewardsAll` loop is isolated per token via `try/catch` so a single griefing token cannot brick the sweep. No action required.

### L-4 (LOW) — `executeSlashBatch` continues after `_settleDisputeBond` push-failure leaves state inconsistent

File: `src/core/Slashing.sol:475-504`.

`_settleDisputeBond` on `refund == false` (executeSlash path) pushes the bond to the treasury via `t.call{ value: bond }("")`. If the call fails, the code restores `proposal.disputeBond` and `proposal.disputer` (line 501-503). For `executeSlash` (single-slash), this is fine — the entire transaction reverts gracefully via the next call's failure.

For `executeSlashBatch`, however, the loop continues even when the treasury push fails on an earlier proposal. The proposal is marked `Executed` at line 308 BEFORE the bond settle at line 314; if the bond push fails, the bond is restored on the proposal but the proposal status remains `Executed`. A subsequent retry of `executeSlash(slashId)` will revert with `SlashNotExecutable`. The bond is stuck on the proposal record — recoverable via a future treasury reconfiguration but not via the normal flow.

Fix: in `executeSlashBatch`, either re-revert the iteration when `_settleDisputeBond` fails to push, or unconditionally credit the bond to a pull-pattern mapping (mirroring the refund path) instead of pushing.

### INFO-1 — `unregisterOperator` allowed during pause

File: `src/core/Operators.sol:196`.

By design, since unregistration only removes state and the protocol-paused state shouldn't trap operators in blueprints. Documented behavior; no action.

### INFO-2 — Permissionless `expireServiceRequest` lacks `whenNotPaused`

File: `src/core/ServicesApprovalsViews.sol:68`.

Also fine by design: this is the customer's recovery path. During pause, `approveService` cannot fire, so an expired request can only be cleaned up via this entry. Worth adding a comment.

### INFO-3 — `_setRoleAdmin` is never invoked, so all five roles share one administrator

See M-1.

## Clean checks (verified, no findings)

1. **`MAX_OPERATORS_PER_SERVICE = 64` enforcement** — enforced at request validation (`ServicesRequests._validateOperatorBounds`) and again at join (`ServicesLifecycle._loadJoinContext:625-630`). Blueprint configs with `maxOperators == 0` are clamped to the protocol ceiling in both spots, matching the docstring at `ProtocolConfig.sol:44-48`.

2. **`MAX_BLUEPRINTS_PER_OPERATOR = 1024` enforcement** — enforced in `Operators._registerOperator:114-118`, decremented in `unregisterOperator:225-227`. `Operators.getOperatorTotalActiveServices:305-313` iterates the global blueprint counter (`_blueprintCount`) — this is a view function, off-chain only; not a DoS concern.

3. **`MAX_TEE_COMMITMENTS_PER_OPERATOR = 8` enforcement** — `ServiceValidationLib.validateTeeCommitments:21-23` rejects above-cap arrays at approval time. Confirmed bound on the storage path (`_serviceTeeCommitmentRoot` is a bytes32, not an array).

4. **Manager-hook gas caps on value-routing paths** — `_callManager` and `_tryCallManager` (`Base.sol:730-748`) both enforce `gas: MANAGER_HOOK_GAS_LIMIT = 500_000`. The two `staticcall` paths in `PaymentsBilling._resolveBillAdjustmentBps:381` and `PaymentsDistribution._resolveDeveloperPaymentAddress:374` do the same. Confirmed.

5. **EIP-712 domain separator** — `SignatureLib.computeDomainSeparator:60-75` binds `name + version + chainId + verifyingContract`. Recomputed from `block.chainid` on every verification in `Base._domainSeparatorView:209-211`, so a post-fork chainid invalidates pre-fork signatures automatically. `verifyAndMarkQuoteUsed`, `verifyAndMarkJobQuoteUsed`, and `verifyQuoteBatch` all mark digests as used in a `mapping(bytes32 => bool)`; no replay window.

6. **BLS PoP binding** — `AttestationLib.blsPopMessage:30-41` returns `abi.encode("TANGLE_BLS_POP_v1", chainId, verifyingContract, operator, blsPubkey)`. `ServiceValidationLib.requireBlsProofOfPossession:83-99` passes that exact tuple to `BN254.verifyBls`. Cross-chain / cross-operator / cross-key replay all blocked.

7. **TEE attestation nonce binding** — `AttestationLib.teeNonce:15-25` binds `(requestId, verifyingContract, chainId)`. `ServiceValidationLib.validateTeeCommitments:30` checks `teeCommitments[i].nonceBinding == expectedNonce`. Cross-request / cross-chain replay both blocked.

8. **`_disableInitializers` on every UUPS implementation** — confirmed on `Base.sol:151-153` (inherited by `Tangle`), `MultiAssetDelegation.sol:30-32`, `MBSMRegistry.sol:89-91`, `TangleGovernor.sol:76-78`, `TangleToken.sol:65-67`. `RewardsManager` and `MasterBlueprintServiceManager` are not upgradeable (no `Initializable` import), so the front-running window doesn't apply.

9. **`withdrawRemainingEscrow` works during pause** — `src/core/PaymentsEscrow.sol:46` lacks `whenNotPaused` by design. Customer recovery path during emergency pause. Confirmed safe.

10. **`claimRewardsAll` per-token isolation** — `src/core/PaymentsRewards.sol:55-78` wraps each token claim in a self-call `try/catch` so a single griefing ERC-20 cannot brick the sweep. The set is snapshot before iteration (line 59-65) to handle in-loop mutation safely.

11. **Slasher registry gating in staking adapter** — `addSlasher` in `StakingAdminFacet.sol:48` requires `ADMIN_ROLE` and grants `SLASHER_ROLE`. (See M-1 for the cross-role-grant concern at the AccessControl level.)

12. **`proposeSlash` per-operator concurrency cap** — `_operatorActiveSlashProposals[operator] >= maxPendingSlashesPerOperator` check at `Slashing.sol:93` is correctly `>=` (rejects at the cap, not above it) and the counter is bumped only after the cap check succeeds. (See M-3 for the auto-fail accounting concern.)

## Method

- Branch: `chore/audit-dos-access-2026-05-16` forked from `chore/audit-economic-oracle-2026-05-16`.
- Read-only static analysis. No source modifications, no test runs.
- Enumerated every `external` state-mutating function in `src/core/` (and the diamond facets that expose them via `selectors()`).
- Catalogued every `for (` loop in `src/core/` (84 loops) and traced their bound to a protocol constant or to user-supplied calldata.
- Catalogued every `IBlueprintServiceManager` call site (29 total) and verified whether the call site enforces an explicit `gas: MANAGER_HOOK_GAS_LIMIT` cap. Found that all 4 paths going through `_callManager` / `_tryCallManager` / explicit `staticcall` enforce the cap, and all `try IBlueprintServiceManager(...)` callsites (13 total) do not.
- Audited `onlyRole`, `whenNotPaused`, `nonReentrant` coverage across 50+ external mutators.
- Verified signature surfaces: EIP-712 quote (`SignatureLib`), BLS PoP (`AttestationLib` + `BN254.verifyBls`), TEE attestation nonce (`AttestationLib.teeNonce`).
- Verified initializer disabling and admin handoff comments across upgradeable implementations.
