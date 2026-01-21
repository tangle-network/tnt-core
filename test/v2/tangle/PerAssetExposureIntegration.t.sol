// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";
import { MockPriceOracle } from "../exposure/MockPriceOracle.sol";
import { ServiceFeeDistributor } from "../../../src/v2/rewards/ServiceFeeDistributor.sol";
import { SlashingLib } from "../../../src/v2/libraries/SlashingLib.sol";

contract PerAssetExposureIntegrationTest is BaseTest {
    MockERC20 internal stakeToken;
    MockERC20 internal payToken;
    MockPriceOracle internal oracle;
    ServiceFeeDistributor internal distributor;

    uint64 internal blueprintId;

    function setUp() public override {
        super.setUp();

        stakeToken = new MockERC20();
        payToken = new MockERC20();
        oracle = new MockPriceOracle();

        // $1 per unit for both assets (18 decimals)
        oracle.setPrice(address(0), 1e18);
        oracle.setPrice(address(stakeToken), 1e18);

        // Deploy distributor behind proxy (upgradeable)
        ServiceFeeDistributor impl = new ServiceFeeDistributor();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(
                ServiceFeeDistributor.initialize,
                (admin, address(staking), address(tangle), address(oracle))
            )
        );
        distributor = ServiceFeeDistributor(payable(address(proxy)));

        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        tangle.setPriceOracle(address(oracle));
        staking.setServiceFeeDistributor(address(distributor));

        // Enable stake ERC20 asset in restaking
        staking.enableAsset(address(stakeToken), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);
        vm.stopPrank();

        // Setup blueprint + operator
        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://per-asset", address(0)));

        _registerOperator(operator1, 5 ether);
        _registerForBlueprint(operator1, blueprintId);

        // Fund staking tokens
        stakeToken.mint(delegator2, 100 ether);
        payToken.mint(user1, 1000 ether);

        // Delegator1 stakes native
        vm.prank(delegator1);
        staking.depositAndDelegate{ value: 10 ether }(operator1);

        // Delegator2 stakes ERC20
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

    function test_ServiceFee_Distribution_RespectsPerAssetCommitments() public {
        // Require both native and ERC20 stake, with asymmetric commitments.
        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](2);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1000,
            maxExposureBps: 10000
        });
        reqs[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) }),
            minExposureBps: 1000,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        // Pay 110 so that restaker share (20%) = 22 and splits cleanly.
        uint256 paymentAmount = 110 ether;
        vm.startPrank(user1);
        payToken.approve(address(tangle), paymentAmount);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId,
            ops,
            reqs,
            "",
            new address[](0),
            0,
            address(payToken),
            paymentAmount
        );
        vm.stopPrank();

        // Commit 100% native exposure, 10% ERC20 exposure.
        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](2);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: 10000 });
        commits[1] = Types.AssetSecurityCommitment({ asset: reqs[1].asset, exposureBps: 1000 });

        vm.prank(operator1);
        tangle.approveServiceWithCommitments(requestId, commits);

        // Restaker share is 22. With equal stake but 10x lower commitment on ERC20, expected:
        // native receives 20, ERC20 receives 2.
        uint256 d1Before = payToken.balanceOf(delegator1);
        uint256 d2Before = payToken.balanceOf(delegator2);

        vm.prank(delegator1);
        distributor.claimFor(address(payToken), operator1, reqs[0].asset);
        vm.prank(delegator2);
        distributor.claimFor(address(payToken), operator1, reqs[1].asset);

        assertEq(payToken.balanceOf(delegator1) - d1Before, 20 ether);
        assertEq(payToken.balanceOf(delegator2) - d2Before, 2 ether);
    }

    function test_Slashing_EffectiveAmount_ScaledByPerAssetCommitments() public {
        Types.AssetSecurityRequirement[] memory reqs = new Types.AssetSecurityRequirement[](2);
        reqs[0] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.Native, token: address(0) }),
            minExposureBps: 1000,
            maxExposureBps: 10000
        });
        reqs[1] = Types.AssetSecurityRequirement({
            asset: Types.Asset({ kind: Types.AssetKind.ERC20, token: address(stakeToken) }),
            minExposureBps: 1000,
            maxExposureBps: 10000
        });

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.startPrank(user1);
        payToken.approve(address(tangle), 1 ether);
        uint64 requestId = tangle.requestServiceWithSecurity(
            blueprintId,
            ops,
            reqs,
            "",
            new address[](0),
            0,
            address(payToken),
            1 ether
        );
        vm.stopPrank();

        Types.AssetSecurityCommitment[] memory commits = new Types.AssetSecurityCommitment[](2);
        commits[0] = Types.AssetSecurityCommitment({ asset: reqs[0].asset, exposureBps: 10000 });
        commits[1] = Types.AssetSecurityCommitment({ asset: reqs[1].asset, exposureBps: 1000 });

        vm.prank(operator1);
        tangle.approveServiceWithCommitments(requestId, commits);

        uint64 serviceId = tangle.serviceCount() - 1;

        // With equal stake in each asset, weighted commitment = (10000 + 1000) / 2 = 5500.
        // Service exposure is 10000 (default), so effective exposure is 5500.
        uint16 slashBps = 2000;
        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, slashBps, keccak256("evidence"));

        SlashingLib.SlashProposal memory p = tangle.getSlashProposal(slashId);
        assertEq(p.slashBps, slashBps);
        assertEq(p.effectiveSlashBps, (uint256(slashBps) * 5500) / 10000);
    }
}
