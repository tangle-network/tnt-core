// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import {
    ChainlinkOracle,
    AggregatorV3Interface as ChainlinkAggregator,
    ISequencerUptimeFeed as IChainlinkSequencerFeed,
    IChainlinkAggregatorBounds,
    IERC20Decimals as IERC20DecimalsChainlink
} from "../../../src/oracles/ChainlinkOracle.sol";
import {
    UniswapV3Oracle,
    IUniswapV3Pool,
    IUniswapV3PoolCardinality,
    AggregatorV3Interface as QuoteAggregator,
    ISequencerUptimeFeed as IUniswapSequencerFeed,
    IERC20Decimals as IERC20DecimalsUniswap
} from "../../../src/oracles/UniswapV3Oracle.sol";
import { IPriceOracle } from "../../../src/oracles/interfaces/IPriceOracle.sol";

// ─────────────────────────────────────────────────────────────────────────────
// Shared mocks
// ─────────────────────────────────────────────────────────────────────────────

contract MockToken is IERC20DecimalsChainlink, IERC20DecimalsUniswap {
    uint8 internal immutable d;

    constructor(uint8 _d) {
        d = _d;
    }

    function decimals() external view override(IERC20DecimalsChainlink, IERC20DecimalsUniswap) returns (uint8) {
        return d;
    }
}

/// @notice Quote aggregator + Chainlink aggregator that also exposes circuit-breaker bounds.
contract MockBoundedAggregator is ChainlinkAggregator, QuoteAggregator, IChainlinkAggregatorBounds {
    uint8 internal dValue;
    int256 internal answerValue;
    uint256 internal updatedAtValue;
    uint80 internal roundIdValue;
    uint80 internal answeredInRoundValue;
    int192 internal minAnswerValue;
    int192 internal maxAnswerValue;
    bool internal exposeBounds;

    constructor(uint8 _d) {
        dValue = _d;
    }

    function setData(int256 _answer, uint256 _updatedAt) external {
        answerValue = _answer;
        updatedAtValue = _updatedAt;
    }

    function setRound(uint80 _roundId, uint80 _answeredInRound) external {
        roundIdValue = _roundId;
        answeredInRoundValue = _answeredInRound;
    }

    function setBounds(int192 _min, int192 _max) external {
        minAnswerValue = _min;
        maxAnswerValue = _max;
        exposeBounds = true;
    }

    function decimals() external view override(ChainlinkAggregator, QuoteAggregator) returns (uint8) {
        return dValue;
    }

    function latestRoundData()
        external
        view
        override(ChainlinkAggregator, QuoteAggregator)
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (roundIdValue, answerValue, 0, updatedAtValue, answeredInRoundValue);
    }

    // ── IChainlinkAggregatorBounds ──
    function aggregator() external view override returns (address) {
        return address(this);
    }

    function minAnswer() external view override returns (int192) {
        if (!exposeBounds) revert("no bounds");
        return minAnswerValue;
    }

    function maxAnswer() external view override returns (int192) {
        if (!exposeBounds) revert("no bounds");
        return maxAnswerValue;
    }
}

/// @notice L2 sequencer uptime feed mock.
contract MockSequencerFeed is IChainlinkSequencerFeed, IUniswapSequencerFeed {
    int256 internal answerValue;
    uint256 internal startedAtValue;

    function set(int256 _answer, uint256 _startedAt) external {
        answerValue = _answer;
        startedAtValue = _startedAt;
    }

    function latestRoundData()
        external
        view
        override(IChainlinkSequencerFeed, IUniswapSequencerFeed)
        returns (uint80, int256, uint256, uint256, uint80)
    {
        return (0, answerValue, startedAtValue, startedAtValue, 0);
    }
}

