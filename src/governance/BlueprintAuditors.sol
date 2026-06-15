// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import { Errors } from "../libraries/Errors.sol";

/// @title BlueprintAuditors
/// @notice Governance-curated registry of auditor identities and weights used by
///         off-chain aggregators when scoring binary-version attestations.
/// @dev Deliberately a standalone UUPS contract — NOT a Tangle facet — so that
///      governance owns the address list independently of protocol upgrades.
///      The protocol-side `BlueprintsBinaryAttestations` registry is permissionless;
///      this contract supplies the trusted weight map that aggregators apply on
///      top of those raw attestations.
///
///      Two admit paths exist:
///        - `admitAuditor` is gated by `GOVERNANCE_ROLE` (held by TangleTimelock)
///          and accepts any tier.
///        - `admitFirstPartyAuditor` is gated by `FIRST_PARTY_ADMIN_ROLE` (held
///          by a security council multisig) and is restricted to FIRST_PARTY
///          tier. It exists so the security council can fast-track first-party
///          team members without waiting on a governance vote.
///
///      Removal is a soft delete: `active=false` plus weight zeroed. The row
///      itself is preserved so historical references on-chain (e.g. attester
///      address inside an `Attestation` row) keep resolving to a real registry
///      entry, with `active=false` signalling that aggregators should ignore
///      new attestations from this address.
contract BlueprintAuditors is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    // ═══════════════════════════════════════════════════════════════════════════
    // ROLES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Role held by TangleTimelock. Authoritative path for admit/remove/weight
    ///         changes across all tiers and is the sole authorizer of contract upgrades.
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");

    /// @notice Role held by the security council multisig. Permits fast-tracked
    ///         admission of `FIRST_PARTY` auditors only; cannot mutate INDEPENDENT
    ///         or COMMUNITY entries and cannot authorize upgrades.
    bytes32 public constant FIRST_PARTY_ADMIN_ROLE = keccak256("FIRST_PARTY_ADMIN_ROLE");

    // ═══════════════════════════════════════════════════════════════════════════
    // TYPES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Tier classification for auditors. Append-only — values must never
    ///         be reordered to preserve storage compatibility.
    ///         FIRST_PARTY=0 (Tangle-team / vendor auditors with privileged trust),
    ///         INDEPENDENT=1 (recognized external firms, governance-admitted),
    ///         COMMUNITY=2 (open-source contributors with reputational standing).
    enum AuditorTier {
        FIRST_PARTY,
        INDEPENDENT,
        COMMUNITY
    }

    /// @notice On-chain auditor record. `admittedAt` is preserved across an
    ///         `active=false` removal so the registry's history is auditable.
    struct Auditor {
        string name;
        string metadataUri;
        uint16 weight; // 0..1000, see `MAX_AUDITOR_WEIGHT`
        AuditorTier tier;
        bool active;
        uint64 admittedAt;
    }

    /// @notice Hard ceiling on per-auditor weight. The 1000 cap (vs. 10000 bps)
    ///         is intentional: aggregators normalize by the sum of active weights
    ///         off-chain, so any single auditor's influence is capped at
    ///         `weight / sum(weights)`. The cap removes the foot-gun of
    ///         accidentally admitting a weight that swamps every other voice.
    uint16 public constant MAX_AUDITOR_WEIGHT = 1000;

    // ═══════════════════════════════════════════════════════════════════════════
    // STORAGE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Address => auditor record. Soft-deleted entries remain queryable.
    mapping(address => Auditor) public auditors;

    /// @dev Enumeration list. Append-only — entries removed via `removeAuditor`
    ///      stay here so historical indexers see a stable identifier space. Off-
    ///      chain aggregators filter with `isActiveAuditor`.
    address[] private _auditorList;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event AuditorAdmitted(address indexed auditor, string name, string metadataUri, uint16 weight, AuditorTier tier);
    event AuditorRemoved(address indexed auditor);
    event AuditorActiveSet(address indexed auditor, bool active);
    event AuditorWeightSet(address indexed auditor, uint16 oldWeight, uint16 newWeight);
    event AuditorMetadataUpdated(address indexed auditor, string metadataUri);

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the registry.
    /// @param admin Initial DEFAULT_ADMIN_ROLE; must be renounced/handed-off after
    ///        cross-grants are set. Typically the deployer EOA pre-handoff.
    /// @param governor Address that will hold GOVERNANCE_ROLE; typically TangleTimelock.
    /// @param firstPartyAdmin Address that will hold FIRST_PARTY_ADMIN_ROLE;
    ///        typically a security-council multisig. May equal `admin` initially
    ///        if no separate multisig is yet provisioned.
    function initialize(address admin, address governor, address firstPartyAdmin) external initializer {
        if (admin == address(0) || governor == address(0) || firstPartyAdmin == address(0)) {
            revert Errors.ZeroAddress();
        }

        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(GOVERNANCE_ROLE, governor);
        _grantRole(FIRST_PARTY_ADMIN_ROLE, firstPartyAdmin);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GOVERNANCE PATH
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Admit a new auditor at any tier. Governance-only.
    /// @dev Reverts if the address was previously admitted (even if currently
    ///      inactive) — re-admission must go through `setAuditorActive` to keep
    ///      the original `admittedAt` immutable. `weight` is bounded by
    ///      `MAX_AUDITOR_WEIGHT`; `data.active` and `data.admittedAt` are
    ///      authoritatively set by this contract (caller-supplied values for
    ///      those fields are ignored).
    function admitAuditor(address auditor, Auditor calldata data) external onlyRole(GOVERNANCE_ROLE) {
        if (auditor == address(0)) revert Errors.ZeroAddress();
        if (auditors[auditor].admittedAt != 0) revert Errors.AuditorAlreadyAdmitted();
        if (bytes(data.name).length == 0) revert Errors.EmptyAuditorName();
        if (data.weight > MAX_AUDITOR_WEIGHT) revert Errors.InvalidWeight();

        auditors[auditor] = Auditor({
            name: data.name,
            metadataUri: data.metadataUri,
            weight: data.weight,
            tier: data.tier,
            active: true,
            admittedAt: uint64(block.timestamp)
        });
        _auditorList.push(auditor);
        emit AuditorAdmitted(auditor, data.name, data.metadataUri, data.weight, data.tier);
    }

    /// @notice Soft-remove an auditor. Governance-only.
    /// @dev `active=false`, weight zeroed. The row is preserved for historical
    ///      attestation lookups. To "re-admit" an address, call
    ///      `setAuditorActive(true)` + `setAuditorWeight(newWeight)` rather than
    ///      `admitAuditor` (which is permanently blocked once a row exists).
    ///      Emits both `AuditorWeightSet` and `AuditorActiveSet` so any consumer
    ///      subscribed to a single event stream sees a complete state transition.
    function removeAuditor(address auditor) external onlyRole(GOVERNANCE_ROLE) {
        Auditor storage row = auditors[auditor];
        if (row.admittedAt == 0) revert Errors.AuditorNotFound();
        uint16 oldWeight = row.weight;
        row.active = false;
        row.weight = 0;
        emit AuditorWeightSet(auditor, oldWeight, 0);
        emit AuditorActiveSet(auditor, false);
        emit AuditorRemoved(auditor);
    }

    /// @notice Toggle an auditor's active flag. Governance-only.
    /// @dev Deactivating zeroes the weight so the registry's advertised invariant
    ///      "inactive ⇒ weight 0" holds for every deactivation path, not just
    ///      `removeAuditor`. Without this, an aggregator that scored by `weight`
    ///      (rather than re-checking `active`) would keep counting a deactivated
    ///      auditor's influence. Re-activation intentionally restores the auditor
    ///      with weight 0; governance sets the new weight via `setAuditorWeight`.
    ///      Emits `AuditorWeightSet` on the zeroing so weight-tracking consumers
    ///      see the transition in their single event stream.
    function setAuditorActive(address auditor, bool active) external onlyRole(GOVERNANCE_ROLE) {
        Auditor storage row = auditors[auditor];
        if (row.admittedAt == 0) revert Errors.AuditorNotFound();
        row.active = active;
        if (!active && row.weight != 0) {
            uint16 oldWeight = row.weight;
            row.weight = 0;
            emit AuditorWeightSet(auditor, oldWeight, 0);
        }
        emit AuditorActiveSet(auditor, active);
    }

    /// @notice Update an auditor's weight. Governance-only.
    /// @dev Requires the auditor to be `active` so the invariant "removed ⇒
    ///      weight 0" cannot be silently violated. To set a weight on a previously
    ///      removed auditor, call `setAuditorActive(true)` first.
    function setAuditorWeight(address auditor, uint16 weight) external onlyRole(GOVERNANCE_ROLE) {
        if (weight > MAX_AUDITOR_WEIGHT) revert Errors.InvalidWeight();
        Auditor storage row = auditors[auditor];
        if (row.admittedAt == 0) revert Errors.AuditorNotFound();
        if (!row.active) revert Errors.AuditorNotActive();
        uint16 oldWeight = row.weight;
        row.weight = weight;
        emit AuditorWeightSet(auditor, oldWeight, weight);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FIRST-PARTY FAST-TRACK PATH
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fast-track admission for FIRST_PARTY auditors only.
    /// @dev Held by the security council multisig to onboard internal staff
    ///      without governance latency. Restricted to the FIRST_PARTY tier;
    ///      external firms and community auditors must still go through governance.
    function admitFirstPartyAuditor(
        address auditor,
        string calldata name,
        uint16 weight
    )
        external
        onlyRole(FIRST_PARTY_ADMIN_ROLE)
    {
        if (auditor == address(0)) revert Errors.ZeroAddress();
        if (auditors[auditor].admittedAt != 0) revert Errors.AuditorAlreadyAdmitted();
        if (bytes(name).length == 0) revert Errors.EmptyAuditorName();
        if (weight > MAX_AUDITOR_WEIGHT) revert Errors.InvalidWeight();

        auditors[auditor] = Auditor({
            name: name,
            metadataUri: "",
            weight: weight,
            tier: AuditorTier.FIRST_PARTY,
            active: true,
            admittedAt: uint64(block.timestamp)
        });
        _auditorList.push(auditor);
        emit AuditorAdmitted(auditor, name, "", weight, AuditorTier.FIRST_PARTY);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SELF-SERVICE PATH
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Auditor updates their own metadata URI. Self-only, active-only.
    /// @dev Restricted to currently-active auditors so a soft-removed address
    ///      cannot mutate its historical record post-removal (which would let an
    ///      ex-auditor flip their metadataUri to a phishing target while the
    ///      registry still resolves attestations from this address through the
    ///      preserved row). Updating the on-chain name is intentionally not
    ///      exposed — the human-readable label is governance-curated to defeat
    ///      squatting.
    function updateAuditorMetadata(string calldata metadataUri) external {
        Auditor storage row = auditors[msg.sender];
        if (row.admittedAt == 0) revert Errors.NotAuditorSelf();
        if (!row.active) revert Errors.AuditorNotActive();
        row.metadataUri = metadataUri;
        emit AuditorMetadataUpdated(msg.sender, metadataUri);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function getAuditor(address auditor) external view returns (Auditor memory) {
        return auditors[auditor];
    }

    function isActiveAuditor(address auditor) external view returns (bool) {
        return auditors[auditor].active;
    }

    function auditorWeight(address auditor) external view returns (uint16) {
        return auditors[auditor].weight;
    }

    function auditorCount() external view returns (uint256) {
        return _auditorList.length;
    }

    function auditorAt(uint256 index) external view returns (address) {
        if (index >= _auditorList.length) revert Errors.IndexOutOfBounds();
        return _auditorList[index];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADE AUTHORIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Upgrades must clear the governance bar; no other role authorizes them.
    function _authorizeUpgrade(address) internal override onlyRole(GOVERNANCE_ROLE) { }

    // ═══════════════════════════════════════════════════════════════════════════
    // RESERVED STORAGE GAP
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Storage gap for future upgrades. Slots consumed: `auditors` mapping
    ///      (slot N) + `_auditorList` array (slot N+1) = 2 slots after the
    ///      AccessControl/UUPS namespaced parents (which use ERC-7201 and do not
    ///      consume sequential slots). Gap of 48 leaves room for future fields
    ///      without bumping the storage layout in a way that would conflict with
    ///      already-deployed proxies.
    uint256[48] private __gap;
}
