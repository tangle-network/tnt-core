// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../../src/staking/MultiAssetDelegation.sol";
import { LiquidDelegationVault } from "../../../src/staking/LiquidDelegationVault.sol";
import { LiquidDelegationFactory } from "../../../src/staking/LiquidDelegationFactory.sol";
import { RebasingAssetAdapter } from "../../../src/staking/adapters/RebasingAssetAdapter.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { StakingOperatorsFacet } from "../../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../../src/facets/staking/StakingAdminFacet.sol";
import { PaymentsEffectiveExposure, IAdapterLookup } from "../../../src/core/PaymentsEffectiveExposure.sol";
import { IStaking } from "../../../src/interfaces/IStaking.sol";
import { IPriceOracle } from "../../../src/oracles/interfaces/IPriceOracle.sol";
import { IAssetAdapter } from "../../../src/staking/adapters/IAssetAdapter.sol";

/// @notice Rebasing token (stETH-style): balances scale by a global multiplier.
contract MockRebasingToken is ERC20 {
    uint256 public rebaseMultiplier = 1e18;

    constructor() ERC20("Mock stETH", "mstETH") { }

    function mint(address to, uint256 amount) external {
        _mint(to, (amount * 1e18) / rebaseMultiplier);
    }

    function rebase(uint256 bps) external {
        rebaseMultiplier = (rebaseMultiplier * (10_000 + bps)) / 10_000;
    }

    function balanceOf(address a) public view override returns (uint256) {
        return (super.balanceOf(a) * rebaseMultiplier) / 1e18;
    }

    function totalSupply() public view override returns (uint256) {
        return (super.totalSupply() * rebaseMultiplier) / 1e18;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        return super.transfer(to, (amount * 1e18) / rebaseMultiplier);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        return super.transferFrom(from, to, (amount * 1e18) / rebaseMultiplier);
    }
}

/// @title AdapterUnitMismatchTest
/// @notice F1 regression: LiquidDelegationVault must mint shares against the CREDITED deposit-units
///         (adapter shares), not the raw token amount. With a rebasing adapter the two diverge; the
///         pre-fix code minted off the raw amount, letting a post-rebase depositor mint far more
///         shares than they actually funded — diluting earlier holders.
contract AdapterUnitMismatchTest is Test {
    IMultiAssetDelegation internal staking;
    LiquidDelegationFactory internal factory;
    MockRebasingToken internal token;
    RebasingAssetAdapter internal adapter;

    address internal admin = makeAddr("admin");
    address internal operator1 = makeAddr("operator1");
    address internal user1 = makeAddr("user1");
    address internal user2 = makeAddr("user2");

    uint256 constant MIN_OPERATOR_STAKE = 1 ether;

    function setUp() public {
        token = new MockRebasingToken();

        MultiAssetDelegation impl = new MultiAssetDelegation();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl), abi.encodeCall(MultiAssetDelegation.initialize, (admin, MIN_OPERATOR_STAKE, 0, 1000))
        );
        staking = IMultiAssetDelegation(payable(address(proxy)));

        MultiAssetDelegation router = MultiAssetDelegation(payable(address(proxy)));
        vm.startPrank(admin);
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));

        // Rebasing adapter for the token, wired to the staking diamond.
        adapter = new RebasingAssetAdapter(address(token), admin);
        adapter.setDelegationManager(address(staking));

        staking.enableAsset(address(token), 1 ether, 0.1 ether, 0, 10_000);
        staking.registerAdapter(address(token), address(adapter));

        staking.addSlasher(admin);
        staking.setTangle(admin);
        vm.stopPrank();

        factory = new LiquidDelegationFactory(staking);

        vm.deal(operator1, 100 ether);
        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);

        token.mint(user1, 1000 ether);
        token.mint(user2, 1000 ether);
    }

    function test_F1_DepositMintsOnCreditedUnitsNotRawAmount() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // user1 deposits 100 tokens at the 1:1 bootstrap rate.
        vm.startPrank(user1);
        token.approve(address(vault), 100 ether);
        uint256 user1Shares = vault.deposit(100 ether, user1);
        vm.stopPrank();
        assertGt(user1Shares, 0, "user1 minted shares");

        // The adapter's token balance doubles via a +100% rebase. Adapter SHARES (deposit-units)
        // are rebase-invariant, so the vault's accounting is unchanged — but 1 token is now worth
        // HALF an adapter share. A depositor of the same nominal 100 tokens must therefore receive
        // ~half the vault shares user1 got.
        token.rebase(10_000); // +100%

        vm.startPrank(user2);
        token.approve(address(vault), 100 ether);
        uint256 user2Shares = vault.deposit(100 ether, user2);
        vm.stopPrank();

        // FIXED: user2 funded ~half the deposit-units, so gets ~half the shares.
        // BUGGY (raw-amount mint): user2 would get == user1Shares (100 raw vs 100 raw), stealing
        // value from user1. This assertion fails under the bug.
        assertLt(user2Shares, user1Shares, "post-rebase deposit must mint on credited units, not raw amount");
        assertApproxEqRel(user2Shares, user1Shares / 2, 0.02e18, "~half the shares for the same nominal deposit");
    }
}

