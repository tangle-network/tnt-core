// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";

import { BlueprintServiceManagerBase } from "../src/BlueprintServiceManagerBase.sol";
import { IBlueprintServiceManager } from "../src/interfaces/IBlueprintServiceManager.sol";
import { Types } from "../src/libraries/Types.sol";
import { Errors } from "../src/libraries/Errors.sol";
import { PaymentLib } from "../src/libraries/PaymentLib.sol";

/// @title MockBSM_StakeRequirement
/// @notice BSM that enforces custom minimum stake requirements
contract MockBSM_StakeRequirement is BlueprintServiceManagerBase {
    uint256 public customMinStake;
    bool public useDefaultStake;

    function setMinStakeRequirement(uint256 minStake, bool useDefault) external {
        customMinStake = minStake;
        useDefaultStake = useDefault;
    }

    function getMinOperatorStake() external view override returns (bool useDefault, uint256 minStake) {
        return (useDefaultStake, customMinStake);
    }

    function onBlueprintCreated(uint64 _blueprintId, address owner, address _tangleCore) external override {
        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = _tangleCore;
    }

    function onRegister(address, bytes calldata) external payable override onlyFromTangle {}
    function onUnregister(address) external override onlyFromTangle {}
    function onUpdatePreferences(address, bytes calldata) external payable override onlyFromTangle {}
    function onRequest(uint64, address, address[] calldata, bytes calldata, uint64, address, uint256) external payable override onlyFromTangle {}
    function onApprove(address, uint64, uint8) external payable override onlyFromTangle {}
    function onReject(address, uint64) external override onlyFromTangle {}
    function onServiceInitialized(uint64, uint64, uint64, address, address[] calldata, uint64) external override onlyFromTangle {}
    function onServiceTermination(uint64, address) external override onlyFromTangle {}
    function onJobCall(uint64, uint8, uint64, bytes calldata) external payable override onlyFromTangle {}
    function onJobResult(uint64, uint8, uint64, address, bytes calldata, bytes calldata) external payable override onlyFromTangle {}
    function onUnappliedSlash(uint64, bytes calldata, uint8) external override onlyFromTangle {}
    function onSlash(uint64, bytes calldata, uint8) external override onlyFromTangle {}
    function onOperatorJoined(uint64, address, uint16) external override onlyFromTangle {}
    function onOperatorLeft(uint64, address) external override onlyFromTangle {}
}

