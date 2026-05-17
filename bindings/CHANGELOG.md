# Changelog

All notable changes to `tnt-core-bindings` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.17.1] - 2026-05-17

### Changed

- Updated bindings from TNT Core contracts

## [0.17.0] - 2026-05-15

Quote-path security hardening, multi-asset bill weighting, EIP-170 facet split,
O(1) staking aggregates, share-pool validator slashing, and griefing-resilient
reward sweep. Diamond ABI from the proxy's perspective is unchanged — every
external selector still routes to `Tangle`. The only binding-level surface
addition is one new diamond self-call on `ITanglePaymentsInternal`. Most of
the behavioral changes are observable to indexers via events that live on the
facet contracts (`Payments*`, `ValidatorPodManager`); those event ABIs are
not surfaced through the `ITangle*` interfaces and therefore are not present
in the generated bindings. Indexer consumers should decode them by topic
hash against the facet source ABIs (see below).

### Added (binding surface)

- `ITanglePaymentsInternal.distributeBillWithKeeper((uint64,uint64,address,uint256,address[],uint256[],uint256,bool,address))`
  selector `0x68cdf660`. Diamond self-call used by `billSubscription` to
  hand the per-operator weights computed during accrual directly to the
  distribution facet, so the keeper rebate and per-asset stake-time
  weighting agree across the bill and the distribute steps.
- `ITanglePaymentsInternal.BillDistribution` struct exposing the
  self-call payload shape: `serviceId`, `blueprintId`, `token`, `amount`,
  `operators`, `weights`, `totalWeight`, `hasSecurityCommitments`,
  `keeper`.

### Behavior changes (no binding ABI delta; same selectors, new semantics)

- RFQ quote redemption is now requester-bound, freshness-checked, and
  cumulative-TTL-capped. Job RFQ now verifies `msg.sender` against the
  quote's signed `requester` (reverts `JobQuoteRequesterMismatch`,
  including for wildcard `address(0)`). Service-creation quotes enforce
  `block.timestamp <= details.timestamp + maxQuoteAge` and revert
  `QuoteTimestampStale`. `extendServiceFromQuotes` rejects extensions
  whose cumulative TTL exceeds `MAX_SERVICE_TTL` with
  `CumulativeTtlExceeded`.
- Subscription bills weight by `Σ_op Σ_asset
  (cumStakeSeconds_delta × commitmentBps × price)` across every asset the
  service requires, replacing the bond-asset-only TWAP. TWAP cursors are
  keyed `(serviceId, operator, assetHash)`. Services without per-asset
  commitments fall back to the bond asset at the operator's overall
  `exposureBps` (legacy semantics).
- `claimRewardsAll` is griefing-resilient. A single token whose `transfer`
  reverts no longer poisons the entire sweep — it is skipped via a
  self-call try/catch path, `RewardsClaimSkipped(account, token)` is
  emitted on the facet, the remaining tokens are claimed, and the
  griefing token stays in the pending set for a future retry. Single-token
  claim paths (`claimRewards()`, `claimRewards(token)`, `claimRewardsBatch`)
  are unchanged and still revert on failure so the explicit caller sees
  the underlying error.
- `ValidatorPodManager._slash(operator, slashBps)` is now O(1) regardless
  of delegator count. Each operator owns a `DelegationPool {
  totalAssets, totalShares }` with virtual-share inflation defenses;
  delegator balances are derived on read from
  `shares × totalAssets / totalShares`. The per-delegator `DelegatorSlashed`
  emission loop is replaced by a single
  `OperatorPoolSlashed(operator, slashAmount, newTotalAssets, totalShares)`
  event on the facet; indexers reconstruct per-delegator impact off-chain
  from share balances + this event.
- `_getOperatorDelegatedStakeForAsset` is now a single SLOAD. The running
  sum `_operatorDelegatedAggregate[operator][assetHash]` is updated at
  every pool-totalAssets mutation. Removes the per-blueprint loop that
  used to gas-bomb operators participating in many services and was
  exercised on every TWAP accrual.

### Storage layout (no slot reordering)

- `DelegationStorage.__gap` decreased 44 → 43 to make room for
  `_operatorDelegatedAggregate`. All pre-existing slots preserved.
- `ValidatorPodManager` appends `_operatorDelegationPools` and
  `_delegationShares` after the existing layout. No existing slot
  reordered.

### Facet split (no diamond-ABI delta)

- `TanglePaymentsFacet`, `TangleServicesFacet`, and
  `TanglePaymentsDistributionFacet` each fit under the EIP-170 24,576-byte
  runtime ceiling now (24,160 / 21,741 / 18,144). `Payments` was split into
  `PaymentsCore` / `PaymentsEscrow` / `PaymentsBilling` /
  `PaymentsDistribution` / `PaymentsRewards`; pure validation helpers moved
  to `ServiceValidationLib` (linked at deploy time, ~3.8 KB). Same selectors,
  routed to different physical facet contracts.

### Facet-only events (decode against source ABIs, not bound here)

