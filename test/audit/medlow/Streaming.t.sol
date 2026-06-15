// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { StreamingPaymentManager } from "../../../src/rewards/StreamingPaymentManager.sol";
import { MockERC20 } from "../../mocks/MockERC20.sol";

/// @dev Minimal Tangle stub exposing only what StreamingPaymentManager.onServiceTerminated reads.
contract StreamingMockTangle {
    mapping(uint64 => address[]) private _ops;

    function setServiceOperators(uint64 serviceId, address[] calldata operators) external {
        _ops[serviceId] = operators;
    }

    function getServiceOperators(uint64 serviceId) external view returns (address[] memory) {
        return _ops[serviceId];
    }
}

/// @title StreamingAuditTest
/// @notice Regression coverage for the audit finding: StreamingPaymentManager stranded the
///         freshly-dripped chunk on `onOperatorLeaving` and `onServiceTerminated`. Both hooks
///         call `_drip()` (which marks the chunk `distributed`) but historically did not move
///         the corresponding tokens, so the earned chunk was locked in the contract forever.
///
/// SECURE INVARIANT under test: every wei `_drip()` marks as `distributed` must physically leave
///         the manager. These tests fail if the transfer-after-drip fix is reverted.
contract StreamingAuditTest is Test {
    StreamingPaymentManager internal manager;
    StreamingMockTangle internal tangle;
    MockERC20 internal payToken;

    address internal admin = makeAddr("admin");
    address internal distributor = makeAddr("distributor");
    address internal operator = makeAddr("operator");
    address internal owner = makeAddr("owner");

    uint64 internal constant SERVICE_ID = 1;
    uint64 internal constant BLUEPRINT_ID = 7;
    uint256 internal constant TOTAL = 100 ether;
    uint64 internal constant TTL = 30 days;

    uint64 internal startTime;
    uint64 internal endTime;

    function setUp() public {
        tangle = new StreamingMockTangle();
        payToken = new MockERC20();

        StreamingPaymentManager impl = new StreamingPaymentManager();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(StreamingPaymentManager.initialize, (admin, address(tangle), distributor))
        );
        manager = StreamingPaymentManager(payable(address(proxy)));

        startTime = uint64(block.timestamp);
        endTime = startTime + TTL;

        // The distributor escrows the whole stream amount in the manager when creating the stream.
        payToken.mint(distributor, TOTAL);
        vm.prank(distributor);
        payToken.transfer(address(manager), TOTAL);

        vm.prank(distributor);
        manager.createStream(SERVICE_ID, BLUEPRINT_ID, operator, address(payToken), TOTAL, startTime, endTime);

        address[] memory ops = new address[](1);
        ops[0] = operator;
        tangle.setServiceOperators(SERVICE_ID, ops);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // onOperatorLeaving — must forward the freshly-dripped chunk to the distributor
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Core regression: after a partial drip on leave, the manager must NOT retain the
    ///      dripped chunk. With the bug, `distributed` is bumped but the tokens stay in the
    ///      manager (managerBalance would stay == TOTAL). The fix forwards the chunk.
    function test_OnOperatorLeaving_ForwardsDrippedChunk_NoStranding() public {
        vm.warp(startTime + TTL / 2);

        uint256 expectedDrip = manager.pendingDrip(SERVICE_ID, operator);
        assertGt(expectedDrip, 0, "precondition: pending drip exists");

        uint256 distBefore = payToken.balanceOf(distributor);

        vm.prank(distributor);
        manager.onOperatorLeaving(SERVICE_ID, operator);

        (,,,,, uint256 distributed,,,) = manager.getStreamingPayment(SERVICE_ID, operator);

        // The chunk marked distributed must have physically left the manager and landed on
        // the distributor. (Reverting the fix leaves distributorGained == 0 -> assertion fails.)
        uint256 distributorGained = payToken.balanceOf(distributor) - distBefore;
        assertEq(distributorGained, distributed, "dripped chunk must be forwarded to distributor");
        assertApproxEqRel(distributorGained, TOTAL / 2, 0.01e18, "should forward ~50%");

        // INVARIANT: manager only still holds the not-yet-distributed remainder. No stranding.
        assertEq(
            payToken.balanceOf(address(manager)),
            TOTAL - distributed,
            "manager must not strand the dripped chunk"
        );
    }

    /// @dev onOperatorLeaving with nothing drippable yet must not move tokens.
    function test_OnOperatorLeaving_NoDripBeforeStart_NoTransfer() public {
        // Still at startTime: nothing has accrued.
        uint256 distBefore = payToken.balanceOf(distributor);

        vm.prank(distributor);
        manager.onOperatorLeaving(SERVICE_ID, operator);

        assertEq(payToken.balanceOf(distributor), distBefore, "no transfer when nothing dripped");
        assertEq(payToken.balanceOf(address(manager)), TOTAL, "escrow untouched");
    }

    function test_OnOperatorLeaving_RevertUnauthorized() public {
        vm.warp(startTime + TTL / 2);
        vm.prank(makeAddr("attacker"));
        vm.expectRevert(StreamingPaymentManager.NotAuthorized.selector);
        manager.onOperatorLeaving(SERVICE_ID, operator);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // onServiceTerminated — drip earned chunk to distributor, refund the rest, conserve total
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev Core regression: on termination the earned (dripped) chunk goes to the distributor
    ///      and only the UNEARNED remainder is refunded to the owner. With the bug the dripped
    ///      chunk was neither refunded nor forwarded — it was locked in the manager.
    function test_OnServiceTerminated_DrippedChunkForwarded_RemainderRefunded() public {
        vm.warp(startTime + TTL / 4); // 25% earned

        uint256 expectedDrip = manager.pendingDrip(SERVICE_ID, operator);
        assertGt(expectedDrip, 0, "precondition: pending drip exists");

        uint256 distBefore = payToken.balanceOf(distributor);
        uint256 ownerBefore = payToken.balanceOf(owner);

        vm.prank(address(tangle));
        manager.onServiceTerminated(SERVICE_ID, owner);

        uint256 distributorGained = payToken.balanceOf(distributor) - distBefore;
        uint256 refund = payToken.balanceOf(owner) - ownerBefore;

        // Earned chunk forwarded to distributor (reverting the fix -> distributorGained == 0).
        assertApproxEqRel(distributorGained, TOTAL / 4, 0.01e18, "earned ~25% forwarded to distributor");
        assertEq(distributorGained, expectedDrip, "forwarded chunk equals the dripped amount");

        // Unearned remainder refunded to the owner.
        assertApproxEqRel(refund, TOTAL * 3 / 4, 0.05e18, "unearned ~75% refunded to owner");

        // CONSERVATION INVARIANT: every escrowed token is accounted for; nothing stranded.
        assertEq(distributorGained + refund, TOTAL, "drip + refund must equal the full escrow");
        assertEq(payToken.balanceOf(address(manager)), 0, "manager holds no stranded tokens");
    }

    /// @dev Stream fully earned at termination: everything goes to the distributor, no refund,
    ///      and crucially nothing is stranded (the whole final chunk is forwarded).
    function test_OnServiceTerminated_FullyEarned_NoStranding() public {
        vm.warp(endTime + 1); // 100% earned

        uint256 distBefore = payToken.balanceOf(distributor);
        uint256 ownerBefore = payToken.balanceOf(owner);

        vm.prank(address(tangle));
        manager.onServiceTerminated(SERVICE_ID, owner);

        assertEq(payToken.balanceOf(distributor) - distBefore, TOTAL, "entire stream forwarded to distributor");
        assertEq(payToken.balanceOf(owner) - ownerBefore, 0, "no refund when fully earned");
        assertEq(payToken.balanceOf(address(manager)), 0, "no stranded tokens");

        (,,,,, uint256 distributed,,,) = manager.getStreamingPayment(SERVICE_ID, operator);
        assertEq(distributed, TOTAL, "stream marked fully distributed");
    }

    /// @dev Already-completed stream: no double-spend, no transfer, total already left earlier.
    function test_OnServiceTerminated_AlreadyCompleted_NoRefundNoForward() public {
        // Drip everything through the normal path first (tokens leave to the distributor).
        vm.warp(endTime + 1);
        vm.prank(distributor);
        manager.dripAndGetChunk(SERVICE_ID, operator);
        assertEq(payToken.balanceOf(address(manager)), 0, "all escrow already dripped out");

        uint256 distBefore = payToken.balanceOf(distributor);
        uint256 ownerBefore = payToken.balanceOf(owner);

        vm.prank(address(tangle));
        manager.onServiceTerminated(SERVICE_ID, owner);

        assertEq(payToken.balanceOf(distributor), distBefore, "no extra forward for completed stream");
        assertEq(payToken.balanceOf(owner), ownerBefore, "no refund for completed stream");
    }

    function test_OnServiceTerminated_RevertUnauthorized() public {
        vm.warp(startTime + TTL / 2);
        vm.prank(makeAddr("attacker"));
        vm.expectRevert(StreamingPaymentManager.NotAuthorized.selector);
        manager.onServiceTerminated(SERVICE_ID, owner);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Cross-check: leave then later normal-drip path is consistent (no residue)
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev After leave forwards the earned chunk, the leftover escrow exactly equals what a
    ///      subsequent full drip can still pay out — proving leave did not over- or under-pay.
    function test_OnOperatorLeaving_LeftoverMatchesRemainingDrip() public {
        vm.warp(startTime + TTL / 2);
        vm.prank(distributor);
        manager.onOperatorLeaving(SERVICE_ID, operator);

        (,,,, uint256 totalAmount, uint256 distributedAfterLeave,,,) =
            manager.getStreamingPayment(SERVICE_ID, operator);
        uint256 remaining = totalAmount - distributedAfterLeave;

        // Escrow left in manager must equal exactly the undistributed remainder.
        assertEq(payToken.balanceOf(address(manager)), remaining, "leftover escrow == remaining accounting");

        // Drip the rest after TTL; the manager should empty out with no residue.
        vm.warp(endTime + 1);
        uint256 distBefore = payToken.balanceOf(distributor);
        vm.prank(distributor);
        manager.dripAndGetChunk(SERVICE_ID, operator);

        assertEq(payToken.balanceOf(distributor) - distBefore, remaining, "remaining fully paid out");
        assertEq(payToken.balanceOf(address(manager)), 0, "no residue after final drip");
    }
}
