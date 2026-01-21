// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {ExposureManager} from "../../../src/v2/exposure/ExposureManager.sol";
import {ExposureTypes} from "../../../src/v2/exposure/ExposureTypes.sol";
import {ExposureCalculator} from "../../../src/v2/exposure/ExposureCalculator.sol";
import {MockPriceOracle} from "./MockPriceOracle.sol";
import {Types} from "../../../src/v2/libraries/Types.sol";
import {IStaking} from "../../../src/v2/interfaces/IStaking.sol";

/// @notice Mock staking contract for testing
contract MockStaking is IStaking {
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

    function slashForBlueprint(
        address,
        uint64,
        uint64,
        uint16 slashBps,
        bytes32
    ) external pure returns (uint256) {
        return slashBps;
    }

    function slashForService(
        address,
        uint64,
        uint64,
        Types.AssetSecurityCommitment[] calldata,
        uint16 slashBps,
        bytes32
    ) external pure returns (uint256) {
        return slashBps;
    }

    function slash(
        address,
        uint64,
        uint16 slashBps,
        bytes32
    ) external pure returns (uint256) {
        return slashBps;
    }

    function isSlasher(address) external pure returns (bool) {
        return false;
    }

    function notifyRewardForBlueprint(
        address,
        uint64,
        uint64,
        uint256
    ) external {}

    function notifyReward(
        address,
        uint64,
        uint256
    ) external {}

    function addBlueprintForOperator(address, uint64) external override {}
    function removeBlueprintForOperator(address, uint64) external override {}

    // M-9 FIX: Pending slash tracking (no-op for mock)
    function incrementPendingSlash(address) external override {}
    function decrementPendingSlash(address) external override {}
    function getPendingSlashCount(address) external pure override returns (uint64) { return 0; }
}

