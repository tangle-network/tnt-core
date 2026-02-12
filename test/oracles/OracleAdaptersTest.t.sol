// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import {
    ChainlinkOracle,
    AggregatorV3Interface as ChainlinkAggregator,
    IERC20Decimals as IERC20DecimalsChainlink
} from "../../src/oracles/ChainlinkOracle.sol";
import {
    UniswapV3Oracle,
    IUniswapV3Pool,
    AggregatorV3Interface as QuoteAggregator,
    IERC20Decimals as IERC20DecimalsUniswap
} from "../../src/oracles/UniswapV3Oracle.sol";
import { IPriceOracle } from "../../src/oracles/interfaces/IPriceOracle.sol";

contract MockAggregator is ChainlinkAggregator, QuoteAggregator {
    uint8 internal decimalsValue;
    int256 internal answer;
    uint256 internal updatedAt;
    bool internal shouldRevert;

    constructor(uint8 _decimals) {
        decimalsValue = _decimals;
    }

    function setData(int256 _answer, uint256 _updatedAt) external {
        answer = _answer;
        updatedAt = _updatedAt;
    }

    function setShouldRevert(bool flag) external {
        shouldRevert = flag;
    }

    function decimals() external view override(ChainlinkAggregator, QuoteAggregator) returns (uint8) {
        return decimalsValue;
    }

    function latestRoundData()
        external
        view
        override(ChainlinkAggregator, QuoteAggregator)
        returns (uint80, int256, uint256, uint256, uint80)
    {
        if (shouldRevert) revert("agg");
        return (0, answer, 0, updatedAt, 0);
    }
}

contract MockDecimalsToken is IERC20DecimalsChainlink, IERC20DecimalsUniswap {
    uint8 internal immutable decimalsValue;

    constructor(uint8 _decimals) {
        decimalsValue = _decimals;
    }

    function decimals() external view override(IERC20DecimalsChainlink, IERC20DecimalsUniswap) returns (uint8) {
        return decimalsValue;
    }
}

contract MockUniswapV3Pool is IUniswapV3Pool {
    address internal immutable token0Address;
    address internal immutable token1Address;
    int24 internal currentTick;

    constructor(address _token0, address _token1) {
        token0Address = _token0;
        token1Address = _token1;
    }

    function setTick(int24 tick) external {
        currentTick = tick;
    }

    function slot0() external view override returns (uint160, int24, uint16, uint16, uint16, uint8, bool) {
        return (0, currentTick, 0, 0, 0, 0, true);
    }

    function observe(uint32[] calldata secondsAgos)
        external
        view
        override
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
    {
        tickCumulatives = new int56[](secondsAgos.length);
        secondsPerLiquidityCumulativeX128s = new uint160[](secondsAgos.length);

        if (secondsAgos.length == 0) {
            return (tickCumulatives, secondsPerLiquidityCumulativeX128s);
        }

        tickCumulatives[0] = 0;
        for (uint256 i = 1; i < secondsAgos.length; i++) {
            int32 base = int32(uint32(secondsAgos[0]));
            int32 target = int32(uint32(secondsAgos[i]));
            tickCumulatives[i] = int56(currentTick) * int56(base - target);
        }
    }

    function token0() external view override returns (address) {
        return token0Address;
    }

    function token1() external view override returns (address) {
        return token1Address;
    }
}

