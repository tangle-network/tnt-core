// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Vm } from "forge-std/Vm.sol";
import { BaseTest } from "../../BaseTest.sol";
import { Tangle } from "../../../src/Tangle.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { Errors } from "../../../src/libraries/Errors.sol";
import { Operators } from "../../../src/core/Operators.sol";
import { TangleOperatorsFacet } from "../../../src/facets/tangle/TangleOperatorsFacet.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @notice Minimal view/admin surface for the gossip-key proof-of-possession controls. These
///         selectors are not in the default `ITangleFull`, so the test routes them explicitly.
interface IOperatorKeyProof {
    function requireOperatorKeyProof() external view returns (bool);
    function setRequireOperatorKeyProof(bool required) external;
}

/// @title OperatorsAuditTest
/// @notice Regression tests for the operators audit unit.
///
/// Finding covered (root cause):
///  - [access-control / low] Operator gossip key registered with no proof-of-possession →
///    identity squat / DoS. A front-runner could register a victim's public 65-byte gossip key
///    first, permanently blocking the genuine operator from claiming it on that blueprint.
///
/// The fix binds the key to a private-key signature over a domain-separated challenge
/// committing to (chainId, proxy, blueprintId, msg.sender, key). With enforcement enabled,
/// only the holder of the gossip private key can register that key. Each test below asserts a
/// SECURE invariant; reverting the production change makes the assertion fail.
contract OperatorsAuditTest is BaseTest {
    // Mirrors Base.ADMIN_ROLE = keccak256("ADMIN_ROLE").
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    IOperatorKeyProof internal keyProof;

    uint64 internal blueprintId;

    // Victim controls a real keypair; the attacker knows only the public key.
    uint256 internal constant VICTIM_PK = 0xA11CE;
    uint256 internal constant ATTACKER_PK = 0xBEEF;

    address internal victim;
    address internal attacker;
    bytes internal victimPubkey; // 65-byte uncompressed key the victim wants to register

    function setUp() public override {
        super.setUp();

        // Wire the proof-of-possession admin/view selectors through the router. The default
        // TangleOperatorsFacet.selectors() list does not include them, so register them
        // explicitly against a facet deployment that carries their code.
        TangleOperatorsFacet opsFacet = new TangleOperatorsFacet();
        bytes4[] memory extra = new bytes4[](2);
        extra[0] = IOperatorKeyProof.requireOperatorKeyProof.selector;
        extra[1] = IOperatorKeyProof.setRequireOperatorKeyProof.selector;
        vm.prank(admin);
        Tangle(payable(address(tangleProxy))).registerFacetSelectors(address(opsFacet), extra);

        keyProof = IOperatorKeyProof(address(tangleProxy));

        victim = vm.addr(VICTIM_PK);
        attacker = vm.addr(ATTACKER_PK);
        vm.deal(victim, 100 ether);
        vm.deal(attacker, 100 ether);

        // The victim's gossip identity == the uncompressed public key of VICTIM_PK. Its derived
        // Ethereum address equals `victim`, which is what the contract recovers the proof against.
        victimPubkey = _uncompressedPubkey(VICTIM_PK);
        assertEq(_addrFromPubkey(victimPubkey), victim, "victim pubkey must derive to victim address");

        vm.prank(developer);
        blueprintId = _createBlueprintAsSender("ipfs://operators-audit", address(0));

        // Both parties are active operators in staking so the registration path is reachable.
        _registerOperator(victim, 5 ether);
        _registerOperator(attacker, 5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SECURE INVARIANT 1 — squatting is impossible once enforcement is on
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice With enforcement on, an attacker who only knows the victim's PUBLIC key cannot
    ///         register it: a bare key carries no proof and is rejected outright.
    function test_squat_barePublicKey_rejectedWhenEnforced() public {
        _enableProof();

        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(Operators.KeyOwnershipProofRequired.selector, blueprintId));
        tangle.registerOperator(blueprintId, victimPubkey, "http://attacker", "");

        // Victim's identity is still unclaimed.
        assertFalse(tangle.isOperatorRegistered(blueprintId, attacker));
    }

    /// @notice An attacker cannot forge possession by signing the challenge with their OWN key:
    ///         the recovered signer (attacker) != the address derived from the victim's pubkey.
    function test_squat_forgedProof_rejected() public {
        _enableProof();

        // Attacker signs the (victim-pubkey, attacker-as-registrant) challenge with their own key.
        bytes memory envelope = _proofEnvelope(victimPubkey, ATTACKER_PK, blueprintId, attacker);

        vm.prank(attacker);
        vm.expectRevert(
            abi.encodeWithSelector(Operators.InvalidKeyOwnershipProof.selector, blueprintId, victim, attacker)
        );
        tangle.registerOperator(blueprintId, envelope, "http://attacker", "");
    }

    /// @notice Even a perfectly valid proof produced FOR the victim cannot be replayed by the
    ///         attacker: the challenge binds msg.sender, so resubmitting under the attacker's
    ///         wallet changes the digest and the recovered signer no longer matches.
    function test_squat_replayVictimProofUnderAttacker_rejected() public {
        _enableProof();

        // Victim builds a proof for THEMSELVES (registrant = victim) and it leaks to the attacker.
        bytes memory victimEnvelope = _proofEnvelope(victimPubkey, VICTIM_PK, blueprintId, victim);

        // Attacker tries to front-run by submitting the leaked envelope from their own wallet.
        vm.prank(attacker);
        vm.expectRevert(); // recovered signer != victim because the bound registrant changed
        tangle.registerOperator(blueprintId, victimEnvelope, "http://attacker", "");

        assertFalse(tangle.isOperatorRegistered(blueprintId, attacker));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SECURE INVARIANT 2 — the genuine key holder can always register
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The true key holder registers with a valid proof; exactly the 65-byte key is
    ///         persisted (the 65-byte signature suffix is consumed and never stored).
    function test_genuineHolder_registersWithProof_storesBareKey() public {
        _enableProof();

        bytes memory envelope = _proofEnvelope(victimPubkey, VICTIM_PK, blueprintId, victim);

        vm.prank(victim);
        tangle.registerOperator(blueprintId, envelope, "http://victim", "");

        assertTrue(tangle.isOperatorRegistered(blueprintId, victim));
        bytes memory stored = tangle.getOperatorPublicKey(blueprintId, victim);
        assertEq(stored.length, 65, "only the 65-byte key is stored, not the proof envelope");
        assertEq(keccak256(stored), keccak256(victimPubkey), "stored key must equal the supplied pubkey");
    }

    /// @notice After the genuine holder registers, the attacker still cannot claim the same key
    ///         on the blueprint (duplicate-key guard) — squat fully foreclosed.
    function test_genuineHolder_thenAttackerBlocked() public {
        _enableProof();

        vm.prank(victim);
        tangle.registerOperator(blueprintId, _proofEnvelope(victimPubkey, VICTIM_PK, blueprintId, victim), "rpc", "");

        // Attacker cannot even produce a valid proof (no private key); a forged one reverts.
        bytes memory forged = _proofEnvelope(victimPubkey, ATTACKER_PK, blueprintId, attacker);
        vm.prank(attacker);
        vm.expectRevert(
            abi.encodeWithSelector(Operators.InvalidKeyOwnershipProof.selector, blueprintId, victim, attacker)
        );
        tangle.registerOperator(blueprintId, forged, "rpc", "");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SECURE INVARIANT 3 — key swaps also require proof
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice updateOperatorPreferences cannot be used to swap to an unproven key once
    ///         enforcement is on — closes the "register proven, swap to squatted" bypass.
    function test_updatePreferences_unprovenKeySwap_rejected() public {
        // Register legacy (enforcement off) so the operator exists, then turn enforcement on.
        vm.prank(victim);
        tangle.registerOperator(blueprintId, victimPubkey, "rpc", "");
        _enableProof();

        // Attempt to swap to a different bare key with no proof.
        bytes memory otherKey = _uncompressedPubkey(0xC0FFEE);
        vm.prank(victim);
        vm.expectRevert(abi.encodeWithSelector(Operators.KeyOwnershipProofRequired.selector, blueprintId));
        tangle.updateOperatorPreferences(blueprintId, otherKey, "");
    }

    /// @notice A swap WITH a valid proof for the new key succeeds and stores the new bare key.
    function test_updatePreferences_provenKeySwap_succeeds() public {
        vm.prank(victim);
        tangle.registerOperator(blueprintId, victimPubkey, "rpc", "");
        _enableProof();

        uint256 newPk = 0xC0FFEE;
        bytes memory newKey = _uncompressedPubkey(newPk);
        bytes memory envelope = _proofEnvelope(newKey, newPk, blueprintId, victim);

        vm.prank(victim);
        tangle.updateOperatorPreferences(blueprintId, envelope, "");

        bytes memory stored = tangle.getOperatorPublicKey(blueprintId, victim);
        assertEq(stored.length, 65);
        assertEq(keccak256(stored), keccak256(newKey), "swapped key must be persisted as the bare 65-byte key");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN GATING + BACKWARD COMPATIBILITY
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Only ADMIN_ROLE may toggle enforcement.
    function test_setRequireOperatorKeyProof_onlyAdmin() public {
        vm.prank(attacker);
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, attacker, ADMIN_ROLE)
        );
        keyProof.setRequireOperatorKeyProof(true);
    }

    /// @notice Default is OFF: a bare 65-byte key still registers (preserves the existing
    ///         corpus / call sites). Asserts the flag defaults false and legacy path works.
    function test_default_off_legacyBareKeyStillWorks() public {
        assertFalse(keyProof.requireOperatorKeyProof(), "enforcement must default off");

        vm.prank(victim);
        tangle.registerOperator(blueprintId, victimPubkey, "rpc", "");
        assertTrue(tangle.isOperatorRegistered(blueprintId, victim));
    }

    /// @notice Even with enforcement OFF, a malformed (non-65, non-130) key is still rejected,
    ///         preserving the original length invariant.
    function test_default_off_malformedKeyStillRejected() public {
        bytes memory bad = new bytes(64);
        vm.prank(victim);
        vm.expectRevert(Errors.InvalidOperatorKey.selector);
        tangle.registerOperator(blueprintId, bad, "rpc", "");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _enableProof() internal {
        vm.prank(admin);
        keyProof.setRequireOperatorKeyProof(true);
        assertTrue(keyProof.requireOperatorKeyProof());
    }

    /// @notice Build the 65-byte uncompressed secp256k1 public key (0x04 || X || Y) for `pk`.
    function _uncompressedPubkey(uint256 pk) internal returns (bytes memory) {
        Vm.Wallet memory w = vm.createWallet(pk);
        return abi.encodePacked(bytes1(0x04), bytes32(w.publicKeyX), bytes32(w.publicKeyY));
    }

    /// @notice Mirror the contract's pubkey→address derivation: keccak256(pubkey[1:65])[12:].
    function _addrFromPubkey(bytes memory pubkey) internal pure returns (address) {
        bytes32 h = keccak256(_slice(pubkey, 1, 64));
        return address(uint160(uint256(h)));
    }

    /// @notice Build a `pubkey(65) || signature(65)` proof envelope. The signature is produced by
    ///         `signerPk` over the exact challenge the contract reconstructs for `registrant`.
    function _proofEnvelope(
        bytes memory pubkey,
        uint256 signerPk,
        uint64 bpId,
        address registrant
    )
        internal
        view
        returns (bytes memory)
    {
        bytes32 inner = keccak256(
            abi.encode(
                keccak256("TangleOperatorKeyProof"),
                block.chainid,
                address(tangleProxy),
                bpId,
                registrant,
                keccak256(pubkey)
            )
        );
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(inner);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPk, digest);
        bytes memory sig = abi.encodePacked(r, s, v); // 65 bytes
        return abi.encodePacked(pubkey, sig); // 130 bytes
    }

    function _slice(bytes memory data, uint256 start, uint256 len) internal pure returns (bytes memory out) {
        out = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            out[i] = data[start + i];
        }
    }
}
