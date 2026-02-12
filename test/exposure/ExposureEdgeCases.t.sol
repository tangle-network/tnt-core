// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { ExposureManager } from "../../src/exposure/ExposureManager.sol";
import { ExposureTypes } from "../../src/exposure/ExposureTypes.sol";
import { ExposureCalculator } from "../../src/exposure/ExposureCalculator.sol";
import { Types } from "../../src/libraries/Types.sol";
import { SlashingLib } from "../../src/libraries/SlashingLib.sol";
import { IStaking } from "../../src/interfaces/IStaking.sol";

/// @notice Mock staking for testing
contract MockStakingEdge is IStaking {
    mapping(address => bool) public operators;
    mapping(address => uint256) public stakes;
    mapping(address => uint256) public delegatedStakes;

    function setOperator(address operator, bool isOp) external {
        operators[operator] = isOp;
    }

    function setStake(address operator, uint256 amount) external {
        stakes[operator] = amount;
    }

    function setDelegatedStake(address operator, uint256 amount) external {
        delegatedStakes[operator] = amount;
    }

    function isOperator(address account) external view returns (bool) {
        return operators[account];
    }

    function isOperatorActive(address) external pure returns (bool) {
        return true;
    }

    function getOperatorStake(address operator) external view returns (uint256) {
        return stakes[operator];
    }

    function getOperatorSelfStake(address operator) external view returns (uint256) {
        return stakes[operator];
    }

    function getOperatorDelegatedStake(address operator) external view returns (uint256) {
        return delegatedStakes[operator];
    }

    function getOperatorDelegatedStakeForAsset(address operator, Types.Asset calldata) external view returns (uint256) {
        return delegatedStakes[operator];
    }

    function getOperatorStakeForAsset(address operator, Types.Asset calldata) external view returns (uint256) {
        return stakes[operator];
    }

    function getDelegation(address, address) external pure returns (uint256) {
        return 0;
    }

    function getTotalDelegation(address) external pure returns (uint256) {
        return 0;
    }

    function minOperatorStake() external pure returns (uint256) {
        return 0;
    }

    function meetsStakeRequirement(address, uint256) external pure returns (bool) {
        return true;
    }

    function slashForBlueprint(address, uint64, uint64, uint16 slashBps, bytes32) external pure returns (uint256) {
        return slashBps;
    }

    function slashForService(
        address,
        uint64,
        uint64,
        Types.AssetSecurityCommitment[] calldata,
        uint16 slashBps,
        bytes32
    )
        external
        pure
        returns (uint256)
    {
        return slashBps;
    }

    function slash(address, uint64, uint16 slashBps, bytes32) external pure returns (uint256) {
        return slashBps;
    }

    function isSlasher(address) external pure returns (bool) {
        return false;
    }
    function notifyRewardForBlueprint(address, uint64, uint64, uint256) external { }
    function notifyReward(address, uint64, uint256) external { }
    function addBlueprintForOperator(address, uint64) external override { }
    function removeBlueprintForOperator(address, uint64) external override { }

    // M-9 FIX: Pending slash tracking (no-op for mock)
    function incrementPendingSlash(address) external override { }
    function decrementPendingSlash(address) external override { }

    function getPendingSlashCount(address) external pure override returns (uint64) {
        return 0;
    }
}

