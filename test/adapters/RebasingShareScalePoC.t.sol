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

    /// F-003 (FIXED): the symmetric virtual offset (VIRTUAL_SHARES == VIRTUAL_ASSETS == 1e8)
    /// makes shares TOKEN-DENOMINATED 1:1 on bootstrap. A fresh-pool deposit of 1 token
    /// (1e18 wei) now mints exactly 1e18 shares — not the old 1e26 (1e8x) — so the share
    /// count consumed downstream as the delegation `amount` and fed to oracle.toUSD()
    /// stays raw-token-wei accurate. Regression guard: any reintroduced asymmetric offset
    /// (e.g. 1e8/1) would mint 1e26 here and trip these assertions.
    function test_RebasingDeposit_Mints_1To1_TokenWei() public {
        uint256 oneToken = 1 ether; // 1e18 wei
        vm.prank(dm);
        uint256 shares = adapter.deposit(alice, oneToken);

        // shares = 1e18 * (0 + 1e8) / (0 + 1e8) = 1e18  == token wei, 1:1 (no 1e8 inflation)
        assertEq(shares, oneToken, "first deposit mints 1:1 token wei (no 1e8 inflation)");
        assertEq(adapter.totalShares(), oneToken, "totalShares equals deposited token wei");
    }

    /// F-004 (FIXED): previewDeposit / assetsToShares now use the SAME symmetric offset
    /// formula as deposit, so the preview agrees exactly with the shares actually minted
    /// (bootstrap: assets * VS / VA == assets). No 1e10 disagreement. Regression guard:
    /// the divergence (preview = assets*1e18 vs mint = assets*1e8) reappears the moment the
    /// offsets are made asymmetric again.
    function test_PreviewDeposit_Agrees_With_Deposit() public {
        uint256 oneToken = 1 ether;
        uint256 previewed = adapter.previewDeposit(oneToken);
        // bootstrap preview is token-denominated 1:1
        assertEq(previewed, oneToken, "preview is token-denominated 1:1 (no 1e10 inflation)");

        vm.prank(dm);
        uint256 minted = adapter.deposit(alice, oneToken);
        // preview must equal what deposit actually mints — agreement, not 1e10 skew
        assertEq(previewed, minted, "previewDeposit agrees with deposit() exactly");
    }
}
