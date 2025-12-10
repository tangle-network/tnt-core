// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
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
    using SafeERC20 for IERC20;

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
        if (!_restaking.isOperatorActive(msg.sender)) {
            revert Errors.OperatorNotActive(msg.sender);
        }

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
    ) external payable whenNotPaused {
        _registerOperator(blueprintId, ecdsaPublicKey, rpcAddress, bytes(""));
    }

    /// @notice Register as operator with blueprint-specific registration inputs
    function registerOperator(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress,
        bytes calldata registrationInputs
    ) external payable whenNotPaused {
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

        // Enforce max blueprint limit per operator if configured
        uint32 currentCount = _operatorBlueprintCounts[msg.sender];
        if (_maxBlueprintsPerOperator > 0) {
            if (currentCount >= _maxBlueprintsPerOperator) {
                revert Errors.MaxBlueprintsPerOperatorExceeded(msg.sender, _maxBlueprintsPerOperator);
            }
        }

        // Check not already registered
        if (_operatorRegistrations[blueprintId][msg.sender].registeredAt != 0) {
            revert Errors.OperatorAlreadyRegistered(blueprintId, msg.sender);
        }

        // Validate operator key and prevent duplicates per blueprint
        if (ecdsaPublicKey.length != 65) {
            revert Errors.InvalidOperatorKey();
        }
        bytes32 keyHash = keccak256(ecdsaPublicKey);
        if (_blueprintOperatorKeys[blueprintId][keyHash] != address(0)) {
            revert Errors.DuplicateOperatorKey(blueprintId, keyHash);
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

        uint256 requiredBond = _getOperatorBondRequirement(blueprintId);
        address bondAsset = _collectOperatorBond(blueprintId, requiredBond);

        SchemaLib.validatePayload(
            _registrationSchemas[blueprintId],
            registrationInputs,
            Types.SchemaTarget.Registration,
            blueprintId,
            0
        );

        string memory rpcAddressCopy = rpcAddress;

        // Encode preferences for backwards-compatible manager hooks
        {
            bytes memory encodedPreferences = abi.encode(
                Types.OperatorPreferences({ ecdsaPublicKey: ecdsaPublicKey, rpcAddress: rpcAddressCopy })
            );

            // Call manager hook first (may reject)
            if (bp.manager != address(0)) {
                bytes memory managerPayload = registrationInputs.length > 0 ? registrationInputs : encodedPreferences;
                _callManager(
                    bp.manager,
                    abi.encodeCall(IBlueprintServiceManager.onRegister, (msg.sender, managerPayload))
                );
            }

            // Store preferences (including ECDSA public key for gossip)
            _operatorPreferences[blueprintId][msg.sender] = Types.OperatorPreferences({
                ecdsaPublicKey: ecdsaPublicKey,
                rpcAddress: rpcAddressCopy
            });
        }

        // Register
        _operatorRegistrations[blueprintId][msg.sender] = Types.OperatorRegistration({
            registeredAt: uint64(block.timestamp),
            updatedAt: uint64(block.timestamp),
            active: true,
            online: true,
            bondAmount: requiredBond,
            bondToken: bondAsset
        });

        _blueprintOperatorKeys[blueprintId][keyHash] = msg.sender;
        _operatorBlueprintCounts[msg.sender] = currentCount + 1;
        _blueprintOperators[blueprintId].add(msg.sender);
        bp.operatorCount++;

        _recordBlueprintRegistration(blueprintId, msg.sender);
        emit OperatorRegistered(blueprintId, msg.sender, ecdsaPublicKey, rpcAddressCopy);
    }

    /// @notice Unregister from a blueprint
    function unregisterOperator(uint64 blueprintId) external {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        Types.OperatorRegistration storage reg = _operatorRegistrations[blueprintId][msg.sender];
        Types.OperatorPreferences storage prefs = _operatorPreferences[blueprintId][msg.sender];

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

        uint256 bondAmount = reg.bondAmount;
        address bondToken = reg.bondToken;
        bytes32 keyHash;
        if (prefs.ecdsaPublicKey.length != 0) {
            keyHash = keccak256(prefs.ecdsaPublicKey);
        }

        delete _operatorRegistrations[blueprintId][msg.sender];
        delete _operatorPreferences[blueprintId][msg.sender];
        _blueprintOperators[blueprintId].remove(msg.sender);
        bp.operatorCount--;

        if (keyHash != bytes32(0) && _blueprintOperatorKeys[blueprintId][keyHash] == msg.sender) {
            delete _blueprintOperatorKeys[blueprintId][keyHash];
        }
        if (_operatorBlueprintCounts[msg.sender] > 0) {
            _operatorBlueprintCounts[msg.sender] -= 1;
        }

        emit OperatorUnregistered(blueprintId, msg.sender);

        if (bondAmount > 0) {
            if (bondToken == address(0)) {
                (bool sent,) = payable(msg.sender).call{ value: bondAmount }("");
                if (!sent) {
                    revert Errors.OperatorBondRefundFailed(msg.sender, bondAmount);
                }
            } else {
                IERC20(bondToken).safeTransfer(msg.sender, bondAmount);
            }
        }
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
        bytes32 currentHash;
        if (prefs.ecdsaPublicKey.length != 0) {
            currentHash = keccak256(prefs.ecdsaPublicKey);
        }

        // Update preferences (only if non-empty)
        if (ecdsaPublicKey.length > 0) {
            if (ecdsaPublicKey.length != 65) {
                revert Errors.InvalidOperatorKey();
            }
            bytes32 newHash = keccak256(ecdsaPublicKey);
            address existing = _blueprintOperatorKeys[blueprintId][newHash];
            if (existing != address(0) && existing != msg.sender) {
                revert Errors.DuplicateOperatorKey(blueprintId, newHash);
            }
            if (currentHash != bytes32(0) && _blueprintOperatorKeys[blueprintId][currentHash] == msg.sender) {
                delete _blueprintOperatorKeys[blueprintId][currentHash];
            }
            _blueprintOperatorKeys[blueprintId][newHash] = msg.sender;
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

    function _collectOperatorBond(uint64 blueprintId, uint256 requiredBond) private returns (address bondAsset) {
        bondAsset = _operatorBondToken;
        if (requiredBond == 0) {
            if (msg.value != 0) {
                revert Errors.OperatorBondMismatch(blueprintId, 0, msg.value);
            }
            return bondAsset;
        }

        if (bondAsset == address(0)) {
            if (msg.value != requiredBond) {
                revert Errors.OperatorBondMismatch(blueprintId, requiredBond, msg.value);
            }
        } else {
            if (msg.value != 0) {
                revert Errors.OperatorBondMismatch(blueprintId, requiredBond, msg.value);
            }
            IERC20(bondAsset).safeTransferFrom(msg.sender, address(this), requiredBond);
        }
    }
}
