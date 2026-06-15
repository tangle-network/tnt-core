// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";

/// @title Operators
/// @notice Operator registration and management for blueprints
abstract contract Operators is Base {
    using EnumerableSet for EnumerableSet.AddressSet;
    using ECDSA for bytes32;

    // ═══════════════════════════════════════════════════════════════════════════
    // GOSSIP-KEY PROOF-OF-POSSESSION
    // ═══════════════════════════════════════════════════════════════════════════
    // Without proof-of-possession an operator's 65-byte gossip public key is only
    // length-checked and deduplicated per blueprint. A front-runner can therefore
    // register a *victim's* public key first (it is public by definition), squatting
    // the victim's gossip identity and permanently blocking the genuine operator from
    // registering it on that blueprint (`DuplicateOperatorKey`).
    //
    // The root-cause fix binds the key to a private-key signature: the registrant must
    // present a signature, produced by the gossip private key, over a domain-separated
    // challenge committing to (chainId, this proxy, blueprintId, msg.sender, key). Only
    // the true key holder can produce it, so squatting another party's key is impossible.
    //
    // Enforcement is governed by an ADMIN_ROLE flag (`OperatorsStorage.requireKeyProof`,
    // toggled via `setRequireOperatorKeyProof`) so the requirement can be switched on
    // protocol-wide. The proof is carried in-band with no
    // new selector or parameter: when enforcement is on the caller passes
    // `pubkey(65) || signature(65)` (130 bytes) as `ecdsaPublicKey`; the 65-byte
    // signature suffix is verified and discarded, and exactly the 65-byte key is stored.

    /// @notice Length of an uncompressed secp256k1 public key (0x04 || X(32) || Y(32)).
    uint256 private constant PUBKEY_LEN = 65;

    /// @notice Length of a `pubkey || signature` proof envelope (65-byte key + 65-byte sig).
    uint256 private constant PUBKEY_WITH_PROOF_LEN = 130;

    /// @notice Domain tag for the gossip-key proof-of-possession challenge.
    bytes32 private constant OPERATOR_KEY_PROOF_DOMAIN = keccak256("TangleOperatorKeyProof");

    /// @notice Emitted when ADMIN_ROLE toggles the gossip-key proof-of-possession requirement.
    event RequireOperatorKeyProofUpdated(bool required);

    /// @notice The supplied proof signature did not recover to the address derived from the
    ///         gossip public key, i.e. the registrant did not prove control of the private key.
    /// @dev Declared locally (not in the shared Errors library) per the edit-scope rule.
    error InvalidKeyOwnershipProof(uint64 blueprintId, address expectedSigner, address recovered);

    /// @notice Proof-of-possession is required but the caller supplied no proof envelope.
    error KeyOwnershipProofRequired(uint64 blueprintId);

    /// @custom:storage-location erc7201:tangle.core.Operators
    struct OperatorsStorage {
        // When true, every gossip key written via registerOperator / updateOperatorPreferences
        // must be accompanied by a proof-of-possession signature.
        bool requireKeyProof;
    }

    /// @notice ERC-7201 slot:
    ///         keccak256(abi.encode(uint256(keccak256("tangle.core.Operators")) - 1)) & ~bytes32(uint256(0xff))
    /// @dev Namespaced storage keeps this flag collision-free against the sequential
    ///      `TangleStorage` layout and the `__gap`, so no storage migration is needed on
    ///      upgrade (matches the pattern in StakingSlashingFacet / the beacon bridges).
    bytes32 private constant OPERATORS_STORAGE_SLOT =
        0xaa9484a4b9844f1d8dd9adbeda155176c107986cc8517a591672638da120d100;

    function _operatorsStorage() private pure returns (OperatorsStorage storage $) {
        bytes32 slot = OPERATORS_STORAGE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    /// @notice Whether gossip-key proof-of-possession is currently enforced.
    function requireOperatorKeyProof() external view returns (bool) {
        return _operatorsStorage().requireKeyProof;
    }

    /// @notice Toggle the gossip-key proof-of-possession requirement protocol-wide.
    /// @dev When enabled, registrations and key updates must carry a `pubkey || signature`
    ///      envelope (130 bytes) instead of a bare 65-byte key. Enabling it closes the
    ///      identity-squat / front-run vector on operator gossip keys.
    function setRequireOperatorKeyProof(bool required) external onlyRole(ADMIN_ROLE) whenNotPaused {
        _operatorsStorage().requireKeyProof = required;
        emit RequireOperatorKeyProofUpdated(required);
    }

    /// @notice Derive the canonical Ethereum address from a 65-byte uncompressed secp256k1
    ///         public key: `address(uint160(uint256(keccak256(pubkey[1:65]))))`.
    function _addressFromPubkey(bytes memory pubkey) private pure returns (address) {
        // Hash the 64-byte (X || Y) body, skipping the 0x04 uncompressed prefix.
        bytes32 h;
        assembly {
            h := keccak256(add(pubkey, 0x21), 0x40)
        }
        return address(uint160(uint256(h)));
    }

    /// @notice EIP-191 digest the gossip private key must sign to prove possession.
    /// @dev Binds chainId + this proxy (replay across forks/deployments), the blueprint, the
    ///      registrant wallet (so a captured proof can't be reused by a different msg.sender),
    ///      and the key itself.
    function _keyProofDigest(
        uint64 blueprintId,
        address registrant,
        bytes memory pubkey
    )
        private
        view
        returns (bytes32)
    {
        bytes32 inner = keccak256(
            abi.encode(
                OPERATOR_KEY_PROOF_DOMAIN, block.chainid, address(this), blueprintId, registrant, keccak256(pubkey)
            )
        );
        // Personal-sign envelope so operators can produce the proof with a standard wallet.
        return MessageHashUtils.toEthSignedMessageHash(inner);
    }

    /// @notice Split an `ecdsaPublicKey` argument into the stored 65-byte key and verify the
    ///         proof-of-possession when enforcement is on.
    /// @dev Returns the canonical 65-byte key to persist. When enforcement is on the argument
    ///      must be `pubkey(65) || signature(65)`; the recovered signer must equal the address
    ///      derived from the key. When enforcement is off, a bare 65-byte key is accepted as-is
    ///      (legacy path); a 130-byte proof envelope is still accepted and verified opportunistically.
    function _resolveOperatorKey(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey
    )
        private
        view
        returns (bytes memory key)
    {
        bool required = _operatorsStorage().requireKeyProof;

        if (ecdsaPublicKey.length == PUBKEY_WITH_PROOF_LEN) {
            key = ecdsaPublicKey[0:PUBKEY_LEN];
            bytes calldata signature = ecdsaPublicKey[PUBKEY_LEN:PUBKEY_WITH_PROOF_LEN];
            address expected = _addressFromPubkey(key);
            address recovered = _keyProofDigest(blueprintId, msg.sender, key).recover(signature);
            if (recovered != expected) {
                revert InvalidKeyOwnershipProof(blueprintId, expected, recovered);
            }
            return key;
        }

        if (required) {
            // Enforcement on but no proof envelope supplied — reject. A bare 65-byte key
            // carries no proof of private-key control and is exactly the squat vector.
            revert KeyOwnershipProofRequired(blueprintId);
        }

        if (ecdsaPublicKey.length != PUBKEY_LEN) {
            revert Errors.InvalidOperatorKey();
        }
        return ecdsaPublicKey;
    }
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
        uint64 indexed blueprintId, address indexed operator, bytes ecdsaPublicKey, string rpcAddress
    );

    event OperatorUnregistered(uint64 indexed blueprintId, address indexed operator);

    /// @notice Emitted when blueprint metadata is locked
    event BlueprintMetadataLocked(uint64 indexed blueprintId);

    /// @notice Emitted when an operator updates their preferences
    event OperatorPreferencesUpdated(
        uint64 indexed blueprintId, address indexed operator, bytes ecdsaPublicKey, string rpcAddress
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
        if (!_staking.isOperatorActive(msg.sender)) {
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
    )
        external
        whenNotPaused
        nonReentrant
    {
        _registerOperator(blueprintId, ecdsaPublicKey, rpcAddress, bytes(""));
    }

    /// @notice Register as operator with blueprint-specific registration inputs
    function registerOperator(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress,
        bytes calldata registrationInputs
    )
        external
        whenNotPaused
        nonReentrant
    {
        _registerOperator(blueprintId, ecdsaPublicKey, rpcAddress, registrationInputs);
    }

    function _registerOperator(
        uint64 blueprintId,
        bytes calldata ecdsaPublicKey,
        string calldata rpcAddress,
        bytes memory registrationInputs
    )
        private
    {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        if (!bp.active) revert Errors.BlueprintNotActive(blueprintId);

        // Must be active in staking
        if (!_staking.isOperatorActive(msg.sender)) {
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

        // Validate operator key (and proof-of-possession when enforced) and prevent
        // duplicates per blueprint. `_resolveOperatorKey` returns the canonical 65-byte
        // key to persist, after verifying the registrant controls its private key.
        bytes memory operatorKey = _resolveOperatorKey(blueprintId, ecdsaPublicKey);
        bytes32 keyHash = keccak256(operatorKey);
        if (_blueprintOperatorKeys[blueprintId][keyHash] != address(0)) {
            revert Errors.DuplicateOperatorKey(blueprintId, keyHash);
        }

        // Validate minimum stake requirement
        uint256 minStake = _staking.minOperatorStake();
        if (bp.manager != address(0)) {
            (bool ok, bytes memory ret) = _tryStaticcallManager(
                bp.manager, abi.encodeWithSelector(IBlueprintServiceManager.getMinOperatorStake.selector), 64
            );
            if (ok) {
                (bool useDefault, uint256 customMin) = abi.decode(ret, (bool, uint256));
                if (!useDefault && customMin > 0) minStake = customMin;
            }
        }
        if (!_staking.meetsStakeRequirement(msg.sender, minStake)) {
            revert Errors.InsufficientStake(msg.sender, minStake, _staking.getOperatorStake(msg.sender));
        }

        SchemaLib.validatePayload(
            _registrationSchemas[blueprintId], registrationInputs, Types.SchemaTarget.Registration, blueprintId, 0
        );

        string memory rpcAddressCopy = rpcAddress;

        // CEI: complete every state write before invoking the (untrusted) BSM hook.
        // The hook can revert to reject the registration; if it does, all the state
        // writes are reverted along with it. The hook *cannot* observe partially-
        // written state, so a malicious BSM cannot exploit half-initialized records.
        _operatorPreferences[blueprintId][msg.sender] =
            Types.OperatorPreferences({ ecdsaPublicKey: operatorKey, rpcAddress: rpcAddressCopy });

        _operatorRegistrations[blueprintId][msg.sender] = Types.OperatorRegistration({
            registeredAt: uint64(block.timestamp), updatedAt: uint64(block.timestamp), active: true, online: true
        });

        _blueprintOperatorKeys[blueprintId][keyHash] = msg.sender;
        _operatorBlueprintCounts[msg.sender] = currentCount + 1;
        _blueprintOperators[blueprintId].add(msg.sender);
        bp.operatorCount++;

        // Lock metadata on first operator registration
        if (bp.operatorCount == 1 && !_blueprintMetadataLocked[blueprintId]) {
            _blueprintMetadataLocked[blueprintId] = true;
            emit BlueprintMetadataLocked(blueprintId);
        }

        // Add blueprint to operator's staking profile for delegation exposure
        _staking.addBlueprintForOperator(msg.sender, blueprintId);

        _recordBlueprintRegistration(blueprintId, msg.sender);
        emit OperatorRegistered(blueprintId, msg.sender, operatorKey, rpcAddressCopy);

        // Hook fires last so the BSM observes the fully-committed registration.
        if (bp.manager != address(0)) {
            bytes memory encodedPreferences =
                abi.encode(Types.OperatorPreferences({ ecdsaPublicKey: operatorKey, rpcAddress: rpcAddressCopy }));
            bytes memory managerPayload = registrationInputs.length > 0 ? registrationInputs : encodedPreferences;
            _callManager(bp.manager, abi.encodeCall(IBlueprintServiceManager.onRegister, (msg.sender, managerPayload)));
        }
    }

    /// @notice Unregister from a blueprint
    /// @dev Reverts if operator has any active services for this blueprint
    function unregisterOperator(uint64 blueprintId) external nonReentrant {
        Types.Blueprint storage bp = _getBlueprint(blueprintId);
        Types.OperatorRegistration storage reg = _operatorRegistrations[blueprintId][msg.sender];
        Types.OperatorPreferences storage prefs = _operatorPreferences[blueprintId][msg.sender];

        if (reg.registeredAt == 0) {
            revert Errors.OperatorNotRegistered(blueprintId, msg.sender);
        }

        // Prevent unregistration if operator has active services for this blueprint
        if (_operatorActiveServiceCount[blueprintId][msg.sender] > 0) {
            revert Errors.OperatorHasActiveServices(blueprintId, msg.sender);
        }

        // CEI: clear operator state BEFORE invoking the (untrusted) BSM hook so the
        // hook observes a fully-finalized unregistration. Mirrors the registration path.
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

        _staking.removeBlueprintForOperator(msg.sender, blueprintId);

        emit OperatorUnregistered(blueprintId, msg.sender);

        // Hook fires last (interaction).
        if (bp.manager != address(0)) {
            _tryCallManager(bp.manager, abi.encodeCall(IBlueprintServiceManager.onUnregister, (msg.sender)));
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
    )
        external
    {
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

        // Update preferences (only if non-empty). A key swap re-runs proof-of-possession
        // so an operator cannot register with a proven key and then silently swap to an
        // unproven / squatted key, which would re-open the front-run vector.
        if (ecdsaPublicKey.length > 0) {
            bytes memory newKey = _resolveOperatorKey(blueprintId, ecdsaPublicKey);
            bytes32 newHash = keccak256(newKey);
            address existing = _blueprintOperatorKeys[blueprintId][newHash];
            if (existing != address(0) && existing != msg.sender) {
                revert Errors.DuplicateOperatorKey(blueprintId, newHash);
            }
            if (currentHash != bytes32(0) && _blueprintOperatorKeys[blueprintId][currentHash] == msg.sender) {
                delete _blueprintOperatorKeys[blueprintId][currentHash];
            }
            _blueprintOperatorKeys[blueprintId][newHash] = msg.sender;
            prefs.ecdsaPublicKey = newKey;
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

    // ═══════════════════════════════════════════════════════════════════════════
    // ACTIVE SERVICE QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get total count of active services for an operator across all blueprints
    /// @dev Sums _operatorActiveServiceCount across all blueprints the operator is registered for
    /// @param operator The operator address
    /// @return count Total number of active services the operator is part of
    function getOperatorTotalActiveServices(address operator) external view returns (uint256 count) {
        // Iterate through all blueprints to sum active service counts
        // This is O(n) where n is the number of blueprints, but typically small
        for (uint64 i = 0; i < _blueprintCount; i++) {
            count += _operatorActiveServiceCount[i][operator];
        }
    }
}
