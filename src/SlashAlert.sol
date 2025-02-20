// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Slash Alert Interface
/// @notice Interface for handling slashing events in the re-staking protocol
/// @dev Implement this interface to handle slashing events for remote tokens
interface ISlashAlert {
    /// @notice Called when a slashing event occurs
    /// @param blueprintId The ID of the blueprint
    /// @param serviceId The ID of the service
    /// @param operator The address/account of the operator being slashed (32 bytes)
    /// @param slashAmount The amount to slash in wei
    function onSlash(
        uint64 blueprintId,
        uint64 serviceId, 
        bytes32 operator,
        uint256 slashAmount
    ) external;
}