/// @title StakeRequirementTests
/// @notice Tests covering operator stake validation, operator count bounds, and payment refunds
contract StakeRequirementTests is BaseTest {
    MockBSM_StakeRequirement public mockBsm;

    address public operator4 = makeAddr("operator4");

    function setUp() public override {
        super.setUp();

        mockBsm = new MockBSM_StakeRequirement();

        vm.deal(operator4, 100 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE VALIDATION TESTS - registerOperator
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RegisterOperator_WithDefaultMinStake_Success() public {
        // Register with staking at minimum stake
        vm.prank(operator1);
        staking.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Create blueprint without BSM
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(0)));

        // Should succeed with exactly minimum stake
        _directRegisterOperator(operator1, blueprintId, "");

        assertTrue(tangle.isOperatorRegistered(blueprintId, operator1));
    }

    function test_RegisterOperator_BelowDefaultMinStake_Reverts() public {
        // Register with staking at below minimum (shouldn't be possible with restaking's own checks)
        // But we test the Tangle contract's check by using a higher custom minimum
        vm.prank(operator1);
        staking.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Create blueprint with BSM requiring higher stake
        mockBsm.setMinStakeRequirement(5 ether, false); // Custom 5 ETH minimum
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(mockBsm)));

        // Should revert - operator has 1 ETH but BSM requires 5 ETH
        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.InsufficientStake.selector, operator1, 5 ether, MIN_OPERATOR_STAKE)
        );
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator1, 0), "");
    }

    function test_RegisterOperator_WithCustomBSMMinStake_Success() public {
        // Register with staking at 10 ETH
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();

        // Create blueprint with BSM requiring 5 ETH
        mockBsm.setMinStakeRequirement(5 ether, false);
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(mockBsm)));

        // Should succeed - operator has 10 ETH, BSM requires 5 ETH
        _directRegisterOperator(operator1, blueprintId, "");

        assertTrue(tangle.isOperatorRegistered(blueprintId, operator1));
    }

    function test_RegisterOperator_BSMUsesDefaultStake_Success() public {
        // Register with minimum stake
        vm.prank(operator1);
        staking.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Create blueprint with BSM using default stake (useDefault=true)
        mockBsm.setMinStakeRequirement(10 ether, true); // High value but useDefault=true
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(mockBsm)));

        // Should succeed - uses protocol default (1 ETH)
        _directRegisterOperator(operator1, blueprintId, "");

        assertTrue(tangle.isOperatorRegistered(blueprintId, operator1));
    }

    function test_RegisterOperator_BSMReturnsZeroCustomStake_UsesDefault() public {
        // Register with minimum stake
        vm.prank(operator1);
        staking.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Create blueprint with BSM returning 0 for custom stake
        mockBsm.setMinStakeRequirement(0, false);
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(mockBsm)));

        // Should succeed - 0 custom stake means use default
        _directRegisterOperator(operator1, blueprintId, "");

        assertTrue(tangle.isOperatorRegistered(blueprintId, operator1));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE VALIDATION TESTS - joinService
    // ═══════════════════════════════════════════════════════════════════════════

    function test_JoinService_StakeRevalidated_Success() public {
        // Setup: operator1 with high stake, create dynamic service
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();

        mockBsm.setMinStakeRequirement(5 ether, false);
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(mockBsm), config));

        _directRegisterOperator(operator1, blueprintId, "");

        // Create service with operator1
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // operator2 registers with sufficient stake and joins
        vm.prank(operator2);
        staking.registerOperator{ value: 10 ether }();

        _directRegisterOperator(operator2, blueprintId, "");

        vm.prank(operator2);
        tangle.joinService(serviceId, 10000);

        assertTrue(tangle.isServiceOperator(serviceId, operator2));
    }

    function test_JoinService_StakeRevalidation_Reverts_AfterSlash() public {
        // Setup: operator1 creates service
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();

        mockBsm.setMinStakeRequirement(5 ether, false);
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(mockBsm), config));

        _directRegisterOperator(operator1, blueprintId, "");

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // operator2 registers with 6 ETH (above minimum)
        vm.prank(operator2);
        staking.registerOperator{ value: 6 ether }();

        _directRegisterOperator(operator2, blueprintId, "");

        // Slash operator2 to below minimum
        vm.prank(address(tangle));
        staking.slash(operator2, 0, 5000, keccak256("test"));

        // Now operator2 has ~3 ETH, below 5 ETH minimum
        // Try to join service should fail
        vm.prank(operator2);
        vm.expectRevert(); // InsufficientStake
        tangle.joinService(serviceId, 10000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR COUNT VALIDATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RequestService_MinOperators_Success() public {
        // Setup operators
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();
        vm.prank(operator2);
        staking.registerOperator{ value: 5 ether }();

        // Create blueprint requiring minimum 2 operators
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 2,
            maxOperators: 5,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");
        _directRegisterOperator(operator2, blueprintId, "");

        // Request with exactly 2 operators - should succeed
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        assertLt(requestId, 100); // Valid request ID (starts from 0 or 1)
    }

    function test_RequestService_BelowMinOperators_Reverts() public {
        // Setup operator
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();

        // Create blueprint requiring minimum 3 operators
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 3,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");

        // Request with only 1 operator - should revert
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientOperators.selector, 3, 1));
        tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);
    }

    function test_RequestService_AboveMaxOperators_Reverts() public {
        // Setup 4 operators
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();
        vm.prank(operator2);
        staking.registerOperator{ value: 5 ether }();
        vm.prank(operator3);
        staking.registerOperator{ value: 5 ether }();
        vm.prank(operator4);
        staking.registerOperator{ value: 5 ether }();

        // Create blueprint with max 2 operators
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 2,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");
        _directRegisterOperator(operator2, blueprintId, "");
        _directRegisterOperator(operator3, blueprintId, "");

        // Request with 3 operators - should revert
        address[] memory ops = new address[](3);
        ops[0] = operator1;
        ops[1] = operator2;
        ops[2] = operator3;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.TooManyOperators.selector, 2, 3));
        tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);
    }

    function test_RequestService_MaxOperatorsZero_NoLimit() public {
        // Setup 3 operators
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();
        vm.prank(operator2);
        staking.registerOperator{ value: 5 ether }();
        vm.prank(operator3);
        staking.registerOperator{ value: 5 ether }();

        // Create blueprint with maxOperators=0 (no limit)
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 0, // No limit
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");
        _directRegisterOperator(operator2, blueprintId, "");
        _directRegisterOperator(operator3, blueprintId, "");

        // Request with 3 operators - should succeed
        address[] memory ops = new address[](3);
        ops[0] = operator1;
        ops[1] = operator2;
        ops[2] = operator3;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);
    }

    function test_RequestService_MinOperatorsZero_DefaultsToOne() public {
        // Setup operator
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();

        // Create blueprint with minOperators=0 (should default to 1)
        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 0, // Should default to 1
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");

        // Request with 1 operator - should succeed
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXCESS ETH REFUND TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_FundService_ExcessETH_Refunded() public {
        // Setup subscription service
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();

        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: 1 ether }(
            blueprintId, ops, "", callers, 365 days, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Fund with excess ETH
        uint256 userBalanceBefore = user1.balance;

        vm.prank(user1);
        tangle.fundService{ value: 2 ether }(serviceId, 1 ether); // Send 2 ETH but only deposit 1 ETH

        uint256 userBalanceAfter = user1.balance;

        // User should have received 1 ETH refund
        assertEq(userBalanceBefore - userBalanceAfter, 1 ether, "User should only lose 1 ETH (excess refunded)");

        // Escrow should have 2 ETH (1 initial + 1 funded)
        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        assertEq(escrow.balance, 2 ether);
    }

    function test_FundService_ExactAmount_NoRefund() public {
        // Setup subscription service
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();

        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: 1 ether }(
            blueprintId, ops, "", callers, 365 days, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Fund with exact amount
        uint256 userBalanceBefore = user1.balance;

        vm.prank(user1);
        tangle.fundService{ value: 1 ether }(serviceId, 1 ether);

        uint256 userBalanceAfter = user1.balance;

        // User should have lost exactly 1 ETH
        assertEq(userBalanceBefore - userBalanceAfter, 1 ether);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        assertEq(escrow.balance, 2 ether);
    }

    function test_FundService_ZeroExcess_Works() public {
        // Setup subscription service
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();

        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: 1 ether }(
            blueprintId, ops, "", callers, 365 days, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        // Fund with exact value=amount
        vm.prank(user1);
        tangle.fundService{ value: 0.5 ether }(serviceId, 0.5 ether);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        assertEq(escrow.balance, 1.5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BOUNDARY CONDITION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_OperatorCount_ExactlyAtMin() public {
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();
        vm.prank(operator2);
        staking.registerOperator{ value: 5 ether }();

        vm.prank(developer);
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 2,
            maxOperators: 2, // Exactly 2 required
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://test", address(0), config));

        _directRegisterOperator(operator1, blueprintId, "");
        _directRegisterOperator(operator2, blueprintId, "");

        // Request with exactly 2 operators - should succeed
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);
    }

    function test_StakeRequirement_ExactlyAtMinimum() public {
        // Register with exactly the custom minimum
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether }();

        mockBsm.setMinStakeRequirement(5 ether, false);
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(mockBsm)));

        // Should succeed with exactly minimum stake
        _directRegisterOperator(operator1, blueprintId, "");

        assertTrue(tangle.isOperatorRegistered(blueprintId, operator1));
    }

    function test_StakeRequirement_OneWeiBelow() public {
        // Register with one wei below the custom minimum
        vm.prank(operator1);
        staking.registerOperator{ value: 5 ether - 1 }();

        mockBsm.setMinStakeRequirement(5 ether, false);
        vm.prank(developer);
        uint64 blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://test", address(mockBsm)));

        // Should revert - one wei below minimum
        vm.prank(operator1);
        vm.expectRevert(); // InsufficientStake
        tangle.registerOperator(blueprintId, "", "");
    }
}
