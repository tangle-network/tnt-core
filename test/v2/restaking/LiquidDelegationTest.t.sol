// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { MultiAssetDelegation } from "../../../src/v2/restaking/MultiAssetDelegation.sol";
import { LiquidDelegationVault } from "../../../src/v2/restaking/LiquidDelegationVault.sol";
import { LiquidDelegationFactory } from "../../../src/v2/restaking/LiquidDelegationFactory.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";

/// @notice Mock ERC20 token for testing
contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MOCK") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

/// @title LiquidDelegationTest
/// @notice Tests for ERC7540 liquid delegation vaults
contract LiquidDelegationTest is Test {
    MultiAssetDelegation public restaking;
    LiquidDelegationFactory public factory;
    MockERC20 public token;

    // Test accounts
    address public admin = makeAddr("admin");
    address public slasher = makeAddr("slasher");
    address public operator1 = makeAddr("operator1");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");
    address public user3 = makeAddr("user3");

    // Constants
    uint256 constant MIN_OPERATOR_STAKE = 1 ether;

    function setUp() public {
        // Deploy mock token
        token = new MockERC20();

        // Deploy restaking (proxy pattern)
        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, MIN_OPERATOR_STAKE, 0, 1000) // 10% commission
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        restaking = MultiAssetDelegation(payable(address(proxy)));

        // Enable mock token as asset
        vm.prank(admin);
        restaking.enableAsset(address(token), 1 ether, 0.1 ether, 0, 10000);

        // Deploy factory
        factory = new LiquidDelegationFactory(restaking);

        // Grant slasher role
        vm.prank(admin);
        restaking.addSlasher(slasher);

        // Fund accounts
        vm.deal(operator1, 100 ether);
        token.mint(user1, 100 ether);
        token.mint(user2, 100 ether);
        token.mint(user3, 100 ether);

        // Register operator
        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FACTORY TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Factory_CreateVault_AllBlueprints() public {
        address vault = factory.createAllBlueprintsVault(operator1, address(token));

        assertTrue(vault != address(0), "Vault should be created");
        assertEq(factory.vaultCount(), 1, "Should have 1 vault");

        LiquidDelegationVault v = LiquidDelegationVault(payable(vault));
        assertEq(v.operator(), operator1, "Vault operator should match");
        assertEq(address(v.asset()), address(token), "Vault asset should match");
    }

    function test_AllBlueprintsVault_IsDynamicAndReceivesFutureBlueprintRewards() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        vm.stopPrank();

        assertEq(
            uint8(vault.selectionMode()),
            uint8(Types.BlueprintSelectionMode.All),
            "Vault should be All mode"
        );
        assertEq(vault.blueprintIds().length, 0, "All mode: no stored blueprint IDs");

        Types.BondInfoDelegator[] memory delegations = restaking.getDelegations(vaultAddr);
        assertEq(delegations.length, 1, "Vault should have 1 delegation");
        assertEq(delegations[0].operator, operator1, "Delegation operator mismatch");
        assertEq(
            uint8(delegations[0].selectionMode),
            uint8(Types.BlueprintSelectionMode.All),
            "Restaking delegation should be All mode"
        );

        uint64[] memory delegationBlueprints = restaking.getDelegationBlueprints(vaultAddr, 0);
        assertEq(delegationBlueprints.length, 0, "All mode: restaking stores no blueprint IDs");

        uint64 futureBlueprintId = 999;
        vm.prank(operator1);
        restaking.addBlueprint(futureBlueprintId);

        restaking.notifyRewardForBlueprint(operator1, futureBlueprintId, 0, 1 ether);
        assertGt(
            restaking.getPendingDelegatorRewards(vaultAddr),
            0,
            "All mode should receive rewards from future blueprints"
        );
    }

    function test_Factory_CreateVault_FixedBlueprints() public {
        uint64[] memory bps = new uint64[](2);
        bps[0] = 1;
        bps[1] = 2;

        address vault = factory.createVault(operator1, address(token), bps);

        LiquidDelegationVault v = LiquidDelegationVault(payable(vault));
        uint64[] memory storedBps = v.blueprintIds();

        assertEq(storedBps.length, 2, "Should have 2 blueprints");
        assertEq(storedBps[0], 1, "First blueprint should be 1");
        assertEq(storedBps[1], 2, "Second blueprint should be 2");
    }

    function test_Factory_CannotCreateDuplicateVault() public {
        factory.createAllBlueprintsVault(operator1, address(token));

        vm.expectRevert(LiquidDelegationFactory.VaultAlreadyExists.selector);
        factory.createAllBlueprintsVault(operator1, address(token));
    }

    function test_Factory_DifferentBlueprintsAreDifferentVaults() public {
        uint64[] memory bps1 = new uint64[](1);
        bps1[0] = 1;
        uint64[] memory bps2 = new uint64[](1);
        bps2[0] = 2;

        address vault1 = factory.createVault(operator1, address(token), bps1);
        address vault2 = factory.createVault(operator1, address(token), bps2);
        address vault3 = factory.createAllBlueprintsVault(operator1, address(token));

        assertTrue(vault1 != vault2, "BP1 and BP2 vaults should differ");
        assertTrue(vault2 != vault3, "BP2 and All vaults should differ");
        assertTrue(vault1 != vault3, "BP1 and All vaults should differ");

        assertEq(factory.vaultCount(), 3, "Should have 3 vaults");
    }

    function test_Factory_GetOperatorVaults() public {
        factory.createAllBlueprintsVault(operator1, address(token));

        uint64[] memory bps = new uint64[](1);
        bps[0] = 1;
        factory.createVault(operator1, address(token), bps);

        address[] memory vaults = factory.getOperatorVaults(operator1);
        assertEq(vaults.length, 2, "Operator should have 2 vaults");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPOSIT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Vault_Deposit_MintsShares() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        uint256 depositAmount = 10 ether;

        vm.startPrank(user1);
        token.approve(address(vault), depositAmount);
        uint256 shares = vault.deposit(depositAmount, user1);
        vm.stopPrank();

        assertEq(shares, depositAmount, "First deposit: shares should equal amount");
        assertEq(vault.balanceOf(user1), depositAmount, "User1 should have shares");
    }

    function test_Vault_Deposit_MultipleUsers() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits 10 ETH
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        vm.stopPrank();

        // User2 deposits 20 ETH
        vm.startPrank(user2);
        token.approve(address(vault), 20 ether);
        vault.deposit(20 ether, user2);
        vm.stopPrank();

        assertEq(vault.balanceOf(user1), 10 ether, "User1 should have 10 shares");
        assertEq(vault.balanceOf(user2), 20 ether, "User2 should have 20 shares");
        assertEq(vault.totalSupply(), 30 ether, "Total supply should be 30");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARE TRANSFER TESTS (LIQUIDITY)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Vault_SharesAreTransferable() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);

        // User1 transfers to User2
        vault.transfer(user2, 5 ether);
        vm.stopPrank();

        assertEq(vault.balanceOf(user1), 5 ether, "User1 should have 5 shares");
        assertEq(vault.balanceOf(user2), 5 ether, "User2 should have 5 shares");
    }

    function test_Vault_SharesAreApproveableAndTransferable() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);

        // User1 approves User2
        vault.approve(user2, 5 ether);
        vm.stopPrank();

        // User2 transfers from User1
        vm.prank(user2);
        vault.transferFrom(user1, user3, 5 ether);

        assertEq(vault.balanceOf(user1), 5 ether, "User1 should have 5 shares");
        assertEq(vault.balanceOf(user3), 5 ether, "User3 should have 5 shares");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ASYNC REDEMPTION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Vault_RequestRedeem_CreatesRequest() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);

        // Request redemption
        uint256 requestId = vault.requestRedeem(5 ether, user1, user1);
        vm.stopPrank();

        assertEq(requestId, 0, "First request should have ID 0");
        assertEq(vault.balanceOf(user1), 5 ether, "User1 should have 5 shares left (burned 5)");

        // Check pending
        uint256 pending = vault.pendingRedeemRequest(requestId, user1);
        assertEq(pending, 5 ether, "Should have 5 shares pending");

        // Not yet claimable
        uint256 claimable = vault.claimableRedeemRequest(requestId, user1);
        assertEq(claimable, 0, "Should not be claimable yet");
    }

    function test_Vault_RequestBecomeClaimable_AfterDelay() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);

        // Request redemption
        uint256 requestId = vault.requestRedeem(5 ether, user1, user1);
        vm.stopPrank();

        // Initially not claimable
        uint256 claimable = vault.claimableRedeemRequest(requestId, user1);
        assertEq(claimable, 0, "Should not be claimable initially");

        // Advance rounds
        uint64 delay = uint64(restaking.delegationBondLessDelay());
        for (uint64 i = 0; i <= delay; i++) {
            restaking.advanceRound();
        }

        // Now should be claimable
        claimable = vault.claimableRedeemRequest(requestId, user1);
        assertEq(claimable, 5 ether, "Should be claimable after delay");

        // Pending should be 0 (moved to claimable)
        uint256 pending = vault.pendingRedeemRequest(requestId, user1);
        assertEq(pending, 0, "Should not be pending anymore");

        // Note: Full redeem claim requires additional withdrawal flow
        // which is out of scope for this MVP test
    }

    function test_Vault_SyncWithdrawReverts() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);

        // Sync withdraw should revert
        vm.expectRevert(LiquidDelegationVault.AsyncRequired.selector);
        vault.withdraw(5 ether, user1, user1);
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING IMPACT TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Vault_SlashingReducesShareValue() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits 10 ETH
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        vm.stopPrank();

        // Check initial value
        uint256 valueBeforeSlash = vault.convertToAssets(vault.balanceOf(user1));
        assertEq(valueBeforeSlash, 10 ether, "Initial value should be 10 ETH");

        // Slash operator (10% of total = 10% of 20 ETH = 2 ETH)
        // Operator stake: 10 ETH, Vault delegation: 10 ETH
        // Slash 2 ETH: 1 ETH from operator, 1 ETH from delegated
        vm.prank(slasher);
        restaking.slash(operator1, 0, 2 ether, keccak256("evidence"));

        // Check value after slash - should be reduced
        uint256 valueAfterSlash = vault.convertToAssets(vault.balanceOf(user1));
        assertTrue(valueAfterSlash < valueBeforeSlash, "Value should be reduced after slash");
    }

    function test_Vault_NewDepositorGetsFewerSharesAfterSlash() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits 10 ETH
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        vm.stopPrank();

        uint256 user1Shares = vault.balanceOf(user1);

        // Slash 2 ETH
        vm.prank(slasher);
        restaking.slash(operator1, 0, 2 ether, keccak256("evidence"));

        // User2 deposits same 10 ETH - should get MORE shares (assets depreciated)
        vm.startPrank(user2);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user2);
        vm.stopPrank();

        uint256 user2Shares = vault.balanceOf(user2);

        // User2 should have more shares for same deposit (since each share worth less)
        assertTrue(user2Shares > user1Shares, "User2 should get more shares after slash");
    }

    function test_Vault_MintSlashRedeemScenario() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 mints exact shares
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        uint256 assetsIn = vault.mint(10 ether, user1);
        vm.stopPrank();

        assertEq(assetsIn, 10 ether, "Mint should pull 10 assets");
        assertEq(vault.balanceOf(user1), 10 ether, "User should hold minted shares");

        // Slash operator to reduce backing assets
        vm.prank(slasher);
        restaking.slash(operator1, 0, 4 ether, keccak256("evidence"));

        uint256 sharesToRedeem = vault.balanceOf(user1);
        uint256 expectedAssets = vault.convertToAssets(sharesToRedeem);
        assertLt(expectedAssets, sharesToRedeem, "Slash should devalue shares");

        // Request redeem (burning shares and scheduling unstake)
        vm.startPrank(user1);
        uint256 requestId = vault.requestRedeem(sharesToRedeem, user1, user1);
        vm.stopPrank();

        assertEq(requestId, 0, "First request id");
        assertEq(vault.balanceOf(user1), 0, "Shares burned during request");

        // Wait out the bond-less delay
        uint64 delay = uint64(restaking.delegationBondLessDelay());
        for (uint64 i = 0; i <= delay; i++) {
            restaking.advanceRound();
        }

        assertEq(vault.claimableRedeemRequest(requestId, user1), sharesToRedeem, "Entire request becomes claimable");

        uint256 tokenBalanceBefore = token.balanceOf(user1);
        vm.startPrank(user1);
        uint256 assetsOut = vault.redeem(sharesToRedeem, user1, user1);
        vm.stopPrank();

        assertEq(token.balanceOf(user1), tokenBalanceBefore + assetsOut, "Return value matches transferred assets");
        assertEq(vault.totalAssets(), 0, "All delegation should be exited after redeem");
        assertEq(restaking.getDelegation(address(vault), operator1), 0, "Underlying delegation removed");

        // Subsequent redeem attempts should fail since request is consumed
        vm.startPrank(user1);
        vm.expectRevert(LiquidDelegationVault.NotClaimable.selector);
        vault.redeem(sharesToRedeem, user1, user1);
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR PERMISSION TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Vault_OperatorCanRequestOnBehalf() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);

        // Approve user2 as operator
        vault.setOperator(user2, true);
        vm.stopPrank();

        // User2 can request on behalf of user1
        vm.prank(user2);
        uint256 requestId = vault.requestRedeem(5 ether, user1, user1);

        assertEq(requestId, 0, "Request should be created");
        assertEq(vault.balanceOf(user1), 5 ether, "User1 should have 5 shares left");
    }

    function test_Vault_NonOperatorCannotRequestOnBehalf() public {
        address vaultAddr = factory.createAllBlueprintsVault(operator1, address(token));
        LiquidDelegationVault vault = LiquidDelegationVault(payable(vaultAddr));

        // User1 deposits
        vm.startPrank(user1);
        token.approve(address(vault), 10 ether);
        vault.deposit(10 ether, user1);
        vm.stopPrank();

        // User2 (not approved) tries to request
        vm.prank(user2);
        vm.expectRevert(LiquidDelegationVault.NotController.selector);
        vault.requestRedeem(5 ether, user1, user1);
    }
}
