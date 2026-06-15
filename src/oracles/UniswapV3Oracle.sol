// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IPriceOracle, IPriceOracleAdmin } from "./interfaces/IPriceOracle.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title IUniswapV3Pool
/// @notice Minimal Uniswap V3 pool interface for TWAP
interface IUniswapV3Pool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    function token0() external view returns (address);
    function token1() external view returns (address);
}

/// @title IUniswapV3PoolCardinality
/// @notice Cardinality-growth surface kept separate from {IUniswapV3Pool} so test/mock pools that
///         predate observation-buffer enforcement remain ABI-compatible with {IUniswapV3Pool}.
///         We invoke `increaseObservationCardinalityNext` opportunistically (via try/catch) at
///         config time to grow a thin pool's observation ring buffer; a pool that does not expose
///         it simply cannot be auto-grown and must already satisfy the cardinality requirement.
interface IUniswapV3PoolCardinality {
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

/// @title ISequencerUptimeFeed
/// @notice L2 sequencer uptime feed (e.g. Base / Arbitrum canonical feed). `answer == 0` means the
///         sequencer is up; `answer == 1` means it is down or has just restarted. Reading any
///         Chainlink quote feed on an L2 while the sequencer is down (or freshly restarted) yields
///         a price that has been frozen during the outage, so the TWAP-to-USD conversion would
///         publish a stale-but-"valid" value. We gate on it for parity with ChainlinkOracle.
interface ISequencerUptimeFeed {
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

/// @title IERC20Decimals
/// @notice Minimal ERC20 interface for decimals
interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

/// @title UniswapV3Oracle
/// @notice Price oracle using Uniswap V3 TWAP
/// @dev Uses time-weighted average prices from Uniswap V3 pools
///
/// SECURITY CONSIDERATIONS:
/// - TWAP Period: The default 30-minute TWAP period provides reasonable manipulation resistance
///   for liquid pools but may be vulnerable in low-liquidity pools. Attackers with sufficient
///   capital can manipulate prices over the TWAP window.
///
/// - Minimum Liquidity: Before configuring a pool, verify it has sufficient liquidity.
///   Recommended minimum: $1M TVL for high-value operations, $100K for low-value operations.
///
/// - For high-stakes operations (slashing, large withdrawals), consider:
///   1. Using longer TWAP periods (1-4 hours) via setTwapPeriod()
///   2. Cross-referencing with Chainlink oracle prices
///   3. Implementing circuit breakers for large price deviations
///
/// - Pool observation cardinality must be sufficient for the TWAP period. The pool
///   should have at least (twapPeriod / 12 seconds) observations initialized.
contract UniswapV3Oracle is IPriceOracle, IPriceOracleAdmin, Ownable {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Standard price precision (18 decimals)
    uint256 private constant PRICE_PRECISION = 1e18;

    /// @notice Fixed point Q96 (for sqrtPriceX96 calculations)
    uint256 private constant Q96 = 2 ** 96;

    /// @notice Default TWAP period (30 minutes)
    uint32 private constant DEFAULT_TWAP_PERIOD = 30 minutes;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Pool configuration for a token
    struct PoolConfig {
        address pool; // Uniswap V3 pool address
        address quoteToken; // Quote token (usually WETH or stablecoin)
        bool isToken0; // True if token is token0 in the pool
        uint8 tokenDecimals; // Token decimals
        uint8 quoteDecimals; // Quote token decimals
        // Set true when the quote token is itself a USD-denominated stablecoin so the
        // oracle can return the TWAP price directly without an external feed.
        bool quoteIsUsd;
    }

    /// @notice Token to pool configuration
    mapping(address => PoolConfig) public poolConfigs;

    /// @notice Quote token to USD price feed (Chainlink)
    mapping(address => address) public quoteTokenFeeds;

    /// @notice TWAP observation period
    uint32 public twapPeriod;

    /// @notice Maximum price age (for staleness)
    uint256 public maxAge;

    /// @notice WETH address (common quote token)
    address public weth;

    // ── Storage appended after the original layout (UUPS-safe; never reorder above) ──

    /// @notice Optional L2 sequencer uptime feed. When set, prices revert if the sequencer
    ///         is reported down or has been up for less than `sequencerGracePeriod`. Mirrors the
    ///         ChainlinkOracle gate so the quote-feed path cannot read frozen L2 prices.
    address public sequencerUptimeFeed;

    /// @notice Required time the sequencer must have been up before prices are accepted.
    uint256 public sequencerGracePeriod;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Sequencer down or recently restarted (within grace period)
    error SequencerDown();

    /// @notice Sequencer feed reports a stalled round
    error StalePrice_Sequencer();

    /// @notice Configured pool does not have enough TWAP observation slots for `twapPeriod`,
    ///         so the TWAP would degenerate toward manipulable spot. `have` < `need`.
    error InsufficientObservationCardinality(address pool, uint16 have, uint16 need);

    event SequencerUptimeFeedConfigured(address indexed feed, uint256 gracePeriod);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _weth) Ownable(msg.sender) {
        weth = _weth;
        twapPeriod = DEFAULT_TWAP_PERIOD;
        maxAge = 1 hours;
        sequencerGracePeriod = 1 hours;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CORE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IPriceOracle
    function getPrice(address token) external view override returns (uint256 price) {
        PriceData memory data = _getPriceData(token);
        if (!data.isValid) {
            revert PriceNotAvailable(token);
        }
        return data.price;
    }

    /// @inheritdoc IPriceOracle
    function getPriceData(address token) external view override returns (PriceData memory data) {
        return _getPriceData(token);
    }

    /// @inheritdoc IPriceOracle
    function isTokenSupported(address token) external view override returns (bool supported) {
        return poolConfigs[token].pool != address(0);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONVERSION FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IPriceOracle
    // forge-lint: disable-next-line(mixed-case-function)
    function toUSD(address token, uint256 amount) external view override returns (uint256 usdValue) {
        PriceData memory data = _getPriceData(token);
        if (!data.isValid) {
            revert PriceNotAvailable(token);
        }

        return (amount * data.price) / (10 ** data.decimals);
    }

    /// @inheritdoc IPriceOracle
    // forge-lint: disable-next-line(mixed-case-function)
    function fromUSD(address token, uint256 usdValue) external view override returns (uint256 amount) {
        PriceData memory data = _getPriceData(token);
        if (!data.isValid) {
            revert PriceNotAvailable(token);
        }

        return (usdValue * (10 ** data.decimals)) / data.price;
    }

    /// @inheritdoc IPriceOracle
    // forge-lint: disable-next-line(mixed-case-function)
    function batchToUSD(
        address[] calldata tokens,
        uint256[] calldata amounts
    )
        external
        view
        override
        returns (uint256 totalUsd)
    {
        require(tokens.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < tokens.length; i++) {
            if (amounts[i] > 0) {
                PriceData memory data = _getPriceData(tokens[i]);
                if (!data.isValid) {
                    revert PriceNotAvailable(tokens[i]);
                }
                totalUsd += (amounts[i] * data.price) / (10 ** data.decimals);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IPriceOracle
    function maxPriceAge() external view override returns (uint256) {
        return maxAge;
    }

    /// @inheritdoc IPriceOracle
    function oracleName() external pure override returns (string memory) {
        return "UniswapV3TWAP";
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure a Uniswap V3 pool for a token
    /// @param token The token to configure
    /// @param pool The Uniswap V3 pool address
    /// @param quoteFeed Chainlink feed for quote-token USD price (required unless `quoteIsUsd`)
    /// @param quoteIsUsd True if the quote token is already USD-denominated (e.g. USDC)
    function configurePool(address token, address pool, address quoteFeed, bool quoteIsUsd) external onlyOwner {
        require(pool != address(0), "Invalid pool");
        require(quoteIsUsd || quoteFeed != address(0), "Quote feed required for non-USD pool");

        IUniswapV3Pool uniPool = IUniswapV3Pool(pool);
        address token0 = uniPool.token0();
        address token1 = uniPool.token1();

        bool isToken0 = token == token0;
        require(isToken0 || token == token1, "Token not in pool");

        address quoteToken = isToken0 ? token1 : token0;

        // Enforce enough TWAP observation slots so observe() does not extrapolate from a near-empty
        // ring buffer. With ~12s blocks the buffer needs at least ceil(twapPeriod/12) slots to span
        // the window; a thin pool with low cardinality lets the TWAP collapse toward single-block
        // (manipulable) spot. If the pool can already cover the window we accept it; otherwise we
        // grow it in-place via increaseObservationCardinalityNext and require the request to take.
        _ensureObservationCardinality(uniPool);

        poolConfigs[token] = PoolConfig({
            pool: pool,
            quoteToken: quoteToken,
            isToken0: isToken0,
            tokenDecimals: IERC20Decimals(token).decimals(),
            quoteDecimals: IERC20Decimals(quoteToken).decimals(),
            quoteIsUsd: quoteIsUsd
        });

        if (quoteFeed != address(0)) {
            quoteTokenFeeds[quoteToken] = quoteFeed;
        }

        emit PriceFeedConfigured(token, pool);
    }

    /// @inheritdoc IPriceOracleAdmin
    function configurePriceFeed(address token, address feed) external override onlyOwner {
        // For compatibility - configure quote token feed
        quoteTokenFeeds[token] = feed;
        emit PriceFeedConfigured(token, feed);
    }

    /// @inheritdoc IPriceOracleAdmin
    function removePriceFeed(address token) external override onlyOwner {
        delete poolConfigs[token];
        emit PriceFeedConfigured(token, address(0));
    }

    /// @inheritdoc IPriceOracleAdmin
    function setMaxPriceAge(uint256 _maxAge) external override onlyOwner {
        require(_maxAge > 0, "Invalid max age");
        maxAge = _maxAge;
    }

    /// @inheritdoc IPriceOracleAdmin
    function setNativeTokenFeed(address feed) external override onlyOwner {
        // For native token (ETH), we use WETH pool
        quoteTokenFeeds[address(0)] = feed;
        emit PriceFeedConfigured(address(0), feed);
    }

    /// @notice Set TWAP observation period
    /// @param period New TWAP period in seconds
    function setTwapPeriod(uint32 period) external onlyOwner {
        require(period > 0, "Invalid period");
        twapPeriod = period;
    }

    /// @notice Configure the L2 sequencer uptime feed. Set to `address(0)` to disable on L1.
    /// @dev Mirrors {ChainlinkOracle.setSequencerUptimeFeed}. When configured, the quote-feed
    ///      path in {_getPriceData} reverts while the sequencer is down or within the grace
    ///      period after a restart, so the oracle cannot publish a frozen-but-"valid" L2 price.
    /// @param feed Sequencer uptime feed address (Base mainnet: 0xBCF85224fc0756B9Fa45aA7892530B47e10b6433)
    /// @param gracePeriodSeconds Seconds the sequencer must have been up before prices are valid
    function setSequencerUptimeFeed(address feed, uint256 gracePeriodSeconds) external onlyOwner {
        require(gracePeriodSeconds > 0, "Invalid grace period");
        sequencerUptimeFeed = feed;
        sequencerGracePeriod = gracePeriodSeconds;
        emit SequencerUptimeFeedConfigured(feed, gracePeriodSeconds);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _getPriceData(address token) internal view returns (PriceData memory data) {
        PoolConfig storage config = poolConfigs[token];

        if (config.pool == address(0)) {
            revert TokenNotSupported(token);
        }

        // Gate the entire pricing path on L2 sequencer liveness, for parity with ChainlinkOracle.
        // The quote-feed branch below reads a Chainlink feed whose value freezes during a sequencer
        // outage; without this gate the oracle would publish that frozen value as a fresh, "valid"
        // price. On L1 (no feed configured) this is a no-op.
        _requireSequencerUp();

        // Get TWAP tick
        int24 arithmeticMeanTick = _getArithmeticMeanTick(config.pool, twapPeriod);

        // Convert tick to price
        // price = 1.0001^tick * 10^(token1Decimals - token0Decimals)
        uint256 sqrtPriceX96 = _getSqrtPriceX96FromTick(arithmeticMeanTick);
        uint256 priceInQuote =
            _getPriceFromSqrtX96(sqrtPriceX96, config.isToken0, config.tokenDecimals, config.quoteDecimals);

        // Resolve the quote-token USD price. Fail closed: if no feed is configured for a
        // non-USD quote token, or the feed reverts / returns a stale or non-positive answer,
        // we cannot price the asset and must surface that to the caller. The previous
        // implementation defaulted to 1:1 here, which silently mispriced any non-USD pool.
        address quoteFeed = quoteTokenFeeds[config.quoteToken];
        uint256 quoteUsdPrice;
        uint256 quoteUpdatedAt;

        if (quoteFeed == address(0)) {
            if (!config.quoteIsUsd) revert PriceNotAvailable(token);
            quoteUsdPrice = PRICE_PRECISION;
            quoteUpdatedAt = block.timestamp;
        } else {
            (uint80 roundId, int256 answer,, uint256 updatedAt, uint80 answeredInRound) =
                AggregatorV3Interface(quoteFeed).latestRoundData();
            if (answer <= 0) revert InvalidPrice(token, answer);
            if (answeredInRound < roundId) revert StalePrice(token, updatedAt, maxAge);
            if (block.timestamp - updatedAt > maxAge) revert StalePrice(token, updatedAt, maxAge);

            uint8 feedDecimals = AggregatorV3Interface(quoteFeed).decimals();
            if (feedDecimals < 18) {
                // forge-lint: disable-next-line(unsafe-typecast)
                quoteUsdPrice = uint256(answer) * (10 ** (18 - feedDecimals));
            } else if (feedDecimals > 18) {
                // forge-lint: disable-next-line(unsafe-typecast)
                quoteUsdPrice = uint256(answer) / (10 ** (feedDecimals - 18));
            } else {
                // forge-lint: disable-next-line(unsafe-typecast)
                quoteUsdPrice = uint256(answer);
            }
            quoteUpdatedAt = updatedAt;
        }

        // Final price in USD = priceInQuote * quoteUsdPrice / 10^quoteDecimals
        data.price = (priceInQuote * quoteUsdPrice) / (10 ** config.quoteDecimals);

        // Fail closed on a zero price. Even after the full-precision mulDiv conversion, a deep
        // out-of-range tick (or a degenerate decimal pairing) can floor `priceInQuote` to 0, and
        // a 0 USD price is never a legitimate quote: downstream toUSD() would value the asset at $0
        // (escaping exposure/slashing) and fromUSD() would divide by zero (DoS). Surfacing
        // PriceNotAvailable here is strictly safer than marking the data valid.
        if (data.price == 0) {
            revert PriceNotAvailable(token);
        }

        // Tie freshness to the underlying quote feed when applicable so downstream
        // staleness checks reflect the slowest input, not "now".
        data.updatedAt = quoteUpdatedAt;
        data.decimals = config.tokenDecimals;
        data.isValid = true;
    }

    /// @dev Reverts if the sequencer feed (when configured) reports the L2 sequencer
    ///      as down or recently restarted within `sequencerGracePeriod`. No-op on L1.
    function _requireSequencerUp() internal view {
        address feed = sequencerUptimeFeed;
        if (feed == address(0)) return;

        (, int256 answer, uint256 startedAt,,) = ISequencerUptimeFeed(feed).latestRoundData();
        if (startedAt == 0) revert StalePrice_Sequencer();
        if (answer != 0) revert SequencerDown();
        if (block.timestamp - startedAt < sequencerGracePeriod) revert SequencerDown();
    }

    /// @dev Ensure the configured pool's observation ring buffer can actually span `twapPeriod`.
    ///      With ~12s L2/L1 blocks the buffer needs at least ceil(twapPeriod / 12) slots; below
    ///      that, observe() interpolates from too few points and the TWAP collapses toward
    ///      single-block (manipulable) spot. We accept a pool that already covers the window (live
    ///      or already-requested cardinality), otherwise we opportunistically grow it in place and
    ///      require the request to take. A pool reporting cardinality 0 is not an initialized
    ///      Uniswap V3 pool (initialize() sets it to 1); we cannot enforce against such a pool and
    ///      defer to the owner-trusted configuration that points the oracle at it.
    function _ensureObservationCardinality(IUniswapV3Pool uniPool) internal {
        (,,, uint16 cardinality, uint16 cardinalityNext,,) = uniPool.slot0();

        // ceil(twapPeriod / 12), clamped to the uint16 range the pool stores cardinality in.
        uint256 needed256 = (uint256(twapPeriod) + 11) / 12;
        if (needed256 > type(uint16).max) needed256 = type(uint16).max;
        uint16 needed = uint16(needed256);

        // Already deep enough (current or pending growth) — nothing to do.
        if (cardinality >= needed || cardinalityNext >= needed) return;

        // A real initialized pool always reports cardinality >= 1. Only a non-initialized
        // (or stubbed) pool reports 0; we cannot meaningfully enforce or grow it.
        if (cardinality == 0) return;

        // Grow the buffer in place. The pool may not expose the growth call (older/forked pools);
        // in that case we fall through to the requirement check and revert below.
        try IUniswapV3PoolCardinality(address(uniPool)).increaseObservationCardinalityNext(needed) { } catch { }

        (,,, uint16 newCardinality, uint16 newCardinalityNext,,) = uniPool.slot0();
        if (newCardinality < needed && newCardinalityNext < needed) {
            revert InsufficientObservationCardinality(address(uniPool), newCardinality, needed);
        }
    }

    /// @notice Get arithmetic mean tick from TWAP
    function _getArithmeticMeanTick(address pool, uint32 period) internal view returns (int24) {
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = period;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives,) = IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];
        // Casting fits because Uniswap ticks are bounded within int24 range.
        // forge-lint: disable-next-line(unsafe-typecast)
        int24 arithmeticMeanTick = int24(tickCumulativesDelta / int56(uint56(period)));

        // Round towards negative infinity
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % int56(uint56(period)) != 0)) {
            arithmeticMeanTick--;
        }

        return arithmeticMeanTick;
    }

    /// @notice Convert tick to sqrtPriceX96
    function _getSqrtPriceX96FromTick(int24 tick) internal pure returns (uint256) {
        // forge-lint: disable-next-line(unsafe-typecast)
        uint256 absTick = tick < 0 ? uint256(uint24(-tick)) : uint256(uint24(tick));
        require(absTick <= 887_272, "Tick out of range");

        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
        if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
        if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
        if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;

        if (tick > 0) ratio = type(uint256).max / ratio;

        return (ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1);
    }

    /// @notice Get the price of one WHOLE priced-token expressed in QUOTE smallest units (raw quote wei).
    /// @dev sqrtPriceX96 = sqrt(token1_raw / token0_raw) * 2^96, where the ratio is in smallest units
    ///      (wei), so (sqrtPriceX96^2 / 2^192) is the dimensionless raw token1/token0 ratio.
    ///
    ///      INVARIANT: the returned `priceInQuote` MUST be denominated in raw quote-token units per
    ///      ONE WHOLE priced token, because `_getPriceData` finishes the conversion with
    ///        data.price = priceInQuote * quoteUsdPrice(18dp, per WHOLE quote token) / 10^quoteDecimals
    ///      which then yields an 18-decimal USD price per whole priced token. Concretely:
    ///        priceInQuote = rawRatio * 10^tokenDecimals
    ///      (the `quoteDecimals` cancel in the chain above; they MUST NOT appear here).
    ///
    ///      Two correctness requirements the previous implementation violated:
    ///      1) MULTIPLY-BEFORE-DIVIDE / no early >>192 truncation. The raw ratio is < 1 for almost
    ///         every real pair (e.g. an 18-dec token quoted in 6-dec USDC), so flooring it to an
    ///         integer before applying decimals produced 0. We fold the 10^tokenDecimals scale into
    ///         the division so the result keeps full precision, using 512-bit `Math.mulDiv` to avoid
    ///         the uint256 overflow of `sqrtPriceX96^2` at high ticks.
    ///      2) CORRECT decimal factor: scale by 10^tokenDecimals (NOT 10^quoteDecimals / 10^tokenDecimals).
    function _getPriceFromSqrtX96(
        uint256 sqrtPriceX96,
        bool isToken0,
        uint8 tokenDecimals,
        uint8 quoteDecimals
    )
        internal
        pure
        returns (uint256)
    {
        quoteDecimals; // unused: quote decimals cancel in the _getPriceData conversion chain.

        uint256 tokenScale = 10 ** tokenDecimals;

        if (isToken0) {
            // Priced token is token0, quote is token1.
            // priceInQuote = (sqrtPriceX96^2 / 2^192) * 10^tokenDecimals
            //             = mulDiv( mulDiv(sqrtPriceX96, sqrtPriceX96, Q96), 10^tokenDecimals, Q96 )
            // First mulDiv yields rawRatio * 2^96 (fits in uint256 across the full tick range);
            // second applies the token scale and the remaining 2^96 divisor with full precision.
            uint256 ratioX96 = Math.mulDiv(sqrtPriceX96, sqrtPriceX96, Q96);
            return Math.mulDiv(ratioX96, tokenScale, Q96);
        } else {
            // Priced token is token1, quote is token0.
            // priceInQuote = (2^192 / sqrtPriceX96^2) * 10^tokenDecimals
            //             = mulDiv( mulDiv(Q96, Q96, sqrtPriceX96), 10^tokenDecimals, sqrtPriceX96 )
            // Avoids both the uint256 overflow of sqrtPriceX96^2 and truncation-to-0 when price > 1.
            if (sqrtPriceX96 == 0) return 0;
            uint256 invX96 = Math.mulDiv(Q96, Q96, sqrtPriceX96); // = 2^192 / sqrtPriceX96
            return Math.mulDiv(invX96, tokenScale, sqrtPriceX96);
        }
    }
}

/// @title AggregatorV3Interface
/// @notice Chainlink interface for quote token price
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}