/// @title ExposureEdgeCasesTest
/// @notice Comprehensive edge case and boundary testing for exposure system
contract ExposureEdgeCasesTest is Test {
    ExposureManager public manager;
    MockStakingEdge public staking;

    address public operator1;
    address public operator2;
    address public operator3;

    Types.Asset public nativeAsset;
    Types.Asset public erc20Asset;

    function setUp() public {
        operator1 = makeAddr("operator1");
        operator2 = makeAddr("operator2");
        operator3 = makeAddr("operator3");

        staking = new MockStakingEdge();
        staking.setOperator(operator1, true);
        staking.setOperator(operator2, true);
        staking.setOperator(operator3, true);

        staking.setStake(operator1, 100 ether);
        staking.setStake(operator2, 1000 ether);
        staking.setStake(operator3, 1 wei);

        manager = new ExposureManager(address(staking));

        nativeAsset = Types.Asset(Types.AssetKind.Native, address(0));
        erc20Asset = Types.Asset(Types.AssetKind.ERC20, makeAddr("token"));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BOUNDARY VALUE TESTS (0, 1, 9999, 10000)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Exposure_BoundaryZero_RejectedByRequirement() public {
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1, // Minimum is 0.01%
            maxExposureBps: 10_000
        });

        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 0 // Zero exposure
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(operator1, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "Commitment below minimum");
    }

    function test_Exposure_BoundaryOne_MinimumValid() public {
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] =
            Types.AssetSecurityRequirement({ asset: nativeAsset, minExposureBps: 1, maxExposureBps: 10_000 });

        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 1 // Minimum 0.01%
        });

        (bool valid,) = manager.validateCommitments(operator1, requirements, commitments);
        assertTrue(valid);
    }

    function test_Exposure_Boundary9999_JustUnderMax() public {
        vm.prank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 10_000, 5000, true);

        (bool canAccept, uint16 limit) = manager.canAcceptExposure(operator1, nativeAsset, 9999);
        assertTrue(canAccept);
        assertEq(limit, 10_000);
    }

    function test_Exposure_Boundary10000_FullExposure() public {
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](1);
        requirements[0] =
            Types.AssetSecurityRequirement({ asset: nativeAsset, minExposureBps: 1, maxExposureBps: 10_000 });

        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 10_000 // 100%
        });

        (bool valid,) = manager.validateCommitments(operator1, requirements, commitments);
        assertTrue(valid);
    }

    function test_Exposure_Boundary10001_ExceedsMax() public {
        vm.prank(operator1);
        vm.expectRevert();
        manager.setAssetExposureLimit(nativeAsset, 10_001, 5000, true);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // LARGE VALUE / OVERFLOW TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExposedAmount_LargeStake_NoOverflow() public {
        // Set up operator with max uint128 stake
        address bigOperator = makeAddr("bigOperator");
        staking.setOperator(bigOperator, true);
        staking.setStake(bigOperator, type(uint128).max);

        (uint256 delegated, uint256 exposed) = manager.calculateExposedAmount(bigOperator, nativeAsset, 10_000);

        assertEq(delegated, type(uint128).max);
        assertEq(exposed, type(uint128).max); // 100% exposure
    }

    function test_ExposedAmount_LargeStake_HalfExposure() public {
        address bigOperator = makeAddr("bigOperator");
        staking.setOperator(bigOperator, true);
        staking.setStake(bigOperator, type(uint128).max);

        (uint256 delegated, uint256 exposed) = manager.calculateExposedAmount(bigOperator, nativeAsset, 5000);

        assertEq(delegated, type(uint128).max);
        assertEq(exposed, type(uint128).max / 2); // 50% exposure
    }

    function test_CalculatorLib_LargeValues_NoOverflow() public pure {
        uint256 largeAmount = type(uint128).max;

        // Should not overflow
        uint256 exposed = ExposureCalculator.calculateExposedAmount(largeAmount, 10_000);
        assertEq(exposed, largeAmount);

        exposed = ExposureCalculator.calculateExposedAmount(largeAmount, 5000);
        assertEq(exposed, largeAmount / 2);

        exposed = ExposureCalculator.calculateExposedAmount(largeAmount, 1);
        assertEq(exposed, largeAmount / 10_000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TINY STAKE / ROUNDING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ExposedAmount_TinyStake_RoundsDown() public {
        // operator3 has 1 wei stake
        (uint256 delegated, uint256 exposed) = manager.calculateExposedAmount(operator3, nativeAsset, 5000);

        assertEq(delegated, 1);
        assertEq(exposed, 0); // 1 * 5000 / 10000 = 0 (rounds down)
    }

    function test_ExposedAmount_TinyStake_FullExposure() public {
        (uint256 delegated, uint256 exposed) = manager.calculateExposedAmount(operator3, nativeAsset, 10_000);

        assertEq(delegated, 1);
        assertEq(exposed, 1); // 100% of 1 wei = 1 wei
    }

    function test_CalculatorLib_SmallValuesRounding() public pure {
        // 1 wei with 1 bps (0.01%) = 0 (rounds down)
        assertEq(ExposureCalculator.calculateExposedAmount(1, 1), 0);

        // 10000 wei with 1 bps = 1 wei
        assertEq(ExposureCalculator.calculateExposedAmount(10_000, 1), 1);

        // 99 with 100 bps (1%) = 0 (rounds down)
        assertEq(ExposureCalculator.calculateExposedAmount(99, 100), 0);

        // 100 with 100 bps (1%) = 1
        assertEq(ExposureCalculator.calculateExposedAmount(100, 100), 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-OPERATOR SCENARIOS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultiOperator_DifferentLimits_Independent() public {
        // Each operator sets different limits
        vm.prank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 2500, 1000, true); // Max 25%

        vm.prank(operator2);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true); // Max 50%

        vm.prank(operator3);
        manager.setAssetExposureLimit(nativeAsset, 10_000, 5000, true); // Max 100%

        // Verify each operator's limit is independent
        (bool canAccept1,) = manager.canAcceptExposure(operator1, nativeAsset, 3000);
        (bool canAccept2,) = manager.canAcceptExposure(operator2, nativeAsset, 3000);
        (bool canAccept3,) = manager.canAcceptExposure(operator3, nativeAsset, 3000);

        assertFalse(canAccept1); // 30% exceeds 25% limit
        assertTrue(canAccept2); // 30% within 50% limit
        assertTrue(canAccept3); // 30% within 100% limit
    }

    function test_MultiOperator_SameAsset_DifferentExposures() public {
        // All operators registered with different stakes
        // Simulate weighted exposure calculation

        uint256[] memory delegations = new uint256[](3);
        delegations[0] = 100 ether; // operator1
        delegations[1] = 1000 ether; // operator2
        delegations[2] = 50 ether; // operator3

        uint16[] memory exposures = new uint16[](3);
        exposures[0] = 5000; // 50%
        exposures[1] = 2500; // 25%
        exposures[2] = 10_000; // 100%

        uint16 weighted = ExposureCalculator.calculateWeightedExposure(delegations, exposures);

        // Expected: (100*50 + 1000*25 + 50*100) / 1150 = (5000 + 25000 + 5000) / 1150 = 30.43%
        assertEq(weighted, 3043);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-ASSET SCENARIOS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MultiAsset_DifferentLimitsPerAsset() public {
        Types.Asset memory asset2 = Types.Asset(Types.AssetKind.ERC20, makeAddr("token2"));
        Types.Asset memory asset3 = Types.Asset(Types.AssetKind.ERC20, makeAddr("token3"));

        vm.startPrank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true); // Native: 50%
        manager.setAssetExposureLimit(erc20Asset, 3000, 1500, true); // Token1: 30%
        manager.setAssetExposureLimit(asset2, 10_000, 5000, true); // Token2: 100%
        // asset3 has no limit set
        vm.stopPrank();

        (bool canAccept1,) = manager.canAcceptExposure(operator1, nativeAsset, 4000);
        (bool canAccept2,) = manager.canAcceptExposure(operator1, erc20Asset, 4000);
        (bool canAccept3,) = manager.canAcceptExposure(operator1, asset2, 4000);
        (bool canAccept4,) = manager.canAcceptExposure(operator1, asset3, 4000);

        assertTrue(canAccept1); // 40% < 50%
        assertFalse(canAccept2); // 40% > 30%
        assertTrue(canAccept3); // 40% < 100%
        assertTrue(canAccept4); // No limit, defaults to 100%
    }

    function test_MultiAsset_BatchSet_AllApplied() public {
        ExposureTypes.OperatorAssetExposureLimit[] memory limits = new ExposureTypes.OperatorAssetExposureLimit[](3);

        limits[0] = ExposureTypes.OperatorAssetExposureLimit({
            asset: nativeAsset, maxExposureBps: 5000, defaultExposureBps: 2500, enabled: true
        });

        limits[1] = ExposureTypes.OperatorAssetExposureLimit({
            asset: erc20Asset, maxExposureBps: 3000, defaultExposureBps: 1500, enabled: true
        });

        limits[2] = ExposureTypes.OperatorAssetExposureLimit({
            asset: Types.Asset(Types.AssetKind.ERC20, makeAddr("token2")),
            maxExposureBps: 10_000,
            defaultExposureBps: 5000,
            enabled: true
        });

        vm.prank(operator1);
        manager.batchSetAssetExposureLimits(limits);

        // Verify all were set
        ExposureTypes.OperatorAssetExposureLimit memory l1 = manager.getAssetExposureLimit(operator1, nativeAsset);
        ExposureTypes.OperatorAssetExposureLimit memory l2 = manager.getAssetExposureLimit(operator1, erc20Asset);

        assertEq(l1.maxExposureBps, 5000);
        assertEq(l2.maxExposureBps, 3000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GLOBAL VS PER-ASSET LIMIT PRECEDENCE
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GlobalLimit_AppliesWhenNoPerAsset() public {
        vm.prank(operator1);
        manager.setOperatorExposureConfig(3000, false); // 30% global

        // No per-asset limit set
        (bool canAccept, uint16 limit) = manager.canAcceptExposure(operator1, nativeAsset, 2500);

        assertTrue(canAccept);
        assertEq(limit, 3000);
    }

    function test_PerAssetLimit_OverridesGlobal() public {
        vm.startPrank(operator1);
        manager.setOperatorExposureConfig(3000, false); // 30% global
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true); // 50% per-asset
        vm.stopPrank();

        (bool canAccept, uint16 limit) = manager.canAcceptExposure(operator1, nativeAsset, 4000);

        assertTrue(canAccept); // Would fail if using global 30%
        assertEq(limit, 5000);
    }

    function test_ExplicitApprovalRequired_NoLimit_StillAllowsIfNoGlobal() public {
        vm.prank(operator1);
        manager.setOperatorExposureConfig(0, true); // Require explicit approval

        // When requireExplicitApproval is true but no limits are set,
        // the default behavior returns MAX_EXPOSURE_BPS (100%)
        // The requireExplicitApproval flag affects validation at the service level
        (bool canAccept, uint16 limit) = manager.canAcceptExposure(operator1, nativeAsset, 5000);

        // Without per-asset limit, defaults to max (100%)
        assertTrue(canAccept);
        assertEq(limit, 10_000);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING INTEGRATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SlashingLib_EffectiveSlashBps_WithExposure() public pure {
        uint16 slashBps = 10_000;

        // 50% exposure
        uint16 effective = SlashingLib.calculateEffectiveSlashBps(slashBps, 5000);
        assertEq(effective, 5000);

        // 25% exposure
        effective = SlashingLib.calculateEffectiveSlashBps(slashBps, 2500);
        assertEq(effective, 2500);

        // 100% exposure
        effective = SlashingLib.calculateEffectiveSlashBps(slashBps, 10_000);
        assertEq(effective, 10_000);

        // 1% exposure
        effective = SlashingLib.calculateEffectiveSlashBps(slashBps, 100);
        assertEq(effective, 100);
    }

    function test_SlashingLib_EffectiveSlashBps_ZeroExposure() public pure {
        uint16 effective = SlashingLib.calculateEffectiveSlashBps(10_000, 0);
        assertEq(effective, 0);
    }

    function test_SlashingLib_CapSlashBps() public pure {
        // Slash 50% with 100% max = 50%
        uint16 capped = SlashingLib.capSlashBps(5000, 10_000);
        assertEq(capped, 5000);

        // Slash 120% with 100% max = 100% (capped)
        capped = SlashingLib.capSlashBps(12_000, 10_000);
        assertEq(capped, 10_000);

        // Slash 50% with 25% max = 25% (capped)
        capped = SlashingLib.capSlashBps(5000, 2500);
        assertEq(capped, 2500);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD DISTRIBUTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RewardShare_ProportionalToExposure() public pure {
        // 3 operators with different exposures
        uint256 totalReward = 100 ether;
        uint256 totalExposed = 200 ether; // Sum of all exposed amounts

        // Operator1: 100 ether delegated, 50% exposure = 50 ether exposed
        uint256 share1 = ExposureCalculator.calculateRewardShare(100 ether, 5000, totalReward, totalExposed);
        assertEq(share1, 25 ether); // 50/200 * 100 = 25 ether

        // Operator2: 200 ether delegated, 50% exposure = 100 ether exposed
        uint256 share2 = ExposureCalculator.calculateRewardShare(200 ether, 5000, totalReward, totalExposed);
        assertEq(share2, 50 ether); // 100/200 * 100 = 50 ether

        // Operator3: 100 ether delegated, 50% exposure = 50 ether exposed
        uint256 share3 = ExposureCalculator.calculateRewardShare(100 ether, 5000, totalReward, totalExposed);
        assertEq(share3, 25 ether); // 50/200 * 100 = 25 ether

        // Total shares = 100 ether (all rewards distributed)
        assertEq(share1 + share2 + share3, totalReward);
    }

    function test_RewardShare_HigherExposure_HigherReward() public pure {
        uint256 totalReward = 100 ether;

        // Same delegation, different exposure
        uint256 delegation = 100 ether;

        // Low exposure operator
        uint256 lowExposed = ExposureCalculator.calculateExposedAmount(delegation, 1000); // 10%
        // High exposure operator
        uint256 highExposed = ExposureCalculator.calculateExposedAmount(delegation, 5000); // 50%

        uint256 totalExposed = lowExposed + highExposed; // 10 + 50 = 60 ether

        uint256 lowShare = ExposureCalculator.calculateRewardShare(delegation, 1000, totalReward, totalExposed);
        uint256 highShare = ExposureCalculator.calculateRewardShare(delegation, 5000, totalReward, totalExposed);

        // High exposure should get approximately 5x the reward (allow for small rounding)
        assertApproxEqAbs(highShare, lowShare * 5, 10); // Allow 10 wei rounding error
        assertGt(highShare, lowShare); // High exposure gets more
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISABLED ASSET SCENARIOS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DisabledAsset_LimitStillApplies() public {
        vm.prank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, false); // Disabled

        ExposureTypes.OperatorAssetExposureLimit memory limit = manager.getAssetExposureLimit(operator1, nativeAsset);

        assertFalse(limit.enabled);
        assertEq(limit.maxExposureBps, 5000); // Limit still stored
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MOCK RESTAKING COVERAGE (unused helpers)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_MockStakingEdge_HelperCoverage() public {
        address tempOperator = makeAddr("tempOperator");
        staking.setOperator(tempOperator, true);
        staking.setStake(tempOperator, 42 ether);
        staking.setDelegatedStake(tempOperator, 84 ether);

        assertTrue(staking.isOperator(tempOperator));
        assertTrue(staking.isOperatorActive(tempOperator));
        assertEq(staking.getOperatorStake(tempOperator), 42 ether);
        assertEq(staking.getOperatorSelfStake(tempOperator), 42 ether);
        assertEq(staking.getOperatorDelegatedStake(tempOperator), 84 ether);
        assertEq(staking.getDelegation(tempOperator, operator1), 0);
        assertEq(staking.getTotalDelegation(tempOperator), 0);
        assertEq(staking.minOperatorStake(), 0);
        assertTrue(staking.meetsStakeRequirement(tempOperator, 1 ether));
        assertEq(staking.slashForBlueprint(tempOperator, 1, 2, 5000, keccak256("bp-slash")), 5000);
        assertEq(staking.slash(tempOperator, 3, 4000, keccak256("plain-slash")), 4000);
        assertFalse(staking.isSlasher(tempOperator));

        // The reward notifiers are no-ops but should remain callable
        staking.notifyRewardForBlueprint(tempOperator, 1, 1, 1 ether);
        staking.notifyReward(tempOperator, 1, 1 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EMPTY / ZERO SCENARIOS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_EmptyRequirements_EmptyCommitments_Valid() public view {
        Types.AssetSecurityRequirement[] memory requirements = new Types.AssetSecurityRequirement[](0);
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](0);

        (bool valid,) = manager.validateCommitments(operator1, requirements, commitments);
        assertTrue(valid);
    }

    function test_WeightedExposure_AllZeroDelegations() public pure {
        uint256[] memory delegations = new uint256[](3);
        delegations[0] = 0;
        delegations[1] = 0;
        delegations[2] = 0;

        uint16[] memory exposures = new uint16[](3);
        exposures[0] = 5000;
        exposures[1] = 5000;
        exposures[2] = 5000;

        uint16 weighted = ExposureCalculator.calculateWeightedExposure(delegations, exposures);
        assertEq(weighted, 0); // Avoid div by zero, return 0
    }

    function test_TotalExposedValue_AllZero() public pure {
        uint256[] memory delegations = new uint256[](3);
        uint16[] memory exposures = new uint16[](3);

        uint256 total = ExposureCalculator.calculateTotalExposedValue(delegations, exposures);
        assertEq(total, 0);
    }
}

/// @title ExposureFuzzTest
/// @notice Fuzz testing for exposure calculations
contract ExposureFuzzTest is Test {
    function testFuzz_CalculateExposedAmount(uint256 delegation, uint16 exposureBps) public pure {
        // Bound inputs to reasonable ranges
        delegation = bound(delegation, 0, type(uint128).max);
        exposureBps = uint16(bound(uint256(exposureBps), 0, 10_000));

        uint256 exposed = ExposureCalculator.calculateExposedAmount(delegation, exposureBps);

        // Verify invariants
        assertLe(exposed, delegation); // Exposed <= Delegated
        if (exposureBps == 10_000) {
            assertEq(exposed, delegation); // 100% exposure = full amount
        }
        if (exposureBps == 0) {
            assertEq(exposed, 0); // 0% exposure = 0
        }
    }

    function testFuzz_CalculateSlashAmount(uint256 delegation, uint16 exposureBps, uint16 slashBps) public pure {
        delegation = bound(delegation, 0, type(uint128).max);
        exposureBps = uint16(bound(uint256(exposureBps), 0, 10_000));
        slashBps = uint16(bound(uint256(slashBps), 0, 10_000));

        uint256 slashAmount = ExposureCalculator.calculateSlashAmount(delegation, exposureBps, slashBps);
        uint256 maxSlashable = ExposureCalculator.calculateMaxSlashable(delegation, exposureBps);

        // Slash amount should never exceed max slashable
        assertLe(slashAmount, maxSlashable);
        assertLe(slashAmount, delegation);
    }

    function testFuzz_WeightedExposure_SingleElement(uint256 delegation, uint16 exposureBps) public pure {
        delegation = bound(delegation, 1, type(uint128).max);
        exposureBps = uint16(bound(uint256(exposureBps), 0, 10_000));

        uint256[] memory delegations = new uint256[](1);
        delegations[0] = delegation;

        uint16[] memory exposures = new uint16[](1);
        exposures[0] = exposureBps;

        uint16 weighted = ExposureCalculator.calculateWeightedExposure(delegations, exposures);

        // With single element, weighted should equal the exposure
        assertEq(weighted, exposureBps);
    }

    function testFuzz_RewardShare_SumToTotal(
        uint256 totalReward,
        uint256 delegation1,
        uint256 delegation2,
        uint16 exposure1,
        uint16 exposure2
    )
        public
        pure
    {
        totalReward = bound(totalReward, 0, type(uint128).max);
        delegation1 = bound(delegation1, 1, type(uint64).max);
        delegation2 = bound(delegation2, 1, type(uint64).max);
        exposure1 = uint16(bound(uint256(exposure1), 1, 10_000));
        exposure2 = uint16(bound(uint256(exposure2), 1, 10_000));

        uint256 exposed1 = ExposureCalculator.calculateExposedAmount(delegation1, exposure1);
        uint256 exposed2 = ExposureCalculator.calculateExposedAmount(delegation2, exposure2);
        uint256 totalExposed = exposed1 + exposed2;

        if (totalExposed > 0) {
            uint256 share1 = ExposureCalculator.calculateRewardShare(delegation1, exposure1, totalReward, totalExposed);
            uint256 share2 = ExposureCalculator.calculateRewardShare(delegation2, exposure2, totalReward, totalExposed);

            // Sum of shares should approximately equal total (may have small rounding error)
            assertLe(share1 + share2, totalReward);
            // Allow for rounding error of at most 2 wei
            assertGe(share1 + share2 + 2, totalReward);
        }
    }

    function testFuzz_SlashingLib_EffectiveSlashBps(uint16 slashBps, uint16 exposureBps) public pure {
        slashBps = uint16(bound(uint256(slashBps), 0, 10_000));
        exposureBps = uint16(bound(uint256(exposureBps), 0, 10_000));

        uint16 effective = SlashingLib.calculateEffectiveSlashBps(slashBps, exposureBps);

        assertLe(effective, slashBps);
        if (exposureBps == 10_000) {
            assertEq(effective, slashBps);
        }
    }

    function testFuzz_IsValidExposure(uint16 exposureBps) public pure {
        bool valid = ExposureCalculator.isValidExposure(exposureBps);

        if (exposureBps >= 1 && exposureBps <= 10_000) {
            assertTrue(valid);
        } else {
            assertFalse(valid);
        }
    }

    function testFuzz_ClampExposure(uint16 exposureBps) public pure {
        uint16 clamped = ExposureCalculator.clampExposure(exposureBps);

        assertGe(clamped, 1); // Min
        assertLe(clamped, 10_000); // Max

        if (exposureBps >= 1 && exposureBps <= 10_000) {
            assertEq(clamped, exposureBps); // Unchanged if valid
        }
    }
}