/// @notice Harness exposing the internal effective-exposure calculation with overridable deps.
contract ExposureHarness is PaymentsEffectiveExposure {
    address public stakingAddr;
    address public oracleAddr;
    mapping(uint64 => mapping(address => Types.AssetSecurityCommitment[])) internal _commits;

    function setStaking(address s) external {
        stakingAddr = s;
    }

    function setOracle(address o) external {
        oracleAddr = o;
    }

    function addCommitment(uint64 svc, address op, Types.Asset memory a, uint16 bps) external {
        _commits[svc][op].push(Types.AssetSecurityCommitment({ asset: a, exposureBps: bps }));
    }

    function _getStaking() internal view override returns (IStaking) {
        return IStaking(stakingAddr);
    }

    function _getPriceOracle() internal view override returns (address) {
        return oracleAddr;
    }

    function _getServiceSecurityCommitments(
        uint64 svc,
        address op
    )
        internal
        view
        override
        returns (Types.AssetSecurityCommitment[] storage)
    {
        return _commits[svc][op];
    }

    function calc(uint64 svc, address[] memory ops) external view returns (uint256[] memory, uint256) {
        return _calculateEffectiveExposures(svc, ops);
    }
}

/// @notice F2 regression: effective-exposure USD weighting must convert deposit-units (adapter
///         shares) to TOKEN units before `oracle.toUSD`, which expects token units. Under a
///         non-1:1 (rebasing) adapter the pre-fix code fed deposit-units straight into toUSD,
///         mis-pricing the operator's payout weight.
contract ExposureUnitMismatchTest is Test {
    function test_F2_ExposureUsesTokenUnitsNotDepositUnits() public {
        ExposureHarness h = new ExposureHarness();
        address mockStaking = makeAddr("mockStaking");
        address mockAdapter = makeAddr("mockAdapter");
        address mockOracle = makeAddr("mockOracle");
        address erc20 = makeAddr("erc20token");

        h.setStaking(mockStaking);
        h.setOracle(mockOracle);

        uint64 svc = 1;
        address op = makeAddr("op");
        Types.Asset memory asset = Types.Asset({ kind: Types.AssetKind.ERC20, token: erc20 });
        h.addCommitment(svc, op, asset, 10_000); // 100% exposure

        uint256 depositUnits = 100 ether; // adapter SHARES (what staking tracks)
        uint256 tokenAmount = 200 ether; // their value in TOKENS after a +100% rebase

        // staking.getOperatorStakeForAsset(op, asset) -> deposit-units
        vm.mockCall(
            mockStaking,
            abi.encodeWithSelector(IStaking.getOperatorStakeForAsset.selector, op, asset),
            abi.encode(depositUnits)
        );
        // staking.getAssetAdapter(erc20) -> mockAdapter
        vm.mockCall(
            mockStaking, abi.encodeWithSelector(IAdapterLookup.getAssetAdapter.selector, erc20), abi.encode(mockAdapter)
        );
        // adapter.sharesToAssets(depositUnits) -> tokenAmount (the non-1:1 conversion)
        vm.mockCall(
            mockAdapter,
            abi.encodeWithSelector(IAssetAdapter.sharesToAssets.selector, depositUnits),
            abi.encode(tokenAmount)
        );
        // oracle.toUSD(erc20, tokenAmount) -> identity, so the result reveals the amount fed in.
        // NOTE: only the TOKEN-unit call is mocked. The buggy path would call toUSD with the raw
        // deposit-units (100e18), which has NO mock and reverts — so this test fails pre-fix.
        vm.mockCall(
            mockOracle, abi.encodeWithSelector(IPriceOracle.toUSD.selector, erc20, tokenAmount), abi.encode(tokenAmount)
        );

        address[] memory ops = new address[](1);
        ops[0] = op;
        (uint256[] memory exp, uint256 total) = h.calc(svc, ops);

        assertEq(exp[0], tokenAmount, "exposure priced on converted TOKEN units, not deposit-units");
        assertEq(total, tokenAmount, "total matches");
    }
}
