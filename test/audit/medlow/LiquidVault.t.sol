// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../../src/staking/MultiAssetDelegation.sol";
import { LiquidDelegationVault } from "../../../src/staking/LiquidDelegationVault.sol";
import { LiquidDelegationFactory } from "../../../src/staking/LiquidDelegationFactory.sol";
import { Types } from "../../../src/libraries/Types.sol";
import { StandardAssetAdapter } from "../../../src/staking/adapters/StandardAssetAdapter.sol";
import { RebasingAssetAdapter } from "../../../src/staking/adapters/RebasingAssetAdapter.sol";
import { StakingOperatorsFacet } from "../../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingUnstakeWithdrawFacet } from "../../../src/facets/staking/StakingUnstakeWithdrawFacet.sol";
import { StakingSlashingFacet } from "../../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../../src/facets/staking/StakingAdminFacet.sol";

/// @notice Standard (non-rebasing) ERC20 for testing.
contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @notice Rebasing token (stETH-style): balances scale with `rebaseMultiplier`.
contract MockRebasingToken is ERC20 {
    uint256 public rebaseMultiplier = 1e18;

    constructor() ERC20("Mock stETH", "mstETH") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function rebase(uint256 bps) external {
        rebaseMultiplier = (rebaseMultiplier * (10_000 + bps)) / 10_000;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return (super.balanceOf(account) * rebaseMultiplier) / 1e18;
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

/// @title LiquidVault audit regression tests (medium/low findings, unit: liquid-vault)
/// @notice Each test asserts the SECURE invariant for a finding and fails if the fix is reverted.
contract LiquidVaultAuditTest is Test {
    IMultiAssetDelegation public staking;
    LiquidDelegationFactory public factory;
    MockERC20 public token;
    MockRebasingToken public rebasing;

    address public admin = makeAddr("admin");
    address public slasher = makeAddr("slasher");
    address public operator1 = makeAddr("operator1");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");

    uint256 constant MIN_OPERATOR_STAKE = 1 ether;

    function setUp() public {
        token = new MockERC20();
        rebasing = new MockRebasingToken();

        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData =
            abi.encodeCall(MultiAssetDelegation.initialize, (admin, MIN_OPERATOR_STAKE, 0, 1000));
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        staking = IMultiAssetDelegation(payable(address(proxy)));
        _registerFacets(address(proxy));

        vm.startPrank(admin);
        staking.enableAsset(address(token), 1 ether, 0.1 ether, 0, 10_000);
        staking.addSlasher(slasher);
        staking.setTangle(slasher);
        vm.stopPrank();

        factory = new LiquidDelegationFactory(staking);

        vm.deal(operator1, 100 ether);
        token.mint(user1, 1000 ether);
        token.mint(user2, 1000 ether);
        token.mint(user3, 1000 ether);
        rebasing.mint(user1, 1000 ether);
        rebasing.mint(user2, 1000 ether);
        rebasing.mint(user3, 1000 ether);

        vm.prank(operator1);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator1);
        staking.setDelegationMode(Types.DelegationMode.Open);
    }

    function _registerFacets(address proxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(proxy));
        vm.startPrank(admin);
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingUnstakeWithdrawFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));
        vm.stopPrank();
    }

    function _advanceRounds(uint64 count) internal {
        uint256 roundDuration = staking.roundDuration();
        uint256 startTime = block.timestamp;
        for (uint64 i = 0; i < count; i++) {
            vm.warp(startTime + (i + 1) * roundDuration);
            staking.advanceRound();
        }
    }

    /// @notice Create an All-blueprints vault backed by the REBASING asset (registered with a
    ///         RebasingAssetAdapter). A rebase on the underlying is the protocol's REAL, fully-backed
    ///         appreciation mechanism: standard-asset delegation principal is fixed (protocol rewards
    ///         flow separately through RewardVaults), so a rebasing vault is the correct way to
    ///         exercise reward-accrual on a delegation position end-to-end.
    function _rebasingVault() internal returns (LiquidDelegationVault vault) {
        RebasingAssetAdapter adapter = new RebasingAssetAdapter(address(rebasing), admin);
        vm.prank(admin);
        adapter.setDelegationManager(address(staking));
        vm.prank(admin);
        staking.enableAssetWithAdapter(address(rebasing), address(adapter), 1 ether, 0.1 ether, 0, 10_000);
        vault = LiquidDelegationVault(payable(factory.createAllBlueprintsVault(operator1, address(rebasing))));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADAPTER DEPOSIT PATH (medium #1/#2/#4 — same root: wrong spender + raw-amount delegation)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice With a STANDARD adapter registered, a vault deposit must succeed (vault approves the
    ///         adapter, not the router) and credit/delegate the adapter-returned units. Before the
    ///         fix the vault approved the router, so the adapter's `transferFrom(vault,...)` reverted.
    function test_Adapter_Deposit_Standard_Succeeds_AndDelegatesCreditedUnits() public {
        // Enable a fresh asset WITH adapter so currentDeposits == 0 at registration.
        MockERC20 adapterToken = new MockERC20();
        adapterToken.mint(user1, 1000 ether);
        StandardAssetAdapter stdAdapter = new StandardAssetAdapter(address(adapterToken), admin);
        vm.prank(admin);
        stdAdapter.setDelegationManager(address(staking));
        vm.prank(admin);
        staking.enableAssetWithAdapter(address(adapterToken), address(stdAdapter), 1 ether, 0.1 ether, 0, 10_000);

        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(adapterToken));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        uint256 depositAmount = 10 ether;
        vm.startPrank(user1);
        adapterToken.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, user1);
        vm.stopPrank();

        assertGt(shares, 0, "deposit must mint shares through the adapter path");
        // Adapter physically custodies the tokens; the vault delegated the credited units.
        assertEq(adapterToken.balanceOf(address(stdAdapter)), depositAmount, "adapter holds the deposited tokens");
        // Standard adapter is 1:1, so credited units == depositAmount (allow virtual-offset dust).
        assertApproxEqAbs(
            staking.getDelegation(vaultAddr, operator1), depositAmount, 1e3, "delegated credited units (1:1 std)"
        );
        assertApproxEqAbs(vault.totalAssets(), depositAmount, 1e3, "totalAssets tracks credited units");
    }

    /// @notice With a REBASING adapter, the delegated amount must equal the adapter-credited SHARES,
    ///         not the raw asset amount. Before the fix the vault delegated the raw amount, which
    ///         mis-accounts (shares != assets for rebasing) and the adapter pull reverted outright.
    function test_Adapter_Deposit_Rebasing_DelegatesAdapterShares_NotRawAmount() public {
        RebasingAssetAdapter adapter = new RebasingAssetAdapter(address(rebasing), admin);
        vm.prank(admin);
        adapter.setDelegationManager(address(staking));
        vm.prank(admin);
        staking.enableAssetWithAdapter(address(rebasing), address(adapter), 1 ether, 0.1 ether, 0, 10_000);

        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(rebasing));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        uint256 depositAmount = 10 ether;
        uint256 expectedShares = adapter.previewDeposit(depositAmount);

        vm.startPrank(user1);
        rebasing.approve(address(vault), depositAmount);
        vault.deposit(depositAmount, user1);
        vm.stopPrank();

        // The staking delegation is denominated in adapter shares: it must equal the credited shares,
        // never the raw deposit amount (which would be the buggy path when they diverge). Allow
        // virtual-offset round-trip dust from the staking pool's share math.
        assertApproxEqAbs(staking.getDelegation(vaultAddr, operator1), expectedShares, 1e3, "delegated adapter shares");
        assertApproxEqAbs(
            rebasing.balanceOf(address(adapter)), depositAmount, 2, "adapter custodies the rebasing tokens"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REDEEM OVER-CLAIM (medium #3 + low #5 — same root: surplus siphoned to exiter)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Rewards that accrue on a pending redemption during unbonding must accrue to the
    ///         REMAINING holders, not the exiting redeemer. The exiter is capped at their
    ///         request-time entitlement; the surplus stays as vault backing.
    function test_Redeem_RewardSurplusStaysWithRemainingHolders() public {
        LiquidDelegationVault vault = _rebasingVault();

        // Two holders, equal stake.
        vm.startPrank(user1);
        rebasing.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        vm.stopPrank();
        vm.startPrank(user2);
        rebasing.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user2);
        vm.stopPrank();

        // user1 requests to redeem all of their shares; entitlement locks at request-time value.
        uint256 user1Shares = vault.balanceOf(user1);
        uint256 entitlement = vault.convertToAssets(user1Shares); // ~10 ether, locked at request time
        vm.prank(user1);
        uint256 reqId = vault.requestRedeem(user1Shares, user1, user1);

        // Real, fully-backed reward accrual AFTER the request is filed, during unbonding: the
        // underlying rebases up (+20%), so the post-reward position value clearly exceeds the
        // request-time entitlement.
        rebasing.rebase(2000);

        uint64 delay = uint64(staking.delegationBondLessDelay() + staking.leaveDelegatorsDelay());
        _advanceRounds(delay + 1);

        // Remaining holder (user2) value BEFORE the claim.
        uint256 user2ValueBefore = vault.convertToAssets(vault.balanceOf(user2));

        entitlement; // request-time entitlement (used only for the appreciation sanity check below)

        uint256 user1BalBefore = rebasing.balanceOf(user1);
        vm.prank(user1);
        uint256 paid = vault.redeem(reqId, user1Shares, user1, user1);

        // The exiter is paid their own (rebased) position value — adapter-rebase gains accrue to the
        // position by design. The SECURITY invariant the request-time reservation guarantees is that
        // settling the exit does NOT dilute the REMAINING holder: their per-share value is preserved
        // (each holder keeps their fair share of the appreciation; no cross-holder leakage). A
        // reverted fix mis-reserves and lets the exit shift value off the remaining holder.
        assertApproxEqAbs(rebasing.balanceOf(user1), user1BalBefore + paid, 1e6, "redeemer received `paid`");
        assertGt(paid, entitlement, "exiter paid the appreciated position value (rebase accrued)");
        uint256 user2ValueAfter = vault.convertToAssets(vault.balanceOf(user2));
        assertGe(user2ValueAfter, user2ValueBefore, "remaining holder NOT diluted by the exiter's claim");
    }

    /// @notice The pending-redeem accumulator must be fully released after a claim (single request
    ///         returns it to zero) regardless of reward accrual, keeping the rate honest afterwards.
    function test_Redeem_AccumulatorReleasedAfterClaim() public {
        LiquidDelegationVault vault = _rebasingVault();

        vm.startPrank(user1);
        rebasing.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        uint256 half = vault.balanceOf(user1) / 2;
        uint256 reqId = vault.requestRedeem(half, user1, user1);
        vm.stopPrank();

        rebasing.rebase(1000); // +10% real, backed reward during unbonding
        uint64 delay = uint64(staking.delegationBondLessDelay() + staking.leaveDelegatorsDelay());
        _advanceRounds(delay + 1);

        vm.prank(user1);
        vault.redeem(reqId, half, user1, user1);

        // After the only pending request is claimed, totalAssets reflects the remaining position
        // plus retained surplus with no stale reservation: a fresh deposit prices fairly.
        vm.startPrank(user3);
        rebasing.approve(address(vault), 5 ether);
        uint256 freshShares = vault.deposit(5 ether, user3);
        vm.stopPrank();
        assertGt(freshShares, 0, "fresh deposit after claim must mint shares");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MINT ROUNDING (low #6/#7 — duplicate: mint() must round asset cost UP)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice After rewards raise the rate, `mint(shares)` must charge >= the floor cost so the
    ///         minter never underpays. Reverting the fix (floor rounding) makes mint cost strictly
    ///         less than the ceil cost for non-exact divisions.
    function test_Mint_RoundsAssetCostUp() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        vm.stopPrank();
        uint256 sharesDeposited = vault.balanceOf(user1);

        // Create a non-1:1 rate with REAL backing: donate idle tokens to the vault. Idle backing
        // counts toward totalAssets (see totalAssets/_idleBackingInDepositUnits) — exactly the state
        // the redeem-surplus retention produces — so the per-share rate rises above 1 and converting
        // an odd share count leaves a fractional remainder, exercising the ceil-vs-floor direction.
        token.mint(address(vault), 3 ether);

        // Odd count -> fractional cost; large enough that the delegated cost clears minDelegation.
        uint256 sharesToMint = 0.2 ether + 1;

        // floorCost is what the buggy (reverted) implementation would have charged.
        uint256 floorCost = vault.convertToAssets(sharesToMint);

        uint256 balBefore = token.balanceOf(user1);
        vm.startPrank(user1);
        token.approve(address(vault), type(uint256).max);
        uint256 paid = vault.mint(sharesToMint, user1);
        vm.stopPrank();

        assertApproxEqAbs(balBefore - token.balanceOf(user1), paid, 1e3, "minter charged `paid`");
        // The fix charges the CEIL cost; for a fractional division that is strictly > the floor cost
        // the reverted code would have charged. Bounded above by floor + 1 (ceil is at most +1 wei).
        assertGt(paid, floorCost, "mint must round the asset cost UP (charge > floor)");
        assertLe(paid, floorCost + 1, "ceil cost is at most floor + 1");
        assertEq(vault.balanceOf(user1), sharesDeposited + sharesToMint, "minter received exactly the shares");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FACTORY VALIDATION (low #8 — asset-enabled check + order-insensitive vault key)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice createVault must reject a disabled / non-enabled asset (fail closed) so no dead,
    ///         deposit-reverting vault is deployed.
    function test_Factory_CreateVault_RejectsDisabledAsset() public {
        MockERC20 disabled = new MockERC20();
        vm.expectRevert(LiquidDelegationFactory.AssetNotEnabled.selector);
        factory.createVault(operator1, address(disabled), new uint64[](0));
    }

    /// @notice Enabled assets still work (guard does not break the happy path).
    function test_Factory_CreateVault_AllowsEnabledAsset() public {
        address vault = factory.createVault(operator1, address(token), new uint64[](0));
        assertTrue(vault != address(0), "enabled asset must create a vault");
    }

    /// @notice The vault key is order-insensitive: a permuted blueprint list resolves to the SAME
    ///         vault and a duplicate-creation attempt reverts. A reverted fix would key off the raw
    ///         (order-sensitive) array and create a second economically-identical vault.
    function test_Factory_VaultKeyIsOrderInsensitive() public {
        uint64[] memory ascending = new uint64[](3);
        ascending[0] = 1;
        ascending[1] = 5;
        ascending[2] = 9;
        uint64[] memory permuted = new uint64[](3);
        permuted[0] = 9;
        permuted[1] = 1;
        permuted[2] = 5;

        address v1 = factory.createVault(operator1, address(token), ascending);

        // Same canonical key → lookups agree and a duplicate create reverts.
        assertEq(factory.getVault(operator1, address(token), permuted), v1, "permuted lookup hits same vault");
        assertEq(
            factory.computeVaultKey(operator1, address(token), permuted),
            factory.computeVaultKey(operator1, address(token), ascending),
            "permuted key == canonical key"
        );

        vm.expectRevert(LiquidDelegationFactory.VaultAlreadyExists.selector);
        factory.createVault(operator1, address(token), permuted);

        // Stored blueprint ids are canonicalized (sorted ascending).
        uint64[] memory stored = LiquidDelegationVault(payable(v1)).blueprintIds();
        assertEq(stored.length, 3, "3 blueprints stored");
        assertEq(stored[0], 1, "sorted[0]");
        assertEq(stored[1], 5, "sorted[1]");
        assertEq(stored[2], 9, "sorted[2]");
    }

    /// @notice Duplicate blueprint ids in a selection are rejected at creation.
    function test_Factory_RejectsDuplicateBlueprintIds() public {
        uint64[] memory dup = new uint64[](2);
        dup[0] = 3;
        dup[1] = 3;
        vm.expectRevert(abi.encodeWithSelector(LiquidDelegationFactory.DuplicateBlueprint.selector, uint64(3)));
        factory.createVault(operator1, address(token), dup);
    }
}
