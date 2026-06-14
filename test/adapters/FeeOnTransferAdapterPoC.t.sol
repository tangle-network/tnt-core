// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { StandardAssetAdapter } from "../../src/staking/adapters/StandardAssetAdapter.sol";

/// @notice Minimal 1%-fee-on-transfer ERC20 (USDT-fee-switch style).
contract FeeToken {
    string public name = "Fee";
    string public symbol = "FEE";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 constant FEE_BPS = 100; // 1%

    function mint(address to, uint256 amt) external {
        balanceOf[to] += amt;
        totalSupply += amt;
    }

    function approve(address s, uint256 a) external returns (bool) {
        allowance[msg.sender][s] = a;
        return true;
    }

    function _move(address from, address to, uint256 amt) internal {
        require(balanceOf[from] >= amt, "bal");
        uint256 fee = (amt * FEE_BPS) / 10_000;
        uint256 net = amt - fee;
        balanceOf[from] -= amt;
        balanceOf[to] += net; // fee burned
        totalSupply -= fee;
    }

    function transfer(address to, uint256 amt) external returns (bool) {
        _move(msg.sender, to, amt);
        return true;
    }

    function transferFrom(address from, address to, uint256 amt) external returns (bool) {
        uint256 a = allowance[from][msg.sender];
        require(a >= amt, "allow");
        if (a != type(uint256).max) allowance[from][msg.sender] = a - amt;
        _move(from, to, amt);
        return true;
    }
}

contract FeeOnTransferAdapterPoC is Test {
    StandardAssetAdapter adapter;
    FeeToken token;

    address owner = address(0xA11CE);
    address delegationManager = address(0xD11);
    address alice = address(0xA1);
    address bob = address(0xB0B);

    function setUp() public {
        token = new FeeToken();
        adapter = new StandardAssetAdapter(address(token), owner);
        vm.prank(owner);
        adapter.setDelegationManager(delegationManager);

        token.mint(alice, 100 ether);
        token.mint(bob, 100 ether);
        vm.prank(alice);
        token.approve(address(adapter), type(uint256).max);
        vm.prank(bob);
        token.approve(address(adapter), type(uint256).max);
    }

    /// @notice Regression guard: the adapter must credit shares against tokens ACTUALLY
    ///         received (balance delta), never the requested amount. With a 1%
    ///         fee-on-transfer token a 100e18 deposit lands 99e18 in custody, so exactly
    ///         99e18 shares are minted. This keeps `totalShares == adapter balance`, so the
    ///         pool stays solvent and EVERY depositor — including the last withdrawer — can
    ///         redeem in full without reverting. If the adapter ever reverts to crediting
    ///         the requested `assets` (100e18) instead of `received` (99e18), totalShares
    ///         would exceed custody and the assertions below would fail.
    function test_FeeOnTransfer_CreditsActualReceivedShares_And_PoolStaysSolvent() public {
        // Alice deposits 100; the 1% fee means only 99 lands in custody, so 99 shares mint.
        vm.prank(delegationManager);
        uint256 aliceShares = adapter.deposit(alice, 100 ether);

        vm.prank(delegationManager);
        uint256 bobShares = adapter.deposit(bob, 100 ether);

        // SOLVENCY INVARIANT: shares credited == tokens actually held (no over-crediting).
        assertEq(aliceShares, 99 ether, "alice credited actual received (99), not requested (100)");
        assertEq(bobShares, 99 ether, "bob credited actual received (99), not requested (100)");
        assertEq(adapter.totalShares(), 198 ether, "totalShares == sum of received");
        assertEq(token.balanceOf(address(adapter)), 198 ether, "pool holds exactly totalShares (solvent)");
        assertEq(
            adapter.totalShares(),
            token.balanceOf(address(adapter)),
            "INVARIANT: totalShares never exceeds custody"
        );

        // Alice withdraws her full 99 shares first -> adapter releases 99, pool drops to 99.
        vm.prank(delegationManager);
        adapter.withdraw(alice, 99 ether);
        assertEq(token.balanceOf(address(adapter)), 99 ether, "pool holds 99 after first withdrawal");

        // Bob (the LAST withdrawer) redeems his 99 shares: the pool holds exactly 99, so the
        // transfer succeeds — no DoS, no bricked stake. The pool fully drains to 0.
        vm.prank(delegationManager);
        adapter.withdraw(bob, 99 ether);
        assertEq(token.balanceOf(address(adapter)), 0, "pool fully drained; last withdrawer not bricked");
        assertEq(adapter.totalShares(), 0, "all shares redeemed");
    }
}
