// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";
import { MockServiceFeeDistributor } from "../mocks/MockServiceFeeDistributor.sol";

interface ITanglePaymentsLike {
    function fundService(uint64 serviceId, uint256 amount) external payable;
    function billSubscription(uint64 serviceId) external;
    function claimRewards() external;
    function terminateService(uint64 serviceId) external;
    function withdrawRemainingEscrow(uint64 serviceId) external;
    function pendingRewards(address account) external view returns (uint256);
    function getServiceEscrow(uint64 serviceId) external view returns (PaymentLib.ServiceEscrow memory);
}

contract SubscriptionEscrowHandler is Test {
    uint256 internal constant MAX_TOP_UP = 2 ether;

    ITanglePaymentsLike internal tangle;
    address internal serviceOwner;
    address internal operator;

    uint64 public immutable serviceId;

    uint256 public totalFunded;
    uint256 public totalClaimedByOperator;
    uint256 public totalRefundedToOwner;

    constructor(ITanglePaymentsLike tangle_, uint64 serviceId_, address serviceOwner_, address operator_) {
        tangle = tangle_;
        serviceId = serviceId_;
        serviceOwner = serviceOwner_;
        operator = operator_;
    }

    function topUp(uint256 amount) external {
        amount = bound(amount, 1 wei, MAX_TOP_UP);
        vm.deal(serviceOwner, serviceOwner.balance + amount);
        vm.prank(serviceOwner);
        try tangle.fundService{ value: amount }(serviceId, amount) {
            totalFunded += amount;
        } catch { }
    }

    function warpForward(uint256 step) external {
        step = bound(step, 1 days, 45 days);
        vm.warp(block.timestamp + step);
    }

    function bill() external {
        try tangle.billSubscription(serviceId) { } catch { }
    }

    function claimOperator() external {
        uint256 beforeBalance = operator.balance;
        vm.prank(operator);
        try tangle.claimRewards() {
            totalClaimedByOperator += operator.balance - beforeBalance;
        } catch { }
    }

    function terminate() external {
        vm.prank(serviceOwner);
        try tangle.terminateService(serviceId) { } catch { }
    }

    function refundRemaining() external {
        uint256 beforeBalance = serviceOwner.balance;
        vm.prank(serviceOwner);
        try tangle.withdrawRemainingEscrow(serviceId) {
            totalRefundedToOwner += serviceOwner.balance - beforeBalance;
        } catch { }
    }
}

contract SubscriptionEscrowInvariantTest is StdInvariant, BaseTest {
    MockServiceFeeDistributor internal distributor;
    SubscriptionEscrowHandler internal handler;

    uint64 internal serviceId;

    uint256 internal initialDeveloperBalance;
    uint256 internal initialTreasuryBalance;
    uint256 internal initialDistributorBalance;

    function setUp() public override {
        super.setUp();

        distributor = new MockServiceFeeDistributor();
        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        staking.setServiceFeeDistributor(address(distributor));
        vm.stopPrank();

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
        uint64 bp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://subscription-invariant", address(0), config));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, bp);

        address[] memory operators = new address[](1);
        operators[0] = operator1;
        address[] memory callers = new address[](0);

        uint256 initialDeposit = 1 ether;
        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: initialDeposit }(
            bp, operators, "", callers, 365 days, address(0), initialDeposit, Types.ConfidentialityPolicy.Any
        );
        _approveService(operator1, requestId);
        serviceId = 0;

        initialDeveloperBalance = developer.balance;
        initialTreasuryBalance = treasury.balance;
        initialDistributorBalance = address(distributor).balance;

        handler = new SubscriptionEscrowHandler(ITanglePaymentsLike(address(tangle)), serviceId, user1, operator1);
        vm.deal(address(handler), 100 ether);
        targetContract(address(handler));
    }

    function invariant_subscriptionEscrowConservesNativeValue() external view {
        PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(serviceId);
        uint256 pendingOperator = tangle.pendingRewards(operator1);

        uint256 developerOut = developer.balance - initialDeveloperBalance;
        uint256 treasuryOut = treasury.balance - initialTreasuryBalance;
        uint256 stakerOut = address(distributor).balance - initialDistributorBalance;

        uint256 lhs = 1 ether + handler.totalFunded();
        uint256 rhs = escrow.balance + pendingOperator + handler.totalClaimedByOperator() + handler.totalRefundedToOwner()
            + developerOut + treasuryOut + stakerOut;

        assertEq(lhs, rhs, "subscription native value not conserved");
        assertEq(address(tangle).balance, escrow.balance + pendingOperator, "tangle balance mismatch");
    }
}
