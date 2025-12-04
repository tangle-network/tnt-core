// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Operators
/// @notice Operator registration and management for blueprints
abstract contract Operators is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event OperatorPreRegistered(uint64 indexed blueprintId, address indexed operator);
    event OperatorRegistered(uint64 indexed blueprintId, address indexed operator, bytes preferences);
    event OperatorUnregistered(uint64 indexed blueprintId, address indexed operator);
    event OperatorPreferencesUpdated(uint64 indexed blueprintId, address indexed operator, bytes preferences);
    event OperatorRpcAddressUpdated(uint64 indexed blueprintId, address indexed operator, string rpcAddress);

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
    function registerOperator(uint64 blueprintId, bytes calldata preferences) external whenNotPaused {
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

        // Call manager hook first (may reject)
        if (bp.manager != address(0)) {
            _callManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onRegister, (msg.sender, preferences))
            );
        }

        // Register
        _operatorRegistrations[blueprintId][msg.sender] = Types.OperatorRegistration({
            registeredAt: uint64(block.timestamp),
            updatedAt: uint64(block.timestamp),
            active: true,
            online: true
        });

        _blueprintOperators[blueprintId].add(msg.sender);
        bp.operatorCount++;

        emit OperatorRegistered(blueprintId, msg.sender, preferences);
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
        _blueprintOperators[blueprintId].remove(msg.sender);
        bp.operatorCount--;

        emit OperatorUnregistered(blueprintId, msg.sender);
    }

    /// @notice Update operator preferences
    function updateOperatorPreferences(uint64 blueprintId, bytes calldata preferences) external {
        Types.OperatorRegistration storage reg = _operatorRegistrations[blueprintId][msg.sender];
        if (reg.registeredAt == 0) {
            revert Errors.OperatorNotRegistered(blueprintId, msg.sender);
        }

        reg.updatedAt = uint64(block.timestamp);

        Types.Blueprint storage bp = _blueprints[blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onUpdatePreferences, (msg.sender, preferences))
            );
        }

        emit OperatorPreferencesUpdated(blueprintId, msg.sender, preferences);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RPC ADDRESS MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update operator's RPC endpoint address for a blueprint
    /// @dev This is used by blueprint-sdk to discover operator endpoints
    /// @param blueprintId The blueprint to update RPC for
    /// @param rpcAddress The new RPC endpoint (e.g., "https://operator.example.com:8545")
    function updateRpcAddress(uint64 blueprintId, string calldata rpcAddress) external {
        Types.OperatorRegistration storage reg = _operatorRegistrations[blueprintId][msg.sender];
        if (reg.registeredAt == 0) {
            revert Errors.OperatorNotRegistered(blueprintId, msg.sender);
        }

        reg.updatedAt = uint64(block.timestamp);

        emit OperatorRpcAddressUpdated(blueprintId, msg.sender, rpcAddress);
    }
}
