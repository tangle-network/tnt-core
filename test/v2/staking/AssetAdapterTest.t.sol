// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/Test.sol";

import {IAssetAdapter} from "../../../src/v2/staking/adapters/IAssetAdapter.sol";
import {StandardAssetAdapter} from "../../../src/v2/staking/adapters/StandardAssetAdapter.sol";
import {RebasingAssetAdapter} from "../../../src/v2/staking/adapters/RebasingAssetAdapter.sol";
import {AssetAdapterFactory} from "../../../src/v2/staking/adapters/AssetAdapterFactory.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title MockERC20
/// @notice Standard ERC20 for testing
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @title MockRebasingToken
/// @notice Simulates a rebasing token like stETH
/// @dev Balance increases can be simulated by calling `rebase()`
contract MockRebasingToken is ERC20 {
    uint256 public rebaseMultiplier = 1e18; // 1:1 initially

    constructor() ERC20("Mock stETH", "mstETH") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    /// @notice Simulate a rebase (increase all balances by percentage)
    /// @param bps Basis points to increase (100 = 1%)
    function rebase(uint256 bps) external {
        rebaseMultiplier = (rebaseMultiplier * (10000 + bps)) / 10000;
    }

    /// @notice Override balanceOf to simulate rebasing
    function balanceOf(address account) public view override returns (uint256) {
        uint256 baseBalance = super.balanceOf(account);
        return (baseBalance * rebaseMultiplier) / 1e18;
    }

    /// @notice Override totalSupply to simulate rebasing
    function totalSupply() public view override returns (uint256) {
        uint256 baseSupply = super.totalSupply();
        return (baseSupply * rebaseMultiplier) / 1e18;
    }

    /// @notice Transfer uses rebased amounts
    function transfer(address to, uint256 amount) public override returns (bool) {
        // Convert rebased amount back to base amount for internal accounting
        uint256 baseAmount = (amount * 1e18) / rebaseMultiplier;
        return super.transfer(to, baseAmount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        uint256 baseAmount = (amount * 1e18) / rebaseMultiplier;
        return super.transferFrom(from, to, baseAmount);
    }
}

/// @title AssetAdapterTest
/// @notice Comprehensive tests for asset adapters
contract AssetAdapterTest is Test {
    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    MockERC20 public token;
    MockRebasingToken public rebasingToken;
    StandardAssetAdapter public standardAdapter;
    RebasingAssetAdapter public rebasingAdapter;
    AssetAdapterFactory public factory;

    address public owner = makeAddr("owner");
    address public delegationManager = makeAddr("delegationManager");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public attacker = makeAddr("attacker");

    // ═══════════════════════════════════════════════════════════════════════════
    // SETUP
    // ═══════════════════════════════════════════════════════════════════════════

    function setUp() public {
        // Deploy tokens
        token = new MockERC20("Test Token", "TEST");
        rebasingToken = new MockRebasingToken();

        // Deploy adapters
        vm.startPrank(owner);
        standardAdapter = new StandardAssetAdapter(address(token), owner);
        standardAdapter.setDelegationManager(delegationManager);

        rebasingAdapter = new RebasingAssetAdapter(address(rebasingToken), owner);
        rebasingAdapter.setDelegationManager(delegationManager);

        factory = new AssetAdapterFactory(owner);
        factory.setDelegationManager(delegationManager);
        vm.stopPrank();

        // Fund users
        token.mint(user1, 1000 ether);
        token.mint(user2, 1000 ether);
        rebasingToken.mint(user1, 1000 ether);
        rebasingToken.mint(user2, 1000 ether);

        // Approve adapters
        vm.prank(user1);
        token.approve(address(standardAdapter), type(uint256).max);
        vm.prank(user2);
        token.approve(address(standardAdapter), type(uint256).max);

        vm.prank(user1);
        rebasingToken.approve(address(rebasingAdapter), type(uint256).max);
        vm.prank(user2);
        rebasingToken.approve(address(rebasingAdapter), type(uint256).max);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STANDARD ADAPTER - HAPPY PATH
    // ═══════════════════════════════════════════════════════════════════════════

    function test_StandardAdapter_Deposit_Success() public {
        vm.prank(delegationManager);
        uint256 shares = standardAdapter.deposit(user1, 100 ether);

        assertEq(shares, 100 ether, "Shares should equal amount for standard adapter");
        assertEq(standardAdapter.totalShares(), 100 ether, "Total shares should be updated");
        assertEq(token.balanceOf(address(standardAdapter)), 100 ether, "Adapter should hold tokens");
    }

    function test_StandardAdapter_Withdraw_Success() public {
        // Deposit first
        vm.prank(delegationManager);
        standardAdapter.deposit(user1, 100 ether);

        // Withdraw
        vm.prank(delegationManager);
        uint256 assets = standardAdapter.withdraw(user2, 50 ether);

        assertEq(assets, 50 ether, "Assets should equal shares for standard adapter");
        assertEq(standardAdapter.totalShares(), 50 ether, "Total shares should be reduced");
        assertEq(token.balanceOf(user2), 1050 ether, "User should receive tokens");
    }

    function test_StandardAdapter_MultipleDeposits() public {
        vm.startPrank(delegationManager);
        standardAdapter.deposit(user1, 100 ether);
        standardAdapter.deposit(user2, 200 ether);
        vm.stopPrank();

        assertEq(standardAdapter.totalShares(), 300 ether, "Total shares should be sum");
        assertEq(standardAdapter.totalAssets(), 300 ether, "Total assets should equal total shares");
    }

    function test_StandardAdapter_SharesToAssets_1to1() public view {
        assertEq(standardAdapter.sharesToAssets(100 ether), 100 ether, "1:1 conversion");
        assertEq(standardAdapter.assetsToShares(100 ether), 100 ether, "1:1 conversion");
    }

    function test_StandardAdapter_PreviewFunctions() public view {
        assertEq(standardAdapter.previewDeposit(100 ether), 100 ether, "Preview deposit 1:1");
        assertEq(standardAdapter.previewWithdraw(100 ether), 100 ether, "Preview withdraw 1:1");
    }

    function test_StandardAdapter_SupportsAsset() public view {
        assertTrue(standardAdapter.supportsAsset(address(token)), "Should support its asset");
        assertFalse(standardAdapter.supportsAsset(address(rebasingToken)), "Should not support other assets");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STANDARD ADAPTER - ERROR CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_StandardAdapter_Deposit_ZeroAmount() public {
        vm.prank(delegationManager);
        vm.expectRevert(IAssetAdapter.ZeroAmount.selector);
        standardAdapter.deposit(user1, 0);
    }

    function test_StandardAdapter_Deposit_ZeroAddress() public {
        vm.prank(delegationManager);
        vm.expectRevert(IAssetAdapter.ZeroAddress.selector);
        standardAdapter.deposit(address(0), 100 ether);
    }

    function test_StandardAdapter_Withdraw_ZeroShares() public {
        vm.prank(delegationManager);
        vm.expectRevert(IAssetAdapter.ZeroShares.selector);
        standardAdapter.withdraw(user1, 0);
    }

    function test_StandardAdapter_Withdraw_ZeroAddress() public {
        vm.prank(delegationManager);
        standardAdapter.deposit(user1, 100 ether);

        vm.prank(delegationManager);
        vm.expectRevert(IAssetAdapter.ZeroAddress.selector);
        standardAdapter.withdraw(address(0), 50 ether);
    }

    function test_StandardAdapter_Withdraw_InsufficientAssets() public {
        vm.prank(delegationManager);
        standardAdapter.deposit(user1, 100 ether);

        vm.prank(delegationManager);
        vm.expectRevert(IAssetAdapter.InsufficientAssets.selector);
        standardAdapter.withdraw(user1, 200 ether);
    }

    function test_StandardAdapter_OnlyDelegationManager() public {
        vm.prank(attacker);
        vm.expectRevert(StandardAssetAdapter.OnlyDelegationManager.selector);
        standardAdapter.deposit(user1, 100 ether);

        vm.prank(attacker);
        vm.expectRevert(StandardAssetAdapter.OnlyDelegationManager.selector);
        standardAdapter.withdraw(user1, 100 ether);
    }

    function test_StandardAdapter_Constructor_ZeroAddress() public {
        vm.expectRevert(IAssetAdapter.ZeroAddress.selector);
        new StandardAssetAdapter(address(0), owner);
    }

    function test_StandardAdapter_SetDelegationManager_ZeroAddress() public {
        StandardAssetAdapter newAdapter = new StandardAssetAdapter(address(token), owner);

        vm.prank(owner);
        vm.expectRevert(IAssetAdapter.ZeroAddress.selector);
        newAdapter.setDelegationManager(address(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REBASING ADAPTER - HAPPY PATH
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RebasingAdapter_Deposit_Success() public {
        vm.prank(delegationManager);
        uint256 shares = rebasingAdapter.deposit(user1, 100 ether);

        // First deposit: shares = amount * INITIAL_SHARES_PER_ASSET (1e18)
        assertEq(shares, 100 ether * 1e18, "Initial shares calculation");
        assertEq(rebasingAdapter.totalShares(), shares, "Total shares updated");
    }

    function test_RebasingAdapter_Withdraw_Success() public {
        vm.prank(delegationManager);
        uint256 shares = rebasingAdapter.deposit(user1, 100 ether);

        vm.prank(delegationManager);
        uint256 assets = rebasingAdapter.withdraw(user2, shares);

        assertEq(assets, 100 ether, "Should withdraw full amount");
        assertEq(rebasingAdapter.totalShares(), 0, "Shares should be zero");
    }

    function test_RebasingAdapter_RebaseIncreasesValue() public {
        // User deposits 100 tokens
        vm.prank(delegationManager);
        uint256 shares = rebasingAdapter.deposit(user1, 100 ether);

        // Token rebases by 10%
        rebasingToken.rebase(1000); // 10% = 1000 bps

        // User's shares should now be worth 110 tokens
        uint256 value = rebasingAdapter.sharesToAssets(shares);
        assertEq(value, 110 ether, "Value should increase with rebase");

        // Withdraw should give 110 tokens
        vm.prank(delegationManager);
        uint256 withdrawn = rebasingAdapter.withdraw(user2, shares);
        assertEq(withdrawn, 110 ether, "Should withdraw rebased amount");
    }

    function test_RebasingAdapter_MultipleDepositorsWithRebase() public {
        // User1 deposits 100 tokens
        vm.prank(delegationManager);
        uint256 shares1 = rebasingAdapter.deposit(user1, 100 ether);

        // Rebase by 10%
        rebasingToken.rebase(1000);

        // User2 deposits 110 tokens (same value as user1's rebased position)
        vm.prank(delegationManager);
        uint256 shares2 = rebasingAdapter.deposit(user2, 110 ether);

        // Both users should have equal shares (proportional to pool)
        // User1's 100 tokens (now worth 110) vs User2's 110 tokens
        assertApproxEqRel(shares1, shares2, 0.01e18, "Shares should be approximately equal");

        // After another 10% rebase, both should have equal withdrawable value
        rebasingToken.rebase(1000);

        uint256 value1 = rebasingAdapter.sharesToAssets(shares1);
        uint256 value2 = rebasingAdapter.sharesToAssets(shares2);
        assertApproxEqRel(value1, value2, 0.01e18, "Values should be approximately equal");
    }

    function test_RebasingAdapter_ExchangeRate() public {
        vm.prank(delegationManager);
        rebasingAdapter.deposit(user1, 100 ether);

        // Initial exchange rate should be 1:1 (scaled by PRECISION)
        uint256 rate = rebasingAdapter.exchangeRate();
        assertApproxEqRel(rate, 1e18, 0.01e18, "Initial rate should be ~1e18");

        // After 10% rebase, rate should increase
        rebasingToken.rebase(1000);
        uint256 newRate = rebasingAdapter.exchangeRate();
        assertApproxEqRel(newRate, 1.1e18, 0.01e18, "Rate should increase by 10%");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REBASING ADAPTER - ERROR CASES
    // ═══════════════════════════════════════════════════════════════════════════

    function test_RebasingAdapter_Deposit_ZeroAmount() public {
        vm.prank(delegationManager);
        vm.expectRevert(IAssetAdapter.ZeroAmount.selector);
        rebasingAdapter.deposit(user1, 0);
    }

    function test_RebasingAdapter_Withdraw_InsufficientAssets() public {
        vm.prank(delegationManager);
        uint256 shares = rebasingAdapter.deposit(user1, 100 ether);

        vm.prank(delegationManager);
        vm.expectRevert(IAssetAdapter.InsufficientAssets.selector);
        rebasingAdapter.withdraw(user1, shares + 1);
    }

    function test_RebasingAdapter_OnlyDelegationManager() public {
        vm.prank(attacker);
        vm.expectRevert(RebasingAssetAdapter.OnlyDelegationManager.selector);
        rebasingAdapter.deposit(user1, 100 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FACTORY TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Factory_DeployStandardAdapter() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW");

        vm.prank(owner);
        address adapter = factory.deployStandardAdapter(address(newToken));

        assertTrue(adapter != address(0), "Adapter should be deployed");
        assertEq(factory.tokenToAdapter(address(newToken)), adapter, "Should be registered");
        assertTrue(IAssetAdapter(adapter).supportsAsset(address(newToken)), "Should support token");
    }

    function test_Factory_DeployRebasingAdapter() public {
        MockRebasingToken newToken = new MockRebasingToken();

        vm.prank(owner);
        address adapter = factory.deployAdapter(address(newToken), AssetAdapterFactory.AdapterType.Rebasing);

        assertTrue(adapter != address(0), "Adapter should be deployed");
        assertEq(factory.tokenToAdapter(address(newToken)), adapter, "Should be registered");
    }

    function test_Factory_AdapterAlreadyExists() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW");

        vm.prank(owner);
        factory.deployStandardAdapter(address(newToken));

        vm.prank(owner);
        vm.expectRevert(abi.encodeWithSelector(AssetAdapterFactory.AdapterAlreadyExists.selector, address(newToken)));
        factory.deployStandardAdapter(address(newToken));
    }

    function test_Factory_GetAdapter() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW");

        vm.prank(owner);
        address deployed = factory.deployStandardAdapter(address(newToken));

        assertEq(factory.getAdapter(address(newToken)), deployed, "Should return adapter");
        assertTrue(factory.hasAdapter(address(newToken)), "Should have adapter");
        assertFalse(factory.hasAdapter(address(token)), "Should not have adapter for unregistered token");
    }

    function test_Factory_RegisterExternalAdapter() public {
        MockERC20 newToken = new MockERC20("New Token", "NEW");
        StandardAssetAdapter externalAdapter = new StandardAssetAdapter(address(newToken), owner);

        vm.prank(owner);
        factory.registerAdapter(address(newToken), address(externalAdapter));

        assertEq(factory.tokenToAdapter(address(newToken)), address(externalAdapter), "Should be registered");
    }

    function test_Factory_AdapterCount() public {
        assertEq(factory.adapterCount(), 0, "Initial count should be 0");

        MockERC20 token1 = new MockERC20("Token 1", "T1");
        MockERC20 token2 = new MockERC20("Token 2", "T2");

        vm.startPrank(owner);
        factory.deployStandardAdapter(address(token1));
        factory.deployStandardAdapter(address(token2));
        vm.stopPrank();

        assertEq(factory.adapterCount(), 2, "Count should be 2");
    }

    function test_Factory_DelegationManagerNotSet() public {
        AssetAdapterFactory newFactory = new AssetAdapterFactory(owner);
        // Don't set delegation manager

        vm.prank(owner);
        vm.expectRevert(AssetAdapterFactory.DelegationManagerNotSet.selector);
        newFactory.deployStandardAdapter(address(token));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_StandardAdapter_DepositWithdraw(uint256 amount) public {
        amount = bound(amount, 1, 500 ether); // Bound to reasonable range

        vm.prank(delegationManager);
        uint256 shares = standardAdapter.deposit(user1, amount);

        vm.prank(delegationManager);
        uint256 withdrawn = standardAdapter.withdraw(user2, shares);

        assertEq(withdrawn, amount, "Should withdraw same amount");
    }

    function testFuzz_RebasingAdapter_RebaseAndWithdraw(uint256 amount, uint256 rebaseBps) public {
        amount = bound(amount, 1 ether, 500 ether);
        rebaseBps = bound(rebaseBps, 0, 5000); // 0-50% rebase

        vm.prank(delegationManager);
        uint256 shares = rebasingAdapter.deposit(user1, amount);

        rebasingToken.rebase(rebaseBps);

        uint256 expectedValue = (amount * (10000 + rebaseBps)) / 10000;

        vm.prank(delegationManager);
        uint256 withdrawn = rebasingAdapter.withdraw(user2, shares);

        assertApproxEqRel(withdrawn, expectedValue, 0.01e18, "Should withdraw rebased amount");
    }
}