contract ChainlinkOracleTest is Test {
    ChainlinkOracle internal oracle;
    MockAggregator internal nativeFeed;
    MockAggregator internal assetFeed;
    MockDecimalsToken internal token;

    function setUp() public {
        vm.warp(1_000_000);
        nativeFeed = new MockAggregator(8);
        nativeFeed.setData(1500e8, block.timestamp);
        oracle = new ChainlinkOracle(address(nativeFeed));

        token = new MockDecimalsToken(6);
        assetFeed = new MockAggregator(8);
        assetFeed.setData(2000e8, block.timestamp);

        oracle.configurePriceFeed(address(token), address(assetFeed));
    }

    function test_getPrice_UsesLatestChainlinkValue() public {
        uint256 price = oracle.getPrice(address(token));
        assertEq(price, 2000 ether);
    }

    function test_toUSDAndFromUSD_RoundTrip() public {
        uint256 usdValue = oracle.toUSD(address(token), 1_000_000);
        assertEq(usdValue, 2000 ether);

        uint256 amount = oracle.fromUSD(address(token), 2000 ether);
        assertEq(amount, 1_000_000);
    }

    function test_batchToUSD_SumsMultipleTokens() public {
        MockDecimalsToken token2 = new MockDecimalsToken(18);
        MockAggregator feed2 = new MockAggregator(18);
        feed2.setData(500 ether, block.timestamp);

        oracle.configurePriceFeed(address(token2), address(feed2));

        address[] memory tokens = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        tokens[0] = address(token);
        tokens[1] = address(token2);
        amounts[0] = 2_000_000; // 2 tokens with 6 decimals
        amounts[1] = 1 ether; // 1 token with 18 decimals

        uint256 totalUsd = oracle.batchToUSD(tokens, amounts);
        assertEq(totalUsd, 4500 ether);
    }

    function test_getPrice_RevertWhenStale() public {
        uint256 updatedAt = block.timestamp - oracle.maxAge() - 1;
        assetFeed.setData(2000e8, updatedAt);

        vm.expectRevert(
            abi.encodeWithSelector(IPriceOracle.StalePrice.selector, address(token), updatedAt, oracle.maxAge())
        );
        oracle.getPrice(address(token));
    }

    function test_getPrice_RevertWhenInvalidPrice() public {
        assetFeed.setData(-1, block.timestamp);
        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.InvalidPrice.selector, address(token), int256(-1)));
        oracle.getPrice(address(token));
    }

    function test_getPrice_RevertWhenTokenUnsupported() public {
        address unknown = makeAddr("unknown");
        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.TokenNotSupported.selector, unknown));
        oracle.getPrice(unknown);
    }

    function test_nativeTokenFeed() public {
        uint256 price = oracle.getPrice(address(0));
        assertEq(price, 1500 ether);
    }

    function test_removePriceFeed_DisablesSupport() public {
        oracle.removePriceFeed(address(token));
        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.TokenNotSupported.selector, address(token)));
        oracle.getPrice(address(token));
    }

    function test_getPrice_RevertWhenAggregatorFails() public {
        assetFeed.setShouldRevert(true);
        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.PriceNotAvailable.selector, address(token)));
        oracle.getPrice(address(token));
    }

    function test_batchToUSD_RevertsWhenFeedInvalid() public {
        MockDecimalsToken token2 = new MockDecimalsToken(18);
        MockAggregator feed2 = new MockAggregator(8);
        feed2.setData(500 ether, block.timestamp);
        oracle.configurePriceFeed(address(token2), address(feed2));

        address[] memory tokens = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        tokens[0] = address(token);
        tokens[1] = address(token2);
        amounts[0] = 1_000_000;
        amounts[1] = 1 ether;

        feed2.setShouldRevert(true);

        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.PriceNotAvailable.selector, address(token2)));
        oracle.batchToUSD(tokens, amounts);
    }

    function testFuzz_batchToUSD_Aggregates(uint8 count, uint256 seed) public {
        count = uint8(bound(uint256(count), 1, 5));
        address[] memory tokens = new address[](count);
        uint256[] memory amounts = new uint256[](count);
        uint256 expected;

        for (uint256 i = 0; i < count; i++) {
            uint256 rand = uint256(keccak256(abi.encode(seed, i)));
            uint8 decimalsValue = uint8(bound(rand % 18, 6, 18));
            MockDecimalsToken tkn = new MockDecimalsToken(decimalsValue);
            MockAggregator agg = new MockAggregator(8);

            uint256 price = bound(rand % 1e10, 1e6, 5e9); // positive price with 8 decimals
            agg.setData(int256(price), block.timestamp);
            oracle.configurePriceFeed(address(tkn), address(agg));

            tokens[i] = address(tkn);
            uint256 amount = bound((rand >> 64) % 1e18, 1, 1e18);
            amounts[i] = amount;

            expected += oracle.toUSD(tokens[i], amount);
        }

        uint256 total = oracle.batchToUSD(tokens, amounts);
        assertEq(total, expected, "batchToUSD should equal sum of individual conversions");
    }
}

contract UniswapV3OracleTest is Test {
    UniswapV3Oracle internal oracle;
    MockUniswapV3Pool internal pool;
    MockDecimalsToken internal token;
    MockDecimalsToken internal quoteToken;
    MockAggregator internal quoteFeed;

    function setUp() public {
        vm.warp(1_000_000);
        token = new MockDecimalsToken(6);
        quoteToken = new MockDecimalsToken(18);
        pool = new MockUniswapV3Pool(address(token), address(quoteToken));
        pool.setTick(0);

        quoteFeed = new MockAggregator(8);
        quoteFeed.setData(1800e8, block.timestamp);

        oracle = new UniswapV3Oracle(address(quoteToken));
        oracle.configurePool(address(token), address(pool), address(quoteFeed));
    }

    function test_getPriceData_ReturnsValidResult() public {
        IPriceOracle.PriceData memory data = oracle.getPriceData(address(token));
        assertTrue(data.isValid);
        assertEq(data.decimals, 6);
        assertGt(data.price, 0);
    }

    function test_toUSD_TracksQuoteFeedChanges() public {
        uint256 startValue = oracle.toUSD(address(token), 1_000_000);
        quoteFeed.setData(3600e8, block.timestamp);
        uint256 updatedValue = oracle.toUSD(address(token), 1_000_000);
        assertGt(updatedValue, startValue);
    }

    function test_getPrice_RevertWhenTokenUnsupported() public {
        address other = makeAddr("other");
        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.TokenNotSupported.selector, other));
        oracle.getPrice(other);
    }

    function test_configurePool_RevertWhenTokenMissing() public {
        MockDecimalsToken other = new MockDecimalsToken(18);
        vm.expectRevert("Token not in pool");
        oracle.configurePool(address(other), address(pool), address(quoteFeed));
    }

    function test_getPrice_UsesFallbackWhenQuoteIsStale() public {
        uint256 freshPrice = oracle.getPrice(address(token));
        uint256 staleTimestamp = block.timestamp - oracle.maxPriceAge() - 1;
        quoteFeed.setData(1800e8, staleTimestamp);
        uint256 fallbackPrice = oracle.getPrice(address(token));
        assertLt(fallbackPrice, freshPrice);
    }

    function test_getPrice_IgnoresRevertingQuoteFeed() public {
        uint256 withFeed = oracle.getPrice(address(token));
        quoteFeed.setShouldRevert(true);
        uint256 fallbackPrice = oracle.getPrice(address(token));

        assertGt(withFeed, fallbackPrice, "Fallback should drop to 1:1 when quote feed fails");
        assertGt(fallbackPrice, 0, "Price should remain positive even when quote feed reverts");
    }
}
