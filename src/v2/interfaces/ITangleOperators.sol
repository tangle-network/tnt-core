// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleOperators
/// @notice Operator registration and management interface
interface ITangleOperators {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event OperatorRegistered(uint64 indexed blueprintId, address indexed operator, bytes preferences);

    event OperatorUnregistered(uint64 indexed blueprintId, address indexed operator);

    event OperatorPreferencesUpdated(uint64 indexed blueprintId, address indexed operator, bytes preferences);

    event OperatorOnlineStatusChanged(uint64 indexed blueprintId, address indexed operator, bool online);

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register as operator for a blueprint
    /// @param blueprintId The blueprint to register for
    /// @param preferences Operator preferences (RPC endpoint, pricing, etc.)
    function registerOperator(uint64 blueprintId, bytes calldata preferences) external;

    /// @notice Unregister from a blueprint
    function unregisterOperator(uint64 blueprintId) external;

    /// @notice Update operator preferences for a blueprint
    function updateOperatorPreferences(uint64 blueprintId, bytes calldata preferences) external;

    /// @notice Set operator online/offline status
    function setOperatorOnline(uint64 blueprintId, bool online) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get operator registration for a blueprint
    function getOperatorRegistration(
        uint64 blueprintId,
        address operator
    ) external view returns (Types.OperatorRegistration memory);

    /// @notice Check if operator is registered for a blueprint
    function isOperatorRegistered(uint64 blueprintId, address operator) external view returns (bool);
}