/// @notice Uniswap V3 pool mock with configurable observation cardinality + growth support.
contract MockCardinalityPool is IUniswapV3Pool, IUniswapV3PoolCardinality {
    address internal immutable t0;
    address internal immutable t1;
    int24 internal tick;
    uint16 internal cardinality;
    uint16 internal cardinalityNext;
    bool internal supportsGrowth;

    constructor(address _t0, address _t1, uint16 _cardinality, bool _supportsGrowth) {
        t0 = _t0;
        t1 = _t1;
        cardinality = _cardinality;
        cardinalityNext = _cardinality;
        supportsGrowth = _supportsGrowth;
    }

    function setTick(int24 _t) external {
        tick = _t;
    }

    function slot0() external view override returns (uint160, int24, uint16, uint16, uint16, uint8, bool) {
        return (0, tick, 0, cardinality, cardinalityNext, 0, true);
    }

    function observe(uint32[] calldata secondsAgos)
        external
        view
        override
        returns (int56[] memory tc, uint160[] memory sl)
    {
        tc = new int56[](secondsAgos.length);
        sl = new uint160[](secondsAgos.length);
        if (secondsAgos.length < 2) return (tc, sl);
        tc[0] = 0;
        tc[1] = int56(tick) * int56(uint56(secondsAgos[0]));
    }

    function token0() external view override returns (address) {
        return t0;
    }

    function token1() external view override returns (address) {
        return t1;
    }

    function increaseObservationCardinalityNext(uint16 next) external override {
        require(supportsGrowth, "growth unsupported");
        if (next > cardinalityNext) cardinalityNext = next;
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChainlinkOracle: min/maxAnswer circuit breaker (finding: low)
// ─────────────────────────────────────────────────────────────────────────────

contract ChainlinkOracleBoundsTest is Test {
    ChainlinkOracle internal oracle;
    MockBoundedAggregator internal feed;
    MockToken internal token;

    function setUp() public {
        vm.warp(1_000_000);
        oracle = new ChainlinkOracle(address(0));
        token = new MockToken(18);
        feed = new MockBoundedAggregator(8);
        feed.setRound(1, 1);
        feed.setData(2000e8, block.timestamp);
        oracle.configurePriceFeed(address(token), address(feed));
    }

    /// SECURE INVARIANT: an answer pinned to the aggregator's minAnswer floor is rejected.
    /// If the bounds check were removed, getPrice would return the saturated floor as a live price.
    function test_RevertWhenAnswerAtMinBound() public {
        feed.setBounds(int192(1000e8), int192(9000e8));
        feed.setData(1000e8, block.timestamp); // exactly at minAnswer

        vm.expectRevert(
            abi.encodeWithSelector(
                ChainlinkOracle.AnswerOutOfBounds.selector,
                address(token),
                int256(1000e8),
                int192(1000e8),
                int192(9000e8)
            )
        );
        oracle.getPrice(address(token));
    }

    /// SECURE INVARIANT: an answer pinned to the aggregator's maxAnswer ceiling is rejected.
    function test_RevertWhenAnswerAtMaxBound() public {
        feed.setBounds(int192(1000e8), int192(9000e8));
        feed.setData(9000e8, block.timestamp); // exactly at maxAnswer

        vm.expectRevert(
            abi.encodeWithSelector(
                ChainlinkOracle.AnswerOutOfBounds.selector,
                address(token),
                int256(9000e8),
                int192(1000e8),
                int192(9000e8)
            )
        );
        oracle.getPrice(address(token));
    }

    /// An answer strictly inside [min, max] is accepted and priced normally.
    function test_AnswerWithinBoundsAccepted() public {
        feed.setBounds(int192(1000e8), int192(9000e8));
        feed.setData(2000e8, block.timestamp);
        assertEq(oracle.getPrice(address(token)), 2000 ether);
    }

    /// Feeds that do not expose bounds (older aggregators) must still work — the check is skipped.
    function test_FeedWithoutBoundsStillWorks() public view {
        // setBounds was never called; minAnswer()/maxAnswer() revert -> skipped via try/catch.
        assertEq(oracle.getPrice(address(token)), 2000 ether);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// ChainlinkOracle: sequencer uptime gate (kept for parity / regression)
// ─────────────────────────────────────────────────────────────────────────────

contract ChainlinkOracleSequencerTest is Test {
    ChainlinkOracle internal oracle;
    MockBoundedAggregator internal feed;
    MockSequencerFeed internal seq;
    MockToken internal token;

    function setUp() public {
        vm.warp(1_000_000);
        oracle = new ChainlinkOracle(address(0));
        token = new MockToken(18);
        feed = new MockBoundedAggregator(8);
        feed.setRound(1, 1);
        feed.setData(2000e8, block.timestamp);
        oracle.configurePriceFeed(address(token), address(feed));

        seq = new MockSequencerFeed();
        oracle.setSequencerUptimeFeed(address(seq), 1 hours);
    }

    function test_RevertWhenSequencerDown() public {
        seq.set(1, block.timestamp - 2 hours); // answer != 0 => down
        vm.expectRevert(ChainlinkOracle.SequencerDown.selector);
        oracle.getPrice(address(token));
    }

    function test_RevertWithinGracePeriod() public {
        seq.set(0, block.timestamp - 10 minutes); // up, but < grace
        vm.expectRevert(ChainlinkOracle.SequencerDown.selector);
        oracle.getPrice(address(token));
    }

    function test_AcceptWhenSequencerUpPastGrace() public {
        seq.set(0, block.timestamp - 2 hours);
        assertEq(oracle.getPrice(address(token)), 2000 ether);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// UniswapV3Oracle: sequencer gate on the quote-feed path (finding: medium)
// ─────────────────────────────────────────────────────────────────────────────

contract UniswapV3OracleSequencerTest is Test {
    UniswapV3Oracle internal oracle;
    MockCardinalityPool internal pool;
    MockToken internal token; // token0, 6 dec
    MockToken internal quote; // token1, 18 dec
    MockBoundedAggregator internal quoteFeed;
    MockSequencerFeed internal seq;

    uint16 internal constant DEEP = 200; // > ceil(1800/12)=150

    function setUp() public {
        vm.warp(1_000_000);
        token = new MockToken(6);
        quote = new MockToken(18);
        pool = new MockCardinalityPool(address(token), address(quote), DEEP, true);
        pool.setTick(0);

        quoteFeed = new MockBoundedAggregator(8);
        quoteFeed.setRound(1, 1);
        quoteFeed.setData(1800e8, block.timestamp);

        oracle = new UniswapV3Oracle(address(quote));
        oracle.configurePool(address(token), address(pool), address(quoteFeed), false);

        seq = new MockSequencerFeed();
        oracle.setSequencerUptimeFeed(address(seq), 1 hours);
    }

    /// SECURE INVARIANT: the Uniswap quote-feed path refuses to price while the L2 sequencer is
    /// down. Pre-fix the path read the (frozen) Chainlink quote feed with no sequencer gate.
    function test_RevertWhenSequencerDown() public {
        seq.set(1, block.timestamp - 2 hours);
        vm.expectRevert(UniswapV3Oracle.SequencerDown.selector);
        oracle.getPrice(address(token));
    }

    function test_RevertWithinGracePeriod() public {
        seq.set(0, block.timestamp - 10 minutes);
        vm.expectRevert(UniswapV3Oracle.SequencerDown.selector);
        oracle.getPrice(address(token));
    }

    function test_AcceptWhenSequencerUpPastGrace() public {
        seq.set(0, block.timestamp - 2 hours);
        assertGt(oracle.getPrice(address(token)), 0);
    }

    /// On L1 (no sequencer feed configured) pricing is unaffected.
    function test_NoSequencerFeedIsNoOp() public {
        UniswapV3Oracle l1Oracle = new UniswapV3Oracle(address(quote));
        l1Oracle.configurePool(address(token), address(pool), address(quoteFeed), false);
        assertGt(l1Oracle.getPrice(address(token)), 0);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// UniswapV3Oracle: observation cardinality enforcement (finding: medium)
// ─────────────────────────────────────────────────────────────────────────────

contract UniswapV3OracleCardinalityTest is Test {
    UniswapV3Oracle internal oracle;
    MockToken internal token; // 6 dec
    MockToken internal quote; // 18 dec
    MockBoundedAggregator internal quoteFeed;

    // ceil(DEFAULT_TWAP_PERIOD(1800) / 12) = 150
    uint16 internal constant NEEDED = 150;

    function setUp() public {
        vm.warp(1_000_000);
        token = new MockToken(6);
        quote = new MockToken(18);
        quoteFeed = new MockBoundedAggregator(8);
        quoteFeed.setRound(1, 1);
        quoteFeed.setData(1800e8, block.timestamp);
        oracle = new UniswapV3Oracle(address(quote));
    }

    /// SECURE INVARIANT: a thin pool that reports positive-but-insufficient cardinality and cannot
    /// grow its buffer is rejected at config time. Pre-fix configurePool ignored cardinality, so a
    /// shallow ring buffer let the TWAP collapse toward manipulable spot.
    function test_RevertWhenCardinalityTooLowAndCannotGrow() public {
        MockCardinalityPool thin = new MockCardinalityPool(address(token), address(quote), 5, false);
        thin.setTick(0);

        vm.expectRevert(
            abi.encodeWithSelector(
                UniswapV3Oracle.InsufficientObservationCardinality.selector, address(thin), uint16(5), NEEDED
            )
        );
        oracle.configurePool(address(token), address(thin), address(quoteFeed), false);
    }

    /// A pool whose buffer is already deep enough configures without growth.
    function test_AcceptWhenCardinalityAlreadyDeep() public {
        MockCardinalityPool deep = new MockCardinalityPool(address(token), address(quote), 200, false);
        deep.setTick(0);
        oracle.configurePool(address(token), address(deep), address(quoteFeed), false);
        assertTrue(oracle.isTokenSupported(address(token)));
    }

    /// A thin pool that DOES support growth is grown in place to satisfy the requirement.
    function test_GrowsThinPoolThatSupportsGrowth() public {
        MockCardinalityPool growable = new MockCardinalityPool(address(token), address(quote), 5, true);
        growable.setTick(0);
        oracle.configurePool(address(token), address(growable), address(quoteFeed), false);
        // After config the pending cardinality must cover the window.
        (,,, uint16 card, uint16 cardNext,,) = growable.slot0();
        assertGe(uint256(card >= cardNext ? card : cardNext), NEEDED);
        assertTrue(oracle.isTokenSupported(address(token)));
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// UniswapV3Oracle: zero-price guard (finding: medium)
// ─────────────────────────────────────────────────────────────────────────────

/// @notice Pool that forces a tick deep enough that the priced ratio floors to 0 after mulDiv,
///         exercising the data.price == 0 guard. token1 (18 dec) priced in token0 (18 dec) at a
///         very negative tick yields priceInQuote == 0.
contract ZeroPricePool is IUniswapV3Pool {
    address internal immutable t0;
    address internal immutable t1;

    constructor(address _t0, address _t1) {
        t0 = _t0;
        t1 = _t1;
    }

    function slot0() external pure override returns (uint160, int24, uint16, uint16, uint16, uint8, bool) {
        // Deep cardinality so the cardinality guard passes; tick handled in observe().
        return (0, int24(-887_000), 0, 300, 300, 0, true);
    }

    function observe(uint32[] calldata secondsAgos)
        external
        pure
        override
        returns (int56[] memory tc, uint160[] memory sl)
    {
        tc = new int56[](secondsAgos.length);
        sl = new uint160[](secondsAgos.length);
        if (secondsAgos.length < 2) return (tc, sl);
        // Maximally negative mean tick: priced token (token1) in token0 -> ratio ~ 0.
        tc[0] = 0;
        tc[1] = int56(-887_000) * int56(uint56(secondsAgos[0]));
    }

    function token0() external view override returns (address) {
        return t0;
    }

    function token1() external view override returns (address) {
        return t1;
    }
}

contract UniswapV3OracleZeroPriceTest is Test {
    UniswapV3Oracle internal oracle;
    MockToken internal token; // token0, the priced token (18 dec)
    MockToken internal quote; // token1, USD-denominated (18 dec)

    function setUp() public {
        vm.warp(1_000_000);
        // Priced token is token0, quote is token1. At a deeply negative mean tick the raw
        // token1/token0 ratio is ~0, so the priced-token value floors to 0 after the conversion.
        token = new MockToken(18);
        quote = new MockToken(18);
    }

    /// SECURE INVARIANT: a computed price of 0 reverts PriceNotAvailable instead of being marked
    /// valid. Pre-fix _getPriceData set data.isValid = true unconditionally, so a $0 quote would
    /// flow into toUSD (value escapes slashing) and fromUSD (division by zero / DoS).
    function test_RevertWhenComputedPriceIsZero() public {
        // token0 = priced token, token1 = quote.
        ZeroPricePool pool = new ZeroPricePool(address(token), address(quote));
        oracle = new UniswapV3Oracle(address(quote));
        // quoteIsUsd = true so no quote feed is needed; isolates the priceInQuote==0 path.
        oracle.configurePool(address(token), address(pool), address(0), true);

        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.PriceNotAvailable.selector, address(token)));
        oracle.getPrice(address(token));

        // getPriceData uses the same internal path and must also revert (never returns isValid).
        vm.expectRevert(abi.encodeWithSelector(IPriceOracle.PriceNotAvailable.selector, address(token)));
        oracle.getPriceData(address(token));
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// UniswapV3Oracle: quote-feed min/maxAnswer circuit breaker (F1, medium)
// ─────────────────────────────────────────────────────────────────────────────

contract UniswapV3OracleQuoteBoundsTest is Test {
    UniswapV3Oracle internal oracle;
    MockCardinalityPool internal pool;
    MockToken internal token; // token0, 6 dec
    MockToken internal quote; // token1, 18 dec
    MockBoundedAggregator internal quoteFeed;

    function setUp() public {
        vm.warp(1_000_000);
        token = new MockToken(6);
        quote = new MockToken(18);
        pool = new MockCardinalityPool(address(token), address(quote), 200, true);
        pool.setTick(0);
        quoteFeed = new MockBoundedAggregator(8);
        quoteFeed.setRound(1, 1);
        quoteFeed.setData(1800e8, block.timestamp);
        oracle = new UniswapV3Oracle(address(quote));
        oracle.configurePool(address(token), address(pool), address(quoteFeed), false);
    }

    /// F1: a quote answer pinned to the aggregator's minAnswer floor is rejected (parity with
    /// ChainlinkOracle). Pre-fix the Uniswap quote-feed path had no bounds check, so a saturated
    /// quote feed would propagate a pinned floor/ceiling through the TWAP→USD conversion.
    function test_F1_RevertWhenQuoteAnswerAtMinBound() public {
        quoteFeed.setBounds(int192(1000e8), int192(9000e8));
        quoteFeed.setData(1000e8, block.timestamp);
        vm.expectRevert(
            abi.encodeWithSelector(
                UniswapV3Oracle.AnswerOutOfBounds.selector,
                address(token),
                int256(1000e8),
                int192(1000e8),
                int192(9000e8)
            )
        );
        oracle.getPrice(address(token));
    }

    function test_F1_RevertWhenQuoteAnswerAtMaxBound() public {
        quoteFeed.setBounds(int192(1000e8), int192(9000e8));
        quoteFeed.setData(9000e8, block.timestamp);
        vm.expectRevert(
            abi.encodeWithSelector(
                UniswapV3Oracle.AnswerOutOfBounds.selector,
                address(token),
                int256(9000e8),
                int192(1000e8),
                int192(9000e8)
            )
        );
        oracle.getPrice(address(token));
    }

    /// A quote answer strictly inside [min, max] still prices normally.
    function test_F1_QuoteAnswerWithinBoundsAccepted() public {
        quoteFeed.setBounds(int192(1000e8), int192(9000e8));
        quoteFeed.setData(1800e8, block.timestamp);
        assertGt(oracle.getPrice(address(token)), 0);
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// UniswapV3Oracle: setTwapPeriod re-validates observation cardinality (F2, medium)
// ─────────────────────────────────────────────────────────────────────────────

contract UniswapV3OracleSetTwapCardinalityTest is Test {
    UniswapV3Oracle internal oracle;
    MockToken internal token; // 6 dec
    MockToken internal quote; // 18 dec
    MockBoundedAggregator internal quoteFeed;

    function setUp() public {
        vm.warp(1_000_000);
        token = new MockToken(6);
        quote = new MockToken(18);
        quoteFeed = new MockBoundedAggregator(8);
        quoteFeed.setRound(1, 1);
        quoteFeed.setData(1800e8, block.timestamp);
        oracle = new UniswapV3Oracle(address(quote));
    }

    /// F2: raising the TWAP period re-grows an already-configured (growable) pool's observation
    /// buffer to span the new window. Pre-fix setTwapPeriod skipped the cardinality check entirely.
    function test_F2_SetTwapPeriodGrowsConfiguredPool() public {
        MockCardinalityPool growable = new MockCardinalityPool(address(token), address(quote), 200, true);
        growable.setTick(0);
        // Configures fine at the default 1800s period (needs ceil(1800/12)=150 <= 200).
        oracle.configurePool(address(token), address(growable), address(quoteFeed), false);

        // Raise to 36000s -> needs ceil(36000/12) = 3000 slots.
        oracle.setTwapPeriod(36_000);

        (,,, uint16 card, uint16 cardNext,,) = growable.slot0();
        assertGe(uint256(card >= cardNext ? card : cardNext), 3000, "pool grown to cover the raised period");
    }

    /// F2: raising the period beyond a non-growable pool's buffer is rejected, instead of silently
    /// leaving a pool whose `observe()` over the new window would revert (price unavailable).
    function test_F2_SetTwapPeriodRevertsWhenPoolCannotGrow() public {
        MockCardinalityPool fixedPool = new MockCardinalityPool(address(token), address(quote), 200, false);
        fixedPool.setTick(0);
        oracle.configurePool(address(token), address(fixedPool), address(quoteFeed), false);

        vm.expectRevert(
            abi.encodeWithSelector(
                UniswapV3Oracle.InsufficientObservationCardinality.selector,
                address(fixedPool),
                uint16(200),
                uint16(3000)
            )
        );
        oracle.setTwapPeriod(36_000);
    }
}
