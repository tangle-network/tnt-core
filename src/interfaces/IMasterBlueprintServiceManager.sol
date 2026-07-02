// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title IMasterBlueprintServiceManager
/// @notice Interface for the protocol-wide master blueprint service manager
interface IMasterBlueprintServiceManager {
    /// @notice Authoritative indexer event carrying the full ABI-encoded blueprint
    ///         definition. The Tangle stores only keccak256(encodedDefinition); this
    ///         event is the canonical off-chain copy, verifiable against
    ///         ITangleBlueprints.blueprintDefinitionHash(blueprintId).
    event BlueprintDefinitionRecorded(uint64 indexed blueprintId, address indexed owner, bytes encodedDefinition);

    /// @notice Called when a new blueprint is created
    /// @param blueprintId The newly assigned blueprint ID
    /// @param owner The blueprint owner
    /// @param encodedDefinition ABI-encoded blueprint definition data
    function onBlueprintCreated(uint64 blueprintId, address owner, bytes calldata encodedDefinition) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // BINARY VERSION LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Indexer notification for a new binary version publish.
    /// @dev The per-blueprint BSM hook is dispatched separately by Tangle so it
    ///      runs under Tangle's identity (`onlyFromTangle`). The master manager
    ///      only records the publish for cross-blueprint analytics / off-chain
    ///      consumers.
    /// @param blueprintId Blueprint receiving the new version.
    /// @param version Full binary version record.
    function onBinaryVersionPublished(uint64 blueprintId, Types.BinaryVersion calldata version) external;

    /// @notice Indexer notification for an operator binary acknowledgement.
    /// @param serviceId Service whose operator acked the version.
    /// @param versionId Version index that was acked.
    /// @param operator Operator that submitted the ack.
    function onOperatorBinaryAcked(uint64 serviceId, uint64 versionId, address operator) external;
}
