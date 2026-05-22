// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IMasterBlueprintServiceManager } from "../interfaces/IMasterBlueprintServiceManager.sol";

/// @title BlueprintsBinaryVersions
/// @notice Append-only binary version registry per blueprint plus per-service
///         upgrade policy and operator acknowledgement tracking.
/// @dev Resolution policy summary (see `effectiveBinaryVersion`):
///        AUTO    → version[activeVersionId]              (blueprint owner-driven rollout)
///        APPROVE → version[ackedVersionId] when ack > 0,
///                  otherwise version[0]                  (genesis until opt-in)
///        MANUAL  → version[0]                            (pinned to genesis)
///      A blueprint with zero published versions reverts `VersionNotFound` from
///      `effectiveBinaryVersion`; the genesis row is the first publish.
///
///      Storage invariants enforced by this mixin:
///        - `_blueprintBinaryVersions[bp]` is strictly append-only; `versionId`
///          equals the array index. Deprecation flips a flag in-place; the row is
///          never removed.
///        - `_blueprintActiveVersionId[bp]` is only writable to existing indices
///          and is left at zero (genesis) for new blueprints.
///        - `_serviceAckedVersionId[svc]` can only advance to versions the operator
///          has opted into; deprecated versions are explicitly rejected at ack time.
abstract contract BlueprintsBinaryVersions is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BinaryVersionPublished(
        uint64 indexed blueprintId, uint64 indexed versionId, bytes32 sha256Hash, string binaryUri
    );
    event BinaryVersionDeprecated(uint64 indexed blueprintId, uint64 indexed versionId);
    event BinaryActiveVersionChanged(uint64 indexed blueprintId, uint64 indexed versionId);
    event ServiceUpgradePolicySet(uint64 indexed serviceId, Types.UpgradePolicy policy);
    event OperatorBinaryAcked(uint64 indexed serviceId, uint64 indexed versionId, address indexed operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT-OWNER ACTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Publish a new binary version for a blueprint.
    /// @dev Append-only. The caller MUST be the blueprint owner. The first publish
    ///      defines the genesis version (versionId == 0); the active version is
    ///      left at zero so existing services do not auto-roll until the owner
    ///      explicitly bumps `setActiveBinaryVersion` or operators ack a newer one.
    /// @param blueprintId Target blueprint.
    /// @param sha256Hash Canonical binary integrity digest; must be non-zero.
    /// @param binaryUri IPFS / HTTPS pointer to the binary artifact; must be non-empty.
    /// @param attestationHash Optional sigstore / SLSA bundle digest. Zero is accepted
    ///        and means "no bundle published with this version."
    /// @return versionId The newly assigned version index.
    function publishBinaryVersion(
        uint64 blueprintId,
        bytes32 sha256Hash,
        string calldata binaryUri,
        bytes32 attestationHash
    )
        external
        whenNotPaused
        nonReentrant
        returns (uint64 versionId)
    {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        if (sha256Hash == bytes32(0)) revert Errors.ZeroBinaryHash();
        if (bytes(binaryUri).length == 0) revert Errors.EmptyBinaryUri();

        Types.BinaryVersion[] storage versions = _blueprintBinaryVersions[blueprintId];
        versionId = uint64(versions.length);

        versions.push(
            Types.BinaryVersion({
                versionId: versionId,
                sha256Hash: sha256Hash,
                binaryUri: binaryUri,
                attestationHash: attestationHash,
                publishedAt: uint64(block.timestamp),
                deprecated: false
            })
        );

        emit BinaryVersionPublished(blueprintId, versionId, sha256Hash, binaryUri);

        // Best-effort fan-out:
        //   1. Per-blueprint BSM hook via Tangle's standard `_tryCallManager`
        //      path so the BSM's `onlyFromTangle` modifier still applies
        //      (msg.sender on the BSM side is Tangle, not the MBSM).
        //   2. MBSM notification for the authoritative indexer event. Trusted
        //      protocol code; non-best-effort.
        // The version row is already persisted, so a reverting BSM is observable
        // via `ManagerHookFailed` (Base) but does not roll back the publish.
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onBinaryVersionPublished, (blueprintId, versions[versionId]))
            );
        }
        _notifyMasterOnVersionPublished(blueprintId, versions[versionId]);
    }

    /// @notice Set the active binary version for a blueprint.
    /// @dev Only affects services using `UpgradePolicy.AUTO`. Reverts if the
    ///      target version does not exist. Setting the active version to a
    ///      `deprecated` row is allowed (the owner may revert to an older known-good
    ///      build); enforcement of "no deprecated active" is a UI concern.
    function setActiveBinaryVersion(uint64 blueprintId, uint64 versionId) external whenNotPaused nonReentrant {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) revert Errors.NotBlueprintOwner(blueprintId, msg.sender);
        if (versionId >= _blueprintBinaryVersions[blueprintId].length) revert Errors.VersionNotFound();

        _blueprintActiveVersionId[blueprintId] = versionId;
        emit BinaryActiveVersionChanged(blueprintId, versionId);
    }

    /// @notice Flag a binary version as deprecated. One-way.
    /// @dev Operators cannot ack a deprecated version; existing acks remain so the
    ///      effective version of an opted-in service stays stable until the
    ///      operator explicitly acks a newer one.
    function deprecateBinaryVersion(uint64 blueprintId, uint64 versionId) external whenNotPaused nonReentrant {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (bp.owner != msg.sender) revert Errors.NotBlueprintOwner(blueprintId, msg.sender);

        Types.BinaryVersion[] storage versions = _blueprintBinaryVersions[blueprintId];
        if (versionId >= versions.length) revert Errors.VersionNotFound();
        if (versions[versionId].deprecated) revert Errors.VersionAlreadyDeprecated();

        versions[versionId].deprecated = true;
        emit BinaryVersionDeprecated(blueprintId, versionId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE-OPERATOR ACTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set the upgrade policy for a service.
    /// @dev The caller MUST be an active operator of the service. Changing policy
    ///      does not retroactively change which version a previously dispatched
    ///      job was scheduled against (off-chain dispatchers resolve at job time).
    function setServiceUpgradePolicy(uint64 serviceId, Types.UpgradePolicy policy) external whenNotPaused nonReentrant {
        _getService(serviceId);
        if (!_serviceOperators[serviceId][msg.sender].active) revert Errors.NotServiceOperator();

        _serviceUpgradePolicy[serviceId] = policy;
        emit ServiceUpgradePolicySet(serviceId, policy);
    }

    /// @notice Acknowledge a binary version for a service under `APPROVE` policy.
    /// @dev The caller MUST be an active operator of the service. The target
    ///      version must exist on the service's blueprint and must not be
    ///      `deprecated` (acking a deprecated version would pin the service to a
    ///      version the blueprint owner has flagged as obsolete). The ack is
    ///      monotonic in intent — `setServiceUpgradePolicy(MANUAL)` is the path
    ///      to pin back to genesis.
    function ackBinaryVersion(uint64 serviceId, uint64 versionId) external whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (!_serviceOperators[serviceId][msg.sender].active) revert Errors.NotServiceOperator();

        Types.BinaryVersion[] storage versions = _blueprintBinaryVersions[svc.blueprintId];
        if (versionId >= versions.length) revert Errors.VersionNotFound();
        if (versions[versionId].deprecated) revert Errors.VersionDeprecatedCannotAck();

        _serviceAckedVersionId[serviceId] = versionId;
        emit OperatorBinaryAcked(serviceId, versionId, msg.sender);

        // Same revert-isolation rationale as `publishBinaryVersion`: the ack is
        // already persisted and the BSM hook is informational. The BSM hook
        // runs first (under `_tryCallManager`'s gas cap and `onlyFromTangle`
        // identity), then the MBSM gets its indexer event.
        address manager = _blueprints[svc.blueprintId].manager;
        if (manager != address(0)) {
            _tryCallManager(
                manager,
                abi.encodeCall(IBlueprintServiceManager.onOperatorBinaryAcked, (serviceId, versionId, msg.sender))
            );
        }
        _notifyMasterOnOperatorAcked(serviceId, svc.blueprintId, versionId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL — MBSM INDEXER NOTIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Notify the blueprint's pinned MBSM of a binary version publish for
    ///      indexer purposes. The MBSM emits the authoritative cross-blueprint
    ///      event; the per-blueprint BSM hook is dispatched separately by the
    ///      caller so it runs with `msg.sender == Tangle` and clears the BSM's
    ///      `onlyFromTangle` identity check. Skipped silently when no registry
    ///      is configured (tests that bypass the registry path) — the
    ///      blueprint-scoped event already persisted carries the same data.
    function _notifyMasterOnVersionPublished(uint64 blueprintId, Types.BinaryVersion storage version) private {
        if (address(_mbsmRegistry) == address(0)) return;
        address master = _mbsmRegistry.getMBSM(blueprintId);
        if (master == address(0)) return;
        IMasterBlueprintServiceManager(master).onBinaryVersionPublished(blueprintId, version);
    }

    /// @dev MBSM indexer notification for an operator ack. See
    ///      `_notifyMasterOnVersionPublished` for the rationale.
    function _notifyMasterOnOperatorAcked(uint64 serviceId, uint64 blueprintId, uint64 versionId) private {
        if (address(_mbsmRegistry) == address(0)) return;
        address master = _mbsmRegistry.getMBSM(blueprintId);
        if (master == address(0)) return;
        IMasterBlueprintServiceManager(master).onOperatorBinaryAcked(serviceId, versionId, msg.sender);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function getBinaryVersion(uint64 blueprintId, uint64 versionId) external view returns (Types.BinaryVersion memory) {
        Types.BinaryVersion[] storage versions = _blueprintBinaryVersions[blueprintId];
        if (versionId >= versions.length) revert Errors.VersionNotFound();
        return versions[versionId];
    }

    function getBinaryVersionCount(uint64 blueprintId) external view returns (uint64) {
        return uint64(_blueprintBinaryVersions[blueprintId].length);
    }

    function getActiveBinaryVersionId(uint64 blueprintId) external view returns (uint64) {
        return _blueprintActiveVersionId[blueprintId];
    }

    function getServiceUpgradePolicy(uint64 serviceId) external view returns (Types.UpgradePolicy) {
        return _serviceUpgradePolicy[serviceId];
    }

    function getServiceAckedVersionId(uint64 serviceId) external view returns (uint64) {
        return _serviceAckedVersionId[serviceId];
    }

    /// @notice Resolve the binary version a service should currently be running.
    /// @dev Pure function of stored state — does not call into any external contract.
    ///      Reverts `VersionNotFound` if the blueprint has zero published versions
    ///      (a service can exist before any binary is published; off-chain
    ///      dispatchers should treat that as "not yet provisioned").
    function effectiveBinaryVersion(uint64 serviceId) external view returns (Types.BinaryVersion memory) {
        Types.Service storage svc = _getService(serviceId);
        Types.BinaryVersion[] storage versions = _blueprintBinaryVersions[svc.blueprintId];
        if (versions.length == 0) revert Errors.VersionNotFound();

        Types.UpgradePolicy policy = _serviceUpgradePolicy[serviceId];
        if (policy == Types.UpgradePolicy.AUTO) {
            uint64 active = _blueprintActiveVersionId[svc.blueprintId];
            // `active` is constrained to existing indices by `setActiveBinaryVersion`;
            // the default 0 always points to genesis when versions.length > 0.
            return versions[active];
        }
        if (policy == Types.UpgradePolicy.APPROVE) {
            uint64 acked = _serviceAckedVersionId[serviceId];
            // Both "no ack" and "ack == 0" collapse to genesis. Acked indices
            // beyond the array length are unreachable: ack writes are bounded.
            return versions[acked];
        }
        // MANUAL: pinned to genesis until the operator switches policy.
        return versions[0];
    }
}
