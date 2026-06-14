// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { RebasingAssetAdapter } from "../../src/staking/adapters/RebasingAssetAdapter.sol";

contract PlainToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 a) external {
        balanceOf[to] += a;
    }

    function approve(address s, uint256 a) external returns (bool) {
        allowance[msg.sender][s] = a;
        return true;
    }

    function transfer(address to, uint256 a) external returns (bool) {
        balanceOf[msg.sender] -= a;
        balanceOf[to] += a;
        return true;
    }

    function transferFrom(address f, address t, uint256 a) external returns (bool) {
        uint256 al = allowance[f][msg.sender];
        if (al != type(uint256).max) allowance[f][msg.sender] = al - a;
        balanceOf[f] -= a;
        balanceOf[t] += a;
        return true;
    }
}

contract RebasingShareScalePoC is Test {
    RebasingAssetAdapter adapter;
    PlainToken token;
    address owner = address(0xA11CE);
    address dm = address(0xD11);
    address alice = address(0xA1);

    function setUp() public {
        token = new PlainToken();
        adapter = new RebasingAssetAdapter(address(token), owner);
        vm.prank(owner);
        adapter.setDelegationManager(dm);
        token.mint(alice, 1000 ether);
        vm.prank(alice);
        token.approve(address(adapter), type(uint256).max);
    }

    /// F-003: a fresh-pool deposit of 1 token (1e18 wei) mints ~1e8x that in shares.
    /// These shares become the delegation-layer "amount" that the oracle USD-exposure
    /// path (PaymentsEffectiveExposure) treats as raw TOKEN wei -> 1e8x over-weighting.
    function test_RebasingDeposit_Mints_1e8x_TokenWei() public {
        uint256 oneToken = 1 ether; // 1e18 wei
        vm.prank(dm);
        uint256 shares = adapter.deposit(alice, oneToken);

        // shares = 1e18 * (0 + 1e8) / (0 + 1) = 1e26  == 1e8 * tokenWei
        assertEq(shares, oneToken * 1e8, "first deposit minted 1e8x token wei");
        assertEq(adapter.totalShares(), shares, "totalShares scaled 1e8x");
    }

    /// F-004: previewDeposit / assetsToShares disagree with the actual deposit by 1e10x
    /// on the bootstrap (returns assets*1e18 instead of assets*1e8).
    function test_PreviewDeposit_Disagrees_By_1e10() public view {
        uint256 oneToken = 1 ether;
        uint256 previewed = adapter.previewDeposit(oneToken); // assets * 1e18
        uint256 actualMintScale = oneToken * 1e8; // what deposit() would mint
        assertEq(previewed, oneToken * 1e18, "preview returns 1e18x");
        assertEq(previewed / actualMintScale, 1e10, "preview overstates deposit by 1e10x");
    }
}
