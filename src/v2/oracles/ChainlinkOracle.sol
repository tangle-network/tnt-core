// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPriceOracle, IPriceOracleAdmin} from "./interfaces/IPriceOracle.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title AggregatorV3Interface
/// @notice Chainlink price feed interface
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

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _nativeFeed) Ownable(msg.sender) {
        maxAge = DEFAULT_MAX_AGE;
        if (_nativeFeed != address(0)) {
            nativeFeed = _nativeFeed;
            emit PriceFeedConfigured(address(0), _nativeFeed);
        }
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
    function batchToUSD(
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external view override returns (uint256 totalUSD) {
        require(tokens.length == amounts.length, "Length mismatch");

        for (uint256 i = 0; i < tokens.length; i++) {
            if (amounts[i] > 0) {
                PriceData memory data = _getPriceData(tokens[i]);
                if (!data.isValid) {
                    revert PriceNotAvailable(tokens[i]);
                }
                totalUSD += (amounts[i] * data.price) / (10 ** data.decimals);
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
        address feed = token == address(0) ? nativeFeed : priceFeeds[token];

        if (feed == address(0)) {
            revert TokenNotSupported(token);
        }

        AggregatorV3Interface aggregator = AggregatorV3Interface(feed);

        try aggregator.latestRoundData() returns (
            uint80,
            int256 answer,
            uint256,
            uint256 updatedAt,
            uint80
        ) {
            // Validate price
            if (answer <= 0) {
                revert InvalidPrice(token, answer);
            }

            // Check staleness
            if (block.timestamp - updatedAt > maxAge) {
                revert StalePrice(token, updatedAt, maxAge);
            }

            // Get feed decimals and normalize to 18
            uint8 feedDecimals = aggregator.decimals();
            uint256 normalizedPrice;

            if (feedDecimals < 18) {
                normalizedPrice = uint256(answer) * (10 ** (18 - feedDecimals));
            } else if (feedDecimals > 18) {
                normalizedPrice = uint256(answer) / (10 ** (feedDecimals - 18));
            } else {
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
}