/// @title ExposureManagerTest
/// @notice Tests for the ExposureManager contract
contract ExposureManagerTest is Test {
    ExposureManager public manager;
    MockStaking public staking;

    address public operator1;
    address public operator2;
    address public operator3;

    address public token1;
    address public token2;

    Types.Asset public nativeAsset;
    Types.Asset public erc20Asset1;
    Types.Asset public erc20Asset2;

    function setUp() public {
        // Create mock accounts
        operator1 = makeAddr("operator1");
        operator2 = makeAddr("operator2");
        operator3 = makeAddr("operator3");

        token1 = makeAddr("token1");
        token2 = makeAddr("token2");

        // Deploy mock restaking
        staking = new MockStaking();

        // Setup operators
        staking.setOperator(operator1, true);
        staking.setOperator(operator2, true);
        staking.setOperator(operator3, true);

        // Setup stakes
        staking.setStake(operator1, 100 ether);
        staking.setStake(operator2, 200 ether);
        staking.setStake(operator3, 50 ether);

        staking.setDelegatedStake(operator1, 50 ether);
        staking.setDelegatedStake(operator2, 100 ether);

        // Deploy exposure manager
        manager = new ExposureManager(address(staking));

        // Setup assets
        nativeAsset = Types.Asset(Types.AssetKind.Native, address(0));
        erc20Asset1 = Types.Asset(Types.AssetKind.ERC20, token1);
        erc20Asset2 = Types.Asset(Types.AssetKind.ERC20, token2);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR CONFIGURATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetAssetExposureLimit() public {
        vm.prank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true);

        ExposureTypes.OperatorAssetExposureLimit memory limit =
            manager.getAssetExposureLimit(operator1, nativeAsset);

        assertEq(limit.maxExposureBps, 5000);
        assertEq(limit.defaultExposureBps, 2500);
        assertTrue(limit.enabled);
    }

    function test_SetAssetExposureLimit_MultipleAssets() public {
        vm.startPrank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true);
        manager.setAssetExposureLimit(erc20Asset1, 3000, 1000, true);
        manager.setAssetExposureLimit(erc20Asset2, 10000, 5000, true);
        vm.stopPrank();

        ExposureTypes.OperatorAssetExposureLimit memory nativeLimit =
            manager.getAssetExposureLimit(operator1, nativeAsset);
        ExposureTypes.OperatorAssetExposureLimit memory erc20Limit1 =
            manager.getAssetExposureLimit(operator1, erc20Asset1);
        ExposureTypes.OperatorAssetExposureLimit memory erc20Limit2 =
            manager.getAssetExposureLimit(operator1, erc20Asset2);

        assertEq(nativeLimit.maxExposureBps, 5000);
        assertEq(erc20Limit1.maxExposureBps, 3000);
        assertEq(erc20Limit2.maxExposureBps, 10000);
    }

    function test_SetAssetExposureLimit_InvalidMaxExceeds100Percent() public {
        vm.prank(operator1);
        vm.expectRevert();
        manager.setAssetExposureLimit(nativeAsset, 10001, 5000, true);
    }

    function test_SetAssetExposureLimit_InvalidDefaultExceedsMax() public {
        vm.prank(operator1);
        vm.expectRevert();
        manager.setAssetExposureLimit(nativeAsset, 5000, 6000, true);
    }

    function test_BatchSetAssetExposureLimits() public {
        ExposureTypes.OperatorAssetExposureLimit[] memory limits =
            new ExposureTypes.OperatorAssetExposureLimit[](2);

        limits[0] = ExposureTypes.OperatorAssetExposureLimit({
            asset: nativeAsset,
            maxExposureBps: 5000,
            defaultExposureBps: 2500,
            enabled: true
        });

        limits[1] = ExposureTypes.OperatorAssetExposureLimit({
            asset: erc20Asset1,
            maxExposureBps: 3000,
            defaultExposureBps: 1000,
            enabled: true
        });

        vm.prank(operator1);
        manager.batchSetAssetExposureLimits(limits);

        ExposureTypes.OperatorAssetExposureLimit memory nativeLimit =
            manager.getAssetExposureLimit(operator1, nativeAsset);
        ExposureTypes.OperatorAssetExposureLimit memory erc20Limit =
            manager.getAssetExposureLimit(operator1, erc20Asset1);

        assertEq(nativeLimit.maxExposureBps, 5000);
        assertEq(erc20Limit.maxExposureBps, 3000);
    }

    function test_SetOperatorExposureConfig() public {
        vm.prank(operator1);
        manager.setOperatorExposureConfig(7500, true);

        ExposureTypes.OperatorExposureConfig memory config =
            manager.getOperatorExposureConfig(operator1);

        assertEq(config.globalMaxExposureBps, 7500);
        assertTrue(config.requireExplicitApproval);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // COMMITMENT VALIDATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_ValidateCommitments_Success() public {
        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1000,
            maxExposureBps: 5000
        });

        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 2500
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(operator1, requirements, commitments);

        assertTrue(valid);
        assertTrue(result.valid);
    }

    function test_ValidateCommitments_BelowMinimum() public {
        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 3000,
            maxExposureBps: 5000
        });

        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 2000 // Below minimum
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(operator1, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "Commitment below minimum");
    }

    function test_ValidateCommitments_AboveMaximum() public {
        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1000,
            maxExposureBps: 3000
        });

        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 4000 // Above maximum
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(operator1, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "Commitment above maximum");
    }

    function test_ValidateCommitments_ExceedsOperatorLimit() public {
        // Set operator's own limit
        vm.prank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 2000, 1000, true);

        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1000,
            maxExposureBps: 5000 // Service allows up to 50%
        });

        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 3000 // Within service bounds but exceeds operator limit
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(operator1, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "Exceeds operator limit");
    }

    function test_ValidateCommitments_MissingCommitment() public {
        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](2);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1000,
            maxExposureBps: 5000
        });
        requirements[1] = Types.AssetSecurityRequirement({
            asset: erc20Asset1,
            minExposureBps: 1000,
            maxExposureBps: 5000
        });

        // Only provide commitment for native asset
        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 2500
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(operator1, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "Missing commitment for required asset");
    }

    function test_ValidateCommitments_UnexpectedCommitment() public {
        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1000,
            maxExposureBps: 5000
        });

        // Provide commitments for both native and erc20 (unexpected)
        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](2);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 2500
        });
        commitments[1] = Types.AssetSecurityCommitment({
            asset: erc20Asset1,
            exposureBps: 2500
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(operator1, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "Unexpected asset commitment");
    }

    function test_ValidateCommitments_NotOperator() public {
        address notOperator = makeAddr("notOperator");

        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1000,
            maxExposureBps: 5000
        });

        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 2500
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(notOperator, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "Not an operator");
    }

    function test_ValidateCommitments_NoDelegation() public {
        // Set up an operator with no stake
        address noStakeOperator = makeAddr("noStakeOperator");
        staking.setOperator(noStakeOperator, true);
        staking.setStake(noStakeOperator, 0);

        Types.AssetSecurityRequirement[] memory requirements =
            new Types.AssetSecurityRequirement[](1);
        requirements[0] = Types.AssetSecurityRequirement({
            asset: nativeAsset,
            minExposureBps: 1000,
            maxExposureBps: 5000
        });

        Types.AssetSecurityCommitment[] memory commitments =
            new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: nativeAsset,
            exposureBps: 2500
        });

        (bool valid, ExposureTypes.CommitmentValidationResult memory result) =
            manager.validateCommitments(noStakeOperator, requirements, commitments);

        assertFalse(valid);
        assertEq(result.reason, "No delegation for asset");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CAN ACCEPT EXPOSURE TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CanAcceptExposure_NoLimitSet() public view {
        (bool canAccept, uint16 effectiveLimit) =
            manager.canAcceptExposure(operator1, nativeAsset, 5000);

        assertTrue(canAccept);
        assertEq(effectiveLimit, 10000); // Default 100%
    }

    function test_CanAcceptExposure_WithinLimit() public {
        vm.prank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true);

        (bool canAccept, uint16 effectiveLimit) =
            manager.canAcceptExposure(operator1, nativeAsset, 4000);

        assertTrue(canAccept);
        assertEq(effectiveLimit, 5000);
    }

    function test_CanAcceptExposure_ExceedsLimit() public {
        vm.prank(operator1);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true);

        (bool canAccept, uint16 effectiveLimit) =
            manager.canAcceptExposure(operator1, nativeAsset, 6000);

        assertFalse(canAccept);
        assertEq(effectiveLimit, 5000);
    }

    function test_CanAcceptExposure_UsesGlobalLimit() public {
        vm.prank(operator1);
        manager.setOperatorExposureConfig(3000, false);

        (bool canAccept, uint16 effectiveLimit) =
            manager.canAcceptExposure(operator1, nativeAsset, 2500);

        assertTrue(canAccept);
        assertEq(effectiveLimit, 3000);
    }

    function test_CanAcceptExposure_PerAssetOverridesGlobal() public {
        vm.startPrank(operator1);
        manager.setOperatorExposureConfig(3000, false);
        manager.setAssetExposureLimit(nativeAsset, 5000, 2500, true);
        vm.stopPrank();

        (bool canAccept, uint16 effectiveLimit) =
            manager.canAcceptExposure(operator1, nativeAsset, 4000);

        assertTrue(canAccept);
        assertEq(effectiveLimit, 5000); // Uses per-asset, not global
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPOSURE CALCULATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_CalculateExposedAmount() public view {
        (uint256 delegated, uint256 exposed) =
            manager.calculateExposedAmount(operator1, nativeAsset, 5000);

        assertEq(delegated, 100 ether); // Operator1's stake
        assertEq(exposed, 50 ether); // 50% of 100 ether
    }

    function test_CalculateExposedAmount_FullExposure() public view {
        (uint256 delegated, uint256 exposed) =
            manager.calculateExposedAmount(operator1, nativeAsset, 10000);

        assertEq(delegated, 100 ether);
        assertEq(exposed, 100 ether); // 100%
    }

    function test_CalculateExposedAmount_MinimalExposure() public view {
        (uint256 delegated, uint256 exposed) =
            manager.calculateExposedAmount(operator1, nativeAsset, 1);

        assertEq(delegated, 100 ether);
        assertEq(exposed, 0.01 ether); // 0.01%
    }
}

