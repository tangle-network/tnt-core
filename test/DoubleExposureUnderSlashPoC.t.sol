// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "./BaseTest.sol";
import { Types } from "../src/libraries/Types.sol";
import { SlashingLib } from "../src/libraries/SlashingLib.sol";

/// @title DoubleExposureUnderSlashPoC
/// @notice Regression guard for F-COORD-001 (FIXED): the commitment slash path must
///         scale the operator's committed exposure into the slash EXACTLY ONCE.
///
/// SETUP   : operator commits exposureBps E (=5000 / 50%) to a single-native-asset
///           service whose service-level exposure is the default 100%.
/// ACTION  : the service owner proposes a 100% (10000 bps) slash and executes it
///           after the dispute window.
/// INVARIANT: each exposure dimension is applied to the slash fraction exactly once.
///           `effectiveSlashBps` (set at propose time) carries ONLY the service-level
///           exposure `opData.exposureBps` (=100% here), so it equals the raw slashBps
///           (10000). The per-asset commitment exposure E is then applied exactly once
///           at execute time in `SlashingManager._slashForService`
///           (effectiveBps = effectiveSlashBps * commitment.exposureBps / 1e4). The
///           amount removed from the operator+delegation pool therefore equals
///           slashBps * E/1e4 (single-scaled, 50%). The pre-fix bug ALSO folded the
///           commitment average into effectiveSlashBps at propose time, so the execute
///           path re-scaled by E a second time and removed slashBps * E/1e4 * E/1e4
///           (double-scaled, 25%), under-slashing by half; this test fails if that
///           double-scaling is reintroduced.
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

    function test_ExposureScaledExactlyOnce_NoUnderSlash() public {
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

        // Propose-time `effectiveSlashBps` carries ONLY the service-level exposure
        // (`opData.exposureBps`), NOT the per-asset commitment exposure E. Here the
        // service-level exposure is the default 100% (10000), so:
        //   effectiveSlashBps = slashBps(10000) * opData.exposureBps(10000) / 1e4 = 10000.
        // The commitment exposure E is applied exactly once LATER, at execute time, in
        // SlashingManager._slashForService. Folding E in here too would double-count it
        // (F-COORD-001) and under-slash the operator.
        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(p.slashBps, slashBps, "raw slashBps");
        assertEq(p.effectiveSlashBps, slashBps, "effectiveSlashBps = slashBps * service-level exposure(100%) = slashBps");

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
        // Correct (single exposure scaling): exposure is folded into effectiveSlashBps
        // at propose time (effectiveSlashBps == E), and the execute path must NOT
        // re-scale by commitment.exposureBps a second time. So the realized slash is
        //   slashBps(100%) * E/1e4  ==  E  ==  50% of the exposed pool.
        uint256 intendedSingleScaled = (exposedBefore * E_BPS) / 10_000;
        // The (now-fixed) F-COORD-001 double-scaling would have re-applied E a second
        // time in _slashForService, removing only E*E/1e4 == 25% of the pool. The
        // assertions below must REJECT this value to stay a meaningful regression guard.
        uint256 doubleScaledUnderSlash = (exposedBefore * E_BPS / 10_000) * E_BPS / 10_000;

        emit log_named_uint("pool exposed before              ", exposedBefore);
        emit log_named_uint("correct single-scaled (50%)      ", intendedSingleScaled);
        emit log_named_uint("rejected double-scaled (25%)     ", doubleScaledUnderSlash);
        emit log_named_uint("actualSlashed (executeSlash)     ", actualSlashed);
        emit log_named_uint("removed from pool                ", removed);

        // FIXED: exposure is scaled exactly ONCE. The amount removed equals the
        // single-scaled penalty (50% of pool), matching effectiveSlashBps == E.
        assertEq(removed, actualSlashed, "removed == executeSlash return value");
        assertEq(removed, intendedSingleScaled, "exposure scaled once: removed == slashBps*E (50%)");
        // Regression guard: if double-scaling were reintroduced, removed would equal
        // doubleScaledUnderSlash (25%) and the operator would be under-slashed.
        assertGt(removed, doubleScaledUnderSlash, "no double exposure-scaling / under-slash");
    }
}
