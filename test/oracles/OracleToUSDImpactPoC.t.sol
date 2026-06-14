// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import {
    UniswapV3Oracle,
    IUniswapV3Pool,
    AggregatorV3Interface as QuoteAggregator,
    IERC20Decimals as IERC20DecimalsUniswap
} from "../../src/oracles/UniswapV3Oracle.sol";

contract Agg is QuoteAggregator {
    uint8 d; int256 a; uint256 u;
    constructor(uint8 _d){ d=_d; }
    function setData(int256 _a, uint256 _u) external { a=_a; u=_u; }
    function decimals() external view override returns (uint8){ return d; }
    function latestRoundData() external view override returns (uint80,int256,uint256,uint256,uint80){ return (1,a,0,u,1); }
}
contract Tok is IERC20DecimalsUniswap { uint8 immutable d; constructor(uint8 _d){d=_d;} function decimals() external view override returns(uint8){return d;} }
contract Pool is IUniswapV3Pool {
    address immutable t0; address immutable t1; int24 tick;
    constructor(address a,address b){t0=a;t1=b;}
    function setTick(int24 t) external { tick=t; }
    function slot0() external pure override returns(uint160,int24,uint16,uint16,uint16,uint8,bool){return(0,0,0,0,0,0,true);}
    function observe(uint32[] calldata s) external view override returns(int56[] memory tc,uint160[] memory sl){
        tc=new int56[](s.length); sl=new uint160[](s.length); tc[1]=int56(tick)*int56(uint56(s[0]));
    }
    function token0() external view override returns(address){return t0;}
    function token1() external view override returns(address){return t1;}
}

contract OracleToUSDImpactPoC is Test {
    function setUp() public { vm.warp(1_000_000); }

    // Protocol calls oracle.toUSD(token, amount) in Slashing/Exposure/Rewards.
    // Regression: WETH as token0 (18dp) priced against a 6dp quote must NOT round to
    // $0. A $0 valuation would let WETH-denominated exposure escape slashing and
    // exposure weighting entirely. The fixed oracle returns a non-zero ~3290e18 USD
    // value for 1 WETH at this tick.
    function test_toUSD_WethToken0_ValuesOneEthNonZero() public {
        Tok weth = new Tok(18); Tok usdc = new Tok(6);
        Pool pool = new Pool(address(weth), address(usdc));
        pool.setTick(-195_331); // ~3000 USDC/WETH
        UniswapV3Oracle o = new UniswapV3Oracle(address(weth));
        o.configurePool(address(weth), address(pool), address(0), true);
        uint256 usd = o.toUSD(address(weth), 1e18); // value of 1 WETH
        emit log_named_uint("toUSD(1 WETH)", usd);
        // Exact value the corrected decimal handling produces for 1 WETH at tick
        // -195_331 (~3290.84 USDC/WETH, normalized to 18dp). Asserting the exact
        // value (not just != 0) keeps this a tight regression guard: any reintroduced
        // decimal-truncation bug that collapses the price toward $0 fails here.
        assertEq(usd, 3290838603000000000000, "1 WETH must be valued near $3290, not $0");
        assertGt(usd, 0, "1 WETH valued at $0 -> escapes slashing/exposure weighting");
    }

    // Regression: a 6dp token0 priced against an 18dp quote must account for the
    // token's own decimals. The buggy oracle overstated value by 1e6x, letting a
    // low-decimal token dominate the reward/exposure pool. The fixed oracle returns
    // the correct 1.8e9.
    function test_toUSD_LowDecToken0_NotOvervalued() public {
        Tok tkn = new Tok(6); Tok quote = new Tok(18);
        Pool pool = new Pool(address(tkn), address(quote));
        pool.setTick(0); // raw ratio 1
        Agg feed = new Agg(8); feed.setData(1800e8, block.timestamp);
        UniswapV3Oracle o = new UniswapV3Oracle(address(quote));
        o.configurePool(address(tkn), address(pool), address(feed), false);
        // 1 whole TKN (1e6) is worth 1e-12 quote * $1800 = 1.8e-9 USD = 1.8e9 (18dp)
        uint256 usd = o.toUSD(address(tkn), 1e6);
        emit log_named_uint("toUSD(1 TKN)", usd);
        // Correct USD value (1.8e9, 18dp). The reintroduced 1e6x-overstatement bug
        // would yield 1.8e15 and fail this exact-equality guard.
        assertEq(usd, 1.8e9, "low-dec token must value correctly, not 1e6x inflated");
    }
}
