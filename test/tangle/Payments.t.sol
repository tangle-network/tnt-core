// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";
import { MockServiceFeeDistributor } from "../mocks/MockServiceFeeDistributor.sol";

/// @title PaymentsTest
/// @notice Comprehensive tests for payment distribution, escrow, and rewards
contract PaymentsTest is BaseTest {
    MockERC20 public token;
    MockServiceFeeDistributor public serviceFeeDistributor;
    uint64 blueprintId;

    function setUp() public override {
        super.setUp();

        serviceFeeDistributor = new MockServiceFeeDistributor();
        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(serviceFeeDistributor));
        staking.setServiceFeeDistributor(address(serviceFeeDistributor));
        vm.stopPrank();

        // Deploy mock token and fund users (constructor initializes with default name/symbol)
        token = new MockERC20();
        token.mint(user1, 1000 ether);
        token.mint(user2, 1000 ether);

        // Setup blueprint
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://payment-test", address(0)));

        // Register operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT SPLIT CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_PaymentSplit_DefaultValues() public view {
        (uint16 dev, uint16 proto, uint16 op, uint16 rest) = tangle.paymentSplit();
        assertEq(dev, 2000); // 20%
        assertEq(proto, 2000); // 20%
        assertEq(op, 4000); // 40%
        assertEq(rest, 2000); // 20%
        assertEq(dev + proto + op + rest, 10_000);
    }

    function test_SetPaymentSplit_ValidConfiguration() public {
        Types.PaymentSplit memory newSplit =
            Types.PaymentSplit({ developerBps: 4000, protocolBps: 2000, operatorBps: 2500, stakerBps: 1500 });

        vm.prank(admin);
        tangle.setPaymentSplit(newSplit);

        (uint16 dev, uint16 proto, uint16 op, uint16 rest) = tangle.paymentSplit();
        assertEq(dev, 4000);
        assertEq(proto, 2000);
        assertEq(op, 2500);
        assertEq(rest, 1500);
    }

    function test_SetPaymentSplit_RevertNotAdmin() public {
        Types.PaymentSplit memory newSplit =
            Types.PaymentSplit({ developerBps: 4000, protocolBps: 2000, operatorBps: 2500, stakerBps: 1500 });

        vm.prank(user1);
        vm.expectRevert();
        tangle.setPaymentSplit(newSplit);
    }

    function test_SetPaymentSplit_RevertTotalNot100Percent() public {
        Types.PaymentSplit memory newSplit =
            Types.PaymentSplit({ developerBps: 5000, protocolBps: 5000, operatorBps: 5000, stakerBps: 5000 });

        vm.prank(admin);
        vm.expectRevert(Errors.InvalidPaymentSplit.selector);
        tangle.setPaymentSplit(newSplit);
    }

    function test_SetPaymentSplit_AllToDeveloper() public {
        Types.PaymentSplit memory newSplit =
            Types.PaymentSplit({ developerBps: 10_000, protocolBps: 0, operatorBps: 0, stakerBps: 0 });

        vm.prank(admin);
        tangle.setPaymentSplit(newSplit);

        (uint16 dev, uint16 proto, uint16 op, uint16 rest) = tangle.paymentSplit();
        assertEq(dev, 10_000);
        assertEq(proto, 0);
        assertEq(op, 0);
        assertEq(rest, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // NATIVE TOKEN PAYMENT DISTRIBUTION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_PayOnce_NativeToken_DistributesCorrectly() public {
        uint256 payment = 10 ether;

        uint256 developerBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        // Request and approve service with payment
        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Check distribution
        uint256 developerExpected = (payment * 2000) / 10_000; // 20%
        uint256 protocolExpected = (payment * 2000) / 10_000; // 20%

        assertEq(developer.balance, developerBefore + developerExpected, "Developer payment incorrect");
        assertEq(treasury.balance, treasuryBefore + protocolExpected, "Protocol payment incorrect");

        // No security commitments: operator gets operator + restaker share (60% of 10 ETH = 6 ETH)
        uint256 operatorPending = tangle.pendingRewards(operator1);
        assertEq(operatorPending, 6 ether, "Operator pending rewards incorrect");
    }

    function test_ClaimRewardsBatch_MultiToken() public {
        uint256 nativePayment = 10 ether;
        uint256 erc20Payment = 50 ether;

        uint256 operatorEthBefore = operator1.balance;
        uint256 operatorTokenBefore = token.balanceOf(operator1);

        uint64 nativeRequest = _requestServiceWithPayment(user1, blueprintId, operator1, nativePayment);
        _approveService(operator1, nativeRequest);

        uint64 tokenRequest = _requestServiceWithErc20(user1, blueprintId, operator1, address(token), erc20Payment);
        _approveService(operator1, tokenRequest);

        address[] memory tokens = new address[](2);
        tokens[0] = address(0);
        tokens[1] = address(token);

        vm.prank(operator1);
        tangle.claimRewardsBatch(tokens);

        assertEq(tangle.pendingRewards(operator1), 0, "Native rewards should be claimed");
        assertEq(tangle.pendingRewards(operator1, address(token)), 0, "ERC20 rewards should be claimed");
        // No security commitments: operator gets operator + restaker share
        assertEq(operator1.balance, operatorEthBefore + 6 ether, "Native rewards mismatch");
        assertEq(token.balanceOf(operator1), operatorTokenBefore + 30 ether, "ERC20 rewards mismatch");
    }

    function test_ClaimRewardsAll_UsesTrackedTokens() public {
        uint256 payment = 5 ether;

        uint256 operatorEthBefore = operator1.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);
        _approveService(operator1, requestId);

        vm.prank(operator1);
        tangle.claimRewardsAll();

        assertEq(tangle.pendingRewards(operator1), 0, "Native rewards should be claimed");
        // No security commitments: operator gets operator + restaker share (60% of 5 = 3 ETH)
        assertEq(operator1.balance, operatorEthBefore + 3 ether, "Native rewards mismatch");
        assertEq(tangle.rewardTokens(operator1).length, 0, "Tracked token set should be empty");
    }

    function test_TntPaymentDiscount_FundedFromProtocolShare_RebatesOwner() public {
        vm.startPrank(admin);
        tangle.setTntToken(address(token));
        tangle.setTntPaymentDiscountBps(1000); // 10%

        // Everything goes to treasury, so discount is easy to verify.
        tangle.setPaymentSplit(
            Types.PaymentSplit({ developerBps: 0, protocolBps: 10_000, operatorBps: 0, stakerBps: 0 })
        );
        vm.stopPrank();

        uint256 payment = 100 ether;

        uint256 userBefore = token.balanceOf(user1);
        uint256 treasuryBefore = token.balanceOf(treasury);

        uint64 requestId = _requestServiceWithErc20(user1, blueprintId, operator1, address(token), payment);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Discount is 10% (funded from protocol share), so treasury receives 90%.
        assertEq(token.balanceOf(treasury), treasuryBefore + 90 ether);

        // User net spends 90 (pays 100, gets 10 rebated).
        assertEq(userBefore - token.balanceOf(user1), 90 ether);
    }

    function test_TntPaymentDiscount_CappedToProtocolShare() public {
        vm.startPrank(admin);
        tangle.setTntToken(address(token));
        tangle.setTntPaymentDiscountBps(1000); // 10%

        // Protocol share is only 5%; discount should be capped to 5%.
        tangle.setPaymentSplit(
            Types.PaymentSplit({ developerBps: 9500, protocolBps: 500, operatorBps: 0, stakerBps: 0 })
        );
        vm.stopPrank();

        uint256 payment = 100 ether;

        uint256 userBefore = token.balanceOf(user1);
        uint256 developerBefore = token.balanceOf(developer);
        uint256 treasuryBefore = token.balanceOf(treasury);

        uint64 requestId = _requestServiceWithErc20(user1, blueprintId, operator1, address(token), payment);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Treasury should receive 0 because its entire 5% share funds the discount.
        assertEq(token.balanceOf(treasury), treasuryBefore);
        assertEq(token.balanceOf(developer), developerBefore + 95 ether);

        // User net spends 95 (pays 100, gets 5 rebated).
        assertEq(userBefore - token.balanceOf(user1), 95 ether);
    }

    function test_PayOnce_NativeToken_MultipleOperators() public {
        uint256 payment = 10 ether;

        // Setup multi-operator service
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService{ value: payment }(blueprintId, operators, "", callers, 0, address(0), payment);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // No security commitments: each operator gets half of (operator + restaker) share = 3 ETH each
        uint256 op1Pending = tangle.pendingRewards(operator1);
        uint256 op2Pending = tangle.pendingRewards(operator2);
        assertEq(op1Pending, 3 ether, "Operator1 pending incorrect");
        assertEq(op2Pending, 3 ether, "Operator2 pending incorrect");
    }

    function test_PayOnce_NativeToken_ExposureWeightedDistribution() public {
        uint256 payment = 10 ether;

        // Setup with different exposures: op1=70%, op2=30%
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;
        uint16[] memory exposures = new uint16[](2);
        exposures[0] = 7000; // 70%
        exposures[1] = 3000; // 30%
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: payment }(
            blueprintId, operators, exposures, "", callers, 0, address(0), payment
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // No security commitments: operator pool = operator + restaker = 6 ETH total
        // Op1 should get 70% = 4.2 ETH
        // Op2 should get 30% = 1.8 ETH
        uint256 op1Pending = tangle.pendingRewards(operator1);
        uint256 op2Pending = tangle.pendingRewards(operator2);
        assertEq(op1Pending, 4.2 ether, "Operator1 exposure-weighted payment incorrect");
        assertEq(op2Pending, 1.8 ether, "Operator2 exposure-weighted payment incorrect");
    }

    function test_PayOnce_ZeroPayment() public {
        // Request with no payment
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // No pending rewards
        assertEq(tangle.pendingRewards(operator1), 0);
    }

    function test_EventDriven_InitialPayment_DistributesOnActivation() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0.1 ether
        });

        vm.prank(developer);
        uint64 eventBlueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://event-initial-payment", address(0), config));
        _registerForBlueprint(operator1, eventBlueprintId);

        uint256 upfront = 10 ether;
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService{ value: upfront }(eventBlueprintId, operators, "", callers, 0, address(0), upfront);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // No security commitments: operator receives operator + restaker share.
        assertEq(tangle.pendingRewards(operator1), 6 ether);
    }

    function test_EventDriven_RequestService_RevertERC20InitialPaymentToken() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0.1 ether
        });

        vm.prank(developer);
        uint64 eventBlueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://event-native-only", address(0), config));
        _registerForBlueprint(operator1, eventBlueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.startPrank(user1);
        token.approve(address(tangle), 1 ether);
        vm.expectRevert(Errors.InvalidPaymentToken.selector);
        tangle.requestService(eventBlueprintId, operators, "", callers, 0, address(token), 1 ether);
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD CLAIMING
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ClaimRewards_NativeToken() public {
        // Setup: create service with payment
        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, 10 ether);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 pending = tangle.pendingRewards(operator1);
        assertGt(pending, 0);

        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        tangle.claimRewards();

        assertEq(operator1.balance, balanceBefore + pending);
        assertEq(tangle.pendingRewards(operator1), 0);
    }

    function test_ClaimRewards_NothingToClaim() public {
        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        tangle.claimRewards();

        // Should not revert, just no effect
        assertEq(operator1.balance, balanceBefore);
    }

    function test_ClaimRewards_MultipleClaims() public {
        // First payment
        uint64 requestId1 = _requestServiceWithPayment(user1, blueprintId, operator1, 10 ether);
        vm.prank(operator1);
        tangle.approveService(requestId1, 0);

        // Claim first
        vm.prank(operator1);
        tangle.claimRewards();

        // Second payment (new service)
        vm.prank(developer);
        uint64 bp2 = tangle.createBlueprint(_blueprintDefinition("ipfs://second", address(0)));
        _registerForBlueprint(operator1, bp2);

        uint64 requestId2 = _requestServiceWithPayment(user1, bp2, operator1, 5 ether);
        vm.prank(operator1);
        tangle.approveService(requestId2, 0);

        // Claim second
        uint256 balanceBefore = operator1.balance;
        vm.prank(operator1);
        tangle.claimRewards();

        // No security commitments: 60% of 5 ETH = 3 ETH
        assertEq(operator1.balance, balanceBefore + 3 ether);
    }

    function test_ClaimRewards_ERC20Token() public {
        uint256 payment = 100 ether;
        uint64 requestId = _requestServiceWithErc20(user1, blueprintId, operator1, address(token), payment);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 pending = tangle.pendingRewards(operator1, address(token));
        assertGt(pending, 0);
        assertEq(tangle.pendingRewards(operator1), 0);

        uint256 operatorBalanceBefore = token.balanceOf(operator1);
        vm.prank(operator1);
        tangle.claimRewards(address(token));
        uint256 operatorBalanceAfter = token.balanceOf(operator1);

        assertEq(operatorBalanceAfter - operatorBalanceBefore, pending);
        assertEq(tangle.pendingRewards(operator1, address(token)), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBSCRIPTION ESCROW
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Subscription_InitialDeposit() public {
        // Create subscription blueprint
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 subBlueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://sub", address(0), config));
        _registerForBlueprint(operator1, subBlueprintId);

        // Request with initial escrow deposit
        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService{ value: 1 ether }(subBlueprintId, operators, "", callers, 0, address(0), 1 ether);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Check escrow balance
        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(0);
        assertEq(escrow.balance, 1 ether);
        assertEq(escrow.totalDeposited, 1 ether);
    }

    function test_Subscription_FundService() public {
        uint64 subServiceId = _setupSubscriptionService();

        uint256 escrowBefore = tangle.getServiceEscrow(subServiceId).balance;

        vm.prank(user1);
        tangle.fundService{ value: 0.5 ether }(subServiceId, 0.5 ether);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(subServiceId);
        assertEq(escrow.balance, escrowBefore + 0.5 ether);
    }

    function test_Subscription_FundServiceExcessETHReverts() public {
        uint64 subServiceId = _setupSubscriptionService();

        uint256 escrowBefore = tangle.getServiceEscrow(subServiceId).balance;
        uint256 userBalanceBefore = user1.balance;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0.25 ether, 0.5 ether));
        tangle.fundService{ value: 0.5 ether }(subServiceId, 0.25 ether);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(subServiceId);
        assertEq(escrow.balance, escrowBefore);
        assertEq(user1.balance, userBalanceBefore);
    }

    function test_Subscription_FundServiceZeroAmountRevertsWithValue() public {
        uint64 subServiceId = _setupSubscriptionService();

        PaymentLib.ServiceEscrow memory escrowBefore = tangle.getServiceEscrow(subServiceId);
        uint256 userBalanceBefore = user1.balance;

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0, 0.2 ether));
        tangle.fundService{ value: 0.2 ether }(subServiceId, 0);

        PaymentLib.ServiceEscrow memory escrowAfter = tangle.getServiceEscrow(subServiceId);
        assertEq(escrowAfter.balance, escrowBefore.balance, "escrow balance unchanged");
        assertEq(escrowAfter.totalDeposited, escrowBefore.totalDeposited, "total deposited unchanged");
        assertEq(escrowAfter.totalReleased, escrowBefore.totalReleased, "total released unchanged");
        assertEq(user1.balance, userBalanceBefore, "user balance unchanged on revert");
    }

    function test_Subscription_FundService_RevertNotActive() public {
        uint64 subServiceId = _setupSubscriptionService();

        vm.prank(user1);
        tangle.terminateService(subServiceId);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceNotActive.selector, subServiceId));
        tangle.fundService{ value: 0.1 ether }(subServiceId, 0.1 ether);
    }

    function test_FundService_RevertWhenNotSubscription() public {
        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, 1 ether);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;

        vm.prank(user1);
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.fundService{ value: 0.1 ether }(serviceId, 0.1 ether);
    }

    function test_Subscription_FundServiceERC20() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 10 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 ercBlueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://erc20-subscription", address(0), config));
        _registerForBlueprint(operator1, ercBlueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        uint256 initialDeposit = 100 ether;
        vm.startPrank(user1);
        token.approve(address(tangle), initialDeposit);
        uint64 requestId =
            tangle.requestService(ercBlueprintId, operators, "", callers, 0, address(token), initialDeposit);
        vm.stopPrank();

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        PaymentLib.ServiceEscrow memory escrowBefore = tangle.getServiceEscrow(serviceId);
        assertEq(escrowBefore.token, address(token));
        assertEq(escrowBefore.balance, initialDeposit);

        uint256 topUp = 25 ether;
        vm.startPrank(user1);
        token.approve(address(tangle), topUp);
        tangle.fundService(serviceId, topUp);
        vm.stopPrank();

        PaymentLib.ServiceEscrow memory escrowAfter = tangle.getServiceEscrow(serviceId);
        assertEq(escrowAfter.balance, escrowBefore.balance + topUp);
        assertEq(escrowAfter.token, address(token));
    }

    function test_Subscription_ZeroInitialDepositERC20_InitializesToken() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 10 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 ercBlueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://erc20-sub-zero-init", address(0), config));
        _registerForBlueprint(operator1, ercBlueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(ercBlueprintId, operators, "", callers, 0, address(token), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 serviceId = tangle.serviceCount() - 1;
        PaymentLib.ServiceEscrow memory escrowBefore = tangle.getServiceEscrow(serviceId);
        assertEq(escrowBefore.token, address(token));
        assertEq(escrowBefore.balance, 0);

        uint256 topUp = 25 ether;
        vm.startPrank(user1);
        token.approve(address(tangle), topUp);
        tangle.fundService(serviceId, topUp);
        vm.stopPrank();

        PaymentLib.ServiceEscrow memory escrowAfter = tangle.getServiceEscrow(serviceId);
        assertEq(escrowAfter.token, address(token));
        assertEq(escrowAfter.balance, topUp);
    }

    function test_Subscription_BillReducesEscrow() public {
        uint64 subServiceId = _setupSubscriptionService();

        PaymentLib.ServiceEscrow memory escrowBefore = tangle.getServiceEscrow(subServiceId);
        uint256 balanceBefore = escrowBefore.balance;

        // Warp past billing interval
        vm.warp(block.timestamp + 31 days);
        tangle.billSubscription(subServiceId);

        PaymentLib.ServiceEscrow memory escrowAfter = tangle.getServiceEscrow(subServiceId);
        assertEq(escrowAfter.balance, balanceBefore - 0.1 ether); // subscriptionRate
        assertEq(escrowAfter.totalReleased, 0.1 ether);
    }

    function test_Subscription_RevertInsufficientEscrow() public {
        // Setup subscription with minimal escrow
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 1 ether, // High rate
            subscriptionInterval: 1 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 bp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://lowescrow", address(0), config));
        _registerForBlueprint(operator1, bp);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        // Only deposit 0.5 ETH but rate is 1 ETH
        vm.prank(user1);
        uint64 requestId =
            tangle.requestService{ value: 0.5 ether }(bp, operators, "", callers, 0, address(0), 0.5 ether);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        vm.warp(block.timestamp + 2 days);

        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientEscrowBalance.selector, 1 ether, 0.5 ether));
        tangle.billSubscription(0);
    }

    function test_Subscription_MultipleBillingCycles() public {
        uint64 subServiceId = _setupSubscriptionService();

        // Fund with enough for multiple cycles
        vm.prank(user1);
        tangle.fundService{ value: 1 ether }(subServiceId, 1 ether);

        // Bill multiple times - use explicit timestamp tracking
        uint256 currentTime = block.timestamp;
        for (uint256 i = 0; i < 5; i++) {
            currentTime += 31 days;
            vm.warp(currentTime);
            tangle.billSubscription(subServiceId);
        }

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(subServiceId);
        // Started with 1 ETH + 1 ETH = 2 ETH, 5 bills of 0.1 ETH = 0.5 ETH used
        assertEq(escrow.balance, 1.5 ether);
        assertEq(escrow.totalReleased, 0.5 ether);
    }

    function test_Subscription_BillRevertWhenExpired() public {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 expBlueprintId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://expiring-sub", address(0), config));
        _registerForBlueprint(operator1, expBlueprintId);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: 1 ether }(
            expBlueprintId, operators, "", callers, 1 days, address(0), 1 ether
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = tangle.serviceCount() - 1;

        vm.warp(block.timestamp + 2 days);

        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceExpired.selector, serviceId));
        tangle.billSubscription(serviceId);
    }

    function test_BillSubscriptionBatch_RevertEmpty() public {
        uint64[] memory ids = new uint64[](0);
        vm.expectRevert(Errors.ZeroAmount.selector);
        tangle.billSubscriptionBatch(ids);
    }

    function test_BillSubscriptionBatch_PartialSuccess() public {
        uint64 healthyService = _setupSubscriptionService();
        uint64 underfundedService = _setupSubscriptionServiceWithDeposit(0.05 ether);

        vm.warp(block.timestamp + 31 days);

        uint64[] memory ids = new uint64[](2);
        ids[0] = healthyService;
        ids[1] = underfundedService;

        (uint256 totalBilled, uint256 billedCount) = tangle.billSubscriptionBatch(ids);
        assertEq(totalBilled, 0.1 ether);
        assertEq(billedCount, 1);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(healthyService);
        assertEq(escrow.totalReleased, 0.1 ether);

        PaymentLib.ServiceEscrow memory underfundedEscrow = tangle.getServiceEscrow(underfundedService);
        assertEq(underfundedEscrow.totalReleased, 0);
    }

    function test_GetBillableServices_FiltersResults() public {
        uint64 activeService = _setupSubscriptionService();
        uint64 expiredService = _setupSubscriptionServiceWithTTL(1 days);

        vm.warp(block.timestamp + 40 days);

        // Create a fresh service after the warp so it hasn't reached its first interval yet
        uint64 freshService = _setupSubscriptionService();

        uint64[] memory candidates = new uint64[](3);
        candidates[0] = activeService;
        candidates[1] = expiredService;
        candidates[2] = freshService;

        uint64[] memory billable = tangle.getBillableServices(candidates);
        assertEq(billable.length, 1);
        assertEq(billable[0], activeService);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TREASURY CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetTreasury_UpdatesRecipient() public {
        address payable newTreasury = payable(makeAddr("newTreasury"));

        vm.prank(admin);
        tangle.setTreasury(newTreasury);

        // Create payment to verify new treasury receives funds
        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, 10 ether);

        uint256 newTreasuryBefore = newTreasury.balance;

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // 20% should go to new treasury
        assertEq(newTreasury.balance, newTreasuryBefore + 2 ether);
    }

    function test_SetTreasury_RevertZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert(Errors.ZeroAddress.selector);
        tangle.setTreasury(payable(address(0)));
    }

    function test_SetTreasury_RevertNotAdmin() public {
        vm.prank(user1);
        vm.expectRevert();
        tangle.setTreasury(payable(makeAddr("hacker")));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT REFUNDS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RejectService_RefundsPayment() public {
        uint256 payment = 5 ether;
        uint256 userBalanceBefore = user1.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);

        // User's balance reduced
        assertEq(user1.balance, userBalanceBefore - payment);

        // Operator rejects
        vm.prank(operator1);
        tangle.rejectService(requestId);

        // Full refund
        assertEq(user1.balance, userBalanceBefore);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUNDING EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Payment_SmallAmountRounding_RevertsWithMinimum() public {
        // M-5 FIX: Payments below MINIMUM_PAYMENT_AMOUNT (100) should revert
        uint256 payment = 1; // 1 wei - below minimum

        vm.expectRevert(abi.encodeWithSelector(Errors.PaymentTooSmall.selector, payment, 100));
        _requestServiceWithPayment(user1, blueprintId, operator1, payment);
    }

    function test_Payment_OddAmountDistribution() public {
        // Amount that doesn't divide evenly
        uint256 payment = 333;

        uint256 developerBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);
        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 devExpected = (uint256(333) * 2000) / 10_000; // 66
        uint256 protoExpected = (uint256(333) * 2000) / 10_000; // 66
        uint256 opAmount = (uint256(333) * 4000) / 10_000; // 133
        uint256 stakerAmount = 333 - devExpected - protoExpected - opAmount; // 68
        // No security commitments: operator gets op + staker = 201

        assertEq(developer.balance, developerBefore + devExpected);
        assertEq(treasury.balance, treasuryBefore + protoExpected);
        assertEq(tangle.pendingRewards(operator1), opAmount + stakerAmount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _setupSubscriptionService() internal returns (uint64) {
        return _setupSubscriptionServiceWithDepositAndTTL(1 ether, 365 days);
    }

    function _setupSubscriptionServiceWithDeposit(uint256 deposit) internal returns (uint64) {
        return _setupSubscriptionServiceWithDepositAndTTL(deposit, 365 days);
    }

    function _setupSubscriptionServiceWithTTL(uint64 ttl) internal returns (uint64) {
        return _setupSubscriptionServiceWithDepositAndTTL(1 ether, ttl);
    }

    function _setupSubscriptionServiceWithDepositAndTTL(uint256 initialDeposit, uint64 ttl) internal returns (uint64) {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 bp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription", address(0), config));
        _registerForBlueprint(operator1, bp);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: initialDeposit }(
            bp, operators, "", callers, ttl, address(0), initialDeposit
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        return tangle.serviceCount() - 1;
    }
}
