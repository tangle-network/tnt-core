# Red-team audit: storage + UUPS — 2026-05-16

Scope: PRs #132 (subscription billing rearchitecture), #133 (payments facet split + RFQ
hardening + multi-asset bill weighting), #134 (O(1) operator stake aggregate + VPM
share-pool slashing), #136 (claimRewardsAll griefing isolation), #137 (bindings regen),
#138 (indexer events). Audit window: `8b2777b..HEAD` on `main`.

## Summary

| Severity | Count |
| --- | --- |
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFORMATIONAL | 3 |

No upgrade-safety regressions detected. One LOW finding on divergent upgrade-authority
role between `Base` and `MultiAssetDelegation`. Three informational notes on
storage-layout reinterpretation and non-proxy "legacy slot preservation" framing.

## Findings

### L-1 — `MultiAssetDelegation._authorizeUpgrade` is gated by `ADMIN_ROLE`, not `UPGRADER_ROLE`

- **Where:** `src/staking/MultiAssetDelegation.sol:116`
- **What:** `_authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) { }`.
  The contract never defines or grants a separate `UPGRADER_ROLE`. By contrast,
  `Base.sol:42,177,232` defines `UPGRADER_ROLE = keccak256("UPGRADER_ROLE")` and
  uses it for `_authorizeUpgrade`. `MBSMRegistry`, `TangleMetrics`,
  `ServiceFeeDistributor`, `RewardVaults`, `InflationPool`, and
  `StreamingPaymentManager` all follow the `Base` pattern.
- **Impact:** Whoever holds `ADMIN_ROLE` on MAD can both administer parameters
  (commission, asset config, adapter migration, slasher role grants) AND upgrade
  the implementation. There is no way to delegate upgrade authority to a separate
  multisig/timelock without also granting day-to-day admin power, which collapses
  the role-separation that `Base` is structured to enforce.
- **Reproducer:** Read `_authorizeUpgrade` on the deployed `MultiAssetDelegation`
  proxy and the role mask of `ADMIN_ROLE`. Compare to `Tangle.UPGRADER_ROLE`. Any
  account with `ADMIN_ROLE` can call `upgradeToAndCall(maliciousImpl, "")` directly.
