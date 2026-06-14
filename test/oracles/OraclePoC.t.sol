// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import {
    UniswapV3Oracle,
    IUniswapV3Pool,
    AggregatorV3Interface as QuoteAggregator,
    IERC20Decimals as IERC20DecimalsUniswap
} from "../../src/oracles/UniswapV3Oracle.sol";
import { IPriceOracle } from "../../src/oracles/interfaces/IPriceOracle.sol";

contract MockAgg is QuoteAggregator {
    uint8 internal d;
    int256 internal a;
    uint256 internal u;
    constructor(uint8 _d) { d = _d; }
    function setData(int256 _a, uint256 _u) external { a = _a; u = _u; }
    function decimals() external view override returns (uint8) { return d; }
    function latestRoundData() external view override returns (uint80, int256, uint256, uint256, uint80) {
        return (0, a, 0, u, 0);
    }
}

contract MockTok is IERC20DecimalsUniswap {
    uint8 internal immutable d;
    constructor(uint8 _d) { d = _d; }
    function decimals() external view override returns (uint8) { return d; }
}

// Pool that returns a tickCumulatives delta consistent with a fixed tick over the TWAP window.
contract MockPool is IUniswapV3Pool {
    address internal immutable t0;
    address internal immutable t1;
    int24 internal tick;
    constructor(address _t0, address _t1) { t0 = _t0; t1 = _t1; }
    function setTick(int24 _t) external { tick = _t; }
    function slot0() external pure override returns (uint160,int24,uint16,uint16,uint16,uint8,bool) {
        return (0,0,0,0,0,0,true);
    }
    function observe(uint32[] calldata secondsAgos)
        external view override returns (int56[] memory tc, uint160[] memory sl)
    {
        tc = new int56[](secondsAgos.length);
        sl = new uint160[](secondsAgos.length);
        // tickCumulatives[1]-[0] = tick * window  => arithmeticMeanTick == tick
        tc[0] = 0;
        tc[1] = int56(tick) * int56(uint56(secondsAgos[0]));
    }
    function token0() external view override returns (address) { return t0; }
    function token1() external view override returns (address) { return t1; }
}

contract OraclePoC is Test {
    function setUp() public { vm.warp(1_000_000); }

    // REGRESSION (was: test_PriceTruncatesToZero_WethAsToken0)
    // token0 = WETH (18 dec), token1 = USDC (6 dec), quoteIsUsd.
    // Real pool tick for ~3000 USDC/WETH. The raw token1/token0 ratio is < 1.
    // VULN (pre-fix): (sqrtPriceX96^2)>>192 floored the sub-1 ratio to ZERO before any
    // decimal adjustment, so WETH was priced at $0 and fromUSD() divided by zero (DoS).
    // FIX: _getPriceFromSqrtX96 folds 10^tokenDecimals into the mulDiv divisor, so the
    // sub-1 raw ratio keeps full precision and the 18dp USD price is non-zero.
    function test_PriceNotTruncatedToZero_WethAsToken0() public {
        MockTok weth = new MockTok(18);   // token being priced (token0)
        MockTok usdc = new MockTok(6);    // quote (token1), USD-denominated
        MockPool pool = new MockPool(address(weth), address(usdc));

        // tick for price ~3000 USDC(6dec)/WETH(18dec):
        // human price 3000 => raw price token1/token0 = 3000 * 10^(6-18) = 3e-9
        // tick = log_1.0001(3e-9) ~= -195331
        pool.setTick(-195_331);

        UniswapV3Oracle oracle = new UniswapV3Oracle(address(weth));
        // quoteIsUsd = true (USDC), no quote feed needed
        oracle.configurePool(address(weth), address(pool), address(0), true);

        IPriceOracle.PriceData memory data = oracle.getPriceData(address(weth));
        emit log_named_uint("WETH price (18dp USD), expected ~3290e18", data.price);
        // FIXED: price is the exact 18dp USD value for this tick (~$3290.84), no longer 0.
        // This pins the corrected mulDiv result; any reintroduction of the >>192 early
        // truncation drops it back to 0 and fails here.
        assertEq(data.price, 3_290_838_603_000_000_000_000, "WETH must be priced at the corrected ~$3290 (18dp), not truncated to 0");
        assertGt(data.price, 0, "INVARIANT: a real sub-1 raw-ratio pair must never price to 0");

        // Downstream invariant: fromUSD no longer divides by zero; it returns a finite amount.
        uint256 amount = oracle.fromUSD(address(weth), data.price); // $price worth of WETH == 1 whole WETH
        assertApproxEqAbs(amount, 1e18, 1e9, "fromUSD round-trips ~1 WETH for its own USD price; no DoS");
    }

    // REGRESSION (was: test_DecimalScalingInverted_Overvalues)
    // token0 = TKN (6 dec), token1 = quote (18 dec, $1800), tick = 0 (raw ratio 1).
    // Correct USD price of 1 whole TKN = 1e-12 quote * $1800 = 1.8e-9 USD = 1.8e9 (18dp).
    // VULN (pre-fix): scaled by 10^quoteDecimals/10^tokenDecimals, returning 1.8e15 —
    //   overstated by 10^tokenDecimals (1e6x), which would inflate collateral/exposure.
    // FIX: _getPriceFromSqrtX96 scales by 10^tokenDecimals only (quoteDecimals cancel),
    //   yielding the exact 1.8e9.
    function test_DecimalScalingCorrect_NoOvervaluation() public {
        MockTok tkn = new MockTok(6);
        MockTok quote = new MockTok(18);
        MockPool pool = new MockPool(address(tkn), address(quote));
        pool.setTick(0);

        MockAgg feed = new MockAgg(8);
        feed.setData(1800e8, block.timestamp); // quote = $1800

        UniswapV3Oracle oracle = new UniswapV3Oracle(address(quote));
        oracle.configurePool(address(tkn), address(pool), address(feed), false);

        IPriceOracle.PriceData memory data = oracle.getPriceData(address(tkn));
        uint256 correct = 1.8e9;
        emit log_named_uint("returned price ", data.price);
        emit log_named_uint("correct  price ", correct);
        // FIXED: exact 18dp USD price, no 1e6x inflation.
        assertEq(data.price, correct, "TKN must be priced at the correct 1.8e9 (18dp), not 1e6x overstated");
        // INVARIANT: the decimal scale factor is 10^tokenDecimals only; reintroducing the
        // inverted quoteDecimals scaling re-inflates by exactly 1e6 and fails this guard.
        assertEq(data.price, 1.8e15 / 1e6, "INVARIANT: overvaluation factor of 10^tokenDecimals (1e6x) is closed");
    }
}
