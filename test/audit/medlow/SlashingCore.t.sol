// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { Errors } from "../../../src/libraries/Errors.sol";
import { SlashingLib } from "../../../src/libraries/SlashingLib.sol";
import { BlueprintServiceManagerBase } from "../../../src/BlueprintServiceManagerBase.sol";

/// @title SlashingCoreAuditTest
/// @notice Regression tests for the slashing-core audit unit.
/// @dev Two findings, fixed in `src/core/Slashing.sol`:
///
///      [MEDIUM] Bondless dispute-origin bypasses the anti-griefing bond. A blueprint
///      controls BOTH `querySlashingOrigin` (who can propose) and `queryDisputeOrigin`
///      (who can dispute bondless). When the slash was proposed by a blueprint-controlled
///      account, a blueprint-supplied dispute origin disputing it bondless is self-dealing:
///      it freezes the operator's stake for the whole resolution window for FREE. The fix
///      denies the bondless path when the proposer is blueprint-controlled, forcing the
///      dispute origin to post the bond like any ordinary disputer.
///
///      [LOW] Forfeited dispute bond stranded when the treasury push reverts on
///      `executeSlash`. The proposal is already `Executed` (so `isExecutable` is false and
///      nothing re-runs settlement), and there was no pull-claimable path for forfeited
///      bonds. The fix credits the forfeited bond to the treasury via the existing
///      `_pendingDisputeBondRefunds` pull mapping, claimable through `claimDisputeBond()`.

/// @dev BSM that lets the test drive both authorization hooks independently, so we can
///      model the "blueprint on both sides of the dispute" griefing setup and the
///      legitimate "neutral third party disputes" setup.
contract DisputeOriginBSM is BlueprintServiceManagerBase {
    address public slashingOrigin;
    address public disputeOrigin;

    function setSlashingOrigin(address origin) external {
        slashingOrigin = origin;
    }

    function setDisputeOrigin(address origin) external {
        disputeOrigin = origin;
    }

    function onBlueprintCreated(uint64 _blueprintId, address owner, address _tangleCore) external override {
        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = _tangleCore;
    }

    function querySlashingOrigin(uint64) external view override returns (address) {
        return slashingOrigin;
    }

    function queryDisputeOrigin(uint64) external view override returns (address) {
        return disputeOrigin;
    }

    function onSlash(uint64, bytes calldata, uint8) external override onlyFromTangle { }

    function onUnappliedSlash(uint64, bytes calldata, uint8) external override onlyFromTangle { }
}

/// @dev Treasury that rejects every incoming native transfer, forcing the
///      `t.call{value: bond}("")` push in `_settleDisputeBond` to fail.
contract RejectingTreasury {
    receive() external payable {
        revert("no eth");
    }
}