Emitted from `Payments*` and `ValidatorPodManager` facets. Not surfaced
on `ITangle` / `ITangleFull` — indexers should decode by topic hash from
the facet source ABIs:

- `OperatorPoolSlashed(address operator, uint256 slashAmount, uint256 newTotalAssets, uint256 totalShares)`
- `RewardsClaimSkipped(address account, address token)`
- `KeeperRebateAccrued(uint64 serviceId, address keeper, address token, uint256 amount)`
- `TntPaymentDiscountApplied(uint64 serviceId, address recipient, address token, uint256 amount)`
- `StakerShareRefundedToEscrow(uint64 serviceId, address operator, address token, uint256 amount, bytes reason)`
- `SubscriptionBaselineInitialized(uint64 serviceId, uint256 baselineStake, uint256 operatorCount)`
- `SubscriptionBillSkippedNoOperators(uint64 serviceId, uint64 period)`
- `SubscriptionBillAdjustedByManager(uint64 serviceId, uint256 preAdjustmentAmount, uint256 adjustedAmount, uint16 adjustmentBps)`

### Errors

- New: `JobQuoteRequesterMismatch`, `QuoteTimestampStale`,
  `CumulativeTtlExceeded`.

## [0.16.0] - 2026-05-11

Subscription billing rearchitecture. Substantive contract behavior changes for
any consumer that calls `billSubscription` / `billSubscriptionBatch`, reads the
subscription billing events, or implements `IBlueprintServiceManager`.

### Changed (BREAKING)

- `Types.PaymentSplit` gained a fifth field `keeperBps`. `setPaymentSplit` now
  requires the five-field sum equal 10_000. `paymentSplit()` view returns a
  5-tuple (was 4-tuple). Default split shifts from 20/20/40/20 to
  19.5/20/40/20/0.5 — the keeper share is paid to the caller of permissionless
  subscription bills, incentivising any wallet/bot to keep the schedule running.
  On non-subscription distributions (PayOnce, RFQ, per-job) the keeper share
  folds back into the operator pool so totals still sum to 10_000.
- `Tangle.billSubscription(uint64)` semantics:
  - Bill amount is now bounded above by the blueprint's nominal rate. Operators
    ramping stake mid-period cannot inflate the customer's bill (kills both
    customer-overpayment surprise AND the bill-exceeds-rate livelock window).
  - Operator payout shares are weighted by per-operator cum-stake-seconds delta
    × exposureBps (same TWAP cursors that drive bill amount). An operator who
    ramps stake earns a larger slice of the SAME (capped) pool.
  - Bills that round to dust (after QoS adjustment) skip cleanly rather than
    reverting in the distribute path. A manager hook returning a tiny `qosBps`
    cannot brick a service.
  - Zero active operators advances the cursor with no escrow movement and
    emits `SubscriptionBillSkippedNoOperators`.
  - Insufficient escrow rewinds the cursor; `terminateServiceForNonPayment`
    remains the canonical recovery path.
- `IBlueprintServiceManager.computeBillAdjustmentBps(serviceId, periodStart,
  periodEnd) returns (uint16)`: new optional hook called via gas-capped
  `staticcall` and clamped to `[0, 10_000]` (manager can discount, never
  inflate). `BlueprintServiceManagerBase` ships a default returning `10_000`.
- `IBlueprintServiceManager.queryDeveloperPaymentAddress` is also called via
  gas-capped `staticcall` now — manager hooks cannot drain a keeper's gas.
- `Tangle.requestService` and the quote-create flow reject EventDriven requests
  with non-zero `paymentAmount` at request time. Reverts with
  `UpfrontPaymentNotAllowedForEventDriven` before any ETH is collected.
- Subscription baseline (`subscriptionBaselineStake`) is seeded at service
  activation, both for the request/approve flow and the quote-create flow.
  First-bill lazy-init was removed; bills against an unbaselined service revert
  with `SubscriptionBaselineNotInitialized`.
- `_forwardStakerShare`: when the fee distributor is unset OR reverts, the
  staker share is refunded to the service escrow (native) or surfaced via
  `StakerShareRefundedToEscrow` with the revert reason (ERC20). Previously
  silently routed to the treasury.
- `PaymentLib.twapBillAmount` reverts with `BillingArithmeticOverflow` on
  product overflow; previously returned `nominalRate` silently.
- `PaymentSplitUpdated` event signature extended with `keeperBps`.

### Added

- Events: `SubscriptionBillSkippedNoOperators`, `SubscriptionBillAdjustedByManager`,
  `KeeperRebateAccrued`, `StakerShareRefundedToEscrow`,
  `SubscriptionBaselineInitialized`.
- `PaymentLib.twapBillAmount`, `applyQosAdjustment`, `minBillAmount` pure
  helpers exposed for downstream off-chain consumers and fuzz tests.
- Errors: `BillingArithmeticOverflow`, `SubscriptionBaselineNotInitialized`,
  `UpfrontPaymentNotAllowedForEventDriven`.

