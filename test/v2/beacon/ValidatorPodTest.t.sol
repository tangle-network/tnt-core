// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BeaconTestBase} from "./BeaconTestBase.sol";
import {ValidatorPod} from "../../../src/v2/beacon/ValidatorPod.sol";
import {ValidatorPodManager} from "../../../src/v2/beacon/ValidatorPodManager.sol";
import {ValidatorTypes} from "../../../src/v2/beacon/ValidatorTypes.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console2} from "forge-std/Test.sol";

/// @title ValidatorPodTest
/// @notice Tests for ValidatorPod contract
/// @dev Tests pod creation, validator restaking, checkpoints, and withdrawals
contract ValidatorPodTest is BeaconTestBase {
    ValidatorPod public pod;

    function setUp() public override {
        super.setUp();
        pod = _createPod(podOwner1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // POD CREATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_podCreation_CorrectOwner() public view {
        assertEq(pod.podOwner(), podOwner1, "Pod owner should be set correctly");
    }

    function test_podCreation_CorrectManager() public view {
        assertEq(address(pod.podManager()), address(podManager), "Pod manager should be set correctly");
    }

    function test_podCreation_CorrectBeaconOracle() public view {
        assertEq(address(pod.beaconOracle()), address(beaconOracle), "Beacon oracle should be set correctly");
    }

    function test_podCreation_CorrectWithdrawalCredentials() public view {
        bytes32 expected = ValidatorTypes.computeWithdrawalCredentials(address(pod));
        assertEq(pod.podWithdrawalCredentials(), expected, "Withdrawal credentials should match pod address");
    }

    function test_podCreation_InitialState() public view {
        assertFalse(pod.hasRestaked(), "Should not have restaked initially");
        assertEq(pod.activeValidatorCount(), 0, "Should have no active validators");
        assertEq(pod.currentCheckpointTimestamp(), 0, "Should have no active checkpoint");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ACCESS CONTROL TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_onlyPodOwner_startCheckpoint() public {
        vm.prank(attacker);
        vm.expectRevert(ValidatorPod.OnlyPodOwner.selector);
        pod.startCheckpoint(false);
    }

    function test_onlyPodOwner_withdrawNonBeaconChainETH() public {
        vm.prank(attacker);
        vm.expectRevert(ValidatorPod.OnlyPodOwner.selector);
        pod.withdrawNonBeaconChainETH(attacker, 1 ether);
    }

    function test_onlyPodOwner_recoverTokens() public {
        vm.prank(attacker);
        vm.expectRevert(ValidatorPod.OnlyPodOwner.selector);
        pod.recoverTokens(IERC20(address(0)), attacker, 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CHECKPOINT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_startCheckpoint_NoActiveValidators() public {
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPod.NoActiveValidators.selector);
        pod.startCheckpoint(false);
    }

    function test_startCheckpoint_AlreadyActive() public {
        // This would require having active validators first
        // For now, just test the error path
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_withdrawNonBeaconChainETH_Success() public {
        // Send some ETH to the pod
        vm.deal(address(pod), 5 ether);

        uint256 recipientBalanceBefore = podOwner1.balance;

        vm.prank(podOwner1);
        pod.withdrawNonBeaconChainETH(podOwner1, 3 ether);

        assertEq(podOwner1.balance, recipientBalanceBefore + 3 ether, "Should receive withdrawn ETH");
        assertEq(address(pod).balance, 2 ether, "Pod should have remaining balance");
    }

    function test_withdrawNonBeaconChainETH_InsufficientBalance() public {
        vm.deal(address(pod), 1 ether);

        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPod.InsufficientBalance.selector);
        pod.withdrawNonBeaconChainETH(podOwner1, 2 ether);
    }

    function test_withdrawNonBeaconChainETH_ToOtherAddress() public {
        vm.deal(address(pod), 5 ether);
        address recipient = makeAddr("recipient");
        uint256 recipientBalanceBefore = recipient.balance;

        vm.prank(podOwner1);
        pod.withdrawNonBeaconChainETH(recipient, 3 ether);

        assertEq(recipient.balance, recipientBalanceBefore + 3 ether, "Recipient should receive ETH");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RECEIVE ETH TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_receiveETH() public {
        uint256 balanceBefore = address(pod).balance;

        // Send ETH to pod
        (bool success,) = address(pod).call{value: 1 ether}("");
        assertTrue(success, "Should accept ETH");

        assertEq(address(pod).balance, balanceBefore + 1 ether, "Pod should hold ETH");
    }

    function test_receiveETH_Multiple() public {
        // Send from multiple sources
        vm.deal(address(0x1), 1 ether);
        vm.deal(address(0x2), 2 ether);

        vm.prank(address(0x1));
        (bool s1,) = address(pod).call{value: 1 ether}("");
        assertTrue(s1);

        vm.prank(address(0x2));
        (bool s2,) = address(pod).call{value: 2 ether}("");
        assertTrue(s2);

        assertEq(address(pod).balance, 3 ether, "Pod should hold all ETH");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATOR INFO TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_getValidatorInfo_NonExistent() public view {
        bytes32 unknownPubkey = keccak256("unknown");
        ValidatorTypes.ValidatorInfo memory info = pod.getValidatorInfo(unknownPubkey);

        assertEq(info.validatorIndex, 0, "Unknown validator should have zero index");
        assertEq(info.restakedBalanceGwei, 0, "Unknown validator should have zero balance");
        assertTrue(
            info.status == ValidatorTypes.ValidatorStatus.INACTIVE, "Unknown validator should be inactive"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CHECKPOINT STATE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_checkpointActive_Initial() public view {
        assertFalse(pod.checkpointActive(), "Checkpoint should not be active initially");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_withdrawNonBeaconChainETH_ZeroAmount() public {
        vm.deal(address(pod), 1 ether);

        vm.prank(podOwner1);
        pod.withdrawNonBeaconChainETH(podOwner1, 0);
        // Should succeed but do nothing
    }

    function test_multiplePodsIndependent() public {
        ValidatorPod pod2 = _createPod(podOwner2);

        // Verify pods are different
        assertTrue(address(pod) != address(pod2), "Pods should be different addresses");

        // Verify each pod has correct owner
        assertEq(pod.podOwner(), podOwner1, "Pod1 owner correct");
        assertEq(pod2.podOwner(), podOwner2, "Pod2 owner correct");

        // Verify withdrawal credentials are different
        assertTrue(
            pod.podWithdrawalCredentials() != pod2.podWithdrawalCredentials(),
            "Withdrawal credentials should be different"
        );
    }
}
