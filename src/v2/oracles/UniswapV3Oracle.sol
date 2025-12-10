// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPriceOracle, IPriceOracleAdmin} from "./interfaces/IPriceOracle.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title IUniswapV3Pool
/// @notice Minimal Uniswap V3 pool interface for TWAP
interface IUniswapV3Pool {
    function slot0() external view returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext,
        uint8 feeProtocol,
        bool unlocked
    );

    function observe(uint32[] calldata secondsAgos) external view returns (
        int56[] memory tickCumulatives,
        uint160[] memory secondsPerLiquidityCumulativeX128s
    );

    function token0() external view returns (address);
    function token1() external view returns (address);
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
        address pool;           // Uniswap V3 pool address
        address quoteToken;     // Quote token (usually WETH or stablecoin)
        bool isToken0;          // True if token is token0 in the pool
        uint8 tokenDecimals;    // Token decimals
        uint8 quoteDecimals;    // Quote token decimals
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

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _weth) Ownable(msg.sender) {
        weth = _weth;
        twapPeriod = DEFAULT_TWAP_PERIOD;
        maxAge = 1 hours;
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
    ) external view override returns (uint256 totalUsd) {
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
    /// @param quoteFeed Chainlink feed for quote token USD price
    function configurePool(
        address token,
        address pool,
        address quoteFeed
    ) external onlyOwner {
        require(pool != address(0), "Invalid pool");

        IUniswapV3Pool uniPool = IUniswapV3Pool(pool);
        address token0 = uniPool.token0();
        address token1 = uniPool.token1();

        bool isToken0 = token == token0;
        require(isToken0 || token == token1, "Token not in pool");

        address quoteToken = isToken0 ? token1 : token0;

        poolConfigs[token] = PoolConfig({
            pool: pool,
            quoteToken: quoteToken,
            isToken0: isToken0,
            tokenDecimals: IERC20Decimals(token).decimals(),
            quoteDecimals: IERC20Decimals(quoteToken).decimals()
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

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _getPriceData(address token) internal view returns (PriceData memory data) {
        PoolConfig storage config = poolConfigs[token];

        if (config.pool == address(0)) {
            revert TokenNotSupported(token);
        }

        // Get TWAP tick
        int24 arithmeticMeanTick = _getArithmeticMeanTick(config.pool, twapPeriod);

        // Convert tick to price
        // price = 1.0001^tick * 10^(token1Decimals - token0Decimals)
        uint256 sqrtPriceX96 = _getSqrtPriceX96FromTick(arithmeticMeanTick);
        uint256 priceInQuote = _getPriceFromSqrtX96(
            sqrtPriceX96,
            config.isToken0,
            config.tokenDecimals,
            config.quoteDecimals
        );

        // Get quote token USD price if configured
        address quoteFeed = quoteTokenFeeds[config.quoteToken];
        uint256 quoteUsdPrice = PRICE_PRECISION; // Default 1:1 if no feed

        if (quoteFeed != address(0)) {
            // Assume Chainlink-style feed
            try AggregatorV3Interface(quoteFeed).latestRoundData() returns (
                uint80,
                int256 answer,
                uint256,
                uint256 updatedAt,
                uint80
            ) {
                if (answer > 0 && block.timestamp - updatedAt <= maxAge) {
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
                }
            } catch {
                // Use default 1:1 price
            }
        }

        // Final price in USD = priceInQuote * quoteUsdPrice / 10^quoteDecimals
        data.price = (priceInQuote * quoteUsdPrice) / (10 ** config.quoteDecimals);
        data.updatedAt = block.timestamp; // TWAP is always "fresh"
        data.decimals = config.tokenDecimals;
        data.isValid = true;
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
        require(absTick <= 887272, "Tick out of range");

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

    /// @notice Get price from sqrtPriceX96
    function _getPriceFromSqrtX96(
        uint256 sqrtPriceX96,
        bool isToken0,
        uint8 tokenDecimals,
        uint8 quoteDecimals
    ) internal pure returns (uint256) {
        // sqrtPriceX96 = sqrt(token1/token0) * 2^96
        // price = (sqrtPriceX96 / 2^96)^2
        // Adjust for decimals

        uint256 price;
        if (isToken0) {
            // Price of token0 in token1
            // price = (sqrtPriceX96)^2 / 2^192
            price = (sqrtPriceX96 * sqrtPriceX96) >> 192;
            // Adjust for decimals: multiply by 10^quoteDecimals, result in quote decimals
            price = (price * (10 ** quoteDecimals)) / (10 ** tokenDecimals);
        } else {
            // Price of token1 in token0
            // price = 2^192 / (sqrtPriceX96)^2
            uint256 sqrtSquared = (sqrtPriceX96 * sqrtPriceX96);
            if (sqrtSquared > 0) {
                price = (1 << 192) / sqrtSquared;
                price = (price * (10 ** quoteDecimals)) / (10 ** tokenDecimals);
            }
        }

        return price;
    }
}

/// @title AggregatorV3Interface
/// @notice Chainlink interface for quote token price
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}