### Removed

- `PaymentLib.calculateOperatorPayments`, `validatePaymentAmount`,
  `bpsShareRoundUp`, `divUp` — superseded by inline per-weight distribution.

## [0.15.0] - 2026-05-09

Round 4 audit consolidation: C-3 (UUPS upgradeable cross-chain slashing
receivers), F5 (TWAP-fair subscription billing), G-02 (share-pool
ValidatorPodManager). Single coordinated bindings cut.

### Changed (BREAKING)

- Round 4 C-3: `L2SlashingReceiver` and the four bridge-adapter receivers
  (`ArbitrumL2Receiver`, `BaseL2Receiver`, `HyperlaneReceiver`,
  `LayerZeroReceiver`) are now UUPS upgradeable. The deploy interface is changed
  from a plain `new Contract(...)` to a proxy + `initialize(...)` pair, and the
  initializer now requires an explicit `_owner` argument (previously implicit
  `msg.sender`). Mutable state has been moved to ERC-7201 namespaced slots
  under `tangle.beacon.L2SlashingReceiver` and
  `tangle.beacon.bridges.{Arbitrum,Base,Hyperlane,LayerZero}*Receiver`. Owner-
  gated functions revert with `OwnableUnauthorizedAccount(account)` instead of
  `"Only owner"`. The `transferOwnership` selector now reverts on
  `address(0)` with `OwnableInvalidOwner` instead of `"Zero address"`. There is
  no in-place storage migration path; existing deployments must be redeployed
  behind a fresh proxy and re-authorised.
- Round 4 F5: `Tangle.billSubscription(uint64)` now bills the TWAP-fair amount
  derived from cumulative stake-seconds instead of a flat `subscriptionRate`.
  The previous billing path priced the period at the operator's stake at the
  bill instant, which let an operator ramp stake immediately before billing and
  dump it after — overcharging customers when stake ramped down mid-period and
  undercharging when it ramped up. Billing now uses
  `rate × cumDelta / (baseline × interval)` where `cumDelta` is summed
  PER-OPERATOR (not aggregated) across the service's active operators for the
  bond asset, and `baseline` is captured at the first bill (lazy init) and
  frozen for the life of the subscription. Per-operator cursors live in
  `TangleStorage._twapCursorByOp` and are re-seeded by
  `ServicesLifecycle._finalizeJoin` so a mid-life joiner is not retroactively
  billed for their pre-join cum activity (rejoin-safe).
- Round 4 F5: `IStaking` gained `getCumStakeSeconds(operator, asset)`,
  exposed via `IMultiAssetDelegation` for Rust callers. Implementations must
  fold elapsed time × current stake into the running counter on every
  stake-changing path. The in-tree `MultiAssetDelegation` ships the working
  implementation; `ValidatorPodManager` ships a zero stub (subscription
  billing is not currently routed through beacon-only services).
- Round 4 F5: `PaymentLib.ServiceEscrow` gained `subscriptionBaselineStake`
  appended at the end of the struct. A second slot (now reserved with sentinel
  zero) was added in the initial F5 commit and retired in the F5 followup; the
  slot layout is stable for the v0.15.0 release. Existing storage slots are
  preserved; pre-upgrade subscriptions are lazy-initialized on the first
  post-upgrade `billSubscription` call (no migration required).
- Round 4 G-02: `ValidatorPodManager` refactored to per-pod share-pool
  accounting (`BeaconPool { totalAssets, totalShares }`) consistent with
  `MultiAssetDelegation` and `LiquidDelegationVault`. Beacon rebases now move
  `totalAssets` only — `shares` are invariant. Slashes remain isolated to the
  affected pod. The legacy
  `recordBeaconChainEthBalanceUpdate(address, int256)` entry point has been
  REPLACED by two explicit methods: `recordBeaconChainDeposit(address, uint256)`
  (mints shares for new principal) and
  `recordBeaconChainRebase(address, int256)` (moves `totalAssets` only).
  Call sites must migrate; there is no back-compat shim. `getShares(address)`
  retains its pre-G-02 `int256` ABI (cast lossless from the new `uint256`
  storage); a companion `getSharesUint(address)` returns the raw unsigned
  value for callers that prefer it. `totalShares()` is now a function
  returning `uint256` (was a public `int256` state variable). Withdrawal
  queue snapshots `convertToAssets(shares)` at queue time and pays out
  `min(snapshot, live)` at completion. The contract is not upgradeable;
  existing deployments must be redeployed fresh (no in-place migration path).

### Added

- Round 4 G-02: `ValidatorPodManager` views `convertToShares`,
  `convertToAssets`, `totalAssetsOf`, `totalSharesOf`, `getRestakedAssets`,
  `getSharesUint` for share-pool introspection.

### Fixed

