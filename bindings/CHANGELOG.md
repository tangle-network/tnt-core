# Changelog

All notable changes to `tnt-core-bindings` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.3...HEAD
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
