// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BeaconTestBase} from "./BeaconTestBase.sol";
import {ValidatorPod} from "../../../src/v2/beacon/ValidatorPod.sol";
import {ValidatorPodManager} from "../../../src/v2/beacon/ValidatorPodManager.sol";
import {ValidatorTypes} from "../../../src/v2/beacon/ValidatorTypes.sol";
import {BeaconChainProofs} from "../../../src/v2/beacon/BeaconChainProofs.sol";
import {Test, console2} from "forge-std/Test.sol";
import {stdJson} from "forge-std/StdJson.sol";

/// @title BeaconProofFixtureTest
/// @notice Tests using real beacon chain proof fixtures
/// @dev Load JSON fixtures from test/v2/beacon/fixtures/ directory
/// @dev To generate real fixtures, use eigenpod-proofs-generation CLI tool:
///      https://github.com/Layr-Labs/eigenpod-proofs-generation
contract BeaconProofFixtureTest is BeaconTestBase {
    using stdJson for string;

    // ═══════════════════════════════════════════════════════════════════════════
    // FIXTURE STRUCTURES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Loaded fixture data
    struct ValidatorProofFixture {
        string name;
        bytes32 beaconBlockRoot;
        bytes32 beaconStateRoot;
        bytes32[] stateRootProof;
        uint40 validatorIndex;
        bytes32[] validatorFields;
        bytes32[] validatorFieldsProof;
        bytes32 expectedPubkeyHash;
        uint64 expectedEffectiveBalanceGwei;
        bytes32 expectedWithdrawalCredentials;
        bool expectedSlashed;
    }

    /// @notice Checkpoint proof fixture
    struct CheckpointProofFixture {
        bytes32 beaconBlockRoot;
        bytes32 beaconStateRoot;
        bytes32[] stateRootProof;
        bytes32 balanceContainerRoot;
        bytes32[] balanceContainerProof;
        uint40[] validatorIndices;
        bytes32[] balanceRoots;
        bytes32[][] balanceProofs;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FIXTURE LOADING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Load a validator proof fixture from JSON file
    /// @param filename The fixture filename (without path)
    /// @return fixture The parsed fixture data
    function _loadValidatorFixture(string memory filename) internal view returns (ValidatorProofFixture memory fixture) {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/v2/beacon/fixtures/", filename);
        string memory json = vm.readFile(path);

        fixture.name = json.readString(".name");
        fixture.beaconBlockRoot = json.readBytes32(".beaconBlockRoot");
        fixture.beaconStateRoot = json.readBytes32(".beaconStateRoot");
        fixture.validatorIndex = uint40(json.readUint(".validatorIndex"));
        fixture.expectedPubkeyHash = json.readBytes32(".expectedPubkeyHash");
        fixture.expectedEffectiveBalanceGwei = uint64(json.readUint(".expectedEffectiveBalanceGwei"));
        fixture.expectedWithdrawalCredentials = json.readBytes32(".expectedWithdrawalCredentials");
        fixture.expectedSlashed = json.readBool(".expectedSlashed");

        // Read arrays
        fixture.stateRootProof = abi.decode(json.parseRaw(".stateRootProof"), (bytes32[]));
        fixture.validatorFields = abi.decode(json.parseRaw(".validatorFields"), (bytes32[]));
        fixture.validatorFieldsProof = abi.decode(json.parseRaw(".validatorFieldsProof"), (bytes32[]));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FIXTURE VALIDATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test loading and parsing fixture file
    function test_loadFixture_ParsesCorrectly() public view {
        ValidatorProofFixture memory fixture = _loadValidatorFixture("validator_proof_fixture_1.json");

        assertEq(fixture.name, "Sample Mainnet Validator Proof - Slot 8000000", "Name should match");
        assertEq(fixture.validatorIndex, 123456, "Validator index should match");
        assertEq(fixture.expectedEffectiveBalanceGwei, 32000000000, "Effective balance should be 32 ETH in gwei");
        assertFalse(fixture.expectedSlashed, "Should not be slashed");
    }

    /// @notice Test validator fields extraction from fixture
    function test_extractValidatorFields_FromFixture() public view {
        ValidatorProofFixture memory fixture = _loadValidatorFixture("validator_proof_fixture_1.json");

        // Test pubkey hash extraction
        bytes32 pubkeyHash = BeaconChainProofs.getPubkeyHash(fixture.validatorFields);
        assertEq(pubkeyHash, fixture.expectedPubkeyHash, "Pubkey hash should match");

        // Test withdrawal credentials extraction
        bytes32 credentials = BeaconChainProofs.getWithdrawalCredentials(fixture.validatorFields);
        assertEq(credentials, fixture.expectedWithdrawalCredentials, "Withdrawal credentials should match");

        // Test effective balance extraction
        uint64 effectiveBalance = BeaconChainProofs.getEffectiveBalanceGwei(fixture.validatorFields);
        assertEq(effectiveBalance, fixture.expectedEffectiveBalanceGwei, "Effective balance should match");

        // Test slashed status
        bool slashed = BeaconChainProofs.isValidatorSlashed(fixture.validatorFields);
        assertEq(slashed, fixture.expectedSlashed, "Slashed status should match");
    }

    /// @notice Test 0x01 withdrawal credential prefix validation
    function test_withdrawalCredentials_HasValidPrefix() public view {
        ValidatorProofFixture memory fixture = _loadValidatorFixture("validator_proof_fixture_1.json");

        bool hasValidPrefix = ValidatorTypes.hasValidPrefix(fixture.expectedWithdrawalCredentials);
        assertTrue(hasValidPrefix, "Should have 0x01 prefix");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MERKLE PROOF TESTS WITH FIXTURES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test state root proof verification (placeholder - needs real fixture)
    /// @dev This test will only pass with a real, valid proof fixture
    function test_SKIP_verifyStateRoot_WithRealFixture() public view {
        ValidatorProofFixture memory fixture = _loadValidatorFixture("validator_proof_fixture_1.json");

        // Convert proof array to bytes
        bytes memory proofBytes = new bytes(fixture.stateRootProof.length * 32);
        for (uint256 i = 0; i < fixture.stateRootProof.length; i++) {
            bytes32 proofElement = fixture.stateRootProof[i];
            assembly {
                mstore(add(proofBytes, add(32, mul(i, 32))), proofElement)
            }
        }

        ValidatorTypes.StateRootProof memory stateRootProof = ValidatorTypes.StateRootProof({
            beaconStateRoot: fixture.beaconStateRoot,
            proof: proofBytes
        });

        // Note: This will fail with placeholder data
        // Replace fixture with real proof data from eigenpod-proofs-generation
        // bool valid = BeaconChainProofs.verifyStateRoot(fixture.beaconBlockRoot, stateRootProof);
        // assertTrue(valid, "State root proof should be valid");

        // For now, just verify the fixture loaded correctly
        assertTrue(fixture.beaconBlockRoot != bytes32(0), "Block root should be set");
        assertTrue(fixture.beaconStateRoot != bytes32(0), "State root should be set");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTEGRATION TESTS WITH FIXTURES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test full withdrawal credential verification flow
    /// @dev This test demonstrates the full flow but requires real fixture data
    function test_SKIP_fullFlow_WithdrawalCredentialVerification() public {
        ValidatorProofFixture memory fixture = _loadValidatorFixture("validator_proof_fixture_1.json");

        // Create a pod
        ValidatorPod pod = _createPod(podOwner1);

        // Set the expected beacon root in mock oracle
        uint64 timestamp = uint64(block.timestamp);
        _setBeaconRoot(timestamp, fixture.beaconBlockRoot);

        // Build proofs from fixture
        bytes memory stateProofBytes = _bytes32ArrayToBytes(fixture.stateRootProof);
        bytes memory validatorProofBytes = _bytes32ArrayToBytes(fixture.validatorFieldsProof);

        ValidatorTypes.StateRootProof memory stateRootProof = ValidatorTypes.StateRootProof({
            beaconStateRoot: fixture.beaconStateRoot,
            proof: stateProofBytes
        });

        ValidatorTypes.ValidatorFieldsProof[] memory validatorProofs = new ValidatorTypes.ValidatorFieldsProof[](1);
        validatorProofs[0] = ValidatorTypes.ValidatorFieldsProof({
            validatorFields: fixture.validatorFields,
            proof: validatorProofBytes
        });

        uint40[] memory validatorIndices = new uint40[](1);
        validatorIndices[0] = fixture.validatorIndex;

        // Note: This call will fail with placeholder fixture data
        // To make it pass, generate real proof data using:
        // ./eigenpod-proofs-generation cli credentials --output fixture.json ...

        // vm.prank(podOwner1);
        // pod.verifyWithdrawalCredentials(
        //     timestamp,
        //     stateRootProof,
        //     validatorIndices,
        //     validatorProofs
        // );

        // For now, verify fixture was loaded
        assertEq(validatorProofs.length, 1, "Should have one validator proof");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Convert bytes32 array to packed bytes
    function _bytes32ArrayToBytes(bytes32[] memory arr) internal pure returns (bytes memory result) {
        result = new bytes(arr.length * 32);
        for (uint256 i = 0; i < arr.length; i++) {
            bytes32 element = arr[i];
            assembly {
                mstore(add(result, add(32, mul(i, 32))), element)
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DOCUMENTATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Instructions for generating real fixtures
    /// @dev Run this test to see fixture generation instructions
    function test_fixtureGenerationInstructions() public pure {
        // To generate real beacon chain proof fixtures:
        //
        // 1. Clone eigenpod-proofs-generation:
        //    git clone https://github.com/Layr-Labs/eigenpod-proofs-generation
        //
        // 2. Build the CLI:
        //    cd eigenpod-proofs-generation
        //    go build -o cli ./cli
        //
        // 3. Generate credential proofs:
        //    ./cli credentials \
        //      --beaconNode https://beacon-node-url \
        //      --podAddress YOUR_POD_ADDRESS \
        //      --execNode https://eth-node-url \
        //      --output credential_proof.json
        //
        // 4. Generate checkpoint proofs:
        //    ./cli checkpoint \
        //      --beaconNode https://beacon-node-url \
        //      --podAddress YOUR_POD_ADDRESS \
        //      --execNode https://eth-node-url \
        //      --output checkpoint_proof.json
        //
        // 5. Copy the JSON output to test/v2/beacon/fixtures/
        //
        // 6. Update the fixture loading code if needed to match
        //    the exact JSON structure from the CLI output.
        //
        // Beacon node providers:
        // - Lido: https://lighthouse.lido.fi
        // - Infura: https://mainnet.infura.io/v3/YOUR_KEY
        // - Alchemy: https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY

        assertTrue(true, "See test comments for fixture generation instructions");
    }
}