- Pre-existing test bug in `LiveBeaconTest.test_validatorFieldsExtraction`
  where SSZ-encoded uint64 fields were stored big-endian, causing
  `BeaconChainProofs._fromLittleEndianUint64` to read zero. Test now encodes
  the leftmost-8-bytes little-endian convention SSZ actually uses. (Tracked
  in #130; resolved here as part of the consolidation.)

## [0.14.0] - 2026-05-08

### Changed (BREAKING)

- `TangleToken.burn(uint256)` and `burnFrom(address,uint256)` now revert. Round 2
  governance auditor #5: unrestricted ERC20 burn allowed any holder to lower
  `getPastTotalSupply()` before a governance snapshot, deflating quorum and
  letting low-stake proposals pass. There is no protocol use case for users
  burning their TNT (inflation is governance-controlled via InflationPool).
  Anyone calling `burn` / `burnFrom` will revert with `BurnDisabled()`.
- `TangleGovernor.MAX_PROPOSAL_ACTIONS` lowered from 50 to 10. `MAX_ACTION_VALUE`
  lowered from 100k ETH to 10k ETH per action. Round 2 governance #8: 50
  actions × 100k ETH was a vast surface area that let a malicious proposer
  bury a privileged call (`grantRole`, etc.) in action #50 of 50 where UI
  tooling may truncate / skim. Real legitimate proposals touch ≤ 5 targets.
- Quote payment ingress (`PaymentLib.collectPayment`) and direct ERC20 deposits
  (`DepositManager._handleErc20Deposit`) now reject fee-on-transfer / rebasing
  tokens via balance-delta check at the boundary. Round 2 economic auditor F6.

### Added

- `Tangle.claimDisputeBond()` and `Tangle.pendingDisputeBondRefund(address)`.
  Round 2 economic auditor F3: `cancelSlash` now credits the bond into a
  pull-pattern mapping rather than pushing back to the disputer's wallet.
  Closed the re-entrancy window where a contract-disputer could re-enter the
  staking module on bond refund and exit at the pre-slash exchange rate. The
  disputer must explicitly call `claimDisputeBond()` to drain their credited
  bond. Pending balance is queryable via `pendingDisputeBondRefund(disputer)`.
- `ArbitrumCrossChainMessenger.setL2RefundAddress(address)`. Round 2
  cross-chain auditor H-1: excess-fee and call-value refunds from
  `createRetryableTicket` were defaulting to the L1 caller's L2 alias —
  unrecoverable. Operators can now set a sweep address on L2 (own treasury,
  receiver itself, etc.) to capture refunds.
- New `__gap[50]` on five UUPS rewards contracts (`TangleMetrics`,
  `RewardVaults`, `InflationPool`, `ServiceFeeDistributor`,
  `StreamingPaymentManager`). Round 2 storage auditor F-3: missing upgrade
  buffer would have forced future field additions to risk slot collisions
  with newly-introduced parent classes.

### Fixed (security — Round 3 deferred from Round 2)

- **Slash-and-dispute reentrancy (F3)** — see `claimDisputeBond` above.
- **JobsAggregation snapshot binding (operator-collusion 2c)** — the BLS
  message now binds chain id, contract address, and a hash of the operator
  set in addition to `(serviceId, callId, output)`. A swap-and-pop reorder
  (operator leaves / forceRemove) now invalidates any in-flight aggregated
  signature instead of silently mis-crediting a different operator at the
  same bitmap index. Off-chain aggregators MUST update their message
  construction to:
  `abi.encode("TANGLE_BLS_AGG_v1", chainId, address(tangle), serviceId, callId, keccak256(abi.encode(operators)), keccak256(output))`.
- **First-depositor inflation defense on RebasingAssetAdapter (F2)** —
  virtual share/asset offset (`VIRTUAL_SHARES = 1e8`, `VIRTUAL_ASSETS = 1`)
  applied to deposit and withdraw share-price math. Mirrors the staking-pool
  defense.
- **Beacon-slash hook design** (cross-chain H-5) — documented intentional
  decision to NOT iterate the operator's blueprint list on
  `TangleL2Slasher.slashOperator`. Liquid-staking BSMs that need to react
  must subscribe to `BeaconSlashExecuted` off-chain. On-chain enumeration
  would be O(N) gas-DoS.
- **ServiceFeeDistributor reentrancy review** (Slither finding) —
  `_claimAllForToken` flagged as state-after-external-call inside loop, but
  every reaching entry point (`claimFor` / `claimAll` / `claimAllBatch`) is
  `nonReentrant`. Documented as non-exploitable.

### Tests

- New `test/security/StorageLayoutSnapshotTest.t.sol` pins critical storage
  slot positions for `Tangle` and verifies the OZ ERC-7201 namespaced slots
  (`Initializable`, `AccessControl`, `ReentrancyGuard`) match the v5.1.0
  values. Round 2 storage auditor F-1 / F-2 flagged upgrade-time field-
  reorder risks; this test catches drift in CI.

## [0.13.0] - 2026-05-08

### Changed (BREAKING)

- `JobQuoteDetails` now includes `address requester` as the first field, mirroring
  the v0.12.0 fix on `QuoteDetails`. The per-job RFQ quote was previously not
  bound to a consumer at the EIP-712 typehash level, so any `_permittedCaller`
  (or anyone watching the mempool) could lift another caller's signed quote
  digest and consume it for themselves. Off-chain signers MUST add `requester`
  to the `JobQuoteDetails` typed data; the new typehash string is:
  `"JobQuoteDetails(address requester,uint64 serviceId,uint8 jobIndex,uint256 price,uint64 timestamp,uint64 expiry,uint8 confidentiality)"`
- `verifyQuoteBatch` now rejects wildcard `requester == address(0)` quotes
  outright. Any operator software that previously emitted wildcard quotes will
  fail and must issue per-caller quotes (or batch them via `permittedCallers`
  at request time).
- `Types.ServiceRequest.activated` field moved to the END of the struct so a
  hypothetical upgrade from a pre-`activated` storage layout cannot
  accidentally read a non-zero byte from a different field as
  `activated == true`.

### Fixed (security — Round 2)

- **Beacon SSZ endianness (B-01, mainnet blocker)**:
  `BeaconChainProofs.getEffectiveBalanceGwei`, `getActivationEpoch`,
  `getExitEpoch`, `getWithdrawableEpoch`, and `_extractBalanceFromLeaf` now
  perform the correct little-endian byte-swap on SSZ-packed uint64 fields.
  Previously they read the LOW 64 bits of a `bytes32` chunk while the
  consensus layer packs values into the HIGH 8 bytes of the chunk in
  little-endian. Real EigenPod proofs would silently mis-account every
  uint64 field — every effective balance, exit epoch, and validator
  balance would be returned as 0 (or a byte-swapped wrong value). Tests
  passed because the in-tree fixtures mirrored the same wrong packing;
  fixtures are now SSZ-correct and there's a regression test pinning the
  canonical 32-ETH leaf.
- **Slash dispute dead-zone (Round 2 economic-MEV F4)**: `disputeSlash`'s
  window now extends through `executeAfter + TIMESTAMP_BUFFER`, mirroring
  `isExecutable`. The previous asymmetry created a deterministic 15-second
  window where a sequencer could land an operator's dispute tx (revert,
  `DisputeWindowPassed`) and then 15s later anyone could call
  `executeSlash` (now eligible). Operator dispute and execute both now use
  the same buffer.
