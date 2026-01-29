// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IMasterBlueprintServiceManager
/// @notice Interface for the protocol-wide master blueprint service manager
interface IMasterBlueprintServiceManager {
    /// @notice Called when a new blueprint is created
    /// @param blueprintId The newly assigned blueprint ID
    /// @param owner The blueprint owner
    /// @param encodedDefinition ABI-encoded blueprint definition data
    function onBlueprintCreated(
        uint64 blueprintId,
        address owner,
        bytes calldata encodedDefinition
    ) external;
}