- **Fix:** Mirror `Base`: declare `bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE")`;
  grant it in `initialize`; switch `_authorizeUpgrade` to `onlyRole(UPGRADER_ROLE)`.
  Storage-safe (no new slots; role data lives in
  `AccessControlUpgradeable`'s ERC-7201 storage). Existing deployments need a
  follow-up admin tx that grants `UPGRADER_ROLE` to the chosen upgrader before
  any subsequent upgrade.

### INFO-1 — Slot 77 in `TangleStorage` was retyped between #132 and #133 (`_twapCursorByOp` → `_twapCursorByOpAsset`)

- **Where:** `src/TangleStorage.sol:423` (`_twapCursorByOpAsset`).
- **What:** PR #132 introduced `mapping(uint64 => mapping(address => uint256)) _twapCursorByOp`
  at slot 77. PR #133 replaced the declaration with
  `mapping(uint64 => mapping(address => mapping(bytes32 => uint256))) _twapCursorByOpAsset`
  at the same slot. Mapping root slot is reused; data lives at hashed addresses
  so the value reads at any (svcId, op) key from the previous declaration are
  now orphaned (never read by the new code path).
- **Impact:** Production proxies that were already initialized under #132 and
  carry attribution data at the old layout would lose that data on upgrade to
  the #133 layout. Verified the only known live deployment manifest
  (`deployments/base-sepolia/latest.json`) is from `19887b5` (Tangle v0.10.9),
  which predates PR #132 — so no production proxy holds `_twapCursorByOp`
  data. No on-chain impact. Calling out so future deployments do not assume
  the slot's data type is stable.
- **Fix (if any prior deployment is later discovered):** Migration script must
  read the old slot and re-key the data via `_twapCursorByOpAsset[svcId][op][bondAssetHash]`
  before the first `billSubscription` call.

### INFO-2 — `ValidatorPodManager` "legacy slot preserved as placeholder" is defensive but inapplicable

- **Where:** `src/beacon/ValidatorPodManager.sol:33,99,104,116,119`.
- **What:** The contract is declared `contract ValidatorPodManager is IStaking, Ownable, ReentrancyGuard`
  with a `constructor(address, uint256)` (line 275). It is deployed directly by
  `script/DeployBeaconSlashing.s.sol:168` and `script/LocalTestnet.s.sol:972`
  with `new ValidatorPodManager(...)` — no proxy, no UUPS, no upgrade path. The
  comments labelling slots 12/13/15/16 as "legacy slot, retained for layout
  compatibility" therefore protect against an upgrade vector that does not exist.
- **Impact:** Zero. The placeholder slots cost one bytes32 each on every new
  pod-manager deployment and are never read by the live code. Consider this
  informational hygiene: either (a) document that VPM is intentionally
  non-upgradeable and remove the preservation comments, or (b) move VPM to a
  UUPS proxy if storage continuity across versions matters operationally.
- **Verification of layout claim:** Despite the upgrade path being absent, the
  layout *is* faithfully preserved: `forge inspect ValidatorPodManager storage-layout`
  shows the legacy mappings at the same indices they occupied at `8b2777b`
  (`delegations` → `_legacyDelegations` slot 12, `operatorDelegatedStake` →
  `_legacyOperatorDelegatedStake` slot 13, `_operatorDelegators` slot 15,
  `_isDelegator` slot 16). New share-pool state (`_operatorDelegationPools`,
  `_delegationShares`) is appended at slots 25–26. Public ABI is preserved via
  explicit `delegations(address,address)` and `operatorDelegatedStake(address)`
  view functions at L377/L384 of the new file.

### INFO-3 — `DelegationStorage` gap arithmetic verified

- **Where:** `src/staking/DelegationStorage.sol:491,495`.
- **What:** `_operatorDelegatedAggregate` was appended in PR #134 to back the
  O(1) `_getOperatorDelegatedStakeForAsset` lookup. The gap was reduced from 44
  to 43 to absorb the one-slot addition. Pre-existing TWAP cursor and
  `lastUpdate` slots (`_cumStakeSeconds`, `_cumStakeSecondsLastUpdate`) keep
  their indices. All other named slots above the gap retain their previous
  positions.
- **Impact:** Safe. Aggregate invariant
  `_operatorDelegatedAggregate[op][h] == _rewardPools[op][h].totalAssets + Σ_bp _blueprintPools[op][bp][h].totalAssets`
  is the only correctness contract that matters for upgrade — and it lives in
  contract logic, not storage layout.

## Clean checks

- **TangleStorage slot ordering.** `forge inspect Tangle storage-layout` confirms
  slot 0 (`_staking`) through slot 77 (`_twapCursorByOpAsset`) match the
  declaration order in `src/TangleStorage.sol`, including all packed sub-slots
  (`_treasury`+`_maxBlueprintsPerOperator` packed in slot 1;
  `_rewardVaults`+`_defaultTntMinExposureBps`+`_deprecatedTntStakerFeeBps`+`_tntPaymentDiscountBps`
  packed in slot 60; the four uint64 TTL fields packed in slot 66). Gap is
  `uint256[40]` at slot 78. OZ-Upgradeable parents (`Initializable`,
  `UUPSUpgradeable`, `PausableUpgradeable`, `ReentrancyGuardUpgradeable`,
  `AccessControlUpgradeable`) all use ERC-7201 namespaced storage in OZ v5 and
  therefore do not occupy contiguous slots — `_staking` correctly sits at slot 0.
- **Payments facet split storage shared via `Base`/`TangleStorage`.** Audited every
  new and modified mixin (`PaymentsCore`, `PaymentsEscrow`, `PaymentsBilling`,
  `PaymentsDistribution`, `PaymentsRewards`, `PaymentsEffectiveExposure`,
  `ServicesApprovalsViews`). None declares any state variable. Mixins that touch
  protocol state inherit `Base` (which inherits `TangleStorage`), so reads/writes
  resolve to the same shared slots used by the pre-split `Payments.sol`.
  `PaymentsEffectiveExposure` is the lone mixin that does *not* inherit `Base`
  (it only defines `internal virtual` hooks and `EXPOSURE_PRECISION`/`_BPS_DENOM`
  constants) so it cannot collide.
- **Facet storage sharing.** `TanglePaymentsFacet` inherits `PaymentsEscrow + PaymentsBilling`,
  `TanglePaymentsDistributionFacet` inherits `PaymentsDistribution`,
  `TanglePaymentsRewardsFacet` inherits `PaymentsRewards`,
  `TangleServicesViewsFacet` inherits `ServicesApprovalsViews`. Each is intended
  to be `delegatecall`-ed from `Tangle` via `FacetRouterBase._fallbackToFacet`,
  so their storage view is the proxy's storage — i.e. `TangleStorage`. None
  declares its own state; the only members are pure `selectors()` functions and
  pure dispatchers to the parent. No collision risk.
- **`_disableInitializers` + `initializer` modifier.** Verified across every
  UUPS contract: `Base` (152), `MultiAssetDelegation` (31),
  `MBSMRegistry` (90), `L2SlashingReceiver` (127), `TangleMetrics` (138),
  `ServiceFeeDistributor` (156), `RewardVaults` (195), `InflationPool` (243),
  `StreamingPaymentManager` (90), `TangleTimelock` (41), `TangleGovernor` (77),
  `TangleToken` (66). All `initialize` functions carry the `initializer` modifier.
  All constructors are tagged `@custom:oz-upgrades-unsafe-allow constructor`.
- **`__gap` declarations.** Enumerated all 12 occurrences:
  `TangleStorage` 40 (was 41 pre-#132, reduced by 1 for `_twapCursorByOp[Asset]`);
  `DelegationStorage` 43 (was 44 pre-#134, reduced by 1 for `_operatorDelegatedAggregate`);
  `MBSMRegistry` 50; rewards/ contracts all 50; cross-chain bridge namespaced
  structs each carry an internal `uint256[50] __gap`. No bridge changed in the
  audit window.
- **External library statelessness.** `AttestationLib`, `ServiceValidationLib`,
  `PaymentLib`, `SignatureLib`, `SlashingLib`, `SchemaLib` — all declared
  `library X` with only `internal constant` declarations (no state, no
  `external` functions on non-`internal` storage). Solc embeds calls to these
  libraries inline; no `delegatecall` storage hazard exists.
- **VPM legacy-slot preservation by inspection.** `forge inspect
  ValidatorPodManager storage-layout` (run under `FOUNDRY_PROFILE=local_build`)
  confirms slot 12 = `_legacyDelegations`, slot 13 = `_legacyOperatorDelegatedStake`,
  slot 15 = `_legacyOperatorDelegators`, slot 16 = `_legacyIsDelegator`,
  slot 25 = `_operatorDelegationPools`, slot 26 = `_delegationShares`. Matches
  the comments in source.
- **Upgrade authorization sweep.** Every `_authorizeUpgrade` in the tree gates
  on `onlyRole(UPGRADER_ROLE)` except `MultiAssetDelegation` (L-1 above) and
  `L2SlashingReceiver` (intentionally `onlyOwner` because it inherits
  `OwnableUpgradeable`, not `AccessControl`).

## Method

- `git log --oneline 8b2777b..HEAD -- src/` to enumerate in-scope file changes.
  Only `ValidatorPodManager.sol` (PR #134), `DelegationStorage.sol` (PR #134),
  `TangleStorage.sol` (PR #133), `Payments.sol` → split (PR #133),
  `core/Payments{Core,Escrow,Billing,Distribution,Rewards,EffectiveExposure}.sol`,
  `core/ServicesApprovals{,Views}.sol` were touched in this window.
- `grep -rn "uint256\[.*\] (private|internal) __gap" src/` to enumerate gaps.
- `grep -rn "_authorizeUpgrade\|UPGRADER_ROLE" src/` to confirm gating.
- `grep -rn "_disableInitializers" src/` to confirm constructor lock.
- `forge inspect Tangle storage-layout` and `forge inspect ValidatorPodManager
  storage-layout` (under `FOUNDRY_PROFILE=local_build`) to verify slot indices
  match the declarations.
- Cross-checked `deployments/base-sepolia/latest.json` to determine whether
  any reinterpreted slot (INFO-1) could affect a live proxy.
