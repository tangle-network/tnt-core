// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleOperators
/// @notice Operator registration and management interface
/// @dev Operator liveness is tracked via OperatorStatusRegistry heartbeats,
///      not a setOperatorOnline call. Use submitHeartbeat/isOnline/getOperatorStatus
///      on the registry for liveness signals.
interface ITangleOperators {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when an operator registers for a blueprint
    /// @param blueprintId The blueprint ID
    /// @param operator The operator address (wallet)
    /// @param ecdsaPublicKey The ECDSA public key for gossip network identity
    /// @param rpcAddress The operator's RPC endpoint
    event OperatorRegistered(
        uint64 indexed blueprintId,
        address indexed operator,
        bytes ecdsaPublicKey,
        string rpcAddress
    );

    event OperatorUnregistered(uint64 indexed blueprintId, address indexed operator);

    /// @notice Emitted when an operator updates their preferences
    /// @param blueprintId The blueprint ID
    /// @param operator The operator address
    /// @param ecdsaPublicKey The updated ECDSA public key (may be empty if unchanged)
    /// @param rpcAddress The updated RPC endpoint (may be empty if unchanged)
    event OperatorPreferencesUpdated(
        uint64 indexed blueprintId,
        address indexed operator,
        bytes ecdsaPublicKey,
        string rpcAddress
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Signal intent to register for a blueprint
    function preRegister(uint64 blueprintId) external;

    /// @notice Register as operator for a blueprint
    /// @param blueprintId The blueprint to register for
    /// @param ecdsaPublicKey The ECDSA public key for gossip network identity
    ///        This key is used for signing/verifying messages in the P2P gossip network
    ///        and may differ from the wallet key (msg.sender)
    /// @param rpcAddress The operator's RPC endpoint URL
    function registerOperator(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress
    ) external payable;

    /// @notice Register as operator providing blueprint-specific registration inputs
    /// @param registrationInputs Encoded payload validated by blueprint's schema
    function registerOperator(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress,
        bytes calldata registrationInputs
    ) external payable;

    /// @notice Unregister from a blueprint
    function unregisterOperator(uint64 blueprintId) external;

    /// @notice Update operator preferences for a blueprint
    /// @param blueprintId The blueprint to update preferences for
    /// @param ecdsaPublicKey New ECDSA public key (pass empty bytes to keep unchanged)
    /// @param rpcAddress New RPC endpoint (pass empty string to keep unchanged)
    function updateOperatorPreferences(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress
    ) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get operator registration for a blueprint
    function getOperatorRegistration(
        uint64 blueprintId,
        address operator
    ) external view returns (Types.OperatorRegistration memory);

    /// @notice Get operator preferences for a blueprint (includes ECDSA public key)
    function getOperatorPreferences(
        uint64 blueprintId,
        address operator
    ) external view returns (Types.OperatorPreferences memory);

    /// @notice Get operator's ECDSA public key for gossip network identity
    /// @dev Returns the key used for signing/verifying gossip messages
    function getOperatorPublicKey(
        uint64 blueprintId,
        address operator
    ) external view returns (bytes memory);

    /// @notice Check if operator is registered for a blueprint
    function isOperatorRegistered(uint64 blueprintId, address operator) external view returns (bool);
}