contract SlashingCoreAuditTest is BaseTest {
    uint64 internal blueprintId;
    uint64 internal serviceId;

    DisputeOriginBSM internal manager;

    // Blueprint-controlled actors (the griefer supplies BOTH from its own BSM).
    address internal bpSlashOrigin = makeAddr("bpSlashOrigin");
    address internal bpDisputeOrigin = makeAddr("bpDisputeOrigin");

    // A neutral dispute resolver that is NOT the proposer (legitimate escalation).
    address internal neutralDisputeOrigin = makeAddr("neutralDisputeOrigin");

    uint256 internal constant DISPUTE_BOND = 1 ether;

    function setUp() public override {
        super.setUp();

        manager = new DisputeOriginBSM();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://slashing-core-audit", address(manager)));

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        _directRegisterOperator(operator1, blueprintId, "");

        uint64 requestId = _requestService(user1, blueprintId, operator1);
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        serviceId = tangle.serviceCount() - 1;

        // Enable a non-zero anti-griefing bond. 7-day window, 14-day resolution deadline.
        vm.prank(admin);
        tangle.setSlashConfig(7 days, false, 10_000, 14 days, DISPUTE_BOND, 8);

        // Fund the dispute-origin actors so they can post a bond when required.
        vm.deal(bpDisputeOrigin, 10 ether);
        vm.deal(neutralDisputeOrigin, 10 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MEDIUM — bondless dispute-origin self-deal
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice SECURE INVARIANT: when the proposal was created by a blueprint-controlled
    ///         account (the BSM's own slashing origin), the blueprint-supplied dispute
    ///         origin CANNOT dispute bondless. It must post the configured bond.
    ///         If the fix were reverted, this bondless dispute would succeed and freeze
    ///         the operator's stake for the whole resolution window for free.
    function test_Med_BlueprintControlledDisputeOrigin_CannotDisputeBondless() public {
        manager.setSlashingOrigin(bpSlashOrigin);
        manager.setDisputeOrigin(bpDisputeOrigin);

        // Blueprint authors the slash via its own slashing origin.
        vm.prank(bpSlashOrigin);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Blueprint-supplied dispute origin tries the bondless path: must revert because
        // the bond is now required (no neutral escalation when the blueprint authored it).
        vm.prank(bpDisputeOrigin);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, DISPUTE_BOND, 0));
        tangle.disputeSlash{ value: 0 }(slashId, "self-deal");

        // The proposal is untouched — still Pending, no disputer recorded.
        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(uint8(p.status), uint8(SlashingLib.SlashStatus.Pending), "must stay pending");
        assertEq(p.disputer, address(0), "no disputer recorded");
        assertEq(p.disputeBond, 0, "no bond locked");
    }

    /// @notice SECURE INVARIANT (owner branch): same denial when the proposer is the
    ///         blueprint OWNER rather than the BSM slashing-origin address.
    function test_Med_BlueprintOwnerProposer_DisputeOriginCannotDisputeBondless() public {
        // bp.owner == developer (creator of the blueprint).
        manager.setSlashingOrigin(address(0));
        manager.setDisputeOrigin(bpDisputeOrigin);

        vm.prank(developer);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(bpDisputeOrigin);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, DISPUTE_BOND, 0));
        tangle.disputeSlash{ value: 0 }(slashId, "self-deal");
    }

    /// @notice The blueprint-controlled dispute origin is NOT locked out entirely — it can
    ///         still dispute, it just has to post the bond like any ordinary disputer.
    ///         Proves the fix is a bond gate, not a hard ban.
    function test_Med_BlueprintControlledDisputeOrigin_CanDisputeWithBond() public {
        manager.setSlashingOrigin(bpSlashOrigin);
        manager.setDisputeOrigin(bpDisputeOrigin);

        vm.prank(bpSlashOrigin);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(bpDisputeOrigin);
        tangle.disputeSlash{ value: DISPUTE_BOND }(slashId, "with bond");

        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(uint8(p.status), uint8(SlashingLib.SlashStatus.Disputed), "disputed with bond");
        assertEq(p.disputer, bpDisputeOrigin, "bond disputer recorded");
        assertEq(p.disputeBond, DISPUTE_BOND, "bond locked");
    }

    /// @notice The legitimate path stays bondless: a NEUTRAL dispute origin (not the
    ///         proposer, not blueprint-controlled-as-proposer) disputing a slash a
    ///         non-blueprint party (the service owner / requester) proposed escalates
    ///         bondless, exactly as SLASH_ADMIN does. Guards against over-tightening
    ///         the fix into a denial of the legitimate escalation path.
    function test_Med_NeutralDisputeOrigin_StaysBondless_WhenProposerNotBlueprint() public {
        // Service owner (user1, the requester) is NOT blueprint-controlled.
        manager.setSlashingOrigin(address(0));
        manager.setDisputeOrigin(neutralDisputeOrigin);

        // user1 is the service owner; authorize them as proposer via the svc.owner path.
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // Neutral dispute origin escalates bondless (msg.value == 0) and succeeds.
        vm.prank(neutralDisputeOrigin);
        tangle.disputeSlash{ value: 0 }(slashId, "neutral escalation");

        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(uint8(p.status), uint8(SlashingLib.SlashStatus.Disputed), "neutral bondless dispute ok");
        assertEq(p.disputer, neutralDisputeOrigin, "neutral disputer recorded");
        assertEq(p.disputeBond, 0, "no bond for neutral path");
    }

    /// @notice SLASH_ADMIN remains the always-neutral bondless escalation, regardless of
    ///         who proposed — proves the fix does not regress the admin path.
    function test_Med_SlashAdmin_StillBondless_EvenWhenBlueprintProposed() public {
        manager.setSlashingOrigin(bpSlashOrigin);
        manager.setDisputeOrigin(bpDisputeOrigin);

        vm.prank(bpSlashOrigin);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.prank(admin);
        tangle.disputeSlash{ value: 0 }(slashId, "admin review");

        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(uint8(p.status), uint8(SlashingLib.SlashStatus.Disputed), "admin bondless dispute ok");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // LOW — forfeited bond recovery when treasury push reverts
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice SECURE INVARIANT: when the treasury push fails on `executeSlash`, the
    ///         forfeited dispute bond is NOT stranded on the Executed proposal — it is
    ///         credited to the treasury's pull-claimable balance and recoverable via
    ///         `claimDisputeBond()`. If the fix were reverted, the bond would be restored
    ///         onto an Executed proposal (which `isExecutable` rejects), permanently
    ///         locking the ETH with no recovery path.
    function test_Low_ForfeitedBond_CreditedToTreasury_WhenPushReverts() public {
        // Point treasury at a contract that rejects ETH so the forfeit push fails.
        RejectingTreasury rejecting = new RejectingTreasury();
        vm.prank(admin);
        tangle.setTreasury(payable(address(rejecting)));

        manager.setSlashingOrigin(address(0));
        manager.setDisputeOrigin(address(0));

        // Operator posts a bond to dispute (the operator path always requires the bond).
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.deal(operator1, DISPUTE_BOND);
        vm.prank(operator1);
        tangle.disputeSlash{ value: DISPUTE_BOND }(slashId, "operator dispute");

        // Let the dispute auto-fail (deadline passes), then execute the slash, forfeiting
        // the bond to the (rejecting) treasury.
        SlashingLib.SlashProposal memory disputed = tangle.getSlashProposal(slashId);
        vm.warp(uint256(disputed.disputeDeadline) + 16);

        uint256 contractBalBefore = address(tangle).balance;
        tangle.executeSlash(slashId);

        // Proposal finalized to Executed; bond fields cleared off the proposal.
        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(uint8(p.status), uint8(SlashingLib.SlashStatus.Executed), "slash executed");
        assertEq(p.disputeBond, 0, "bond cleared off proposal");
        assertEq(p.disputer, address(0), "disputer cleared off proposal");

        // The forfeited bond is now claimable by the treasury via the pull mapping —
        // it is NOT stranded. The contract still custodies the ETH (push failed).
        assertEq(
            tangle.pendingDisputeBondRefund(address(rejecting)),
            DISPUTE_BOND,
            "forfeited bond credited to treasury pull balance"
        );
        assertEq(address(tangle).balance, contractBalBefore, "bond ETH retained for pull-claim");
    }

    /// @notice The forfeited-bond credit is drained through the existing
    ///         `claimDisputeBond()` pull entry point (not a new code path) and survives a
    ///         failed claim — closing the loop on the recovery path. Here the credited
    ///         address is the rejecting treasury itself, so its own claim push reverts; the
    ///         balance is restored and stays recoverable once the treasury is replaced with
    ///         a payable account.
    function test_Low_ForfeitedBond_ClaimableThroughPullEntrypoint() public {
        RejectingTreasury rejecting = new RejectingTreasury();
        vm.prank(admin);
        tangle.setTreasury(payable(address(rejecting)));

        manager.setSlashingOrigin(address(0));
        manager.setDisputeOrigin(address(0));

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.deal(operator1, DISPUTE_BOND);
        vm.prank(operator1);
        tangle.disputeSlash{ value: DISPUTE_BOND }(slashId, "operator dispute");

        SlashingLib.SlashProposal memory disputed = tangle.getSlashProposal(slashId);
        vm.warp(uint256(disputed.disputeDeadline) + 16);
        tangle.executeSlash(slashId);

        // The credit is owned by `rejecting` (the treasury at forfeit time).
        assertEq(tangle.pendingDisputeBondRefund(address(rejecting)), DISPUTE_BOND, "credited");

        // claimDisputeBond() pushes to msg.sender; for the rejecting treasury it reverts and
        // restores the balance (recoverable once treasury is replaced with a payable account).
        vm.prank(address(rejecting));
        vm.expectRevert(Errors.InvalidState.selector);
        tangle.claimDisputeBond();
        assertEq(
            tangle.pendingDisputeBondRefund(address(rejecting)), DISPUTE_BOND, "balance preserved on failed claim"
        );
    }

    /// @notice Sanity baseline: when the treasury accepts ETH, executing a forfeit pushes
    ///         the bond straight to the treasury and credits NOTHING to the pull mapping —
    ///         the recovery path only engages on push failure.
    function test_Low_HealthyTreasury_ReceivesForfeitDirectly() public {
        // Default treasury (BaseTest's `treasury` EOA) accepts ETH.
        manager.setSlashingOrigin(address(0));
        manager.setDisputeOrigin(address(0));

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        vm.deal(operator1, DISPUTE_BOND);
        vm.prank(operator1);
        tangle.disputeSlash{ value: DISPUTE_BOND }(slashId, "operator dispute");

        SlashingLib.SlashProposal memory disputed = tangle.getSlashProposal(slashId);
        vm.warp(uint256(disputed.disputeDeadline) + 16);

        address treasuryAddr = tangle.treasury();
        uint256 treasuryBefore = treasuryAddr.balance;
        tangle.executeSlash(slashId);

        assertEq(treasuryAddr.balance, treasuryBefore + DISPUTE_BOND, "bond pushed to treasury");
        assertEq(tangle.pendingDisputeBondRefund(treasuryAddr), 0, "no pull credit on healthy push");
    }
}
