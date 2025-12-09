// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IMBSMRegistry
/// @notice Minimal interface for the Master Blueprint Service Manager registry
interface IMBSMRegistry {
    /// @notice Get the MBSM address currently pinned for a blueprint
    /// @param blueprintId The blueprint identifier
    /// @return mbsmAddress The pinned MBSM (or latest if not pinned)
    // forge-lint: disable-next-line(mixed-case-function)
    function getMBSM(uint64 blueprintId) external view returns (address mbsmAddress);

    /// @notice Get the revision pinned for a blueprint (0 = latest)
    function getPinnedRevision(uint64 blueprintId) external view returns (uint32 revision);

    /// @notice Get the latest registered MBSM address
    /// @return mbsmAddress The latest MBSM
    // forge-lint: disable-next-line(mixed-case-function)
    function getLatestMBSM() external view returns (address mbsmAddress);

    /// @notice Get an MBSM by explicit revision
    /// @param revision The registry revision (1-indexed)
    /// @return mbsmAddress The registered address for the revision
    // forge-lint: disable-next-line(mixed-case-function)
    function getMBSMByRevision(uint32 revision) external view returns (address mbsmAddress);

    /// @notice Get the latest revision number registered in the registry
    function getLatestRevision() external view returns (uint32);

    /// @notice Pin a blueprint to a specific revision (0 disallowed)
    function pinBlueprint(uint64 blueprintId, uint32 revision) external;

    /// @notice Unpin a blueprint (reverting to latest)
    function unpinBlueprint(uint64 blueprintId) external;
}
