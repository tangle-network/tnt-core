// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { InflationPool } from "../../src/rewards/InflationPool.sol";
import { TangleMetrics } from "../../src/rewards/TangleMetrics.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";

/// @title InflationPoolDeregisterTest
/// @notice Regression: `deregisterOperator` removes an operator from `trackedOperators`,
///         clears its registration epoch, and lets the index shrink instead of growing
///         monotonically as inactive operators accumulate.
contract InflationPoolDeregisterTest is Test {
    InflationPool pool;
    address admin = makeAddr("admin");
    address tnt = address(0xDEAD);

    function setUp() public {
        InflationPool impl = new InflationPool();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl), abi.encodeCall(InflationPool.initialize, (admin, tnt, address(0), address(0), 7 days))
        );
        pool = InflationPool(payable(address(proxy)));
    }

    function _trackedCount() internal view returns (uint256 count) {
        // `trackedOperators` is `address[] public`; length is exposed indirectly.
        // Iterate by slot until we hit a revert or zero - simpler to just probe with try/catch.
        while (true) {
            try pool.trackedOperators(count) returns (address) {
                count++;
            } catch {
                return count;
            }
        }
    }

    function test_DeregisterOperator_RemovesFromTrackedList() public {
        address[] memory ops = new address[](3);
        ops[0] = makeAddr("op1");
        ops[1] = makeAddr("op2");
        ops[2] = makeAddr("op3");

        vm.prank(admin);
        pool.registerOperators(ops);

        assertEq(_trackedCount(), 3, "all three tracked");
        assertTrue(pool.isTrackedOperator(ops[1]));

        vm.prank(admin);
        pool.deregisterOperator(ops[1]);

        assertEq(_trackedCount(), 2, "shrinks after deregister");
        assertFalse(pool.isTrackedOperator(ops[1]));
        assertEq(pool.operatorRegistrationEpoch(ops[1]), 0, "registration epoch cleared");
    }

    function test_DeregisterOperator_NonAdminReverts() public {
        address attacker = makeAddr("attacker");
        vm.prank(admin);
        pool.registerOperator(makeAddr("op"));

        vm.prank(attacker);
        vm.expectRevert();
        pool.deregisterOperator(makeAddr("op"));
    }

    function test_DeregisterOperator_AllowsReregistration() public {
        address op = makeAddr("op");

        vm.startPrank(admin);
        pool.registerOperator(op);
        pool.deregisterOperator(op);
        pool.registerOperator(op);
        vm.stopPrank();

        assertTrue(pool.isTrackedOperator(op));
        assertEq(_trackedCount(), 1);
    }
}

/// @notice Minimal `IStaking.isOperatorActive` source for gating operator reward scoring.
/// @dev Only `isOperatorActive` is exercised by `_distributeOperatorRewards`; every other
///      `IStaking` member reverts so the test proves the gate relies solely on the active flag.
contract MockOperatorStatusSource {
    mapping(address => bool) public active;

    function setActive(address operator, bool isActive_) external {
        active[operator] = isActive_;
    }

    function isOperatorActive(address operator) external view returns (bool) {
        return active[operator];
    }

    // Any other call would indicate the gate read the wrong thing.
    fallback() external {
        revert("unexpected IStaking call");
    }
}

