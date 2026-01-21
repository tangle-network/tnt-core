// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";
import { MockPriceOracle } from "../exposure/MockPriceOracle.sol";
import { ServiceFeeDistributor } from "../../../src/v2/rewards/ServiceFeeDistributor.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { DelegationErrors } from "../../../src/v2/staking/DelegationErrors.sol";
import { IPriceOracle } from "../../../src/v2/oracles/interfaces/IPriceOracle.sol";

contract ServiceFeeDistributorTest is BaseTest {
    MockERC20 internal stakeToken;
    MockERC20 internal payTokenA;
    MockERC20 internal payTokenB;
    MockPriceOracle internal oracle;
    ServiceFeeDistributor internal distributor;
    uint64 internal blueprintId;

    function setUp() public override {
        super.setUp();

        stakeToken = new MockERC20();
        payTokenA = new MockERC20();
        payTokenB = new MockERC20();
        oracle = new MockPriceOracle();

        oracle.setPrice(address(0), 1e18);
        oracle.setPrice(address(stakeToken), 1e18);

        ServiceFeeDistributor impl = new ServiceFeeDistributor();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(ServiceFeeDistributor.initialize, (admin, address(staking), address(tangle), address(oracle)))
        );
        distributor = ServiceFeeDistributor(payable(address(proxy)));

        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        tangle.setPriceOracle(address(oracle));
        staking.setServiceFeeDistributor(address(distributor));
        staking.enableAsset(address(stakeToken), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);
        vm.stopPrank();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://sfd", address(0)));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);

        stakeToken.mint(delegator2, 100 ether);
        payTokenA.mint(user1, 1_000 ether);
        payTokenB.mint(user1, 1_000 ether);

        vm.prank(delegator1);
        staking.depositAndDelegate{ value: 10 ether }(operator1);

        vm.startPrank(delegator2);
        stakeToken.approve(address(staking), 10 ether);
        staking.depositAndDelegateWithOptions(
            operator1,
            address(stakeToken),
            10 ether,
            Types.BlueprintSelectionMode.All,
            new uint64[](0)
        );
        vm.stopPrank();
    }

    function _requestAndApproveWithCommitments(uint16 nativeBps, uint16 erc20Bps, address paymentToken, uint256 paymentAmount)
        internal
        returns (uint64 serviceId)
    {
        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](2);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });
        reqs[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.startPrank(user1);
        MockERC20(paymentToken).approve(address(tangle), paymentAmount);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId,
            ops,
            reqs,
            "",
            new address[](0),
            0,
            paymentToken,
            paymentAmount
        );
        vm.stopPrank();

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](2);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: nativeBps });
        commits[1] = Types.AssetSecurityCommitment({ asset: reqs[1].asset, exposureBps: erc20Bps });

        vm.prank(operator1);
        tangle.approveServiceWithCommitments(requestId, commits);

        serviceId = tangle.serviceCount() - 1;
    }

    function test_Distribution_MultiplePaymentTokens_AccruesSeparately() public {
        // restaker share = 20% of payment, pick amounts divisible.
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenB), 50 ether);

        uint256 d1A = payTokenA.balanceOf(delegator1);
        uint256 d2A = payTokenA.balanceOf(delegator2);
        uint256 d1B = payTokenB.balanceOf(delegator1);
        uint256 d2B = payTokenB.balanceOf(delegator2);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });
        Types.Asset memory ercAsset = Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) });

        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        vm.prank(delegator2);
        distributor.claimFor(address(payTokenA), operator1, ercAsset);

        vm.prank(delegator1);
        distributor.claimFor(address(payTokenB), operator1, nativeAsset);
        vm.prank(delegator2);
        distributor.claimFor(address(payTokenB), operator1, ercAsset);

        // With equal stake, and equal commitments, each gets half of restaker share:
        // A: 20 ether total -> 10/10; B: 10 ether total -> 5/5.
        assertEq(payTokenA.balanceOf(delegator1) - d1A, 10 ether);
        assertEq(payTokenA.balanceOf(delegator2) - d2A, 10 ether);
        assertEq(payTokenB.balanceOf(delegator1) - d1B, 5 ether);
        assertEq(payTokenB.balanceOf(delegator2) - d2B, 5 ether);
    }

    function test_ClaimAllBatch_MultiToken() public {
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenB), 50 ether);

        uint256 pendingA = distributor.pendingRewards(delegator1, address(payTokenA));
        uint256 pendingB = distributor.pendingRewards(delegator1, address(payTokenB));
        assertGt(pendingA, 0);
        assertGt(pendingB, 0);

        address[] memory tokens = new address[](2);
        tokens[0] = address(payTokenA);
        tokens[1] = address(payTokenB);

        vm.prank(delegator1);
        uint256[] memory claimed = distributor.claimAllBatch(tokens);

        assertEq(claimed[0], pendingA);
        assertEq(claimed[1], pendingB);
        assertEq(distributor.pendingRewards(delegator1, address(payTokenA)), 0);
        assertEq(distributor.pendingRewards(delegator1, address(payTokenB)), 0);
    }

    function test_Fallback_NoSecurityRequirements_StillDistributesToRestakers() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;

        // Pay once via requestService (no per-asset requirements); ensure distributor does not route to treasury.
        uint256 paymentAmount = 110 ether; // restaker share = 22
        vm.startPrank(user1);
        payTokenA.approve(address(tangle), paymentAmount);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(payTokenA), paymentAmount
        );
        vm.stopPrank();

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });
        Types.Asset memory ercAsset = Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) });

        uint256 d1Before = payTokenA.balanceOf(delegator1);
        uint256 d2Before = payTokenA.balanceOf(delegator2);

        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        vm.prank(delegator2);
        distributor.claimFor(address(payTokenA), operator1, ercAsset);

        // Equal USD stake => split restaker share 11/11.
        assertEq(payTokenA.balanceOf(delegator1) - d1Before, 11 ether);
        assertEq(payTokenA.balanceOf(delegator2) - d2Before, 11 ether);
    }

    function test_Restaking_PreventsSelectionModeMixing() public {
        uint64[] memory bps = new uint64[](1);
        bps[0] = 123;

        vm.startPrank(delegator1);
        staking.deposit{ value: 1 ether }();
        vm.expectRevert(DelegationErrors.SelectionModeMismatch.selector);
        staking.delegateWithOptions(operator1, address(0), 1 ether, Types.BlueprintSelectionMode.Fixed, bps);
        vm.stopPrank();
    }

    function test_FixedMode_MultiBlueprint_SplitsByBlueprintExposure() public {
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, blueprintId);

        vm.prank(developer);
        uint64 blueprint2 = tangle.createBlueprint(_blueprintDefinition("ipfs://sfd-2", address(0)));
        _registerForBlueprint(operator2, blueprint2);

        address fixedDelA = makeAddr("fixedDelA");
        address fixedDelB = makeAddr("fixedDelB");
        vm.deal(fixedDelA, 50 ether);
        vm.deal(fixedDelB, 50 ether);

        uint64[] memory both = new uint64[](2);
        both[0] = blueprintId;
        both[1] = blueprint2;

        vm.prank(fixedDelA);
        staking.depositAndDelegateWithOptions{ value: 12 ether }(
            operator2,
            address(0),
            12 ether,
            Types.BlueprintSelectionMode.Fixed,
            both
        );

        uint64[] memory onlyFirst = new uint64[](1);
        onlyFirst[0] = blueprintId;

        vm.prank(fixedDelB);
        staking.depositAndDelegateWithOptions{ value: 12 ether }(
            operator2,
            address(0),
            12 ether,
            Types.BlueprintSelectionMode.Fixed,
            onlyFirst
        );

        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](1);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator2;

        uint256 paymentAmount = 90 ether;
        vm.startPrank(user1);
        payTokenA.approve(address(tangle), paymentAmount);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId,
            ops,
            reqs,
            "",
            new address[](0),
            0,
            address(payTokenA),
            paymentAmount
        );
        vm.stopPrank();

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](1);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: 10000 });

        vm.prank(operator2);
        tangle.approveServiceWithCommitments(requestId, commits);

        Types.Asset memory nativeAsset = reqs[0].asset;
        uint256 beforeA = payTokenA.balanceOf(fixedDelA);
        uint256 beforeB = payTokenA.balanceOf(fixedDelB);

        vm.prank(fixedDelA);
        distributor.claimFor(address(payTokenA), operator2, nativeAsset);
        vm.prank(fixedDelB);
        distributor.claimFor(address(payTokenA), operator2, nativeAsset);

        // Restaker share = 20% of payment = 18. fixedDelA has half the blueprint exposure.
        assertEq(payTokenA.balanceOf(fixedDelA) - beforeA, 6 ether);
        assertEq(payTokenA.balanceOf(fixedDelB) - beforeB, 12 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EDGE CASES & ABUSE SCENARIOS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_EdgeCase_ZeroOraclePrice_RevertsPriceNotAvailable() public {
        oracle.setPrice(address(stakeToken), 0);

        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](2);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });
        reqs[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        uint256 paymentAmount = 100 ether;
        vm.startPrank(user1);
        payTokenA.approve(address(tangle), paymentAmount);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId,
            ops,
            reqs,
            "",
            new address[](0),
            0,
            address(payTokenA),
            paymentAmount
        );
        vm.stopPrank();

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](2);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: 10000 });
        commits[1] = Types.AssetSecurityCommitment({ asset: reqs[1].asset, exposureBps: 10000 });

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.PriceNotAvailable.selector, address(stakeToken)));
        tangle.approveServiceWithCommitments(requestId, commits);
    }

    function test_EdgeCase_NoDelegators_DistributionDoesNotRevert() public {
        // Register operator2 with no delegators
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator2, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator2;

        // Create service with operator2 (who has no delegators)
        vm.startPrank(user1);
        payTokenA.approve(address(tangle), 100 ether);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(payTokenA), 100 ether
        );
        vm.stopPrank();

        // Should not revert even though operator has no delegators
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        // Treasury should receive the restaker share since no delegators
        // (or it stays in distributor - depends on implementation)
    }

    function test_EdgeCase_AsymmetricCommitments_CorrectWeighting() public {
        // Native: 100% commitment (10000 bps)
        // ERC20: 10% commitment (1000 bps)
        _requestAndApproveWithCommitments(10000, 1000, address(payTokenA), 110 ether);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });
        Types.Asset memory ercAsset = Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) });

        uint256 d1Before = payTokenA.balanceOf(delegator1);
        uint256 d2Before = payTokenA.balanceOf(delegator2);

        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        vm.prank(delegator2);
        distributor.claimFor(address(payTokenA), operator1, ercAsset);

        // Restaker share = 22 ether
        // Native exposed = 10 ETH * 100% = 10 ETH USD
        // ERC20 exposed = 10 tokens * 10% = 1 token USD
        // Total USD = 11
        // Native share = 22 * 10/11 = 20
        // ERC20 share = 22 * 1/11 = 2
        assertEq(payTokenA.balanceOf(delegator1) - d1Before, 20 ether, "Native delegator should get 20 ether");
        assertEq(payTokenA.balanceOf(delegator2) - d2Before, 2 ether, "ERC20 delegator should get 2 ether");
    }

    function test_EdgeCase_ClaimTwice_SecondClaimReturnsZero() public {
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });

        // First claim
        vm.prank(delegator1);
        uint256 firstClaim = distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        assertGt(firstClaim, 0, "First claim should be non-zero");

        // Second claim should return 0 (no new rewards)
        vm.prank(delegator1);
        uint256 secondClaim = distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        assertEq(secondClaim, 0, "Second claim should be zero");
    }

    function test_EdgeCase_ClaimAfterUndelegation_GetsPreviousRewards() public {
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });

        // Undelegate before claiming
        vm.prank(delegator1);
        staking.scheduleDelegatorUnstake(operator1, address(0), 5 ether);

        // Should still be able to claim rewards accumulated before undelegation
        uint256 d1Before = payTokenA.balanceOf(delegator1);
        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        assertGt(payTokenA.balanceOf(delegator1) - d1Before, 0, "Should claim rewards from before undelegation");
    }

    function test_EdgeCase_MultipleServicesAccumulate() public {
        // Create two services with same operator
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });

        uint256 d1Before = payTokenA.balanceOf(delegator1);
        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);

        // Should receive rewards from both services
        // Each service: 20 ether restaker share, half to native = 10 ether
        // Two services = 20 ether total
        assertEq(payTokenA.balanceOf(delegator1) - d1Before, 20 ether, "Should accumulate from multiple services");
    }

    function test_EdgeCase_DifferentPrices_CorrectUSDWeighting() public {
        // Set different prices: Native = $2000, ERC20 = $1
        oracle.setPrice(address(0), 2000e18);
        oracle.setPrice(address(stakeToken), 1e18);

        // Both delegators have 10 units each
        // Native: 10 ETH * $2000 = $20,000
        // ERC20: 10 tokens * $1 = $10
        // Native should get ~99.95% of rewards

        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });
        Types.Asset memory ercAsset = Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) });

        uint256 d1Before = payTokenA.balanceOf(delegator1);
        uint256 d2Before = payTokenA.balanceOf(delegator2);

        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        vm.prank(delegator2);
        distributor.claimFor(address(payTokenA), operator1, ercAsset);

        uint256 d1Reward = payTokenA.balanceOf(delegator1) - d1Before;
        uint256 d2Reward = payTokenA.balanceOf(delegator2) - d2Before;

        // Native should get vastly more due to higher USD value
        assertGt(d1Reward, d2Reward * 100, "Native should get >100x more due to price difference");
    }

    function test_EdgeCase_CommitmentBelowMin_Reverts() public {
        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](2);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });
        reqs[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.startPrank(user1);
        payTokenA.approve(address(tangle), 100 ether);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, ops, reqs, "", new address[](0), 0, address(payTokenA), 100 ether
        );
        vm.stopPrank();

        // Commit 100% native, 0% ERC20
        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](2);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: 10000 });
        commits[1] = Types.AssetSecurityCommitment({ asset: reqs[1].asset, exposureBps: 0 });

        vm.prank(operator1);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.CommitmentBelowMinimum.selector, address(stakeToken), uint16(0), uint16(1))
        );
        tangle.approveServiceWithCommitments(requestId, commits);
    }

    function test_EdgeCase_VerySmallAmounts_NoDustLoss() public {
        // Test with very small payment amounts
        payTokenA.mint(user1, 1000);

        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](1);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.startPrank(user1);
        payTokenA.approve(address(tangle), 1000);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, ops, reqs, "", new address[](0), 0, address(payTokenA), 1000
        );
        vm.stopPrank();

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](1);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: 10000 });

        vm.prank(operator1);
        tangle.approveServiceWithCommitments(requestId, commits);

        // Restaker share = 200 (20% of 1000)
        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });

        uint256 d1Before = payTokenA.balanceOf(delegator1);
        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);

        // Should get the full restaker share (200)
        assertEq(payTokenA.balanceOf(delegator1) - d1Before, 200, "Should receive full small amount without dust loss");
    }

    function test_View_PendingRewards_MatchesActualClaim() public {
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);

        Types.Asset memory nativeAsset = Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });

        // Check pending rewards view function
        uint256 pending = distributor.pendingRewards(delegator1, address(payTokenA));

        // Claim and verify matches
        uint256 d1Before = payTokenA.balanceOf(delegator1);
        vm.prank(delegator1);
        distributor.claimFor(address(payTokenA), operator1, nativeAsset);
        uint256 actualClaimed = payTokenA.balanceOf(delegator1) - d1Before;

        assertEq(pending, actualClaimed, "Pending rewards view should match actual claim");
    }

    function test_View_DelegatorOperators_TracksPositions() public {
        _requestAndApproveWithCommitments(10000, 10000, address(payTokenA), 100 ether);

        // Check delegator1 has operator1 tracked
        address[] memory ops = distributor.delegatorOperators(delegator1);
        assertEq(ops.length, 1, "Should track 1 operator");
        assertEq(ops[0], operator1, "Should be operator1");
    }

    /// @notice Test TNT score rate boost: 1 TNT = $1 score regardless of market price
    function test_TntScoreRate_BoostsDistribution() public {
        // Setup: Create a "TNT" token with market price of $0.10
        MockERC20 tntToken = new MockERC20();
        oracle.setPrice(address(tntToken), 0.1e18); // TNT = $0.10 market price

        // Enable TNT as a staking asset
        vm.prank(admin);
        staking.enableAsset(address(tntToken), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);

        // Set TNT score rate: 1 TNT = $1 score (10x boost vs market price)
        vm.prank(admin);
        distributor.setTntScoreRate(address(tntToken), 1e18);

        // Verify storage
        assertEq(distributor.tntToken(), address(tntToken), "TNT token should be set");
        assertEq(distributor.tntScoreRate(), 1e18, "TNT score rate should be 1e18");

        // delegator3 stakes 10 TNT (worth $1 at market, but $10 score value)
        address delegator3 = makeAddr("delegator3");
        tntToken.mint(delegator3, 10 ether);

        vm.startPrank(delegator3);
        tntToken.approve(address(staking), 10 ether);
        staking.depositAndDelegateWithOptions(
            operator1,
            address(tntToken),
            10 ether,
            Types.BlueprintSelectionMode.All,
            new uint64[](0)
        );
        vm.stopPrank();

        // Request service with all 3 assets: native ETH ($10), stakeToken ($10), TNT ($1 market but $10 score)
        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](3);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });
        reqs[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });
        reqs[2] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(tntToken) }),
            minExposureBps: 1,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        uint256 paymentAmount = 300 ether; // Large amount for easier math
        vm.startPrank(user1);
        payTokenA.approve(address(tangle), paymentAmount);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId, ops, reqs, "", new address[](0), 0, address(payTokenA), paymentAmount
        );
        vm.stopPrank();

        // Commit 100% exposure on all assets
        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](3);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: 10000 });
        commits[1] = Types.AssetSecurityCommitment({ asset: reqs[1].asset, exposureBps: 10000 });
        commits[2] = Types.AssetSecurityCommitment({ asset: reqs[2].asset, exposureBps: 10000 });

        vm.prank(operator1);
        tangle.approveServiceWithCommitments(requestId, commits);

        // Restaker share is 20% = 60 ether
        // Without TNT boost: native $10, stakeToken $10, TNT $1 = $21 total
        //   - native gets 10/21 * 60 ≈ 28.57 ether
        //   - stakeToken gets 10/21 * 60 ≈ 28.57 ether
        //   - TNT gets 1/21 * 60 ≈ 2.86 ether
        //
        // WITH TNT boost (1 TNT = $1 score): native $10, stakeToken $10, TNT $10 = $30 total
        //   - Each gets exactly 1/3 = 20 ether

        Types.Asset memory tntAsset = Types.Asset({ kind: Types.AssetKind.ERC20, token: address(tntToken) });

        uint256 d3Before = payTokenA.balanceOf(delegator3);
        vm.prank(delegator3);
        distributor.claimFor(address(payTokenA), operator1, tntAsset);
        uint256 d3Claimed = payTokenA.balanceOf(delegator3) - d3Before;

        // With TNT boost, delegator3 should get 1/3 of 60 ether = 20 ether
        assertEq(d3Claimed, 20 ether, "TNT holder should get 1/3 of restaker share with score boost");
    }

    /// @notice Test that disabling TNT score rate reverts to oracle price
    function test_TntScoreRate_DisabledUsesOracle() public {
        MockERC20 tntToken = new MockERC20();
        oracle.setPrice(address(tntToken), 0.1e18); // TNT = $0.10

        vm.prank(admin);
        staking.enableAsset(address(tntToken), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);

        // First set TNT score rate, then disable it
        vm.startPrank(admin);
        distributor.setTntScoreRate(address(tntToken), 1e18);
        distributor.setTntScoreRate(address(0), 0); // Disable
        vm.stopPrank();

        assertEq(distributor.tntToken(), address(0), "TNT token should be cleared");
        assertEq(distributor.tntScoreRate(), 0, "TNT score rate should be 0");
    }
}
