// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { BaseTest } from "../BaseTest.sol";
import { ServiceFeeDistributor } from "../../src/rewards/ServiceFeeDistributor.sol";

contract ServiceFeeDistributorInvariantHandler is Test {
    uint256 internal constant MIN_DELEGATION = 0.1 ether;
    uint64 internal constant SERVICE_ID = 0;
    uint64 internal constant BLUEPRINT_ID = 0;

    ServiceFeeDistributor internal distributor;
    IMultiAssetDelegationLike internal staking;
    address internal operator;
    address internal delegator1;
    address internal delegator2;

    uint256 public totalDistributedNative;
    uint256 public totalClaimedNative;
    uint256 public distributionCount;

    constructor(
        ServiceFeeDistributor distributor_,
        address staking_,
        address operator_,
        address delegator1_,
        address delegator2_
    ) {
        distributor = distributor_;
        staking = IMultiAssetDelegationLike(staking_);
        operator = operator_;
        delegator1 = delegator1_;
        delegator2 = delegator2_;
    }

    function delegate1(uint256 amount) external {
        _delegate(delegator1, amount);
    }

    function delegate2(uint256 amount) external {
        _delegate(delegator2, amount);
    }

    function undelegate1(uint256 amount) external {
        _undelegate(delegator1, amount);
    }

    function undelegate2(uint256 amount) external {
        _undelegate(delegator2, amount);
    }

    function distributeNative(uint256 amount) external {
        if (staking.getOperatorDelegatedStake(operator) == 0) return;

        amount = bound(amount, 1 wei, 5 ether);
        vm.deal(address(this), address(this).balance + amount);

        distributor.distributeInflationReward{ value: amount }(SERVICE_ID, BLUEPRINT_ID, operator, address(0), amount);

        totalDistributedNative += amount;
        distributionCount++;
    }

    function claim1() external {
        _claim(delegator1);
    }

    function claim2() external {
        _claim(delegator2);
    }

    function trackedPendingNative() external view returns (uint256) {
        return distributor.pendingRewards(delegator1, address(0)) + distributor.pendingRewards(delegator2, address(0));
    }

    function _delegate(address delegator, uint256 amount) internal {
        amount = bound(amount, MIN_DELEGATION, 5 ether);
        vm.deal(delegator, delegator.balance + amount);
        vm.prank(delegator);
        try staking.depositAndDelegate{ value: amount }(operator) { } catch { }
    }

    function _undelegate(address delegator, uint256 amount) internal {
        uint256 current = staking.getDelegation(delegator, operator);
        if (current < MIN_DELEGATION) return;

        amount = bound(amount, MIN_DELEGATION, current);
        vm.prank(delegator);
        try staking.scheduleDelegatorUnstake(operator, address(0), amount) { } catch { }
    }

    function _claim(address delegator) internal {
        vm.prank(delegator);
        uint256 claimed = distributor.claimAll(address(0));
        totalClaimedNative += claimed;
    }

    receive() external payable { }
}

interface IMultiAssetDelegationLike {
    function depositAndDelegate(address operator) external payable;
    function scheduleDelegatorUnstake(address operator, address token, uint256 amount) external;
    function getDelegation(address delegator, address operator) external view returns (uint256);
    function getOperatorDelegatedStake(address operator) external view returns (uint256);
}

contract ServiceFeeDistributorInvariantTest is StdInvariant, BaseTest {
    ServiceFeeDistributor internal distributor;
    ServiceFeeDistributorInvariantHandler internal handler;

    function setUp() public override {
        super.setUp();

        ServiceFeeDistributor impl = new ServiceFeeDistributor();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(ServiceFeeDistributor.initialize, (admin, address(staking), address(tangle), address(0)))
        );
        distributor = ServiceFeeDistributor(payable(address(proxy)));

        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        staking.setServiceFeeDistributor(address(distributor));
        distributor.setInflationPool(address(this));
        vm.stopPrank();

        _registerOperator(operator1, 5 ether);

        handler =
            new ServiceFeeDistributorInvariantHandler(distributor, address(staking), operator1, delegator1, delegator2);

        vm.prank(admin);
        distributor.setInflationPool(address(handler));

        targetContract(address(handler));
    }

    function invariant_nativeClaimsNeverExceedDistributed() external view {
        uint256 pending = distributor.pendingRewards(delegator1, address(0)) + distributor.pendingRewards(delegator2, address(0));
        uint256 claimed = handler.totalClaimedNative();
        uint256 distributed = handler.totalDistributedNative();

        assertLe(claimed, distributed, "claimed exceeds distributed");
        assertLe(claimed + pending, distributed, "claimed plus pending exceeds distributed");
        assertLe(pending, address(distributor).balance, "pending exceeds distributor balance");
    }
}
