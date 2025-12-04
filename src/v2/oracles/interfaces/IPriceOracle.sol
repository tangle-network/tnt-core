// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IPriceOracle
/// @notice Interface for price oracle adapters
/// @dev All prices are returned with 18 decimals (1 USD = 1e18)
/// Implementations should handle token decimals internally
interface IPriceOracle {
    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error PriceNotAvailable(address token);
    error StalePrice(address token, uint256 updatedAt, uint256 maxAge);
    error InvalidPrice(address token, int256 price);
    error TokenNotSupported(address token);

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when a price feed is configured
    event PriceFeedConfigured(address indexed token, address indexed feed);

    /// @notice Emitted when a price is updated (for push-based oracles)
    event PriceUpdated(address indexed token, uint256 price, uint256 timestamp);

    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Price data with metadata
    struct PriceData {
        uint256 price;          // Price in USD with 18 decimals
        uint256 updatedAt;      // Timestamp of last update
        uint8 decimals;         // Decimals of the underlying token
        bool isValid;           // Whether price is considered valid
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CORE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the USD price of a token
    /// @param token The token address (use address(0) for native ETH)
    /// @return price Price in USD with 18 decimals (1 USD = 1e18)
    /// @dev Reverts if price is not available or stale
    function getPrice(address token) external view returns (uint256 price);

    /// @notice Get price with full metadata
    /// @param token The token address
    /// @return data Full price data including validity and timestamp
    function getPriceData(address token) external view returns (PriceData memory data);

    /// @notice Check if a token is supported by this oracle
    /// @param token The token address
    /// @return supported True if the oracle can provide prices for this token
    function isTokenSupported(address token) external view returns (bool supported);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONVERSION FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Convert token amount to USD value
    /// @param token The token address
    /// @param amount The amount in token's native decimals
    /// @return usdValue USD value with 18 decimals
    function toUSD(address token, uint256 amount) external view returns (uint256 usdValue);

    /// @notice Convert USD value to token amount
    /// @param token The token address
    /// @param usdValue USD value with 18 decimals
    /// @return amount Token amount in token's native decimals
    function fromUSD(address token, uint256 usdValue) external view returns (uint256 amount);

    /// @notice Batch convert multiple token amounts to USD
    /// @param tokens Array of token addresses
    /// @param amounts Array of amounts in each token's native decimals
    /// @return totalUSD Total USD value with 18 decimals
    function batchToUSD(
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external view returns (uint256 totalUSD);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the maximum acceptable price age
    /// @return maxAge Maximum age in seconds before price is considered stale
    function maxPriceAge() external view returns (uint256 maxAge);

    /// @notice Get the oracle identifier/name
    /// @return name Human-readable oracle name (e.g., "Chainlink", "UniswapV3TWAP")
    function oracleName() external view returns (string memory name);
}

/// @title IPriceOracleAdmin
/// @notice Admin interface for configuring price oracles
interface IPriceOracleAdmin {
    /// @notice Configure a price feed for a token
    /// @param token The token address
    /// @param feed The price feed address (Chainlink aggregator, Uniswap pool, etc.)
    function configurePriceFeed(address token, address feed) external;

    /// @notice Remove a price feed configuration
    /// @param token The token address
    function removePriceFeed(address token) external;

    /// @notice Set the maximum acceptable price age
    /// @param maxAge Maximum age in seconds
    function setMaxPriceAge(uint256 maxAge) external;

    /// @notice Set the native token price feed (for ETH/MATIC/etc.)
    /// @param feed The price feed address
    function setNativeTokenFeed(address feed) external;
}
