// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BeaconTestBase} from "./BeaconTestBase.sol";
import {ValidatorPod} from "../../../src/v2/beacon/ValidatorPod.sol";
import {ValidatorPodManager} from "../../../src/v2/beacon/ValidatorPodManager.sol";
import {ValidatorTypes} from "../../../src/v2/beacon/ValidatorTypes.sol";
import {BeaconChainProofs} from "../../../src/v2/beacon/BeaconChainProofs.sol";
import {console2} from "forge-std/Test.sol";

/// @title BeaconIntegrationTest
/// @notice Integration tests for the full beacon chain restaking flow
/// @dev Tests end-to-end scenarios including proof verification, checkpoints, and slashing
contract BeaconIntegrationTest is BeaconTestBase {
    // ═══════════════════════════════════════════════════════════════════════════
    // TEST FIXTURES (EigenLayer-style)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Fixture representing a complete validator proof
    struct ValidatorProofFixture {
        bytes32 beaconBlockRoot;
        bytes32 beaconStateRoot;
        bytes stateRootProof;
        uint40 validatorIndex;
        bytes32[] validatorFields;
        bytes validatorFieldsProof;
    }

    /// @notice Fixture representing a balance update proof
    struct BalanceProofFixture {
        bytes32 beaconBlockRoot;
        bytes32 balanceContainerRoot;
        bytes balanceContainerProof;
        bytes32 pubkeyHash;
        bytes32 balanceRoot;
        bytes balanceProof;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FULL FLOW TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_fullFlow_CreatePodAndRegisterOperator() public {
        // Step 1: Create pod
        ValidatorPod pod = _createPod(podOwner1);
        assertTrue(address(pod) != address(0), "Pod should be created");

        // Step 2: Register operator
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        assertTrue(podManager.isOperator(operator1), "Operator should be registered");

        // Step 3: Verify pod can receive ETH (simulating validator rewards)
        vm.deal(address(pod), 32 ether);
        assertEq(address(pod).balance, 32 ether, "Pod should hold ETH");

        // Step 4: Pod owner can withdraw non-beacon ETH
        vm.prank(podOwner1);
        pod.withdrawNonBeaconChainETH(podOwner1, 1 ether);
        assertEq(address(pod).balance, 31 ether, "Pod should have remaining ETH");
    }

    function test_fullFlow_MultipleOperatorsWithDelegation() public {
        // Create pods
        ValidatorPod pod1 = _createPod(podOwner1);
        ValidatorPod pod2 = _createPod(podOwner2);

        // Register operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 3 ether);

        // Simulate beacon balance updates (would normally come from proof verification)
        vm.prank(address(pod1));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 64 ether);

        vm.prank(address(pod2));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner2, 32 ether);

        // Verify total shares
        assertEq(podManager.totalShares(), 96 ether, "Total shares should be 96 ETH");

        // Delegate to operators
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);

        vm.prank(podOwner1);
        podManager.delegateTo(operator2, 16 ether);

        // Verify delegations
        assertEq(podManager.getDelegation(podOwner1, operator1), 32 ether, "Delegation to op1 correct");
        assertEq(podManager.getDelegation(podOwner1, operator2), 16 ether, "Delegation to op2 correct");
        assertEq(podManager.getOperatorDelegatedStake(operator1), 32 ether, "Op1 delegated stake correct");
    }

    function test_fullFlow_SlashingReducesStake() public {
        // Setup
        _registerOperator(operator1, 10 ether);
        ValidatorPod pod = _createPod(podOwner1);

        // Record some shares
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 64 ether);

        // Delegate to operator
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);

        uint256 totalStakeBefore = podManager.getOperatorStake(operator1);
        assertEq(totalStakeBefore, 42 ether, "Total stake should be 10 + 32");

        // Slash the operator
        vm.prank(slasher);
        uint256 slashed = podManager.slash(operator1, 1, 15 ether, keccak256("misbehavior"));

        assertEq(slashed, 15 ether, "Should slash 15 ETH");

        // Self-stake slashed first (10 ETH), then 5 ETH from delegated
        assertEq(podManager.getOperatorSelfStake(operator1), 0, "Self stake should be fully slashed");
        assertEq(podManager.getOperatorDelegatedStake(operator1), 27 ether, "Delegated stake should be reduced");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // WITHDRAWAL CREDENTIAL TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_withdrawalCredentials_MatchesPodAddress() public {
        ValidatorPod pod = _createPod(podOwner1);

        bytes32 credentials = pod.podWithdrawalCredentials();
        bytes32 expected = ValidatorTypes.computeWithdrawalCredentials(address(pod));

        assertEq(credentials, expected, "Credentials should match computed value");

        // Verify it has the 0x01 prefix
        assertTrue(ValidatorTypes.hasValidPrefix(credentials), "Should have 0x01 prefix");

        // Verify we can extract the address back
        address extracted = ValidatorTypes.getAddressFromCredentials(credentials);
        assertEq(extracted, address(pod), "Extracted address should match pod");
    }

    function test_withdrawalCredentials_UniquePerPod() public {
        ValidatorPod pod1 = _createPod(podOwner1);
        ValidatorPod pod2 = _createPod(podOwner2);

        bytes32 cred1 = pod1.podWithdrawalCredentials();
        bytes32 cred2 = pod2.podWithdrawalCredentials();

        assertTrue(cred1 != cred2, "Different pods should have different credentials");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE ACCOUNTING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_shareAccounting_PositiveAndNegative() public {
        ValidatorPod pod = _createPod(podOwner1);

        // Initial positive update (validator restaking)
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);
        assertEq(podManager.getShares(podOwner1), 32 ether, "Initial shares");

        // Positive update (balance increase)
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 1 ether);
        assertEq(podManager.getShares(podOwner1), 33 ether, "After increase");

        // Negative update (slashing on beacon chain)
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, -5 ether);
        assertEq(podManager.getShares(podOwner1), 28 ether, "After slashing");

        // Large negative (can go negative if slashed more than deposited)
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, -30 ether);
        assertEq(podManager.getShares(podOwner1), -2 ether, "Shares can be negative");
    }

    function test_shareAccounting_TotalSharesTracking() public {
        ValidatorPod pod1 = _createPod(podOwner1);
        ValidatorPod pod2 = _createPod(podOwner2);

        vm.prank(address(pod1));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);

        vm.prank(address(pod2));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner2, 64 ether);

        assertEq(podManager.totalShares(), 96 ether, "Total should be sum");

        // Negative update
        vm.prank(address(pod1));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, -10 ether);

        assertEq(podManager.totalShares(), 86 ether, "Total should decrease");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR STAKE REQUIREMENT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_operatorStake_MeetsRequirementWithDelegation() public {
        // Operator with 1 ETH self-stake
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // Initially only has 1 ETH
        assertFalse(podManager.meetsStakeRequirement(operator1, 5 ether), "Should not meet 5 ETH");

        // Create pod and delegate
        ValidatorPod pod = _createPod(podOwner1);
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);

        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 10 ether);

        // Now has 11 ETH total
        assertTrue(podManager.meetsStakeRequirement(operator1, 5 ether), "Should meet 5 ETH");
        assertTrue(podManager.meetsStakeRequirement(operator1, 11 ether), "Should meet exact 11 ETH");
        assertFalse(podManager.meetsStakeRequirement(operator1, 12 ether), "Should not meet 12 ETH");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES AND SECURITY TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_security_CannotCreateMultiplePods() public {
        vm.prank(podOwner1);
        podManager.createPod();

        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.PodAlreadyExists.selector);
        podManager.createPod();
    }

    function test_security_OnlyPodCanUpdateShares() public {
        ValidatorPod pod = _createPod(podOwner1);

        // Attacker tries to update shares
        vm.prank(attacker);
        vm.expectRevert(ValidatorPodManager.OnlyPod.selector);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 1000 ether);

        // Pod owner tries directly (not through pod)
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.OnlyPod.selector);
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 1000 ether);

        // Only the actual pod contract should work
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);
        assertEq(podManager.getShares(podOwner1), 32 ether, "Update from pod should work");
    }

    function test_security_CannotOverDelegate() public {
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        ValidatorPod pod = _createPod(podOwner1);

        // Record 32 ETH of shares
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);

        // Try to delegate more than available
        vm.prank(podOwner1);
        vm.expectRevert(ValidatorPodManager.InsufficientShares.selector);
        podManager.delegateTo(operator1, 40 ether);
    }

    function test_security_SlashingOnlyByAuthorized() public {
        _registerOperator(operator1, 5 ether);

        // Unauthorized slashing attempt
        vm.prank(attacker);
        vm.expectRevert(ValidatorPodManager.NotAuthorizedSlasher.selector);
        podManager.slash(operator1, 1, 1 ether, bytes32(0));

        // Authorized slashing works
        vm.prank(slasher);
        podManager.slash(operator1, 1, 1 ether, bytes32(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GAS BENCHMARKS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_gas_createPod() public {
        uint256 gasBefore = gasleft();
        vm.prank(podOwner1);
        podManager.createPod();
        uint256 gasUsed = gasBefore - gasleft();

        console2.log("Gas used for createPod:", gasUsed);
        // Pod creation deploys a new contract, ~2.1M gas with ELIP-004 slashing factor
        assertTrue(gasUsed < 2_200_000, "Pod creation should use less than 2.2M gas");
    }

    function test_gas_registerOperator() public {
        uint256 gasBefore = gasleft();
        vm.prank(operator1);
        podManager.registerOperator{value: MIN_OPERATOR_STAKE}();
        uint256 gasUsed = gasBefore - gasleft();

        console2.log("Gas used for registerOperator:", gasUsed);
        assertTrue(gasUsed < 100_000, "Operator registration should use less than 100k gas");
    }

    function test_gas_recordBalanceUpdate() public {
        ValidatorPod pod = _createPod(podOwner1);

        uint256 gasBefore = gasleft();
        vm.prank(address(pod));
        podManager.recordBeaconChainETHBalanceUpdate(podOwner1, 32 ether);
        uint256 gasUsed = gasBefore - gasleft();

        console2.log("Gas used for recordBeaconChainETHBalanceUpdate:", gasUsed);
        assertTrue(gasUsed < 50_000, "Balance update should use less than 50k gas");
    }
}
