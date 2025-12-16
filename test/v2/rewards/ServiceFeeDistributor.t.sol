// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";
import { MockPriceOracle } from "../exposure/MockPriceOracle.sol";
import { ServiceFeeDistributor } from "../../../src/v2/rewards/ServiceFeeDistributor.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { DelegationErrors } from "../../../src/v2/restaking/DelegationErrors.sol";

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
            abi.encodeCall(ServiceFeeDistributor.initialize, (admin, address(restaking), address(tangle), address(oracle)))
        );
        distributor = ServiceFeeDistributor(payable(address(proxy)));

        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        tangle.setPriceOracle(address(oracle));
        restaking.setServiceFeeDistributor(address(distributor));
        restaking.enableAsset(address(stakeToken), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);
        vm.stopPrank();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://sfd", address(0)));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);

        stakeToken.mint(delegator2, 100 ether);
        payTokenA.mint(user1, 1_000 ether);
        payTokenB.mint(user1, 1_000 ether);

        vm.prank(delegator1);
        restaking.depositAndDelegate{ value: 10 ether }(operator1);

        vm.startPrank(delegator2);
        stakeToken.approve(address(restaking), 10 ether);
        restaking.depositAndDelegateWithOptions(
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
        restaking.deposit{ value: 1 ether }();
        vm.expectRevert(DelegationErrors.SelectionModeMismatch.selector);
        restaking.delegateWithOptions(operator1, address(0), 1 ether, Types.BlueprintSelectionMode.Fixed, bps);
        vm.stopPrank();
    }
}