/// @title InflationPoolLiveStatusGateTest
/// @notice Security regression: operator reward scoring must be gated on LIVE operator status,
///         so a deregistered / leaving / slashed-inactive operator accrues 0 NEW
///         `pendingOperatorRewards` automatically — without any admin `deregisterOperator` call —
///         instead of diluting the active operators until an admin intervenes.
contract InflationPoolLiveStatusGateTest is Test {
    InflationPool pool;
    TangleMetrics metrics;
    MockERC20 tnt;
    MockOperatorStatusSource statusSource;

    address admin = makeAddr("admin");
    address opActive = makeAddr("opActive");
    address opInactive = makeAddr("opInactive");

    uint256 constant EPOCH_LENGTH = 100;
    uint256 constant POOL_FUNDING = 1_000_000 ether;

    function setUp() public {
        vm.startPrank(admin);

        // Real ERC20 so the pool can compute an epoch budget (poolBalance > 0) and reach the
        // operator scoring path. Operator rewards are pure accounting (no transfer) once scored.
        tnt = new MockERC20();
        tnt.mint(admin, POOL_FUNDING);

        // Metrics (records operator activity that scoring reads).
        TangleMetrics metricsImpl = new TangleMetrics();
        ERC1967Proxy metricsProxy =
            new ERC1967Proxy(address(metricsImpl), abi.encodeCall(TangleMetrics.initialize, (admin)));
        metrics = TangleMetrics(address(metricsProxy));
        metrics.grantRecorderRole(address(this));

        // Pool with vaults disabled (address(0)) so only the operator pot is exercised.
        InflationPool poolImpl = new InflationPool();
        ERC1967Proxy poolProxy = new ERC1967Proxy(
            address(poolImpl),
            abi.encodeCall(InflationPool.initialize, (admin, address(tnt), address(metrics), address(0), EPOCH_LENGTH))
        );
        pool = InflationPool(payable(address(poolProxy)));

        // Fund the pool so calculateEpochBudget() > 0.
        tnt.approve(address(pool), POOL_FUNDING);
        pool.fund(POOL_FUNDING);

        statusSource = new MockOperatorStatusSource();
        pool.setOperatorStatusSource(address(statusSource));

        address[] memory ops = new address[](2);
        ops[0] = opActive;
        ops[1] = opInactive;
        pool.registerOperators(ops);

        vm.stopPrank();

        // Identical on-chain activity for both operators, so any difference in accrual is due
        // solely to the live-status gate, not to differing scores.
        metrics.recordOperatorRegistered(opActive, address(0), 100 ether);
        metrics.recordOperatorRegistered(opInactive, address(0), 100 ether);
        metrics.recordJobCompletion(opActive, 1, 0, true);
        metrics.recordJobCompletion(opInactive, 1, 1, true);
        metrics.recordHeartbeat(opActive, 1, uint64(block.timestamp));
        metrics.recordHeartbeat(opInactive, 1, uint64(block.timestamp));
    }

    function _distribute() internal {
        // minStakeEpochs default is 1: an operator registered in epoch 1 is only eligible from
        // epoch 2 onward. Distribute epoch 1 (ineligible), then epoch 2 (eligible) — mirrors
        // the working InflationPoolTest.test_OperatorRewards flow.
        InflationPool.EpochData memory e1 = pool.getEpoch(pool.currentEpoch());
        vm.warp(e1.endTimestamp + 1);
        pool.distributeEpoch();

        InflationPool.EpochData memory e2 = pool.getEpoch(pool.currentEpoch());
        vm.warp(e2.endTimestamp + 1);
        pool.distributeEpoch();
    }

    function test_InactiveOperator_AccruesNoNewRewards() public {
        statusSource.setActive(opActive, true);
        statusSource.setActive(opInactive, false);

        _distribute();

        // Active operator captured the operator pot; inactive operator got nothing despite
        // identical metrics and never being deregistered by an admin.
        assertGt(pool.pendingOperatorRewards(opActive), 0, "active operator should accrue");
        assertEq(pool.pendingOperatorRewards(opInactive), 0, "inactive operator must accrue 0");
    }

    function test_BothActive_BothAccrue() public {
        statusSource.setActive(opActive, true);
        statusSource.setActive(opInactive, true);

        _distribute();

        assertGt(pool.pendingOperatorRewards(opActive), 0, "operator 1 accrues");
        assertGt(pool.pendingOperatorRewards(opInactive), 0, "operator 2 accrues");
    }

    function test_NoSourceConfigured_GateIsNoOp() public {
        // Backward-compat: a pool with no status source wired must behave as before (both score).
        vm.prank(admin);
        pool.setOperatorStatusSource(address(0));

        // Even with the mock marking one inactive, the unset gate must not zero it.
        statusSource.setActive(opActive, true);
        statusSource.setActive(opInactive, false);

        _distribute();

        assertGt(pool.pendingOperatorRewards(opActive), 0, "operator 1 accrues with no gate");
        assertGt(pool.pendingOperatorRewards(opInactive), 0, "operator 2 accrues with no gate");
    }
}
