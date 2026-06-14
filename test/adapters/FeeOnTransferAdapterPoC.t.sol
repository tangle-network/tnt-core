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

    function test_FeeOnTransfer_OverCreditsShares_And_BricksLastWithdrawer() public {
        // Alice deposits 100; adapter credits 100 shares but only receives 99.
        vm.prank(delegationManager);
        uint256 aliceShares = adapter.deposit(alice, 100 ether);

        vm.prank(delegationManager);
        uint256 bobShares = adapter.deposit(bob, 100 ether);

        // INVARIANT VIOLATION: shares credited (200) exceed assets actually held (198).
        assertEq(aliceShares, 100 ether, "alice over-credited");
        assertEq(bobShares, 100 ether, "bob over-credited");
        assertEq(adapter.totalShares(), 200 ether, "totalShares = 200");
        assertEq(token.balanceOf(address(adapter)), 198 ether, "pool only holds 198");

        // Alice withdraws her full 100 shares first -> adapter sends 100, leaving 98.
        vm.prank(delegationManager);
        adapter.withdraw(alice, 100 ether);
        assertEq(token.balanceOf(address(adapter)), 98 ether, "pool now holds 98");

        // Bob tries to withdraw his 100 shares but the pool is insolvent: only 98 held.
        // The transfer reverts -> Bob's stake is permanently locked (DoS).
        vm.prank(delegationManager);
        vm.expectRevert(); // ERC20 balance underflow inside FeeToken._move
        adapter.withdraw(bob, 100 ether);
    }
}
