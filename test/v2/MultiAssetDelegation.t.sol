// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { DelegationErrors } from "../../src/v2/restaking/DelegationErrors.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { MockERC20 } from "./mocks/MockERC20.sol";
import { RestakingOperatorsFacet } from "../../src/v2/facets/restaking/RestakingOperatorsFacet.sol";
import { RestakingDepositsFacet } from "../../src/v2/facets/restaking/RestakingDepositsFacet.sol";
import { RestakingDelegationsFacet } from "../../src/v2/facets/restaking/RestakingDelegationsFacet.sol";
import { RestakingSlashingFacet } from "../../src/v2/facets/restaking/RestakingSlashingFacet.sol";
import { RestakingAssetsFacet } from "../../src/v2/facets/restaking/RestakingAssetsFacet.sol";
import { RestakingViewsFacet } from "../../src/v2/facets/restaking/RestakingViewsFacet.sol";
import { RestakingAdminFacet } from "../../src/v2/facets/restaking/RestakingAdminFacet.sol";

contract MultiAssetDelegationTest is Test {
    IMultiAssetDelegation public delegation;
    MockERC20 public token;

    address public admin = makeAddr("admin");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public delegator1 = makeAddr("delegator1");
    address public delegator2 = makeAddr("delegator2");

    uint256 public constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 public constant MIN_DELEGATION = 0.1 ether;
    uint16 public constant OPERATOR_COMMISSION_BPS = 1000; // 10%
    uint256 public constant ROUND_DURATION_SECONDS = 21_600; // 6 hours (matches ProtocolConfig)

    /// @notice Helper to advance rounds with proper time warping
    function _advanceRounds(uint256 rounds) internal {
        uint256 startTime = block.timestamp;
        for (uint256 i = 0; i < rounds; i++) {
            vm.warp(startTime + (i + 1) * ROUND_DURATION_SECONDS);
            delegation.advanceRound();
        }
    }

    function setUp() public {
        // Deploy mock token
        token = new MockERC20();

        // Deploy delegation
        MultiAssetDelegation impl = new MultiAssetDelegation();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(
                MultiAssetDelegation.initialize,
                (admin, MIN_OPERATOR_STAKE, MIN_DELEGATION, OPERATOR_COMMISSION_BPS)
            )
        );
        delegation = IMultiAssetDelegation(payable(address(proxy)));

        _registerFacets(address(proxy));

        // Fund actors
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(delegator1, 100 ether);
        vm.deal(delegator2, 100 ether);
        token.mint(delegator1, 100 ether);
        token.mint(delegator2, 100 ether);

        // Enable ERC20 token
        vm.prank(admin);
        delegation.enableAsset(address(token), 1 ether, 0.1 ether, 0, 10000);
    }

    function _registerFacets(address proxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(proxy));
        vm.startPrank(admin);
        router.registerFacet(address(new RestakingOperatorsFacet()));
        router.registerFacet(address(new RestakingDepositsFacet()));
        router.registerFacet(address(new RestakingDelegationsFacet()));
        router.registerFacet(address(new RestakingSlashingFacet()));
        router.registerFacet(address(new RestakingAssetsFacet()));
        router.registerFacet(address(new RestakingViewsFacet()));
        router.registerFacet(address(new RestakingAdminFacet()));
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RegisterOperator() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertTrue(delegation.isOperator(operator1));
        assertTrue(delegation.isOperatorActive(operator1));
        assertEq(delegation.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE);
    }

    function test_RegisterOperator_RevertInsufficientStake() public {
        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationErrors.InsufficientStake.selector,
                MIN_OPERATOR_STAKE,
                MIN_OPERATOR_STAKE - 1
            )
        );
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE - 1 }();
    }

    function test_RegisterOperator_RevertAlreadyRegistered() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(DelegationErrors.OperatorAlreadyRegistered.selector, operator1)
        );
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();
    }

    function test_IncreaseStake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.increaseStake{ value: 1 ether }();

        assertEq(delegation.getOperatorSelfStake(operator1), MIN_OPERATOR_STAKE + 1 ether);
    }

    function test_AddBlueprint() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.addBlueprint(1);

        uint256[] memory blueprints = delegation.getOperatorBlueprints(operator1);
        assertEq(blueprints.length, 1);
        assertEq(blueprints[0], 1);
    }

    function test_StartLeaving() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.startLeaving();

        assertFalse(delegation.isOperatorActive(operator1));
    }

    function test_CompleteLeaving() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator1);
        delegation.startLeaving();

        // Advance rounds with proper time warping (56 rounds for operator exit = 2 epochs)
        _advanceRounds(56);

        uint256 balanceBefore = operator1.balance;

        vm.prank(operator1);
        delegation.completeLeaving();

        assertEq(operator1.balance, balanceBefore + MIN_OPERATOR_STAKE);
        assertFalse(delegation.isOperator(operator1));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPOSIT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DepositNative() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 1 ether);
        assertEq(dep.delegatedAmount, 0);
    }

    function test_DepositWithLock() public {
        vm.prank(delegator1);
        delegation.depositWithLock{ value: 1 ether }(Types.LockMultiplier.ThreeMonths);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 1 ether);
    }

    function test_DepositERC20() public {
        vm.startPrank(delegator1);
        token.approve(address(delegation), 1 ether);
        delegation.depositERC20(address(token), 1 ether);
        vm.stopPrank();

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(token));
        assertEq(dep.amount, 1 ether);
    }

    function test_ScheduleWithdraw() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 0.5 ether);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 0.5 ether);
    }

    function test_ExecuteWithdraw() public {
        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        vm.prank(delegator1);
        delegation.scheduleWithdraw(address(0), 0.5 ether);

        // Advance rounds with proper time warping (28 rounds for delegator = 1 epoch)
        _advanceRounds(28);

        uint256 balanceBefore = delegator1.balance;

        vm.prank(delegator1);
        delegation.executeWithdraw();

        assertEq(delegator1.balance, balanceBefore + 0.5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Delegate() public {
        // Setup operator
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Deposit and delegate
        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 0.5 ether);
        vm.stopPrank();

        assertEq(delegation.getDelegation(delegator1, operator1), 0.5 ether);
        assertEq(delegation.getOperatorDelegatedStake(operator1), 0.5 ether);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.delegatedAmount, 0.5 ether);
    }

    function test_DepositAndDelegate_SingleTransaction() public {
        // Setup operator
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        // Single transaction: deposit + delegate
        vm.prank(delegator1);
        delegation.depositAndDelegate{ value: 1 ether }(operator1);

        // Verify delegation
        assertEq(delegation.getDelegation(delegator1, operator1), 1 ether);
        assertEq(delegation.getOperatorDelegatedStake(operator1), 1 ether);

        // Verify deposit tracking
        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.amount, 1 ether);
        assertEq(dep.delegatedAmount, 1 ether);
    }

    function test_DelegateWithBlueprintSelection() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(delegator1);
        delegation.deposit{ value: 1 ether }();

        uint64[] memory blueprints = new uint64[](2);
        blueprints[0] = 1;
        blueprints[1] = 2;

        vm.prank(delegator1);
        delegation.delegateWithOptions(
            operator1,
            address(0),
            0.5 ether,
            Types.BlueprintSelectionMode.Fixed,
            blueprints
        );

        uint64[] memory selectedBlueprints = delegation.getDelegationBlueprints(delegator1, 0);
        assertEq(selectedBlueprints.length, 2);
        assertEq(selectedBlueprints[0], 1);
        assertEq(selectedBlueprints[1], 2);
    }

    function test_DelegateMultipleOperators() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.prank(operator2);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 2 ether }();
        delegation.delegate(operator1, 0.5 ether);
        delegation.delegate(operator2, 0.5 ether);
        vm.stopPrank();

        assertEq(delegation.getDelegation(delegator1, operator1), 0.5 ether);
        assertEq(delegation.getDelegation(delegator1, operator2), 0.5 ether);
        assertEq(delegation.getTotalDelegation(delegator1), 1 ether);
    }

    function test_ScheduleUnstake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 0.5 ether);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 0.25 ether);
        vm.stopPrank();

        // Still delegated until execution
        assertEq(delegation.getDelegation(delegator1, operator1), 0.5 ether);
    }

    function test_ExecuteUnstake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 1 ether }();
        delegation.delegate(operator1, 0.5 ether);
        delegation.scheduleDelegatorUnstake(operator1, address(0), 0.25 ether);
        vm.stopPrank();

        // Advance rounds with proper time warping (28 rounds for delegator = 1 epoch)
        _advanceRounds(28);

        vm.prank(delegator1);
        delegation.executeDelegatorUnstake();

        assertEq(delegation.getDelegation(delegator1, operator1), 0.25 ether);

        Types.Deposit memory dep = delegation.getDeposit(delegator1, address(0));
        assertEq(dep.delegatedAmount, 0.25 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Slash() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        vm.prank(admin);
        delegation.addSlasher(admin);

        vm.prank(admin);
        uint256 slashed = delegation.slash(operator1, 0, 1000, bytes32(0));

        assertEq(slashed, 1 ether);
        assertEq(delegation.getOperatorSelfStake(operator1), 9 ether);
    }

    function test_Slash_RevertNotSlasher() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        vm.prank(delegator1);
        vm.expectRevert();
        delegation.slash(operator1, 0, 1000, bytes32(0));
    }

    function test_SlashForService_WithCommitments() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        vm.prank(admin);
        delegation.addSlasher(admin);

        // Create commitment for native asset only (50% exposure)
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 5000 // 50% exposure
        });

        vm.prank(admin);
        uint256 slashed = delegation.slashForService(
            operator1,
            1, // blueprintId
            1, // serviceId
            commitments,
            2000,
            bytes32("evidence")
        );

        assertEq(slashed, 1 ether);
        assertEq(delegation.getOperatorSelfStake(operator1), 9 ether);
    }

    function test_SlashForService_NoCommitmentsFallsBack() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        vm.prank(admin);
        delegation.addSlasher(admin);

        // Empty commitments should fall back to slashForBlueprint
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](0);

        vm.prank(admin);
        uint256 slashed = delegation.slashForService(
            operator1,
            1, // blueprintId
            1, // serviceId
            commitments,
            1000,
            bytes32("evidence")
        );

        assertEq(slashed, 1 ether);
        assertEq(delegation.getOperatorSelfStake(operator1), 9 ether);
    }

    function test_SlashForService_RevertNotSlasher() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 10000
        });

        vm.prank(delegator1);
        vm.expectRevert();
        delegation.slashForService(operator1, 1, 1, commitments, 1000, bytes32(0));
    }

    function test_SlashForService_SlashesPoolDelegations() public {
        // Setup operator
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        // Delegator deposits and delegates to pool (All mode)
        vm.startPrank(delegator1);
        delegation.deposit{ value: 10 ether }();
        uint64[] memory empty = new uint64[](0);
        delegation.delegateWithOptions(
            operator1,
            address(0),
            10 ether,
            Types.BlueprintSelectionMode.All,
            empty
        );
        vm.stopPrank();

        vm.prank(admin);
        delegation.addSlasher(admin);

        // Create commitment for native asset (100% exposure)
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 10000 // 100% exposure
        });

        // Total slashable: 10 operator + 10 delegator = 20 ether
        // Slash 10% of total
        vm.prank(admin);
        uint256 slashed = delegation.slashForService(
            operator1,
            1,
            1,
            commitments,
            1000,
            bytes32("evidence")
        );

        assertEq(slashed, 2 ether);
        // Operator should lose 1 ether (10% of 10 ether)
        assertEq(delegation.getOperatorSelfStake(operator1), 9 ether);
        // Delegator pool should also be slashed (10% of 10 ether)
        assertEq(delegation.getOperatorDelegatedStake(operator1), 9 ether);
    }

    function test_SlashForService_MultipleAssetCommitments() public {
        // Setup operator
        vm.prank(operator1);
        delegation.registerOperator{ value: 10 ether }();

        // Delegator deposits native and ERC20
        vm.startPrank(delegator1);
        delegation.deposit{ value: 5 ether }();
        token.approve(address(delegation), 5 ether);
        delegation.depositERC20(address(token), 5 ether);

        // Delegate both to operator (All mode)
        uint64[] memory empty = new uint64[](0);
        delegation.delegateWithOptions(
            operator1,
            address(0),
            5 ether,
            Types.BlueprintSelectionMode.All,
            empty
        );
        delegation.delegateWithOptions(
            operator1,
            address(token),
            5 ether,
            Types.BlueprintSelectionMode.All,
            empty
        );
        vm.stopPrank();

        vm.prank(admin);
        delegation.addSlasher(admin);

        // Create commitments for both assets with different exposure
        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](2);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 10000 // 100% exposure for native
        });
        commitments[1] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(token) }),
            exposureBps: 5000 // 50% exposure for ERC20
        });

        vm.prank(admin);
        uint256 slashed = delegation.slashForService(
            operator1,
            1,
            1,
            commitments,
            500,
            bytes32("evidence")
        );

        // Should slash proportionally from committed assets
        uint256 nativeSlashed = (15 ether * 500) / 10_000;
        uint256 tokenSlashed = (5 ether * 500 * 5000) / (10_000 * 10_000);
        uint256 expectedSlashed = nativeSlashed + tokenSlashed;
        assertApproxEqAbs(slashed, expectedSlashed, 1);
    }

    function test_SlashForService_FullSlash() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 5 ether }();

        vm.prank(admin);
        delegation.addSlasher(admin);

        Types.AssetSecurityCommitment[] memory commitments = new Types.AssetSecurityCommitment[](1);
        commitments[0] = Types.AssetSecurityCommitment({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            exposureBps: 10000
        });

        // Try to slash more than available
        vm.prank(admin);
        uint256 slashed = delegation.slashForService(
            operator1,
            1,
            1,
            commitments,
            10_000,
            bytes32("evidence")
        );

        // Should only slash up to available amount
        assertEq(slashed, 5 ether);
        assertEq(delegation.getOperatorSelfStake(operator1), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERC20 DELEGATION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DelegateERC20() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        vm.startPrank(delegator1);
        token.approve(address(delegation), 1 ether);
        delegation.depositERC20(address(token), 1 ether);

        uint64[] memory empty = new uint64[](0);
        delegation.delegateWithOptions(
            operator1,
            address(token),
            0.5 ether,
            Types.BlueprintSelectionMode.All,
            empty
        );
        vm.stopPrank();

        Types.BondInfoDelegator[] memory delegations = delegation.getDelegations(delegator1);
        assertEq(delegations.length, 1);
        // Shares = amount for first delegation (1:1 exchange rate)
        assertEq(delegations[0].shares, 0.5 ether);
        assertEq(delegations[0].asset.token, address(token));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SetOperatorCommission() public {
        vm.prank(admin);
        delegation.setOperatorCommission(2000); // 20%

        assertEq(delegation.operatorCommissionBps(), 2000);
    }

    function test_SetDelays() public {
        vm.prank(admin);
        delegation.setDelays(14, 14, 14);

        assertEq(delegation.delegationBondLessDelay(), 14);
        assertEq(delegation.leaveDelegatorsDelay(), 14);
        assertEq(delegation.leaveOperatorsDelay(), 14);
    }

    function test_DisableAsset() public {
        vm.prank(admin);
        delegation.disableAsset(address(token));

        Types.AssetConfig memory config = delegation.getAssetConfig(address(token));
        assertFalse(config.enabled);
    }

    function test_Pause() public {
        vm.prank(admin);
        delegation.pause();

        vm.prank(delegator1);
        vm.expectRevert();
        delegation.deposit{ value: 1 ether }();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GetOperatorStake() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 5 ether }();

        vm.startPrank(delegator1);
        delegation.deposit{ value: 3 ether }();
        delegation.delegate(operator1, 3 ether);
        vm.stopPrank();

        // Total = self-stake + delegated
        assertEq(delegation.getOperatorStake(operator1), 8 ether);
    }

    function test_MeetsStakeRequirement() public {
        vm.prank(operator1);
        delegation.registerOperator{ value: 5 ether }();

        assertTrue(delegation.meetsStakeRequirement(operator1, 5 ether));
        assertTrue(delegation.meetsStakeRequirement(operator1, 1 ether));
        assertFalse(delegation.meetsStakeRequirement(operator1, 10 ether));
    }

    function test_OperatorCount() public {
        assertEq(delegation.operatorCount(), 0);

        vm.prank(operator1);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertEq(delegation.operatorCount(), 1);

        vm.prank(operator2);
        delegation.registerOperator{ value: MIN_OPERATOR_STAKE }();

        assertEq(delegation.operatorCount(), 2);
    }
}
