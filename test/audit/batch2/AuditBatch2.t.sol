// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { Errors } from "../../../src/libraries/Errors.sol";
import { BlueprintServiceManagerBase } from "../../../src/BlueprintServiceManagerBase.sol";

/// @notice BSM that lets operators leave instantly (no min-commitment, no exit queue), so the
///         F1 leave/rejoin dilution can be reproduced inside the slash dispute window.
contract InstantExitBSM is BlueprintServiceManagerBase {
    function getExitConfig(uint64)
        external
        pure
        override
        returns (bool useDefault, uint64 minCommitmentDuration, uint64 exitQueueDuration, bool forceExitAllowed)
    {
        return (false, 0, 0, false);
    }
}

/// @title AuditBatch2Test
/// @notice Reproductions / regression guards for the second audit batch.
contract AuditBatch2Test is BaseTest {
    InstantExitBSM internal bsm;
    uint64 internal dynBlueprint;

    function setUp() public override {
        super.setUp();

        bsm = new InstantExitBSM();

        _registerOperator(operator1, 10 ether);
        _registerOperator(operator2, 10 ether);

        Types.BlueprintConfig memory cfg = Types.BlueprintConfig({
            membership: Types.MembershipModel.Dynamic,
            pricing: Types.PricingModel.PayOnce,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0
        });

        vm.prank(developer);
        dynBlueprint = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://audit-batch2", address(bsm), cfg));

        _registerForBlueprint(operator1, dynBlueprint);
        _registerForBlueprint(operator2, dynBlueprint);
    }

    function _native() internal pure returns (Types.Asset memory) {
        return Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });
    }

    function _commit(uint16 bps) internal pure returns (Types.AssetSecurityCommitment[] memory c) {
        c = new Types.AssetSecurityCommitment[](1);
        c[0] = Types.AssetSecurityCommitment({ asset: _native(), exposureBps: bps });
    }

    /// @dev Spin up an active dynamic service with operator1 (full 100% native commitment) and
    ///      operator2 (filler so a later operator1 exit keeps the service above minOperators).
    function _activeServiceWithFullCommitment() internal returns (uint64 serviceId) {
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            dynBlueprint, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        // operator1 backs the native asset at full exposure; operator2 fills the roster.
        vm.prank(operator1);
        tangle.approveService(_approveWithCommitments(requestId, _commit(10_000)));
        vm.prank(operator2);
        tangle.approveService(_approveWithCommitments(requestId, _commit(10_000)));

        serviceId = tangle.serviceCount() - 1;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // F1 (High): per-asset commitments are snapshotted at propose time
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev A 100% slash is proposed while operator1 backs the native asset at full exposure.
    ///      operator1 then leaves and rejoins with a 1-bps commitment to try to evade the slash.
    ///      With the snapshot fix, `executeSlash` slashes against the propose-time commitment
    ///      (full), not the diluted live one — so ~100% of the native stake is removed.
    function test_F1_SlashUsesCommitmentSnapshotNotDilutedRejoin() public {
        uint64 serviceId = _activeServiceWithFullCommitment();

        uint256 exposedBefore = staking.getOperatorStakeForAsset(operator1, _native());
        assertGt(exposedBefore, 0, "operator has native stake");

        // Service owner proposes a 100% slash; snapshot captures the full native commitment.
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 10_000, keccak256("evidence"));

        // Attacker dilutes: leave instantly (BSM exit config) then rejoin with a 1-bps commitment.
        vm.prank(operator1);
        tangle.leaveService(serviceId);
        vm.prank(operator1);
        tangle.joinServiceWithCommitments(serviceId, 10_000, _commit(1));

        // Past the default 7-day dispute window (+ timestamp buffer).
        vm.warp(block.timestamp + 7 days + 16);
        uint256 actualSlashed = tangle.executeSlash(slashId);

        uint256 exposedAfter = staking.getOperatorStakeForAsset(operator1, _native());
        uint256 removed = exposedBefore - exposedAfter;

        // Snapshot used: ~100% of the exposed native stake is removed. The diluted (1-bps) live
        // commitment would have removed ~0.01% — assert we are nowhere near that under-slash.
        assertEq(removed, actualSlashed, "removed == executeSlash return");
        assertGe(removed, (exposedBefore * 9000) / 10_000, "snapshot slash removes ~full stake, not diluted 1bps");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // F2 (Med): operator self-dispute is no longer free (non-zero default bond)
    // ─────────────────────────────────────────────────────────────────────────

    function test_F2_OperatorSelfDisputeRequiresBond() public {
        uint64 serviceId = _activeServiceWithFullCommitment();

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, 1000, keccak256("evidence"));

        // A free (zero-value) self-dispute is rejected by the non-zero default bond.
        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, uint256(0.02 ether), uint256(0)));
        tangle.disputeSlash(slashId, "free grief");

        // Posting the configured bond succeeds.
        vm.prank(operator1);
        tangle.disputeSlash{ value: 0.02 ether }(slashId, "bonded dispute");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // F9 (Low): duplicate-asset commitments rejected even with no requirements
    // ─────────────────────────────────────────────────────────────────────────

    function test_F9_DuplicateAssetCommitmentRejectedWithoutRequirements() public {
        // Active service (no security requirements on this blueprint).
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            dynBlueprint, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        uint64 serviceId = tangle.serviceCount() - 1;

        // operator2 joins with two commitments for the SAME native asset → must revert.
        Types.AssetSecurityCommitment[] memory dup = new Types.AssetSecurityCommitment[](2);
        dup[0] = Types.AssetSecurityCommitment({ asset: _native(), exposureBps: 5000 });
        dup[1] = Types.AssetSecurityCommitment({ asset: _native(), exposureBps: 5000 });

        vm.prank(operator2);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.DuplicateAssetCommitment.selector, uint8(Types.AssetKind.Native), address(0))
        );
        tangle.joinServiceWithCommitments(serviceId, 10_000, dup);
    }
}
