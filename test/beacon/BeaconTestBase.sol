// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ValidatorPod} from "../../src/beacon/ValidatorPod.sol";
import {ValidatorPodManager} from "../../src/beacon/ValidatorPodManager.sol";
import {ValidatorTypes} from "../../src/beacon/ValidatorTypes.sol";
import {MockBeaconOracle} from "../../src/beacon/BeaconRootReceiver.sol";

/// @title BeaconTestBase
/// @notice Base test contract for beacon chain staking tests
abstract contract BeaconTestBase is Test {
    function assertEq(
        ValidatorTypes.ValidatorStatus left,
        ValidatorTypes.ValidatorStatus right,
        string memory err
    ) internal pure {
        if (left != right) {
            revert(err);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONTRACTS
    // ═══════════════════════════════════════════════════════════════════════════

    MockBeaconOracle public beaconOracle;
    ValidatorPodManager public podManager;

    // ═══════════════════════════════════════════════════════════════════════════
    // ACTORS
    // ═══════════════════════════════════════════════════════════════════════════

    address public admin = makeAddr("admin");
    address public podOwner1 = makeAddr("podOwner1");
    address public podOwner2 = makeAddr("podOwner2");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public slasher = makeAddr("slasher");
    address public attacker = makeAddr("attacker");

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    uint256 public constant MIN_OPERATOR_STAKE = 1 ether;
    uint64 public constant VALIDATOR_BALANCE_GWEI = 32_000_000_000; // 32 ETH
    uint64 public constant BEACON_TIMESTAMP = 1700000000;

    // ═══════════════════════════════════════════════════════════════════════════
    // SETUP
    // ═══════════════════════════════════════════════════════════════════════════

    function setUp() public virtual {
        // Deploy mock beacon oracle
        beaconOracle = new MockBeaconOracle();

        // Deploy pod manager
        vm.prank(admin);
        podManager = new ValidatorPodManager(address(beaconOracle), MIN_OPERATOR_STAKE);

        // Setup slasher
        vm.prank(admin);
        podManager.addSlasher(slasher);

        // Fund actors
        vm.deal(podOwner1, 100 ether);
        vm.deal(podOwner2, 100 ether);
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS - POD MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a pod for an owner
    function _createPod(address owner) internal returns (ValidatorPod) {
        vm.prank(owner);
        address podAddr = podManager.createPod();
        return ValidatorPod(payable(podAddr));
    }

    /// @notice Register an operator
    function _registerOperator(address operator, uint256 stake) internal {
        vm.prank(operator);
        podManager.registerOperator{value: stake}();
    }

    /// @notice Create a pod and give it shares for delegation testing
    /// @param owner The pod owner
    /// @param shares The amount of shares to grant (in wei)
    function _createPodWithShares(address owner, uint256 shares) internal returns (ValidatorPod) {
        ValidatorPod pod = _createPod(owner);
        // Prank as the pod to record a positive balance update
        vm.prank(address(pod));
        podManager.recordBeaconChainEthBalanceUpdate(owner, int256(shares));
        return pod;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS - MERKLE PROOF GENERATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Generate a simple valid Merkle proof for testing
    /// @dev Creates a minimal 2-level tree where leaf is at index 0
    function _generateSimpleMerkleProof(bytes32 leaf, bytes32 sibling)
        internal
        pure
        returns (bytes memory proof, bytes32 root)
    {
        // For a 2-element tree: root = sha256(leaf, sibling)
        root = sha256(abi.encodePacked(leaf, sibling));
        proof = abi.encodePacked(sibling);
    }

    /// @notice Generate a multi-level Merkle proof
    /// @param leaf The leaf to prove
    /// @param siblings Array of siblings at each level
    /// @param leafIndex The index of the leaf (determines left/right at each level)
    function _generateMerkleProof(
        bytes32 leaf,
        bytes32[] memory siblings,
        uint256 leafIndex
    ) internal pure returns (bytes memory proof, bytes32 root) {
        bytes32 current = leaf;
        proof = "";

        for (uint256 i = 0; i < siblings.length; i++) {
            proof = abi.encodePacked(proof, siblings[i]);

            if (leafIndex % 2 == 0) {
                current = sha256(abi.encodePacked(current, siblings[i]));
            } else {
                current = sha256(abi.encodePacked(siblings[i], current));
            }
            leafIndex = leafIndex / 2;
        }

        root = current;
    }

    /// @notice Generate mock validator fields
    function _generateValidatorFields(
        bytes32 pubkeyHash,
        bytes32 withdrawalCredentials,
        uint64 effectiveBalance,
        bool slashed,
        uint64 activationEpoch,
        uint64 exitEpoch
    ) internal pure returns (bytes32[] memory fields) {
        fields = new bytes32[](8);
        fields[0] = pubkeyHash;
        fields[1] = withdrawalCredentials;
        fields[2] = bytes32(uint256(effectiveBalance));
        fields[3] = slashed ? bytes32(uint256(1)) : bytes32(0);
        fields[4] = bytes32(uint256(activationEpoch)); // activation eligibility
        fields[5] = bytes32(uint256(activationEpoch));
        fields[6] = bytes32(uint256(exitEpoch));
        fields[7] = bytes32(uint256(exitEpoch + 256)); // withdrawable epoch
    }

    /// @notice Hash validator fields like the beacon chain does
    function _hashValidatorFields(bytes32[] memory fields) internal pure returns (bytes32) {
        bytes32 h0 = sha256(abi.encodePacked(fields[0], fields[1]));
        bytes32 h1 = sha256(abi.encodePacked(fields[2], fields[3]));
        bytes32 h2 = sha256(abi.encodePacked(fields[4], fields[5]));
        bytes32 h3 = sha256(abi.encodePacked(fields[6], fields[7]));

        bytes32 h01 = sha256(abi.encodePacked(h0, h1));
        bytes32 h23 = sha256(abi.encodePacked(h2, h3));

        return sha256(abi.encodePacked(h01, h23));
    }

    /// @notice Generate a balance root with 4 packed balances
    function _generateBalanceRoot(
        uint64 balance0,
        uint64 balance1,
        uint64 balance2,
        uint64 balance3
    ) internal pure returns (bytes32) {
        // Pack 4 64-bit balances into 32 bytes (little-endian)
        return bytes32(
            uint256(balance0) | (uint256(balance1) << 64) | (uint256(balance2) << 128)
                | (uint256(balance3) << 192)
        );
    }

    /// @notice Set up a beacon block root in the mock oracle
    function _setBeaconRoot(uint64 timestamp, bytes32 root) internal {
        beaconOracle.setBeaconBlockRoot(timestamp, root);
    }
}
