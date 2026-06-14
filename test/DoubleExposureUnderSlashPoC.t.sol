// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../src/libraries/Types.sol";
import { SlashingLib } from "../src/libraries/SlashingLib.sol";

/// @title DoubleExposureUnderSlashPoC
/// @notice Reproduces F-COORD-001: the commitment slash path scales the operator's
///         committed exposure into the slash TWICE, systematically under-slashing.
///
/// SETUP   : operator commits exposureBps E (=5000 / 50%) to a single-native-asset
///           service whose service-level exposure is the default 100%.
/// ATTACK  : the service owner proposes a 100% (10000 bps) slash and executes it
///           after the dispute window.
/// OUTCOME : the amount actually removed from the operator+delegation pool equals
///           slashBps * E/1e4 * E/1e4  (double-scaled, 25%) instead of the intended
///           slashBps * E/1e4 (single-scaled, 50%). The no-commitment fallback
///           (_slashForBlueprint) scales exposure only once.
contract DoubleExposureUnderSlashPoC is BaseTest {
    uint64 internal blueprintId;

    // Operator commits E = 50% exposure to the single required native asset.
    uint16 internal constant E_BPS = 5000;

    function setUp() public override {
        super.setUp();

        // Take the simple-average commitment branch in
        // _computeServiceCommitmentExposureBps by disabling the Tangle-side
        // service-fee distributor. For a single asset the average == E exactly.
        vm.prank(admin);
        tangle.setServiceFeeDistributor(address(0));

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://poc", address(0)));

        // Operator with 1 ether native self-stake, open to delegation.
        _registerOperator(operator1, MIN_OPERATOR_STAKE);
        _registerForBlueprint(operator1, blueprintId);

        // Delegator adds 10 ether native into the all-mode pool.
        vm.prank(delegator1);
        staking.depositAndDelegate{ value: 10 ether }(operator1);
    }

    function _nativeAsset() internal pure returns (Types.Asset memory) {
        return Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });
    }

    function test_DoubleExposureScaling_UnderSlashes() public {
        // ── Service with a single native AssetSecurityRequirement ──────────────
        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](1);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: _nativeAsset(),
            minExposureBps: 1000,
            maxExposureBps: 10_000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, ops, reqs, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );

        // Operator commits exposureBps E to the native asset.
        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](1);
        commits[0] = Types.AssetSecurityCommitment({ asset: _nativeAsset(), exposureBps: E_BPS });

        vm.prank(operator1);
        tangle.approveService(_approveWithCommitments(requestId, commits));

        uint64 serviceId = tangle.serviceCount() - 1;

        // ── Propose a 100% slash ───────────────────────────────────────────────
        uint16 slashBps = 10_000; // 100%
        vm.prank(user1); // user1 is the service owner
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, slashBps, keccak256("evidence"));

        // Propose-time exposure scaling is already baked into effectiveSlashBps:
        //   effectiveExposureBps = opData.exposureBps(10000) * commitmentBps(E) / 1e4 = E
        //   effectiveSlashBps    = slashBps(10000) * E / 1e4 = E
        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(p.slashBps, slashBps, "raw slashBps");
        assertEq(p.effectiveSlashBps, E_BPS, "effectiveSlashBps already exposure-scaled once == E");

        // ── Measure the native pool, execute past the dispute window ────────────
        uint256 exposedBefore = tangle.getSlashProposal(slashId).effectiveSlashBps == 0
            ? 0
            : staking.getOperatorStakeForAsset(operator1, _nativeAsset());

        // Default dispute window is 7 days; add the timestamp buffer.
        vm.warp(block.timestamp + 7 days + 1 hours);

        uint256 actualSlashed = tangle.executeSlash(slashId);

        uint256 exposedAfter = staking.getOperatorStakeForAsset(operator1, _nativeAsset());
        uint256 removed = exposedBefore - exposedAfter;

        // ── Expected amounts ───────────────────────────────────────────────────
        // Intended (single exposure scaling): remove effectiveSlashBps (=E=50%) of pool.
        uint256 intendedSingleScaled = (exposedBefore * E_BPS) / 10_000;
        // Actual (double exposure scaling): effectiveSlashBps is re-scaled by
        // commitment.exposureBps in _slashForService => E * E / 1e4 = 25%.
        uint256 expectedDoubleScaled = (exposedBefore * E_BPS / 10_000) * E_BPS / 10_000;

        emit log_named_uint("pool exposed before          ", exposedBefore);
        emit log_named_uint("intended single-scaled (50%) ", intendedSingleScaled);
        emit log_named_uint("expected double-scaled (25%) ", expectedDoubleScaled);
        emit log_named_uint("actualSlashed (executeSlash) ", actualSlashed);
        emit log_named_uint("removed from pool            ", removed);

        // The bug: removed matches the DOUBLE-scaled amount, not the intended one.
        assertEq(removed, actualSlashed, "removed == executeSlash return value");
        assertEq(removed, expectedDoubleScaled, "BUG: slash is double exposure-scaled (25%)");
        assertTrue(removed < intendedSingleScaled, "BUG: operator under-slashed vs intent");

        // Quantify: exactly half of the intended penalty is applied for E=50%.
        assertEq(intendedSingleScaled - removed, intendedSingleScaled / 2, "under-slash == 50% of intended");
    }
}
