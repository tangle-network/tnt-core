// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { BeaconChainProofs } from "../../src/beacon/BeaconChainProofs.sol";
import { ValidatorTypes } from "../../src/beacon/ValidatorTypes.sol";

/// @title BeaconChainProofsRealFixtureTest
/// @notice Validates our SSZ merkle-proof verifier against a REAL beacon-chain proof, not a
///         self-referential fixture. The proof is EigenLayer's own committed Deneb-era test
///         vector (eigenlayer-contracts v1.12.0, MIT) for validator index 302913 — a genuine
///         `validators` List inclusion proof against a real beacon state root.
/// @dev Why Deneb: the only fork-dependent value in the verifier is the beacon-state tree
///      height (Deneb 5 / Pectra 6) and the two field gindexes derived from it. Everything
///      else — the `mix_in_length` +1 level, the 8-leaf validator merkleization, the
///      gindex-LSB traversal, LE balance extraction — is fork-independent. Proving our logic
///      accepts EigenLayer's REAL Deneb proof validates that entire fork-independent core
///      against real consensus data; the Pectra height is separately cross-checked against
///      EigenLayer's `PECTRA_BEACON_STATE_TREE_HEIGHT = 6` and the post-Electra field count.
///      A real Pectra fixture additionally requires a live Electra beacon-state endpoint +
///      the (MIT) eigenpod-proofs-generation generator; this test covers what is verifiable
///      offline today.
contract BeaconChainProofsRealFixtureTest is Test {
    string internal constant FIXTURE = "test/beacon/test-data/eigenlayer_deneb_validator_fields.json";

    /// @dev External boundary so `vm.expectRevert` can catch the library's revert (internal
    ///      library calls are inlined and have no CALL frame for expectRevert to observe).
    function callVerify(
        BeaconChainProofs.ProofVersion version,
        bytes32 beaconStateRoot,
        uint40 validatorIndex,
        ValidatorTypes.ValidatorFieldsProof calldata proof
    )
        external
        pure
        returns (bool)
    {
        return BeaconChainProofs.verifyValidatorFields(version, beaconStateRoot, validatorIndex, proof);
    }

    function _loadProof()
        internal
        view
        returns (bytes32 beaconStateRoot, uint40 validatorIndex, ValidatorTypes.ValidatorFieldsProof memory proof)
    {
        string memory json = vm.readFile(FIXTURE);
        beaconStateRoot = vm.parseJsonBytes32(json, ".beaconStateRoot");
        validatorIndex = uint40(vm.parseJsonUint(json, ".validatorIndex"));

        proof.validatorFields = vm.parseJsonBytes32Array(json, ".ValidatorFields");

        bytes32[] memory nodes = vm.parseJsonBytes32Array(json, ".ValidatorProof");
        bytes memory flat;
        for (uint256 i = 0; i < nodes.length; i++) {
            flat = abi.encodePacked(flat, nodes[i]);
        }
        proof.proof = flat;
    }

    /// @notice The real Deneb validator-fields proof verifies against the real state root.
    ///         This is the end-to-end validation no synthetic fixture can substitute for.
    function test_realDenebValidatorFieldsProof_verifies() public view {
        (bytes32 stateRoot, uint40 idx, ValidatorTypes.ValidatorFieldsProof memory proof) = _loadProof();

        // Sanity: this is EigenLayer's Deneb vector — 8 validator fields, 46-node proof
        // (= (VALIDATOR_TREE_HEIGHT + 1 + 5) nodes), validator index 302913.
        assertEq(proof.validatorFields.length, 8, "validator fields");
        assertEq(proof.proof.length, 46 * 32, "deneb validator proof = 46 nodes");
        assertEq(idx, 302_913, "fixture validator index");

        bool ok = BeaconChainProofs.verifyValidatorFields(BeaconChainProofs.ProofVersion.DENEB, stateRoot, idx, proof);
        assertTrue(ok, "real EigenLayer Deneb proof must verify against the real state root");
    }

    /// @notice The SAME real proof must be REJECTED under PECTRA — a Deneb proof is one merkle
    ///         level short of a Pectra one (46 vs 47 nodes), so the fork parameter is
    ///         load-bearing and our Pectra path is not silently accepting Deneb-shaped proofs.
    function test_denebProof_rejectedUnderPectra() public {
        (bytes32 stateRoot, uint40 idx, ValidatorTypes.ValidatorFieldsProof memory proof) = _loadProof();

        vm.expectRevert(BeaconChainProofs.InvalidProofLength.selector);
        this.callVerify(BeaconChainProofs.ProofVersion.PECTRA, stateRoot, idx, proof);
    }

    /// @notice Tampering any byte of the real proof breaks verification — confirms the proof is
    ///         actually constraining (not trivially passing).
    function test_realDenebProof_tamperedFails() public view {
        (bytes32 stateRoot, uint40 idx, ValidatorTypes.ValidatorFieldsProof memory proof) = _loadProof();

        // Flip one bit of the first validator field (the pubkey hash).
        proof.validatorFields[0] = bytes32(uint256(proof.validatorFields[0]) ^ 1);

        bool ok = BeaconChainProofs.verifyValidatorFields(BeaconChainProofs.ProofVersion.DENEB, stateRoot, idx, proof);
        assertFalse(ok, "tampered validator fields must not verify");
    }
}
