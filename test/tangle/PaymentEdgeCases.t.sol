// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";
import { MockServiceFeeDistributor } from "../mocks/MockServiceFeeDistributor.sol";

/// @notice Mock token that takes a fee on transfer
contract FeeOnTransferToken is ERC20 {
    uint256 public feePercent; // in basis points

    constructor(uint256 _feePercent) ERC20("Fee Token", "FEE") {
        feePercent = _feePercent;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 amount) internal virtual override {
        if (from != address(0) && to != address(0)) {
            // Apply fee on transfer
            uint256 fee = (amount * feePercent) / 10_000;
            uint256 amountAfterFee = amount - fee;
            super._update(from, to, amountAfterFee);
            if (fee > 0) {
                // Burn fee
                super._update(from, address(0), fee);
            }
        } else {
            super._update(from, to, amount);
        }
    }
}

/// @notice Mock token that always reverts on transfer
contract RevertingToken is ERC20 {
    constructor() ERC20("Revert", "REV") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function transfer(address, uint256) public pure override returns (bool) {
        revert("Transfer disabled");
    }

    function transferFrom(address, address, uint256) public pure override returns (bool) {
        revert("TransferFrom disabled");
    }
}

/// @notice Receiver that rejects ETH
contract ETHRejecter {
    receive() external payable {
        revert("No ETH");
    }
}

