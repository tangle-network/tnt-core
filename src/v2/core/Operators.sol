// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";

/// @title Operators
/// @notice Operator registration and management for blueprints
abstract contract Operators is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event OperatorPreRegistered(uint64 indexed blueprintId, address indexed operator);

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
    event OperatorPreferencesUpdated(
        uint64 indexed blueprintId,
        address indexed operator,
        bytes ecdsaPublicKey,
        string rpcAddress
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // PRE-REGISTRATION (Intent Signal)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Signal intent to register for a blueprint
    /// @dev Emits PreRegistered event for off-chain indexers (e.g., blueprint-sdk)
    /// This allows operators to signal interest before actual registration
    /// @param blueprintId The blueprint to signal interest in
    function preRegister(uint64 blueprintId) external {
        // Validate blueprint exists and is active
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);

        emit OperatorPreRegistered(blueprintId, msg.sender);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION
    // ═══════════════════════════════════════════════════════════════════════════

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
    ) external whenNotPaused {
        _registerOperator(blueprintId, ecdsaPublicKey, rpcAddress, bytes(""));
    }

    /// @notice Register as operator with blueprint-specific registration inputs
    function registerOperator(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress,
        bytes calldata registrationInputs
    ) external whenNotPaused {
        _registerOperator(blueprintId, ecdsaPublicKey, rpcAddress, registrationInputs);
    }

    function _registerOperator(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress,
        bytes memory registrationInputs
    ) private {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);

        // Must be active in restaking
        if (!_restaking.isOperatorActive(msg.sender)) {
            revert Errors.OperatorNotActive(msg.sender);
        }

        // Check not already registered
        if (_operatorRegistrations[blueprintId][msg.sender].registeredAt != 0) {
            revert Errors.OperatorAlreadyRegistered(blueprintId, msg.sender);
        }

        // Validate minimum stake requirement
        uint256 minStake = _restaking.minOperatorStake();
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).getMinOperatorStake() returns (bool useDefault, uint256 customMin) {
                if (!useDefault && customMin > 0) {
                    minStake = customMin;
                }
            } catch {}
        }
        if (!_restaking.meetsStakeRequirement(msg.sender, minStake)) {
            revert Errors.InsufficientStake(msg.sender, minStake, _restaking.getOperatorStake(msg.sender));
        }

        SchemaLib.validatePayload(
            _registrationSchemas[blueprintId],
            registrationInputs,
            Types.SchemaTarget.Registration,
            blueprintId,
            0
        );

        // Encode preferences for storage and backwards-compatible manager hooks
        bytes memory encodedPreferences = abi.encode(
            Types.OperatorPreferences({
                ecdsaPublicKey: ecdsaPublicKey,
                rpcAddress: rpcAddress
            })
        );

        bytes memory managerPayload = registrationInputs.length > 0 ? registrationInputs : encodedPreferences;

        // Call manager hook first (may reject)
        if (bp.manager != address(0)) {
            _callManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onRegister, (msg.sender, managerPayload))
            );
        }

        // Register
        _operatorRegistrations[blueprintId][msg.sender] = Types.OperatorRegistration({
            registeredAt: uint64(block.timestamp),
            updatedAt: uint64(block.timestamp),
            active: true,
            online: true
        });

        // Store preferences (including ECDSA public key for gossip)
        _operatorPreferences[blueprintId][msg.sender] = Types.OperatorPreferences({
            ecdsaPublicKey: ecdsaPublicKey,
            rpcAddress: rpcAddress
        });

        _blueprintOperators[blueprintId].add(msg.sender);
        bp.operatorCount++;

        emit OperatorRegistered(blueprintId, msg.sender, ecdsaPublicKey, rpcAddress);
        _recordBlueprintRegistration(blueprintId, msg.sender);
    }

    /// @notice Unregister from a blueprint
    function unregisterOperator(uint64 blueprintId) external {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        Types.OperatorRegistration storage reg = _operatorRegistrations[blueprintId][msg.sender];

        if (reg.registeredAt == 0) {
            revert Errors.OperatorNotRegistered(blueprintId, msg.sender);
        }

        // Call manager hook
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onUnregister, (msg.sender))
            );
        }

        delete _operatorRegistrations[blueprintId][msg.sender];
        delete _operatorPreferences[blueprintId][msg.sender];
        _blueprintOperators[blueprintId].remove(msg.sender);
        bp.operatorCount--;

        emit OperatorUnregistered(blueprintId, msg.sender);
    }

    /// @notice Update operator preferences for a blueprint
    /// @param blueprintId The blueprint to update preferences for
    /// @param ecdsaPublicKey New ECDSA public key (pass empty bytes to keep unchanged)
    /// @param rpcAddress New RPC endpoint (pass empty string to keep unchanged)
    function updateOperatorPreferences(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress
    ) external {
        Types.OperatorRegistration storage reg = _operatorRegistrations[blueprintId][msg.sender];
        if (reg.registeredAt == 0) {
            revert Errors.OperatorNotRegistered(blueprintId, msg.sender);
        }

        reg.updatedAt = uint64(block.timestamp);

        Types.OperatorPreferences storage prefs = _operatorPreferences[blueprintId][msg.sender];

        // Update preferences (only if non-empty)
        if (ecdsaPublicKey.length > 0) {
            prefs.ecdsaPublicKey = ecdsaPublicKey;
        }
        if (bytes(rpcAddress).length > 0) {
            prefs.rpcAddress = rpcAddress;
        }

        // Encode for BSM hook
        bytes memory encodedPreferences = abi.encode(prefs);

        Types.Blueprint storage bp = _blueprints[blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onUpdatePreferences, (msg.sender, encodedPreferences))
            );
        }

        emit OperatorPreferencesUpdated(blueprintId, msg.sender, prefs.ecdsaPublicKey, prefs.rpcAddress);
    }
}
