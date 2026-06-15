// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../../BaseTest.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { MockBSM_V1 } from "../../blueprints/mocks/MockBSM.sol";
import { MockERC20 } from "../../mocks/MockERC20.sol";

/// @title SvcApprovalsAuditTest
/// @notice Regression coverage for the svc-approvals audit unit.
/// @dev Finding (medium, launch-gating): `ServicesApprovals.approveService` derived the
///      `stakingPercent` it forwards to the blueprint manager's `onApprove` hook from
///      `securityCommitments[0].exposureBps` ONLY — the first asset commitment. When an
///      operator commits to multiple required assets at different exposures, the hook
///      received whatever the first commitment happened to be, not a value representative
///      of the operator's true binding exposure. An operator could commit 100% on the
///      first (cheap/abundant) asset and the bare minimum on the rest, and the manager
///      would see 100% — inflating every launch/admission gating decision that reads this
///      percent. The fix derives the percent from the MINIMUM committed exposure across
///      all of the operator's commitments, which is the conservative, non-gameable floor:
///      a service's effective security is bounded by its weakest asset commitment.
///
///      The manager hook value is observed via `MockBSM_V1.approveStakingPercent`, which
///      records the exact `stakingPercent` argument `onApprove` was called with.
contract SvcApprovalsAuditTest is BaseTest {
    uint16 internal constant BPS = 10_000; // BPS_DENOMINATOR — 100%
    uint16 internal constant DEFAULT_TNT_MIN_BPS = 1000; // DEFAULT_TNT_MIN_EXPOSURE_BPS — 10%

    MockBSM_V1 internal bsm;
    MockERC20 internal tnt; // becomes the protocol-default TNT asset
    MockERC20 internal other; // a second required asset
    uint64 internal blueprintId;

    function setUp() public override {
        super.setUp();

        // The default-TNT requirement (and thus the multi-requirement shape we need) is
        // only materialized when `_tntToken` is configured.
        tnt = new MockERC20();
        other = new MockERC20();
        vm.prank(admin);
        tangle.setTntToken(address(tnt));

        bsm = new MockBSM_V1();
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://svc-approvals-audit", address(bsm)));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────────

    function _erc20Asset(address token) internal pure returns (Types.Asset memory) {
        return Types.Asset({ kind: Types.AssetKind.ERC20, token: token });
    }

    function _requirement(address token, uint16 minBps) internal pure returns (Types.AssetSecurityRequirement memory) {
        return Types.AssetSecurityRequirement({ asset: _erc20Asset(token), minExposureBps: minBps, maxExposureBps: BPS });
    }

    function _commitment(address token, uint16 bps) internal pure returns (Types.AssetSecurityCommitment memory) {
        return Types.AssetSecurityCommitment({ asset: _erc20Asset(token), exposureBps: bps });
    }

    /// @notice Request a service for `operator1` carrying two distinct asset security
    ///         requirements: the protocol-default TNT asset plus `other`. Because TNT is
    ///         supplied explicitly, the request path does NOT auto-append a second TNT
    ///         requirement, so the operator must commit to exactly two assets at approval.
    function _requestTwoAssetService() internal returns (uint64 requestId) {
        address[] memory ops = new address[](1);
        ops[0] = operator1;

        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](2);
        // TNT requirement must be >= the protocol default min; keep both wide-open (min=10%, max=100%).
        reqs[0] = _requirement(address(tnt), DEFAULT_TNT_MIN_BPS);
        reqs[1] = _requirement(address(other), DEFAULT_TNT_MIN_BPS);

        vm.prank(user1);
        requestId = tangle.requestServiceWithSecurity(
            blueprintId, ops, reqs, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any
        );
    }

    function _approveWithTwoCommitments(uint64 requestId, uint16 tntBps, uint16 otherBps) internal {
        Types.AssetSecurityCommitment[] memory cm = new Types.AssetSecurityCommitment[](2);
        cm[0] = _commitment(address(tnt), tntBps);
        cm[1] = _commitment(address(other), otherBps);

        Types.ApprovalParams memory p;
        p.requestId = requestId;
        p.securityCommitments = cm;

        vm.prank(operator1);
        tangle.approveService(p);
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MEDIUM: onApprove stakingPercent reflects the MINIMUM committed exposure
    // ─────────────────────────────────────────────────────────────────────────

    /// @dev SECURE INVARIANT (the core fix): with the high commitment FIRST and the low
    ///      commitment second, the manager must receive the LOW (minimum) percent. Under
    ///      the reverted bug it would receive `commitments[0]` = 100, letting the operator
    ///      inflate the gating signal while binding only 10% of collateral on `other`.
    function test_onApprove_usesMinExposure_highFirst() public {
        uint64 requestId = _requestTwoAssetService();

        // Commit 100% on TNT (first), 10% on `other` (second). True binding floor = 10%.
        _approveWithTwoCommitments(requestId, BPS, DEFAULT_TNT_MIN_BPS);

        assertEq(
            bsm.approveStakingPercent(requestId, operator1),
            uint8(DEFAULT_TNT_MIN_BPS / 100), // 10
            "onApprove stakingPercent must be the MINIMUM committed exposure, not commitments[0]"
        );
    }

    /// @dev Order-independence: with the low commitment FIRST and the high second, the
    ///      manager still receives the LOW (minimum) percent. This proves the fix computes
    ///      a true minimum rather than accidentally reading the last element. Note that
    ///      under the OLD `commitments[0]` behavior this case ALSO returned 10 — so this
    ///      test alone cannot catch the bug; it pairs with `highFirst` to pin the invariant.
    function test_onApprove_usesMinExposure_lowFirst() public {
        uint64 requestId = _requestTwoAssetService();

        _approveWithTwoCommitments(requestId, DEFAULT_TNT_MIN_BPS, BPS);

        assertEq(
            bsm.approveStakingPercent(requestId, operator1),
            uint8(DEFAULT_TNT_MIN_BPS / 100), // 10
            "onApprove stakingPercent must be the MINIMUM committed exposure regardless of order"
        );
    }

    /// @dev Intermediate values: 75% TNT, 30% other -> min 30%. Confirms the percent is the
    ///      genuine arithmetic minimum across commitments, not a boundary artifact.
    function test_onApprove_usesMinExposure_intermediate() public {
        uint64 requestId = _requestTwoAssetService();

        _approveWithTwoCommitments(requestId, 7500, 3000);

        assertEq(
            bsm.approveStakingPercent(requestId, operator1),
            uint8(30),
            "onApprove stakingPercent must equal min(75%,30%)/100 = 30"
        );
    }

    /// @dev Single-commitment path still maps to that commitment's exposure (min over one
    ///      element == that element). Guards against the fix regressing the simple path.
    function test_onApprove_singleCommitment_unchanged() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;

        // No explicit requirements: the request carries only the auto-appended default-TNT
        // requirement, so a single TNT commitment is the full set.
        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any);

        Types.AssetSecurityCommitment[] memory cm = new Types.AssetSecurityCommitment[](1);
        cm[0] = _commitment(address(tnt), 2500); // 25%

        Types.ApprovalParams memory p;
        p.requestId = requestId;
        p.securityCommitments = cm;

        vm.prank(operator1);
        tangle.approveService(p);

        assertEq(
            bsm.approveStakingPercent(requestId, operator1),
            uint8(25),
            "single-commitment path must report that commitment's exposure"
        );
    }

    /// @dev Auto-fill path (operator omits commitments on a default-TNT-only request) is
    ///      unaffected by the fix: the hook still receives the auto-filled min-exposure
    ///      percent. Co-located here so the whole `effectiveStakingPercent` branch set is
    ///      pinned by this audit file.
    function test_onApprove_autoFilledDefault_unchanged() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(blueprintId, ops, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.Any);

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));

        assertEq(
            bsm.approveStakingPercent(requestId, operator1),
            uint8(tangle.defaultTntMinExposureBps() / 100),
            "auto-filled default path must report the requirement min exposure"
        );
    }
}