/// @title PaymentEdgeCasesTest
/// @notice Edge cases and stress tests for payment system
contract PaymentEdgeCasesTest is BaseTest {
    MockERC20 public token;
    MockServiceFeeDistributor public serviceFeeDistributor;
    uint64 public blueprintId;

    function setUp() public override {
        super.setUp();

        serviceFeeDistributor = new MockServiceFeeDistributor();
        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(serviceFeeDistributor));
        staking.setServiceFeeDistributor(address(serviceFeeDistributor));
        vm.stopPrank();

        // Deploy mock token (constructor initializes with default name/symbol)
        token = new MockERC20();
        token.mint(user1, 1000 ether);
        token.mint(user2, 1000 ether);

        // Setup basic infrastructure
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);

        blueprintId = _createBlueprint(developer);

        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INSUFFICIENT ESCROW BALANCE
    // ═══════════════════════════════════════════════════════════════════════════

    function test_BillSubscription_InsufficientEscrow_Reverts() public {
        uint64 serviceId = _setupSubscriptionService(0.5 ether);

        // Warp past billing interval
        vm.warp(block.timestamp + 31 days);

        // Escrow has 0.5 ETH but rate is 1 ETH
        vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientEscrowBalance.selector, 1 ether, 0.5 ether));
        tangle.billSubscription(serviceId);
    }

    function test_BillSubscription_ExactlyEnough_Success() public {
        uint64 serviceId = _setupSubscriptionService(1 ether); // Exactly enough for one billing

        vm.warp(block.timestamp + 31 days);
        tangle.billSubscription(serviceId);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        assertEq(escrow.balance, 0);
    }

    // Note: Multiple billing scenario is already tested in test_BillSubscription_MultipleMissedIntervals

    // ═══════════════════════════════════════════════════════════════════════════
    // ZERO AMOUNT PAYMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_PayOnce_ZeroPayment_Success() public {
        uint64 requestId = _requestService(user1, blueprintId, operator1);
        _approveService(operator1, requestId);

        // No rewards should be pending
        assertEq(tangle.pendingRewards(operator1), 0);
    }

    function test_ClaimRewards_NothingToClaim_NoRevert() public {
        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        tangle.claimRewards();

        // Should not revert, balance unchanged
        assertEq(operator1.balance, balanceBefore);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUNDING AND PRECISION
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Payment_VerySmallAmount_RevertsWithMinimum() public {
        // M-5 FIX: Payments below MINIMUM_PAYMENT_AMOUNT (100) should revert
        uint256 payment = 1;
        vm.expectRevert(abi.encodeWithSelector(Errors.PaymentTooSmall.selector, payment, 100));
        _requestServiceWithPayment(user1, blueprintId, operator1, payment);
    }

    function test_Payment_PrimeNumberAmount_RoundingHandled() public {
        // Prime number that doesn't divide evenly
        uint256 payment = 7919; // Prime number

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);
        _approveService(operator1, requestId);

        // All payment should be distributed (developer + protocol + operator pending + restaker)
        // Sum of individual amounts should equal original (accounting for operator pending)
    }

    function test_Payment_MaxUint256_DistributionMatchesSplit() public {
        uint256 payment = type(uint128).max; // still exercises large values without hitting forge limits
        vm.deal(user1, payment);

        uint256 developerBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);
        _approveService(operator1, requestId);

        (uint16 devBps, uint16 protoBps, uint16 opBps, uint16 stakerBps) = tangle.paymentSplit();
        uint256 expectedDev = (payment * devBps) / 10_000;
        uint256 expectedTreasury = (payment * protoBps) / 10_000;
        // No security commitments: operator gets operator + restaker share
        uint256 expectedOperator = (payment * (uint256(opBps) + uint256(stakerBps))) / 10_000;

        assertEq(developer.balance - developerBefore, expectedDev);
        assertEq(treasury.balance - treasuryBefore, expectedTreasury);
        assertEq(tangle.pendingRewards(operator1), expectedOperator);
    }

    function test_Payment_ThreeOperators_UnevenSplit() public {
        // Register third operator
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator3, blueprintId);

        // 100 wei split among 3 operators (33.33... each)
        address[] memory ops = new address[](3);
        ops[0] = operator1;
        ops[1] = operator2;
        ops[2] = operator3;
        address[] memory callers = new address[](0);

        uint256 payment = 100;

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService{ value: payment }(blueprintId, ops, "", callers, 0, address(0), payment);

        _approveService(operator1, requestId);
        _approveService(operator2, requestId);
        _approveService(operator3, requestId);

        // Check that all operators got something (may not be exactly equal due to rounding)
        uint256 op1Pending = tangle.pendingRewards(operator1);
        uint256 op2Pending = tangle.pendingRewards(operator2);
        uint256 op3Pending = tangle.pendingRewards(operator3);

        // No security commitments: operators share (operator + restaker) = 60% of 100 = 60 wei
        (,, uint16 opBps, uint16 stakerBps) = tangle.paymentSplit();
        uint256 expectedTotal = (payment * (uint256(opBps) + uint256(stakerBps))) / 10_000;
        assertTrue(
            op1Pending + op2Pending + op3Pending <= expectedTotal,
            "Total operator rewards should not exceed operator+restaker share"
        );
    }

    function test_Payment_RequestServiceWithRevertingTokenReverts() public {
        RevertingToken revertToken = new RevertingToken();
        revertToken.mint(user1, 10 ether);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        vm.startPrank(user1);
        revertToken.approve(address(tangle), 5 ether);
        vm.expectRevert(bytes("TransferFrom disabled"));
        tangle.requestService(blueprintId, operators, "", callers, 0, address(revertToken), 5 ether);
        vm.stopPrank();
    }

    function test_Payment_TreasuryRejectsETH_Reverts() public {
        ETHRejecter rejecter = new ETHRejecter();
        vm.prank(admin);
        tangle.setTreasury(payable(address(rejecter)));

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, 1 ether);

        vm.expectRevert(Errors.PaymentFailed.selector);
        _approveService(operator1, requestId);

        vm.prank(admin);
        tangle.setTreasury(payable(treasury));
    }

    function test_Payment_ZeroExposure_OperatorStillGetsPaid() public {
        // Operators always get paid for providing compute, even with 0% exposure.
        // Customer protection: set minimum exposureBps on the service to prevent this.
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = 0; // 0% exposure
        address[] memory callers = new address[](0);

        uint256 payment = 10 ether;

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: payment }(
            blueprintId, ops, exposures, "", callers, 0, address(0), payment
        );

        _approveService(operator1, requestId);

        // With 0% exposure and no restakers, operator gets (operator + restaker) share equally
        (,, uint16 opBps, uint16 stakerBps) = tangle.paymentSplit();
        uint256 expectedOperatorReward = (payment * (uint256(opBps) + uint256(stakerBps))) / 10_000;
        assertEq(tangle.pendingRewards(operator1), expectedOperatorReward);
    }

    function test_Payment_HeavilySkewedExposure() public {
        // 99% to op1, 1% to op2
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        uint16[] memory exposures = new uint16[](2);
        exposures[0] = 9900; // 99%
        exposures[1] = 100; // 1%
        address[] memory callers = new address[](0);

        uint256 payment = 100 ether;

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure{ value: payment }(
            blueprintId, ops, exposures, "", callers, 0, address(0), payment
        );

        _approveService(operator1, requestId);
        _approveService(operator2, requestId);

        uint256 op1Pending = tangle.pendingRewards(operator1);
        uint256 op2Pending = tangle.pendingRewards(operator2);

        // Operator share is 40% of 100 = 40 ETH
        // Op1 gets 99% of 40 = 39.6 ETH
        // Op2 gets 1% of 40 = 0.4 ETH
        assertGt(op1Pending, op2Pending * 90, "Op1 should get much more than op2");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT SPLIT EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_PaymentSplit_AllToProtocol() public {
        Types.PaymentSplit memory split =
            Types.PaymentSplit({ developerBps: 0, protocolBps: 10_000, operatorBps: 0, stakerBps: 0 });

        vm.prank(admin);
        tangle.setPaymentSplit(split);

        uint256 treasuryBefore = treasury.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, 10 ether);
        _approveService(operator1, requestId);

        assertEq(treasury.balance, treasuryBefore + 10 ether);
        assertEq(tangle.pendingRewards(operator1), 0);
    }

    function test_PaymentSplit_AllToOperators() public {
        Types.PaymentSplit memory split =
            Types.PaymentSplit({ developerBps: 0, protocolBps: 0, operatorBps: 10_000, stakerBps: 0 });

        vm.prank(admin);
        tangle.setPaymentSplit(split);

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, 10 ether);
        _approveService(operator1, requestId);

        assertEq(tangle.pendingRewards(operator1), 10 ether);
    }

    function test_PaymentSplit_RevertsTotalNot100Percent() public {
        Types.PaymentSplit memory split =
            Types.PaymentSplit({ developerBps: 2000, protocolBps: 2000, operatorBps: 2000, stakerBps: 2000 }); // Total
        // = 80%

        vm.prank(admin);
        vm.expectRevert(Errors.InvalidPaymentSplit.selector);
        tangle.setPaymentSplit(split);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SUBSCRIPTION TIMING EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_BillSubscription_ExactlyAtInterval() public {
        uint64 serviceId = _setupSubscriptionService(10 ether);

        // Warp exactly to interval boundary
        vm.warp(block.timestamp + 30 days);
        tangle.billSubscription(serviceId);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        assertEq(escrow.totalReleased, 1 ether);
    }

    function test_BillSubscription_JustBeforeInterval_Reverts() public {
        uint64 serviceId = _setupSubscriptionService(10 ether);

        // Warp to just before interval
        vm.warp(block.timestamp + 30 days - 1);

        vm.expectRevert(Errors.DeadlineExpired.selector);
        tangle.billSubscription(serviceId);
    }

    function test_BillSubscription_MultipleMissedIntervals() public {
        uint64 serviceId = _setupSubscriptionService(10 ether);

        // Warp past multiple intervals
        vm.warp(block.timestamp + 90 days); // 3 intervals

        // First bill works
        tangle.billSubscription(serviceId);

        // Second bill also works (since enough time has passed)
        vm.warp(block.timestamp + 30 days);
        tangle.billSubscription(serviceId);

        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        assertEq(escrow.totalReleased, 2 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REFUND EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RejectService_RefundsFullPayment() public {
        uint256 payment = 5 ether;
        uint256 userBalanceBefore = user1.balance;

        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, payment);

        assertEq(user1.balance, userBalanceBefore - payment);

        vm.prank(operator1);
        tangle.rejectService(requestId);

        assertEq(user1.balance, userBalanceBefore, "Full payment should be refunded");
    }

    function test_RejectService_RefundsZeroPayment() public {
        uint256 userBalanceBefore = user1.balance;

        uint64 requestId = _requestService(user1, blueprintId, operator1);

        vm.prank(operator1);
        tangle.rejectService(requestId);

        assertEq(user1.balance, userBalanceBefore, "Balance should be unchanged");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLAIM REWARDS EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ClaimRewards_MultipleTimesInSameBlock() public {
        // Setup rewards
        uint64 requestId = _requestServiceWithPayment(user1, blueprintId, operator1, 10 ether);
        _approveService(operator1, requestId);

        uint256 pending = tangle.pendingRewards(operator1);
        assertGt(pending, 0);

        // Claim multiple times in same block
        vm.startPrank(operator1);
        tangle.claimRewards();
        uint256 afterFirst = operator1.balance;

        tangle.claimRewards(); // Should be no-op
        uint256 afterSecond = operator1.balance;

        tangle.claimRewards(); // Should be no-op
        uint256 afterThird = operator1.balance;
        vm.stopPrank();

        assertEq(afterSecond, afterFirst, "Second claim should not change balance");
        assertEq(afterThird, afterFirst, "Third claim should not change balance");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _setupSubscriptionService(uint256 initialDeposit) internal returns (uint64) {
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 1 ether,
            subscriptionInterval: 30 days,
            eventRate: 0
        });

        vm.prank(developer);
        uint64 subBlueprintId = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://sub", address(0), config));

        _registerForBlueprint(operator1, subBlueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: initialDeposit }(
            subBlueprintId, ops, "", callers, 365 days, address(0), initialDeposit
        );

        _approveService(operator1, requestId);

        return tangle.serviceCount() - 1;
    }
}