/// @title ExposureCalculatorTest
/// @notice Tests for the ExposureCalculator library
contract ExposureCalculatorTest is Test {
    function test_CalculateExposedAmount() public pure {
        uint256 exposed = ExposureCalculator.calculateExposedAmount(100 ether, 5000);
        assertEq(exposed, 50 ether);
    }

    function test_CalculateExposedAmount_FullExposure() public pure {
        uint256 exposed = ExposureCalculator.calculateExposedAmount(100 ether, 10000);
        assertEq(exposed, 100 ether);
    }

    function test_CalculateExposedAmount_Zero() public pure {
        uint256 exposed = ExposureCalculator.calculateExposedAmount(100 ether, 0);
        assertEq(exposed, 0);
    }

    function test_CalculateWeightedExposure() public pure {
        uint256[] memory delegations = new uint256[](3);
        delegations[0] = 100 ether;
        delegations[1] = 200 ether;
        delegations[2] = 100 ether;

        uint16[] memory exposures = new uint16[](3);
        exposures[0] = 5000; // 50%
        exposures[1] = 2500; // 25%
        exposures[2] = 7500; // 75%

        // Weighted = (100*50 + 200*25 + 100*75) / 400 = (5000 + 5000 + 7500) / 400 = 43.75%
        uint16 weighted = ExposureCalculator.calculateWeightedExposure(delegations, exposures);
        assertEq(weighted, 4375);
    }

    function test_CalculateWeightedExposure_Empty() public pure {
        uint256[] memory delegations = new uint256[](0);
        uint16[] memory exposures = new uint16[](0);

        uint16 weighted = ExposureCalculator.calculateWeightedExposure(delegations, exposures);
        assertEq(weighted, 0);
    }

    function test_CalculateSlashAmount() public pure {
        // 100 ETH delegated, 50% exposure, 10% slash
        uint256 slashAmount = ExposureCalculator.calculateSlashAmount(100 ether, 5000, 1000);
        assertEq(slashAmount, 5 ether); // 10% of 50 ETH exposed = 5 ETH
    }

    function test_CalculateSlashAmount_FullSlash() public pure {
        // 100 ETH delegated, 25% exposure, 100% slash of exposed
        uint256 slashAmount = ExposureCalculator.calculateSlashAmount(100 ether, 2500, 10000);
        assertEq(slashAmount, 25 ether); // 100% of 25 ETH exposed = 25 ETH
    }

    function test_CalculateMaxSlashable() public pure {
        uint256 maxSlash = ExposureCalculator.calculateMaxSlashable(100 ether, 3000);
        assertEq(maxSlash, 30 ether); // 30% of 100 ETH
    }

    function test_CalculateRewardShare() public pure {
        // Operator has 50 ETH exposed out of total 200 ETH exposed
        // Should get 25% of total rewards
        uint256 share = ExposureCalculator.calculateRewardShare(
            100 ether, // delegated
            5000,      // 50% exposure
            100 ether, // total reward
            200 ether  // total exposed value
        );
        assertEq(share, 25 ether); // 50 ETH / 200 ETH * 100 ETH reward
    }

    function test_CalculateRewardShare_NoTotalExposure() public pure {
        uint256 share = ExposureCalculator.calculateRewardShare(100 ether, 5000, 100 ether, 0);
        assertEq(share, 0);
    }

    function test_CalculateUSDWeightedExposure() public {
        address[] memory tokens = new address[](2);
        tokens[0] = address(0xAAA);
        tokens[1] = address(0xBBB);

        uint256[] memory delegations = new uint256[](2);
        delegations[0] = 10 ether;
        delegations[1] = 5 ether;

        uint16[] memory exposures = new uint16[](2);
        exposures[0] = 5000;
        exposures[1] = 1000;

        MockPriceOracle oracle = new MockPriceOracle();
        oracle.setPrice(tokens[0], 2e18); // $2 per unit
        oracle.setPrice(tokens[1], 1e18); // $1 per unit

        (uint16 weighted, uint256 totalUsd) = ExposureCalculator.calculateUSDWeightedExposure(
            tokens,
            delegations,
            exposures,
            oracle
        );

        // USD values: token0 => 20, token1 => 5
        // Weighted = (50% * 20 + 10% * 5) / 25 = 42% (rounded down)
        assertEq(weighted, 4200);
        assertEq(totalUsd, 25e18);
    }

    function test_CalculateUSDWeightedExposure_NoDelegations() public {
        address[] memory tokens = new address[](0);
        uint256[] memory delegations = new uint256[](0);
        uint16[] memory exposures = new uint16[](0);
        MockPriceOracle oracle = new MockPriceOracle();
        (uint16 weighted, uint256 totalUsd) = ExposureCalculator.calculateUSDWeightedExposure(
            tokens,
            delegations,
            exposures,
            oracle
        );
        assertEq(weighted, 0);
        assertEq(totalUsd, 0);
    }

    function test_CalculateTotalExposedValue() public pure {
        uint256[] memory delegations = new uint256[](3);
        delegations[0] = 100 ether;
        delegations[1] = 200 ether;
        delegations[2] = 50 ether;

        uint16[] memory exposures = new uint16[](3);
        exposures[0] = 5000; // 50%
        exposures[1] = 2500; // 25%
        exposures[2] = 10000; // 100%

        uint256 total = ExposureCalculator.calculateTotalExposedValue(delegations, exposures);
        // 50 + 50 + 50 = 150 ETH
        assertEq(total, 150 ether);
    }

    function test_IsValidExposure() public pure {
        assertTrue(ExposureCalculator.isValidExposure(1)); // MIN
        assertTrue(ExposureCalculator.isValidExposure(5000)); // 50%
        assertTrue(ExposureCalculator.isValidExposure(10000)); // MAX
        assertFalse(ExposureCalculator.isValidExposure(0)); // Below MIN
    }

    function test_IsWithinBounds() public pure {
        assertTrue(ExposureCalculator.isWithinBounds(5000, 1000, 8000));
        assertTrue(ExposureCalculator.isWithinBounds(1000, 1000, 8000)); // At min
        assertTrue(ExposureCalculator.isWithinBounds(8000, 1000, 8000)); // At max
        assertFalse(ExposureCalculator.isWithinBounds(500, 1000, 8000)); // Below min
        assertFalse(ExposureCalculator.isWithinBounds(9000, 1000, 8000)); // Above max
    }

    function test_ClampExposure() public pure {
        assertEq(ExposureCalculator.clampExposure(0), 1); // Clamp up to MIN
        assertEq(ExposureCalculator.clampExposure(5000), 5000); // No change
        assertEq(ExposureCalculator.clampExposure(15000), 10000); // Clamp down to MAX
    }

    function test_BuildCalculatedExposure() public pure {
        Types.Asset memory asset = Types.Asset(Types.AssetKind.Native, address(0));

        ExposureTypes.CalculatedExposure memory exposure = ExposureCalculator.buildCalculatedExposure(
            address(0x123),
            asset,
            100 ether,
            5000,
            1
        );

        assertEq(exposure.operator, address(0x123));
        assertEq(exposure.delegatedAmount, 100 ether);
        assertEq(exposure.exposureBps, 5000);
        assertEq(exposure.exposedAmount, 50 ether);
        assertEq(exposure.serviceId, 1);
    }
}