- **SLASH_ADMIN self-dispute (Round 2 governance #4)**: a SLASH_ADMIN that
  is also the proposer of a slash can no longer self-dispute their own
  slash. Without this, a single role-holder could propose, immediately
  self-dispute (no bond), and freeze operator stake for the full
  `disputeResolutionDeadline` window AND (when treasury == admin) capture
  the operator's bond on auto-execution.
- **L2 slash CEI (Round 1 deferred S-1)**: `L2SlashingReceiver` now
  applies the slash BEFORE consuming the nonce. If `canSlash` returns
  false (paused, unknown operator, etc.) or `slashBps == 0`, the call
  reverts so the bridge keeps the message available for retry. Previously
  the nonce was consumed first and the slash silently dropped on transient
  failure, locking that slash out forever.
- **L2 setMessenger / setSlasher timelock (Round 2 cross-chain C-2)**: both
  swaps now require `SENDER_ACTIVATION_DELAY` (2 days) for non-bootstrap
  changes. Without this, a compromised owner could hot-swap to a messenger
  they control and immediately impersonate any previously-authorised
  sender, undercutting the H-4 timelock on `authorizedSenders`. The first
  swap (when current is unset) is a bootstrap exemption so deploy scripts
  can wire the bridge without a 2-day deadlock.
- **TNTLockFactory delegate-on-init airdrop capture (Round 2 governance
  #1, CRITICAL)**: `getOrCreateLock` now requires `msg.sender ==
  beneficiary`. Without this gate, a third party could front-run the
  victim's first interaction with a lock, supply themselves as
  `delegatee`, and persistently capture the victim's voting power for
  every future inbound TNT transfer to the deterministic lock address.
- **MBSM grace-period pinning (Round 1 deferred gov H-3)**:
  `MBSMRegistry.pinBlueprint` rejects revisions that are already
  scheduled for deprecation. Pinning during the grace window meant
  `getMBSM` returned `address(0)` the moment `completeDeprecation` ran,
  breaking every BSM call for the pinned blueprint.
- **forceRemoveOperator min-operators floor (Round 2 operator-collusion
  #7)**: a blueprint manager can no longer evict honest operators below
  `minOperators` unless their BSM explicitly opts in via the new
  `forceRemoveAllowsBelowMin(serviceId)` hook. The previous unconditional
  bypass let a malicious BSM bias the operator set toward sybils.

### Added

- `IBlueprintServiceManager.forceRemoveAllowsBelowMin(uint64) -> bool`
  hook. Default implementation in `BlueprintServiceManagerBase` returns
  `false`, enforcing the protocol-level minimum.
- `L2SlashingReceiver.activateMessenger()` / `activateSlasher()` for
  consuming queued swaps after the timelock elapses.
- `L2SlashingReceiver.SlashingNotPossible(address operator)` error,
  emitted when a slash arrives for an operator the slasher cannot act on.

## [0.12.0] - 2026-05-08

### Changed (BREAKING)

- `QuoteDetails` EIP-712 typehash now includes `address requester` as the first
  field. Previously `requester` lived on the struct but was excluded from the
  typehash, so an attacker who observed a signed quote in the mempool could
  flip `details.requester` to themselves and the operator's signature still
  recovered correctly — the binding check at the protocol layer was therefore
  cosmetic. Off-chain signers MUST now hash `requester` as the first member of
  `QuoteDetails`. Existing pre-fix signatures are invalid against the new
  typehash. The full updated string is:
  `"QuoteDetails(address requester,uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,uint8 confidentiality,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)"`
- `ITangleSlashing` event declarations realigned with what the protocol
  actually emits from `SlashingLib`: `SlashProposed` is now 8 fields (was 4),
  `SlashExecuted` is now 4 fields (was 3), and the previously-missing
  `SlashDisputed`, `SlashCancelled`, `SlashConfigUpdated` events are now
  declared. Rust consumers wired to `ITangleSlashing` could not decode any
  emitted slash event before this fix; they can now.

### Added

- Permissionless `expireServiceRequest(uint64)` is wired to the proxy. The
  declaration shipped in 0.11.2 but the corresponding selector was never
  registered on `TangleServicesFacet.selectors()`, so calls routed through the
  unknown-selector fallback. Off-chain callers can now reach the function via
  the canonical `ITangleServices` ABI.

### Fixed (security)

- `proposeSlash` and `disputeSlash` now carry `nonReentrant`; only `executeSlash`,
  `executeSlashBatch`, and `cancelSlash` were guarded before. `proposeSlash`
  also rejects `bytes32(0)` evidence so off-chain monitors keying off non-zero
  evidence don't see silently-zero entries.
- Disputed slashes now apply the same 15-second `TIMESTAMP_BUFFER` as Pending
  slashes. Previously a sequencer / proposer with timestamp influence could
  sandwich the dispute deadline tick; the operator had no symmetric protection.
- `approveService` now rejects requests past the expiry grace window — operators
  could otherwise race `expireServiceRequest` and quietly activate a stale
  request the requester thought they could clean up.
- `requestService*` now rejects duplicate operator entries. With duplicates,
  `req.operatorCount` exceeds the unique approver count, so
  `approvalCount == operatorCount` was unreachable and the request could only
  be cleaned up via `expireServiceRequest`.
- `terminateService` and `terminateServiceForNonPayment` now carry
  `nonReentrant`. State writes already preceded external calls (CEI), but
  defense-in-depth aligns these entrypoints with the rest of the lifecycle.
- All operator-exit entrypoints (`scheduleExit`, `executeExit`, `forceExit`,
  `leaveService`, `forceRemoveOperator`) now reject when the service is no
  longer Active. Previously a stale operator could continue to fire exit paths
  on a Terminated service, double-decrementing counts and emitting
  `OperatorLeftService` for a dead service.
- `_distributePaymentWithEffectiveExposure` now reverts (instead of silently
  retaining funds) when there are zero active operators at billing time. The
  developer/treasury split would still pay out while the operator+staker pool
  (default 60%) remained stuck in the contract with no path back. Service
  owners who lose all operators can recover escrow via `terminateService` →
  `withdrawRemainingEscrow`.
- `fundService`, `billSubscription`, and `billSubscriptionBatch` now respect
  the global pause. Reward / refund claim paths remain unguarded so users can
  always exit.
- `OperatorStatusRegistry.registerOperator` now resets all per-(serviceId,
  operator) heartbeat / metrics state on (re-)register. Without this, an
  operator who deregistered carried stale heartbeat data forward — and
  `isHeartbeatCurrent` could return true before any new heartbeat landed.
- `LiquidDelegationVault.requestRedeem` rejects `controller == address(0)` so
  filing a request under that controller no longer permanently locks the
  redeemer's burned shares.

### Removed

- Deleted unused `src/exposure/` module (`ExposureManager`, `ExposureCalculator`,
  `ExposureTypes`, `IExposureManager`) and its self-contained `test/exposure/`
  suite. The actual exposure logic lives in `src/core/PaymentsEffectiveExposure.sol`
  and is exercised by `test/payments/`. The orphan module was an audit-burden
  divergence risk for the same bps math.
- Deleted `src/interfaces/IStreamingPaymentAdapter.sol` (also defining
  `ISuperfluidAdapter`, `ISablierAdapter`, `IPaymentAdapterRegistry`). None of
  these interfaces are implemented or referenced anywhere; only
  `IStreamingPaymentManager` is wired in.

## [0.11.3] - 2026-05-06

### Changed

- Updated bindings from TNT Core contracts

## [0.11.2] - 2026-05-05

### Added

- `ITangleServices.expireServiceRequest(uint64)` — declared on the public
  interface so the permissionless cleanup path is reachable via the standard
  ABI. The implementation already existed on `ServicesApprovals`; the
  declaration was missing, so off-chain consumers could not invoke it through
  the canonical interface.

## [0.11.1] - 2026-05-05

### Fixed

- `approveService` correctness: the TEE root SSTORE is now gated on
  `p.teeCommitments.length > 0` directly, not on `keccak256(...) != bytes32(0)`.
  The prior gate relied on cryptographic happenstance (any empty hash being
  non-zero) instead of input shape, which is the property we actually mean.
- `approveService` manager-hook fidelity: when an operator approves a request
  with the protocol-default TNT requirement and supplies no explicit
  commitments, the contract auto-fills at the requirement's `minExposureBps`.
  The `IBlueprintServiceManager.onApprove` hook now receives the value that
  was actually committed (`minExposureBps / 100`), not the prior `100`
  fallback. New tests in `ServicesApprovalTest` (`test_managerStakingPercent_*`)
  pin this behavior.

### Notes

- Storage layout: `_serviceTeeCommitments` mapping (legacy
  `TeeAttestationCommitment[]` value) was retired in 0.11.0 in favor of
  `_serviceTeeCommitmentRoot` (`bytes32` value). Same head-slot count, different
  shape at keyed slots — safe for greenfield deploys; live-proxy upgrades would
  require explicit migration of orphaned data, which is N/A pre-mainnet.
- Rust API: `TangleClient::approve_service(request_id)` lost its
  `restaking_percent: u8` parameter at 0.11.0 because the contract derives the
  effective exposure on-chain. Direct callers of the convenience method on
  `tangle-tools-clients-tangle` must drop the second argument; the unified
  builder `approve_service_with_params(ApprovalParams)` is also available.

## [0.11.0] - 2026-05-05

### Changed (BREAKING)

- Unified `approveService` entrypoint replaces five `approveServiceWith*` variants
  (tnt-core PR #119). The new ABI takes a single `Types.ApprovalParams` tuple
  carrying `requestId`, `securityCommitments`, `blsPubkey`, `blsPopSignature`,
  `teeCommitments`. Empty / zero fields opt out of the corresponding capability.
- TEE commitment storage moves from `TeeAttestationCommitment[]` arrays to a
  single keccak256 root per `(serviceId, operator)`. The `getTeeCommitment` view
  is replaced by `getTeeCommitmentRoot(serviceId, operator) -> bytes32`. Slashers
  / provisioning oracles supply the original commitment array as a witness and
  verify keccak match against the on-chain root.
- New event `TeeCommitmentsRecorded(requestId, operator, root, commitments)`
  emits the full commitment array for indexer reconstruction.
- Selector list on `TangleServicesFacet` shrinks from 10 → 6.

### Added

- `Types.ApprovalParams` struct exposed via the generated bindings.
- `teeNonceFor(uint64 requestId) -> bytes32` view: canonical
  `keccak256(abi.encode("tangle.tee.nonce", requestId, address(this), block.chainid))`
  that operators MUST set as `TeeAttestationCommitment.nonceBinding`.

## [0.10.9] - 2026-04-23

### Changed

- Updated bindings from TNT Core contracts

## [0.10.8] - 2026-04-19

### Changed

- Updated bindings from TNT Core contracts

## [0.10.7] - 2026-04-08

### Changed

- Updated bindings for the confidentiality field added to job quote EIP-712 signatures

## [0.10.6] - 2026-03-26

### Changed

- Updated bindings from TNT Core contracts

## [0.10.4] - 2026-02-24

### Changed

- Updated bindings from TNT Core contracts

## [0.10.3] - 2026-02-21

### Changed

- Updated bindings from TNT Core contracts

## [0.10.2] - 2026-02-18

### Changed

- Updated bindings from TNT Core contracts

## [0.10.0] - 2026-02-11

### Changed

- Updated bindings from TNT Core contracts

## [0.9.0] - 2026-02-09

### Changed

- Updated bindings from TNT Core contracts

## [0.8.2] - 2026-01-29

### Changed

- Updated bindings from TNT Core contracts

## [0.8.0] - 2026-01-29

### Changed

- Updated bindings from TNT Core contracts

## [0.7.3] - 2026-01-23

### Changed

- Updated bindings from TNT Core contracts

## [0.7.2] - 2026-01-23

### Changed

- Updated bindings from TNT Core contracts

## [0.7.0] - 2026-01-21

### Changed

- **BREAKING**: Normalized interface names to `IStaking`
- **BREAKING**: Normalized module naming to `staking`
- **BREAKING**: Normalized `PaymentSplit` staking weight field naming
- Updated all bindings from TNT Core contracts with canonical staking terminology

## [0.6.1] - 2026-01-17

### Changed

- Updated bindings from TNT Core contracts

## [0.6.0] - 2026-01-17

### Changed

- Updated bindings from TNT Core contracts

## [0.5.6] - 2026-01-16

### Changed

- Updated bindings from TNT Core contracts

## [0.5.5] - 2026-01-15

### Changed

- Updated bindings from TNT Core contracts

## [0.5.4] - 2026-01-14

### Changed

- Updated bindings from TNT Core contracts

## [0.5.3] - 2026-01-14

### Changed

- Updated bindings from TNT Core contracts

## [0.5.2] - 2026-01-12

### Changed

- Updated bindings from TNT Core contracts

## [0.5.1] - 2026-01-12

### Changed

- Updated bindings from TNT Core contracts

## [0.5.0] - 2025-12-31

### Changed

- Updated bindings from TNT Core contracts

## [0.4.10] - 2025-12-23

### Changed

- Updated bindings from TNT Core contracts

## [0.4.9] - 2025-12-23

### Changed

- Updated bindings from TNT Core contracts

## [0.4.8] - 2025-12-21

### Changed

- Updated bindings from TNT Core contracts

## [0.4.7] - 2025-12-21

### Changed

- Updated bindings from TNT Core contracts

## [0.4.6] - 2025-12-18

### Changed

- Updated bindings from TNT Core contracts

## [0.4.5] - 2025-12-17

### Changed

- Updated bindings from TNT Core contracts

## [0.4.4] - 2025-12-16

### Changed

- Updated bindings from TNT Core contracts

## [0.4.3] - 2025-12-15

### Changed

- Updated bindings from TNT Core contracts

## [0.4.2] - 2025-12-15

### Changed

- Updated bindings from TNT Core contracts

## [0.4.1] - 2025-12-15

### Changed

- Updated bindings from TNT Core contracts

## [0.4.0] - 2025-12-11

### Changed

- Updated bindings from TNT Core contracts

## [0.3.0] - 2025-12-10

### Changed

- Updated bindings from TNT Core contracts

## [0.2.0] - 2025-12-10

### Changed

- Updated bindings from TNT Core contracts

## [0.1.0] - 2024-12-10

### Added

- Initial release of TNT Core Rust bindings
- `ITangle` - Main Tangle protocol interface
- `ITangleBlueprints` - Blueprint registration and management
- `ITangleServices` - Service lifecycle management
- `ITangleJobs` - Job submission and results
- `ITangleOperators` - Operator registration and status
- `ITangleSlashing` - Slashing mechanism
- `ITangleRewards` - Reward distribution
- `MultiAssetDelegation` - Multi-asset staking and delegation
- `IBlueprintServiceManager` - Blueprint service manager interface
- `IOperatorStatusRegistry` - Operator status tracking
- Raw ABI JSON exports via `abi` module
- `TNT_CORE_VERSION` constant for commit tracking

[Unreleased]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.17.1...HEAD
[0.11.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.0...bindings-v0.11.1
[0.11.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.9...bindings-v0.11.0
[0.1.0]: https://github.com/tangle-network/tnt-core/releases/tag/bindings-v0.1.0
[0.4.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.0...bindings-v0.4.1
[0.4.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.1...bindings-v0.4.2
[0.4.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.2...bindings-v0.4.3
[0.4.4]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.3...bindings-v0.4.4
[0.4.5]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.4...bindings-v0.4.5
[0.4.6]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.5...bindings-v0.4.6
[0.4.7]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.6...bindings-v0.4.7
[0.4.8]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.7...bindings-v0.4.8
[0.4.9]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.8...bindings-v0.4.9
[0.4.10]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.9...bindings-v0.4.10
[0.5.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.10...bindings-v0.5.0
[0.5.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.0...bindings-v0.5.1
[0.5.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.1...bindings-v0.5.2
[0.5.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.2...bindings-v0.5.3
[0.5.4]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.3...bindings-v0.5.4
[0.5.5]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.4...bindings-v0.5.5
[0.5.6]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.5...bindings-v0.5.6
[0.6.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.6...bindings-v0.6.0
[0.6.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.6.0...bindings-v0.6.1
[0.7.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.6.1...bindings-v0.7.0
[0.7.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.7.1...bindings-v0.7.2
[0.7.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.7.2...bindings-v0.7.3
[0.8.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.7.3...bindings-v0.8.0
[0.8.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.8.0...bindings-v0.8.2
[0.9.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.8.2...bindings-v0.9.0
[0.10.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.9.0...bindings-v0.10.0
[0.10.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.0...bindings-v0.10.2
[0.10.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.2...bindings-v0.10.3
[0.10.4]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.3...bindings-v0.10.4
[0.10.7]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.6...bindings-v0.10.7
[0.10.6]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.4...bindings-v0.10.6
[0.10.8]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.7...bindings-v0.10.8
[0.10.9]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.8...bindings-v0.10.9
[0.11.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.1...bindings-v0.11.2
[0.11.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.2...bindings-v0.11.3
[0.16.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.15.0...bindings-v0.16.0
[0.17.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.16.0...bindings-v0.17.0
[0.17.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.17.0...bindings-v0.17.1
