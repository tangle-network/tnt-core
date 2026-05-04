// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IPriceOracle, IPriceOracleAdmin } from "./interfaces/IPriceOracle.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AggregatorV3Interface
/// @notice Chainlink price feed interface
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}

/// @title ISequencerUptimeFeed
/// @notice L2 sequencer uptime feed (e.g. Base canonical feed). `answer == 0` means the
///         sequencer is up; `answer == 1` means it is down or has just restarted.
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

/// @title ChainlinkOracle
/// @notice Price oracle using Chainlink price feeds
/// @dev Supports configurable feeds per token with staleness checks
contract ChainlinkOracle is IPriceOracle, IPriceOracleAdmin, Ownable {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Standard price precision (18 decimals)
    uint256 private constant PRICE_PRECISION = 1e18;

    /// @notice Default max price age (1 hour)
    uint256 private constant DEFAULT_MAX_AGE = 1 hours;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Token to Chainlink price feed mapping
    mapping(address => address) public priceFeeds;

    /// @notice Token decimals cache
    mapping(address => uint8) public tokenDecimals;

    /// @notice Maximum acceptable price age
    uint256 public maxAge;

    /// @notice Native token (ETH/MATIC) price feed
    address public nativeFeed;

    /// @notice Optional L2 sequencer uptime feed. When set, prices revert if the sequencer
    ///         is reported down or has been up for less than `sequencerGracePeriod`.
    address public sequencerUptimeFeed;

    /// @notice Required time the sequencer must have been up before prices are accepted.
    uint256 public sequencerGracePeriod;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Sequencer down or recently restarted (within grace period)
    error SequencerDown();

    /// @notice Sequencer feed reports a stalled round
    error StalePrice_Sequencer();

    /// @notice Chainlink round was emitted before its data was finalized
    error StaleRound(address token, uint80 roundId, uint80 answeredInRound);

    event SequencerUptimeFeedConfigured(address indexed feed, uint256 gracePeriod);

    constructor(address _nativeFeed) Ownable(msg.sender) {
        maxAge = DEFAULT_MAX_AGE;
        sequencerGracePeriod = 1 hours;
        if (_nativeFeed != address(0)) {
            nativeFeed = _nativeFeed;
            emit PriceFeedConfigured(address(0), _nativeFeed);
        }
    }

    /// @notice Configure the L2 sequencer uptime feed. Set to `address(0)` to disable on L1.
    /// @param feed Sequencer uptime feed address (Base mainnet: 0xBCF85224fc0756B9Fa45aA7892530B47e10b6433)
    /// @param gracePeriodSeconds Seconds the sequencer must have been up before prices are valid
    function setSequencerUptimeFeed(address feed, uint256 gracePeriodSeconds) external onlyOwner {
        require(gracePeriodSeconds > 0, "Invalid grace period");
        sequencerUptimeFeed = feed;
        sequencerGracePeriod = gracePeriodSeconds;
        emit SequencerUptimeFeedConfigured(feed, gracePeriodSeconds);
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
        if (token == address(0)) {
            return nativeFeed != address(0);
        }
        return priceFeeds[token] != address(0);
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

        // Normalize to 18 decimals: (amount * price) / 10^tokenDecimals
        // amount is in token decimals, price is in 18 decimals
        // Result is USD with 18 decimals
        return (amount * data.price) / (10 ** data.decimals);
    }

    /// @inheritdoc IPriceOracle
    // forge-lint: disable-next-line(mixed-case-function)
    function fromUSD(address token, uint256 usdValue) external view override returns (uint256 amount) {
        PriceData memory data = _getPriceData(token);
        if (!data.isValid) {
            revert PriceNotAvailable(token);
        }

        // Convert from USD to token amount
        // usdValue is in 18 decimals, result should be in token decimals
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
        return "Chainlink";
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IPriceOracleAdmin
    function configurePriceFeed(address token, address feed) external override onlyOwner {
        require(feed != address(0), "Invalid feed");

        priceFeeds[token] = feed;

        // Cache token decimals
        if (token != address(0)) {
            tokenDecimals[token] = IERC20Decimals(token).decimals();
        } else {
            tokenDecimals[token] = 18; // Native token
        }

        emit PriceFeedConfigured(token, feed);
    }

    /// @inheritdoc IPriceOracleAdmin
    function removePriceFeed(address token) external override onlyOwner {
        delete priceFeeds[token];
        delete tokenDecimals[token];
        emit PriceFeedConfigured(token, address(0));
    }

    /// @inheritdoc IPriceOracleAdmin
    function setMaxPriceAge(uint256 _maxAge) external override onlyOwner {
        require(_maxAge > 0, "Invalid max age");
        maxAge = _maxAge;
    }

    /// @inheritdoc IPriceOracleAdmin
    function setNativeTokenFeed(address feed) external override onlyOwner {
        nativeFeed = feed;
        tokenDecimals[address(0)] = 18; // Native token is always 18 decimals
        emit PriceFeedConfigured(address(0), feed);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _getPriceData(address token) internal view returns (PriceData memory data) {
        _requireSequencerUp();

        address feed = token == address(0) ? nativeFeed : priceFeeds[token];

        if (feed == address(0)) {
            revert TokenNotSupported(token);
        }

        AggregatorV3Interface aggregator = AggregatorV3Interface(feed);

        try aggregator.latestRoundData() returns (
            uint80 roundId, int256 answer, uint256, uint256 updatedAt, uint80 answeredInRound
        ) {
            if (answer <= 0) {
                revert InvalidPrice(token, answer);
            }

            // Reject stalled rounds where the answer was carried over from an older round.
            if (answeredInRound < roundId) {
                revert StaleRound(token, roundId, answeredInRound);
            }

            if (block.timestamp - updatedAt > maxAge) {
                revert StalePrice(token, updatedAt, maxAge);
            }

            // Get feed decimals and normalize to 18
            uint8 feedDecimals = aggregator.decimals();
            uint256 normalizedPrice;

            if (feedDecimals < 18) {
                // Casting is safe because Chainlink answers fit in uint256.
                // forge-lint: disable-next-line(unsafe-typecast)
                normalizedPrice = uint256(answer) * (10 ** (18 - feedDecimals));
            } else if (feedDecimals > 18) {
                // forge-lint: disable-next-line(unsafe-typecast)
                normalizedPrice = uint256(answer) / (10 ** (feedDecimals - 18));
            } else {
                // forge-lint: disable-next-line(unsafe-typecast)
                normalizedPrice = uint256(answer);
            }

            // Get token decimals
            uint8 tokDecimals = token == address(0) ? 18 : tokenDecimals[token];
            if (tokDecimals == 0 && token != address(0)) {
                tokDecimals = IERC20Decimals(token).decimals();
            }

            data.price = normalizedPrice;
            data.updatedAt = updatedAt;
            data.decimals = tokDecimals;
            data.isValid = true;
        } catch {
            data.isValid = false;
        }
    }

    /// @dev Reverts if the sequencer feed (when configured) reports the L2 sequencer
    ///      as down or recently restarted within `sequencerGracePeriod`.
    function _requireSequencerUp() internal view {
        address feed = sequencerUptimeFeed;
        if (feed == address(0)) return;

        (, int256 answer, uint256 startedAt,,) = ISequencerUptimeFeed(feed).latestRoundData();
        if (startedAt == 0) revert StalePrice_Sequencer();
        if (answer != 0) revert SequencerDown();
        if (block.timestamp - startedAt < sequencerGracePeriod) revert SequencerDown();
    }
}
