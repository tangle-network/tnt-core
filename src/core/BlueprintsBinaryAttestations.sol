// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title BlueprintsBinaryAttestations
/// @notice Permissionless attestations against a specific blueprint binary version.
/// @dev Anyone may attest to a `(blueprintId, versionId)`. Only the original
///      attester may revoke their own row. Rows are append-only; revocation flips
///      the `revoked` flag so off-chain indexers retain a stable id space and a
///      complete provenance history.
///
///      Trust model is intentionally minimal at the protocol layer: aggregation
///      and weighting is delegated to `BlueprintAuditors` (which curates an
///      address → weight map) plus off-chain scoring. Reading attestations on
///      their own is not a security claim; weighting via the auditor registry is.
abstract contract BlueprintsBinaryAttestations is Base {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BinaryVersionAttested(
        uint64 indexed blueprintId,
        uint64 indexed versionId,
        uint64 attestationId,
        address indexed attester,
        Types.AttestationKind kind,
        uint8 severityFound,
        string reportUri
    );
    event BinaryVersionAttestationRevoked(
        uint64 indexed blueprintId, uint64 indexed versionId, uint64 attestationId, string reasonUri
    );

    /// @notice Maximum severity value accepted by `attestBinaryVersion`.
    /// @dev Matches the ladder documented on `Types.Attestation.severityFound`:
    ///      0=none, 1=info, 2=low, 3=med, 4=high, 5=critical.
    uint8 internal constant MAX_ATTESTATION_SEVERITY = 5;

    // ═══════════════════════════════════════════════════════════════════════════
    // MUTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a new attestation against a binary version.
    /// @dev Permissionless. `msg.sender` is recorded as the attester. The targeted
    ///      version must exist; missing versions revert `VersionNotFound`.
    /// @param blueprintId Blueprint whose version is being attested.
    /// @param versionId Version index on the blueprint's version list.
    /// @param reportHash Digest of the report off-chain (e.g. PDF SHA256). Zero is
    ///        allowed because not every attestation kind produces a hashable
    ///        artifact (e.g. a SELF declaration may carry only a URI).
    /// @param reportUri Pointer to the report; must be non-empty so consumers
    ///        always have somewhere to read the substantive claim.
    /// @param kind Attestation kind (see `Types.AttestationKind`).
    /// @param severityFound CVSS-style worst severity discovered, in [0, 5].
    /// @param expiresAt Optional expiry timestamp; 0 means no expiry. Non-zero
    ///        values must be strictly in the future at submit time to avoid
    ///        admitting already-expired rows that would mislead consumers.
    /// @return attestationId The newly assigned attestation index for this version.
    function attestBinaryVersion(
        uint64 blueprintId,
        uint64 versionId,
        bytes32 reportHash,
        string calldata reportUri,
        Types.AttestationKind kind,
        uint8 severityFound,
        uint64 expiresAt
    )
        external
        whenNotPaused
        nonReentrant
        returns (uint64 attestationId)
    {
        if (versionId >= _blueprintBinaryVersions[blueprintId].length) revert Errors.VersionNotFound();
        if (bytes(reportUri).length == 0) revert Errors.EmptyReportUri();
        if (severityFound > MAX_ATTESTATION_SEVERITY) revert Errors.InvalidSeverity();
        if (expiresAt != 0 && expiresAt <= uint64(block.timestamp)) revert Errors.ExpiresInPast();

        Types.Attestation[] storage list = _blueprintVersionAttestations[blueprintId][versionId];
        attestationId = uint64(list.length);
        list.push(
            Types.Attestation({
                attester: msg.sender,
                reportHash: reportHash,
                kind: kind,
                severityFound: severityFound,
                attestedAt: uint64(block.timestamp),
                expiresAt: expiresAt,
                revoked: false
            })
        );

        emit BinaryVersionAttested(blueprintId, versionId, attestationId, msg.sender, kind, severityFound, reportUri);
    }

    /// @notice Revoke an attestation. One-way; flips `revoked = true`.
    /// @dev Only the original attester may revoke. The row is preserved so
    ///      historical indexers can show "attested then revoked" with the reason.
    /// @param reasonUri Off-chain pointer describing why the attestation was
    ///        withdrawn (e.g. "new evidence invalidates audit"). Emitted in the
    ///        revocation event for transparency; not stored on-chain.
    function revokeAttestation(
        uint64 blueprintId,
        uint64 versionId,
        uint64 attestationId,
        string calldata reasonUri
    )
        external
        whenNotPaused
        nonReentrant
    {
        Types.Attestation[] storage list = _blueprintVersionAttestations[blueprintId][versionId];
        if (attestationId >= list.length) revert Errors.AttestationNotFound();

        Types.Attestation storage row = list[attestationId];
        if (row.attester != msg.sender) revert Errors.NotAttester();
        if (row.revoked) revert Errors.AttestationAlreadyRevoked();

        row.revoked = true;
        emit BinaryVersionAttestationRevoked(blueprintId, versionId, attestationId, reasonUri);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function getAttestation(
        uint64 blueprintId,
        uint64 versionId,
        uint64 attestationId
    )
        external
        view
        returns (Types.Attestation memory)
    {
        Types.Attestation[] storage list = _blueprintVersionAttestations[blueprintId][versionId];
        if (attestationId >= list.length) revert Errors.AttestationNotFound();
        return list[attestationId];
    }

    function getAttestationCount(uint64 blueprintId, uint64 versionId) external view returns (uint64) {
        return uint64(_blueprintVersionAttestations[blueprintId][versionId].length);
    }

    /// @notice Return the full attestation list for a binary version.
    /// @dev O(n) memory copy. Lists are unbounded in principle; off-chain
    ///      consumers that expect very large lists should paginate via
    ///      `getAttestation` / `getAttestationCount`.
    function listAttestations(uint64 blueprintId, uint64 versionId) external view returns (Types.Attestation[] memory) {
        Types.Attestation[] storage stored = _blueprintVersionAttestations[blueprintId][versionId];
        Types.Attestation[] memory copy = new Types.Attestation[](stored.length);
        for (uint256 i = 0; i < stored.length; ++i) {
            copy[i] = stored[i];
        }
        return copy;
    }
}
